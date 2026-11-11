# EventHub — PRM393 Lab 3 / Group 4

App Flutter Android cho người tham gia sự kiện. CLB và admin dùng web riêng; mobile không quản trị sự kiện hoặc mở phiên QR.

## Bắt đầu cho teammate

1. Đọc [tiến độ so với yêu cầu Lab 3](docs/lab3-readiness.md).
2. Cài Flutter/Android SDK, mở emulator hoặc nối điện thoại Android.
3. Chạy các lệnh dưới đây. Dự án chỉ cấu hình Android. Để xuất/upload PDF, thêm hai dart-define theo [Cloudinary setup](docs/cloudinary-setup.md); không cần API secret.

```sh
flutter pub get
flutter devices
flutter run -t lib/main.dart
```

Project Firebase dùng chung: **eventhub-group4**, application ID **com.eventhub.app**. Không tạo Firebase riêng cho từng teammate. Cấu hình Google Sign-In trên máy mới theo [Firebase setup](docs/firebase-setup.md), gồm fingerprint debug của máy đó.

Firestore có 5 sự kiện nội dung do nhóm biên soạn, ảnh bìa được tạo bằng AI và đóng gói trong app; danh sách/nội dung đọc từ Firestore. Hai sự kiện cũ đã ẩn khỏi danh sách công khai. Google login đã được xác nhận. Đăng ký/hủy/QR dùng Firestore transaction và Rules đã deploy, nhưng vẫn cần test Android thật với sự kiện còn hạn và QR/phiên fixture chuẩn bị qua Firebase Console cho Lab 3. PDF dùng Cloudinary Free; preset đã kiểm tra upload/download theo [hướng dẫn](docs/cloudinary-setup.md). Không dùng Functions hoặc Firebase Storage.

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
| Chuẩn bị bài nộp | [Report](report/README.md), [Slides](slides/README.md) ([Xem online](https://thinhcri.github.io/PRM393_Lab03_Group4/slides/)) |

## Sản phẩm bàn giao Lab 3 (Deliverables)

- 📊 **Slide Thuyết trình Online (34 Slide Trực Quan & Evidence Thực Tế)**: [https://thinhcri.github.io/PRM393_Lab03_Group4/slides/](https://thinhcri.github.io/PRM393_Lab03_Group4/slides/)  
  *(Link fork cá nhân: [https://kietntse.github.io/PRM393_Lab03_Group4_pre/slides/](https://kietntse.github.io/PRM393_Lab03_Group4_pre/slides/))*
- 📑 **Hướng dẫn xem Slide & Xuất PDF chuẩn (34 Slide)**: [slides/README.md](slides/README.md) (xuất ra `slides/Lab03_Group4_slides.pdf`)
- 📄 **Báo cáo tổng kết đồ án (8–12 trang)**: [report/Lab03_Group4_Report.md](report/Lab03_Group4_Report.md) (hướng dẫn xuất PDF tại [report/README.md](report/README.md))


## Kiểm tra trước khi gửi thay đổi

```sh
flutter analyze
flutter test
flutter build apk --debug -t lib/main.dart
```

Kiểm thử Rules: xem `firebase/tests/README.md`. Chỉ chạy với emulator, không tác động dữ liệu cloud.

Mỗi teammate làm nhánh riêng, review trước khi merge. Thay đổi UI cần lưu ảnh trước/sau và lý do theo [quy ước](evidence/design-changes/README.md), rồi cập nhật Figma.

[Figma Lab 2](https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393). Lab 2 đã chốt; phần bổ sung Lab 3 chưa đồng bộ Figma đầy đủ. Đề gốc yêu cầu ARTEMIS dù tên PDF còn nhắc Patrol.

Kiểm kê chi tiết trang 5–10: [requirements audit](docs/lab3-requirements-audit.md). Ánh xạ token/component: [Flutter handoff](docs/flutter-handoff.md).

## Phiên bản và AI disclosure

Môi trường kiểm tra source: Flutter **3.47.4**, Dart **3.13.3**, Python **3.12.14**; pytest **8.4.2**. Các dependency Flutter trực tiếp được pin tại `pubspec.yaml`; dependency gián tiếp khóa tại `pubspec.lock`. ARTEMIS/SDK pin **351ca8422f7b5b54e80a9c1ce03a222e02415b6b**; thay đổi tương thích Groq được công bố trong `e2e_test/groq-compact.patch`, chưa chứng minh regression đạt.

AI sử dụng theo lịch sử nhóm: Stitch hỗ trợ thiết kế ban đầu, Antigravity hỗ trợ code, Codex hỗ trợ triển khai/review local và diff PR #3/refactor/tài liệu, ARTEMIS với Groq hỗ trợ thử E2E. Xem `docs/code-review.md`; đã có output review PR #3; commit cũ gộp nhiều findings nên chưa khớp chặt yêu cầu mỗi finding một commit riêng. **Video demo: chưa quay/chưa có link nộp.**

Bàn giao 07/11: analyze sạch, 64 test Flutter đạt, 25 ca ARTEMIS được thu thập (chưa tính đạt). Quyền riêng tư Cloudinary, xác nhận cloud/ARTEMIS và tài liệu nộp vẫn mở; trạng thái chi tiết chỉ ghi tại `docs/lab3-readiness.md`.

## Phần teammate vừa bổ sung

`web/` và `packages/core/` được giữ từ nhánh main của nhóm. Phần bàn giao này chỉ xác minh mobile Lab 3; không tuyên bố web đã đạt. Root `flutter analyze` chỉ kiểm tra mobile; kiểm tra riêng từng package bằng `cd packages/core` hoặc `cd web`, rồi `flutter pub get`, `flutter analyze`, `flutter test`. Không dùng web mock làm bằng chứng mobile chạy Firestore thật.
