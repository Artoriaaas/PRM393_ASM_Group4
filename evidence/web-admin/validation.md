# Báo Cáo Kiểm Chứng & Bằng Chứng Tự Động — Flutter Web Admin (`web-admin`)

Ngày thực hiện: 06/11/2026  
Môi trường: Windows x64, Flutter 3.47.4 (Channel stable), Dart 3.13.3

---

## 1. Kết Quả Chạy `flutter analyze` (0 lỗi trên toàn hệ thống)

### 1.1. Gói dùng chung `packages/core/`
```
Analyzing core...
No issues found! (ran in 22.3s)
```

### 1.2. Ứng dụng Flutter Web `web/`
```
Analyzing 2 items...
No issues found! (ran in 17.4s)
```

### 1.3. Ứng dụng Flutter Mobile & Thư mục kiểm thử Root (`lib/`, `test/`)
```
Analyzing 3 items...
No issues found! (ran in 157.8s)
```

---

## 2. Kết Quả Kiểm Thử Đơn Vị & Giao Diện (`flutter test`)

### 2.1. Gói dùng chung `packages/core/test/` (3/3 test đạt 100%)
- `Design Tokens match Lab 2 spec`: Đạt chuẩn mã màu HEX `AppColors`, khoảng cách `AppSpacing`, bo góc `AppRadius`.
- `Club & Registration & Announcement models instantiate properly`: Kiểm tra toàn vẹn trường dữ liệu và phương thức kiểm tra vai trò.
- `AppButton renders with tokens`: Kiểm tra render widget dùng chung.

### 2.2. Ứng dụng Flutter Web `web/test/` (10/10 test đạt 100%)

#### Chặng 1 — Xác thực, Cổng vai trò & Khung Web Shell (`auth_role_rejection_test.dart`)
- `SignInScreen renders login button and branding`: Hiển thị thương hiệu EventHub, thẻ đăng nhập và nút Đăng nhập bằng Google.
- `Role Rejection Gate rejects role == "user" with clear explanation`: Chặn người dùng có `role == 'user'` (sinh viên) tại cổng vào Web, hiển thị màn hình từ chối quyền truy cập rõ ràng và hỗ trợ đăng xuất an toàn.
- `Role Rejection Gate rejects role == "staff" without clubId`: Chặn tài khoản Trưởng CLB chưa được phân công `clubId` hợp lệ.
- `Staff with valid clubId successfully enters and AppShell renders desktop sidebar`: Tài khoản Trưởng CLB hợp lệ đăng nhập thành công vào `/dashboard`, AppShell hiển thị thanh điều hướng cố định bên trái (Sidebar 260dp) kèm huy hiệu `Trưởng CLB`.

#### Chặng 2 — Bảng thống kê, Quản lý sự kiện & Panel Điểm danh QR (`events_and_dashboard_test.dart`)
- `Dashboard renders 3 figures, chart and quick lists`: Hiển thị tối thiểu 3 chỉ số tổng hợp (`countPublishedEvents`, `countPendingRegistrations`, `countApprovedRegistrations`), biểu đồ cột trực quan `ClubAttendanceChart` và danh sách nhanh.
- `ClubEventsScreen filters by status and archives event cleanly`: Lọc danh sách theo trạng thái (`all`, `draft`, `published`, `cancelled`, `archived`) và thực hiện lưu trữ sự kiện an toàn (không xóa cứng).
- `LiveQrPanelScreen displays large QR, toggles session and shows live checkin count`: Khung chiếu hội trường hiển thị mã QR lớn, điều khiển đóng/mở phiên `checkinSessions` và bảng đồng bộ số liệu điểm danh thời gian thực.

#### Chặng 3 — Hàng đợi Duyệt đơn & Thông báo CLB (`reviews_and_announcements_test.dart`)
- `ReviewQueueScreen displays pending registration and can Approve`: Duyệt đơn đăng ký `pending -> approved` thông qua transaction nguyên tử tăng `activeCount + 1` và tạo thông báo Inbox cho người tham gia.
- `Reject dialog validates required reason length >= 3 chars`: Hộp thoại từ chối bắt buộc nhập lý do có độ dài từ 3 đến 300 ký tự trước khi cập nhật `rejected` và gửi lý do về Inbox sinh viên.
- `ClubAnnouncementsScreen composes and publishes new announcement`: Soạn và đăng thông báo CLB/Sự kiện vào collection `announcements`, cập nhật realtime vào danh sách lịch sử.

---

## 3. Kết Quả Biên Dịch Flutter Web (`flutter build web`)

```
Compiling lib\main.dart for the Web...
√ Built build\web (268.8s)
```

Thư mục xuất bản: `web/build/web/`  
Cấu hình Firebase Hosting tại `firebase.json`:
```json
"hosting": {
  "public": "web/build/web",
  "ignore": [
    "firebase.json",
    "**/.*",
    "**/node_modules/**"
  ],
  "rewrites": [
    {
      "source": "**",
      "destination": "/index.html"
    }
  ]
}
```
Sẵn sàng thực thi lệnh `firebase deploy --only hosting` lên dự án `eventhub-group4`.
