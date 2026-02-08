#!/usr/bin/env python3
"""Export GDS/DEF to PNG. klayout -z -nc -rx -rd in_file=X -rd out_file=Y -rd tech_file=Z -rm gds_to_png.py"""
import pya
import os

try:
    in_file
except NameError:
    in_file = None
try:
    out_file
except NameError:
    out_file = None
try:
    tech_file
except NameError:
    tech_file = ""
try:
    w_px = int(width)
except NameError:
    w_px = 1600

if not in_file or not os.path.exists(str(in_file)):
    print("Error: -rd in_file=path/to/6_final.gds required")
    pya.Application.instance().exit(1)
if not out_file:
    print("Error: -rd out_file=chip.png required")
    pya.Application.instance().exit(1)

layout = pya.Layout()
opts = pya.LoadLayoutOptions()
if tech_file and os.path.exists(str(tech_file)):
    tech = pya.Technology()
    tech.load(str(tech_file))
    opts = tech.load_layout_options

layout.read(str(in_file), opts)
view = pya.LayoutView()
view.show_layout(layout, True)
top = layout.top_cell()
bbox = top.dbbox()
w = min(w_px, 4000)
h = int(w * bbox.height() / bbox.width()) if bbox.width() > 0 else w
h = min(h, 4000)
view.save_image_with_options(str(out_file), w, h, 0, 0, 0, bbox, False)
print("[INFO] Saved plot to " + str(out_file))
pya.Application.instance().exit(0)
