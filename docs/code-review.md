# AI-assisted code review — trạng thái hiện hành

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
