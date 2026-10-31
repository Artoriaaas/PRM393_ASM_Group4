# Bằng chứng thay đổi thiết kế

## Yêu cầu của đề và quy ước nhóm

Đề Lab 3 trang 3, mục “Changes to the design”: ghi mọi thay đổi cùng lý do vào `docs/design-traceability.md` và cập nhật Figma để thiết kế/app đồng bộ. Khác biệt không được ghi bị tính là defect. Trang 11 yêu cầu báo cáo nêu mọi khác biệt và slide đặt Figma/app cạnh nhau.

Thư mục ảnh trước/sau và mẫu dưới đây là quy ước nhóm để đáp ứng yêu cầu; không phải tên thư mục bắt buộc của đề. Đề không nói phải xin phép thầy riêng cho mọi chỉnh sửa UI. Khi thay đổi phạm vi/chủ đề hoặc thay dịch vụ bắt buộc, đối chiếu yêu cầu phê duyệt tương ứng trong đề.

## Cách lưu mỗi thay đổi

Tạo thư mục `DC-001-ten-thay-doi/` gồm:

- `before.png`: ảnh màn Final UI Lab 2 đã chốt, trước khi sửa.
- `after.png`: ảnh app sau sửa; ghi rõ nếu mới là prototype mô phỏng.
- `figma-after.png`: thiết kế Figma đã cập nhật, khi có.
- `README.md`: dùng mẫu bên dưới.

Không ghi đè ảnh trước. Giữ đúng màn/state và kích thước so sánh; che thông tin nhạy cảm. Không dùng ảnh mô phỏng làm bằng chứng Firebase hoạt động.

## Mẫu README của một thay đổi

- ID: DC-xxx
- Ngày / người phụ trách:
- Màn / flow / persona bị ảnh hưởng:
- Figma trước: URL + node ID; phiên bản/ngày chốt
- Trước sửa:
- Sau sửa:
- Lý do: vấn đề thực tế / yêu cầu Lab 3 / nền tảng / accessibility / API
- Ảnh trước / ảnh app sau / ảnh Figma sau:
- Route / file code / commit:
- Ảnh hưởng nghiệp vụ và màn liên quan:
- Kiểm tra đã chạy và kết quả thực:
- Trạng thái: đề xuất / đã sửa app / đã đồng bộ Figma / đã kiểm tra
- Phản hồi của nhóm hoặc thầy (nếu có; không tự ghi đã duyệt):

Thêm cùng ID và liên kết thư mục này vào `docs/design-traceability.md`. Bản sửa tiếp theo phải có dấu vết phiên bản, không xóa bằng chứng cũ.
