extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret drawBeam jitter (N2251):
	# The jitter is the three Rand draws seeded by id + target
	# id (`rand.setSeed(id + (target instanceof Entityc e ?
	# e.id() : 0));`, RepairTurret.java:111), guarded by the
	# target (`if(target != null){`, RepairTurret.java:113):
	# the first draw is the angle (`rand.random(360f) +
	# Time.time/2f,`, RepairTurret.java:122), the second and
	# third feed the table-sin amplitude (`Mathf.sin(Time.time
	# + rand.random(200f), 55f, rand.random(target.hitSize() *
	# 0.2f, target.hitSize() * 0.45f))`, RepairTurret.java:123),
	# and the offset is trns(angle, amplitude) rotated by the
	# target rotation (`).rotate(target instanceof Rotc rot ?
	# rot.rotation() : 0f));`, RepairTurret.java:124). arc Rand
	# is xorshift128+ (Rand.java), Time.time is the tick
	# counter (Time.java:15, 60fps units). The proof calls the
	# pure function with explicit params (no live tick: the
	# frame carries no building id, target id, target rotation
	# or absolute tick yet, so there is no driver line). The
	# oracle draws below are the Python-model vectors (5/5
	# pass), verified live in Godot by the throwaway probe
	# before this slice was built.

	# Seed 10 (building id 7 + target id 3), time 0, hitSize
	# 10: the three draws match the oracle -- r1 257.9808,
	# r2 38.3020, r3 3.0084.
	var seed_10: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_jitter_state(7, 3, 0.0, 10.0, 0.0)
	proof["rand_draws_match_seed_10_oracle"] = is_equal_approx(float(seed_10.get("rand_angle_draw", -1.0)), 257.9808) and is_equal_approx(float(seed_10.get("rand_time_draw", -1.0)), 38.3020) and is_equal_approx(float(seed_10.get("rand_hit_draw", -1.0)), 3.0084)

	# Seed 10, time 0, target rotation 0: the jitter offset is
	# trns(257.9808, 1.9294) -- (-0.401776, -1.887106).
	proof["jitter_offset_seed_10_time_0"] = (seed_10.get("jitter_offset", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(-0.401776, -1.887106))

	# The offset rotates with the target rotation: target
	# rotation 90 turns (-0.401776, -1.887106) into (1.887106,
	# -0.401776).
	var rot_90: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_jitter_state(7, 3, 0.0, 10.0, 90.0)
	proof["jitter_offset_rotates_with_target_rotation"] = (rot_90.get("jitter_offset", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(1.887106, -0.401776))

	# The offset changes with time: time 60 moves the angle to
	# 287.9808 and the amplitude to 2.9382, so the offset is
	# (0.907019, -2.794698).
	var time_60: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_jitter_state(7, 3, 60.0, 10.0, 0.0)
	proof["jitter_offset_changes_with_time"] = (time_60.get("jitter_offset", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(0.907019, -2.794698))

	# The angle is the first draw plus half the time: at time
	# 60 the angle is 257.9808 + 30 = 287.9808.
	proof["jitter_angle_is_rand_draw_plus_half_time"] = is_equal_approx(float(time_60.get("jitter_angle_deg", -1.0)), 287.9808) and is_equal_approx(float(seed_10.get("jitter_angle_deg", -1.0)), 257.9808)

	# The amplitude is the table sin of (time + second draw) /
	# 55 scaled by the third draw: 1.9294 at time 0, 2.9382 at
	# time 60.
	proof["jitter_amplitude_uses_table_sin"] = is_equal_approx(float(seed_10.get("jitter_amplitude", -1.0)), 1.9294) and is_equal_approx(float(time_60.get("jitter_amplitude", -1.0)), 2.9382)

	# The same seed gives the same offset: the Rand sequence is
	# deterministic per setSeed.
	var seed_10_again: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_jitter_state(7, 3, 0.0, 10.0, 0.0)
	proof["jitter_is_deterministic_same_seed"] = (seed_10_again.get("jitter_offset", Vector2.ZERO) as Vector2) == (seed_10.get("jitter_offset", Vector2.ONE) as Vector2) and is_equal_approx(float(seed_10_again.get("rand_angle_draw", -1.0)), float(seed_10.get("rand_angle_draw", -2.0)))

	# A different seed gives a different offset: building id 8
	# + target id 3 seeds 11, whose first draw is 112.6388,
	# not 257.9808.
	var seed_11: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_jitter_state(8, 3, 0.0, 10.0, 0.0)
	proof["jitter_differs_across_seeds"] = is_equal_approx(float(seed_11.get("rand_angle_draw", -1.0)), 112.6388) and not (seed_11.get("jitter_offset", Vector2.ZERO) as Vector2).is_equal_approx(seed_10.get("jitter_offset", Vector2.ZERO) as Vector2)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretDrawBeamJitterProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
