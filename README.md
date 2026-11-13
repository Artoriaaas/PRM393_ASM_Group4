# EventHub — PRM393 Final Assignment / Group 4

Một Firebase project **eventhub-group4** cho mobile người tham gia và web CLB/admin. Mobile dùng đăng ký **Chờ duyệt → CLB duyệt/từ chối → điểm danh QR**. Không dùng Cloud Functions, Cloud Storage hoặc custom server. PDF lưu/chia sẻ trên thiết bị, chỉ metadata lưu Firestore theo đề Final.

## Bắt đầu

- [Chạy mobile và kiểm tra từng chức năng](docs/mobile-setup.md), gồm cấu hình App Check bắt buộc ở Console.
- `mobile/`: Flutter Android, entrypoint `lib/main.dart`, Firebase app `com.eventhub.app`.
- `web/`: Flutter Web CLB/admin; giữ cách chạy web hiện có trong VS Code.
- `packages/core/`: model, Firestore services của hai client, contracts, theme, component và font/icon dùng chung.
- `firebase/`: Rules/indexes/Remote Config/tests, cấu hình Hosting ở firebase.json.

```powershell
cd mobile
flutter pub get --enforce-lockfile
flutter run -d emulator-5554 -t lib/main.dart
```

Máy mới cần `mobile/android/app/google-services.json`, SHA Google Sign-In và App Check debug token riêng. Không commit các file cấu hình local, keystore, secret hay token. Phiên bản kiểm tra: Flutter 3.47.4 / Dart 3.13.3; dependencies cố định trong pubspec và lockfile của từng package. Không dùng lệnh flutter ở gốc repo vì gốc là hệ thống, không còn là package mobile.

## Trạng thái trung thực

Phần mobile được hoàn thiện theo Final; kết quả kiểm tra mới ghi tại [mobile validation](evidence/mobile-final/validation.md). App Check Console/enforcement và test xuyên mobile–web trên cloud cần xác nhận thực tế. AI và ARTEMIS hoãn theo yêu cầu, không tính đã hoàn tất Assignment. Tài liệu Lab 3 cũ là hồ sơ lịch sử; luồng upload Cloudinary và đăng ký trực tiếp trong đó không áp dụng cho Final.

| Nội dung | Tài liệu hiện hành |
|---|---|
| Mobile: cài đặt, Console, test từng bước | [mobile setup](docs/mobile-setup.md) |
| Kiến trúc dùng chung | [architecture](docs/architecture.md) |
| Schema và Rules | [data model](docs/data-model.md), [backend setup](docs/backend-setup.md) |
| Thiết kế thay đổi | [design traceability](docs/design-traceability.md) |
| Khoảng cách còn lại | [gap review](docs/gap-review.md) |
| Luồng mobile–web | [cross-role flow](docs/cross-role-flow.md) |
| Kết quả và bằng chứng | [test report](docs/test-report.md) |

## Hồ sơ slide và báo cáo Lab 3 (chưa phải bài nộp Final)

- 📊 **Slide Thuyết trình Online (34 Slide Trực Quan & Evidence Thực Tế)**: [https://artoriaaas.github.io/PRM393_ASM_Group4/slides/](https://artoriaaas.github.io/PRM393_ASM_Group4/slides/)  
  *(Link fork cá nhân: [https://kietntse.github.io/PRM393_Lab03_Group4_pre/slides/](https://kietntse.github.io/PRM393_Lab03_Group4_pre/slides/))*
- 📑 **Hướng dẫn xem Slide & Xuất PDF chuẩn (34 Slide)**: [slides/README.md](slides/README.md) (xuất ra `slides/Lab03_Group4_slides.pdf`)
- 📄 **Báo cáo tổng kết đồ án (8–12 trang)**: [report/Lab03_Group4_Report.md](report/Lab03_Group4_Report.md) (hướng dẫn xuất PDF tại [report/README.md](report/README.md))


## Kiểm tra trước khi gửi thay đổi

```sh
cd mobile
flutter analyze --no-pub lib test
flutter test --no-pub
flutter build apk --debug -t lib/main.dart
```

Kiểm thử Rules: xem `firebase/tests/README.md`. Chỉ chạy với emulator, không tác động dữ liệu cloud.

Mỗi teammate làm nhánh riêng, review trước khi merge. Thay đổi UI cần lưu ảnh trước/sau và lý do theo [quy ước](evidence/design-changes/README.md), rồi cập nhật Figma.

[Figma Lab 2](https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393). Lab 2 đã chốt; phần bổ sung Lab 3 chưa đồng bộ Figma đầy đủ. Đề gốc yêu cầu ARTEMIS dù tên PDF còn nhắc Patrol.

Kiểm kê chi tiết trang 5–10: [requirements audit](docs/lab3-requirements-audit.md). Ánh xạ token/component: [Flutter handoff](docs/flutter-handoff.md).

## Phiên bản và AI disclosure

Flutter **3.47.4**, Dart **3.13.3**. Các dependency và lockfile nằm riêng ở mobile/, web/ và packages/core/. Mobile dùng firebase_app_check **0.5.1**, share_plus **13.3.1**. ARTEMIS pin **351ca8422f7b5b54e80a9c1ce03a222e02415b6b**; chưa chạy lại cho Final. Xem [validation](evidence/mobile-final/validation.md) để biết kết quả đúng với code mới.

AI sử dụng theo lịch sử nhóm: Stitch hỗ trợ thiết kế, Antigravity hỗ trợ code, Codex hỗ trợ triển khai/review/tài liệu và ARTEMIS/Groq hỗ trợ thử E2E. **Tính năng Gemini cho người dùng chưa được triển khai**. [Code review](docs/code-review.md) ghi các finding/decision; không dùng việc có code review thay thế AI feature theo đề.

Video Final, report Final và slides Final chưa hoàn tất trong hạng mục mobile này. Các báo cáo/slide Lab 3 ở trên không được tính là sản phẩm Final đã đạt.
