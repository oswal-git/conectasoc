import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  Future<Uint8List?> pickImage(BuildContext context) async {
    // Extraer los datos del BuildContext ANTES del primer 'await'.
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final source = await _showImageSourceActionSheet(context, l10n);
    if (source == null) return null; // User cancelled

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return null;

    // Another mounted check is needed here before using context again.
    if (!context.mounted) return null;

    // Pasamos los datos extraídos en lugar del BuildContext completo.
    final croppedFile = await _cropImage(
      l10n: l10n,
      theme: theme,
      filePath: pickedFile.path,
      context: context, // Pasamos el contexto para WebUiSettings
    );

    if (croppedFile != null) {
      return await croppedFile.readAsBytes();
    }
    return null;
  }

  Future<ImageSource?> _showImageSourceActionSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      // Use a different name for the builder's context to avoid shadowing.
      builder: (builderContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () =>
                  Navigator.of(builderContext).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.camera),
              onTap: () => Navigator.of(builderContext).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<CroppedFile?> _cropImage({
    required AppLocalizations l10n,
    required ThemeData theme,
    required String filePath,
    required BuildContext context,
  }) async {
    return _cropper.cropImage(
      sourcePath: filePath,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: l10n.cropImage,
            toolbarColor: theme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]),
        IOSUiSettings(
          title: l10n.cropImage,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
        if (kIsWeb)
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 520, height: 520),
            viewwMode: WebViewMode.mode_1,
            dragMode: WebDragMode.crop,
            // Opciones adicionales para una mejor experiencia de usuario en web
            center: true,
            guides: true,
            scalable: true,
            zoomable: true,
            cropBoxResizable: true,
            cropBoxMovable: true,
          ),
      ],
    );
  }
}
