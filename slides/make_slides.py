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

def get_g1_to_g4_html():
    return """
    <!-- SLIDE G1 · Cover (layout DARK) -->
    <section class="slide layout-dark active" id="slide-g1" data-page-id="G1">
      <!-- Tag top -->
      <div style="position: absolute; left: 57.6px; top: 52.8px; width: 440px; height: 30.72px; background: rgba(255,255,255,0.12); border-radius: 9999px; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; color: var(--slate-300); letter-spacing: 1px; text-transform: uppercase;">
        PRM393 · ĐỒ ÁN PHÁT TRIỂN PHẦN MỀM DI ĐỘNG · GROUP 4
      </div>

      <!-- Main Title (Arial bold) -->
      <div style="position: absolute; left: 57.6px; top: 105.6px; width: 1152px; height: 153.6px; font-family: Arial, sans-serif; font-size: 46px; font-weight: 700; line-height: 1.15; color: #FFFFFF;">
        EVENTHUB — NỀN TẢNG QUẢN LÝ SỰ KIỆN<br>VÀ ĐIỂM DANH QR LIÊN VAI TRÒ
      </div>

      <!-- Subtitle -->
      <div style="position: absolute; left: 57.6px; top: 283.2px; width: 1132.8px; height: 67.2px; font-size: 19px; line-height: 1.35; color: var(--slate-300);">
        Hệ thống Serverless Realtime: Flutter Mobile App (Android) cho Sinh viên · Flutter Web Admin cho Trưởng CLB &amp; Quản trị viên · Cloud Firestore Security Rules
      </div>

      <!-- 4 Phase Cards -->
      <div style="position: absolute; left: 57.6px; top: 398.4px; width: 273.6px; height: 144px; background: rgba(255,255,255,0.08); border: 1px solid var(--slate-700); border-radius: 8px; padding: 16px;">
        <div style="font-size: 26px; font-weight: 700; color: var(--accent1); margin-bottom: 2px;">01</div>
        <div style="font-size: 18px; font-weight: 700; color: #FFFFFF; margin-bottom: 8px;">PROBLEM</div>
        <div style="font-size: 16px; color: var(--slate-200);">Tại sao làm? Làm gì?</div>
      </div>

      <div style="position: absolute; left: 350.4px; top: 398.4px; width: 273.6px; height: 144px; background: rgba(255,255,255,0.08); border: 1px solid var(--slate-700); border-radius: 8px; padding: 16px;">
        <div style="font-size: 26px; font-weight: 700; color: var(--accent3); margin-bottom: 2px;">02</div>
        <div style="font-size: 18px; font-weight: 700; color: #FFFFFF; margin-bottom: 8px;">DESIGN</div>
        <div style="font-size: 16px; color: var(--slate-200);">Xây thế nào? Toàn hệ thống</div>
      </div>

      <div style="position: absolute; left: 643.2px; top: 398.4px; width: 273.6px; height: 144px; background: rgba(255,255,255,0.08); border: 2px solid var(--accent4); border-radius: 8px; padding: 16px;">
        <div style="font-size: 26px; font-weight: 700; color: var(--accent4); margin-bottom: 2px;">03</div>
        <div style="font-size: 18px; font-weight: 700; color: #FFFFFF; margin-bottom: 8px;">DEMO</div>
        <div style="font-size: 16px; color: var(--slate-200);">Workflow chạy ra sao?</div>
      </div>

      <div style="position: absolute; left: 936px; top: 398.4px; width: 273.6px; height: 144px; background: rgba(255,255,255,0.08); border: 1px solid var(--slate-700); border-radius: 8px; padding: 16px;">
        <div style="font-size: 26px; font-weight: 700; color: var(--accent5); margin-bottom: 2px;">04</div>
        <div style="font-size: 18px; font-weight: 700; color: #FFFFFF; margin-bottom: 8px;">PROOF</div>
        <div style="font-size: 16px; color: var(--slate-200);">Chứng minh được gì?</div>
      </div>

      <!-- 3 Workflow Pills -->
      <div style="position: absolute; left: 57.6px; top: 571.2px; width: 371.5px; height: 40.3px; background: var(--accent1); border-radius: 9999px; display: flex; align-items: center; justify-content: center; font-size: 14.5px; font-weight: 700; color: #FFFFFF;">
        WF-01 · Đăng ký sự kiện (Mobile)
      </div>

      <div style="position: absolute; left: 448.3px; top: 571.2px; width: 371.5px; height: 40.3px; background: var(--accent2); border-radius: 9999px; display: flex; align-items: center; justify-content: center; font-size: 14.5px; font-weight: 700; color: #FFFFFF;">
        WF-02 · Xét duyệt đơn (Web Admin)
      </div>

      <div style="position: absolute; left: 839.0px; top: 571.2px; width: 371.5px; height: 40.3px; background: var(--accent4); border-radius: 9999px; display: flex; align-items: center; justify-content: center; font-size: 14.5px; font-weight: 700; color: #FFFFFF;">
        WF-03 · Điểm danh QR Realtime
      </div>

      <!-- Bottom Note -->
      <div style="position: absolute; left: 57.6px; top: 633.6px; width: 1056px; height: 28.8px; font-size: 14px; font-style: italic; color: var(--slate-400); display: flex; align-items: center;">
        Dùng cho bảo vệ đồ án: Đại học FPT • PRM393 (Flutter &amp; Firebase) • Giảng viên hướng dẫn &amp; Hội đồng chấm thi
      </div>

      <!-- Page Number -->
      <div style="position: absolute; left: 1135.68px; top: 670.08px; width: 96px; height: 28.8px; font-size: 13.33px; font-weight: 700; color: var(--slate-400); text-align: right; display: flex; align-items: center; justify-content: flex-end;">
        G1
      </div>
    </section>

    <!-- SLIDE G2 · Nguyên tắc chung -->
    <section class="slide" id="slide-g2" data-page-id="G2">
      <div class="h-section" style="left: 48px; top: 34.56px;">NGUYÊN TẮC CHUNG</div>
      <div class="h-title" style="top: 63.36px;">Slide là công cụ tổng quan: thiết kế tổng thể, demo theo workflow</div>
      <div class="h-subtitle">Tài liệu kỹ thuật (SRS, SDD, test report) nằm ở phụ lục và báo cáo; slide chỉ chọn điều hội đồng cần thấy.</div>

      <!-- 4 Cards -->
      <div style="position: absolute; left: 48px; top: 182.4px; width: 281.3px; height: 264px; background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 20px;">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: var(--accent1); color: #FFF; font-size: 18px; font-weight: 700; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;">1</div>
        <div style="font-size: 19px; font-weight: 700; color: #000; margin-bottom: 10px;">Một slide = một thông điệp</div>
        <div style="font-size: 15px; color: var(--slate-600); line-height: 1.35;">Tiêu đề là câu kết luận. Mỗi phần trả lời một câu hỏi của hội đồng; không liệt kê tính năng rời rạc.</div>
      </div>

      <div style="position: absolute; left: 348.5px; top: 182.4px; width: 281.3px; height: 264px; background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 20px;">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: var(--accent3); color: #FFF; font-size: 18px; font-weight: 700; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;">2</div>
        <div style="font-size: 19px; font-weight: 700; color: #000; margin-bottom: 10px;">Thiết kế cho tổng thể</div>
        <div style="font-size: 15px; color: var(--slate-600); line-height: 1.35;">Phần Design mô tả toàn hệ thống bằng các sơ đồ tổng quan. Không trình bày thiết kế riêng cho từng workflow.</div>
      </div>

      <div style="position: absolute; left: 649px; top: 182.4px; width: 281.3px; height: 264px; background: #FFFFFF; border: 2px solid var(--accent4); border-radius: 8px; padding: 20px;">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: var(--accent4); color: #FFF; font-size: 18px; font-weight: 700; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;">3</div>
        <div style="font-size: 19px; font-weight: 700; color: #000; margin-bottom: 10px;">Demo theo workflow</div>
        <div style="font-size: 15px; color: var(--slate-600); line-height: 1.35;">Chọn 2–4 workflow lõi. Mỗi workflow một slide demo: actor, trigger, các bước, kết quả, ngoại lệ, minh chứng.</div>
      </div>

      <div style="position: absolute; left: 949.4px; top: 182.4px; width: 281.3px; height: 264px; background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 8px; padding: 20px;">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: var(--accent5); color: #FFF; font-size: 18px; font-weight: 700; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;">4</div>
        <div style="font-size: 19px; font-weight: 700; color: #000; margin-bottom: 10px;">Có minh chứng</div>
        <div style="font-size: 15px; color: var(--slate-600); line-height: 1.35;">Số liệu, ảnh, link demo, test report. Chi tiết kỹ thuật để ở phụ lục, mở khi hội đồng hỏi.</div>
      </div>

      <!-- Row 2: 6 boxes -->
      <div style="position: absolute; left: 48px; top: 470.4px; font-size: 12px; font-weight: 700; color: var(--muted); letter-spacing: 1px; text-transform: uppercase;">
        CẤU TRÚC MỖI SLIDE MẪU
      </div>

      <div style="position: absolute; left: 48px; top: 504px; width: 184.3px; height: 91.2px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; justify-content: center;">
        <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Câu hỏi hội đồng</div>
        <div style="font-size: 13.3px; color: var(--muted); margin-top: 4px;">slide trả lời câu gì</div>
      </div>

      <div style="position: absolute; left: 246.7px; top: 504px; width: 184.3px; height: 91.2px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; justify-content: center;">
        <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Thời lượng</div>
        <div style="font-size: 13.3px; color: var(--muted); margin-top: 4px;">ngân sách thời gian</div>
      </div>

      <div style="position: absolute; left: 445.4px; top: 504px; width: 184.3px; height: 91.2px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; justify-content: center;">
        <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Minh chứng</div>
        <div style="font-size: 13.3px; color: var(--muted); margin-top: 4px;">phải có trên slide</div>
      </div>

      <div style="position: absolute; left: 644.2px; top: 504px; width: 184.3px; height: 91.2px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; justify-content: center;">
        <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Nội dung</div>
        <div style="font-size: 13.3px; color: var(--muted); margin-top: 4px;">4 ý cần trình bày</div>
      </div>

      <div style="position: absolute; left: 842.9px; top: 504px; width: 184.3px; height: 91.2px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; justify-content: center;">
        <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Tránh</div>
        <div style="font-size: 13.3px; color: var(--muted); margin-top: 4px;">lỗi hay gặp</div>
      </div>

      <div style="position: absolute; left: 1041.6px; top: 504px; width: 184.3px; height: 91.2px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; justify-content: center;">
        <div style="font-size: 15px; font-weight: 700; color: var(--tx1);">Mẫu bố cục</div>
        <div style="font-size: 13.3px; color: var(--muted); margin-top: 4px;">gợi ý hình / bảng</div>
      </div>

      <!-- Footer -->
      <div class="slide-footer-text">SOFTWARE PROJECT / PRESENTATION GUIDELINE V11</div>
      <div class="slide-page-num">G2</div>
    </section>

    <!-- SLIDE G3 · Cách chia nội dung -->
    <section class="slide" id="slide-g3" data-page-id="G3">
      <div class="h-section" style="left: 48px; top: 34.56px;">CÁCH PHÂN CHIA NỘI DUNG</div>
      <div class="h-title" style="top: 63.36px;">Thiết kế cho tổng thể, demo cho workflow</div>
      <div class="h-subtitle">Mỗi phần có một vai trò riêng; không lặp lại chi tiết từng workflow ở phần Design.</div>

      <!-- 2 Cards -->
      <div style="position: absolute; left: 48px; top: 182.4px; width: 580.8px; height: 379.2px; background: #FFFFFF; border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden;">
        <div style="width: 100%; height: 55.7px; background: var(--accent3); color: #FFF; font-size: 17.3px; font-weight: 700; padding: 0 20px; display: flex; align-items: center;">
          DESIGN — TOÀN HỆ THỐNG
        </div>
        <div style="padding: 16px 20px;">
          <div style="font-size: 16px; font-style: italic; color: var(--slate-600); margin-bottom: 14px;">Trả lời: hệ thống được xây như thế nào?</div>
          
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <div style="background: rgba(234, 88, 12, 0.08); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent3);">Slide 07</div>
              <div style="font-size: 16px; font-weight: 700; color: var(--tx1);">Business Flow</div>
            </div>
            <div style="background: rgba(234, 88, 12, 0.08); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent3);">Slide 08</div>
              <div style="font-size: 16px; font-weight: 700; color: var(--tx1);">State machine</div>
            </div>
            <div style="background: rgba(234, 88, 12, 0.08); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent3);">Slide 09</div>
              <div style="font-size: 16px; font-weight: 700; color: var(--tx1);">System architecture</div>
            </div>
            <div style="background: rgba(234, 88, 12, 0.08); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent3);">Slide 11</div>
              <div style="font-size: 16px; font-weight: 700; color: var(--tx1);">UI/UX tổng thể</div>
            </div>
            <div style="background: rgba(234, 88, 12, 0.08); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent3);">Slide 13</div>
              <div style="font-size: 16px; font-weight: 700; color: var(--tx1);">Class design</div>
            </div>
            <div style="background: rgba(234, 88, 12, 0.08); border-radius: 6px; padding: 10px 14px;">
              <div style="font-size: 12.6px; font-weight: 700; color: var(--accent3);">Slide 14–15</div>
              <div style="font-size: 16px; font-weight: 700; color: var(--tx1);">Database design</div>
            </div>
          </div>
        </div>
      </div>

      <div style="position: absolute; left: 650.9px; top: 182.4px; width: 580.8px; height: 379.2px; background: #FFFFFF; border: 2px solid var(--accent4); border-radius: 8px; overflow: hidden;">
        <div style="width: 100%; height: 55.7px; background: var(--accent4); color: #FFF; font-size: 17.3px; font-weight: 700; padding: 0 20px; display: flex; align-items: center;">
          DEMO — THEO TỪNG WORKFLOW
        </div>
        <div style="padding: 16px 20px;">
          <div style="font-size: 16px; font-style: italic; color: var(--slate-600); margin-bottom: 14px;">Trả lời: từng workflow chạy thật ra sao?</div>
          
          <div style="display: flex; flex-direction: column; gap: 12px;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="width: 187px; height: 60px; background: var(--accent1); border-radius: 6px; color: #FFF; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <div style="font-size: 15px; font-weight: 700;">WF-01</div>
                <div style="font-size: 13px;">Gửi yêu cầu đăng ký</div>
              </div>
              <div style="flex: 1; height: 60px; background: rgba(219,39,119,0.08); border-radius: 6px; padding: 8px 14px; display: flex; flex-direction: column; justify-content: center;">
                <div style="font-size: 12px; font-weight: 700; color: var(--accent1);">Slide 18</div>
                <div style="font-size: 14.5px; color: var(--tx1);">Trigger → các bước → kết quả + ngoại lệ</div>
              </div>
            </div>

            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="width: 187px; height: 60px; background: var(--accent2); border-radius: 6px; color: #FFF; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <div style="font-size: 15px; font-weight: 700;">WF-02</div>
                <div style="font-size: 13px;">Duyệt yêu cầu</div>
              </div>
              <div style="flex: 1; height: 60px; background: rgba(249,115,22,0.08); border-radius: 6px; padding: 8px 14px; display: flex; flex-direction: column; justify-content: center;">
                <div style="font-size: 12px; font-weight: 700; color: var(--accent2);">Slide 19</div>
                <div style="font-size: 14.5px; color: var(--tx1);">Trigger → các bước → kết quả + ngoại lệ</div>
              </div>
            </div>

            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="width: 187px; height: 60px; background: var(--accent4); border-radius: 6px; color: #FFF; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <div style="font-size: 15px; font-weight: 700;">WF-03</div>
                <div style="font-size: 13px;">Điểm danh QR Realtime</div>
              </div>
              <div style="flex: 1; height: 60px; background: rgba(217,119,6,0.08); border-radius: 6px; padding: 8px 14px; display: flex; flex-direction: column; justify-content: center;">
                <div style="font-size: 12px; font-weight: 700; color: var(--accent4);">Slide 20</div>
                <div style="font-size: 14.5px; color: var(--tx1);">Trigger → các bước → kết quả + ngoại lệ</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Bottom Rule Bar -->
      <div style="position: absolute; left: 48px; top: 580.8px; width: 1183.7px; height: 52.8px; background: rgba(217, 119, 6, 0.12); border-radius: 8px; padding: 0 20px; display: flex; align-items: center; font-size: 16px; font-weight: 700; color: var(--accent4);">
        Quy tắc: chọn 2–4 workflow lõi để demo, ghép thành một câu chuyện liền mạch; chi tiết từng workflow chỉ xuất hiện ở phần Demo.
      </div>

      <!-- Footer -->
      <div class="slide-footer-text">SOFTWARE PROJECT / PRESENTATION GUIDELINE V11</div>
      <div class="slide-page-num">G3</div>
    </section>

    <!-- SLIDE G4 · Danh mục slide -->
    <section class="slide" id="slide-g4" data-page-id="G4">
      <div class="h-section" style="left: 48px; top: 34.56px;">DANH MỤC SLIDE / VERSION 11</div>
      <div class="h-title" style="top: 63.36px;">24 slide nội dung, 4 phần, ≈ 18–20 phút — demo chiếm 1/3</div>
      <div class="h-subtitle">(*) = gộp hoặc đưa vào phụ lục khi thiếu thời gian.</div>

      <!-- 4 Columns -->
      <div style="position: absolute; left: 48px; top: 177.6px; width: 281.3px; height: 379.2px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden;">
        <div style="width: 100%; height: 52.8px; background: var(--accent1); color: #FFF; font-size: 16px; font-weight: 700; padding: 0 16px; display: flex; align-items: center;">
          P1 PROBLEM · ≈ 3.5′
        </div>
        <div style="padding: 14px 16px; font-size: 14.5px; color: var(--slate-700); line-height: 1.8;">
          01 Overview<br>
          02 Context<br>
          03 Problem<br>
          04 Proposed Solution<br>
          05 Main Actors<br>
          06 Main Features
        </div>
      </div>

      <div style="position: absolute; left: 348.5px; top: 177.6px; width: 281.3px; height: 379.2px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden;">
        <div style="width: 100%; height: 52.8px; background: var(--accent3); color: #FFF; font-size: 16px; font-weight: 700; padding: 0 16px; display: flex; align-items: center;">
          P2 DESIGN · ≈ 6′
        </div>
        <div style="padding: 10px 16px; font-size: 13.5px; color: var(--slate-700); line-height: 1.65;">
          07 Business Flow<br>
          08 State Machine<br>
          09 System Architecture<br>
          10 Technology Stack<br>
          11 UI/UX Design<br>
          12 Sequence Diagram *<br>
          13 Class Design<br>
          14 Database Conceptual *<br>
          15 Database Logical/Physical<br>
          16 Traceability
        </div>
      </div>

      <div style="position: absolute; left: 649px; top: 177.6px; width: 281.3px; height: 379.2px; background: #FFF; border: 2px solid var(--accent4); border-radius: 8px; overflow: hidden;">
        <div style="width: 100%; height: 52.8px; background: var(--accent4); color: #FFF; font-size: 16px; font-weight: 700; padding: 0 16px; display: flex; align-items: center;">
          P3 DEMO · ≈ 6.5′
        </div>
        <div style="padding: 14px 16px; font-size: 14.5px; color: var(--slate-700); line-height: 1.8;">
          17 Demo Plan<br>
          18 Demo WF-01<br>
          19 Demo WF-02<br>
          20 Demo WF-03
        </div>
      </div>

      <div style="position: absolute; left: 949.4px; top: 177.6px; width: 281.3px; height: 379.2px; background: #FFF; border: 1px solid var(--slate-200); border-radius: 8px; overflow: hidden;">
        <div style="width: 100%; height: 52.8px; background: var(--accent5); color: #FFF; font-size: 16px; font-weight: 700; padding: 0 16px; display: flex; align-items: center;">
          P4 PROOF · ≈ 2.5′
        </div>
        <div style="padding: 14px 16px; font-size: 14.5px; color: var(--slate-700); line-height: 1.8;">
          21 Testing<br>
          22 Achievements<br>
          23 Limitations<br>
          24 Conclusion
        </div>
      </div>

      <!-- Time Budget Bar -->
      <div style="position: absolute; left: 48px; top: 574.1px; font-size: 12px; font-weight: 700; color: var(--muted); text-transform: uppercase;">
        NGÂN SÁCH THỜI GIAN
      </div>

      <div style="position: absolute; left: 48px; top: 600px; width: 219.8px; height: 34.6px; background: var(--accent1); color: #FFF; font-size: 12.6px; font-weight: 700; display: flex; align-items: center; justify-content: center;">
        PROBLEM 3.5′
      </div>

      <div style="position: absolute; left: 271.7px; top: 600px; width: 380.2px; height: 34.6px; background: var(--accent3); color: #FFF; font-size: 12.6px; font-weight: 700; display: flex; align-items: center; justify-content: center;">
        DESIGN 6′
      </div>

      <div style="position: absolute; left: 655.7px; top: 600px; width: 411.8px; height: 34.6px; background: var(--accent4); color: #FFF; font-size: 12.6px; font-weight: 700; display: flex; align-items: center; justify-content: center;">
        DEMO 6.5′
      </div>

      <div style="position: absolute; left: 1071.4px; top: 600px; width: 160.3px; height: 34.6px; background: var(--accent5); color: #FFF; font-size: 12.6px; font-weight: 700; display: flex; align-items: center; justify-content: center;">
        PROOF 2.5′
      </div>

      <div style="position: absolute; left: 48px; top: 641.3px; font-size: 12.6px; font-style: italic; color: var(--slate-600);">
        Chỉ có 15′? Gộp 02 với 03, 14 vào 15; đưa 12 vào phụ lục; demo 2 workflow. Sau Conclusion: 25 Phụ lục (backup).
      </div>

      <!-- Footer -->
      <div class="slide-footer-text">SOFTWARE PROJECT / PRESENTATION GUIDELINE V11</div>
      <div class="slide-page-num">G4</div>
    </section>
    """

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
    parts.append(get_html_head())
    
    # Slides G1-G4
    parts.append(get_g1_to_g4_html())
    
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
        
    total_slides = 4 + len(p1_defs) + len(p2_defs) + len(p3_p4_defs) + 1
    print(f"Successfully generated {output_path} with {total_slides} slides total!")

if __name__ == "__main__":
    main()
