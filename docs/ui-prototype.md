# Bộ giao diện tương tác để chia việc

Ngày 31/10/2026. Mục đích: cho nhóm xem, bấm và chỉnh UI trước khi nối toàn bộ backend. **Không phải bằng chứng hoàn thành các flow Firebase của Lab 3.**

## Chạy bản prototype

```powershell
flutter pub get
flutter run -d emulator-5554 -t lib/main_prototype.dart
```

Hoặc chọn cấu hình **EventHub — UI Prototype (local demo)** trong VS Code/Antigravity. Thay ID thiết bị theo `flutter devices`. Không cần Firebase project, thẻ thanh toán hoặc API key để xem bản này.

Ứng dụng mở A01a, luôn có banner `UI PROTOTYPE • DỮ LIỆU MÔ PHỎNG • KHÔNG FIREBASE`. Các thao tác tài khoản trong bản này chỉ đổi session trong bộ nhớ. Chọn Google hoặc nhập email đúng định dạng và mật khẩu bất kỳ không rỗng để tiếp tục xem. Tạo tài khoản → kiểm tra email → bấm Tôi đã xác nhận email cũng là mô phỏng; không gửi thư thật. Không nhập mật khẩu cá nhân vào prototype.

Ở A01, bấm **Danh sách màn prototype** để mở catalog. Ở các màn khác dùng icon lưới góc phải. Catalog có 19 đích giao diện: A01a–d, A02–A12, tham gia tự do, sửa hồ sơ và hai màn bổ sung Lab 3. Mở thẳng màn cần review sẽ chuẩn bị trạng thái local phù hợp; đây là cách review riêng từng màn, không dùng để chứng minh đường đi E2E.

Icon thanh trượt góc phải mở **Trạng thái mô phỏng**: mặc định, loading, empty, lỗi mạng, kết quả chưa rõ, hết chỗ/hạn, CLB hủy, phiên đóng, đã kết thúc, camera denied và QR sai. Chọn trạng thái phù hợp màn đang xem; ví dụ Hết chỗ áp dụng A04, camera denied áp dụng A11. Chọn Mặc định để quay lại; loading kéo dài cho tới khi đổi trạng thái để dễ review.

## Màn và phần code

| Nhóm | File | Nội dung |
|---|---|---|
| A01a–d | `lib/screens/auth/auth_screen.dart` | Dùng chung UI auth thật; service được inject khác tại entrypoint prototype |
| A02/A03/A04 | `lib/dev/prototype/event_screens.dart` | Danh sách, search, sheet chủ đề, CLB, detail có đăng ký/tự do |
| A05/A06/A07/A08 | `lib/dev/prototype/registration_screens.dart` | Form sinh viên/khách, xác nhận, lịch/tab, chi tiết/dialog hủy |
| A09/A11/A12 | `lib/dev/prototype/participation_screens.dart` | Thông báo, camera giả lập, kết quả điểm danh không lộ contact |
| A10 và L3-01/02 | `lib/dev/prototype/account_screens.dart` | Profile/edit, trạng thái email chờ, export/upload/config preview |
| Khối UI dùng lại | `lib/dev/prototype/prototype_widgets.dart` | Cover vector, event card, summary, participant, message, page shell |
| State/fixture/adapter demo | `lib/dev/prototype/prototype_state.dart` | Toàn bộ dữ liệu mẫu và mutation local; không dùng trong main.dart |
| Route/catalog/injection | `lib/dev/prototype/prototype_app.dart` | Routing riêng, catalog và scope service demo |

Các file ở `lib/dev/` là bản xem thử có thể chỉnh sửa. Khi triển khai một feature thật, giữ bố cục/component đã duyệt và đưa vào `lib/screens/`/`lib/widgets/`, thay phần đọc `prototypeProvider` bằng ViewModel/service của feature theo architecture.md. Không đưa fixture, delay hoặc success mô phỏng vào adapter Firebase.

## Ba kịch bản chạy liền mạch

