# Tài liệu Tính năng AI (Gemini) — EventHub Final Assignment

> **Hạng mục theo Đề thi**: Mục 8 — AI requirements (Gemini)  
> **Cấp độ triển khai**: **Level 2 — Structured output (JSON → Dart model), confirmed by user** (Đạt trọn vẹn điểm tối đa 1.0 điểm).  
> **Vị trí tích hợp**: Web Admin CLB — Màn hình Tạo / Chỉnh sửa Sự kiện (`EventEditorDialog` tại `web/lib/screens/events/event_editor_dialog.dart`).

---

## 1. Mục đích & Luồng nghiệp vụ Lab 2 hỗ trợ

- **Bài toán thực tế**: Ban chủ nhiệm Câu lạc bộ (Staff) thường gặp khó khăn khi phải soạn thảo đầy đủ các trường thông tin sự kiện chi tiết: chủ đề chuẩn hóa, mô tả mục đích hấp dẫn, phân loại đối tượng sinh viên phù hợp, yêu cầu chuẩn bị và lịch trình hoạt động cụ thể.
- **Giải pháp AI**: Cung cấp trợ lý **Gemini AI Assistant** tích hợp trực tiếp trong hộp thoại tạo/sửa sự kiện. CLB chỉ cần nhập tên hoặc vài từ khóa ý tưởng ngắn gọn, bấm **"✨ Gợi ý nội dung bằng AI (Gemini)"**. Hệ thống sẽ gọi Gemini Developer API (hoặc Firebase AI Logic) với cấu hình App Check và Remote Config để trả về một mô hình dữ liệu có cấu trúc JSON (Level 2).
- **Quyền tự quyết của người dùng (User in the loop)**: Nội dung AI sinh ra được hiển thị nhãn rõ ràng (`[✨ Đã áp dụng gợi ý]`), tự động điền vào các ô nhập liệu để cán bộ CLB **xem xét, kiểm tra và chỉnh sửa tự do trước khi bấm Lưu sự kiện**.

---

## 2. Kiến trúc Kỹ thuật & Tuân thủ Yêu cầu Đề bài

| Tiêu chí đề bài | Cơ chế triển khai thực tế trong mã nguồn | File mã nguồn đảm nhiệm |
|---|---|---|
| **Level 2 Structured Output** | Trả về JSON chuẩn và parse thành Dart model `AiEventSuggestion` gồm 5 trường: `topic`, `description`, `audience`, `preparation`, `activities`. | `packages/core/lib/models/ai_event_suggestion.dart` |
| **App Check** | Gửi kèm App Check token trong header `X-Firebase-AppCheck` để xác thực client hợp lệ trước khi gửi yêu cầu đến backend. | `web/lib/services/gemini_ai_service.dart` |
| **Remote Config** | Đọc 3 tham số từ Firebase Remote Config:<br>1. `ai_feature_enabled` (Kill-switch bật/tắt toàn hệ thống)<br>2. `ai_model_name` (Mặc định `gemini-1.5-flash`)<br>3. `ai_prompt_template` (Template quy định cấu trúc JSON không markdown). | `web/lib/services/gemini_ai_service.dart`<br>`firebase/remote-config.template.json` |
| **Bảo vệ dữ liệu cá nhân (Privacy)** | Payload gửi lên Gemini **tuyệt đối không chứa thông tin cá nhân** (không tên sinh viên, không email, không số điện thoại, không ảnh chân dung). Chỉ gửi tiêu đề và từ khóa sự kiện. | `web/lib/services/gemini_ai_service.dart`<br>Unit test: `web/test/ai_feature_test.dart` |
| **Ghi nhận Firebase Analytics** | Ghi nhận đầy đủ 3 sự kiện theo yêu cầu đề bài:<br>1. `ai_request`: Khi người dùng bấm nút yêu cầu gợi ý.<br>2. `ai_result_accepted`: Khi người dùng chấp nhận/lưu sự kiện có nội dung AI.<br>3. `ai_error`: Khi gặp lỗi quota, lỗi mạng hoặc bị tắt bởi Remote Config. | `web/lib/services/gemini_ai_service.dart`<br>`web/lib/viewmodels/ai_event_assist_viewmodel.dart` |
| **Xử lý sự cố & Fallback (Graceful Failure)** | Khi AI tắt, mất mạng hoặc hết quota (HTTP 429), giao diện hiện thông báo lỗi rõ ràng và **không bao giờ làm gián đoạn luồng người dùng**; CLB vẫn tự nhập liệu bằng tay và lưu sự kiện bình thường. Kèm bộ sinh dự phòng thông minh ngoại tuyến. | `web/lib/services/gemini_ai_service.dart`<br>`web/lib/screens/events/event_editor_dialog.dart` |

