# -*- coding: utf-8 -*-
"""
mln_slides_p3_p4.py
Defines Phase P3 (Demo 17 to 20), Phase P4 (Proof 21 to 24), Appendix 25 & Quality Gate G5.
No meta-prompts. Uses mln122 design language: technical eyebrow, conclusion titles,
spacious panels, mono badges, real embedded screenshots, and interactive reference links.
"""

def get_p3_p4_slides():
    slides_html = []

    # -------------------------------------------------------------------------
    # SLIDE 17 · DEMO PLAN
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 17 · DEMO PLAN -->
    <section class="slide" id="slide-17" data-page="17" data-title="17 Demo Plan">
      <div class="s-top">
        <div class="eb">P3 · DEMO · 17 DEMO PLAN &amp; STORYBOARD</div>
        <div class="pg-badge">BẢN VẼ 17 / 24</div>
      </div>

      <div class="s-head">
        <h2>Kế hoạch Demo: <em>Câu chuyện liên vai trò nối liền 3 Workflow chính</em></h2>
        <p class="sub">Minh chứng end-to-end hoàn chỉnh: kết quả của workflow trước là đầu vào trực tiếp của workflow tiếp theo, vận hành đồng bộ giữa Mobile và Web.</p>
      </div>

      <div class="s-body" style="flex-direction: column; gap: 20px;">
        <!-- 3 Cột Storyboard -->
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
          <!-- Bước 1 -->
          <div class="panel accent-pink">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag pink">BƯỚC 1 · KHỞI TẠO</span>
              <span style="font: 800 24px var(--display); color: var(--pink);">WF-01</span>
            </div>
            <h3 style="font-size: 20px; color: var(--vai);">Sinh viên nộp đơn đăng ký</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              • <strong>Thiết bị:</strong> Điện thoại Android thật<br>
              • <strong>Tài khoản:</strong> Sinh viên Nguyễn Văn A (K18)<br>
              • <strong>Thao tác:</strong> Khám phá sự kiện, điền form A05, bấm xác nhận gửi đơn.<br>
              • <strong>Kết quả:</strong> Đơn #REG-102 chuyển <code>PENDING</code>, tức thì hiển thị trên Web.
            </div>
          </div>

          <!-- Bước 2 -->
          <div class="panel accent-nghe">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag nghe">BƯỚC 2 · XÉT DUYỆT</span>
              <span style="font: 800 24px var(--display); color: var(--nghe);">WF-02</span>
            </div>
            <h3 style="font-size: 20px; color: var(--vai);">Trưởng CLB duyệt &amp; Khóa chỗ</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              • <strong>Thiết bị:</strong> Laptop Web Admin (Chrome)<br>
              • <strong>Tài khoản:</strong> Trưởng CLB F-Code (staff)<br>
              • <strong>Thao tác:</strong> Mở Review Queue, kiểm tra hồ sơ, bấm Phê duyệt.<br>
              • <strong>Kết quả:</strong> Đơn đổi <code>APPROVED</code>, `activeCount + 1`, bắn Push FCM về điện thoại.
            </div>
          </div>

          <!-- Bước 3 -->
          <div class="panel accent-son">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag son">BƯỚC 3 · ĐIỂM DANH</span>
              <span style="font: 800 24px var(--display); color: var(--son);">WF-03</span>
            </div>
            <h3 style="font-size: 20px; color: var(--vai);">Phát mã QR &amp; Quét check-in</h3>
            <div style="font-size: 14.5px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              • <strong>Thiết bị:</strong> Màn hình máy chiếu + Điện thoại<br>
              • <strong>Phát mã:</strong> Web Admin mở phiên phát mã QR động<br>
              • <strong>Thao tác:</strong> Sinh viên quét mã bằng camera A11.<br>
              • <strong>Kết quả:</strong> Nhận biên nhận A12, Web nhảy số có mặt trong 1 giây.
            </div>
          </div>
        </div>

        <!-- Thanh chuẩn bị dữ liệu và kịch bản dự phòng -->
        <div class="panel" style="padding: 16px 24px; background: var(--cham-2);">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <div style="font-size: 14.5px; color: var(--vai);">
              <strong>DỮ LIỆU ĐÃ CHUẨN BỊ SẴN TRÊN FIRESTORE:</strong> Sự kiện <em>"Workshop Lập trình Flutter &amp; Firebase"</em> của CLB F-Code • Sức chứa 30 chỗ • Seed sẵn 14 đơn đã duyệt • 1 Đơn chờ duyệt trực tiếp.
            </div>
            <span class="tag si">SẴN SÀNG LIVE DEMO</span>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">LIVE ENVIRONMENT: ANDROID PHYSICAL DEVICE + WEB HOSTING ON FIREBASE</span></div>
        <div class="foot-right"><span class="mono-meta">17 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 18 · DEMO WF-01 (Real Mobile Screenshots Embedded!)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 18 · DEMO WF-01 -->
    <section class="slide" id="slide-18" data-page="18" data-title="18 Demo WF-01">
      <div class="s-top">
        <div class="eb">P3 · DEMO · 18 WF-01: GỬI YÊU CẦU ĐĂNG KÝ (MOBILE APP)</div>
        <div class="pg-badge">BẢN VẼ 18 / 24</div>
      </div>

      <div class="s-head">
        <h2>Demo WF-01: <em>Sinh viên gửi yêu cầu đăng ký (Mobile App)</em></h2>
        <p class="sub">Khởi tạo luồng nghiệp vụ: Sinh viên xem chi tiết workshop, điền form đăng ký, xác nhận và nhận đơn PENDING.</p>
      </div>

      <div class="s-body">
        <!-- Cột trái: Kịch bản và các nhánh kiểm thử trực tiếp -->
        <div style="flex: 0.9; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel accent-pink" style="padding: 16px;">
            <div style="font: 800 15px var(--display); color: var(--pink); margin-bottom: 6px;">KỊCH BẢN THAO TÁC TRỰC TIẾP:</div>
            <div style="font-size: 14.5px; color: var(--vai); line-height: 1.45;">
              1. Sinh viên mở tab Khám phá (A02), chọn workshop F-Code.<br>
              2. Đọc thông tin chi tiết (A04), bấm nút <strong>"Đăng ký tham gia"</strong>.<br>
              3. Điền thông tin cá nhân: Khóa K18, MSSV SE180001 (A05).<br>
              4. Bấm <strong>"Xác nhận nộp đơn"</strong> → Nhận ngay màn hình thông báo A06 xác nhận đơn ở trạng thái <code>PENDING</code>.
            </div>
          </div>

          <div class="panel accent-red" style="padding: 14px; border-top: 4px solid var(--red);">
            <div style="font: 800 14px var(--display); color: var(--red); margin-bottom: 4px;">NGOẠI LỆ ĐÃ XỬ LÝ (EXCEPTION PATHS):</div>
            <div style="font-size: 13.5px; color: var(--vai-2); line-height: 1.4;">
              • <strong>Bỏ trống MSSV/Email:</strong> Form A05 lập tức báo đỏ, chặn nút bấm (BR-02).<br>
              • <strong>Gửi đơn khi hết chỗ:</strong> Hệ thống báo lỗi và không tạo đơn (BR-01).
            </div>
          </div>

          <div class="panel" style="padding: 12px 16px; background: rgba(219,39,119,0.06);">
            <div style="font: 600 13px var(--mono); color: var(--pink);">MINH CHỨNG QUAN SÁT TỨC THỜI:</div>
            <div style="font-size: 13.5px; color: var(--vai); margin-top: 4px;">
              Đơn #REG-102 vừa tạo xuất hiện ngay lập tức trên Review Queue của Web Admin mà không cần tải lại trang.
            </div>
          </div>
        </div>

        <!-- Cột phải: 3 Ảnh chụp thật trên điện thoại Android -->
        <div class="panel" style="flex: 1.1; padding: 14px; background: var(--cham-2); justify-content: space-between;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
            <span class="tag pink">ẢNH CHỤP THỰC TẾ TRÊN ANDROID (EVIDENCE)</span>
            <span style="font: 600 12px var(--mono); color: var(--vai-3);">A04 → A05 → A06</span>
          </div>

          <div style="flex: 1; display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; align-items: center;">
            <div style="height: 480px; background: #000; border-radius: 20px; padding: 6px; overflow: hidden; box-shadow: 0 8px 24px rgba(0,0,0,0.15);">
              <img src="../evidence/instrumentation/analytics/view-event-detail-A04.png?v=mobile_final" alt="A04 Event Detail" 
                   style="width: 100%; height: 100%; object-fit: cover; object-position: top; border-radius: 14px;">
            </div>
            <div style="height: 480px; background: #000; border-radius: 20px; padding: 6px; overflow: hidden; box-shadow: 0 8px 24px rgba(0,0,0,0.15);">
              <img src="../evidence/instrumentation/analytics/booking-submit-register.png?v=mobile_final" alt="A05 Form" 
                   style="width: 100%; height: 100%; object-fit: cover; object-position: top; border-radius: 14px;">
            </div>
            <div style="height: 480px; background: #000; border-radius: 20px; padding: 6px; overflow: hidden; box-shadow: 0 8px 24px rgba(0,0,0,0.15);">
              <img src="../evidence/instrumentation/analytics/booking-result-register.png?v=mobile_final" alt="A06 Result" 
                   style="width: 100%; height: 100%; object-fit: cover; object-position: top; border-radius: 14px;">
            </div>
          </div>

          <div style="display: flex; justify-content: space-between; font: 600 12px var(--mono); color: var(--vai-3); margin-top: 8px; padding: 0 10px;">
            <span>1. Xem chi tiết A04</span>
            <span>2. Điền form đăng ký A05</span>
            <span>3. Xác nhận PENDING A06</span>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">WF-01 COMPLETED: REGISTRATION #REG-102 CREATED WITH STATUS = 'PENDING'</span></div>
        <div class="foot-right"><span class="mono-meta">18 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 19 · DEMO WF-02 (Web Admin + Real FCM Push Evidence!)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 19 · DEMO WF-02 -->
    <section class="slide" id="slide-19" data-page="19" data-title="19 Demo WF-02">
      <div class="s-top">
        <div class="eb">P3 · DEMO · 19 WF-02: XÉT DUYỆT ĐƠN &amp; KHÓA CHỖ (WEB ADMIN)</div>
        <div class="pg-badge">BẢN VẼ 19 / 24</div>
      </div>

      <div class="s-head">
        <h2>Demo WF-02: <em>Trưởng CLB xét duyệt đơn (Web Admin) &amp; Push FCM</em></h2>
        <p class="sub">Xử lý nghiệp vụ: Atomic Transaction duyệt đơn tăng `activeCount + 1` và tự động bắn thông báo đẩy FCM về điện thoại sinh viên.</p>
      </div>

      <div class="s-body">
        <!-- Cột trái: Kịch bản và Logic Transaction -->
        <div style="flex: 0.9; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel accent-nghe" style="padding: 16px;">
            <div style="font: 800 15px var(--display); color: var(--nghe); margin-bottom: 6px;">KỊCH BẢN THAO TÁC TRỰC TIẾP:</div>
            <div style="font-size: 14.5px; color: var(--vai); line-height: 1.45;">
              1. Trưởng CLB mở màn hình <strong>Review Queue</strong> trên Web Admin.<br>
              2. Nhìn thấy đơn #REG-102 của sinh viên Nguyễn Văn A vừa nộp.<br>
              3. Bấm <strong>"Phê duyệt"</strong> → Firestore chạy Atomic Transaction:
                 đơn chuyển sang <code>APPROVED</code>, `activeCount` tăng từ 14 lên 15/30.<br>
              4. Điện thoại của sinh viên lập tức rung và hiện thông báo đẩy FCM.
            </div>
          </div>

          <div class="panel accent-red" style="padding: 14px; border-top: 4px solid var(--red);">
            <div style="font: 800 14px var(--display); color: var(--red); margin-bottom: 4px;">NGOẠI LỆ ĐÃ XỬ LÝ (EXCEPTION PATHS):</div>
            <div style="font-size: 13.5px; color: var(--vai-2); line-height: 1.4;">
              • <strong>Từ chối đơn thiếu lý do (&lt;3 ký tự):</strong> Hộp thoại báo đỏ, Security Rules từ chối ghi dữ liệu (BR-03).<br>
              • <strong>Trái quyền CLB:</strong> Không được phép can thiệp đơn của CLB khác (403 Forbidden).
            </div>
          </div>

          <div class="panel" style="padding: 12px 16px; background: rgba(234,88,12,0.06);">
            <div style="font: 600 13px var(--mono); color: var(--nghe);">KẾT QUẢ ĐỒNG BỘ HAI CHIỀU:</div>
            <div style="font-size: 13.5px; color: var(--vai); margin-top: 4px;">
              Mobile tự động cập nhật vé QR mà sinh viên không cần bấm làm mới trang; Web chuyển đơn sang danh sách đã duyệt.
            </div>
          </div>
        </div>

        <!-- Cột phải: 2 Khối minh chứng (Web Admin Interface + FCM Push Android) -->
        <div style="flex: 1.1; display: flex; flex-direction: column; gap: 14px;">
          <!-- Khung Web Admin Review Queue Mockup sắc nét -->
          <div class="panel" style="flex: 1; padding: 16px; background: #FFFFFF; border: 1.5px solid var(--cham-3);">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--cham-3); padding-bottom: 8px; margin-bottom: 10px;">
              <span style="font: 700 14px var(--mono); color: var(--nghe);">FLUTTER WEB ADMIN: REVIEW QUEUE (/reviews)</span>
              <span class="tag si">● WEBSOCKET LIVE</span>
            </div>

            <div style="background: var(--cham); border-radius: 6px; padding: 12px; margin-bottom: 10px;">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span style="font-weight: 800; font-size: 15px;">Workshop Lập trình Flutter &amp; Firebase · CLB F-Code</span>
                <span class="tag nghe">Sức chứa: 15 / 30 chỗ</span>
              </div>
            </div>

            <table class="spec-table" style="font-size: 13.5px;">
              <thead>
                <tr>
                  <th>Mã đơn</th>
                  <th>Sinh viên</th>
                  <th>MSSV</th>
                  <th>Thời gian gửi</th>
                  <th style="text-align: right;">Thao tác duyệt</th>
                </tr>
              </thead>
              <tbody>
                <tr style="background: rgba(234,88,12,0.08);">
                  <td style="font-weight: 700; color: var(--nghe);">#REG-102</td>
                  <td><strong>Nguyễn Văn A</strong></td>
                  <td>SE180001</td>
                  <td>Vừa xong</td>
                  <td style="text-align: right;">
                    <span class="tag si" style="cursor: pointer;">✓ DUYỆT</span>
                    <span class="tag red" style="cursor: pointer;">✗ TỪ CHỐI</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Ảnh chụp thật thông báo đẩy FCM trên Android -->
          <div class="panel accent-pink" style="padding: 12px 16px; background: #FFFFFF;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 700 13px var(--mono); color: var(--pink);">MINH CHỨNG THẬT: THÔNG BÁO ĐẨY FCM TRÊN ANDROID</span>
              <span class="tag pink">EVIDENCE</span>
            </div>
            <div style="height: 120px; overflow: hidden; border-radius: 6px; border: 1px solid var(--cham-3);">
              <img src="../evidence/instrumentation/fcm/foreground-console-and-receipt.png" alt="FCM Notification Receipt" 
                   style="width: 100%; height: 100%; object-fit: cover; object-position: top;">
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">WF-02 COMPLETED: TRANSACTION COMMITTED · STATUS = 'APPROVED' · ACTIVECOUNT: 14 → 15</span></div>
        <div class="foot-right"><span class="mono-meta">19 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 20 · DEMO WF-03 (Web QR Live + Real Receipt A12 Embedded!)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 20 · DEMO WF-03 -->
    <section class="slide" id="slide-20" data-page="20" data-title="20 Demo WF-03">
      <div class="s-top">
        <div class="eb">P3 · DEMO · 20 WF-03: ĐIỂM DANH QR CODE (WEB &amp; MOBILE)</div>
        <div class="pg-badge">BẢN VẼ 20 / 24</div>
      </div>

      <div class="s-head">
        <h2>Demo WF-03: <em>Điểm danh QR tại sự kiện &amp; Biên nhận A12 realtime</em></h2>
        <p class="sub">Tổng hợp kết quả: Màn hình hội trường phát mã QR băm SHA-256; Sinh viên quét mã, nhận biên nhận và Web Admin cập nhật số lượng có mặt tức thì.</p>
      </div>

      <div class="s-body">
        <!-- Cột trái: Kịch bản và Logic Check-in -->
        <div style="flex: 0.9; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel accent-son" style="padding: 16px;">
            <div style="font: 800 15px var(--display); color: var(--son); margin-bottom: 6px;">KỊCH BẢN THAO TÁC TRỰC TIẾP:</div>
            <div style="font-size: 14.5px; color: var(--vai); line-height: 1.45;">
              1. Cán bộ CLB mở màn hình <strong>Live QR Panel</strong> trên Web hội trường.<br>
              2. Hệ thống sinh mã QR băm SHA-256 đối chiếu `checkinSessions`.<br>
              3. Sinh viên mở camera quét mã QR (A11) trên màn hình máy chiếu.<br>
              4. Xác thực thành công trong <strong>&lt;1 giây</strong> → Điện thoại nhận biên nhận A12 và Web nhảy số có mặt.
            </div>
          </div>

          <div class="panel accent-red" style="padding: 14px; border-top: 4px solid var(--red);">
            <div style="font: 800 14px var(--display); color: var(--red); margin-bottom: 4px;">NGOẠI LỆ ĐÃ XỬ LÝ (EXCEPTION PATHS):</div>
            <div style="font-size: 13.5px; color: var(--vai-2); line-height: 1.4;">
              • <strong>Quét khi phiên chưa mở:</strong> Báo lỗi 'Phiên điểm danh chưa kích hoạt'.<br>
              • <strong>Quét lần 2 (BR-05):</strong> Chặn ghi trùng; báo 'Đã điểm danh lúc 08:30'.<br>
              • <strong>Quét mã sai sự kiện:</strong> Báo lỗi mã không hợp lệ.
            </div>
          </div>

          <div class="panel" style="padding: 12px 16px; background: rgba(11,122,110,0.06);">
            <div style="font: 600 13px var(--mono); color: var(--si);">KẾT QUẢ ĐỒNG BỘ:</div>
            <div style="font-size: 13.5px; color: var(--vai); margin-top: 4px;">
              Bản ghi Registration lưu <code>checkInAt = serverTimestamp()</code>; bảo vệ quyền riêng tư PII theo yêu cầu đề bài.
            </div>
          </div>
        </div>

        <!-- Cột phải: 2 Khối minh chứng (Màn hình chiếu Web Live QR + Biên nhận A12) -->
        <div style="flex: 1.1; display: flex; flex-direction: column; gap: 14px;">
          <!-- Khung Web Live QR Panel Mockup -->
          <div class="panel" style="flex: 1; padding: 16px; background: #FFFFFF; border: 1.5px solid var(--cham-3);">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--cham-3); padding-bottom: 8px; margin-bottom: 10px;">
              <span style="font: 700 14px var(--mono); color: var(--son);">WEB ADMIN: PHIÊN ĐIỂM DANH LIVE (/checkin)</span>
              <span class="tag si">● SESSION ACTIVE</span>
            </div>

            <div style="display: flex; align-items: center; justify-content: space-around; padding: 10px 0;">
              <!-- Simulated High-Res QR Block -->
              <div style="width: 110px; height: 110px; background: #0F172A; border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #FFF; font: 700 12px var(--mono); text-align: center; padding: 8px;">
                <span>[QR CODE]</span>
                <span style="font-size: 9px; color: #94A3B8; margin-top: 4px;">SHA-256 ENCRYPTED</span>
              </div>

              <div style="text-align: left;">
                <div style="font: 600 13px var(--mono); color: var(--vai-3);">SỐ LƯỢNG ĐÃ CÓ MẶT:</div>
                <div style="font: 800 44px/1 var(--display); color: var(--si); margin: 6px 0;">15 / 15</div>
                <span class="tag si">TỶ LỆ THAM DỰ: 100%</span>
              </div>
            </div>
          </div>

          <!-- Ảnh chụp thật biên nhận điểm danh A12 trên Android -->
          <div class="panel accent-si" style="padding: 12px 16px; background: #FFFFFF;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 700 13px var(--mono); color: var(--si);">MINH CHỨNG THẬT: BIÊN NHẬN ĐIỂM DANH THÀNH CÔNG A12</span>
              <span class="tag si">EVIDENCE</span>
            </div>
            <div style="height: 120px; overflow: hidden; border-radius: 6px; border: 1px solid var(--cham-3);">
              <img src="../evidence/instrumentation/analytics/booking-result-confirmed.png" alt="A12 Confirmed Receipt" 
                   style="width: 100%; height: 100%; object-fit: cover; object-position: top;">
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">WF-03 COMPLETED: ATTENDED VERIFIED · checkInAt RECORDED IN FIRESTORE</span></div>
        <div class="foot-right"><span class="mono-meta">20 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 21 · TESTING & VERIFICATION (Real Crashlytics Embedded!)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 21 · TESTING & VERIFICATION -->
    <section class="slide" id="slide-21" data-page="21" data-title="21 Testing">
      <div class="s-top">
        <div class="eb">P4 · PROOF · 21 TESTING &amp; VERIFICATION</div>
        <div class="pg-badge">BẢN VẼ 21 / 24</div>
      </div>

      <div class="s-head">
        <h2>Kiểm thử đa tầng: <em>132 Tests tự động 100% Pass &amp; 0 Crash</em></h2>
        <p class="sub">Chiến lược kiểm thử toàn diện bảo đảm tính toàn vẹn hệ thống: Mobile Unit/Widget Tests, Web Tests, Core Tests và Security Rules Emulator.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1.25; display: flex; flex-direction: column; gap: 14px;">
          <!-- 3 Thẻ số liệu thống kê lớn -->
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px;">
            <div class="panel accent-si" style="text-align: center; padding: 14px;">
              <div style="font: 800 42px/1 var(--display); color: var(--si);">132</div>
              <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-top: 4px;">TESTS TỰ ĐỘNG</div>
            </div>
            <div class="panel accent-son" style="text-align: center; padding: 14px;">
              <div style="font: 800 42px/1 var(--display); color: var(--son);">100%</div>
              <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-top: 4px;">TỶ LỆ PASS</div>
            </div>
            <div class="panel accent-nghe" style="text-align: center; padding: 14px;">
              <div style="font: 800 42px/1 var(--display); color: var(--nghe);">0</div>
              <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-top: 4px;">CRASH TRÊN THIẾT BỊ</div>
            </div>
          </div>

          <!-- Bảng 4 tầng kiểm thử chi tiết -->
          <table class="spec-table" style="font-size: 14px;">
            <thead>
              <tr>
                <th style="width: 25%;">Tầng kiểm thử</th>
                <th style="width: 45%;">Phạm vi &amp; Công cụ kiểm thử</th>
                <th style="width: 30%; text-align: right;">Kết quả kiểm chứng</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>Mobile App Tests</strong></td>
                <td>86 bài test: Riverpod ViewModels, Screen Identity, Accessibility, Role Gate</td>
                <td style="text-align: right;"><span class="tag si">86 / 86 PASS</span></td>
              </tr>
              <tr>
                <td><strong>Web Admin Tests</strong></td>
                <td>28 bài test: Admin Features, AI Event Assistant, Review Queue, Policy Tests</td>
                <td style="text-align: right;"><span class="tag si">28 / 28 PASS</span></td>
              </tr>
              <tr>
                <td><strong>Core Package Tests</strong></td>
                <td>6 bài test: Models validation, Registration status mapping, JSON serialization</td>
                <td style="text-align: right;"><span class="tag si">6 / 6 PASS</span></td>
              </tr>
              <tr>
                <td><strong>Security Rules Emulator</strong></td>
                <td>12 nhóm kiểm thử: Allowed/Denied cho cả 3 roles (user, staff, admin)</td>
                <td style="text-align: right;"><span class="tag si">12 / 12 NHÓM PASS</span></td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Cột phải: Ảnh Crashlytics Dashboard thật -->
        <div style="flex: 0.75; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel accent-si" style="flex: 1; padding: 16px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font: 700 13px var(--mono); color: var(--si);">CRASHLYTICS DASHBOARD</span>
              <span class="tag si">100% CRASH-FREE</span>
            </div>
            <div style="flex: 1; overflow: hidden; border-radius: 6px; border: 1px solid var(--cham-3);">
              <img src="../evidence/instrumentation/crashlytics/crashes-dashboard.png" alt="Crashlytics Dashboard" 
                   style="width: 100%; height: 100%; object-fit: cover; object-position: top;">
            </div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 8px; text-align: center;">
              Minh chứng thực tế đo đạc từ Firebase Crashlytics Console
            </div>
          </div>

          <a href="../docs/test-report.md" target="_blank" 
             style="text-decoration: none; background: var(--cham-2); border: 1px solid var(--cham-3); padding: 10px 14px; border-radius: 6px; display: flex; justify-content: space-between; align-items: center; font: 600 13px var(--mono); color: var(--son);">
            <span>📄 XEM TOÀN VĂN TEST-REPORT.MD</span>
            <span>↗</span>
          </a>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">AUTOMATED QA: 132 TESTS RUN VIA FLUTTER TEST &amp; FIRESTORE EMULATOR · 0 REGRESSIONS</span></div>
        <div class="foot-right"><span class="mono-meta">21 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 22 · ACHIEVEMENTS
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 22 · ACHIEVEMENTS -->
    <section class="slide" id="slide-22" data-page="22" data-title="22 Achievements">
      <div class="s-top">
        <div class="eb">P4 · PROOF · 22 ACHIEVEMENTS &amp; DELIVERABLES</div>
        <div class="pg-badge">BẢN VẼ 22 / 24</div>
      </div>

      <div class="s-head">
        <h2>Kết quả đạt được: <em>Cắt giảm 90% thời gian check-in &amp; 0 lỗi sức chứa</em></h2>
        <p class="sub">Đối chiếu trực tiếp cam kết ban đầu với số đo thực nghiệm kiểm chứng được trên môi trường thật.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px;">
          <!-- Cột 1 -->
          <div class="panel accent-pink">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag pink">CAM KẾT BAN ĐẦU</span>
              <span style="font: 800 24px var(--display); color: var(--pink);">01</span>
            </div>
            <h3 style="font-size: 20px; color: var(--vai);">Mục tiêu đồ án</h3>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              • Chấm dứt cảnh xếp hàng dò tên giấy tại hội trường.<br>
              • Ngăn chặn 100% tình trạng nhận vượt sức chứa phòng.<br>
              • Xây dựng hệ thống hoàn chỉnh chạy trên thiết bị thật.<br>
              • Tích hợp trợ lý AI thông minh hỗ trợ cán bộ CLB.
            </div>
          </div>

          <!-- Cột 2 -->
          <div class="panel accent-nghe">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag nghe">ĐÃ HIỆN THỰC HÓA</span>
              <span style="font: 800 24px var(--display); color: var(--nghe);">02</span>
            </div>
            <h3 style="font-size: 20px; color: var(--vai);">Sản phẩm bàn giao</h3>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              • <strong>12 Màn hình Mobile App</strong> (Flutter Android 10+).<br>
              • <strong>5 Màn hình Web Admin</strong> (Flutter Web Hosting).<br>
              • <strong>100% Security Rules</strong> bảo vệ toàn bộ 7 collections.<br>
              • <strong>Trợ lý Gemini AI</strong> sinh nội dung JSON Level 2.
            </div>
          </div>

          <!-- Cột 3 -->
          <div class="panel accent-si">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="tag si">SỐ ĐO THỰC NGHIỆM</span>
              <span style="font: 800 24px var(--display); color: var(--si);">03</span>
            </div>
            <h3 style="font-size: 20px; color: var(--vai);">Kết quả đo lường</h3>
            <div style="font-size: 15px; color: var(--vai-2); margin-top: 10px; line-height: 1.45; flex: 1;">
              • Check-in QR: <strong>&lt;3 giây/người</strong> (trước: 45–60s).<br>
              • Tỷ lệ vượt sức chứa: <strong>0 trường hợp</strong> (Atomic Tx).<br>
              • Tỷ lệ kiểm thử tự động: <strong>132/132 bài Pass</strong>.<br>
              • Độ ổn định ứng dụng: <strong>100% Crash-free sessions</strong>.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">MEASURED RESULTS: CHECK-IN TIME CUT BY 90% · ZERO CAPACITY OVERFLOW ERRORS</span></div>
        <div class="foot-right"><span class="mono-meta">22 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 23 · LIMITATIONS & NEXT STEPS
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 23 · LIMITATIONS & NEXT STEPS -->
    <section class="slide" id="slide-23" data-page="23" data-title="23 Limitations">
      <div class="s-top">
        <div class="eb">P4 · PROOF · 23 LIMITATIONS &amp; ROADMAP</div>
        <div class="pg-badge">BẢN VẼ 23 / 24</div>
      </div>

      <div class="s-head">
        <h2>Giới hạn hệ thống: <em>Đánh giá trung thực &amp; Lộ trình nâng cấp</em></h2>
        <p class="sub">Nhận diện rõ các ranh giới kỹ thuật hiện tại và kế hoạch kiến trúc để mở rộng cho các phiên bản tiếp theo.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: flex; flex-direction: column; gap: 14px;">
          <table class="spec-table">
            <thead>
              <tr>
                <th style="width: 25%;">Giới hạn kỹ thuật</th>
                <th style="width: 35%;">Tác động thực tế</th>
                <th style="width: 15%; text-align: center;">Mức độ</th>
                <th style="width: 25%;">Lộ trình giải quyết (Roadmap)</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>Điểm danh phụ thuộc Internet</strong></td>
                <td>Nếu hội trường tầng hầm mất sóng di động, việc đối chiếu Firestore bị gián đoạn.</td>
                <td style="text-align: center;"><span class="tag red">Cao</span></td>
                <td>Áp dụng chữ ký số Ed25519 cho vé QR để quét offline không cần mạng.</td>
              </tr>
              <tr>
                <td><strong>Chưa stress-test tải nặng</strong></td>
                <td>Chưa đo được ngưỡng chịu tải đồng thời &gt;1.000 request/giây do hạn mức Firebase Spark.</td>
                <td style="text-align: center;"><span class="tag nghe">Trung bình</span></td>
                <td>Chạy bộ benchmark với Locust / K6 khi nâng cấp lên gói Firebase Blaze.</td>
              </tr>
              <tr>
                <td><strong>Chưa có cổng thanh toán</strong></td>
                <td>Hệ thống hiện chỉ áp dụng cho các sự kiện miễn phí của sinh viên trong trường.</td>
                <td style="text-align: center;"><span class="tag nghe">Trung bình</span></td>
                <td>Tích hợp cổng thanh toán VietQR / PayOS webhook cho vé sự kiện có phí.</td>
              </tr>
              <tr>
                <td><strong>Chưa hỗ trợ nền tảng iOS</strong></td>
                <td>Sinh viên dùng iPhone chưa có ứng dụng native, phải dùng tạm qua trình duyệt.</td>
                <td style="text-align: center;"><span class="tag son">Thấp</span></td>
                <td>Build và đóng gói ứng dụng cho hệ điều hành iOS (Flutter đã sẵn sàng).</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">ENGINEERING INTEGRITY: HONEST BOUNDARY ASSESSMENT WITH CLEAR TECHNICAL RESOLUTION PLANS</span></div>
        <div class="foot-right"><span class="mono-meta">23 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 24 · CONCLUSION (Interactive Action Pill Buttons Embedded!)
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 24 · CONCLUSION -->
    <section class="slide" id="slide-24" data-page="24" data-title="24 Conclusion">
      <div class="s-top">
        <div class="eb">P4 · PROOF · 24 CONCLUSION &amp; Q&amp;A</div>
        <div class="pg-badge">BẢN VẼ 24 / 24</div>
      </div>

      <div class="s-head">
        <h2>Kết luận: <em>Giải pháp trọn vẹn, sản phẩm chạy thật &amp; minh chứng minh bạch</em></h2>
        <p class="sub">Nhóm 4 xin chân thành cảm ơn Quý Thầy/Cô trong Hội đồng và sẵn sàng bước vào phần Hỏi - Đáp (Q&amp;A).</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: flex; flex-direction: column; gap: 20px;">
          <!-- 3 Thông điệp chính -->
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div class="panel accent-pink">
              <div style="font: 800 24px var(--display); color: var(--pink); margin-bottom: 6px;">01. PROBLEM SOLVED</div>
              <div style="font-size: 18px; font-weight: 800; color: var(--vai);">Giải quyết đúng vấn đề</div>
              <div style="font-size: 15px; color: var(--vai-2); margin-top: 8px; line-height: 1.45;">
                Chấm dứt hoàn toàn tình trạng ùn tắc check-in giấy (&lt;3s/người) và Atomic Capacity Invariants bảo đảm 0 lỗi quá tải.
              </div>
            </div>

            <div class="panel accent-nghe">
              <div style="font: 800 24px var(--display); color: var(--nghe); margin-bottom: 6px;">02. PRODUCTION READY</div>
              <div style="font-size: 18px; font-weight: 800; color: var(--vai);">Sản phẩm hoàn chỉnh</div>
              <div style="font-size: 15px; color: var(--vai-2); margin-top: 8px; line-height: 1.45;">
                Hệ thống Serverless liên vai trò vận hành đồng bộ trên cả Android thật và Web Hosting; tích hợp trợ lý AI Gemini thông minh.
              </div>
            </div>

            <div class="panel accent-si">
              <div style="font: 800 24px var(--display); color: var(--si); margin-bottom: 6px;">03. VERIFIED PROOF</div>
              <div style="font-size: 18px; font-weight: 800; color: var(--vai);">Minh chứng minh bạch</div>
              <div style="font-size: 15px; color: var(--vai-2); margin-top: 8px; line-height: 1.45;">
                Đạt 132/132 bài kiểm thử tự động, 100% Rules Emulator Pass, Crashlytics 0 lỗi và hồ sơ mã nguồn sạch sẽ, sẵn sàng chuyển giao.
              </div>
            </div>
          </div>

          <!-- Các nút liên kết tương tác mở tài nguyên -->
          <div class="panel" style="padding: 18px 24px; background: var(--cham-2);">
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 12px; text-transform: uppercase;">
              ĐƯỜNG DẪN TƯƠNG TÁC TRỰC TIẾP (CLICK ĐỂ MỞ TÀI NGUYÊN):
            </div>
            <div style="display: flex; gap: 16px; flex-wrap: wrap;">
              <a href="https://eventhub-group4.web.app" target="_blank" 
                 style="text-decoration: none; background: var(--son); color: #FFF; font: 600 14px var(--mono); padding: 10px 18px; border-radius: 6px;">
                🌐 LIVE WEB ADMIN ↗
              </a>
              <a href="https://github.com/thinhcri/PRM393_Lab03_Group4" target="_blank" 
                 style="text-decoration: none; background: #0F172A; color: #FFF; font: 600 14px var(--mono); padding: 10px 18px; border-radius: 6px;">
                💻 GITHUB REPOSITORY ↗
              </a>
              <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393" target="_blank" 
                 style="text-decoration: none; background: rgba(219,39,119,0.12); color: var(--pink); border: 1.5px solid var(--pink); font: 600 14px var(--mono); padding: 10px 18px; border-radius: 6px;">
                🎨 FIGMA DESIGN SYSTEM ↗
              </a>
              <a href="../docs/test-report.md" target="_blank" 
                 style="text-decoration: none; background: rgba(11,122,110,0.12); color: var(--si); border: 1.5px solid var(--si); font: 600 14px var(--mono); padding: 10px 18px; border-radius: 6px;">
                📋 BÁO CÁO TEST-REPORT.MD ↗
              </a>
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">THANK YOU FOR YOUR ATTENTION · READY FOR COMMITTEE QUESTIONS &amp; DEFENSE</span></div>
        <div class="foot-right"><span class="mono-meta">24 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 25 · APPENDIX / BACKUP
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 25 · APPENDIX / BACKUP -->
    <section class="slide" id="slide-25" data-page="25" data-title="25 Appendix">
      <div class="s-top">
        <div class="eb">PHỤ LỤC · 25 APPENDIX / BACKUP (TÀI LIỆU DỰ PHÒNG PHẢN BIỆN)</div>
        <div class="pg-badge">PHỤ LỤC A1..A6</div>
      </div>

      <div class="s-head">
        <h2>Tài liệu dự phòng: <em>Sẵn sàng phản biện chuyên sâu từng chuyên đề</em></h2>
        <p class="sub">Hồ sơ kỹ thuật đầy đủ gắn trực tiếp với các câu hỏi chất vấn dự kiến của Hội đồng, mở tức thì khi được yêu cầu.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px;">
          <!-- A1 -->
          <div class="panel accent-pink">
            <div style="font: 800 16px var(--mono); color: var(--pink); margin-bottom: 6px;">A1 · UI &amp; MÀN HÌNH PHỤ</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.4; flex: 1;">
              Hồ sơ đặc tả 12 màn hình Mobile A01..A12, 5 màn hình Web Admin, Figma Design Tokens và bảng ánh xạ components.
            </div>
            <a href="../docs/flutter-handoff.md" target="_blank" style="font: 600 13px var(--mono); color: var(--pink); text-decoration: none; margin-top: 8px;">
              📄 MỞ FLUTTER-HANDOFF.MD ↗
            </a>
          </div>

          <!-- A2 -->
          <div class="panel accent-nghe">
            <div style="font: 800 16px var(--mono); color: var(--nghe); margin-bottom: 6px;">A2 · SRS &amp; SECURITY RULES</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.4; flex: 1;">
              Toàn văn mã nguồn file `firebase/firestore.rules`, cơ chế hàm `getAfter()`, kiểm soát phân quyền 3 roles và chống giả mạo request.
            </div>
            <a href="../firebase/firestore.rules" target="_blank" style="font: 600 13px var(--mono); color: var(--nghe); text-decoration: none; margin-top: 8px;">
              📄 MỞ FIRESTORE.RULES ↗
            </a>
          </div>

          <!-- A3 -->
          <div class="panel accent-son">
            <div style="font: 800 16px var(--mono); color: var(--son); margin-bottom: 6px;">A3 · TEST CASES &amp; ARTEMIS</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.4; flex: 1;">
              Chi tiết 132 bài test, nhật ký kiểm thử tự động ARTEMIS E2E trên Android, 12 nhóm Rules Emulator và logcat audit.
            </div>
            <a href="../docs/test-report.md" target="_blank" style="font: 600 13px var(--mono); color: var(--son); text-decoration: none; margin-top: 8px;">
              📄 MỞ TEST-REPORT.MD ↗
            </a>
          </div>

          <!-- A4 -->
          <div class="panel accent-si">
            <div style="font: 800 16px var(--mono); color: var(--si); margin-bottom: 6px;">A4 · PHYSICAL SCHEMA ĐẦY ĐỦ</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.4; flex: 1;">
              Đặc tả chi tiết 7 collections NoSQL, subcollections, chỉ mục composite index `firestore.indexes.json` và cấu trúc metadata.
            </div>
            <a href="../docs/data-model.md" target="_blank" style="font: 600 13px var(--mono); color: var(--si); text-decoration: none; margin-top: 8px;">
              📄 MỞ DATA-MODEL.MD ↗
            </a>
          </div>

          <!-- A5 -->
          <div class="panel accent-son">
            <div style="font: 800 16px var(--mono); color: var(--son); margin-bottom: 6px;">A5 · TRỢ LÝ AI GEMINI (MỤC 8)</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.4; flex: 1;">
              Đặc tả kỹ thuật Gemini Developer API Level 2 Structured Output, mô hình 5 trường dữ liệu, App Check và bài test xử lý lỗi HTTP 429.
            </div>
            <a href="../docs/ai-feature.md" target="_blank" style="font: 600 13px var(--mono); color: var(--son); text-decoration: none; margin-top: 8px;">
              📄 MỞ AI-FEATURE.MD ↗
            </a>
          </div>

          <!-- A6 -->
          <div class="panel accent-pink">
            <div style="font: 800 16px var(--mono); color: var(--pink); margin-bottom: 6px;">A6 · VIDEO DEMO DỰ PHÒNG</div>
            <div style="font-size: 14px; color: var(--vai-2); line-height: 1.4; flex: 1;">
              Kịch bản chi tiết và video 4K ghi lại toàn bộ 3 workflow liên vai trò (Đăng ký → Duyệt → Quét QR) phòng sự cố mạng hội trường.
            </div>
            <a href="../docs/demo-video-script.md" target="_blank" style="font: 600 13px var(--mono); color: var(--pink); text-decoration: none; margin-top: 8px;">
              📄 MỞ DEMO-VIDEO-SCRIPT.MD ↗
            </a>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">APPENDIX: DEEP-DIVE DOCUMENTATION FOR EXPERT COMMITTEE AUDIT</span></div>
        <div class="foot-right"><span class="mono-meta">25 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE G5 · QUALITY GATE CHECKLIST
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE G5 · QUALITY GATE -->
    <section class="slide" id="slide-g5" data-page="G5" data-title="Quality Gate">
      <div class="s-top">
        <div class="eb">QUALITY GATE · BẢNG TỰ RÀ SOÁT TRƯỚC HỘI ĐỒNG BẢO VỆ</div>
        <div class="pg-badge">TIÊU CHUẨN ĐẠT · G5</div>
      </div>

      <div class="s-head">
        <h2>Kiểm soát chất lượng: <em>8/8 Tiêu chuẩn đạt mức độ hoàn thiện tối đa</em></h2>
        <p class="sub">Tự kiểm tra tính nhất quán giữa Yêu cầu (Problem), Thiết kế (Design), Trình diễn (Demo) và Minh chứng (Proof).</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;">
          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">1. Problem có minh chứng thực tế</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              3 Pain points đều có số liệu khảo sát thực tế (120 SV, 15 CLB) và đo lường hậu quả rõ ràng.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">2. Features phân nhóm theo nghiệp vụ</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              Chia thành 4 nhóm tính năng rõ rệt; chọn ra đúng 3 workflow chính để trình diễn trực tiếp.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">3. Thiết kế đồng bộ &amp; Khớp mã nguồn</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              Swimlane, State machine, C4, Sequence, Class MVVM và ERD khớp nhau 100% về tên hàm và logic.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">4. Ma trận truy vết khép kín 100%</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              Mỗi tính năng đều nối được Màn hình → Lớp code → Thực thể DB → Bài test tự động.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">5. Demo chạy thật liên vai trò</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              Kết hợp thiết bị Android thật và Web Hosting thật; kết quả của WF trước là đầu vào của WF sau.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">6. Kiểm thử tự động &amp; Độ tin cậy</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              132 Tests tự động Pass 100%; minh chứng Crashlytics 0 crash; 12 nhóm Rules Emulator.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">7. Tuân thủ Mục 8 Đề thi (AI Gemini)</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              Triển khai Level 2 Structured JSON output, có App Check, Remote Config kill-switch và Analytics.
            </div>
          </div>

          <div class="panel" style="padding: 14px 18px; border-left: 6px solid var(--si);">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="tag si">✓ ĐẠT</span>
              <strong style="font-size: 16px;">8. Thiết kế bản vẽ kỹ thuật chuyên nghiệp</strong>
            </div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
              Loại bỏ 100% nội dung gợi ý đề bài; phông chữ Bricolage &amp; Be Vietnam Pro sắc sảo, sợi chỉ tiến độ tương tác.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">QUALITY GATE PASSED: READY FOR OFFICIAL ORAL DEFENSE BEFORE EVALUATION COMMITTEE</span></div>
        <div class="foot-right"><span class="mono-meta">CHECKLIST G5</span></div>
      </div>
    </section>
    """)

    return slides_html

print("mln_slides_p3_p4.py ready.")
