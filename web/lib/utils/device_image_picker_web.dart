// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

class DevicePickedImage {
  const DevicePickedImage({required this.dataUrl, required this.name});
  final String dataUrl;
  final String name;
}

Future<DevicePickedImage?> pickAndCompressImageFromDevice({
  int maxWidth = 800,
  double quality = 0.75,
}) async {
  final completer = Completer<DevicePickedImage?>();
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/png,image/jpeg,image/webp,image/jpg'
    ..multiple = false;

  uploadInput.click();

  uploadInput.onChange.listen((e) async {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final file = files[0];
    try {
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      await reader.onLoad.first;
      final rawDataUrl = reader.result as String;

      final img = html.ImageElement(src: rawDataUrl);
      await img.onLoad.first;

      int width = img.width ?? 800;
      int height = img.height ?? 450;
      if (width > maxWidth) {
        height = (height * (maxWidth / width)).round();
        width = maxWidth;
      }

      final canvas = html.CanvasElement(width: width, height: height);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, width, height);

      final compressedDataUrl = canvas.toDataUrl('image/jpeg', quality);
      if (!completer.isCompleted) {
        completer.complete(
          DevicePickedImage(
            dataUrl: compressedDataUrl,
            name: file.name,
          ),
        );
      }
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    }
  });

  return completer.future;
}
