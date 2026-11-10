# Bộ Slide Thuyết Trình Lab 3 — EventHub (HTML & PDF)

Bộ slide này được xây dựng bằng **Reveal.js (HTML/CSS thuần qua CDN, 0 dependencies)**, tuân thủ 100% khung chuẩn **Software Project Presentation Guideline V11** (14 slide, tỉ lệ chuẩn 16:9, bố cục 4 phần: *Problem $\rightarrow$ Design $\rightarrow$ Demo Workflow $\rightarrow$ Proof*).

---

## 1. Cách Chạy Slide Trên GitHub Pages (`github.io`)

File slide được đặt trực tiếp tại `slides/index.html`. Để chia sẻ link online cho giảng viên và hội đồng xem trực tiếp:

1. Đẩy code lên GitHub:
   ```bash
   git add slides/
   git commit -m "docs(slides): add HTML presentation slide deck for Lab 3"
   git push origin main
   ```
2. Vào GitHub Repository $\rightarrow$ **Settings** $\rightarrow$ chọn mục **Pages** (cột bên trái).
3. Tại phần **Build and deployment**:
   - **Source**: Chọn `Deploy from a branch`.
   - **Branch**: Chọn `main`, thư mục `/ (root)`.
4. Sau 1–2 phút, link slide online của bạn sẽ hoạt động tại:
   `https://<username>.github.io/PRM393_Lab03_Group4/slides/`

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

## 3. Cấu Trúc Nội Dung 14 Slide

- **Slide 01**: **Overview** — Giới thiệu EventHub trong 30 giây, công nghệ & nhóm tác giả.
- **Slide 02**: **Context & Persona** — Bối cảnh hoạt động CLB FPTU TP.HCM & 3 Persona (P01 sinh viên FPTU, P02 khách ngoài trường, P03 tham gia tự do).
- **Slide 03**: **Pain Points & Goals** — 3 điểm nghẽn thực tế & Tiêu chí thành công Lab 2 (đăng ký $\le 90s$, QR $\le 30s$).
- **Slide 04**: **Design Traceability** — Hiện thực hóa Design System Lab 2 (Tokens, Typography, 10 Reusable Widgets, truy vết D01–D04).
- **Slide 05**: **System Architecture** — Kiến trúc phân tầng MVVM + Riverpod, Dependency Injection, State tường minh.
- **Slide 06**: **Firebase Auth & Firestore** — Google Sign-In, xác minh email, Firestore Transaction nguyên tử `getAfter()`.
- **Slide 07**: **PDF Report & Storage** — Xuất PDF lịch tham gia tiếng Việt trên máy và tích hợp upload đám mây (Cloudinary Free).
- **Slide 08**: **FCM Push Notifications** — Bằng chứng nhận thông báo đẩy ở cả 3 trạng thái (Foreground, Background, Terminated) và đồng bộ Inbox.
- **Slide 09**: **Analytics DebugView** — Kế hoạch 14 sự kiện đo lường không PII, bằng chứng DebugView thực tế trên Console.
- **Slide 10**: **Crashlytics & Remote Config** — Non-fatal upload error thật + native test crash; đổi tham số gợi ý từ Console không rebuild app.
- **Slide 11**: **Demo Workflow 1 (F1: Khám phá & Đăng ký)** — Happy path & Exception paths (hết chỗ, quá hạn, thiếu khóa K, chống trùng bằng `operationId`).
- **Slide 12**: **Demo Workflow 2 (F2 & F4A: Hủy & Quét QR)** — Xem lịch, hủy đơn bảo toàn chỗ, quét QR băm SHA-256 xác thực trực tiếp qua Security Rules.
- **Slide 13**: **Testing & AI Code Review** — 65 automated tests pass, 25 kịch bản ARTEMIS, 5 findings AI review được khắc phục qua các commit độc lập.
- **Slide 14**: **Conclusion & Deliverables** — Nghiệm thu đồ án, tính trung thực của bằng chứng và các liên kết bàn giao.
