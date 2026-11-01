"""Generates the app's own icon.

Run from the project root:  python scripts/generate_assets.py
Needs numpy. Writes assets/branding/icon.png and the web icons.
"""
import struct
import zlib
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent


def write_png(path, rgb):
    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    height, width, _ = rgb.shape
    raw = b"".join(b"\0" + rgb[y].tobytes() for y in range(height))
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def render_icon(size=1024, scale=2):
    """Ring with three vertical courses, gold on near-black, without alpha."""
    n = size * scale
    y, x = np.mgrid[0:n, 0:n] / n - 0.5
    radius = np.hypot(x, y)
    mask = (radius > 0.30) & (radius < 0.36)
    for course in (-0.11, 0.0, 0.11):
        bar = (np.abs(x - course) < 0.016) & (np.abs(y) < 0.17)
        cap = np.hypot(x - course, np.abs(y) - 0.17) < 0.016
        mask |= bar | cap
    background = np.array([14, 16, 20], float)
    gold = np.array([240, 169, 59], float)
    image = background + mask[..., None] * (gold - background)
    small = image.reshape(size, scale, size, scale, 3).mean(axis=(1, 3))
    return small.round().astype(np.uint8)


def main():
    (ROOT / "assets/branding").mkdir(parents=True, exist_ok=True)
    write_png(ROOT / "assets/branding/icon.png", render_icon())
    (ROOT / "web/icons").mkdir(parents=True, exist_ok=True)
    write_png(ROOT / "web/favicon.png", render_icon(32, 8))
    for size in (192, 512):
        icon = render_icon(size, 4)
        write_png(ROOT / f"web/icons/Icon-{size}.png", icon)
        # The artwork stays inside the maskable safe zone, so it can be shared.
        write_png(ROOT / f"web/icons/Icon-maskable-{size}.png", icon)


if __name__ == "__main__":
    main()
