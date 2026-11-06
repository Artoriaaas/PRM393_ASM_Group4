# Code review — PR instrumentation

Cập nhật 07/11/2026: đã mở PR #3, Codex review 5 findings thuộc bug/privacy/concurrency/reliability, ghi accepted và 3 commit sửa gắn ID. Đầu ra chi tiết tại [review-pr-findings.md](review-pr-findings.md). PR đang draft, chưa có review bot ngoài hoặc chấp thuận giảng viên về công cụ; không gọi local test là native cloud verification.

# Nhật ký review local trước PR

Ngày 31/10/2026. Reviewer local: Codex assistant trong phiên triển khai. Đây là review diff và kiểm tra tự động trong workspace, **chưa phải AI review trên PR**, chưa đáp ứng đầy đủ bước 11 của đề. Chưa có PR/link hoặc đầu ra CodeRabbit/Copilot/Sonar/Kodus. Không ghi các fix dưới đây thành “3 fix commits từ PR” khi chưa có bằng chứng đó.

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

## Để hoàn thành bước 11

- Sau khi code/cloud ổn định, mở PR chứa thay đổi có phạm vi rõ; chạy ít nhất một công cụ AI review thật trên PR, lưu nguyên đầu ra và link.
- Ghi ≥5 findings thuộc ≥2 nhóm với file:dòng, accepted/modified/rejected và lý do thực tế.
- ≥3 findings được chấp nhận phải có mỗi fix một commit chứa ID finding, link và kiểm tra lại. Không cố ý thêm lỗi để tạo lịch sử fix.
- AI disclosure: Codex hỗ trợ thiết kế kiến trúc/code, đọc tài liệu, unit/emulator tests, review local và tài liệu; nguồn UI là Lab 2/Figma, không nhận là nghiên cứu người dùng thật.
