import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.playable import build_playable_manifest


class PlayableManifestTests(unittest.TestCase):
    def test_manifest_requires_source_asset_paths(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            assets = root / "assets"
            required = [
                "core/assets-raw/sprites/items/item-copper.png",
                "core/assets-raw/sprites/blocks/environment/ore-copper1.png",
                "core/assets-raw/sprites/blocks/environment/stone1.png",
                "core/assets-raw/sprites/blocks/drills/mechanical-drill.png",
                "core/assets-raw/sprites/blocks/distribution/conveyors/conveyor-0-0.png",
                "core/assets-raw/sprites/blocks/storage/core-shard.png",
            ]
            for rel in required:
                path = assets / rel
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"asset")

            manifest = build_playable_manifest(assets)

        self.assertEqual(manifest["item"]["id"], "copper")
        self.assertEqual(set(manifest["blocks"].keys()), {"core_shard", "mechanical_drill", "conveyor", "ore_copper", "stone_floor"})
        for entry in [manifest["item"], *manifest["blocks"].values()]:
            self.assertTrue(entry["texture"].startswith("res://assets/"))

    def test_port_game_hud_reads_generated_class_registry(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn('preload("res://src/generated/GeneratedClassRegistry.gd")', source)
        self.assertIn("generated_class_count = GeneratedClassRegistry.count()", source)
        self.assertIn("Generated Java classes: %d", source)

    def test_port_game_loads_selected_generated_scripts_from_registry(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn('const SELECTED_GENERATED_CLASS_NAMES := ["Items", "Blocks", "UnitTypes", "Damage"]', source)
        self.assertIn("ResourceLoader.load(str(entry.get(\"gdscript_path\", \"\")))", source)
        self.assertIn("loaded_generated_class_names.append(java_name)", source)
        self.assertIn("Loaded generated scripts: %d (%s)", source)

    def test_port_game_exposes_runtime_summary_for_mcp(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func get_runtime_summary() -> Dictionary:", source)
        self.assertIn('"generated_class_count": generated_class_count', source)
        self.assertIn('"loaded_generated_class_names": loaded_generated_class_names.duplicate()', source)
        self.assertIn('"content_counts": content_counts.duplicate()', source)

    def test_port_game_instantiates_selected_generated_scripts(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var loaded_generated_instances: Dictionary = {}", source)
        self.assertIn("var loaded_generated_instance_names: Array[String] = []", source)
        self.assertIn("var instance = script.new()", source)
        self.assertIn("loaded_generated_instances[java_name] = instance", source)
        self.assertIn("loaded_generated_instance_names.append(java_name)", source)
        self.assertIn('"loaded_generated_instance_names": loaded_generated_instance_names.duplicate()', source)
        self.assertIn("Instanced generated scripts: %d (%s)", source)

    def test_port_game_routes_mouse_event_position_to_placement(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("place_selected_block_at_world(event.position)", source)
        self.assertIn("func place_selected_block_at_world(world_pos: Vector2) -> bool:", source)
        self.assertIn("var cell := world_to_grid(world_pos)", source)
        self.assertIn('"placed_block_count": placed_block_origins.size()', source)
        self.assertIn('"selected_build_index": selected_build_index', source)

    def test_port_game_instantiates_all_generated_scripts_from_registry(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var all_generated_scripts: Dictionary = {}", source)
        self.assertIn("var all_generated_instances: Dictionary = {}", source)
        self.assertIn("var all_generated_load_failures: Array[String] = []", source)
        self.assertIn("var all_generated_instance_failures: Array[String] = []", source)
        self.assertIn("func load_all_generated_scripts() -> void:", source)
        self.assertIn("for entry in GeneratedClassRegistry.all_classes():", source)
        self.assertIn('var java_key := "%s.%s" % [str(entry.get("java_package", "")), str(entry.get("java_name", ""))]', source)
        self.assertIn("all_generated_scripts[java_key] = script", source)
        self.assertIn("all_generated_instances[java_key] = instance", source)
        self.assertIn('"all_generated_script_count": all_generated_scripts.size()', source)
        self.assertIn('"all_generated_instance_count": all_generated_instances.size()', source)
        self.assertIn("All generated script instances: %d / %d", source)

    def test_port_game_build_palette_uses_all_textured_blocks(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const PINNED_BUILD_BLOCK_IDS", source)
        self.assertIn('for block in content_catalog.get_many("block"):', source)
        self.assertIn("if block.has_texture() and not build_palette.has(block):", source)
        self.assertIn("func select_next_build_slot() -> void:", source)
        self.assertIn("func select_previous_build_slot() -> void:", source)
        self.assertIn("selected_build_index = (selected_build_index + 1) % build_palette.size()", source)
        self.assertIn("selected_build_index = (selected_build_index - 1 + build_palette.size()) % build_palette.size()", source)
        self.assertIn('"selected_build_id": selected.id if selected else ""', source)

    def test_port_game_selects_build_block_by_id_for_mcp(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func select_build_block_by_id(block_id: String) -> bool:", source)
        self.assertIn("for index in build_palette.size():", source)
        self.assertIn("if build_palette[index].id == block_id:", source)
        self.assertIn("selected_build_index = index", source)
        self.assertIn("return true", source)
        self.assertIn("return false", source)

    def test_port_game_uses_source_block_size_for_placement(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var last_placed_block_id := \"\"", source)
        self.assertIn("var last_placed_block_size := 0", source)
        self.assertIn("var last_placed_cell := Vector2i.ZERO", source)
        self.assertIn("func block_size(block) -> int:", source)
        self.assertIn('return max(1, int(block.properties.get("size", 1)))', source)
        self.assertIn("func block_world_size(block) -> float:", source)
        self.assertIn("return float(tile_size * block_size(block))", source)
        self.assertIn("func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:", source)
        self.assertIn("sprite.position = grid_to_world(cell) + Vector2.ONE * (block_world_size(block) - float(tile_size)) * 0.5", source)
        self.assertIn("sprite.scale = Vector2(block_world_size(block) / size.x, block_world_size(block) / size.y)", source)
        self.assertIn("configure_block_sprite(sprite, block, cell)", source)
        self.assertIn('"last_placed_block_id": last_placed_block_id', source)
        self.assertIn('"last_placed_block_size": last_placed_block_size', source)
        self.assertIn('"last_placed_cell": {"x": last_placed_cell.x, "y": last_placed_cell.y}', source)


    def test_port_game_tracks_source_block_footprint_occupancy(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var placed_block_origins: Dictionary = {}", source)
        self.assertIn("var last_placed_occupied_cell_count := 0", source)
        self.assertIn("var last_place_blocked := false", source)
        self.assertIn("func occupied_cells(cell: Vector2i, block) -> Array[Vector2i]:", source)
        self.assertIn("var cells: Array[Vector2i] = []", source)
        self.assertIn("for y in block_size(block):", source)
        self.assertIn("for x in block_size(block):", source)
        self.assertIn("cells.append(cell + Vector2i(x, y))", source)
        self.assertIn("func is_cell_in_world(cell: Vector2i) -> bool:", source)
        self.assertIn("return cell.x >= 0 and cell.y >= 0 and cell.x < WORLD_W and cell.y < WORLD_H", source)
        self.assertIn("func can_place_block_at_cell(block, cell: Vector2i) -> bool:", source)
        self.assertIn("for occupied_cell in occupied_cells(cell, block):", source)
        self.assertIn("if not is_cell_in_world(occupied_cell):", source)
        self.assertIn("if placed_blocks.has(cell_key(occupied_cell)):", source)
        self.assertIn("func record_placed_block(sprite: Sprite2D, block, cell: Vector2i) -> void:", source)
        self.assertIn("var cell_keys: Array[String] = []", source)
        self.assertIn("placed_block_origins[cell_key(cell)] = sprite", source)
        self.assertIn("placed_blocks[cell_key(occupied_cell)] = sprite", source)
        self.assertIn("sprite.set_meta(\"occupied_cells\", cell_keys)", source)
        self.assertIn("sprite.set_meta(\"origin_cell\", cell)", source)
        self.assertIn("func place_selected_block_at_world(world_pos: Vector2) -> bool:", source)
        self.assertIn("if not can_place_block_at_cell(block, cell):", source)
        self.assertIn("last_place_blocked = true", source)
        self.assertIn("return false", source)
        self.assertIn("last_place_blocked = false", source)
        self.assertIn("last_placed_occupied_cell_count = block_size(block) * block_size(block)", source)
        self.assertIn("record_placed_block(sprite, block, cell)", source)
        self.assertIn('"placed_block_count": placed_block_origins.size()', source)
        self.assertIn('"occupied_cell_count": placed_blocks.size()', source)
        self.assertIn('"last_placed_occupied_cell_count": last_placed_occupied_cell_count', source)
        self.assertIn('"last_place_blocked": last_place_blocked', source)

    def test_port_game_records_initial_source_world_occupancy(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var initial_world_block_count := 0", source)
        self.assertIn("var initial_occupied_cell_count := 0", source)
        self.assertNotIn('add_sprite(blocks, "mechanical_drill", grid_to_world(drill_pos))', source)
        self.assertNotIn('add_sprite(blocks, "conveyor", grid_to_world(Vector2i(x, drill_pos.y)))', source)
        self.assertNotIn('add_sprite(blocks, "core_shard", grid_to_world(core_pos))', source)
        self.assertIn('add_source_block(blocks, "mechanical-drill", drill_pos)', source)
        self.assertIn('add_source_block(blocks, "conveyor", Vector2i(x, drill_pos.y))', source)
        self.assertIn('add_source_block(blocks, "core-shard", core_pos)', source)
        self.assertIn('add_source_block(blocks, "duo", duo_pos)', source)
        self.assertIn("initial_world_block_count = placed_block_origins.size()", source)
        self.assertIn("initial_occupied_cell_count = placed_blocks.size()", source)
        self.assertIn('"initial_world_block_count": initial_world_block_count', source)
        self.assertIn('"initial_occupied_cell_count": initial_occupied_cell_count', source)

    def test_port_game_uses_all_source_requirement_items(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var core_items: Dictionary = {\"copper\": 0}", source)
        self.assertIn("func sync_copper_inventory_alias() -> void:", source)
        self.assertIn('core_items["copper"] = max(int(core_items.get("copper", 0)), core_inventory)', source)
        self.assertIn("func set_core_item_count(item_id: String, amount: int) -> void:", source)
        self.assertIn("core_items[item_id] = max(0, amount)", source)
        self.assertIn("func add_core_item(item_id: String, amount: int) -> void:", source)
        self.assertIn("set_core_item_count(item_id, core_item_count(item_id) + amount)", source)
        self.assertIn("func core_item_count(item_id: String) -> int:", source)
        self.assertIn("return int(core_items.get(item_id, 0))", source)
        self.assertIn("for requirement in block.properties.get(\"requirements\", []):", source)
        self.assertIn('var item_id := str(requirement.get("item", ""))', source)
        self.assertIn('var amount := int(requirement.get("amount", 0))', source)
        self.assertIn("if item_id != \"\" and core_item_count(item_id) < amount:", source)
        self.assertIn("set_core_item_count(item_id, core_item_count(item_id) - amount)", source)
        self.assertNotIn('requirement.get("item", "") == "copper"', source)
        self.assertIn('add_core_item("copper", 1)', source)
        self.assertIn('"core_items": core_items.duplicate()', source)

    def test_port_game_initializes_core_health_from_source_block(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertNotIn("var core_health := 500.0", source)
        self.assertIn("var core_max_health := 0.0", source)
        self.assertIn("var core_health := 0.0", source)
        self.assertIn('core_max_health = source_block_health("core-shard")', source)
        self.assertIn("core_health = core_max_health", source)
        self.assertIn("func source_block_health(block_id: String) -> float:", source)
        self.assertIn('return float(block.properties.get("health", 0.0))', source)
        self.assertIn('"core_max_health": core_max_health', source)

if __name__ == "__main__":
    unittest.main()
