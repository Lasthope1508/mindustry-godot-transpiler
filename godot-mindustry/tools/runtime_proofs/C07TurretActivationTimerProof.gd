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

	# --- Turret activationTimer decay (N2279):
	# `if(activationTimer > 0){ activationTimer -= Time.delta;
	# return; }` (Turret.java:561-564) on the field `public
	# float activationTimer = 0;` (BaseTurret.java:115, set to
	# activationTime in placed() :119-120), where `public float
	# activationTime = 0f;` (BaseTurret.java:27) is the class
	# default. Duo never overrides activationTime
	# (Blocks.java:3257-3331), and no turret def in Blocks.java
	# sets it above 0, so the duo timer is always 0.0 and the
	# gate never fires -- the same vacuous-guard precedent as
	# the N2270 heat fold and the N2263 heatReq fold: the tick
	# still stamps both keys so the frame mirrors the
	# TurretBuild fields. The timer decays by delta while
	# positive, with NO clamp (the N2261 precedent); the
	# elapsed verdict is the gate itself evaluated on the
	# INPUT timer -- Java returns before the rest of the tick
	# when the input is positive, even if this tick's decay
	# would cross zero. The early-return skip of the aim/shoot
	# half is NOT wired in this slice: the gate never fires
	# for duo, so restructuring the aim block for a
	# never-firing guard is churn, and it waits for a def
	# with activationTime > 0. The direct pure-function calls
	# pin the value behind the driver observables below: a
	# positive timer decays by delta / zero stays zero /
	# elapsed is true at zero and false while positive.

	# The direct pure-function calls pin the value behind the
	# driver observables below.
	var direct_positive: Dictionary = turret_build_state.source_turret_activation_timer_state(120.0, 1.0 / 60.0)
	var direct_zero: Dictionary = turret_build_state.source_turret_activation_timer_state(0.0, 1.0 / 60.0)

	# A positive timer decays by delta -- directly.
	proof["activation_timer_decays_when_positive"] = absf(float(direct_positive.get("activation_timer", -999.0)) - (120.0 - 1.0 / 60.0)) < 0.001
	# Zero stays zero -- directly (Java only subtracts while > 0).
	proof["activation_timer_unchanged_at_zero"] = absf(float(direct_zero.get("activation_timer", -999.0)) - 0.0) < 0.001
	# Elapsed is true at zero -- directly (the gate lets the tick proceed).
	proof["activation_timer_elapsed_at_zero"] = bool(direct_zero.get("activation_timer_elapsed", false)) == true
	# Elapsed is false while positive -- directly (Java returns early).
	proof["activation_timer_not_elapsed_when_positive"] = bool(direct_positive.get("activation_timer_elapsed", true)) == false

	# One duo segment, live on the driver: the decay tick runs
	# between the rotate sync and the aim call, so the frame
	# carries both live keys after a single tick.
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

	# Both keys are stamped on the frame after the tick, as
	# live keys -- not just computed by the pure function.
	# This duo has the 0.0 field default, so the stamped timer
	# is 0.0 and elapsed is true; setting the timer to 120.0
	# and ticking once more decays it by 1/60 and stamps
	# elapsed false (the gate verdict is evaluated on the
	# input timer, so it stays false for this tick).
	var stamped_default: bool = frame.has("activation_timer") and absf(float(frame.get("activation_timer", -999.0)) - 0.0) < 0.001 and frame.has("activation_timer_elapsed") and bool(frame.get("activation_timer_elapsed", false)) == true
	frame["activation_timer"] = 120.0
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["activation_timer_stamped_to_frame"] = stamped_default and frame.has("activation_timer") and absf(float(frame.get("activation_timer", -999.0)) - (120.0 - 1.0 / 60.0)) < 0.001 and frame.has("activation_timer_elapsed") and bool(frame.get("activation_timer_elapsed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretActivationTimerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
