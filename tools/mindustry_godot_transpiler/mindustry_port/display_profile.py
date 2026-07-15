from __future__ import annotations

import json
from math import ceil
from pathlib import Path
from typing import Any

DEFAULT_PROJECT_SETTINGS_PATH = Path("godot-mindustry/project.godot")
CAMERA_PROFILE = {
    "zoom": 0.5,
    "min_zoom": 0.5,
    "max_zoom": 6.0,
}
TILE_SIZE = 32
SOURCE_TILE_SIZE = 8
RENDER_SCALE = 4
BACKGROUND_MARGIN_VIEWPORTS = {"x": 1.0, "y": 1.0}
VIEWPORT_WIDTH_KEY = "window/size/viewport_width"
VIEWPORT_HEIGHT_KEY = "window/size/viewport_height"

def _project_viewport_size(project_settings_path: Path) -> dict[str, int]:
    section = ""
    display_settings: dict[str, str] = {}
    for raw_line in project_settings_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith(";"):
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if section != "display" or "=" not in line:
            continue
        key, value = line.split("=", 1)
        display_settings[key.strip()] = value.strip().strip('"')
    return {
        "width": int(display_settings[VIEWPORT_WIDTH_KEY]),
        "height": int(display_settings[VIEWPORT_HEIGHT_KEY]),
    }

def _visible_world_size(viewport: dict[str, int], camera: dict[str, float]) -> dict[str, int]:
    zoom = float(camera["zoom"])
    return {
        "width_pixels": int(viewport["width"] / zoom),
        "height_pixels": int(viewport["height"] / zoom),
    }

def _background_margin_tiles(visible_world: dict[str, int], tile_size: int, margin_viewports: dict[str, float]) -> dict[str, int]:
    return {
        "x": int(ceil((visible_world["width_pixels"] / tile_size) * margin_viewports["x"])),
        "y": int(ceil((visible_world["height_pixels"] / tile_size) * margin_viewports["y"])),
    }

def _world_size(visible_world: dict[str, int], tile_size: int, background_margin_tiles: dict[str, int]) -> dict[str, int]:
    width_tiles = int(ceil(visible_world["width_pixels"] / tile_size) + background_margin_tiles["x"])
    height_tiles = int(ceil(visible_world["height_pixels"] / tile_size) + background_margin_tiles["y"])
    return {
        "width_tiles": width_tiles,
        "height_tiles": height_tiles,
        "width_pixels": width_tiles * tile_size,
        "height_pixels": height_tiles * tile_size,
    }

def _camera_profile(world: dict[str, int]) -> dict[str, float]:
    return {
        "position_x": float(world["width_pixels"] / 2.0),
        "position_y": float(world["height_pixels"] / 2.0),
        "zoom": CAMERA_PROFILE["zoom"],
        "min_zoom": CAMERA_PROFILE["min_zoom"],
        "max_zoom": CAMERA_PROFILE["max_zoom"],
    }

def build_display_profile(project_settings_path: Path | str = DEFAULT_PROJECT_SETTINGS_PATH) -> dict[str, Any]:
    project_settings = Path(project_settings_path)
    viewport = _project_viewport_size(project_settings)
    visible_world = _visible_world_size(viewport, CAMERA_PROFILE)
    background_margin_tiles = _background_margin_tiles(visible_world, TILE_SIZE, BACKGROUND_MARGIN_VIEWPORTS)
    world = _world_size(visible_world, TILE_SIZE, background_margin_tiles)
    camera = _camera_profile(world)
    return {
        "version": 1,
        "root_key": "playfield",
        "playfield": {
            "viewport": {
                "width": viewport["width"],
                "height": viewport["height"],
                "source": f"{project_settings.as_posix()} display/{VIEWPORT_WIDTH_KEY}, display/{VIEWPORT_HEIGHT_KEY}",
            },
            "camera": {
                "position_x": camera["position_x"],
                "position_y": camera["position_y"],
                "zoom": camera["zoom"],
                "min_zoom": camera["min_zoom"],
                "max_zoom": camera["max_zoom"],
                "source": "camera.position = world_pixels / 2, Camera2D.zoom",
            },
            "tile_size": TILE_SIZE,
            "source_tile_size": SOURCE_TILE_SIZE,
            "render_scale": RENDER_SCALE,
            "background_margin_viewports": {
                "x": BACKGROUND_MARGIN_VIEWPORTS["x"],
                "y": BACKGROUND_MARGIN_VIEWPORTS["y"],
            },
            "background_margin_tiles": {
                "x": background_margin_tiles["x"],
                "y": background_margin_tiles["y"],
            },
            "visible_world": {
                "width_pixels": visible_world["width_pixels"],
                "height_pixels": visible_world["height_pixels"],
                "formula": "viewport_pixels / camera.zoom",
            },
            "world": {
                "width_tiles": world["width_tiles"],
                "height_tiles": world["height_tiles"],
                "width_pixels": world["width_pixels"],
                "height_pixels": world["height_pixels"],
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

def write_display_profile(output_path: Path, project_settings_path: Path | str = DEFAULT_PROJECT_SETTINGS_PATH) -> dict[str, Any]:
    profile = build_display_profile(project_settings_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")
    return profile
