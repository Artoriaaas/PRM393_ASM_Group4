# Review mobile Final — 13/11/2026

Review thực hiện trên source mới bởi Codex, trước commit phần hoàn thiện mobile. Đây là review code với finding/decision, không phải AI feature Gemini của đề.

| ID | Finding | Quyết định và sửa | Xác minh |
|---|---|---|---|
| FM-01 | Auth map mặc định role user khiến staff/admin vào mobile; role lỗi đọc không được cấp quyền mặc định | Accepted: đọc role stream Firestore, router reject và UID providers chỉ mở với user; logout/account change xóa state ngay, refresh tên cùng UID không đưa Profile về startup | final_mobile_requirements_test.dart + auth redirect tests; chưa xác nhận role change trên Android cloud |
| FM-02 | Inbox chỉ đọc tin riêng nên announcement web không đến mobile; đánh dấu đọc không được sửa thông báo gốc | Accepted: hợp nhất stream personal/announcements/registrations/receipts; scope global/club/event và receipt owner-only | test scope và Rules receipt allowed/denied |
| FM-03 | Luồng Cloudinary cũ sai Final; hoàn thành tác vụ muộn có thể giữ file của phiên cũ | Accepted: file local theo UID hash, chia sẻ native chủ động, metadata-only Firestore; epoch guard và xóa file trả về muộn | test file namespace, explicit share, stale UID completion, metadata retry |
| FM-04 | Retry metadata server timestamp có thể ghi đè lịch sử hoặc tạo bản ghi/file trùng | Accepted: dùng cùng fileId, transaction đọc trước, giữ createdAt và Rules cấm update/delete | Rules immutable test + retry test không tạo lại PDF |
| FM-05 | Rules tương thích Lab 3 vẫn cho tạo active mới ở sự kiện thiếu clubId | Accepted: bỏ nhánh tạo trực tiếp active/seat increment; giữ dữ liệu cũ chỉ đọc/hủy/điểm danh đủ điều kiện | Rules test legacy ownerless new create denied, pending/approved flows vẫn đạt |

Tài liệu và test Lab 3 lịch sử bên dưới không được dùng để khẳng định App Check Console hay cross-role Final đã được kiểm thử thật.

---

# AI-assisted code review — hồ sơ Lab 3 kế thừa

