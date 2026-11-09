# Palette grade for racecondition.software. Builds a 33^3 .cube LUT from one
# grading function and applies that same function to an image, so that a photo
# picks up the site's sage, teal, deep green, and cream (see css/style.css).
# Requires numpy and Pillow.
#
#   python3 scripts/palette_grade.py in.jpg out.jpg scripts/racecondition_palette.cube
#
# The .cube file is the same grade as a standard 3D LUT, usable in Final Cut Pro
# or ffmpeg (-vf lut3d=file=scripts/racecondition_palette.cube:interp=tetrahedral).
# First used for img/houseRules/banyan-drone.jpg (November 2026).
import sys, numpy as np
from PIL import Image

def hx(h): return np.array([int(h[i:i+2], 16) for i in (1, 3, 5)]) / 255.0
SHADOW, TEAL, SAGE, ROSE, CREAM = (hx(c) for c in ('#1A2422', '#4A5C58', '#A8BFA0', '#C8899A', '#F5F3EF'))

def rgb2hsv(c):
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    mx, mn = c.max(-1), c.min(-1); d = mx - mn
    h = np.zeros_like(mx); s = np.where(mx > 0, d / np.maximum(mx, 1e-9), 0)
    m = d > 1e-9
    rr = m & (mx == r); gg = m & (mx == g) & ~rr; bb = m & ~rr & ~gg
    h[rr] = ((g - b)[rr] / d[rr]) % 6
    h[gg] = (b - r)[gg] / d[gg] + 2
    h[bb] = (r - g)[bb] / d[bb] + 4
    return np.stack([h * 60.0, s, mx], -1)

def hsv2rgb(c):
    h, s, v = c[..., 0] % 360 / 60.0, c[..., 1], c[..., 2]
    i = np.floor(h).astype(int) % 6; f = h - np.floor(h)
    p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    out = np.choose(i[..., None] * np.ones(3, int),
                    [np.stack(x, -1) for x in ((v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q))])
    return out

def pull(h, lo, hi, target, amt):
    m = (h >= lo) & (h <= hi)
    w = np.where(m, np.clip(np.sin(np.pi * (h - lo) / (hi - lo)), 0, 1) ** 0.5, 0)  # feathered band
    return h + (target - h) * amt * w

def grade(rgb):
    hsv = rgb2hsv(rgb)
    h, s, v = hsv[..., 0], hsv[..., 1], hsv[..., 2]
    h = pull(h, 45, 150, 100, 0.55)    # foliage and lawn toward sage (~104 deg)
    h = pull(h, 150, 235, 168, 0.60)   # water, pool, and blue glass toward teal (~168 deg)
    cool = np.clip(np.sin(np.pi * np.clip((hsv[..., 0] - 150) / 85, 0, 1)), 0, 1)
    s = s * (0.70 - 0.22 * cool)        # the site's teal is muted, so quiet cyan and blue most
    s = np.where(s > 0.45, 0.45 + (s - 0.45) * 0.5, s)  # tame the loudest colors
    out = hsv2rgb(np.stack([h, s, v], -1))
    lum = out @ np.array([0.2126, 0.7152, 0.0722])
    lo = np.clip(1 - lum / 0.45, 0, 1)[..., None] ** 1.5
    hi = np.clip((lum - 0.65) / 0.35, 0, 1)[..., None]
    out = out * (1 - 0.35 * lo) + SHADOW * 0.35 * lo          # shadows into the site's deep green
    out = out * (1 - 0.38 * hi) + CREAM * 0.38 * hi           # highlights into its cream
    mid = np.exp(-((lum - 0.55) / 0.15) ** 2)[..., None]
    out = out * (1 - 0.04 * mid) + ROSE * 0.04 * mid          # a trace of the rose accent
    return np.clip(out, 0, 1)

if __name__ == '__main__':
    N = 33
    g = np.linspace(0, 1, N)
    b_, g_, r_ = np.meshgrid(g, g, g, indexing='ij')          # .cube order: red varies fastest
    lut = grade(np.stack([r_, g_, b_], -1).reshape(-1, 3))
    with open(sys.argv[3], 'w') as f:
        f.write('TITLE "Race Condition palette"\nLUT_3D_SIZE 33\n')
        for c in lut: f.write(f'{c[0]:.6f} {c[1]:.6f} {c[2]:.6f}\n')
    im = np.asarray(Image.open(sys.argv[1]).convert('RGB')) / 255.0
    Image.fromarray((grade(im) * 255 + 0.5).astype('uint8')).save(sys.argv[2], quality=90)
