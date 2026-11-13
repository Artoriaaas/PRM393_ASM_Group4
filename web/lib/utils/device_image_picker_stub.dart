class DevicePickedImage {
  const DevicePickedImage({required this.dataUrl, required this.name});
  final String dataUrl;
  final String name;
}

Future<DevicePickedImage?> pickAndCompressImageFromDevice({
  int maxWidth = 800,
  double quality = 0.75,
}) async {
  return null;
}
