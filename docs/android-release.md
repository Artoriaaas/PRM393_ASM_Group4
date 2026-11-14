# Build Android release trên máy nhóm

Dùng bản release ký bằng khóa nhóm; không dùng debug signing làm fallback.

Khôi phục riêng `mobile/android/key.properties`, `mobile/android/app/eventhub-release.jks` và cấu hình Firebase Android trước khi build. Các file này được Git bỏ qua, không gửi mật khẩu/keystore lên repo.

`key.properties` cần storeFile (đường dẫn tương đối từ android/app), storePassword, keyAlias, keyPassword. Dùng cùng keystore cho các lần cập nhật APK. Lưu bản sao bảo mật của khóa nhóm; không tạo lại khóa tùy tiện.

Từ mobile: `flutter build apk --release -t lib/main.dart`. APK ở `mobile/build/app/outputs/flutter-apk/app-release.apk`. Chuyển APK riêng và cài trên thiết bị Android thật để xác nhận Google sign-in, App Check, Firestore, camera, thông báo và các luồng liên vai trò. Build thành công không thay cho kiểm thử thiết bị thật.
