extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure advance (N2195): BeamDrillBuild.updateTile()
	# (BeamDrill.java:237-263, the internal part): warmup
	# approachDelta toward num(efficiency > 0)
	# (BeamDrill.java:242), the boost multiplier lerp(1, 2.5,
	# optionalEfficiency) (BeamDrill.java:246), boostWarmup
	# lerpDelta toward optionalEfficiency (BeamDrill.java:248),
	# time += edelta() * multiplier (BeamDrill.java:251).
	# source_delta is Time.delta in ticks (1.0 = one tick).
	var warmup_frame: Dictionary = {"efficiency": 1.0, "optional_efficiency": 0.0, "warmup": 0.0, "boost_warmup": 0.0, "time": 0.0}
	for iteration in range(60):
		var advanced: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state(warmup_frame, 1.0, 1.0)
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["boost_warmup"] = advanced["boost_warmup"]
		warmup_frame["multiplier"] = advanced["multiplier"]
		warmup_frame["time"] = advanced["time"]
	proof["warmup_approaches_one_when_powered"] = is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 1.0)

	var decay_frame: Dictionary = {"efficiency": 0.0, "optional_efficiency": 0.0, "warmup": 1.0, "boost_warmup": 0.0, "time": 0.0}
	for iteration in range(60):
		var decayed: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state(decay_frame, 1.0, 1.0)
		decay_frame["warmup"] = decayed["warmup"]
		decay_frame["boost_warmup"] = decayed["boost_warmup"]
		decay_frame["multiplier"] = decayed["multiplier"]
		decay_frame["time"] = decayed["time"]
	proof["warmup_decays_to_zero_without_power"] = is_equal_approx(float(decay_frame.get("warmup", -1.0)), 0.0)

	var boost_frame: Dictionary = {"efficiency": 1.0, "optional_efficiency": 0.5, "warmup": 0.0, "boost_warmup": 0.0, "time": 0.0}
	var boosted: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state(boost_frame, 1.0, 1.0)
	proof["boost_warmup_lerps_to_optional_efficiency"] = is_equal_approx(float(boosted.get("boost_warmup", -1.0)), 0.05)

	var multiplier_half: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.5, "warmup": 0.0, "boost_warmup": 0.0, "time": 0.0}, 1.0, 1.0)
	var multiplier_full: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "warmup": 0.0, "boost_warmup": 0.0, "time": 0.0}, 1.0, 1.0)
	var multiplier_none: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "warmup": 0.0, "boost_warmup": 0.0, "time": 0.0}, 1.0, 1.0)
	proof["multiplier_lerps_boost_intensity"] = is_equal_approx(float(multiplier_half.get("multiplier", -1.0)), 1.75) and is_equal_approx(float(multiplier_full.get("multiplier", -1.0)), 2.5) and is_equal_approx(float(multiplier_none.get("multiplier", -1.0)), 1.0)

	var time_frame: Dictionary = {"efficiency": 0.5, "optional_efficiency": 0.5, "warmup": 0.0, "boost_warmup": 0.0, "time": 0.0}
	var time_advanced: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state(time_frame, 1.0, 1.0)
	var time_scaled: Dictionary = beam_drill_build_state.source_beam_drill_update_tile_advance_state(time_frame, 1.0, 2.0)
	proof["time_advances_by_edelta_times_multiplier"] = is_equal_approx(float(time_advanced.get("time", -1.0)), 0.875) and is_equal_approx(float(time_scaled.get("time", -1.0)), 1.75)

	# --- Live tick: the plasma-bore is a BeamDrill with a power
	# consumer (consumePower 0.15f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick: warmup rises 1/60 toward 1.
	# N2300 (N2195 stale since N2256): this drill holds NO
	# hydrogen, so the plasma-bore booster row folds
	# optionalEfficiency to 0 (ConsumeLiquid.efficiency with a
	# 0.0 held amount, ConsumeLiquid.java:42-47) and the
	# multiplier is lerp(1, 2.5, 0) = 1.0, so time rises 0.5 *
	# 1.0 * 1.0 * 1.0 = 0.5 -- NOT 0.875. The old 1.75 / 0.875
	# values survive in the hydrogen-seeded case below, where
	# a full store folds the booster row to 1.0, capped by the
	# power min 0.5 (BuildingComp.java:1986) to
	# optionalEfficiency 0.5. Both drills stamp facing_amount
	# 1: the N2202 shouldConsume gate (BeamDrill.java:271,
	# facingAmount > 0) closes on the freshly bound frame's
	# default 0 and the fold reads efficiency 0 (the N2256
	# proof precedent).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var drill_cell := Vector2i(28, 20)
	var drill := Sprite2D.new()
	game.add_child(drill)
	game.call("record_placed_block", drill, blocks_by_id["plasma-bore"], drill_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	beam_drill_build_state.source_beam_drill_bind_frame_state(drill, blocks_by_id["plasma-bore"])
	var drill_frame: Dictionary = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})

	# Half power: efficiency folds the power min 0.5, and the
	# advance moves warmup / multiplier / time with it. No
	# hydrogen in the store: the booster row folds
	# optionalEfficiency to 0, so the multiplier is 1.0 and
	# time rises 0.5 (N2300 fix of the stale 1.75 / 0.875).
	drill_frame["power_status"] = 0.5
	drill_frame["facing_amount"] = 1
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_advances_warmup_and_time"] = is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(drill_frame.get("warmup", -1.0)), 1.0 / 60.0) and is_equal_approx(float(drill_frame.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("time", -1.0)), 0.5)

	# --- Hydrogen-seeded live tick (N2300): the same
	# half-power drill with a FULL hydrogen store pins the old
	# values instead of deleting them (the N2252 precedent).
	# The booster row reads 1.0 (held 10.0 >> the 0.25f/60f
	# per-frame demand, Blocks.java:3049), capped by the power
	# min 0.5 (BuildingComp.java:1986) to optionalEfficiency
	# 0.5, so the multiplier is lerp(1, 2.5, 0.5) = 1.75 and
	# time rises 0.5 * 1.0 * 1.0 * 1.75 = 0.875. Each key gets
	# its own drill: one tick call re-ticks every placed drill,
	# so the first key is read before this second tick (the
	# N2256 proof precedent).
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var seeded_cell := Vector2i(22, 20)
	var seeded := Sprite2D.new()
	game.add_child(seeded)
	game.call("record_placed_block", seeded, blocks_by_id["plasma-bore"], seeded_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(seeded, blocks_by_id["plasma-bore"])
	var seeded_frame: Dictionary = seeded.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var seeded_liquids: Dictionary = seeded.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(seeded_liquids, hydrogen_id, 10.0)
	seeded_frame["power_status"] = 0.5
	seeded_frame["facing_amount"] = 1
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	seeded_frame = seeded.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_with_hydrogen_pins_boost_values"] = is_equal_approx(float(seeded_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(seeded_frame.get("optional_efficiency", -1.0)), 0.5) and is_equal_approx(float(seeded_frame.get("warmup", -1.0)), 1.0 / 60.0) and is_equal_approx(float(seeded_frame.get("multiplier", -1.0)), 1.75) and is_equal_approx(float(seeded_frame.get("time", -1.0)), 0.875)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
