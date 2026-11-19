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

	# --- Turret charge advance (N2259): N2250-N2258 never
	# stamped frame["charge"] / frame["charging"] on the new duo
	# driver -- the warmup tick (N2253) already read
	# frame["charging"] and the aim call already passed it, but
	# the value was always the false default because no tick
	# stamped it, and the shoot gate (:733) also reads
	# !charging(). TurretBuild.updateTile() (Turret.java:490-615)
	# advances the charge every tick, after the recoil/heat
	# decay and before the recoilOffset draw:
	# `charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;`
	# (Turret.java:527), where charging is
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
	# (:715-717). The field is
	# `public float shootWarmup, charge, warmupHold = 0f;`
	# (:286), the queue counter is
	# `public int queuedBullets = 0;` (:293), and the delay is
	# `public float firstShotDelay = 0;`
	# (ShootPattern.java:11, `/** delay in ticks before first shot */`)
	# -- duo never overrides it (`shoot = new ShootAlternate(3.5f);`,
	# Blocks.java:3299, inside the duo block 3257-3330;
	# ShootAlternate only sets the spread). approachDelta is
	# `public static float approachDelta(float from, float to, float speed){`
	# / `return approach(from, to, Time.delta * speed);`
	# (arc Mathf.java:420-422) with approach
	# `public static float approach(float from, float to, float speed){`
	# / `return from + Mathf.clamp(to - from, -speed, speed);`
	# (:415-417), so a charging tick moves the charge toward 1
	# by delta / firstShotDelay, never past 1, and a
	# non-charging tick resets it to 0 outright (not a decay).
	# Java order :519/:520-525 decay, :526 heat, :527 charge,
	# :532 offset -- so the charge tick runs AFTER the N2256
	# multi-recoil decay tick and BEFORE the N2258 recoilOffset
	# tick, and BEFORE the aim/shoot call, so aim reads a fresh
	# charging flag. With duo, queuedBullets is 0 at every tick
	# boundary (every bullet delay is firstShotDelay + shotDelay
	# * i = 0 + 0 = 0, so bullet() runs synchronously inside
	# shoot() and the queue nets to 0 before the tick ends),
	# and firstShotDelay is 0, so the live duo charge is always
	# 0 and charging always false -- but the frame still gets a
	# live stamp, which the warmup tick and the shoot gate read.
	# The direct pure-function calls pin the advance behind the
	# driver observables below: a non-charging tick resets the
	# charge to 0 even from 0.5, a queued bullet with
	# firstShotDelay 0 still charges nothing, a charging tick
	# moves the charge toward 1 by exactly delta /
	# firstShotDelay (1/60 for a 60-tick delay over one second),
	# the charge clamps at 1 and never passes it, and the
	# charge builds on the previous charge instead of from 0.

	# The direct pure-function calls pin the formula behind the
	# driver observables below.
	var direct_not_charging: Dictionary = turret_build_state.source_turret_charge_state(0.5, 0, 10.0, 1.0 / 60.0)
	var direct_delay_zero: Dictionary = turret_build_state.source_turret_charge_state(0.5, 5, 0.0, 1.0 / 60.0)
	var direct_advance: Dictionary = turret_build_state.source_turret_charge_state(0.0, 1, 60.0, 1.0)
	var direct_clamp: Dictionary = turret_build_state.source_turret_charge_state(0.99, 1, 60.0, 1.0)
	var direct_previous: Dictionary = turret_build_state.source_turret_charge_state(0.5, 1, 60.0, 1.0)
	var direct_gate_true: Dictionary = turret_build_state.source_turret_charge_state(0.0, 1, 60.0, 1.0)
	var direct_gate_no_queue: Dictionary = turret_build_state.source_turret_charge_state(0.0, 0, 60.0, 1.0)
	var direct_gate_no_delay: Dictionary = turret_build_state.source_turret_charge_state(0.0, 1, 0.0, 1.0)

	# A non-charging tick resets the charge to 0 outright --
	# directly (0.5 with no queued bullet -> 0.0, charging
	# false), not a decay.
	proof["charge_zero_when_not_charging"] = absf(float(direct_not_charging.get("charge", 9.9))) < 0.0001 and not bool(direct_not_charging.get("charging", true))
	# A queued bullet with firstShotDelay 0 still charges
	# nothing -- directly (0.5, queued 5, delay 0 -> 0.0,
	# charging false), so firstShotDelay <= 0 never divides
	# by zero.
	proof["charge_zero_when_first_shot_delay_zero"] = absf(float(direct_delay_zero.get("charge", 9.9))) < 0.0001 and not bool(direct_delay_zero.get("charging", true))
	# A charging tick moves the charge toward 1 by exactly
	# delta / firstShotDelay -- directly (0.0, queued 1,
	# delay 60, delta 1.0 -> 1/60).
	proof["charge_advances_toward_one"] = absf(float(direct_advance.get("charge", 9.9)) - 1.0 / 60.0) < 0.0001 and bool(direct_advance.get("charging", false))
	# The charge clamps at 1, never past it -- directly (0.99,
	# queued 1, delay 60, delta 1.0 -> 1.0, not 1.00667).
	proof["charge_clamps_at_one"] = absf(float(direct_clamp.get("charge", 9.9)) - 1.0) < 0.0001
	# The charge builds on the previous charge, not from 0 --
	# directly (0.5, queued 1, delay 60, delta 1.0 ->
	# 0.5 + 1/60).
	proof["charge_uses_previous_charge"] = absf(float(direct_previous.get("charge", 9.9)) - (0.5 + 1.0 / 60.0)) < 0.0001
	# The charging flag matches the gate exactly: true only
	# when queuedBullets > 0 AND firstShotDelay > 0 -- directly
	# (queued 1 + delay 60 -> true; queued 0 + delay 60 ->
	# false; queued 1 + delay 0 -> false).
	proof["charging_flag_matches_gate"] = bool(direct_gate_true.get("charging", false)) and not bool(direct_gate_no_queue.get("charging", true)) and not bool(direct_gate_no_delay.get("charging", true))

	# One duo segment, live on the driver: the charge tick
	# runs before the aim call, so the frame carries a live
	# charge + charging stamp after a single tick.
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

	# The charge + charging are stamped on the frame after the
	# tick, as live keys -- not just computed by the pure
	# function.
	proof["charge_stamped_to_frame"] = frame.has("charge") and frame.has("charging")
	# The duo live tick stamps charge 0 + charging false:
	# duo firstShotDelay is 0 and queuedBullets is 0 at every
	# tick boundary, so charging is false and the charge resets
	# to 0 -- the stamp is live, not a default left behind.
	proof["charge_duo_live_zero"] = absf(float(frame.get("charge", 9.9))) < 0.0001 and not bool(frame.get("charging", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretChargeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
