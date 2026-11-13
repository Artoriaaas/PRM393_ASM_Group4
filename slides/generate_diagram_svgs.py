# -*- coding: utf-8 -*-
"""
generate_diagram_svgs.py - Generate high-quality standalone SVG diagrams
into evidence/diagrams/ for EventHub PRM393 presentation.
Color palette: Cam - Vàng - Hồng (Warm Ember).
"""
import os

DIAGRAMS_DIR = os.path.join(os.path.dirname(__file__), "..", "evidence", "diagrams")
os.makedirs(DIAGRAMS_DIR, exist_ok=True)

# -----------------------------------------------------------------------------
# 1. 07-business-flow.svg (Swimlane 4 làn: Sinh viên, Hệ thống, Trưởng CLB, Admin)
# -----------------------------------------------------------------------------
svg_07 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 480" width="100%" height="100%">
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B" />
    </marker>
    <marker id="arrow-pink" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#DB2777" />
    </marker>
    <marker id="arrow-orange" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#EA580C" />
    </marker>
    <marker id="arrow-red" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#DC2626" />
    </marker>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="480" rx="8" fill="#FFFFFF" />

  <!-- Title & Legend -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ NGHIỆP VỤ LIÊN VAI TRÒ (CROSS-ROLE ACTIVITY &amp; BUSINESS FLOW)</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 ASM · 4 Làn phối hợp: Sinh viên (Mobile), Hệ thống (Rules), Trưởng CLB (Web), Admin (Web)</text>

  <!-- Swimlane 1: Sinh viên -->
  <rect x="20" y="60" width="920" height="95" rx="6" fill="#FDF2F8" stroke="#FBCFE8" stroke-width="1" />
  <rect x="20" y="60" width="130" height="95" rx="6" fill="#DB2777" opacity="0.12" />
  <text x="35" y="105" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#9D174D">SINH VIÊN</text>
  <text x="35" y="122" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Mobile App (Flutter)</text>

  <!-- SV Nodes -->
  <circle cx="175" cy="107" r="12" fill="#DB2777" />
  <text x="175" y="111" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#FFF" text-anchor="middle">Start</text>

  <rect x="210" y="85" width="120" height="45" rx="6" fill="#FFF" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <text x="270" y="104" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777" text-anchor="middle">Điền form ĐK</text>
  <text x="270" y="120" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Màn hình A05</text>

  <rect x="580" y="85" width="135" height="45" rx="6" fill="#FFF" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <text x="647" y="104" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777" text-anchor="middle">Nhận vé QR + Inbox</text>
  <text x="647" y="120" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Push FCM · Màn A08/A09</text>

  <rect x="755" y="85" width="125" height="45" rx="6" fill="#FFF" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <text x="817" y="104" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777" text-anchor="middle">Quét QR Hội trường</text>
  <text x="817" y="120" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Scanner A11 → Biên nhận A12</text>

  <!-- Swimlane 2: Hệ thống (Firestore & Rules) -->
  <rect x="20" y="165" width="920" height="105" rx="6" fill="#FFFBEB" stroke="#FDE68A" stroke-width="1" />
  <rect x="20" y="165" width="130" height="105" rx="6" fill="#D97706" opacity="0.12" />
  <text x="35" y="212" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#B45309">HỆ THỐNG</text>
  <text x="35" y="229" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Firestore Rules Serverless</text>

  <!-- Decision BR-02 -->
  <polygon points="270,180 305,210 270,240 235,210" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="270" y="213" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#B45309" text-anchor="middle">BR-02?</text>

  <!-- Decision BR-01 -->
  <polygon points="370,180 405,210 370,240 335,210" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="370" y="213" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#B45309" text-anchor="middle">BR-01?</text>

  <rect x="430" y="188" width="125" height="45" rx="6" fill="#FFF" stroke="#EA580C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="492" y="207" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#EA580C" text-anchor="middle">Tạo đơn PENDING</text>
  <text x="492" y="223" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">activeCount chưa tăng</text>

  <rect x="755" y="188" width="125" height="45" rx="6" fill="#FFF" stroke="#059669" stroke-width="1.5" filter="url(#shadow)" />
  <text x="817" y="207" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#059669" text-anchor="middle">Xác thực SHA-256</text>
  <text x="817" y="223" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Ghi checkInAt (BR-04, 05)</text>

  <!-- Swimlane 3: Trưởng CLB -->
  <rect x="20" y="280" width="920" height="95" rx="6" fill="#FFF7ED" stroke="#FED7AA" stroke-width="1" />
  <rect x="20" y="280" width="130" height="95" rx="6" fill="#EA580C" opacity="0.12" />
  <text x="35" y="325" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#C2410C">TRƯỞNG CLB</text>
  <text x="35" y="342" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Web Admin (Role: staff)</text>

  <rect x="430" y="302" width="125" height="48" rx="6" fill="#FFF" stroke="#EA580C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="492" y="322" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#EA580C" text-anchor="middle">Review Queue Realtime</text>
  <text x="492" y="338" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Đơn mới tự đẩy qua snapshot</text>

  <!-- Decision BR-03 -->
  <polygon points="647,295 682,325 647,355 612,325" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="647" y="328" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#B45309" text-anchor="middle">Duyệt?</text>

  <rect x="755" y="302" width="125" height="48" rx="6" fill="#FFF" stroke="#EA580C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="817" y="322" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#EA580C" text-anchor="middle">Mở Phiên QR Hội trường</text>
  <text x="817" y="338" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Ghi qrCredentials/{hash}</text>

  <!-- Swimlane 4: Quản trị viên (Admin) -->
  <rect x="20" y="385" width="920" height="80" rx="6" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1" />
  <rect x="20" y="385" width="130" height="80" rx="6" fill="#64748B" opacity="0.12" />
  <text x="35" y="425" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#334155">QUẢN TRỊ VIÊN</text>
  <text x="35" y="442" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Web System (Role: admin)</text>

  <rect x="210" y="402" width="140" height="45" rx="6" fill="#FFF" stroke="#64748B" stroke-width="1.2" filter="url(#shadow)" />
  <text x="280" y="422" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#334155" text-anchor="middle">Duyệt sự kiện CLB</text>
  <text x="280" y="437" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">status: draft → published</text>

  <rect x="580" y="402" width="150" height="45" rx="6" fill="#FFF" stroke="#64748B" stroke-width="1.2" filter="url(#shadow)" />
  <text x="655" y="422" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#334155" text-anchor="middle">Audit Logs &amp; Analytics</text>
  <text x="655" y="437" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Giám sát tài khoản &amp; thống kê</text>

  <!-- Connectors -->
  <!-- SV -> System BR-02 -->
  <line x1="187" y1="107" x2="208" y2="107" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="270" y1="130" x2="270" y2="178" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  
  <!-- BR-02 Yes -> BR-01 -->
  <line x1="305" y1="210" x2="333" y2="210" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="319" y="204" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#16A34A" font-weight="700">Hợp lệ</text>

  <!-- BR-02 No -> Back to SV -->
  <path d="M 270 240 L 270 255 L 190 255 L 190 120 L 208 120" fill="none" stroke="#DC2626" stroke-width="1.2" stroke-dasharray="3,2" marker-end="url(#arrow-red)" />
  <text x="215" y="250" font-family="Calibri, Arial, sans-serif" font-size="8" fill="#DC2626" font-weight="700">Báo lỗi form A05</text>

  <!-- BR-01 Yes -> Create PENDING -->
  <line x1="405" y1="210" x2="428" y2="210" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="416" y="204" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#16A34A" font-weight="700">Còn chỗ</text>

  <!-- PENDING -> Web Queue -->
  <line x1="492" y1="233" x2="492" y2="300" stroke="#EA580C" stroke-width="1.5" marker-end="url(#arrow-orange)" />
  <text x="502" y="268" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#EA580C" font-weight="700">Realtime sync</text>

  <!-- Web Queue -> Decision BR-03 -->
  <line x1="555" y1="325" x2="610" y2="325" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />

  <!-- BR-03 Approve -> SV Receive QR -->
  <path d="M 647 295 L 647 132" fill="none" stroke="#DB2777" stroke-width="1.5" marker-end="url(#arrow-pink)" />
  <text x="655" y="215" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#16A34A" font-weight="700">Duyệt (activeCount+1)</text>

  <!-- SV QR -> Scanner Hội trường -->
  <line x1="715" y1="107" x2="753" y2="107" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />

  <!-- Web Open QR -> System Validate -->
  <line x1="817" y1="302" x2="817" y2="235" stroke="#EA580C" stroke-width="1.5" marker-end="url(#arrow-orange)" />
  <text x="825" y="268" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#EA580C" font-weight="700">Mở session</text>

  <!-- SV Scan -> System Validate -->
  <line x1="817" y1="130" x2="817" y2="186" stroke="#DB2777" stroke-width="1.5" marker-end="url(#arrow-pink)" />

  <!-- End Node -->
  <circle cx="910" cy="210" r="14" fill="#059669" />
  <circle cx="910" cy="210" r="10" fill="#FFF" />
  <circle cx="910" cy="210" r="7" fill="#059669" />
  <line x1="880" y1="210" x2="894" y2="210" stroke="#059669" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="910" y="238" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#059669" text-anchor="middle">HOÀN TẤT</text>
