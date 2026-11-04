# Một lượt kiểm thử Lab 3 trên Android

Chỉ bắt đầu sau khi có Cloudinary preset, tài khoản Firebase test đã xác nhận email, sự kiện còn hạn/chỗ và QR/phiên do web CLB chuẩn bị. Test trên `lib/main.dart`, không dùng prototype offline. Ghi ảnh và thời điểm từng bước; test nào chưa chạy ghi **chưa kiểm thử**.

## Chuẩn bị

1. Chạy `flutter devices` và chọn Android emulator/máy thật. Với emulator thường là `emulator-5554`.
2. Chạy:

   ```powershell
   flutter run -d emulator-5554 -t lib/main.dart --dart-define=CLOUDINARY_CLOUD_NAME=<cloud-name> --dart-define=CLOUDINARY_UPLOAD_PRESET=<preset-name>
   ```

   Mở **Tài khoản → Dịch vụ Firebase** để xem Remote Config, bật thông báo, vào trung tâm thông báo/xuất file và thử Crashlytics. Nút test crash chỉ hiện trong bản debug và cần xác nhận trước khi app đóng.
3. Mở Firebase Console cho đúng project `eventhub-group4`, Cloudinary Media Library và bảng [test-plan.md](test-plan.md). Bật Firebase Analytics DebugView cho Android test theo hướng dẫn Firebase. Không đưa token QR, mật khẩu, email cá nhân hoặc URL PDF vào log công khai.

## Thứ tự đi qua app

| Bước | Persona / flow | Thao tác chính | Kiểm tra và bằng chứng |
|---|---|---|---|
| 1 | P01/P02/P03, Auth | Đăng nhập Google hoặc email/password; thử sai/hủy; email chưa xác minh | Vào Khám phá sau thành công; Auth Users và state lỗi đúng |
| 2 | P01 sinh viên, F1 | Tìm workshop → chi tiết → form; bỏ trống K rồi sửa → xác nhận | Lỗi tại K; A06; Firestore đăng ký + số chỗ tăng cùng nhau |
| 3 | P02 khách, F1 | Tài khoản test khác → đăng ký workshop khác/còn chỗ; chọn Khách ngoài trường | Không hỏi K; A06 và dữ liệu snapshot đúng |
| 4 | P03 xem tự do, F1 | Mở sự kiện `registrationMode=free` | Chỉ xem giờ/địa điểm; không có đăng ký/QR/lịch |
| 5 | P01/P02, F2 | Lịch → chi tiết → dialog hủy → Giữ; mở lại → Xác nhận hủy | Giữ không thay dữ liệu; hủy chuyển lịch sử và số chỗ giảm một lần |
| 6 | P01/P02, F4A | Đăng ký đang active; CLB mở QR trên web; thử QR sai/đóng phiên rồi QR đúng | QR sai không ghi; QR đúng ghi một `checkInAt`; quét lại giữ giờ gốc; A12 không lộ email/số điện thoại |
| 7 | Mọi persona | Tài khoản → Xuất lịch → Tạo PDF và tải lên | PDF đúng lịch; Cloudinary Media Library có file; link mở được; thử offline để thấy lỗi |
| 8 | FCM | Gửi test message qua Firebase Console đến Android | Nhận khi app foreground/background/terminated, tap đi đúng màn; ghi trường hợp OS chặn quyền |
| 9 | Remote Config | Đổi hai tham số trên Console, publish, bấm fetch trong Dịch vụ Firebase | Ảnh trước/sau của số gợi ý hoặc khối gợi ý |
| 10 | Analytics/Crashlytics | Đi qua các thao tác trên; mở DebugView; thử nonfatal và test crash có xác nhận trong Dịch vụ Firebase | ≥7 event đúng tên, không PII; Crashlytics dashboard có nonfatal/fatal sau khi xử lý |

Sau mỗi flow, đăng xuất trước khi đổi tài khoản. Không dùng cùng một event hết chỗ/hết hạn để kiểm tra nhánh thành công. Đối với test offline/mất mạng, không bấm gửi lặp trước khi app kiểm tra trạng thái; ghi rõ nếu kết quả vẫn chưa xác định.

## Sau lượt thủ công

Chạy ARTEMIS ít nhất 10 ca, mỗi ca 3 lần độc lập và một phiên Pro exploration 15–30 phút theo [e2e_test/README.md](../e2e_test/README.md). Lưu trace và pass rate thật. Mở PR để AI review, tổng hợp ít nhất 5 findings và ít nhất 3 fix commits theo findings. Cuối cùng mới điền report 8–12 trang, slides 12–15 và video 5–10 phút từ bằng chứng thật. Xem [lab3-readiness.md](lab3-readiness.md) để biết mục nào còn thiếu.
