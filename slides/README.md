# Bộ Slide Thuyết Trình Lab 3 — EventHub (35 Slide Trực Quan & Evidence Thực Tế)

Bộ slide này được xây dựng bằng **Reveal.js (HTML/CSS thuần qua CDN, 0 dependencies)**, tích hợp hiệu ứng thị giác hiện đại (glassmorphism cards, glowing badges, device framing, smooth transitions) và **26 ảnh bằng chứng thực nghiệm** trích xuất từ thư mục `evidence/`. Nội dung bám sát và mở rộng đầy đủ toàn bộ yêu cầu của tài liệu **PRM393 / HƯỚNG DẪN CHUẨN BỊ LAB 3 THỰC HÀNH** (đáp ứng vượt mức &ge;25 slide tối thiểu).

---

## 1. Cách Chạy Slide Trên GitHub Pages (`github.io`)

File slide được đặt trực tiếp tại `slides/index.html`. Để chia sẻ link online cho giảng viên và hội đồng xem trực tiếp:

1. Đẩy code lên GitHub:
   ```bash
   git add slides/
   git commit -m "docs(slides): update HTML presentation slide deck for Lab 3"
   git push origin main
   ```
2. Vào GitHub Repository $\rightarrow$ **Settings** $\rightarrow$ chọn mục **Pages** (cột bên trái).
3. Tại phần **Build and deployment**:
   - **Cách 1 (Tự động qua GitHub Actions - Khuyên dùng)**:
     - **Source**: Chọn `GitHub Actions`. Workflow `.github/workflows/deploy-slides.yml` đã được cấu hình sẵn sẽ tự động kích hoạt và deploy mỗi khi push code lên `main`.
   - **Cách 2 (Deploy trực tiếp từ Branch)**:
     - **Source**: Chọn `Deploy from a branch`.
     - **Branch**: Chọn `main`, thư mục `/ (root)`. Nhấn **Save**.
4. Sau 1–2 phút, link slide online hoạt động tại:
   - Repo nhóm chính: `https://thinhcri.github.io/PRM393_Lab03_Group4/slides/`
   - Repo fork: `https://kietntse.github.io/PRM393_Lab03_Group4_pre/slides/`

---

## 2. Cách Xuất Ra File PDF Chuẩn (`Lab03_Group4_slides.pdf`)

Reveal.js hỗ trợ chế độ in PDF chuyên dụng giữ nguyên độ nét vector và màu sắc:

1. Mở file `slides/index.html` bằng trình duyệt **Google Chrome** hoặc **Microsoft Edge** (chạy local hoặc mở link GitHub Pages).
2. Thêm tham số `?print-pdf` vào cuối URL, ví dụ:
   - Chạy local: `file:///D:/GitHub/PRM_LAB3/PRM393_Lab03_Group4/slides/index.html?print-pdf`
   - Hoặc link online: `https://.../slides/?print-pdf`
3. Nhấn tổ hợp phím **`Ctrl + P`** (hoặc `Cmd + P` trên Mac).
4. Thiết lập trong hộp thoại In của trình duyệt:
   - **Destination (Máy in đích)**: `Save as PDF` (Lưu dưới dạng PDF).
   - **Layout (Bố cục)**: `Landscape` (Khổ ngang).
   - **Margins (Lề)**: `None` (Không có).
   - **Options (Tùy chọn)**: Tích chọn **`Background graphics`** (Đồ họa nền) để nhận đầy đủ màu nền và khung thẻ.
5. Nhấn **Save** và lưu file vào:
   `slides/Lab03_Group4_slides.pdf`

---

## 3. Cấu Trúc Nội Dung 35 Slide Trực Quan (Vượt mức chuẩn ≥25 slide)

Bộ slide bao gồm 35 slide phân bổ theo 3 phần chính, minh họa bằng 26 ảnh bằng chứng thực tế:

