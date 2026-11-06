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

**Đối chiếu sát PDF:** Firestore transaction là nguồn dữ liệu của đăng ký/hủy/điểm danh; không gọi Cloud Functions. Danh sách hiện có 5 sự kiện do nhóm biên soạn trên Firestore; hai sự kiện cũ đã visibility=archived. Không có danh sách sự kiện hard-code trong app. Ảnh bìa AI là asset, cần đồng bộ Figma và disclosure. Đề không bắt buộc dữ liệu do người dùng bên ngoài tạo. Public REST API không phải yêu cầu đồng thời với Firestore. Khu demo Firebase hiện có lối vào trên Tài khoản. Theo thông tin của nhóm, giảng viên cho phép Cloudinary thay Storage; cần ghi quyết định này trong báo cáo. URL public không đáp ứng quyền đọc riêng theo UID, nên mục quyền truy cập file vẫn chưa đạt.

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

## Rà từng yêu cầu PDF ngày 07/11/2026

Đối chiếu PDF 18 trang, source tại commit fb0517a và evidence đã lưu. Không chạy lại cloud/E2E trong lượt rà này. “Có code” không đồng nghĩa đạt toàn bộ tiêu chí.

| Trang / yêu cầu | Trạng thái kiểm chứng | Việc còn lại |
|---|---|---|
| 1–3: Android, đề tài/persona/3 flow Lab 2, ≥8 màn Final UI | Có A01–A12 và F1/F2/F4A trong code | Chạy đủ flow/Back/nhánh lỗi trên Android và đối chiếu Final UI hiện hành |
| 3: loading/empty/error/retry, dữ liệu Firestore hoặc REST | Có AsyncValue/state/widget và Firestore adapter, 5 event đã ghi cloud | Xác nhận nội dung từng màn và lỗi mạng; không bắt thêm REST khi đã dùng Firestore |
| 3: sinh file từ dữ liệu đang xem, upload | Có PDF lịch, adapter Cloudinary, tiến độ/URL | Chạy upload thật trong app; quyền đọc/ghi riêng chưa đạt |
| 3: khu demo Firebase tại Profile | Có lối vào config/notification/export/Crashlytics | Giữ vì đề yêu cầu; app chỉ fetch config, chỉnh/publish ở Console |
| 3: thay đổi thiết kế phải ghi và cập nhật Figma | Có design-traceability và một số ảnh trước/sau | D14 ảnh bìa mới và các deviation trước còn chưa đồng bộ Figma đầy đủ |
| 4–5: MVVM, injection, logic ngoài build, sơ đồ/thư mục/bảng VM | Đã refactor provider và có architecture.md | Kiểm tra toàn bộ fidelity/semantics, không suy ra điểm tối đa từ analyze |
| 6: theme/tokens/widgets, ≥48dp/14sp, 360/412dp | Có theme/widgets; test layout/large text đã đạt | Đối chiếu tất cả màn, contrast và ảnh thiết bị cuối |
| 6: Google Auth, routing, cancel, logout xóa dữ liệu user | Có code/tests; user đã xác nhận Google login thật | Ảnh signed in/out, cancel, Users console và xác nhận đổi tài khoản không giữ dữ liệu |
| 6: file per-user path, progress, URL, owner-only access | PDF/progress/URL có; Cloudinary public hiện không kiểm tra Firebase UID và uid upload chưa tạo folder riêng | Chưa đạt per-user path/phân quyền; không tự thêm Worker/Functions. storage.rules trong repo không bảo vệ Cloudinary |
| 7: FCM ba trạng thái, permission, inbox, tap relevant screen | Có handler/lưu receipt/route và Rules tests | Tin thật 3 trạng thái, ảnh và xác nhận lịch sử; notification-only có thể chỉ lưu sau khi mở |
| 7: ≥7 Analytics events/params/product questions/no PII/UID | Có 14 event trong plan và tracking | DebugView cho từng event; rà ý nghĩa tham số. Không dùng lời gọi SDK làm bằng chứng server nhận |
| 7: nonfatal thật + test crash, UID/custom key | Có diagnose ở lỗi booking/upload và test crash, UID/key | Dashboard cả hai; nút manual nonfatal không thay lỗi từ đường nghiệp vụ thật |
| 7: ≥2 Remote Config thay đổi UI, defaults, không rebuild | Có recommendation_limit/show_recommendations và ảnh fetch trước | Hai bộ ảnh trước/sau + Console. Home cap 3: dùng 1↔3 để chứng minh limit; 5↔10 không đổi số thẻ |
| 8–9: ≥10 ARTEMIS cases, đủ 3 flow/error/native, SDK Flash | 25 ca theo chức năng, pin runtime, assertion structured output | Chuẩn bị fixture độc lập và chạy thật; agent/model quota còn chưa ổn |
| 9: mỗi ca ≥3 lượt, trace/replay, pass rate/avgtime/reasons | Có runner và JUnit summarizer, các lần thử TC01 thất bại được lưu | Chưa có bộ ≥10 ca ×3 lượt đạt; không tính skipped hoặc model PASS đơn lẻ |
| 8–9: Pro exploratory 15–30 phút + issues; một test Analytics | Có explore.py và TC18 kiểm Logcat | Chưa có phiên Pro/bằng chứng TC18 đạt; tương thích Pro với Groq chưa xác minh |
| 10: AI review PR, ≥5 findings/≥2 nhóm, quyết định, ≥3 fix commits theo ID | Chỉ có review local/6 findings | Chưa có bộ evidence PR review đáp ứng đề; không tính mọi commit cũ thành fix từ PR |
| 10–11: repo structure/docs/pin/secret hygiene/README | Có phần lớn cấu trúc, docs/versions/AI disclosure | google-services.json local bị ignore theo lựa chọn trước của chủ repo; PDF cho phép commit, cần bảo đảm người chấm có cấu hình chạy. Tên repo nhóm cần theo thông báo thầy |
| 11–12: report 8–12 trang, slides 12–15, video 5–10 phút | Chỉ có README khung trong report/slides | Chưa có PDF/link video cuối và chưa kiểm link trong private browser |
| 16: xác minh cá nhân chạy test, đổi config, giải thích VM/review | Chưa đánh giá | Nhóm tự luyện sau khi có kết quả thật |

