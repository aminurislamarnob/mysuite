import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_provider.dart';

/// The model's raw text answer and which model actually produced it.
class AiRawResponse {
  final String text;
  final String model;

  const AiRawResponse({required this.text, required this.model});
}

/// One provider behind one method. Each implementation knows its endpoint,
/// its headers and how to ask for JSON that matches [schema]; nothing above
/// this interface knows which vendor is on the other end.
abstract class AiClient {
  AiProvider get provider;
  String get model;

  Future<AiRawResponse> complete({
    required String system,
    required String user,
    required Map<String, Object?> schema,
  });
}

/// Base type: the message is safe to show in a toast.
class AiException implements Exception {
  final String message;

  const AiException(this.message);

  @override
  String toString() => 'AiException: $message';
}

/// 401 or 403: the key is missing, wrong, or for the wrong provider.
class AiAuthException extends AiException {
  const AiAuthException(super.message);
}

/// 429: over quota or rate limited; worth retrying later.
class AiRateLimitException extends AiException {
  const AiRateLimitException(super.message);
}

/// The provider declined to answer on policy grounds.
class AiRefusalException extends AiException {
  const AiRefusalException(super.message);
}

/// Could not reach the provider, or it failed on its side.
class AiNetworkException extends AiException {
  const AiNetworkException(super.message);
}

/// The provider answered, but not with something the parser can use.
class AiMalformedException extends AiException {
  const AiMalformedException(super.message);
}

/// The one HTTP call every client makes, with status codes mapped to the
/// exceptions above so the screen can pick a remedy without inspecting
/// vendor-specific bodies.
class AiHttp {
  const AiHttp._();

  static const timeout = Duration(seconds: 30);

  static Future<Map<String, Object?>> postJson(
    http.Client client,
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    http.Response response;
    try {
      response = await client
          .post(
            uri,
            headers: {
              ...headers,
              // Some proxies drop a body whose charset is not spelled out.
              'content-type': 'application/json; charset=utf-8',
              'accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AiNetworkException('The request timed out.');
    } on http.ClientException catch (e) {
      throw AiNetworkException(e.message);
    }

    final decoded = _decode(response);
    final status = response.statusCode;
    if (status >= 200 && status < 300) return decoded;

    final message = _errorMessage(decoded) ?? 'HTTP $status';
    if (status == 401 || status == 403) throw AiAuthException(message);
    if (status == 429) throw AiRateLimitException(message);
    if (status >= 500) throw AiNetworkException(message);
    throw AiException(message);
  }

  static Map<String, Object?> _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (text.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      return decoded is Map ? Map<String, Object?>.from(decoded) : const {};
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw const AiMalformedException('The reply was not JSON.');
      }
      return const {};
    }
  }

  /// All four providers report `{"error": {"message": "..."}}`; Gemini also
  /// carries a `status` string worth showing when the message is empty.
  static String? _errorMessage(Map<String, Object?> body) {
    final error = body['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
      final status = error['status'];
      if (status is String && status.isNotEmpty) return status;
    } else if (error is String && error.isNotEmpty) {
      return error;
    }
    return null;
  }
}
