#!/usr/bin/env python3
"""
Render a PNG preview from a hardcoded assembly-style BYTE table.

This script contains the bytemap embedded (edit the ASM_BLOCK if you want to try a different block),
maps palette indices to RGBA colors (default rock-style palette), renders preview.png and an
upscaled preview_4x.png for easier viewing.

Requirements:
  pip install pillow

Run:
  python render_bitmap_preview_hardcoded.py
"""

import re
from PIL import Image
from pathlib import Path

# Image settings (match header in the ASM block)
WIDTH = 32
HEIGHT = 61
SCALE = 4
OUT_BASE = "preview"

# Hardcoded ASM-style BYTE block (paste your full block here).
# I used the rock0 snippet you provided above — if you'd like the original cactus bytes instead,
# replace asm_block with that full text.
ASM_BLOCK = r"""
rock0 DINOGAMEBITMAP <32, 61, 255,, offset rock0 + sizeof rock0>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,049h,000h,000h
	BYTE 000h,049h,049h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,049h,06dh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,06dh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,0dbh,000h,000h,06dh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,049h,0ffh,0ffh
	BYTE 0ffh,0ffh,06dh,000h,049h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0xdbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,000h,0dbh,0ffh
	BYTE 0ffh,000h,000h,000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0xdbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,000h,0ffh,0ffh
	BYTE 0ffh,000h,000h,000h,000h,000h,000h,049h,0ffh,0ffh,0ffh,0xdbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,000h,0ffh,0ffh
	BYTE 0ffh,000h,000h,000h,000h,000h,000h,049h,0ffh,0ffh,0ffh,0xdbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,000h,0ffh,0ffh
	BYTE 0ffh,000h,000h,000h,000h,000h,000h,049h,0ffh,0ffh,0ffh,0xdbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,049h,0ffh,0ffh
	BYTE 0ffh,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0xdbh,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,000h,049h,0xdbh
	BYTE 0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0xffh,0xdbh,0xdbh,0xdbh,0xdbh
	BYTE 0xdbh,0xdbh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
"""

# Default palette (rock-friendly). Edit to match your game's palette indices.
PALETTE = {
    0xFF: (0, 0, 0, 0),          # 0FFh -> transparent
    0x00: (0, 0, 0, 255),
    0x24: (34, 139, 34, 255),    # kept in case any green remains
    0x49: (128, 128, 128, 255),  # mid gray (rock midtone)
    0x6D: (80, 80, 80, 255),     # dark gray (shadow)
    0x92: (170, 170, 170, 255),  # light gray
    0xB6: (100, 60, 20, 255),    # brown-ish
    0xDB: (220, 220, 220, 255),  # highlight
}
FALLBACK = (150, 150, 150, 255)

def parse_tokens_from_asm(asm_text):
    # find tokens like 0ffh, 049h, 0b6h (hex digits followed by 'h')
    tokens = re.findall(r'\b([0-9A-Fa-f]+)h\b', asm_text)
    values = [int(t, 16) for t in tokens]
    return values

def build_image(values, width, height, palette, fallback, out_base="preview", scale=4):
    expected = width * height
    if len(values) < expected:
        print(f"Warning: parsed {len(values)} values but expected {expected} (width*height).")
        print("Padding with transparent (0xFF) to fill the image so a preview can be generated.")
        values = values + [0xFF] * (expected - len(values))
    elif len(values) > expected:
        print(f"Warning: parsed {len(values)} values but expected {expected} (width*height). Extra values will be ignored.")
        values = values[:expected]

    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    px = img.load()
    for y in range(height):
        for x in range(width):
            v = values[y * width + x]
            color = palette.get(v, fallback)
            px[x, y] = color

    p = Path(f"{out_base}.png")
    img.save(p)
    up = img.resize((width * scale, height * scale), Image.NEAREST)
    up_path = Path(f"{out_base}_{scale}x.png")
    up.save(up_path)
    print(f"Saved: {p.resolve()}")
    print(f"Saved (upscaled x{scale}): {up_path.resolve()}")

def main():
    values = parse_tokens_from_asm(ASM_BLOCK)
    print(f"Parsed {len(values)} hex values from the hardcoded ASM block.")
    build_image(values, WIDTH, HEIGHT, PALETTE, FALLBACK, out_base=OUT_BASE, scale=SCALE)

if __name__ == "__main__":
    main()