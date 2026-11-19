extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


class FakeAssemblerGame extends RefCounted:
	var sprites: Dictionary = {}

	func block_sprite_at_cell(cell: Vector2i) -> Variant:
		return sprites.get(cell, null)


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Pure module events (N2351): updateModules
	# (UnitAssembler.java:355-358) `modules.addUnique(build);`
	# `checkTier();` and removeModule (:359-362)
	# `modules.remove(build);` `checkTier();`, with the tier
	# re-derived through the N2133 climb (sort by tier, climb
	# while each module is max or max + 1, stop at the first
	# gap, `currentTier = max;`). Java's addUnique dedupes by
	# BUILD identity, so two distinct tier-1 modules both
	# enter ([1, 1]); remove drops ONE occurrence.
	var add_one: Dictionary = unit_factory_build_state.source_unit_assembler_modules_event_state([], 1, "add")
	var add_two: Dictionary = unit_factory_build_state.source_unit_assembler_modules_event_state(add_one.get("modules", []), 2, "add")
	proof["event_add_climbs_tier"] = Array(add_one.get("modules", [])) == [1] and int(add_one.get("current_tier", -1)) == 1 and Array(add_two.get("modules", [])) == [1, 2] and int(add_two.get("current_tier", -1)) == 2 and bool(add_two.get("tier_gap", true)) == false

	var gap: Dictionary = unit_factory_build_state.source_unit_assembler_modules_event_state([1, 2], 1, "remove")
	proof["event_remove_gap_resets_tier"] = Array(gap.get("modules", [])) == [2] and int(gap.get("current_tier", -1)) == 0 and bool(gap.get("tier_gap", false))

	var dup_add: Dictionary = unit_factory_build_state.source_unit_assembler_modules_event_state([1], 1, "add")
	proof["event_add_duplicate_tier_keeps_both"] = Array(dup_add.get("modules", [])) == [1, 1] and int(dup_add.get("current_tier", -1)) == 1

	var dup_remove: Dictionary = unit_factory_build_state.source_unit_assembler_modules_event_state([1, 1], 1, "remove")
	proof["event_remove_one_of_duplicate"] = Array(dup_remove.get("modules", [])) == [1] and int(dup_remove.get("current_tier", -1)) == 1

	var absent: Dictionary = unit_factory_build_state.source_unit_assembler_modules_event_state([1], 2, "remove")
	proof["event_remove_absent_noop"] = Array(absent.get("modules", [])) == [1] and int(absent.get("current_tier", -1)) == 1

	# --- Cell helper (N2351, the N2342 fake-game pattern):
	# the helper only calls block_sprite_at_cell, so a
	# RefCounted carrying proof-made sprites is deterministic
	# and independent of the campaign slice's layout. The
	# assembler sprite carries the unit-factory family frame
	# (source_unit_factory_building); the turret sprite
	# carries a different family frame.
	var fake_game := FakeAssemblerGame.new()
	var fake_assembler_cell := Vector2i(3, 4)
	var fake_assembler_sprite := Sprite2D.new()
	fake_assembler_sprite.set_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {"enabled": true, "current_tier": 0})
	fake_game.sprites[fake_assembler_cell] = fake_assembler_sprite
	var fake_turret_cell := Vector2i(5, 6)
	var fake_turret_sprite := Sprite2D.new()
	fake_turret_sprite.set_meta("source_turret_building", {"enabled": true})
	fake_game.sprites[fake_turret_cell] = fake_turret_sprite

	var helper_add: Dictionary = unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(fake_game, fake_assembler_cell, 1, "add")
	# Preserve the add observation before remove mutates the same live frame.
	var helper_frame_after_add: Dictionary = fake_assembler_sprite.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {}).duplicate(true)
	var helper_remove: Dictionary = unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(fake_game, fake_assembler_cell, 1, "remove")
	var helper_frame_after_remove: Dictionary = fake_assembler_sprite.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["helper_add_writes_frame"] = bool(helper_add.get("applied", false)) and str(helper_add.get("reason", "")) == "live_frame" and Array(helper_frame_after_add.get("modules", [])) == [1] and int(helper_frame_after_add.get("current_tier", -1)) == 1 and bool(helper_remove.get("applied", false)) and Array(helper_frame_after_remove.get("modules", [])) == [] and int(helper_frame_after_remove.get("current_tier", -1)) == 0

	var helper_missing: Dictionary = unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(fake_game, Vector2i(9, 9), 1, "add")
	proof["helper_missing_sprite_skips"] = not bool(helper_missing.get("applied", true)) and str(helper_missing.get("reason", "")) == "no_sprite"

	var helper_turret: Dictionary = unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(fake_game, fake_turret_cell, 1, "add")
	var fake_turret_frame: Dictionary = fake_turret_sprite.get_meta("source_turret_building", {})
	proof["helper_non_factory_skips"] = not bool(helper_turret.get("applied", true)) and str(helper_turret.get("reason", "")) == "not_unit_factory" and not bool(fake_turret_frame.has("modules"))

	# --- Live tick: a placed tank-assembler plus three
	# placed basic-assembler-modules. Two modules carry a
	# link candidate WITH a cell (the N2351 format:
	# {"block", "cell": Vector2i}); the third carries a
	# block-only candidate (the old proofs' format). The
	# first module tick refreshes all three links (fresh
	# frames: lastChange -2 vs tileChanges 1) and the wiring
	# adds the two tier-1 modules to the assembler frame
	# ([1, 1], current_tier 1) while the block-only link
	# skips. A second tick unlinks the first module
	# (tile_changes bumped to 2, candidate null) and the
	# wiring removes one tier ([1], current_tier 1). The
	# module tick driver is called directly (as the N2248
	# proof does), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_assembler_cell := Vector2i(28, 20)
	var live_assembler := Sprite2D.new()
	game.add_child(live_assembler)
	game.call("record_placed_block", live_assembler, blocks_by_id["tank-assembler"], live_assembler_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict to read the wiring result from it).
	unit_factory_build_state.source_unit_factory_bind_frame_state(live_assembler, blocks_by_id["tank-assembler"])

	var module_one_cell := Vector2i(10, 10)
	var module_one := Sprite2D.new()
	game.add_child(module_one)
	game.call("record_placed_block", module_one, blocks_by_id["basic-assembler-module"], module_one_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(module_one, blocks_by_id["basic-assembler-module"])
	var module_one_frame: Dictionary = module_one.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_one_frame["link_candidate"] = {"block": "tank-assembler", "cell": live_assembler_cell}
	module_one_frame["power_status"] = 1.0

	var module_two_cell := Vector2i(10, 20)
	var module_two := Sprite2D.new()
	game.add_child(module_two)
	game.call("record_placed_block", module_two, blocks_by_id["basic-assembler-module"], module_two_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(module_two, blocks_by_id["basic-assembler-module"])
	var module_two_frame: Dictionary = module_two.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_two_frame["link_candidate"] = {"block": "tank-assembler", "cell": live_assembler_cell}
	module_two_frame["power_status"] = 1.0

	var module_three_cell := Vector2i(20, 10)
	var module_three := Sprite2D.new()
	game.add_child(module_three)
	game.call("record_placed_block", module_three, blocks_by_id["basic-assembler-module"], module_three_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(module_three, blocks_by_id["basic-assembler-module"])
	var module_three_frame: Dictionary = module_three.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_three_frame["link_candidate"] = {"block": "tank-assembler"}
	module_three_frame["power_status"] = 1.0

	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	var live_assembler_frame: Dictionary = live_assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["live_tick_two_modules_link"] = Array(live_assembler_frame.get("modules", [])) == [1, 1] and int(live_assembler_frame.get("current_tier", -1)) == 1
	module_three_frame = module_three.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var module_three_link: Dictionary = module_three_frame.get("link", {})
	proof["live_tick_block_only_link_skips"] = Array(live_assembler_frame.get("modules", [])) == [1, 1] and not module_three_link.has("cell")

	module_one_frame = module_one.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_one_frame["tile_changes"] = 2
	module_one_frame["link_candidate"] = null
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	live_assembler_frame = live_assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["live_tick_unlink_removes_one"] = Array(live_assembler_frame.get("modules", [])) == [1] and int(live_assembler_frame.get("current_tier", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerCheckTierWiringProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