### Phần 1: Nền Tảng Dự Án (Slide 01 – 08)
- **Slide 01**: Bìa Đề Tài — EventHub & Hệ Thống Firebase Backend Suite.
- **Slide 02**: Mục Lục Báo Cáo — Lộ trình 3 phần chuẩn bị bảo vệ.
- **Slide 03**: Tổng Quan Ứng Dụng EventHub & Nghiệp vụ cốt lõi.
- **Slide 04**: Môi Trường Kỹ Thuật & Tech Stack (Flutter 3.29, Firebase SDK, Riverpod).
- **Slide 05**: Khởi Tạo Firebase & Lifecycle trong `main.dart`.
- **Slide 06**: Kiến Trúc Phần Mềm — Định nghĩa Mô hình Clean Architecture MVVM + Riverpod trong EventHub.
- **Slide 07**: MVVM Workflow — Quy Trình Kết Nối & Luồng Dữ Liệu 4 Bước (Action Stream vs Reactive Data Binding).
- **Slide 08**: Visual Design Evidence — Ảnh thực tế Discover, Event Detail, Catalog.

### Phần 2: 6 Dịch Vụ Firebase Chuyên Sâu (Slide 09 – 29)
- **Slide 09**: Firebase Auth — Khái niệm, Cơ chế JWT, Zero PII Policy.
- **Slide 10**: Firebase Auth — Tích hợp code `AuthService` & Riverpod stream.
- **Slide 11**: Firebase Auth — Bằng chứng kiểm thử màn hình Login Configured vs Fallback.
- **Slide 12**: Cloud Storage & Export — Khái niệm, Export Engine, `storage.rules`.
- **Slide 13**: Cloud Storage & Export — Bằng chứng DebugView (`export_generate`, `export_upload`).
- **Slide 14**: FCM — Khái niệm, Kiến trúc Push & 3 trạng thái (Foreground, Background, Terminated).
- **Slide 15**: FCM — Tích hợp code Background Handler & Quyền Android 13+ `POST_NOTIFICATIONS`.
- **Slide 16**: FCM — Bằng chứng Foreground Push Test & Hòm thư Inbox.
- **Slide 17**: FCM — Bằng chứng Background System Tray & Deep Linking Inbox.
- **Slide 18**: Firebase Analytics — Chiến lược đo lường Conversion Funnel & Zero PII Policy.
- **Slide 19**: Firebase Analytics — Bảng Kế hoạch đo lường (Measurement Plan) 7+ Custom Events.
- **Slide 20**: Firebase Analytics — Bằng chứng DebugView 1 (`search` & `view_event_detail`).
- **Slide 21**: Firebase Analytics — Bằng chứng DebugView 2 (`booking_submit` & `booking_result`).
- **Slide 22**: Firebase Crashlytics — Khái niệm Fatal vs Non-Fatal, Custom Keys Context.
- **Slide 23**: Firebase Crashlytics — Tích hợp code `CrashlyticsService` & Test Crash UI.
- **Slide 24**: Firebase Crashlytics — Bằng chứng Console Dashboard Fatal Crash & Stacktrace.
- **Slide 25**: Firebase Crashlytics — Bằng chứng Console Dashboard Non-Fatal & Graceful App UI.
- **Slide 26**: Remote Config — Khái niệm Feature Flags, 2 tham số (`recommendation_limit`, `show_recommendations`).
- **Slide 27**: Remote Config — Tích hợp code `RemoteConfigService` & Cache Expiration Policy.
- **Slide 28**: Remote Config — Bằng chứng Live A/B Feature Flag (`recommendation_limit = 1`).
- **Slide 29**: Remote Config — Bằng chứng Live Feature Toggle (`show_recommendations = false`).

### Phần 3: Đảm Bảo Chất Lượng & Bàn Giao (Slide 30 – 35)
- **Slide 30**: ARTEMIS Protocol — Khung kiểm thử tự động E2E (25 Test Cases, 3x Execution).
- **Slide 31**: ARTEMIS Protocol — Kết quả thực thi (65/65 Unit tests pass, 5/5 Firestore emulator).
- **Slide 32**: AI Code Review — Bảng 5 Findings & 3 Commits khắc phục (PR #3).
- **Slide 33**: Bằng Chứng Cải Tiến Giao Diện — Màn hình D03 Firebase Tools & D11 Filter Chips.
- **Slide 34**: Danh Mục Sản Phẩm Bàn Giao (Deliverables Checklist & URLs).
- **Slide 35**: Tổng Kết & Hỏi Đáp (Q&A Session & Live Demo).
- **Slide 34**: Tổng Kết Báo Cáo & Phiên Hỏi Đáp Q&A / Live Demo.
