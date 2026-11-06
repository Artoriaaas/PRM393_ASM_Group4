# Báo Cáo Kiểm Chứng & Rà Soát Mã Nguồn — Flutter Web Admin (`web-admin`)

Ngày thực hiện: 06/11/2026  
Môi trường: Windows x64, Flutter 3.47.4 (Channel stable), Dart 3.13.3

---

## 1. Kết Quả Chạy `flutter analyze` (0 lỗi trên toàn hệ thống)

### 1.1. Gói dùng chung `packages/core/`
```
Analyzing core...
No issues found! (ran in 38.9s)
```

### 1.2. Ứng dụng Flutter Web `web/` (`lib` & `test`)
```
Analyzing 2 items...
No issues found! (ran in 40.8s)
```

### 1.3. Ứng dụng Flutter Mobile & Kiểm thử Root (`lib` & `test`)
```
Analyzing 2 items...
No issues found! (ran in 124.5s)
```

---

## 2. Kết Quả Kiểm Thử Đơn Vị & Giao Diện (`flutter test`)

### 2.1. Gói dùng chung `packages/core/test/` (`3/3` test đạt 100%)
- `Design Tokens match Lab 2 spec`: Đạt chuẩn mã màu HEX `AppColors`, khoảng cách `AppSpacing`, bo góc `AppRadius`.
- `Club & Registration & Announcement models instantiate properly`: Kiểm tra toàn vẹn trường dữ liệu và phương thức kiểm tra vai trò.
- `AppButton renders with tokens`: Kiểm tra render widget dùng chung.

### 2.2. Ứng dụng Flutter Web `web/test/` (`12/12` test đạt 100%)

#### Chặng 1 — Khởi tạo Firebase Web, Cổng Vai trò & Cô lập Phiên CLB (`auth_role_rejection_test.dart` — 5/5 pass)
- `WebFirebaseAppBootstrap shows error state when unconfigured and recovers on retry`: Kiểm chứng màn hình báo lỗi cấu hình `--dart-define` và nút *Thử lại*.
- `SignInScreen renders login button and branding`: Hiển thị thương hiệu EventHub, thẻ đăng nhập và nút Đăng nhập bằng Google.
- `Role Rejection Gate rejects role == "user" with clear explanation`: Chặn tài khoản sinh viên (`role == 'user'`) ngay tại cổng vào Web kèm nút đăng xuất an toàn.
- `Role Rejection Gate rejects role == "staff" without clubId`: Chặn tài khoản Trưởng CLB chưa được Admin gán `clubId`.
- `Staff with valid clubId enters AppShell and switching staff accounts isolates club data`: Đăng nhập vào `AppShell` (Sidebar 260dp) và xác minh khi chuyển phiên sang Trưởng CLB khác (`club_music`), dữ liệu `club_it` bị hủy đăng ký ngay lập tức, không rò rỉ chéo CLB.

#### Chặng 2 — Bảng thống kê, Đủ 4 Trạng thái UI, Sự kiện & Điểm danh QR (`events_and_dashboard_test.dart` — 4/4 pass)
- `Dashboard explicitly handles loading, error with Retry, and empty state with CTA`: Xác minh tường minh chuỗi trạng thái `loading` (`AppLoadingState`) -> `error` (`AppErrorState` + nút *Thử lại*) -> `empty` (`AppEmptyState` + nút *Tạo sự kiện đầu tiên*).
- `Dashboard renders 3 figures, chart and quick lists`: Hiển thị 3 nhóm chỉ số aggregation (`countPublishedEvents`, `countPendingRegistrations`, `countApprovedRegistrations` / `countCheckedInRegistrations`), biểu đồ cột `ClubAttendanceChart` có icon + chú giải và danh sách nhanh.
- `ClubEventsScreen filters by status, clears filter, and renders cleanly on narrow 360dp`: Lọc theo trạng thái, xóa bộ lọc khôi phục danh sách và không tràn viền (`RenderFlex overflow`) ngay cả ở kích thước hẹp `360 x 800 dp`.
- `LiveQrPanelScreen guards draft events, toggles session with int analytics, rotates & disables old QR, and hides student email`: Chặn mở QR cho sự kiện `draft`, ghi Analytics kiểu số nguyên (`open: 1`), vô hiệu hóa `qrCredentials` cũ (`enabled: false`) khi xoay mã QR mới, và ẩn email cá nhân của sinh viên trên màn hình chiếu hội trường.

#### Chặng 3 — Hàng đợi Duyệt đơn Nguyên tử & Thông báo CLB (`reviews_and_announcements_test.dart` — 3/3 pass)
- `ReviewQueueScreen approves last available seat and blocks over-capacity approval`: Phê duyệt chỗ trống cuối cùng thành công và chặn duyệt vượt `capacity` với thông báo lỗi rõ ràng.
- `Reject flow validates >= 3 chars and preserves underscored eventId in student notification`: Bắt buộc lý do từ chối `3..300` ký tự, thực thi transaction kiểm tra trạng thái `pending` và giữ nguyên mã `eventId` có dấu gạch dưới (`ev_ai_2026`) trong thông báo Inbox sinh viên.
- `ClubAnnouncementsScreen composes, previews, and publishes new announcement`: Xem trước trực tiếp nội dung Mobile Inbox `A09` và phát hành thông báo vào `announcements`.

---

## 3. Kết Quả Biên Dịch Flutter Web (`flutter build web`)

```
Compiling lib\main.dart for the Web...
Wasm dry run succeeded.
Compiling lib\main.dart for the Web... 192.3s
√ Built build\web
```

Lệnh truyền cấu hình khi chạy/build kết nối dự án Firebase thật:
```bash
flutter build web \
  --dart-define=FIREBASE_WEB_API_KEY=<apiKey> \
  --dart-define=FIREBASE_WEB_APP_ID=<appId> \
  --dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=<senderId> \
  --dart-define=FIREBASE_WEB_PROJECT_ID=eventhub-group4 \
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN=eventhub-group4.firebaseapp.com \
  --dart-define=FIREBASE_RECAPTCHA_V3_SITE_KEY=<siteKey>
```
