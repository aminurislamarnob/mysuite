import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';

enum ScanMode { receipt, prescription }

/// What the OCR pass managed to pull out of the image.
@immutable
class ScanResult {
  final String rawText;
  final String? imagePath;

  // Receipt fields
  final double? amount;
  final String? merchant;

  // Prescription fields
  final String? medicineName;
  final String? dosage;
  final int? timesPerDay;
  final int? durationDays;

  const ScanResult({
    required this.rawText,
    this.imagePath,
    this.amount,
    this.merchant,
    this.medicineName,
    this.dosage,
    this.timesPerDay,
    this.durationDays,
  });
}

/// On-device OCR over a captured photo, using ML Kit.
class CameraScanScreen extends StatefulWidget {
  final ScanMode mode;
  const CameraScanScreen({super.key, required this.mode});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  final _recognizer = TextRecognizer();
  final _picker = ImagePicker();

  bool _busy = false;
  String? _error;
  ScanResult? _result;
  String? _imagePath;

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final photo = await _picker.pickImage(source: source, imageQuality: 90);
      if (photo == null) {
        setState(() => _busy = false);
        return;
      }
      _imagePath = photo.path;

      final recognized =
          await _recognizer.processImage(InputImage.fromFilePath(photo.path));
      final text = recognized.text;

      if (text.trim().isEmpty) {
        setState(() {
          _busy = false;
          _error = 'No text found. Try a sharper, better-lit photo.';
        });
        return;
      }

