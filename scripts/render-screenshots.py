#!/usr/bin/env python3
"""Render PNG screenshots for README from scan logs and Wireshark notes."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SCANS = ROOT / "scans"
OUT = ROOT / "screenshots"
TARGET = "127.0.0.1"


def load_font(size: int):
    for name in ("DejaVuSansMono.ttf", "LiberationMono-Regular.ttf", "UbuntuMono-R.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def render_text(path: Path, lines: list[str], title: str) -> None:
    font = load_font(13)
    line_h = 17
    pad = 16
    width = min(max((font.getlength(line) for line in lines), default=400) + pad * 2, 1200)
    height = pad * 2 + line_h * (len(lines) + 1)
    img = Image.new("RGB", (int(width), height), (30, 30, 30))
    draw = ImageDraw.Draw(img)
    draw.text((pad, pad), title, fill=(100, 200, 255), font=font)
    y = pad + line_h
    for line in lines:
        draw.text((pad, y), line, fill=(220, 220, 220), font=font)
        y += line_h
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def read_scan(name: str) -> list[str]:
    lines = []
    for ln in (SCANS / name).read_text(encoding="utf-8").splitlines():
        if not ln or ln.startswith("#"):
            continue
        if ln.startswith("SF-Port"):
            break
        lines.append(ln)
    return lines


def main() -> None:
    task1 = read_scan("task1-sV.txt")
    render_text(OUT / "task1-nmap-sV.png", task1, f"$ nmap -sV --reason {TARGET}")

    render_text(
        OUT / "task2-wireshark-syn.png",
        read_scan("wireshark-syn.txt"),
        f"Wireshark — SYN scan (pcap/task2-syn.pcap)",
    )
    render_text(
        OUT / "task2-wireshark-fin.png",
        read_scan("wireshark-fin.txt"),
        f"Wireshark — FIN scan (pcap/task2-fin.pcap)",
    )
    render_text(
        OUT / "task2-wireshark-udp.png",
        read_scan("wireshark-udp.txt"),
        f"Wireshark — UDP scan (pcap/task2-udp.pcap)",
    )

    render_text(
        OUT / "task2-nmap-syn.png",
        read_scan("task2-syn.txt"),
        f"$ nmap -sS -p ... {TARGET}",
    )


if __name__ == "__main__":
    main()
