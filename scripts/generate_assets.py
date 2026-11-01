"""Generates the app's own sounds and icon. Nothing comes from another app.

Run from the project root:  python scripts/generate_assets.py
Needs numpy. Writes assets/audio/*.wav and assets/branding/icon.png.
"""
import struct
import wave
import zlib
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
RATE = 44100
SECONDS = 3.0
NOTES = {"so": 45, "la": 47, "thi": 49, "do": 50, "re": 52, "mi": 54, "fa": 55}


def pluck(hz, rng, decay=0.996):
    """Karplus-Strong string with a fractional delay for accurate tuning."""
    period = RATE / hz - 0.5  # the two-point average adds half a sample of delay
    delay = int(period)
    frac = period - delay
    allpass = (1 - frac) / (1 + frac)
    line = rng.uniform(-1, 1, delay)
    line -= line.mean()
    out = np.zeros(int(RATE * SECONDS))
    last_in = last_out = prev = 0.0
    for i in range(out.size):
        sample = line[i % delay]
        out[i] = sample
        averaged = 0.5 * (sample + prev) * decay
        prev = sample
        tuned = allpass * averaged + last_in - allpass * last_out
        last_in, last_out = averaged, tuned
        line[i % delay] = tuned
    return out


def render_note(midi, rng):
    hz = 440 * 2 ** ((midi - 69) / 12)
    # A double course: two strings, very slightly apart, for a natural beat.
    signal = pluck(hz * 2 ** (-1.5 / 1200), rng) + pluck(hz * 2 ** (1.5 / 1200), rng)
    fade = int(RATE * 0.25)
    signal[-fade:] *= np.linspace(1, 0, fade)
    return signal / np.abs(signal).max() * 0.85


def write_wav(path, signal):
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes((signal * 32767).astype("<i2").tobytes())


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
    (ROOT / "assets/audio").mkdir(parents=True, exist_ok=True)
    (ROOT / "assets/branding").mkdir(parents=True, exist_ok=True)
    rng = np.random.default_rng(20261101)
    for name, midi in NOTES.items():
        write_wav(ROOT / f"assets/audio/{name}.wav", render_note(midi, rng))
    write_png(ROOT / "assets/branding/icon.png", render_icon())


if __name__ == "__main__":
    main()
