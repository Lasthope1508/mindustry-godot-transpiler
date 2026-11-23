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

	# --- Turret isActive() derivation (N2280):
	# `public boolean isActive(){ return (target != null ||
	# wasShooting) && enabled && activationTimer <= 0; }`
	# (Turret.java:449-450) on the fields `public boolean
	# wasShooting, isShooting;` (Turret.java:292, set false
	# at :517 and true at :600/:608), `transient boolean
	# enabled = true;` (BuildingComp.java:77) and `public
	# float activationTimer = 0;` (BaseTurret.java:115,
	# decayed live by the N2279 tick). Only LaserTurret
	# consumes it in Java (`if(bullets.any() ||
	# isActive()) return true;`, LaserTurret.java:55 in
	# shouldConsume() :53-57); duo is an ItemTurret with no
	# consumer, so this slice is stamp-only like N2274-N2276:
	# one pure function plus one driver tick, no consumer
	# rewired. The direct pure-function calls pin the value
	# behind the driver observables below: a target alone /
	# was shooting alone makes the turret active, while a
	# disabled turret or a positive activation timer does
	# not -- each clause read live from the frame.

	# The direct pure-function calls pin the value behind the
	# driver observables below.
	var direct_target: Dictionary = turret_build_state.source_turret_is_active_state(true, false, true, 0.0)
	var direct_was_shooting: Dictionary = turret_build_state.source_turret_is_active_state(false, true, true, 0.0)
	var direct_disabled: Dictionary = turret_build_state.source_turret_is_active_state(true, false, false, 0.0)
	var direct_timer: Dictionary = turret_build_state.source_turret_is_active_state(true, false, true, 120.0)

	# A target alone makes the turret active -- directly.
	proof["is_active_true_with_target"] = bool(direct_target.get("is_active", false)) == true
	# Was shooting alone makes the turret active -- directly.
	proof["is_active_true_when_was_shooting"] = bool(direct_was_shooting.get("is_active", false)) == true
	# A disabled turret is not active, even with a target -- directly.
	proof["is_active_false_when_disabled"] = bool(direct_disabled.get("is_active", true)) == false
	# A positive activation timer keeps the turret inactive -- directly.
	proof["is_active_false_when_timer_positive"] = bool(direct_timer.get("is_active", true)) == false

	# --- Merged from the local N2328 proof (merge 2026-11-23):
	# the local cases the remote direct calls do not cover. The
	# local N2328 signature was (frame, target_is_null,
	# is_shooting, activation_timer) with enabled read from the
	# frame; here they are re-expressed on the kept remote
	# signature (has_target, was_shooting, enabled,
	# activation_timer). The other local cases duplicate remote
	# keys (active_with_target / active_while_shooting /
	# inactive_when_disabled / inactive_while_timer_positive /
	# active_at_timer_zero) and are not repeated.
	# No target and not shooting: nothing to shoot at and no
	# previous-tick shot, enabled, timer 0 -> false.
	var idle: Dictionary = turret_build_state.source_turret_is_active_state(false, false, true, 0.0)
	proof["inactive_no_target_not_shooting"] = bool(idle.get("is_active", true)) == false
	# A negative activation timer is also elapsed: below zero
	# counts as active, matching Java `activationTimer <= 0`.
	var negative: Dictionary = turret_build_state.source_turret_is_active_state(true, false, true, -1.0)
	proof["active_at_activation_timer_negative"] = bool(negative.get("is_active", false)) == true
	# The result carries ONLY the one is_active key: no frame
	# echo, no extra state.
	proof["returns_only_one_key"] = direct_target.size() == 1

	# One duo segment, live on the driver: the is_active tick
	# runs right after the was_shooting stamp, once every
	# input is its final value for the tick, so the frame
	# carries the verdict as a live key after a single tick.
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

	# The verdict is stamped on the frame after the tick, as
	# a live key -- not just computed by the pure function.
	# This duo has no target and is not shooting, so the
	# stamped verdict is false.
	proof["is_active_stamped_to_frame"] = frame.has("is_active") and bool(frame.get("is_active", true)) == false

	# Give the duo a target in range (duo sits at (224, 168);
	# (300, 200) is ~82 tiles inside the 160 range) and tick
	# once more: validateTarget keeps it (N2251 -- a non-null
	# target dict with has_target true, a different team,
	# valid health, targetable), so the stamped verdict turns
	# true. Then set the activation timer to 120.0 and tick
	# again: the N2279 tick decays it by 1/60 and the
	# activation clause turns the stamped verdict false.
	frame["target"] = {"x": 300.0, "y": 200.0}
	frame["has_target"] = true
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var stamped_with_target: bool = frame.has("is_active") and bool(frame.get("is_active", false)) == true
	frame["activation_timer"] = 120.0
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["is_active_target_and_timer_stamped_to_frame"] = stamped_with_target and frame.has("is_active") and bool(frame.get("is_active", true)) == false and frame.has("activation_timer") and absf(float(frame.get("activation_timer", -999.0)) - (120.0 - 1.0 / 60.0)) < 0.001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretIsActiveProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
