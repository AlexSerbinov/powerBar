#!/bin/bash

# Create simple PowerBar icon using built-in macOS tools

# Create iconset directory
mkdir -p PowerBar.iconset

# Create a simple lightning bolt icon using sf symbols (if available)
# Or create a text-based icon

# Function to create icon with SF Symbols
create_sf_icon() {
    local size=$1
    local output=$2
    
    # Use sf symbols to create lightning bolt icon
    python3 -c "
import os
from pathlib import Path

# Simple text-based icon creation using ASCII
def create_text_icon(size, output):
    # Create a simple SVG with lightning bolt
    svg_content = '''<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<svg width=\"{size}\" height=\"{size}\" viewBox=\"0 0 {size} {size}\" xmlns=\"http://www.w3.org/2000/svg\">
  <defs>
    <style>
      .bg {{ fill: #2d2d30; rx: {radius}; }}
      .bolt {{ fill: #ffd700; }}
      .text {{ fill: white; font-family: Arial, sans-serif; font-size: {font_size}px; text-anchor: middle; }}
    </style>
  </defs>
  <rect class=\"bg\" width=\"{size}\" height=\"{size}\" />
  <polygon class=\"bolt\" points=\"{bolt_points}\" />
  <text class=\"text\" x=\"{size_half}\" y=\"{text_y}\">PowerBar</text>
</svg>'''.format(
        size=size,
        radius=size//8,
        font_size=size//12,
        size_half=size//2,
        text_y=size*0.85,
        bolt_points=f'{size*0.45},{size*0.2} {size*0.3},{size*0.45} {size*0.55},{size*0.45} {size*0.25},{size*0.7} {size*0.7},{size*0.55} {size*0.4},{size*0.55}'
    )
    
    # Write SVG file
    with open('temp_icon.svg', 'w') as f:
        f.write(svg_content)
    
    # Convert SVG to PNG using built-in tools (if available)
    os.system(f'qlmanage -t -s {size} -o . temp_icon.svg 2>/dev/null')
    if os.path.exists('temp_icon.svg.png'):
        os.rename('temp_icon.svg.png', output)
        os.remove('temp_icon.svg')
        return True
    
    # Fallback: try with sips or other tools
    os.system(f'convert temp_icon.svg -resize {size}x{size} {output} 2>/dev/null')
    os.remove('temp_icon.svg')
    return os.path.exists(output)

# Icon sizes
sizes = [
    (16, 'icon_16x16.png'),
    (32, 'icon_16x16@2x.png'),
    (32, 'icon_32x32.png'),
    (64, 'icon_32x32@2x.png'),
    (128, 'icon_128x128.png'),
    (256, 'icon_128x128@2x.png'),
    (256, 'icon_256x256.png'),
    (512, 'icon_256x256@2x.png'),
    (512, 'icon_512x512.png'),
    (1024, 'icon_512x512@2x.png'),
]

success = False
for size, filename in sizes:
    if create_text_icon(size, f'PowerBar.iconset/{filename}'):
        print(f'Created {filename} ({size}x{size})')
        success = True
    else:
        print(f'Failed to create {filename}')

if success:
    print('\\nIconset created! Run: iconutil -c icns PowerBar.iconset')
else:
    print('Failed to create icons. Try installing ImageMagick or use manual creation.')
"
}

# Try to create icons
create_sf_icon

# If that fails, create a simple fallback
if [ ! -d "PowerBar.iconset" ] || [ -z "$(ls -A PowerBar.iconset)" ]; then
    echo "Creating simple fallback icons..."
    mkdir -p PowerBar.iconset
    
    # Create a simple colored square as fallback
    for size in 16 32 64 128 256 512 1024; do
        # Use a simple approach with ImageMagick if available
        if command -v convert >/dev/null 2>&1; then
            convert -size ${size}x${size} xc:"#2d2d30" -fill "#ffd700" \
                -pointsize $((size/8)) -gravity center \
                -annotate +0+0 "⚡" PowerBar.iconset/temp_${size}.png 2>/dev/null
        fi
    done
    
    # Rename to proper iconset names
    [ -f "PowerBar.iconset/temp_16.png" ] && mv "PowerBar.iconset/temp_16.png" "PowerBar.iconset/icon_16x16.png"
    [ -f "PowerBar.iconset/temp_32.png" ] && mv "PowerBar.iconset/temp_32.png" "PowerBar.iconset/icon_16x16@2x.png"
    [ -f "PowerBar.iconset/temp_32.png" ] && cp "PowerBar.iconset/icon_16x16@2x.png" "PowerBar.iconset/icon_32x32.png"
    [ -f "PowerBar.iconset/temp_64.png" ] && mv "PowerBar.iconset/temp_64.png" "PowerBar.iconset/icon_32x32@2x.png"
    [ -f "PowerBar.iconset/temp_128.png" ] && mv "PowerBar.iconset/temp_128.png" "PowerBar.iconset/icon_128x128.png"
    [ -f "PowerBar.iconset/temp_256.png" ] && mv "PowerBar.iconset/temp_256.png" "PowerBar.iconset/icon_128x128@2x.png"
    [ -f "PowerBar.iconset/temp_256.png" ] && cp "PowerBar.iconset/icon_128x128@2x.png" "PowerBar.iconset/icon_256x256.png"
    [ -f "PowerBar.iconset/temp_512.png" ] && mv "PowerBar.iconset/temp_512.png" "PowerBar.iconset/icon_256x256@2x.png"
    [ -f "PowerBar.iconset/temp_512.png" ] && cp "PowerBar.iconset/icon_256x256@2x.png" "PowerBar.iconset/icon_512x512.png"
    [ -f "PowerBar.iconset/temp_1024.png" ] && mv "PowerBar.iconset/temp_1024.png" "PowerBar.iconset/icon_512x512@2x.png"
fi

# Create .icns file
if [ -d "PowerBar.iconset" ] && [ -n "$(ls -A PowerBar.iconset)" ]; then
    echo "Converting to .icns format..."
    iconutil -c icns PowerBar.iconset
    
    if [ -f "PowerBar.icns" ]; then
        echo "✅ Successfully created PowerBar.icns"
        echo "Icon file is ready for use in Info.plist"
    else
        echo "❌ Failed to create .icns file"
    fi
else
    echo "❌ No icons were created"
fi 