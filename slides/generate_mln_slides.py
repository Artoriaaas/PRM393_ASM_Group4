# -*- coding: utf-8 -*-
"""
generate_mln_slides.py
Generates slides/index.html based on mln122-nhom9 technical drawing design.
Removes all meta-prompts (CÂU HỎI HỘI ĐỒNG, THỜI LƯỢNG, MINH CHỨNG BẮT BUỘC, NỘI DUNG CẦN TRÌNH BÀY, TRÁNH, MẪU BỐ CỤC).
Uses 1600x900 stage, Bricolage Grotesque, Be Vietnam Pro, IBM Plex Mono, technical blueprint grid,
interactive progress thread, theme toggles, and spacious engineering panels.
"""

import sys
import os

def get_head_css():
    return """<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <title>EventHub — Báo cáo Đồ án PRM393 (Group 4)</title>
  <style>
    /* 1. LOCAL FONTS (Bricolage Grotesque, Be Vietnam Pro, IBM Plex Mono) */
    @font-face {
      font-family: "Bricolage Grotesque";
      font-weight: 600;
      font-display: swap;
      src: url("fonts/bricolage-grotesque-vietnamese-600-normal.woff2") format("woff2");
    }
    @font-face {
      font-family: "Bricolage Grotesque";
      font-weight: 800;
      font-display: swap;
      src: url("fonts/bricolage-grotesque-vietnamese-800-normal.woff2") format("woff2");
    }
    @font-face {
      font-family: "Be Vietnam Pro";
      font-weight: 400;
      font-display: swap;
      src: url("fonts/be-vietnam-pro-vietnamese-400-normal.woff2") format("woff2");
    }
    @font-face {
      font-family: "Be Vietnam Pro";
      font-weight: 600;
      font-display: swap;
      src: url("fonts/be-vietnam-pro-vietnamese-600-normal.woff2") format("woff2");
    }
    @font-face {
      font-family: "IBM Plex Mono";
      font-weight: 400;
      font-display: swap;
      src: url("fonts/ibm-plex-mono-vietnamese-400-normal.woff2") format("woff2");
    }
    @font-face {
      font-family: "IBM Plex Mono";
      font-weight: 600;
      font-display: swap;
      src: url("fonts/ibm-plex-mono-vietnamese-600-normal.woff2") format("woff2");
    }

    /* 2. COLOR SYSTEM & TOKENS (In the style of mln122 Technical Drawing) */
    :root {
      color-scheme: light;
      /* Mặc định: Giấy can kỹ thuật sáng */
      --cham: #F5F7F3;
      --cham-2: #E8ECE4;
      --cham-3: #CBD5E1;
      --cham-deep: #FFFFFF;
      --vai: #0F172A;
      --vai-2: #334155;
      --vai-3: #64748B;
      --son: #1D4ED8;    /* Xanh kỹ thuật / Tech */
      --nghe: #EA580C;   /* Cam kỹ thuật / Amber Action */
      --si: #0B7A6E;     /* Xanh ngọc / Emerald Success */
      --pink: #DB2777;   /* Hồng điểm nhấn / P1 */
      --red: #DC2626;    /* Đỏ cảnh báo / Exception */
      --on-son: #FFFFFF;
      --on-nghe: #FFFFFF;
      --on-si: #FFFFFF;
      --tex: rgba(15, 23, 42, 0.05);
      --tex2: rgba(15, 23, 42, 0.12);
      --display: "Bricolage Grotesque", "Be Vietnam Pro", -apple-system, sans-serif;
      --body: "Be Vietnam Pro", -apple-system, sans-serif;
      --mono: "IBM Plex Mono", "SF Mono", Consolas, monospace;
    }

    :root[data-look="reu"] {
      color-scheme: dark;
      /* Bản in xanh kỹ thuật (Blueprint) */
      --cham: #123E7C;
      --cham-2: #1A4A8F;
      --cham-3: #5C83C0;
      --cham-deep: #0E3368;
      --vai: #F2F6FF;
      --vai-2: #C9D8F2;
      --vai-3: #93AEDA;
      --son: #60A5FA;
      --nghe: #FFD54A;
      --si: #8BEBD6;
      --pink: #F472B6;
      --red: #F87171;
      --on-son: #0E3368;
      --on-nghe: #0E3368;
      --on-si: #0E3368;
      --tex: rgba(255, 255, 255, 0.04);
      --tex2: rgba(255, 255, 255, 0.08);
    }

    :root[data-look="cham"] {
      color-scheme: dark;
      /* Bàn vẽ đêm (Dark mode) */
      --cham: #0F172A;
      --cham-2: #1E293B;
      --cham-3: #334155;
      --cham-deep: #162032;
      --vai: #F8FAFC;
      --vai-2: #CBD5E1;
      --vai-3: #94A3B8;
      --son: #38BDF8;
      --nghe: #F59E0B;
      --si: #34D399;
      --pink: #EC4899;
      --red: #EF4444;
      --on-son: #0F172A;
      --on-nghe: #0F172A;
      --on-si: #0F172A;
      --tex: rgba(255, 255, 255, 0.04);
      --tex2: rgba(255, 255, 255, 0.08);
    }

    * { box-sizing: border-box; }
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background: #090D14;
      color: var(--vai);
      font-family: var(--body);
      overflow: hidden;
      -webkit-font-smoothing: antialiased;
    }

    /* 3. STAGE 1600x900 CỐ ĐỊNH, CO GIÃN THEO MÀN HÌNH */
    #viewport {
      position: absolute;
      inset: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }

    #stage {
      position: absolute;
      width: 1600px;
      height: 900px;
      transform-origin: center center;
      background: var(--cham);
      background-image:
        linear-gradient(var(--tex) 1px, transparent 1px),
        linear-gradient(90deg, var(--tex) 1px, transparent 1px);
      background-size: 32px 32px;
      box-shadow: 0 30px 90px rgba(0, 0, 0, 0.35);
      border: 1px solid var(--tex2);
    }

    /* 4. SLIDE LAYOUT & ANIMATION */
    .slide {
      position: absolute;
      inset: 0;
      padding: 44px 64px 64px;
      display: none;
      flex-direction: column;
      justify-content: space-between;
      opacity: 0;
      transform: translateY(8px);
      transition: opacity 0.28s ease, transform 0.28s ease;
    }
    .slide.active {
      display: flex;
      opacity: 1;
      transform: translateY(0);
    }

    /* Top Bar / Eyebrow */
    .s-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }
    .eb {
      font: 600 16px/1.2 var(--mono);
      color: var(--nghe);
      letter-spacing: 0.06em;
      text-transform: uppercase;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .eb::before {
      content: "";
      display: inline-block;
      width: 8px;
      height: 8px;
      background: var(--nghe);
      border-radius: 50%;
    }
    .pg-badge {
      font: 600 16px/1.2 var(--mono);
      color: var(--vai-3);
      background: var(--cham-2);
      border: 1px solid var(--cham-3);
      padding: 4px 12px;
      border-radius: 4px;
      letter-spacing: 0.04em;
    }

    /* Header */
    .s-head {
      margin-bottom: 20px;
    }
    h1, h2, h3 {
      font-family: var(--display);
      margin: 0;
    }
    h2 {
      font-weight: 800;
      font-size: 40px;
      line-height: 1.14;
      letter-spacing: -0.02em;
      color: var(--vai);
    }
    h2 em {
      font-style: normal;
      color: var(--son);
    }
    .sub {
      margin: 8px 0 0 0;
      font-size: 19px;
      line-height: 1.4;
      color: var(--vai-2);
      max-width: 1360px;
    }

    /* Body Container */
    .s-body {
      flex: 1;
      min-height: 0;
      display: flex;
      gap: 28px;
    }

    /* Panels & Cards */
    .panel {
      background: var(--cham-deep);
      border: 1px solid var(--cham-3);
      border-radius: 8px;
      padding: 24px;
      display: flex;
      flex-direction: column;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
    }
    .panel.accent-son { border-top: 5px solid var(--son); }
    .panel.accent-nghe { border-top: 5px solid var(--nghe); }
    .panel.accent-si { border-top: 5px solid var(--si); }
    .panel.accent-pink { border-top: 5px solid var(--pink); }

    .tag {
      display: inline-block;
      font: 600 13px/1 var(--mono);
      padding: 6px 10px;
      border-radius: 4px;
      letter-spacing: 0.02em;
      text-transform: uppercase;
      width: fit-content;
    }
    .tag.son { background: rgba(29, 78, 216, 0.12); color: var(--son); }
    .tag.nghe { background: rgba(234, 88, 12, 0.12); color: var(--nghe); }
    .tag.si { background: rgba(11, 122, 110, 0.12); color: var(--si); }
    .tag.pink { background: rgba(219, 39, 119, 0.12); color: var(--pink); }
    .tag.red { background: rgba(220, 38, 38, 0.12); color: var(--red); }

    /* Tables */
    table.spec-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 15px;
    }
    table.spec-table th {
      font: 600 14px var(--mono);
      color: var(--vai-3);
      text-align: left;
      padding: 10px 14px;
      border-bottom: 2px solid var(--cham-3);
      background: var(--cham-2);
      letter-spacing: 0.03em;
    }
    table.spec-table td {
      padding: 12px 14px;
      border-bottom: 1px solid var(--cham-3);
      color: var(--vai);
      vertical-align: middle;
      line-height: 1.35;
    }
    table.spec-table tr:hover td {
      background: var(--cham-2);
    }

    /* Footer Sheet Block */
    .s-foot {
      display: flex;
      justify-content: space-between;
      align-items: baseline;
      font: 500 14px/1 var(--mono);
      color: var(--vai-3);
      padding-top: 14px;
      border-top: 1px dashed var(--cham-3);
    }
    .mono-meta { letter-spacing: 0.04em; }
    .foot-dot { margin: 0 8px; color: var(--cham-3); }

    /* 5. INTERACTIVE SỢI CHỈ TIẾN ĐỘ (#thread) */
    #thread-bar {
      position: absolute;
      left: 0;
      right: 0;
      bottom: 0;
      height: 38px;
      background: var(--cham-2);
      border-top: 1px solid var(--cham-3);
      display: flex;
      align-items: center;
      padding: 0 32px;
      z-index: 10;
    }
    .thread-track {
      flex: 1;
      height: 3px;
      background: var(--cham-3);
      position: relative;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .thread-progress {
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      background: var(--son);
      width: 0%;
      transition: width 0.3s ease;
    }
    .knot {
      width: 14px;
      height: 14px;
      border-radius: 50%;
      background: var(--cham-deep);
      border: 2px solid var(--cham-3);
      cursor: pointer;
      position: relative;
      z-index: 2;
      transition: transform 0.2s, border-color 0.2s, background-color 0.2s;
    }
    .knot:hover {
      transform: scale(1.35);
      border-color: var(--nghe);
    }
    .knot.active {
      background: var(--son);
      border-color: var(--son);
      transform: scale(1.2);
    }
    .knot.completed {
      background: var(--si);
      border-color: var(--si);
    }
    .knot-tooltip {
      position: absolute;
      bottom: 22px;
      left: 50%;
      transform: translateX(-50%);
      background: #0F172A;
      color: #FFF;
      font: 600 12px var(--mono);
      padding: 4px 8px;
      border-radius: 4px;
      white-space: nowrap;
      pointer-events: none;
      opacity: 0;
      transition: opacity 0.15s;
    }
    .knot:hover .knot-tooltip { opacity: 1; }

    .thread-meta {
      margin-left: 24px;
      font: 600 13px var(--mono);
      color: var(--vai-2);
      display: flex;
      align-items: center;
      gap: 16px;
    }
    .btn-tool {
      background: var(--cham);
      border: 1px solid var(--cham-3);
      color: var(--vai);
      font: 600 12px var(--mono);
      padding: 4px 10px;
      border-radius: 4px;
      cursor: pointer;
      transition: all 0.15s;
    }
    .btn-tool:hover {
      background: var(--son);
      color: #FFF;
      border-color: var(--son);
    }

    /* 6. OVERVIEW GRID (PHÍM O) */
    #overview-modal {
      position: absolute;
      inset: 0;
      background: rgba(15, 23, 42, 0.88);
      backdrop-filter: blur(10px);
      z-index: 999;
      display: none;
      flex-direction: column;
      padding: 40px;
    }
    #overview-modal.open { display: flex; }
    .ov-head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      color: #FFF;
      margin-bottom: 24px;
    }
    .ov-head h3 { font-size: 28px; font-weight: 800; font-family: var(--display); }
    .ov-grid {
      flex: 1;
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      gap: 16px;
      overflow-y: auto;
      padding-right: 8px;
    }
    .ov-thumb {
      background: #1E293B;
      border: 1.5px solid #334155;
      border-radius: 6px;
      padding: 12px;
      cursor: pointer;
      color: #E2E8F0;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      aspect-ratio: 16/9;
      transition: all 0.2s;
    }
    .ov-thumb:hover {
      border-color: var(--son);
      transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.4);
    }
    .ov-thumb.active {
      border-color: var(--nghe);
      box-shadow: 0 0 0 2px var(--nghe);
    }
    .ov-num { font: 600 12px var(--mono); color: var(--nghe); }
    .ov-title { font-size: 13px; font-weight: 700; line-height: 1.25; margin-top: 4px; }
  </style>
</head>
<body>
  <div id="viewport">
    <div id="stage">
"""