</svg>
"""

# -----------------------------------------------------------------------------
# 2. 08-state-machine.svg (Vòng đời Registration Entity)
# -----------------------------------------------------------------------------
svg_08 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 440" width="100%" height="100%">
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B" />
    </marker>
    <marker id="arrow-green" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#16A34A" />
    </marker>
    <marker id="arrow-red" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#DC2626" />
    </marker>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ TRẠNG THÁI (STATE MACHINE) — REGISTRATION ENTITY</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · Đặc tả 5 trạng thái hợp lệ, guard conditions và các bước chuyển bị cấm tuyệt đối bởi Security Rules</text>

  <!-- Initial State -->
  <circle cx="50" cy="130" r="14" fill="#1E293B" />
  <line x1="64" y1="130" x2="105" y2="130" stroke="#64748B" stroke-width="1.8" marker-end="url(#arrow)" />

  <!-- State 1: DRAFT -->
  <rect x="110" y="95" width="130" height="70" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.8" filter="url(#shadow)" />
  <text x="175" y="125" font-family="Calibri, Arial, sans-serif" font-size="14" font-weight="700" fill="#DB2777" text-anchor="middle">DRAFT</text>
  <text x="175" y="145" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B" text-anchor="middle">Điền form A05 (local)</text>

  <!-- Transition DRAFT -> PENDING -->
  <line x1="240" y1="130" x2="315" y2="130" stroke="#64748B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="278" y="118" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#1E293B" text-anchor="middle">submit()</text>
  <text x="278" y="146" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#D97706" text-anchor="middle">[BR-01, BR-02]</text>

  <!-- State 2: PENDING -->
  <rect x="320" y="95" width="150" height="70" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="2" filter="url(#shadow)" />
  <text x="395" y="125" font-family="Calibri, Arial, sans-serif" font-size="14" font-weight="700" fill="#F97316" text-anchor="middle">PENDING</text>
  <text x="395" y="145" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B" text-anchor="middle">Chờ Trưởng CLB duyệt</text>

  <!-- Transition PENDING -> APPROVED -->
  <line x1="470" y1="130" x2="555" y2="130" stroke="#16A34A" stroke-width="2" marker-end="url(#arrow-green)" />
  <text x="512" y="118" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#16A34A" text-anchor="middle">approveRegistration()</text>
  <text x="512" y="146" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#16A34A" text-anchor="middle">[staff &amp;&amp; active &lt; cap]</text>

  <!-- State 3: APPROVED -->
  <rect x="560" y="95" width="155" height="70" rx="8" fill="#F0FDF4" stroke="#16A34A" stroke-width="2" filter="url(#shadow)" />
  <text x="637" y="125" font-family="Calibri, Arial, sans-serif" font-size="14" font-weight="700" fill="#16A34A" text-anchor="middle">APPROVED</text>
  <text x="637" y="145" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B" text-anchor="middle">Vé QR hợp lệ · activeCount+1</text>

  <!-- Transition APPROVED -> ATTENDED -->
  <line x1="715" y1="130" x2="785" y2="130" stroke="#9D174D" stroke-width="2" marker-end="url(#arrow)" />
  <text x="750" y="118" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#9D174D" text-anchor="middle">scanQrToken()</text>
  <text x="750" y="146" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#9D174D" text-anchor="middle">[hash khớp &amp; session open]</text>

  <!-- State 4: ATTENDED (Final state) -->
  <rect x="790" y="95" width="145" height="70" rx="8" fill="#FDF2F8" stroke="#9D174D" stroke-width="2.5" filter="url(#shadow)" />
  <text x="862" y="125" font-family="Calibri, Arial, sans-serif" font-size="14" font-weight="700" fill="#9D174D" text-anchor="middle">ATTENDED</text>
  <text x="862" y="145" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B" text-anchor="middle">Đã điểm danh (checkInAt)</text>

  <!-- State 5: REJECTED -->
  <rect x="320" y="260" width="150" height="65" rx="8" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.8" filter="url(#shadow)" />
  <text x="395" y="288" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#DC2626" text-anchor="middle">REJECTED</text>
  <text x="395" y="307" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B" text-anchor="middle">Lý do &gt;= 3 ký tự (BR-03)</text>

  <!-- Transition PENDING -> REJECTED -->
  <line x1="395" y1="165" x2="395" y2="255" stroke="#DC2626" stroke-width="1.8" marker-end="url(#arrow-red)" />
  <text x="445" y="210" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#DC2626">rejectRegistration()</text>
  <text x="445" y="224" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B">[reason != null]</text>

  <!-- State 6: CANCELLED -->
  <rect x="560" y="260" width="155" height="65" rx="8" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.8" filter="url(#shadow)" />
  <text x="637" y="288" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#64748B" text-anchor="middle">CANCELLED</text>
  <text x="637" y="307" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B" text-anchor="middle">Hủy trước giờ · activeCount-1</text>

  <!-- Transition APPROVED -> CANCELLED -->
  <line x1="637" y1="165" x2="637" y2="255" stroke="#64748B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="688" y="210" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#64748B">cancelBooking()</text>
  <text x="688" y="224" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B">[now &lt; startsAt]</text>

  <!-- Re-register: CANCELLED / REJECTED -> PENDING -->
  <path d="M 320 292 L 270 292 L 270 155 L 315 155" fill="none" stroke="#D97706" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow)" />
  <text x="235" y="235" font-family="Calibri, Arial, sans-serif" font-size="8.5" font-weight="700" fill="#D97706">Nộp lại đơn</text>
  <text x="235" y="248" font-family="Calibri, Arial, sans-serif" font-size="7.5" fill="#64748B">(gen + 1)</text>

  <!-- FORBIDDEN TRANSITIONS (RED DASHED) -->
  <!-- 1. DRAFT -> APPROVED (FORBIDDEN) -->
  <path d="M 175 95 C 175 40, 637 40, 637 90" fill="none" stroke="#DC2626" stroke-width="2.2" stroke-dasharray="5,4" marker-end="url(#arrow-red)" />
  <rect x="340" y="42" width="195" height="24" rx="4" fill="#FEF2F2" stroke="#DC2626" stroke-width="1" />
  <text x="437" y="58" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#DC2626" text-anchor="middle">CẤM: DRAFT → APPROVED (Rules chặn)</text>

  <!-- 2. REJECTED -> APPROVED (FORBIDDEN) -->
  <path d="M 470 292 C 515 292, 515 180, 560 150" fill="none" stroke="#DC2626" stroke-width="1.8" stroke-dasharray="4,3" marker-end="url(#arrow-red)" />
  <text x="515" y="235" font-family="Calibri, Arial, sans-serif" font-size="8" font-weight="700" fill="#DC2626" text-anchor="middle">CẤM: REJECTED → APPROVED</text>

  <!-- Bottom Rule Summary -->
  <rect x="20" y="375" width="920" height="50" rx="6" fill="#F8FAFC" stroke="#E2E8F0" />
  <text x="35" y="396" font-family="Calibri, Arial, sans-serif" font-size="11.5" font-weight="700" fill="#1E293B">NGUYÊN TẮC: Transition = Event [Guard] / Action</text>
  <text x="35" y="413" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">Mọi bước chuyển đều là Atomic Firestore Transaction. Vi phạm Guard lập tức kích hoạt Rollback và báo mã lỗi chuẩn (BR-01..BR-05).</text>
</svg>
"""