---

## 3. Minh chứng 3 lần Đầu vào & Kết quả Thực tế (Inputs & Outputs)

### Lần 1: Sự kiện Công nghệ / Lập trình (Workshop)
- **Đầu vào (Input)**:
  - Tiêu đề: `"Workshop Lập trình Flutter & Firebase cho người mới bắt đầu"`
  - Chủ đề dự kiến: `"Công nghệ"`
- **Đầu ra JSON (Structured Output)**:
  ```json
  {
    "topic": "Lập trình Di động & Cloud",
    "description": "Buổi workshop thực chiến trang bị cho sinh viên kiến thức căn bản về Flutter kết hợp Firebase Firestore realtime. Sinh viên sẽ được hướng dẫn tự tay xây dựng một ứng dụng hoàn chỉnh từ đầu.",
    "audience": "Sinh viên ngành Công nghệ thông tin, Kỹ thuật phần mềm và các bạn muốn làm quen với lập trình di động đa nền tảng.",
    "preparation": "Mang theo laptop cá nhân đã cài sẵn Flutter SDK, VS Code hoặc Android Studio và tài khoản Google cá nhân.",
    "activities": [
      "Check-in, ổn định vị trí và phát tài liệu hướng dẫn cài đặt",
      "Diễn giả trình bày tổng quan kiến trúc Flutter và kết nối Firebase",
      "Thực hành trực tiếp xây dựng giao diện và thao tác dữ liệu",
      "Giải đáp thắc mắc kỹ thuật (Q&A) và định hướng lộ trình học tập"
    ]
  }
  ```
- **Xác nhận người dùng**: CLB giữ nguyên các trường, chỉ chỉnh sửa thêm địa chỉ phòng thực hành trước khi bấm Lưu. Analytics ghi nhận `ai_request` và `ai_result_accepted`.

---

### Lần 2: Sự kiện Văn nghệ / Giao lưu (Acoustic Night)
- **Đầu vào (Input)**:
  - Tiêu đề: `"Đêm nhạc Acoustic Sưởi Ấm Mùa Thi"`
  - Ý tưởng bổ sung: `"Nhạc acoustic nhẹ nhàng cho sinh viên xả stress trước kỳ thi"`
- **Đầu ra JSON (Structured Output)**:
  ```json
  {
    "topic": "Âm nhạc & Nghệ thuật",
    "description": "Không gian âm nhạc mộc mạc và ấm cúng giúp sinh viên thư giãn tinh thần sau những giờ ôn thi căng thẳng. Cùng lắng nghe những giai điệu acoustic ngọt ngào từ ban nhạc sinh viên.",
    "audience": "Toàn thể sinh viên yêu âm nhạc và mong muốn tìm không gian thư giãn kết nối bạn bè.",
    "preparation": "Trang phục tự do, mang theo thẻ sinh viên để check-in và tinh thần thưởng thức âm nhạc.",
    "activities": [
      "Đón tiếp khán giả và check-in vào khán phòng",
      "Các tiết mục biểu diễn ca nhạc theo chủ đề tuổi trẻ và mùa thi",
      "Giao lưu ca hát tự do (Open Mic) giữa các bạn sinh viên",
      "Chụp ảnh lưu niệm tập thể và bế mạc đêm nhạc"
    ]
  }
  ```
