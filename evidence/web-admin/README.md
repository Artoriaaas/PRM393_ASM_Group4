# Bằng chứng & Nhật ký AI — Flutter Web Quản lý CLB & Admin (`web-admin`)

Thư mục này lưu trữ **(1) Nhật ký khai báo công cụ AI & truy vết prompt** dùng để thiết kế/sinh ứng dụng Flutter Web và **(2) Bộ ảnh chụp bằng chứng kiểm thử bắt buộc của Web Admin** theo Mục 7, Mục 9 và Mục 12 của đề Final Assignment.

---

## 1. Nhật ký Sử dụng AI & Truy vết Prompt (`AI Disclosure Record`)

> Dùng để tổng hợp trực tiếp vào mục **AI Tools Used** trong `README.md`, `docs/test-report.md`, Báo cáo cuối kỳ và Slide thuyết trình.

| Ngày | Hạng mục | Công cụ AI sử dụng | Mục đích & Phạm vi hỗ trợ | Tài liệu nguồn đối chiếu | Tệp đầu ra / Lưu vết |
|---|---|---|---|---|---|
| 06/11/2026 | Đặc tả vai trò, luồng liên thiết bị & sinh Master Prompt cho Flutter Web Trưởng CLB (`role: staff`) | **Google Antigravity (Gemini)** | Rà soát hệ thống Design Tokens & Components từ Lab 2/Lab 3, đối chiếu quy tắc MVVM + Firestore Security Rules, tổng hợp đặc tả 3 vai trò (`user`, `staff`, `admin`), 2 luồng `cross-role-flow` và biên soạn bộ prompt sinh giao diện Flutter Web Trưởng CLB | - `lib/theme/*`, `lib/widgets/*`, `lib/models/*`<br>- Lab 2 `project/design/design-system.md`, `handoff/flutter-handoff.md`, `project/full-product/screen-spec-full-product.md`<br>- Đề Final Assignment (Mục 4, 6, 7, 9, Appendix A–C) | - [docs/role-features.md](../../docs/role-features.md)<br>- [docs/cross-role-flow.md](../../docs/cross-role-flow.md) |
| 06/11/2026 | Triển khai & rà soát mã nguồn Flutter Web (`web/` & `packages/core/`) theo lộ trình 3 chặng | **Google Antigravity (Gemini)** | Sinh và chuẩn hóa gói `packages/core/` (tokens, widgets, models, contracts), khởi tạo ứng dụng Web kết nối Firebase thật (`WebFirebaseAppBootstrap`, App Check, Remote Config, Analytics), `AppShell` màn rộng, `/login` Google Auth & Role Rejection Gate, `/dashboard` (3 chỉ số aggregation + biểu đồ cột `ClubAttendanceChart`), `/events` (tìm kiếm/lọc, modal tạo/sửa có chọn ngày giờ + khung xem trước Mobile A04, lưu trữ soft-archive), panel `/events/:id/checkin` (mã QR lớn, xoay mã vô hiệu mã cũ, bảng điểm danh realtime ẩn PII), `/reviews` (hàng đợi duyệt đơn, transaction nguyên tử `Approve`/`Reject` lý do 3..300 ký tự) và `/announcements` (soạn & phát hành thông báo CLB 2 cột). Đạt 12/12 ca test Web, 3/3 ca test Core, 0 lỗi analyze và build web thành công. | - [docs/role-features.md](../../docs/role-features.md)<br>- [docs/cross-role-flow.md](../../docs/cross-role-flow.md) | `packages/core/`, `web/`, [evidence/web-admin/validation.md](validation.md) |
| *Cập nhật khi mở PR* | AI Code Review phần code Web mới | *Copilot / CodeRabbit / SonarCloud...* | Review Pull Request code mới của `web/` & `packages/core/`, ghi nhận tối thiểu 3 findings kèm quyết định kỹ thuật | Mục 9 đề Final Assignment | Lưu đầu ra gốc tại `../code-review/` & ghi bảng trong `docs/test-report.md` |

