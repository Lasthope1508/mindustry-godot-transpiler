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

	# --- Turret micro-accessors (N2297): four read accessors on
	# TurretBuild (Turret.java:277,
	# `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`):
	# warmup() (Turret.java:354-356, `return shootWarmup;`),
	# drawrot() (Turret.java:359-361, `return rotation - 90;`),
	# canControl() (Turret.java:376-378, `return
	# playerControllable;`), logicControlled()
	# (Turret.java:445-447, `return logicControlTime > 0;`).
	# Each is a pure function over explicit params (the
	# N2268/N2261 precedent): shoot_warmup is advanced by the
	# updateTile warmup leg (N2265), NOT here; rotation is the
	# RotComp float aim angle (RotComp.java:8), NOT the Building
	# int rotation 0-3 (BuildingComp.java:69); player_controllable
	# is the block-level Turret field (Turret.java:97, default
	# true); logic_control_time is the TurretBuild field
	# (Turret.java:284, default -1). NO driver tick line: read
	# accessors their callers read, not per-tick writes. The
	# proof calls the pure functions with synthetic frames (no
	# live tick).

	# warmup() returns shootWarmup as-is at 0.75.
	var warmup_mid: Dictionary = turret_build_state.source_turret_warmup_state({}, 0.75)
	proof["warmup_returns_shoot_warmup"] = is_equal_approx(float(warmup_mid.get("warmup", -1.0)), 0.75)

	# warmup() returns 0.0 at the Java field default.
	var warmup_zero: Dictionary = turret_build_state.source_turret_warmup_state({}, 0.0)
	proof["warmup_zero"] = is_equal_approx(float(warmup_zero.get("warmup", -1.0)), 0.0)

	# warmup() returns 1.0 at full warmup.
	var warmup_full: Dictionary = turret_build_state.source_turret_warmup_state({}, 1.0)
	proof["warmup_full"] = is_equal_approx(float(warmup_full.get("warmup", -1.0)), 1.0)

	# drawrot() subtracts 90: aim 180 draws at 90.
	var drawrot_ninety: Dictionary = turret_build_state.source_turret_drawrot_state({}, 180.0)
	proof["drawrot_ninety"] = is_equal_approx(float(drawrot_ninety.get("drawrot", 0.0)), 90.0)

	# drawrot() at aim 0 draws at -90 (the RotComp default).
	var drawrot_zero: Dictionary = turret_build_state.source_turret_drawrot_state({}, 0.0)
	proof["drawrot_zero"] = is_equal_approx(float(drawrot_zero.get("drawrot", 0.0)), -90.0)

	# drawrot() at aim 45 draws at -45.
	var drawrot_negative: Dictionary = turret_build_state.source_turret_drawrot_state({}, 45.0)
	proof["drawrot_negative"] = is_equal_approx(float(drawrot_negative.get("drawrot", 0.0)), -45.0)

	# canControl() passes the def through when true.
	var can_control_true: Dictionary = turret_build_state.source_turret_can_control_state({}, true)
	proof["can_control_true"] = bool(can_control_true.get("can_control", false)) == true

	# canControl() passes the def through when false.
	var can_control_false: Dictionary = turret_build_state.source_turret_can_control_state({}, false)
	proof["can_control_false"] = bool(can_control_false.get("can_control", true)) == false

	# logicControlled() is true while the timer is positive
	# (logicControlCooldown is 60 * 2 = 120).
	var logic_positive: Dictionary = turret_build_state.source_turret_logic_controlled_state({}, 120.0)
	proof["logic_controlled_positive"] = bool(logic_positive.get("logic_controlled", false)) == true

	# logicControlled() is false at the -1 Java field default.
	var logic_default: Dictionary = turret_build_state.source_turret_logic_controlled_state({}, -1.0)
	proof["logic_controlled_default"] = bool(logic_default.get("logic_controlled", true)) == false

	# logicControlled() is false at exactly 0: the comparison
	# is `> 0`, not `>= 0`.
	var logic_zero: Dictionary = turret_build_state.source_turret_logic_controlled_state({}, 0.0)
	proof["logic_controlled_zero"] = bool(logic_zero.get("logic_controlled", true)) == false

	# Each result carries ONLY its one key: no frame echo, no
	# extra state.
	proof["returns_only_one_key"] = warmup_mid.size() == 1 and drawrot_ninety.size() == 1 and can_control_true.size() == 1 and logic_positive.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretMicroAccessorsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
