#!/usr/bin/env python3
"""
Generate placeholder coach portrait images for Pocket Coach app.
Creates simple colored circles with initials for each coach and expression.
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Coach personas and their colors
COACHES = {
    'sterling': {'color': (70, 70, 70), 'initial': 'S'},    # Dark gray for drill sergeant
    'willow': {'color': (34, 139, 34), 'initial': 'W'},    # Forest green for nurturing
    'kai': {'color': (70, 130, 180), 'initial': 'K'},      # Steel blue for analytical
    'sparky': {'color': (255, 165, 0), 'initial': 'S'}     # Orange for energetic
}

EXPRESSIONS = ['default', 'happy', 'disappointed', 'surprised']

def create_placeholder_image(coach_name, expression, size=200):
    """Create a placeholder image for a coach with the given expression."""
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Get coach info
    coach_info = COACHES[coach_name]
    base_color = coach_info['color']
    initial = coach_info['initial']
    
    # Adjust color based on expression
    if expression == 'happy':
        # Brighter version
        color = tuple(min(255, int(c * 1.3)) for c in base_color)
    elif expression == 'disappointed':
        # Darker version
        color = tuple(int(c * 0.7) for c in base_color)
    elif expression == 'surprised':
        # Add some yellow tint
        color = (base_color[0] + 20, base_color[1] + 20, min(255, base_color[2] + 40))
    else:  # default
        color = base_color
    
    # Add alpha channel
    color = color + (255,)
    
    # Draw circle
    margin = 10
    circle_bounds = [margin, margin, size - margin, size - margin]
    draw.ellipse(circle_bounds, fill=color)
    
    # Add border
    border_color = (255, 255, 255, 200)
    draw.ellipse(circle_bounds, outline=border_color, width=3)
    
    # Try to use a font, fallback to default if not available
    try:
        font_size = size // 3
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        try:
            font = ImageFont.load_default()
        except:
            font = None
    
    # Draw initial
    if font:
        # Get text bounding box
        bbox = draw.textbbox((0, 0), initial, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Center the text
        text_x = (size - text_width) // 2
        text_y = (size - text_height) // 2
        
        # Draw text with shadow for better visibility
        shadow_offset = 2
        draw.text((text_x + shadow_offset, text_y + shadow_offset), initial, 
                 fill=(0, 0, 0, 128), font=font)
        draw.text((text_x, text_y), initial, fill=(255, 255, 255, 255), font=font)
    
    # Add expression indicator
    if expression != 'default':
        # Small dot in corner to indicate expression
        dot_size = size // 10
        dot_x = size - dot_size - 5
        dot_y = 5
        
        dot_colors = {
            'happy': (0, 255, 0, 255),      # Green
            'disappointed': (255, 0, 0, 255),  # Red
            'surprised': (255, 255, 0, 255)    # Yellow
        }
        
        if expression in dot_colors:
            draw.ellipse([dot_x, dot_y, dot_x + dot_size, dot_y + dot_size], 
                        fill=dot_colors[expression])
    
    return img

def main():
    # Create assets directory
    assets_dir = 'assets/images'
    os.makedirs(assets_dir, exist_ok=True)
    
    # Generate all combinations
    for coach_name in COACHES.keys():
        for expression in EXPRESSIONS:
            filename = f"{coach_name}_{expression}.png"
            filepath = os.path.join(assets_dir, filename)
            
            print(f"Generating {filename}...")
            
            img = create_placeholder_image(coach_name, expression)
            img.save(filepath, 'PNG')
    
    print(f"\nGenerated {len(COACHES) * len(EXPRESSIONS)} placeholder images in {assets_dir}/")
    print("\nImages created:")
    for coach_name in COACHES.keys():
        for expression in EXPRESSIONS:
            print(f"  - {coach_name}_{expression}.png")

if __name__ == "__main__":
    main()