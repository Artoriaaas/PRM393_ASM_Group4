# -*- coding: utf-8 -*-
"""
Generator for EventHub PRM393 ASM Group 4 Presentation Slides
Compliant with: Slide_Template_Spec_CamVangHong.md (Software Project Presentation Guideline V11)
30 Slides: G1-G4, Slide 01-25, G5
"""

import os
import json

def get_html_head():
    return """<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PRM393 · EventHub · Group 4 — Software Project Presentation V11</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Carlito:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet">
  <style>
    :root {
      --tx1: #1E293B;
      --navy: #2B1418;
      --bg: #FFF8F3;
      --white: #FFFFFF;
      --accent1: #DB2777; /* PINK - P1 PROBLEM, WF-01 */
      --accent2: #F97316; /* LIGHT ORANGE - WF-02 */
      --accent3: #EA580C; /* ORANGE - P2 DESIGN */
      --accent4: #D97706; /* AMBER YELLOW - P3 DEMO, WF-03, TRÁNH */
      --accent5: #9D174D; /* DEEP PINK - P4 PROOF */
      --accent6: #DC2626; /* RED - Error / exception / pain point */
      --muted: #64748B;
      --slate-600: #475569;
      --slate-700: #334155;
      --slate-300: #CBD5E1;
      --slate-400: #94A3B8;
      --slate-200: #E2E8F0;
      --slate-100: #F1F5F9;
      --slate-50: #F8FAFC;
      --peach: #FDE68A;
      
      --slide-width: 1280px;
      --slide-height: 720px;
      --font-main: Calibri, Carlito, Arial, sans-serif;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      background-color: #1a0f12;
      font-family: var(--font-main);
      color: var(--tx1);
      overflow: hidden;
      width: 100vw;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    /* Presentation Canvas Stage */
    #stage {
      position: relative;
      width: var(--slide-width);
      height: var(--slide-height);
      transform-origin: center center;
      box-shadow: 0 25px 60px rgba(0,0,0,0.45);
      background: var(--bg);
    }

    .slide {
      position: absolute;
      top: 0;
      left: 0;
      width: 1280px;
      height: 720px;
      overflow: hidden;
      display: none;
      background-color: var(--bg);
    }

    .slide.active {
      display: block;
    }

    .slide.layout-dark {
      background-color: var(--navy);
      color: #FFFFFF;
    }

    /* Fixed Template Typography & Base Units */
    .round-rect {
      border-radius: 8px;
    }

    .pill {
      border-radius: 9999px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    /* Fixed Template Elements (Position Absolute) */
    .h-tag-phase {
      position: absolute;
      left: 48px;
      top: 34.56px;
      width: 144px;
      height: 24.96px;
      font-size: 11.33px; /* 8.5pt */
      font-weight: 700;
      text-align: center;
      border-radius: 9999px;
    }

    .h-section {
      position: absolute;
      left: 206.4px;
      top: 34.56px;
      width: 672px;
      height: 24.96px;
      font-size: 12.67px; /* 9.5pt */
      font-weight: 700;
      color: var(--muted);
      display: flex;
      align-items: center;
      letter-spacing: 0.5px;
    }

    .h-pill-right {
      position: absolute;
      left: 895.68px;
      top: 34.56px;
      width: 336px;
      height: 24.96px;
      font-size: 11.33px;
      font-weight: 700;
      border-radius: 9999px;
      display: flex;
      align-items: center;
      justify-content: center;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .h-title {
      position: absolute;
      left: 48px;
      top: 63.36px;
      width: 1183.68px;
      height: 59.52px;
      font-size: 34.67px; /* 26pt */
      font-weight: 700;
      line-height: 1.15;
      display: flex;
      align-items: center;
      color: var(--tx1);
    }
    .h-title .phase-num {
      margin-right: 12px;
    }

    .h-subtitle {
      position: absolute;
      left: 48px;
      top: 124.8px;
      width: 1183.68px;
      height: 30.72px;
      font-size: 16.67px; /* 12.5pt */
      color: var(--muted);
      display: flex;
      align-items: center;
    }

    /* 3 Header Information Boxes */
    .h-box-question {
      position: absolute;
      left: 48px;
      top: 168.96px;
      width: 590.4px;
      height: 61.44px;
      border-radius: 6px;
      padding: 8px 12px;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .h-box-duration {
      position: absolute;
      left: 652.8px;
      top: 168.96px;
      width: 148.8px;
      height: 61.44px;
      border-radius: 6px;
      padding: 8px 12px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
    }

    .h-box-evidence {
      position: absolute;
      left: 816px;
      top: 168.96px;
      width: 415.68px;
      height: 61.44px;
      border-radius: 6px;
      padding: 8px 12px;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .info-box-label {
      font-size: 10.67px; /* 8pt */
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-bottom: 2px;
    }

    .info-box-question-val {
      font-size: 15.33px; /* 11.5pt */
      font-style: italic;
      color: var(--tx1);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .info-box-duration-val {
      font-size: 20px; /* 15pt */
      font-weight: 700;
      color: var(--tx1);
    }

    .info-box-evidence-val {
      font-size: 14px; /* 10.5pt */
      color: var(--tx1);
      line-height: 1.2;
    }

    /* Left Column (x=48px, w=436.8px) */
    .left-label {
      position: absolute;
      left: 48px;
      top: 249.6px;
      width: 432px;
      height: 24px;
      font-size: 12px; /* 9pt */
      font-weight: 700;
      letter-spacing: 1px;
      text-transform: uppercase;
    }

    .left-item {
      position: absolute;
      left: 48px;
      width: 436.8px;
      height: 59.52px;
      display: flex;
      align-items: flex-start;
      gap: 14px;
    }

    .item-num {
      width: 25px;
      height: 25px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: 700;
      flex-shrink: 0;
      margin-top: 2px;
    }

    .item-text {
      font-size: 15px; /* ~11.5 - 12pt */
      color: #000000;
      line-height: 1.25;
    }

    .left-avoid-box {
      position: absolute;
      left: 48px;
      top: 547.2px;
      width: 436.8px;
      height: 94.08px;
      background: rgba(217, 119, 6, 0.10);
      border: 1px solid rgba(217, 119, 6, 0.25);
      border-radius: 6px;
      padding: 10px 14px;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .avoid-title {
      font-size: 11.33px; /* 8.5pt */
      font-weight: 700;
      color: var(--accent4);
      letter-spacing: 1px;
      margin-bottom: 3px;
    }

    .avoid-desc {
      font-size: 14px; /* 10.5pt */
      color: var(--tx1);
      line-height: 1.25;
    }

    /* Right Panel (x=513.6px, y=244.8px, w=718.08px, h=398.4px) */
    .right-card {
      position: absolute;
      left: 513.6px;
      top: 244.8px;
      width: 718.08px;
      height: 398.4px;
      background: var(--white);
      border: 1px solid var(--slate-200);
      border-radius: 8px;
      overflow: hidden;
      padding: 14px 18px;
    }

    .right-panel-label {
      font-size: 11.33px; /* 8.5pt */
      font-weight: 700;
      color: var(--muted);
      letter-spacing: 1px;
      text-transform: uppercase;
      margin-bottom: 8px;
    }

    .right-panel-inner {
      width: 100%;
      height: 320px;
      position: relative;
    }

    .panel-note {
      position: absolute;
      left: 537.6px;
      top: 610.56px;
      width: 672px;
      height: 24.96px;
      font-size: 12.67px; /* 9.5pt */
      font-style: italic;
      color: var(--muted);
      display: flex;
      align-items: center;
    }

    /* Footer */
    .slide-footer-text {
      position: absolute;
      left: 48px;
      top: 672px;
      width: 768px;
      height: 24px;
      font-size: 10.67px; /* 8pt */
      color: var(--muted);
      letter-spacing: 1px;
      text-transform: uppercase;
      display: flex;
      align-items: center;
    }

    .slide-page-num {
      position: absolute;
      left: 1135.68px;
      top: 670.08px;
      width: 96px;
      height: 28.8px;
      font-size: 13.33px; /* 10pt */
      font-weight: 700;
      color: #000000;
      text-align: right;
      display: flex;
      align-items: center;
      justify-content: flex-end;
    }

    /* Layout Components & Badges */
    .status-badge {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 700;
    }

    .badge-pink { background: rgba(219, 39, 119, 0.14); color: var(--accent1); }
    .badge-orange { background: rgba(234, 88, 12, 0.14); color: var(--accent3); }
    .badge-amber { background: rgba(217, 119, 6, 0.14); color: var(--accent4); }
    .badge-red { background: rgba(220, 38, 38, 0.14); color: var(--accent6); }
    .badge-green { background: rgba(22, 163, 74, 0.14); color: #16A34A; }

    /* Tables */
    .spec-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 12.5px;
    }
    .spec-table th {
      background-color: var(--navy);
      color: #FFFFFF;
      font-weight: 700;
      padding: 6px 10px;
      text-align: left;
      border: 1px solid var(--slate-200);
    }
    .spec-table td {
      padding: 6px 10px;
      border: 1px solid var(--slate-200);
      vertical-align: middle;
    }
    .spec-table tr:nth-child(even) td {
      background-color: #FAF5F2;
    }

    /* Interactive Bottom Navigation Controls */
    #nav-controls {
      position: fixed;
      bottom: 12px;
      left: 50%;
      transform: translateX(-50%);
      background: rgba(30, 20, 24, 0.92);
      backdrop-filter: blur(8px);
      border: 1px solid rgba(255,255,255,0.15);
      border-radius: 30px;
      padding: 6px 18px;
      display: flex;
      align-items: center;
      gap: 14px;
      color: #FFFFFF;
      font-size: 13px;
      z-index: 9999;
      box-shadow: 0 8px 24px rgba(0,0,0,0.5);
    }
    #nav-controls button {
      background: rgba(255,255,255,0.12);
      border: none;
      color: #FFFFFF;
      width: 28px;
      height: 28px;
      border-radius: 50%;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 14px;
      transition: all 0.15s;
    }
    #nav-controls button:hover {
      background: var(--accent2);
      transform: scale(1.08);
    }
    #slide-indicator {
      font-weight: 700;
      min-width: 65px;
      text-align: center;
      color: var(--peach);
    }

    /* Modal Overview Grid */
    #overview-modal {
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background: rgba(18, 10, 12, 0.94);
      z-index: 10000;
      display: none;
      flex-direction: column;
      padding: 30px 40px;
      overflow-y: auto;
    }
    #overview-modal.open {
      display: flex;
    }
    .overview-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      color: #FFF;
      margin-bottom: 24px;
    }
    .overview-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
      gap: 16px;
    }
    .overview-thumb {
      background: var(--bg);
      border-radius: 6px;
      padding: 10px;
      cursor: pointer;
      border: 2px solid transparent;
      transition: all 0.2s;
      color: var(--tx1);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      min-height: 125px;
    }
    .overview-thumb:hover {
      border-color: var(--accent2);
      transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.4);
    }
    .overview-thumb.active {
      border-color: var(--accent1);
      background: #FFF1E6;
    }
    .overview-thumb-num {
      font-weight: 700;
      font-size: 12px;
      color: var(--accent3);
    }
    .overview-thumb-title {
      font-size: 13px;
      font-weight: 700;
      margin-top: 4px;
      line-height: 1.25;
    }
    .overview-thumb-phase {
      font-size: 10px;
      font-weight: 700;
      color: var(--muted);
      text-transform: uppercase;
      margin-top: 8px;
    }

    /* Print styles */
    @media print {
      body {
        background: transparent !important;
        width: auto !important;
        height: auto !important;
        overflow: visible !important;
        display: block !important;
      }
      #nav-controls, #overview-modal {
        display: none !important;
      }
      #stage {
        transform: none !important;
        width: 100% !important;
        height: auto !important;
        box-shadow: none !important;
        background: transparent !important;
      }
      .slide {
        display: block !important;
        position: relative !important;
        page-break-after: always !important;
        break-after: page !important;
        width: 1280px !important;
        height: 720px !important;
        margin: 0 auto 20px auto !important;
      }
      @page {
        size: 1280px 720px;
        margin: 0;
      }
    }
  </style>
</head>
<body>
  <div id="stage">
"""

