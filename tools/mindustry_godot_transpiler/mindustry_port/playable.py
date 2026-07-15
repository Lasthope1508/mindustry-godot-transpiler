import json
from pathlib import Path

from mindustry_port.display_profile import build_display_profile

REQUIRED_ASSETS = {
    "item": ("copper", "core/assets-raw/sprites/items/item-copper.png"),
    "blocks": {
        "core_shard": "core/assets-raw/sprites/blocks/storage/core-shard.png",
        "mechanical_drill": "core/assets-raw/sprites/blocks/drills/mechanical-drill.png",
        "conveyor": "core/assets-raw/sprites/blocks/distribution/conveyors/conveyor-0-0.png",
        "ore_copper": "core/assets-raw/sprites/blocks/environment/ore-copper1.png",
        "stone_floor": "core/assets-raw/sprites/blocks/environment/stone1.png",
    },
}
PINNED_BUILD_BLOCK_IDS = ["conveyor", "router", "junction", "mechanical-drill", "duo", "copper-wall"]
BOOTSTRAP_BLOCKS = {
    "conveyor_block": "conveyor",
    "core_block": "core-shard",
    "drill_block": "mechanical-drill",
    "turret_block": "duo",
}
BOOTSTRAP_LAYOUT_OFFSETS = {
    "drill_cell": {"x": -5, "y": 0},
    "core_cell": {"x": 5, "y": 0},
    "duo_cell": {"x": 6, "y": -1},
}
BOOTSTRAP_TERRAIN = {
    "floor_block": "stone_floor",
    "ore_patch_offsets": {
        "x_from": -2,
        "x_to": 1,
        "y_from": -2,
        "y_to": 3,
    },
}
BOOTSTRAP_TRANSPORT = {
    "item_sprite_count": 3,
}


def _asset_entry(asset_root: Path, relative_path: str, asset_id: str) -> dict:
    path = asset_root / relative_path
    if not path.exists():
        raise FileNotFoundError(f"missing playable asset: {relative_path}")
    return {
        "id": asset_id,
        "source": relative_path,
        "texture": "res://assets/" + relative_path.replace("\\", "/"),
    }


def _centered_cell(center_x: int, center_y: int, offset: dict) -> dict:
    return {
        "x": center_x + int(offset["x"]),
        "y": center_y + int(offset["y"]),
    }

def _bootstrap_layout(playfield: dict) -> dict:
    world = playfield["world"]
    center_x = int(world["width_tiles"]) // 2
    center_y = int(world["height_tiles"]) // 2
    return {
        name: _centered_cell(center_x, center_y, offset)
        for name, offset in BOOTSTRAP_LAYOUT_OFFSETS.items()
    }

def _bootstrap_terrain(layout: dict) -> dict:
    drill_cell = layout["drill_cell"]
    offsets = BOOTSTRAP_TERRAIN["ore_patch_offsets"]
    return {
        "floor_block": "stone_floor",
        "ore_patches": [
            {
                "item": "copper",
                "ore_block": "ore_copper",
                "x_from": drill_cell["x"] + int(offsets["x_from"]),
                "x_to": drill_cell["x"] + int(offsets["x_to"]),
                "y_from": drill_cell["y"] + int(offsets["y_from"]),
                "y_to": drill_cell["y"] + int(offsets["y_to"]),
            }
        ],
    }

def build_playable_manifest(asset_root: Path) -> dict:
    asset_root = Path(asset_root)
    item_id, item_path = REQUIRED_ASSETS["item"]
    blocks = {}
    for block_id, rel in REQUIRED_ASSETS["blocks"].items():
        blocks[block_id] = _asset_entry(asset_root, rel, block_id)
    display_profile = build_display_profile()["playfield"]
    bootstrap_layout = _bootstrap_layout(display_profile)
    return {
        "tile_size": 32,
        "item": _asset_entry(asset_root, item_path, item_id),
        "blocks": blocks,
        "bootstrap_blocks": BOOTSTRAP_BLOCKS,
        "bootstrap_layout": bootstrap_layout,
        "bootstrap_terrain": _bootstrap_terrain(bootstrap_layout),
        "bootstrap_transport": BOOTSTRAP_TRANSPORT,
        "build_palette": {
            "pinned_block_ids": PINNED_BUILD_BLOCK_IDS,
        },
        "skin_overrides": {},
    }


def write_playable_manifest(asset_root: Path, output_path: Path) -> dict:
    manifest = build_playable_manifest(asset_root)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(manifest, indent=2, sort_keys=True), encoding="utf-8")
    return manifest
