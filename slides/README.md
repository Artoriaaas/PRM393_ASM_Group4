# Bộ Slide Thuyết Trình Bảo Vệ Đồ Án — EventHub (Phiên Bản Bản Vẽ Kỹ Thuật · MLN122)

Bộ slide này được xây dựng và thiết kế lại hoàn toàn dựa trên triết lý **"Bản vẽ kỹ thuật động" (MLN122)** và chuẩn mực nội dung đồ án phần mềm:
- **Loại bỏ 100% nội dung gợi ý/meta-prompts**: Không còn các khối nhắc bài như *"CÂU HỎI HỘI ĐỒNG"*, *"THỜI LƯỢNG"*, *"MINH CHỨNG BẮT BUỘC"*, *"NỘI DUNG CẦN TRÌNH BÀY"*, *"TRÁNH"*, *"MẪU BỐ CỤC"*. Toàn bộ slide tập trung 100% vào giá trị kỹ thuật, kiến trúc, sơ đồ, giao diện và dữ liệu thực tế của đề tài **EventHub (PRM393 ASM Group 4)**.
- **Thiết kế sân khấu 1600 × 900 px (16:9)**: Nền giấy kẻ ô kỹ thuật (grid paper), typography kết hợp `Bricolage Grotesque` (tiêu đề mạnh mẽ), `Be Vietnam Pro` (nội dung rõ nét) và `IBM Plex Mono` (thông số kỹ thuật & mã quy tắc).
- **Sợi chỉ tiến độ tương tác (#thread)**: Thanh tiến độ chạy dọc đáy màn hình với các nút chuyển slide trực tiếp.
- **3 Kiểu màu kỹ thuật (Phím D)**: Giấy can sáng (`giay` - mặc định), Bản in xanh (`reu` - blueprint), Bàn vẽ đêm (`cham` - dark mode).

---

## 1. Danh Mục 29 Bản Vẽ Kỹ Thuật

| STT | Mã trang | Phase / Section | Tiêu đề & Nội dung then chốt |
|:---:|:---:|:---|:---|
| **01** | `G1` | **Bìa chính** | EventHub — Nền tảng quản lý sự kiện và điểm danh QR thời gian thực |
| **02** | `G4` | **Lộ trình thuyết trình** | Cấu trúc 4 phần tập trung vào giá trị kỹ thuật & minh chứng thực tế (18–20') |
| **03** | `01` | `P1 · PROBLEM` | **Overview**: Giới thiệu giải pháp EventHub trong 30 giây (Mobile + Web Admin) |
| **04** | `02` | `P1 · PROBLEM` | **Context**: Hiện trạng tổ chức sự kiện tại ĐH FPT (Quy trình 4 bước giấy/Excel) |
| **05** | `03` | `P1 · PROBLEM` | **Problem**: 3 Pain points (Ùn tắc đón tiếp, Vượt sức chứa, Mù xét duyệt) |
| **06** | `04` | `P1 · PROBLEM` | **Proposed Solution**: Kiến trúc Serverless Realtime, QR SHA-256 & Phạm vi MVP |
| **07** | `05` | `P1 · PROBLEM` | **Main Actors**: 4 Tác nhân (user, staff, admin, Firebase) & Ranh giới bảo mật |
| **08** | `06` | `P1 · PROBLEM` | **Main Features**: 4 Nhóm tính năng bao phủ trọn vẹn vòng đời sự kiện CLB |
| **09** | `06B` | `P1 · PROBLEM` | **Core Workflows**: 3 Workflow chính liên thiết bị (Sợi chỉ xuyên suốt bài bảo vệ) |
| **10** | `07` | `P2 · DESIGN` | **Business Flow**: Sơ đồ phân làn (Swimlane) 4 làn kèm các điểm rẽ BR-01..BR-05 |
| **11** | `08` | `P2 · DESIGN` | **State Machine**: Registration Lifecycle, State Transitions &amp; Atomic Invariants |
| **12** | `09` | `P2 · DESIGN` | **System Architecture**: Sơ đồ C4 Container Serverless &amp; 3 Quyết định kiến trúc |
| **13** | `10` | `P2 · DESIGN` | **Technology Stack**: Bảng công nghệ 8 nhóm (Flutter 3.29, Gemini AI Level 2) |
| **14** | `11` | `P2 · DESIGN` | **UI/UX Design**: Sitemap, Tiến trình Figma, 4 UI States, Cải tiến D11/D08 |
| **15** | `12` | `P2 · DESIGN` | **Sequence Diagram**: Duyệt đơn (`approveRegistration` Tx) & Nhánh ngoại lệ hết chỗ |
| **16** | `13` | `P2 · DESIGN` | **Class Design**: Clean Architecture MVVM, Service Contracts & Domain Models |
| **17** | `14` | `P2 · DESIGN` | **Conceptual Database**: ERD Ngữ nghĩa, Cardinality & Ràng buộc toàn vẹn IC-01..IC-03 |
| **18** | `15` | `P2 · DESIGN` | **Physical Database**: NoSQL Schema Firestore, Composite Indexes & Security Rules |
| **19** | `16` | `P2 · DESIGN` | **Traceability**: Ma trận truy vết khép kín 100% Feature ↔ Screen ↔ Class ↔ DB ↔ Test |
| **20** | `17` | `P3 · DEMO` | **Demo Plan**: Storyboard 3 bước demo liên vai trò (Đăng ký → Duyệt → Điểm danh) |
| **21** | `18` | `P3 · DEMO` | **Demo WF-01**: Sinh viên nộp đơn đăng ký trên Mobile App (Đơn PENDING, A04..A06) |
| **22** | `19` | `P3 · DEMO` | **Demo WF-02**: Trưởng CLB duyệt đơn trên Web Admin Review Queue (APPROVED + FCM) |
| **23** | `20` | `P3 · DEMO` | **Demo WF-03**: Mở phiên phát QR & Sinh viên quét check-in (Biên nhận A12 realtime) |
| **24** | `21` | `P4 · PROOF` | **Testing**: 132 Tests tự động Pass 100%, 0 Crashlytics sessions, 12 nhóm Rules |
| **25** | `22` | `P4 · PROOF` | **Achievements**: Đối chiếu cam kết: Giảm 90% thời gian check-in (<3s), 0 lỗi quá tải |
| **26** | `23` | `P4 · PROOF` | **Limitations**: Ranh giới kỹ thuật trung thực & Lộ trình nâng cấp công nghệ tiếp theo |
| **27** | `24` | `P4 · PROOF` | **Conclusion**: 3 Thông điệp chính, liên kết Live Demo, GitHub, Figma và bắt đầu Q&A |
| **28** | `25` | **Phụ lục** | **Appendix / Backup**: 6 Nhóm tài liệu A1..A6 sẵn sàng trả lời phản biện chuyên sâu |
| **29** | `G5` | **Checklist** | **Quality Gate**: 8/8 Tiêu chuẩn tự rà soát đạt mức độ hoàn thiện tối đa |

---

## 2. Hướng Dẫn Điều Khiển Trình Diễn

Mở trực tiếp file `slides/index.html` trong bất kỳ trình duyệt nào (Google Chrome, Microsoft Edge, Firefox, Safari).

### Phím tắt điều khiển:
- **`Mũi tên Phải` / `Phím Cách (Space)` / `PageDown`**: Chuyển sang slide tiếp theo.
- **`Mũi tên Trái` / `PageUp`**: Quay lại slide trước.
- **`Home`**: Về slide đầu tiên (Slide G1 bìa).
- **`End`**: Đến slide cuối cùng (Slide G5 Checklist).
- **`Phím D`**: Đổi kiểu màu (Giấy can sáng $\rightarrow$ Bản in xanh Blueprint $\rightarrow$ Bàn vẽ đêm Dark Mode).
- **`Phím O`**: Bật/Tắt Lưới tổng quan (Overview Grid) 28 slide để nhảy nhanh đến trang bất kỳ.
- **`Phím F`**: Bật/Tắt chế độ Toàn màn hình (Fullscreen).
- **`Esc`**: Đóng Lưới tổng quan.
- **`Click vào nút trên thanh tiến độ (#thread)`**: Nhảy trực tiếp đến slide đó.
