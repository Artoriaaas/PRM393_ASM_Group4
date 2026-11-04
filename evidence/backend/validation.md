# Kết quả kiểm tra — 01/11/2026

> Các kết quả bên dưới là lịch sử của phương án Functions/Storage cũ. Kiến trúc hiện tại chuyển sang Firestore transaction trực tiếp và Cloudinary Free; xem cập nhật 04/11 ở cuối, không dùng 4 ca cũ làm bằng chứng cho phương án mới.

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


Cập nhật 03/11/2026: chạy lại toàn bộ `flutter test`, **59/59 pass** sau sửa Khám phá. Firebase CLI truy cập được project nhóm; emulator online. Chưa xác nhận billing/Storage/Functions triển khai. Chưa có cấu hình ARTEMIS trong môi trường chạy hiện tại; `.env.example` chỉ chứa tên biến và giá trị mẫu, không chứa credential. Các hạng mục cloud/E2E/PR/report còn giữ trạng thái chờ bằng chứng.

03/11/2026: chạy lại Firestore + Storage emulator, **4/4 integration tests pass** (CLI exit0); runtime Storage có cảnh báo Java deprecated và lỗi lúc shutdown sau khi tests đã pass. Đã sửa đường dẫn Rules độc lập cwd và lệnh test bật đủ hai emulator. Có script tool/deploy-cloud.ps1, chưa chạy cloud do chủ project xác nhận chưa liên kết billing. ARTEMIS chưa có host/model key.

## Cập nhật 04/11/2026 — kiến trúc hiện tại

- `flutter test`: **62/62 pass**; `flutter analyze`: không có issue.
- Firestore Rules emulator `functions/integration/direct-firestore.test.js`: **4/4 pass**. Đã kiểm tra đăng ký nguyên tử, không ghi tăng chỗ riêng lẻ, không ghi thay người khác, hủy giảm chỗ, đăng ký lại tăng generation, tài khoản chưa xác minh bị chặn, QR giả bị từ chối, QR web tạo và phiên mở điểm danh được đúng một lần.
- Firebase CLI deploy `firestore:rules,firestore:indexes` lên đúng project `eventhub-group4`: exit 0, Rules compile thành công. Không deploy Functions/Storage.
- Cloudinary adapter test mock **2/2 pass**, chưa upload thật vì nhóm chưa tạo account/preset. Android APK build mới đang được kiểm tra; kết quả chỉ ghi sau khi lệnh hoàn tất.
- Chưa có bằng chứng E2E nghiệp vụ trên cloud, ARTEMIS, FCM ba trạng thái, Analytics DebugView đủ event, Crashlytics dashboard, Cloudinary Media Library, PR AI review, báo cáo/video.
