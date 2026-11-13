# -*- coding: utf-8 -*-
"""
slide_definitions_p2.py - Phase P2 (DESIGN) Slides 07 to 16 for EventHub
Equipped with real vector SVG diagrams, image slots for external diagrams, and clickable refs.
"""

def get_p2_slides():
    slides = []

    # -------------------------------------------------------------------------
    # SLIDE 07 · BUSINESS FLOW
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-07",
        "page_id": "07",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "07 / BUSINESS FLOW",
        "slide_num_str": "Slide 7",
        "title_rest": "Business Flow — luồng nghiệp vụ tổng thể",
        "subtitle": "Một sơ đồ Activity / BPMN cho toàn hệ thống: các actor phối hợp thế nào từ đầu đến cuối.",
        "pill_right": None,
        "question": "Nghiệp vụ của hệ thống vận hành thế nào, ai làm gì ở đâu?",
        "duration": "60 s",
        "evidence": "Sơ đồ swimlane 3 làn (Sinh viên, Hệ thống, Trưởng CLB) kèm mã BR",
        "left_items": [
            "Toàn bộ 3 làn phối hợp: Sinh viên (Mobile App), Hệ thống (Firestore Rules), Trưởng CLB (Web Admin).",
            "Trình tự từ đề xuất sự kiện → mở đăng ký → duyệt đơn → mở phiên QR → điểm danh.",
            "Thể hiện rõ các nhánh ngoại lệ: Sai form (FAIL BR-02), Hết chỗ (BR-01), Từ chối duyệt (BR-03).",
            "Gán mã quy tắc nghiệp vụ BR-01..BR-05 tại điểm rẽ để nối với State Machine và Test Case."
        ],
        "avoid_text": "Vẽ riêng cho từng tính năng ở đây, hoặc thay bằng danh sách thao tác click.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="width: 100%; height: 100%; position: relative;">
            <!-- Optional User Image (priority if provided in evidence/diagrams/07-business-flow.png) -->
            <img src="../evidence/diagrams/07-business-flow.svg?v=3lane2" alt="Business Flow Diagram" 
                 style="width: 100%; height: 100%; object-fit: contain; display: block;" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            
            <!-- Fallback High-Detail SVG Swimlane Diagram -->
            <div style="display: none; width: 100%; height: 100%; flex-direction: column; justify-content: space-between;">
              <svg viewBox="0 0 680 300" style="width: 100%; height: 100%;">
                <defs>
                  <marker id="arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                    <path d="M 0 1 L 8 5 L 0 9 z" fill="#94A3B8" />
                  </marker>
                  <marker id="arrow-red" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                    <path d="M 0 1 L 8 5 L 0 9 z" fill="#DC2626" />
                  </marker>
                </defs>

                <!-- Swimlane 1: Sinh viên -->
                <rect x="0" y="5" width="680" height="65" rx="4" fill="#F8FAFC" stroke="#E2E8F0" />
                <text x="12" y="42" fill="#64748B" font-size="10" font-weight="700">SINH VIÊN (Mobile)</text>
                
                <rect x="130" y="16" width="95" height="42" rx="4" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" />
                <text x="177" y="41" fill="#DB2777" font-size="10.5" font-weight="700" text-anchor="middle">Điền form A05</text>

                <rect x="390" y="16" width="105" height="42" rx="4" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" />
                <text x="442" y="35" fill="#DB2777" font-size="10" font-weight="700" text-anchor="middle">Thông báo duyệt</text>
                <text x="442" y="48" fill="#64748B" font-size="9" text-anchor="middle">Inbox A09 · A08</text>

                <rect x="545" y="16" width="105" height="42" rx="4" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" />
                <text x="597" y="35" fill="#DB2777" font-size="10" font-weight="700" text-anchor="middle">Quét QR (A11)</text>
                <text x="597" y="48" fill="#64748B" font-size="9" text-anchor="middle">Biên nhận A12</text>

                <!-- Swimlane 2: Hệ thống -->
                <rect x="0" y="75" width="680" height="70" rx="4" fill="#F8FAFC" stroke="#E2E8F0" />
                <text x="12" y="115" fill="#64748B" font-size="10" font-weight="700">HỆ THỐNG (Rules)</text>
                
                <!-- Diamond BR-02 -->
                <polygon points="177,85 210,110 177,135 144,110" fill="#FEF3C7" stroke="#D97706" stroke-width="1.2" />
                <text x="177" y="113" fill="#D97706" font-size="9" font-weight="700" text-anchor="middle">BR-02?</text>

                <!-- Diamond BR-01 -->
                <polygon points="265,85 298,110 265,135 232,110" fill="#FEF3C7" stroke="#D97706" stroke-width="1.2" />
                <text x="265" y="113" fill="#D97706" font-size="9" font-weight="700" text-anchor="middle">BR-01?</text>

                <rect x="320" y="90" width="105" height="40" rx="4" fill="#FFF7ED" stroke="#EA580C" stroke-width="1.2" />
                <text x="372" y="108" fill="#EA580C" font-size="9.5" font-weight="700" text-anchor="middle">Tạo PENDING</text>
                <text x="372" y="120" fill="#64748B" font-size="8.5" text-anchor="middle">Ghi registrations</text>

                <rect x="545" y="90" width="105" height="40" rx="4" fill="#FFF1F2" stroke="#BE123C" stroke-width="1.2" />
                <text x="597" y="108" fill="#BE123C" font-size="9.5" font-weight="700" text-anchor="middle">Xác thực SHA-256</text>
                <text x="597" y="120" fill="#64748B" font-size="8.5" text-anchor="middle">checkInAt (BR-04)</text>

                <!-- Swimlane 3: Trưởng CLB -->
                <rect x="0" y="150" width="680" height="70" rx="4" fill="#F8FAFC" stroke="#E2E8F0" />
                <text x="12" y="190" fill="#64748B" font-size="10" font-weight="700">TRƯỞNG CLB (Web)</text>

                <rect x="320" y="165" width="105" height="40" rx="4" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
                <text x="372" y="183" fill="#F97316" font-size="9.5" font-weight="700" text-anchor="middle">Review Queue</text>
                <text x="372" y="195" fill="#64748B" font-size="8.5" text-anchor="middle">Realtime snapshot</text>

                <!-- Diamond BR-03 -->
                <polygon points="460,160 493,185 460,210 427,185" fill="#FEF3C7" stroke="#D97706" stroke-width="1.2" />
                <text x="460" y="188" fill="#D97706" font-size="9" font-weight="700" text-anchor="middle">BR-03?</text>

                <rect x="545" y="165" width="105" height="40" rx="4" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
                <text x="597" y="183" fill="#F97316" font-size="9.5" font-weight="700" text-anchor="middle">Mở phiên check-in</text>
                <text x="597" y="195" fill="#64748B" font-size="8.5" text-anchor="middle">Phát mã QR động</text>

                <!-- Swimlane 4: Quản trị viên -->
                <rect x="0" y="225" width="680" height="70" rx="4" fill="#F8FAFC" stroke="#E2E8F0" />
                <text x="12" y="265" fill="#64748B" font-size="10" font-weight="700">QUẢN TRỊ VIÊN (Web)</text>

                <rect x="130" y="240" width="160" height="40" rx="4" fill="#FEF3C7" stroke="#D97706" stroke-width="1.2" />
                <text x="210" y="258" fill="#D97706" font-size="9.5" font-weight="700" text-anchor="middle">Phê duyệt sự kiện</text>
                <text x="210" y="270" fill="#64748B" font-size="8.5" text-anchor="middle">Draft → Published</text>

                <rect x="360" y="240" width="180" height="40" rx="4" fill="#FEF3C7" stroke="#D97706" stroke-width="1.2" />
                <text x="450" y="258" fill="#D97706" font-size="9.5" font-weight="700" text-anchor="middle">Phân quyền vai trò users</text>
                <text x="450" y="270" fill="#64748B" font-size="8.5" text-anchor="middle">Gán staff theo clubId</text>

                <!-- Arrows -->
                <line x1="177" y1="58" x2="177" y2="82" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="210" y1="110" x2="228" y2="110" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="298" y1="110" x2="316" y2="110" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="372" y1="130" x2="372" y2="160" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="425" y1="185" x2="427" y2="185" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="460" y1="160" x2="460" y2="60" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="495" y1="37" x2="540" y2="37" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />
                <line x1="597" y1="58" x2="597" y2="85" stroke="#94A3B8" stroke-width="1.5" marker-end="url(#arrow)" />

                <!-- Red branch for error -->
                <path d="M 144 110 L 105 110 L 105 37 L 125 37" fill="none" stroke="#DC2626" stroke-width="1.2" stroke-dasharray="3,3" marker-end="url(#arrow-red)" />
                <text x="80" y="70" fill="#DC2626" font-size="8" font-weight="700">Lỗi Form</text>
              </svg>
            </div>
          </div>
        """,
        "panel_note": "Chỉ một sơ đồ tổng thể. Chi tiết từng workflow được trình bày khi demo (18–20).",
        "footer_page": "07"
    })

    # -------------------------------------------------------------------------
    # SLIDE 08 · STATE MACHINE
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-08",
        "page_id": "08",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "08 / STATE MACHINE",
        "slide_num_str": "Slide 8",
        "title_rest": "State Machine — vòng đời đối tượng",
        "subtitle": "Mô tả các trạng thái hợp lệ và quy tắc chuyển trạng thái của business entity.",
        "pill_right": None,
        "question": "Đối tượng chính đi qua những trạng thái nào, chuyển nào bị cấm?",
        "duration": "40 s",
        "evidence": "State diagram của Registration có event, guard, action và chuyển trạng thái bị cấm",
        "left_items": [
            "Business entity trọng tâm: Registration (Đơn đăng ký tham gia sự kiện).",
            "5 Trạng thái hợp lệ: DRAFT → PENDING → APPROVED / REJECTED → ATTENDED (kèm CANCELLED).",
            "Guard conditions: Kiểm tra quyền role == 'staff' cùng clubId, activeCount < capacity.",
            "Chuyển trạng thái bị cấm tuyệt đối: Cấm DRAFT → APPROVED và Cấm REJECTED → APPROVED."
        ],
        "avoid_text": "Vẽ một state diagram cho mỗi màn hình hoặc mỗi tính năng.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="width: 100%; height: 100%; position: relative;">
            <img src="../evidence/diagrams/08-state-machine.svg" alt="State Machine Diagram" 
                 style="width: 100%; height: 100%; object-fit: contain; display: block;" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            
            <!-- Fallback SVG State Diagram -->
            <div style="display: none; width: 100%; height: 100%; flex-direction: column; justify-content: space-between;">
              <svg viewBox="0 0 680 260" style="width: 100%; height: 100%;">
                <defs>
                  <marker id="sm-arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                    <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B" />
                  </marker>
                  <marker id="sm-red-arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                    <path d="M 0 1 L 8 5 L 0 9 z" fill="#DC2626" />
                  </marker>
                </defs>

                <!-- Initial Node -->
                <circle cx="35" cy="65" r="10" fill="#1E293B" />
                <line x1="45" y1="65" x2="75" y2="65" stroke="#64748B" stroke-width="1.5" marker-end="url(#sm-arrow)" />

                <!-- DRAFT -->
                <rect x="80" y="40" width="100" height="50" rx="6" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" />
                <text x="130" y="69" fill="#DB2777" font-size="12" font-weight="700" text-anchor="middle">DRAFT</text>

                <!-- Transition 1 -->
                <line x1="180" y1="65" x2="235" y2="65" stroke="#64748B" stroke-width="1.5" marker-end="url(#sm-arrow)" />
                <text x="207" y="55" fill="#64748B" font-size="9" text-anchor="middle">submit [BR-01,02]</text>

                <!-- PENDING -->
                <rect x="240" y="40" width="115" height="50" rx="6" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
                <text x="297" y="69" fill="#F97316" font-size="12" font-weight="700" text-anchor="middle">PENDING</text>

                <!-- Transition to APPROVED -->
                <line x1="355" y1="65" x2="425" y2="65" stroke="#64748B" stroke-width="1.5" marker-end="url(#sm-arrow)" />
                <text x="390" y="55" fill="#64748B" font-size="9" text-anchor="middle">approve [active&lt;cap]</text>

                <!-- APPROVED -->
                <rect x="430" y="40" width="115" height="50" rx="6" fill="#F0FDF4" stroke="#16A34A" stroke-width="1.5" />
                <text x="487" y="69" fill="#16A34A" font-size="12" font-weight="700" text-anchor="middle">APPROVED</text>

                <!-- Transition to ATTENDED -->
                <line x1="545" y1="65" x2="575" y2="65" stroke="#64748B" stroke-width="1.5" marker-end="url(#sm-arrow)" />
                <text x="560" y="55" fill="#64748B" font-size="8.5" text-anchor="middle">scan QR</text>

                <!-- ATTENDED -->
                <rect x="580" y="40" width="90" height="50" rx="6" fill="#FDF2F8" stroke="#9D174D" stroke-width="1.5" />
                <text x="625" y="69" fill="#9D174D" font-size="11" font-weight="700" text-anchor="middle">ATTENDED</text>

                <!-- REJECTED -->
                <rect x="240" y="160" width="115" height="45" rx="6" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5" />
                <text x="297" y="187" fill="#DC2626" font-size="11" font-weight="700" text-anchor="middle">REJECTED</text>
                <line x1="297" y1="90" x2="297" y2="155" stroke="#64748B" stroke-width="1.5" marker-end="url(#sm-arrow)" />
                <text x="345" y="125" fill="#64748B" font-size="8.5">reject [reason &ge; 3]</text>

                <!-- CANCELLED -->
                <rect x="430" y="160" width="115" height="45" rx="6" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.5" />
                <text x="487" y="187" fill="#64748B" font-size="11" font-weight="700" text-anchor="middle">CANCELLED</text>
                <line x1="487" y1="90" x2="487" y2="155" stroke="#64748B" stroke-width="1.5" marker-end="url(#sm-arrow)" />
                <text x="535" y="125" fill="#64748B" font-size="8.5">cancel [now &lt; start]</text>

                <!-- Red Cấm Arrow (DRAFT -> APPROVED) -->
                <path d="M 130 40 C 130 10, 487 10, 487 35" fill="none" stroke="#DC2626" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#sm-red-arrow)" />
                <text x="300" y="22" fill="#DC2626" font-size="10" font-weight="700" text-anchor="middle">CẤM: DRAFT → APPROVED</text>
              </svg>

              <!-- Footer Rule -->
              <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--slate-200); padding-top: 8px;">
                <div style="font-size: 13px; font-weight: 700; color: var(--tx1);">Transition = Event [Guard] / Action</div>
                <div style="background: rgba(220,38,38,0.14); color: var(--accent6); font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 4px;">
                  Cấm: DRAFT → APPROVED &amp; REJECTED → APPROVED
                </div>
              </div>
            </div>
          </div>
        """,
        "panel_note": "Transition = Event [Guard] / Action. Toàn bộ quy tắc cấm được test tự động trong Rules Test.",
        "footer_page": "08"
    })

    # -------------------------------------------------------------------------
    # SLIDE 09 · SYSTEM ARCHITECTURE
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-09",
        "page_id": "09",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "09 / SYSTEM ARCHITECTURE",
        "slide_num_str": "Slide 9",
        "title_rest": "System Architecture — các khối chính và nơi triển khai",
        "subtitle": "Boundary, ứng dụng, data store, hệ thống ngoài, nơi triển khai và lý do chọn.",
        "pill_right": None,
        "question": "Hệ thống gồm những khối nào, chạy ở đâu, vì sao thiết kế như vậy?",
        "duration": "50 s",
        "evidence": "Sơ đồ C4 Container + Quyết định kiến trúc Serverless Security Rules",
        "left_items": [
            "Kiến trúc C4 Container: Flutter Android App + Flutter Web Admin giao tiếp trực tiếp Firebase.",
            "Không máy chủ trung gian: 0 custom server, 0 Cloud Functions, tiết kiệm 100% chi phí vận hành.",
            "Giao tiếp dữ liệu: HTTPS/gRPC realtime qua .snapshots() lắng nghe trực tiếp từ Cloud Firestore.",
            "Quyết định kiến trúc: Chuyển toàn bộ ràng buộc nghiệp vụ vào Firestore Security Rules (getAfter())."
        ],
        "avoid_text": "Hình hạ tầng quá rối, hoặc chỉ liệt kê công nghệ.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="width: 100%; height: 100%; position: relative;">
            <img src="../evidence/diagrams/09-system-architecture.svg" alt="System Architecture Diagram" 
                 style="width: 100%; height: 100%; object-fit: contain; display: block;" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            
            <!-- Fallback High-Quality Container Architecture -->
            <div style="display: none; width: 100%; height: 100%; flex-direction: column; justify-content: space-between;">
              <div style="display: flex; gap: 14px; align-items: stretch;">
                <!-- Client Box -->
                <div style="flex: 1; border: 1px solid var(--accent1); border-radius: 6px; background: rgba(219,39,119,0.04); padding: 12px; display: flex; flex-direction: column; justify-content: space-between;">
                  <div style="background: var(--accent1); color: #FFF; font-size: 13px; font-weight: 700; text-align: center; padding: 4px; border-radius: 4px;">CLIENT APPLICATIONS</div>
                  <div style="margin: 8px 0; font-size: 12px; color: var(--slate-700); line-height: 1.45;">
                    • <strong>Flutter Android:</strong> Sinh viên (A01..A12)<br>
                    • <strong>Flutter Web:</strong> Trưởng CLB &amp; Admin<br>
                    • <strong>packages/core:</strong> Chia sẻ Models &amp; Services
                  </div>
                  <div style="font-size: 11px; color: var(--muted); background: var(--slate-100); padding: 4px 8px; border-radius: 4px;">Host: Android &amp; Firebase Hosting</div>
                </div>

                <!-- Middle: Cloud Firestore -->
                <div style="flex: 1.2; border: 2px solid var(--accent2); border-radius: 6px; background: rgba(249,115,22,0.04); padding: 12px; display: flex; flex-direction: column; justify-content: space-between;">
                  <div style="background: var(--accent2); color: #FFF; font-size: 13px; font-weight: 700; text-align: center; padding: 4px; border-radius: 4px;">CLOUD FIRESTORE &amp; RULES</div>
                  <div style="margin: 8px 0; font-size: 12px; color: var(--slate-700); line-height: 1.45;">
                    • <strong>NoSQL Realtime:</strong> .snapshots() gRPC sync<br>
                    • <strong>firestore.rules:</strong> Phân quyền 3 roles trực tiếp<br>
                    • <strong>Transactions:</strong> getAfter() khóa sức chứa
                  </div>
                  <div style="font-size: 11px; color: var(--muted); background: var(--slate-100); padding: 4px 8px; border-radius: 4px;">Region: asia-southeast1</div>
                </div>

                <!-- Right: Firebase Suite -->
                <div style="flex: 1; border: 1px solid var(--accent4); border-radius: 6px; background: rgba(217,119,6,0.04); padding: 12px; display: flex; flex-direction: column; justify-content: space-between;">
                  <div style="background: var(--accent4); color: #FFF; font-size: 13px; font-weight: 700; text-align: center; padding: 4px; border-radius: 4px;">FIREBASE CLOUD SUITE</div>
                  <div style="margin: 8px 0; font-size: 12px; color: var(--slate-700); line-height: 1.45;">
                    • <strong>Auth:</strong> Google Sign-In &amp; Email<br>
                    • <strong>FCM:</strong> Push Notification 3 trạng thái<br>
                    • <strong>Remote Config:</strong> Live Feature Flags
                  </div>
                  <div style="font-size: 11px; color: var(--muted); background: var(--slate-100); padding: 4px 8px; border-radius: 4px;">0 Chi phí máy chủ</div>
                </div>
              </div>

              <!-- Local Adapters -->
              <div style="background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 8px 14px; display: flex; justify-content: space-around; font-size: 12.5px;">
                <span style="font-weight: 700; color: var(--tx1);">ADAPTER THIẾT BỊ:</span>
                <span style="color: var(--slate-600);">Local PDF (LocalReportFileService)</span>
                <span style="color: var(--slate-400);">•</span>
                <span style="color: var(--slate-600);">Android Native Share Sheet</span>
                <span style="color: var(--slate-400);">•</span>
                <span style="color: var(--slate-600);">MobileScanner 5.2</span>
              </div>

              <!-- Decision Banner -->
              <div style="background: rgba(234,88,12,0.10); border-radius: 6px; padding: 8px 14px; font-size: 12.5px; font-weight: 700; color: var(--accent3);">
                QUYẾT ĐỊNH: Bỏ Cloud Functions, đưa toàn bộ logic kiểm tra vào Security Rules (getAfter) để đạt độ trễ realtime &lt;100ms và 0 chi phí.
              </div>
            </div>
          </div>
        """,
        "panel_note": "Sơ đồ kiến trúc không máy chủ nhìn là hiểu trong 10–15 giây.",
        "footer_page": "09"
    })

    # -------------------------------------------------------------------------
    # SLIDE 10 · TECHNOLOGY STACK
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-10",
        "page_id": "10",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "10 / TECHNOLOGY STACK",
        "slide_num_str": "Slide 10",
        "title_rest": "Technology Stack — công nghệ theo nhóm",
        "subtitle": "Liệt kê công nghệ đã sử dụng theo từng mảng, mỗi công nghệ gắn với một vai trò cụ thể.",
        "pill_right": None,
        "question": "Hệ thống dùng những công nghệ nào, mỗi thứ để làm gì?",
        "duration": "40 s",
        "evidence": "Công nghệ khớp 100% với mã nguồn trong git repository và file pubspec.yaml",
        "left_items": [
            "Liệt kê theo 6 nhóm: Mobile, Web, Core Package, Backend Cloud, Testing, DevOps.",
            "Mỗi công nghệ gắn với một vai trò thực tế, không đưa vào danh sách chỉ để 'làm đẹp'.",
            "Nêu ngắn lý do chọn: Flutter 3.29 chia sẻ 100% code models/services qua packages/core.",
            "Chỉ đề cập công nghệ đã dùng thật và đang chạy trong mã nguồn hiện hành."
        ],
        "avoid_text": "“Bức tường logo” thiếu lý do sử dụng.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <table class="spec-table">
            <thead>
              <tr>
                <th style="width: 15%;">Nhóm</th>
                <th style="width: 45%;">Công nghệ &amp; Thư viện đã dùng</th>
                <th style="width: 40%;">Dùng để làm gì trong hệ thống</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td style="font-weight: 700; color: var(--accent1);">Mobile</td>
                <td>Flutter 3.29 • Dart 3.7 • Riverpod 2.6 • MobileScanner</td>
                <td>Ứng dụng di động Android cho Sinh viên</td>
              </tr>
              <tr>
                <td style="font-weight: 700; color: var(--accent2);">Web</td>
                <td>Flutter Web • Riverpod • GoRouter 14.8</td>
                <td>Ứng dụng Web Admin cho Trưởng CLB &amp; Admin</td>
              </tr>
              <tr>
                <td style="font-weight: 700; color: var(--accent3);">Core</td>
                <td>packages/core (Models, Contracts, Services, Theme)</td>
                <td>Chia sẻ 100% dữ liệu dùng chung giữa Web và Mobile</td>
              </tr>
              <tr>
                <td style="font-weight: 700; color: var(--accent4);">Backend</td>
                <td>Cloud Firestore • Firebase Security Rules</td>
                <td>Cơ sở dữ liệu realtime &amp; Kiểm soát phân quyền</td>
              </tr>
              <tr>
                <td style="font-weight: 700; color: var(--accent5);">Cloud</td>
                <td>Firebase Auth • FCM • Remote Config • Crashlytics</td>
                <td>Xác thực, Thông báo đẩy, Feature Flags, Báo cáo lỗi</td>
              </tr>
              <tr>
                <td style="font-weight: 700; color: var(--slate-600);">Testing</td>
                <td>Google ARTEMIS • Firestore Emulator • Unit Tests</td>
                <td>Kiểm thử tự động E2E Android &amp; Kiểm thử Rules</td>
              </tr>
              <tr>
                <td style="font-weight: 700; color: var(--accent6);">DevOps</td>
                <td>GitHub Actions • Firebase Hosting</td>
                <td>Tự động hóa kiểm thử và triển khai Web Admin</td>
              </tr>
            </tbody>
          </table>
        """,
        "panel_note": "Toàn bộ stack công nghệ đều hiện diện trong repo mã nguồn và đang vận hành thực tế.",
        "footer_page": "10"
    })

    # -------------------------------------------------------------------------
    # SLIDE 11 · UI/UX DESIGN (Real Screenshots Embedded!)
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-11",
        "page_id": "11",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "11 / UI/UX DESIGN",
        "slide_num_str": "Slide 11",
        "title_rest": "UI/UX Design — giao diện tổng thể",
        "subtitle": "Bức tranh giao diện toàn hệ thống: điều hướng, ngôn ngữ thiết kế và các trạng thái UI.",
        "pill_right": None,
        "question": "Giao diện được tổ chức thế nào và có nhất quán, dễ dùng không?",
        "duration": "40 s",
        "evidence": "Figma Screen Inventory & 4 Trạng thái UI (Loading, Empty, Error, Success)",
        "left_items": [
            "Sitemap 4 tab Mobile (Khám phá A02, Lịch A07, Hộp thư A09, Tài khoản A10) & 4 màn Web.",
            "Wireframe Low-fi → Mockup Hi-fi → Final Flutter (Figma chốt) → Triển khai Flutter Widgets nhất quán.",
            "Chuẩn hóa 4 trạng thái giao diện bắt buộc: Empty, Loading (Shimmer), Error (kèm Retry), Success.",
            "Ghi nhận cải tiến: D11 (Thanh cuộn Filter Chips nhanh), D08 (Giữ form khi mất mạng)."
        ],
        "avoid_text": "Chiếu 20 màn hình Figma không có câu chuyện sử dụng.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <!-- 3 UI Evolution Steps (Interactive Text Links without images) -->
            <div style="display: flex; align-items: stretch; justify-content: space-between; gap: 12px; margin-bottom: 8px;">
              <!-- 1. Wireframe -->
              <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393?node-id=43-313&p=f&t=2npJzoZzH6u54m3R-0" target="_blank" 
                 style="flex: 1; text-decoration: none; border: 1.5px solid var(--slate-300); border-radius: 8px; background: #FFFFFF; padding: 14px 12px; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 1px 3px rgba(0,0,0,0.05); transition: all 0.2s ease;">
                <div>
                  <div style="background: rgba(100,116,139,0.12); color: var(--slate-700); font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 4px; display: inline-block; margin-bottom: 8px;">BƯỚC 1 · WIREFRAME</div>
                  <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Low-fi Prototype</div>
                  <div style="font-size: 12px; color: var(--slate-600); margin-top: 6px; line-height: 1.45;">
                    Khung xương sơ bộ bố cục màn hình Khám phá A02 và các khối tính năng chính.
                  </div>
                </div>
                <div style="margin-top: 14px; background: var(--slate-100); color: var(--slate-700); padding: 8px 10px; border-radius: 6px; font-size: 11.5px; font-weight: 700; display: flex; align-items: center; justify-content: space-between; border: 1px solid var(--slate-200);">
                  <span>🔗 Mở Wireframe Figma</span>
                  <span>↗</span>
                </div>
              </a>

              <div style="display: flex; align-items: center; justify-content: center; color: var(--slate-400); font-weight: 700; font-size: 18px;">→</div>

              <!-- 2. Mockup Figma -->
              <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393?node-id=153-2&p=f&t=2npJzoZzH6u54m3R-0" target="_blank" 
                 style="flex: 1; text-decoration: none; border: 1.5px solid var(--accent1); border-radius: 8px; background: rgba(219,39,119,0.02); padding: 14px 12px; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 1px 3px rgba(219,39,119,0.08); transition: all 0.2s ease;">
                <div>
                  <div style="background: rgba(219,39,119,0.14); color: var(--accent1); font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 4px; display: inline-block; margin-bottom: 8px;">BƯỚC 2 · MOCKUP</div>
                  <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Hi-fi Design Tokens</div>
                  <div style="font-size: 12px; color: var(--slate-600); margin-top: 6px; line-height: 1.45;">
                    Chuẩn hóa bảng màu Cam-Vàng-Hồng, Typography, Component cards và nút bấm.
                  </div>
                </div>
                <div style="margin-top: 14px; background: rgba(219,39,119,0.10); color: var(--accent1); padding: 8px 10px; border-radius: 6px; font-size: 11.5px; font-weight: 700; display: flex; align-items: center; justify-content: space-between; border: 1px solid rgba(219,39,119,0.25);">
                  <span>🔗 Mở Mockup Figma</span>
                  <span>↗</span>
                </div>
              </a>

              <div style="display: flex; align-items: center; justify-content: center; color: var(--slate-400); font-weight: 700; font-size: 18px;">→</div>

              <!-- 3. Final Flutter -->
              <a href="https://www.figma.com/design/WC21Na9ZDS8jjM2LzPKeXa/PRM393?node-id=199-1681&p=f&t=2npJzoZzH6u54m3R-0" target="_blank" 
                 style="flex: 1; text-decoration: none; border: 1.5px solid var(--accent2); border-radius: 8px; background: rgba(249,115,22,0.02); padding: 14px 12px; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 1px 3px rgba(249,115,22,0.08); transition: all 0.2s ease;">
                <div>
                  <div style="background: rgba(249,115,22,0.14); color: var(--accent2); font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 4px; display: inline-block; margin-bottom: 8px;">BƯỚC 3 · FINAL FLUTTER</div>
                  <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Bản chốt triển khai</div>
                  <div style="font-size: 12px; color: var(--slate-600); margin-top: 6px; line-height: 1.45;">
                    Giao diện chốt chuyển giao cho Flutter Widgets chạy thật trên điện thoại Android.
                  </div>
                </div>
                <div style="margin-top: 14px; background: rgba(249,115,22,0.10); color: var(--accent2); padding: 8px 10px; border-radius: 6px; font-size: 11.5px; font-weight: 700; display: flex; align-items: center; justify-content: space-between; border: 1px solid rgba(249,115,22,0.25);">
                  <span>🔗 Mở Final Flutter</span>
                  <span>↗</span>
                </div>
              </a>
            </div>

            <!-- 4 UI States -->
            <div style="display: flex; gap: 8px; justify-content: center;">
              <span style="background: rgba(148,163,184,0.14); color: var(--slate-600); font-weight: 700; padding: 5px 12px; border-radius: 6px; font-size: 12px;">Empty State</span>
              <span style="background: rgba(219,39,119,0.14); color: var(--accent1); font-weight: 700; padding: 5px 12px; border-radius: 6px; font-size: 12px;">Loading (Shimmer)</span>
              <span style="background: rgba(220,38,38,0.14); color: var(--accent6); font-weight: 700; padding: 5px 12px; border-radius: 6px; font-size: 12px;">Error (kèm Retry)</span>
              <span style="background: rgba(22,163,74,0.14); color: #16A34A; font-weight: 700; padding: 5px 12px; border-radius: 6px; font-size: 12px;">Success (Biên nhận)</span>
            </div>

            <!-- Feedback improvement bar -->
            <div style="background: rgba(217,119,6,0.10); border-radius: 6px; padding: 8px 12px; font-size: 12.5px; font-weight: 700; color: var(--accent4);">
              SAU GÓP Ý: [D11 Filter Chips] → Bổ sung thanh cuộn ngang lọc nhanh theo CLB giúp giảm 2 thao tác chạm khi tìm kiếm sự kiện.
            </div>
          </div>
        """,
        "panel_note": "Chọn lọc các màn hình đại diện; thao tác chi tiết sẽ thấy trực tiếp khi demo.",
        "footer_page": "11"
    })

    # -------------------------------------------------------------------------
    # SLIDE 12 · SEQUENCE DIAGRAM
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-12",
        "page_id": "12",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "12 / SEQUENCE DIAGRAM",
        "slide_num_str": "Slide 12",
        "title_rest": "Sequence Diagram — các thành phần phối hợp",
        "subtitle": "Một tương tác tiêu biểu giữa UI, service, repository và hệ thống ngoài.",
        "pill_right": "TÙY CHỌN",
        "question": "Khi người dùng bấm nút, bên trong hệ thống diễn ra những gì?",
        "duration": "35 s",
        "evidence": "Sequence diagram tương tác Duyệt đơn (approveRegistration) có nhánh ngoại lệ hết chỗ",
        "left_items": [
            "Chọn tương tác cốt lõi nhất: Trưởng CLB duyệt đơn đăng ký trên Web Admin (approveRegistration).",
            "Lifeline khớp đúng class trong code: :ReviewQueueView → :ReviewQueueVM → :FirestoreServices → DB.",
            "Thể hiện rõ nhánh ngoại lệ (alt): Khi sự kiện vừa hết chỗ (activeCount >= capacity) trong lúc duyệt.",
            "Tên message là tên hàm thật: approveRegistration(), runTransaction(), getAfter()."
        ],
        "avoid_text": "Vẽ sequence cho mọi tính năng.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="width: 100%; height: 100%; position: relative;">
            <img src="../evidence/diagrams/12-sequence-diagram.svg" alt="Sequence Diagram" 
                 style="width: 100%; height: 100%; object-fit: contain; display: block;" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            
            <!-- Fallback Detailed SVG Sequence Diagram -->
            <div style="display: none; width: 100%; height: 100%; flex-direction: column; justify-content: space-between;">
              <svg viewBox="0 0 680 260" style="width: 100%; height: 100%;">
                <defs>
                  <marker id="seq-arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                    <path d="M 0 1 L 8 5 L 0 9 z" fill="#1E293B" />
                  </marker>
                  <marker id="seq-dash-arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                    <path d="M 0 1 L 8 5 L 0 9 z" fill="#94A3B8" />
                  </marker>
                </defs>

                <!-- Lifeline Boxes -->
                <rect x="20" y="5" width="110" height="30" rx="4" fill="#FFF7ED" stroke="#F97316" stroke-width="1.2" />
                <text x="75" y="24" fill="#F97316" font-size="10" font-weight="700" text-anchor="middle">Trưởng CLB (Actor)</text>

                <rect x="180" y="5" width="120" height="30" rx="4" fill="#FFF7ED" stroke="#F97316" stroke-width="1.2" />
                <text x="240" y="24" fill="#F97316" font-size="10" font-weight="700" text-anchor="middle">:ReviewQueueView</text>

                <rect x="350" y="5" width="120" height="30" rx="4" fill="#FFF7ED" stroke="#F97316" stroke-width="1.2" />
                <text x="410" y="24" fill="#F97316" font-size="10" font-weight="700" text-anchor="middle">:ReviewQueueVM</text>

                <rect x="520" y="5" width="140" height="30" rx="4" fill="#FFF7ED" stroke="#F97316" stroke-width="1.2" />
                <text x="590" y="24" fill="#F97316" font-size="10" font-weight="700" text-anchor="middle">Firestore &amp; Rules</text>

                <!-- Lifeline Dashes -->
                <line x1="75" y1="35" x2="75" y2="250" stroke="#CBD5E1" stroke-width="1" stroke-dasharray="3,3" />
                <line x1="240" y1="35" x2="240" y2="250" stroke="#CBD5E1" stroke-width="1" stroke-dasharray="3,3" />
                <line x1="410" y1="35" x2="410" y2="250" stroke="#CBD5E1" stroke-width="1" stroke-dasharray="3,3" />
                <line x1="590" y1="35" x2="590" y2="250" stroke="#CBD5E1" stroke-width="1" stroke-dasharray="3,3" />

                <!-- 1. click approve -->
                <line x1="75" y1="65" x2="235" y2="65" stroke="#1E293B" stroke-width="1.2" marker-end="url(#seq-arrow)" />
                <text x="150" y="58" fill="#1E293B" font-size="9" text-anchor="middle">1. Bấm 'Phê duyệt' (id)</text>

                <!-- 2. approveRegistration -->
                <line x1="240" y1="90" x2="405" y2="90" stroke="#1E293B" stroke-width="1.2" marker-end="url(#seq-arrow)" />
                <text x="325" y="83" fill="#1E293B" font-size="9" text-anchor="middle">2. approveRegistration(id, eventId)</text>

                <!-- 3. runTransaction -->
                <line x1="410" y1="115" x2="585" y2="115" stroke="#1E293B" stroke-width="1.2" marker-end="url(#seq-arrow)" />
                <text x="500" y="108" fill="#1E293B" font-size="9" text-anchor="middle">3. runTransaction(update reg + event)</text>

                <!-- alt Frame -->
                <rect x="170" y="130" width="480" height="60" fill="rgba(220,38,38,0.06)" stroke="#DC2626" stroke-width="1" stroke-dasharray="3,2" />
                <text x="180" y="145" fill="#DC2626" font-size="9" font-weight="700">alt [Vượt sức chứa: getAfter(event).activeCount &gt; capacity] (BR-01)</text>
                <line x1="585" y1="165" x2="245" y2="165" stroke="#DC2626" stroke-width="1.2" stroke-dasharray="4,2" marker-end="url(#seq-dash-arrow)" />
                <text x="410" y="160" fill="#DC2626" font-size="8.5" text-anchor="middle">409 Conflict / Rollback (Báo hết chỗ)</text>

                <!-- 4. 200 OK -->
                <line x1="585" y1="210" x2="415" y2="210" stroke="#16A34A" stroke-width="1.2" stroke-dasharray="4,2" marker-end="url(#seq-dash-arrow)" />
                <text x="500" y="203" fill="#16A34A" font-size="9" text-anchor="middle">200 OK (status=approved, activeCount+1)</text>

                <line x1="405" y1="230" x2="245" y2="230" stroke="#16A34A" stroke-width="1.2" stroke-dasharray="4,2" marker-end="url(#seq-dash-arrow)" />
                <text x="325" y="223" fill="#16A34A" font-size="9" text-anchor="middle">Cập nhật UI Đã duyệt &amp; Bắn FCM Push</text>
              </svg>
            </div>
          </div>
        """,
        "panel_note": "Ví dụ minh họa: nhánh ngoại lệ khi vi phạm business rule hết chỗ (BR-01).",
        "footer_page": "12"
    })

    # -------------------------------------------------------------------------
    # SLIDE 13 · CLASS DESIGN
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-13",
        "page_id": "13",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "13 / CLASS DESIGN",
        "slide_num_str": "Slide 13",
        "title_rest": "Class Design — trách nhiệm & quan hệ",
        "subtitle": "Class diagram mô tả thiết kế code, không phải bản sao của ERD.",
        "pill_right": None,
        "question": "Code chia trách nhiệm ra sao, business rule nằm ở đâu?",
        "duration": "30 s",
        "evidence": "Class diagram khớp 100% tên class trong mobile/lib và packages/core/lib",
        "left_items": [
            "Kiến trúc MVVM phân tầng chặt chẽ: Screen (View) → ViewModel → Service Contract → Service.",
            "Phân tách rõ Domain Entity (Registration, Event) với ViewModel điều phối logic.",
            "Tách riêng Service Contract (EventService, AuthService) để dễ dàng mock trong unit test.",
            "Business rules (BR-01, BR-02) được kiểm tra tại ViewModel và bắt buộc thực thi bởi Rules."
        ],
        "avoid_text": "Chuyển mọi bảng database thành class có getter/setter.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="width: 100%; height: 100%; position: relative;">
            <img src="../evidence/diagrams/13-class-design.svg" alt="Class Design Diagram" 
                 style="width: 100%; height: 100%; object-fit: contain; display: block;" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            
            <!-- Fallback Detailed UML Class Boxes -->
            <div style="display: none; width: 100%; height: 100%; flex-direction: column; justify-content: space-between;">
              <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px;">
                <div style="border: 1px solid var(--slate-200); border-radius: 6px; overflow: hidden; background: #FFF;">
                  <div style="background: rgba(219,39,119,0.15); color: var(--accent1); font-size: 13px; font-weight: 700; text-align: center; padding: 5px;">BookingViewModel</div>
                  <div style="padding: 8px; font-size: 11.5px; color: var(--slate-700); line-height: 1.5;">
                    + submitRegistration()<br>
                    + cancelRegistration()<br>
                    + recoverPending()<br>
                    + state: AsyncValue
                  </div>
                </div>

                <div style="border: 1px solid var(--slate-200); border-radius: 6px; overflow: hidden; background: #FFF;">
                  <div style="background: rgba(249,115,22,0.15); color: var(--accent2); font-size: 13px; font-weight: 700; text-align: center; padding: 5px;">FirestoreEventService</div>
                  <div style="padding: 8px; font-size: 11.5px; color: var(--slate-700); line-height: 1.5;">
                    + registerEvent(form, opId)<br>
                    + approveRegistration(id)<br>
                    + checkInWithQr(qrHash)<br>
                    &laquo;implements EventService&raquo;
                  </div>
                </div>

                <div style="border: 1px solid var(--slate-200); border-radius: 6px; overflow: hidden; background: #FFF;">
                  <div style="background: rgba(217,119,6,0.15); color: var(--accent4); font-size: 13px; font-weight: 700; text-align: center; padding: 5px;">SecureBookingStore</div>
                  <div style="padding: 8px; font-size: 11.5px; color: var(--slate-700); line-height: 1.5;">
                    + savePending(uid, opId)<br>
                    + getPending(uid)<br>
                    + clearPending(uid)<br>
                    (Phục hồi khi mất mạng)
                  </div>
                </div>
              </div>

              <!-- Domain Model & Note -->
              <div style="display: flex; gap: 12px; align-items: center;">
                <div style="flex: 1; border: 1px solid var(--slate-200); border-radius: 6px; overflow: hidden; background: #FFF;">
                  <div style="background: rgba(234,88,12,0.15); color: var(--accent3); font-size: 13px; font-weight: 700; text-align: center; padding: 5px;">Registration (Domain Model)</div>
                  <div style="padding: 6px 12px; font-size: 11.5px; color: var(--slate-700); display: flex; justify-content: space-between;">
                    <span>+ id: String</span>
                    <span>+ status: RegistrationStatus</span>
                    <span>+ generation: int</span>
                    <span>+ checkInAt: DateTime?</span>
                  </div>
                </div>
                <div style="width: 220px; font-size: 11.5px; font-style: italic; color: var(--slate-600); line-height: 1.3;">
                  Domain entity độc lập với SDK, chia sẻ 100% qua package core.
                </div>
              </div>

              <div style="background: rgba(100,116,139,0.10); border-radius: 6px; padding: 8px 14px; font-size: 12px; color: var(--slate-600);">
                Business rules (BR-01, BR-02) đặt trong ViewModel &amp; Service, được kiểm chứng 100% bằng Unit Tests.
              </div>
            </div>
          </div>
        """,
        "panel_note": "Domain entity &ne; database table (không mặc định 1:1).",
        "footer_page": "13"
    })

    # -------------------------------------------------------------------------
    # SLIDE 14 · DATABASE DESIGN — CONCEPTUAL
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-14",
        "page_id": "14",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "14 / DATABASE DESIGN — CONCEPTUAL",
        "slide_num_str": "Slide 14",
        "title_rest": "Database Design 1/2 — mô hình khái niệm",
        "subtitle": "Mô hình hóa ngữ nghĩa nghiệp vụ, chưa phụ thuộc SQL hay DBMS.",
        "pill_right": "TÙY CHỌN — có thể gộp vào slide 15",
        "question": "Dữ liệu nghiệp vụ gồm những thực thể nào, quan hệ ra sao?",
        "duration": "25 s",
        "evidence": "Sơ đồ Conceptual ERD chuẩn quan hệ ngữ nghĩa kèm cardinality và business rules",
        "left_items": [
            "5 Thực thể nghiệp vụ cốt lõi: USER, CLUB, EVENT, REGISTRATION, CHECKIN_SESSION.",
            "Bản chất quan hệ ngữ nghĩa: Một Club tổ chức Nhiều Event; Một User đăng ký Nhiều Event.",
            "Cardinality: Mỗi Registration thuộc đúng 1 User và 1 Event (quan hệ n–n được phân rã).",
            "Business rule chi phối quan hệ: Mỗi User chỉ có tối đa 1 Registration active cho cùng 1 Event."
        ],
        "avoid_text": "Thêm VARCHAR, INT, PK vật lý vào conceptual ERD.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="width: 100%; height: 100%; position: relative;">
            <img src="../evidence/diagrams/14-conceptual-erd.svg" alt="Conceptual ERD" 
                 style="width: 100%; height: 100%; object-fit: contain; display: block;" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            
            <!-- Fallback Conceptual ERD Diagram -->
            <div style="display: none; width: 100%; height: 100%; flex-direction: column; justify-content: space-between;">
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 0;">
                <div style="width: 125px; height: 70px; background: rgba(249,115,22,0.12); border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
                  <div style="font-size: 13.5px; font-weight: 700; color: var(--accent2);">USER</div>
                  <div style="font-size: 11.5px; color: var(--slate-600);">Người dùng</div>
                </div>

                <div style="text-align: center; font-size: 11px; font-weight: 700; color: var(--muted);">1 ────── 0..*</div>

                <div style="width: 145px; height: 70px; background: rgba(219,39,119,0.12); border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
                  <div style="font-size: 13.5px; font-weight: 700; color: var(--accent1);">REGISTRATION</div>
                  <div style="font-size: 11.5px; color: var(--slate-600);">Đơn đăng ký</div>
                </div>

                <div style="text-align: center; font-size: 11px; font-weight: 700; color: var(--muted);">0..* ────── 1</div>

                <div style="width: 125px; height: 70px; background: rgba(249,115,22,0.12); border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
                  <div style="font-size: 13.5px; font-weight: 700; color: var(--accent2);">EVENT</div>
                  <div style="font-size: 11.5px; color: var(--slate-600);">Sự kiện</div>
                </div>

                <div style="text-align: center; font-size: 11px; font-weight: 700; color: var(--muted);">1 ────── 0..1</div>

                <div style="width: 135px; height: 70px; background: rgba(217,119,6,0.12); border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
                  <div style="font-size: 12.5px; font-weight: 700; color: var(--accent4);">CHECKIN SESSION</div>
                  <div style="font-size: 11.5px; color: var(--slate-600);">Phiên điểm danh</div>
                </div>
              </div>

              <div style="background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 6px; padding: 12px 16px;">
                <div style="font-size: 13px; font-weight: 700; color: var(--tx1); margin-bottom: 6px;">Business rules ngữ nghĩa chi phối:</div>
                <div style="font-size: 12px; color: var(--slate-700); line-height: 1.5;">
                  • <strong>BR-01 (Định danh đăng ký):</strong> Mỗi Registration thuộc đúng một User và một Event (ID: {uid}_{eventId}).<br>
                  • <strong>BR-02 (Quyền sở hữu sự kiện):</strong> Mỗi Event thuộc đúng một Club; chỉ Trưởng CLB đó (staff) mới có quyền duyệt đơn và mở phiên QR.<br>
                  • <strong>BR-03 (Bảo toàn phiên):</strong> Một sự kiện chỉ có tối đa 1 phiên điểm danh QR mở tại một thời điểm.
                </div>
              </div>
            </div>
          </div>
        """,
        "panel_note": "Mã BR dùng lại ở luồng nghiệp vụ (07) và kiểm thử (21).",
        "footer_page": "14"
    })

    # -------------------------------------------------------------------------
    # SLIDE 15 · DATABASE DESIGN — LOGICAL → PHYSICAL
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-15",
        "page_id": "15",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "15 / DATABASE DESIGN — LOGICAL → PHYSICAL",
        "slide_num_str": "Slide 15",
        "title_rest": "Database Design 2/2 — từ logic đến vật lý",
        "subtitle": "Từ cấu trúc logic sang database đang chạy, có minh chứng triển khai.",
        "pill_right": None,
        "question": "Dữ liệu được hiện thực đúng và có ràng buộc bảo vệ chưa?",
        "duration": "30 s",
        "evidence": "Tệp cấu hình firestore.rules và firestore.indexes.json triển khai thật trên Firebase Console",
        "left_items": [
            "Logical: Định nghĩa thuộc tính, identifier, và các ràng buộc toàn vẹn.",
            "Physical: NoSQL Cloud Firestore collections (users, clubs, events, registrations).",
            "Ràng buộc bảo vệ: Security Rules kiểm tra status in ['pending', 'approved', 'rejected', 'cancelled'].",
            "Minh chứng: File firestore.rules & composite index events(clubId, status, startsAt)."
        ],
        "avoid_text": "Coi screenshot các bảng là thiết kế vật lý hoàn chỉnh.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; gap: 14px; height: 100%;">
            <div style="flex: 0.85; border: 1px solid var(--slate-200); border-radius: 6px; overflow: hidden; background: #FFF;">
              <div style="background: rgba(249,115,22,0.15); color: var(--accent2); font-size: 13px; font-weight: 700; text-align: center; padding: 6px;">
                REGISTRATION (Logical)
              </div>
              <div style="padding: 10px; font-size: 12px; color: var(--slate-700); line-height: 1.7;">
                • RegistrationId (PK)<br>
                • UserId (ref users)<br>
                • EventId (ref events)<br>
                • ClubId (ref clubs)<br>
                • Status (Enum)<br>
                • Generation (int)<br>
                • CheckInAt (timestamp)<br>
                • LastOperationId (hex)
              </div>
            </div>

            <div style="flex: 1.65; display: flex; flex-direction: column; justify-content: space-between;">
              <table class="spec-table" style="font-size: 11.5px;">
                <thead>
                  <tr>
                    <th>Trường (Field)</th>
                    <th>Kiểu NoSQL</th>
                    <th>Ràng buộc (Security Rules)</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td style="font-weight: 700;">uid / eventId</td>
                    <td>string</td>
                    <td>ID khớp doc: uid + '_' + eventId</td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700;">status</td>
                    <td>string</td>
                    <td>CHECK IN ['pending','approved','rejected','cancelled']</td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700;">generation</td>
                    <td>int</td>
                    <td>CHECK &ge; 1 (tăng khi re-register)</td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700;">reason</td>
                    <td>string?</td>
                    <td>Bắt buộc khi rejected (size 3..300)</td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700;">lastOperationId</td>
                    <td>string</td>
                    <td>Khóa 48 ký tự hex chống gửi trùng</td>
                  </tr>
                </tbody>
              </table>

              <div style="background: rgba(249,115,22,0.10); border-radius: 6px; padding: 6px 12px; font-size: 12px; font-weight: 700; color: var(--accent2);">
                COMPOSITE INDEX: events(clubId, status, startsAt) • File: firebase/firestore.indexes.json
              </div>
            </div>
          </div>
        """,
        "panel_note": "Schema vật lý đầy đủ của 7 collections được lưu trữ tại Phụ lục A4.",
        "footer_page": "15"
    })

    # -------------------------------------------------------------------------
    # SLIDE 16 · TRACEABILITY
    # -------------------------------------------------------------------------
    slides.append({
        "id": "slide-16",
        "page_id": "16",
        "phase_tag": "P2 · DESIGN",
        "phase_color": "var(--accent3)",
        "phase_bg": "rgba(234,88,12,0.14)",
        "box_bg": "rgba(234,88,12,0.08)",
        "section_str": "16 / TRACEABILITY",
        "slide_num_str": "Slide 16",
        "title_rest": "Traceability — kiểm tra tính nhất quán của thiết kế",
        "subtitle": "Mỗi nhóm tính năng phải được nhìn thấy nhất quán qua UI, code, data và test.",
        "pill_right": None,
        "question": "Các bản thiết kế có khớp nhau và có được dùng thật không?",
        "duration": "30 s",
        "evidence": "Ma trận Feature → Screen → Class/Service → Firestore Entity → Test Case",
        "left_items": [
            "Mỗi nhóm tính năng có mã riêng: F1 (Đăng ký sự kiện), F2 (Phê duyệt đơn), F3 (Điểm danh QR).",
            "Ánh xạ nhất quán: Feature ↔ Screen ↔ ViewModel/Service ↔ Entity ↔ Test Case.",
            "Tất cả Business Rule và nhánh rẽ ngoại lệ đều sinh ra Test Case kiểm thử tự động.",
            "Phát hiện và loại bỏ thiết kế 'thừa thãi' — 100% bản vẽ đều có mã nguồn hiện thực."
        ],
        "avoid_text": "Bắt 1 class / 1 bảng / 1 màn hình cho mỗi tính năng.",
        "panel_label": "MẪU BỐ CỤC",
        "panel_content_html": """
          <div style="display: flex; flex-direction: column; height: 100%; justify-content: space-between;">
            <table class="spec-table">
              <thead>
                <tr>
                  <th style="width: 20%;">Feature</th>
                  <th style="width: 18%;">Screen</th>
                  <th style="width: 24%;">Class / Service</th>
                  <th style="width: 20%;">Firestore Entity</th>
                  <th style="width: 18%;">Tests</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td style="font-weight: 700; color: var(--accent1);">F1 Đăng ký sự kiện</td>
                  <td>A04, A05, A06</td>
                  <td>BookingViewModel</td>
                  <td>registrations</td>
                  <td>TC01–04</td>
                </tr>
                <tr>
                  <td style="font-weight: 700; color: var(--accent2);">F2 Phê duyệt đơn</td>
                  <td>Web ReviewQueue</td>
                  <td>ReviewQueueViewModel</td>
                  <td>registrations, events</td>
                  <td>TC05–08</td>
                </tr>
                <tr>
                  <td style="font-weight: 700; color: var(--accent4);">F3 Điểm danh QR</td>
                  <td>A11, A12 &amp; LiveQr</td>
                  <td>ScannerViewModel</td>
                  <td>checkinSessions, qr</td>
                  <td>TC09–12</td>
                </tr>
                <tr>
                  <td style="font-weight: 700; color: var(--accent5);">F4 Báo cáo PDF</td>
                  <td>ExportScreen (A10)</td>
                  <td>ExportViewModel</td>
                  <td>users/{uid}/reports</td>
                  <td>TC13–15</td>
                </tr>
              </tbody>
            </table>

            <div style="background: rgba(249,115,22,0.10); border-radius: 6px; padding: 10px 14px; text-align: center; font-size: 14px; font-weight: 700; color: var(--accent2);">
              TRUY VẾT: Feature → Screen → Class → Database → Test Case (Khép kín 100%)
            </div>
          </div>
        """,
        "panel_note": "Slide chốt phần Design: Khẳng định sự đồng bộ từ tài liệu thiết kế đến mã nguồn.",
        "footer_page": "16"
    })

    return slides
