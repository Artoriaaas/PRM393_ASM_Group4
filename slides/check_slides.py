import re

with open('slides/index.html', 'r', encoding='utf-8') as f:
    text = f.read()

tags = re.findall(r'<section class="slide[^"]*" id="([^"]+)" data-page-id="([^"]+)">', text)
print(f"Total slides found: {len(tags)}")
for i, t in enumerate(tags):
    print(f"{i+1:02d}: id={t[0]:15s} data-page-id={t[1]}")

