# -*- coding: utf-8 -*-
"""
mln_slides_p2.py
Defines Phase P2 slides (Slides 07 to 16) for EventHub PRM393.
No meta-prompts. Uses mln122 design language: technical eyebrow, conclusion titles,
spacious panels, mono badges, high-impact vector diagrams, and crisp code references.
"""

def get_p2_slides():
    slides_html = []

    # -------------------------------------------------------------------------
    # SLIDE 07 · BUSINESS FLOW
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 07 · BUSINESS FLOW -->
    <section class="slide" id="slide-07" data-page="07" data-title="07 Business Flow">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 07 BUSINESS FLOW (SWIMLANE)</div>
        <div class="pg-badge">BẢN VẼ 07 / 24</div>
      </div>

      <div class="s-head">
        <h2>Business Flow — <em>Luồng nghiệp vụ tổng thể</em></h2>
        <p class="sub">Sơ đồ Activity phân làn (Swimlane) thể hiện sự phối hợp liên ứng dụng giữa Sinh viên (Mobile App), Hệ thống (Firestore Rules) và Trưởng CLB (Web).</p>
      </div>

      <div class="s-body">
        <!-- Khung sơ đồ Swimlane Vector -->
        <div class="panel" style="flex: 1.4; padding: 12px; background: var(--cham-deep); justify-content: center; align-items: center; position: relative;">
          <img src="../evidence/diagrams/07-business-flow.svg?v=3lane_bpmn_clean2" alt="Business Flow Diagram" 
               style="width: 100%; height: 100%; object-fit: contain;">
        </div>

        <!-- Cột phải: Diễn giải các điểm rẽ Business Rules -->
        <div style="flex: 0.6; display: flex; flex-direction: column; gap: 12px;">
          <div class="panel" style="padding: 14px; background: var(--cham-2);">
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 6px; text-transform: uppercase;">QUY TẮC NGHIỆP VỤ TẠI CÁC ĐIỂM RẼ:</div>
            
            <div style="display: flex; flex-direction: column; gap: 10px; font-size: 14px;">
              <div>
                <span class="tag pink">BR-02</span> <strong style="color: var(--vai);">Kiểm tra form hợp lệ:</strong>
                <div style="color: var(--vai-2); font-size: 13px; margin-top: 2px;">MSSV, Họ tên, Email không rỗng; vi phạm sẽ báo đỏ ngay trên form A05.</div>
              </div>

              <div>
                <span class="tag nghe">BR-01</span> <strong style="color: var(--vai);">Khóa sức chứa hội trường:</strong>
                <div style="color: var(--vai-2); font-size: 13px; margin-top: 2px;">Chỉ tạo đơn PENDING khi `activeCount &lt; capacity` và thời gian hiện tại trước deadline.</div>
              </div>

              <div>
                <span class="tag son">BR-03</span> <strong style="color: var(--vai);">Xét duyệt &amp; Lý do bắt buộc:</strong>
                <div style="color: var(--vai-2); font-size: 13px; margin-top: 2px;">Chỉ `staff` đúng CLB được duyệt; nếu từ chối bắt buộc `reason &ge; 3` ký tự.</div>
              </div>

              <div>
                <span class="tag si">BR-04, 05</span> <strong style="color: var(--vai);">Xác thực QR &amp; Chặn trùng:</strong>
                <div style="color: var(--vai-2); font-size: 13px; margin-top: 2px;">Đối chiếu mã băm SHA-256 với phiên mở; chỉ ghi nhận khi `checkInAt == null`.</div>
              </div>
            </div>
          </div>

          <div class="panel" style="padding: 12px 16px; background: rgba(234,88,12,0.06); border-color: rgba(234,88,12,0.25);">
            <div style="font: 800 14px var(--display); color: var(--nghe);">NGUYÊN TẮC THIẾT KẾ:</div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 4px; line-height: 1.35;">
              Mỗi nhánh rẽ tại hình thoi trên sơ đồ đều sinh ra ít nhất một test case kiểm thử tự động, kết nối trực tiếp với State Machine và Ma trận truy vết.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">SWIMLANE DIAGRAM: 4 ACTORS · 5 BUSINESS RULES (BR-01..BR-05) · 3 CORE WORKFLOWS</span></div>
        <div class="foot-right"><span class="mono-meta">07 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 08 · STATE MACHINE
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 08 · STATE MACHINE -->
    <section class="slide" id="slide-08" data-page="08" data-title="08 State Machine">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 08 STATE MACHINE &amp; ATOMIC INVARIANTS</div>
        <div class="pg-badge">BẢN VẼ 08 / 24</div>
      </div>

      <div class="s-head">
        <h2>Registration Lifecycle: <em>State Transitions &amp; Atomic Invariants</em></h2>
        <p class="sub">Đối tượng trọng tâm <code>Registration</code> được quản lý State Transitions chặt chẽ; Firestore Security Rules thực thi Atomic Invariants và cấm tuyệt đối các bước chuyển trạng thái nhảy cóc.</p>
      </div>

      <div class="s-body">
        <!-- Khung sơ đồ State Machine Vector -->
        <div class="panel" style="flex: 1.35; padding: 12px; background: var(--cham-deep); justify-content: center; align-items: center; position: relative;">
          <img src="../evidence/diagrams/08-state-machine.svg" alt="State Machine Diagram" 
               style="width: 100%; height: 100%; object-fit: contain;">
        </div>

        <!-- Cột phải: Bảng đối chiếu nghiệp vụ vs dữ liệu & Ràng buộc cấm -->
        <div style="flex: 0.65; display: flex; flex-direction: column; gap: 12px;">
          <div class="panel accent-son" style="padding: 14px;">
            <div style="font: 800 15px var(--display); color: var(--son); margin-bottom: 6px;">ĐỐI CHIẾU NGHIỆP VỤ UI ↔ DỮ LIỆU FIRESTORE:</div>
            <table class="spec-table" style="font-size: 13px;">
              <thead>
                <tr>
                  <th>Trạng thái UI</th>
                  <th>Trường `status`</th>
                  <th>Điều kiện kèm theo</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><span class="tag pink">DRAFT</span></td>
                  <td>(chưa ghi)</td>
                  <td>Lưu cục bộ tại client</td>
                </tr>
                <tr>
                  <td><span class="tag nghe">PENDING</span></td>
                  <td>`'pending'`</td>
                  <td>Đã gửi, chờ duyệt</td>
                </tr>
                <tr>
                  <td><span class="tag si">APPROVED</span></td>
                  <td>`'approved'`</td>
                  <td>`checkInAt == null`</td>
                </tr>
                <tr>
                  <td><span class="tag son">ATTENDED</span></td>
                  <td>`'approved'`</td>
                  <td>`checkInAt != null` (Timestamp)</td>
                </tr>
                <tr>
                  <td><span class="tag red">REJECTED</span></td>
                  <td>`'rejected'`</td>
                  <td>Bắt buộc `reason` hợp lệ</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="panel accent-pink" style="padding: 12px 16px;">
            <div style="font: 800 14px var(--display); color: var(--pink);">2 BƯỚC CHUYỂN BỊ CẤM TUYỆT ĐỐI (SECURITY RULES):</div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 4px; line-height: 1.4;">
              🚫 <strong>CẤM DRAFT → APPROVED:</strong> Không ai được cấp vé trực tiếp mà bỏ qua hàng đợi duyệt.<br>
              🚫 <strong>CẤM REJECTED → APPROVED:</strong> Đơn đã từ chối không được sửa ngược; muốn tham gia phải nộp đơn mới (`generation + 1`).
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">ATOMIC INVARIANT: APPROVE BẮT BUỘC TĂNG activeCount +1 TRONG TRANSACTION</span></div>
        <div class="foot-right"><span class="mono-meta">08 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 09 · SYSTEM ARCHITECTURE
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 09 · SYSTEM ARCHITECTURE -->
    <section class="slide" id="slide-09" data-page="09" data-title="09 System Architecture">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 09 SYSTEM ARCHITECTURE (C4 CONTAINER)</div>
        <div class="pg-badge">BẢN VẼ 09 / 24</div>
      </div>

      <div class="s-head">
        <h2>Kiến trúc C4 Container: <em>Serverless Realtime &amp; 0 Máy chủ trung gian</em></h2>
        <p class="sub">Flutter Mobile và Flutter Web giao tiếp trực tiếp với Cloud Firestore qua kết nối gRPC/HTTPS; toàn bộ ranh giới nghiệp vụ do Security Rules kiểm soát.</p>
      </div>

      <div class="s-body">
        <!-- Khung sơ đồ C4 Container Vector -->
        <div class="panel" style="flex: 1.35; padding: 12px; background: var(--cham-deep); justify-content: center; align-items: center; position: relative;">
          <img src="../evidence/diagrams/09-system-architecture.svg?v=c4_perfect_clean" alt="System Architecture Diagram" 
               style="width: 100%; height: 100%; object-fit: contain;">
        </div>

        <!-- Cột phải: 3 Quyết định kiến trúc then chốt -->
        <div style="flex: 0.65; display: flex; flex-direction: column; gap: 10px;">
          <div class="panel accent-son" style="padding: 12px 14px;">
            <div style="font: 800 14px var(--display); color: var(--son);">QUYẾT ĐỊNH 1: ZERO-SERVER (KHÔNG CUSTOM SERVER)</div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 3px; line-height: 1.35;">
              Loại bỏ hoàn toàn chi phí bảo trì backend, không cần Cloud Functions. Đạt độ trễ tối thiểu khi đồng bộ trạng thái trực tiếp giữa các thiết bị.
            </div>
          </div>

          <div class="panel accent-nghe" style="padding: 12px 14px;">
            <div style="font: 800 14px var(--display); color: var(--nghe);">QUYẾT ĐỊNH 2: CLOUD FIRESTORE SECURITY RULES</div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 3px; line-height: 1.35;">
              Sử dụng <code>getAfter()</code> để bảo đảm Atomic Transactions: nếu <code>activeCount &gt; capacity</code> thì toàn bộ transaction tự động rollback.
            </div>
          </div>

          <div class="panel accent-si" style="padding: 12px 14px;">
            <div style="font: 800 14px var(--display); color: var(--si);">QUYẾT ĐỊNH 3: MONOREPO &amp; SHARED PACKAGES/CORE</div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 3px; line-height: 1.35;">
              Tách toàn bộ Data Models, Service Contracts và Design Tokens dùng chung ra thư mục `packages/core`, bảo đảm Web và Mobile không bị lệch logic.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">BOUNDARY: FLUTTER MOBILE (ANDROID) + FLUTTER WEB (HOSTING) → DIRECT FIRESTORE SDK</span></div>
        <div class="foot-right"><span class="mono-meta">09 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 10 · TECHNOLOGY STACK
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 10 · TECHNOLOGY STACK -->
    <section class="slide" id="slide-10" data-page="10" data-title="10 Technology Stack">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 10 TECHNOLOGY STACK</div>
        <div class="pg-badge">BẢN VẼ 10 / 24</div>
      </div>

      <div class="s-head">
        <h2>Ngăn xếp công nghệ 8 nhóm: <em>Đồng nhất mã nguồn &amp; Trợ lý Gemini AI</em></h2>
        <p class="sub">Tất cả công nghệ đều khớp 100% với file `pubspec.yaml` và đang vận hành thực tế; tích hợp Gemini AI Structured Output Level 2.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: flex; flex-direction: column; gap: 14px;">
          <table class="spec-table">
            <thead>
              <tr>
                <th style="width: 14%;">Nhóm mảng</th>
                <th style="width: 38%;">Công nghệ &amp; Thư viện chính</th>
                <th style="width: 36%;">Vai trò cụ thể trong hệ thống</th>
                <th style="width: 12%; text-align: center;">Môi trường</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><span class="tag pink">Mobile</span></td>
                <td><strong>Flutter 3.29 • Dart 3.7 • Riverpod 2.6 • Mobile Scanner 6.0</strong></td>
                <td>Ứng dụng di động cho Sinh viên; quét mã QR camera phần cứng</td>
                <td style="text-align: center;"><span class="tag">Android 10+</span></td>
              </tr>
              <tr>
                <td><span class="tag nghe">Web</span></td>
                <td><strong>Flutter Web • Flutter Riverpod • GoRouter 14.8</strong></td>
                <td>Cổng quản trị cho Trưởng CLB (Review Queue) &amp; Admin hệ thống</td>
                <td style="text-align: center;"><span class="tag">Browser</span></td>
              </tr>
              <tr>
                <td><span class="tag son">Core</span></td>
                <td><strong>packages/core (Models, Contracts, Services, Theme)</strong></td>
                <td>Chia sẻ 100% logic nghiệp vụ, models và contracts giữa Web &amp; Mobile</td>
                <td style="text-align: center;"><span class="tag">Shared</span></td>
              </tr>
              <tr>
                <td><span class="tag si">Backend</span></td>
                <td><strong>Cloud Firestore • Firebase Security Rules</strong></td>
                <td>Cơ sở dữ liệu NoSQL realtime, lắng nghe `snapshots()`, phân quyền RBAC</td>
                <td style="text-align: center;"><span class="tag">Serverless</span></td>
              </tr>
              <tr>
                <td><span class="tag son">Cloud</span></td>
                <td><strong>Firebase Auth • FCM • Remote Config • Crashlytics</strong></td>
                <td>Đăng nhập Google, Thông báo đẩy, Feature Flags (A/B Test), Giám sát crash</td>
                <td style="text-align: center;"><span class="tag">Google Cloud</span></td>
              </tr>
              <tr>
                <td><span class="tag pink">AI Service</span></td>
                <td><strong>Google Gemini Developer API (Level 2 Structured Output)</strong></td>
                <td>Trợ lý AI gợi ý nội dung sự kiện: trả về JSON parse thành Dart model</td>
                <td style="text-align: center;"><span class="tag">Gemini API</span></td>
              </tr>
              <tr>
                <td><span class="tag si">Testing</span></td>
                <td><strong>Google ARTEMIS • Firestore Emulator Suite • Unit/Widget Tests</strong></td>
                <td>Kiểm thử tự động E2E trên Android thật, kiểm thử Rules Allowed/Denied</td>
                <td style="text-align: center;"><span class="tag">CI / Emulator</span></td>
              </tr>
              <tr>
                <td><span class="tag nghe">DevOps</span></td>
                <td><strong>GitHub Actions • Firebase Hosting • Docker</strong></td>
                <td>Tự động hóa CI/CD, kiểm tra code analyze và deploy bản Web</td>
                <td style="text-align: center;"><span class="tag">Automated</span></td>
              </tr>
            </tbody>
          </table>

          <div style="background: rgba(219,39,119,0.06); border: 1px solid rgba(219,39,119,0.25); border-radius: 6px; padding: 10px 16px; font-size: 14px; color: var(--vai);">
            <strong>★ TUÂN THỦ MỤC 8 ĐỀ THI (AI GEMINI):</strong> Triển khai cấp độ Level 2 — Trả về Structured JSON gồm 5 trường (`topic`, `description`, `audience`, `preparation`, `activities`), có xác nhận của người dùng trước khi lưu, kèm App Check token và Remote Config kill-switch.
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">MÃ NGUỒN CHUẨN: 0 THƯ VIỆN THỪA · 100% HIỆN DIỆN TRONG PUBSPEC.YAML VÀ GIT REPO</span></div>
        <div class="foot-right"><span class="mono-meta">10 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 11 · UI/UX DESIGN
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 11 · UI/UX DESIGN -->
    <section class="slide" id="slide-11" data-page="11" data-title="11 UI/UX Design">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 11 UI/UX DESIGN SYSTEM</div>
        <div class="pg-badge">BẢN VẼ 11 / 24</div>
      </div>

      <div class="s-head">
        <h2>Thiết kế UI/UX: <em>Tiến trình từ Figma Wireframe đến Flutter Widgets</em></h2>
        <p class="sub">Hệ thống sitemap 4 tab Mobile, 4 màn Web; tiến hóa qua 3 giai đoạn thiết kế và chuẩn hóa 4 trạng thái giao diện bắt buộc.</p>
      </div>

      <div class="s-body" style="flex-direction: column; gap: 16px;">
        <!-- 3 Thẻ tiến trình thiết kế (Clickable Figma Links) -->
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px;">
          <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393?node-id=43-313" target="_blank" 
             style="text-decoration: none;" class="panel accent-pink">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span class="tag pink">GIAI ĐOẠN 1</span>
              <span style="font: 600 12px var(--mono); color: var(--pink);">🔗 MỞ FIGMA ↗</span>
            </div>
            <div style="font-size: 19px; font-weight: 800; color: var(--vai);">Low-fi Wireframe</div>
            <div style="font-size: 14px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Định hình khung xương và luồng điều hướng của 12 màn hình Mobile (A01..A12) cùng 5 màn Web, sắp xếp bố cục hợp lý trước khi đổ màu.
            </div>
          </a>

          <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393?node-id=153-2" target="_blank" 
             style="text-decoration: none;" class="panel accent-nghe">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span class="tag nghe">GIAI ĐOẠN 2</span>
              <span style="font: 600 12px var(--mono); color: var(--nghe);">🔗 MỞ FIGMA ↗</span>
            </div>
            <div style="font-size: 19px; font-weight: 800; color: var(--vai);">Hi-fi Design Tokens</div>
            <div style="font-size: 14px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Chuẩn hóa bảng màu Cam – Vàng – Hồng, Typography `Be Vietnam Pro`, khoảng cách chuẩn 4dp/8dp/16dp, component cards, buttons và status badges.
            </div>
          </a>

          <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393?node-id=199-1681" target="_blank" 
             style="text-decoration: none;" class="panel accent-son">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span class="tag son">GIAI ĐOẠN 3</span>
              <span style="font: 600 12px var(--mono); color: var(--son);">🔗 MỞ FIGMA ↗</span>
            </div>
            <div style="font-size: 19px; font-weight: 800; color: var(--vai);">Final Flutter Code</div>
            <div style="font-size: 14px; color: var(--vai-2); margin-top: 6px; line-height: 1.4;">
              Bản chốt giao diện được chuyển giao 100% thành các Flutter Widgets trong thư mục `mobile/lib/widgets/`, bảo đảm hiển thị pixel-perfect trên Android.
            </div>
          </a>
        </div>

        <!-- 4 Trạng thái UI & 2 Cải tiến thiết kế D11/D08 -->
        <div style="display: grid; grid-template-columns: 1.2fr 0.8fr; gap: 18px;">
          <!-- 4 UI States -->
          <div class="panel" style="padding: 16px 20px;">
            <div style="font: 600 13px var(--mono); color: var(--vai-3); margin-bottom: 8px;">CHUẨN HÓA 4 TRẠNG THÁI GIAO DIỆN BẮT BUỘC:</div>
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; font-size: 13.5px;">
              <div style="background: var(--cham-2); padding: 8px 10px; border-radius: 4px;">
                <span class="tag" style="background: #94A3B8; color: #FFF; font-size: 11px;">EMPTY</span>
                <div style="font-weight: 700; margin-top: 4px;">Trống dữ liệu</div>
                <div style="font-size: 12px; color: var(--vai-2);">Hình minh họa + Nút CTA hành động</div>
              </div>
              <div style="background: var(--cham-2); padding: 8px 10px; border-radius: 4px;">
                <span class="tag son" style="font-size: 11px;">LOADING</span>
                <div style="font-weight: 700; margin-top: 4px;">Đang tải</div>
                <div style="font-size: 12px; color: var(--vai-2);">Shimmer hiệu ứng mượt mà</div>
              </div>
              <div style="background: var(--cham-2); padding: 8px 10px; border-radius: 4px;">
                <span class="tag red" style="font-size: 11px;">ERROR</span>
                <div style="font-weight: 700; margin-top: 4px;">Gặp lỗi</div>
                <div style="font-size: 12px; color: var(--vai-2);">Thông báo rõ + Nút Thử lại (Retry)</div>
              </div>
              <div style="background: var(--cham-2); padding: 8px 10px; border-radius: 4px;">
                <span class="tag si" style="font-size: 11px;">SUCCESS</span>
                <div style="font-weight: 700; margin-top: 4px;">Thành công</div>
                <div style="font-size: 12px; color: var(--vai-2);">Dữ liệu hoàn chỉnh + Feed realtime</div>
              </div>
            </div>
          </div>

          <!-- Cải tiến D11 & D08 -->
          <div class="panel" style="padding: 16px 20px; background: rgba(11,122,110,0.06); border-color: rgba(11,122,110,0.25);">
            <div style="font: 800 14px var(--display); color: var(--si); margin-bottom: 6px;">2 CẢI TIẾN TRẢI NGHIỆM ĐƯỢC CHỨNG MINH:</div>
            <div style="font-size: 13.5px; color: var(--vai); line-height: 1.4;">
              • <strong>D11 (Filter Chips):</strong> Thanh lọc CLB cuộn ngang trên màn A02 giúp sinh viên lọc sự kiện chỉ với 1 chạm.<br>
              • <strong>D08 (Network Recovery):</strong> Tự động giữ nguyên nội dung form đăng ký khi mất sóng, không bắt sinh viên nhập lại.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">DESIGN TRACEABILITY: FIGMA DESIGN SYSTEM → FLUTTER THEME DATA &amp; CUSTOM WIDGETS</span></div>
        <div class="foot-right"><span class="mono-meta">11 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 12 · SEQUENCE DIAGRAM
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 12 · SEQUENCE DIAGRAM -->
    <section class="slide" id="slide-12" data-page="12" data-title="12 Sequence Diagram">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 12 SEQUENCE DIAGRAM</div>
        <div class="pg-badge">BẢN VẼ 12 / 24</div>
      </div>

      <div class="s-head">
        <h2>Sơ đồ tuần tự: <em>Phê duyệt đơn đăng ký (approveRegistration)</em></h2>
        <p class="sub">Tương tác chi tiết giữa Actor, View, ViewModel, Firestore Rules và Mobile Client kèm nhánh ngoại lệ hết chỗ.</p>
      </div>

      <div class="s-body">
        <!-- Khung sơ đồ Sequence Vector -->
        <div class="panel" style="flex: 1.35; padding: 12px; background: var(--cham-deep); justify-content: center; align-items: center; position: relative;">
          <img src="../evidence/diagrams/12-sequence-diagram.svg" alt="Sequence Diagram" 
               style="width: 100%; height: 100%; object-fit: contain;">
        </div>

        <!-- Cột phải: Diễn giải kỹ thuật các bước tương tác -->
        <div style="flex: 0.65; display: flex; flex-direction: column; gap: 12px;">
          <div class="panel accent-nghe" style="padding: 14px;">
            <div style="font: 800 15px var(--display); color: var(--nghe); margin-bottom: 6px;">QUY TRÌNH TRANSACTION NGUYÊN TỬ:</div>
            <div style="display: flex; flex-direction: column; gap: 8px; font-size: 13.5px; color: var(--vai);">
              <div><strong>1. Thao tác:</strong> Trưởng CLB bấm 'Phê duyệt' đơn #REG-102 tại `ReviewQueueScreen`.</div>
              <div><strong>2. Điều phối:</strong> `ReviewQueueViewModel` gọi hàm `runTransaction` cập nhật đồng thời đơn và sự kiện.</div>
              <div><strong>3. Kiểm tra Rules:</strong> Firestore Rules thực thi `getAfter(event).activeCount &lt;= capacity`.</div>
              <div><strong>4. Commit:</strong> Đơn đổi sang `'approved'`, `activeCount + 1`, sinh vé QR.</div>
            </div>
          </div>

          <div class="panel accent-pink" style="padding: 14px;">
            <div style="font: 800 15px var(--display); color: var(--pink); margin-bottom: 6px;">NHÁNH NGOẠI LỆ (ALT): HẾT CHỖ</div>
            <div style="font-size: 13.5px; color: var(--vai-2); line-height: 1.4;">
              Nếu hai cán bộ CLB cùng duyệt lúc hội trường chỉ còn 1 chỗ: Transaction thứ hai bị Rules chặn với lỗi <code>Permission Denied</code>; hệ thống tự động Rollback và thông báo cho cán bộ biết sự kiện đã hết chỗ.
            </div>
          </div>

          <div class="panel accent-son" style="padding: 12px 16px;">
            <div style="font: 800 14px var(--display); color: var(--son);">KẾT QUẢ ĐỒNG BỘ:</div>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 2px;">
              Điện thoại của sinh viên nhận ngay thông báo đẩy FCM và màn hình A08 tự động cập nhật sang trạng thái <strong>ĐÃ ĐƯỢC DUYỆT</strong>.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">TRANSACTION INVARIANT: UPDATE REGISTRATION + INCREMENT ACTIVECOUNT IN SINGLE ATOMIC COMMIT</span></div>
        <div class="foot-right"><span class="mono-meta">12 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 13 · CLASS DESIGN
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 13 · CLASS DESIGN -->
    <section class="slide" id="slide-13" data-page="13" data-title="13 Class Design">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 13 CLASS DESIGN &amp; MVVM ARCHITECTURE</div>
        <div class="pg-badge">BẢN VẼ 13 / 24</div>
      </div>

      <div class="s-head">
        <h2>Thiết kế Class: <em>Phân tầng MVVM &amp; Tách biệt Domain Model độc lập</em></h2>
        <p class="sub">Tuân thủ Clean Architecture: Screen (View) → ViewModel (StateNotifier) → Service Contract (Interface) → Firestore Service.</p>
      </div>

      <div class="s-body">
        <!-- Khung sơ đồ Class Vector -->
        <div class="panel" style="flex: 1.35; padding: 12px; background: var(--cham-deep); justify-content: center; align-items: center; position: relative;">
          <img src="../evidence/diagrams/13-class-design.svg?v=valid_xml" alt="Class Design Diagram" 
               style="width: 100%; height: 100%; object-fit: contain;">
        </div>

        <!-- Cột phải: 3 Nguyên tắc phân tách trách nhiệm trong Code -->
        <div style="flex: 0.65; display: flex; flex-direction: column; gap: 12px;">
          <div class="panel accent-son" style="padding: 14px;">
            <div style="font: 800 15px var(--display); color: var(--son);">TÁCH RỜI SERVICE CONTRACT (DIP)</div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px; line-height: 1.4;">
              ViewModel chỉ phụ thuộc vào Interface abstract (`EventService`, `AuthService`). Cho phép tráo đổi sang `FakeEventService` trong Unit Tests mà không cần kết nối Firebase thật.
            </div>
          </div>

          <div class="panel accent-nghe" style="padding: 14px;">
            <div style="font: 800 15px var(--display); color: var(--nghe);">DOMAIN MODEL THUẦN TÚY (PACKAGE CORE)</div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px; line-height: 1.4;">
              `Registration`, `Event`, `Club` là các immutable domain entities độc lập với SDK Firestore; sở hữu các getters nghiệp vụ như `isApproved`, `canCheckIn`, `hasRequest`.
            </div>
          </div>

          <div class="panel accent-si" style="padding: 14px;">
            <div style="font: 800 15px var(--display); color: var(--si);">VIEWMODEL QUẢN LÝ STATE REACTIVE</div>
            <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px; line-height: 1.4;">
              Sử dụng Riverpod `AsyncValue` tự động xử lý 3 trạng thái `data`, `loading`, `error`, loại bỏ hoàn toàn các lỗi memory leak khi unmount widget.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">CLEAN ARCHITECTURE: PACKAGES/CORE (ENTITIES/CONTRACTS) ← SERVICES ← VIEWMODELS ← SCREENS</span></div>
        <div class="foot-right"><span class="mono-meta">13 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 14 · DATABASE DESIGN — CONCEPTUAL
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 14 · DATABASE DESIGN — CONCEPTUAL -->
    <section class="slide" id="slide-14" data-page="14" data-title="14 Conceptual Database">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 14 DATABASE DESIGN — CONCEPTUAL ERD</div>
        <div class="pg-badge">BẢN VẼ 14 / 24</div>
      </div>

      <div class="s-head">
        <h2>Mô hình thực thể khái niệm: <em>Ngữ nghĩa nghiệp vụ &amp; Bản số quan hệ</em></h2>
        <p class="sub">Mô hình hóa 5 thực thể cốt lõi độc lập với DBMS vật lý (không phụ thuộc SQL/NoSQL), thể hiện bản chất quan hệ và các ràng buộc toàn vẹn.</p>
      </div>

      <div class="s-body">
        <!-- Khung sơ đồ Conceptual ERD Vector (ĐÃ BỎ CHỮ PK!) -->
        <div class="panel" style="flex: 1.35; padding: 12px; background: var(--cham-deep); justify-content: center; align-items: center; position: relative;">
          <img src="../evidence/diagrams/14-conceptual-erd.svg?v=clean_rel" alt="Conceptual ERD" 
               style="width: 100%; height: 100%; object-fit: contain;">
        </div>

        <!-- Cột phải: Diễn giải ngữ nghĩa quan hệ và Ràng buộc IC-01..IC-03 -->
        <div style="flex: 0.65; display: flex; flex-direction: column; gap: 12px;">
          <div class="panel accent-son" style="padding: 14px;">
            <div style="font: 800 15px var(--body); color: var(--son); margin-bottom: 6px;">BẢN SỐ QUAN HỆ (CARDINALITY):</div>
            <div style="display: flex; flex-direction: column; gap: 8px; font-size: 13.5px; color: var(--vai);">
              <div>• <strong>CLUB 1 : 0..* EVENT:</strong> Một CLB có thể tổ chức nhiều sự kiện; mỗi sự kiện thuộc sở hữu của đúng 1 CLB.</div>
              <div>• <strong>USER 1 : 0..* REGISTRATION:</strong> Một sinh viên có thể đăng ký nhiều sự kiện khác nhau.</div>
              <div>• <strong>EVENT 1 : 0..* REGISTRATION:</strong> Một sự kiện nhận nhiều đơn đăng ký (n–n được phân rã thành thực thể liên kết).</div>
              <div>• <strong>EVENT 1 : 0..1 CHECKIN_SESSION:</strong> Mỗi sự kiện chỉ có tối đa 1 phiên QR mở tại một thời điểm.</div>
            </div>
          </div>

          <div class="panel accent-nghe" style="padding: 14px;">
            <div style="font: 800 15px var(--body); color: var(--nghe); margin-bottom: 6px;">RÀNG BUỘC TOÀN VẸN NGỮ NGHĨA (IC-01..IC-03):</div>
            <div style="font-size: 13px; color: var(--vai-2); line-height: 1.4;">
              • <strong>IC-01:</strong> Mỗi Sinh viên chỉ có tối đa 1 Registration đang hoạt động cho 1 Event (định danh: <code>{uid}_{eventId}</code>).<br>
              • <strong>IC-02:</strong> Chỉ Trưởng CLB sở hữu sự kiện (hoặc Admin) mới có quyền duyệt đơn và mở phiên điểm danh.<br>
              • <strong>IC-03:</strong> Một sự kiện chỉ có tối đa 1 phiên điểm danh mở (`open == true`).
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">SEMANTIC DATA MODEL: 5 CORE ENTITIES · 1 ASSOCIATIVE ENTITY · 3 INTEGRITY CONSTRAINTS</span></div>
        <div class="foot-right"><span class="mono-meta">14 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 15 · DATABASE DESIGN — PHYSICAL
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 15 · DATABASE DESIGN — PHYSICAL -->
    <section class="slide" id="slide-15" data-page="15" data-title="15 Physical Database">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 15 DATABASE DESIGN — LOGICAL → PHYSICAL</div>
        <div class="pg-badge">BẢN VẼ 15 / 24</div>
      </div>

      <div class="s-head">
        <h2>Mô hình vật lý Firestore: <em>Collections, Composite Indexes &amp; Rules</em></h2>
        <p class="sub">Chuyển từ cấu trúc ngữ nghĩa sang NoSQL Cloud Firestore; toàn bộ ràng buộc kiểu dữ liệu và phân quyền được hiện thực trong `firestore.rules`.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1.1; display: flex; flex-direction: column; gap: 14px;">
          <table class="spec-table" style="font-size: 13.5px;">
            <thead>
              <tr>
                <th style="width: 25%;">Firestore Collection</th>
                <th style="width: 38%;">Các trường chính &amp; Kiểu dữ liệu</th>
                <th style="width: 37%;">Ràng buộc bảo vệ (firestore.rules)</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><code>users/{uid}</code></td>
                <td>`role` (string), `displayName`, `email`, `clubId`?</td>
                <td>Chỉ Admin được đổi `role`/`clubId`; cấm tự đổi role chính mình</td>
              </tr>
              <tr>
                <td><code>clubs/{clubId}</code></td>
                <td>`name` (string &le; 120), `status` ('active'/'archived')</td>
                <td>Chỉ Admin được tạo/sửa; cấm xóa (chuyển archived)</td>
              </tr>
              <tr>
                <td><code>events/{eventId}</code></td>
                <td>`title`, `clubId`, `capacity` (int), `activeCount` (int), `status`</td>
                <td>Staff chỉ tạo sự kiện cho CLB mình; atomic count `&lt;= capacity`</td>
              </tr>
              <tr>
                <td><code>registrations/{id}</code></td>
                <td>`uid`, `eventId`, `status`, `generation`, `checkInAt`, `reason`</td>
                <td>Status in ['pending','approved','rejected','cancelled']; reason &ge; 3</td>
              </tr>
              <tr>
                <td><code>checkinSessions/{evId}</code></td>
                <td>`eventId`, `clubId`, `open` (bool), `updatedAt`</td>
                <td>Staff đúng CLB mở/đóng; chỉ người có đơn approved được đọc</td>
              </tr>
            </tbody>
          </table>

          <div style="background: rgba(234,88,12,0.06); border: 1px solid rgba(234,88,12,0.25); border-radius: 6px; padding: 10px 16px; font-size: 13.5px;">
            <strong>COMPOSITE INDEXES ĐÃ TRIỂN KHAI THẬT (firestore.indexes.json):</strong><br>
            • <code>events: clubId (ASC) + status (ASC) + startsAt (ASC)</code> → Tối ưu truy vấn sự kiện CLB.<br>
            • <code>registrations: clubId (ASC) + status (ASC) + createdAt (DESC)</code> → Tối ưu tải Review Queue.
          </div>
        </div>

        <div style="flex: 0.9; display: flex; flex-direction: column; gap: 14px;">
          <div class="panel accent-si" style="flex: 1;">
            <div style="font: 800 15px var(--display); color: var(--si); margin-bottom: 6px;">MINH CHỨNG FIRESTORE SECURITY RULES (TRÍCH ĐOẠN):</div>
            <pre style="background: #0F172A; color: #F8FAFC; padding: 14px; border-radius: 6px; font: 500 12px/1.45 var(--mono); margin: 0; overflow-x: auto;">
