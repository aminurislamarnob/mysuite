import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../widgets/common.dart';

/// What the user chose to do with a person's photo.
sealed class AvatarChoice {
  const AvatarChoice();
}

/// A cropped image, ready to hand to `PeopleRepository.setPhoto`.
class AvatarPicked extends AvatarChoice {
  final File file;
  const AvatarPicked(this.file);
}

/// The existing photo should go.
class AvatarCleared extends AvatarChoice {
  const AvatarCleared();
}

/// Offers camera, gallery and — when there is something to remove — a way to
/// clear the photo. Returns null if the sheet was dismissed or the picker
/// cancelled.
///
/// [hasPhoto] decides whether the remove row is offered at all, rather than
/// showing a row that does nothing.
Future<AvatarChoice?> pickAvatar(
  BuildContext context, {
  required bool hasPhoto,
}) async {
  final action = await brandSheet<String>(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: 'Photo',
      child: TileColumn(
        children: [
          BrandTile(
            leading: const AppIcon(AppIcons.camera),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(sheetContext, 'camera'),
          ),
          BrandTile(
            leading: const AppIcon(AppIcons.gallery),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(sheetContext, 'gallery'),
          ),
          if (hasPhoto)
            BrandTile(
              leading: const AppIcon(
                AppIcons.delete,
                color: AppColors.dangerLight,
              ),
              title: const Text(
                'Remove photo',
                style: TextStyle(color: AppColors.dangerLight),
              ),
              onTap: () => Navigator.pop(sheetContext, 'remove'),
            ),
        ],
      ),
    ),
  );

  if (action == null) return null;
  if (action == 'remove') return const AvatarCleared();

  final picked = await ImagePicker().pickImage(
    source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
    // Cropping happens next, so this is only a ceiling on what gets decoded.
    maxWidth: 1440,
    maxHeight: 1440,
    imageQuality: 90,
  );
  if (picked == null) return null;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    // Every avatar in the app is a circle, so a free-form crop would only let
    // the user frame something the UI then cuts differently.
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    maxWidth: 512,
    maxHeight: 512,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 85,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop photo',
        toolbarColor: AppColors.coral,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: AppColors.coral,
        cropStyle: CropStyle.circle,
        lockAspectRatio: true,
        hideBottomControls: true,
      ),
      IOSUiSettings(
        title: 'Crop photo',
        cropStyle: CropStyle.circle,
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ],
  );
  if (cropped == null) return null;

  return AvatarPicked(File(cropped.path));
}
