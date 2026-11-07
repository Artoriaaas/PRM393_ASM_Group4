# Đối chiếu từng yêu cầu Lab 3 — trang 5–10

Ngày 07/11/2026. Đối chiếu nội dung người dùng cung cấp, source sau 30e7aa3 và ảnh Console tại evidence/instrumentation/. Bảng gốc bên dưới là baseline audit; xem cập nhật khắc phục ngay sau đoạn này để biết trạng thái hiện tại. ARTEMIS và quyền riêng tư Cloudinary được hoãn theo yêu cầu người dùng; không tính đạt. Chưa xác minh lại Figma trong lượt này.

## Cập nhật sau sửa source 07/11/2026

- **Đã sửa:** ScannerViewModel + QrCamera interface/provider; preview không điều khiển thiết bị; camera failure state/fake tests. Cần kiểm tra native QR/resume một lần sau cài.
- **Đã sửa:** AppTopBar/AppButton/Dialog/ChoiceChip được dùng ở production screens; placeholder #5F6B7A, body14, input border token đúng, chip48. Geometry của artwork vẫn là số đo vẽ, không phải nội dung nghiệp vụ/mock.
- **Đã sửa:** logout clear pending UID và chặn chen ngang lệnh busy. Đính chính baseline: Firebase bootstrap đã persistenceEnabled=false từ trước; không có cơ sở bắt thêm clearPersistence khi SDK đang chạy. Native đổi tài khoản/offline logout còn cần xác nhận.
- **Đã sửa:** push open phát notification_open(source=push); lưu inbox thất bại có feedback/nonfatal, không chỉ nuốt lỗi. Chưa có ảnh Console cho nhánh mới này.
- **Đã bổ sung:** docs/flutter-handoff.md đối chiếu bản Lab2 đã mở ở revision31cd447; architecture/analytics/README/code-review đồng bộ trạng thái. Vẫn không tự sửa Figma.
- **Chưa thể tự đóng bằng source:** thiếu ảnh Auth, mọi Analytics event trong plan, native quyền/denied/deep-link/read-state; cấu trúc commit PR cũ; config bàn giao theo quyết định chủ repo; legacy title (Mẫu) trong dữ liệu cloud. Không xóa dữ liệu cloud trong lượt sửa source.
- **Hoãn nguyên trạng:** ARTEMIS, riêng tư Cloudinary; report/slides/video không được tạo trong lượt này.

**Quy ước:** Đạt = đủ phần đã kiểm chứng; Một phần = có code/đầu ra nhưng chưa đủ bằng chứng hoặc còn điểm lệch; Cần sửa = tìm thấy điểm trái yêu cầu; Hoãn = ngoài phạm vi lượt này.

## 5. Architecture / MVVM

| Yêu cầu | Kết quả | Căn cứ và việc cần làm |
|---|---|---|
| Views chỉ giao tiếp ViewModels, network/Firebase ở services | Một phần | Không thấy screens/widgets gọi Firebase SDK/http trực tiếp. Nhưng screens/events/scanner_screen.dart tự tạo qrCameraProvider, gọi start/stop/openSettings và quản lý stream camera; services/device/qr_camera_service.dart trả Widget preview. Cần tách điều phối camera vào ViewModel và giữ preview ở lớp presentation. |
| Filtering/ranking/aggregation/validation ngoài build | Cơ bản đạt | EventFilterViewModel và các provider event_viewmodels.dart xử lý lọc/lịch; Auth/Profile/Booking xử lý validation. Điều kiện render theo state trong build không phải tự động là business-logic defect. Cần kiểm tra lại camera như trên. |
| State tường minh loading/empty/error/data do VM quản lý | Một phần | Event/list/schedule/notification/export dùng AsyncValue của Stream/FutureProvider; form dùng state classes. Scanner còn message và lỗi camera trong State widget; cần đưa state điều phối về VM. Empty hiển thị từ kết quả data rỗng là cách dùng AsyncValue hợp lệ, không bắt đổi toàn bộ thành enum. |
| Services inject và fake được | Một phần | Auth/Event/Report/Cloud có contract + Riverpod overrides và tests. QrCameraService là concrete adapter được tạo trong screen, chưa có contract/controller VM để fake độc lập. |
| architecture.md: thư mục, layer diagram, sequence, VM-services | Có đủ đầu ra | docs/architecture.md có bảng thư mục, Mermaid layer/sequence và VM-services. Cần chỉnh tuyên bố Views chỉ qua VM cho khớp camera và cập nhật trạng thái cloud đã test. Không cần thêm firebase/ trong lib nếu đã giải thích lib/services/firebase/. |

