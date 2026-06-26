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
        self.assertIn('source_offload_to_inventory(drill_output_item_id, int(output_batch["amount"]))', source)
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
        self.assertIn('source_offload_to_inventory(drill_output_item_id, int(output_batch["amount"]))', source)
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

    def test_port_game_decays_source_drill_warmup_when_inactive(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_drill_inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float) -> float:", source)
        self.assertIn("return source_approach_delta(current_warmup, 0.0, warmup_speed, source_delta)", source)
        self.assertIn("set_drill_warmup_at_cell(drill_pos.x, drill_pos.y, source_drill_inactive_warmup_state(drill_warmup_at_cell(drill_pos.x, drill_pos.y), source_drill_warmup_speed(\"mechanical-drill\"), delta * SOURCE_TICK_RATE))", source)

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
        self.assertIn("var output_batch := source_drill_output_batch(raw_progress, drill_delay, drill_ore_cell_count, drill_items_total(), source_block_item_capacity(\"mechanical-drill\"))", source)
        self.assertIn("item_progress = source_drill_progress_fraction(float(output_batch[\"progress\"]), drill_delay, drill_ore_cell_count > 0)", source)
        self.assertIn("source_offload_to_inventory(drill_output_item_id, int(output_batch[\"amount\"]))", source)

    def test_port_game_tracks_source_drill_internal_inventory(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var drill_items: Dictionary = {}", source)
        self.assertIn("func drill_item_count(item_id: String) -> int:", source)
        self.assertIn("return int(drill_items.get(item_id, 0))", source)
        self.assertIn("func drill_items_total() -> int:", source)
        self.assertIn("for amount in drill_items.values():", source)
        self.assertIn("func add_drill_item(item_id: String, amount: int) -> void:", source)
        self.assertIn("drill_items[item_id] = drill_item_count(item_id) + amount", source)
        self.assertIn("func source_offload_to_inventory(item_id: String, amount: int) -> void:", source)
        self.assertIn("add_drill_item(item_id, amount)", source)
        self.assertIn('"drill_items": drill_items.duplicate()', source)
        self.assertIn('"drill_items_total": drill_items_total()', source)

    def test_port_game_dumps_source_drill_inventory_to_core(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var drill_dump_timer := 0.0", source)
        self.assertIn("func remove_drill_item(item_id: String, amount: int) -> int:", source)
        self.assertIn("var removed = mini(amount, drill_item_count(item_id))", source)
        self.assertIn("drill_items[item_id] = drill_item_count(item_id) - removed", source)
        self.assertIn("func source_dump_drill_item_to_core(item_id: String) -> bool:", source)
        self.assertIn("if drill_item_count(item_id) <= 0:", source)
        self.assertIn("remove_drill_item(item_id, 1)", source)
        self.assertIn("source_core_handle_item(item_id)", source)
        self.assertIn("func simulate_drill_dump(delta: float) -> void:", source)
        self.assertIn("drill_dump_timer += delta * SOURCE_TICK_RATE", source)
        self.assertIn("var dump_interval := source_drill_dump_interval(\"mechanical-drill\", source_block_time_scale_at_cell(drill_pos.x, drill_pos.y))", source)
        self.assertIn("if drill_dump_timer >= dump_interval:", source)
        self.assertIn("source_dump_drill_item_to_core(drill_output_item_id)", source)
        self.assertIn("simulate_drill_dump(delta)", source)
        self.assertIn('"drill_dump_timer": drill_dump_timer', source)

    def test_port_game_dump_respects_source_core_accept_item_capacity(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_core_accept_item(item_id: String) -> bool:", source)
        self.assertIn("return core_item_count(item_id) < core_item_capacity", source)
        self.assertIn("if not source_core_accept_item(item_id):", source)
        self.assertIn("return false", source)
        dump_start = source.index("func source_dump_drill_item_to_core(item_id: String) -> bool:")
        self.assertLess(source.index("if not source_core_accept_item(item_id):", dump_start), source.index("source_core_handle_item(item_id)", dump_start))
        self.assertLess(source.index("source_core_handle_item(item_id)", dump_start), source.index("remove_drill_item(item_id, 1)", dump_start))

    def test_port_game_handles_core_item_like_source_before_dump_remove(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_core_handle_item(item_id: String) -> bool:", source)
        self.assertIn("if not source_core_accept_item(item_id):", source)
        self.assertIn("add_core_item(item_id, 1)", source)
        self.assertIn("return true", source)
        dump_start = source.index("func source_dump_drill_item_to_core(item_id: String) -> bool:")
        self.assertLess(source.index("source_core_handle_item(item_id)", dump_start), source.index("remove_drill_item(item_id, 1)", dump_start))

    def test_port_game_tracks_source_dump_cursor(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var drill_dump_cursor := 0", source)
        self.assertIn("func source_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:", source)
        self.assertIn("if proximity_size != 0:", source)
        self.assertIn("return (current_dump + 1) % proximity_size", source)
        self.assertIn("return current_dump", source)
        self.assertIn("func set_drill_dump_cursor(value: int) -> void:", source)
        self.assertIn("func increment_drill_dump(proximity_size: int) -> int:", source)
        self.assertIn("drill_dump_cursor = source_increment_dump_cursor(drill_dump_cursor, proximity_size)", source)
        dump_start = source.index("func source_dump_drill_item_to_core(item_id: String) -> bool:")
        self.assertIn("increment_drill_dump(1)", source[dump_start:])
        self.assertIn('"drill_dump_cursor": drill_dump_cursor', source)

    def test_port_game_exposes_source_dump_accumulate_attempt_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var building_dump_accum := 0.0", source)
        self.assertIn("func source_dump_accumulate_attempt_state(current_accum: float, source_delta: float) -> Dictionary:", source)
        self.assertIn("var next_accum := current_accum + source_delta", source)
        self.assertIn("var dump_attempts := 0", source)
        self.assertIn("while next_accum >= 1.0:", source)
        self.assertIn("dump_attempts += 1", source)
        self.assertIn("next_accum -= 1.0", source)
        self.assertIn('return {"dump_attempts": dump_attempts, "dump_accum": next_accum}', source)
        self.assertIn("func step_building_dump_accum(source_delta: float) -> Dictionary:", source)
        self.assertIn("building_dump_accum = float(state[\"dump_accum\"])", source)
        self.assertIn('"building_dump_accum": building_dump_accum', source)

    def test_port_game_exposes_source_move_forward_to_core(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_move_forward_accept_state(has_front: bool, same_team: bool, front_accepts: bool) -> bool:", source)
        self.assertIn("return has_front and same_team and front_accepts", source)
        self.assertIn("func source_move_forward_to_core(item_id: String, has_front := true, same_team := true) -> bool:", source)
        self.assertIn("if not source_move_forward_accept_state(has_front, same_team, source_core_accept_item(item_id)):", source)
        self.assertIn("return source_core_handle_item(item_id)", source)

    def test_port_game_exposes_source_building_handle_accept_item_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_handle_item_count(current_count: int) -> int:", source)
        self.assertIn("return current_count + 1", source)
        self.assertIn("func source_building_accept_item_state(consumes_item: bool, item_count: int, maximum_accepted: int) -> bool:", source)
        self.assertIn("return consumes_item and item_count < maximum_accepted", source)

    def test_port_game_exposes_source_building_handle_accept_liquid_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_handle_liquid_amount(current_amount: float, amount: float) -> float:", source)
        self.assertIn("return current_amount + amount", source)
        self.assertIn("func source_building_accept_liquid_state(has_liquids: bool, consumes_liquid: bool) -> bool:", source)
        self.assertIn("return has_liquids and consumes_liquid", source)

    def test_port_game_exposes_source_building_maximum_accepted_and_stack_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_maximum_accepted(block_item_capacity: int) -> int:", source)
        self.assertIn("return block_item_capacity", source)
        self.assertIn("func source_building_handle_stack_count(current_count: int, amount: int) -> int:", source)
        self.assertIn("return current_count + amount", source)

    def test_port_game_exposes_source_building_accept_stack_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_accept_stack_state(accepts_item: bool, has_items: bool, same_team_or_null_source: bool, maximum_accepted: int, item_count: int, amount: int) -> int:", source)
        self.assertIn("if accepts_item and has_items and same_team_or_null_source:", source)
        self.assertIn("return mini(maximum_accepted - item_count, amount)", source)
        self.assertIn("return 0", source)

    def test_port_game_exposes_source_building_remove_stack_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_remove_stack_state(has_items_module: bool, item_count: int, amount: int) -> Dictionary:", source)
        self.assertIn("if not has_items_module:", source)
        self.assertIn('return {"removed": 0, "remaining": item_count}', source)
        self.assertIn("var removed := mini(amount, item_count)", source)
        self.assertIn('return {"removed": removed, "remaining": item_count - removed}', source)

    def test_port_game_exposes_source_building_payload_default_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_accept_payload_state() -> bool:", source)
        self.assertIn("return false", source)
        self.assertIn("func source_building_handle_payload_state(payload_state: Variant) -> Variant:", source)
        self.assertIn("return payload_state", source)

    def test_port_game_exposes_source_move_payload_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_payload_forward_offset(payload_block_size: int) -> int:", source)
        self.assertIn("return floori(float(payload_block_size) / 2.0) + 1", source)
        self.assertNotIn("func source_payload_forward_offset(block_size: int) -> int:", source)
        self.assertIn("func source_move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:", source)
        self.assertIn("return has_next_tile and has_next_build and same_team and accepts_payload", source)

    def test_port_game_exposes_source_dump_payload_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:", source)
        self.assertIn("return (loop_index + dump_cursor) % proximity_size", source)
        self.assertIn("func source_dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:", source)
        self.assertIn("if proximity_size == 0:", source)
        self.assertIn('return {"moved": false, "cdump": dump_cursor, "handled_index": -1}', source)
        self.assertIn("var dump := dump_cursor", source)
        self.assertIn("for i in range(proximity_size):", source)
        self.assertIn("var other_index := source_dump_payload_index(i, dump, proximity_size)", source)
        self.assertIn("next_dump = source_increment_dump_cursor(next_dump, proximity_size)", source)
        self.assertIn("if other_index < accepts_payload_by_index.size() and bool(accepts_payload_by_index[other_index]):", source)
        self.assertIn('return {"moved": true, "cdump": next_dump, "handled_index": other_index}', source)
        self.assertIn('return {"moved": false, "cdump": next_dump, "handled_index": -1}', source)

    def test_port_game_exposes_source_building_can_be_replaced_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:", source)
        self.assertIn("if existing_always_replace:", source)
        self.assertIn("if existing_privileged:", source)
        self.assertIn("return existing_replaceable and (not same_block or (new_rotate and new_quick_rotate)) and ((not new_group_is_none and same_group) or same_block) and (new_size == existing_size or (new_size >= existing_size and (same_subclass or group_any_replace)))", source)
        self.assertIn("func source_building_can_be_replaced_state(other_can_replace_block: bool) -> bool:", source)
        self.assertIn("return other_can_replace_block", source)

    def test_port_game_exposes_source_building_default_activity_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_should_consume_state(enabled_state: bool) -> bool:", source)
        self.assertIn("return enabled_state", source)
        self.assertIn("func source_building_production_valid_state() -> bool:", source)
        self.assertIn("return true", source)
        self.assertIn("func source_building_consume_trigger_valid_state() -> bool:", source)
        self.assertIn("return false", source)
        self.assertIn("func source_building_power_production_state() -> float:", source)
        self.assertIn("return 0.0", source)

    def test_port_game_exposes_source_building_progress_display_ambient_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_progress_increase(base_time: float, edelta_value: float) -> float:", source)
        self.assertIn("return 1.0 / base_time * edelta_value", source)
        self.assertIn("func source_building_display_efficiency(edelta_value: float) -> float:", source)
        self.assertIn("return source_building_progress_increase(1.0, edelta_value) / edelta_value", source)
        self.assertIn("func source_building_should_ambient_sound(should_consume_state: bool) -> bool:", source)
        self.assertIn("return should_consume_state", source)

    def test_port_game_exposes_source_building_draw_status_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_status_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:", source)
        self.assertIn("if not (enable_draw_status and consumers_length > 0):", source)
        self.assertIn('return {"visible": false}', source)
        self.assertIn("var multiplier := 1.0 if block_size_value > 1 else 0.64", source)
        self.assertIn("var brcx := source_x + (float(block_size_value) * source_tilesize / 2.0) - (source_tilesize * multiplier / 2.0)", source)
        self.assertIn("var brcy := source_y - (float(block_size_value) * source_tilesize / 2.0) + (source_tilesize * multiplier / 2.0)", source)
        self.assertIn('"gray_square_size": 2.5 * multiplier', source)
        self.assertIn('"status_square_size": 1.5 * multiplier', source)

    def test_port_game_exposes_source_building_draw_cracks_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_cracks_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:", source)
        self.assertIn("if not draw_cracks or not damaged_state or block_size_value > max_crack_size:", source)
        self.assertIn('return {"visible": false}', source)
        self.assertIn("var crack_index := clampi(int((1.0 - health_fraction) * float(crack_regions)), 0, crack_regions - 1)", source)
        self.assertIn("var lightness := 0.1 + (1.0 - health_fraction) * 0.6", source)
        self.assertIn("var crack_rotation_degrees := (position_id % 4) * 90", source)
        self.assertNotIn("var rotation_degrees :=", source)
        self.assertIn('"region_size_index": block_size_value - 1', source)
        self.assertIn('"crack_index": crack_index', source)
        self.assertIn('"rotation_degrees": crack_rotation_degrees', source)

    def test_port_game_exposes_source_building_draw_select_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_select_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:", source)
        self.assertIn("var inactive_unit_factory := block_status == \"inactiveUnitFactory\"", source)
        self.assertIn("var remaining_activation_delay := maxf(0.0, unit_activation_delay - state_tick)", source)
        self.assertIn('"overlay_visible": true', source)
        self.assertIn('"overlay_x": source_x', source)
        self.assertIn('"overlay_y": source_y', source)
        self.assertIn('"overlay_rotation": source_rotation', source)
        self.assertIn('"place_text_visible": inactive_unit_factory', source)
        self.assertIn('"place_text_bundle_key": "rules.unitfactoryactivation.objective"', source)
        self.assertIn('"place_text_time": remaining_activation_delay', source)
        self.assertIn('"place_text_tile_x": tile_x', source)
        self.assertIn('"place_text_tile_y": tile_y', source)

    def test_port_game_exposes_source_building_draw_item_selection_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_item_selection_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:", source)
        self.assertIn("if not has_selection:", source)
        self.assertIn('return {"visible": false}', source)
        self.assertIn("var dx := source_x - float(block_size_value) * source_tilesize / 2.0", source)
        self.assertIn("var dy := source_y + float(block_size_value) * source_tilesize / 2.0", source)
        self.assertIn("var selection_width := icon_small / 4.0 * selection_icon_ratio", source)
        self.assertIn("var selection_height := icon_small / 4.0", source)
        self.assertIn('"shadow_color": "darkGray"', source)
        self.assertIn('"shadow_alpha": 1.0', source)
        self.assertIn('"shadow_y": dy - 1.0', source)
        self.assertIn('"foreground_y": dy', source)
        self.assertIn('"selection_width": selection_width', source)
        self.assertIn('"selection_height": selection_height', source)

    def test_port_game_exposes_source_building_draw_disabled_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_disabled_state(source_x: float, source_y: float) -> Dictionary:", source)
        self.assertIn("var disabled_icon_size := 6.0", source)
        self.assertIn('"visible": true', source)
        self.assertIn('"icon": "cancel"', source)
        self.assertIn('"color": "scarlet"', source)
        self.assertIn('"alpha": 0.8', source)
        self.assertIn('"x": source_x', source)
        self.assertIn('"y": source_y', source)
        self.assertIn('"width": disabled_icon_size', source)
        self.assertIn('"height": disabled_icon_size', source)

    def test_port_game_exposes_source_building_drawrot_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_drawrot_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> float:", source)
        self.assertIn("return float(rotation_quadrants * 90) if block_rotate and block_rotate_draw else 0.0", source)

    def test_port_game_exposes_source_arc_random_seed_int(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_INT64_MIN := -9223372036854775807 - 1", source)
        self.assertIn("const SOURCE_RAND_MURMUR_CONST1 := -49064778989728563", source)
        self.assertIn("const SOURCE_RAND_MURMUR_CONST2 := -4265267296055464877", source)
        self.assertIn("func source_arc_is_power_of_two(value: int) -> bool:", source)
        self.assertIn("return value != 0 and (value & (value - 1)) == 0", source)
        self.assertIn("func source_arc_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:", source)
        self.assertIn("if source_arc_is_power_of_two(max_value):", source)
        self.assertIn("_source_arc_rand_next_int_unbounded(rand_state)", source)
        self.assertIn("return _source_arc_rand_next_int_bound(rand_state, max_value - min_value + 1) + min_value", source)

    def test_port_game_exposes_source_arc_random_seed_float(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_RAND_NORM_FLOAT := 1.0 / 16777216.0", source)
        self.assertIn("func _source_arc_rand_next_float(rand_state: Dictionary) -> float:", source)
        self.assertIn("return float(_source_words_to_nonnegative(_source_words_unsigned_shift_right(_source_arc_rand_next_long_words(rand_state), 40))) * SOURCE_RAND_NORM_FLOAT", source)
        self.assertIn("func source_arc_random_seed_float_max(source_seed: int, max_value: float) -> float:", source)
        self.assertIn("var rand_state := _source_arc_rand_set_seed(source_seed * 99999)", source)
        self.assertIn("return _source_arc_rand_next_float(rand_state) * max_value", source)

    def test_port_game_exposes_source_building_draw_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:", source)
        self.assertIn("var draw_rotation := source_building_drawrot_state(block_rotate, block_rotate_draw, rotation_quadrants)", source)
        self.assertIn("if variants == 0 or not has_variant_regions:", source)
        self.assertIn('"region_kind": "region"', source)
        self.assertIn("var max_variant_index: int = max(0, variant_region_count - 1)", source)
        self.assertIn("var variant_index: int = source_arc_random_seed_int(tile_pos, 0, max_variant_index)", source)
        self.assertIn('"region_kind": "variant_region"', source)
        self.assertIn('"draw_team_top": true', source)

    def test_port_game_exposes_source_building_draw_cached_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_cached_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:", source)
        self.assertIn("return source_building_draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)", source)

    def test_port_game_exposes_source_building_recache_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_recache_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:", source)
        self.assertIn("if headless:", source)
        self.assertIn('"recache": false', source)
        self.assertIn('"recache": true', source)
        self.assertIn('"building_cache_layer": building_cache_layer', source)
        self.assertIn('"tile": tile_state', source)

    def test_port_game_exposes_source_building_payload_draw_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_payload_draw_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:", source)
        self.assertIn("var cached_draw := {}", source)
        self.assertIn("var dynamic_draw := {}", source)
        self.assertIn("if draw_cached:", source)
        self.assertIn("cached_draw = source_building_draw_cached_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)", source)
        self.assertIn("if draw_dynamic:", source)
        self.assertIn("dynamic_draw = source_building_draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)", source)
        self.assertIn('"saved_z": current_z', source)
        self.assertIn('"cached_z": building_cache_layer_z', source)
        self.assertIn('"dynamic_z": current_z', source)

    def test_port_game_exposes_source_building_draw_team_top_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_team_top_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:", source)
        self.assertIn("if not team_region_found:", source)
        self.assertIn('"visible": false', source)
        self.assertIn('"visible": true', source)
        self.assertIn('"tint_color": team_color if team_region_matches_team else ""', source)
        self.assertIn('"x": source_x', source)
        self.assertIn('"y": source_y', source)
        self.assertIn('"color_reset": true', source)

    def test_port_game_exposes_source_building_draw_liquid_light_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_liquid_light_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:", source)
        self.assertIn("if amount <= 0.01:", source)
        self.assertIn('"visible": false', source)
        self.assertIn("var fract := 1.0", source)
        self.assertIn("var opacity := light_alpha * fract", source)
        self.assertIn("if opacity <= 0.001:", source)
        self.assertIn('"radius": block_size_value * 30.0 * fract', source)
        self.assertIn('"alpha": opacity * amount', source)

    def test_port_game_exposes_source_building_draw_light_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_arc_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:", source)
        self.assertIn("return lerp(from_value, to_value, clamp(progress * source_delta, 0.0, 1.0))", source)
        self.assertIn("func source_building_draw_light_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:", source)
        self.assertIn("var selected_color := current_liquid_color if light_liquid_is_null else light_liquid_color", source)
        self.assertIn("var selected_alpha := current_liquid_alpha if light_liquid_is_null else light_liquid_alpha", source)
        self.assertIn("if not has_liquids or not draw_liquid_light or selected_alpha <= 0.001:", source)
        self.assertIn("var target := 1.0 if selected_liquid_amount >= 0.01 else 0.0", source)
        self.assertIn("var next_visual_liquid := source_arc_lerp_delta(visual_liquid, target, 0.06, source_delta)", source)
        self.assertIn("var light_state := source_building_draw_liquid_light_state(source_x, source_y, block_size_value, selected_color, selected_alpha, next_visual_liquid)", source)

    def test_port_game_exposes_source_building_draw_team_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_draw_team_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:", source)
        self.assertIn('"region": "block-border"', source)
        self.assertIn('"color": team_color', source)
        self.assertIn('"x": source_x - block_size_value * source_tilesize / 2.0 + 4.0', source)
        self.assertIn('"y": source_y - block_size_value * source_tilesize / 2.0 + 4.0', source)
        self.assertIn('"color_reset": true', source)

    def test_port_game_exposes_source_building_check_suppression_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_is_heal_suppressed_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> bool:", source)
        self.assertIn("return block_suppressable and source_time <= heal_suppression_time", source)
        self.assertIn("func source_arc_chance_delta_threshold(chance: float, source_delta: float) -> float:", source)
        self.assertIn("return chance * source_delta", source)
        self.assertIn("func source_building_check_suppression_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:", source)
        self.assertIn("var suppressed := source_building_is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)", source)
        self.assertIn("if not suppressed:", source)
        self.assertIn('"suppressed": false', source)
        self.assertIn("var particle_range := block_size_value * source_tilesize / 2.0 - 1.0", source)
        self.assertIn("var chance_threshold := source_arc_chance_delta_threshold(0.03, source_delta)", source)
        self.assertIn('"effect": "regenSuppressParticle"', source)
        self.assertIn('"x_min": source_x - particle_range', source)
        self.assertIn('"x_max": source_x + particle_range', source)

    def test_port_game_exposes_source_building_player_placed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_player_placed_state(config_state: Variant) -> Variant:", source)
        self.assertIn("return config_state", source)

    def test_port_game_exposes_source_building_placed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:", source)
        self.assertIn("if net_client:", source)
        self.assertIn('"returned": true', source)
        self.assertIn("var should_link_power := (consumes_power or outputs_power) and has_power and connected_power", source)
        self.assertIn("if not should_link_power:", source)
        self.assertIn('"power_link_scan": false', source)
        self.assertIn("var configure := not linked_to_self", source)
        self.assertIn('"configure_pos": source_pos if configure else -1', source)

    def test_port_game_exposes_source_building_on_repaired_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_repaired_state(has_fog_radius: bool) -> Dictionary:", source)
        self.assertIn('"placed": true', source)
        self.assertIn('"fog_force_update": has_fog_radius', source)

    def test_port_game_exposes_source_building_is_commandable_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_is_commandable_state(block_commandable: bool) -> bool:", source)
        self.assertIn("return block_commandable", source)

    def test_port_game_exposes_source_building_is_payload_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_is_payload_state(tile_is_empty_tile: bool) -> bool:", source)
        self.assertIn("return tile_is_empty_tile", source)

    def test_port_game_exposes_source_building_overwrote_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_overwrote_state(previous_state: Variant) -> Variant:", source)
        self.assertIn("return previous_state", source)

    def test_port_game_exposes_source_building_on_removed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_removed_state(current_state: Variant) -> Variant:", source)
        self.assertIn("return current_state", source)

    def test_port_game_exposes_source_building_unit_on_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_unit_on_state(unit_state: Variant) -> Variant:", source)
        self.assertIn("return unit_state", source)

    def test_port_game_exposes_source_building_unit_on_any_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_unit_on_any_state(unit_state: Variant) -> Variant:", source)
        self.assertIn("return unit_state", source)

    def test_port_game_exposes_source_building_unit_removed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_unit_removed_state(unit_state: Variant) -> Variant:", source)
        self.assertIn("return unit_state", source)

    def test_port_game_exposes_source_building_puddle_on_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_puddle_on_state(puddle_state: Variant) -> Variant:", source)
        self.assertIn("return puddle_state", source)

    def test_port_game_exposes_source_building_configured_type_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_configured_type_state(value_state: Dictionary) -> String:", source)
        self.assertIn('return "void"', source)
        self.assertIn('if value_kind == "Item":', source)
        self.assertIn('if value_kind == "Block":', source)
        self.assertIn('if value_kind == "Liquid":', source)
        self.assertIn('if value_kind == "UnitType":', source)

    def test_port_game_exposes_source_building_configured_last_access_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_configured_last_access_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:", source)
        self.assertIn('"last_accessed": current_last_accessed', source)
        self.assertIn('bool(builder_state.get("exists", false)) and bool(builder_state.get("is_player", false))', source)
        self.assertIn('result["last_accessed"] = str(builder_state.get("colored_name", ""))', source)

    def test_port_game_exposes_source_building_configured_direct_handler_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_configured_direct_handler_state(has_configuration: bool, configured_type: String, value_state: Variant) -> Dictionary:", source)
        self.assertIn('"handled": has_configuration', source)
        self.assertIn('"handler_type": configured_type', source)
        self.assertIn('"value": value_state', source)

    def test_port_game_exposes_source_building_configured_copy_config_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:", source)
        self.assertIn('"copy_branch": value_is_building', source)
        self.assertIn('"recurse": false', source)
        self.assertIn('if value_is_building and copied_config != null and not copied_config_is_building:', source)
        self.assertIn('result["config"] = copied_config', source)

    def test_port_game_exposes_source_building_tapped_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_tapped_state(current_state: Variant) -> Variant:", source)
        self.assertIn("return current_state", source)

    def test_port_game_exposes_source_building_after_destroyed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:", source)
        self.assertIn('"create_bullet": false', source)
        self.assertIn('"team": team_id if destroy_bullet_same_team else "derelict"', source)
        self.assertIn("source_arc_random_seed_float_max(building_id, 360.0)", source)

    def test_port_game_exposes_source_building_explosion_item_cap_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_explosion_item_cap_state(item_capacity: int) -> int:", source)
        self.assertIn("return item_capacity", source)

    def test_port_game_exposes_source_building_splash_liquid_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_splash_liquid_state(amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:", source)
        self.assertIn("var splash := clampf(amount / 4.0, 0.0, 10.0)", source)
        self.assertIn("var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))", source)
        self.assertIn("delays.append(float(i) / 2.0)", source)
        self.assertIn('"random_range": float(source_block_size) * source_tilesize / 2.0', source)

    def test_port_game_exposes_source_building_on_deconstructed_liquid_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:", source)
        self.assertIn("not current_incinerable or deconstruct_drop_all_liquid", source)
        self.assertIn("float(source_block_size * source_block_size) * 2.0", source)
        self.assertIn('"deposit_linked_tiles": true', source)

    def test_port_game_exposes_source_building_on_destroyed_item_explosion_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:", source)
        self.assertIn('var explosiveness := base_explosiveness', source)
        self.assertIn('var flammability := 0.0', source)
        self.assertIn('var power := 0.0', source)
        self.assertIn('var item_amount: int = min(int(item_state.get("amount", 0)), item_cap)', source)
        self.assertIn('explosiveness += float(item_state.get("explosiveness", 0.0)) * float(item_amount)', source)
        self.assertIn('flammability += float(item_state.get("flammability", 0.0)) * float(item_amount)', source)
        self.assertIn('power += float(item_state.get("charge", 0.0)) * pow(float(item_amount), 1.1) * 150.0', source)

    def test_port_game_exposes_source_building_on_destroyed_liquid_explosion_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:", source)
        self.assertIn('flammability += float(liquid_state.get("flammability", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0', source)
        self.assertIn('explosiveness += float(liquid_state.get("explosiveness", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0', source)

    def test_port_game_exposes_source_building_on_destroyed_buffered_power_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> float:", source)
        self.assertIn("if has_cons_power and cons_power_buffered:", source)
        self.assertIn("return current_power + power_status * cons_power_capacity", source)
        self.assertIn("return current_power", source)

    def test_port_game_exposes_source_building_on_destroyed_splash_liquid_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:", source)
        self.assertIn("var should_splash := has_liquids and damage_explosions", source)
        self.assertIn('"splash_liquids": should_splash', source)
        self.assertIn('"liquid_count": liquid_states.size() if should_splash else 0', source)

    def test_port_game_exposes_source_building_on_destroyed_dynamic_explosion_call_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:", source)
        self.assertIn('"flammability": flammability * flammability_scale', source)
        self.assertIn('"explosiveness": explosiveness * 3.5 * explosiveness_scale', source)
        self.assertIn('"radius": source_tilesize * float(source_block_size) / 2.0', source)
        self.assertIn('"damage_explosions": damage_explosions', source)

    def test_port_game_exposes_source_building_on_destroyed_rubble_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:", source)
        self.assertIn("var should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid", source)
        self.assertIn('"create_rubble": should_create_rubble', source)
        self.assertIn('"size": source_block_size if should_create_rubble else 0', source)

    def test_port_game_exposes_source_building_on_destroyed_base_sound_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:", source)
        self.assertIn("var should_play_sound := not headless", source)
        self.assertIn('"play_destroy_sound": should_play_sound', source)
        self.assertIn('"pitch_min": destroy_pitch_min', source)
        self.assertIn('"pitch_max": destroy_pitch_max', source)
        self.assertIn('"volume": destroy_sound_volume', source)

    def test_port_game_exposes_source_building_on_destroyed_reactive_sound_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:", source)
        self.assertIn("var should_play_reactive_sound := not headless", source)
        self.assertIn('"reactive_sound_kind": "explosive"', source)
        self.assertIn('"reactive_sound_kind": "flammable"', source)
        self.assertIn('"chance": 0.5', source)

    def test_port_game_exposes_source_building_on_destroyed_power_sound_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:", source)
        self.assertIn("var should_play_power_sound := not headless", source)
        self.assertIn('"power_sound_kind": "big"', source)
        self.assertIn('"sound": "blockExplodeElectricBig"', source)
        self.assertIn('"power_sound_kind": "normal"', source)
        self.assertIn('"sound": "blockExplodeElectric"', source)

    def test_port_game_exposes_source_building_display_name_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_display_name_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> String:", source)
        self.assertIn('return localized_name + "\\n" + derelict_label', source)
        self.assertIn("if team_is_player or team_emoji.is_empty():", source)
        self.assertIn('return localized_name + " " + team_emoji', source)

    def test_port_game_exposes_source_building_display_icon_and_flow_items_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_display_icon_state(block_ui_icon: Variant) -> Variant:", source)
        self.assertIn("return block_ui_icon", source)
        self.assertIn("func source_building_flow_items_state(items_module: Variant) -> Variant:", source)
        self.assertIn("return items_module", source)

    def test_port_game_exposes_source_building_display_ui_gates_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_display_ui_gates_state(team_is_player: bool, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:", source)
        self.assertIn('var display_flow := (block_category == "distribution" or block_category == "liquid") and block_display_flow', source)
        self.assertIn('"display_header": true', source)
        self.assertIn('"display_same_team_details": team_is_player', source)
        self.assertIn('"display_flow": team_is_player and display_flow', source)
        self.assertIn('"display_last_accessed": team_is_player and net_active and has_last_accessed', source)

    def test_port_game_exposes_source_building_display_flow_rate_label_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_arc_strings_fixed_one_decimal(value: float) -> String:", source)
        self.assertIn("var abs_value: float = absf(value)", source)
        self.assertIn("var scaled: int = int(floor(abs_value * 10.0 + 0.0001))", source)
        self.assertIn("var whole: int = int(float(scaled) / 10.0)", source)
        self.assertIn("var prefix: String = \"-\" if negative else \"\"", source)
        self.assertIn('return prefix + str(whole) + "." + str(decimal)', source)
        self.assertIn("func source_building_display_flow_rate_label(flow_rate: float, per_second_label: String) -> String:", source)
        self.assertIn('if flow_rate < 0.0:', source)
        self.assertIn('return "..."', source)
        self.assertIn('return source_arc_strings_fixed_one_decimal(flow_rate) + " " + per_second_label', source)

    def test_port_game_exposes_source_building_cursor_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_cursor_state(block_configurable: bool, interactable_player_team: bool) -> String:", source)
        self.assertIn('return "hand" if block_configurable and interactable_player_team else "arrow"', source)

    def test_port_game_exposes_source_building_configure_tap_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:", source)
        self.assertIn('if clear_on_double_tap:', source)
        self.assertIn('if same_building:', source)
        self.assertIn('"deselect": true', source)
        self.assertIn('"configure_null": true', source)
        self.assertIn('"consumed": false', source)
        self.assertIn('return {"deselect": false, "configure_null": false, "consumed": not same_building}', source)
    def test_port_game_exposes_source_building_configure_position_tap_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_configure_tapped_state(_x: float, _y: float) -> bool:", source)
        self.assertIn("return false", source)
    def test_port_game_exposes_source_building_configure_closed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_configure_closed_state() -> void:", source)
        self.assertIn("pass", source)
    def test_port_game_exposes_source_building_configure_visibility_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_configure_menu_visibility_state(_player: Variant) -> Dictionary:", source)
        self.assertIn('return {"should_show": true, "should_hide": false}', source)
        self.assertIn("func source_building_should_show_configure_state(_player: Variant) -> bool:", source)
        self.assertIn('return bool(source_building_configure_menu_visibility_state(_player)["should_show"])', source)
        self.assertIn("func source_building_should_hide_configure_state(_player: Variant) -> bool:", source)
        self.assertIn('return bool(source_building_configure_menu_visibility_state(_player)["should_hide"])', source)
    def test_port_game_exposes_source_building_draw_configure_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_block_half_extent(block_size_value: int, source_tilesize: float) -> float:", source)
        self.assertIn("return float(block_size_value) * source_tilesize / 2.0", source)
        self.assertIn("func source_building_draw_configure_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:", source)
        self.assertIn("source_building_block_half_extent(block_size_value, source_tilesize) + 1.0", source)
        self.assertIn('"color": "Pal.accent"', source)
        self.assertIn('"stroke": 1.0', source)
        self.assertIn('"reset": true', source)
    def test_port_game_exposes_source_building_check_solid_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_check_solid_state() -> bool:", source)
        self.assertIn("return false", source)
    def test_port_game_exposes_source_building_handle_damage_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_handle_damage_state(amount: float) -> float:", source)
        self.assertIn("return amount", source)
    def test_port_game_exposes_source_building_absorb_lasers_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_absorb_lasers_state(block_absorb_lasers: bool) -> bool:", source)
        self.assertIn("return block_absorb_lasers", source)
    def test_port_game_exposes_source_building_is_insulated_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_is_insulated_state(block_insulated: bool) -> bool:", source)
        self.assertIn("return block_insulated", source)
    def test_port_game_exposes_source_building_collide_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_collide_state(_other: Variant) -> bool:", source)
        self.assertIn("return true", source)
    def test_port_game_exposes_source_building_collision_damage_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_collision_damage_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:", source)
        self.assertIn("var armor := block_armor * bullet_armor_multiplier * bullet_block_armor_multiplier", source)
        self.assertIn("if not bullet_pierce_armor:", source)
        self.assertIn("damage = max(damage - armor, 0.1 * damage)", source)
        self.assertIn('"was_dead": current_health <= 0.0', source)
        self.assertIn('"removed": true', source)
    def test_port_game_exposes_source_building_damage_delegate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_damage_delegate_state(source_team: Variant, damage_amount: float) -> Dictionary:", source)
        self.assertIn('"delegates_to_damage": true', source)
        self.assertIn('"damage": damage_amount', source)
        self.assertIn("func source_building_bullet_damage_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:", source)
        self.assertIn('"delegates_to_source_damage": true', source)
        self.assertIn('"fires_bullet_damage_event": true', source)
    def test_port_game_exposes_source_building_change_team_delegate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_change_team_delegate_state(next_team: Variant) -> Dictionary:", source)
        self.assertIn('"delegates_to_change_team": true', source)
        self.assertIn('"update_power": true', source)
    def test_port_game_exposes_source_building_change_team_initial_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:", source)
        self.assertIn("if current_team == next_team:", source)
        self.assertIn("var team_after_force = force_team if force_team != null else current_team", source)
        self.assertIn("if last_team == next_team:", source)
        self.assertIn('"remove_index": was_valid', source)
        self.assertIn('"team": next_team', source)
    def test_port_game_exposes_source_building_change_team_power_proximity_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:", source)
        self.assertIn("if power_present and update_power:", source)
        self.assertIn('"proximity_reflow": true', source)
        self.assertIn('"proximity_reflow": false', source)
        self.assertIn('"old_graph": old_graph', source)
    def test_port_game_exposes_source_building_change_team_power_links_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:", source)
        self.assertIn("if link_count <= 0:", source)
        self.assertIn('"remove_index": true', source)
        self.assertIn('"remove_index": false', source)
        self.assertIn('"reflow_self": true', source)
        self.assertIn('"update_power_graph": true', source)
    def test_port_game_exposes_source_building_change_team_final_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_change_team_final_state(was: bool, last_team: Variant) -> Dictionary:", source)
        self.assertIn('"add_index": was', source)
        self.assertIn('"team_change_event": was', source)
        self.assertIn('"event_last": last_team', source)
        self.assertIn('"check_allow_update": true', source)
    def test_port_game_exposes_source_building_can_pickup_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_can_pickup_state(block_can_pickup: bool) -> bool:", source)
        self.assertIn("return block_can_pickup", source)
    def test_port_game_exposes_source_building_picked_up_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_picked_up_state(previous_state: Variant) -> Variant:", source)
        self.assertIn("return previous_state", source)
    def test_port_game_exposes_source_building_after_picked_up_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:", source)
        self.assertIn('"new_power_graph": power_present', source)
        self.assertIn('"clear_links": power_present', source)
        self.assertIn("if power_present and has_cons_power and not cons_power_buffered:", source)
        self.assertIn('"status": 0.0', source)
    def test_port_game_exposes_source_building_remove_from_proximity_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:", source)
        self.assertIn('"on_proximity_removed": true', source)
        self.assertIn('"tmp_tiles_cleared": true', source)
        self.assertIn('"nearby_count": nearby_count', source)
        self.assertIn('"queued_removals": clampi(removable_count, 0, nearby_count)', source)
        self.assertIn('"proximity_cleared": true', source)
    def test_port_game_exposes_source_building_update_proximity_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:", source)
        self.assertIn('"tmp_tiles_cleared": true', source)
        self.assertIn('"proximity_cleared": true', source)
        self.assertIn('"same_team_count": clampi(same_team_count, 0, nearby_count)', source)
        self.assertIn('"add_unique_calls": clampi(same_team_count, 0, nearby_count)', source)
        self.assertIn('"on_proximity_added": true', source)
        self.assertIn('"self_proximity_update": true', source)
        self.assertIn('"recache": (not headless) and draw_cached', source)
    def test_port_game_exposes_source_building_on_nearby_build_added_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_on_nearby_build_added_state(other_state: Variant) -> Variant:", source)
        self.assertIn("return other_state", source)

    def test_port_game_exposes_source_building_consume_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_consume_state(consumers: Array, self_state: Variant) -> Dictionary:", source)
        self.assertIn("for consumer in consumers:", source)
        self.assertIn('triggered.append({"consumer": consumer, "self": self_state})', source)
        self.assertIn('return {"triggered": triggered}', source)

    def test_port_game_exposes_source_building_can_consume_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_can_consume_state(potential_efficiency: float) -> bool:", source)
        self.assertIn("return potential_efficiency > 0.0", source)

    def test_port_game_exposes_source_building_efficiency_multiplier_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_efficiency_scale_state() -> float:", source)
        self.assertIn("return 1.0", source)
        self.assertIn("func source_building_update_efficiency_multiplier_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:", source)
        self.assertIn('"efficiency": efficiency * efficiency_scale', source)
        self.assertIn('"optional_efficiency": optional_efficiency * efficiency_scale', source)

    def test_port_game_exposes_source_building_update_consumption_initial_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_initial_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:", source)
        self.assertIn("if has_consumers and not cheating:", source)
        self.assertIn("var potential_efficiency := 1.0 if enabled_state and production_valid else 0.0", source)
        self.assertIn("var efficiency := potential_efficiency if should_consume_state else 0.0", source)
        self.assertIn('"should_consume_power": true', source)
        self.assertIn('"returned": true', source)

    def test_port_game_exposes_source_building_update_consumption_disabled_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_disabled_state(enabled_state: bool) -> Dictionary:", source)
        self.assertIn("if enabled_state:", source)
        self.assertIn('"potential_efficiency": 0.0', source)
        self.assertIn('"efficiency": 0.0', source)
        self.assertIn('"optional_efficiency": 0.0', source)
        self.assertIn('"should_consume_power": false', source)
        self.assertIn('"returned": true', source)

    def test_port_game_exposes_source_building_update_consumption_setup_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_setup_state(should_consume_state: bool, production_valid: bool) -> Dictionary:", source)
        self.assertIn('"update": should_consume_state and production_valid', source)
        self.assertIn('"min_efficiency": 1.0', source)
        self.assertIn('"efficiency": 1.0', source)
        self.assertIn('"optional_efficiency": 1.0', source)
        self.assertIn('"should_consume_power": true', source)

    def test_port_game_exposes_source_building_update_consumption_non_optional_pass_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_non_optional_pass_state(non_optional_consumer_results: Array) -> Dictionary:", source)
        self.assertIn('for consumer in non_optional_consumer_results:', source)
        self.assertIn('"min_efficiency": min_efficiency', source)
        self.assertIn('"should_consume_power": should_consume_power', source)

    def test_port_game_exposes_source_building_update_consumption_optional_pass_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_optional_pass_state(optional_consumer_results: Array) -> Dictionary:", source)
        self.assertIn("var optional_efficiency := 1.0", source)
        self.assertIn("for result in optional_consumer_results:", source)
        self.assertIn('"optional_efficiency": optional_efficiency', source)

    def test_port_game_exposes_source_building_update_consumption_efficiency_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_efficiency_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:", source)
        self.assertIn("var efficiency := min_efficiency", source)
        self.assertIn("optional_efficiency = min(optional_efficiency, min_efficiency)", source)
        self.assertIn("var potential_efficiency := efficiency", source)
        self.assertIn("if not update:", source)
        self.assertIn("efficiency = 0.0", source)
        self.assertIn("optional_efficiency = 0.0", source)
        self.assertIn('"potential_efficiency": potential_efficiency', source)

    def test_port_game_exposes_source_building_update_consumption_second_pass_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_second_pass_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:", source)
        self.assertIn("if update and efficiency > 0.0:", source)
        self.assertIn("for consumer in update_consumers:", source)
        self.assertIn('"updated_consumers": updated_consumers', source)
        self.assertIn('"update_count": updated_consumers.size()', source)

    def test_port_game_exposes_source_building_ambient_volume(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_ambient_volume(efficiency: float) -> float:", source)
        self.assertIn("return efficiency", source)

    def test_port_game_exposes_source_building_config_default(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_config_default() -> Variant:", source)
        self.assertIn("return null", source)

    def test_port_game_exposes_source_building_is_valid(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_is_valid(tile_build_matches_self: bool, dead_state: bool) -> bool:", source)
        self.assertIn("return tile_build_matches_self and not dead_state", source)

    def test_port_game_exposes_source_building_heal_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_heal_state(_amount: Variant = null) -> Dictionary:", source)
        self.assertIn('"health_changed": true', source)

    def test_port_game_exposes_source_building_hit_size(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_hit_size(block_size_value: int, source_tilesize: float) -> float:", source)
        self.assertIn("return float(block_size_value) * source_tilesize", source)

    def test_port_game_exposes_source_building_kill_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_kill_state(self_state := {}) -> Dictionary:", source)
        self.assertIn('"call": "buildDestroyed"', source)
        self.assertIn('"self": self_state', source)

    def test_port_game_exposes_source_building_damage_dead_guard_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_damage_dead_guard_state(dead_state: bool) -> Dictionary:", source)
        self.assertIn('"returned": dead_state', source)
        self.assertIn('"continues": not dead_state', source)

    def test_port_game_exposes_source_building_damage_block_health_scale_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_damage_block_health_scale_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:", source)
        self.assertIn("if is_zero_approx(block_health_multiplier):", source)
        self.assertIn('"damage": health + 1.0', source)
        self.assertIn('"damage": damage_amount / block_health_multiplier', source)
        self.assertIn('"last_damage_time": source_time', source)

    def test_port_game_exposes_source_building_damage_handle_damage_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_damage_handle_damage_gate_state(net_client: bool, health: float, damage_amount: float, handled_damage: float) -> Dictionary:", source)
        self.assertIn("if not net_client:", source)
        self.assertIn('"health": health - handled_damage', source)
        self.assertIn('"damage": damage_amount', source)
        self.assertIn('"handle_damage_called": true', source)
        self.assertIn('"handle_damage_called": false', source)

    def test_port_game_exposes_source_building_damage_health_changed_call_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_damage_health_changed_call_state() -> Dictionary:", source)
        self.assertIn('"health_changed": true', source)

    def test_port_game_exposes_source_building_health_changed_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_health_changed_state(net_server: bool, self_state := {}) -> Dictionary:", source)
        self.assertIn("var build_health_update = self_state", source)
        self.assertIn("if not net_server:", source)
        self.assertIn("build_health_update = null", source)
        self.assertIn('"build_health_update_called": net_server', source)
        self.assertIn('"build_health_update": build_health_update', source)
        self.assertIn('"notify_health_changed": self_state', source)

    def test_port_game_exposes_source_building_sense_position_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_position_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:", source)
        self.assertIn('"x": world_x / source_tilesize', source)
        self.assertIn('"y": world_y / source_tilesize', source)

    def test_port_game_exposes_source_building_sense_health_process_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:", source)
        self.assertIn('"health": health', source)
        self.assertIn('"max_health": max_health', source)
        self.assertIn('"efficiency": efficiency', source)
        self.assertIn('"timescale": time_scale', source)
        self.assertIn('"range": ranged_range / source_tilesize if has_range else 0.0', source)
        self.assertIn('"rotation": rotation_value', source)

    def test_port_game_exposes_source_building_sense_totals_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:", source)
        self.assertIn('"total_items": total_items', source)
        self.assertIn('"total_liquids": total_liquids', source)
        self.assertIn('"total_power": total_power', source)

    def test_port_game_exposes_source_building_sense_capacity_power_net_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_capacity_power_net_state(block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float) -> Dictionary:", source)
        self.assertIn('"item_capacity": block_item_capacity if block_has_items else 0.0', source)
        self.assertIn('"liquid_capacity": block_liquid_capacity if block_has_liquids else 0.0', source)
        self.assertIn('"power_capacity": cons_power_capacity if has_cons_power else 0.0', source)
        self.assertIn('"power_net_in": power_net_in', source)
        self.assertIn('"power_net_out": power_net_out', source)
        self.assertIn('"power_net_stored": power_net_stored', source)
        self.assertIn('"power_net_capacity": power_net_capacity', source)
        self.assertIn("power_net_in = last_scaled_power_in * SOURCE_TICK_RATE", source)
        self.assertIn("power_net_out = last_scaled_power_out * SOURCE_TICK_RATE", source)

    def test_port_game_exposes_source_building_sense_enabled_controlled_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:", source)
        self.assertIn('"enabled": 1.0 if enabled_state else 0.0', source)
        self.assertIn('"controlled": ctrl_player_value if is_control_block and is_controlled else 0.0', source)

    def test_port_game_exposes_source_building_sense_payload_size_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:", source)
        self.assertIn("var payload_count := 0.0", source)
        self.assertIn("payload_count += payload_seq_total", source)
        self.assertIn("payload_count += 1.0", source)
        self.assertIn('"payload_count": payload_count', source)
        self.assertIn('"size": block_size_value', source)

    def test_port_game_exposes_source_building_sense_object_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:", source)
        self.assertIn('return {"no_sensed": false, "value": block_value}', source)
        self.assertIn('return {"no_sensed": false, "value": first_item_value if has_items_module else null}', source)
        self.assertIn('return {"no_sensed": false, "value": config_value if config_senseable else null}', source)
        self.assertIn('if single_payload_kind == "unit" or single_payload_kind == "block":', source)
        self.assertIn('return {"no_sensed": false, "value": single_payload_content}', source)
        self.assertIn('return {"no_sensed": true, "value": null}', source)

    def test_port_game_exposes_source_building_sense_content_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:", source)
        self.assertIn('if content_type == "item" and has_items_module:', source)
        self.assertIn('return {"sensed": true, "value": item_amount}', source)
        self.assertIn('if content_type == "liquid" and has_liquids_module:', source)
        self.assertIn('return {"sensed": true, "value": liquid_amount}', source)
        self.assertIn('if (content_type == "unit" or content_type == "block") and has_payloads:', source)
        self.assertIn('return {"sensed": true, "value": payload_amount}', source)
        self.assertIn('return {"sensed": false, "value": null}', source)

    def test_port_game_exposes_source_building_control_enabled_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_FLOAT_ROUNDING_ERROR := 0.000001", source)
        self.assertIn("func source_building_control_enabled_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:", source)
        self.assertIn('if control_type == "enabled":', source)
        self.assertIn("next_enabled = not absf(p1) <= SOURCE_FLOAT_ROUNDING_ERROR", source)
        self.assertIn('return {"enabled": next_enabled}', source)

    def test_port_game_exposes_source_building_control_config_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:", source)
        self.assertIn('if control_type == "config" and block_logic_configurable and not p1_is_logic_build:', source)
        self.assertIn('return {"configured_called": true, "builder": null, "value": p1_value}', source)
        self.assertIn('return {"configured_called": false, "builder": null, "value": null}', source)

    def test_port_game_exposes_source_building_set_prop_health_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_set_prop_health_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:", source)
        self.assertIn('if prop != "health":', source)
        self.assertIn('var next_health := clampf(value, 0.0, max_health_value)', source)
        self.assertIn("if next_health <= 0.0 and not dead_state:", source)
        self.assertIn('return {"health": next_health, "build_destroyed_called": true, "build_destroyed": self_state, "health_changed": false}', source)
        self.assertIn('return {"health": next_health, "build_destroyed_called": false, "build_destroyed": null, "health_changed": true}', source)

    def test_port_game_exposes_source_building_set_prop_team_double_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_set_prop_team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:", source)
        self.assertIn('if prop != "team":', source)
        self.assertIn("var next_team_id := int(value)", source)
        self.assertIn("if current_team_id != next_team_id:", source)
        self.assertIn('return {"team_id": next_team_id, "change_team_called": true, "change_team": next_team_id}', source)
        self.assertIn('return {"team_id": current_team_id, "change_team_called": false, "change_team": null}', source)

    def test_port_game_exposes_source_building_set_prop_total_power_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_set_prop_total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:", source)
        self.assertIn('if prop == "totalPower" and has_power and has_cons_power and cons_power_buffered:', source)
        self.assertIn("var next_status := clampf(value / cons_power_capacity, 0.0, 1.0)", source)
        self.assertIn('return {"power_status": next_status, "updated": true}', source)
        self.assertIn('return {"power_status": current_power_status, "updated": false}', source)

    def test_port_game_exposes_source_building_set_prop_team_object_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_set_prop_team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:", source)
        self.assertIn('if prop == "team" and value_is_team and current_team_value != team_value:', source)
        self.assertIn('return {"team": team_value, "change_team_called": true, "change_team": team_value}', source)
        self.assertIn('return {"team": current_team_value, "change_team_called": false, "change_team": null}', source)

    def test_port_game_exposes_source_building_set_prop_item_content_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_set_prop_item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:", source)
        self.assertIn('if content_type != "item" or not has_items_module:', source)
        self.assertIn("var amount := int(value)", source)
        self.assertIn("if current_amount == amount:", source)
        self.assertIn("if current_amount < amount:", source)
        self.assertIn('return {"action": "handle_stack", "item": item_value, "amount": amount, "delta": amount - current_amount, "accepted": accepted_stack}', source)
        self.assertIn("if amount >= 0:", source)
        self.assertIn('return {"action": "remove_stack", "item": item_value, "amount": amount, "delta": current_amount - amount, "accepted": 0}', source)

    def test_port_game_exposes_source_building_set_prop_liquid_content_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_set_prop_liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, block_consumes_liquid: bool) -> Dictionary:", source)
        self.assertIn('if content_type != "liquid" or not has_liquids_module:', source)
        self.assertIn("var amount := clampf(value, 0.0, block_liquid_capacity)", source)
        self.assertIn("var can_set := amount < current_amount", source)
        self.assertIn("can_set = accept_liquid_result and (current_liquid_matches or current_amount <= 0.1 or block_consumes_liquid)", source)
        self.assertIn('return {"action": "set_liquid", "liquid": liquid_value, "amount": amount}', source)

    def test_port_game_exposes_source_building_in_fog_initial_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:", source)
        self.assertIn("if same_team or not rules_fog:", source)
        self.assertIn('return {"returned": true, "value": false}', source)
        self.assertIn('return {"returned": false, "value": null}', source)

    def test_port_game_exposes_source_building_in_fog_discovery_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_in_fog_discovery_gate_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:", source)
        self.assertIn('"size": block_size_value,', source)
        self.assertIn('"offset": block_size_offset,', source)
        self.assertIn('"tile_x": tile_x,', source)
        self.assertIn('"tile_y": tile_y,', source)
        self.assertIn("if not is_discovered:", source)
        self.assertIn('return {"returned": true, "value": true, "grid": grid}', source)
        self.assertIn('return {"returned": false, "value": null, "grid": grid}', source)

    def test_port_game_exposes_source_building_in_fog_visibility_loop_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_in_fog_visibility_loop_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:", source)
        self.assertIn("for x in range(block_size_value):", source)
        self.assertIn("for y in range(block_size_value):", source)
        self.assertIn("var check_x := tile_x + x + block_size_offset", source)
        self.assertIn("var check_y := tile_y + y + block_size_offset", source)
        self.assertIn('if int(visible_tile.get("x", -2147483648)) == check_x and int(visible_tile.get("y", -2147483648)) == check_y:', source)
        self.assertIn('return {"in_fog": false, "checked_tiles": checked_tiles, "visible_tile": {"x": check_x, "y": check_y}}', source)
        self.assertIn('return {"in_fog": true, "checked_tiles": checked_tiles, "visible_tile": null}', source)

    def test_port_game_exposes_source_building_killed_initial_side_effects_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_killed_initial_side_effects_state(tile_value: Variant) -> Dictionary:", source)
        self.assertIn('"dead": true,', source)
        self.assertIn('"event": {"type": "BlockDestroyEvent", "tile": tile_value},', source)
        self.assertIn('"on_destroyed_called": true,', source)
        self.assertIn('"next_step": "tile_remove_gate",', source)

    def test_port_game_exposes_source_building_killed_removal_side_effects_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_killed_removal_side_effects_state(tile_is_empty_tile: bool) -> Dictionary:", source)
        self.assertIn('"tile_remove_called": not tile_is_empty_tile,', source)
        self.assertIn('"remove_called": true,', source)
        self.assertIn('"after_destroyed_called": true,', source)

    def test_port_game_exposes_source_building_check_allow_update_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:", source)
        self.assertIn("if not allow_update_result:", source)
        self.assertIn('return {"enabled": false, "changed": current_enabled}', source)
        self.assertIn('return {"enabled": current_enabled, "changed": false}', source)

    def test_port_game_exposes_source_building_update_timescale_decay_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:", source)
        self.assertIn("var next_duration := current_time_scale_duration - time_delta", source)
        self.assertIn("if next_duration <= 0.0:", source)
        self.assertIn('return {"time_scale": 1.0, "time_scale_duration": next_duration}', source)
        self.assertIn('return {"time_scale": current_time_scale, "time_scale_duration": next_duration}', source)

    def test_port_game_exposes_source_building_update_ambient_sound_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:", source)
        self.assertIn("var should_loop: bool = not headless_mode and ambient_sound_value != sounds_none_value and should_ambient_sound_result", source)
        self.assertIn('return {"loop_called": false, "sound": ambient_sound_value, "volume": 0.0}', source)
        self.assertIn('return {"loop_called": true, "sound": ambient_sound_value, "volume": block_ambient_sound_volume * ambient_volume_value}', source)

    def test_port_game_exposes_source_building_update_consumption_call_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_consumption_call_state() -> Dictionary:", source)
        self.assertIn('return {"update_consumption_called": true}', source)

    def test_port_game_exposes_source_building_update_tile_gate_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:", source)
        self.assertIn("var update_tile_called: bool = enabled_state or not block_no_update_disabled", source)
        self.assertIn('return {"update_tile_called": update_tile_called}', source)

    def test_port_game_exposes_source_building_update_fog_visibility_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_update_fog_visibility_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state := {}, tile_state := {}) -> Dictionary:", source)
        self.assertIn("var should_update: bool = not was_visible and not in_fog_to_player_team", source)
        self.assertIn("var updated_flags: int = visible_flags | (1 << player_team_id)", source)
        self.assertIn('"update_shadow": self_state', source)
        self.assertIn('"minimap_update": tile_state', source)

    def test_port_game_exposes_source_building_hitbox_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:", source)
        self.assertIn("var hitbox_size: float = float(block_size_value) * source_tilesize", source)
        self.assertIn('"set_centered": {"x": world_x, "y": world_y, "width": hitbox_size, "height": hitbox_size}', source)

    def test_port_game_exposes_source_building_to_string_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_building_to_string_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> String:", source)
        self.assertIn('return "Building#" + str(id_value) + "[" + str(tile_x_value) + "," + str(tile_y_value) + "]:" + str(block_value)', source)

    def test_port_game_exposes_source_unit_grounded_flying_target_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_is_grounded(elevation_value: float) -> bool:", source)
        self.assertIn("return elevation_value < 0.001", source)
        self.assertIn("func source_unit_is_flying(elevation_value: float) -> bool:", source)
        self.assertIn("return elevation_value >= 0.09", source)
        self.assertIn("func source_unit_check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:", source)
        self.assertIn("var grounded: bool = source_unit_is_grounded(elevation_value)", source)
        self.assertIn("var flying: bool = source_unit_is_flying(elevation_value)", source)
        self.assertIn('"targetable": (grounded and target_ground) or (flying and target_air)', source)

    def test_port_game_exposes_source_unit_can_drown_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:", source)
        self.assertIn("var grounded: bool = source_unit_is_grounded(elevation_value)", source)
        self.assertIn('"can_drown": grounded and type_can_drown', source)

    def test_port_game_exposes_source_unit_drown_floor_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_drown_floor_state(floor_on_value: Variant) -> Variant:", source)
        self.assertIn("return floor_on_value", source)

    def test_port_game_exposes_source_unit_wobble_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_ARC_SIN_BITS := 14", source)
        self.assertIn("const SOURCE_ARC_SIN_MASK := 16383", source)
        self.assertIn("func source_arc_mathf_sin_lookup(radians: float) -> float:", source)
        self.assertIn("return sin((float(index) + 0.5) / float(SOURCE_ARC_SIN_COUNT) * SOURCE_ARC_RAD_FULL)", source)
        self.assertIn("func source_arc_mathf_sin_scaled(radians: float, scl: float, mag: float) -> float:", source)
        self.assertIn("return source_arc_mathf_sin_lookup(radians / scl) * mag", source)
        self.assertIn("func source_arc_mathf_cos_scaled(radians: float, scl: float, mag: float) -> float:", source)
        self.assertIn("return source_arc_mathf_cos_lookup(radians / scl) * mag", source)
        self.assertIn("func source_unit_wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:", source)
        self.assertIn("var wobble_input := source_time + float(unit_id % 10) * 12.0", source)
        self.assertIn("var dx := source_arc_mathf_sin_scaled(wobble_input, 25.0, 0.05) * source_delta * elevation_value", source)
        self.assertIn("var dy := source_arc_mathf_cos_scaled(wobble_input, 25.0, 0.05) * source_delta * elevation_value", source)

    def test_port_game_exposes_source_unit_move_at_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_arc_vec2_limit(vec: Vector2, limit: float) -> Vector2:", source)
        self.assertIn("var limit2 := limit * limit", source)
        self.assertIn("return vec * sqrt(limit2 / len2)", source)
        self.assertIn("func source_unit_move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:", source)
        self.assertIn("var vel := Vector2(vel_x, vel_y)", source)
        self.assertIn("var target := Vector2(vector_x, vector_y)", source)
        self.assertIn("var delta := source_arc_vec2_limit(target - vel, acceleration * target.length() * source_delta)", source)
        self.assertIn("var next_vel := vel + delta", source)

    def test_port_game_exposes_source_unit_floor_speed_multiplier_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:", source)
        self.assertIn("var flying: bool = source_unit_is_flying(elevation_value)", source)
        self.assertIn("var uses_air_floor: bool = flying or type_hovering", source)
        self.assertIn("var on_speed_multiplier: float = 1.0 if uses_air_floor else floor_on_speed_multiplier", source)
        self.assertIn("var result: float = pow(on_speed_multiplier, type_floor_multiplier) * speed_multiplier_value", source)

    def test_port_game_exposes_source_unit_unloaded_noop_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_unloaded_state(unit_state: Variant) -> Variant:", source)
        self.assertIn("return unit_state", source)

    def test_port_game_exposes_source_unit_update_boosting_default_event_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_update_boosting_default_event_state(boost: bool) -> Dictionary:", source)
        self.assertIn('"boost": boost', source)
        self.assertIn('"event": false', source)

    def test_port_game_exposes_source_unit_update_boosting_guard_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_update_boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:", source)
        self.assertIn("var returned: bool = (not type_can_boost) or dead_state", source)
        self.assertIn('"returned": returned', source)
        self.assertIn('"elevation": elevation_value', source)

    def test_port_game_exposes_source_unit_update_boosting_should_boost_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_unit_update_boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:", source)
        self.assertIn("var flying: bool = source_unit_is_flying(elevation_value)", source)
        self.assertIn("var should_boost: bool = boost or on_solid_result or (flying and not can_land_result)", source)
        self.assertIn('"should_boost": should_boost', source)

    def test_port_game_exposes_source_unit_update_boosting_elevation_state(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_arc_mathf_num(value: bool) -> int:", source)
        self.assertIn("return 1 if value else 0", source)
        self.assertIn("func source_unit_update_boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:", source)
        self.assertIn("var target_elevation: float = float(source_arc_mathf_num(should_boost)) if type_can_boost else 0.0", source)
        self.assertIn("var speed: float = type_rise_speed if should_boost else type_descent_speed", source)
        self.assertIn("var next_elevation: float = source_approach_delta(current_elevation, target_elevation, speed, source_delta)", source)

    def test_port_game_exposes_source_drill_dump_interval(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("const SOURCE_BLOCK_DUMP_TIME := 5.0", source)
        self.assertIn("func source_block_dump_time(block_id: String) -> float:", source)
        self.assertIn('return float(block.properties.get("dumpTime", SOURCE_BLOCK_DUMP_TIME))', source)
        self.assertIn("func source_drill_dump_interval(block_id: String, time_scale := 1.0) -> float:", source)
        self.assertIn("return source_block_dump_time(block_id) / time_scale", source)

    def test_port_game_exposes_source_drill_progress_fraction(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:", source)
        self.assertIn("if not has_dominant_item:", source)
        self.assertIn("return clampf(progress / delay, 0.0, 1.0)", source)
        self.assertIn("item_progress = source_drill_progress_fraction(float(output_batch[\"progress\"]), drill_delay, drill_ore_cell_count > 0)", source)

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
