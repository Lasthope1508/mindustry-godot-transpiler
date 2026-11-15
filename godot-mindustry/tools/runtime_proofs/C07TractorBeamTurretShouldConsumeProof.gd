extends Node

const main_scene := preload("res://scenes/Main.tscn")
const tractor_beam_turret_build_state := preload("res://src/game/SourceTractorBeamTurretBuildState.gd")
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

	# --- Pure shouldConsume gate (N2218):
	# TractorBeamBuild.shouldConsume()
	# (TractorBeamTurret.java:141-143, `public boolean
	# shouldConsume(){` with `return super.shouldConsume() &&
	# target != null;`, TractorBeamTurret.java:142) -- the gate
	# reads the live target AND the super default. The super
	# is the BuildingComp default `return enabled;`
	# (BuildingComp.java:755-756): the chain is
	# TractorBeamBuild (TractorBeamTurret.java:71, `public
	# class TractorBeamBuild extends BaseTurretBuild{`) ->
	# BaseTurretBuild (BaseTurret.java:113, `public class
	# BaseTurretBuild extends Building implements Ranged,
	# RotBlock{`) -> Building; neither BaseTurret.java nor
	# ReloadTurret.java overrides shouldConsume.
	# Turret.TurretBuild.shouldConsume() (Turret.java:364) is
	# NOT in this chain -- the tractor beam extends
	# BaseTurret, NOT Turret. The field is `public @Nullable
	# Unit target;` (TractorBeamTurret.java:72) -- the target
	# is a UNIT. The gate reads frame["enabled"] internal
	# (the super default, the N2212 RepairTurret precedent).
	# The gate reads only the null-ness of frame["target"], so
	# the present-target fixture below is a minimal test-only
	# Dictionary -- no real Unit is built; the port has no
	# live retarget on the building frame yet (the
	# Units.closestEnemy retarget every retargetTime 5f is
	# the updateTile advance, TractorBeamTurret.java:78-139,
	# and waits for its own slice).
	var has_target: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_should_consume_state({"target": {"type": "dart"}})
	proof["gate_true_when_target_present"] = bool(has_target.get("should_consume", false)) and bool(has_target.get("has_target", false))

	var no_target: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_should_consume_state({"target": null})
	proof["gate_false_when_target_null"] = bool(no_target.get("should_consume", true)) == false and bool(no_target.get("has_target", true)) == false

	var disabled_has_target: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_should_consume_state({"target": {"type": "dart"}, "enabled": false})
	proof["gate_false_when_disabled"] = bool(disabled_has_target.get("should_consume", true)) == false and bool(disabled_has_target.get("has_target", false))

	# --- Live tick: parallax is a TractorBeamTurret with a
	# power consumer (consumePower 3.3f), placed live; the
	# tick driver is called directly (as the N2147/N2148/
	# N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/
	# N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/
	# N2169/N2170/N2171/N2172/N2173/N2174 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The tractor-beam tick models
	# no other consumers, so with a power consumer the first
	# pass holds only the power row; when the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var parallax_cell := Vector2i(28, 21)
	var parallax := Sprite2D.new()
	game.add_child(parallax)
	game.call("record_placed_block", parallax, blocks_by_id["parallax"], parallax_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the target on it).
	tractor_beam_turret_build_state.source_tractor_beam_turret_bind_frame_state(parallax, blocks_by_id["parallax"])
	var parallax_frame: Dictionary = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})

	# A freshly bound frame carries the target key defaulting
	# to null (the Java field default) -- no target yet, so
	# the gate reads false and the turret does not consume.
	proof["frame_target_default_null"] = parallax_frame.has("target") and parallax_frame["target"] == null

	# No target: gate false -> efficiency 0 even at half power.
	parallax_frame["target"] = null
	parallax_frame["power_status"] = 0.5
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_frame = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(parallax_frame.get("efficiency", -1.0)), 0.0)

	# Target present: gate true -> efficiency folds the power
	# min 0.5 (the N2152 power fold preserved).
	parallax_frame["target"] = {"type": "dart"}
	parallax_frame["power_status"] = 0.5
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_frame = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(parallax_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TractorBeamTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
