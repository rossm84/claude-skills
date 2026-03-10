---
name: excel-report-generation
description: Use when generating Excel reports, spreadsheets, or workbooks with openpyxl. Use when the user wants styled multi-sheet exports, color-coded data, freeze panes, merged cells, or professional formatting. Use when creating .xlsx files from Python.
---

# Excel Report Generation with openpyxl

## Overview

Build professional multi-sheet Excel workbooks with color-coding, freeze panes, row striping, and merged header sections. Uses openpyxl — the standard Python library for .xlsx files.

## Setup

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side, numbers
from openpyxl.utils import get_column_letter
```

## Style Factory Pattern

Define reusable style functions instead of creating styles inline:

```python
# Color palette (define once, use everywhere)
BRAND_GREEN = "1DB954"
DARK_BG = "191414"
WHITE = "FFFFFF"
LIGHT_GREY = "F5F5F5"
MID_GREY = "E0E0E0"
RED = "C62828"
AMBER = "E65100"
GREEN = "2E7D32"

def header_style():
    return {
        "font": Font(bold=True, color=WHITE, size=10, name="Calibri"),
        "fill": PatternFill(start_color=BRAND_GREEN, end_color=BRAND_GREEN, fill_type="solid"),
        "alignment": Alignment(horizontal="center", vertical="center", wrap_text=True),
        "border": Border(bottom=Side(style="medium", color=BRAND_GREEN)),
    }

def apply_header(ws, row=1):
    hs = header_style()
    for cell in ws[row]:
        cell.font = hs["font"]
        cell.fill = hs["fill"]
        cell.alignment = hs["alignment"]
        cell.border = hs["border"]
    ws.row_dimensions[row].height = 28
```

## Common Operations

### Column Widths

```python
def set_col_widths(ws, widths):
    for i, w in enumerate(widths, 1):
        ws.column_dimensions[get_column_letter(i)].width = w

set_col_widths(ws, [8, 40, 15, 20, 12, 50])
```

### Row Striping

```python
def stripe_rows(ws, start_row, end_row, num_cols, wrap_cols=None):
    wrap_cols = wrap_cols or []
    for r in range(start_row, end_row + 1):
        is_odd = (r - start_row) % 2 == 1
        for c in range(1, num_cols + 1):
            cell = ws.cell(r, c)
            cell.border = Border(bottom=Side(style="thin", color=MID_GREY))
            cell.alignment = Alignment(vertical="top", wrap_text=(c in wrap_cols))
            if is_odd:
                cell.fill = PatternFill(start_color=LIGHT_GREY, end_color=LIGHT_GREY, fill_type="solid")
```

### Conditional Color Coding

```python
def color_cell(cell, bg, text_color=None):
    cell.fill = PatternFill(start_color=bg, end_color=bg, fill_type="solid")
    if text_color:
        cell.font = Font(color=text_color, bold=True, size=10, name="Calibri")

# Usage: color by sentiment
SENTIMENT_COLORS = {
    "positive": ("E8F5E9", "2E7D32"),  # (bg, text)
    "negative": ("FFEBEE", "C62828"),
    "neutral":  ("E3F2FD", "1565C0"),
}
bg, fg = SENTIMENT_COLORS.get(sentiment, ("FFFFFF", "000000"))
color_cell(cell, bg, fg)
```

### Freeze Panes

```python
ws.freeze_panes = "A2"      # Freeze header row
ws.freeze_panes = "B2"      # Freeze header + first column
ws.freeze_panes = "C3"      # Freeze first 2 rows + 2 columns
```

### Merged Title Rows

```python
ws.merge_cells("A1:F1")
title_cell = ws.cell(1, 1, "Report Title")
title_cell.font = Font(bold=True, color=WHITE, size=14)
title_cell.fill = PatternFill(start_color=DARK_BG, fill_type="solid")
title_cell.alignment = Alignment(horizontal="center", vertical="center")
ws.row_dimensions[1].height = 36
```

## Multi-Sheet Workbook Pattern

```python
wb = Workbook()

# Sheet 1: Summary (rename default sheet)
ws_summary = wb.active
ws_summary.title = "Summary"
# ... populate summary

# Sheet 2: Details
ws_detail = wb.create_sheet("Details")
ws_detail.append(["ID", "Title", "Status", "Date"])
apply_header(ws_detail)
for item in data:
    ws_detail.append([item["id"], item["title"], item["status"], item["date"]])
stripe_rows(ws_detail, 2, len(data) + 1, 4, wrap_cols=[2])
set_col_widths(ws_detail, [10, 50, 15, 15])
ws_detail.freeze_panes = "A2"

# Save
wb.save("/path/to/report.xlsx")
```

## Quick Reference

| Task | Code |
|------|------|
| New workbook | `wb = Workbook()` |
| Add sheet | `ws = wb.create_sheet("Name")` |
| Rename default | `wb.active.title = "Name"` |
| Write row | `ws.append([val1, val2, ...])` |
| Write cell | `ws.cell(row, col, value)` |
| Merge cells | `ws.merge_cells("A1:D1")` |
| Column width | `ws.column_dimensions["A"].width = 20` |
| Row height | `ws.row_dimensions[1].height = 30` |
| Freeze | `ws.freeze_panes = "A2"` |
| Auto-filter | `ws.auto_filter.ref = ws.dimensions` |
| Number format | `cell.number_format = '#,##0'` |
| Save | `wb.save("file.xlsx")` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Styling cells before writing data | Write data first, then apply styles |
| Using `ws["A1"]` for iteration | Use `ws.cell(row, col)` in loops — faster |
| Forgetting `fill_type="solid"` | `PatternFill` requires `fill_type="solid"` to render |
| Colors as `#RRGGBB` | openpyxl uses `RRGGBB` without the `#` |
| Not setting wrap_text on long columns | `Alignment(wrap_text=True)` prevents truncation |
| Applying styles to merged cell range | Style only the top-left cell of a merge |