def get_html_tail():
    return """
  </div>

  <!-- Interactive Controls Bar -->
  <div id="nav-controls">
    <button id="btn-prev" title="Slide trước (Phím Mũi tên Trái / PageUp)">❮</button>
    <span id="slide-indicator">01 / 30</span>
    <button id="btn-next" title="Slide sau (Phím Mũi tên Phải / Space / PageDown)">❯</button>
    <button id="btn-overview" title="Xem danh mục lưới 30 slide (Phím O)">☰</button>
    <button id="btn-fullscreen" title="Toàn màn hình (Phím F)">⛶</button>
  </div>

  <!-- Modal Overview Grid -->
  <div id="overview-modal">
    <div class="overview-header">
      <h2 style="font-size: 22px; font-weight: 700;">Danh mục 30 Slide Thuyết trình (Guideline V11 — Cam Vàng Hồng)</h2>
      <button id="btn-close-overview" style="background: none; border: none; color: #FFF; font-size: 24px; cursor: pointer;">✕</button>
    </div>
    <div class="overview-grid" id="overview-grid-container"></div>
  </div>

  <script>
    const slides = Array.from(document.querySelectorAll('.slide'));
    let currentIndex = 0;

    function updateScale() {
      const stage = document.getElementById('stage');
      const stageWidth = 1280;
      const stageHeight = 720;
      const windowWidth = window.innerWidth;
      const windowHeight = window.innerHeight;
      
      const scaleX = windowWidth / stageWidth;
      const scaleY = windowHeight / stageHeight;
      const scale = Math.min(scaleX, scaleY) * 0.96; // 96% padding
      
      stage.style.transform = `scale(${scale})`;
    }

    function showSlide(index) {
      if (index < 0) index = 0;
      if (index >= slides.length) index = slides.length - 1;
      
      slides.forEach((s, i) => {
        s.classList.toggle('active', i === index);
      });
      currentIndex = index;
      
      const pageId = slides[index].getAttribute('data-page-id') || (index + 1);
      document.getElementById('slide-indicator').textContent = `${String(index + 1).padStart(2, '0')} / ${slides.length}`;
      window.location.hash = pageId;
      
      // Update active in overview
      document.querySelectorAll('.overview-thumb').forEach((thumb, i) => {
        thumb.classList.toggle('active', i === index);
      });
    }

    function nextSlide() {
      if (currentIndex < slides.length - 1) {
        showSlide(currentIndex + 1);
      }
    }

    function prevSlide() {
      if (currentIndex > 0) {
        showSlide(currentIndex - 1);
      }
    }

    function buildOverview() {
      const container = document.getElementById('overview-grid-container');
      container.innerHTML = '';
      slides.forEach((s, idx) => {
        const pageId = s.getAttribute('data-page-id') || (idx + 1);
        const titleEl = s.querySelector('.h-title') || s.querySelector('h1') || s.querySelector('.slide-sub-title');
        const phaseEl = s.querySelector('.h-tag-phase') || s.querySelector('.phase-pill');
        
        let titleText = titleEl ? titleEl.innerText.replace(/Slide \\d+\\s*/, '').trim() : `Slide ${idx + 1}`;
        let phaseText = phaseEl ? phaseEl.innerText.trim() : '';

        const card = document.createElement('div');
        card.className = `overview-thumb ${idx === currentIndex ? 'active' : ''}`;
        card.innerHTML = `
          <div>
            <div class="overview-thumb-num">#${pageId}</div>
            <div class="overview-thumb-title">${titleText}</div>
          </div>
          <div class="overview-thumb-phase">${phaseText}</div>
        `;
        card.addEventListener('click', () => {
          showSlide(idx);
          document.getElementById('overview-modal').classList.remove('open');
        });
        container.appendChild(card);
      });
    }

    function toggleOverview() {
      const modal = document.getElementById('overview-modal');
      modal.classList.toggle('open');
    }

    function toggleFullscreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {});
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        }
      }
    }

    // Event Listeners
    window.addEventListener('resize', updateScale);
    window.addEventListener('DOMContentLoaded', () => {
      updateScale();
      buildOverview();
      
      // Check hash
      if (window.location.hash) {
        const hash = window.location.hash.substring(1);
        const found = slides.findIndex(s => s.getAttribute('data-page-id') === hash || s.id === hash);
        if (found !== -1) {
          showSlide(found);
          return;
        }
      }
      showSlide(0);
    });

    document.getElementById('btn-next').addEventListener('click', nextSlide);
    document.getElementById('btn-prev').addEventListener('click', prevSlide);
    document.getElementById('btn-overview').addEventListener('click', toggleOverview);
    document.getElementById('btn-close-overview').addEventListener('click', toggleOverview);
    document.getElementById('btn-fullscreen').addEventListener('click', toggleFullscreen);

    window.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === ' ' || e.key === 'PageDown') {
        e.preventDefault();
        nextSlide();
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        e.preventDefault();
        prevSlide();
      } else if (e.key === 'Home') {
        e.preventDefault();
        showSlide(0);
      } else if (e.key === 'End') {
        e.preventDefault();
        showSlide(slides.length - 1);
      } else if (e.key.toLowerCase() === 'o') {
        e.preventDefault();
        toggleOverview();
      } else if (e.key.toLowerCase() === 'f') {
        e.preventDefault();
        toggleFullscreen();
      } else if (e.key === 'Escape') {
        document.getElementById('overview-modal').classList.remove('open');
      }
    });
  </script>
</body>
</html>
"""

print("Generator helper base defined.")

