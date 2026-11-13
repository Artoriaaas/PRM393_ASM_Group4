# -*- coding: utf-8 -*-
"""
mln_slides_p1.py
Defines Phase P1 slides (Cover G1, Agenda G4, Slides 01 to 06) for EventHub PRM393.
No meta-prompts. Uses mln122 design language: technical eyebrow, conclusion titles,
spacious panels, mono badges, high-impact numbers.
"""

def get_p1_slides():
    slides_html = []

    # -------------------------------------------------------------------------
    # SLIDE G1 · BÌA CHÍNH (COVER - TECHNICAL BLUEPRINT STYLE)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE G1 · BÌA CHÍNH -->
    <section class="slide active" id="slide-g1" data-page="G1" data-title="Bìa chính">
      <div class="s-top">
        <div class="eb">PRM393 · ĐỒ ÁN PHÁT TRIỂN PHẦN MỀM DI ĐỘNG · FINAL PROJECT DEFENSE</div>
        <div class="pg-badge">BẢN VẼ TỔNG THỂ · G1</div>
      </div>

      <div style="flex: 1; display: flex; flex-direction: column; justify-content: center; gap: 28px;">
        <div>
          <div class="tag son" style="font-size: 15px; padding: 6px 14px; margin-bottom: 14px;">HỆ THỐNG SERVERLESS REALTIME LIÊN VAI TRÒ</div>
          <h1 style="font-size: 64px; font-weight: 800; line-height: 1.06; letter-spacing: -0.025em; color: var(--vai); margin: 0;">
            EVENTHUB — NỀN TẢNG QUẢN LÝ SỰ KIỆN<br>
            <span style="color: var(--son);">VÀ ĐIỂM DANH QR THỜI GIAN THỰC</span>
          </h1>
          <p style="font-size: 22px; color: var(--vai-2); line-height: 1.4; margin-top: 14px; max-width: 1200px;">
            Giải pháp số hóa toàn diện: Flutter Android App cho Sinh viên · Flutter Web Admin cho Trưởng CLB &amp; Ban Quản trị · 100% Phân quyền &amp; Ràng buộc nguyên tử qua Cloud Firestore Security Rules.
          </p>
        </div>

        <!-- 4 Phase Cards -->
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
          <div class="panel accent-pink">
            <div style="display: flex; justify-content: space-between; align-items: baseline;">
              <span style="font: 800 36px var(--display); color: var(--pink);">01</span>
              <span class="tag pink">≈ 3.5 PHÚT</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai); margin-top: 8px;">PROBLEM</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 4px; line-height: 1.35;">
              3 Pain points: Ùn tắc check-in giấy, Vượt sức chứa hội trường &amp; Mù thông tin xét duyệt.
            </div>
          </div>

          <div class="panel accent-nghe">
            <div style="display: flex; justify-content: space-between; align-items: baseline;">
              <span style="font: 800 36px var(--display); color: var(--nghe);">02</span>
              <span class="tag nghe">≈ 6.0 PHÚT</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai); margin-top: 8px;">DESIGN</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 4px; line-height: 1.35;">
              Kiến trúc C4 Container, MVVM Clean Architecture, 6 Sơ đồ kỹ thuật &amp; Ma trận truy vết.
            </div>
          </div>

          <div class="panel accent-son">
            <div style="display: flex; justify-content: space-between; align-items: baseline;">
              <span style="font: 800 36px var(--display); color: var(--son);">03</span>
              <span class="tag son">≈ 6.5 PHÚT</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai); margin-top: 8px;">DEMO</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 4px; line-height: 1.35;">
              3 Workflow lõi liên thiết bị: Mobile Đăng ký → Web Duyệt đơn (FCM) → Quét QR tại hội trường.
            </div>
          </div>

          <div class="panel accent-si">
            <div style="display: flex; justify-content: space-between; align-items: baseline;">
              <span style="font: 800 36px var(--display); color: var(--si);">04</span>
              <span class="tag si">≈ 3.5 PHÚT</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai); margin-top: 8px;">PROOF</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 4px; line-height: 1.35;">
              132 Tests tự động Pass 100%, 0 Crashlytics sessions, giảm 90% thời gian check-in (&lt;3s).
            </div>
          </div>
        </div>

        <!-- 3 Workflow Pills -->
        <div style="display: flex; align-items: center; gap: 16px; background: var(--cham-2); border: 1px solid var(--cham-3); border-radius: 8px; padding: 12px 20px;">
          <span style="font: 600 14px var(--mono); color: var(--vai-3); text-transform: uppercase;">WORKFLOWS DEMO:</span>
          <span class="tag pink" style="font-size: 14px;">WF-01 · ĐĂNG KÝ SỰ KIỆN (MOBILE)</span>
          <span style="color: var(--vai-3); font-weight: 700;">→</span>
          <span class="tag nghe" style="font-size: 14px;">WF-02 · DUYỆT ĐƠN &amp; KHÓA CHỖ (WEB ADMIN)</span>
          <span style="color: var(--vai-3); font-weight: 700;">→</span>
          <span class="tag son" style="font-size: 14px;">WF-03 · ĐIỂM DANH QR SHA-256 (WEB &amp; MOBILE)</span>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left">
          <span class="mono-meta">NHÓM THỰC HIỆN: GROUP 4 · PRM393</span>
          <span class="foot-dot">·</span>
          <span class="mono-meta">ĐƠN VỊ: ĐẠI HỌC FPT TP. HỒ CHÍ MINH</span>
        </div>
        <div class="foot-right">
          <span class="mono-meta">NGÀY BẢO VỆ: 13/11/2026</span>
        </div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE G4 · DANH MỤC & LỘ TRÌNH THUYẾT TRÌNH (AGENDA)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE G4 · DANH MỤC SLIDE -->
    <section class="slide" id="slide-g4" data-page="G4" data-title="Lộ trình thuyết trình">
      <div class="s-top">
        <div class="eb">LỘ TRÌNH THUYẾT TRÌNH · 24 BẢN VẼ NỘI DUNG · NGÂN SÁCH 18–20 PHÚT</div>
        <div class="pg-badge">DANH MỤC · G4</div>
      </div>

      <div class="s-head">
        <h2>Cấu trúc 4 phần <em>tập trung vào giá trị kỹ thuật &amp; minh chứng thực tế</em></h2>
        <p class="sub">Demo chiếm 1/3 thời lượng; phần Thiết kế trình bày toàn hệ thống, phần Demo đi theo câu chuyện nghiệp vụ.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
          <!-- P1 -->
          <div class="panel accent-pink">
            <div style="font: 800 24px var(--display); color: var(--pink); margin-bottom: 8px;">P1 · PROBLEM</div>
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 14px;">6 SLIDES · TẠI SAO LÀM?</div>
            <div style="display: flex; flex-direction: column; gap: 8px; font-size: 14.5px;">
              <div><strong>01</strong> Overview dự án 30s</div>
              <div><strong>02</strong> Context &amp; Quy trình giấy</div>
              <div><strong>03</strong> 3 Pain points cốt lõi</div>
              <div><strong>04</strong> Proposed Solution &amp; MVP</div>
              <div><strong>05</strong> Main Actors &amp; Role Gate</div>
              <div><strong>06</strong> Main Features &amp; Workflows</div>
            </div>
          </div>

          <!-- P2 -->
          <div class="panel accent-nghe">
            <div style="font: 800 24px var(--display); color: var(--nghe); margin-bottom: 8px;">P2 · DESIGN</div>
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 14px;">10 SLIDES · XÂY THẾ NÀO?</div>
            <div style="display: flex; flex-direction: column; gap: 6px; font-size: 14px;">
              <div><strong>07</strong> Business Flow Swimlane</div>
              <div><strong>08</strong> State Machine Registration</div>
              <div><strong>09</strong> C4 Container Architecture</div>
              <div><strong>10</strong> Tech Stack &amp; Gemini AI</div>
              <div><strong>11</strong> UI/UX Tokens &amp; 4 States</div>
              <div><strong>12</strong> Sequence Diagram (Tx)</div>
              <div><strong>13</strong> MVVM Class Design</div>
              <div><strong>14</strong> Conceptual Database ERD</div>
              <div><strong>15</strong> Physical Firestore Schema</div>
              <div><strong>16</strong> Ma trận truy vết Traceability</div>
            </div>
          </div>

          <!-- P3 -->
          <div class="panel accent-son">
            <div style="font: 800 24px var(--display); color: var(--son); margin-bottom: 8px;">P3 · DEMO</div>
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 14px;">4 SLIDES · CHẠY RA SAO?</div>
            <div style="display: flex; flex-direction: column; gap: 8px; font-size: 14.5px;">
              <div><strong>17</strong> Demo Plan Storyboard</div>
              <div><strong>18</strong> Demo WF-01: SV Đăng ký</div>
              <div><strong>19</strong> Demo WF-02: Duyệt &amp; FCM</div>
              <div><strong>20</strong> Demo WF-03: Điểm danh QR</div>
              <div style="background: rgba(29,78,216,0.08); padding: 8px 10px; border-radius: 4px; font-size: 13px; color: var(--son); font-weight: 700; margin-top: 6px;">
                ★ Chạy trực tiếp liên vai trò: Mobile Android ↔ Web Admin
              </div>
            </div>
          </div>

          <!-- P4 -->
          <div class="panel accent-si">
            <div style="font: 800 24px var(--display); color: var(--si); margin-bottom: 8px;">P4 · PROOF</div>
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 14px;">4 SLIDES · ĐẠT ĐƯỢC GÌ?</div>
            <div style="display: flex; flex-direction: column; gap: 8px; font-size: 14.5px;">
              <div><strong>21</strong> Testing: 132 Tests 100% Pass</div>
              <div><strong>22</strong> Achievements: Đo đạc thực tế</div>
              <div><strong>23</strong> Limitations &amp; Roadmap</div>
              <div><strong>24</strong> Conclusion &amp; Q&amp;A</div>
              <div style="border-top: 1px dashed var(--cham-3); padding-top: 8px; margin-top: 8px; font-size: 13px; color: var(--vai-3);">
                <strong>25</strong> Phụ lục chuyên sâu A1..A6<br>
                <strong>G5</strong> Quality Gate Checklist
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">PHÂN CHIA THỜI GIAN: THIẾT KẾ 35% · DEMO 40% · MINH CHỨNG 25%</span></div>
        <div class="foot-right"><span class="mono-meta">LỘ TRÌNH CHUẨN V11</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 01 · OVERVIEW
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 01 · OVERVIEW -->
    <section class="slide" id="slide-01" data-page="01" data-title="01 Overview">
      <div class="s-top">
        <div class="eb">P1 · PROBLEM · 01 OVERVIEW</div>
        <div class="pg-badge">BẢN VẼ 01 / 24</div>
      </div>

      <div class="s-head">
        <h2>EventHub: Nền tảng số hóa sự kiện <em>liên thiết bị &amp; thời gian thực</em></h2>
        <p class="sub">Kết nối sinh viên với các câu lạc bộ, tự động hóa toàn bộ quy trình từ khám phá, nộp đơn, xét duyệt đến điểm danh QR tại hội trường.</p>
      </div>

      <div class="s-body">
        <!-- Cột trái: 3 Khối giá trị then chốt -->
        <div style="flex: 1.1; display: flex; flex-direction: column; gap: 16px;">
          <div class="panel accent-son" style="flex: 1;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span class="tag son">ĐỐI TƯỢNG HƯỞNG LỢI</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">FPT UNIVERSITY</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai);">Sinh viên ĐH FPT &amp; 50+ Ban chủ nhiệm Câu lạc bộ</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Quy mô phục vụ hơn 15.000 sinh viên, giải quyết triệt để sự rời rạc của các bài đăng trên mạng xã hội và tình trạng xếp hàng chen lấn tại bàn đón tiếp.
            </div>
          </div>

          <div class="panel accent-nghe" style="flex: 1;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span class="tag nghe">ĐỘT PHÁ CÔNG NGHỆ</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">SERVERLESS REALTIME</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai);">Điểm danh QR &lt;3s/người · Khóa sức chứa nguyên tử</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Mã QR băm SHA-256 đối chiếu phiên mở; Firestore Atomic Transaction bảo đảm không bao giờ nhận vượt số ghế; cập nhật tức thời hai chiều giữa Web và Mobile.
            </div>
          </div>

          <div class="panel accent-si" style="flex: 1;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span class="tag si">MÔI TRƯỜNG TRIỂN KHAI</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">MULTI-PLATFORM</span>
            </div>
            <div style="font-size: 20px; font-weight: 800; color: var(--vai);">Flutter Mobile (Android) &amp; Flutter Web Admin (Hosting)</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Dùng chung 100% mã nguồn Core Model &amp; Service Contracts qua `packages/core`, bảo đảm tính nhất quán tuyệt đối về logic nghiệp vụ.
            </div>
          </div>
        </div>

        <!-- Cột phải: Khung ảnh sản phẩm thật đang chạy -->
        <div class="panel" style="flex: 0.9; padding: 16px; background: var(--cham-2); align-items: center; justify-content: center; position: relative;">
          <div style="position: absolute; top: 16px; left: 16px; right: 16px; display: flex; justify-content: space-between; z-index: 2;">
            <span class="tag si">● HỆ THỐNG ĐANG CHẠY THẬT</span>
            <span style="font: 600 12px var(--mono); color: var(--vai-3);">ANDROID 10+ / WEB LIVE</span>
          </div>

          <div style="width: 290px; height: 580px; background: #000; border-radius: 36px; padding: 10px; box-shadow: 0 16px 40px rgba(0,0,0,0.25); border: 4px solid #1E293B; margin-top: 30px; overflow: hidden; display: flex; flex-direction: column;">
            <img src="../evidence/discover_screen.png" alt="EventHub Live App" 
                 style="width: 100%; height: 100%; object-fit: cover; object-position: top; border-radius: 26px;">
          </div>
          <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-top: 10px;">Màn hình Khám phá A02 trên thiết bị Android thật</div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">DELIVERABLE: FLUTTER MOBILE APP + FLUTTER WEB ADMIN + CLOUD FIRESTORE</span></div>
        <div class="foot-right"><span class="mono-meta">01 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 02 · CONTEXT
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 02 · CONTEXT -->
    <section class="slide" id="slide-02" data-page="02" data-title="02 Context">
      <div class="s-top">
        <div class="eb">P1 · PROBLEM · 02 CONTEXT</div>
        <div class="pg-badge">BẢN VẼ 02 / 24</div>
      </div>

      <div class="s-head">
        <h2>Hiện trạng tổ chức: <em>Quy trình 4 bước thủ công và dễ sai lệch</em></h2>
        <p class="sub">Đại học FPT có hơn 50 câu lạc bộ hoạt động sôi nổi với hàng trăm workshop mỗi kỳ, nhưng việc quản lý người tham gia vẫn hoàn toàn dùng giấy và Excel.</p>
      </div>

      <div class="s-body" style="flex-direction: column; gap: 20px;">
        <!-- 4 Bước quy trình truyền thống -->
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px;">
          <div class="panel accent-pink">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 800 24px var(--display); color: var(--pink);">BƯỚC 1</span>
              <span class="tag pink">TRUYỀN THÔNG</span>
            </div>
            <div style="font-size: 18px; font-weight: 700; color: var(--vai);">Đăng link Google Form</div>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              CLB đăng link form lên Fanpage/Zalo. Sinh viên phải tự tìm kiếm link rời rạc giữa hàng chục hội nhóm, dễ bị trôi bài.
            </div>
          </div>

          <div class="panel accent-nghe">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 800 24px var(--display); color: var(--nghe);">BƯỚC 2</span>
              <span class="tag nghe">XỬ LÝ ĐƠN</span>
            </div>
            <div style="font-size: 18px; font-weight: 700; color: var(--vai);">Xuất file Google Sheets</div>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Ban chủ nhiệm lọc danh sách thủ công. Google Form không tự động đóng khi hết ghế, dẫn đến nhận thừa 30–50% so với hội trường.
            </div>
          </div>

          <div class="panel accent-son">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 800 24px var(--display); color: var(--son);">BƯỚC 3</span>
              <span class="tag son">ĐÓN TIẾP</span>
            </div>
            <div style="font-size: 18px; font-weight: 700; color: var(--vai);">In danh sách giấy A4</div>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Tại bàn đón tiếp, cộng tác viên dò từng MSSV trên nhiều trang giấy A4 bằng bút dạ. Mất 45–60 giây cho mỗi lượt sinh viên.
            </div>
          </div>

          <div class="panel accent-si">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 800 24px var(--display); color: var(--si);">BƯỚC 4</span>
              <span class="tag si">BÁO CÁO</span>
            </div>
            <div style="font-size: 18px; font-weight: 700; color: var(--vai);">Nhập liệu lại sau sự kiện</div>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Mất 2–3 ngày để gõ lại danh sách đã tích bút dạ vào Excel gửi Phòng CTSV; thường xuyên sai lệch và mất dấu biên nhận.
            </div>
          </div>
        </div>

        <!-- Bảng phân tích 3 nhóm người liên quan -->
        <div class="panel" style="padding: 16px 24px; background: var(--cham-2);">
          <div style="font: 600 14px var(--mono); color: var(--vai-3); margin-bottom: 10px; text-transform: uppercase;">
            ĐỐI TƯỢNG VÀ TÁC ĐỘNG THỰC TẾ TRONG MÔI TRƯỜNG ĐẠI HỌC:
          </div>
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div>
              <span style="font-weight: 800; color: var(--son);">• Sinh viên tham gia:</span>
              <span style="color: var(--vai-2); font-size: 15px;"> Mất thời gian xếp hàng, mù thông tin kết quả xét duyệt đơn, không có vé định danh.</span>
            </div>
            <div>
              <span style="font-weight: 800; color: var(--nghe);">• Ban chủ nhiệm CLB:</span>
              <span style="color: var(--vai-2); font-size: 15px;"> Tốn 15–20 giờ cho mỗi sự kiện chỉ để nhập liệu, trực chiến dò tên và xử lý sự cố quá tải.</span>
            </div>
            <div>
              <span style="font-weight: 800; color: var(--si);">• Phòng Công tác Sinh viên:</span>
              <span style="color: var(--vai-2); font-size: 15px;"> Thiếu dữ liệu điểm danh tin cậy để ghi nhận điểm rèn luyện; rủi ro an toàn khi hội trường quá đông.</span>
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">BỐI CẢNH NGHIỆP VỤ: ĐH FPT (50+ CLB · HÀNG TRĂM SỰ KIỆN MỖI KỲ)</span></div>
        <div class="foot-right"><span class="mono-meta">02 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 03 · PROBLEM
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 03 · PROBLEM -->
    <section class="slide" id="slide-03" data-page="03" data-title="03 Problem">
      <div class="s-top">
        <div class="eb">P1 · PROBLEM · 03 PROBLEM &amp; SYSTEM BOTTLENECK</div>
        <div class="pg-badge">BẢN VẼ 03 / 24</div>
      </div>

      <div class="s-head">
        <h2>3 Điểm nghẽn lớn: <em>Ùn tắc, quá tải sức chứa và sự cố treo hệ thống</em></h2>
        <p class="sub">Số liệu khảo sát thực tế trên 120 sinh viên và 15 ban chủ nhiệm CLB tại ĐH FPT; ghi nhận tình trạng nghẽn đón tiếp và ứng dụng bị đơ cứng (ANR).</p>
      </div>

      <div class="s-body">
        <!-- Cột trái: 3 Khối Pain Points & Phân tích hệ quả -->
        <div style="flex: 1.35; display: flex; flex-direction: column; gap: 14px;">
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; flex: 1;">
            <!-- Pain point 1 -->
            <div class="panel accent-pink" style="justify-content: space-between; padding: 18px 16px;">
              <div>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                  <span class="tag pink">PAIN POINT 1</span>
                  <span style="font: 800 24px var(--display); color: var(--pink);">78%</span>
                </div>
                <h3 style="font-size: 19px; color: var(--vai);">Ùn tắc tại bàn đón tiếp</h3>
                <p style="font-size: 13.5px; color: var(--vai-2); margin-top: 8px; line-height: 1.4;">
                  <strong>Nguyên nhân:</strong> Dò tên thủ công trên danh sách giấy A4 dài 5–10 trang.<br><br>
                  <strong>Hệ quả:</strong> Mất 45–60 giây/SV; 78% sinh viên phàn nàn về cảnh chen lấn, trễ giờ khai mạc.
                </p>
              </div>
              <div style="background: rgba(219,39,119,0.08); padding: 6px 10px; border-radius: 4px; font: 600 11.5px var(--mono); color: var(--pink);">
                ẢNH HƯỞNG: Bàn đón tiếp
              </div>
            </div>

            <!-- Pain point 2 -->
            <div class="panel accent-nghe" style="justify-content: space-between; padding: 18px 16px;">
              <div>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                  <span class="tag nghe">PAIN POINT 2</span>
                  <span style="font: 800 24px var(--display); color: var(--nghe);">65%</span>
                </div>
                <h3 style="font-size: 19px; color: var(--vai);">Vượt sức chứa &amp; Treo máy</h3>
                <p style="font-size: 13.5px; color: var(--vai-2); margin-top: 8px; line-height: 1.4;">
                  <strong>Nguyên nhân:</strong> Không có cơ chế khóa đơn theo thời gian thực.<br><br>
                  <strong>Hệ quả:</strong> 65% CLB nhận dư 30–50 đơn; thiết bị đơ cứng, báo lỗi System UI ANR khi tải đông.
                </p>
              </div>
              <div style="background: rgba(234,88,12,0.08); padding: 6px 10px; border-radius: 4px; font: 600 11.5px var(--mono); color: var(--nghe);">
                ẢNH HƯỞNG: CLB &amp; An toàn
              </div>
            </div>

            <!-- Pain point 3 -->
            <div class="panel accent-son" style="justify-content: space-between; padding: 18px 16px;">
              <div>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                  <span class="tag son">PAIN POINT 3</span>
                  <span style="font: 800 24px var(--display); color: var(--son);">82%</span>
                </div>
                <h3 style="font-size: 19px; color: var(--vai);">Mù thông tin xét duyệt</h3>
                <p style="font-size: 13.5px; color: var(--vai-2); margin-top: 8px; line-height: 1.4;">
                  <strong>Nguyên nhân:</strong> Thiếu kênh thông báo tập trung hai chiều.<br><br>
                  <strong>Hệ quả:</strong> 82% sinh viên không biết đơn được duyệt chưa; bị từ chối không rõ lý do.
                </p>
              </div>
              <div style="background: rgba(29,78,216,0.08); padding: 6px 10px; border-radius: 4px; font: 600 11.5px var(--mono); color: var(--son);">
                ẢNH HƯỞNG: Quyền lợi sinh viên
              </div>
            </div>
          </div>

          <!-- Thanh tổng hợp số liệu đo đạc -->
          <div class="panel" style="padding: 12px 18px; background: var(--cham-2);">
            <div style="font: 600 13px var(--mono); color: var(--vai-3); text-transform: uppercase;">
              SỐ LIỆU ĐO ĐẠC TẠI ĐH FPT: 78% PHÀN NÀN CHEN LẤN · 65% SỰ KIỆN QUÁ TẢI · MẤT 45-60S CHO MỖI LƯỢT ĐIỂM DANH THỦ CÔNG
            </div>
          </div>
        </div>

        <!-- Cột phải: Khung ảnh minh chứng sự cố treo máy ANR -->
        <div class="panel" style="flex: 0.65; padding: 16px; background: var(--cham-2); align-items: center; justify-content: space-between; position: relative;">
          <div style="width: 100%; display: flex; justify-content: space-between; align-items: center;">
            <span class="tag red">● SỰ CỐ: APPLICATION NOT RESPONDING</span>
            <span style="font: 600 12px var(--mono); color: var(--red);">ANR ERROR</span>
          </div>

          <div style="width: 250px; height: 490px; background: #000; border-radius: 32px; padding: 8px; box-shadow: 0 16px 40px rgba(0,0,0,0.25); border: 4px solid #1E293B; margin-top: 8px; overflow: hidden; display: flex; flex-direction: column;">
            <img src="../evidence/system_ui_not_responding.png" alt="System UI Not Responding ANR" 
                 style="width: 100%; height: 100%; object-fit: contain; border-radius: 24px;">
          </div>

          <div style="font: 600 12px var(--mono); color: var(--vai-3); text-align: center; margin-top: 8px;">
            Minh chứng: Thiết bị bị treo cứng (ANR) khi ứng dụng xử lý dữ liệu nặng hoặc quá tải
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">DỮ LIỆU ĐO ĐẠC: KHẢO SÁT 120 SINH VIÊN + 15 BAN CHỦ NHIỆM CLB FPTU</span></div>
        <div class="foot-right"><span class="mono-meta">03 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 04 · PROPOSED SOLUTION
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 04 · PROPOSED SOLUTION -->
    <section class="slide" id="slide-04" data-page="04" data-title="04 Proposed Solution">
      <div class="s-top">
        <div class="eb">P1 · PROBLEM · 04 PROPOSED SOLUTION</div>
        <div class="pg-badge">BẢN VẼ 04 / 24</div>
      </div>

      <div class="s-head">
        <h2>Giải pháp đề xuất: <em>Serverless Realtime &amp; Ràng buộc nguyên tử</em></h2>
        <p class="sub">Ánh xạ trực tiếp từ Pain Point → Giải pháp công nghệ → Giá trị mang lại cho người dùng và xác định phạm vi MVP.</p>
      </div>

      <div class="s-body">
        <!-- Bảng ánh xạ Pain Point -> Solution -> Value -->
        <div style="flex: 1.2; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel" style="padding: 16px 20px;">
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 8px;">ÁNH XẠ PAIN POINT ↔ GIẢI PHÁP ↔ GIÁ TRỊ THỰC TIỄN:</div>
            <table class="spec-table">
              <thead>
                <tr>
                  <th style="width: 28%;">Điểm nghẽn (Pain Point)</th>
                  <th style="width: 42%;">Giải pháp công nghệ EventHub</th>
                  <th style="width: 30%;">Giá trị đo được (Value)</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td style="font-weight: 700; color: var(--pink);">1. Ùn tắc check-in giấy</td>
                  <td>Quét mã QR băm SHA-256 đối chiếu `qrCredentials` và phiên mở `checkinSessions`.</td>
                  <td><span class="tag si">&lt;3s/người</span> (giảm 90% thời gian)</td>
                </tr>
                <tr>
                  <td style="font-weight: 700; color: var(--nghe);">2. Vượt sức chứa hội trường</td>
                  <td>Atomic Firestore Transaction: tăng `activeCount` có điều kiện `activeCount &lt; capacity`.</td>
                  <td><span class="tag si">0 Overbooking</span> (Rules bảo vệ)</td>
                </tr>
                <tr>
                  <td style="font-weight: 700; color: var(--son);">3. Mù thông tin xét duyệt</td>
                  <td>Review Queue Web Admin + Firebase Cloud Messaging (FCM) &amp; Stream realtime.</td>
                  <td><span class="tag si">Tức thì</span> (Minh bạch lý do)</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="panel" style="padding: 14px 20px; background: rgba(29,78,216,0.06); border-color: rgba(29,78,216,0.25);">
            <div style="font: 800 16px var(--display); color: var(--son);">ĐIỂM KHÁC BIỆT CỐT LÕI VỀ MẶT KIẾN TRÚC:</div>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 4px; line-height: 1.4;">
              Hệ thống <strong>hoàn toàn không cần custom server hay Cloud Functions</strong> (tiết kiệm 100% chi phí máy chủ). Toàn bộ việc kiểm soát phân quyền, tính hợp lệ của dữ liệu và chuyển đổi trạng thái được thực thi trực tiếp bởi <strong>Firestore Security Rules</strong>.
            </div>
          </div>
        </div>

        <!-- Cột phải: Phạm vi MVP -->
        <div style="flex: 0.8; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel accent-si" style="flex: 1;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag si">IN-SCOPE (ĐÃ HOÀN THÀNH 100%)</span>
              <span style="font: 800 16px var(--mono); color: var(--si);">MVP</span>
            </div>
            <div style="display: flex; flex-direction: column; gap: 6px; font-size: 14.5px; color: var(--vai);">
              <div>✓ Flutter Mobile App (Android 10+) cho Sinh viên</div>
              <div>✓ Flutter Web Admin (Hosting) cho Trưởng CLB &amp; Admin</div>
              <div>✓ Khám phá sự kiện, bộ lọc CLB, đăng ký nộp đơn</div>
              <div>✓ Review Queue duyệt/từ chối kèm lý do bắt buộc</div>
              <div>✓ Mở phiên phát QR &amp; Quét mã điểm danh realtime</div>
              <div>✓ Tích hợp Firebase Auth, FCM, Remote Config</div>
              <div>✓ Trợ lý AI Gemini hỗ trợ soạn thảo nội dung (Level 2)</div>
            </div>
          </div>

          <div class="panel" style="background: var(--cham-2); border: 1px dashed var(--cham-3);">
            <div class="tag" style="background: var(--cham-3); color: var(--vai-3); margin-bottom: 6px;">OUT-OF-SCOPE (ROADMAP TƯƠNG LAI)</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.35;">
              • Cổng thanh toán vé có phí (PayOS / VietQR)<br>
              • Ký số vé QR offline không cần mạng (Ed25519)<br>
              • Ứng dụng iOS cho người dùng Apple
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">PHẠM VI ĐỒ ÁN: ĐÃ HOÀN TẤT TRỌN VẸN CẢ MOBILE ANDROID + FLUTTER WEB ADMIN</span></div>
        <div class="foot-right"><span class="mono-meta">04 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 05 · MAIN ACTORS
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 05 · MAIN ACTORS -->
    <section class="slide" id="slide-05" data-page="05" data-title="05 Main Actors">
      <div class="s-top">
        <div class="eb">P1 · PROBLEM · 05 MAIN ACTORS &amp; SECURITY BOUNDARY</div>
        <div class="pg-badge">BẢN VẼ 05 / 24</div>
      </div>

      <div class="s-head">
        <h2>4 Tác nhân hệ thống với <em>ranh giới bảo mật nghiêm ngặt</em></h2>
        <p class="sub">Mô hình phân quyền chặt chẽ theo vai trò (Role-Based Access Control) được thực thi bởi Firestore Security Rules và chặn chéo nền tảng (Role Gate).</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
          <!-- Actor 1 -->
          <div class="panel accent-pink">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag pink">user</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">MOBILE APP</span>
            </div>
            <h3 style="font-size: 22px; color: var(--vai);">Sinh viên / Khách</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              <strong>Họ là ai:</strong> Sinh viên ĐH FPT muốn tìm kiếm và tham gia sự kiện CLB.<br><br>
              <strong>Được làm gì:</strong>
              <div style="margin-top: 4px;">• Xem sự kiện công khai (`published`)</div>
              <div>• Nộp đơn đăng ký (`status = 'pending'`)</div>
              <div>• Hủy đơn của mình khi chưa bắt đầu</div>
              <div>• Quét QR điểm danh tại hội trường</div>
              <div>• Nhận thông báo FCM &amp; Xuất lịch PDF</div>
            </div>
            <div style="background: rgba(219,39,119,0.08); padding: 8px 10px; border-radius: 4px; font: 600 12.5px var(--mono); color: var(--pink); margin-top: 10px;">
              BẢO MẬT: Bị chặn không cho đăng nhập Web Admin
            </div>
          </div>

          <!-- Actor 2 -->
          <div class="panel accent-nghe">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag nghe">staff</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">WEB ADMIN</span>
            </div>
            <h3 style="font-size: 22px; color: var(--vai);">Trưởng Câu lạc bộ</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              <strong>Họ là ai:</strong> Cán bộ quản lý CLB, được gán đúng 1 `clubId` cụ thể.<br><br>
              <strong>Được làm gì:</strong>
              <div style="margin-top: 4px;">• Tạo &amp; chỉnh sửa sự kiện của CLB mình</div>
              <div>• Soạn nội dung sự kiện với trợ lý AI</div>
              <div>• Duyệt đơn (`approved`) / Từ chối kèm lý do</div>
              <div>• Mở/đóng phiên điểm danh `checkinSessions`</div>
              <div>• Phát mã QR động và xem số liệu realtime</div>
            </div>
            <div style="background: rgba(234,88,12,0.08); padding: 8px 10px; border-radius: 4px; font: 600 12.5px var(--mono); color: var(--nghe); margin-top: 10px;">
              BẢO MẬT: Rules kiểm tra `isStaffOf(event.clubId)`
            </div>
          </div>

          <!-- Actor 3 -->
          <div class="panel accent-son">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag son">admin</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">WEB ADMIN</span>
            </div>
            <h3 style="font-size: 22px; color: var(--vai);">Quản trị viên</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              <strong>Họ là ai:</strong> Cán bộ Phòng CTSV / Quản trị viên hệ thống trường.<br><br>
              <strong>Được làm gì:</strong>
              <div style="margin-top: 4px;">• Quản trị danh mục Câu lạc bộ toàn trường</div>
              <div>• Phân vai người dùng (`role`, gán `clubId`)</div>
              <div>• Phê duyệt sự kiện đề xuất (`published`)</div>
              <div>• Toàn quyền xem xét &amp; can thiệp đơn</div>
              <div>• Xem biểu đồ thống kê tổng thể</div>
            </div>
            <div style="background: rgba(29,78,216,0.08); padding: 8px 10px; border-radius: 4px; font: 600 12.5px var(--mono); color: var(--son); margin-top: 10px;">
              BẢO MẬT: Bất biến: Không ai được tự đổi role của mình
            </div>
          </div>

          <!-- Actor 4 -->
          <div class="panel accent-si">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag si">external</span>
              <span style="font: 600 13px var(--mono); color: var(--vai-3);">CLOUD SERVICE</span>
            </div>
            <h3 style="font-size: 22px; color: var(--vai);">Firebase Suite</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              <strong>Hệ thống ngoài:</strong> Nền tảng dịch vụ đám mây của Google cung cấp hạ tầng.<br><br>
              <strong>Các dịch vụ tích hợp:</strong>
              <div style="margin-top: 4px;">• <strong>Firebase Auth:</strong> Xác thực Google Sign-in</div>
              <div>• <strong>Cloud Firestore:</strong> Dữ liệu NoSQL realtime</div>
              <div>• <strong>Cloud Messaging:</strong> Thông báo đẩy FCM</div>
              <div>• <strong>Remote Config:</strong> Feature flags &amp; A/B test</div>
              <div>• <strong>Crashlytics:</strong> Báo cáo lỗi &amp; crash</div>
            </div>
            <div style="background: rgba(11,122,110,0.08); padding: 8px 10px; border-radius: 4px; font: 600 12.5px var(--mono); color: var(--si); margin-top: 10px;">
              BẢO MẬT: Firebase App Check chặn truy cập trái phép
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">RANH GIỚI BẢO MẬT: RBAC KIỂM SOÁT BỞI SECURITY RULES + CHẶN CHÉO TẠI CỔNG ĐĂNG NHẬP</span></div>
        <div class="foot-right"><span class="mono-meta">05 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 06 · MAIN FEATURES
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 06 · MAIN FEATURES -->
    <section class="slide" id="slide-06" data-page="06" data-title="06 Main Features">
      <div class="s-top">
        <div class="eb">P1 · PROBLEM · 06 MAIN FEATURES &amp; WORKFLOWS</div>
        <div class="pg-badge">BẢN VẼ 06 / 24</div>
      </div>

      <div class="s-head">
        <h2>4 Nhóm tính năng &amp; <em>3 Workflow lõi liên thiết bị sẽ demo</em></h2>
        <p class="sub">Tập trung vào tính năng mang lại giá trị nghiệp vụ thay vì các màn hình CRUD riêng lẻ; 3 workflow được chọn để trình diễn trực tiếp.</p>
      </div>

      <div class="s-body" style="flex-direction: column; gap: 18px;">
        <!-- 4 Nhóm tính năng chính -->
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;">
          <div class="panel" style="padding: 18px;">
            <div style="font: 800 16px var(--mono); color: var(--pink); margin-bottom: 6px;">F1 · KHÁM PHÁ &amp; ĐĂNG KÝ</div>
            <div style="font-size: 14.5px; color: var(--vai-2); line-height: 1.4;">
              • Danh mục sự kiện, bộ lọc CLB &amp; thời gian<br>
              • Chi tiết sự kiện, chỉ báo chỗ còn lại realtime<br>
              • Form đăng ký thông minh, lưu nháp cục bộ<br>
              • Khóa đơn nguyên tử chống gửi lặp (48-hex opId)
            </div>
          </div>

          <div class="panel" style="padding: 18px;">
            <div style="font: 800 16px var(--mono); color: var(--nghe); margin-bottom: 6px;">F2 · QUẢN TRỊ &amp; DUYỆT ĐƠN</div>
            <div style="font-size: 14.5px; color: var(--vai-2); line-height: 1.4;">
              • Quản lý sự kiện theo CLB, hỗ trợ soạn bài bằng AI<br>
              • Review Queue: danh sách chờ duyệt trực quan<br>
              • Phê duyệt đơn / Từ chối kèm lý do bắt buộc<br>
              • Khóa sức chứa nguyên tử `activeCount &lt;= capacity`
            </div>
          </div>

          <div class="panel" style="padding: 18px;">
            <div style="font: 800 16px var(--mono); color: var(--son); margin-bottom: 6px;">F3 · ĐIỂM DANH QR CODE</div>
            <div style="font-size: 14.5px; color: var(--vai-2); line-height: 1.4;">
              • Mở/đóng phiên điểm danh trên Web hội trường<br>
              • Sinh mã QR băm SHA-256 chống làm giả<br>
              • Quét mã tốc độ cao trên Mobile, phản hồi &lt;3s<br>
              • Biên nhận thành công A12, chặn quét trùng lặp
            </div>
          </div>

          <div class="panel" style="padding: 18px;">
            <div style="font: 800 16px var(--mono); color: var(--si); margin-bottom: 6px;">F4 · GIÁM SÁT &amp; BÁO CÁO</div>
            <div style="font-size: 14.5px; color: var(--vai-2); line-height: 1.4;">
              • Dashboard thống kê số liệu tham dự trực tiếp<br>
              • Thông báo đẩy FCM &amp; Hộp thư thông báo A09<br>
              • Xuất báo cáo PDF lịch tham gia đã ký số cục bộ<br>
              • Quản lý tài khoản, phân vai người dùng
            </div>
          </div>
        </div>

        <!-- 3 Thẻ Workflow lõi sẽ demo -->
        <div style="background: var(--cham-2); border: 2px solid var(--son); border-radius: 8px; padding: 18px 24px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <span style="font: 800 16px var(--display); color: var(--son); text-transform: uppercase;">
              ★ 3 WORKFLOW LÕI LIÊN THIẾT BỊ ĐƯỢC CHỌN ĐỂ TRÌNH DIỄN TRỰC TIẾP (DEMO):
            </span>
            <span class="tag son">CHIẾM 40% THỜI LƯỢNG BẢO VỆ</span>
          </div>

          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;">
            <div style="background: var(--cham-deep); border: 1px solid var(--cham-3); border-radius: 6px; padding: 12px 16px;">
              <div style="display: flex; align-items: center; gap: 8px;">
                <span class="tag pink">WF-01</span>
                <span style="font-weight: 800; color: var(--vai);">Gửi yêu cầu đăng ký</span>
              </div>
              <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 6px;">
                Sinh viên thao tác trên <strong>Mobile App</strong>: Điền form, xác thực thông tin, Firestore tạo đơn `PENDING`.
              </div>
            </div>

            <div style="background: var(--cham-deep); border: 1px solid var(--cham-3); border-radius: 6px; padding: 12px 16px;">
              <div style="display: flex; align-items: center; gap: 8px;">
                <span class="tag nghe">WF-02</span>
                <span style="font-weight: 800; color: var(--vai);">Xét duyệt đơn &amp; Khóa chỗ</span>
              </div>
              <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 6px;">
                Trưởng CLB thao tác trên <strong>Web Admin</strong>: Xem Review Queue, duyệt đơn (activeCount +1), gửi FCM Push về Mobile.
              </div>
            </div>

            <div style="background: var(--cham-deep); border: 1px solid var(--cham-3); border-radius: 6px; padding: 12px 16px;">
              <div style="display: flex; align-items: center; gap: 8px;">
                <span class="tag son">WF-03</span>
                <span style="font-weight: 800; color: var(--vai);">Điểm danh mã QR SHA-256</span>
              </div>
              <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 6px;">
                <strong>Web hội trường</strong> mở phiên phát QR; <strong>Mobile</strong> quét mã, ghi nhận `checkInAt` và Web nhảy số tức thì.
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">TIÊU CHUẨN WORKFLOW: 3-5 BƯỚC MỖI WF · RẼ NHÁNH THEO BR · KẾT THÚC BẰNG GIÁ TRỊ NGHIỆP VỤ</span></div>
        <div class="foot-right"><span class="mono-meta">06 / 24</span></div>
      </div>
    </section>
    """)

    return slides_html

print("mln_slides_p1.py ready.")
