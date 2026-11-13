# Firebase setup — Final

Dùng chung project **eventhub-group4** cho mobile user và web staff/admin. Không tạo project riêng cho từng teammate. Firebase Console là nơi cấp cấu hình, không đưa secret vào app/repo.

## Android

1. Android package `com.eventhub.app`; config tải từ Project settings, đặt `mobile/android/app/google-services.json` (gitignored).
2. Thêm SHA-1/SHA-256 của máy/chữ ký thực chạy. Chạy `./gradlew.bat signingReport` trong `mobile/android/` để lấy; không sao chép fingerprint máy khác.
3. Authentication bật Google Sign-In và support email. Email/password chỉ giữ cho flow A01 kế thừa nếu nhóm dùng, không thay thế yêu cầu Google.
4. App Check đăng ký provider/token đúng máy theo [mobile setup](mobile-setup.md); xác nhận requests verified, phối hợp web trước enforcement.

## Web

Config public từ Firebase Web app, tạo `web/web_env.json` local theo các tên trong `.env.example`; không có service account/API secret. Code đọc dart-define qua web/lib/services/web_firebase_bootstrap.dart. App Check web cần reCAPTCHA site key riêng, authorized domains cho localhost và domain deployment.

```powershell
cd web
flutter pub get --enforce-lockfile
flutter run -d chrome -t lib/main.dart --dart-define-from-file=web_env.json
flutter build web -t lib/main.dart --dart-define-from-file=web_env.json
```

Ở gốc repo, Hosting lấy `web/build/web` theo firebase.json. Chỉ deploy khi cấu hình/test đã xác nhận; không tự bật enforcement hoặc thay đổi tài khoản Console. Kiểm tra URL trong cửa sổ ẩn danh sau deploy.

## Roles, dữ liệu và Rules

- User profile tự tạo role user; Admin đầu tiên phải được chủ project đặt trên Console và ghi trong README. Chưa biết tài khoản thì để chưa xác nhận, không tự chọn.
- Staff được admin gán clubId. Mobile không quản lý vai trò, mở QR hoặc duyệt đơn.
- Dữ liệu và transitions: [data model](data-model.md); emulator/tests: firebase/tests/README.md. Không chạy script seed tự động khi mở app.
- Không Cloud Functions, Cloud Storage, App Hosting, Cloudinary hay custom server. PDF lưu/share trên máy, metadata riêng Firestore.
- FCM, Analytics, RC, Crashlytics tiếp tục theo Lab 3; xem [analytics plan](analytics-plan.md), [test plan](test-plan.md). Inbox từ web không đồng nghĩa push tự động.
