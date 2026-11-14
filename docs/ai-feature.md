# AI — bản nháp nội dung sự kiện cho CLB

Theo mục 8 đề Final: Gemini qua Firebase AI Logic, Level 2 JSON → Dart model → người dùng xác nhận. Tính năng nằm trong form tạo/sửa sự kiện web CLB, không thêm màn chat hoặc tự lưu/công bố.

## Cơ chế

- SDK `firebase_ai` 5.1.0, `FirebaseAI.googleAI()`, responseSchema JSON; không gọi trực tiếp endpoint Google bằng Firebase Web API key.
- Buộc fetch Remote Config khi người dùng yêu cầu (bỏ cache5phút cho hành động này; lỗi fetch thì không gọi model): `ai_feature_enabled`, `ai_model_name`, `ai_prompt_template`. Mặc định tắt nếu chưa có cấu hình. Model cần chọn model Gemini hiện được project hỗ trợ trong Console; không dùng model cũ theo ví dụ.
- App Check phải có token trước khi gọi; lỗi token chặn yêu cầu. Cần cấu hình reCAPTCHA Web và bật enforcement AI Logic trong Console để bảo vệ phía dịch vụ; code local không chứng minh enforcement đã bật.
- Chỉ gửi ý tưởng chung do người dùng nhập riêng (5–500 ký tự), không tự lấy tiêu đề/mô tả toàn form hoặc dữ liệu tài khoản/ảnh. Nhãn nhắc không nhập tên người/thông tin cá nhân; client chặn email, số điện thoại, URL, nhãn định danh và các mẫu nghi tên người bằng bộ lọc local dùng chung. Bộ lọc bảo thủ có thể từ chối nhầm, không bảo đảm nhận diện mọi tên/biệt danh/ngôn ngữ; người dùng chỉ được nhập ý tưởng hoạt động chung, bỏ PII khi được nhắc. Không ghi ý tưởng, prompt, response hoặc raw exception vào Analytics. Lỗi Analytics không làm hỏng thao tác tạo/áp dụng AI.
- Trả về JSON theo schema, kiểm tra type/độ dài/required fields; từ chối text thường, JSON thiếu trường và nội dung nghi PII trong từng trường/hoạt động. Chỉ kết quả đã qua kiểm tra mới vào lịch sử prompt tạo lại.
- Xem trước có nhãn Gemini → Hủy / Tạo lại / Áp dụng phần đã chọn. Chọn riêng danh mục, mô tả, đối tượng, chuẩn bị và hoạt động; ô đã có nội dung không được chọn sẵn. Chỉ Áp dụng mới thay các phần đã chọn và ghi `ai_result_accepted`. Người dùng sửa tiếp rồi tự lưu/gửi duyệt.
- Lỗi cấu hình, App Check, mạng, quota, timeout, output sai: hiện lỗi, giữ form; tiếp tục nhập tay. Không sinh đoạn văn cố định rồi gọi đó là kết quả Gemini.
- `ai_request` khi chuẩn bị gọi model; `ai_error` với mã lỗi cố định; `ai_result_accepted` một lần khi áp dụng mỗi kết quả. State autoDispose theo form, bỏ kết quả muộn khi đóng.

## Thiết lập cần xác nhận

1. Firebase Console → Firebase AI Logic: thiết lập Gemini Developer API cho project chung.
2. Đăng ký App Check web/domain, đặt site key trong file cấu hình local và xác nhận enforcement AI Logic.
3. Publish ba tham số RC; chọn model có sẵn, prompt nội dung sự kiện tiếng Việt, bật cờ khi sẵn sàng. Không đặt Gemini API secret trong app.
4. Mở form CLB trên web triển khai, nhập ý tưởng chung → yêu cầu → xem trước → áp dụng → sửa → lưu. Chạy RC off và lỗi thực tế.

## Bằng chứng thực thi — chưa có

Ba ví dụ trong bản tài liệu cũ không kèm bằng chứng xác minh, vì vậy không còn được ghi là kết quả thực tế. Điền bảng sau bằng kết quả chạy thật; unit test dùng fake không thay thế bằng chứng Gemini.

| Lượt | Chủ đề | Model/RC version | Kết quả JSON thật | Ảnh/log đã lọc PII | Xác nhận |
|---|---|---|---|---|---|
| 1 | Chưa chạy | | | | |
| 2 | Chưa chạy | | | | |
| 3 | Chưa chạy | | | | |
| Lỗi thật/RC off | Chưa chạy | | | | |

Kiểm thử tự động: `web/test/ai_feature_test.dart`. Chưa chốt hoàn tất AI trước khi có cấu hình Console, 3 input/output thật, 1 failure và bằng chứng Analytics.

## Cấu hình cloud đã xác minh — 13/11/2026

- App Check EventHub Web đã đăng ký reCAPTCHA Enterprise, token TTL3600s; key khớp cấu hình local. Source dùng ReCaptchaEnterpriseProvider và FIREBASE_RECAPTCHA_ENTERPRISE_SITE_KEY; key chỉ ở file local bị Git bỏ qua.
- firebasevertexai.googleapis.com và generativelanguage.googleapis.com đã ENABLED.
- Remote Config cloud version6: ai_feature_enabled=true, ai_model_name=gemini-3.5-flash-lite và prompt chung cho nội dung sự kiện. Publish có kiểm tra ETag, chỉ cập nhật 3tham số AI, giữ tham số khác.
- Các mặc định local vẫn tắt khi chưa lấy được cấu hình; không đồng nghĩa cloud đang tắt.
- Chưa xác minh yêu cầu generateContent thành công qua trình duyệt thật, chưa đủ 3kết quả thật/1failure. API App Check đã xác nhận service firebaseml.googleapis.com (Firebase AI Logic) ENFORCED; vẫn cần request hợp lệ trên trình duyệt để chốt end-to-end.

Bản web Enterprise đã build và deploy thành công lên https://eventhub-group4.web.app ngày 13/11/2026. Site key chỉ cho phép eventhub-group4.web.app và eventhub-group4.firebaseapp.com, loại SCORE, xác minh domain bật. Cần test trên URL Hosting này; localhost chưa nằm trong domain key.

### Xem trước và tạo lại — cập nhật 14/11/2026
Người dùng xem bản nháp trong popup với Hủy, Tạo lại và Áp dụng. Hủy không đổi form; Tạo lại gửi một yêu cầu mới, không tự áp dụng. Prompt yêu cầu đổi góc tiếp cận theo chủ đề và tránh ba bản nháp gần nhất trong phiên; kết quả trùng mô tả và hoạt động bị từ chối. Không bảo đảm mọi câu chữ luôn khác nhau. Chưa xác nhận kết quả Gemini thật sau thay đổi này.

AI chỉ đề xuất nội dung theo ý tưởng, không chọn ngày giờ, địa điểm, hạn đăng ký hoặc sức chứa. JSON chỉ nhận đúng 5 trường nội dung; không cập nhật các controller ngày giờ/chế độ/địa điểm khi áp dụng. Mỗi lần Tạo lại là một yêu cầu mới do người dùng chủ động, không tự retry dùng thêm quota. Chưa xác nhận kết quả Gemini thật sau thay đổi đầu vào tự do này.
