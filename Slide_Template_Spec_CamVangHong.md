# SPEC TEMPLATE SLIDE HTML — "Software Project Presentation Guideline V11"

> **Nguồn**: file `Software_Project_Presentation_Guideline_V11.pptx` (30 trang). Toàn bộ số liệu dưới đây (toạ độ, kích thước, màu, cỡ chữ, nội dung) được trích trực tiếp từ XML của file, không ước lượng.
> **Mục tiêu cho IDE**: dựng bộ slide HTML **giống hệt khung mẫu** của file PPTX. Không tự thiết kế lại, không đổi màu/bố cục/vị trí, không thêm bớt khối.


> **ĐÃ ĐỔI BẢNG MÀU (primary: cam – vàng – hồng).** Bố cục, kích thước, font giữ nguyên bản gốc; chỉ thay màu. Ánh xạ: accent1 hồng `#DB2777` (P1, WF-01) · accent2 cam nhạt `#F97316` (WF-02) · accent3 cam `#EA580C` (P2) · accent4 vàng hổ phách `#D97706` (P3, WF-03, hộp TRÁNH) · accent5 hồng đậm `#9D174D` (P4) · accent6 đỏ `#DC2626` giữ nguyên cho lỗi/exception. Nền slide `#FFF8F3`, màu đậm `#2B1418` (thay navy). Chữ trên nền vàng/cam dùng trắng bold; chữ vàng trên nền sáng dùng `#D97706` (đủ tương phản). Các từ màu trong file đã đổi theo (xanh dương→hồng, tím→cam, cam→vàng, xanh lá→hồng đậm). Slide bìa G1 nền `#2B1418`.

---

## 0. QUY TẮC BẮT BUỘC CHO IDE (đọc trước)

1. **Canvas cố định 13.333 in × 7.5 in (16:9)**. Quy đổi: `1 in = 96 px` → slide `1280 × 720 px`. Mọi toạ độ trong file này là **inch, gốc (0,0) ở góc trên-trái slide**, dạng `x,y  w×h`. Dựng bằng `position:absolute` (left/top/width/height = inch × 96px, hoặc `calc(var(--in) * x)` với `--in:96px`).
2. **Cỡ chữ**: file ghi theo `pt`. `px = pt × 1.3333`. Ví dụ 26pt = 34.67px, 12pt = 16px, 8.5pt = 11.33px.
3. Mỗi slide là một `<section class="slide">` 1280×720, overflow hidden. Cho phép thu phóng cả slide bằng `transform: scale()` để vừa màn hình (giữ nguyên tỉ lệ), **không** dùng layout responsive/flex-wrap làm thay đổi vị trí.
4. **Font**: tất cả dùng `Calibri` (fallback `Carlito, Arial, sans-serif`), **trừ tiêu đề trang bìa G1 dùng `Arial` bold**. Không dùng font khác.
5. **Màu chỉ lấy từ bảng token ở mục 1**. Ký hiệu `accentN@X%` nghĩa là màu accentN với độ trong suốt X% (`rgba`) đặt trên nền hiện tại (trắng hoặc `#FFF8F3`).
6. Văn bản trong file là **nội dung mẫu/hướng dẫn tiếng Việt** — giữ nguyên chữ, dấu, ký tự đặc biệt (`·`, `—`, `→`, `↔`, `′`, `≈`, `≤`, `≥`, `✓`). Phần trong `[ngoặc vuông]` là placeholder để người dùng thay bằng nội dung thật của đề tài.
7. Thứ tự slide trong file: **G1–G4 (4 slide giới thiệu khung) → 25 slide mẫu (Slide 1…Slide 25) → G5 (checklist)**. Giữ đúng thứ tự và số trang (xem mục 6).
8. Khi người dùng yêu cầu làm slide cho đề tài của họ: **dùng 25 slide mẫu làm khung**, chỉ thay phần placeholder/ví dụ bằng nội dung thật; giữ nguyên header, cột trái, hộp TRÁNH, khung phải, footer. G1–G5 là slide hướng dẫn, chỉ dùng khi người dùng muốn tái tạo cả tài liệu guideline.

---

## 1. DESIGN TOKENS

### 1.1 Màu (theme "Guideline V11")
| Token | Hex | Dùng cho |
|---|---|---|
| `--tx1` / dk1 | `#1E293B` | Chữ chính trên nền sáng (tiêu đề G-slide, giá trị trong hộp thông tin) |
| `--navy` / dk2 | `#2B1418` | Nền slide bìa G1; header bảng; thanh "TRUY VẾT" |
| `--bg` / lt2 | `#FFF8F3` | **Nền mọi slide nội dung** |
| `--white` | `#FFFFFF` | Nền card/panel |
| `--accent1` PINK | `#DB2777` | Phase P1 PROBLEM; WF-01 |
| `--accent2` LIGHT ORANGE | `#F97316` | WF-02; màu phụ |
| `--accent3` ORANGE | `#EA580C` | Phase P2 DESIGN |
| `--accent4` YELLOW | `#D97706` | Phase P3 DEMO; WF-03; hộp "TRÁNH"; chữ nhấn cảnh báo |
| `--accent5` DEEP PINK | `#9D174D` | Phase P4 PROOF |
| `--accent6` RED | `#DC2626` | Lỗi / exception / pain point |
| muted | `#64748B` | Chữ phụ, label nhỏ, số trang trên slide sáng |
| slate-600 | `#475569` | Chữ mô tả trong card, trạng thái |
| slate-700 | `#334155` | Danh sách trong G4; viền card tối ở G1 |
| slate-300 | `#CBD5E1` | Viền nét đứt, đường lifeline, chữ phụ trên nền navy |
| slate-400 | `#94A3B8` | Đường nối/mũi tên, chữ phụ G1 |
| slate-200 | `#E2E8F0` | **Viền card/panel**, viền ô bảng, thanh nhãn |
| slate-100 | `#F1F5F9` | Ô xám (placeholder ảnh, bước quy trình) |
| slate-50 | `#F8FAFC` | Nền swimlane / khung wireframe |
| peach | `#FDE68A` | Chữ trên thanh navy "TRUY VẾT" (G5) |

### 1.2 Phase → màu (áp dụng cho header của slide nội dung)
| Phase | Nhãn tag | Slide mẫu | Accent |
|---|---|---|---|
| P1 | `P1 · PROBLEM` | Slide 1–6 | `accent1` (hồng) |
| P2 | `P2 · DESIGN` | Slide 7–16 | `accent3` (cam) |
| P3 | `P3 · DEMO` | Slide 17–20 | `accent4` (vàng) |
| P4 | `P4 · PROOF` | Slide 21–24 | `accent5` (hồng đậm) |
| Phụ lục | `PHỤ LỤC` | Slide 25 | `#475569` (xám) |

Workflow demo: **WF-01 = accent1 (hồng)**, **WF-02 = accent2 (cam nhạt)**, **WF-03 = accent4 (vàng)**.
Lưu ý: ở Slide 18–20 (P3) header vẫn dùng **vàng** của phase; màu WF chỉ dùng cho pill góc phải trên và panel bên phải.

### 1.3 Kiểu chữ & hình chung
- Bo góc: `roundRect` — card lớn bán kính ≈ **0.094 × cạnh ngắn** (≈ 6–8px); pill (tag, chip) bo **tròn hết (50%)**.
- Viền card chuẩn: `1px (0.8pt) solid #E2E8F0`. Card nhấn (phase DEMO ở G2/G3/G4) viền `1.5pt solid #D97706`.
- Không đổ bóng, không gradient.
- Label nhỏ in hoa (`NỘI DUNG CẦN TRÌNH BÀY`, `CÂU HỎI HỘI ĐỒNG`…) có `letter-spacing: 1pt`.
- Text box thường: padding 0, `line-height` ~1.15–1.2. Pill: padding 0.056in. Hộp thông tin: padding 0.111in.
- Đường nối: `1.2pt`, màu `#94A3B8` (nối thường), `#DC2626` nét đứt (nhánh lỗi), `#D97706` (nhánh vượt hạn mức). Dim `w×0` = đường ngang, `0×h` = đường dọc; đường chéo nối 2 node liền kề đúng như hình mẫu.
- Bảng: viền mọi ô `0.75pt #E2E8F0`; **hàng tiêu đề nền `#2B1418`, chữ trắng bold 9–9.5pt**; padding ô 0.06in; căn giữa dọc; cột đầu in đậm.

---

## 2. LAYOUT NỀN

| Layout | Nền | Dùng cho |
|---|---|---|
| `DARK` | `#2B1418` | Chỉ slide G1 (bìa) |
| `CONTENT` | `#FFF8F3` | G2–G5 và toàn bộ 25 slide mẫu |

Footer của layout CONTENT (có sẵn trên mọi slide CONTENT): text `SOFTWARE PROJECT  /  PRESENTATION GUIDELINE V11` tại `0.5,7.0  8.0×0.25`, 8pt, `#64748B`, letter-spacing ~1pt.
Số trang: `11.83,6.98  1.0×0.3`, căn **phải**, 10pt bold; nhãn: G1…G4 → `G1`..`G4`; slide mẫu → `01`…`25`; checklist → `G5`. Màu `#000000` (G1: `#94A3B8` trên nền navy).

---

## 3. KHUNG CHUNG CỦA 25 SLIDE MẪU (Slide 1 → Slide 25)

Tất cả 25 slide mẫu dùng **cùng một khung**. Chỉ đổi: màu phase, text, và nội dung khung phải.

### 3.1 Header (cố định vị trí)
| # | Phần tử | Vị trí `x,y w×h` | Kiểu |
|---|---|---|---|
| H1 | **Tag phase** (pill) | `0.5,0.36  1.5×0.26` | bo tròn, nền `accentP@14%`, chữ `accentP` 8.5pt bold, căn giữa, ví dụ `P1 · PROBLEM` |
| H2 | **Số/section** | `2.15,0.36  7.0×0.26` | 9.5pt bold `#64748B`, dạng `01  /  OVERVIEW` |
| H2b | **Pill phải (tuỳ slide)** | `9.33,0.36  3.5×0.26` | chỉ Slide 12 `TÙY CHỌN`, 14 `TÙY CHỌN — có thể gộp vào slide 15`, 18/19/20 `WF-0x · tên actor`, 25 `KHÔNG CHIẾU — mở khi bị hỏi` (xem từng slide) |
| H3 | **Tiêu đề** | `0.5,0.66  12.33×0.62` | 26pt bold; phần `Slide N` màu `accentP`, phần còn lại (`Tên — mô tả`) màu `#1E293B` |
| H4 | **Phụ đề** | `0.5,1.3  12.33×0.32` | 12.5pt `#64748B` |
| H5 | **Hộp CÂU HỎI HỘI ĐỒNG** | `0.5,1.76  6.15×0.64` | nền `accentP@8%`, bo nhỏ, padding 0.111in; dòng 1 label 8pt bold `accentP`; dòng 2 câu hỏi **11.5pt italic** `#1E293B` |
| H6 | **Hộp THỜI LƯỢNG** | `6.8,1.76  1.55×0.64` | cùng kiểu; label 8pt bold; giá trị **15pt bold** `#1E293B` (vd `30 s`) |
| H7 | **Hộp MINH CHỨNG BẮT BUỘC** | `8.5,1.76  4.33×0.64` | cùng kiểu; giá trị **10.5pt** `#1E293B` |

### 3.2 Cột trái (rộng ≈ 4.55in)
- Label `NỘI DUNG CẦN TRÌNH BÀY`: `0.5,2.6  4.5×0.25`, 9pt bold `accentP`, letter-spacing 1pt.
- **4 ý** — mỗi ý gồm:
  - Vòng số: ellipse `0.26×0.26`, nền `accentP@20%`, số 9pt bold `accentP`, căn giữa. Toạ độ: `0.5,2.97` / `0.5,3.64` / `0.5,4.31` / `0.5,4.98` (bước 0.67).
  - Text: `0.9,2.95 / 3.62 / 4.29 / 4.96`, kích thước `4.15×0.62`, **12pt** `#000000`.
- **Hộp TRÁNH**: `0.5,5.7  4.55×0.98`, nền `accent4@10%` (vàng nhạt), padding 0.111in; label `TRÁNH` 8.5pt bold `accent4`; nội dung 10.5pt `#1E293B`.

### 3.3 Khung phải — "MẪU BỐ CỤC"
- Card trắng cố định: `5.35,2.55  7.48×4.15`, nền `#FFFFFF`, viền `0.8pt #E2E8F0`, bo góc.
- Label `MẪU BỐ CỤC`: `5.6,2.68  3.0×0.22`, 8.5pt bold `#64748B`, letter-spacing 1pt.
- Vùng nội dung bên trong: x từ **5.6 đến 12.6** (rộng 7.0), y từ **3.05 đến ~6.1**.
- **Chú thích cuối panel**: `5.6,6.36  7.0×0.26`, 9.5pt **italic** `#64748B` (mỗi slide một câu nhắc).

### 3.4 Footer: xem mục 2.

> Ký hiệu trong các bảng phần tử bên dưới: `rr` = roundRect; `oval` = ellipse; `bg=` nền; `bd=` viền (màu/độ dày pt/kiểu); chữ in dạng “nội dung” + cỡ pt (`b`=bold, `i`=italic) + màu (nếu không ghi = `#000000`/`tx1`) + căn (`ctr`/`r`); `⏎` = xuống dòng/đoạn mới trong cùng một khối; `LINE` = đường kẻ.

---

## 4. CÁC SLIDE GIỚI THIỆU (G1–G4) VÀ CHECKLIST (G5)

Tất cả dạng danh sách phần tử tuyệt đối `x,y w×h`.

### G1 — Cover (nền `#2B1418`)
Bố cục: pill nhỏ phía trên → tiêu đề 2 dòng Arial 36pt bold trắng → câu mô tả → 4 card phase (card DEMO viền vàng 1.5pt) → 3 nút WF → dòng ghi chú → số trang `G1`.

### G2 — Nguyên tắc chung (nền sáng)
Header kiểu G: label `NGUYÊN TẮC CHUNG` 9.5pt bold muted (`0.5,0.36`), tiêu đề 26pt bold `#1E293B` (không tô màu phase), phụ đề 12.5pt muted. Hàng 1: **4 card trắng** (`2.93×2.75`, y=1.9, x = 0.5 / 3.63 / 6.76 / 9.89), card thứ 3 viền vàng 1.5pt. Hàng 2: label `CẤU TRÚC MỖI SLIDE MẪU` + **6 ô** `1.92×0.95` nền `accent1@8%` (y=5.25, x = 0.5, 2.57, 4.64, 6.71, 8.78, 10.85).

