# -*- coding: utf-8 -*-
"""
make_slides.py - Generates index.html for EventHub PRM393 ASM Group 4
Strictly aligned with Slide_Template_Spec_CamVangHong.md
"""

import sys
import os

from generate_slides import get_html_head, get_html_tail
from slide_definitions import get_slide_definitions
from slide_definitions_p2 import get_p2_slides
from slide_definitions_p3_p4 import get_p3_p4_slides

def render_standard_slide(s):
    pill_right_html = ""
    if s.get("pill_right"):
        pill_right_html = f"""
        <div class="h-pill-right" style="background: {s['phase_bg']}; color: {s['phase_color']};">
          {s['pill_right']}
        </div>
        """

    left_items_html = ""
    y_starts = [285.12, 349.44, 413.76, 478.08]
    for idx, item in enumerate(s["left_items"]):
        y_top = y_starts[idx] if idx < len(y_starts) else 285.12 + idx * 64.32
        left_items_html += f"""
        <div class="left-item" style="top: {y_top}px;">
          <div class="item-num" style="background: {s['phase_bg']}; color: {s['phase_color']};">{idx + 1}</div>
          <div class="item-text">{item}</div>
        </div>
        """

    return f"""
    <!-- {s['section_str']} -->
    <section class="slide" id="{s['id']}" data-page-id="{s['page_id']}">
      <!-- Header -->
      <div class="h-tag-phase" style="background: {s['phase_bg']}; color: {s['phase_color']};">
        {s['phase_tag']}
      </div>
      <div class="h-section">{s['section_str']}</div>
      {pill_right_html}
      <div class="h-title">
        <span class="phase-num" style="color: {s['phase_color']};">{s['slide_num_str']}</span>
        <span>{s['title_rest']}</span>
      </div>
      <div class="h-subtitle">{s['subtitle']}</div>

      <!-- 3 Info Boxes -->
      <div class="h-box-question" style="background: {s['box_bg']};">
        <div class="info-box-label" style="color: {s['phase_color']};">CÂU HỎI HỘI ĐỒNG</div>
        <div class="info-box-question-val">“{s['question']}”</div>
      </div>

      <div class="h-box-duration" style="background: {s['box_bg']};">
        <div class="info-box-label" style="color: {s['phase_color']};">THỜI LƯỢNG</div>
        <div class="info-box-duration-val">{s['duration']}</div>
      </div>

      <div class="h-box-evidence" style="background: {s['box_bg']};">
        <div class="info-box-label" style="color: {s['phase_color']};">MINH CHỨNG BẮT BUỘC</div>
        <div class="info-box-evidence-val">{s['evidence']}</div>
      </div>

      <!-- Left Column -->
      <div class="left-label" style="color: {s['phase_color']};">NỘI DUNG CẦN TRÌNH BÀY</div>
      {left_items_html}
      <div class="left-avoid-box">
        <div class="avoid-title">TRÁNH</div>
        <div class="avoid-desc">{s['avoid_text']}</div>
      </div>

      <!-- Right Panel -->
      <div class="right-card">
        <div class="right-panel-label">{s['panel_label']}</div>
        <div class="right-panel-inner">
          {s['panel_content_html']}
        </div>
      </div>
      <div class="panel-note">{s['panel_note']}</div>

      <!-- Footer -->
      <div class="slide-footer-text">PRM393 · EVENTHUB · GROUP 4 · SOFTWARE PROJECT PRESENTATION V11</div>
      <div class="slide-page-num">{s['footer_page']}</div>
    </section>
    """

