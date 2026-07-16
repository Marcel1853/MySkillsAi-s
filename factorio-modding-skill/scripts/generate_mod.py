#!/usr/bin/env python3
"""
Factorio 2.1 Mod Skeleton Generator

Generates a complete, properly structured mod directory.
Only info.json is technically required by Factorio, but this
generates a best-practice layout with all recommended files.

Usage: python3 generate_mod.py <mod_name> <title> [dependencies]
Example: python3 generate_mod.py my-mod "My Mod" "base >= 2.1,+ space-age"
"""

import json
import os
import sys


def generate_mod(mod_name, title, dependencies=None):
    """Generate a complete Factorio 2.1 mod structure."""

    if dependencies is None:
        dependencies = ["base >= 2.1"]

    mod_dir = mod_name

    # --- Create directory structure ---
    for d in [
        f"{mod_dir}/prototypes/space-age",
        f"{mod_dir}/locale/en",
        f"{mod_dir}/locale/de",
        f"{mod_dir}/migrations",
        f"{mod_dir}/graphics/icons",
        f"{mod_dir}/graphics/entity",
        f"{mod_dir}/graphics/technology",
    ]:
        os.makedirs(d, exist_ok=True)

    # --- info.json ---
    info = {
        "name": mod_name,
        "version": "0.1.0",
        "title": title,
        "author": "Your Name",
        "factorio_version": "2.1",
        "dependencies": dependencies,
        "description": f"A Factorio 2.1 mod: {title}",
    }
    with open(f"{mod_dir}/info.json", "w") as f:
        json.dump(info, f, indent=2)
        f.write("\n")

    # --- changelog.txt ---
    with open(f"{mod_dir}/changelog.txt", "w") as f:
        f.write(
            "---------------------------------------------------------------------------------------------------\n"
            f"Version: 0.1.0\n"
            f"Date: 2026-06-24\n"
            f"  Features:\n"
            f"    - Initial release for Factorio 2.1\n"
            f"---------------------------------------------------------------------------------------------------\n"
        )

    # --- settings.lua ---
    with open(f"{mod_dir}/settings.lua", "w") as f:
        f.write(
            f"-- settings.lua for {mod_name}\n"
            f"-- Define mod configuration options here.\n"
            f"-- Factorio loads this file automatically during the settings stage.\n\n"
            f"data:extend({{\n"
            f"  {{\n"
            f'    type = "bool-setting",\n'
            f'    name = "{mod_name}-enabled",\n'
            f'    setting_type = "startup",\n'
            f"    default_value = true,\n"
            f'    order = "a",\n'
            f"  }},\n"
            f"}})\n"
        )

    # --- data.lua ---
    # IMPORTANT: Factorio loads data.lua automatically during the prototype stage.
    # Do NOT require("settings") here — settings.lua is already loaded by Factorio
    # in the preceding settings stage.
    with open(f"{mod_dir}/data.lua", "w") as f:
        f.write(
            f"-- data.lua for {mod_name}\n"
            f"-- Entry point for prototype definitions.\n"
            f"-- Factorio loads this file automatically during the prototype stage.\n"
            f"-- Split prototypes into separate files for maintainability.\n\n"
            f'-- Core prototypes\n'
            f'require("__{mod_name}__.prototypes.items")\n'
            f'require("__{mod_name}__.prototypes.recipes")\n'
            f'require("__{mod_name}__.prototypes.entities")\n'
            f'require("__{mod_name}__.prototypes.technologies")\n\n'
            f'-- Space Age prototypes (only if the mod is active)\n'
            f'if mods["space-age"] then\n'
            f'  require("__{mod_name}__.prototypes.space-age.planets")\n'
            f'  require("__{mod_name}__.prototypes.space-age.asteroids")\n'
            f'end\n'
        )

    # --- data-updates.lua ---
    with open(f"{mod_dir}/data-updates.lua", "w") as f:
        f.write(
            f"-- data-updates.lua for {mod_name}\n"
            f"-- Modify existing prototypes (from base game or other mods) here.\n\n"
        )

    # --- data-final-fixes.lua ---
    with open(f"{mod_dir}/data-final-fixes.lua", "w") as f:
        f.write(
            f"-- data-final-fixes.lua for {mod_name}\n"
            f"-- Final prototype corrections after all mods have loaded.\n\n"
        )

    # --- control.lua ---
    with open(f"{mod_dir}/control.lua", "w") as f:
        f.write(
            f"-- control.lua for {mod_name}\n"
            f"-- Runtime scripting: event handlers, GUI, circuit logic.\n\n"
            f"-- Initialize storage (runs once when mod is first added to a save)\n"
            f"script.on_init(function()\n"
            f"  storage.{mod_name.replace('-', '_')} = storage.{mod_name.replace('-', '_')} or {{\n"
            f"    enabled = true,\n"
            f'    version = "0.1.0",\n'
            f"  }}\n"
            f'  log("[{mod_name}] Mod initialized!")\n'
            f"end)\n\n"
            f"-- Re-setup metatables or conditional handlers (runs on every save load)\n"
            f"script.on_load(function()\n"
            f"  -- Do NOT access `game` or write to `storage` here.\n"
            f"  -- Only re-register closures or rebuild metatables.\n"
            f"end)\n\n"
            f"-- Handle mod updates on existing saves\n"
            f"script.on_configuration_changed(function(event)\n"
            f"  if event.mod_changes[\"{mod_name}\"] then\n"
            f'    log("[{mod_name}] Configuration changed")\n'
            f"  end\n"
            f"end)\n\n"
            f"-- Example event handler\n"
            f"script.on_event(defines.events.on_player_joined_game, function(event)\n"
            f"  local player = game.get_player(event.player_index)\n"
            f"  if player then\n"
            f'    player.print("Welcome to {title}!")\n'
            f"  end\n"
            f"end)\n"
        )

    # --- Prototype stub files ---
    # Note: RecipePrototype::category was removed in 2.1, so we use categories instead
    for proto_file, content in [
        ("prototypes/items.lua", f"-- Items for {mod_name}\ndata:extend({{\n}})\n"),
        (
            "prototypes/recipes.lua",
            f"-- Recipes for {mod_name}\n-- Note: In 2.1, RecipePrototype::category was removed; use categories instead.\ndata:extend({{\n}})\n",
        ),
        ("prototypes/entities.lua", f"-- Entities for {mod_name}\ndata:extend({{\n}})\n"),
        (
            "prototypes/technologies.lua",
            f"-- Technologies for {mod_name}\ndata:extend({{\n}})\n",
        ),
        (
            "prototypes/space-age/planets.lua",
            f"-- Space Age planets for {mod_name}\n-- Only loaded when space-age mod is active\ndata:extend({{\n}})\n",
        ),
        (
            "prototypes/space-age/asteroids.lua",
            f"-- Space Age asteroids for {mod_name}\ndata:extend({{\n}})\n",
        ),
    ]:
        with open(f"{mod_dir}/{proto_file}", "w") as f:
            f.write(content)

    # --- English locale ---
    mod_id = mod_name.replace("-", "_")
    with open(f"{mod_dir}/locale/en/{mod_name}.cfg", "w") as f:
        f.write(
            f"[mod-name]\n{mod_name}={title}\n\n"
            f"[mod-description]\n{mod_name}=A Factorio 2.1 mod: {title}\n\n"
            f"[item-name]\n{mod_id}-item={title} Item\n\n"
            f"[item-description]\n{mod_id}-item=An item from {title}.\n\n"
            f"[entity-name]\n{mod_id}-entity={title} Entity\n\n"
            f"[recipe-name]\n{mod_id}-recipe={title} Recipe\n\n"
            f"[technology-name]\n{mod_id}-tech={title} Technology\n"
        )

    # --- German locale ---
    with open(f"{mod_dir}/locale/de/{mod_name}.cfg", "w") as f:
        f.write(
            f"[mod-name]\n{mod_name}={title}\n\n"
            f"[mod-description]\n{mod_name}=Ein Factorio 2.1 Mod: {title}\n\n"
            f"[item-name]\n{mod_id}-item={title} Item\n\n"
            f"[item-description]\n{mod_id}-item=Ein Item aus {title}.\n\n"
            f"[entity-name]\n{mod_id}-entity={title} Entity\n\n"
            f"[recipe-name]\n{mod_id}-recipe={title} Rezept\n\n"
            f"[technology-name]\n{mod_id}-tech={title} Technologie\n"
        )

    # --- Summary ---
    print(f"Generated mod '{mod_name}' in directory: {mod_dir}/")
    print(f"  - info.json")
    print(f"  - changelog.txt")
    print(f"  - settings.lua")
    print(f"  - data.lua (with require() stubs)")
    print(f"  - data-updates.lua")
    print(f"  - data-final-fixes.lua")
    print(f"  - control.lua")
    print(f"  - prototypes/items.lua")
    print(f"  - prototypes/recipes.lua (Updated for 2.1 categories)")
    print(f"  - prototypes/entities.lua")
    print(f"  - prototypes/technologies.lua")
    print(f"  - prototypes/space-age/planets.lua")
    print(f"  - prototypes/space-age/asteroids.lua")
    print(f"  - locale/en/{mod_name}.cfg")
    print(f"  - locale/de/{mod_name}.cfg")
    print(f"  - migrations/")
    print(f"  - graphics/icons/, entity/, technology/")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <mod_name> <title> [dep1,dep2,...]")
        sys.exit(1)

    mod_name = sys.argv[1]
    title = sys.argv[2]
    deps = sys.argv[3].split(",") if len(sys.argv) > 3 else None

    generate_mod(mod_name, title, deps)