# -----------------------------------------------------------------------------
# 3. 09-system-architecture.svg (C4 Container Architecture)
# -----------------------------------------------------------------------------
svg_09 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 480" width="100%" height="100%">
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B" />
    </marker>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="480" rx="8" fill="#FFFFFF" />

  <!-- Title -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ KIẾN TRÚC HỆ THỐNG (C4 CONTAINER SYSTEM ARCHITECTURE)</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · Kiến trúc Serverless 100% (0 máy chủ tùy biến, 0 Cloud Functions), giao tiếp qua Cloud Firestore Security Rules</text>

  <!-- Left: Client Layer -->
  <rect x="25" y="70" width="260" height="380" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="25" y="70" width="260" height="35" rx="8" fill="#DB2777" />
  <text x="155" y="93" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">CLIENT APPLICATIONS (TẦNG CLIENT)</text>

  <!-- Mobile App Box -->
  <rect x="40" y="120" width="230" height="135" rx="6" fill="#FFF" stroke="#F472B6" stroke-width="1.2" filter="url(#shadow)" />
  <text x="55" y="142" font-family="Calibri, Arial, sans-serif" font-size="12.5" font-weight="700" fill="#DB2777">Flutter Mobile (Android)</text>
  <text x="55" y="160" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• Dành cho Sinh viên (role: user)</text>
  <text x="55" y="176" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• 12 Màn hình hoàn chỉnh A01..A12</text>
  <text x="55" y="192" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• Riverpod MVVM Architecture</text>
  <text x="55" y="208" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• MobileScanner quét QR Token</text>
  <text x="55" y="235" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#DB2777">Platform: Android 10+ (API 29+)</text>

  <!-- Web Admin Box -->
  <rect x="40" y="270" width="230" height="120" rx="6" fill="#FFF" stroke="#F472B6" stroke-width="1.2" filter="url(#shadow)" />
  <text x="55" y="292" font-family="Calibri, Arial, sans-serif" font-size="12.5" font-weight="700" fill="#DB2777">Flutter Web Admin</text>
  <text x="55" y="310" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• Dành cho Trưởng CLB (staff) &amp; Admin</text>
  <text x="55" y="326" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• 5 Màn hình: Dashboard, Reviews, QR...</text>
  <text x="55" y="342" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• GoRouter 14.8 responsive web</text>
  <text x="55" y="370" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#DB2777">Host: Firebase Hosting (SSL CDN)</text>

  <!-- Shared Core Library -->
  <rect x="40" y="400" width="230" height="38" rx="5" fill="#FFF" stroke="#F472B6" stroke-width="1" />
  <text x="155" y="424" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#9D174D" text-anchor="middle">packages/core (100% Models &amp; Contracts)</text>

  <!-- Middle: Cloud Backend Layer -->
  <rect x="335" y="70" width="340" height="380" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="2" filter="url(#shadow)" />
  <rect x="335" y="70" width="340" height="35" rx="8" fill="#F97316" />
  <text x="505" y="93" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">BACKEND: CLOUD FIRESTORE &amp; RULES</text>

  <!-- Firestore NoSQL Core -->
  <rect x="355" y="120" width="300" height="150" rx="6" fill="#FFF" stroke="#FB923C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="370" y="142" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#EA580C">Cloud Firestore (asia-southeast1)</text>
  <text x="370" y="162" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• NoSQL Document Store với 7 collections</text>
  <text x="370" y="178" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• Realtime Sync qua HTTPS / gRPC Stream</text>
  <text x="370" y="194" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• Atomic Transactions: Khóa sức chứa activeCount</text>
  <text x="370" y="210" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">• Composite Indexes: (status, eventId, createdAt)</text>
  <text x="370" y="240" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#EA580C">SLA Google Cloud 99.99% · Local Emulator Test</text>

  <!-- Security Rules Engine -->
  <rect x="355" y="290" width="300" height="145" rx="6" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="370" y="312" font-family="Calibri, Arial, sans-serif" font-size="12.5" font-weight="700" fill="#B45309">firestore.rules (Serverless Logic)</text>
  <text x="370" y="330" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#78350F">• Kiểm tra role: request.auth.token.role</text>
  <text x="370" y="346" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#78350F">• getAfter(event).activeCount == old + 1</text>
  <text x="370" y="362" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#78350F">• Ràng buộc schema: MSSV, email, sđt</text>
  <text x="370" y="378" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#78350F">• Chặn ghi đè trực tiếp &amp; phân quyền 3 roles</text>
  <text x="370" y="410" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#B45309">16 ca test Emulator Pass 100%</text>

  <!-- Right: Supporting Cloud Services -->
  <rect x="715" y="70" width="220" height="380" rx="8" fill="#FFFBEB" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="715" y="70" width="220" height="35" rx="8" fill="#D97706" />
  <text x="825" y="93" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">CLOUD SERVICES (DỊCH VỤ ĐÁM MÂY)</text>

  <!-- Auth -->
  <rect x="730" y="115" width="190" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="742" y="133" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B">Firebase Authentication</text>
  <text x="742" y="148" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Email/Pass + Google Sign-In</text>

  <!-- FCM -->
  <rect x="730" y="172" width="190" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="742" y="190" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B">Cloud Messaging (FCM)</text>
  <text x="742" y="205" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Push notifications 3 trạng thái</text>

  <!-- Crashlytics -->
  <rect x="730" y="229" width="190" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="742" y="247" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B">Firebase Crashlytics</text>
  <text x="742" y="262" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Báo cáo crash &amp; custom keys</text>

  <!-- Remote Config -->
  <rect x="730" y="286" width="190" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="742" y="304" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B">Remote Config</text>
  <text x="742" y="319" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Feature flags &amp; giới hạn hiển thị</text>

  <!-- Cloudinary -->
  <rect x="730" y="343" width="190" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="742" y="361" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B">Cloudinary Free Tier</text>
  <text x="742" y="376" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Lưu trữ PDF vé minh họa</text>

  <!-- Connectors -->
  <!-- Client <-> Firestore -->
  <line x1="285" y1="187" x2="333" y2="187" stroke="#EA580C" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="335" y1="195" x2="287" y2="195" stroke="#EA580C" stroke-width="2" marker-end="url(#arrow)" />
  <text x="310" y="177" font-family="Calibri, Arial, sans-serif" font-size="8.5" font-weight="700" fill="#EA580C" text-anchor="middle">gRPC / TLS</text>

  <!-- Client <-> Cloud Services -->
  <path d="M 270 140 C 270 40, 715 40, 728 120" fill="none" stroke="#D97706" stroke-width="1.2" stroke-dasharray="3,3" marker-end="url(#arrow)" />