---

## 2. Checklist Ảnh Bằng chứng Bắt buộc cho Web (`Web Admin Checklist` — Mục 7 & 9)

> **Quy tắc bắt buộc khi chụp bằng chứng**:
> - Chỉ chụp trên bản chạy Flutter Web kết nối dự án Firebase thật (`eventhub-group4`), ưu tiên chụp trực tiếp trên **Live URL Firebase Hosting** mở bằng trình duyệt ở kích thước màn hình rộng (`>= 1280 px`).
> - Không dùng ảnh mockup hay dữ liệu giả lập cục bộ làm bằng chứng hoàn thành.
> - Giữ nguyên trạng thái `Chờ chụp` cho tới khi màn hình đã triển khai và kiểm chứng thực tế.

| Mã ảnh | Tên file chuẩn lưu tại thư mục này | Màn hình & Yêu cầu cần chứng minh | Trạng thái |
|---|---|---|---|
| **W-EV-01** | `01-signin-google-staff.png` | Màn `/login`: Đăng nhập Google Sign-In thành công với tài khoản Trưởng CLB (`role == 'staff'`) vào không gian CLB được gán | Chờ chụp |
| **W-EV-02** | `02-role-rejection-student.png` | **Role Rejection**: Tài khoản Sinh viên (`role == 'user'`) đăng nhập vào Web bị chặn ngay tại cổng với thông báo từ chối rõ ràng và nút Đăng xuất | Chờ chụp |
| **W-EV-03** | `03-dashboard-figures-chart.png` | Màn `/dashboard`: Hiển thị tối thiểu **3 chỉ số tổng hợp** (từ Firestore aggregation queries) và **1 biểu đồ** dùng đúng màu/font token Lab 2 | Chờ chụp |
| **W-EV-04** | `04-events-list-search-filter.png` | Màn `/events` (*Management*): Danh sách sự kiện của CLB, thanh tìm kiếm và bộ lọc trạng thái hoạt động với dữ liệu Firestore thật | Chờ chụp |
| **W-EV-05** | `05-event-create-edit-archive.png` | Tạo mới / Chỉnh sửa sự kiện (kèm khung xem trước A04) và thao tác **Archive (`archived`)** thay vì xóa cứng | Chờ chụp |
| **W-EV-06** | `06-live-qr-checkin-panel.png` | Panel Mở phiên điểm danh (`checkinSessions`), hiển thị mã QR trực tiếp (`qrCredentials`) và bảng đếm sinh viên điểm danh cập nhật realtime | Chờ chụp |
| **W-EV-07** | `07-review-queue-approve.png` | Màn `/reviews` (*Review Queue*): Thao tác **Approve** đơn `pending -> approved` (tăng `activeCount` và gửi thông báo về Mobile) | Chờ chụp |
| **W-EV-08** | `08-review-queue-reject-reason.png` | Màn `/reviews`: Hộp thoại bắt buộc nhập lý do khi **Reject** đơn `pending -> rejected` | Chờ chụp |
| **W-EV-09** | `09-announcement-form-published.png` | Màn `/announcements`: Gửi thông báo CLB vào `announcements` và ảnh đối chiếu tin nhắn vừa xuất hiện trong Mobile Inbox (`A09`) | Chờ chụp |
| **W-EV-10** | `10-states-loading-empty-error.png` | Bộ ảnh (hoặc ghép 3 khung rõ nét) chứng minh Web xử lý đầy đủ trạng thái **`loading`**, **`empty`** (khi lọc không có kết quả / CLB mới) và **`error` kèm nút Thử lại** | Chờ chụp |
| **W-EV-11** | `11-incognito-live-url.png` | Ảnh chụp cửa sổ trình duyệt ẩn danh (*Private / Incognito window*) mở thành công Live URL trên Firebase Hosting | Chờ chụp |
