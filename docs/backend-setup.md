# Firebase project `eventhub-group4` — thiết lập và kiểm thử

Cập nhật 04/11/2026. Backend app Lab 3 dùng Firebase Auth và Firestore trực tiếp; không deploy Cloud Functions hay Firebase Storage. File PDF minh họa dùng Cloudinary Free theo [cloudinary-setup.md](cloudinary-setup.md).

## Đã có trong project

- Google Sign-In và email/password đã cấu hình; Google login được người dùng xác nhận trên Android.
- Firestore database, Rules và indexes đã triển khai. Lệnh triển khai hiện tại: `./tool/deploy-cloud.ps1` (chỉ Firestore Rules/indexes, project ID cố định). Rules được kiểm thử bằng emulator trước khi deploy.
- Remote Config hai tham số mặc định `discover_featured_limit=10`, `discover_recommendations_enabled=true` đã được publish trước đó.
- Hai sự kiện gắn `(Mẫu)` trong Firestore để xem UI. Chúng không phải sự kiện thật của CLB. Trước demo nghiệp vụ, kiểm tra `startsAt`, `deadline`, `capacity`, `activeCount` và `status`; thời điểm qua hạn không thể đăng ký.

## Cần chuẩn bị để test nghiệp vụ thật

1. Dùng Android emulator hoặc máy thật, `flutter run -d <device> -t lib/main.dart` với `--dart-define` Cloudinary nếu test PDF. Không dùng `main_prototype.dart` làm bằng chứng cloud.
2. Chọn tài khoản Firebase Auth có email đã xác nhận. Nếu dùng email/password, mở link verify trước khi vào app. Không nhập API key hoặc service account vào repo.
3. Tạo hoặc chỉnh **sự kiện test mới** qua Firebase Console/Admin SDK có `visibility=public`, `status=published`, `registrationMode=required`, `startsAt` và `deadline` trong tương lai, `capacity>0`, `activeCount=0`. Với demo cũ ngày 08/11/2026, chỉ test khi còn hạn. Không thay số chỗ thủ công sau khi có đăng ký.
4. Test trên app: A02→A04→A05→A06, A07/A08 hủy, re-register. Mở Firestore Console xác nhận `registrations/{uid}_{eventId}` và `events/{eventId}.activeCount` cùng thay đổi. Thử tài khoản thứ hai khi chỉ còn một chỗ.
5. Để test QR, **web CLB** phải tạo token ngẫu nhiên dài tối thiểu 32 ký tự, lưu `sha256(token)` làm ID của `qrCredentials/{hash}` với `{eventId, enabled:true}`, đồng thời tạo `checkinSessions/{eventId}` với `{open:true}`. Web hiển thị token dưới dạng QR. App mobile chỉ quét; không có quyền tạo/mở các tài liệu này. Test QR sai, phiên đóng, quét đúng và quét trùng. Không đưa token hoặc hash vào log/báo cáo.
6. FCM Lab 3 có thể gửi test message từ Firebase Console đến thiết bị; push tự động theo nghiệp vụ chưa có khi không dùng server/Functions. Inbox Firestore do web/admin tạo. Kiểm tra foreground, background và terminated cùng quyền thông báo.
7. Thu bằng chứng Auth Users, Firestore, Remote Config, Analytics DebugView, Crashlytics, FCM và Cloudinary. ARTEMIS cần host/model/tài khoản test riêng; unit/emulator pass không thay cho E2E.

## Giới hạn hiện tại

`lastOperationId` nằm trên đăng ký hiện hành, chưa có ledger lịch sử độc lập. Nếu một thiết bị khác thay đổi cùng đăng ký trước khi thiết bị đầu khôi phục lệnh chưa rõ, app không thể tự suy ra kết quả cũ; phải giữ trạng thái chưa xác định. Notifications tự động theo thay đổi Firestore và web CLB/admin chưa được triển khai ở Lab 3. Các điểm này được ghi trong [lab3-readiness.md](lab3-readiness.md), không tính là chức năng cloud đã kiểm thử.
