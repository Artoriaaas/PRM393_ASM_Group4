# AI feature — yêu cầu Final, chưa triển khai

Tài liệu trạng thái, không phải bằng chứng có tính năng. Người dùng đang hoãn AI; vẫn cần hoàn thành trước nộp. Đề mục 8 cho phép AI ở **một trong hai client**, không bắt buộc thêm màn mobile.

Checklist theo đề:

- [ ] Một tính năng hỗ trợ một bước Lab 2, gọi Gemini qua Firebase AI Logic (Gemini Developer API).
- [ ] App Check; model name, prompt và on/off flag từ Remote Config.
- [ ] Không gửi tên/email/ảnh người; hiển thị nhãn AI, người dùng chỉnh sửa/confirm.
- [ ] Quota/mạng lỗi vẫn tiếp tục flow không AI.
- [ ] Analytics ai_request, ai_result_accepted, ai_error.
- [ ] Mức full theo rubric: JSON → Dart model, user confirmation. Mức 1 streamed text chỉ partial; mức 3 function calling là bonus, không bắt buộc.
- [ ] Ba input/output thật và một failure handled có bằng chứng.
- [ ] Test và demo live cả trường hợp Remote Config tắt AI.

Không điền ví dụ giả, không tự chọn tính năng mở rộng ngoài flow đã duyệt. Chốt bước sử dụng AI với nhóm khi bắt đầu triển khai.