### G3 — Cách chia nội dung
2 card lớn `6.05×3.95` (y=1.9): trái cam (`DESIGN — TOÀN HỆ THỐNG`, x=0.5), phải vàng viền 1.5pt (`DEMO — THEO TỪNG WORKFLOW`, x=6.78); mỗi card có thanh tiêu đề màu `6.05×0.58`. Dưới cùng: thanh quy tắc `0.5,6.05  12.33×0.55` nền `accent4@12%`.

### G4 — Danh mục slide
4 card `2.93×3.95` (y=1.85; x = 0.5 / 3.63 / 6.76 / 9.89), thanh tiêu đề màu `2.93×0.55` (hồng / cam / vàng / hồng đậm), danh sách 11pt `#334155`. Dưới: label `NGÂN SÁCH THỜI GIAN` + thanh chia thời gian y=6.25 cao 0.36: PROBLEM 3.5′ (x0.5 w2.29) · DESIGN 6′ (x2.83 w3.96) · DEMO 6.5′ (x6.83 w4.29) · PROOF 2.5′ (x11.16 w1.63), chữ 9.5pt bold trắng. Cuối: ghi chú italic 9.5pt.

### G5 — Checklist rà soát (cuối file)
Lưới **4×2 card trắng** `2.93×1.8` (x = 0.5/3.63/6.76/9.89; y = 1.9 và 3.9), mỗi card: dấu ✓ trong ellipse `0.42×0.42` (nền = màu nhóm), tiêu đề 12.5pt bold, mô tả 11.5pt `#475569`. Nhóm màu: PROBLEM, FEATURES = hồng; DESIGN, TRACEABILITY = cam; DEMO WORKFLOW, DEMO DATA = vàng; TESTS, OUTCOME = hồng đậm. Cuối: thanh navy `0.5,6.05  12.33×0.5` chữ `#FDE68A` 11pt bold.

**Chi tiết chính xác từng phần tử G1–G5 xem mục 7 (phụ lục dữ liệu thô).**

---

## 5. DANH SÁCH 25 SLIDE MẪU — NỘI DUNG & KHUNG PHẢI

Quy ước mỗi slide: các dòng `H` = header (đúng khung mục 3.1), `LEFT` = 4 ý + hộp TRÁNH (đúng mục 3.2), `PANEL` = các phần tử bên trong khung phải. Slide 12, 14, 18, 19, 20, 25 có thêm pill phải ở `9.33,0.36`.

### Slide mẫu 1 (file pptx: trang 5/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent1@14% “P1 · PROBLEM” 8.5b accent1 ctr
- H `2.15,0.36 7.0×0.26`  “01 / OVERVIEW” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 1 Overview — giới thiệu dự án trong 30 giây” 26b accent1
- H `0.5,1.3 12.33×0.32`  “Tạo bức tranh tổng thể và cho hội đồng thấy sản phẩm thật ngay từ đầu.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent1@8% “CÂU HỎI HỘI ĐỒNG” 8b accent1 ⏎ “Đây là sản phẩm gì, cho ai, và đã chạy được chưa?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent1@8% “THỜI LƯỢNG” 8b accent1 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent1@8% “MINH CHỨNG BẮT BUỘC” 8b accent1 ⏎ “Ảnh hoặc GIF sản phẩm đang chạy” 10.5 tx1
- LEFT: “Tên đề tài rõ nghiệp vụ và dạng sản phẩm.” 12 ‖ “Một câu mô tả: dành cho ai, giải quyết điều gì.” 12 ‖ “Đối tượng sử dụng và 2–3 giá trị cốt lõi.” 12 ‖ “Tên nhóm, môn học, người hướng dẫn.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Tên đề tài quá dài, chung chung, hoặc chỉ là danh sách công nghệ.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 1.4×0.26` rr bg=accent4@14% “PROJECT NAME” 8.5b accent4 ctr
  - `5.6,3.43 4.3×0.5`  “[Tên hệ thống / sản phẩm]” 20b
  - `5.6,3.97 4.3×0.45`  “[Một câu giải thích giá trị sản phẩm tạo ra]” 11 64748B
  - `5.6,4.65 1.33×1.1` rr bg=accent1@8% “USERS” 9.5b accent1 ⏎ “[Đối tượng chính]” 9.5 64748B
  - `7.05,4.65 1.33×1.1` rr bg=accent2@8% “VALUE” 9.5b accent2 ⏎ “[Giá trị chính]” 9.5 64748B
  - `8.5,4.65 1.33×1.1` rr bg=accent4@8% “PLATFORM” 9.5b accent4 ⏎ “[Web / Mobile…]” 9.5 64748B
  - `10.15,3.05 2.45×2.7` rr bg=F1F5F9 bd=CBD5E1/1.0/dash “ẢNH / GIF” 12b 64748B ctr ⏎ “sản phẩm thật” 10 64748B ctr
  - `5.6,6.36 7.0×0.26`  “Dùng ảnh sản phẩm thật; nếu chưa có, dùng một câu value proposition.” 9.5i 64748B

### Slide mẫu 2 (file pptx: trang 6/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent1@14% “P1 · PROBLEM” 8.5b accent1 ctr
- H `2.15,0.36 7.0×0.26`  “02 / CONTEXT” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 2 Context — bối cảnh và hiện trạng” 26b accent1
- H `0.5,1.3 12.33×0.32`  “Đặt vấn đề bằng tình huống thực tế, không bắt đầu từ công nghệ.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent1@8% “CÂU HỎI HỘI ĐỒNG” 8b accent1 ⏎ “Đề tài ra đời trong bối cảnh nào, công việc hiện được thực hiện ra sao?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent1@8% “THỜI LƯỢNG” 8b accent1 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent1@8% “MINH CHỨNG BẮT BUỘC” 8b accent1 ⏎ “Mô tả hiện trạng, ảnh / số liệu quy trình” 10.5 tx1
- LEFT: “Môi trường, lĩnh vực và quy mô.” 12 ‖ “Quy trình hiện tại đang vận hành ra sao.” 12 ‖ “Ai liên quan và họ đang dùng công cụ gì.” 12 ‖ “Nhu cầu hoặc xu hướng dẫn đến đề tài.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Kể quá nhiều bối cảnh, hoặc bắt đầu bằng công nghệ.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×1.15` rr bg=accent1@10% “MÔI TRƯỜNG” 10b accent1 ⏎ “[Lĩnh vực, tổ chức, quy mô]” 10.5 475569
  - `8.0,3.05 2.2×1.15` rr bg=accent2@10% “NGƯỜI LIÊN QUAN” 10b accent2 ⏎ “[Ai tham gia quy trình]” 10.5 475569
  - `10.4,3.05 2.2×1.15` rr bg=accent3@10% “CÔNG CỤ HIỆN TẠI” 10b accent3 ⏎ “[Giấy tờ, Excel, phần mềm cũ]” 10.5 475569
  - `5.6,4.35 3.0×0.22`  “QUY TRÌNH HIỆN TẠI” 8.5b 64748B
  - `5.6,4.63 1.6×0.58` rr bg=F1F5F9 “[Bước 1]” 10.5b 475569 ctr
  - `7.22,4.92 0.16×0.0` LINE bd=94A3B8/1.2/solid
  - `7.4,4.63 1.6×0.58` rr bg=F1F5F9 “[Bước 2]” 10.5b 475569 ctr
  - `9.02,4.92 0.16×0.0` LINE bd=94A3B8/1.2/solid
  - `9.2,4.63 1.6×0.58` rr bg=F1F5F9 “[Bước 3]” 10.5b 475569 ctr
  - `10.82,4.92 0.16×0.0` LINE bd=94A3B8/1.2/solid
  - `11.0,4.63 1.6×0.58` rr bg=F1F5F9 “[Bước 4]” 10.5b 475569 ctr
  - `5.6,5.45 7.0×0.6` rr bg=64748B@10% “HIỆN TRẠNG [Số liệu về quy mô, tần suất, thời gian xử lý hiện nay]” 9.5b 64748B
  - `5.6,6.36 7.0×0.26`  “Chỉ mô tả hiện trạng; vấn đề được nêu ở slide 03.” 9.5i 64748B

### Slide mẫu 3 (file pptx: trang 7/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent1@14% “P1 · PROBLEM” 8.5b accent1 ctr
- H `2.15,0.36 7.0×0.26`  “03 / PROBLEM” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 3 Problem — vấn đề và hậu quả” 26b accent1
- H `0.5,1.3 12.33×0.32`  “Nêu các điểm nghẽn có nguyên nhân cụ thể và hậu quả có thể đo được.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent1@8% “CÂU HỎI HỘI ĐỒNG” 8b accent1 ⏎ “Vấn đề có thật không, và gây hậu quả gì?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent1@8% “THỜI LƯỢNG” 8b accent1 ⏎ “40 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent1@8% “MINH CHỨNG BẮT BUỘC” 8b accent1 ⏎ “Số liệu, trích dẫn khảo sát, log” 10.5 tx1
- LEFT: “2–3 pain point, mỗi cái có nguyên nhân cụ thể.” 12 ‖ “Impact: hậu quả quan sát hoặc đo được.” 12 ‖ “Ai bị ảnh hưởng nhiều nhất.” 12 ‖ “Minh chứng: phỏng vấn, khảo sát, log, số liệu mẫu.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Biến slide này thành mô tả giải pháp.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×0.32` rr bg=accent6@14% “PAIN POINT” 9b accent6 ctr
  - `8.0,3.05 2.2×0.32` rr bg=accent4@14% “NGUYÊN NHÂN” 9b accent4 ctr
  - `10.4,3.05 2.2×0.32` rr bg=accent1@14% “IMPACT” 9b accent1 ctr
  - `5.6,3.47 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Pain point 1]” 10 475569 ctr
  - `7.81,3.68 0.18×0.0` LINE bd=94A3B8/1.2/solid
  - `8.0,3.47 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Nguyên nhân]” 10 475569 ctr
  - `10.21,3.68 0.18×0.0` LINE bd=94A3B8/1.2/solid
  - `10.4,3.47 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Chi phí / thời gian]” 10 475569 ctr
  - `5.6,3.97 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Pain point 2]” 10 475569 ctr
  - `7.81,4.18 0.18×0.0` LINE bd=94A3B8/1.2/solid
  - `8.0,3.97 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Nguyên nhân]” 10 475569 ctr
  - `10.21,4.18 0.18×0.0` LINE bd=94A3B8/1.2/solid
  - `10.4,3.97 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Sai sót / rủi ro]” 10 475569 ctr
  - `5.6,4.47 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Pain point 3]” 10 475569 ctr
  - `7.81,4.68 0.18×0.0` LINE bd=94A3B8/1.2/solid
  - `8.0,4.47 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Nguyên nhân]” 10 475569 ctr
  - `10.21,4.68 0.18×0.0` LINE bd=94A3B8/1.2/solid
  - `10.4,4.47 2.2×0.42` rr bg=FFFFFF bd=E2E8F0/0.8 “[Ảnh hưởng người dùng]” 10 475569 ctr
  - `5.6,5.05 7.0×1.0` rr bg=FFFFFF bd=E2E8F0/0.8 “MINH CHỨNG” 9.5b accent2 ⏎ “[Số liệu] + [Trích dẫn khảo sát] + [Log / hiện trạng] — ghi nguồn và cỡ mẫu” 11 tx1
  - `5.6,6.36 7.0×0.26`  “Mỗi pain point ở đây được giải pháp ở slide 04 trả lời trực tiếp.” 9.5i 64748B

### Slide mẫu 4 (file pptx: trang 8/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent1@14% “P1 · PROBLEM” 8.5b accent1 ctr
- H `2.15,0.36 7.0×0.26`  “04 / PROPOSED SOLUTION” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 4 Proposed Solution — giải quyết trực tiếp vấn đề” 26b accent1
- H `0.5,1.3 12.33×0.32`  “Thể hiện quan hệ Pain point → Solution → Value, và phạm vi MVP.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent1@8% “CÂU HỎI HỘI ĐỒNG” 8b accent1 ⏎ “Giải pháp có trúng vấn đề không, phạm vi làm tới đâu?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent1@8% “THỜI LƯỢNG” 8b accent1 ⏎ “40 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent1@8% “MINH CHỨNG BẮT BUỘC” 8b accent1 ⏎ “Bảng ánh xạ pain point ↔ solution” 10.5 tx1
- LEFT: “Một giải pháp tổng thể, mô tả ngắn gọn.” 12 ‖ “Ánh xạ từng pain point với tính năng của sản phẩm.” 12 ‖ “Nêu điểm khác biệt và mục tiêu đo được.” 12 ‖ “Phân biệt in-scope (MVP) và out-of-scope.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Gọi “AI”, “microservices” là giá trị khi chưa chỉ ra lợi ích.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×0.32` rr bg=accent6@14% “PAIN POINT” 9b accent6 ctr
  - `8.0,3.05 2.2×0.32` rr bg=accent1@14% “SOLUTION” 9b accent1 ctr
  - `10.4,3.05 2.2×0.32` rr bg=accent2@14% “EXPECTED VALUE” 9b accent2 ctr
  - `5.6,3.47 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Chậm xử lý]” 10 475569 ctr
  - `8.0,3.47 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Tự động hóa]” 10 475569 ctr
  - `10.4,3.47 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Rút ngắn thời gian]” 10 475569 ctr
  - `5.6,3.95 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Khó truy vết]” 10 475569 ctr
  - `8.0,3.95 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Lưu lịch sử]” 10 475569 ctr
  - `10.4,3.95 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Minh bạch trạng thái]” 10 475569 ctr
  - `5.6,4.43 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Dữ liệu rời rạc]” 10 475569 ctr
  - `8.0,4.43 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Tập trung hóa]” 10 475569 ctr
  - `10.4,4.43 2.2×0.4` rr bg=FFFFFF bd=E2E8F0/0.8 “[Dễ thống kê]” 10 475569 ctr
  - `5.6,5.0 3.4×1.05` rr bg=accent2@10% “IN-SCOPE (MVP)” 9.5b accent2 ⏎ “[Các workflow lõi sẽ demo]” 10.5 tx1
  - `9.2,5.0 3.4×1.05` rr bg=F1F5F9 “OUT-OF-SCOPE” 9.5b 64748B ⏎ “[Để giai đoạn sau, kèm lý do]” 10.5 tx1
  - `5.6,6.36 7.0×0.26`  “Dùng 3 pain point có thật của đề tài thay cho ví dụ.” 9.5i 64748B

