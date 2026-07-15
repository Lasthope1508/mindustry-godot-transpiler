from __future__ import annotations

import json
from math import ceil
from pathlib import Path
from typing import Any

VIEWPORT_SIZE = {"width": 1280, "height": 720}
CAMERA_PROFILE = {
    "position_x": 1280.0,
    "position_y": 720.0,
    "zoom": 0.5,
}
TILE_SIZE = 32
SOURCE_TILE_SIZE = 8
RENDER_SCALE = 4
BACKGROUND_MARGIN_TILES = {"x": 16, "y": 9}

def _visible_world_size(viewport: dict[str, int], camera: dict[str, float]) -> dict[str, int]:
    zoom = float(camera["zoom"])
    return {
        "width_pixels": int(viewport["width"] / zoom),
        "height_pixels": int(viewport["height"] / zoom),
    }

def _world_size(visible_world: dict[str, int], tile_size: int, background_margin_tiles: dict[str, int]) -> dict[str, int]:
    return {
        "width_tiles": int(ceil(visible_world["width_pixels"] / tile_size) + background_margin_tiles["x"]),
        "height_tiles": int(ceil(visible_world["height_pixels"] / tile_size) + background_margin_tiles["y"]),
    }

def build_display_profile() -> dict[str, Any]:
    visible_world = _visible_world_size(VIEWPORT_SIZE, CAMERA_PROFILE)
    world = _world_size(visible_world, TILE_SIZE, BACKGROUND_MARGIN_TILES)
    return {
        "version": 1,
        "root_key": "playfield",
        "playfield": {
            "viewport": {
                "width": VIEWPORT_SIZE["width"],
                "height": VIEWPORT_SIZE["height"],
                "source": "godot-mindustry/project.godot display/window/size/viewport_width, display/window/size/viewport_height",
            },
            "camera": {
                "position_x": CAMERA_PROFILE["position_x"],
                "position_y": CAMERA_PROFILE["position_y"],
                "zoom": CAMERA_PROFILE["zoom"],
                "source": "camera.position = visible_world_pixels / 2, Camera2D.zoom",
            },
            "tile_size": TILE_SIZE,
            "source_tile_size": SOURCE_TILE_SIZE,
            "render_scale": RENDER_SCALE,
            "background_margin_tiles": {
                "x": BACKGROUND_MARGIN_TILES["x"],
                "y": BACKGROUND_MARGIN_TILES["y"],
            },
            "visible_world": {
                "width_pixels": visible_world["width_pixels"],
                "height_pixels": visible_world["height_pixels"],
                "formula": "viewport_pixels / camera.zoom",
            },
            "world": {
                "width_tiles": world["width_tiles"],
                "height_tiles": world["height_tiles"],
                "width_pixels": world["width_tiles"] * TILE_SIZE,
                "height_pixels": world["height_tiles"] * TILE_SIZE,
                "formula": "ceil(visible_world_pixels / tile_size) + background_margin_tiles",
            },
            "source": {
                "world_width_expr": "return tiles.width;",
                "world_height_expr": "return tiles.height;",
                "unit_width_expr": "return width()*tilesize;",
                "unit_height_expr": "return height()*tilesize;",
                "tilesize_expr": "public static final int tilesize = 8;",
                "java_sources": [
                    "core/src/mindustry/core/World.java",
                    "core/src/mindustry/Vars.java",
                ],
            },
        },
    }

def write_display_profile(output_path: Path) -> dict[str, Any]:
    profile = build_display_profile()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")
    return profile
