extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- Pure shouldConsume gate (N2217):
	# PointDefenseBuild.shouldConsume()
	# (PointDefenseTurret.java:105-107, `public boolean
	# shouldConsume(){` with `return super.shouldConsume() &&
	# target != null;`, PointDefenseTurret.java:106) -- the gate
	# reads the enabled flag through super AND the live bullet
	# target. The field is `public @Nullable Bullet target;`
	# (PointDefenseTurret.java:59) -- the target is a BULLET,
	# not a Unit -- on PointDefenseBuild (`public class
	# PointDefenseBuild extends ReloadTurretBuild{`,
	# PointDefenseTurret.java:58). `super` is the BuildingComp
	# default (`return enabled;`, BuildingComp.java:755-756):
	# the chain runs PointDefenseBuild -> ReloadTurretBuild ->
	# BaseTurretBuild -> Building, and neither ReloadTurret.java
	# nor BaseTurret.java overrides shouldConsume, so the gate
	# is `enabled && target != null`. Turret.TurretBuild.
	# shouldConsume() (Turret.java:364-366, `return isShooting
	# || reloadCounter < reload;`) is NOT in this chain --
	# PointDefenseTurret extends ReloadTurret, not Turret. The
	# gate reads only the null-ness of frame["target"], so the
	# present-target fixture below is a minimal test-only
	# Dictionary -- no real Bullet is built; the port has no
	# live bullet-target retarget on the building frame yet
	# (the Groups.bullet scan / isAdded clear is the updateTile
	# advance, PointDefenseTurret.java:62-103, and waits for
	# its own slice).
	var has_target: Dictionary = point_defense_turret_build_state.source_point_defense_turret_should_consume_state({"target": {"type": "bullet"}})
	proof["gate_true_when_target_present"] = bool(has_target.get("should_consume", false)) and bool(has_target.get("has_target", false))

	var no_target: Dictionary = point_defense_turret_build_state.source_point_defense_turret_should_consume_state({"target": null})
	proof["gate_false_when_target_null"] = bool(no_target.get("should_consume", true)) == false and bool(no_target.get("has_target", true)) == false

	var disabled_has_target: Dictionary = point_defense_turret_build_state.source_point_defense_turret_should_consume_state({"target": {"type": "bullet"}, "enabled": false})
	proof["gate_false_when_disabled"] = bool(disabled_has_target.get("should_consume", true)) == false and bool(disabled_has_target.get("has_target", false))

	# --- Live tick: segment is a PointDefenseTurret with a
	# power consumer (consumePower 8f), placed live; the tick
	# driver is called directly (as the N2151 power proof
	# does), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The point-defense
	# tick models no other consumers, so with a power consumer
	# the first pass holds only the power row; when the gate
	# is false updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var segment_cell := Vector2i(28, 20)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], segment_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the target on it).
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	var segment_frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})

	# A freshly bound frame carries the target key defaulting
	# to null (the Java field default) -- no target yet, so
	# the gate reads false and the segment does not consume.
	proof["frame_target_default_null"] = segment_frame.has("target") and segment_frame["target"] == null

	# No target: gate false -> efficiency 0 even at half power.
	segment_frame["target"] = null
	segment_frame["power_status"] = 0.5
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(segment_frame.get("efficiency", -1.0)), 0.0)

	# Target present: gate true -> efficiency folds the power
	# min 0.5 (the N2151 power fold preserved).
	segment_frame["target"] = {"type": "bullet"}
	segment_frame["power_status"] = 0.5
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(segment_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
