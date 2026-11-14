# Gap review Final — chốt source 14/11/2026

## Phần source đã kiểm tra

- Mobile87, web51 và core10 tests đạt; kiểm tra nguồn dữ liệu Firestore, MVVM, shared core, đăng ký pending→staff approve/reject, inbox, QR, PDF local/share và metadata riêng UID qua các test hiện có.
- Mobile UI đối chiếu ảnh F1/F2/F4A, xử lý vùng an toàn Android; preview A04 trên web theo bố cục mới. Không chép dữ liệu mẫu hoặc nút mô phỏng prototype vào build.
- Phân quyền: Admin phân công email, đại diện Google ghi danh tính chờ kích hoạt, chỉ Admin khác UID cấp staff. Rules đã được triển khai ở commit trước, bộ hiện tại61 ca lá đạt; không thay Rules trong lượt sửa AI này.
- AI Firebase AI Logic, JSON→Dart, popup chọn phần áp dụng, nhập tay khi lỗi/RC tắt. Thêm sàng lọc nghi PII local trước RC/token/model và trong output; không log nội dung. Bộ lọc có thể từ chối nhầm và không nhận diện mọi tên/biệt danh/ngôn ngữ; chỉ nhập ý tưởng hoạt động chung. Không gọi Gemini để phân loại PII.
- Lỗi Analytics không chặn tạo/áp dụng AI; equality bản nháp bao gồm hoạt động. Review findings/decisions ở docs/code-review.md.
- Harness ARTEMIS nhận cả report final_screen phẳng/lồng mà không suy diễn giá trị; giữ raw report và không nhận thiếu/mâu thuẫn là pass. Yêu cầu serial điện thoại thật. Ba unittest parser chạy local không được tính là ARTEMIS E2E pass.

## Cấu hình cloud đã đọc thật

Theo evidence/cloud-readiness/config-status.json ngày14/11: Web Enterprise/Android Play Integrity đã đăng ký, AI Logic ENFORCED, Firestore UNENFORCED. Cửa sổ24h có web AI VALID4 và Android Firestore VALID380; chưa có hàng Firestore web VALID trong lần quan sát. HostingHTTP200, RCv6 bật AI. Đây không phải bằng chứng ba output Gemini/cross-role chạy thành công.

## Việc còn lại trước nộp

1. Xác nhận request Firestore web/mobile hợp lệ, chốt enforcement và thử lại; không bật vội làm khóa client.
2. Cài APK mới trên điện thoại thật, kiểm thử chức năng và trạng thái một lượt; sửa lỗi thực tế nếu phát hiện. Không thể cam kết không còn lỗi chỉ từ unit test.
3. Lưu3input/output Gemini thật,1lỗi,RCoff và Analytics; cross-role3lượt deployment kèm độ trễ/ảnh/video. Bộ slide nhóm được giữ nguyên.
4. ARTEMIS đủ flow Lab2/cross-role/AI,3lượt và trace/pass rate. Bộ kết quả cũ25ca×3 đều skipped, chưa đạt; coverage Final chưa được chốt.
5. README Admin đầu tiên/demo accounts/ID/video; report10–15trang, slidePDF12–15trang, video8–12phút. Đồng bộ đối chiếu thiết kế theo tài liệu traceability. Không có yêu cầu phải thêm chức năng mới hoặc backend riêng.

Thực hiện theo docs/final-live-verification.md. Nguồn và cấu hình chỉ là tiền điều kiện; chỉ đánh dấu chạy thật đạt khi đã lưu bằng chứng.
