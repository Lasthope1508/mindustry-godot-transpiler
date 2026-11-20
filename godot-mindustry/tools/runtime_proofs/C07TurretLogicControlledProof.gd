extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret logicControlled() live derivation (N2278):
	# `public boolean logicControlled(){ return logicControlTime
	# > 0; }` (Turret.java:445-447) on the field `public float
	# curRecoil, heat, logicControlTime = -1;` (:284, set to
	# logicControlCooldown by the control() setters :384/:394,
	# N2264; decayed :534-536 by the N2261 tick). It rescues
	# validateTarget (`return !Units.invalidateTarget(target,
	# canHeal() ? Team.derelict : team, x, y) || controlled() ||
	# logicControlled();`, :631-633, N2251) and picks the logic
	# branch of isShooting (:492, N2277) -- but the driver
	# validate call passed `bool(frame.get("logic_controlled",
	# false))` while frame["logic_controlled"] was NEVER stamped
	# anywhere, so a logic-controlled duo with an
	# otherwise-invalid target wrongly failed validation. This
	# slice ports the one-line Java method as a pure function and
	# stamps it live on the frame right before the validate call
	# (Java order :491 validate before :534-536 decay, so the
	# stamp reads the PREVIOUS tick's logic_control_time -- the
	# N2261 decay tick runs later in the driver, the same
	# precedent as N2277 / N2265). The direct pure-function calls
	# pin the value behind the driver observables below: a
	# positive time is controlled / zero is not (Java `> 0`) /
	# the -1 default is not.

	# The direct pure-function calls pin the value behind the
	# driver observables below.
	var direct_positive: Dictionary = turret_build_state.source_turret_logic_controlled_state(120.0)
	var direct_zero: Dictionary = turret_build_state.source_turret_logic_controlled_state(0.0)
	var direct_negative: Dictionary = turret_build_state.source_turret_logic_controlled_state(-1.0)

	# A positive logic_control_time is controlled -- directly.
	proof["logic_controlled_positive"] = bool(direct_positive.get("logic_controlled", false)) == true
	# Zero is not controlled -- directly (Java `> 0`, not `>= 0`).
	proof["logic_controlled_zero"] = bool(direct_zero.get("logic_controlled", true)) == false
	# The -1 field default is not controlled -- directly.
	proof["logic_controlled_negative"] = bool(direct_negative.get("logic_controlled", true)) == false

	# One duo segment, live on the driver: the stamp tick runs
	# right before the validateTarget call, so the frame carries
	# a live logic_controlled after a single tick.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)
	turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["duo"])

	# One shared tick wires team_id / cheating / enabled onto
	# the frame (and charges the reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The logic_controlled key is stamped on the frame after the
	# tick, as a live key -- not just computed by the pure
	# function. This duo has the -1 default time, so the stamped
	# value is false; setting the time to 120.0 and ticking once
	# more stamps true (the N2261 decay tick runs later in the
	# driver, so the 120.0 survives into the stamp as ~119.98,
	# still > 0).
	var stamped_default: bool = frame.has("logic_controlled") and bool(frame.get("logic_controlled", true)) == false
	frame["logic_control_time"] = 120.0
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["logic_controlled_stamped_to_frame"] = stamped_default and frame.has("logic_controlled") and bool(frame.get("logic_controlled", false)) == true

	# The validate rescue, live: a dead-Healthc target due east
	# would fail validation on its own, but the duo is
	# logic-controlled (logic_control_time still ~119.98 after
	# the decay tick), so the driver must NOT clear it and the
	# aim must run (dest 90) -- proving the validate call reads
	# the live derivation, not the never-stamped default false.
	frame["target"] = {"x": segment.position.x + 100.0, "y": segment.position.y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frame["has_target"] = true
	frame["target_health_valid"] = false
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["logic_controlled_driver_rescues_validate"] = frame.get("target", "x") != null and bool(frame.get("has_target", false)) and absf(float(frame.get("dest", -999.0)) - 90.0) < 0.001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretLogicControlledProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
