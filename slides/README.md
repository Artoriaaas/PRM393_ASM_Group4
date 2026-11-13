# Bộ Slide Thuyết Trình Bảo Vệ Đồ Án — EventHub (Guideline V11 · Cam Vàng Hồng)

Bộ slide này được xây dựng và thiết kế lại hoàn toàn tuân thủ theo **"Software Project Presentation Guideline V11"** (30 slide chuẩn mực) và đặc tả thiết kế **`Slide_Template_Spec_CamVangHong.md`** (bảng màu Cam – Vàng – Hồng, canvas cố định 1280 × 720 px, tỉ lệ 16:9). Toàn bộ nội dung bám sát 100% dự án **EventHub (PRM393 ASM Group 4)**.

---

## 1. Cấu Trúc 30 Slide Chuẩn Guideline V11

| Số trang | Nhãn | Phase / Section | Nội dung chính của đề tài EventHub |
|:---:|:---:|:---|:---|
| **01** | `G1` | **Bìa chính (Layout DARK)** | EventHub — Nền tảng quản lý sự kiện và điểm danh QR liên vai trò |
| **02** | `G2` | **Nguyên tắc chung** | 4 Nguyên tắc cốt lõi & cấu trúc khung chuẩn của một slide |
| **03** | `G3` | **Cách chia nội dung** | Phân định ranh giới: Thiết kế cho tổng thể, Demo theo workflow |
| **04** | `G4` | **Danh mục slide** | Lộ trình 24 slide nội dung, 4 phần, ngân sách 18–20 phút |
| **05** | `01` | `P1 · PROBLEM` | **Overview**: Giới thiệu EventHub trong 30 giây (Mobile + Web Admin) |
| **06** | `02` | `P1 · PROBLEM` | **Context**: Hiện trạng tổ chức sự kiện tại ĐH FPT (Quy trình 4 bước giấy/Excel) |
| **07** | `03` | `P1 · PROBLEM` | **Problem**: 3 Pain points (Ùn tắc check-in, Vượt sức chứa, Mù xét duyệt) |
| **08** | `04` | `P1 · PROBLEM` | **Proposed Solution**: Kiến trúc Serverless, QR băm SHA-256, Review Queue |
| **09** | `05` | `P1 · PROBLEM` | **Main Actors**: Sinh viên (`user`), Trưởng CLB (`staff`), Quản trị viên (`admin`), Firebase |
| **10** | `06` | `P1 · PROBLEM` | **Main Features**: 4 Nhóm tính năng & 3 Workflow liên thiết bị sẽ demo |
| **11** | `07` | `P2 · DESIGN` | **Business Flow**: Sơ đồ phân làn (Swimlane) 4 làn kèm các điểm rẽ BR-01..BR-04 |
| **12** | `08` | `P2 · DESIGN` | **State Machine**: Vòng đời Registration (`PENDING → APPROVED / REJECTED → ATTENDED`) |
| **13** | `09` | `P2 · DESIGN` | **System Architecture**: Sơ đồ C4 Container Serverless & Quyết định kiến trúc |
| **14** | `10` | `P2 · DESIGN` | **Technology Stack**: Bảng công nghệ 7 nhóm (Flutter 3.29, Riverpod, Firestore, Rules) |
| **15** | `11` | `P2 · DESIGN` | **UI/UX Design**: Sitemap, Wireframe → Figma → Flutter, 4 UI States, Cải tiến D11 |
| **16** | `12` | `P2 · DESIGN` | **Sequence Diagram**: Trưởng CLB duyệt đơn (`approveRegistration` transaction + alt hết chỗ) |
| **17** | `13` | `P2 · DESIGN` | **Class Design**: Clean Architecture MVVM (`BookingViewModel`, `FirestoreEventService`) |
| **18** | `14` | `P2 · DESIGN` | **Database Conceptual**: Sơ đồ thực thể Conceptual ERD (User, Club, Event, Registration) |
| **19** | `15` | `P2 · DESIGN` | **Database Physical**: NoSQL Schema Firestore, kiểu dữ liệu, index, rules bảo vệ |
| **20** | `16` | `P2 · DESIGN` | **Traceability**: Ma trận truy vết Feature ↔ Screen ↔ Class ↔ Database ↔ Tests |
| **21** | `17` | `P3 · DEMO` | **Demo Plan**: Storyboard 3 bước demo liên vai trò (Đăng ký → Duyệt → Điểm danh) |
| **22** | `18` | `P3 · DEMO` | **Demo WF-01**: Sinh viên gửi yêu cầu đăng ký trên Mobile App (Đơn PENDING) |
| **23** | `19` | `P3 · DEMO` | **Demo WF-02**: Trưởng CLB duyệt đơn trên Web Admin Review Queue (APPROVED + FCM) |
| **24** | `20` | `P3 · DEMO` | **Demo WF-03**: Mở phiên phát QR & Sinh viên quét check-in (ATTENDED realtime) |
| **25** | `21` | `P4 · PROOF` | **Testing**: 65 Tests pass (Unit 35/35, Rules Emulator 16/16, ARTEMIS E2E 25/25) |
| **26** | `22` | `P4 · PROOF` | **Achievements**: Đối chiếu cam kết, giảm 90% thời gian check-in (<3s), 0 lỗi sức chứa |
| **27** | `23` | `P4 · PROOF` | **Limitations**: Check-in phụ thuộc mạng, chưa stress-test tải nặng, thiếu cổng thanh toán |
| **28** | `24` | `P4 · PROOF` | **Conclusion**: 3 Thông điệp chính, link Live Demo, Repo, Figma và bắt đầu Q&A |
| **29** | `25` | **Phụ lục** | **Appendix / Backup**: 6 Nhóm tài liệu A1..A6 sẵn sàng trả lời phản biện chuyên sâu |
| **30** | `G5` | **Checklist** | **Quality Gate**: 8 Tiêu chí tự rà soát trước khi bảo vệ trước Hội đồng |