## Design system

| Yêu cầu | Kết quả | Căn cứ và việc cần làm |
|---|---|---|
| Tokens tại lib/theme; ColorScheme/TextTheme/spacing/radius/elevation | Một phần | Có AppColors/Typography/Spacing/Radius/Shadows và ThemeData. Còn màu, font size, radius, padding literal ở widgets/workshop_cover.dart, app_navigation_bar.dart, app_icon_button.dart và GenericEventCover. Preview dev cũng có literal nhưng không phải màn production. Cần tập trung tokens thay vì chỉ có thư mục theme. |
| Screens đọc theme, không hard-code giao diện | Cơ bản đạt ở màn production đã rà | Các màn chính dùng token AppSpacing/AppColors, textTheme. Tuy nhiên dùng AppColors trực tiếp khiến đổi ColorScheme không truyền hết; component internals còn literal như trên. Không khẳng định toàn bộ thiết kế 1:1. |
| Một reusable widget mỗi component; screens dùng wrapper | Một phần | Có AppButton/TextField/SearchField/Card/Navigation/TopBar/Dialog/Loading/Empty/Error. Nhiều màn vẫn dựng AppBar và TextButton riêng; profile_edit_screen.dart có AlertDialog/TextButton riêng thay AppConfirmationDialog. ChoiceChip/filter sheet chưa chuẩn hóa thành component chung. |
| Contrast | Cần sửa một điểm xác định | AppColors.primary trên trắng khoảng 4.95:1; textSecondary trên trắng 5.43:1. InputDecorationTheme.hintStyle dùng textDisabled #A0ABBA trên surface trắng, chỉ 2.33:1 cho hint ở input đang bật. Cần màu hint đủ contrast; màu disabled thực sự không đánh đồng với placeholder nhập liệu đang hoạt động. Chưa audit mọi cặp màu. |
| Touch target ≥48dp | Có nền tảng, chưa đủ kiểm chứng | AppButton/IconButton/Nav và theme đặt min 48. Chưa đo mọi chip, list item, inline TextButton trên các màn; không suy ra toàn bộ đạt từ minHeight chung. |
| Body ≥14sp | Một phần | bodyLarge=16, bodyMedium=14; bodySmall=12 được AppTopBar subtitle dùng. Cần phân biệt body/subtitle với caption: label 12 không tự động vi phạm body, nhưng bodySmall=12 có thể bị dùng sai. Nav label 12/badge 10 cần ghi rõ vai trò label/badge. |
| Kiểm layout 360/412 | Đã có test, phạm vi giới hạn | auth_screen_test.dart, live_event_screens_test.dart và responsive_test.dart có cả hai width + text scale lớn; toàn suite 65 pass. Chưa có ảnh/measurement cho mọi state ở cả hai kích thước. |
| Ánh xạ từ flutter-handoff.md | Một phần | Có design-traceability và architecture nhưng không tìm thấy flutter-handoff.md trong repo Lab3. Cần liên kết bản Lab2 truy cập được hoặc đưa hai bảng token/component mapping vào docs, không tự bịa nội dung handoff. |

## 6. Firebase