def render_g5():
    return """
    <!-- SLIDE G5 · CHECKLIST QUALITY GATE -->
    <section class="slide" id="slide-g5" data-page-id="G5">
      <div class="h-section" style="left: 48px; top: 34.56px;">QUALITY GATE</div>
      <div class="h-title" style="top: 63.36px;">Checklist rà soát trước khi bảo vệ</div>
      <div class="h-subtitle">Tự kiểm tra tính nhất quán của thiết kế và mức sẵn sàng của demo.</div>

      <!-- 4x2 Grid Cards -->
      <!-- Row 1 -->
      <div style="position: absolute; left: 48px; top: 182.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent1); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">PROBLEM</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Vấn đề có minh chứng, user rõ ràng, pain points đo lường được?</div>
      </div>

      <div style="position: absolute; left: 348.5px; top: 182.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent1); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">FEATURES</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Tính năng chính nhóm theo nghiệp vụ, gắn chặt với giải pháp?</div>
      </div>

      <div style="position: absolute; left: 649px; top: 182.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent3); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">DESIGN</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Business flow, state, UI, class, DB khớp nhau và khớp code?</div>
      </div>

      <div style="position: absolute; left: 949.4px; top: 182.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent3); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">TRACEABILITY</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Mỗi feature nối được Screen → Class → Database → Test?</div>
      </div>

      <!-- Row 2 -->
      <div style="position: absolute; left: 48px; top: 374.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent4); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">DEMO WORKFLOW</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">2–4 workflow lõi có trigger, kết quả; chạy thật, có nhánh ngoại lệ?</div>
      </div>

      <div style="position: absolute; left: 348.5px; top: 374.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent4); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">DEMO DATA</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Seed data, tài khoản theo actor, script reset, video dự phòng?</div>
      </div>

      <div style="position: absolute; left: 649px; top: 374.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent5); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">TESTS</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Test theo tính năng / BR / state; có report và kết quả thực tế?</div>
      </div>

      <div style="position: absolute; left: 949.4px; top: 374.4px; width: 281.3px; height: 172.8px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 16px;">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 10px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--accent5); color: #FFF; font-weight: 700; font-size: 16px; display: flex; align-items: center; justify-content: center;">✓</div>
          <div style="font-size: 16px; font-weight: 700; color: #000;">OUTCOME</div>
        </div>
        <div style="font-size: 14.5px; color: var(--slate-600); line-height: 1.35;">Kết quả và giới hạn được phát biểu trung thực, có cơ sở rõ ràng?</div>
      </div>

      <!-- Bottom Banner (Navy + Peach text) -->
      <div style="position: absolute; left: 48px; top: 580.8px; width: 1183.7px; height: 48px; background: var(--navy); border-radius: 6px; padding: 0 20px; display: flex; align-items: center; font-size: 15px; font-weight: 700; color: var(--peach); letter-spacing: 0.5px;">
        TRUY VẾT: Problem → Feature → Design tổng thể → Demo workflow → Test → Achievements
      </div>

      <!-- Footer -->
      <div class="slide-footer-text">PRM393 · EVENTHUB · GROUP 4 · SOFTWARE PROJECT PRESENTATION V11</div>
      <div class="slide-page-num">G5</div>
    </section>
    """

def main():
    parts = []
    # HTML Head & Styles
    parts.append(get_html_head())
    
    # Slides G1-G4
    from make_slides import build_slides_html
    # get raw G1-G4 from make_slides.py
    with open("slides/make_slides.py", "r", encoding="utf-8") as f:
        content = f.read()
    g1_g4_start = content.find("html.append(\"\"\"\n    <section class=\"slide layout-dark active\" id=\"slide-g1\"")
    g1_g4_end = content.find("return \"\".join(html)")
    if g1_g4_start != -1 and g1_g4_end != -1:
        # Extract the html chunks between g1_g4_start and g1_g4_end
        code_slice = content[g1_g4_start:g1_g4_end]
        # execute code_slice in a local dict
        loc = {"html": []}
        exec(code_slice, {}, loc)
        parts.extend(loc["html"])
    
    # Slides 01-06 (P1)
    p1_defs = get_slide_definitions()
    for s in p1_defs:
        parts.append(render_standard_slide(s))
        
    # Slides 07-16 (P2)
    p2_defs = get_p2_slides()
    for s in p2_defs:
        parts.append(render_standard_slide(s))

    # Slides 17-25 (P3, P4, Appendix)
    p3_p4_defs = get_p3_p4_slides()
    for s in p3_p4_defs:
        parts.append(render_standard_slide(s))

    # Slide G5 (Checklist Quality Gate)
    parts.append(render_g5())

    # HTML Tail & Script
    parts.append(get_html_tail())

    full_html = "".join(parts)
    
    output_path = "slides/index.html"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(full_html)
        
    print(f"Successfully generated {output_path} with {len(p1_defs) + len(p2_defs) + len(p3_p4_defs) + 5} slides total!")

if __name__ == "__main__":
    main()