---

## 2. Cách Sử Dụng & Điều Khiển Trình Diễn

Trực tiếp mở file `slides/index.html` bằng bất kỳ trình duyệt hiện đại nào (Google Chrome, Microsoft Edge, Safari, Firefox). Ứng dụng tự động co giãn (`transform: scale()`) khớp với kích thước màn hình mà không làm lệch toạ độ thiết kế.

### Phím tắt điều khiển:
- **`Phím Mũi tên Phải` / `Phím Cách (Space)` / `PageDown`**: Chuyển sang slide kế tiếp.
- **`Phím Mũi tên Trái` / `PageUp`**: Quay lại slide trước.
- **`Home`**: Về slide đầu tiên (Slide G1 bìa).
- **`End`**: Đến slide cuối cùng (Slide G5 Checklist).
- **`Phím O`**: Mở danh mục lưới (Overview Grid) 30 slide để nhảy nhanh đến bất kỳ slide nào.
- **`Phím F`**: Bật / Tắt chế độ Toàn màn hình (Fullscreen).
- **`Esc`**: Đóng danh mục lưới.

---

## 3. Cách Xuất Ra File PDF Chuẩn Không Lỗi Layout

Bộ slide đã được nhúng sẵn cấu hình in ấn chuyên dụng (`@media print` và `@page { size: 1280px 720px; margin: 0; }`):

1. Mở file `slides/index.html` trong trình duyệt Google Chrome hoặc Microsoft Edge.
2. Nhấn tổ hợp phím **`Ctrl + P`** (hoặc `Cmd + P` trên macOS).
3. Cài đặt các thông số trong hộp thoại In:
   - **Destination (Máy in)**: `Save as PDF` (Lưu dưới dạng PDF).
   - **Layout (Bố cục)**: `Landscape` (Khổ ngang).
   - **Paper size (Khổ giấy)**: Tùy chỉnh hoặc A4/Letter ngang.
   - **Margins (Lề)**: `None` (Không lề).
   - **Options (Tùy chọn)**: Tích chọn **`Background graphics`** (Đồ họa nền) để hiển thị đầy đủ màu sắc, thẻ và viền.
4. Nhấn **Save** để nhận file PDF 30 trang sắc nét.

---

## 4. Danh Mục Ảnh & Minh Chứng Nhóm Cần Chuẩn Bị Thêm

Hệ thống slide hiện tại đã tích hợp sẵn:
- Ảnh chụp thực tế của Mobile App: `evidence/discover_screen.png`, `evidence/eventhub_live.png`.
- Các sơ đồ kỹ thuật (Swimlane, State Machine, C4 Container, Sequence Diagram, Class Design, ERD, Traceability Matrix) được render bằng vector SVG/HTML sắc nét.

**Các tài nguyên bổ sung nhóm có thể cung cấp thêm:**
1. **Ảnh chụp Web Admin màn hình rộng (&ge; 1280px)**:
   - Ảnh màn hình Review Queue duyệt đơn (`evidence/web-admin/07-review-queue-approve.png`) để thay thế khung minh họa tại Slide 19 (Demo WF-02).
   - Ảnh màn hình Live QR Check-in Panel (`evidence/web-admin/06-live-qr-checkin-panel.png`) để thay thế khung minh họa tại Slide 20 (Demo WF-03).
   - Ảnh màn hình Dashboard số liệu thống kê (`evidence/web-admin/03-dashboard-figures-chart.png`) cho Phụ lục A1.
2. **Ảnh sơ đồ vẽ tay hoặc xuất từ Draw.io / Figma (nếu muốn thay thế vector HTML)**:
   - File PNG/SVG sơ đồ Swimlane (Slide 07), State Machine (Slide 08), C4 Architecture (Slide 09).
3. **Video Demo Dự phòng (4K/FullHD)**:
   - Ghi lại quá trình Sinh viên đăng ký trên điện thoại $\rightarrow$ Trưởng CLB duyệt trên Web $\rightarrow$ Quét QR tại bàn đón tiếp để gắn link vào Phụ lục A6.
