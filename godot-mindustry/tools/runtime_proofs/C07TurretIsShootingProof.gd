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

	# --- Turret isShooting flag (N2277): TurretBuild.updateTile()
	# (Turret.java:490-615) sets the shooting flag at the head of
	# the tick, first line after the validateTarget verdict:
	# `isShooting = alwaysShooting || (unit.controller()
	# instanceof Player ? unit.isShooting() : logicControlled()
	# ? logicShooting : target != null);` (Turret.java:492).
	# alwaysShooting is `public boolean alwaysShooting = false;`
	# (:103, duo never overrides it); controlled() is
	# `return unit.isPlayer();` (:441-443); logicControlled() is
	# `return logicControlTime > 0;` (:445-447); logicShooting is
	# `public boolean logicShooting = false;` (:288, set by the
	# control() setters :384/:394, N2264). The flag feeds the
	# warmup target (:502) and shouldConsume (:364-366), but the
	# driver had no frame["is_shooting"] stamp and no standalone
	# pure function: N2253 folded the formula inline as the
	# warmup call's is_shooting arg. This slice adds the pure
	# function plus one driver tick right after the validateTarget
	# block and before the N2265 efficiency fold, and rewires the
	# warmup call to read the stamped key. The direct
	# pure-function calls pin the value behind the driver
	# observables below: a duo with a target is shooting / no
	# target is not / a logic-controlled duo with logicShooting
	# false is not shooting even with a target.

	# The direct pure-function calls pin the value behind the
	# driver observables below.
	var direct_duo_target: Dictionary = turret_build_state.source_turret_is_shooting_state(false, false, false, false, false, true)
	var direct_no_target: Dictionary = turret_build_state.source_turret_is_shooting_state(false, false, false, false, false, false)
	var direct_logic_controlled: Dictionary = turret_build_state.source_turret_is_shooting_state(false, false, false, true, false, true)

	# A duo with a target is shooting -- directly (no player,
	# no logic, has_target true -> true).
	proof["is_shooting_duo_target"] = bool(direct_duo_target.get("is_shooting", false)) == true
	# No target is not shooting -- directly (has_target false
	# -> false).
	proof["is_shooting_no_target"] = bool(direct_no_target.get("is_shooting", true)) == false
	# A logic-controlled duo with logicShooting false is not
	# shooting even with a target -- directly (the logic branch
	# overrides the target branch).
	proof["is_shooting_logic_controlled"] = bool(direct_logic_controlled.get("is_shooting", true)) == false

	# One duo segment, live on the driver: the isShooting tick
	# runs right after the validateTarget block, so the frame
	# carries a live is_shooting after a single tick.
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

	# The is_shooting key is stamped on the frame after the
	# tick, as a live key -- not just computed by the pure
	# function. This duo has no target, so the stamped value
	# is false.
	proof["is_shooting_stamped_to_frame"] = frame.has("is_shooting") and bool(frame.get("is_shooting", true)) == false

	# Logic control, live: set the previous tick's
	# logic_control_time to 120.0 and logic_shooting to true on
	# the frame, then tick once more. The isShooting tick
	# derives logicControlled LIVE from that value (the N2261
	# decay tick runs later in the driver), so the duo shoots
	# with no target -- proving the live derivation from
	# logic_control_time, not a stamped key.
	frame["logic_control_time"] = 120.0
	frame["logic_shooting"] = true
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["is_shooting_logic_live"] = bool(frame.get("is_shooting", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretIsShootingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
