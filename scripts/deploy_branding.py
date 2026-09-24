r"""
Deploy official BANDHU logo (updated single source of truth) across all project locations.
Master asset: C:\Users\gmune\.gemini\antigravity-ide\brain\7e2f7de6-81cc-418c-bf89-f8abd62f016d\.user_uploaded\media_1790265759364.png
"""
import os
from PIL import Image

OFFICIAL_SOURCE = r"C:\Users\gmune\.gemini\antigravity-ide\brain\7e2f7de6-81cc-418c-bf89-f8abd62f016d\.user_uploaded\media_1790265759364.png"
ROOT_DIR = r"c:\Users\gmune\OneDrive\Desktop\DEMO"

raw_img = Image.open(OFFICIAL_SOURCE).convert("RGBA")
print(f"Loaded master official logo: {raw_img.size}")

# Warm cream background color
BG_COLOR = (249, 245, 235, 255)

# 1. High-resolution square canvas for master bandhu_logo.png
sq_logo = Image.new("RGBA", (1024, 1024), BG_COLOR)
scale = min(960 / raw_img.width, 960 / raw_img.height)
new_w = int(raw_img.width * scale)
new_h = int(raw_img.height * scale)
resized_raw = raw_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
paste_x = (1024 - new_w) // 2
paste_y = (1024 - new_h) // 2
sq_logo.paste(resized_raw, (paste_x, paste_y), resized_raw)

# 2. Square Emblem crop (top heart emblem)
emblem_box = (103, 16, 583, 496) # 480x480 square crop
emblem_crop = raw_img.crop(emblem_box)
# Place emblem in clean 512x512 canvas with uniform bg
emblem_sq = Image.new("RGBA", (512, 512), BG_COLOR)
emblem_resized = emblem_crop.resize((480, 480), Image.Resampling.LANCZOS)
emblem_sq.paste(emblem_resized, (16, 16), emblem_resized)

# Target directories
dirs = [
    os.path.join(ROOT_DIR, "assets", "branding"),
    os.path.join(ROOT_DIR, "apps", "patient_app", "assets", "branding"),
    os.path.join(ROOT_DIR, "apps", "caregiver_dashboard", "public", "assets", "branding"),
    os.path.join(ROOT_DIR, "apps", "patient_app", "web", "icons"),
]

for d in dirs:
    os.makedirs(d, exist_ok=True)

# Save master bandhu_logo.png and bandhu_emblem.png
for d in [
    os.path.join(ROOT_DIR, "assets", "branding"),
    os.path.join(ROOT_DIR, "apps", "patient_app", "assets", "branding"),
    os.path.join(ROOT_DIR, "apps", "caregiver_dashboard", "public", "assets", "branding"),
]:
    logo_dest = os.path.join(d, "bandhu_logo.png")
    sq_logo.save(logo_dest, format="PNG", optimize=True)
    print(f"Saved master logo: {logo_dest}")

    emblem_dest = os.path.join(d, "bandhu_emblem.png")
    emblem_sq.save(emblem_dest, format="PNG", optimize=True)
    print(f"Saved emblem: {emblem_dest}")

# Favicons
cg_public = os.path.join(ROOT_DIR, "apps", "caregiver_dashboard", "public")
emblem_sq.resize((64, 64), Image.Resampling.LANCZOS).save(os.path.join(cg_public, "favicon.png"), format="PNG")
emblem_sq.resize((32, 32), Image.Resampling.LANCZOS).save(os.path.join(cg_public, "favicon.ico"), format="ICO")
print("Saved caregiver dashboard favicons")

web_dir = os.path.join(ROOT_DIR, "apps", "patient_app", "web")
emblem_sq.resize((64, 64), Image.Resampling.LANCZOS).save(os.path.join(web_dir, "favicon.png"), format="PNG")

# PWA icons
icons_dir = os.path.join(web_dir, "icons")
emblem_sq.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(icons_dir, "Icon-192.png"), format="PNG")
emblem_sq.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(icons_dir, "Icon-512.png"), format="PNG")
emblem_sq.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(icons_dir, "Icon-maskable-192.png"), format="PNG")
emblem_sq.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(icons_dir, "Icon-maskable-512.png"), format="PNG")
print("Saved patient app web icons")

# Android launcher icons
android_res = os.path.join(ROOT_DIR, "apps", "patient_app", "android", "app", "src", "main", "res")
android_mipmaps = {
    "mipmap-mdpi": (48, 48),
    "mipmap-hdpi": (72, 72),
    "mipmap-xhdpi": (96, 96),
    "mipmap-xxhdpi": (144, 144),
    "mipmap-xxxhdpi": (192, 192),
}

for folder, size in android_mipmaps.items():
    target_folder = os.path.join(android_res, folder)
    if os.path.exists(target_folder):
        icon_path = os.path.join(target_folder, "ic_launcher.png")
        emblem_sq.resize(size, Image.Resampling.LANCZOS).save(icon_path, format="PNG")
        print(f"Saved Android launcher icon: {icon_path} ({size[0]}x{size[1]})")

print("\nOfficial BANDHU branding assets deployment complete!")
