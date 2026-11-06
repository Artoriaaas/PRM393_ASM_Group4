# Danh Mục & Quy Chuẩn Thu Thập Bằng Chứng (`evidence/`)

> **Nguyên tắc chấm điểm của môn PRM393 (Lab 3 & Final Assignment)**:
> *"Each requirement names its evidence; work that cannot be shown is graded as missing. A criterion without evidence is not met."*
> Mọi khẳng định trong Báo cáo (`report/`) và Slide (`slides/`) đều phải dẫn chiếu tới tệp thật trong thư mục `evidence/` này.

---

## 1. Năm Quy tắc Bắt buộc trước khi Lưu Ảnh / Log vào `evidence/`

1. **Khớp `project_id` trên Firebase Console**: Mọi ảnh chụp trên Firebase Console phải thấy rõ tên/mã dự án **`eventhub-group4`** ở góc trên, khớp với `android/app/google-services.json`.
2. **Không lấy ảnh Prototype / Fixture làm bằng chứng Cloud**:
   - Các ảnh hiện có ở `ui-prototype/`, `component_preview*.png`, hoặc ảnh gắn hậu tố `*-ui-fixture.png` chỉ dùng để đối chiếu bố cục giao diện (UI/Theme).
   - Bằng chứng nghiệp vụ Firebase, Cross-role và ARTEMIS **bắt buộc chụp từ bản chạy thật** (`flutter run -t lib/main.dart` trên Android và Live URL Firebase Hosting trên Web).
3. **Bảo mật & Chống lộ dữ liệu cá nhân (PII / Secrets)**:
   - Không lưu `.env`, API key, token đăng nhập, chuỗi QR gốc (`qrToken`), hay file `service-account.json`.
   - Sử dụng **tài khoản Google kiểm thử riêng** của nhóm; trong ảnh Analytics DebugView và log AI không được xuất hiện họ tên thật, email hay số điện thoại trong `parameters`.
4. **Đủ thông tin ngữ cảnh trong một bức ảnh**: Không cắt (crop) quá sát làm mất tiêu đề màn hình, trạng thái hoặc thanh URL/Console header.
5. **Chỉ đánh dấu `[x]` khi tệp đã tồn tại thật**: Tuyệt đối không ghi số liệu giả hoặc mượn ảnh từ dự án khác (vi phạm Mục 11 Lab 3 / Mục 12 Final Assignment).

---

## 2. Phân loại Các Tệp Đã Có Sẵn trong `evidence/`

| Đường dẫn hiện có | Loại bằng chứng | Được dùng cho mục nào? |
|---|---|---|
| [backend/validation.md](backend/validation.md) | Nhật ký chạy unit test & Firestore Emulator (`62/62` Flutter tests, `4/4` Rules tests) | Chứng minh kiểm thử local & Emulator; **chưa thay thế** bằng chứng E2E trên cloud |
| [cloud/remote-config-fetch-android.png](cloud/remote-config-fetch-android.png) | Ảnh chạy Android thật đọc Remote Config | Một phần của mục Remote Config (cẫn cần bổ sung cặp Before/After đổi giá trị trên Console) |
| [design-changes/](design-changes/README.md) (`D03`, `D08`, `D11`) | Ảnh đối chiếu thay đổi UI so với Lab 2 | Mục Design Traceability (`D11` đã chụp Android; `D03`, `D08` còn là ảnh fixture, cần chụp lại bản thật & cập nhật Figma) |
| [web-admin/README.md](web-admin/README.md) | Nhật ký AI Disclosure & Checklist 11 ảnh Web | Quản lý bằng chứng riêng cho Flutter Web CLB & Admin |
| `component_preview*.png`, `ui-prototype/*`, `step4/*` | Ảnh kiểm tra kích thước 360dp/widget & prototype | Chỉ minh họa Design System / quá trình phát triển UI; **không đưa vào phần bằng chứng Cloud** |

---

## 3. Checklist Bằng chứng Cần Thu Thập (Chuẩn hóa Đường dẫn & Tên File)

### 3.1. Authentication & Kiểm soát Vai trò (`evidence/auth/`)
- [ ] `auth/01-mobile-signed-out.png` — Màn hình `A01` khi chưa đăng nhập (chứng minh AuthGate chặn vào màn trong).
- [ ] `auth/02-mobile-google-cancelled.png` — Thông báo lỗi rõ ràng trên `A01` khi người dùng bấm hủy chọn tài khoản Google.
- [ ] `auth/03-mobile-signed-in-home.png` — Màn hình trang chủ `A02` sau khi đăng nhập thành công bằng tài khoản test.
- [ ] `auth/04-mobile-role-rejection.png` — *(Final)* Thông báo chặn khi tài khoản `staff` / `admin` đăng nhập vào Mobile App.
- [ ] `auth/05-console-auth-users.png` — Tab **Firebase Console → Authentication → Users** thấy rõ `eventhub-group4` và các tài khoản demo theo từng role (`user`, `staff`, `admin`).

