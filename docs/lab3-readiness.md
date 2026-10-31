# Trạng thái bàn giao Lab 3

01/11/2026. Đây là bảng thực trạng, không phải tuyên bố đã hoàn tất bài nộp.

| Phần | Đã có | Còn cần |
|---|---|---|
| Thiết kế/kiến trúc | Traceability A01–A12, MVVM, theme/component, quyết định khác biệt | Đồng bộ các thay đổi Lab 3 lên Figma và duyệt ảnh trước/sau |
| Auth | Config project nhóm, adapter Google/password/verify/reset, chủ dự án xác nhận Google; native restore phiên | đủ nhánh hủy/lỗi/logout/Users console |
| F1/F2/F4A | UI thật, Firestore services, callable transaction ledger/generation/QR, camera adapter, recovery và test | deploy Functions, nguồn event và QR từ web CLB thật, test cloud và native |
| Firestore | Database đúng region; Rules/indexes test emulator và deploy cloud | dữ liệu CLB được phép dùng và E2E |
| Profile | Name thật; Google email read-only, password email reauth/verify, giữ snapshot đăng ký | kiểm thử sửa email/reauth cloud và cập nhật Figma |
| PDF/Storage | Sinh PDF tiếng Việt thật, upload/progress/URL adapter, Storage rules test emulator | bucket/billing/deploy và console/file proof |
| Analytics | Plan ≥7 events, user ID, adapter/trigger, native remote_config_fetch đã thấy | từng event DebugView và ảnh console |
| Remote Config | defaults + hai tham số, fetch/activate và UI behavior, fetch native đã thành công; defaults 10/true đã publish | before/after thay giá trị trên cloud và console đầy đủ |
| Crashlytics | fatal handler redacted, non-fatal nhánh lỗi thật + test action, debug crash confirmation | dashboard non-fatal và crash thật; chưa chủ động crash app trong phiên này |
| FCM | permission, register/unregister SDK17/FID, foreground + background/terminated handlers, owner device rules, server trigger | deploy Functions, permissions/FID cloud và bằng chứng ba trạng thái |
| ARTEMIS | 25 ca/pin commit, Flash assertions + trace output, Pro opt-in script | host/model/fixtures, mỗi ca3 lần, pass rates và Pro15–30 phút thật |
| AI review | Findings local và giới hạn được ghi rõ | PR review thật, đầu ra, ≥3 fix commits theo findings |
| Report/slide/video | Checklist nội dung và nguồn bằng chứng | chỉ hoàn tất sau cloud/E2E/review; chưa có PDF/video giả |

## Các đầu vào đang thiếu

1. Quyết định billing của chủ project: chưa tự bật Blaze hay liên kết thẻ. Không thay dịch vụ bắt buộc nếu thầy chưa đồng ý.
2. Nguồn event/QR CLB được phép dùng; mobile không tạo/mở phiên hoặc điều khiển web CLB.
3. Host ARTEMIS/model và tài khoản/fixtures test riêng. Không dùng tài khoản cá nhân hoặc tự tiêu phí API.
4. PR/AI review và bằng chứng console thật để viết báo cáo cuối.

Đọc `backend-setup.md`, `analytics-plan.md`, `test-plan.md`, `code-review.md` và `e2e_test/README.md`. UI prototype vẫn có entrypoint riêng; app thật chạy `flutter run -t lib/main.dart`.
