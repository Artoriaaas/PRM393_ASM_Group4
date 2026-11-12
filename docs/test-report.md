# Báo cáo Kiểm thử Hệ thống & Rà soát Mã nguồn (`docs/test-report.md`)

> **Căn cứ yêu cầu**: Đề Final Assignment — Mục 9 (Testing requirements), Mục 10 (Deliverables: `docs/test-report.md`), Mục 11 (Grading rubric) & Phụ lục B (Appendix B — Rules test template).  
> **Nguyên tắc**: Báo cáo tổng hợp các bằng chứng kiểm thử tự động, kết quả kiểm tra Security Rules trên Emulator, checklist Web Admin và quyết định từ các lượt AI Code Review.

---

## 1. Kiểm thử Security Rules trên Firebase Emulator (Chuẩn Appendix B)

Toàn bộ quy tắc bảo mật của hệ thống được kiểm thử tự động thông qua bộ test `firebase/tests/direct-firestore.test.js` chạy trên Firestore Emulator. Bảng dưới đây đối chiếu đầy đủ các ca kiểm thử cho từng vai trò (`user`, `staff`, `admin`) trên từng collection chính:

| ID | Collection | Role kiểm thử | Thao tác thực thi (Operation) | Kết quả kỳ vọng (Expected) | Trạng thái thực tế (Result) | Ghi chú & Mã kiểm tra |
|---|---|---|---|---|---|---|
| **R-01** | `registrations` | `user` | Tạo đơn mới với `status = 'approved'` | Denied | **Pass** | User không được tự duyệt đơn của mình |
| **R-02** | `registrations` | `user` | Tạo đơn mới với `status = 'pending'`, sự kiện còn chỗ & còn hạn | Allowed | **Pass** | Luồng đăng ký hợp lệ từ Mobile |
| **R-03** | `registrations` | `staff` | Duyệt đơn `pending -> approved` và tăng `activeCount + 1` | Allowed | **Pass** | Trưởng CLB duyệt đơn cùng `clubId` |
| **R-04** | `registrations` | `staff` | Duyệt đơn cho sự kiện thuộc CLB khác (`clubId` khác) | Denied | **Pass** | Chặn can thiệp chéo CLB |
| **R-05** | `registrations` | `staff` | Từ chối đơn `pending -> rejected` kèm trường `reason` hợp lệ | Allowed | **Pass** | Bắt buộc có lý do từ chối |
| **R-06** | `registrations` | `staff` | Từ chối đơn `pending -> rejected` nhưng để trống `reason` | Denied | **Pass** | Rules bắt buộc `reason.size() >= 3` |
| **R-07** | `users` | `user` | Tự cập nhật nâng `role` của mình thành `admin` hoặc `staff` | Denied | **Pass** | User không được tự sửa role |
| **R-08** | `users` | `admin` | Tự hạ role của chính mình | Denied | **Pass** | Không ai được tự đổi role của chính mình |
| **R-09** | `users` | `admin` | Cập nhật role và gán `clubId` cho người dùng khác | Allowed | **Pass** | Admin phân vai hệ thống |
| **R-10** | `events` | `user` | Tự tạo hoặc cập nhật thông tin sự kiện | Denied | **Pass** | User chỉ được đọc sự kiện `published` |
| **R-11** | `events` | `staff` | Tạo sự kiện mới cho CLB của mình | Allowed | **Pass** | Trưởng CLB quản lý sự kiện CLB |
| **R-12** | `events` | `staff` | Giảm sức chứa (`capacity`) nhỏ hơn số chỗ đang active | Denied | **Pass** | Bảo toàn số lượng người đã đăng ký |
| **R-13** | `checkinSessions` | `user` | Mở hoặc đóng phiên điểm danh | Denied | **Pass** | Chỉ Staff/Admin được điều khiển phiên |
| **R-14** | `qrCredentials` | `user` | Đọc danh sách mã QR điểm danh của CLB | Denied | **Pass** | Chặn đọc lộ chuỗi token điểm danh |
| **R-15** | `registrations` | `user` | Quét QR điểm danh với mã hợp lệ khi phiên đang mở | Allowed | **Pass** | Check-in thành công 1 lần duy nhất |
| **R-16** | `registrations` | `user` | Quét QR điểm danh lần thứ 2 (đã có `checkInAt`) | Denied | **Pass** | Chặn điểm danh trùng lặp |

---

## 2. Danh mục Kiểm tra Ứng dụng Web Admin (`Web Admin Checklist`)

Toàn bộ 4 màn hình chính và form thông báo trên Web Admin (`web/`) đã được kiểm tra trên các trạng thái giao diện:

