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
        self.assertIn("func source_block_sprite_base_position(block, cell: Vector2i) -> Vector2:", source)
        self.assertIn("return grid_to_world(cell) + Vector2.ONE * (block_world_size(block) - float(tile_size)) * 0.5", source)
        self.assertIn("func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:", source)
        self.assertIn("sprite.position = source_block_sprite_base_position(block, cell)", source)
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
        self.assertIn('core_items["copper"] = clamp_core_item_amount(max(int(core_items.get("copper", 0)), core_inventory))', source)
        self.assertIn("func set_core_item_count(item_id: String, amount: int) -> void:", source)
        self.assertIn("core_items[item_id] = clamp_core_item_amount(amount)", source)
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
        self.assertIn('add_core_item(drill_output_item_id, int(output_batch["amount"]))', source)
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

    def test_port_game_exposes_selected_build_scaled_health(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func selected_build_health() -> float:", source)
        self.assertIn('return float(selected.properties.get("health", 0.0))', source)
        self.assertIn("func selected_build_scaled_health() -> float:", source)
        self.assertIn('return float(selected.properties.get("scaledHealth", 0.0))', source)
        self.assertIn('"selected_build_health": selected_build_health()', source)
        self.assertIn('"selected_build_scaled_health": selected_build_scaled_health()', source)

    def test_port_game_exposes_selected_build_mend_repair_params(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func selected_build_heal_percent() -> float:", source)
        self.assertIn('return float(selected.properties.get("healPercent", 0.0))', source)
        self.assertIn("func selected_build_phase_boost() -> float:", source)
        self.assertIn('return float(selected.properties.get("phaseBoost", 0.0))', source)
        self.assertIn("func selected_build_phase_range_boost() -> float:", source)
        self.assertIn('return float(selected.properties.get("phaseRangeBoost", 0.0))', source)
        self.assertIn('"selected_build_heal_percent": selected_build_heal_percent()', source)
        self.assertIn('"selected_build_phase_boost": selected_build_phase_boost()', source)
        self.assertIn('"selected_build_phase_range_boost": selected_build_phase_range_boost()', source)

    def test_port_game_exposes_overdrive_projector_real_boost_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:", source)
        self.assertIn('var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))', source)
        self.assertIn('var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))', source)
        self.assertIn("return (speed_boost + phase_heat * speed_boost_phase) * efficiency", source)
        self.assertIn("func selected_build_overdrive_real_boost() -> float:", source)
        self.assertIn('if selected.implementation != "OverdriveProjector":', source)
        self.assertIn("return source_overdrive_projector_real_boost(selected)", source)
        self.assertIn("func selected_build_overdrive_phase_real_boost() -> float:", source)
        self.assertIn("return source_overdrive_projector_real_boost(selected, 1.0)", source)
        self.assertIn('"selected_build_overdrive_real_boost": selected_build_overdrive_real_boost()', source)
        self.assertIn('"selected_build_overdrive_phase_real_boost": selected_build_overdrive_phase_real_boost()', source)

    def test_port_game_exposes_overdrive_projector_range_state_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_range(overdrive_projector, phase_heat := 0.0) -> float:", source)
        self.assertIn('var base_range := float(overdrive_projector.properties.get("range", 0.0))', source)
        self.assertIn('var phase_range_boost := float(overdrive_projector.properties.get("phaseRangeBoost", 0.0))', source)
        self.assertIn("return base_range + phase_heat * phase_range_boost", source)
        self.assertIn("func source_overdrive_projector_select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:", source)
        self.assertIn('"range": source_overdrive_projector_range(overdrive_projector, phase_heat)', source)
        self.assertIn('"color": str(overdrive_projector.properties.get("baseColor", ""))', source)
        self.assertIn("func source_overdrive_projector_place_state(overdrive_projector) -> Dictionary:", source)
        self.assertIn("return source_overdrive_projector_select_state(overdrive_projector, 0.0)", source)
        self.assertIn("func selected_build_overdrive_place_state() -> Dictionary:", source)
        self.assertIn("return source_overdrive_projector_place_state(selected)", source)
        self.assertIn("func selected_build_overdrive_phase_select_state() -> Dictionary:", source)
        self.assertIn("return source_overdrive_projector_select_state(selected, 1.0)", source)
        self.assertIn('"selected_build_overdrive_place_state": selected_build_overdrive_place_state()', source)
        self.assertIn('"selected_build_overdrive_phase_select_state": selected_build_overdrive_phase_select_state()', source)

    def test_port_game_exposes_overdrive_projector_boost_bar_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:", source)
        self.assertIn('var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))', source)
        self.assertIn('var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))', source)
        self.assertIn('var has_boost := bool(overdrive_projector.properties.get("hasBoost", false))', source)
        self.assertIn("var denominator := speed_boost + speed_boost_phase if has_boost else speed_boost", source)
        self.assertIn("return source_overdrive_projector_real_boost(overdrive_projector, phase_heat, efficiency) / denominator", source)
        self.assertIn("func selected_build_overdrive_boost_bar_fraction() -> float:", source)
        self.assertIn("return source_overdrive_projector_boost_bar_fraction(selected)", source)
        self.assertIn("func selected_build_overdrive_phase_boost_bar_fraction() -> float:", source)
        self.assertIn("return source_overdrive_projector_boost_bar_fraction(selected, 1.0)", source)
        self.assertIn('"selected_build_overdrive_boost_bar_fraction": selected_build_overdrive_boost_bar_fraction()', source)
        self.assertIn('"selected_build_overdrive_phase_boost_bar_fraction": selected_build_overdrive_phase_boost_bar_fraction()', source)

    def test_port_game_exposes_overdrive_projector_draw_light_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:", source)
        self.assertIn('if overdrive_projector == null or not bool(overdrive_projector.properties.get("emitLight", false)):', source)
        self.assertIn('"color": str(overdrive_projector.properties.get("baseColor", ""))', source)
        self.assertIn('"radius": float(overdrive_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency', source)
        self.assertIn('"alpha": 0.7 * smooth_efficiency', source)
        self.assertIn("func selected_build_overdrive_light_state_for_smooth_efficiency(smooth_efficiency: float) -> Dictionary:", source)
        self.assertIn("return source_overdrive_projector_light_state(selected, smooth_efficiency)", source)

    def test_port_game_exposes_overdrive_projector_draw_state_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_draw_state(overdrive_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:", source)
        self.assertIn("var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)", source)
        self.assertIn("var line_r: float = max(0.0, clamp(2.0 - f * 2.0, 0.0, 1.0) * float(block_size(overdrive_projector)) * float(tile_size) / 2.0 - f - 0.2)", source)
        self.assertIn("var line_w: float = clamp(0.5 - f, 0.0, 1.0) * float(block_size(overdrive_projector)) * float(tile_size)", source)
        self.assertIn('"base_color": str(overdrive_projector.properties.get("baseColor", ""))', source)
        self.assertIn('"phase_color": str(overdrive_projector.properties.get("phaseColor", overdrive_projector.properties.get("baseColor", "")))', source)
        self.assertIn('"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2', source)
        self.assertIn('"stroke": (2.0 * f + 0.1) * heat', source)
        self.assertIn("func selected_build_overdrive_draw_state_for_inputs(heat: float, phase_heat: float, source_time_ticks := 0.0) -> Dictionary:", source)
        self.assertIn("return source_overdrive_projector_draw_state(selected, heat, phase_heat, source_time_ticks)", source)

    def test_port_game_advances_overdrive_projector_update_state_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var overdrive_projector_charges: Dictionary = {}", source)
        self.assertIn("var overdrive_projector_smooth_efficiency: Dictionary = {}", source)
        self.assertIn("var overdrive_projector_heat: Dictionary = {}", source)
        self.assertIn("var overdrive_projector_phase_heat: Dictionary = {}", source)
        self.assertIn("var overdrive_projector_optional_efficiency: Dictionary = {}", source)
        self.assertIn("var overdrive_projector_booster_items: Dictionary = {}", source)
        self.assertIn("var overdrive_projector_use_progress: Dictionary = {}", source)
        self.assertIn("func boost_overdrive_projector_at_cell(x: int, y: int) -> bool:", source)
        self.assertIn("func simulate_overdrive_projectors(delta: float) -> void:", source)
        self.assertIn("overdrive_projector_smooth_efficiency[key] = source_lerp_delta(float(overdrive_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
        self.assertIn("overdrive_projector_heat[key] = source_lerp_delta(float(overdrive_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
        self.assertIn('if bool(block.properties.get("hasBoost", false)):', source)
        self.assertIn("overdrive_projector_phase_heat[key] = source_lerp_delta(float(overdrive_projector_phase_heat.get(key, 0.0)), float(overdrive_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)", source)
        self.assertIn("overdrive_projector_charges[key] = float(overdrive_projector_charges.get(key, 0.0)) + float(overdrive_projector_heat.get(key, 0.0)) * source_delta", source)
        self.assertIn('last_overdrive_projector_boost_duration = float(block.properties.get("reload", 0.0)) + 1.0', source)
        self.assertIn('overdrive_projector_use_progress[key] = fmod(float(overdrive_projector_use_progress.get(key, 0.0)), float(block.properties.get("useTime", 0.0)))', source)
        self.assertIn("func step_overdrive_projectors(seconds: float) -> Dictionary:", source)

    def test_port_game_exposes_building_apply_boost_state_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:", source)
        self.assertIn("if not can_overdrive:", source)
        self.assertIn("if intensity >= current_time_scale - 0.001:", source)
        self.assertIn('result["time_scale_duration"] = max(current_duration, duration)', source)
        self.assertIn('result["time_scale"] = max(current_time_scale, intensity)', source)

    def test_port_game_exposes_selected_build_can_overdrive_from_source_metadata(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func selected_build_can_overdrive() -> bool:", source)
        self.assertIn('return bool(selected.properties.get("canOverdrive", true))', source)
        self.assertIn('"selected_build_can_overdrive": selected_build_can_overdrive()', source)

    def test_port_game_exposes_overdrive_projector_target_filter_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:", source)
        self.assertIn("var real_range := source_overdrive_projector_range(overdrive_projector, phase_heat)", source)
        self.assertIn('var can_overdrive := bool(target_block.properties.get("canOverdrive", true))', source)
        self.assertIn("var in_range := distance <= real_range", source)
        self.assertIn('"eligible": in_range and can_overdrive', source)
        self.assertIn("func selected_build_overdrive_target_filter_state_for_block_id(target_block_id: String, distance: float, phase_heat := 0.0) -> Dictionary:", source)
        self.assertIn("return source_overdrive_projector_target_filter_state(selected, target, distance, phase_heat)", source)

    def test_port_game_applies_overdrive_projector_boost_to_eligible_target_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn('sprite.set_meta("source_block_time_scale", 1.0)', source)
        self.assertIn('sprite.set_meta("source_block_time_scale_duration", 0.0)', source)
        self.assertIn("var last_overdrive_projector_boosted_block_id := \"\"", source)
        self.assertIn("func source_block_time_scale_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("func source_block_time_scale_duration_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("func find_overdrive_boost_target(overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):", source)
        self.assertIn("var filter_state := source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance, phase_heat)", source)
        self.assertIn('if bool(filter_state.get("eligible", false)):', source)
        self.assertIn("func apply_overdrive_boost_to_sprite(target, intensity: float, duration: float) -> void:", source)
        self.assertIn("var result := source_building_apply_boost_state(float(target.get_meta(\"source_block_time_scale\", 1.0)), float(target.get_meta(\"source_block_time_scale_duration\", 0.0)), intensity, duration, bool(target_block.properties.get(\"canOverdrive\", true)))", source)
        self.assertIn('target.set_meta("source_block_time_scale", float(result.get("time_scale", 1.0)))', source)
        self.assertIn('target.set_meta("source_block_time_scale_duration", float(result.get("time_scale_duration", 0.0)))', source)
        self.assertIn("var target = find_overdrive_boost_target(overdrive_cell, block, phase_heat)", source)
        self.assertIn("apply_overdrive_boost_to_sprite(target, last_overdrive_projector_boost, last_overdrive_projector_boost_duration)", source)
        self.assertIn('"last_overdrive_projector_boosted_block_id": last_overdrive_projector_boosted_block_id', source)

    def test_port_game_decays_building_time_scale_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float) -> Dictionary:", source)
        self.assertIn('var result := {"time_scale": current_time_scale, "time_scale_duration": current_duration - source_delta}', source)
        self.assertIn('if float(result["time_scale_duration"]) <= 0.0:', source)
        self.assertIn('result["time_scale"] = 1.0', source)
        self.assertIn("func decay_block_time_scale_sprite(sprite, source_delta: float) -> void:", source)
        self.assertIn("var result := source_building_time_scale_decay_state(float(sprite.get_meta(\"source_block_time_scale\", 1.0)), float(sprite.get_meta(\"source_block_time_scale_duration\", 0.0)), source_delta)", source)
        self.assertIn("func simulate_block_time_scales(delta: float) -> void:", source)
        self.assertIn("decay_block_time_scale_sprite(sprite, source_delta)", source)
        self.assertIn("func step_block_time_scales(seconds: float) -> Dictionary:", source)
        self.assertIn("simulate_block_time_scales(delta)", source)

    def test_port_game_exposes_building_delta_edelta_helpers_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_delta(source_delta: float, time_scale: float) -> float:", source)
        self.assertIn("return source_delta * time_scale", source)
        self.assertIn("func source_building_edelta(source_delta: float, time_scale: float, efficiency: float) -> float:", source)
        self.assertIn("return efficiency * source_building_delta(source_delta, time_scale)", source)

    def test_port_game_uses_source_mend_projector_repair_amount_formula(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_mend_projector_repair_amount(mend_projector, target_block, phase_heat := 0.0, efficiency := 1.0) -> float:", source)
        self.assertIn('var heal_percent := float(mend_projector.properties.get("healPercent", 0.0))', source)
        self.assertIn('var phase_boost := float(mend_projector.properties.get("phaseBoost", 0.0))', source)
        self.assertIn('var target_health := float(target_block.properties.get("health", 0.0))', source)
        self.assertIn('return target_health * (heal_percent + phase_heat * phase_boost) / 100.0 * efficiency', source)
        self.assertIn("func selected_build_repair_amount() -> float:", source)
        self.assertIn('var mend_projector = content_catalog.get_by_id("mend-projector")', source)
        self.assertIn('return source_mend_projector_repair_amount(mend_projector, selected)', source)
        self.assertIn('"selected_build_repair_amount": selected_build_repair_amount()', source)

    def test_port_game_tracks_source_health_for_placed_blocks(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func place_selected_block_at_cell(x: int, y: int) -> bool:", source)
        self.assertIn("return place_selected_block_at_world(grid_to_world(Vector2i(x, y)))", source)
        self.assertIn('sprite.set_meta("source_block_id", block.id)', source)
        self.assertIn('sprite.set_meta("source_block_max_health", float(block.properties.get("health", 0.0)))', source)
        self.assertIn('sprite.set_meta("source_block_health", float(block.properties.get("health", 0.0)))', source)
        self.assertIn("func source_block_health_at_cell(x: int, y: int) -> float:", source)
        self.assertIn('return float(sprite.get_meta("source_block_health", 0.0))', source)
        self.assertIn("func damage_block_at_cell(x: int, y: int, amount: float) -> float:", source)
        self.assertIn('sprite.set_meta("source_block_health", max(0.0, float(sprite.get_meta("source_block_health", 0.0)) - amount))', source)
        self.assertIn("func repair_block_sprite(sprite, amount: float) -> float:", source)
        self.assertIn('min(float(sprite.get_meta("source_block_max_health", 0.0)), before + amount)', source)

    def test_port_game_simulates_source_mend_projector_heal_cycle(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_charges: Dictionary = {}", source)
        self.assertIn("var last_mend_projector_healed_amount := 0.0", source)
        self.assertIn("simulate_mend_projectors(delta)", source)
        self.assertIn("func simulate_mend_projectors(delta: float) -> void:", source)
        self.assertIn('if block.implementation != "MendProjector":', source)
        self.assertIn("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta", source)
        self.assertIn('if float(mend_projector_charges.get(key, 0.0)) < float(block.properties.get("reload", 0.0)):', source)
        self.assertIn("func find_damaged_block_in_mend_range(mend_cell: Vector2i, mend_projector, phase_heat := 0.0):", source)
        self.assertIn("func source_mend_projector_range(mend_projector, phase_heat := 0.0) -> float:", source)
        self.assertIn("return float(mend_projector.properties.get(\"range\", 0.0)) + phase_heat * float(mend_projector.properties.get(\"phaseRangeBoost\", 0.0))", source)
        self.assertIn("var healed := repair_block_sprite(target, source_mend_projector_repair_amount(block, target_block, phase_heat))", source)
        self.assertIn("func step_mend_projectors(seconds: float) -> Dictionary:", source)
        self.assertIn('"last_mend_projector_healed_amount": last_mend_projector_healed_amount', source)

    def test_port_game_simulates_source_mend_projector_phase_boost(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_phase_heat: Dictionary = {}", source)
        self.assertIn("func selected_build_booster_item() -> String:", source)
        self.assertIn('return str(selected.properties.get("boosterItem", ""))', source)
        self.assertIn("func selected_build_booster_use_time() -> float:", source)
        self.assertIn('return float(selected.properties.get("boosterUseTime", 0.0))', source)
        self.assertIn("func boost_mend_projector_at_cell(x: int, y: int) -> bool:", source)
        self.assertIn('var item_id := str(block.properties.get("boosterItem", ""))', source)
        self.assertIn('core_items[item_id] = int(core_items.get(item_id, 0)) - 1', source)
        self.assertIn("mend_projector_optional_efficiency[key] = 1.0", source)
        self.assertIn("func find_damaged_block_in_mend_range(mend_cell: Vector2i, mend_projector, phase_heat := 0.0):", source)
        self.assertIn("var real_range := source_mend_projector_range(mend_projector, phase_heat)", source)
        self.assertIn("var phase_heat := float(mend_projector_phase_heat.get(key, 0.0))", source)
        self.assertIn("find_damaged_block_in_mend_range(mend_cell, block, phase_heat)", source)
        self.assertIn("source_mend_projector_repair_amount(block, target_block, phase_heat)", source)
        self.assertIn('"selected_build_booster_item": selected_build_booster_item()', source)
        self.assertIn('"selected_build_booster_use_time": selected_build_booster_use_time()', source)

    def test_port_game_lerps_mend_projector_phase_heat_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_optional_efficiency: Dictionary = {}", source)
        self.assertIn("func source_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:", source)
        self.assertIn("return from_value + (to_value - from_value) * clamp(progress * source_delta, 0.0, 1.0)", source)
        self.assertIn("mend_projector_optional_efficiency[key] = 1.0", source)
        self.assertNotIn("mend_projector_phase_heat[key] = 1.0", source)
        self.assertIn("func mend_projector_phase_heat_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("var source_delta := delta * SOURCE_TICK_RATE", source)
        self.assertIn("mend_projector_phase_heat[key] = source_lerp_delta(float(mend_projector_phase_heat.get(key, 0.0)), float(mend_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)", source)

    def test_port_game_consumes_mend_projector_booster_stock_on_source_timer(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_booster_items: Dictionary = {}", source)
        self.assertIn("var mend_projector_booster_timers: Dictionary = {}", source)
        self.assertIn("mend_projector_booster_items[key] = int(mend_projector_booster_items.get(key, 0)) + 1", source)
        self.assertIn("mend_projector_optional_efficiency[key] = 1.0 if int(mend_projector_booster_items.get(key, 0)) > 0 else 0.0", source)
        self.assertIn("mend_projector_booster_timers[key] = float(mend_projector_booster_timers.get(key, 0.0)) + source_delta", source)
        self.assertIn('if float(mend_projector_booster_timers.get(key, 0.0)) >= float(block.properties.get("boosterUseTime", 0.0)):', source)
        self.assertIn("mend_projector_booster_items[key] = max(0, int(mend_projector_booster_items.get(key, 0)) - 1)", source)
        self.assertIn("mend_projector_booster_timers[key] = 0.0", source)
        self.assertLess(
            source.index("mend_projector_phase_heat[key] = source_lerp_delta"),
            source.index('if float(mend_projector_booster_timers.get(key, 0.0)) >= float(block.properties.get("boosterUseTime", 0.0)):'),
        )

    def test_port_game_advances_mend_projector_charge_with_source_heat(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_heat: Dictionary = {}", source)
        self.assertIn("mend_projector_heat[key] = source_lerp_delta(float(mend_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
        self.assertIn("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta", source)
        self.assertNotIn("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + source_delta", source)
        self.assertIn("func mend_projector_heat_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("func mend_projector_charge_at_cell(x: int, y: int) -> float:", source)
        self.assertLess(
            source.index("mend_projector_heat[key] = source_lerp_delta"),
            source.index("mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta"),
        )

    def test_port_game_lerps_mend_projector_smooth_efficiency_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_smooth_efficiency: Dictionary = {}", source)
        self.assertIn("func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("mend_projector_smooth_efficiency[key] = source_lerp_delta(float(mend_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
        self.assertLess(
            source.index("mend_projector_smooth_efficiency[key] = source_lerp_delta"),
            source.index("mend_projector_heat[key] = source_lerp_delta"),
        )

    def test_port_game_computes_mend_projector_light_state_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:", source)
        self.assertIn('"color": str(mend_projector.properties.get("baseColor", ""))', source)
        self.assertIn('"radius": float(mend_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency', source)
        self.assertIn('"alpha": 0.7 * smooth_efficiency', source)
        self.assertIn("func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:", source)
        self.assertIn("return source_mend_projector_light_state(block, mend_projector_smooth_efficiency_at_cell(x, y))", source)

    def test_port_game_exposes_mend_projector_progress_like_source_sense(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_mend_projector_progress(mend_projector, charge: float) -> float:", source)
        self.assertIn('var reload := float(mend_projector.properties.get("reload", 0.0))', source)
        self.assertIn("return clamp(charge / reload, 0.0, 1.0)", source)
        self.assertIn("func mend_projector_progress_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("return source_mend_projector_progress(block, mend_projector_charge_at_cell(x, y))", source)

    def test_port_game_exposes_mend_projector_select_range_like_source_draw_select(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:", source)
        self.assertIn('"range": source_mend_projector_range(mend_projector, phase_heat)', source)
        self.assertIn('"color": str(mend_projector.properties.get("baseColor", ""))', source)
        self.assertIn("func source_mend_projector_place_state(mend_projector) -> Dictionary:", source)
        self.assertIn('return source_mend_projector_select_state(mend_projector, 0.0)', source)
        self.assertIn("func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:", source)
        self.assertIn("return source_mend_projector_select_state(block, mend_projector_phase_heat_at_cell(x, y))", source)
        self.assertIn("func selected_build_place_state() -> Dictionary:", source)
        self.assertIn("return source_mend_projector_place_state(selected)", source)
        self.assertIn('"selected_build_place_state": selected_build_place_state()', source)

    def test_port_game_exposes_mend_projector_draw_state_like_source_draw(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_PI2 := PI * 2.0", source)
        self.assertIn("func source_absin(value: float, scl: float, mag: float) -> float:", source)
        self.assertIn("return (sin(value / scl) * mag + mag) / 2.0", source)
        self.assertIn("func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:", source)
        self.assertIn("var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)", source)
        self.assertIn("if mend_projector == null or not lod_l2:", source)
        self.assertIn('"visible": false', source)
        self.assertIn('"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2', source)
        self.assertIn('"square_alpha": lod_alpha2', source)
        self.assertIn('"square_stroke": (2.0 * f + 0.2) * heat', source)
        self.assertIn('"square_radius": min(1.0 + (1.0 - f) * float(block_size(mend_projector)) * float(tile_size) / 2.0, float(block_size(mend_projector)) * float(tile_size) / 2.0)', source)
        self.assertIn("func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:", source)
        self.assertIn("return source_mend_projector_draw_state(block, mend_projector_heat_at_cell(x, y), mend_projector_phase_heat_at_cell(x, y), source_time_ticks)", source)
    def test_port_game_enforces_source_core_item_capacity(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var core_item_capacity := 0", source)
        self.assertIn('core_item_capacity = source_block_item_capacity("core-shard")', source)
        self.assertIn("func source_block_item_capacity(block_id: String) -> int:", source)
        self.assertIn('return int(block.properties.get("itemCapacity", 0))', source)
        self.assertIn("func clamp_core_item_amount(amount: int) -> int:", source)
        self.assertIn("return mini(max(0, amount), core_item_capacity)", source)
        self.assertIn("core_items[item_id] = clamp_core_item_amount(amount)", source)
        self.assertIn('"core_item_capacity": core_item_capacity', source)

    def test_port_game_uses_source_unit_weapon_damage_against_core(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_weapon_damage(unit_type) -> float:", source)
        self.assertIn('var weapons: Array = unit_type.properties.get("weapons", [])', source)
        self.assertIn('var bullet: Dictionary = weapon.get("bullet", {})', source)
        self.assertIn('return float(bullet.get("damage", 0.0))', source)
        self.assertIn('core_health = max(0.0, core_health - source_unit_weapon_damage(unit_type))', source)
        self.assertNotIn('core_health = max(0.0, core_health - 15.0)', source)
        self.assertIn('"selected_enemy_weapon_damage": source_unit_weapon_damage(selected_enemy_unit())', source)

    def test_port_game_uses_source_unit_speed(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_world_speed(unit_type) -> float:", source)
        self.assertIn('return float(unit_type.properties.get("speed", 0.0)) * 60.0', source)
        self.assertIn("var speed := source_unit_world_speed(unit_type)", source)
        self.assertNotIn('max(20.0, float(unit_type.properties.get("speed", 0.5)) * float(tile_size) * 5.0)', source)
        self.assertIn('"selected_enemy_world_speed": source_unit_world_speed(selected_enemy_unit())', source)

    def test_port_game_uses_source_unit_hit_size_for_sprite_scale(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_hit_size(unit_type) -> float:", source)
        self.assertIn('return float(unit_type.properties.get("hitSize", 6.0))', source)
        self.assertIn("var hit_size := source_unit_hit_size(unit_type)", source)
        self.assertIn("sprite.scale = Vector2(hit_size / size.x, hit_size / size.y)", source)
        self.assertEqual(source.count("\n\t\t\tsprite.scale = Vector2(tile_size / size.x, tile_size / size.y)\n"), 1)
        self.assertIn('"selected_enemy_hit_size": source_unit_hit_size(selected_enemy_unit())', source)

    def test_port_game_uses_source_unit_health_for_spawned_units(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_health(unit_type) -> float:", source)
        self.assertIn('return float(unit_type.properties.get("health", 200.0))', source)
        self.assertIn('"health": source_unit_health(unit_type)', source)
        self.assertNotIn('"health": float(unit_type.properties.get("health", 100.0))', source)
        self.assertIn('"selected_enemy_health": source_unit_health(selected_enemy_unit())', source)

    def test_port_game_uses_source_bullet_sprite_assets(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_texture(sprite_id: String) -> Texture2D:", source)
        self.assertIn('"res://assets/core/assets-raw/sprites/effects/%s.png" % sprite_id', source)
        self.assertIn('sprite.texture = source_bullet_texture(str(data.get("sprite", "bullet")))', source)
        self.assertIn('"selected_turret_ammo_sprite": selected_turret_ammo_sprite()', source)
        self.assertNotIn('sprite.texture = textures.get("item")', source)

    def test_port_game_uses_source_bullet_lifetime(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_lifetime_seconds(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("lifetime", 40.0)) / 60.0', source)
        self.assertIn('"lifetime_remaining": source_bullet_lifetime_seconds(data)', source)
        self.assertIn('var lifetime_remaining := float(bullet.get("lifetime_remaining", 0.0)) - delta', source)
        self.assertIn('bullet["lifetime_remaining"] = lifetime_remaining', source)
        self.assertIn("if lifetime_remaining <= 0.0:", source)
        self.assertIn("func selected_turret_ammo_lifetime_seconds() -> float:", source)
        self.assertIn('return source_bullet_lifetime_seconds(data)', source)
        self.assertIn('"selected_turret_ammo_lifetime_seconds": selected_turret_ammo_lifetime_seconds()', source)
        self.assertIn("func selected_turret_limit_range_margin() -> float:", source)
        self.assertIn('return float(duo.properties.get("limitRangeMargin", 0.0))', source)
        self.assertIn('"selected_turret_limit_range_margin": selected_turret_limit_range_margin()', source)

    def test_port_game_uses_source_bullet_speed(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_world_speed(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("speed", 1.0)) * 60.0', source)
        self.assertIn('"speed": source_bullet_world_speed(data)', source)
        self.assertNotIn('float(data.get("speed", 2.5)) * float(tile_size) * 4.0', source)
        self.assertIn("func selected_turret_ammo_world_speed() -> float:", source)
        self.assertIn('return source_bullet_world_speed(data)', source)
        self.assertIn('"selected_turret_ammo_world_speed": selected_turret_ammo_world_speed()', source)

    def test_port_game_uses_source_bullet_dimensions(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_scale(data: Dictionary, texture_size: Vector2) -> Vector2:", source)
        self.assertIn('var width := float(data.get("width", 4.0))', source)
        self.assertIn('var height := float(data.get("height", width))', source)
        self.assertIn("return Vector2(width / texture_size.x, height / texture_size.y)", source)
        self.assertIn("sprite.scale = source_bullet_scale(data, size)", source)
        self.assertNotIn("sprite.scale = Vector2(tile_size / size.x, tile_size / size.y) * 0.45", source)
        self.assertIn("func selected_turret_ammo_dimensions() -> Dictionary:", source)
        self.assertIn('"selected_turret_ammo_dimensions": selected_turret_ammo_dimensions()', source)

    def test_port_game_uses_source_bullet_hit_size(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_hit_size(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("hitSize", 4.0))', source)
        self.assertIn('"hit_size": source_bullet_hit_size(data)', source)
        self.assertIn('if target_direction.length() <= float(bullet.get("hit_size", 4.0)):', source)
        self.assertNotIn("if direction.length() <= 6.0:", source)
        self.assertIn("func selected_turret_ammo_hit_size() -> float:", source)
        self.assertIn('"selected_turret_ammo_hit_size": selected_turret_ammo_hit_size()', source)

    def test_port_game_uses_source_bullet_damage(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_damage(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("damage", 1.0))', source)
        self.assertIn('"damage": source_bullet_damage(data)', source)
        self.assertNotIn('"damage": float(data.get("damage", 1.0))', source)
        self.assertIn("func selected_turret_ammo_damage() -> float:", source)
        self.assertIn('"selected_turret_ammo_damage": selected_turret_ammo_damage()', source)

    def test_port_game_exposes_source_turret_ammo_count(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func selected_turret_ammo_count() -> int:", source)
        self.assertIn('return duo.properties.get("ammo", []).size()', source)
        self.assertIn('"selected_turret_ammo_count": selected_turret_ammo_count()', source)

    def test_port_game_uses_source_bullet_ammo_multiplier(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_bullet_ammo_multiplier(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("ammoMultiplier", 2.0))', source)
        self.assertIn("func selected_turret_ammo_multiplier() -> float:", source)
        self.assertIn('return source_bullet_ammo_multiplier(data)', source)
        self.assertIn('"selected_turret_ammo_multiplier": selected_turret_ammo_multiplier()', source)

    def test_port_game_uses_source_bullet_reload_multiplier(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var last_turret_fired_reload_multiplier := 1.0", source)
        self.assertIn("func source_bullet_reload_multiplier(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("reloadMultiplier", 1.0))', source)
        self.assertIn("func source_turret_reload_seconds_for_ammo(turret, data: Dictionary) -> float:", source)
        self.assertIn("return source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)", source)
        self.assertIn("cooldown = source_turret_reload_seconds_for_ammo(duo, data)", source)
        self.assertIn("func selected_turret_cooldown_seconds() -> float:", source)
        self.assertIn('return float(turret_cooldowns.get(cell_key(duo_pos), 0.0))', source)
        self.assertIn("last_turret_fired_reload_multiplier = source_bullet_reload_multiplier(data)", source)
        self.assertIn('"last_turret_fired_reload_multiplier": last_turret_fired_reload_multiplier', source)
        self.assertIn('"selected_turret_ammo_reload_multiplier": selected_turret_ammo_reload_multiplier()', source)
        self.assertIn('"selected_turret_cooldown_seconds": selected_turret_cooldown_seconds()', source)

    def test_port_game_exposes_source_turret_ammo_storage(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func selected_turret_max_ammo() -> int:", source)
        self.assertIn('return int(duo.properties.get("maxAmmo", 30))', source)
        self.assertIn("func selected_turret_ammo_per_shot() -> int:", source)
        self.assertIn('return int(duo.properties.get("ammoPerShot", 1))', source)
        self.assertIn("func selected_turret_consume_ammo_once() -> bool:", source)
        self.assertIn('return bool(duo.properties.get("consumeAmmoOnce", true))', source)
        self.assertIn('"selected_turret_max_ammo": selected_turret_max_ammo()', source)
        self.assertIn('"selected_turret_ammo_per_shot": selected_turret_ammo_per_shot()', source)
        self.assertIn('"selected_turret_consume_ammo_once": selected_turret_consume_ammo_once()', source)

    def test_port_game_ports_source_item_turret_ammo_stack_logic(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var turret_ammo_stacks: Dictionary = {}", source)
        self.assertIn("var turret_total_ammo: Dictionary = {}", source)
        self.assertIn("func source_turret_ammo_data(turret, item_id: String) -> Dictionary:", source)
        self.assertIn("func handle_turret_item(cell: Vector2i, turret, item_id: String) -> bool:", source)
        self.assertIn("func use_turret_ammo(cell: Vector2i, turret) -> Dictionary:", source)
        self.assertIn("func load_selected_turret_ammo(item_id: String, amount: int) -> int:", source)
        self.assertIn("func use_selected_turret_ammo_once() -> Dictionary:", source)
        self.assertIn('"selected_turret_total_ammo": selected_turret_total_ammo()', source)
        self.assertIn('"selected_turret_ammo_stack_count": selected_turret_ammo_stack_count()', source)
        self.assertIn('"selected_turret_loaded_ammo_item": selected_turret_loaded_ammo_item()', source)

    def test_port_game_turret_fire_uses_source_loaded_ammo(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var data := peek_turret_ammo(cell, duo)", source)
        self.assertIn("data = use_turret_ammo(cell, duo)", source)
        self.assertIn("if not data.is_empty():", source)
        self.assertIn("spawn_turret_bullet(bullet_origin, target, data, shoot_angle_degrees)", source)
        self.assertIn("func spawn_turret_bullet(origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:", source)
        self.assertNotIn("spawn_turret_bullet(grid_to_world(cell), target, duo)", source)
        self.assertIn("var turret_shot_count := 0", source)
        self.assertIn("var last_turret_fired_ammo_item := \"\"", source)
        self.assertIn("var last_turret_fired_damage := 0.0", source)
        self.assertIn('last_turret_fired_ammo_item = str(data.get("item", ""))', source)
        self.assertIn("last_turret_fired_damage = source_bullet_damage(data)", source)
        self.assertIn("turret_shot_count += 1", source)
        self.assertIn('"turret_shot_count": turret_shot_count', source)
        self.assertIn('"last_turret_fired_ammo_item": last_turret_fired_ammo_item', source)
        self.assertIn('"last_turret_fired_damage": last_turret_fired_damage', source)

    def test_port_game_uses_source_turret_reload(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_turret_reload_seconds(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("reload", 10.0)) / 60.0', source)
        self.assertIn("cooldown = source_turret_reload_seconds_for_ammo(duo, data)", source)
        self.assertNotIn('max(0.1, float(duo.properties.get("reload", 60.0)) / 60.0)', source)
        self.assertIn("func selected_turret_reload_seconds() -> float:", source)
        self.assertIn('return source_turret_reload_seconds(duo)', source)
        self.assertIn('"selected_turret_reload_seconds": selected_turret_reload_seconds()', source)

    def test_port_game_uses_source_turret_range(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_turret_range(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("range", 80.0))', source)
        self.assertIn("func source_bullet_range_change(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("rangeChange", 0.0))', source)
        self.assertIn("func source_turret_range_for_ammo(turret, data: Dictionary) -> float:", source)
        self.assertIn("return source_turret_range(turret) + source_bullet_range_change(data)", source)
        self.assertIn("var data := peek_turret_ammo(cell, duo)", source)
        self.assertIn("var range_pixels := source_turret_range_for_ammo(duo, data)", source)
        self.assertIn("last_turret_fired_range = range_pixels", source)
        self.assertNotIn('var range_pixels = float(duo.properties.get("range", 0.0))', source)
        self.assertIn("func selected_turret_range() -> float:", source)
        self.assertIn('return source_turret_range(duo)', source)
        self.assertIn('"last_turret_fired_range": last_turret_fired_range', source)
        self.assertIn('"selected_turret_ammo_range_change": selected_turret_ammo_range_change()', source)
        self.assertIn('"selected_turret_range": selected_turret_range()', source)

    def test_port_game_uses_source_turret_shoot_y(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var last_turret_fired_shoot_y := 0.0", source)
        self.assertIn("func source_turret_shoot_y(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("shootY", 0.0))', source)
        self.assertIn("func source_turret_bullet_origin(origin: Vector2, target, turret, shoot_x_offset := 0.0) -> Vector2:", source)
        self.assertIn("var shoot_y_origin := origin + direction.normalized() * source_turret_shoot_y(turret)", source)
        self.assertIn("return shoot_y_origin + side * shoot_x_offset", source)
        self.assertIn("var bullet_origin := source_turret_bullet_origin(grid_to_world(cell), target, duo, shoot_x_offset)", source)
        self.assertIn("last_turret_fired_shoot_y = source_turret_shoot_y(duo)", source)
        self.assertIn("spawn_turret_bullet(bullet_origin, target, data, shoot_angle_degrees)", source)
        self.assertIn('"last_turret_fired_shoot_y": last_turret_fired_shoot_y', source)
        self.assertIn('"selected_turret_shoot_y": selected_turret_shoot_y()', source)

    def test_port_game_uses_source_shoot_alternate_pattern(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var turret_barrel_counters: Dictionary = {}", source)
        self.assertIn("var last_turret_fired_shoot_x_offset := 0.0", source)
        self.assertIn("func source_turret_shoot_pattern(turret) -> Dictionary:", source)
        self.assertIn('return turret.properties.get("shootPattern", {})', source)
        self.assertIn("func use_turret_shoot_x_offset(cell: Vector2i, turret) -> float:", source)
        self.assertIn('if str(pattern.get("type", "")) != "ShootAlternate":', source)
        self.assertIn('var spread := float(pattern.get("spread", 0.0))', source)
        self.assertIn("var offset := (float(index) - 0.5) * spread", source)
        self.assertIn("turret_barrel_counters[key] = counter + 1", source)
        self.assertIn("var shoot_x_offset := use_turret_shoot_x_offset(cell, duo)", source)
        self.assertIn("last_turret_fired_shoot_x_offset = shoot_x_offset", source)
        self.assertIn("source_turret_bullet_origin(grid_to_world(cell), target, duo, shoot_x_offset)", source)
        self.assertIn('"last_turret_fired_shoot_x_offset": last_turret_fired_shoot_x_offset', source)
        self.assertIn('"selected_turret_shoot_pattern": selected_turret_shoot_pattern()', source)

    def test_port_game_uses_source_turret_inaccuracy(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var last_turret_fired_inaccuracy_range := 0.0", source)
        self.assertIn("var last_turret_fired_inaccuracy_offset := 0.0", source)
        self.assertIn("func source_turret_inaccuracy(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("inaccuracy", 0.0))', source)
        self.assertIn("func source_bullet_inaccuracy(data: Dictionary) -> float:", source)
        self.assertIn('return float(data.get("inaccuracy", 0.0))', source)
        self.assertIn("func source_turret_total_inaccuracy(turret, data: Dictionary) -> float:", source)
        self.assertIn("return source_turret_inaccuracy(turret) + source_bullet_inaccuracy(data)", source)
        self.assertIn("var inaccuracy_range := source_turret_total_inaccuracy(duo, data)", source)
        self.assertIn("var inaccuracy_offset := randf_range(-inaccuracy_range, inaccuracy_range)", source)
        self.assertIn("last_turret_fired_inaccuracy_range = inaccuracy_range", source)
        self.assertIn("last_turret_fired_inaccuracy_offset = inaccuracy_offset", source)
        self.assertIn("var shoot_angle_degrees := current_rotation + inaccuracy_offset", source)
        self.assertIn("spawn_turret_bullet(bullet_origin, target, data, shoot_angle_degrees)", source)
        self.assertIn("var velocity := source_bullet_velocity(data, shoot_angle_degrees)", source)
        self.assertIn('"velocity": velocity', source)
        self.assertIn('"last_turret_fired_inaccuracy_range": last_turret_fired_inaccuracy_range', source)
        self.assertIn('"last_turret_fired_inaccuracy_offset": last_turret_fired_inaccuracy_offset', source)
        self.assertIn('"selected_turret_inaccuracy": selected_turret_inaccuracy()', source)

    def test_port_game_uses_source_turret_rotation_and_shoot_cone(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_TICK_RATE := 60.0", source)
        self.assertIn("var turret_rotations: Dictionary = {}", source)
        self.assertIn("var last_turret_target_rotation := 0.0", source)
        self.assertIn("var last_turret_rotation := 0.0", source)
        self.assertIn("var last_turret_angle_delta := 0.0", source)
        self.assertIn("turret_rotations[key] = 0.0", source)
        self.assertIn("turret_rotations.erase(key)", source)
        self.assertIn("func source_turret_rotate_speed(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("rotateSpeed", 5.0))', source)
        self.assertIn("func source_turret_shoot_cone(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("shootCone", 8.0))', source)
        self.assertIn("func source_angle_to_target(origin: Vector2, target) -> float:", source)
        self.assertIn("func source_angle_distance(current_degrees: float, target_degrees: float) -> float:", source)
        self.assertIn("func source_move_angle_toward(current_degrees: float, target_degrees: float, max_delta: float) -> float:", source)
        self.assertIn("var target_rotation := source_angle_to_target(grid_to_world(cell), target)", source)
        self.assertIn("var current_rotation := float(turret_rotations.get(key, target_rotation))", source)
        self.assertIn("current_rotation = source_move_angle_toward(current_rotation, target_rotation, source_turret_rotate_speed(duo) * delta * SOURCE_TICK_RATE)", source)
        self.assertIn("turret_rotations[key] = current_rotation", source)
        self.assertIn("var angle_delta := source_angle_distance(current_rotation, target_rotation)", source)
        self.assertIn("if angle_delta >= source_turret_shoot_cone(duo):", source)
        self.assertIn("last_turret_target_rotation = target_rotation", source)
        self.assertIn("last_turret_rotation = current_rotation", source)
        self.assertIn("last_turret_angle_delta = angle_delta", source)
        self.assertIn("func selected_turret_rotate_speed() -> float:", source)
        self.assertIn("func selected_turret_shoot_cone() -> float:", source)
        self.assertIn('"selected_turret_rotate_speed": selected_turret_rotate_speed()', source)
        self.assertIn('"selected_turret_shoot_cone": selected_turret_shoot_cone()', source)
        self.assertIn('"last_turret_target_rotation": last_turret_target_rotation', source)
        self.assertIn('"last_turret_rotation": last_turret_rotation', source)
        self.assertIn('"last_turret_angle_delta": last_turret_angle_delta', source)

    def test_port_game_uses_source_turret_recoil(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_RECOIL_POW := 1.8", source)
        self.assertIn("var turret_recoils: Dictionary = {}", source)
        self.assertIn("var last_turret_recoil := 0.0", source)
        self.assertIn("var last_turret_recoils := 0", source)
        self.assertIn("var last_turret_cur_recoil := 0.0", source)
        self.assertIn("var last_turret_recoil_offset := Vector2.ZERO", source)
        self.assertIn("turret_recoils[key] = 0.0", source)
        self.assertIn("turret_recoils.erase(key)", source)
        self.assertIn("func source_turret_recoil(turret) -> float:", source)
        self.assertIn('return float(turret.properties.get("recoil", 1.0))', source)
        self.assertIn("func source_turret_recoils(turret) -> int:", source)
        self.assertIn('return int(turret.properties.get("recoils", -1))', source)
        self.assertIn("func source_turret_recoil_time(turret) -> float:", source)
        self.assertIn("return source_turret_reload_seconds(turret) * SOURCE_TICK_RATE", source)
        self.assertIn("func source_turret_recoil_offset(turret, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:", source)
        self.assertIn("return Vector2.RIGHT.rotated(deg_to_rad(recoil_rotation_degrees)) * (-pow(cur_recoil, SOURCE_RECOIL_POW) * source_turret_recoil(turret))", source)
        self.assertIn("func update_turret_recoil(cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:", source)
        self.assertIn("cur_recoil = max(0.0, cur_recoil - delta * SOURCE_TICK_RATE / source_turret_recoil_time(turret))", source)
        self.assertIn("turret_recoils[key] = cur_recoil", source)
        self.assertIn("last_turret_recoil_offset = source_turret_recoil_offset(turret, recoil_rotation_degrees, cur_recoil)", source)
        self.assertIn("apply_turret_recoil_offset(cell, turret, last_turret_recoil_offset)", source)
        self.assertIn("update_turret_recoil(cell, duo, delta, float(turret_rotations.get(key, 0.0)))", source)
        self.assertIn("turret_recoils[key] = 1.0", source)
        self.assertIn("last_turret_cur_recoil = 1.0", source)
        self.assertIn("last_turret_recoil = source_turret_recoil(duo)", source)
        self.assertIn("last_turret_recoils = source_turret_recoils(duo)", source)
        self.assertIn("apply_turret_recoil_offset(cell, duo, last_turret_recoil_offset)", source)
        self.assertIn("func selected_turret_recoil() -> float:", source)
        self.assertIn("func selected_turret_recoils() -> int:", source)
        self.assertIn('"selected_turret_recoil": selected_turret_recoil()', source)
        self.assertIn('"selected_turret_recoils": selected_turret_recoils()', source)
        self.assertIn('"last_turret_recoil": last_turret_recoil', source)
        self.assertIn('"last_turret_recoils": last_turret_recoils', source)
        self.assertIn('"last_turret_cur_recoil": last_turret_cur_recoil', source)
        self.assertIn('"last_turret_recoil_offset": {"x": last_turret_recoil_offset.x, "y": last_turret_recoil_offset.y}', source)

    def test_port_game_uses_source_drill_rate(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_DRILL_HARDNESS_MULTIPLIER := 50.0", source)
        self.assertIn("var ore_items_by_cell: Dictionary = {}", source)
        self.assertIn("var drill_output_item_id := \"copper\"", source)
        self.assertIn("var drill_ore_cell_count := 0", source)
        self.assertIn("var drill_output_rate := 0.0", source)
        self.assertIn('add_ore_cell(terrain, "ore_copper", "copper", Vector2i(x, y))', source)
        self.assertIn('drill_ore_cell_count = source_drill_ore_count("mechanical-drill", drill_pos, drill_output_item_id)', source)
        self.assertIn('drill_output_rate = source_drill_output_rate("mechanical-drill", drill_output_item_id, drill_ore_cell_count)', source)
        self.assertIn("raw_progress += source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, delta, drill_warmup) * drill_delay", source)
        self.assertNotIn("item_progress += delta * 0.45", source)
        self.assertIn('add_core_item(drill_output_item_id, int(output_batch["amount"]))', source)
        self.assertNotIn('add_core_item("copper", 1)', source)
        self.assertIn("func source_drill_output_rate(block_id: String, item_id: String, ore_count: int) -> float:", source)
        self.assertIn("func source_drill_delay(block_id: String, item_id: String) -> float:", source)
        self.assertIn('return float(block.properties.get("drillTime", 300.0)) + SOURCE_DRILL_HARDNESS_MULTIPLIER * float(item.properties.get("hardness", 0))', source)
        self.assertIn("var delay := source_drill_delay(block_id, item_id)", source)
        self.assertIn("return 60.0 * float(ore_count) / delay", source)
        self.assertIn("func source_drill_output_delta(block_id: String, item_id: String, ore_count: int, seconds: float, time_scale := 1.0, warmup := 1.0) -> float:", source)
        self.assertIn("var scaled_source_delta := source_building_delta(seconds * SOURCE_TICK_RATE, time_scale)", source)
        self.assertIn("return source_drill_output_rate(block_id, item_id, ore_count) * scaled_source_delta / SOURCE_TICK_RATE", source)
        self.assertIn("func source_drill_output_delta_for_cell(x: int, y: int, item_id: String, ore_count: int, seconds: float, warmup := 1.0) -> float:", source)
        self.assertIn("func step_factory_drill(seconds: float) -> Dictionary:", source)
        self.assertIn('"drill_output_item_id": drill_output_item_id', source)
        self.assertIn('"drill_ore_cell_count": drill_ore_cell_count', source)
        self.assertIn('"drill_output_rate": drill_output_rate', source)

    def test_port_game_applies_source_drill_warmup_to_output_delta(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_DRILL_WARMUP_SPEED := 0.015", source)
        self.assertIn("var drill_warmups: Dictionary = {}", source)
        self.assertIn("func source_approach(from_value: float, to_value: float, speed: float) -> float:", source)
        self.assertIn("return from_value + clamp(to_value - from_value, -speed, speed)", source)
        self.assertIn("func source_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:", source)
        self.assertIn("return source_approach(from_value, to_value, source_delta * speed)", source)
        self.assertIn("func source_drill_warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:", source)
        self.assertIn("return source_approach_delta(current_warmup, speed, warmup_speed, source_delta)", source)
        self.assertIn("func set_drill_warmup_at_cell(x: int, y: int, warmup: float) -> void:", source)
        self.assertIn("func step_drill_warmup_cell(x: int, y: int, seconds: float, speed := 1.0) -> float:", source)
        self.assertIn("var drill_warmup := step_drill_warmup_cell(drill_pos.x, drill_pos.y, delta)", source)
        self.assertIn("raw_progress += source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, delta, drill_warmup) * drill_delay", source)
        self.assertIn("func source_drill_output_delta(block_id: String, item_id: String, ore_count: int, seconds: float, time_scale := 1.0, warmup := 1.0) -> float:", source)
        self.assertIn("return source_drill_output_rate(block_id, item_id, ore_count) * scaled_source_delta / SOURCE_TICK_RATE * warmup", source)
        self.assertIn('"drill_warmup": drill_warmup_at_cell(drill_pos.x, drill_pos.y)', source)

    def test_port_game_tracks_source_drill_time_drilled(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var drill_time_drilled: Dictionary = {}", source)
        self.assertIn("func source_drill_time_drilled_delta(warmup: float, seconds: float, time_scale := 1.0) -> float:", source)
        self.assertIn("return warmup * source_building_delta(seconds * SOURCE_TICK_RATE, time_scale)", source)
        self.assertIn("func drill_time_drilled_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("func set_drill_time_drilled_at_cell(x: int, y: int, value: float) -> void:", source)
        self.assertIn("func step_drill_time_drilled_cell(x: int, y: int, seconds: float, warmup: float) -> float:", source)
        self.assertIn("step_drill_time_drilled_cell(drill_pos.x, drill_pos.y, delta, drill_warmup_at_cell(drill_pos.x, drill_pos.y))", source)
        self.assertIn('"drill_time_drilled": drill_time_drilled_at_cell(drill_pos.x, drill_pos.y)', source)

    def test_port_game_tracks_source_drill_last_speed(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var drill_last_speeds: Dictionary = {}", source)
        self.assertIn("func source_drill_last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:", source)
        self.assertIn('var delay := source_drill_delay(block_id, item_id)', source)
        self.assertIn("return speed * float(ore_count) * warmup / delay", source)
        self.assertIn("func drill_last_speed_at_cell(x: int, y: int) -> float:", source)
        self.assertIn("func set_drill_last_speed_at_cell(x: int, y: int, value: float) -> void:", source)
        self.assertIn("set_drill_last_speed_at_cell(drill_pos.x, drill_pos.y, source_drill_last_speed_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, drill_warmup_at_cell(drill_pos.x, drill_pos.y)))", source)
        self.assertIn('"drill_last_speed": drill_last_speed_at_cell(drill_pos.x, drill_pos.y)', source)

    def test_port_game_batches_source_drill_output(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:", source)
        self.assertIn("if dominant_items > 0 and progress >= delay and items_total < item_capacity:", source)
        self.assertIn("var amount := int(progress / delay)", source)
        self.assertIn("return {\"amount\": amount, \"progress\": fmod(progress, delay)}", source)
        self.assertIn("var raw_progress := item_progress * drill_delay", source)
        self.assertIn("raw_progress += source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, delta, drill_warmup) * drill_delay", source)
        self.assertIn("var output_batch := source_drill_output_batch(raw_progress, drill_delay, drill_ore_cell_count, 0, source_block_item_capacity(\"mechanical-drill\"))", source)
        self.assertIn("item_progress = float(output_batch[\"progress\"]) / drill_delay", source)
        self.assertIn("add_core_item(drill_output_item_id, int(output_batch[\"amount\"]))", source)

    def test_port_game_uses_source_conveyor_speed_for_item_motion(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_CONVEYOR_TILE_SPEED_SCALE := 55.0", source)
        self.assertIn("var transport_progress := 0.0", source)
        self.assertIn("var conveyor_world_speed := 0.0", source)
        self.assertIn("var conveyor_path_progress_rate := 0.0", source)
        self.assertIn('conveyor_world_speed = source_conveyor_world_speed("conveyor")', source)
        self.assertIn('conveyor_path_progress_rate = source_conveyor_path_progress_rate("conveyor")', source)
        self.assertIn("transport_progress = fmod(transport_progress + source_conveyor_path_progress_delta_for_cell(drill_pos.x + 1, drill_pos.y, delta), 1.0)", source)
        self.assertIn("var phase := fmod(transport_progress + float(i) / float(item_sprites.size()), 1.0)", source)
        self.assertIn("func source_conveyor_world_speed(block_id: String) -> float:", source)
        self.assertIn('return float(block.properties.get("speed", 0.0)) * float(tile_size) * SOURCE_CONVEYOR_TILE_SPEED_SCALE', source)
        self.assertIn("func source_conveyor_path_progress_rate(block_id: String) -> float:", source)
        self.assertIn("var path_length := float(max(1, path_points.size() - 1) * tile_size)", source)
        self.assertIn("return source_conveyor_world_speed(block_id) / path_length", source)
        self.assertIn("func source_conveyor_path_progress_delta(block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:", source)
        self.assertIn("var scaled_source_delta := source_building_edelta(seconds * SOURCE_TICK_RATE, time_scale, efficiency)", source)
        self.assertIn("return source_conveyor_path_progress_rate(block_id) * scaled_source_delta / SOURCE_TICK_RATE", source)
        self.assertIn("func source_conveyor_path_progress_delta_for_cell(x: int, y: int, seconds: float, efficiency := 1.0) -> float:", source)
        self.assertIn("func step_factory_transport(seconds: float) -> Dictionary:", source)
        self.assertIn('"transport_progress_before": before', source)
        self.assertIn('"transport_progress_delta": progress_delta', source)
        self.assertIn('"conveyor_world_speed": conveyor_world_speed', source)
        self.assertIn('"conveyor_path_progress_rate": conveyor_path_progress_rate', source)

if __name__ == "__main__":
    unittest.main()