### Slide mẫu 5 (file pptx: trang 9/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent1@14% “P1 · PROBLEM” 8.5b accent1 ctr
- H `2.15,0.36 7.0×0.26`  “05 / MAIN ACTORS” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 5 Main Actors — các tác nhân chính của hệ thống” 26b accent1
- H `0.5,1.3 12.33×0.32`  “Mô tả những ai tương tác với hệ thống: họ là ai và được làm gì.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent1@8% “CÂU HỎI HỘI ĐỒNG” 8b accent1 ⏎ “Ai dùng hệ thống, họ là ai, và mỗi vai trò được làm gì?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent1@8% “THỜI LƯỢNG” 8b accent1 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent1@8% “MINH CHỨNG BẮT BUỘC” 8b accent1 ⏎ “Danh sách actor khớp phân quyền thật” 10.5 tx1
- LEFT: “Liệt kê các actor chính: người dùng và hệ thống ngoài.” 12 ‖ “Mô tả ngắn: họ là ai, trong bối cảnh nào.” 12 ‖ “Quyền hạn và công việc chính của mỗi actor.” 12 ‖ “Liên kết actor với nhóm tính năng chính.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Chỉ ghi tên vai trò mà không mô tả họ là ai, được làm gì.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `6.25,3.05 1.4×0.22`  “ACTOR” 8.5b 64748B
  - `7.75,3.05 2.7×0.22`  “MÔ TẢ” 8.5b 64748B
  - `10.55,3.05 2.0×0.22`  “QUYỀN HẠN CHÍNH” 8.5b 64748B
  - `5.6,3.33 7.0×0.65` rr bg=accent1@7%
  - `5.72,3.44 0.42×0.42` oval bg=DB2777 “N” 11b FFFFFF ctr
  - `6.25,3.44 1.4×0.45`  “Nhân viên” 11b ⏎ “Người dùng” 9 64748B
  - `7.75,3.43 2.7×0.48`  “Nhân viên các phòng ban có nhu cầu mua hàng” 10.5
  - `10.55,3.43 1.95×0.48`  “Tạo và theo dõi yêu cầu” 10.5b accent1
  - `5.6,4.06 7.0×0.65` rr bg=accent2@7%
  - `5.72,4.17 0.42×0.42` oval bg=F97316 “Q” 11b FFFFFF ctr
  - `6.25,4.17 1.4×0.45`  “Quản lý” 11b ⏎ “Người dùng” 9 64748B
  - `7.75,4.16 2.7×0.48`  “Trưởng phòng chịu trách nhiệm ngân sách” 10.5
  - `10.55,4.16 1.95×0.48`  “Duyệt, từ chối, điều phối” 10.5b accent2
  - `5.6,4.79 7.0×0.65` rr bg=accent4@7%
  - `5.72,4.91 0.42×0.42` oval bg=D97706 “K” 11b FFFFFF ctr
  - `6.25,4.9 1.4×0.45`  “Kế toán” 11b ⏎ “Người dùng” 9 64748B
  - `7.75,4.89 2.7×0.48`  “Theo dõi chi tiêu của toàn đơn vị” 10.5
  - `10.55,4.89 1.95×0.48`  “Xem và xuất báo cáo” 10.5b accent4
  - `5.6,5.52 7.0×0.65` rr bg=accent3@7%
  - `5.72,5.63 0.42×0.42` oval bg=EA580C “E” 11b FFFFFF ctr
  - `6.25,5.63 1.4×0.45`  “Email Service” 11b ⏎ “Hệ thống ngoài” 9 64748B
  - `7.75,5.62 2.7×0.48`  “Dịch vụ gửi thông báo tự động” 10.5
  - `10.55,5.62 1.95×0.48`  “Nhận yêu cầu gửi email” 10.5b accent3
  - `5.6,6.36 7.0×0.26`  “Thay bằng các actor thật của đề tài; thêm hoặc bớt dòng cho phù hợp.” 9.5i 64748B

### Slide mẫu 6 (file pptx: trang 10/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent1@14% “P1 · PROBLEM” 8.5b accent1 ctr
- H `2.15,0.36 7.0×0.26`  “06 / MAIN FEATURES” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 6 Main Features — nhóm theo nghiệp vụ” 26b accent1
- H `0.5,1.3 12.33×0.32`  “Tập trung tính năng mang giá trị; chọn ra các workflow quan trọng nhất để demo.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent1@8% “CÂU HỎI HỘI ĐỒNG” 8b accent1 ⏎ “Hệ thống làm được gì, và đâu là các workflow quan trọng nhất?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent1@8% “THỜI LƯỢNG” 8b accent1 ⏎ “45 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent1@8% “MINH CHỨNG BẮT BUỘC” 8b accent1 ⏎ “Nhóm tính năng; 2–4 workflow sẽ demo” 10.5 tx1
- LEFT: “Chia thành 3–5 nhóm tính năng chính.” 12 ‖ “Nêu bật 2–4 workflow quan trọng nhất để demo.” 12 ‖ “Chỉ ra tính năng MVP và phần mở rộng.” 12 ‖ “Liên kết tính năng ↔ actor ↔ vấn đề.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Liệt kê 20 tính năng chữ nhỏ, hoặc đọc menu chức năng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×2.5` rr bg=FFFFFF bd=E2E8F0/0.8
  - `5.6,3.05 2.2×0.55` rr bg=DB2777 “WF-01” 11b FFFFFF ctr ⏎ “Gửi yêu cầu” 10 FFFFFF ctr
  - `5.75,3.7 1.95×1.8`  “Actor” 8.5b 64748B ⏎ “Nhân viên” 10.5 ⏎ “Trigger” 8.5b 64748B ⏎ “Nhân viên cần mua hàng” 10.5 ⏎ “Kết quả” 8.5b 64748B ⏎ “Yêu cầu ở SUBMITTED” 10.5b accent1 ⏎ “Tính năng” 8.5b 64748B ⏎ “Tạo • kiểm tra • lưu nháp” 10
  - `8.0,3.05 2.2×2.5` rr bg=FFFFFF bd=E2E8F0/0.8
  - `8.0,3.05 2.2×0.55` rr bg=F97316 “WF-02” 11b FFFFFF ctr ⏎ “Duyệt yêu cầu” 10 FFFFFF ctr
  - `8.15,3.7 1.95×1.8`  “Actor” 8.5b 64748B ⏎ “Quản lý” 10.5 ⏎ “Trigger” 8.5b 64748B ⏎ “Có yêu cầu chờ duyệt” 10.5 ⏎ “Kết quả” 8.5b 64748B ⏎ “APPROVED / REJECTED + email” 10.5b accent2 ⏎ “Tính năng” 8.5b 64748B ⏎ “Duyệt • từ chối • thông báo” 10
  - `10.4,3.05 2.2×2.5` rr bg=FFFFFF bd=E2E8F0/0.8
  - `10.4,3.05 2.2×0.55` rr bg=D97706 “WF-03” 11b FFFFFF ctr ⏎ “Xem báo cáo” 10 FFFFFF ctr
  - `10.55,3.7 1.95×1.8`  “Actor” 8.5b 64748B ⏎ “Kế toán” 10.5 ⏎ “Trigger” 8.5b 64748B ⏎ “Cuối tháng / khi cần” 10.5 ⏎ “Kết quả” 8.5b 64748B ⏎ “Báo cáo chi tiêu” 10.5b accent4 ⏎ “Tính năng” 8.5b 64748B ⏎ “Lọc • tổng hợp • xuất file” 10
  - `5.6,5.75 7.0×0.3`  “Ngoài workflow lõi: [Quản trị tài khoản • cấu hình hạn mức • thống kê]” 10.5 64748B
  - `5.6,6.36 7.0×0.26`  “Các workflow này được demo ở slide 18–20.” 9.5i 64748B

### Slide mẫu 7 (file pptx: trang 11/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “07 / BUSINESS FLOW” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 7 Business Flow — luồng nghiệp vụ tổng thể” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Một sơ đồ Activity / BPMN cho toàn hệ thống: các actor phối hợp thế nào từ đầu đến cuối.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Nghiệp vụ của hệ thống vận hành thế nào, ai làm gì ở đâu?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “60 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Một activity / BPMN tổng thể có swimlane” 10.5 tx1
- LEFT: “Toàn bộ actor và hệ thống trong một sơ đồ.” 12 ‖ “Swimlane, bước xử lý chính, điểm rẽ nhánh.” 12 ‖ “Thể hiện cả nhánh ngoại lệ quan trọng.” 12 ‖ “Gán mã BR tại điểm rẽ để nối với State Machine và test.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Vẽ riêng cho từng tính năng ở đây, hoặc thay bằng danh sách thao tác click.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 7.0×0.74` rr bg=F8FAFC bd=E2E8F0/0.8
  - `5.7,3.13 0.95×0.22`  “NHÂN VIÊN” 8.5b 64748B
  - `5.6,3.85 7.0×0.74` rr bg=F8FAFC bd=E2E8F0/0.8
  - `5.7,3.93 0.95×0.22`  “HỆ THỐNG” 8.5b 64748B
  - `5.6,4.65 7.0×0.74` rr bg=F8FAFC bd=E2E8F0/0.8
  - `5.7,4.73 0.95×0.22`  “QUẢN LÝ” 8.5b 64748B
  - `5.6,5.45 7.0×0.74` rr bg=F8FAFC bd=E2E8F0/0.8
  - `5.7,5.53 0.95×0.22`  “KẾ TOÁN” 8.5b 64748B
  - `6.65,3.21 1.35×0.42` rr bg=accent1@14% “Gửi yêu cầu” 9.5b accent1 ctr
  - `8.15,4.01 1.35×0.42` rr bg=accent2@14% “Kiểm tra BR-02” 9.5b accent2 ctr
  - `9.75,3.9 1.05×0.64` diamond bg=accent4@18% “BR-03?” 8.5b accent4 ctr
  - `8.8,4.81 1.35×0.42` rr bg=accent4@14% “Cấp trên duyệt” 9.5b accent4 ctr
  - `11.05,4.81 1.35×0.42` rr bg=accent2@14% “Quản lý duyệt” 9.5b accent2 ctr
  - `11.05,3.21 1.35×0.42` rr bg=accent5@14% “Nhận kết quả” 9.5b accent5 ctr
  - `11.05,5.61 1.35×0.42` rr bg=accent4@14% “Xem báo cáo” 9.5b accent4 ctr
  - `7.35,3.64 0.78×0.52` LINE bd=94A3B8/1.2/solid
  - `8.02,3.47 0.68×0.53` LINE bd=DC2626/1.2/dash
  - `8.6,3.55 0.9×0.2`  “FAIL BR-02” 8.5b accent6
  - `9.52,4.22 0.21×0.0` LINE bd=94A3B8/1.2/solid
  - `10.8,4.22 0.75×0.58` LINE bd=94A3B8/1.2/solid
  - `11.32,4.25 0.75×0.2`  “≤ hạn mức” 8.5b accent2
  - `9.8,4.54 0.3×0.26` LINE bd=D97706/1.2/solid
  - `9.15,4.43 0.8×0.2`  “> hạn mức” 8.5b accent4
  - `10.17,5.02 0.86×0.0` LINE bd=D97706/1.2/solid
  - `12.05,3.64 0.0×1.16` LINE bd=94A3B8/1.2/solid
  - `11.72,5.24 0.0×0.36` LINE bd=94A3B8/1.2/solid
  - `5.6,6.36 7.0×0.26`  “Chỉ một sơ đồ tổng thể. Chi tiết từng workflow được trình bày khi demo (18–20).” 9.5i 64748B

### Slide mẫu 8 (file pptx: trang 12/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “08 / STATE MACHINE” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 8 State Machine — vòng đời đối tượng” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Mô tả các trạng thái hợp lệ và quy tắc chuyển trạng thái của business entity.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Đối tượng chính đi qua những trạng thái nào, chuyển nào bị cấm?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “40 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “State diagram có event, guard, chuyển bị cấm” 10.5 tx1
- LEFT: “Chọn entity có lifecycle quan trọng (Order, Request…).” 12 ‖ “Định nghĩa state, event, guard và action rõ ràng.” 12 ‖ “Phân biệt trạng thái nghiệp vụ với trạng thái UI.” 12 ‖ “Chuyển trạng thái không hợp lệ phải có test.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Vẽ một state diagram cho mỗi màn hình hoặc mỗi tính năng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×0.26` rr bg=accent1@14% “Business entity: Request” 8.5b accent1 ctr
  - `5.62,3.92 0.16×0.16` oval bg=1E293B
  - `5.78,4.0 0.3×0.0` LINE bd=94A3B8/1.2/solid
  - `6.1,3.75 1.45×0.5` rr bg=accent1@14% “DRAFT” 10.5b accent1 ctr
  - `8.35,3.75 1.45×0.5` rr bg=accent2@14% “SUBMITTED” 10.5b accent2 ctr
  - `10.75,3.75 1.45×0.5` rr bg=accent5@14% “APPROVED” 10.5b accent5 ctr
  - `8.35,5.0 1.45×0.5` rr bg=accent3@14% “REJECTED” 10.5b accent3 ctr
  - `10.75,5.0 1.45×0.5` rr bg=accent1@14% “COMPLETED” 10.5b accent1 ctr
  - `7.57,4.0 0.76×0.0` LINE bd=94A3B8/1.2/solid
  - `7.57,3.7 0.76×0.2`  “submit” 8.5 64748B ctr
  - `9.82,4.0 0.91×0.0` LINE bd=94A3B8/1.2/solid
  - `9.82,3.7 0.91×0.2`  “approve [valid]” 8.5 64748B ctr
  - `9.07,4.27 0.0×0.71` LINE bd=94A3B8/1.2/solid
  - `9.15,4.6 1.0×0.2`  “reject [reason]” 8.5 64748B
  - `11.47,4.27 0.0×0.71` LINE bd=94A3B8/1.2/solid
  - `11.55,4.6 0.8×0.2`  “finish” 8.5 64748B
  - `5.6,5.85 3.5×0.3`  “Transition = Event [Guard] / Action” 11b
  - `9.8,5.85 2.8×0.3` rr bg=accent6@14% “Cấm: DRAFT → APPROVED” 8.5b accent6 ctr
  - `5.6,6.36 7.0×0.26`  “Transition = Event [Guard] / Action.” 9.5i 64748B

### Slide mẫu 9 (file pptx: trang 13/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “09 / SYSTEM ARCHITECTURE” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 9 System Architecture — các khối chính và nơi triển khai” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Boundary, ứng dụng, data store, hệ thống ngoài, nơi triển khai và lý do chọn.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Hệ thống gồm những khối nào, chạy ở đâu, vì sao thiết kế như vậy?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “50 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Sơ đồ container + 1–2 quyết định kiến trúc” 10.5 tx1
- LEFT: “Mô tả theo C4 Context / Container ở mức phù hợp.” 12 ‖ “Giao tiếp, chiều dữ liệu, sync / async.” 12 ‖ “Nơi triển khai: môi trường, dịch vụ host.” 12 ‖ “1–2 quyết định kiến trúc và trade-off.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Hình hạ tầng quá rối, hoặc chỉ liệt kê công nghệ.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.1 1.8×0.9` rr bg=accent1@12% “CLIENT” 10.5b accent1 ctr ⏎ “Web / Mobile” 9.5 64748B ctr
  - `7.43,3.55 0.74×0.0` LINE bd=94A3B8/1.2/solid
  - `7.4,3.29 0.8×0.2`  “HTTPS/REST” 8 64748B ctr
  - `8.2,3.1 1.8×0.9` rr bg=accent2@12% “BACKEND API” 10.5b accent2 ctr ⏎ “Business services” 9.5 64748B ctr
  - `10.03,3.55 0.74×0.0` LINE bd=94A3B8/1.2/solid
  - `10.0,3.29 0.8×0.2`  “SQL” 8 64748B ctr
  - `10.8,3.1 1.8×0.9` rr bg=accent4@12% “DATA” 10.5b accent4 ctr ⏎ “Database / files” 9.5 64748B ctr
  - `7.9,4.3 2.3×0.5` rr bg=FFFFFF bd=E2E8F0/0.8 “EXTERNAL Auth • Email” 9.5b tx1 ctr
  - `9.05,4.02 0.0×0.26` LINE bd=94A3B8/1.2/solid
  - `5.6,5.0 7.0×0.45` rr bg=64748B@10% “DEPLOYMENT [Docker trên VPS / Firebase / Vercel] • dev / production” 9.5b 64748B
  - `5.6,5.55 7.0×0.5` rr bg=accent3@10% “QUYẾT ĐỊNH Chọn [X] để đạt [hiệu năng / chi phí] — đánh đổi: [Y]” 9.5b accent3
  - `5.6,6.36 7.0×0.26`  “Sơ đồ nhìn là hiểu trong 10–15 giây.” 9.5i 64748B

