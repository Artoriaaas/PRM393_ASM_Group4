# Bước 4 — Nhật ký kiểm tra 31/10/2026

## Phạm vi đã kiểm tra

- `flutter analyze`: pass sau sửa lint, không còn issue.
- `flutter test`: **30/30 pass** sau sửa test cuộn tới trường nhập trong ListView lazy và chờ scroll animation trước khi bấm nút.
- Test VM: validation tại field, không gọi service khi input sai, khóa gửi trùng, giữ email khi network failure, reset chỉ xác nhận sau service success, Google cancellation, thiếu config không đăng nhập giả.
- Test UI: login/register/reset/verify/change-email ở 360 và 412 dp với text scale 200%; không overflow trong các viewport đã kiểm tra.
- Test cũ: auth redirects, tab navigation, button/dialog/text field và responsive vẫn pass.
- Đã lấy design context và screenshot trực tiếp cho A01a–d; tải icon Figma về local, không dùng asset URL tạm ở runtime.
- Đã cài và mở APK trên Android emulator API 35. Kiểm tra trực quan [màn login khi chưa cấu hình](../evidence/step4/login-unconfigured.png): hiện form, Google button và thông báo chưa kết nối. Đã sửa icon password về mép phải với vùng chạm 48 dp, chạy lại 30/30 test và build APK pass. Ảnh này không chứng minh OAuth hoạt động.

## Lỗi môi trường đã phát hiện

Build Android đầu tiên thất bại ở Kotlin incremental caches: source của plugin trên C:, root app trên D:, lỗi `this and base files have different roots`. Đã thêm `kotlin.incremental=false` trong `android/gradle.properties`; **build lại `flutter build apk --debug` đã pass** và tạo `build/app/outputs/flutter-apk/app-debug.apk`. SDK Platform 34 đã được Gradle cài theo dependency. Flutter còn cảnh báo Firebase plugins dùng Kotlin Gradle Plugin cũ; hiện không chặn build, cần theo dõi khi nâng Flutter/plugin.

## Chưa được chứng minh

Lần mở đầu trên emulator giữ splash khi Firebase chưa có cấu hình. Đã thêm timeout 10 giây cho bootstrap để không chờ Firebase vô hạn, build lại APK pass. Việc timeout chỉ báo chưa kết nối, không tạo project hoặc phiên giả; cần khởi động lại app sau khi thêm cấu hình hợp lệ.

Nhóm chưa có Firebase project ở thời điểm triển khai. Chưa có `google-services.json`/project ID thật, chưa chạy FlutterFire CLI, chưa xác nhận đăng nhập Google/email, gửi thư, reset, đổi email hoặc Users console. Test dùng fake service không thay thế test Firebase. Chưa deploy Firestore rules. Chưa đánh dấu bước 4 hoàn tất.
