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
# 1. 07-business-flow.svg (Swimlane 3 làn: Sinh viên, Hệ thống, Trưởng CLB)
# -----------------------------------------------------------------------------
svg_07 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 440" width="100%" height="100%">
  <defs>
    <style>
      .lbl { font-family: Calibri, Arial, sans-serif; font-size: 8.5px; font-weight: 700; paint-order: stroke fill; stroke: #FFFFFF; stroke-width: 3.5px; stroke-linejoin: round; }
      .lbl-green { fill: #16A34A; }
      .lbl-red { fill: #DC2626; font-size: 8px; }
      .lbl-orange { fill: #EA580C; }
      .lbl-pink { fill: #DB2777; }
      .lbl-gray { fill: #475569; font-size: 8px; }
    </style>
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

  <rect width="960" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title & Legend -->
  <text x="24" y="30" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ NGHIỆP VỤ LIÊN VAI TRÒ (CROSS-ROLE ACTIVITY &amp; BUSINESS FLOW)</text>
  <text x="24" y="46" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 ASM · 3 Làn phối hợp: Sinh viên (Mobile App), Hệ thống (Firestore Rules), Trưởng CLB (Web Admin)</text>

  <!-- Swimlane 1: Sinh viên -->
  <rect x="20" y="58" width="920" height="112" rx="6" fill="#FDF2F8" stroke="#FBCFE8" stroke-width="1" />
  <rect x="20" y="58" width="125" height="112" rx="6" fill="#DB2777" opacity="0.12" />
  <text x="32" y="112" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#9D174D">SINH VIÊN</text>
  <text x="32" y="129" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Mobile App (Flutter)</text>

  <!-- SV Nodes -->
  <circle cx="155" cy="114" r="10" fill="#DB2777" />
  <text x="155" y="118" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#FFF" text-anchor="middle">Start</text>

  <!-- 1. Điền form -->
  <rect x="180" y="92" width="92" height="44" rx="6" fill="#FFF" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <text x="226" y="111" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#DB2777" text-anchor="middle">Điền form ĐK</text>
  <text x="226" y="126" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Màn hình A05</text>

  <!-- Fail BR-01: Hết chỗ -->
  <rect x="282" y="92" width="94" height="44" rx="6" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5" stroke-dasharray="3,2" filter="url(#shadow)" />
  <text x="329" y="111" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#DC2626" text-anchor="middle">Hết chỗ / Hạn</text>
  <text x="329" y="126" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#991B1B" text-anchor="middle">Báo lỗi A04/A05</text>

  <!-- Fail BR-03: Từ chối -->
  <rect x="532" y="92" width="104" height="44" rx="6" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5" stroke-dasharray="3,2" filter="url(#shadow)" />
  <text x="584" y="111" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#DC2626" text-anchor="middle">Thông báo Từ chối</text>
  <text x="584" y="126" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#991B1B" text-anchor="middle">Inbox A09 kèm lý do</text>

  <!-- Succeed BR-03: Duyệt -->
  <rect x="648" y="92" width="100" height="44" rx="6" fill="#FFF" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <text x="698" y="111" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#DB2777" text-anchor="middle">Thông báo Duyệt</text>
  <text x="698" y="126" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Inbox A09 · Chi tiết A08</text>

  <!-- Quét QR -->
  <rect x="795" y="92" width="96" height="44" rx="6" fill="#FFF" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <text x="843" y="111" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#DB2777" text-anchor="middle">Quét QR Hội trường</text>
  <text x="843" y="126" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B" text-anchor="middle">Scanner A11 → A12</text>

  <!-- Swimlane 2: Hệ thống (Firestore & Rules) -->
  <rect x="20" y="176" width="920" height="120" rx="6" fill="#FFFBEB" stroke="#FDE68A" stroke-width="1" />
  <rect x="20" y="176" width="125" height="120" rx="6" fill="#D97706" opacity="0.12" />
  <text x="32" y="232" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#B45309">HỆ THỐNG</text>
  <text x="32" y="249" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Firestore Rules Serverless</text>

  <!-- Decision BR-02 (Form hợp lệ?) -->
  <polygon points="226,216 250,236 226,256 202,236" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="226" y="239" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#B45309" text-anchor="middle">BR-02?</text>

  <!-- Decision BR-01 (Còn chỗ?) -->
  <polygon points="329,216 353,236 329,256 305,236" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="329" y="239" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#B45309" text-anchor="middle">BR-01?</text>

  <!-- Tạo PENDING -->
  <rect x="408" y="214" width="112" height="44" rx="6" fill="#FFF" stroke="#EA580C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="464" y="232" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#EA580C" text-anchor="middle">Tạo đơn PENDING</text>
  <text x="464" y="247" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B" text-anchor="middle">activeCount chưa tăng</text>

  <!-- Xác thực SHA-256 -->
  <rect x="795" y="214" width="96" height="44" rx="6" fill="#FFF" stroke="#059669" stroke-width="1.5" filter="url(#shadow)" />
  <text x="843" y="232" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#059669" text-anchor="middle">Xác thực SHA-256</text>
  <text x="843" y="247" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B" text-anchor="middle">Ghi checkInAt (BR-04,05)</text>

  <!-- Swimlane 3: Trưởng CLB -->
  <rect x="20" y="302" width="920" height="120" rx="6" fill="#FFF7ED" stroke="#FED7AA" stroke-width="1" />
  <rect x="20" y="302" width="125" height="120" rx="6" fill="#EA580C" opacity="0.12" />
  <text x="32" y="358" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#C2410C">TRƯỞNG CLB</text>
  <text x="32" y="375" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Web Admin (Role: staff)</text>

  <!-- Review Queue -->
  <rect x="408" y="339" width="112" height="46" rx="6" fill="#FFF" stroke="#EA580C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="464" y="358" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#EA580C" text-anchor="middle">Review Queue Realtime</text>
  <text x="464" y="373" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B" text-anchor="middle">Đơn mới đẩy qua snapshot</text>

  <!-- Decision BR-03 (Duyệt?) -->
  <polygon points="584,338 608,362 584,386 560,362" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="584" y="365" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#B45309" text-anchor="middle">Duyệt?</text>

  <!-- Mở phiên QR -->
  <rect x="795" y="339" width="96" height="46" rx="6" fill="#FFF" stroke="#EA580C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="843" y="358" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#EA580C" text-anchor="middle">Mở Phiên QR</text>
  <text x="843" y="373" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B" text-anchor="middle">Ghi qrCredentials/{hash}</text>

  <!-- CONNECTORS -->
  <!-- 1. Start -> Điền form -->
  <line x1="165" y1="114" x2="178" y2="114" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />

  <!-- 2. Điền form -> BR-02 -->
  <line x1="226" y1="136" x2="226" y2="214" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />

  <!-- 3. BR-02 Succeed ("Hợp lệ") -> BR-01 (Khoảng cách 55px) -->
  <line x1="250" y1="236" x2="303" y2="236" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="277" y="228" class="lbl lbl-green" text-anchor="middle">Hợp lệ</text>

  <!-- 4. BR-02 Fail ("Sai form") -> Vòng về A05 -->
  <path d="M 226 256 L 226 276 L 168 276 L 168 126 L 178 126" fill="none" stroke="#DC2626" stroke-width="1.2" stroke-dasharray="3,2" marker-end="url(#arrow-red)" />
  <text x="197" y="271" class="lbl lbl-red" text-anchor="middle">Báo lỗi form A05</text>

  <!-- 5. BR-01 Succeed ("Còn chỗ") -> Tạo PENDING (Khoảng cách 55px) -->
  <line x1="353" y1="236" x2="406" y2="236" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="380" y="228" class="lbl lbl-green" text-anchor="middle">Còn chỗ</text>

  <!-- 6. BR-01 Fail ("Hết chỗ") -> Lên thẳng node Hết chỗ ở SV -->
  <line x1="329" y1="216" x2="329" y2="138" stroke="#DC2626" stroke-width="1.3" stroke-dasharray="3,2" marker-end="url(#arrow-red)" />
  <text x="338" y="177" class="lbl lbl-red">Hết chỗ</text>

  <!-- 7. PENDING -> Review Queue CLB -->
  <line x1="464" y1="258" x2="464" y2="337" stroke="#EA580C" stroke-width="1.5" marker-end="url(#arrow-orange)" />
  <text x="473" y="295" class="lbl lbl-orange">Realtime sync</text>

  <!-- 8. Review Queue -> Decision BR-03 (Khoảng cách 40px) -->
  <line x1="520" y1="362" x2="558" y2="362" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />

  <!-- 9. BR-03 Fail ("Từ chối") -> Đi thẳng lên từ ĐỈNH của diamond BR-03 (x=584), cách ô PENDING 64px không đè -->
  <line x1="584" y1="338" x2="584" y2="138" stroke="#DC2626" stroke-width="1.3" stroke-dasharray="3,2" marker-end="url(#arrow-red)" />
  <text x="593" y="236" class="lbl lbl-red">Từ chối (kèm lý do)</text>

  <!-- 10. BR-03 Succeed ("Duyệt") -> Đi ra từ GÓC BÊN PHẢI (608, 362), rẽ vuông góc đi lên Thông báo Duyệt (698, 138) -->
  <path d="M 608 362 L 698 362 L 698 138" fill="none" stroke="#DB2777" stroke-width="1.5" marker-end="url(#arrow-pink)" />
  <text x="706" y="236" class="lbl lbl-green">Duyệt (activeCount+1)</text>

  <!-- 11. Thông báo Duyệt -> Quét QR Hội trường (Khoảng cách 47px thoáng đãng) -->
  <line x1="748" y1="114" x2="793" y2="114" stroke="#64748B" stroke-width="1.5" marker-end="url(#arrow)" />
  <text x="771" y="106" class="lbl lbl-gray" text-anchor="middle">Đến sự kiện</text>

  <!-- 12. Mở Phiên QR -> Xác thực SHA-256 -->
  <line x1="843" y1="339" x2="843" y2="260" stroke="#EA580C" stroke-width="1.5" marker-end="url(#arrow-orange)" />
  <text x="851" y="300" class="lbl lbl-orange">Mở session</text>

  <!-- 13. SV Quét QR -> Xác thực SHA-256 -->
  <line x1="843" y1="136" x2="843" y2="212" stroke="#DB2777" stroke-width="1.5" marker-end="url(#arrow-pink)" />
  <text x="851" y="175" class="lbl lbl-pink">Gửi mã quét</text>

  <!-- 14. Xác thực SHA-256 -> HOÀN TẤT (Cách biên phải 22px, cách biên dưới 38px) -->
  <line x1="891" y1="236" x2="906" y2="236" stroke="#059669" stroke-width="1.5" marker-end="url(#arrow)" />
  <circle cx="918" cy="236" r="11" fill="#059669" />
  <circle cx="918" cy="236" r="8" fill="#FFF" />
  <circle cx="918" cy="236" r="5" fill="#059669" />
  <text x="918" y="258" font-family="Calibri, Arial, sans-serif" font-size="8.5" font-weight="700" fill="#059669" text-anchor="middle">HOÀN TẤT</text>
</svg>
"""

# -----------------------------------------------------------------------------
# 2. 08-state-machine.svg (Vòng đời Registration Entity)
# -----------------------------------------------------------------------------
svg_08 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1020 440" width="100%" height="100%">
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
    <marker id="arrow-amber" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#D97706" />
    </marker>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="1020" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title Block -->
  <text x="28" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ TRẠNG THÁI (STATE MACHINE) — REGISTRATION ENTITY</text>
  <text x="28" y="50" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · Đặc tả 5 trạng thái hợp lệ, guard conditions và các bước chuyển nguyên tử (Atomic Invariants)</text>

  <!-- Initial State Circle -->
  <circle cx="35" cy="115" r="12" fill="#1E293B" />
  <line x1="47" y1="115" x2="65" y2="115" stroke="#64748B" stroke-width="1.8" marker-end="url(#arrow)" />

  <!-- State 1: DRAFT -->
  <rect x="70" y="83" width="115" height="64" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.8" filter="url(#shadow)" />
  <text x="127" y="112" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#DB2777" text-anchor="middle">DRAFT</text>
  <text x="127" y="132" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Điền form A05</text>

  <!-- Transition DRAFT -> PENDING -->
  <line x1="185" y1="115" x2="307" y2="115" stroke="#64748B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="246" y="104" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#1E293B" text-anchor="middle">submit()</text>
  <text x="246" y="132" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#D97706" text-anchor="middle">[BR-01, BR-02]</text>

  <!-- State 2: PENDING -->
  <rect x="315" y="83" width="125" height="64" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="2" filter="url(#shadow)" />
  <text x="377" y="112" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#F97316" text-anchor="middle">PENDING</text>
  <text x="377" y="132" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Chờ CLB duyệt</text>

  <!-- Transition PENDING -> APPROVED -->
  <line x1="440" y1="115" x2="587" y2="115" stroke="#16A34A" stroke-width="2" marker-end="url(#arrow-green)" />
  <text x="513" y="104" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#16A34A" text-anchor="middle">approveRegistration()</text>
  <text x="513" y="132" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#16A34A" text-anchor="middle">[staff &amp;&amp; active &lt; cap]</text>

  <!-- State 3: APPROVED -->
  <rect x="595" y="83" width="125" height="64" rx="8" fill="#F0FDF4" stroke="#16A34A" stroke-width="2" filter="url(#shadow)" />
  <text x="657" y="112" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#16A34A" text-anchor="middle">APPROVED</text>
  <text x="657" y="132" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Vé QR hợp lệ · +1 chỗ</text>

  <!-- Transition APPROVED -> ATTENDED -->
  <line x1="720" y1="115" x2="867" y2="115" stroke="#9D174D" stroke-width="2" marker-end="url(#arrow)" />
  <text x="793" y="104" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#9D174D" text-anchor="middle">scanQrToken()</text>
  <text x="793" y="132" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#9D174D" text-anchor="middle">[hash khớp &amp; session open]</text>

  <!-- State 4: ATTENDED (Final state) -->
  <rect x="875" y="83" width="118" height="64" rx="8" fill="#FDF2F8" stroke="#9D174D" stroke-width="2.2" filter="url(#shadow)" />
  <text x="934" y="112" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#9D174D" text-anchor="middle">ATTENDED</text>
  <text x="934" y="132" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">checkInAt != null</text>

  <!-- Transition PENDING -> REJECTED -->
  <line x1="377" y1="147" x2="377" y2="237" stroke="#DC2626" stroke-width="1.8" marker-end="url(#arrow-red)" />
  <text x="392" y="188" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#DC2626">rejectRegistration()</text>
  <text x="392" y="204" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">[reason &gt;= 3 ký tự]</text>

  <!-- State 5: REJECTED -->
  <rect x="315" y="245" width="125" height="60" rx="8" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.8" filter="url(#shadow)" />
  <text x="377" y="272" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#DC2626" text-anchor="middle">REJECTED</text>
  <text x="377" y="291" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Lý do &gt;= 3 ký tự (BR-03)</text>

  <!-- Transition APPROVED -> CANCELLED -->
  <line x1="657" y1="147" x2="657" y2="237" stroke="#64748B" stroke-width="1.8" marker-end="url(#arrow)" />
  <text x="672" y="188" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#64748B">cancelBooking()</text>
  <text x="672" y="204" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">[now &lt; startsAt]</text>

  <!-- State 6: CANCELLED -->
  <rect x="595" y="245" width="125" height="60" rx="8" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.8" filter="url(#shadow)" />
  <text x="657" y="272" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#64748B" text-anchor="middle">CANCELLED</text>
  <text x="657" y="291" font-family="Calibri, Arial, sans-serif" font-size="9.5" fill="#64748B" text-anchor="middle">Hủy trước giờ · -1 chỗ</text>

  <!-- Re-register: REJECTED -> PENDING -->
  <path d="M 315 275 L 240 275 L 240 137 L 307 137" fill="none" stroke="#D97706" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow-amber)" />
  <text x="230" y="198" font-family="Calibri, Arial, sans-serif" font-size="9.5" font-weight="700" fill="#D97706" text-anchor="end">Nộp lại đơn</text>
  <text x="230" y="212" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B" text-anchor="end">(generation + 1)</text>

  <!-- Bottom Rule Summary -->
  <rect x="20" y="365" width="980" height="52" rx="6" fill="#F8FAFC" stroke="#E2E8F0" />
  <text x="35" y="388" font-family="Calibri, Arial, sans-serif" font-size="11.5" font-weight="700" fill="#1E293B">NGUYÊN TẮC: Transition = Event [Guard] / Action</text>
  <text x="35" y="405" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#64748B">Mọi bước chuyển đều là Atomic Firestore Transaction. Vi phạm Guard lập tức kích hoạt Rollback và báo mã lỗi chuẩn (BR-01..BR-05).</text>
</svg>"""

# -----------------------------------------------------------------------------
# 3. 09-system-architecture.svg (C4 Container Architecture)
# -----------------------------------------------------------------------------
svg_09 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 485" width="100%" height="100%">
  <defs>
    <style>
      .lbl-pill { font-family: Calibri, Arial, sans-serif; font-size: 8.5px; font-weight: 700; fill: #EA580C; text-anchor: middle; }
      .lbl-amber { font-family: Calibri, Arial, sans-serif; font-size: 8.5px; font-weight: 700; fill: #D97706; text-anchor: middle; }
    </style>
    <marker id="arrow-orange" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#EA580C" />
    </marker>
    <marker id="arrow-amber" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#D97706" />
    </marker>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="485" rx="8" fill="#FFFFFF" />

  <!-- Title & Subtitle -->
  <text x="24" y="26" font-family="Calibri, Arial, sans-serif" font-size="15" font-weight="700" fill="#1E293B">SƠ ĐỒ KIẾN TRÚC HỆ THỐNG (C4 CONTAINER SYSTEM ARCHITECTURE)</text>
  <text x="24" y="42" font-family="Calibri, Arial, sans-serif" font-size="11" fill="#64748B">EventHub PRM393 · Kiến trúc Serverless 100% · Phân tầng Client, Firestore &amp; Dịch vụ Cloud</text>

  <!-- Top Corridor: Orthogonal Connector Client -> Cloud Services (y=58, perfectly clears subtitle at y=42 and containers at y=80) -->
  <path d="M 147 80 L 147 58 L 840 58 L 840 73" fill="none" stroke="#D97706" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow-amber)" />
  <rect x="408" y="49" width="204" height="18" rx="4" fill="#FFFFFF" stroke="#D97706" stroke-width="1.2" />
  <text x="510" y="61.5" class="lbl-amber">HTTPS SDK (Auth / FCM / Remote Config)</text>

  <!-- Left: Client Layer (x=24..270, width=246, y=80..470) -->
  <rect x="24" y="80" width="246" height="390" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="24" y="80" width="246" height="34" rx="8" fill="#DB2777" />
  <text x="147" y="102" font-family="Calibri, Arial, sans-serif" font-size="12.5" font-weight="700" fill="#FFF" text-anchor="middle">CLIENT APPLICATIONS (TẦNG CLIENT)</text>

  <!-- Mobile App Box -->
  <rect x="36" y="125" width="222" height="135" rx="6" fill="#FFF" stroke="#F472B6" stroke-width="1.2" filter="url(#shadow)" />
  <text x="48" y="147" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#DB2777">Flutter Mobile (Android)</text>
  <text x="48" y="165" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• Dành cho Sinh viên (role: user)</text>
  <text x="48" y="181" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• 12 Màn hình hoàn chỉnh A01..A12</text>
  <text x="48" y="197" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• Riverpod MVVM Architecture</text>
  <text x="48" y="213" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• MobileScanner quét QR Token</text>
  <text x="48" y="242" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#DB2777">Platform: Android 10+ (API 29+)</text>

  <!-- Web Admin Box -->
  <rect x="36" y="272" width="222" height="120" rx="6" fill="#FFF" stroke="#F472B6" stroke-width="1.2" filter="url(#shadow)" />
  <text x="48" y="294" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#DB2777">Flutter Web Admin</text>
  <text x="48" y="312" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• Dành cho Trưởng CLB (staff) &amp; Admin</text>
  <text x="48" y="328" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• 5 Màn hình: Dashboard, Reviews, QR...</text>
  <text x="48" y="344" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• GoRouter 14.8 responsive web</text>
  <text x="48" y="372" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#DB2777">Host: Firebase Hosting (SSL CDN)</text>

  <!-- Shared Core Library -->
  <rect x="36" y="405" width="222" height="45" rx="5" fill="#FFF" stroke="#F472B6" stroke-width="1" />
  <text x="147" y="432" font-family="Calibri, Arial, sans-serif" font-size="10" font-weight="700" fill="#9D174D" text-anchor="middle">packages/core (100% Models &amp; Contracts)</text>

  <!-- Middle: Cloud Backend Layer (x=345..675, width=330, Gap 75px) -->
  <rect x="345" y="80" width="330" height="390" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="2" filter="url(#shadow)" />
  <rect x="345" y="80" width="330" height="34" rx="8" fill="#F97316" />
  <text x="510" y="102" font-family="Calibri, Arial, sans-serif" font-size="13" font-weight="700" fill="#FFF" text-anchor="middle">BACKEND: CLOUD FIRESTORE &amp; RULES</text>

  <!-- Firestore NoSQL Core -->
  <rect x="359" y="125" width="302" height="150" rx="6" fill="#FFF" stroke="#FB923C" stroke-width="1.5" filter="url(#shadow)" />
  <text x="373" y="147" font-family="Calibri, Arial, sans-serif" font-size="12.5" font-weight="700" fill="#EA580C">Cloud Firestore (asia-southeast1)</text>
  <text x="373" y="167" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• NoSQL Document Store với 7 collections</text>
  <text x="373" y="183" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• Realtime Sync qua HTTPS / gRPC Stream</text>
  <text x="373" y="199" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• Atomic Transactions: Khóa sức chứa activeCount</text>
  <text x="373" y="215" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">• Composite Indexes: (status, eventId, createdAt)</text>
  <text x="373" y="248" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#EA580C">SLA Google Cloud 99.99% · Local Emulator Test</text>

  <!-- Security Rules Engine -->
  <rect x="359" y="288" width="302" height="162" rx="6" fill="#FEF3C7" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <text x="373" y="310" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#B45309">firestore.rules (Serverless Logic)</text>
  <text x="373" y="330" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#78350F">• Kiểm tra role: request.auth.token.role</text>
  <text x="373" y="346" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#78350F">• getAfter(event).activeCount == old + 1</text>
  <text x="373" y="362" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#78350F">• Ràng buộc schema: MSSV, email, sđt</text>
  <text x="373" y="378" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#78350F">• Chặn ghi đè trực tiếp &amp; phân quyền 3 roles</text>
  <text x="373" y="415" font-family="Calibri, Arial, sans-serif" font-size="9" font-weight="700" fill="#B45309">16 ca test Emulator Pass 100%</text>

  <!-- Right: Supporting Cloud Services (x=745..935, width=190, Gap 70px) -->
  <rect x="745" y="80" width="190" height="390" rx="8" fill="#FFFBEB" stroke="#D97706" stroke-width="1.5" filter="url(#shadow)" />
  <rect x="745" y="80" width="190" height="34" rx="8" fill="#D97706" />
  <text x="840" y="102" font-family="Calibri, Arial, sans-serif" font-size="12" font-weight="700" fill="#FFF" text-anchor="middle">CLOUD SERVICES (ĐÁM MÂY)</text>

  <!-- Auth -->
  <rect x="755" y="122" width="170" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="765" y="140" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#1E293B">Firebase Authentication</text>
  <text x="765" y="155" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Email/Pass + Google Sign-In</text>

  <!-- FCM -->
  <rect x="755" y="179" width="170" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="765" y="197" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#1E293B">Cloud Messaging (FCM)</text>
  <text x="765" y="212" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Push notifications 3 trạng thái</text>

  <!-- Crashlytics -->
  <rect x="755" y="236" width="170" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="765" y="254" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#1E293B">Firebase Crashlytics</text>
  <text x="765" y="269" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Báo cáo crash &amp; custom keys</text>

  <!-- Remote Config -->
  <rect x="755" y="293" width="170" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="765" y="311" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#1E293B">Remote Config</text>
  <text x="765" y="326" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Feature flags &amp; giới hạn hiển thị</text>

  <!-- App Check -->
  <rect x="755" y="350" width="170" height="48" rx="5" fill="#FFF" stroke="#FDE68A" />
  <text x="765" y="368" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#1E293B">Firebase App Check</text>
  <text x="765" y="383" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#64748B">Play Integrity &amp; Debug Token</text>

  <!-- CONNECTORS (Khoảng cách rộng, có pill nhãn riêng, cách viền 8px không đè khối) -->
  <!-- 1. Client <-> Firestore gRPC (Trong khoảng hở 75px: x=270..345) -->
  <line x1="276" y1="192" x2="337" y2="192" stroke="#EA580C" stroke-width="2" marker-end="url(#arrow-orange)" />
  <line x1="339" y1="206" x2="278" y2="206" stroke="#EA580C" stroke-width="2" marker-end="url(#arrow-orange)" />
  <rect x="282" y="178" width="51" height="17" rx="3" fill="#FFFFFF" stroke="#EA580C" stroke-width="1" />
  <text x="307.5" y="190" class="lbl-pill">gRPC / TLS</text>

  <!-- 2. Firestore <-> Cloud Services (Trong khoảng hở 70px: x=675..745) -->
  <line x1="681" y1="144" x2="737" y2="144" stroke="#D97706" stroke-width="1.5" stroke-dasharray="3,3" marker-end="url(#arrow-amber)" />
  <line x1="739" y1="158" x2="683" y2="158" stroke="#D97706" stroke-width="1.5" stroke-dasharray="3,3" marker-end="url(#arrow-amber)" />
  <rect x="686" y="132" width="48" height="16" rx="3" fill="#FFFFFF" stroke="#D97706" stroke-width="1" />
  <text x="710" y="143.5" class="lbl-amber">Identity</text>
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
  <text x="525" y="132" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#B45309">&#171;interface&#187; EventService</text>
  <text x="525" y="150" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ registerEvent(form, opId)</text>
  <text x="525" y="165" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ approveRegistration(id)</text>
  <text x="525" y="180" font-family="Calibri, Arial, sans-serif" font-size="9" fill="#1E293B">+ checkInWithQr(qrHash)</text>
  <text x="525" y="195" font-family="Calibri, Arial, sans-serif" font-size="8.5" fill="#64748B">Dễ dàng Fake / Mock khi Test</text>

  <rect x="515" y="215" width="180" height="85" rx="5" fill="#FFF" stroke="#FCD34D" />
  <text x="525" y="232" font-family="Calibri, Arial, sans-serif" font-size="10.5" font-weight="700" fill="#B45309">&#171;interface&#187; QrCameraService</text>
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
  <text x="45" y="390" font-family="Calibri, Arial, sans-serif" font-size="10.5" fill="#1E293B"><tspan font-weight="700">Registration:</tspan> id, uid, eventId, clubId, status, generation, participant, reason, checkInAt, createdAt, lastOperationId</text>
  <text x="45" y="408" font-family="Calibri, Arial, sans-serif" font-size="10" fill="#64748B">Hoàn toàn độc lập với Flutter UI và SDK Cloud, chia sẻ 100% giữa Mobile App và Web Admin.</text>
</svg>
"""

# -----------------------------------------------------------------------------
# 6. 14-conceptual-erd.svg (Sơ đồ ERD khái niệm)
# -----------------------------------------------------------------------------
svg_14 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 440" width="100%" height="100%">
  <defs>
    <style>
      .rel-text { font-family: Calibri, Arial, sans-serif; font-size: 10px; font-weight: 700; fill: #475569; paint-order: stroke fill; stroke: #FFFFFF; stroke-width: 3.5px; stroke-linejoin: round; }
      .card-text { font-family: Calibri, Arial, sans-serif; font-size: 11px; font-weight: 700; fill: #64748B; paint-order: stroke fill; stroke: #FFFFFF; stroke-width: 3px; stroke-linejoin: round; }
      .entity-title { font-family: Calibri, Arial, sans-serif; font-size: 12.5px; font-weight: 700; fill: #FFFFFF; text-anchor: middle; }
      .attr-text { font-family: Calibri, Arial, sans-serif; font-size: 10px; fill: #1E293B; }
    </style>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.08" />
    </filter>
  </defs>

  <rect width="960" height="440" rx="8" fill="#FFFFFF" />

  <!-- Title -->
  <text x="24" y="32" font-family="Calibri, Arial, sans-serif" font-size="16" font-weight="700" fill="#1E293B">SƠ ĐỒ THỰC THỂ KHÁI NIỆM (CONCEPTUAL ERD — NGỮ NGHĨA NGHIỆP VỤ)</text>
  <text x="24" y="48" font-family="Calibri, Arial, sans-serif" font-size="11.5" fill="#64748B">EventHub PRM393 · 5 Thực thể cốt lõi, quan hệ bản số (cardinality) và quy tắc toàn vẹn nghiệp vụ chi phối</text>

  <!-- Entity 1: CLUB -->
  <rect x="30" y="80" width="160" height="125" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="2" filter="url(#shadow)" />
  <rect x="30" y="80" width="160" height="30" rx="8" fill="#F97316" />
  <text x="110" y="100" class="entity-title">CLUB (CÂU LẠC BỘ)</text>
  <text x="42" y="126" class="attr-text">• Mã câu lạc bộ (PK)</text>
  <text x="42" y="144" class="attr-text">• Tên CLB &amp; Logo</text>
  <text x="42" y="162" class="attr-text">• Trưởng CLB (staffUid)</text>
  <text x="42" y="180" class="attr-text">• Trạng thái hoạt động</text>

  <!-- Line CLUB to EVENT (Gap 95px: x=190 to x=285) -->
  <line x1="190" y1="142" x2="285" y2="142" stroke="#64748B" stroke-width="2" />
  <text x="237" y="134" class="rel-text" text-anchor="middle">organizes</text>
  <text x="200" y="157" class="card-text" text-anchor="start">1</text>
  <text x="275" y="157" class="card-text" text-anchor="end">0..*</text>

  <!-- Entity 2: EVENT -->
  <rect x="285" y="65" width="180" height="155" rx="8" fill="#FFFBEB" stroke="#D97706" stroke-width="2" filter="url(#shadow)" />
  <rect x="285" y="65" width="180" height="30" rx="8" fill="#D97706" />
  <text x="375" y="85" class="entity-title">EVENT (SỰ KIỆN)</text>
  <text x="295" y="112" class="attr-text">• Mã sự kiện (PK)</text>
  <text x="295" y="129" class="attr-text">• Tiêu đề &amp; Mô tả</text>
  <text x="295" y="146" class="attr-text">• Sức chứa (capacity)</text>
  <text x="295" y="163" class="attr-text">• Số đã duyệt (activeCount)</text>
  <text x="295" y="180" class="attr-text">• Thời hạn &amp; Bắt đầu</text>
  <text x="295" y="197" class="attr-text">• Trạng thái (status)</text>

  <!-- Line EVENT to REGISTRATION (Gap 90px: x=465 to x=555) -->
  <line x1="465" y1="142" x2="555" y2="142" stroke="#64748B" stroke-width="2" />
  <text x="510" y="134" class="rel-text" text-anchor="middle">receives</text>
  <text x="475" y="157" class="card-text" text-anchor="start">1</text>
  <text x="545" y="157" class="card-text" text-anchor="end">0..*</text>

  <!-- Entity 3: REGISTRATION (Associative Entity) -->
  <rect x="555" y="65" width="190" height="155" rx="8" fill="#FDF2F8" stroke="#DB2777" stroke-width="2.2" filter="url(#shadow)" />
  <rect x="555" y="65" width="190" height="30" rx="8" fill="#DB2777" />
  <text x="650" y="85" class="entity-title">REGISTRATION (ĐƠN ĐK)</text>
  <text x="565" y="112" class="attr-text">• ID: {uid}_{eventId} (PK)</text>
  <text x="565" y="129" class="attr-text">• Thông tin SV (participant)</text>
  <text x="565" y="146" class="attr-text">• Trạng thái (status: pending...)</text>
  <text x="565" y="163" class="attr-text">• Lần gửi (generation)</text>
  <text x="565" y="180" class="attr-text">• checkInAt (thời điểm checkin)</text>
  <text x="565" y="197" class="attr-text">• Lý do từ chối (reason)</text>

  <!-- Line REGISTRATION to USER (Gap 70px: x=745 to x=815) -->
  <line x1="745" y1="142" x2="815" y2="142" stroke="#64748B" stroke-width="2" />
  <text x="780" y="134" class="rel-text" text-anchor="middle">submits</text>
  <text x="755" y="157" class="card-text" text-anchor="start">0..*</text>
  <text x="805" y="157" class="card-text" text-anchor="end">1</text>

  <!-- Entity 4: USER -->
  <rect x="815" y="80" width="125" height="125" rx="8" fill="#F8FAFC" stroke="#64748B" stroke-width="2" filter="url(#shadow)" />
  <rect x="815" y="80" width="125" height="30" rx="8" fill="#64748B" />
  <text x="877" y="100" class="entity-title">USER (NGƯỜI DÙNG)</text>
  <text x="825" y="126" class="attr-text">• UID (PK)</text>
  <text x="825" y="144" class="attr-text">• Họ tên, MSSV</text>
  <text x="825" y="162" class="attr-text">• Vai trò (role)</text>
  <text x="825" y="180" class="attr-text">• clubId (nếu staff)</text>

  <!-- Entity 5: CHECKIN_SESSION -->
  <rect x="285" y="265" width="180" height="100" rx="8" fill="#FFFBEB" stroke="#D97706" stroke-width="1.8" filter="url(#shadow)" />
  <rect x="285" y="265" width="180" height="28" rx="8" fill="#D97706" />
  <text x="375" y="284" class="entity-title">CHECKIN_SESSION</text>
  <text x="295" y="310" class="attr-text">• eventId (PK, FK)</text>
  <text x="295" y="328" class="attr-text">• Trạng thái mở (open)</text>
  <text x="295" y="346" class="attr-text">• openedAt (thời điểm mở)</text>

  <!-- Line EVENT to CHECKIN_SESSION (Vertical gap 45px: y=220 to y=265) -->
  <line x1="375" y1="220" x2="375" y2="265" stroke="#64748B" stroke-width="2" />
  <text x="388" y="246" class="rel-text" text-anchor="start">opens</text>
  <text x="362" y="235" class="card-text" text-anchor="end">1</text>
  <text x="362" y="258" class="card-text" text-anchor="end">0..1</text>

  <!-- Entity 6: QR_CREDENTIAL -->
  <rect x="555" y="265" width="190" height="100" rx="8" fill="#FFF7ED" stroke="#F97316" stroke-width="1.8" filter="url(#shadow)" />
  <rect x="555" y="265" width="190" height="28" rx="8" fill="#F97316" />
  <text x="650" y="284" class="entity-title">QR_CREDENTIAL</text>
  <text x="565" y="310" class="attr-text">• qrHash = sha256(token) (PK)</text>
  <text x="565" y="328" class="attr-text">• eventId (FK) &amp; clubId</text>
  <text x="565" y="346" class="attr-text">• enabled: true/false</text>

  <!-- Line CHECKIN_SESSION to QR_CREDENTIAL (Gap 90px: x=465 to x=555) -->
  <line x1="465" y1="315" x2="555" y2="315" stroke="#64748B" stroke-width="1.6" stroke-dasharray="4,3" />
  <text x="510" y="307" class="rel-text" text-anchor="middle">issues</text>
  <text x="475" y="330" class="card-text" text-anchor="start">1</text>
  <text x="545" y="330" class="card-text" text-anchor="end">1..*</text>

  <!-- Bottom Rules Note -->
  <rect x="25" y="385" width="910" height="38" rx="6" fill="#F8FAFC" stroke="#E2E8F0" />
  <text x="35" y="408" font-family="Calibri, Arial, sans-serif" font-size="11" fill="#1E293B">
    <tspan font-weight="700" fill="#475569">Ràng buộc toàn vẹn ngữ nghĩa (Business Integrity Constraints):</tspan>
    <tspan fill="#334155"> Mỗi Sinh viên chỉ có tối đa 1 Registration hoạt động cho 1 Event (khóa {uid}_{eventId}). Một Event chỉ có tối đa 1 phiên QR đang mở.</tspan>
  </text>
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

