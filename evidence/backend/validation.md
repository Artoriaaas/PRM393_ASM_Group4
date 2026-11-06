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

## Cập nhật 07/11/2026 — Hoàn thành Đồng bộ Liên Vai Trò (Cross-Role Flows & Shared Core)

- **Shared Core Package (`packages/core/`)**: Đã hoàn tất cutover 100% import trên toàn bộ Mobile (`lib/`, `test/`) và Web (`web/`) sang `package:eventhub_core/eventhub_core.dart`. Đã xóa sạch 36 file duplicate trong `lib/{theme,models,utils,services/contracts,widgets/app_*}`.
- **Firestore Security Rules (`firebase/firestore.rules`)**:
  - Nâng cấp bộ rules phân quyền 3 vai trò (`user`, `staff`, `admin`) với đầy đủ helper: `isUser()`, `isStaffOf(clubId)`, `isAdmin()`.
  - Bảo vệ luồng `pending -> approved` (chỉ `staff`/`admin` được duyệt và tăng nguyên tử `activeCount + 1 <= capacity` + gửi inbox notification).
  - Bảo vệ luồng `pending -> rejected` (bắt buộc lý do từ chối 3..300 ký tự, `activeCount` giữ nguyên + gửi inbox notification).
  - Bảo vệ luồng hủy đơn: hủy đơn `pending` không đổi `activeCount`; hủy đơn `approved` giảm nguyên tử `activeCount - 1`.
  - Bảo vệ phiên QR: mở/đóng phiên `checkinSessions`, tạo & xoay mã băm SHA-256 `qrCredentials`, chặn sinh viên chưa duyệt quét QR, chặn quét lặp và chặn quét sau khi đóng phiên hoặc xoay mã.
  - Bảo vệ thông báo CLB `announcements`: chỉ `staff` cùng `clubId` hoặc `admin` mới được tạo; cấm người dùng tạo thông báo mạo danh.
  - Bảo vệ tài khoản `users/{uid}`: sinh viên tự tạo hồ sơ `role == 'user'`; cấm người dùng tự leo quyền; `admin` không được tự đổi role của chính mình.
- **Kiểm thử Firestore Emulator (`firebase/tests/direct-firestore.test.js`)**: **5/5 ca test pass 100% (exit 0)** bao phủ đầy đủ cả ca Allowed và Denied cho tất cả các role trên mọi collection.
- **Kiểm thử Mobile (`test/`)**: **61/61 tests pass 100%** bao gồm các ca kiểm tra chặn vai trò quản trị trên mobile (`MobileRoleRejectionScreen`), hiển thị lý do từ chối và cho phép đăng ký lại sau khi hủy/từ chối.
- **Kiểm thử Web (`web/test/`)**: **12/12 tests pass 100%**; `flutter build web` thành công.
- **Linter**: `flutter analyze` đạt **0 lỗi, 0 cảnh báo** trên toàn bộ `lib`, `test`, `packages/core` và `web`.
