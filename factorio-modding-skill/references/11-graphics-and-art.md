# Factorio Graphics & Art Style Guide (AI-Generation Reference)

This guide provides precise instructions, style rules, and AI prompt templates for generating Factorio-compatible mod assets. It covers items, entities, technologies, terrain tiles, and user interface elements, ensuring they match the unique, gritty industrial dieselpunk aesthetic of Factorio.

---

## 🎨 The Factorio Art Style Rules

To match the official game style, generated graphics must adhere to these four pillars:

1. **Industrial Realism & Dieselpunk**:
   * **Subject Matter**: Heavy machinery, thick pipes, brass gears, rusty rivets, structural steel frames, and analogue dials.
   * **Surface Wear**: Metal is rarely pristine. Add rust, soot, scratch marks, weathering, grease, and dirt overlays.
   * **Technology Level**: Mid-20th-century industrial revolution mixed with futuristic, functional automation. No "sleek, clean sci-fi."

2. **Contrast & Color Palette**:
   * **Base Tones**: Slate gray, dark iron, oxidized copper green, rusted orange, muddy brown, industrial yellow, and raw concrete.
   * **Accent Highlights**: Neon green (uranium/bioflux), glowing purple (electromagnetic/molten metals), vivid orange/red (lava/steam vents).
   * **Value Range**: High contrast. Deep ambient occlusion shadows in crevices and sharp specular highlights on metallic edges.

3. **Lighting & Shadows**:
   * **Sun/Light Angle**: Coming from the **top-left** (diagonal downward-right).
   * **Shadows**: Rendered as a separate layer or baked into the sprite. Shadows are dark, soft-edged, extending toward the **bottom-right**.
   * **Ambient Occlusion**: Essential for giving heavy, grounded weight to ground-placed machines.

4. **Projection & Perspective**:
   * **Isometric/Orthographic Projection**: Entities use an orthographic parallel projection with a slightly tilted camera (not true 3D perspective to prevent vanishing points).
   * **Orientation**: Entities must be aligned to the grid. 4-way structures need North, East, South, and West sprites. 8-way structures (like the flamethrower turret) need intermediate diagonal orientations.

---

## 🚀 Prompt Templates for AI Image Generators (Midjourney, Stable Diffusion, DALL-E)

Use these carefully crafted prompts to generate high-quality Factorio-style graphics assets.

### 1. Item Icons (64x64 px)
Item icons should be clean, highly legible, and centered, with no background.

* **Prompt Template**:
  > `A 2D game icon of [ITEM_NAME], isolated on a pure black background. Factorio game style, dieselpunk aesthetic, high contrast, industrial realism, rusted copper and oxidized iron, sharp metallic edges, dramatic top-left lighting, detailed textures, volumetric shading, high fidelity, 8k resolution, photorealistic asset --no background, shadows`
* **Example (Quantum Processor)**:
  > `A 2D game icon of a glowing purple quantum microchip processor, isolated on a pure black background. Factorio game style, heavy industrial copper pipes, brass circuit tracks, glowing violet resistors, rusted steel casing, sharp metallic edges, top-left lighting, volumetric shading --no background, reflections`

### 2. Entity Sprites (Placements on the Ground)
Entity sprites are placed on surfaces. They need a heavy, grounded base and should be rendered in isometric or orthographic view.

* **Prompt Template**:
  > `A heavy industrial [MACHINE_TYPE] machine, isometric view, orthographic game asset. Factorio game style, dieselpunk, retro-futuristic, thick steel frames, complex gear networks, greasy mechanical pistons, copper pipes with valves, dark soot and rust detailing, grounded on raw industrial concrete floor, top-left sunlight, sharp details, photorealistic texture --no background, humans, characters`
* **Example (Bio-Chemical Refiner)**:
  > `A heavy industrial bio-chemical refinery vessel, isometric view, orthographic game asset. Factorio style, weathered cast-iron tank, leaking green sludge, thick brass valves, steel reinforcement bands, heavy rivets, steam venting from chimneys, top-left lighting, photorealistic textures --no background, characters`