| Màn hình (Screen) | Hành động chính (Main Action) | Kiểm tra chặn sai Role (Role Rejection) | Trạng thái Đang tải (`loading`) | Trạng thái Rỗng (`empty`) | Trạng thái Lỗi (`error` + retry) | Trạng thái Bằng chứng |
|---|---|---|---|---|---|---|
| **1. Đăng nhập (`/login`)** | Đăng nhập bằng tài khoản Google | Chặn tài khoản `user` và tài khoản `staff` chưa có `clubId` (`role_rejection_screen.dart`) | Có nút loading indicator khi đang xác thực | Không áp dụng | Hiển thị lỗi khi đóng popup hoặc lỗi mạng | `evidence/web-admin/01-signin-google-staff.png`, `02-role-rejection-student.png` |
| **2. Bảng điều khiển (`/dashboard`)** | Xem ≥ 3 số liệu thống kê aggregation (`count()`) và biểu đồ cột | Tự động điều hướng / chặn nếu mất phiên | Skeleton / CircularProgressIndicator | Hiển thị khi CLB chưa có sự kiện nào | Hiển thị nút Thử lại khi mất mạng | `evidence/web-admin/03-dashboard-figures-chart.png` |
| **3. Quản lý Sự kiện (`/events`)** | Tìm kiếm, lọc, tạo/sửa sự kiện, mở phiên & phát mã QR | Chỉ thao tác trong sự kiện của `clubId` mình | Shimmer/Loading list | Khi không có kết quả tìm kiếm/lọc | Hiển thị banner lỗi + nút tải lại | `evidence/web-admin/04-events-list-search-filter.png`, `05-event-create-edit-archive.png`, `06-live-qr-checkin-panel.png` |
| **4. Hàng đợi Duyệt (`/reviews`)** | Duyệt đơn (`Approve`) hoặc từ chối kèm lý do (`Reject`) | Chỉ xem đơn của các sự kiện thuộc CLB mình | Loading spinner trên bảng đơn | Khi hàng đợi không còn đơn chờ duyệt | Báo lỗi khi transaction duyệt thất bại | `evidence/web-admin/07-review-queue-approve.png`, `08-review-queue-reject-reason.png` |
| **5. Phát Thông báo (`/announcements`)** | Soạn và đăng thông báo mới vào `announcements` | Chỉ phát thông báo trong phạm vi CLB mình | Loading trên nút Gửi | Khi chưa có thông báo nào trong lịch sử | Báo lỗi khi Firestore từ chối ghi | `evidence/web-admin/09-announcement-form-published.png` |

---

## 3. Kiểm thử Tự động E2E với Google ARTEMIS (`e2e_test/`)

- **Cấu hình & Phiên bản**: Google ARTEMIS pin commit `351ca8422f7b5b54e80a9c1ce03a222e02415b6b`, chạy với Python 3.12+ và `pytest`.
- **Phạm vi kịch bản**: 25 kịch bản kiểm thử độc lập (`TC01`–`TC25`) bao phủ toàn bộ các luồng Lab 2, các nhánh lỗi mạng/hết chỗ/quá hạn, tương tác native Android (chọn tài khoản Google, cấp quyền Camera, quyền thông báo Android 13+) và bước mobile của cross-role flow.
- **Tiêu chí đánh giá**: Assert trực tiếp trên giá trị văn bản mà agent quan sát được trên màn hình, không chỉ dựa vào trạng thái `SUCCESS`.

---

## 4. Nhật ký Rà soát Mã nguồn bằng AI (`AI Code Review Record`)

Tuân thủ Mục 8 Lab 3 và Mục 9 Final Assignment, các phát hiện từ quá trình AI Review được ghi nhận kèm quyết định kỹ thuật:

| ID | Công cụ AI | Tệp & Dòng mã tham chiếu | Phân loại (Kind) | Tóm tắt phát hiện (Finding) | Quyết định (Decision) | Lý do kỹ thuật (Reason) | Mã Commit khắc phục |
|---|---|---|---|---|---|---|---|
| **CR-01** | OpenAI Codex | `lib/viewmodels/booking_viewmodel.dart:34` | Concurrency & Privacy | Đổi UID khi upload hoặc booking đang chờ có thể làm rò rỉ dữ liệu phiên cũ sang phiên mới | **Accepted** | Kiểm tra `_userEpoch` và UID hiện tại trước khi cập nhật kết quả bất đồng bộ | `fe02d20` |
| **CR-02** | OpenAI Codex | `lib/screens/account/profile_edit_screen.dart:45` | Architecture & Maintainability | Giao diện tự dựng `AlertDialog` và `TextButton` riêng thay vì dùng component dùng chung | **Accepted** | Thay bằng `AppConfirmationDialog` để tuân thủ quy tắc Design System của đề | `fe02d20` |
| **CR-03** | OpenAI Codex | `lib/screens/events/scanner_screen.dart:60` | Architecture (MVVM) | Screen tự quản lý vòng đời camera và stream thay vì ủy quyền qua ViewModel | **Accepted** | Tách `QrCameraController` và provider quản lý trạng thái camera vào ViewModel | `9f92864` |
| **CR-04** | OpenAI Codex | `lib/services/firebase/firebase_cloud_services.dart:120` | Reliability & Tracking | Thao tác mở từ Push Notification không phát sự kiện `notification_open(source='push')` | **Accepted** | Bổ sung theo dõi nguồn mở push để phục vụ bảng phân tích Analytics | `599b4c4` |
| **CR-05** | OpenAI Codex | `lib/viewmodels/auth_viewmodel.dart:88` | Reliability & Race Condition | Khi đăng xuất, tác vụ xóa dữ liệu cục bộ có thể chen ngang một booking transaction đang chạy | **Accepted** | Chặn thao tác đăng xuất khi trạng thái nghiệp vụ đang bận (`busy`), bảo đảm an toàn dữ liệu | `53eae7e` |

---

## 5. Khai báo Sử dụng Công cụ AI (`AI Disclosure`)
- **OpenAI Codex**: Hỗ trợ thiết kế kiến trúc MVVM, boilerplate code ban đầu, unit tests và rà soát lỗi local.
- **Google Antigravity (Gemini)**: Rà soát thiếu sót tài liệu, lập đặc tả vai trò, luồng liên thiết bị và tạo khung báo cáo kiểm thử.
- **Google ARTEMIS**: Agent AI kiểm thử tự động trên môi trường Android thật / emulator.
