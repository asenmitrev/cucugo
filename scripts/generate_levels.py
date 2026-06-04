#!/usr/bin/env python3
"""
Generate random 1600x900 level files for Godot fighting game.
This creates .tres resource files directly without needing Godot runtime.
"""

import os
import random
import math

# Configuration
LEVEL_WIDTH = 1600.0
LEVEL_HEIGHT = 900.0
NUM_LEVELS = 10

# Platform generation parameters
MIN_PLATFORMS = 8
MAX_PLATFORMS = 15
MIN_PLATFORM_WIDTH = 80.0
MAX_PLATFORM_WIDTH = 300.0
PLATFORM_HEIGHT = 14.0
MIN_PLATFORM_Y = 100.0
MAX_PLATFORM_Y = 700.0
GROUND_PLATFORM_Y = 850.0  # Near bottom of level

# Color palettes for different level themes
COLOR_PALETTES = [
    # Forest theme
    {
        "name": "Forest",
        "bg_top": "Color( 0.05, 0.12, 0.08, 1 )",
        "bg_bottom": "Color( 0.10, 0.20, 0.15, 1 )",
        "plat_fill": "Color( 0.25, 0.35, 0.20, 1 )",
        "plat_highlight": "Color( 0.45, 0.65, 0.35, 1 )",
        "plat_shadow": "Color( 0.15, 0.25, 0.12, 1 )",
        "plat_dark": "Color( 0, 0, 0, 0.22 )",
        "star_color": "Color( 0.8, 1.0, 0.7, 0.5 )"
    },
    # Desert theme
    {
        "name": "Desert",
        "bg_top": "Color( 0.95, 0.85, 0.65, 1 )",
        "bg_bottom": "Color( 0.85, 0.70, 0.50, 1 )",
        "plat_fill": "Color( 0.75, 0.60, 0.40, 1 )",
        "plat_highlight": "Color( 1.0, 0.90, 0.70, 1 )",
        "plat_shadow": "Color( 0.65, 0.50, 0.30, 1 )",
        "plat_dark": "Color( 0, 0, 0, 0.22 )",
        "star_color": "Color( 1.0, 0.95, 0.7, 0.5 )"
    },
    # Ocean theme
    {
        "name": "Ocean",
        "bg_top": "Color( 0.05, 0.10, 0.20, 1 )",
        "bg_bottom": "Color( 0.10, 0.20, 0.35, 1 )",
        "plat_fill": "Color( 0.20, 0.35, 0.50, 1 )",
        "plat_highlight": "Color( 0.40, 0.65, 0.85, 1 )",
        "plat_shadow": "Color( 0.15, 0.25, 0.40, 1 )",
        "plat_dark": "Color( 0, 0, 0, 0.22 )",
        "star_color": "Color( 0.7, 0.9, 1.0, 0.5 )"
    },
    # Volcano theme
    {
        "name": "Volcano",
        "bg_top": "Color( 0.15, 0.05, 0.05, 1 )",
        "bg_bottom": "Color( 0.25, 0.10, 0.08, 1 )",
        "plat_fill": "Color( 0.40, 0.15, 0.10, 1 )",
        "plat_highlight": "Color( 0.85, 0.35, 0.20, 1 )",
        "plat_shadow": "Color( 0.30, 0.10, 0.05, 1 )",
        "plat_dark": "Color( 0, 0, 0, 0.22 )",
        "star_color": "Color( 1.0, 0.5, 0.3, 0.5 )"
    },
    # Space theme
    {
        "name": "Space",
        "bg_top": "Color( 0.02, 0.02, 0.08, 1 )",
        "bg_bottom": "Color( 0.05, 0.05, 0.15, 1 )",
        "plat_fill": "Color( 0.20, 0.20, 0.35, 1 )",
        "plat_highlight": "Color( 0.45, 0.45, 0.75, 1 )",
        "plat_shadow": "Color( 0.15, 0.15, 0.25, 1 )",
        "plat_dark": "Color( 0, 0, 0, 0.22 )",
        "star_color": "Color( 0.9, 0.9, 1.0, 0.7 )"
    }
]

def random_color_component():
    """Return a random color component value formatted for Godot."""
    return round(random.uniform(0.0, 1.0), 2)

def generate_platforms(rng, num_platforms):
    """Generate random platform positions."""
    platforms = []
    
    # Always add ground platform
    platforms.append([0.0, GROUND_PLATFORM_Y, LEVEL_WIDTH, PLATFORM_HEIGHT])
    
    # Generate floating platforms
    for _ in range(num_platforms):
        platform = generate_platform(rng, platforms)
        if platform:
            platforms.append(platform)
    
    return platforms

