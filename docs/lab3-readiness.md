# Tiến độ Lab 3 — EventHub Group 4

Cập nhật 05/11/2026. Trạng thái có bằng chứng; **chưa phải xác nhận hoàn thành**. Bản app duy nhất: `lib/main.dart`.

| Yêu cầu | Đã có / đã kiểm tra | Chưa hoàn tất hoặc cần bằng chứng |
|---|---|---|
| Final UI và 3 flow | A01–A12, F1/F2/F4A, state lỗi, MVVM; Kiểm thử local ghi tại `evidence/backend/cleanup-validation.md` | So ảnh Figma và Android cuối cùng; test thao tác E2E trên máy thật/emulator |
| Auth | Google/email/password/verify/reset và guard; Google login thật đã được chủ project xác nhận | Bằng chứng đủ nhánh lỗi/hủy và Users console cho bài nộp |
| Firestore nghiệp vụ | Đăng ký/hủy transaction, chỗ trống, recovery, QR check-in qua Rules; 4 emulator tests mới qua; Rules/indexes deploy `eventhub-group4` ngày 04/11 | Test Android với tài khoản thật và sự kiện còn hạn; fixture QR/phiên chuẩn bị qua Console cho Lab 3; kiểm thử cạnh tranh hai tài khoản và phục hồi mạng. Chưa có ledger operation độc lập |
| PDF/Cloudinary Free | PDF local tiếng Việt, upload raw PDF adapter, test mock; upload PDF trắng thử lên `qcfqv5oj` thành công 05/11; URL cũ và mới đều tải được PDF (HTTP 200) sau khi bật PDF delivery | Chưa test thao tác trên Android vì chưa có emulator kết nối; URL public không giới hạn theo UID |
| FCM | SDK token/permission, foreground/background/terminated handler, route theo payload | Test message thật ba trạng thái; đã bổ sung lưu receipt theo UID, chống trùng; chưa xác minh nhận/lưu trên Android ở cả ba trạng thái |
| Analytics | Kế hoạch ≥7 events và adapter ghi event | DebugView của từng event trên thiết bị thật |
| Crashlytics | Handler fatal/nonfatal và màn test có xác nhận | Dashboard lỗi thật và crash thử có kiểm soát |
| Remote Config | Hai tham số mặc định đã publish, fetch/fallback/code UI | Ảnh trước/sau khi thay config thật trên Console |
| ARTEMIS | 25 ca test, script/fixtures, pin SDK | Chưa có host/model key và tài khoản test. Cần ≥10 ca ×3 lần, Pro exploration 15–30 phút thật, trace và pass rate |
| AI code review | Local findings và code review plan | PR review bằng AI có ≥5 findings; ≥3 fix commits gắn findings và bằng chứng |
| Report/slides/video | Khung tài liệu và checklist | Chỉ chốt sau khi có cloud/E2E/review evidence thật; không điền pass rate hoặc video giả |

**Đối chiếu sát PDF:** Firestore transaction là nguồn dữ liệu của đăng ký/hủy/điểm danh; không gọi Cloud Functions. Danh sách hai sự kiện `(Mẫu)` là fixture trên Firestore thật; không phải mock hard-code trong app. Đề không bắt buộc dữ liệu do người dùng bên ngoài tạo. Public REST API không phải yêu cầu đồng thời với Firestore. Khu demo Firebase hiện có lối vào trên Tài khoản. Theo thông tin của nhóm, giảng viên cho phép Cloudinary thay Storage; cần ghi quyết định này trong báo cáo. URL public không đáp ứng quyền đọc riêng theo UID, nên mục quyền truy cập file vẫn chưa đạt.

## Việc cần người dùng/nhóm làm trước một lượt test cuối

1. Cloudinary đã cấu hình và thử upload/download. Còn giải quyết quyền đọc/ghi riêng theo tài khoản; không dùng URL public làm bằng chứng đạt yêu cầu này.
2. Chuẩn bị một sự kiện test còn hạn/chỗ trên Firestore, tài khoản email đã xác nhận và QR/phiên test chuẩn bị qua Console. Xem [backend-setup.md](backend-setup.md).
3. Cung cấp ARTEMIS host/provider và model key qua `.env` local, không gửi key trong chat hoặc commit. Chuẩn bị tài khoản test riêng.
4. Chạy Android app thật, test Auth → F1 → F2 → F4A → PDF → FCM/Analytics/Crashlytics/Config; chụp bằng chứng. Sau đó chạy ARTEMIS và mở PR AI review.
