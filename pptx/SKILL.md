---
name: pptx
description: Use when creating, editing, or reading PowerPoint presentations (.pptx files). Covers python-pptx for creation, PptxGenJS for HTML-to-slides, and raw OOXML editing. Use for deck building, slide generation, or presentation analysis.
---

# PowerPoint Presentations

## Dependencies
- `python-pptx` (installed): Python library for creating/reading .pptx
- `pptxgenjs` (install with `npm install pptxgenjs` if needed): Node.js library for HTML-to-PPTX
- Spotify brand: primary #1DB954, bg #121212, fg #FFFFFF, accent #1ED760

## Reading a presentation

```python
from pptx import Presentation
prs = Presentation('deck.pptx')
for i, slide in enumerate(prs.slides):
    print(f"Slide {i+1}:")
    for shape in slide.shapes:
        if shape.has_text_frame:
            print(f"  {shape.text}")
        if shape.has_table:
            for row in shape.table.rows:
                print("  | " + " | ".join(cell.text for cell in row.cells) + " |")
```

## Creating a presentation (python-pptx)

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.chart import XL_CHART_TYPE

prs = Presentation()
prs.slide_width = Inches(13.333)  # 16:9
prs.slide_height = Inches(7.5)

# Title slide
slide = prs.slides.add_slide(prs.slide_layouts[6])  # blank layout
txBox = slide.shapes.add_textbox(Inches(1), Inches(2.5), Inches(11), Inches(2))
tf = txBox.text_frame
p = tf.paragraphs[0]
p.text = "Presentation Title"
p.font.size = Pt(44)
p.font.bold = True
p.font.color.rgb = RGBColor(0x1D, 0xB9, 0x54)
p.alignment = PP_ALIGN.CENTER

# Content slide with bullets
slide = prs.slides.add_slide(prs.slide_layouts[6])
txBox = slide.shapes.add_textbox(Inches(1), Inches(1.5), Inches(11), Inches(5))
tf = txBox.text_frame
tf.word_wrap = True
for item in ["First point", "Second point", "Third point"]:
    p = tf.add_paragraph()
    p.text = item
    p.font.size = Pt(24)
    p.level = 0

# Table
slide = prs.slides.add_slide(prs.slide_layouts[6])
table = slide.shapes.add_table(3, 4, Inches(1), Inches(1.5), Inches(11), Inches(4)).table
table.cell(0, 0).text = "Header 1"
table.cell(0, 1).text = "Header 2"
# Style header row
for col in range(4):
    cell = table.cell(0, col)
    cell.fill.solid()
    cell.fill.fore_color.rgb = RGBColor(0x1D, 0xB9, 0x54)
    for p in cell.text_frame.paragraphs:
        p.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        p.font.bold = True

# Chart
from pptx.chart.data import CategoryChartData
chart_data = CategoryChartData()
chart_data.categories = ['Q1', 'Q2', 'Q3', 'Q4']
chart_data.add_series('Revenue', (4500, 5500, 6200, 7100))
chart = slide.shapes.add_chart(
    XL_CHART_TYPE.COLUMN_CLUSTERED,
    Inches(1), Inches(1.5), Inches(11), Inches(5),
    chart_data
).chart

# Save
prs.save('/mnt/c/Users/RossMiller/Desktop/output.pptx')
```

## Key patterns

### Background color
```python
from pptx.oxml.ns import qn
bg = slide.background
fill = bg.fill
fill.solid()
fill.fore_color.rgb = RGBColor(0x12, 0x12, 0x12)
```

### Images
```python
slide.shapes.add_picture('image.png', Inches(1), Inches(1), Inches(4), Inches(3))
```

### Speaker notes
```python
notes_slide = slide.notes_slide
notes_slide.notes_text_frame.text = "Speaker notes here"
```

### Slide numbers
```python
from pptx.oxml.ns import qn
sp = slide.shapes.add_textbox(Inches(12), Inches(7), Inches(1), Inches(0.4))
sp.text_frame.paragraphs[0].text = str(slide_num)
```

## Output
Always save to `/mnt/c/Users/RossMiller/Desktop/` so it's accessible in Windows.

## Design principles
- Spotify green (#1DB954) for accents, dark backgrounds (#121212 or #191414)
- Web-safe fonts: Arial, Helvetica, Verdana
- Max 6 bullets per slide, max 8 words per bullet
- Strong contrast: white text on dark, or dark text on light
- One key message per slide