### Slide mẫu 10 (file pptx: trang 14/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “10 / TECHNOLOGY STACK” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 10 Technology Stack — công nghệ theo nhóm” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Liệt kê công nghệ đã sử dụng theo từng mảng, mỗi công nghệ gắn với một vai trò cụ thể.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Hệ thống dùng những công nghệ nào, mỗi thứ để làm gì?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “40 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Công nghệ khớp mã nguồn và môi trường thật” 10.5 tx1
- LEFT: “Liệt kê theo nhóm: FE, Mobile, BE, AI, Dev, DevOps, Ops.” 12 ‖ “Mỗi công nghệ gắn với vai trò cụ thể.” 12 ‖ “Nêu ngắn lý do chọn các công nghệ quan trọng.” 12 ‖ “Chỉ đề cập công nghệ đã dùng thật.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ ““Bức tường logo” thiếu lý do sử dụng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 7.0×1.0`  “Nhóm” 9.5b FFFFFF ⏎ “Công nghệ (ví dụ)” 9.5b FFFFFF ⏎ “Dùng để làm gì” 9.5b FFFFFF ⏎ “FE” 10.5b DB2777 ⏎ “React • TypeScript • Tailwind” 10.5 1E293B ⏎ “Giao diện web” 10.5 1E293B ⏎ “Mobile” 10.5b F97316 ⏎ “Flutter / React Native” 10.5 1E293B ⏎ “Ứng dụng di động” 10.5 1E293B ⏎ “BE” 10.5b EA580C ⏎ “Node.js / Spring Boot • PostgreSQL” 10.5 1E293B ⏎ “API, nghiệp vụ, dữ liệu” 10.5 1E293B ⏎ “AI” 10.5b D97706 ⏎ “[OpenAI API / LangChain / PyTorch]” 10.5 1E293B ⏎ “Mô hình, pipeline AI” 10.5 1E293B ⏎ “Dev” 10.5b 475569 ⏎ “Git • VS Code • Figma • Postman” 10.5 1E293B ⏎ “Công cụ phát triển” 10.5 1E293B ⏎ “DevOps” 10.5b 9D174D ⏎ “Docker • GitHub Actions” 10.5 1E293B ⏎ “Build, test, deploy tự động” 10.5 1E293B ⏎ “Ops” 10.5b DC2626 ⏎ “Nginx / Cloud • Grafana • Sentry” 10.5 1E293B ⏎ “Vận hành, giám sát” 10.5 1E293B
  - `5.6,6.36 7.0×0.26`  “Tên công nghệ chỉ là ví dụ — thay bằng stack thực tế; nhóm không dùng thì bỏ dòng đó.” 9.5i 64748B

### Slide mẫu 11 (file pptx: trang 15/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “11 / UI/UX DESIGN” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 11 UI/UX Design — giao diện tổng thể” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Bức tranh giao diện toàn hệ thống: điều hướng, ngôn ngữ thiết kế và các trạng thái UI.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Giao diện được tổ chức thế nào và có nhất quán, dễ dùng không?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “40 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Sitemap / user flow và UI cuối (Figma)” 10.5 tx1
- LEFT: “Sitemap và navigation của toàn hệ thống, mã UI-xx.” 12 ‖ “Wireframe → Hi-Fi → Final Figma đã chốt.” 12 ‖ “Trạng thái UI: empty, loading, error, success.” 12 ‖ “Phản hồi người dùng đã làm thay đổi thiết kế.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Chiếu 20 màn hình Figma không có câu chuyện sử dụng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.0×1.95` rr bg=F8FAFC bd=E2E8F0/0.8
  - `5.75,3.17 1.7×0.26` rr bg=94A3B8@14% “WIREFRAME” 8.5b 94A3B8 ctr
  - `5.8,3.6 1.6×0.18` rr bg=E2E8F0
  - `5.8,3.9 1.6×0.18` rr bg=E2E8F0
  - `5.8,4.2 1.6×0.18` rr bg=E2E8F0
  - `5.8,4.6 1.6×0.25`  “Low-fi” 9.5 64748B ctr
  - `7.63,4.02 0.39×0.0` LINE bd=94A3B8/1.2/solid
  - `8.05,3.05 2.0×1.95` rr bg=F8FAFC bd=E2E8F0/0.8
  - `8.2,3.17 1.7×0.26` rr bg=accent1@14% “MOCKUP” 8.5b accent1 ctr
  - `8.25,3.6 1.6×0.18` rr bg=E2E8F0
  - `8.25,3.9 1.6×0.18` rr bg=E2E8F0
  - `8.25,4.2 1.6×0.18` rr bg=E2E8F0
  - `8.25,4.6 1.6×0.25`  “Hi-fi” 9.5 64748B ctr
  - `10.08,4.02 0.39×0.0` LINE bd=94A3B8/1.2/solid
  - `10.5,3.05 2.0×1.95` rr bg=F8FAFC bd=E2E8F0/0.8
  - `10.65,3.17 1.7×0.26` rr bg=accent2@14% “FINAL FIGMA” 8.5b accent2 ctr
  - `10.7,3.6 1.6×0.18` rr bg=E2E8F0
  - `10.7,3.9 1.6×0.18` rr bg=E2E8F0
  - `10.7,4.2 1.6×0.18` rr bg=E2E8F0
  - `10.7,4.6 1.6×0.25`  “Đã chốt” 9.5 64748B ctr
  - `5.6,5.17 1.1×0.3` rr bg=94A3B8@14% “Empty” 8.5b 94A3B8 ctr
  - `6.85,5.17 1.1×0.3` rr bg=accent1@14% “Loading” 8.5b accent1 ctr
  - `8.1,5.17 1.1×0.3` rr bg=accent6@14% “Error” 8.5b accent6 ctr
  - `9.35,5.17 1.1×0.3` rr bg=accent2@14% “Success” 8.5b accent2 ctr
  - `5.6,5.65 7.0×0.45` rr bg=accent4@10% “SAU GÓP Ý [Phản hồi người dùng] → [Điều đã sửa trên thiết kế]” 9.5b accent4
  - `5.6,6.36 7.0×0.26`  “Chọn vài màn hình đại diện; thao tác chi tiết sẽ thấy khi demo.” 9.5i 64748B

### Slide mẫu 12 (file pptx: trang 16/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “12 / SEQUENCE DIAGRAM” 9.5b 64748B
- H `9.33,0.36 3.5×0.26` rr bg=accent4@12% “TÙY CHỌN” 8.5b accent4 ctr
- H `0.5,0.66 12.33×0.62`  “Slide 12 Sequence Diagram — các thành phần phối hợp” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Một tương tác tiêu biểu giữa UI, service, repository và hệ thống ngoài.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Khi người dùng bấm nút, bên trong hệ thống diễn ra những gì?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “35 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Sequence cho 1 tương tác, có nhánh ngoại lệ” 10.5 tx1
- LEFT: “Chọn một tương tác tiêu biểu của hệ thống.” 12 ‖ “Lifeline khớp class / component (slide 13).” 12 ‖ “Có nhánh ngoại lệ (alt) theo business rule.” 12 ‖ “Tên message là tên hàm / API thật.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Vẽ sequence cho mọi tính năng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.65,3.05 1.1×0.36` rr bg=accent2@14% “Actor” 9.5b accent2 ctr
  - `6.2,3.41 0.0×2.8` LINE bd=CBD5E1/1.0/dash
  - `7.1,3.05 1.1×0.36` rr bg=accent2@14% “:UI” 9.5b accent2 ctr
  - `7.65,3.41 0.0×2.8` LINE bd=CBD5E1/1.0/dash
  - `8.55,3.05 1.1×0.36` rr bg=accent2@14% “:Service” 9.5b accent2 ctr
  - `9.1,3.41 0.0×2.8` LINE bd=CBD5E1/1.0/dash
  - `10.0,3.05 1.1×0.36` rr bg=accent2@14% “:Repository” 9.5b accent2 ctr
  - `10.55,3.41 0.0×2.8` LINE bd=CBD5E1/1.0/dash
  - `11.45,3.05 1.1×0.36` rr bg=accent2@14% “DB” 9.5b accent2 ctr
  - `12.0,3.41 0.0×2.8` LINE bd=CBD5E1/1.0/dash
  - `6.22,3.8 1.41×0.0` LINE bd=475569/1.2/solid
  - `6.25,3.58 1.45×0.2`  “1. approve(id)” 8.5 1E293B ctr
  - `7.67,4.15 1.41×0.0` LINE bd=475569/1.2/solid
  - `7.7,3.93 1.45×0.2`  “2. approveRequest(id)” 8.5 1E293B ctr
  - `9.12,4.5 1.41×0.0` LINE bd=475569/1.2/solid
  - `9.15,4.28 1.45×0.2`  “3. findById(id)” 8.5 1E293B ctr
  - `10.57,4.85 1.41×0.0` LINE bd=475569/1.2/solid
  - `10.6,4.63 1.45×0.2`  “4. SELECT” 8.5 1E293B ctr
  - `7.2,5.05 3.4×0.5` rr bg=accent6@8% bd=DC2626/0.8/dash “alt [vượt hạn mức · BR-03] → escalate()” 9b accent6
  - `7.67,5.8 1.41×0.0` LINE bd=94A3B8/1.2/dash
  - `7.7,5.58 1.45×0.2`  “5. 200 OK / 409 (BR-03)” 8.5 64748B ctr
  - `5.6,6.36 7.0×0.26`  “Ví dụ minh họa: nhánh ngoại lệ khi vi phạm business rule (BR-03).” 9.5i 64748B

### Slide mẫu 13 (file pptx: trang 17/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “13 / CLASS DESIGN” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 13 Class Design — trách nhiệm & quan hệ” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Class diagram mô tả thiết kế code, không phải bản sao của ERD.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Code chia trách nhiệm ra sao, business rule nằm ở đâu?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Class khớp tên trong mã nguồn” 10.5 tx1
- LEFT: “Class cốt lõi của hệ thống / module quan trọng.” 12 ‖ “Attribute, operation, association / dependency.” 12 ‖ “Phân biệt Entity, Service, Controller, Repository.” 12 ‖ “Đối chiếu với mã nguồn và business rule.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Chuyển mọi bảng database thành class có getter/setter.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.1×0.36` rr bg=accent1@15% “RequestViewModel” 10b accent1 ctr
  - `5.6,3.41 2.1×0.75` rr bg=FFFFFF bd=E2E8F0/0.8 “+ submitCommand()” 9.5 334155 ⏎ “+ loading: bool” 9.5 334155
  - `8.05,3.05 2.1×0.36` rr bg=accent2@15% “RequestService” 10b accent2 ctr
  - `8.05,3.41 2.1×0.75` rr bg=FFFFFF bd=E2E8F0/0.8 “+ createRequest()” 9.5 334155 ⏎ “+ approveRequest()” 9.5 334155
  - `10.5,3.05 2.1×0.36` rr bg=accent4@15% “RequestRepository” 10b accent4 ctr
  - `10.5,3.41 2.1×0.75` rr bg=FFFFFF bd=E2E8F0/0.8 “+ save(request)” 9.5 334155 ⏎ “+ findById(id)” 9.5 334155
  - `8.05,4.8 2.1×0.36` rr bg=accent3@15% “Request (domain)” 10b accent3 ctr
  - `8.05,5.16 2.1×0.75` rr bg=FFFFFF bd=E2E8F0/0.8 “+ status: RequestStatus” 9.5 334155 ⏎ “+ submit() / approve()” 9.5 334155
  - `7.72,3.65 0.31×0.0` LINE bd=94A3B8/1.2/solid
  - `10.17,3.65 0.31×0.0` LINE bd=94A3B8/1.2/solid
  - `9.1,4.18 0.0×0.6` LINE bd=94A3B8/1.2/solid
  - `10.5,4.95 2.1×0.9`  “Business rule (BR-02, BR-03) đặt trong domain entity, không trong UI.” 9.5i 64748B
  - `5.6,6.36 7.0×0.26`  “Domain entity ≠ database table (không mặc định 1:1).” 9.5i 64748B