### 3.2. Firestore Data Model, Security Rules & Xuất File PDF (`evidence/firestore-rules/` & `evidence/export/`)
- [ ] `firestore-rules/emulator-rules-test-log.txt` (kèm ảnh terminal `.png`) — Đầu ra chạy toàn bộ ca test Security Rules trên Firebase Emulator: **pass 100%** tối thiểu 1 ca `Allowed` và 1 ca `Denied` cho mỗi role (`user`, `staff`, `admin`) trên mỗi collection (khớp bảng Appendix B).
- [ ] `firestore-rules/console-collections.png` — Ảnh Firebase Console → Firestore Database hiển thị cấu trúc dữ liệu thật (`users`, `clubs`, `events`, `registrations`, `announcements`).
- [ ] `export/01-pdf-generated-mobile.png` — Màn hình tạo/chia sẻ báo cáo PDF lịch tham gia tiếng Việt trên thiết bị.
- [ ] `export/02-pdf-cloud-or-metadata.png` — *(Lab 3)* Ảnh tiến độ + URL Cloudinary Media Library (kèm ghi nhận giảng viên duyệt thay Storage) **HOẶC** *(Final)* Ảnh lưu metadata báo cáo PDF trên Firestore theo kiến trúc Mục 4 đề Final.

### 3.3. Cloud Messaging (FCM) & Hộp thư Thông báo (`evidence/fcm-inbox/`)
- [ ] `fcm-inbox/01-android13-permission-dialog.png` — Hộp thoại hệ thống xin quyền thông báo trên Android 13+.
- [ ] `fcm-inbox/02-fcm-foreground.png` — Nhận test message từ Firebase Console khi ứng dụng đang mở (`foreground`).
- [ ] `fcm-inbox/03-fcm-background.png` — Nhận thông báo trên thanh trạng thái khi ứng dụng chạy nền (`background`) và chạm mở đúng màn hình đích.
- [ ] `fcm-inbox/04-fcm-terminated.png` — Nhận và mở thông báo khi ứng dụng đã đóng hẳn (`terminated`).
- [ ] `fcm-inbox/05-mobile-inbox-realtime.png` — Tab Thông báo `A09` hiển thị danh sách thông báo trong app (cả thông báo xét duyệt đăng ký và `announcements` gửi từ Web Admin).

### 3.4. Firebase Analytics — DebugView (`evidence/analytics/`)
> Mở **Firebase Console → Analytics → DebugView**, bấm vào từng sự kiện để chụp rõ **tên event + danh sách tham số (`parameters`) + `user_id`** (xác nhận không chứa email/họ tên):

- [ ] `analytics/01-login-logout.png` — Sự kiện `login` (`method`) và `logout` (`method`).
- [ ] `analytics/02-search-and-screens.png` — Sự kiện `search` (`query_length`), `view_screen`, `view_event_detail` (`A04`), `view_registration_detail` (`A08`), `view_checkin_result` (`A12`).
- [ ] `analytics/03-booking-events.png` — Sự kiện `booking_submit`, `booking_result` (`action`, `result`), `booking_recover`.
- [ ] `analytics/04-export-notif-config.png` — Sự kiện `export_generate` (`row_count`), `export_upload` (`byte_count`), `notification_open`, `remote_config_fetch`.
- [ ] `analytics/05-ai-events.png` — *(Final)* Đủ 3 sự kiện bắt buộc của tính năng Gemini: `ai_request`, `ai_result_accepted`, `ai_error`.

### 3.5. Firebase Crashlytics (`evidence/crashlytics/`)
- [ ] `crashlytics/01-dashboard-overview.png` — Crashlytics Dashboard hiển thị rõ cả **1 sự cố Non-fatal** (từ luồng lỗi thật) và **1 sự cố Fatal** (test crash có kiểm soát).
- [ ] `crashlytics/02-issue-keys-userid.png` — Trang chi tiết sự cố mở tab **Keys / Data** chứng minh có gắn `userId` và custom key (`app_flow = eventhub`).

### 3.6. Firebase Remote Config & App Check (`evidence/remote-config/`)
- [ ] `remote-config/01-console-parameters.png` — Màn hình Firebase Console → Remote Config hiển thị các tham số (`recommendation_limit`, `show_recommendations`, và ở Final có thêm `ai_enabled`, `ai_model`, `ai_prompt`).
- [ ] `remote-config/02-mobile-before-change.png` — Màn hình Khám phá `A02` trước khi đổi cấu hình.
- [ ] `remote-config/03-mobile-after-change-no-rebuild.png` — Màn hình Khám phá `A02` thay đổi ngay hành vi (ẩn khu gợi ý hoặc đổi giới hạn số thẻ) sau khi publish trên Console mà **không build lại APK**.
- [ ] `remote-config/04-app-check-enforced.png` — *(Final)* Ảnh cấu hình **App Check** đang bật cho Cloud Firestore và Firebase AI Logic trên Console.