def get_tail_js(total_slides):
    return f"""
    <!-- SỢI CHỈ TIẾN ĐỘ CHẠY ĐÁY (THEO PHONG CÁCH MLN122) -->
    <div id="thread-bar">
      <div class="thread-track" id="threadTrack">
        <div class="thread-progress" id="threadProgress"></div>
        <!-- Knots generated dynamically -->
      </div>
      <div class="thread-meta">
        <span id="slideIndicator">01 / {total_slides:02d}</span>
        <button class="btn-tool" onclick="toggleTheme()" title="Đổi kiểu màu (Phím D)">🎨 THEME [D]</button>
        <button class="btn-tool" onclick="toggleOverview()" title="Lưới tổng quan (Phím O)">☰ LƯỚI [O]</button>
        <button class="btn-tool" onclick="toggleFullscreen()" title="Toàn màn hình (Phím F)">⛶ TOÀN MÀN HÌNH [F]</button>
      </div>
    </div>

  </div> <!-- /stage -->
</div> <!-- /viewport -->

<!-- LƯỚI TỔNG QUAN TẤT CẢ SLIDE (PHÍM O) -->
<div id="overview-modal">
  <div class="ov-head">
    <h3>LỘ TRÌNH 28 BẢN VẼ KỸ THUẬT · EVENTHUB PRM393</h3>
    <button class="btn-tool" onclick="toggleOverview()" style="padding: 8px 16px; font-size: 14px;">ĐÓNG [ESC]</button>
  </div>
  <div class="ov-grid" id="overviewGrid"></div>
</div>

<script>
  // 1. AUTO-SCALE VIEWPORT TO FIT 1600x900
  const stage = document.getElementById('stage');
  function updateScale() {{
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const scale = Math.min(vw / 1600, vh / 900);
    stage.style.transform = `scale(${{scale}})`;
  }}
  window.addEventListener('resize', updateScale);
  updateScale();

  // 2. SLIDE CONTROLLER
  const slides = Array.from(document.querySelectorAll('.slide'));
  let currentIdx = 0;

  function showSlide(idx) {{
    if (idx < 0 || idx >= slides.length) return;
    slides[currentIdx].classList.remove('active');
    currentIdx = idx;
    slides[currentIdx].classList.add('active');

    // Update Progress Thread
    const progress = (currentIdx / (slides.length - 1)) * 100;
    document.getElementById('threadProgress').style.width = progress + '%';
    document.getElementById('slideIndicator').textContent = 
      `${{String(currentIdx + 1).padStart(2, '0')}} / ${{String(slides.length).padStart(2, '0')}}`;

    // Update knots
    document.querySelectorAll('.knot').forEach((knot, i) => {{
      knot.classList.toggle('active', i === currentIdx);
      knot.classList.toggle('completed', i < currentIdx);
    }});

    // Update overview thumbs
    document.querySelectorAll('.ov-thumb').forEach((thumb, i) => {{
      thumb.classList.toggle('active', i === currentIdx);
    }});
  }}

  function nextSlide() {{ showSlide(currentIdx + 1); }}
  function prevSlide() {{ showSlide(currentIdx - 1); }}

  // 3. BUILD THREAD KNOTS & OVERVIEW THUMBS
  const track = document.getElementById('threadTrack');
  const ovGrid = document.getElementById('overviewGrid');

  slides.forEach((s, i) => {{
    const title = s.getAttribute('data-title') || s.querySelector('h2')?.textContent || `Slide ${{i+1}}`;
    const pageId = s.getAttribute('data-page') || `${{i+1}}`;

    // Thread knot
    const knot = document.createElement('div');
    knot.className = 'knot' + (i === 0 ? ' active' : '');
    knot.innerHTML = `<div class="knot-tooltip">${{pageId}}: ${{title.slice(0, 32)}}</div>`;
    knot.onclick = () => showSlide(i);
    track.appendChild(knot);

    // Overview thumb
    const thumb = document.createElement('div');
    thumb.className = 'ov-thumb' + (i === 0 ? ' active' : '');
    thumb.innerHTML = `
      <div class="ov-num">${{pageId}}</div>
      <div class="ov-title">${{title}}</div>
    `;
    thumb.onclick = () => {{
      showSlide(i);
      toggleOverview();
    }};
    ovGrid.appendChild(thumb);
  }});

  // 4. KEYBOARD SHORTCUTS
  window.addEventListener('keydown', (e) => {{
    if (e.key === 'ArrowRight' || e.key === ' ' || e.key === 'PageDown') {{
      e.preventDefault();
      nextSlide();
    }} else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {{
      e.preventDefault();
      prevSlide();
    }} else if (e.key === 'Home') {{
      e.preventDefault();
      showSlide(0);
    }} else if (e.key === 'End') {{
      e.preventDefault();
      showSlide(slides.length - 1);
    }} else if (e.key === 'd' || e.key === 'D') {{
      toggleTheme();
    }} else if (e.key === 'f' || e.key === 'F') {{
      toggleFullscreen();
    }} else if (e.key === 'o' || e.key === 'O') {{
      toggleOverview();
    }} else if (e.key === 'Escape') {{
      const ov = document.getElementById('overview-modal');
      if (ov.classList.contains('open')) toggleOverview();
    }}
  }});

  // 5. THEME TOGGLER (giay -> reu -> cham -> giay)
  const looks = ['', 'reu', 'cham'];
  let lookIdx = 0;
  function toggleTheme() {{
    lookIdx = (lookIdx + 1) % looks.length;
    const look = looks[lookIdx];
    if (look) {{
      document.documentElement.setAttribute('data-look', look);
    }} else {{
      document.documentElement.removeAttribute('data-look');
    }}
  }}

  // 6. FULLSCREEN & OVERVIEW
  function toggleFullscreen() {{
    if (!document.fullscreenElement) {{
      document.documentElement.requestFullscreen().catch(() => {{}});
    }} else {{
      document.exitFullscreen();
    }}
  }}

  function toggleOverview() {{
    document.getElementById('overview-modal').classList.toggle('open');
  }}
</script>
</body>
</html>
"""

print("generate_mln_slides.py base components ready.")