### Slide mẫu 14 (file pptx: trang 18/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “14 / DATABASE DESIGN — CONCEPTUAL” 9.5b 64748B
- H `9.33,0.36 3.5×0.26` rr bg=accent4@12% “TÙY CHỌN — có thể gộp vào slide 15” 8.5b accent4 ctr
- H `0.5,0.66 12.33×0.62`  “Slide 14 Database Design 1/2 — mô hình khái niệm” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Mô hình hóa ngữ nghĩa nghiệp vụ, chưa phụ thuộc SQL hay DBMS.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Dữ liệu nghiệp vụ gồm những thực thể nào, quan hệ ra sao?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “25 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “ERD có cardinality và business rule” 10.5 tx1
- LEFT: “Business entity và định nghĩa nhất quán.” 12 ‖ “Quan hệ, cardinality, optionality chính.” 12 ‖ “Business rule chi phối quan hệ.” 12 ‖ “Đối chiếu entity với actor và nghiệp vụ.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Thêm VARCHAR, INT, PK vật lý vào conceptual ERD.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.7,3.35 1.8×0.85` rr bg=accent2@12% “EMPLOYEE” 10.5b accent2 ctr ⏎ “Nhân viên” 9.5 64748B ctr
  - `7.52,3.77 0.66×0.0` LINE bd=64748B/1.2/solid
  - `7.56,3.51 0.2×0.2`  “1” 9b
  - `7.8,3.51 0.4×0.2`  “0..*” 9b
  - `8.2,3.35 1.8×0.85` rr bg=accent2@12% “REQUEST” 10.5b accent2 ctr ⏎ “Yêu cầu” 9.5 64748B ctr
  - `10.02,3.77 0.66×0.0` LINE bd=64748B/1.2/solid
  - `10.06,3.51 0.2×0.2`  “1” 9b
  - `10.3,3.51 0.4×0.2`  “0..*” 9b
  - `10.7,3.35 1.8×0.85` rr bg=accent2@12% “REQUEST ITEM” 10.5b accent2 ctr ⏎ “Dòng yêu cầu” 9.5 64748B ctr
  - `5.6,4.65 7.0×1.4` rr bg=FFFFFF bd=E2E8F0/0.8 “Business rules (ví dụ)” 11b tx1 ⏎ “BR-01 Mỗi Request thuộc đúng một Employee.” 10.5 tx1 ⏎ “BR-02 Request đã gửi phải có ít nhất một Item.” 10.5 tx1
  - `5.6,6.36 7.0×0.26`  “Mã BR dùng lại ở luồng nghiệp vụ (07) và test (21).” 9.5i 64748B

### Slide mẫu 15 (file pptx: trang 19/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “15 / DATABASE DESIGN — LOGICAL → PHYSICAL” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 15 Database Design 2/2 — từ logic đến vật lý” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Từ cấu trúc logic sang database đang chạy, có minh chứng triển khai.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Dữ liệu được hiện thực đúng và có ràng buộc bảo vệ chưa?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Migration / schema hoặc query thật” 10.5 tx1
- LEFT: “Logical: attribute, identifier, chuẩn hóa quan hệ.” 12 ‖ “Physical: DBMS, bảng, cột, kiểu dữ liệu.” 12 ‖ “PK, FK, UNIQUE, CHECK, NOT NULL và index.” 12 ‖ “Minh chứng: file migration, schema export.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Coi screenshot các bảng là thiết kế vật lý hoàn chỉnh.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 1.95×0.36` rr bg=accent2@15% “REQUEST (logical)” 10b accent2 ctr
  - `5.6,3.41 1.95×1.6` rr bg=FFFFFF bd=E2E8F0/0.8 “RequestID (ID)” 10 334155 ⏎ “EmployeeID (ref)” 10 334155 ⏎ “Status” 10 334155 ⏎ “TotalAmount” 10 334155 ⏎ “CreatedAt” 10 334155
  - `7.6,4.05 0.45×0.0` LINE bd=EA580C/1.2/solid
  - `8.1,3.05 4.5×1.0`  “request · PostgreSQL” 9b FFFFFF ⏎ “Kiểu” 9b FFFFFF ⏎ “Ràng buộc” 9b FFFFFF ⏎ “request_id” 10b 1E293B ⏎ “BIGINT” 10 1E293B ⏎ “PK” 10 1E293B ⏎ “employee_id” 10b 1E293B ⏎ “BIGINT” 10 1E293B ⏎ “FK, NOT NULL” 10 1E293B ⏎ “status” 10b 1E293B ⏎ “VARCHAR(16)” 10 1E293B ⏎ “CHECK IN (…)” 10 1E293B ⏎ “total_amount” 10b 1E293B ⏎ “NUMERIC(12,2)” 10 1E293B ⏎ “CHECK ≥ 0” 10 1E293B ⏎ “created_at” 10b 1E293B ⏎ “TIMESTAMPTZ” 10 1E293B ⏎ “NOT NULL” 10 1E293B
  - `5.6,5.55 7.0×0.5` rr bg=accent2@10% “INDEX request(employee_id, created_at) • Migration: V3__create_request.sql” 9.5b accent2
  - `5.6,6.36 7.0×0.26`  “Schema đầy đủ để ở phụ lục.” 9.5i 64748B

### Slide mẫu 16 (file pptx: trang 20/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent3@14% “P2 · DESIGN” 8.5b accent3 ctr
- H `2.15,0.36 7.0×0.26`  “16 / TRACEABILITY” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 16 Traceability — kiểm tra tính nhất quán của thiết kế” 26b accent3
- H `0.5,1.3 12.33×0.32`  “Mỗi nhóm tính năng phải được nhìn thấy nhất quán qua UI, code, data và test.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent3@8% “CÂU HỎI HỘI ĐỒNG” 8b accent3 ⏎ “Các bản thiết kế có khớp nhau và có được dùng thật không?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent3@8% “THỜI LƯỢNG” 8b accent3 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent3@8% “MINH CHỨNG BẮT BUỘC” 8b accent3 ⏎ “Ma trận Feature → Screen → Class → Entity → Test” 10.5 tx1
- LEFT: “Mỗi nhóm tính năng có mã riêng, gắn actor.” 12 ‖ “Map Feature ↔ Screen ↔ Class / Service ↔ Entity.” 12 ‖ “Business rule và nhánh rẽ sinh ra test case.” 12 ‖ “Phát hiện thiết kế “có hình nhưng không dùng”.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Bắt 1 class / 1 bảng / 1 màn hình cho mỗi tính năng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 7.0×1.0`  “Feature” 9.5b FFFFFF ⏎ “Screen” 9.5b FFFFFF ⏎ “Class / Service” 9.5b FFFFFF ⏎ “Entity” 9.5b FFFFFF ⏎ “Tests” 9.5b FFFFFF ⏎ “F1 Yêu cầu” 10.5b 1E293B ⏎ “UI-01, 02” 10.5 1E293B ⏎ “RequestService” 10.5 1E293B ⏎ “Request” 10.5 1E293B ⏎ “TC01–04” 10.5 1E293B ⏎ “F2 Phê duyệt” 10.5b 1E293B ⏎ “UI-03, 04” 10.5 1E293B ⏎ “RequestService” 10.5 1E293B ⏎ “Request” 10.5 1E293B ⏎ “TC05–11” 10.5 1E293B ⏎ “F3 Báo cáo” 10.5b 1E293B ⏎ “UI-05, 06” 10.5 1E293B ⏎ “ReportService” 10.5 1E293B ⏎ “Request” 10.5 1E293B ⏎ “TC12–14” 10.5 1E293B
  - `5.6,5.35 7.0×0.6` rr bg=accent2@10% “TRUY VẾT: Feature → Screen → Class → DB → Test” 10.5b accent2 ctr
  - `5.6,6.36 7.0×0.26`  “Slide chốt phần Design.” 9.5i 64748B

### Slide mẫu 17 (file pptx: trang 21/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent4@14% “P3 · DEMO” 8.5b accent4 ctr
- H `2.15,0.36 7.0×0.26`  “17 / DEMO PLAN” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 17 Demo Plan — ghép các workflow thành một câu chuyện” 26b accent4
- H `0.5,1.3 12.33×0.32`  “Demo là minh chứng end-to-end: kết quả của workflow trước là đầu vào của workflow sau.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent4@8% “CÂU HỎI HỘI ĐỒNG” 8b accent4 ⏎ “Hội đồng sắp xem những workflow nào, theo thứ tự nào, vì sao?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent4@8% “THỜI LƯỢNG” 8b accent4 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent4@8% “MINH CHỨNG BẮT BUỘC” 8b accent4 ⏎ “Storyboard workflow + dữ liệu demo chuẩn bị sẵn” 10.5 tx1
- LEFT: “Thứ tự workflow theo câu chuyện nghiệp vụ (tạo → xử lý → kết quả).” 12 ‖ “Mỗi workflow: actor, tài khoản, dữ liệu, kết quả mong đợi.” 12 ‖ “Seed data cố định, script reset dữ liệu.” 12 ‖ “Video dự phòng; người thao tác ≠ người thuyết minh.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Demo theo menu chức năng; dữ liệu ngẫu nhiên tạo tại chỗ.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×2.0` rr bg=FFFFFF bd=E2E8F0/0.8
  - `5.8,3.23 0.55×0.55` oval bg=DB2777 “01” 12b FFFFFF ctr
  - `6.45,3.27 1.3×0.25`  “Gửi yêu cầu” 11.5b
  - `6.45,3.53 1.3×0.22`  “Nhân viên” 9.5 64748B
  - `5.75,3.95 1.9×0.95` rr bg=accent1@10% “KẾT QUẢ” 8b accent1 ⏎ “Yêu cầu #R-102 ở SUBMITTED” 10 tx1
  - `7.82,4.05 0.16×0.0` LINE bd=D97706/1.8/solid
  - `8.0,3.05 2.2×2.0` rr bg=FFFFFF bd=E2E8F0/0.8
  - `8.2,3.23 0.55×0.55` oval bg=F97316 “02” 12b FFFFFF ctr
  - `8.85,3.27 1.3×0.25`  “Duyệt yêu cầu” 11.5b
  - `8.85,3.53 1.3×0.22`  “Quản lý” 9.5 64748B
  - `8.15,3.95 1.9×0.95` rr bg=accent2@10% “KẾT QUẢ” 8b accent2 ⏎ “#R-102 → APPROVED, email đã gửi” 10 tx1
  - `10.22,4.05 0.16×0.0` LINE bd=D97706/1.8/solid
  - `10.4,3.05 2.2×2.0` rr bg=FFFFFF bd=E2E8F0/0.8
  - `10.6,3.23 0.55×0.55` oval bg=D97706 “03” 12b FFFFFF ctr
  - `11.25,3.27 1.3×0.25`  “Xem báo cáo” 11.5b
  - `11.25,3.53 1.3×0.22`  “Kế toán” 9.5 64748B
  - `10.55,3.95 1.9×0.95` rr bg=accent4@10% “KẾT QUẢ” 8b accent4 ⏎ “#R-102 có trong báo cáo tháng” 10 tx1
  - `5.6,5.3 7.0×0.75` rr bg=accent4@10% “CHUẨN BỊ Seed data • tài khoản Nhân viên / Quản lý / Kế toán • script reset • video dự phòng” 9.5b accent4
  - `5.6,6.36 7.0×0.26`  “Bố cục 3 cột là storyboard của toàn bộ phần demo.” 9.5i 64748B

### Slide mẫu 18 (file pptx: trang 22/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent4@14% “P3 · DEMO” 8.5b accent4 ctr
- H `2.15,0.36 7.0×0.26`  “18 / DEMO WF-01” 9.5b 64748B
- H `9.33,0.36 3.5×0.26` rr bg=accent1@12% “WF-01 · NHÂN VIÊN” 8.5b accent1 ctr
- H `0.5,0.66 12.33×0.62`  “Slide 18 Demo WF-01 — Gửi yêu cầu (khởi tạo nghiệp vụ)” 26b accent4
- H `0.5,1.3 12.33×0.32`  “Cùng một layout cho mọi workflow để người xem dễ theo dõi.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent4@8% “CÂU HỎI HỘI ĐỒNG” 8b accent4 ⏎ “WF-01 có chạy thật, đúng nghiệp vụ, và xử lý lỗi đúng không?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent4@8% “THỜI LƯỢNG” 8b accent4 ⏎ “≈ 2′” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent4@8% “MINH CHỨNG BẮT BUỘC” 8b accent4 ⏎ “Chạy trực tiếp; record ID, trạng thái, log / email” 10.5 tx1
- LEFT: “Scenario: nhân viên cần mua hàng nên tạo yêu cầu.” 12 ‖ “Happy path: đi qua từng bước và màn hình như thiết kế.” 12 ‖ “Exception path: cố ý vi phạm business rule.” 12 ‖ “Minh chứng: trạng thái mới, record ID, khớp test case.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Chiếu video thay cho chạy thật; video chỉ là phương án dự phòng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 1.26×0.8` rr bg=DB2777 “Trigger” 10b FFFFFF ctr ⏎ “cần mua hàng” 8.5 FFFFFF ctr
  - `6.87,3.45 0.16×0.0` LINE bd=DB2777/1.2/solid
  - `7.04,3.05 1.26×0.8` rr bg=accent1@14% “Nhập form” 10b accent1 ctr ⏎ “UI-01” 8.5 475569 ctr
  - `8.3,3.45 0.16×0.0` LINE bd=DB2777/1.2/solid
  - `8.47,3.05 1.26×0.8` rr bg=accent1@14% “Kiểm tra” 10b accent1 ctr ⏎ “BR-02” 8.5 475569 ctr
  - `9.74,3.45 0.16×0.0` LINE bd=DB2777/1.2/solid
  - `9.91,3.05 1.26×0.8` rr bg=accent1@14% “Xác nhận” 10b accent1 ctr ⏎ “UI-02” 8.5 475569 ctr
  - `11.17,3.45 0.16×0.0` LINE bd=DB2777/1.2/solid
  - `11.34,3.05 1.26×0.8` rr bg=DB2777 “Kết quả” 10b FFFFFF ctr ⏎ “SUBMITTED” 8.5 FFFFFF ctr
  - `5.6,4.05 7.0×0.5` rr bg=475569@10% “TRẠNG THÁI DRAFT → SUBMITTED” 9.5b 475569
  - `5.6,4.65 7.0×0.65` rr bg=accent6@10% “EXCEPTION Gửi khi chưa có dòng hàng → báo lỗi BR-02, không tạo yêu cầu” 9.5b accent6
  - `5.6,5.4 7.0×0.65` rr bg=accent5@10% “EVIDENCE Mã #R-102 • trạng thái SUBMITTED • khớp TC01–04” 9.5b accent5
  - `5.6,6.36 7.0×0.26`  “Thay nội dung ví dụ bằng dữ liệu demo cụ thể của nhóm.” 9.5i 64748B

### Slide mẫu 19 (file pptx: trang 23/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent4@14% “P3 · DEMO” 8.5b accent4 ctr
- H `2.15,0.36 7.0×0.26`  “19 / DEMO WF-02” 9.5b 64748B
- H `9.33,0.36 3.5×0.26` rr bg=accent2@12% “WF-02 · QUẢN LÝ” 8.5b accent2 ctr
- H `0.5,0.66 12.33×0.62`  “Slide 19 Demo WF-02 — Duyệt yêu cầu (xử lý nghiệp vụ)” 26b accent4
- H `0.5,1.3 12.33×0.32`  “Cùng một layout cho mọi workflow để người xem dễ theo dõi.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent4@8% “CÂU HỎI HỘI ĐỒNG” 8b accent4 ⏎ “WF-02 có chạy thật, đúng nghiệp vụ, và xử lý lỗi đúng không?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent4@8% “THỜI LƯỢNG” 8b accent4 ⏎ “≈ 2′” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent4@8% “MINH CHỨNG BẮT BUỘC” 8b accent4 ⏎ “Chạy trực tiếp; record ID, trạng thái, log / email” 10.5 tx1
- LEFT: “Scenario: quản lý có yêu cầu đang chờ duyệt.” 12 ‖ “Happy path: đi qua từng bước và màn hình như thiết kế.” 12 ‖ “Exception path: cố ý vi phạm business rule.” 12 ‖ “Minh chứng: trạng thái mới, record ID, khớp test case.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Chiếu video thay cho chạy thật; video chỉ là phương án dự phòng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 1.26×0.8` rr bg=F97316 “Trigger” 10b FFFFFF ctr ⏎ “yêu cầu chờ” 8.5 FFFFFF ctr
  - `6.87,3.45 0.16×0.0` LINE bd=F97316/1.2/solid
  - `7.04,3.05 1.26×0.8` rr bg=accent2@14% “Danh sách” 10b accent2 ctr ⏎ “UI-03” 8.5 475569 ctr
  - `8.3,3.45 0.16×0.0` LINE bd=F97316/1.2/solid
  - `8.47,3.05 1.26×0.8` rr bg=accent2@14% “Chi tiết” 10b accent2 ctr ⏎ “UI-04” 8.5 475569 ctr
  - `9.74,3.45 0.16×0.0` LINE bd=F97316/1.2/solid
  - `9.91,3.05 1.26×0.8` rr bg=accent2@14% “Hạn mức?” 10b accent2 ctr ⏎ “BR-03” 8.5 475569 ctr
  - `11.17,3.45 0.16×0.0` LINE bd=F97316/1.2/solid
  - `11.34,3.05 1.26×0.8` rr bg=F97316 “Kết quả” 10b FFFFFF ctr ⏎ “APPROVED + email” 8.5 FFFFFF ctr
  - `5.6,4.05 7.0×0.5` rr bg=475569@10% “TRẠNG THÁI SUBMITTED → APPROVED / REJECTED” 9.5b 475569
  - `5.6,4.65 7.0×0.65` rr bg=accent6@10% “EXCEPTION Vượt hạn mức → chuyển cấp trên; từ chối không lý do → bị chặn” 9.5b accent6
  - `5.6,5.4 7.0×0.65` rr bg=accent5@10% “EVIDENCE #R-102 APPROVED • email đã gửi • khớp TC05–11” 9.5b accent5
  - `5.6,6.36 7.0×0.26`  “Thay nội dung ví dụ bằng dữ liệu demo cụ thể của nhóm.” 9.5i 64748B

