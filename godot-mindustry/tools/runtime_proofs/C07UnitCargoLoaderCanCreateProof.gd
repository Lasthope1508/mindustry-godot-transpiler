extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


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

	# --- Pure canCreate (N2322): Units.canCreate(team, unitType)
	# (Units.java:115-117, `return !type.useUnitCap ||
	# (team.data().countType(type) < getCap(team) &&
	# !type.isBanned());`) over getCap (Units.java:119-126),
	# evaluated from the frame can_create_inputs dict and
	# returning {can_create, cap}. The UCL unitType is
	# manifold (UnitCargoLoader.java:24), which keeps the
	# UnitType default useUnitCap = true (UnitType.java:205;
	# the manifold def, UnitTypes.java:4568-4593, sets NO
	# override), so the check is live, not vacuous. The cap
	# math (the four uncapped branches + the max(0, ...)
	# clamp + the unitCapVariable branch) lives in the shared
	# N2140 bridge (SourceUnitUpdateState.cap_state) and the
	# predicate in SourceUnitRuntimeState.
	# source_units_can_create_state; this pure composes them.
	# No input stamped (absent, non-dict, or empty) means
	# permissive: can_create true, cap Integer.MAX_VALUE
	# (2147483647). The live unit-count source
	# (team.data().countType live query) still defers, so
	# count_type arrives as a frame input here.
	var cap_max: int = unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_UNIT_CAP_MAX
	var no_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"use_unit_cap": false, "count_type": 9999, "unit_cap": 0, "is_banned": true}})
	var no_cap_capped: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"use_unit_cap": false, "count_type": 5, "unit_cap": 5}})
	proof["no_cap_when_unit_cap_unused"] = bool(no_cap.get("can_create", false)) and bool(no_cap_capped.get("can_create", false)) and int(no_cap.get("cap", -1)) == 0

	var below: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 3, "unit_cap": 5, "unit_cap_variable": false}})
	var below_zero: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 0, "unit_cap": 1, "unit_cap_variable": false}})
	proof["can_create_below_cap"] = bool(below.get("can_create", false)) and int(below.get("cap", -1)) == 5 and bool(below_zero.get("can_create", false)) and int(below_zero.get("cap", -1)) == 1

	var at_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 5, "unit_cap": 5, "unit_cap_variable": false}})
	var over_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 9, "unit_cap": 5, "unit_cap_variable": false}})
	proof["cannot_create_at_cap"] = bool(at_cap.get("can_create", true)) == false and int(at_cap.get("cap", -1)) == 5 and bool(over_cap.get("can_create", true)) == false and int(over_cap.get("cap", -1)) == 5

	var banned: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 0, "unit_cap": 5, "unit_cap_variable": false, "is_banned": true}})
	var not_banned: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 0, "unit_cap": 5, "unit_cap_variable": false, "is_banned": false}})
	proof["banned_type_cannot_create"] = bool(banned.get("can_create", true)) == false and int(banned.get("cap", -1)) == 5 and bool(not_banned.get("can_create", false))

	# All four uncapped branches return Integer.MAX_VALUE
	# (Units.java:122-124): the wave team outside pvp, the
	# wave team in campaign, disableUnitCap, and
	# team.ignoreUnitCap -- so even a huge count still
	# creates. The wave team inside pvp stays capped (the
	# first branch needs !pvp and the second needs campaign).
	var disabled: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "disable_unit_cap": true}})
	var wave_no_pvp: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "is_wave_team": true, "is_pvp": false}})
	var wave_campaign: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "is_wave_team": true, "is_pvp": true, "is_campaign": true}})
	var ignored: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "ignore_unit_cap": true}})
	var wave_pvp: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 0, "unit_cap": 0, "is_wave_team": true, "is_pvp": true, "is_campaign": false}})
	proof["uncapped_when_unit_cap_disabled"] = bool(disabled.get("can_create", false)) and int(disabled.get("cap", -1)) == cap_max and bool(wave_no_pvp.get("can_create", false)) and int(wave_no_pvp.get("cap", -1)) == cap_max and bool(wave_campaign.get("can_create", false)) and int(wave_campaign.get("cap", -1)) == cap_max and bool(ignored.get("can_create", false)) and int(ignored.get("cap", -1)) == cap_max and bool(wave_pvp.get("can_create", true)) == false and int(wave_pvp.get("cap", -1)) == 0

	# unitCapVariable adds the team bonus (Units.java:125):
	# cap = unitCap + teamUnitCap when variable, unitCap
	# alone when not; a negative total clamps to 0
	# (Math.max(0, ...)), so nothing creates at cap 0.
	var variable: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 7, "unit_cap": 5, "unit_cap_variable": true, "team_unit_cap": 3}})
	var fixed: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 7, "unit_cap": 5, "unit_cap_variable": false, "team_unit_cap": 3}})
	var clamped: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {"count_type": 0, "unit_cap": -5, "unit_cap_variable": true, "team_unit_cap": 2}})
	proof["variable_cap_adds_team_bonus"] = bool(variable.get("can_create", false)) and int(variable.get("cap", -1)) == 8 and bool(fixed.get("can_create", true)) == false and int(fixed.get("cap", -1)) == 5 and bool(clamped.get("can_create", true)) == false and int(clamped.get("cap", -1)) == 0

	var no_inputs: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({})
	var empty_inputs: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": {}})
	var non_dict_inputs: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_create_state({"can_create_inputs": 7})
	proof["permissive_default_without_inputs"] = bool(no_inputs.get("can_create", false)) and int(no_inputs.get("cap", -1)) == cap_max and bool(empty_inputs.get("can_create", false)) and int(empty_inputs.get("cap", -1)) == cap_max and bool(non_dict_inputs.get("can_create", false)) and int(non_dict_inputs.get("cap", -1)) == cap_max

	# --- Live tick: two loaders placed live; the tick
	# driver is called directly (as the N2165/N2211/N2234
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Both
	# loaders get full nitrogen (1.0, on the sprite liquids
	# meta store, the N2249 pattern) and full power, so both
	# fold efficiency 1.0. Loader A is capped (count 5 at cap
	# 5, stamped on the frame can_create_inputs): its build
	# stays frozen at 0 across two ticks. Loader B has no
	# inputs stamped (the permissive default): its build
	# advances 1/480 per tick at full efficiency. One 1/60s
	# tick is one source tick.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var nitrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("nitrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var loader_a_cell := Vector2i(28, 20)
	var loader_a := Sprite2D.new()
	game.add_child(loader_a)
	game.call("record_placed_block", loader_a, blocks_by_id["unit-cargo-loader"], loader_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and the
	# can_create_inputs on it).
	unit_cargo_loader_build_state.source_unit_cargo_loader_bind_frame_state(loader_a, blocks_by_id["unit-cargo-loader"])
	var loader_a_frame: Dictionary = loader_a.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var loader_a_liquids: Dictionary = loader_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(loader_a_liquids, nitrogen_id, 1.0)
	loader_a_frame["can_create_inputs"] = {"count_type": 5, "unit_cap": 5, "unit_cap_variable": false}

	var loader_b_cell := Vector2i(20, 10)
	var loader_b := Sprite2D.new()
	game.add_child(loader_b)
	game.call("record_placed_block", loader_b, blocks_by_id["unit-cargo-loader"], loader_b_cell)
	unit_cargo_loader_build_state.source_unit_cargo_loader_bind_frame_state(loader_b, blocks_by_id["unit-cargo-loader"])
	var loader_b_frame: Dictionary = loader_b.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var loader_b_liquids: Dictionary = loader_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(loader_b_liquids, nitrogen_id, 1.0)

	loader_a_frame["power_status"] = 1.0
	loader_b_frame["power_status"] = 1.0
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	loader_a_frame = loader_a.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	loader_b_frame = loader_b.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var tick1_ok: bool = is_equal_approx(float(loader_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(loader_a_frame.get("build_progress", -1.0)), 0.0) and is_equal_approx(float(loader_a_frame.get("total_progress", -1.0)), 0.0) and is_equal_approx(float(loader_b_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(loader_b_frame.get("build_progress", -1.0)), 1.0 / 480.0) and is_equal_approx(float(loader_b_frame.get("total_progress", -1.0)), 1.0)

	loader_a_frame["power_status"] = 1.0
	loader_b_frame["power_status"] = 1.0
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	loader_a_frame = loader_a.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	loader_b_frame = loader_b.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var tick2_ok: bool = is_equal_approx(float(loader_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(loader_a_frame.get("build_progress", -1.0)), 0.0) and is_equal_approx(float(loader_a_frame.get("total_progress", -1.0)), 0.0) and is_equal_approx(float(loader_b_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(loader_b_frame.get("build_progress", -1.0)), 2.0 / 480.0) and is_equal_approx(float(loader_b_frame.get("total_progress", -1.0)), 2.0)
	proof["live_tick_blocks_build_when_capped"] = tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderCanCreateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
