# Mobile ASM: chạy cùng web CLB/admin

Quyết định ngày 13/11/2026: mobile ASM theo luồng chờ CLB duyệt trên web. Repo Lab 3 độc lập không thay đổi. Những hướng dẫn đăng ký trực tiếp trong hồ sơ Lab 3 chỉ mang tính lịch sử.

## Cấu trúc

- Thư mục gốc: mobile Flutter Android, `lib/main.dart`, MVVM/Riverpod; không có entrypoint mock.
- `web/`: Flutter web cho CLB/admin; giữ code và bộ dependencies riêng.
- `packages/core/`: model/contracts của web. Mobile dùng model/contracts trong `lib/`.
- `firebase/`: Rules và indexes dùng chung. Hosting tiếp tục phục vụ `web/build/web`.

## Máy mới

1. Dùng Flutter 3.47.4 / Dart 3.13.3 (bộ đã kiểm tra), Android SDK và JDK tương thích Gradle của dự án.
2. Từ Firebase project **eventhub-group4**, tải cấu hình Android package **com.eventhub.app** vào `android/app/google-services.json`. File này được bỏ qua bởi Git. Không tạo Firebase project riêng.
3. Chạy `cd android` rồi `.\gradlew.bat signingReport`; thêm SHA-1/SHA-256 debug của máy vào Android app trong Firebase. Tải lại cấu hình nếu cần. Không chia sẻ keystore cá nhân.
4. Về gốc repo, chạy:

```powershell
flutter pub get --enforce-lockfile
flutter devices
flutter run -d emulator-5554 -t lib/main.dart --dart-define=CLOUDINARY_CLOUD_NAME=qcfqv5oj --dart-define=CLOUDINARY_UPLOAD_PRESET=eventhub_lab3_pdf_test
```

Thay device ID bằng thiết bị Android của bạn. VS Code có profile **EventHub Mobile — Firebase (Android)**. Không chạy mobile bằng Chrome; web nằm trong package `web/` và chạy theo cấu hình web hiện có. Không dùng `flutter pub upgrade` chỉ để cài dependencies.

Cloudinary cloud name/preset là cấu hình public; API secret/service-account key không được đặt trong app hoặc Git. PDF public và ARTEMIS chưa được xác nhận hoàn tất trong lần tích hợp này.

## Hợp đồng dữ liệu đăng ký

- Sự kiện do web tạo phải có `clubId` hợp lệ. Tài khoản người tham gia có `users/{uid}.role = user`; CLB dùng tài khoản staff của đúng club trên web.
- Mobile tạo `registrations/{uid}_{eventId}` với `uid`, `eventId`, `clubId`, `status: pending`, `generation`, `participant`, `checkInAt: null`, `createdAt` server timestamp, `lastOperationId`; các trường duyệt được đặt null.
- CLB trên web đổi `pending` thành `approved` và tăng `events.activeCount` trong cùng transaction; hoặc `rejected` với lý do. Mobile lắng nghe Firestore nên tự cập nhật.
- Pending không chiếm chỗ và không được quét QR. Hủy pending không đổi số chỗ; hủy approved trước giờ bắt đầu giảm một chỗ.
- Đăng ký bị từ chối/hủy có thể gửi lại khi còn điều kiện; tăng generation và xóa thông tin duyệt cũ.
- QR do CLB mở trên web; mobile chỉ quét, không mở/điều khiển web. Chỉ approved (hoặc active của dữ liệu Lab 3 cũ) được đọc phiên và ghi điểm danh, theo Rules.
- Dữ liệu `active` cũ được giữ để xem lịch sử/hủy/điểm danh theo Rules cũ; không tự gắn CLB. Sự kiện thiếu `clubId` không nhận yêu cầu mới từ mobile ASM. Không tự chọn CLB thay cho chủ sự kiện.
- Khôi phục khi mất mạng phải đọc trạng thái hiện tại: pending vẫn là chờ duyệt, rejected không hiển thị thành công, unknown không tự gửi lặp.

## Kiểm tra hai thiết bị/app

1. CLB trên web tạo và công khai một sự kiện còn hạn, còn chỗ; xác nhận đúng clubId.
2. Người dùng mobile đăng ký: thấy **Đã gửi đăng ký / Chờ duyệt** trong chi tiết và lịch Sắp tới. Chưa có nút QR hoạt động; số chỗ chưa giảm.
3. CLB mở danh sách chờ trên web, duyệt yêu cầu: mobile chuyển **Đã được duyệt**, số chỗ giảm một.
4. CLB mở phiên QR trên web; mobile quét và nhận thời gian điểm danh từ máy chủ.
5. Với tài khoản/yêu cầu khác: CLB từ chối và nhập lý do; mobile hiển thị lý do, lịch nhóm **Đã hủy / Từ chối**, không điểm danh được.
6. Gửi lại yêu cầu bị từ chối khi còn hạn: trở về Chờ duyệt. Hủy khi chờ: số chỗ không đổi. Hủy khi được duyệt: trả lại chỗ (chưa bắt đầu/chưa điểm danh).

## Kiểm tra và triển khai Rules

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug -t lib/main.dart --dart-define=CLOUDINARY_CLOUD_NAME=qcfqv5oj --dart-define=CLOUDINARY_UPLOAD_PRESET=eventhub_lab3_pdf_test
```

Rules có bổ sung quyền đọc phiên QR cho đăng ký `approved`. Chạy bộ test Rules trong `firebase/tests` với emulator trước khi deploy. Sau khi nhóm thống nhất, deploy Rules/indexes lên project chung từ repo ASM; không deploy lại Rules Lab 3 lên cùng project vì có thể ghi đè quyền web. Thay đổi file local chưa có nghĩa Rules trên cloud đã được cập nhật.

Không commit APK, google-services.json, .env, keystore, API secret hoặc QR token. Mọi tuyên bố chạy Android/web cloud thật phải được xác nhận bằng lần kiểm thử liên ứng dụng, không suy ra chỉ từ unit tests.

## Kết quả kiểm tra tích hợp ngày 13/11/2026

- `flutter pub get --enforce-lockfile`: đạt, mobile dùng lockfile riêng.
- `flutter analyze --no-pub` và `flutter analyze --no-pub lib test`: không có lỗi. Thư mục thư viện npm được loại khỏi phân tích Dart.
- `flutter test --no-pub`: 79/79 test đạt, gồm trạng thái pending/approved/rejected và khôi phục kết quả.
- Firestore Rules: 9/9 test đạt trên emulator với project `demo-direct-booking`; không ghi dữ liệu production.
- `npm ci --prefix firebase/tests --dry-run --ignore-scripts --no-audit --no-fund`: đạt sau khi sửa lockfile thiếu picomatch.
- APK debug đã build thành công tại `build/app/outputs/flutter-apk/app-debug.apk` với cấu hình Cloudinary public bên trên.
- Mã `web/`, `packages/core/`, Hosting và indexes không thay đổi trong lần tích hợp này.
- Chưa thao tác duyệt xuyên mobile/web trên cloud thật; chưa deploy Rules mới và chưa sửa Figma. Không đánh dấu các mục này đã đạt.