### Slide mẫu 20 (file pptx: trang 24/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent4@14% “P3 · DEMO” 8.5b accent4 ctr
- H `2.15,0.36 7.0×0.26`  “20 / DEMO WF-03” 9.5b 64748B
- H `9.33,0.36 3.5×0.26` rr bg=accent4@12% “WF-03 · KẾ TOÁN” 8.5b accent4 ctr
- H `0.5,0.66 12.33×0.62`  “Slide 20 Demo WF-03 — Xem báo cáo (tổng hợp kết quả)” 26b accent4
- H `0.5,1.3 12.33×0.32`  “Cùng một layout cho mọi workflow để người xem dễ theo dõi.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent4@8% “CÂU HỎI HỘI ĐỒNG” 8b accent4 ⏎ “WF-03 có chạy thật, đúng nghiệp vụ, và xử lý lỗi đúng không?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent4@8% “THỜI LƯỢNG” 8b accent4 ⏎ “≈ 2′” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent4@8% “MINH CHỨNG BẮT BUỘC” 8b accent4 ⏎ “Chạy trực tiếp; record ID, trạng thái, log / email” 10.5 tx1
- LEFT: “Scenario: kế toán cần báo cáo cuối tháng.” 12 ‖ “Happy path: đi qua từng bước và màn hình như thiết kế.” 12 ‖ “Exception path: cố ý vi phạm business rule.” 12 ‖ “Minh chứng: trạng thái mới, record ID, khớp test case.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Chiếu video thay cho chạy thật; video chỉ là phương án dự phòng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 1.26×0.8` rr bg=D97706 “Trigger” 10b FFFFFF ctr ⏎ “cuối tháng” 8.5 FFFFFF ctr
  - `6.87,3.45 0.16×0.0` LINE bd=D97706/1.2/solid
  - `7.04,3.05 1.26×0.8` rr bg=accent4@14% “Bộ lọc” 10b accent4 ctr ⏎ “UI-05” 8.5 475569 ctr
  - `8.3,3.45 0.16×0.0` LINE bd=D97706/1.2/solid
  - `8.47,3.05 1.26×0.8` rr bg=accent4@14% “Tổng hợp” 10b accent4 ctr ⏎ “server” 8.5 475569 ctr
  - `9.74,3.45 0.16×0.0` LINE bd=D97706/1.2/solid
  - `9.91,3.05 1.26×0.8` rr bg=accent4@14% “Báo cáo” 10b accent4 ctr ⏎ “UI-06” 8.5 475569 ctr
  - `11.17,3.45 0.16×0.0` LINE bd=D97706/1.2/solid
  - `11.34,3.05 1.26×0.8` rr bg=D97706 “Kết quả” 10b FFFFFF ctr ⏎ “file xuất” 8.5 FFFFFF ctr
  - `5.6,4.05 7.0×0.5` rr bg=475569@10% “TRẠNG THÁI APPROVED (chỉ đọc)” 9.5b 475569
  - `5.6,4.65 7.0×0.65` rr bg=accent6@10% “EXCEPTION Không có dữ liệu trong kỳ → trạng thái empty; không có quyền → 403” 9.5b accent6
  - `5.6,5.4 7.0×0.65` rr bg=accent5@10% “EVIDENCE #R-102 xuất hiện trong báo cáo • số tổng khớp DB • TC12–14” 9.5b accent5
  - `5.6,6.36 7.0×0.26`  “Thay nội dung ví dụ bằng dữ liệu demo cụ thể của nhóm.” 9.5i 64748B

### Slide mẫu 21 (file pptx: trang 25/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent5@14% “P4 · PROOF” 8.5b accent5 ctr
- H `2.15,0.36 7.0×0.26`  “21 / TESTING & VERIFICATION” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 21 Testing — kiểm thử và minh chứng” 26b accent5
- H `0.5,1.3 12.33×0.32`  “Ưu tiên kiểm chứng tính năng chính, state transition, business rule và tích hợp.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent5@8% “CÂU HỎI HỘI ĐỒNG” 8b accent5 ⏎ “Làm sao nhóm biết hệ thống chạy đúng?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent5@8% “THỜI LƯỢNG” 8b accent5 ⏎ “50 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent5@8% “MINH CHỨNG BẮT BUỘC” 8b accent5 ⏎ “Test report, log, CI link; số liệu pass / fail” 10.5 tx1
- LEFT: “Mapping tính năng / BR / state transition → test case.” 12 ‖ “Unit, integration, E2E / UI, UAT — chọn mức phù hợp.” 12 ‖ “Báo pass / fail, bug còn mở và lý do.” 12 ‖ “Minh chứng: test report, log, video, CI link.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Ghi “đã test OK” mà không có kế hoạch và minh chứng kiểm thử.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×0.85` rr bg=accent5@10% “[N]” 22b accent5 ctr ⏎ “test case” 9.5 64748B ctr
  - `8.0,3.05 2.2×0.85` rr bg=accent5@10% “[x]%” 22b accent5 ctr ⏎ “pass” 9.5 64748B ctr
  - `10.4,3.05 2.2×0.85` rr bg=accent5@10% “[k]” 22b accent5 ctr ⏎ “bug còn mở” 9.5 64748B ctr
  - `5.6,4.1 7.0×1.0`  “Level” 9b FFFFFF ⏎ “Evidence” 9b FFFFFF ⏎ “Result” 9b FFFFFF ⏎ “Unit” 10b 1E293B ⏎ “[Assertion / CI report]” 10 1E293B ⏎ “[Pass/Fail]” 10 1E293B ⏎ “Integration” 10b 1E293B ⏎ “[API / DB / contract test]” 10 1E293B ⏎ “[Pass/Fail]” 10 1E293B ⏎ “E2E / UI” 10b 1E293B ⏎ “[Playwright / Cypress • Espresso]” 10 1E293B ⏎ “[Pass/Fail]” 10 1E293B ⏎ “UAT” 10b 1E293B ⏎ “[User scenario + sign-off]” 10 1E293B ⏎ “[Accepted]” 10 1E293B
  - `5.6,6.36 7.0×0.26`  “Android: Espresso / UI Automator. Web: Playwright / Cypress.” 9.5i 64748B

### Slide mẫu 22 (file pptx: trang 26/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent5@14% “P4 · PROOF” 8.5b accent5 ctr
- H `2.15,0.36 7.0×0.26`  “22 / ACHIEVEMENTS” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 22 Achievements — đối chiếu mục tiêu với kết quả” 26b accent5
- H `0.5,1.3 12.33×0.32`  “Kết quả phải đo hoặc kiểm chứng được, không chỉ là tuyên bố đã hoàn thành.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent5@8% “CÂU HỎI HỘI ĐỒNG” 8b accent5 ⏎ “Nhóm đã đạt được những gì đã vàng kết ở phần đầu?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent5@8% “THỜI LƯỢNG” 8b accent5 ⏎ “40 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent5@8% “MINH CHỨNG BẮT BUỘC” 8b accent5 ⏎ “Số đo thật kèm link minh chứng” 10.5 tx1
- LEFT: “Gắn từng mục tiêu với deliverable.” 12 ‖ “Nêu hệ thống đang chạy ở môi trường nào.” 12 ‖ “Chọn metric có cơ sở và nguồn minh chứng.” 12 ‖ “Đính kèm repository, live demo, minh chứng.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Số liệu ước đoán, hoặc tự khẳng định “hoàn hảo”, “100%”.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×2.0` rr bg=FFFFFF bd=E2E8F0/0.8
  - `5.8,3.25 0.45×0.45` oval bg=DB2777 “✓” 13b FFFFFF ctr
  - `5.8,3.85 1.9×0.3`  “OBJECTIVE” 11.5b
  - `5.8,4.2 1.9×0.3`  “[Mục tiêu 1]” 10.5
  - `5.8,4.55 1.9×0.3`  “[Link minh chứng]” 10 64748B
  - `8.0,3.05 2.2×2.0` rr bg=FFFFFF bd=E2E8F0/0.8
  - `8.2,3.25 0.45×0.45` oval bg=F97316 “✓” 13b FFFFFF ctr
  - `8.2,3.85 1.9×0.3`  “IMPLEMENTED” 11.5b
  - `8.2,4.2 1.9×0.3`  “[Tính năng / workflow]” 10.5
  - `8.2,4.55 1.9×0.3`  “[Demo / release]” 10 64748B
  - `10.4,3.05 2.2×2.0` rr bg=FFFFFF bd=E2E8F0/0.8
  - `10.6,3.25 0.45×0.45` oval bg=D97706 “✓” 13b FFFFFF ctr
  - `10.6,3.85 1.9×0.3`  “VALIDATED” 11.5b
  - `10.6,4.2 1.9×0.3`  “[Quality target]” 10.5
  - `10.6,4.55 1.9×0.3`  “[Test report]” 10 64748B
  - `5.6,5.35 7.0×0.6` rr bg=accent4@10% “CHƯA ĐẠT [Chỉ tiêu, thiếu bao nhiêu] → slide 23” 9.5b accent4
  - `5.6,6.36 7.0×0.26`  “Các ô [ ] thay bằng kết quả thực tế, không điền “100%” mặc định.” 9.5i 64748B

### Slide mẫu 23 (file pptx: trang 27/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent5@14% “P4 · PROOF” 8.5b accent5 ctr
- H `2.15,0.36 7.0×0.26`  “23 / LIMITATIONS & NEXT STEPS” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 23 Limitations — trung thực và có hướng cải thiện” 26b accent5
- H `0.5,1.3 12.33×0.32`  “Giới hạn được mô tả bằng tác động và kế hoạch xử lý cụ thể.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent5@8% “CÂU HỎI HỘI ĐỒNG” 8b accent5 ⏎ “Sản phẩm chưa làm được gì, và ảnh hưởng thế nào?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent5@8% “THỜI LƯỢNG” 8b accent5 ⏎ “25 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent5@8% “MINH CHỨNG BẮT BUỘC” 8b accent5 ⏎ “Liên kết tới kết quả test và achievements” 10.5 tx1
- LEFT: “Nêu 2–3 giới hạn có ảnh hưởng thật.” 12 ‖ “Phân loại: product / technology / testing / data.” 12 ‖ “Đánh giá tác động và mức ưu tiên.” 12 ‖ “Đề xuất bước tiếp theo có thể triển khai.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Viết “thiếu thời gian” mà không giải thích hệ quả.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 7.0×1.0`  “Giới hạn” 9.5b FFFFFF ⏎ “Tác động” 9.5b FFFFFF ⏎ “Ưu tiên” 9.5b FFFFFF ⏎ “Next step” 9.5b FFFFFF ⏎ “[Thiếu case biên]” 10.5b 1E293B ⏎ “[Rủi ro lỗi]” 10.5 1E293B ⏎ “Cao” 10.5b DC2626 ctr ⏎ “[Bổ sung test]” 10.5 1E293B ⏎ “Chưa stress test” 10.5b 1E293B ⏎ “Chưa rõ khả năng chịu tải” 10.5 1E293B ⏎ “TB” 10.5b D97706 ctr ⏎ “Benchmark” 10.5 1E293B ⏎ “UX chưa đo” 10.5b 1E293B ⏎ “Chưa tối ưu thao tác” 10.5 1E293B ⏎ “TB” 10.5b D97706 ctr ⏎ “User study” 10.5 1E293B
  - `5.6,6.36 7.0×0.26`  “Ưu tiên giới hạn liên quan tính năng chính thay vì chi tiết trang trí.” 9.5i 64748B

