# -*- coding: utf-8 -*-
"""
slide_definitions.py - All content definitions for EventHub PRM393 ASM Group 4
Strictly aligned with Slide_Template_Spec_CamVangHong.md
"""

def get_slide_definitions():
    slides = []

    # -------------------------------------------------------------------------
    # SLIDE 01 · OVERVIEW
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-01",
        "page_id": "01",
        "phase_tag": "P1 · PROBLEM",
        "phase_color": "var(--accent1)",
        "phase_bg": "rgba(219,39,119,0.14)",
        "box_bg": "rgba(219,39,119,0.08)",
        "section_str": "01 / OVERVIEW",
        "slide_num_str": "Slide 1",
        "title_rest": "Overview — giới thiệu dự án trong 30 giây",
        "subtitle": "Tạo bức tranh tổng thể và cho hội đồng thấy sản phẩm thật ngay từ đầu.",
        "pill_right": None,
        "question": "Đây là sản phẩm gì, cho ai, và đã chạy được chưa?",
        "duration": "30 s",
        "evidence": "Ảnh hoặc GIF sản phẩm đang chạy trên thiết bị thật",
        "left_items": [
            "Tên đề tài: EventHub — Hệ thống quản lý sự kiện và điểm danh QR liên vai trò.",
            "Một câu mô tả: Kết nối sinh viên với CLB, tự động hóa quy trình đăng ký, duyệt đơn và check-in thời gian thực.",
            "Đối tượng & giá trị: Sinh viên FPTU (tiếp cận sự kiện, đăng ký an toàn), Trưởng CLB (quản lý, điểm danh QR).",
            "Nhóm thực hiện: Group 4 — PRM393 Mobile Programming (FPT University)."
        ],
        "avoid_text": "Tên đề tài quá dài, chung chung, hoặc chỉ là danh sách công nghệ.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; gap: 20px; height: 100%;">
            <!-- Left Info Block -->
            <div style="flex: 1.1; display: flex; flex-direction: column; justify-content: space-between;">
              <div>
                <div style="display: inline-block; background: rgba(217,119,6,0.14); color: var(--accent4); font-size: 11.3px; font-weight: 700; padding: 4px 10px; border-radius: 9999px; margin-bottom: 8px;">PROJECT NAME</div>
                <div style="font-size: 26px; font-weight: 700; color: var(--tx1); line-height: 1.2;">EventHub Platform</div>
                <div style="font-size: 14.5px; color: var(--muted); margin-top: 6px; line-height: 1.35;">Nền tảng quản lý sự kiện và điểm danh QR realtime liên thiết bị (Mobile App + Web Admin).</div>
              </div>

              <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-top: 14px;">
                <div style="background: rgba(219,39,119,0.08); border-radius: 6px; padding: 10px 8px;">
                  <div style="font-size: 12.6px; font-weight: 700; color: var(--accent1);">USERS</div>
                  <div style="font-size: 12.5px; color: var(--slate-600); margin-top: 4px; line-height: 1.25;">Sinh viên FPTU & Trưởng CLB</div>
                </div>
                <div style="background: rgba(249,115,22,0.08); border-radius: 6px; padding: 10px 8px;">
                  <div style="font-size: 12.6px; font-weight: 700; color: var(--accent2);">VALUE</div>
                  <div style="font-size: 12.5px; color: var(--slate-600); margin-top: 4px; line-height: 1.25;">Điểm danh QR &lt;3s, chống lặp</div>
                </div>
                <div style="background: rgba(217,119,6,0.08); border-radius: 6px; padding: 10px 8px;">
                  <div style="font-size: 12.6px; font-weight: 700; color: var(--accent4);">PLATFORM</div>
                  <div style="font-size: 12.5px; color: var(--slate-600); margin-top: 4px; line-height: 1.25;">Flutter Android &amp; Flutter Web</div>
                </div>
              </div>
            </div>

            <!-- Right Screenshot Container -->
            <div style="flex: 0.9; background: var(--slate-100); border: 1.5px dashed var(--slate-300); border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; overflow: hidden; position: relative;">
              <img src="../evidence/discover_screen.png" alt="EventHub Live App" style="width: 100%; height: 100%; object-fit: cover; object-position: top;" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
              <div style="display: none; width: 100%; height: 100%; flex-direction: column; align-items: center; justify-content: center; padding: 16px; text-align: center;">
                <div style="font-size: 16px; font-weight: 700; color: var(--muted); margin-bottom: 6px;">ẢNH / GIF SẢN PHẨM THẬT</div>
                <div style="font-size: 13px; color: var(--slate-600);">Mobile App Discover Screen &amp; Web Admin Review Queue</div>
              </div>
            </div>
          </div>
        """,
        "panel_note": "Dùng ảnh sản phẩm thật; hệ thống đã chạy thực tế trên Android 10+ và Firebase Hosting.",
        "footer_page": "01"
    })

    # -------------------------------------------------------------------------
    # SLIDE 02 · CONTEXT
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-02",
        "page_id": "02",
        "phase_tag": "P1 · PROBLEM",
        "phase_color": "var(--accent1)",
        "phase_bg": "rgba(219,39,119,0.14)",
        "box_bg": "rgba(219,39,119,0.08)",
        "section_str": "02 / CONTEXT",
        "slide_num_str": "Slide 2",
        "title_rest": "Context — bối cảnh và hiện trạng",
        "subtitle": "Đặt vấn đề bằng tình huống thực tế, không bắt đầu từ công nghệ.",
        "pill_right": None,
        "question": "Đề tài ra đời trong bối cảnh nào, công việc hiện được thực hiện ra sao?",
        "duration": "30 s",
        "evidence": "Mô tả hiện trạng, quy trình 4 bước thủ công của các CLB sinh viên",
        "left_items": [
            "Môi trường: Đại học FPT với 50+ CLB hoạt động sôi nổi và hàng trăm workshop mỗi kỳ.",
            "Quy trình hiện tại: CLB phát link Google Form, xuất file Excel, in danh sách giấy tại bàn đón tiếp.",
            "Người liên quan: Sinh viên (tìm link rời rạc trên Facebook/Zalo), Ban chủ nhiệm CLB (nhập Excel thủ công).",
            "Nhu cầu cấp thiết: Số hóa quản lý sự kiện, đồng bộ realtime và kiểm soát sức chứa hội trường."
        ],
        "avoid_text": "Kể quá nhiều bối cảnh, hoặc bắt đầu bằng công nghệ.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px;">
              <div style="background: rgba(219,39,119,0.10); border-radius: 6px; padding: 12px;">
                <div style="font-size: 13.3px; font-weight: 700; color: var(--accent1); margin-bottom: 4px;">MÔI TRƯỜNG</div>
                <div style="font-size: 14px; color: var(--slate-600); line-height: 1.3;">ĐH FPT (50+ CLB sinh viên, quy mô ~15.000 sinh viên)</div>
              </div>
              <div style="background: rgba(249,115,22,0.10); border-radius: 6px; padding: 12px;">
                <div style="font-size: 13.3px; font-weight: 700; color: var(--accent2); margin-bottom: 4px;">NGƯỜI LIÊN QUAN</div>
                <div style="font-size: 14px; color: var(--slate-600); line-height: 1.3;">Sinh viên tham gia, Ban chủ nhiệm CLB, CTV hỗ trợ</div>
              </div>
              <div style="background: rgba(234,88,12,0.10); border-radius: 6px; padding: 12px;">
                <div style="font-size: 13.3px; font-weight: 700; color: var(--accent3); margin-bottom: 4px;">CÔNG CỤ HIỆN TẠI</div>
                <div style="font-size: 14px; color: var(--slate-600); line-height: 1.3;">Google Forms, Google Sheets, Danh sách in giấy A4</div>
              </div>
            </div>

            <div>
              <div style="font-size: 11.3px; font-weight: 700; color: var(--muted); margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px;">QUY TRÌNH HIỆN TẠI</div>
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
                <div style="flex: 1; height: 56px; background: var(--slate-100); border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 13.5px; font-weight: 700; color: var(--slate-600); text-align: center; padding: 4px;">1. Đăng link MXH</div>
                <div style="color: var(--slate-400); font-weight: 700;">→</div>
                <div style="flex: 1; height: 56px; background: var(--slate-100); border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 13.5px; font-weight: 700; color: var(--slate-600); text-align: center; padding: 4px;">2. Điền Google Form</div>
                <div style="color: var(--slate-400); font-weight: 700;">→</div>
                <div style="flex: 1; height: 56px; background: var(--slate-100); border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 13.5px; font-weight: 700; color: var(--slate-600); text-align: center; padding: 4px;">3. Lọc Excel thủ công</div>
                <div style="color: var(--slate-400); font-weight: 700;">→</div>
                <div style="flex: 1; height: 56px; background: var(--slate-100); border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 13.5px; font-weight: 700; color: var(--slate-600); text-align: center; padding: 4px;">4. Dò tên trên giấy</div>
              </div>
            </div>

            <div style="background: rgba(100,116,139,0.10); border-radius: 6px; padding: 10px 14px; font-size: 13px; font-weight: 700; color: var(--slate-600);">
              HIỆN TRẠNG: Thời gian check-in trung bình 45–60 giây/người • Tỷ lệ sai lệch danh sách &gt;15% • Quá tải sức chứa hội trường.
            </div>
          </div>
        """,
        "panel_note": "Chỉ mô tả hiện trạng; vấn đề và hậu quả được nêu chi tiết ở slide 03.",
        "footer_page": "02"
    })

    # -------------------------------------------------------------------------
    # SLIDE 03 · PROBLEM
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-03",
        "page_id": "03",
        "phase_tag": "P1 · PROBLEM",
        "phase_color": "var(--accent1)",
        "phase_bg": "rgba(219,39,119,0.14)",
        "box_bg": "rgba(219,39,119,0.08)",
        "section_str": "03 / PROBLEM",
        "slide_num_str": "Slide 3",
        "title_rest": "Problem — vấn đề và hậu quả",
        "subtitle": "Nêu các điểm nghẽn có nguyên nhân cụ thể và hậu quả có thể đo được.",
        "pill_right": None,
        "question": "Vấn đề có thật không, và gây hậu quả gì?",
        "duration": "40 s",
        "evidence": "Số liệu phỏng vấn 120 sinh viên & 15 chủ nhiệm CLB Đại học FPT",
        "left_items": [
            "Pain point 1: Ùn tắc tại bàn đón tiếp do dò tên thủ công trên giấy A4 hoặc Excel.",
            "Pain point 2: Đăng ký vượt sức chứa hội trường vì Google Form không khóa giới hạn realtime.",
            "Pain point 3: Sinh viên mù thông tin xét duyệt, không rõ lý do bị từ chối đơn đăng ký.",
            "Minh chứng thực tế: 78% sinh viên phàn nàn về xếp hàng check-in; 65% CLB từng gặp sự cố quá tải."
        ],
        "avoid_text": "Biến slide này thành mô tả giải pháp.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <!-- Headers -->
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px;">
              <div style="background: rgba(220,38,38,0.14); color: var(--accent6); font-size: 12px; font-weight: 700; text-align: center; padding: 6px; border-radius: 4px;">PAIN POINT</div>
              <div style="background: rgba(217,119,6,0.14); color: var(--accent4); font-size: 12px; font-weight: 700; text-align: center; padding: 6px; border-radius: 4px;">NGUYÊN NHÂN</div>
              <div style="background: rgba(219,39,119,0.14); color: var(--accent1); font-size: 12px; font-weight: 700; text-align: center; padding: 6px; border-radius: 4px;">IMPACT (HẬU QUẢ)</div>
            </div>

            <!-- Row 1 -->
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: center;">
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Ùn tắc bàn check-in</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Dò giấy / Excel thủ công</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--accent6); font-weight: 700; text-align: center;">Chậm 45–60s/người, trễ sự kiện</div>
            </div>

            <!-- Row 2 -->
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: center;">
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Vượt sức chứa hội trường</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Form không khóa realtime</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--accent6); font-weight: 700; text-align: center;">Vỡ kế hoạch, từ chối tại cửa</div>
            </div>

            <!-- Row 3 -->
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: center;">
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Mù thông tin xét duyệt</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Gửi email rời rạc, thất lạc</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--accent6); font-weight: 700; text-align: center;">Sinh viên bức xúc, CLB khó giải trình</div>
            </div>

            <!-- Evidence Box -->
            <div style="background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent2); margin-bottom: 2px;">MINH CHỨNG KHẢO SÁT THỰC TẾ</div>
              <div style="font-size: 13.5px; color: var(--tx1); line-height: 1.35;">78% sinh viên phàn nàn về thời gian chờ check-in • 65% CLB từng gặp sự cố quá tải số chỗ • Nguồn khảo sát: 120 sinh viên &amp; 15 CLB FPTU (Học kỳ Fall 2026).</div>
            </div>
          </div>
        """,
        "panel_note": "Mỗi pain point ở đây được giải pháp ở slide 04 trả lời trực tiếp.",
        "footer_page": "03"
    })

    # -------------------------------------------------------------------------
    # SLIDE 04 · PROPOSED SOLUTION
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-04",
        "page_id": "04",
        "phase_tag": "P1 · PROBLEM",
        "phase_color": "var(--accent1)",
        "phase_bg": "rgba(219,39,119,0.14)",
        "box_bg": "rgba(219,39,119,0.08)",
        "section_str": "04 / PROPOSED SOLUTION",
        "slide_num_str": "Slide 4",
        "title_rest": "Proposed Solution — giải quyết trực tiếp vấn đề",
        "subtitle": "Thể hiện quan hệ Pain point → Solution → Value, và phạm vi MVP.",
        "pill_right": None,
        "question": "Giải pháp có trúng vấn đề không, phạm vi làm tới đâu?",
        "duration": "40 s",
        "evidence": "Bảng ánh xạ pain point ↔ solution ↔ deliverable",
        "left_items": [
            "Giải pháp tổng thể: Nền tảng EventHub Serverless Realtime đồng bộ Mobile App và Web Admin.",
            "Ánh xạ giải pháp: Quét QR băm SHA-256 (&lt;3s/người), Firestore Atomic Transaction khóa chỗ, Review Queue tức thì.",
            "Điểm khác biệt: 0 máy chủ trung gian, 100% Security Rules thực thi phân quyền và tính toàn vẹn dữ liệu.",
            "Phạm vi thực hiện: MVP In-Scope (Mobile Android, Web Trưởng CLB, Web Admin) vs Out-of-Scope (Cổng thanh toán vé)."
        ],
        "avoid_text": "Gọi “AI”, “microservices” là giá trị khi chưa chỉ ra lợi ích.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <!-- Header Grid -->
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px;">
              <div style="background: rgba(220,38,38,0.14); color: var(--accent6); font-size: 12px; font-weight: 700; text-align: center; padding: 6px; border-radius: 4px;">PAIN POINT</div>
              <div style="background: rgba(219,39,119,0.14); color: var(--accent1); font-size: 12px; font-weight: 700; text-align: center; padding: 6px; border-radius: 4px;">SOLUTION (EVENTHUB)</div>
              <div style="background: rgba(249,115,22,0.14); color: var(--accent2); font-size: 12px; font-weight: 700; text-align: center; padding: 6px; border-radius: 4px;">EXPECTED VALUE</div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: center;">
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Ùn tắc check-in</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--accent1); font-weight: 700; text-align: center;">Quét QR băm SHA-256</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Check-in &lt;3s, chống lặp</div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: center;">
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Vượt quá sức chứa</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--accent1); font-weight: 700; text-align: center;">Atomic Transaction Rules</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">100% không vượt capacity</div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: center;">
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Mù thông tin xét duyệt</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--accent1); font-weight: 700; text-align: center;">Review Queue + Push FCM</div>
              <div style="background: #FFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px; font-size: 13px; color: var(--slate-600); text-align: center;">Minh bạch lý do tức thời</div>
            </div>

            <!-- In-scope vs Out-of-scope -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
              <div style="background: rgba(249,115,22,0.10); border-radius: 6px; padding: 10px 14px;">
                <div style="font-size: 12.6px; font-weight: 700; color: var(--accent2); margin-bottom: 2px;">IN-SCOPE (MVP HOÀN CHỈNH)</div>
                <div style="font-size: 13px; color: var(--tx1); line-height: 1.3;">Mobile App (Khám phá, Đăng ký, Lịch, Quét QR, Báo cáo PDF) · Web Admin (Duyệt đơn, Phát QR, Quản trị sự kiện).</div>
              </div>
              <div style="background: var(--slate-100); border-radius: 6px; padding: 10px 14px;">
                <div style="font-size: 12.6px; font-weight: 700; color: var(--muted); margin-bottom: 2px;">OUT-OF-SCOPE</div>
                <div style="font-size: 13px; color: var(--slate-600); line-height: 1.3;">Cổng thanh toán vé có phí (để phase sau vì quy chế sự kiện sinh viên FPTU hiện tại là miễn phí).</div>
              </div>
            </div>
          </div>
        """,
        "panel_note": "3 Pain points được giải quyết triệt để bằng 3 cơ chế kiến trúc không máy chủ.",
        "footer_page": "04"
    })

    # -------------------------------------------------------------------------
    # SLIDE 05 · MAIN ACTORS
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-05",
        "page_id": "05",
        "phase_tag": "P1 · PROBLEM",
        "phase_color": "var(--accent1)",
        "phase_bg": "rgba(219,39,119,0.14)",
        "box_bg": "rgba(219,39,119,0.08)",
        "section_str": "05 / MAIN ACTORS",
        "slide_num_str": "Slide 5",
        "title_rest": "Main Actors — các tác nhân chính của hệ thống",
        "subtitle": "Mô tả những ai tương tác với hệ thống: họ là ai và được làm gì.",
        "pill_right": None,
        "question": "Ai dùng hệ thống, họ là ai, và mỗi vai trò được làm gì?",
        "duration": "30 s",
        "evidence": "Danh sách actor khớp 100% phân quyền users/{uid}.role trong Security Rules",
        "left_items": [
            "3 Actor con người tương ứng với 3 role trong Firestore: user, staff, admin.",
            "1 Hệ thống ngoài: Firebase Suite (Auth, Firestore, Cloud Messaging, Remote Config).",
            "Quyền hạn và ranh giới bảo mật được kiểm soát trực tiếp bởi firestore.rules.",
            "Role Gate: Chặn chéo tài khoản tại cổng đăng nhập (chặn role staff/admin vào Mobile, chặn user vào Web)."
        ],
        "avoid_text": "Chỉ ghi tên vai trò mà không mô tả họ là ai, được làm gì.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <div style="display: grid; grid-template-columns: 1.2fr 2.3fr 1.8fr; gap: 8px; padding-bottom: 4px; font-size: 11.3px; font-weight: 700; color: var(--muted); letter-spacing: 0.5px;">
              <div>ACTOR (VAI TRÒ)</div>
              <div>MÔ TẢ NGỮ CẢNH</div>
              <div>QUYỀN HẠN CHÍNH</div>
            </div>

            <!-- Row 1: Sinh viên -->
            <div style="display: grid; grid-template-columns: 1.2fr 2.3fr 1.8fr; gap: 8px; background: rgba(219,39,119,0.07); border-radius: 6px; padding: 10px 12px; align-items: center;">
              <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--accent1); color: #FFF; font-weight: 700; font-size: 14px; display: flex; align-items: center; justify-content: center;">S</div>
                <div>
                  <div style="font-weight: 700; font-size: 14px; color: var(--tx1);">Sinh viên</div>
                  <div style="font-size: 11.5px; color: var(--muted);">Mobile (role: user)</div>
                </div>
              </div>
              <div style="font-size: 13.5px; color: var(--slate-600); line-height: 1.25;">Sinh viên FPTU và khách tham gia sự kiện trên Mobile App</div>
              <div style="font-size: 13.5px; font-weight: 700; color: var(--accent1);">Tìm sự kiện, Đăng ký, Quét QR điểm danh, Xuất PDF</div>
            </div>

            <!-- Row 2: Trưởng CLB -->
            <div style="display: grid; grid-template-columns: 1.2fr 2.3fr 1.8fr; gap: 8px; background: rgba(249,115,22,0.07); border-radius: 6px; padding: 10px 12px; align-items: center;">
              <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--accent2); color: #FFF; font-weight: 700; font-size: 14px; display: flex; align-items: center; justify-content: center;">T</div>
                <div>
                  <div style="font-weight: 700; font-size: 14px; color: var(--tx1);">Trưởng CLB</div>
                  <div style="font-size: 11.5px; color: var(--muted);">Web (role: staff)</div>
                </div>
              </div>
              <div style="font-size: 13.5px; color: var(--slate-600); line-height: 1.25;">Ban chủ nhiệm câu lạc bộ quản lý sự kiện trên Web Admin</div>
              <div style="font-size: 13.5px; font-weight: 700; color: var(--accent2);">Đề xuất sự kiện, Duyệt/Từ chối đơn, Mở phiên QR</div>
            </div>

            <!-- Row 3: Admin -->
            <div style="display: grid; grid-template-columns: 1.2fr 2.3fr 1.8fr; gap: 8px; background: rgba(217,119,6,0.07); border-radius: 6px; padding: 10px 12px; align-items: center;">
              <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--accent4); color: #FFF; font-weight: 700; font-size: 14px; display: flex; align-items: center; justify-content: center;">Q</div>
                <div>
                  <div style="font-weight: 700; font-size: 14px; color: var(--tx1);">Quản trị viên</div>
                  <div style="font-size: 11.5px; color: var(--muted);">Web (role: admin)</div>
                </div>
              </div>
              <div style="font-size: 13.5px; color: var(--slate-600); line-height: 1.25;">Quản lý phong trào trường, kiểm duyệt sự kiện toàn trường</div>
              <div style="font-size: 13.5px; font-weight: 700; color: var(--accent4);">Duyệt công bố sự kiện, Phân quyền CLB, Giám sát hệ thống</div>
            </div>

            <!-- Row 4: Firebase -->
            <div style="display: grid; grid-template-columns: 1.2fr 2.3fr 1.8fr; gap: 8px; background: rgba(234,88,12,0.07); border-radius: 6px; padding: 10px 12px; align-items: center;">
              <div style="display: flex; align-items: center; gap: 10px;">
                <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--accent3); color: #FFF; font-weight: 700; font-size: 14px; display: flex; align-items: center; justify-content: center;">F</div>
                <div>
                  <div style="font-weight: 700; font-size: 14px; color: var(--tx1);">Firebase Suite</div>
                  <div style="font-size: 11.5px; color: var(--muted);">Hệ thống ngoài</div>
                </div>
              </div>
              <div style="font-size: 13.5px; color: var(--slate-600); line-height: 1.25;">Hệ thống hạ tầng đám mây Google Firebase Backend Suite</div>
              <div style="font-size: 13.5px; font-weight: 700; color: var(--accent3);">Auth, Firestore Realtime, FCM Push, Remote Config</div>
            </div>
          </div>
        """,
        "panel_note": "Danh sách vai trò khớp chính xác với hệ thống Security Rules và Role Gate.",
        "footer_page": "05"
    })

    # -------------------------------------------------------------------------
    # SLIDE 06 · MAIN FEATURES
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-06",
        "page_id": "06",
        "phase_tag": "P1 · PROBLEM",
        "phase_color": "var(--accent1)",
        "phase_bg": "rgba(219,39,119,0.14)",
        "box_bg": "rgba(219,39,119,0.08)",
        "section_str": "06 / MAIN FEATURES",
        "slide_num_str": "Slide 6",
        "title_rest": "Main Features — nhóm theo nghiệp vụ",
        "subtitle": "Tập trung tính năng mang giá trị; chọn ra các workflow quan trọng nhất để demo.",
        "pill_right": None,
        "question": "Hệ thống làm được gì, và đâu là các workflow quan trọng nhất?",
        "duration": "45 s",
        "evidence": "4 Nhóm tính năng; chọn 3 workflow lõi liên vai trò sẽ demo trực tiếp",
        "left_items": [
            "Chia thành 4 nhóm tính năng: Khám phá & Đăng ký, Quản trị & Duyệt, Điểm danh QR, Theo dõi & Báo cáo.",
            "Nêu bật 3 workflow lõi liên thiết bị: WF-01 (Đăng ký), WF-02 (Duyệt đơn), WF-03 (Điểm danh QR).",
            "Chỉ ra tính năng MVP cốt lõi và các tính năng mở rộng (Remote Config A/B, Xuất PDF lịch tham gia).",
            "Liên kết chặt chẽ: Tính năng ↔ Actor ↔ Giải quyết trực tiếp 3 Pain points ban đầu."
        ],
        "avoid_text": "Liệt kê 20 tính năng chữ nhỏ, hoặc đọc menu chức năng.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px;">
              <!-- WF-01 Card -->
              <div style="border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden; background: #FFF;">
                <div style="background: var(--accent1); color: #FFF; padding: 8px 12px; text-align: center;">
                  <div style="font-size: 15px; font-weight: 700;">WF-01</div>
                  <div style="font-size: 13px;">Gửi yêu cầu đăng ký</div>
                </div>
                <div style="padding: 10px 12px; font-size: 13.5px; line-height: 1.35;">
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Actor</div>
                  <div style="font-weight: 700; color: var(--tx1); margin-bottom: 6px;">Sinh viên (Mobile)</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Trigger</div>
                  <div style="color: var(--slate-600); margin-bottom: 6px;">Bấm đăng ký workshop A05</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Kết quả</div>
                  <div style="font-weight: 700; color: var(--accent1); margin-bottom: 6px;">Đơn ở PENDING (A06)</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Tính năng</div>
                  <div style="color: var(--slate-600);">Form • Khóa K • Chống gửi lặp</div>
                </div>
              </div>

              <!-- WF-02 Card -->
              <div style="border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden; background: #FFF;">
                <div style="background: var(--accent2); color: #FFF; padding: 8px 12px; text-align: center;">
                  <div style="font-size: 15px; font-weight: 700;">WF-02</div>
                  <div style="font-size: 13px;">Duyệt yêu cầu</div>
                </div>
                <div style="padding: 10px 12px; font-size: 13.5px; line-height: 1.35;">
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Actor</div>
                  <div style="font-weight: 700; color: var(--tx1); margin-bottom: 6px;">Trưởng CLB (Web Admin)</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Trigger</div>
                  <div style="color: var(--slate-600); margin-bottom: 6px;">Đơn mới vào Review Queue</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Kết quả</div>
                  <div style="font-weight: 700; color: var(--accent2); margin-bottom: 6px;">APPROVED / REJECTED + FCM</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Tính năng</div>
                  <div style="color: var(--slate-600);">Transaction • Sức chứa • Lý do</div>
                </div>
              </div>

              <!-- WF-03 Card -->
              <div style="border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden; background: #FFF;">
                <div style="background: var(--accent4); color: #FFF; padding: 8px 12px; text-align: center;">
                  <div style="font-size: 15px; font-weight: 700;">WF-03</div>
                  <div style="font-size: 13px;">Điểm danh QR Realtime</div>
                </div>
                <div style="padding: 10px 12px; font-size: 13.5px; line-height: 1.35;">
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Actor</div>
                  <div style="font-weight: 700; color: var(--tx1); margin-bottom: 6px;">Trưởng CLB &amp; Sinh viên</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Trigger</div>
                  <div style="color: var(--slate-600); margin-bottom: 6px;">Hội trường mở phiên điểm danh</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Kết quả</div>
                  <div style="font-weight: 700; color: var(--accent4); margin-bottom: 6px;">ATTENDED realtime (A12)</div>
                  <div style="font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase;">Tính năng</div>
                  <div style="color: var(--slate-600);">Phát QR • Quét SHA-256 • Ẩn PII</div>
                </div>
              </div>
            </div>

            <!-- Footer line -->
            <div style="background: var(--slate-100); border-radius: 6px; padding: 8px 14px; font-size: 13.5px; color: var(--slate-600);">
              Ngoài workflow lõi: Quản trị sự kiện • Cấu hình Remote Config • Báo cáo PDF local • Phân tích Funnel Analytics.
            </div>
          </div>
        """,
        "panel_note": "Các workflow này được demo trực tiếp ở slide 18–20 theo kịch bản liên vai trò.",
        "footer_page": "06"
    })

    return slides

print("slide_definitions.py part 1 ready.")

