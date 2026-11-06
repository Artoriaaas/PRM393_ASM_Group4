# Tiến độ Lab 3 — EventHub Group 4

Cập nhật 07/11/2026. Trạng thái có bằng chứng; **chưa phải xác nhận hoàn thành**. Bản app duy nhất: `lib/main.dart`.

| Yêu cầu | Đã có / đã kiểm tra | Chưa hoàn tất hoặc cần bằng chứng |
|---|---|---|
| Final UI và 3 flow | A01–A12, F1/F2/F4A, state lỗi, MVVM; Kiểm thử local ghi tại `evidence/backend/cleanup-validation.md` | So ảnh Figma và Android cuối cùng; test thao tác E2E trên máy thật/emulator |
| Auth | Google/email/password/verify/reset và guard; Google login thật đã được chủ project xác nhận | Bằng chứng đủ nhánh lỗi/hủy và Users console cho bài nộp |
| Firestore nghiệp vụ | Đăng ký/hủy transaction, chỗ trống, recovery, QR check-in qua Rules; 5 emulator tests đã qua (lần kiểm tra trước); Rules/indexes deploy `eventhub-group4` ngày 04/11 | Test Android với tài khoản thật và sự kiện còn hạn; fixture QR/phiên chuẩn bị qua Console cho Lab 3; kiểm thử cạnh tranh hai tài khoản và phục hồi mạng. Chưa có ledger operation độc lập |
| PDF/Cloudinary Free | PDF local tiếng Việt, upload raw PDF adapter, test mock; upload PDF trắng thử lên `qcfqv5oj` thành công 05/11; URL cũ và mới đều tải được PDF (HTTP 200) sau khi bật PDF delivery | Chưa xác nhận thao tác upload trên Android trong lượt bàn giao này; URL public không giới hạn theo UID |
| FCM | SDK token/permission, foreground/background/terminated handler, route theo payload | Test message thật ba trạng thái; đã bổ sung lưu receipt theo UID, chống trùng; chưa xác minh nhận/lưu trên Android ở cả ba trạng thái |
| Analytics | Kế hoạch ≥7 events và adapter ghi event | DebugView của từng event trên thiết bị thật |
| Crashlytics | Handler fatal/nonfatal và màn test có xác nhận | Dashboard lỗi thật và crash thử có kiểm soát |
| Remote Config | Hai tham số mặc định đã publish, fetch/fallback/code UI | Ảnh trước/sau khi thay config thật trên Console |
| ARTEMIS | 25 ca test, script/fixtures, pin SDK | Đã có host local, Groq và tài khoản test; các lần thử chưa được pytest xác nhận đạt, còn lỗi quota/điều hướng. Cần ≥10 ca ×3 lần, Pro exploration 15–30 phút thật, trace và pass rate |
| AI code review | Local findings và code review plan | PR review bằng AI có ≥5 findings; ≥3 fix commits gắn findings và bằng chứng |
| Report/slides/video | Khung tài liệu và checklist | Chỉ chốt sau khi có cloud/E2E/review evidence thật; không điền pass rate hoặc video giả |

**Đối chiếu sát PDF:** Firestore transaction là nguồn dữ liệu của đăng ký/hủy/điểm danh; không gọi Cloud Functions. Danh sách hai sự kiện `(Mẫu)` là fixture trên Firestore thật; không phải mock hard-code trong app. Đề không bắt buộc dữ liệu do người dùng bên ngoài tạo. Public REST API không phải yêu cầu đồng thời với Firestore. Khu demo Firebase hiện có lối vào trên Tài khoản. Theo thông tin của nhóm, giảng viên cho phép Cloudinary thay Storage; cần ghi quyết định này trong báo cáo. URL public không đáp ứng quyền đọc riêng theo UID, nên mục quyền truy cập file vẫn chưa đạt.

## Việc cần người dùng/nhóm làm trước một lượt test cuối

1. Cloudinary đã cấu hình và thử upload/download. Còn giải quyết quyền đọc/ghi riêng theo tài khoản; không dùng URL public làm bằng chứng đạt yêu cầu này.
2. Chuẩn bị một sự kiện test còn hạn/chỗ trên Firestore, tài khoản email đã xác nhận và QR/phiên test chuẩn bị qua Console. Xem [backend-setup.md](backend-setup.md).
3. ARTEMIS/Groq đã cấu hình local. Chạy một ca thử trước; nếu gặp quota hoặc agent không thao tác đúng thì chưa chạy cả bộ. Xem `e2e_test/README.md`.
4. Chạy Android app thật, test Auth → F1 → F2 → F4A → PDF → FCM/Analytics/Crashlytics/Config; chụp bằng chứng. Sau đó chạy ARTEMIS và mở PR AI review.

## Bàn giao sửa source ngày 06/11/2026

- Đối chiếu lại PDF trang 3–11: giữ MVVM/Riverpod, Firestore (không cần thêm REST), sáu nhóm dịch vụ với ngoại lệ Cloudinary do giảng viên cho phép; không thêm Functions.
- Tách service injection khỏi `app/`; ViewModel không còn import lớp khởi tạo app. Chỉnh screen code Analytics của tạo tài khoản, scanner và khu demo/export.
- Upload có tiến độ truyền dữ liệu, chờ tối đa 60 giây, chỉ báo 100% khi nhận phản hồi hợp lệ; không đưa response body dịch vụ vào lỗi.
- 25 ca ARTEMIS chia theo chức năng, có script 3 lượt và bảng tổng hợp từ pytest JUnit; chưa có bộ kết quả đạt.
- Kiểm tra local: `flutter analyze` sạch; `flutter test` 64/64; ARTEMIS collect-only nhận 25 ca. Đây không phải bằng chứng cloud hoặc E2E.

**Không phải chỉ còn test:** quyền riêng tư Cloudinary vẫn thiếu dịch vụ xác thực (nhóm tạm hoãn); AI review trên PR/fix evidence, Figma đồng bộ cuối, PDF báo cáo/slides/video vẫn chưa hoàn tất. Xem thứ tự bàn giao ở [one-pass-test.md](one-pass-test.md).