### Slide mẫu 24 (file pptx: trang 28/30)
- H `0.5,0.36 1.5×0.26` rr bg=accent5@14% “P4 · PROOF” 8.5b accent5 ctr
- H `2.15,0.36 7.0×0.26`  “24 / CONCLUSION” 9.5b 64748B
- H `0.5,0.66 12.33×0.62`  “Slide 24 Conclusion — kết lại bằng ba thông điệp” 26b accent5
- H `0.5,1.3 12.33×0.32`  “Không lặp lại các slide trước; chỉ chốt giá trị đã chứng minh.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent5@8% “CÂU HỎI HỘI ĐỒNG” 8b accent5 ⏎ “Hội đồng nên nhớ điều gì sau buổi bảo vệ?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent5@8% “THỜI LƯỢNG” 8b accent5 ⏎ “30 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent5@8% “MINH CHỨNG BẮT BUỘC” 8b accent5 ⏎ “Link demo, repo, Figma” 10.5 tx1
- LEFT: “Nhắc lại problem và người hưởng lợi.” 12 ‖ “Sản phẩm đã xây và các workflow đã demo.” 12 ‖ “Kết quả test / minh chứng nổi bật.” 12 ‖ “Định hướng cải tiến và lời cảm ơn.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Roadmap quá dài, hoặc tuyên bố chưa kiểm chứng.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.7,3.1 0.48×0.48` oval bg=DB2777 “1” 13b FFFFFF ctr
  - `6.4,3.12 5.5×0.26`  “PROBLEM SOLVED” 12.5b
  - `6.4,3.38 5.5×0.24`  “[Vấn đề được giảm bao nhiêu]” 10.5 64748B
  - `5.7,3.85 0.48×0.48` oval bg=D97706 “2” 13b FFFFFF ctr
  - `6.4,3.87 5.5×0.26`  “WORKING PRODUCT” 12.5b
  - `6.4,4.13 5.5×0.24`  “[WF-01..03 hoạt động trong demo]” 10.5 64748B
  - `5.7,4.6 0.48×0.48` oval bg=9D174D “3” 13b FFFFFF ctr
  - `6.4,4.62 5.5×0.26`  “VERIFIED RESULT” 12.5b
  - `6.4,4.88 5.5×0.24`  “[Minh chứng kiểm thử]” 10.5 64748B
  - `5.6,5.6 1.45×0.32` rr bg=accent1@14% “Demo URL” 8.5b accent1 ctr
  - `7.2,5.6 1.45×0.32` rr bg=accent1@14% “Git Repo” 8.5b accent1 ctr
  - `8.8,5.6 1.45×0.32` rr bg=accent1@14% “Final Figma” 8.5b accent1 ctr
  - `5.6,6.36 7.0×0.26`  “Để slide này trên màn hình trong suốt phần Q&A.” 9.5i 64748B

### Slide mẫu 25 (file pptx: trang 29/30)
- H `0.5,0.36 1.5×0.26` rr bg=475569@14% “PHỤ LỤC” 8.5b 475569 ctr
- H `2.15,0.36 7.0×0.26`  “25 / APPENDIX / BACKUP” 9.5b 64748B
- H `9.33,0.36 3.5×0.26` rr bg=accent4@12% “KHÔNG CHIẾU — mở khi bị hỏi” 8.5b accent4 ctr
- H `0.5,0.66 12.33×0.62`  “Slide 25 Appendix — slide dự phòng cho câu hỏi chuyên sâu” 26b 475569
- H `0.5,1.3 12.33×0.32`  “Chi tiết kỹ thuật không đủ thời gian trình bày nhưng hội đồng có thể yêu cầu xem.” 12.5 64748B
- H `0.5,1.76 6.15×0.64` rr bg=accent5@8% “CÂU HỎI HỘI ĐỒNG” 8b accent5 ⏎ “Nếu hội đồng muốn kiểm tra chi tiết, nhóm có sẵn minh chứng không?” 11.5i tx1
- H `6.8,1.76 1.55×0.64` rr bg=accent5@8% “THỜI LƯỢNG” 8b accent5 ⏎ “0 s” 15b tx1
- H `8.5,1.76 4.33×0.64` rr bg=accent5@8% “MINH CHỨNG BẮT BUỘC” 8b accent5 ⏎ “Mỗi slide phụ lục gắn một câu hỏi dự kiến” 10.5 tx1
- LEFT: “Đặt sau Conclusion, đánh mã A1, A2…” 12 ‖ “Activity chi tiết của từng workflow.” 12 ‖ “Đặc tả chi tiết, schema, test case đầy đủ.” 12 ‖ “Phân công người trả lời theo từng phụ lục.” 12 ‖ “TRÁNH” 8.5b accent4 ⏎ “Nhồi chi tiết vào slide chính vì “sợ bị hỏi”.” 10.5 tx1
- PANEL (khung trắng 5.35,2.55 7.48×4.15 là cố định; liệt kê phần bên trong):
  - `5.6,3.05 2.2×1.4` rr bg=accent3@7% “A1 · Activity & màn hình phụ” 10.5b tx1 ⏎ “Chi tiết từng workflow, Figma” 10 64748B
  - `8.0,3.05 2.2×1.4` rr bg=accent3@7% “A2 · Đặc tả use case / SRS” 10.5b tx1 ⏎ “Pre/post, alternative flow” 10 64748B
  - `10.4,3.05 2.2×1.4` rr bg=accent3@7% “A3 · Test case & report” 10.5b tx1 ⏎ “Danh sách TC, log, coverage” 10 64748B
  - `5.6,4.6 2.2×1.4` rr bg=accent3@7% “A4 · Physical schema đầy đủ” 10.5b tx1 ⏎ “Bảng, index, migration” 10 64748B
  - `8.0,4.6 2.2×1.4` rr bg=accent3@7% “A5 · Application design” 10.5b tx1 ⏎ “Layer, module, phụ thuộc” 10 64748B
  - `10.4,4.6 2.2×1.4` rr bg=accent3@7% “A6 · Video demo dự phòng” 10.5b tx1 ⏎ “Khi mạng / thiết bị lỗi” 10 64748B
  - `5.6,6.36 7.0×0.26`  “Phụ lục giúp slide chính gọn mà vẫn trả lời được câu hỏi sâu.” 9.5i 64748B

---

## 6. THỨ TỰ TRANG & CHECKLIST KIỂM TRA ĐỘ KHỚP

| Trang file | Nhãn | Nội dung | Phase |
|---|---|---|---|
| 1 | G1 | Cover | — |
| 2 | G2 | Nguyên tắc chung | — |
| 3 | G3 | Cách chia nội dung | — |
| 4 | G4 | Danh mục slide (24 slide, ≈18–20′) | — |
| 5–10 | 01–06 | Overview, Context, Problem, Proposed Solution, Main Actors, Main Features | P1 · hồng |
| 11–20 | 07–16 | Business Flow, State Machine, System Architecture, Technology Stack, UI/UX Design, Sequence Diagram *(tuỳ chọn)*, Class Design, Database 1/2 *(tuỳ chọn)*, Database 2/2, Traceability | P2 · cam |
| 21–24 | 17–20 | Demo Plan, Demo WF-01, Demo WF-02, Demo WF-03 | P3 · vàng |
| 25–28 | 21–24 | Testing, Achievements, Limitations, Conclusion | P4 · hồng đậm |
| 29 | 25 | Appendix (backup, không chiếu) | Phụ lục · xám |
| 30 | G5 | Checklist rà soát | — |

Thời lượng đã định: Problem ≈ 3.5′ · Design ≈ 6′ · Demo ≈ 6.5′ (≈ 2′ mỗi workflow) · Proof ≈ 2.5′.

**IDE tự kiểm tra trước khi giao:**
- [ ] Mỗi slide đúng 1280×720, không cuộn, không tràn chữ ra ngoài hộp.
- [ ] Header 7 khối (tag, section, tiêu đề, phụ đề, 3 hộp thông tin) đúng toạ độ ở mục 3.1 trên **mọi** slide mẫu.
- [ ] Cột trái có đủ 4 ý đánh số + hộp TRÁNH vàng; khung phải có `MẪU BỐ CỤC` + chú thích italic ở y=6.36.
- [ ] Màu header đúng phase (hồng / cam / vàng / hồng đậm / xám phụ lục).
- [ ] Chỉ dùng token màu mục 1.1; font Calibri (bìa G1 Arial).
- [ ] Không thêm hình minh hoạ, icon, bóng đổ, gradient ngoài khung mẫu.
- [ ] Phần `[ ... ]` được thay bằng dữ liệu thật của đề tài; chú thích cuối panel được cập nhật cho đúng đề tài hoặc giữ nguyên nếu là nhắc chung.


---

## 7. PHỤ LỤC DỮ LIỆU THÔ CHO G1–G5 (toạ độ chính xác từng phần tử)

## [01/30] G1 · Cover (layout DARK)

- `0.6,0.55` `3.9×0.32` roundRect fill=FFFFFF@12% → «GUIDELINE • SOFTWARE PROJECT • V11» [9.0pt bold] c=CBD5E1 al=ctr
- `0.6,1.1` `12.0×1.6` rect nofill → «KHUNG SLIDE CHUẨN» [36.0pt bold] c=FFFFFF ⏎ «CHO ĐỒ ÁN PHÁT TRIỂN PHẦN MỀM» [36.0pt bold] c=FFFFFF
- `0.6,2.95` `11.8×0.7` rect nofill → «Slide là công cụ tổng quan. Phần thiết kế trình bày toàn hệ thống; phần demo tập trung vào các workflow.» [15.0pt] c=CBD5E1
- `0.6,4.15` `2.85×1.5` roundRect fill=FFFFFF@8% ln=334155/0.8 → 
- `0.82,4.33` `0.6×0.4` rect nofill → «01» [20.0pt bold] c=accent1
- `1.45,4.4` `1.9×0.32` rect nofill → «PROBLEM» [14.0pt bold] c=FFFFFF
- `0.82,4.95` `2.45×0.35` rect nofill → «Tại sao làm? Làm gì?» [12.5pt] c=E2E8F0
- `3.65,4.15` `2.85×1.5` roundRect fill=FFFFFF@8% ln=334155/0.8 → 
- `3.87,4.33` `0.6×0.4` rect nofill → «02» [20.0pt bold] c=accent3
- `4.5,4.4` `1.9×0.32` rect nofill → «DESIGN» [14.0pt bold] c=FFFFFF
- `3.87,4.95` `2.45×0.35` rect nofill → «Xây thế nào?» [12.5pt] c=E2E8F0
- `6.7,4.15` `2.85×1.5` roundRect fill=FFFFFF@8% ln=D97706/1.5 → 
- `6.92,4.33` `0.6×0.4` rect nofill → «03» [20.0pt bold] c=accent4
- `7.55,4.4` `1.9×0.32` rect nofill → «DEMO» [14.0pt bold] c=FFFFFF
- `6.92,4.95` `2.45×0.35` rect nofill → «Workflow chạy ra sao?» [12.5pt] c=E2E8F0
- `9.75,4.15` `2.85×1.5` roundRect fill=FFFFFF@8% ln=334155/0.8 → 
- `9.97,4.33` `0.6×0.4` rect nofill → «04» [20.0pt bold] c=accent5
- `10.6,4.4` `1.9×0.32` rect nofill → «PROOF» [14.0pt bold] c=FFFFFF
- `9.97,4.95` `2.45×0.35` rect nofill → «Chứng minh được gì?» [12.5pt] c=E2E8F0
- `0.6,5.95` `3.87×0.42` roundRect fill=DB2777 → «WF-01 · Gửi yêu cầu» [11.0pt bold] c=FFFFFF al=ctr
- `4.67,5.95` `3.87×0.42` roundRect fill=F97316 → «WF-02 · Duyệt yêu cầu» [11.0pt bold] c=FFFFFF al=ctr
- `8.74,5.95` `3.87×0.42` roundRect fill=D97706 → «WF-03 · Xem báo cáo» [11.0pt bold] c=FFFFFF al=ctr
- `0.6,6.6` `11.0×0.3` rect nofill → «Dùng cho đồ án môn học và capstone: Web • Mobile • Desktop • AI-enabled Software» [10.5pt italic] c=94A3B8
- `11.83,6.98` `1.0×0.3` rect nofill → «G1» [10.0pt bold] c=94A3B8 al=r


## [02/30] G2 · Nguyên tắc chung

- `0.5,0.36` `9.0×0.26` rect nofill → «NGUYÊN TẮC CHUNG» [9.5pt bold] c=64748B
- `0.5,0.66` `12.33×0.62` rect nofill → «Slide là công cụ tổng quan: thiết kế tổng thể, demo theo workflow» [26.0pt bold] c=tx1 al=l
- `0.5,1.3` `12.33×0.32` rect nofill → «Tài liệu kỹ thuật (SRS, SDD, test report) nằm ở phụ lục và báo cáo; slide chỉ chọn điều hội đồng cần thấy.» [12.5pt] c=64748B
- `11.83,6.98` `1.0×0.3` rect nofill → «G2» [10.0pt bold] c=000000 al=r
- `0.5,1.9` `2.93×2.75` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `0.75,2.15` `0.5×0.5` ellipse fill=DB2777 → «1» [14.0pt bold] c=FFFFFF al=ctr
- `0.75,2.85` `2.45×0.4` rect nofill → «Một slide = một thông điệp» [15.0pt bold] c=000000
- `0.75,3.3` `2.45×1.3` rect nofill → «Tiêu đề là câu kết luận. Mỗi phần trả lời một câu hỏi của hội đồng; không liệt kê tính năng rời rạc.» [11.5pt] c=475569
- `3.63,1.9` `2.93×2.75` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `3.88,2.15` `0.5×0.5` ellipse fill=EA580C → «2» [14.0pt bold] c=FFFFFF al=ctr
- `3.88,2.85` `2.45×0.4` rect nofill → «Thiết kế cho tổng thể» [15.0pt bold] c=000000
- `3.88,3.3` `2.45×1.3` rect nofill → «Phần Design mô tả toàn hệ thống bằng các sơ đồ tổng quan. Không trình bày thiết kế riêng cho từng workflow.» [11.5pt] c=475569
- `6.76,1.9` `2.93×2.75` roundRect fill=FFFFFF ln=D97706/1.5 → 
- `7.01,2.15` `0.5×0.5` ellipse fill=D97706 → «3» [14.0pt bold] c=FFFFFF al=ctr
- `7.01,2.85` `2.45×0.4` rect nofill → «Demo theo workflow» [15.0pt bold] c=000000
- `7.01,3.3` `2.45×1.3` rect nofill → «Chọn 2–4 workflow lõi. Mỗi workflow một slide demo: actor, trigger, các bước, kết quả, ngoại lệ, minh chứng.» [11.5pt] c=475569
- `9.89,1.9` `2.93×2.75` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `10.14,2.15` `0.5×0.5` ellipse fill=9D174D → «4» [14.0pt bold] c=FFFFFF al=ctr
- `10.14,2.85` `2.45×0.4` rect nofill → «Có minh chứng» [15.0pt bold] c=000000
- `10.14,3.3` `2.45×1.3` rect nofill → «Số liệu, ảnh, link demo, test report. Chi tiết kỹ thuật để ở phụ lục, mở khi hội đồng hỏi.» [11.5pt] c=475569
- `0.5,4.9` `8.0×0.25` rect nofill → «CẤU TRÚC MỖI SLIDE MẪU» [9.0pt bold] c=64748B
- `0.5,5.25` `1.92×0.95` roundRect fill=accent1@8% → «Câu hỏi hội đồng» [11.5pt bold] c=tx1 al=l ⏎ «slide trả lời câu gì» [10.0pt] c=64748B al=l
- `2.57,5.25` `1.92×0.95` roundRect fill=accent1@8% → «Thời lượng» [11.5pt bold] c=tx1 al=l ⏎ «ngân sách thời gian» [10.0pt] c=64748B al=l
- `4.64,5.25` `1.92×0.95` roundRect fill=accent1@8% → «Minh chứng» [11.5pt bold] c=tx1 al=l ⏎ «phải có trên slide» [10.0pt] c=64748B al=l
- `6.71,5.25` `1.92×0.95` roundRect fill=accent1@8% → «Nội dung» [11.5pt bold] c=tx1 al=l ⏎ «4 ý cần trình bày» [10.0pt] c=64748B al=l
- `8.78,5.25` `1.92×0.95` roundRect fill=accent1@8% → «Tránh» [11.5pt bold] c=tx1 al=l ⏎ «lỗi hay gặp» [10.0pt] c=64748B al=l
- `10.85,5.25` `1.92×0.95` roundRect fill=accent1@8% → «Mẫu bố cục» [11.5pt bold] c=tx1 al=l ⏎ «gợi ý hình / bảng» [10.0pt] c=64748B al=l


## [03/30] G3 · Cách chia nội dung

- `0.5,0.36` `9.0×0.26` rect nofill → «CÁCH PHÂN CHIA NỘI DUNG» [9.5pt bold] c=64748B
- `0.5,0.66` `12.33×0.62` rect nofill → «Thiết kế cho tổng thể, demo cho workflow» [26.0pt bold] c=tx1 al=l
- `0.5,1.3` `12.33×0.32` rect nofill → «Mỗi phần có một vai trò riêng; không lặp lại chi tiết từng workflow ở phần Design.» [12.5pt] c=64748B
- `11.83,6.98` `1.0×0.3` rect nofill → «G3» [10.0pt bold] c=000000 al=r
- `0.5,1.9` `6.05×3.95` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `0.5,1.9` `6.05×0.58` roundRect fill=EA580C → «DESIGN — TOÀN HỆ THỐNG» [13.0pt bold] c=FFFFFF al=l
- `0.75,2.6` `5.6×0.3` rect nofill → «Trả lời: hệ thống được xây như thế nào?» [12.5pt italic] c=475569
- `0.75,3.05` `2.7×0.76` roundRect fill=accent3@8% → «Slide 07» [9.5pt bold] c=accent3 al=l ⏎ «Business Flow» [12.0pt bold] c=tx1 al=l
- `3.6,3.05` `2.7×0.76` roundRect fill=accent3@8% → «Slide 08» [9.5pt bold] c=accent3 al=l ⏎ «State machine» [12.0pt bold] c=tx1 al=l
- `0.75,3.93` `2.7×0.76` roundRect fill=accent3@8% → «Slide 09» [9.5pt bold] c=accent3 al=l ⏎ «System architecture» [12.0pt bold] c=tx1 al=l
- `3.6,3.93` `2.7×0.76` roundRect fill=accent3@8% → «Slide 11» [9.5pt bold] c=accent3 al=l ⏎ «UI/UX tổng thể» [12.0pt bold] c=tx1 al=l
- `0.75,4.81` `2.7×0.76` roundRect fill=accent3@8% → «Slide 13» [9.5pt bold] c=accent3 al=l ⏎ «Class design» [12.0pt bold] c=tx1 al=l
- `3.6,4.81` `2.7×0.76` roundRect fill=accent3@8% → «Slide 14–15» [9.5pt bold] c=accent3 al=l ⏎ «Database design» [12.0pt bold] c=tx1 al=l
- `6.78,1.9` `6.05×3.95` roundRect fill=FFFFFF ln=D97706/1.5 → 
- `6.78,1.9` `6.05×0.58` roundRect fill=D97706 → «DEMO — THEO TỪNG WORKFLOW» [13.0pt bold] c=FFFFFF al=l
- `7.03,2.6` `5.6×0.3` rect nofill → «Trả lời: từng workflow chạy thật ra sao?» [12.5pt italic] c=475569
- `7.03,3.05` `1.95×0.76` roundRect fill=DB2777 → «WF-01» [12.0pt bold] c=FFFFFF al=ctr ⏎ «Gửi yêu cầu» [10.0pt] c=FFFFFF al=ctr
- `9.08,3.05` `3.5×0.76` roundRect fill=accent1@8% → «Slide 18» [9.5pt bold] c=accent1 al=l ⏎ «Trigger → các bước → kết quả + ngoại lệ» [11.0pt] c=tx1 al=l
- `7.03,3.93` `1.95×0.76` roundRect fill=F97316 → «WF-02» [12.0pt bold] c=FFFFFF al=ctr ⏎ «Duyệt yêu cầu» [10.0pt] c=FFFFFF al=ctr
- `9.08,3.93` `3.5×0.76` roundRect fill=accent2@8% → «Slide 19» [9.5pt bold] c=accent2 al=l ⏎ «Trigger → các bước → kết quả + ngoại lệ» [11.0pt] c=tx1 al=l
- `7.03,4.81` `1.95×0.76` roundRect fill=D97706 → «WF-03» [12.0pt bold] c=FFFFFF al=ctr ⏎ «Xem báo cáo» [10.0pt] c=FFFFFF al=ctr
- `9.08,4.81` `3.5×0.76` roundRect fill=accent4@8% → «Slide 20» [9.5pt bold] c=accent4 al=l ⏎ «Trigger → các bước → kết quả + ngoại lệ» [11.0pt] c=tx1 al=l
- `0.5,6.05` `12.33×0.55` roundRect fill=accent4@12% → «Quy tắc: chọn 2–4 workflow lõi để demo, ghép thành một câu chuyện liền mạch; chi tiết từng workflow chỉ xuất hiện ở phần Demo.» [12.0pt bold] c=accent4 al=l


## [04/30] G4 · Danh mục slide

- `0.5,0.36` `9.0×0.26` rect nofill → «DANH MỤC SLIDE / VERSION 11» [9.5pt bold] c=64748B
- `0.5,0.66` `12.33×0.62` rect nofill → «24 slide nội dung, 4 phần, ≈ 18–20 phút — demo chiếm 1/3» [26.0pt bold] c=tx1 al=l
- `0.5,1.3` `12.33×0.32` rect nofill → «(*) = gộp hoặc đưa vào phụ lục khi thiếu thời gian.» [12.5pt] c=64748B
- `11.83,6.98` `1.0×0.3` rect nofill → «G4» [10.0pt bold] c=000000 al=r
- `0.5,1.85` `2.93×3.95` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `0.5,1.85` `2.93×0.55` roundRect fill=DB2777 → «P1 PROBLEM · ≈ 3.5′» [12.0pt bold] c=FFFFFF al=l
- `0.65,2.52` `2.7×3.2` rect nofill → «01 Overview» [11.0pt] c=334155 ⏎ «02 Context» [11.0pt] c=334155 ⏎ «03 Problem» [11.0pt] c=334155 ⏎ «04 Proposed Solution» [11.0pt] c=334155 ⏎ «05 Main Actors» [11.0pt] c=334155 ⏎ «06 Main Features» [11.0pt] c=334155
- `3.63,1.85` `2.93×3.95` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `3.63,1.85` `2.93×0.55` roundRect fill=EA580C → «P2 DESIGN · ≈ 6′» [12.0pt bold] c=FFFFFF al=l
- `3.78,2.52` `2.7×3.2` rect nofill → «07 Business Flow» [11.0pt] c=334155 ⏎ «08 State Machine» [11.0pt] c=334155 ⏎ «09 System Architecture» [11.0pt] c=334155 ⏎ «10 Technology Stack» [11.0pt] c=334155 ⏎ «11 UI/UX Design» [11.0pt] c=334155 ⏎ «12 Sequence Diagram *» [11.0pt] c=334155 ⏎ «13 Class Design» [11.0pt] c=334155 ⏎ «14 Database Conceptual *» [11.0pt] c=334155 ⏎ «15 Database Logical/Physical» [11.0pt] c=334155 ⏎ «16 Traceability» [11.0pt] c=334155
- `6.76,1.85` `2.93×3.95` roundRect fill=FFFFFF ln=D97706/1.5 → 
- `6.76,1.85` `2.93×0.55` roundRect fill=D97706 → «P3 DEMO · ≈ 6.5′» [12.0pt bold] c=FFFFFF al=l
- `6.91,2.52` `2.7×3.2` rect nofill → «17 Demo Plan» [11.0pt] c=334155 ⏎ «18 Demo WF-01» [11.0pt] c=334155 ⏎ «19 Demo WF-02» [11.0pt] c=334155 ⏎ «20 Demo WF-03» [11.0pt] c=334155
- `9.89,1.85` `2.93×3.95` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `9.89,1.85` `2.93×0.55` roundRect fill=9D174D → «P4 PROOF · ≈ 2.5′» [12.0pt bold] c=FFFFFF al=l
- `10.04,2.52` `2.7×3.2` rect nofill → «21 Testing» [11.0pt] c=334155 ⏎ «22 Achievements» [11.0pt] c=334155 ⏎ «23 Limitations» [11.0pt] c=334155 ⏎ «24 Conclusion» [11.0pt] c=334155
- `0.5,5.98` `6.0×0.22` rect nofill → «NGÂN SÁCH THỜI GIAN» [9.0pt bold] c=64748B
- `0.5,6.25` `2.29×0.36` rect fill=DB2777 → «PROBLEM 3.5′» [9.5pt bold] c=FFFFFF al=ctr
- `2.83,6.25` `3.96×0.36` rect fill=EA580C → «DESIGN 6′» [9.5pt bold] c=FFFFFF al=ctr
- `6.83,6.25` `4.29×0.36` rect fill=D97706 → «DEMO 6.5′» [9.5pt bold] c=FFFFFF al=ctr
- `11.16,6.25` `1.63×0.36` rect fill=9D174D → «PROOF 2.5′» [9.5pt bold] c=FFFFFF al=ctr
- `0.5,6.68` `11.2×0.28` rect nofill → «Chỉ có 15′? Gộp 02 với 03, 14 vào 15; đưa 12 vào phụ lục; demo 2 workflow. Sau Conclusion: 25 Phụ lục (backup).» [9.5pt italic] c=64748B


## [30/30] G5 · Checklist

- `0.5,0.36` `9.0×0.26` rect nofill → «QUALITY GATE» [9.5pt bold] c=64748B
- `0.5,0.66` `12.33×0.62` rect nofill → «Checklist rà soát trước khi bảo vệ» [26.0pt bold] c=tx1 al=l
- `0.5,1.3` `12.33×0.32` rect nofill → «Tự kiểm tra tính nhất quán của thiết kế và mức sẵn sàng của demo.» [12.5pt] c=64748B
- `11.83,6.98` `1.0×0.3` rect nofill → «G5» [10.0pt bold] c=000000 al=r
- `0.5,1.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `0.72,2.12` `0.42×0.42` ellipse fill=DB2777 → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `1.3,2.18` `2.0×0.3` rect nofill → «PROBLEM» [12.5pt bold] c=000000
- `0.72,2.7` `2.5×0.9` rect nofill → «Vấn đề có minh chứng, user rõ ràng?» [11.5pt] c=475569
- `3.63,1.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `3.85,2.12` `0.42×0.42` ellipse fill=DB2777 → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `4.43,2.18` `2.0×0.3` rect nofill → «FEATURES» [12.5pt bold] c=000000
- `3.85,2.7` `2.5×0.9` rect nofill → «Tính năng chính nhóm theo nghiệp vụ, gắn với vấn đề?» [11.5pt] c=475569
- `6.76,1.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `6.98,2.12` `0.42×0.42` ellipse fill=EA580C → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `7.56,2.18` `2.0×0.3` rect nofill → «DESIGN» [12.5pt bold] c=000000
- `6.98,2.7` `2.5×0.9` rect nofill → «Business flow, state, UI, class, DB khớp nhau và khớp code?» [11.5pt] c=475569
- `9.89,1.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `10.11,2.12` `0.42×0.42` ellipse fill=EA580C → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `10.69,2.18` `2.0×0.3` rect nofill → «TRACEABILITY» [12.5pt bold] c=000000
- `10.11,2.7` `2.5×0.9` rect nofill → «Mỗi feature nối được Screen → Class → DB → Test?» [11.5pt] c=475569
- `0.5,3.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `0.72,4.12` `0.42×0.42` ellipse fill=D97706 → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `1.3,4.18` `2.0×0.3` rect nofill → «DEMO WORKFLOW» [12.5pt bold] c=000000
- `0.72,4.7` `2.5×0.9` rect nofill → «2–4 workflow lõi có trigger, kết quả; chạy thật, có nhánh ngoại lệ?» [11.5pt] c=475569
- `3.63,3.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `3.85,4.12` `0.42×0.42` ellipse fill=D97706 → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `4.43,4.18` `2.0×0.3` rect nofill → «DEMO DATA» [12.5pt bold] c=000000
- `3.85,4.7` `2.5×0.9` rect nofill → «Seed data, tài khoản theo actor, script reset, video dự phòng?» [11.5pt] c=475569
- `6.76,3.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `6.98,4.12` `0.42×0.42` ellipse fill=9D174D → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `7.56,4.18` `2.0×0.3` rect nofill → «TESTS» [12.5pt bold] c=000000
- `6.98,4.7` `2.5×0.9` rect nofill → «Test theo tính năng / BR / state; có report và kết quả?» [11.5pt] c=475569
- `9.89,3.9` `2.93×1.8` roundRect fill=FFFFFF ln=E2E8F0/0.8 → 
- `10.11,4.12` `0.42×0.42` ellipse fill=9D174D → «✓» [13.0pt bold] c=FFFFFF al=ctr
- `10.69,4.18` `2.0×0.3` rect nofill → «OUTCOME» [12.5pt bold] c=000000
- `10.11,4.7` `2.5×0.9` rect nofill → «Kết quả và giới hạn được phát biểu có cơ sở?» [11.5pt] c=475569
- `0.5,6.05` `12.33×0.5` roundRect fill=2B1418 → «TRUY VẾT: Problem → Feature → Design tổng thể → Demo workflow → Test → Achievements» [11.0pt bold] c=FDE68A al=l