| Service / tiêu chí | Kết quả | Căn cứ và việc còn lại |
|---|---|---|
| Auth Google và auth-state routing | Có code + người dùng xác nhận chạy | FirebaseAuthService/SessionViewModel/auth_redirect; signed-out → login, signed-in → home, unverified → verify. Cần ảnh signed-in/signed-out và Users Console thành bộ chứng minh. |
| Hủy Google có thông báo | Code + unit test | GoogleSignInExceptionCode.canceled được map thành lời nhắn; test canceled Google không tạo session đã qua. Chưa có ảnh thao tác hủy native. |
| Sign-out xóa dữ liệu local của user | Cần sửa/kiểm chứng thêm | UI stream/VM theo UID được reset và Auth sign-out có gọi. Nhưng SecurePendingBookingStore vẫn giữ pending_booking_UID cho recovery; logout không clear. Không thấy clearPersistence của Firestore; không thể coi đổi query theo UID là xóa cache. Cần chính sách xóa local đáp ứng đề mà không vô tình gửi lại thao tác chưa rõ. |
| Storage/Cloudinary upload, progress, URL | Tạo/upload thật đã thấy | export_generate row_count=2, export_upload byte_count=13803 và app có URL. Chưa có ảnh mở file PDF kiểm nội dung hoặc console asset list. Per-user path/private-access hoãn theo yêu cầu, không đánh dấu đạt. |
| FCM foreground/background/terminated | Đạt phạm vi receipt | Có ảnh Console và app/shade/inbox cho cả 3; terminated được xác nhận pidof rỗng trước gửi, không force-stop. |
| Permission Android13+ | Có code và quyền granted thực | Request tại nút, không bypass quyền. Chưa có ảnh hộp thoại lần đầu/nhánh deny. Cài update không reset quyền nên không hỏi lại là đúng. |
| FCM inbox và tap relevant screen | Một phần | Generic push mở inbox và chọn đúng tab; persisted messages có ảnh. Còn deep link eventId/registrationId và read-state chưa xác minh native. |
| Analytics plan trước tracking, ≥7, names/types/product questions/no PII | Có đầu ra; thiếu chứng minh thứ tự chi tiết | docs/analytics-plan.md có 14 events, types và product questions; login/search chuẩn, custom snake_case. Không gửi tên/email/search contents; query_length là phép đo hợp lý nếu câu hỏi chỉ là có dùng search. Ngày ghi trong doc không tự chứng minh chronology; dùng Git khi cần. |
| Analytics bao phủ login/logout, mỗi detail, export/upload | Có tracking, còn lỗi/thiếu ảnh | Có login/logout/A04/A08/A12/export. notification_open trong plan có source push/in_app nhưng code hiện chỉ phát source=in_app; mở từ push chưa phát event đó. Cần sửa attribution/emit đúng khi thực sự mở. |
| DebugView mọi event kèm params và user ID | Một phần | Đã thấy 8 event: search, view_screen, view_event_detail, view_registration_detail, booking_submit/result, export_generate/upload. 7 có ảnh param riêng; view_screen chưa mở params. Thiếu ảnh login, logout, view_checkin_result, booking_recover, notification_open, remote_config_fetch theo plan. Ảnh overview có mục user_id nhưng chưa mở giá trị; source có setUserId/reset sau logout. Không lấy đủ 7 làm lý do bỏ login/logout bắt buộc. |
| Crashlytics real non-fatal + test crash + UID/key | Đạt bằng chứng đã yêu cầu | Dashboard native test crash, report_upload_failed từ ca offline thật, UID và app_flow=eventhub đều có ảnh. Manual non-fatal là bằng chứng bổ sung, không thay lỗi thực. Lỗi unhandled_platform_error cũ chưa được phân tích/sửa, tách khỏi kết quả instrumentation. |
| Remote Config ≥2, defaults, thay UI không rebuild | Đạt ca đã thử | recommendation_limit và show_recommendations có defaults, Console 1/true → false → restore 10/true; ảnh app một thẻ/ẩn/nhiều thẻ. Giữ app chạy trong chuỗi thử. Home cap3, limit10 không có nghĩa hiển thị10. |
| Mỗi service xử lý network/permission/cancel rõ ràng | Một phần | Auth/cloud/export/booking có feedback. FCM registration đã sửa và test nhận thật; lưu push receipt catchError bị bỏ qua, chưa có feedback khi Firestore từ chối lưu inbox. EventFailure gộp lỗi permission/network thành chung, camera lỗi còn ở View. Cần audit nhánh denied/cancel thay vì giả định từ happy path. |

## 7. ARTEMIS

**Hoãn theo yêu cầu người dùng.** Không chạy thêm, không coi các lần thử failed/paused là pass. Local Flutter tests không thay ARTEMIS.