### 3.7. Kiểm thử Tự động E2E Google ARTEMIS (`evidence/artemis/`)
- [ ] `artemis/run-command-and-summary.txt` — Lệnh CLI đã thực thi và bảng tổng hợp kết quả chạy (`>= 10` ca ở Lab 3; toàn bộ flow Lab 2 + bước mobile cross-role + AI feature ở Final), mỗi ca chạy **tối thiểu 3 lần** kèm pass rate & thời gian trung bình.
- [ ] `artemis/traces/` — Các tệp kết quả JSON / trace ID và ảnh chụp màn hình hoặc video replay cho từng lượt chạy (đã ẩn email cá nhân nếu có).
- [ ] `artemis/exploratory-pro-session.md` (kèm trace) — Báo cáo phiên kiểm thử khám phá không kịch bản bằng profile **Pro (15–30 phút)** và danh sách vấn đề phát hiện được.

### 3.8. AI Code Review (`evidence/code-review/`)
- [ ] `code-review/pr-ai-review-raw.md` (hoặc `.pdf` / bộ ảnh chụp `.png`) — Đầu ra nhận xét nguyên bản của công cụ AI review (Copilot / CodeRabbit / SonarCloud / Kodus) chạy trên Pull Request thật.
- [ ] `code-review/fix-commits-proof.png` — Ảnh lịch sử Git hiển thị các commit sửa lỗi độc lập có gắn mã ID finding (Lab 3: `>= 5` findings & `>= 3` fix commits; Final: thêm `>= 3` findings trên code mới).

### 3.9. Web Admin Checklist (`evidence/web-admin/`)
- [ ] Hoàn thành đủ **11 ảnh (`W-EV-01` → `W-EV-11`)** cho các màn hình của Trưởng CLB (`staff`) và Quản trị viên (`admin`) theo bảng kiểm chi tiết tại **[evidence/web-admin/README.md](web-admin/README.md)**.

### 3.10. Luồng Liên Vai Trò — Cross-Role Flows (`evidence/cross-role/`)
- [ ] `cross-role/flow1-run1..3/` — Bằng chứng **3 lần chạy thực tế trên hệ thống đã deploy** cho **Luồng 1** (Mobile gửi `pending` → Web `Approve`/`Reject` kèm lý do → Mobile `A08` & Inbox `A09` cập nhật realtime), dùng để điền số đo độ trễ `ms` vào [docs/cross-role-flow.md](../docs/cross-role-flow.md).
- [ ] `cross-role/flow2-run1..3/` — Bằng chứng **3 lần chạy thực tế trên hệ thống đã deploy** cho **Luồng 2** (Web mở phiên & chiếu mã QR → Mobile quét QR tại `A11` → Cả `A12` trên Mobile và bảng điểm danh trên Web nhảy kết quả realtime).

### 3.11. Tính năng AI Gemini (`evidence/ai-feature/`)
- [ ] `ai-feature/input-output-1..3.png` — Ảnh chụp màn hình thực tế cho **3 cặp Input → Output thật** (có nhãn *"Gợi ý bởi AI"* và cho phép người dùng chỉnh sửa trước khi xác nhận).
- [ ] `ai-feature/fallback-handled.png` — Ảnh chứng minh khi tắt cờ `ai_enabled = false` trên Remote Config hoặc khi mất mạng/vượt quota, ứng dụng hiển thị thông báo nhẹ nhàng và người dùng vẫn hoàn tất được luồng bằng tay.

---

## 4. Bảng Ghi Nhận Chung Các Công Cụ AI Nhóm Đã Dùng (`AI Disclosure Master Table`)

> Bất kỳ thành viên nào dùng thêm công cụ AI mới trong quá trình code, test, làm báo cáo hoặc làm slide đều ghi bổ sung ngay một dòng vào bảng này để khi nộp bài copy đồng bộ sang `README.md`, `Report` và `Slides`:

| Công cụ AI | Phiên bản / Mô hình | Dùng cho giai đoạn nào | Người kiểm chứng kết quả |
|---|---|---|---|
| **OpenAI Codex** | Coding Assistant | Hỗ trợ dựng khung MVVM, giao diện Mobile Lab 3, unit/emulator tests và rà soát lỗi local ban đầu | Thành viên nhóm Mobile |
| **Google Antigravity** | Gemini | Rà soát thiếu sót tài liệu so với đề, đặc tả [role-features.md](../docs/role-features.md), [cross-role-flow.md](../docs/cross-role-flow.md), sinh prompt và triển khai trọn vẹn mã nguồn Flutter Web Trưởng CLB (`web/` & `packages/core/`) theo 3 chặng kèm kiểm thử đơn vị & bằng chứng | Thành viên nhóm |
| **Google ARTEMIS** | Commit `351ca842...` (Flash & Pro) | Agent kiểm thử tự động E2E trên Android và phiên kiểm thử khám phá (Exploratory testing) | *Cập nhật khi chạy* |
| *Điền công cụ PR Review* | *Copilot / CodeRabbit / SonarCloud* | Review Pull Request phát hiện lỗi kiến trúc, bảo mật và bảo trì mã nguồn | *Cập nhật khi mở PR* |
| *Điền công cụ Slide (nếu có)* | *Gamma / Canva AI / Gemini...* | *Ghi rõ nếu có dùng AI hỗ trợ bố cục slide thuyết trình (bắt buộc khai báo theo đề)* | *Cập nhật khi làm slide* |
