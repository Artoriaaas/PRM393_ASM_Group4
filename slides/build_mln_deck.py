# -*- coding: utf-8 -*-
"""
build_mln_deck.py
Assembles all slide components and generates slides/index.html
"""

import sys
import os

from generate_mln_slides import get_head_css, get_tail_js
from mln_slides_p1 import get_p1_slides
from mln_slides_p2 import get_p2_slides
from mln_slides_p3_p4 import get_p3_p4_slides

def main():
    p1 = get_p1_slides()
    p2 = get_p2_slides()
    p3_p4 = get_p3_p4_slides()

    all_slides = p1 + p2 + p3_p4
    total = len(all_slides)
    print(f"Total slides to assemble: {total} (P1: {len(p1)}, P2: {len(p2)}, P3+P4: {len(p3_p4)})")

    head = get_head_css()
    tail = get_tail_js(total)

    full_html = head + "\n".join(all_slides) + tail

    out_path = "slides/index.html"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(full_html)

    size = os.path.getsize(out_path)
    print(f"Generated {out_path} successfully. Size: {size:,} bytes.")

if __name__ == "__main__":
    main()