## 8. AI-assisted review

| Yêu cầu | Kết quả | Căn cứ và việc cần làm |
|---|---|---|
| AI review trên PR, lưu output | Có bằng chứng phạm vi | PR #3; docs/review-pr-findings.md; evidence/code-review/pr-3-scope.json. Reviewer là Codex trong chat trên diff PR, không phải CodeRabbit/Copilot. Đề liệt kê ví dụ công cụ, không có căn cứ tự yêu cầu bot ngoài bắt buộc. Chưa xác minh PR state hiện tại qua network trong lượt này. |
| ≥5 findings, file/dòng, ≥2 loại | Có nhưng phân loại cần chuẩn | PR01–05, source revision fb2d2ee và 5 vị trí dòng có ghi. Nhóm hiện là Bug/privacy/concurrency/reliability; cần map rõ sang taxonomy của đề (Bug/Security/Maintainability/Test gap...), không chỉ tự đặt category. |
| Decision và lý do | Cơ bản có | Cả5 accepted, lý do có flow recovery/async/session attribution và tham chiếu §3/5/6. Phải gom vào code-review.md hoặc link rõ, xóa mâu thuẫn phần lịch sử nói chưa có PR. |
| ≥3 accepted findings, mỗi finding một commit riêng có ID | Chưa khớp chặt câu chữ | fe02d20 gộp PR01+PR02; 9f92864 gộp PR03+PR04; 33fb007 riêng PR05. Có3 commits không tự đồng nghĩa mỗi finding riêng. Không viết lại history đã push để giả lập; các finding tiếp theo cần mỗi commit một ID, hoặc nêu trung thực giới hạn cũ. |
| Disclosure mọi AI tool + mục đích | Có nhưng doc chưa đồng nhất | README liệt kê Stitch, Antigravity, Codex, ARTEMIS/Groq; code-review.md mới ghi Codex và còn câu chưa có PR, cần cập nhật theo bằng chứng mới. Không cần khai API key/tài khoản riêng tư. |

## 9. Repo / bàn giao được trích trong nội dung gửi

- Có lib/, android/, firebase/storage.rules, remote-config-defaults.json, docs bắt buộc, evidence và e2e_test/. Không bắt buộc Functions/Worker/backend riêng trong các dòng này.
- android/app/google-services.json có local nhưng bị gitignore theo quyết định chủ repo; đề ghi bao gồm file này. Cần lựa chọn cách nộp/cung cấp cấu hình chạy rõ ràng, không tự commit hoặc sửa policy của người dùng trong lượt audit.
- Repo tên Group4 thay StudentID: cần áp dụng chỉ dẫn nhóm của giảng viên; không tự đổi tên repo.
- report/ và slides/ mới có README, chưa có PDF cuối; video chưa có. Không nằm trong yêu cầu làm hiện tại.
- Dữ liệu cloud được đọc thật không đồng nghĩa không còn legacy sample: ảnh export có tên (Mẫu) từ event cũ. Cần quyết định xử lý lịch sử/metadata, không xóa cloud trong audit.

## Thứ tự xử lý tiếp (không đụng hai phần hoãn)

1. Kiến trúc camera + hợp đồng inject/state VM; chuẩn hóa wrappers và tokens/contrast/body text.
2. Logout cleanup đúng yêu cầu; sửa tracking notification_open cho push và phản hồi lỗi inbox.
3. Hoàn thiện ảnh Auth, Analytics mọi event trong plan, deep link/read-state và quyền Android lần đầu. Không lặp lại Crashlytics/Remote Config đã đủ ảnh.
4. Chuẩn hóa tài liệu AI review, taxonomy, mỗi finding mới một fix commit riêng; README/architecture/analytics evidence links đồng nhất.
5. Rà handoff mapping/config bàn giao và legacy data. Không ghi tất cả đã xong khi vẫn thiếu các đầu ra trên.

**Validation baseline audit:** 65/65 tests pass. Sau sửa: xem evidence/source-fixes/validation.md cho kết quả mới. Không gọi cloud/ARTEMIS hoặc thay đổi dữ liệu cloud trong các unit/widget tests.