Không tính Cloud Functions, Cloudflare Worker, web/admin hoặc operation ledger độc lập là yêu cầu bắt buộc Lab 3. Các phần web của teammate được giữ riêng; không dùng làm bằng chứng mobile đạt.

## Xác minh trực tiếp Figma

Đã kiểm kê page 03 và 06: 78 frame thuộc bộ Final UI mới, 74 frame cũ/QA, 55 frame prototype. Có đủ nhóm A01–A12 nhưng thiếu/khác chi tiết state/control tại A03/A08/A10/A11/A12. Xem [figma-app-audit.md](figma-app-audit.md); chưa xác nhận pixel 1:1 hoặc E2E mọi state.

Sau audit đã bổ sung code cho các thiếu hụt A03/A08/A10/A11/A12; Rules phân quyền đọc phiên/tra QR đã kiểm 6 ca và deploy. Figma giữ nguyên theo yêu cầu người dùng, đối chiếu trong docs/figma-app-audit.md. Còn cần Android E2E/ảnh toàn bộ state.

## PR review và lần xác nhận mới 07/11/2026

PR #3 có Codex AI review 5 findings/3 fix commits theo ID; xem docs/review-pr-findings.md và evidence/code-review/. Analyzer sạch, 65 Flutter tests đạt. Không giả danh bot bên ngoài. Instrumentation Console chưa thu được do công cụ UI lỗi kernel assets. ARTEMIS/Groq paced retry vẫn 429 và chỉ 2 bước; chưa đạt. Xem evidence/instrumentation/status.md và evidence/artemis/setup-status.md.
