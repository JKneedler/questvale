#!/usr/bin/env python3
"""Pixel-exact recolor tool for images/ui/ theme assets.

Two modes:
  derive  - given an old Main/Light/Dark triple and a new Main color, suggest
            new Light/Dark Accent shades by preserving the old HSL
            lightness/saturation offset from Main across the hue change.
  apply   - substitute exact RGB pixel values across one or more PNGs,
            leaving transparent and drop-shadow pixels untouched.
"""
import argparse
import colorsys
from pathlib import Path

from PIL import Image

SKIP_PIXELS = {(0, 0, 0, 0), (0, 0, 0, 52)}


def hex_to_rgb(h):
    h = h.strip().lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return '{:02x}{:02x}{:02x}'.format(*rgb)


def rgb_to_hls(rgb):
    r, g, b = (c / 255 for c in rgb)
    return colorsys.rgb_to_hls(r, g, b)


def hls_to_rgb(hls):
    r, g, b = colorsys.hls_to_rgb(*hls)
    return tuple(round(clamp(c) * 255) for c in (r, g, b))


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


def derive(args):
    old_main = hex_to_rgb(args.old_main)
    old_light = hex_to_rgb(args.old_light)
    old_dark = hex_to_rgb(args.old_dark)
    new_main = hex_to_rgb(args.new_main)

    h_main, l_main, s_main = rgb_to_hls(old_main)
    h_new, l_new, s_new = rgb_to_hls(new_main)

    def offset_from_main(old_accent):
        _, l_a, s_a = rgb_to_hls(old_accent)
        l_off = l_a - l_main
        s_off = s_a - s_main
        return hls_to_rgb((h_new, l_new + l_off, s_new + s_off))

    new_light = offset_from_main(old_light)
    new_dark = offset_from_main(old_dark)

    print(f"New Main:  #{rgb_to_hex(new_main)}")
    print(f"New Light: #{rgb_to_hex(new_light)}  (offset from old Light #{args.old_light})")
    print(f"New Dark:  #{rgb_to_hex(new_dark)}  (offset from old Dark #{args.old_dark})")


def iter_target_files(args):
    if args.files:
        return [Path(f) for f in args.files.split(',')]
    root = Path(args.dir)
    files = []
    for p in root.rglob('*.png'):
        if not args.include_icons and 'icons' in p.parts:
            continue
        files.append(p)
    return sorted(files)


def apply(args):
    pairs = []
    for pair in args.pair:
        old_hex, new_hex = pair.split(':')
        pairs.append((hex_to_rgb(old_hex), hex_to_rgb(new_hex)))

    files = iter_target_files(args)
    if not files:
        print("No files matched.")
        return

    total_changed = 0
    for path in files:
        im = Image.open(path).convert('RGBA')
        pixels = im.load()
        w, h = im.size
        changed = 0
        for y in range(h):
            for x in range(w):
                px = pixels[x, y]
                if px in SKIP_PIXELS:
                    continue
                rgb, alpha = px[:3], px[3]
                for old_rgb, new_rgb in pairs:
                    if rgb == old_rgb:
                        pixels[x, y] = (*new_rgb, alpha)
                        changed += 1
                        break
        suffix = " (dry-run, not written)" if args.dry_run else ""
        if changed:
            print(f"{path}: {changed} pixel(s) changed{suffix}")
            total_changed += changed
            if not args.dry_run:
                im.save(path)
        else:
            print(f"{path}: no matching pixels")

    note = " DRY RUN — nothing written." if args.dry_run else ""
    print(f"\nTotal: {total_changed} pixel(s) across {len(files)} file(s).{note}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='mode', required=True)

    d = sub.add_parser('derive', help='Suggest new Light/Dark Accent shades for a new Main color.')
    d.add_argument('--old-main', required=True)
    d.add_argument('--old-light', required=True)
    d.add_argument('--old-dark', required=True)
    d.add_argument('--new-main', required=True)
    d.set_defaults(func=derive)

    a = sub.add_parser('apply', help='Apply exact pixel-color substitutions to PNG(s).')
    a.add_argument('--pair', action='append', required=True, help='OLDHEX:NEWHEX, repeatable')
    a.add_argument('--dir', help='Recursively scan this directory for .png files')
    a.add_argument('--files', help='Comma-separated explicit file list')
    a.add_argument('--include-icons', action='store_true', help='Also scan images/ui/icons/ (excluded by default)')
    a.add_argument('--dry-run', action='store_true')
    a.set_defaults(func=apply)

    args = parser.parse_args()
    if args.mode == 'apply' and not args.dir and not args.files:
        parser.error('apply requires --dir or --files')
    args.func(args)


if __name__ == '__main__':
    main()