</svg>
"""

# -----------------------------------------------------------------------------
# 4. 12-sequence-diagram.svg (Sơ đồ tuần tự WF-02 Phê duyệt)
# -----------------------------------------------------------------------------
svg_12 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 440" width="100%" height="100%">
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#1E293B" />
    </marker>
    <marker id="arrow-dash" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B" />
    </marker>
    <marker id="arrow-green" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#16A34A" />
    </marker>
    <marker id="arrow-red" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#DC2626" />
    </marker>
  </defs>

  <rect width="960" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ TUẦN TỰ (SEQUENCE DIAGRAM) — PHÊ DUYỆT ĐƠN ĐĂNG KÝ (WF-02)</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · Trưởng CLB (Web) thao tác duyệt → Firestore Atomic Transaction → Mobile cập nhật realtime</text>

  <!-- Lifeline Headers -->
  <rect x="40" y="65" width="140" height="38" rx="6" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
  <text x="110" y="88" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#F97316" text-anchor="middle">Trưởng CLB (Actor)</text>

  <rect x="230" y="65" width="150" height="38" rx="6" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
  <text x="305" y="88" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#F97316" text-anchor="middle">:ReviewQueueScreen</text>

  <rect x="430" y="65" width="150" height="38" rx="6" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
  <text x="505" y="88" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#F97316" text-anchor="middle">:ReviewQueueViewModel</text>

  <rect x="630" y="65" width="150" height="38" rx="6" fill="#FFF7ED" stroke="#F97316" stroke-width="1.5" />
  <text x="705" y="88" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#F97316" text-anchor="middle">Firestore &amp; Rules</text>

  <rect x="810" y="65" width="130" height="38" rx="6" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" />
  <text x="875" y="88" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#DB2777" text-anchor="middle">Sinh viên (Mobile)</text>

  <!-- Lifeline Dashes -->
  <line x1="110" y1="105" x2="110" y2="410" stroke="#CBD5E1" stroke-width="1.5" stroke-dasharray="4,4" />
  <line x1="305" y1="105" x2="305" y2="410" stroke="#CBD5E1" stroke-width="1.5" stroke-dasharray="4,4" />
  <line x1="505" y1="105" x2="505" y2="410" stroke="#CBD5E1" stroke-width="1.5" stroke-dasharray="4,4" />
  <line x1="705" y1="105" x2="705" y2="410" stroke="#CBD5E1" stroke-width="1.5" stroke-dasharray="4,4" />
  <line x1="875" y1="105" x2="875" y2="410" stroke="#CBD5E1" stroke-width="1.5" stroke-dasharray="4,4" />

  <!-- Step 1: Click Approve -->
  <line x1="110" y1="130" x2="300" y2="130" stroke="#1E293B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="207" y="123" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B" text-anchor="middle">1. Bấm 'Phê duyệt' (#REG-102)</text>

  <!-- Step 2: Call ViewModel -->
  <line x1="305" y1="160" x2="500" y2="160" stroke="#1E293B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="405" y="153" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B" text-anchor="middle">2. approveRegistration(id, eventId)</text>

  <!-- Step 3: Atomic Transaction -->
  <line x1="505" y1="190" x2="700" y2="190" stroke="#1E293B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="605" y="183" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#1E293B" text-anchor="middle">3. runTransaction(update reg + event)</text>

  <!-- Rules Execution Box -->
  <rect x="695" y="200" width="20" height="90" fill="#FEF3C7" stroke="#D97706" />

  <!-- alt Frame (Exception: Over capacity) -->
  <rect x="250" y="215" width="480" height="60" fill="rgba(220,38,38,0.06)" stroke="#DC2626" stroke-width="1.2" stroke-dasharray="4,3" />
  <text x="260" y="232" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#DC2626">[alt: getAfter(event).activeCount &gt; capacity] (BR-01)</text>
  
  <line x1="695" y1="255" x2="510" y2="255" stroke="#DC2626" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow-red)" />
  <text x="605" y="248" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#DC2626" text-anchor="middle">Rollback &amp; ném Permission Denied</text>

  <!-- Happy path: 200 OK -->
  <line x1="705" y1="310" x2="510" y2="310" stroke="#16A34A" stroke-width="2" stroke-dasharray="4,2" marker-end="url(#arrow-green)" />
  <text x="605" y="303" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#16A34A" text-anchor="middle">Transaction commit: status=approved, activeCount+1</text>

  <!-- Step 4: Update Web UI -->
  <line x1="505" y1="340" x2="310" y2="340" stroke="#16A34A" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#arrow-green)" />
  <text x="405" y="333" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#16A34A" text-anchor="middle">Cập nhật đơn rời Queue, tăng Đã duyệt</text>

  <!-- Step 5: Realtime push to Mobile -->
  <line x1="705" y1="375" x2="870" y2="375" stroke="#DB2777" stroke-width="2" stroke-dasharray="4,2" marker-end="url(#arrow)" />
  <text x="790" y="367" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777" text-anchor="middle">Realtime snapshot &amp; FCM Push</text>

  <rect x="830" y="388" width="90" height="22" rx="4" fill="#DB2777" />
  <text x="875" y="403" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#FFF" text-anchor="middle">Màn A08 ĐÃ DUYỆT</text>
</svg>
"""