1. **F1 — P01/P02:** login demo → Khám phá → tìm/chọn workshop → Đăng ký → A05. Sinh viên bắt buộc K, khách ẩn K và cho trường/tổ chức tùy chọn. Xác nhận → loading → A06 → lịch. Còn 24 chỗ trước đăng ký, 23 sau đăng ký; chọn lại mở A08. Lỗi form không mất dữ liệu; trạng thái chưa rõ yêu cầu Kiểm tra trạng thái. P03 chọn Acoustic → đọc giờ/địa điểm, không có CTA đăng ký, không tạo lịch/QR.
2. **F2:** A07 → A08 → Hủy → dialog. Giữ đăng ký không đổi; xác nhận hủy → loading → lịch cập nhật. Tab Đã hủy giữ lịch sử; phân biệt tự hủy và CLB hủy. Chọn lỗi mạng hoặc chưa rõ ở A08 để xem nhánh phục hồi. Điểm vào phụ qua A09 và A10.
3. **F4A:** dùng đăng ký đang active → A08 → Quét QR → **Mô phỏng quét QR** → loading → A12 → lịch. Không mở camera hoặc ghi điểm danh thật. Menu cho sai QR, chưa quyền, phiên đóng, hủy và chưa rõ kết quả. Catalog A12 chuẩn bị kết quả local để review độc lập. Thời gian check-in gốc 14:05 được giữ; không gửi email/số điện thoại lên A12.

Ngày workshop 24/10/2026 là snapshot thiết kế từ Lab 2; bản xem thử không dùng đồng hồ hôm nay để suy ra hết hạn. Nếu chọn trạng thái Đã kết thúc trên lịch thì chuyển tab Đã kết thúc để xem biến thể.

## Cách chia việc đề xuất

- Người làm UI F1 nhận `event_screens.dart` và `registration_screens.dart`; giữ theme, review trước khi đổi component chung.
- Người làm F2/profile nhận lịch, chi tiết đăng ký, thông báo, account; thống nhất model đăng ký và email liên hệ trước khi nối Firebase.
- Người làm F4A nhận camera/kết quả; kết nối native camera và CheckInService sau khi backend kiểm tra đủ điều kiện.
- Người phụ trách Firebase nhận service/rules/Functions; người review kiểm tra UI với Figma và test trước khi merge.

Tạo nhánh feature riêng cho mỗi phần; tránh cùng sửa một file tại một thời điểm. Nếu chia người theo module, tách màn trong file nhóm thành file riêng ở commit đầu của module. Trước khi đổi contract/service dùng chung, thống nhất tên và kiểu với nhóm.

## Fidelity và giới hạn đã biết

Đã đọc design context/screenshot Figma cho A01a–d, A02 `164:241`, A03 `179:599`, A04 `164:336`, A05 `179:965`, A06 `179:1538`, A07 `179:1581`, A08 `181:1345`, A09 `181:1767`, A10 `181:1982`, A11 `182:1804`, A12 `182:1995`. Dùng Be Vietnam Pro, token và component hiện có; cover tạo bằng shape/text/vector theo lớp thiết kế, không phủ ảnh màn hình lên UI.

- Có thanh điều khiển development và banner nên vùng nhìn khác bản Present; không gọi bản này khớp pixel tuyệt đối hoặc đã duyệt thay Figma.
- Filter ngày đang giải thích mốc snapshot; search/nhóm chủ đề/CLB hoạt động trên hai fixture. Cần backend search và query thật khi làm F1.
- Error/loading cho review và mutation demo không phải lỗi cloud thật. Không lưu qua lần khởi động; preset/catalog có thể thay state local. Dữ liệu email `example.com` là mẫu.
- Camera, Google picker, email verification, export/PDF, upload/download URL, FCM, Remote Config và Crashlytics trong prototype chưa dùng dịch vụ thiết bị/cloud. Những phần này có nhãn mô phỏng rõ ràng.
- Khu Lab 3 export/config là bố cục bổ sung, cần chốt thiết kế và ghi deviation. Chính sách phát hành chưa hoàn thiện.
- Bản production chạy bằng `flutter run -t lib/main.dart`; build nộp cũng chỉ định `-t lib/main.dart`. Target prototype từ chối chạy release. Không dùng APK prototype làm app nộp Lab 3.

## Điểm dừng review

Trước khi từng teammate nối backend: duyệt bố cục màn của module, kiểm tra Back/CTA và state lỗi; sau đó thay service, test dữ liệu thật và cập nhật design-traceability.md. Tiến độ UI prototype không tự đánh dấu các bước Firebase/F1/F2/F4A hoàn thành.
