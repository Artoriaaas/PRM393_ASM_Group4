# Tiến độ Lab 3 — EventHub Group 4

Cập nhật 04/11/2026. Đây là trạng thái có bằng chứng; **chưa phải xác nhận bài nộp hoàn thành**. Flutter app thật chạy `lib/main.dart`, prototype offline chạy `lib/main_prototype.dart`.

| Yêu cầu | Đã có / đã kiểm tra | Chưa hoàn tất hoặc cần bằng chứng |
|---|---|---|
| Final UI và 3 flow | A01–A12, F1/F2/F4A, state lỗi, MVVM; 62 Flutter tests qua, `flutter analyze` sạch | So ảnh Figma và Android cuối cùng; test thao tác E2E trên máy thật/emulator |
| Auth | Google/email/password/verify/reset và guard; Google login thật đã được chủ project xác nhận | Bằng chứng đủ nhánh lỗi/hủy và Users console cho bài nộp |
| Firestore nghiệp vụ | Đăng ký/hủy transaction, chỗ trống, recovery, QR check-in qua Rules; 4 emulator tests mới qua; Rules/indexes deploy `eventhub-group4` ngày 04/11 | Test Android với tài khoản thật và sự kiện còn hạn; web CLB tạo QR/phiên; kiểm thử cạnh tranh hai tài khoản và phục hồi mạng. Chưa có ledger operation độc lập |
| PDF/Cloudinary Free | PDF local tiếng Việt, upload raw PDF adapter, test mock; Firebase Storage không dùng | Nhóm tạo Cloudinary account/preset và test upload thật. Preset unsigned/URL chia sẻ công khai; cần thầy chấp nhận thay Storage trong báo cáo |
| FCM | SDK token/permission, foreground/background/terminated handler, route theo payload | Test message thật ba trạng thái; không có push tự động theo nghiệp vụ khi chưa có web/admin gửi |
| Analytics | Kế hoạch ≥7 events và adapter ghi event | DebugView của từng event trên thiết bị thật |
| Crashlytics | Handler fatal/nonfatal và màn test có xác nhận | Dashboard lỗi thật và crash thử có kiểm soát |
| Remote Config | Hai tham số mặc định đã publish, fetch/fallback/code UI | Ảnh trước/sau khi thay config thật trên Console |
| ARTEMIS | 25 ca test, script/fixtures, pin SDK | Chưa có host/model key và tài khoản test. Cần ≥10 ca ×3 lần, Pro exploration 15–30 phút thật, trace và pass rate |
| AI code review | Local findings và code review plan | PR review bằng AI có ≥5 findings; ≥3 fix commits gắn findings và bằng chứng |
| Report/slides/video | Khung tài liệu và checklist | Chỉ chốt sau khi có cloud/E2E/review evidence thật; không điền pass rate hoặc video giả |

## Việc cần người dùng/nhóm làm trước một lượt test cuối

1. Tạo Cloudinary Free và unsigned preset giới hạn PDF/5 MB theo [cloudinary-setup.md](cloudinary-setup.md). Gửi **cloud name** và **preset name**, không gửi API secret.
2. Chuẩn bị một sự kiện test còn hạn/chỗ trên Firestore, tài khoản email đã xác nhận và QR/phiên do web CLB tạo. Xem [backend-setup.md](backend-setup.md).
3. Cung cấp ARTEMIS host/provider và model key qua `.env` local, không gửi key trong chat hoặc commit. Chuẩn bị tài khoản test riêng.
4. Chạy Android app thật, test Auth → F1 → F2 → F4A → PDF → FCM/Analytics/Crashlytics/Config; chụp bằng chứng. Sau đó chạy ARTEMIS và mở PR AI review.

## Ranh giới Lab 3 → Final

Final Assignment dùng Firestore + Rules + App Check và web CLB/admin, không dùng custom backend/Functions/Storage. Code mobile đã bỏ Functions/Storage để giảm rework. Chức năng duyệt `pending → approved` và web admin chưa nằm trong Lab 3 hiện hành; sẽ cần thay đổi trạng thái đăng ký/thiết kế khi chuyển Final. Mọi khác biệt so với Figma và thay thế Storage phải ghi ảnh trước/sau và lý do ở `evidence/design-changes/`.
