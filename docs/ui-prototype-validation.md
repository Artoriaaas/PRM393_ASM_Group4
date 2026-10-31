# Kiểm tra UI prototype — 31/10/2026

## Đã chạy

- `flutter analyze`: không có issue.
- `flutter test`: 35/35 pass trong lượt kiểm tra toàn bộ suite.
- Sau chỉnh icon tìm kiếm và chuyển nhãn mô phỏng vào header từng trang: chạy lại `flutter test test/prototype_test.dart`, 5/5 pass; analyzer tiếp tục pass.
- Route smoke test đi qua 19 đích catalog tại cả 360 và 412 dp với text scale 150%, cuộn các phần bên dưới để phát hiện overflow. Các màn auth còn có suite riêng tại text scale 200%.
- Test tương tác A05: thiếu khóa K không đăng ký; nhập K hợp lệ rồi xác nhận chuyển sang A06.
- Test local state: không check-in khi chưa đăng ký; không tạo đăng ký trùng; đã check-in không hủy; tự hủy còn lịch sử; kết quả chưa rõ cần tra trạng thái; khách không bắt buộc K.
- `flutter build apk --debug -t lib/main_prototype.dart`: đã build thành công. Cảnh báo Kotlin Gradle Plugin của Firebase dependency vẫn còn như bản auth, không chặn build.
- Đã cài và mở target prototype trên Android emulator API 35, kiểm tra catalog và Khám phá; cover, icon tìm kiếm và navigation dùng local vector. Ảnh tại `evidence/ui-prototype/` chỉ là bằng chứng UI demo.

## Chưa được chứng minh

Chưa chạy ARTEMIS hoặc test cả ba flow thật với Firebase. Các mutation, email, camera, export/upload và config ở target prototype là mô phỏng; không dùng số test trên để tuyên bố đã đạt backend, độ chính xác QR, bảo mật rules hoặc tiêu chí thời gian của persona. Chưa duyệt pixel từng state so với toàn bộ Figma. Teammate tiếp tục chỉnh theo docs/ui-prototype.md.