# -----------------------------------------------------------------------------
# 5. 13-class-design.svg (Kiến trúc phân tầng MVVM & Service Contracts)
# -----------------------------------------------------------------------------
svg_13 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 440" width="100%" height="100%">
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B" />
    </marker>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ THIẾT KẾ LỚP (CLASS DESIGN &amp; LAYERED ARCHITECTURE)</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · Clean MVVM: Tách biệt rõ View (UI), ViewModel (Riverpod), Service Contracts và Domain Models</text>

  <!-- 3 Main Columns: View -> ViewModel -> Service Contract -->
  <!-- Box 1: View Layer -->
  <rect x="25" y="70" width="180" height="260" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="25" y="70" width="180" height="32" rx="8" fill="#DB2777" />
  <text x="115" y="91" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">VIEW (UI SCREENS)</text>
  
  <rect x="35" y="115" width="160" height="55" rx="5" fill="#FFF" stroke="#F472B6" />
  <text x="45" y="133" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777">RegistrationFormScreen</text>
  <text x="45" y="150" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Màn A05: Nhập thông tin</text>

  <rect x="35" y="180" width="160" height="55" rx="5" fill="#FFF" stroke="#F472B6" />
  <text x="45" y="198" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777">ScannerScreen</text>
  <text x="45" y="215" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Màn A11: Camera QR</text>

  <rect x="35" y="245" width="160" height="55" rx="5" fill="#FFF" stroke="#F472B6" />
  <text x="45" y="263" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#DB2777">ReviewQueueView</text>
  <text x="45" y="280" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Web Admin: Phê duyệt</text>

  <!-- Box 2: ViewModel Layer -->
  <rect x="245" y="70" width="220" height="260" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="1.8" filter="url(#shadow)" />
  <rect x="245" y="70" width="220" height="32" rx="8" fill="#F97316" />
  <text x="355" y="91" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">VIEWMODELS (RIVERPOD)</text>

  <rect x="255" y="115" width="200" height="90" rx="5" fill="#FFF" stroke="#FB923C" />
  <text x="265" y="133" font-family="Calibri, Arial, sans-serif" font-size="11.5" font-weight="700" fill="#EA580C">BookingViewModel</text>
  <text x="265" y="152" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#1E293B">+ submitRegistration(form)</text>
  <text x="265" y="168" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#1E293B">+ cancelRegistration(id)</text>
  <text x="265" y="184" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#1E293B">+ state: AsyncValue&lt;BookingState&gt;</text>

  <rect x="255" y="215" width="200" height="85" rx="5" fill="#FFF" stroke="#FB923C" />
  <text x="265" y="233" font-family="Calibri, Arial, sans-serif" font-size="11.5" font-weight="700" fill="#EA580C">ScannerViewModel</text>
  <text x="265" y="252" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#1E293B">+ onQrCodeDetected(rawToken)</text>
  <text x="265" y="268" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#1E293B">+ verifyAndCheckIn()</text>
  <text x="265" y="284" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#1E293B">+ lockDuplicateScans()</text>

  <!-- Box 3: Service Contracts (Interfaces) -->
  <rect x="505" y="70" width="200" height="260" rx="8" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="505" y="70" width="200" height="32" rx="8" fill="#D97706" />
  <text x="605" y="91" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">SERVICE CONTRACTS</text>

  <rect x="515" y="115" width="180" height="90" rx="5" fill="#FFF" stroke="#FCD34D" />
  <text x="525" y="132" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#B45309">&laquo;interface&raquo; EventService</text>
  <text x="525" y="150" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ registerEvent(form, opId)</text>
  <text x="525" y="165" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ approveRegistration(id)</text>
  <text x="525" y="180" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ checkInWithQr(qrHash)</text>
  <text x="525" y="195" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B">Dễ dàng Fake / Mock khi Test</text>

  <rect x="515" y="215" width="180" height="85" rx="5" fill="#FFF" stroke="#FCD34D" />
  <text x="525" y="232" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#B45309">&laquo;interface&raquo; QrCameraService</text>
  <text x="525" y="250" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ startScanning()</text>
  <text x="525" y="265" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ stopScanning()</text>
  <text x="525" y="280" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ torchToggle()</text>

  <!-- Box 4: Implementation Layer -->
  <rect x="745" y="70" width="190" height="260" rx="8" fill="#F8FAFC" stroke="#64748B" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="745" y="70" width="190" height="32" rx="8" fill="#64748B" />
  <text x="840" y="91" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">IMPLEMENTATIONS</text>

  <rect x="755" y="115" width="170" height="90" rx="5" fill="#FFF" stroke="#CBD5E1" />
  <text x="765" y="132" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#334155">FirestoreEventService</text>
  <text x="765" y="150" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">implements EventService</text>
  <text x="765" y="168" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">Gọi Cloud Firestore SDK</text>
  <text x="765" y="184" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">Thực thi Transactions</text>

  <rect x="755" y="215" width="170" height="85" rx="5" fill="#FFF" stroke="#CBD5E1" />
  <text x="765" y="232" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#334155">SecureBookingStore</text>
  <text x="765" y="250" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">FlutterSecureStorage</text>
  <text x="765" y="266" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">Lưu pending operationId</text>
  <text x="765" y="282" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">Phục hồi khi mất mạng (D08)</text>

  <!-- Connectors -->
  <line x1="205" y1="145" x2="243" y2="145" stroke="#DB2777" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="465" y1="145" x2="503" y2="145" stroke="#EA580C" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="705" y1="145" x2="743" y2="145" stroke="#D97706" stroke-width="1.5" stroke-dasharray="3,3" marker-end="url(#arrow)" />

  <!-- Domain Entity Box (Bottom Bar) -->
  <rect x="25" y="345" width="910" height="75" rx="6" fill="#FDF2F8" stroke="#DB2777" stroke-width="1" />
  <text x="45" y="368" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#9D174D">DOMAIN MODELS (PACKAGE: packages/core/lib/models/)</text>
  <text x="45" y="390" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B"><strong>Registration:</strong> id, uid, eventId, clubId, status, generation, participant, reason, checkInAt, createdAt, lastOperationId</text>
  <text x="45" y="408" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Hoàn toàn độc lập với Flutter UI và SDK Cloud, chia sẻ 100% giữa Mobile App và Web Admin.</text>
