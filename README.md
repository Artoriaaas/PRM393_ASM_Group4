# EventHub — PRM393 Lab 3 / Group 4

App Flutter Android cho người tham gia sự kiện. CLB và admin dùng web riêng; mobile không quản trị sự kiện hoặc mở phiên QR.

## Bắt đầu cho teammate

1. Đọc [tiến độ so với yêu cầu Lab 3](docs/lab3-readiness.md).
2. Cài Flutter/Android SDK, mở emulator hoặc nối điện thoại Android.
3. Chạy các lệnh dưới đây. Dự án chỉ cấu hình Android.

```sh
flutter pub get
flutter devices
flutter run -t lib/main.dart
```

Project Firebase dùng chung: **eventhub-group4**, application ID **com.eventhub.app**. Không tạo Firebase riêng cho từng teammate. Cấu hình Google Sign-In trên máy mới theo [Firebase setup](docs/firebase-setup.md), gồm fingerprint debug của máy đó.

Firestore hiện có hai sự kiện **(Mẫu)** để xem UI, không phải thông báo CLB thật. Google login đã được xác nhận. Đăng ký/hủy/QR dùng Firestore transaction và Rules đã deploy, nhưng vẫn cần test Android thật với sự kiện còn hạn và QR từ web CLB. PDF dùng Cloudinary Free; preset đã kiểm tra upload/download theo [hướng dẫn](docs/cloudinary-setup.md). Không dùng Functions hoặc Firebase Storage.

Theo đề Lab 3, **Tài khoản → Dịch vụ Firebase** mở khu demo thông báo, xuất/upload, Remote Config và Crashlytics. Giảng viên đã cho phép Cloudinary thay Firebase Storage. Quyền truy cập file riêng theo tài khoản vẫn chưa đạt với preset public hiện tại.

## Đọc tài liệu nào?

| Cần làm gì | Tài liệu |
|---|---|
| Biết đã xong gì, còn thiếu gì | [Bảng tiến độ duy nhất](docs/lab3-readiness.md) |
| Hiểu trình tự và yêu cầu bài nộp | [Kế hoạch Lab 3](KE-HOACH-LAB3.md) |
| Sửa code, hiểu MVVM/service | [Kiến trúc](docs/architecture.md) |
| Cấu hình Auth trên máy mới | [Firebase setup](docs/firebase-setup.md) |
| Schema, Rules và deploy | [Backend setup](docs/backend-setup.md) |
| PDF Cloudinary Free | [Cloudinary setup](docs/cloudinary-setup.md) |
| Đối chiếu UI/Figma và thay đổi | [Design traceability](docs/design-traceability.md) |
| Kiểm thử và bằng chứng đã chạy | [Test plan](docs/test-plan.md), [validation](evidence/backend/validation.md) |
| Test toàn bộ một lượt trên Android | [One-pass test](docs/one-pass-test.md) |
| Instrumentation và AI review | [Analytics](docs/analytics-plan.md), [code review](docs/code-review.md) |
| Chạy ARTEMIS | [E2E setup](e2e_test/README.md) |
| Chuẩn bị bài nộp | [Report](report/README.md), [Slides](slides/README.md) |


## Kiểm tra trước khi gửi thay đổi

```sh
flutter analyze
flutter test
flutter build apk --debug -t lib/main.dart
```

Kiểm thử Rules: xem `firebase/tests/README.md`. Chỉ chạy với emulator, không tác động dữ liệu cloud.

Mỗi teammate làm nhánh riêng, review trước khi merge. Thay đổi UI cần lưu ảnh trước/sau và lý do theo [quy ước](evidence/design-changes/README.md), rồi cập nhật Figma.

[Figma Lab 2](https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393). Lab 2 đã chốt; phần bổ sung Lab 3 chưa đồng bộ Figma đầy đủ. Đề gốc yêu cầu ARTEMIS dù tên PDF còn nhắc Patrol.