def generate_platform(rng, existing_platforms):
    """Generate a single platform that doesn't overlap with existing ones."""
    max_attempts = 50
    for _ in range(max_attempts):
        width = rng.uniform(MIN_PLATFORM_WIDTH, MAX_PLATFORM_WIDTH)
        x = rng.uniform(50.0, LEVEL_WIDTH - width - 50.0)
        y = rng.uniform(MIN_PLATFORM_Y, MAX_PLATFORM_Y)
        
        # Check if platform overlaps with existing platforms
        overlaps = False
        for existing in existing_platforms:
            existing_x, existing_y, existing_w, existing_h = existing
            
            # Check for overlap with margin
            margin = 40.0
            if (x < existing_x + existing_w + margin and
                x + width > existing_x - margin and
                y < existing_y + existing_h + margin and
                y + PLATFORM_HEIGHT > existing_y - margin):
                overlaps = True
                break
        
        if not overlaps:
            return [x, y, width, PLATFORM_HEIGHT]
    
    # Couldn't find non-overlapping position
    return None

def platforms_to_string(platforms):
    """Convert platform list to Godot string format."""
    platform_strings = []
    for platform in platforms:
        x, y, w, h = platform
        platform_strings.append(f"{x:.1f},{y:.1f},{w:.1f},{h:.1f}")
    return "|".join(platform_strings)

def generate_level(level_num, rng):
    """Generate a single level resource."""
    palette = random.choice(COLOR_PALETTES)
    
    # Generate level name
    level_name = f"random_{level_num:02d}"
    
    # Generate start positions
    start_p1 = f"Vector2( {rng.uniform(200.0, 500.0):.1f}, {rng.uniform(200.0, 400.0):.1f} )"
    start_p2 = f"Vector2( {rng.uniform(LEVEL_WIDTH - 500.0, LEVEL_WIDTH - 200.0):.1f}, {rng.uniform(200.0, 400.0):.1f} )"
    start_p3 = f"Vector2( {rng.uniform(300.0, 600.0):.1f}, {rng.uniform(LEVEL_HEIGHT - 400.0, LEVEL_HEIGHT - 200.0):.1f} )"
    start_p4 = f"Vector2( {rng.uniform(LEVEL_WIDTH - 600.0, LEVEL_WIDTH - 300.0):.1f}, {rng.uniform(LEVEL_HEIGHT - 400.0, LEVEL_HEIGHT - 200.0):.1f} )"
    
    # Generate platforms
    num_platforms = rng.randint(MIN_PLATFORMS, MAX_PLATFORMS)
    platforms = generate_platforms(rng, num_platforms)
    platforms_str = platforms_to_string(platforms)
    
    # Generate other random values
    bg_split = round(rng.uniform(0.4, 0.7), 2)
    star_seed = rng.randint(0, 999)
    star_count = rng.randint(20, 40)
    
    # Create the .tres file content
    content = f"""[gd_resource type="Resource" load_steps=2 format=2]

[ext_resource path="res://scripts/LevelDef.gd" type="Script" id=1]

[resource]
script = ExtResource( 1 )
level_name = "{level_name}"
level_width = {LEVEL_WIDTH}
level_height = {LEVEL_HEIGHT}
scale_to_fit = true
bg_top = {palette['bg_top']}
bg_bottom = {palette['bg_bottom']}
bg_split = {bg_split}
plat_fill = {palette['plat_fill']}
plat_highlight = {palette['plat_highlight']}
plat_shadow = {palette['plat_shadow']}
plat_dark = {palette['plat_dark']}
star_seed = {star_seed}
star_color = {palette['star_color']}
star_count = {star_count}
start_p1 = {start_p1}
start_p2 = {start_p2}
start_p3 = {start_p3}
start_p4 = {start_p4}
platforms_str = "{platforms_str}"
"""
    
    return level_name, content

def main():
    print(f"Generating {NUM_LEVELS} random 1600x900 levels...")
    
    # Create levels directory if it doesn't exist
    levels_dir = os.path.join(os.path.dirname(__file__), "..", "resources", "levels")
    os.makedirs(levels_dir, exist_ok=True)
    
    # Generate levels
    for i in range(NUM_LEVELS):
        # Create a seeded RNG for reproducible results
        rng = random.Random(i * 12345)
        
        level_name, content = generate_level(i + 1, rng)
        
        # Save the level file
        file_path = os.path.join(levels_dir, f"{level_name}.tres")
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"Generated: {level_name}.tres")
    
    print(f"Done! Generated {NUM_LEVELS} levels in {levels_dir}")

if __name__ == "__main__":
    main()