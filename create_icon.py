#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFont
import tempfile

def create_app_icon():
    """Create PowerBar app icon with lightning bolt"""
    
    # Create a 1024x1024 image for high resolution
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create rounded rectangle background
    corner_radius = size // 8
    
    # Draw dark background with rounded corners
    draw.rounded_rectangle(
        [(corner_radius//2, corner_radius//2), (size - corner_radius//2, size - corner_radius//2)],
        radius=corner_radius,
        fill=(45, 45, 48, 255),  # Dark gray
        outline=None
    )
    
    # Lightning bolt parameters
    bolt_width = size // 3
    bolt_height = size // 2.5
    bolt_x = (size - bolt_width) // 2
    bolt_y = size // 4
    
    # Lightning bolt shape (simplified)
    lightning_points = [
        (bolt_x + bolt_width * 0.4, bolt_y),  # Top
        (bolt_x + bolt_width * 0.1, bolt_y + bolt_height * 0.4),
        (bolt_x + bolt_width * 0.5, bolt_y + bolt_height * 0.4),
        (bolt_x, bolt_y + bolt_height),  # Bottom left
        (bolt_x + bolt_width * 0.6, bolt_y + bolt_height * 0.6),
        (bolt_x + bolt_width * 0.2, bolt_y + bolt_height * 0.6),
        (bolt_x + bolt_width * 0.4, bolt_y)  # Back to top
    ]
    
    # Draw lightning bolt with gradient effect
    draw.polygon(lightning_points, fill=(255, 215, 0, 255), outline=None)  # Gold color
    
    # Add text "PowerBar" at bottom
    try:
        font_size = size // 12
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        font = ImageFont.load_default()
    
    text = "PowerBar"
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    
    text_x = (size - text_width) // 2
    text_y = size - size // 4
    
    draw.text((text_x, text_y), text, fill=(255, 255, 255, 255), font=font)
    
    return img

def create_iconset():
    """Create .iconset directory with all required icon sizes"""
    
    # Create base icon
    base_icon = create_app_icon()
    
    # Icon sizes required for macOS
    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]
    
    # Create iconset directory
    iconset_dir = "PowerBar.iconset"
    os.makedirs(iconset_dir, exist_ok=True)
    
    # Generate all icon sizes
    for size, filename in sizes:
        resized_icon = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized_icon.save(os.path.join(iconset_dir, filename))
        print(f"Created {filename} ({size}x{size})")
    
    print(f"\nIconset created in {iconset_dir}/")
    print("To create .icns file, run:")
    print(f"iconutil -c icns {iconset_dir}")
    
    return iconset_dir

if __name__ == "__main__":
    try:
        create_iconset()
    except ImportError:
        print("PIL (Pillow) is required. Install with: pip install Pillow")
    except Exception as e:
        print(f"Error creating icon: {e}") 