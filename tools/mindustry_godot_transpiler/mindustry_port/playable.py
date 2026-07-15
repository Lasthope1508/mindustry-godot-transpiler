import json
from pathlib import Path

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
BOOTSTRAP_LAYOUT = {
    "drill_cell": {"x": 7, "y": 8},
    "core_cell": {"x": 17, "y": 8},
    "duo_cell": {"x": 18, "y": 7},
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


def build_playable_manifest(asset_root: Path) -> dict:
    asset_root = Path(asset_root)
    item_id, item_path = REQUIRED_ASSETS["item"]
    blocks = {}
    for block_id, rel in REQUIRED_ASSETS["blocks"].items():
        blocks[block_id] = _asset_entry(asset_root, rel, block_id)
    return {
        "tile_size": 32,
        "item": _asset_entry(asset_root, item_path, item_id),
        "blocks": blocks,
        "bootstrap_layout": BOOTSTRAP_LAYOUT,
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
