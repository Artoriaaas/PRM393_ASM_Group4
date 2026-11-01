# Kết quả kiểm tra — 01/11/2026

- Flutter: **55/55 tests pass**: auth/router, duplicate submit/recovery/UID isolation, 360/412dp và text lớn, profile, PDF tiếng Việt, cloud settings và startup retry.
- Backend domain: **8/8 pass**. Node runtime local khác Node22 deploy target; không coi domain test là kiểm chứng runtime cloud.
- Emulator đã chạy: **4/4 integration pass**, gồm Firestore transaction/rules và Storage ownership/PDF MIME.
- PDF fixture tạo 9 trang, kiểm tra text tiếng Việt bằng pypdf.
- Android debug với Firebase SDK đã build/cài, restore phiên Google và fetch Remote Config thành công. Ảnh không có PII: `../cloud/remote-config-fetch-android.png`. Native Analytics đã thấy remote_config_fetch trong debug log; chưa có đủ DebugView từng event.
- Firestore Rules/indexes và Remote Config defaults 10/true đã deploy lên eventhub-group4. Không bật billing.
- ARTEMIS: 25 ca được collect nhưng skip do thiếu host/test credentials; **không phải 25 ca pass**.

Còn thiếu: Functions/Storage deploy, dữ liệu và QR web CLB thật, camera/FCM ba trạng thái, Remote Config thay giá trị before/after, Crashlytics dashboard, ARTEMIS 3 lượt và Pro, AI review PR, báo cáo/video. Xem `../../docs/lab3-readiness.md`.

## Lịch sử kiểm tra nền

- 31/10: auth 30 tests pass, prototype 35 tests pass; smoke 19 route tại 360/412dp. Đây là lịch sử local, không phải cloud proof.
- Android từng lỗi Kotlin incremental cache giữa ổ C/D; cấu hình kotlin.incremental=false đã khắc phục.
- 01/11: sau sửa Khám phá chạy 7/7 tests liên quan pass; analyze sạch, build/cài APK thành công. Chưa chạy lại toàn suite sau thay đổi này.
