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

	# --- Turret logicControlTime decay (N2261): N2250-N2260 never
	# decayed the logic-control timer on the new duo driver -- the
	# logicControlled() read had no live timer frame key.
	# TurretBuild.updateTile() (Turret.java:490-615) decays the
	# timer every tick, after the recoilOffset draw and before the
	# heat-requirement fold:
	# `if(logicControlTime > 0){`
	# `logicControlTime -= Time.delta;`
	# (Turret.java:534-536). The field is
	# `public float curRecoil, heat, logicControlTime = -1;`
	# (:284), so the timer starts at -1 (never logic-controlled)
	# and only a logic shoot control arms it
	# (`logicControlTime = logicControlCooldown;`, :384/:394, with
	# `public final static float logicControlCooldown = 60 * 2;`,
	# :38 -- 120 ticks of logic control). The reader is
	# `logicControlled()` (`return logicControlTime > 0;`,
	# :445-447), so the decay is observable through the isShooting
	# gate (:492) on the very next tick. The decay has NO clamp: a
	# timer of 0.001 with delta 1/60 lands negative (0.001 -
	# 0.0166... = -0.0156...), exactly what Java does -- the next
	# tick's guard then leaves it alone. Java order :532 offset,
	# :534-536 decay, :595-596 turnToTarget, :601/:609
	# updateShooting -- so the decay tick runs AFTER the N2258
	# recoilOffset tick and BEFORE the aim/shoot call, and the
	# isShooting gate sees a fresh timer. The direct pure-function
	# calls pin the decay behind the driver observables below: the
	# timer decays by delta while positive / a negative timer is
	# untouched / a zero timer is untouched / a near-zero timer
	# decays past zero with no clamp / the decayed timer still
	# reads logic-controlled while positive / a timer decayed past
	# zero reads not-controlled.

	# The direct pure-function calls pin the formula behind the
	# driver observables below.
	var direct_positive: Dictionary = turret_build_state.source_turret_logic_control_time_state(120.0, 1.0 / 60.0)
	var direct_negative: Dictionary = turret_build_state.source_turret_logic_control_time_state(-1.0, 1.0 / 60.0)
	var direct_zero: Dictionary = turret_build_state.source_turret_logic_control_time_state(0.0, 1.0 / 60.0)
	var direct_near_zero: Dictionary = turret_build_state.source_turret_logic_control_time_state(0.001, 1.0 / 60.0)

	# The timer decays by delta while positive -- directly (120.0
	# in, delta 1/60 -> 120.0 - 1/60).
	proof["logic_control_time_decays_when_positive"] = absf(float(direct_positive.get("logic_control_time", 9.9)) - (120.0 - 1.0 / 60.0)) < 0.0001
	# A negative timer is untouched -- directly (-1.0 in, delta
	# 1/60 -> -1.0, the field default).
	proof["logic_control_time_unchanged_when_negative"] = absf(float(direct_negative.get("logic_control_time", 9.9)) - (-1.0)) < 0.0001
	# A zero timer is untouched -- directly (0.0 in, delta 1/60
	# -> 0.0, the guard is strict > 0).
	proof["logic_control_time_unchanged_when_zero"] = absf(float(direct_zero.get("logic_control_time", 9.9)) - 0.0) < 0.0001
	# A near-zero timer decays past zero with no clamp --
	# directly (0.001 in, delta 1/60 -> -0.0156..., negative).
	proof["logic_control_time_can_go_negative"] = float(direct_near_zero.get("logic_control_time", 9.9)) < 0.0
	# The decayed timer still reads logic-controlled while
	# positive -- directly (120.0 decayed once is still > 0, so
	# logicControlled() stays true).
	proof["logic_controlled_true_while_positive"] = float(direct_positive.get("logic_control_time", 9.9)) > 0.0
	# A timer decayed past zero reads not-controlled -- directly
	# (0.001 decayed once is < 0, so logicControlled() is false).
	proof["logic_controlled_false_when_expired"] = not (float(direct_near_zero.get("logic_control_time", 9.9)) > 0.0)

	# One duo segment, live on the driver: the decay tick runs
	# after the recoilOffset tick and before the aim call, so the
	# frame carries a live timer after a single tick.
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

	# Arm the timer the way a logic shoot control would
	# (`logicControlTime = logicControlCooldown;`, :384/:394 --
	# the control() setters are their own slices, so the proof
	# arms the frame directly); the decay tick then has a live
	# positive timer to decay. The frame Dictionary is a
	# reference, so this stamp survives into the tick.
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	frame["logic_control_time"] = 120.0

	# One shared tick wires team_id / cheating / enabled onto
	# the frame (and charges the reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The timer key is stamped on the frame after the tick, as a
	# live key -- not just computed by the pure function.
	proof["logic_control_time_stamped_to_frame"] = frame.has("logic_control_time")
	# The duo live tick decays an armed timer by one delta: the
	# frame was armed to 120.0 before the tick, so after one tick
	# it reads 120.0 - 1/60 -- the stamp is live, not a default
	# left behind.
	proof["logic_control_time_duo_live"] = absf(float(frame.get("logic_control_time", 9.9)) - (120.0 - 1.0 / 60.0)) < 0.0001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretLogicControlTimeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
