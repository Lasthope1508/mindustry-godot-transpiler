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
        self.assertIn("func place_selected_block_at_world(world_pos: Vector2) -> void:", source)
        self.assertIn("var cell := world_to_grid(world_pos)", source)
        self.assertIn('"placed_block_count": placed_blocks.size()', source)
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


if __name__ == "__main__":
    unittest.main()