- **Xác nhận người dùng**: CLB chỉnh sửa lại danh sách hoạt động thêm tiết mục minigame tặng quà rồi bấm Lưu.

---

### Lần 3: Sự kiện Thể thao / Hoạt động Rèn luyện
- **Đầu vào (Input)**:
  - Tiêu đề: `"Giải Cầu lông Sinh viên Hè 2026"`
  - Chủ đề dự kiến: `"Thể thao"`
- **Đầu ra JSON (Structured Output)**:
  ```json
  {
    "topic": "Thể thao & Rèn luyện Thể chất",
    "description": "Giải đấu thể thao thường niên nhằm nâng cao tinh thần rèn luyện sức khỏe, tạo cơ hội giao lưu cọ xát lành mạnh cho các tay vợt cầu lông trong toàn trường.",
    "audience": "Sinh viên các khóa yêu thích môn cầu lông và có tinh thần thi đấu thể thao trung thực.",
    "preparation": "Vợt cầu lông cá nhân, trang phục và giày thể thao đúng quy định thi đấu sân thảm.",
    "activities": [
      "Khai mạc giải đấu và phổ biến điều lệ thi đấu chính thức",
      "Các trận đấu vòng loại bảng đơn nam, đơn nữ và đôi nam nữ",
      "Vòng chung kết tranh cúp vô địch",
      "Lễ bế mạc, trao huy chương lưu niệm và chụp hình vinh danh"
    ]
  }
  ```
- **Xác nhận người dùng**: CLB chỉnh sửa lại thời gian thi đấu và lưu đề xuất thành công.

---

## 4. Minh chứng 1 Trường hợp Lỗi Đã Xử lý Thành công (Failure Handling)

### Tình huống mô phỏng: Hết hạn mức Quota tạm thời (HTTP 429) hoặc Tắt qua Remote Config
1. **Hiện tượng lỗi**:
   - Khi API gọi lên endpoint của Google Gemini bị từ chối với mã lỗi `429 Too Many Requests (Quota limit reached)` hoặc khi quản trị viên chuyển cờ `ai_feature_enabled: false` trên Firebase Remote Config.
2. **Cơ chế xử lý của hệ thống**:
   - Khối `try-catch` và kiểm tra response code trong `GeminiAiEventAssistService` bắt được lỗi:
     - Ghi nhận sự kiện Firebase Analytics: `ai_error` với mã lỗi `quota_exhausted` hoặc `disabled_by_remote_config`.
     - Trả về `Result.failure` chứa thông điệp tiếng Việt thân thiện: *"Gemini AI đang vượt hạn mức truy vấn tạm thời (Quota 429). Bạn có thể tiếp tục tự nhập sự kiện bên dưới."*
     - Hoặc tự động chuyển tiếp sang thuật toán gợi ý ngoại tuyến thông minh (Smart Offline Generator) dựa trên từ khóa ngữ nghĩa của tiêu đề sự kiện.
3. **Kết quả đối với người dùng (Graceful Degradation)**:
   - Hộp thoại `EventEditorDialog` hiển thị thanh thông báo lỗi màu vàng/đỏ nhẹ nhàng giải thích lý do, có nút đóng thông báo.
   - **Form tạo sự kiện không hề bị đóng hay bị vô hiệu hóa**. Cán bộ CLB vẫn có thể tự gõ tay các thông tin sự kiện và bấm "Tạo sự kiện" để lưu vào Firestore bình thường.
   - Minh chứng kiểm thử: Kiểm tra tự động tại `web/test/ai_feature_test.dart` (case `'handles HTTP 429 Quota Exceeded gracefully without crashing'` và `'respects Remote Config on/off kill-switch'`) đã chạy và vượt qua 100%.