Đã dùng Codex assistant (GPT-6.1) review diff PR [#3](https://github.com/ThinhCri/PRM393_Lab03_Group4/pull/3), source fb2d2ee. Output và file:dòng tại [review-pr-findings.md](review-pr-findings.md); metadata phạm vi tại evidence/code-review/pr-3-scope.json. Không giả danh output Copilot/CodeRabbit. Đề nêu ví dụ công cụ, không bắt buộc bot ngoài cụ thể. Trạng thái PR hiện tại chưa được kiểm tra lại qua GitHub trong lượt sửa source này.

| Finding | Loại theo taxonomy đề | Quyết định / lý do | Commit đã sửa |
|---|---|---|---|
| PR01 | Bug | Accept: camera không resume làm đứt luồng quét khi quay từ nền; §3/5 | fe02d20 (gộp PR02) |
| PR02 | Bug | Accept: ref sau await có thể truy cập widget đã dispose; §5/6 | fe02d20 (gộp PR01) |
| PR03 | Security | Accept: analytics async có thể gán thao tác tài khoản cũ sang UID mới; §6 | 9f92864 (gộp PR04) |
| PR04 | Bug | Accept: feedback non-fatal cũ có thể hiện trong phiên tài khoản mới; §5/6 | 9f92864 (gộp PR03) |
| PR05 | Bug | Accept: future timeout không được quan sát gây lỗi async thứ hai; §6 | 33fb007 |

**Giới hạn phải ghi trung thực:** có5 findings và3 commits nhưng hai commits gộp findings, chưa khớp chặt câu chữ mỗi finding một commit riêng. Không rewrite history đã push hoặc cố ý thêm lỗi. Adapter FCM sau đó đổi sang getToken nên đoạn onRegistered mà PR05 review đã được thay thế; commit/finding cũ vẫn là lịch sử thật. Cần PR review tiếp trên phạm vi thay đổi thực tế nếu muốn hoàn thiện phần fix-commit riêng.

## Khắc phục từ audit trang 5–10 (source hiện tại)

| ID | Finding | Thay đổi / kiểm tra |
|---|---|---|
| AUD01 | Architecture: screen tự điều phối SDK camera | QrCamera interface + provider, ScannerViewModel state/lifecycle, QrCameraPreview presentation; fake-camera tests |
| AUD02 | Accessibility/design-system: input hint contrast thấp, wrappers lặp | AppTopBar/Button/Dialog/ChoiceChip; hint secondary, body14, named tokens; contrast/touch/layout tests |
| AUD03 | Security: pending command còn trong local sau logout | Chặn race lúc booking busy, clear UID pending trước sign-out; lỗi clear không giả logout thành công; tests |
| AUD04 | Bug: mở push thiếu analytics và nuốt lỗi inbox | notification_open source=push; feedback + nonfatal khi lưu lịch sử thất bại; native DebugView còn cần kiểm tra |

Đây là audit/fix trong workspace theo yêu cầu người dùng, không tự gọi chúng là một review bot trên PR mới. Các thay đổi kiến trúc và UI không tự chứng minh native camera/Console đã qua.

## AI disclosure

| Công cụ | Mục đích sử dụng thực tế |
|---|---|
| Stitch | Tham chiếu/khởi tạo thiết kế Lab2 theo lịch sử nhóm |
| Antigravity | Hỗ trợ dựng code ban đầu theo lịch sử nhóm |
| Codex assistant | Kiến trúc, triển khai/refactor, đối chiếu đề, review local và diff PR #3, tài liệu, chạy kiểm thử |
| Image generation | Tạo ảnh bìa minh họa sự kiện; không phải ảnh sự kiện thực đã diễn ra |
| ARTEMIS + Groq/Qwen | Thử E2E; các phiên chưa đủ điều kiện regression, hiện hoãn theo yêu cầu |

Người dùng xác nhận thao tác app/Console; ảnh và kết quả thật lưu tại evidence/. Không công bố key, mật khẩu hay token thiết bị.

---

# Nhật ký review local trước PR

Ngày 31/10/2026. Reviewer local: Codex assistant trong phiên triển khai. Đây là review diff và kiểm tra tự động trong workspace, **là lịch sử trước PR**, không phải trạng thái hiện tại. PR #3 đã được review sau đó như phần hiện hành bên trên. Không ghi các fix dưới đây thành “3 fix commits từ PR” khi chưa có bằng chứng đó.

## Findings local đã xử lý trong lúc triển khai

| ID | File:dòng tham chiếu | Nhóm | Vấn đề và quyết định | Kiểm tra |
|---|---|---|---|---|
| L01 | lib/viewmodels/booking_viewmodel.dart:34; lib/viewmodels/export_viewmodel.dart:57 | Concurrency/privacy | Accepted: kiểm tra UID hiện tại + epoch + mounted trước nhận kết quả async; chỉ epoch không đủ nếu provider chưa rebuild | đổi UID khi upload/booking đang chờ không hiện URL/dữ liệu cũ |
| L02 | lib/viewmodels/profile_viewmodel.dart:6; lib/screens/account/profile_edit_screen.dart | UX/state | Accepted: saved là trạng thái xác nhận riêng, không suy ra thành công từ errors trống; lỗi mạng giữ dirty state | profile_viewmodel_test |
| L03 | lib/utils/push_destination.dart:3 | Navigation/input | Accepted: bỏ ID rỗng và từ chối path không hợp lệ; event notification không bị ID đăng ký rỗng làm mất đích | push fallback/cross-UID/path tests |
| L04 | lib/viewmodels/booking_viewmodel.dart:109 | Concurrency/reliability | Accepted: khóa thao tác trước bất kỳ await; tracking không chặn hay thay kết quả nghiệp vụ | double-tap + unknown/replay tests |
| L05 | lib/app/bootstrap.dart:10; lib/services/firebase/firebase_bootstrap.dart:13 | Startup/reliability | Accepted: cold boot nhiều SDK vượt timeout ngắn; có loading/retry, giữ future core không khởi tạo chồng; ghi lỗi đã redacted | bootstrap_test + native phiên Google khôi phục được |
| L06 | lib/viewmodels/auth_viewmodel.dart | Auth/reliability | Accepted: đăng xuất vẫn tiến hành nếu gỡ đăng ký push mạng lỗi; có timeout và không để tác vụ Firestore chặn unregister trước | cần kiểm tra offline/native thêm |

Dòng tham chiếu có thể thay đổi khi formatter chạy; dùng ID + file và commit gắn tại lịch sử Git. Không gọi review local này là đầu ra của một công cụ PR chưa được chạy.

## Checklist lịch sử trước PR (không phải trạng thái hiện hành)

- Sau khi code/cloud ổn định, mở PR chứa thay đổi có phạm vi rõ; chạy ít nhất một công cụ AI review thật trên PR, lưu nguyên đầu ra và link.
- Ghi ≥5 findings thuộc ≥2 nhóm với file:dòng, accepted/modified/rejected và lý do thực tế.
- ≥3 findings được chấp nhận phải có mỗi fix một commit chứa ID finding, link và kiểm tra lại. Không cố ý thêm lỗi để tạo lịch sử fix.
- AI disclosure: Codex hỗ trợ thiết kế kiến trúc/code, đọc tài liệu, unit/emulator tests, review local và tài liệu; nguồn UI là Lab 2/Figma, không nhận là nghiên cứu người dùng thật.

## Commits khắc phục audit hiện tại

- AUD01: 9bd5bd8 — scanner MVVM/camera contract và fake tests.
- AUD02: c3273ec — components/tokens/accessibility và kiểm tra contrast/touch.
- AUD03: 53eae7e — pending cleanup/logout race và tests.
- AUD04: 599b4c4 — push-open analytics và feedback lưu inbox.

Mỗi commit mới có một audit ID. Đây không sửa lại lịch sử PR #3; các commits này xuất phát từ audit workspace, chưa tự biến thành bằng chứng AI review trên PR mới.

## FM06 — Export không được âm thầm thiếu sự kiện

- File: mobile/lib/viewmodels/export_viewmodel.dart, reportRowsProvider.
- Finding: khi registration tồn tại nhưng event không tải được/null, code cũ bỏ qua dòng; PDF vẫn báo tạo thành công dù không khớp toàn bộ lịch.
- Quyết định: accept. Final kế thừa yêu cầu dữ liệu/file đúng nội dung; không giả vờ xuất đầy đủ.
- Fix: phát error để màn xuất hiển thị retry, không tạo báo cáo thiếu dòng.
- Kiểm tra: final_mobile_requirements_test — export refuses a partial schedule when a registered event is missing; suite 84/84 đạt. Không thay bằng bằng chứng native share/cloud.

## Findings đã sửa — 13/11/2026

- S01: public draft bị đọc và staff có thể vượt phê duyệt. Sửa Rules read/status transition; test deny/allow với user, staff, Admin. Rules/indexes deploy thành công.
- W01–W03: action Admin tạo không dùng được và fallback CLB đầu tiên. Bỏ action Admin, kiểm tra staff/clubId cả ViewModel/Rules; CLB gửi đề xuất pending_approval.
- W04: dựng lại Event làm mất ảnh. Giữ cả coverKey/coverUrl và thêm regression chỉnh sửa/gửi duyệt.
- W05: RC web fetch nhưng không dùng. Dashboard đọc giới hạn recent/chart, có test tác động đầu ra; không dùng RC quyết định quyền.
- M01–M02: đăng ký cũ thắng bản hủy mới và vùng bấm tab nhỏ. Dùng canonical/generation/time chung lịch/detail/PDF; tăng vùng bấm và test text lớn.

Kết quả: mobile86, web28, core6, Rules12 nhóm đạt. Các fix đã commit/push; review source này chưa thay thế bộ bằng chứng review trên PR. Fix commit: `0e9854f`; cleanup runtime: `261d191`. AI/ARTEMIS chưa thực hiện trong đợt này.

## AI review và quyết định sửa — 13/11/2026

| Finding | Quyết định / sửa | Kiểm chứng |
|---|---|---|
| AI01: gọi Google REST bằng Firebase Web key, App Check lỗi vẫn gửi | Dùng firebase_ai 5.1.0, FirebaseAI.googleAI + response schema; chặn khi không có App Check token | Unit test cấu hình/token; build web |
| AI02: fallback cố định bị gắn nhãn Gemini | Bỏ generator offline; trả lỗi và tiếp tục nhập tay | Quota/network/invalid output tests |
| AI03: gửi nguyên title/description có thể chứa PII | Chỉ gửi một chủ đề trong danh sách cố định; từ chối free text; không log raw exception/prompt | Input rejection và telemetry privacy tests |
| AI04: ghi đè form và accepted sai thời điểm/stale state | Xem trước/cancel/apply; chỉ apply ghi accepted; autoDispose và bỏ kết quả muộn | Widget preview/cancel/apply, lifecycle tests |
| AI05: text/JSON thiếu trường được nhận như Level 2 | JSON/schema và kiểm tra bắt buộc/type/length, không fallback regex/plain text | Model invalid output tests |
| AI06: tài liệu ghi kết quả thực tế chưa có bằng chứng | Thay bằng bảng chưa chạy; không dùng fake làm cloud evidence | docs/ai-feature.md |

Kết quả tự động mới: web analyze sạch, 39/39 tests; core analyze sạch, 6/6 tests; web build thành công. Cần Console setup và 3 output thật +1 failure trước khi chốt yêu cầu AI hoàn thành. Chưa có PR evidence hoặc commit SHA mới cho lượt sửa AI này.

### Bổ sung trước chạy thật

- RC cache5phút khiến demo kill-switch có thể vẫn gọi AI bằng cấu hình cũ. Chấp nhận finding: explicit AI action force-fetch, fetch lỗi thì dừng model; passive dashboard giữ cache bình thường. Test stale-config failure và forceRefresh flag.
- Profile self-update và event metadata update chưa kiểm tra đầy đủ kiểu/ngày. Chấp nhận finding: string/size/server timestamp profile và timestamp/order/deadline events; matrix thêm allow update hợp lệ +deny sai kiểu/ngày.
- App Check cloud: AI Logic ENFORCED, Firestore UNENFORCED; Android chưa có debug token và không kết nối thiết bị. Không bật Firestore enforcement trước verified requests để tránh khóa binary test. Helpers chỉ đọc cloud/đăng ký debug token; không tạo backend mới.

## AI đầu vào tự do — 14/11/2026
Thay quyết định AI03 giới hạn 5 chủ đề bằng ý tưởng riêng 5–500 ký tự: không tự gửi dữ liệu tài khoản hoặc toàn form; chặn mẫu thông tin liên hệ/URL và hướng dẫn không nhập PII. Không tuyên bố lọc được mọi tên người. JSON chỉ nhận 5 trường nội dung, popup chọn từng trường, giữ nguyên ngày giờ/địa điểm/capacity/deadline. Test xác nhận lựa chọn, hủy/tạo lại, giữ trường bỏ chọn, lưu metadata nguyên trạng và không log ý tưởng.