</svg>
"""

# -----------------------------------------------------------------------------
# 6. 14-conceptual-erd.svg (Sơ đồ ERD khái niệm)
# -----------------------------------------------------------------------------
svg_14 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 440" width="100%" height="100%">
  <defs>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ THỰC THỂ KHÁI NIỆM (CONCEPTUAL ERD — NGỮ NGHĨA NGHIỆP VỤ)</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · 5 Thực thể cốt lõi, quan hệ bản số (cardinality) và quy tắc toàn vẹn nghiệp vụ chi phối</text>

  <!-- Entity 1: CLUB -->
  <rect x="35" y="90" width="165" height="115" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="2" filter="url(#shadow)" />
  <rect x="35" y="90" width="165" height="30" rx="8" fill="#F97316" />
  <text x="117" y="111" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">CLUB (CÂU LẠC BỘ)</text>
  <text x="45" y="138" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Mã câu lạc bộ (PK)</text>
  <text x="45" y="156" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Tên CLB &amp; Logo</text>
  <text x="45" y="174" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Trưởng CLB (staffUid)</text>
  <text x="45" y="192" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Trạng thái hoạt động</text>

  <!-- Line CLUB to EVENT -->
  <line x1="200" y1="147" x2="275" y2="147" stroke="#64748B" stroke-width="2" />
  <text x="210" y="140" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#64748B">1</text>
  <text x="240" y="138" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">tổ chức</text>
  <text x="260" y="140" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#64748B">0..*</text>

  <!-- Entity 2: EVENT -->
  <rect x="275" y="75" width="180" height="145" rx="8" fill="#FFFBEB" stroke="#D97706" stroke-width="2" filter="url(#shadow)" />
  <rect x="275" y="75" width="180" height="30" rx="8" fill="#D97706" />
  <text x="365" y="96" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">EVENT (SỰ KIỆN)</text>
  <text x="285" y="123" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Mã sự kiện (PK)</text>
  <text x="285" y="140" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Tiêu đề &amp; Mô tả</text>
  <text x="285" y="157" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Sức chứa (capacity)</text>
  <text x="285" y="174" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Số đã duyệt (activeCount)</text>
  <text x="285" y="191" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Thời hạn &amp; Bắt đầu</text>
  <text x="285" y="208" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Trạng thái (status)</text>

  <!-- Line EVENT to REGISTRATION -->
  <line x1="455" y1="147" x2="535" y2="147" stroke="#64748B" stroke-width="2" />
  <text x="465" y="140" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#64748B">1</text>
  <text x="485" y="138" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">được ĐK</text>
  <text x="520" y="140" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#64748B">0..*</text>

  <!-- Entity 3: REGISTRATION (Associative Entity) -->
  <rect x="535" y="75" width="195" height="145" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="2.2" filter="url(#shadow)" />
  <rect x="535" y="75" width="195" height="30" rx="8" fill="#DB2777" />
  <text x="632" y="96" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">REGISTRATION (ĐƠN ĐK)</text>
  <text x="545" y="123" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• ID: {uid}_{eventId} (PK)</text>
  <text x="545" y="140" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Thông tin SV (participant)</text>
  <text x="545" y="157" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Trạng thái (status: pending...)</text>
  <text x="545" y="174" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Lần gửi (generation)</text>
  <text x="545" y="191" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• checkInAt (thời điểm checkin)</text>
  <text x="545" y="208" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Lý do từ chối (reason)</text>

  <!-- Line USER to REGISTRATION -->
  <line x1="730" y1="147" x2="805" y2="147" stroke="#64748B" stroke-width="2" />
  <text x="740" y="140" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#64748B">0..*</text>
  <text x="760" y="138" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">gửi bởi</text>
  <text x="790" y="140" font-family="Calibri, Arial, sans-serif" font-size="11" font-weight="700" fill="#64748B">1</text>

  <!-- Entity 4: USER -->
  <rect x="805" y="90" width="130" height="115" rx="8" fill="#F8FAFC" stroke="#64748B" stroke-width="2" filter="url(#shadow)" />
  <rect x="805" y="90" width="130" height="30" rx="8" fill="#64748B" />
  <text x="870" y="111" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">USER</text>
  <text x="815" y="138" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• UID (PK)</text>
  <text x="815" y="156" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Họ tên, MSSV</text>
  <text x="815" y="174" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• Vai trò (role)</text>
  <text x="815" y="192" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B">• clubId (nếu staff)</text>

  <!-- Entity 5: CHECKIN_SESSION -->
  <rect x="275" y="270" width="180" height="100" rx="8" fill="#FFFBEB" stroke="#D97706" stroke-width="1.8" filter="url(#shadow)" />
  <rect x="275" y="270" width="180" height="28" rx="8" fill="#D97706" />
  <text x="365" y="289" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">CHECKIN_SESSION</text>
  <text x="285" y="315" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#1E293B">• eventId (PK)</text>
  <text x="285" y="333" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#1E293B">• Trạng thái mở (open)</text>
  <text x="285" y="351" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#1E293B">• openedAt (thời điểm mở)</text>

  <!-- Line EVENT to CHECKIN_SESSION -->
  <line x1="365" y1="220" x2="365" y2="270" stroke="#64748B" stroke-width="2" />
  <text x="372" y="235" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#64748B">1</text>
  <text x="372" y="260" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#64748B">0..1</text>

  <!-- Entity 6: QR_CREDENTIAL -->
  <rect x="535" y="270" width="195" height="100" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="1.8" filter="url(#shadow)" />
  <rect x="535" y="270" width="195" height="28" rx="8" fill="#F97316" />
  <text x="632" y="289" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">QR_CREDENTIAL</text>
  <text x="545" y="315" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#1E293B">• qrHash = sha256(token)</text>
  <text x="545" y="333" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#1E293B">• eventId &amp; clubId</text>
  <text x="545" y="351" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#1E293B">• enabled: true/false</text>

  <!-- Line CHECKIN_SESSION to QR_CREDENTIAL -->
  <line x1="455" y1="320" x2="535" y2="320" stroke="#64748B" stroke-width="1.5" stroke-dasharray="3,3" />
  <text x="475" y="312" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">liên kết</text>

  <!-- Bottom Rules Note -->
  <rect x="25" y="390" width="910" height="38" rx="6" fill="#F8FAFC" stroke="#E2E8F0" />
  <text x="35" y="413" font-family="Calibri, Arial, sans-serif" font-size="11" fill="#1E293B"><strong>Ràng buộc toàn vẹn ngữ nghĩa:</strong> Mỗi Sinh viên chỉ có tối đa 1 Registration hoạt động cho 1 Event (khóa {uid}_{eventId}). Một Event chỉ có tối đa 1 phiên QR đang mở.</text>
</svg>
"""

# Write all SVGs
files_to_write = [
    ("07-business-flow.svg", svg_07),
    ("08-state-machine.svg", svg_08),
    ("09-system-architecture.svg", svg_09),
    ("12-sequence-diagram.svg", svg_12),
    ("13-class-design.svg", svg_13),
    ("14-conceptual-erd.svg", svg_14),
]

for filename, content in files_to_write:
    path = os.path.join(DIAGRAMS_DIR, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content.strip())
    print(f"Generated: {path} ({len(content)} bytes)")

print("All standalone diagram SVGs generated successfully in evidence/diagrams/!")