      setState(() {
        _busy = false;
        _result = widget.mode == ScanMode.receipt
            ? ReceiptParser.parse(text, _imagePath)
            : PrescriptionParser.parse(text, _imagePath);
      });
    } on Exception catch (e) {
      setState(() {
        _busy = false;
        _error = 'Scan failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceipt = widget.mode == ScanMode.receipt;

    return Scaffold(
      appBar: AppBar(
        title: Text(isReceipt ? 'Scan receipt' : 'Scan prescription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _busy
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Reading the image…'),
                  ],
                ),
              )
            : _result != null
                ? _buildResult(_result!, isReceipt)
                : _buildPrompt(isReceipt),
      ),
    );
  }

  Widget _buildPrompt(bool isReceipt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isReceipt
                ? Icons.receipt_long_outlined
                : Icons.medical_information_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 20),
          Text(
            isReceipt
                ? 'Point at a receipt to pull out the total'
                : 'Point at a prescription to pre-fill the schedule',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.dangerLight)),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _scan(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Take a photo'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => _scan(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose from gallery'),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(ScanResult r, bool isReceipt) {
    final rows = isReceipt
        ? <(String, String?)>[
            ('Amount', r.amount?.toStringAsFixed(2)),
            ('Merchant', r.merchant),
          ]
        : <(String, String?)>[
            ('Medicine', r.medicineName),
            ('Dosage', r.dosage),
            ('Times per day', r.timesPerDay?.toString()),
            ('Duration', r.durationDays == null ? null : '${r.durationDays} days'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(File(_imagePath!),
                height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
        const SizedBox(height: 16),
        const Text('What we found',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        ...rows.map((row) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(row.$1),
              trailing: Text(
                row.$2 ?? 'not detected',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: row.$2 == null
                      ? Theme.of(context).colorScheme.outline
                      : null,
                ),
              ),
            )),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Raw text', style: TextStyle(fontSize: 13)),
          children: [
            Text(r.rawText, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _result = null;
                  _imagePath = null;
                }),
                child: const Text('Rescan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context, r),
                child: const Text('Use these details'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Extracts a total and merchant name from receipt OCR text.
class ReceiptParser {
  const ReceiptParser._();

  static ScanResult parse(String text, String? imagePath) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    double? amount;

    // Prefer a line that explicitly names the total.
    for (final line in lines.reversed) {
      if (!RegExp(r'\b(grand\s+total|total|amount|due|payable)\b',
              caseSensitive: false)
          .hasMatch(line)) {
        continue;
      }
      final value = _lastNumber(line);
      if (value != null) {
        amount = value;
        break;
      }
    }

    // Otherwise fall back to the largest number on the receipt, which is
    // almost always the total.
    amount ??= lines
        .map(_lastNumber)
        .whereType<double>()
        .fold<double?>(null, (max, v) => max == null || v > max ? v : max);

    // The merchant is conventionally the first substantial line.
    final merchant = lines
        .take(4)
        .where((l) => l.length > 3 && !RegExp(r'^\d').hasMatch(l))
        .firstOrNull;

    return ScanResult(
      rawText: text,
      imagePath: imagePath,
      amount: amount,
      merchant: merchant,
    );
  }

  static double? _lastNumber(String line) {
    final matches =
        RegExp(r'(\d[\d,]*(?:\.\d{1,2})?)').allMatches(line).toList();
    if (matches.isEmpty) return null;
    return double.tryParse(matches.last.group(1)!.replaceAll(',', ''));
  }
}

/// Extracts medicine name, dose and course length from prescription OCR text.
class PrescriptionParser {
  const PrescriptionParser._();

  static ScanResult parse(String text, String? imagePath) {
    final lower = text.toLowerCase();

    // "500mg", "5 ml", "10 mcg"
    final dosage = RegExp(r'(\d+(?:\.\d+)?)\s*(mg|ml|mcg|g|iu)\b',
            caseSensitive: false)
        .firstMatch(text)
        ?.group(0);

    // A medicine name usually sits immediately before its strength.
    String? name;
    final nameMatch = RegExp(
            r'([A-Z][A-Za-z\-]{2,})\s+\d+(?:\.\d+)?\s*(?:mg|ml|mcg|g|iu)\b')
        .firstMatch(text);
    if (nameMatch != null) {
      name = nameMatch.group(1);
    } else {
      // Fall back to the first capitalised word after an Rx marker.
      final rx = RegExp(r'(?:rx|tab|cap|syp)[.:\s]+([A-Za-z][A-Za-z\-]{2,})',
              caseSensitive: false)
          .firstMatch(text);
      name = rx?.group(1);
    }

    // Frequency: "twice daily", "3 times a day", or the 1+0+1 convention.
    int? timesPerDay;
    if (RegExp(r'\bonce\b').hasMatch(lower)) timesPerDay = 1;
    if (RegExp(r'\btwice\b').hasMatch(lower)) timesPerDay = 2;
    if (RegExp(r'\b(thrice|three times)\b').hasMatch(lower)) timesPerDay = 3;

    final timesMatch =
        RegExp(r'(\d+)\s*times?\s*(?:a|per)?\s*day').firstMatch(lower);
    if (timesMatch != null) {
      timesPerDay = int.tryParse(timesMatch.group(1)!);
    }

    // The South-Asian "1+0+1" dosing notation: count the non-zero slots.
    final plusNotation =
        RegExp(r'\b([01])\s*\+\s*([01])\s*\+\s*([01])\b').firstMatch(lower);
    if (plusNotation != null) {
      timesPerDay = [1, 2, 3]
          .map((i) => plusNotation.group(i))
          .where((g) => g != '0')
          .length;
    }

    // Course length: "for 7 days", "for 2 weeks".
    int? durationDays;
    final dayMatch = RegExp(r'for\s+(\d+)\s*day').firstMatch(lower);
    final weekMatch = RegExp(r'for\s+(\d+)\s*week').firstMatch(lower);
    if (dayMatch != null) {
      durationDays = int.tryParse(dayMatch.group(1)!);
    } else if (weekMatch != null) {
      final weeks = int.tryParse(weekMatch.group(1)!);
      durationDays = weeks == null ? null : weeks * 7;
    }

    return ScanResult(
      rawText: text,
      imagePath: imagePath,
      medicineName: name,
      dosage: dosage,
      timesPerDay: timesPerDay,
      durationDays: durationDays,
    );
  }
}