// Atomic Invariant: Tăng activeCount có điều kiện khi duyệt đơn
function canApprove() {
  return isStaffOf(resource.data.clubId)
    && resource.data.status == 'pending'
    && request.resource.data.status == 'approved'
    && getAfter(eventDoc(resource.data.eventId)).data.activeCount
       == get(eventDoc(resource.data.eventId)).data.activeCount + 1
    && getAfter(eventDoc(resource.data.eventId)).data.activeCount
       &lt;= get(eventDoc(resource.data.eventId)).data.capacity;
}
            </pre>
            <div style="font-size: 13px; color: var(--vai-2); margin-top: 8px;">
              Quy tắc trên đảm bảo 100% không bao giờ xảy ra tình trạng overbooking dù có hàng trăm yêu cầu duyệt đồng thời.
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">PHYSICAL SCHEMA: 7 COLLECTIONS · COMPOSITE INDEXES · 100% SECURITY RULES VALIDATED</span></div>
        <div class="foot-right"><span class="mono-meta">15 / 24</span></div>
      </div>
    </section>
    """)

    # -------------------------------------------------------------------------
    # SLIDE 16 · TRACEABILITY MATRIX
    # -------------------------------------------------------------------------
    slides_html.append("""
    <!-- SLIDE 16 · TRACEABILITY MATRIX -->
    <section class="slide" id="slide-16" data-page="16" data-title="16 Traceability">
      <div class="s-top">
        <div class="eb">P2 · DESIGN · 16 TRACEABILITY MATRIX</div>
        <div class="pg-badge">BẢN VẼ 16 / 24</div>
      </div>

      <div class="s-head">
        <h2>Ma trận truy vết: <em>Tính nhất quán khép kín từ Yêu cầu đến Kiểm thử</em></h2>
        <p class="sub">Mỗi nhóm tính năng đều được đối chiếu xuyên suốt qua Màn hình, Lớp mã nguồn, Dữ liệu và Test Case; 100% thiết kế đều có mã nguồn hiện thực.</p>
      </div>

      <div class="s-body">
        <div style="flex: 1; display: flex; flex-direction: column; gap: 16px;">
          <table class="spec-table" style="font-size: 14.5px;">
            <thead>
              <tr>
                <th style="width: 20%;">Tính năng (Feature)</th>
                <th style="width: 18%;">Màn hình (Screen)</th>
                <th style="width: 25%;">Lớp mã nguồn (Class / Service)</th>
                <th style="width: 20%;">Thực thể DB (Entity)</th>
                <th style="width: 17%;">Bộ Test kiểm chứng</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong style="color: var(--pink);">F1. Đăng ký sự kiện</strong></td>
                <td>Mobile: A04, A05, A06</td>
                <td>`BookingViewModel`<br>`FirestoreEventService`</td>
                <td>`registrations`<br>`events`</td>
                <td><span class="tag si">TC01–TC04</span><br>Unit &amp; Widget</td>
              </tr>
              <tr>
                <td><strong style="color: var(--nghe);">F2. Phê duyệt &amp; Khóa chỗ</strong></td>
                <td>Web: `ReviewQueueScreen`<br>`RejectReasonDialog`</td>
                <td>`ReviewQueueViewModel`<br>`FirebaseWebServices`</td>
                <td>`registrations`<br>`events.activeCount`</td>
                <td><span class="tag si">TC05–TC08</span><br>Rules Emulator</td>
              </tr>
              <tr>
                <td><strong style="color: var(--son);">F3. Điểm danh QR SHA-256</strong></td>
                <td>Mobile: A11, A12<br>Web: `LiveQrPanelScreen`</td>
                <td>`ScannerViewModel`<br>`QrCheckInViewModel`</td>
                <td>`checkinSessions`<br>`qrCredentials`</td>
                <td><span class="tag si">TC09–TC12</span><br>ARTEMIS E2E</td>
              </tr>
              <tr>
                <td><strong style="color: var(--si);">F4. Soạn thảo với AI</strong></td>
                <td>Web: `EventEditorDialog`</td>
                <td>`AiEventAssistViewModel`<br>`GeminiAiService`</td>
                <td>`ai_event_suggestion`<br>`RemoteConfig`</td>
                <td><span class="tag si">AI Test 1..3</span><br>Unit Test AI</td>
              </tr>
            </tbody>
          </table>

          <div style="display: flex; gap: 20px;">
            <div class="panel" style="flex: 1; padding: 14px 20px; background: rgba(11,122,110,0.06); border-color: rgba(11,122,110,0.25);">
              <div style="font: 800 15px var(--display); color: var(--si);">KHÔNG CÓ TÍNH NĂNG 'MỒ CÔI'</div>
              <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
                Mọi thực thể database và API service đều phục vụ trực tiếp cho ít nhất một màn hình và một workflow của người dùng; loại bỏ 100% code thừa.
              </div>
            </div>

            <div class="panel" style="flex: 1; padding: 14px 20px; background: rgba(29,78,216,0.06); border-color: rgba(29,78,216,0.25);">
              <div style="font: 800 15px var(--display); color: var(--son);">KHÉP KÍN BẰNG BỘ TEST TỰ ĐỘNG</div>
              <div style="font-size: 13.5px; color: var(--vai-2); margin-top: 4px;">
                Tất cả các rẽ nhánh ngoại lệ tại Business Rules (hết chỗ, thiếu lý do, sai mã QR) đều có các test cases tương ứng khẳng định hệ thống hoạt động đúng.
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="s-foot">
        <div class="foot-left"><span class="mono-meta">TRACEABILITY VERIFICATION: 100% REVENUE FEATURES TIED DIRECTLY TO TEST CASSETS</span></div>
        <div class="foot-right"><span class="mono-meta">16 / 24</span></div>
      </div>
    </section>
    """)

    return slides_html

print("mln_slides_p2.py ready.")
