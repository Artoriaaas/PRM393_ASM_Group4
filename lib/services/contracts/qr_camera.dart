/// Camera operations; no widgets or Firebase SDK escape this interface.
abstract interface class QrCamera {
  Object get previewHandle;
  Stream<String> get errors;
  Future<void> start();
  Future<void> stop();
  Future<void> openSettings();
  Future<void> dispose();
}