### 3. Technology Icons (256x256 px)
Technology icons represent research cards. They are highly illustrative, featuring blueprint-like lines or dramatic, conceptual lighting.

* **Prompt Template**:
  > `An illustrative technology research card for [TECH_NAME]. Factorio game style, high-contrast digital illustration, dramatic industrial lighting, technical blueprints superimposed on a dark metallic background, glowing holographic wires, mechanical schematic overlays, retro-futuristic, cinematic atmosphere, 4k`
* **Example (Advanced Space Travel)**:
  > `An illustrative technology research card for interplanetary rocketry. Factorio game style, high-contrast, a heavy steel rocket engine booster emitting fiery orange exhaust, technical white schematic lines overlaid, dark starfield background, dramatic metallic sheen, cinematic lighting, 4k`

### 4. Terrain Tiles (Seamless 32x32 px up to 128x128 px)
Terrain tiles must be completely seamless and support tiling without obvious repetitive patterns.

* **Prompt Template**:
  > `A seamless, top-down texture of [TERRAIN_TYPE], tileable game asset. Factorio style, gritty industrial, photorealistic natural texture, high-detail soil structures, noise variation, organic weathering, diffuse lighting, no shadows, no seams, flat 2D texture`
* **Example (Volcanic Ash Sand)**:
  > `A seamless, top-down texture of dark basalt volcanic ash sand, tileable game asset. Factorio style, gritty, tiny obsidian crystal fragments, organic cracks in dry lava crust, dark gray and deep charcoal tones, diffuse lighting, seamless tiling, flat texture`

---

## 🛠️ Post-Processing and Asset Preparation

AI-generated images require technical processing to work perfectly in Factorio:

### 1. Transparency & Alpha Channels
* Remove any generated backgrounds.
* Save icons and sprites as `.png` with a transparent alpha channel.
* For glowing elements (light-emissive parts), create a separate **glow mask** `.png` (white on transparent black). Reference it in the prototype:
  ```lua
  working_visualisations = {
    {
      fade_out_input_multiplier = true,
      apply_recipe_tint = "primary",
      animation = {
        filename = "__my-mod__/graphics/entity/machine-glow.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        draw_as_glow = true, -- Enables emissive light glow
      }
    }
  }
  ```

### 2. Sprite Sheet Packing
* To create seamless animations (e.g., rotating gears, bubbling fluids), pack individual animation frames into a single sprite sheet.
* Specify `frame_count`, `line_length`, and `animation_speed` in the prototype.
* Example sprite-sheet definition:
  ```lua
  animation = {
    filename = "__my-mod__/graphics/entity/my-machine-sheet.png",
    width = 64,
    height = 64,
    frame_count = 16,
    line_length = 4, -- 4 frames per row
    shift = {0, 0},
    animation_speed = 0.5,
  }
  ```

### 3. Mask-Based Color Tinting
* If you want your entity or item to dynamically change colors (e.g., based on the fluid inside, or recipe chosen):
  1. Generate a grayscale mask where **white** represents the area to be tinted, and **transparent black** represents untinted regions.
  2. Define `apply_runtime_tint = true` in the prototype.
  3. Specify the tint colors inside the prototype or let the engine dynamically fetch it from the recipe tint.

---

## 📋 Checklist for AI Artists & Modders

1. [ ] **Sun Direction**: Is the light source coming from the **top-left**?
2. [ ] **Color Contrast**: Are there dark crevices and sharp metallic highlights?
3. [ ] **Weathering**: Did you prompt for rust, soot, weathering, and grease?
4. [ ] **Scale**: Are items exactly 64x64 px (or 128x128 px for high-res icons)?
5. [ ] **Orientation**: Is the entity aligned to a parallel orthographic/isometric grid?
6. [ ] **Separation**: Are shadows on a separate layer/image if transparency over other terrains is required?
