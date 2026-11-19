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

	# --- Turret control() setters (N2264): N2250-N2263 never armed
	# the logic-control timer from a logic shoot / shootp
	# instruction -- the N2261 decay tick only ever reads the frame
	# value, it never arms it, so logicControlled() could never go
	# live from logic. TurretBuild.control() arms it, outside
	# updateTile():
	# `if(type == LAccess.shoot && !unit.isPlayer()){`
	# `targetPos.set(World.unconv((float)p1), World.unconv((float)p2));`
	# `logicControlTime = logicControlCooldown;`
	# `logicShooting = !Mathf.zero(p3);`
	# (Turret.java:382-386) and
	# `if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){`
	# `logicControlTime = logicControlCooldown;`
	# `logicShooting = !Mathf.zero(p2);`
	# `if(p1 instanceof Posc pos){`
	# `targetPosition(pos);`
	# (Turret.java:393-400). The cooldown is
	# `public final static float logicControlCooldown = 60 * 2;`
	# (:38 -- 120 ticks of logic control), the timer field is
	# `public float curRecoil, heat, logicControlTime = -1;`
	# (:284), the flag field is
	# `public boolean logicShooting = false;` (:287) and the
	# target field is `public Vec2 targetPos = new Vec2();`
	# (:289). World.unconv is
	# `public static float unconv(float coord){`
	# `return coord * tilesize;` (World.java:170-172) with
	# `public static final int tilesize = 8;` (Vars.java:135), so
	# a shoot at tile (10, 20) aims at world (80, 160).
	# Mathf.zero is
	# `public static boolean zero(float value){`
	# `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;`
	# (arc Mathf.java:522-524) with
	# `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
	# (:10), so a shoot flag of 0.0000005 reads zero and a flag
	# of 0.00001 reads shooting. This is an EVENT, not a per-tick
	# step: control() is called by the logic executor, and no
	# logic executor exists in the driver yet, so there is no
	# driver tick (the N2248 precedent) -- the direct
	# pure-function calls below pin the arming, and the N2261
	# decay tick reads the armed frame value. The shootp
	# targetPosition(pos) call (:398) waits for its own slice:
	# it needs hasAmmo / peekAmmo plus Predict.intercept
	# (:453-471), so the shootp arm only reports
	# target_position_deferred and leaves targetPos untouched.
	# The direct pure-function calls pin the arming behind the
	# observables below: shoot arms the timer to 120 / shoot
	# sets the world target pos / shoot sets logicShooting from
	# the p3 flag / the flag reads zero at the 1e-6 epsilon /
	# shoot is blocked while a player controls the unit / shootp
	# arms the timer to 120 / shootp sets logicShooting from the
	# p2 flag / shootp with a Posc defers targetPosition and
	# leaves targetPos untouched / shootp is blocked while a
	# player controls the unit / a non-shoot/shootp type changes
	# nothing.

	# The direct pure-function calls pin the formula behind the
	# observables below.
	var direct_shoot: Dictionary = turret_build_state.source_turret_control_state("shoot", 10.0, 20.0, 1.0, false, false, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shoot_flag_off: Dictionary = turret_build_state.source_turret_control_state("shoot", 10.0, 20.0, 0.0, false, false, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shoot_flag_tiny: Dictionary = turret_build_state.source_turret_control_state("shoot", 10.0, 20.0, 0.0000005, false, false, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shoot_flag_small: Dictionary = turret_build_state.source_turret_control_state("shoot", 10.0, 20.0, 0.00001, false, false, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shoot_player: Dictionary = turret_build_state.source_turret_control_state("shoot", 10.0, 20.0, 1.0, true, false, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shootp: Dictionary = turret_build_state.source_turret_control_state("shootp", 0.0, 1.0, 0.0, false, true, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shootp_flag_off: Dictionary = turret_build_state.source_turret_control_state("shootp", 0.0, 0.0, 0.0, false, true, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)
	var direct_shootp_posc: Dictionary = turret_build_state.source_turret_control_state("shootp", 0.0, 1.0, 0.0, false, true, -1.0, false, {"x": 0.0, "y": 0.0}, true, 8.0)
	var direct_shootp_player: Dictionary = turret_build_state.source_turret_control_state("shootp", 0.0, 1.0, 0.0, true, false, -1.0, false, {"x": 0.0, "y": 0.0}, true, 8.0)
	var direct_other: Dictionary = turret_build_state.source_turret_control_state("enabled", 10.0, 20.0, 1.0, false, false, -1.0, false, {"x": 0.0, "y": 0.0}, false, 8.0)

	# Shoot arms the timer to 120 -- directly (timer -1.0 in,
	# shoot with a non-player unit -> 120.0, the
	# logicControlCooldown).
	proof["control_shoot_arms_timer"] = absf(float(direct_shoot.get("logic_control_time", 9.9)) - 120.0) < 0.0001
	# Shoot sets the world target pos -- directly (tile (10, 20)
	# in, tilesize 8 -> world (80, 160), World.unconv).
	var shoot_target: Dictionary = direct_shoot.get("target_pos", {})
	proof["control_shoot_sets_target_pos"] = absf(float(shoot_target.get("x", 9.9)) - 80.0) < 0.0001 and absf(float(shoot_target.get("y", 9.9)) - 160.0) < 0.0001
	# Shoot sets logicShooting from the p3 flag -- directly (p3
	# 1.0 -> true, p3 0.0 -> false).
	proof["control_shoot_sets_logic_shooting"] = bool(direct_shoot.get("logic_shooting", false)) and not bool(direct_shoot_flag_off.get("logic_shooting", true))
	# The flag reads zero at the 1e-6 epsilon -- directly (p3
	# 0.0000005 -> false, |v| <= FLOAT_ROUNDING_ERROR; p3
	# 0.00001 -> true).
	proof["control_shoot_flag_zero_epsilon"] = not bool(direct_shoot_flag_tiny.get("logic_shooting", true)) and bool(direct_shoot_flag_small.get("logic_shooting", false))
	# Shoot is blocked while a player controls the unit --
	# directly (unit_is_player true -> timer stays -1.0,
	# targetPos stays (0, 0), logicShooting stays false).
	var player_target: Dictionary = direct_shoot_player.get("target_pos", {})
	proof["control_shoot_blocked_when_player"] = absf(float(direct_shoot_player.get("logic_control_time", 9.9)) - (-1.0)) < 0.0001 and absf(float(player_target.get("x", 9.9)) - 0.0) < 0.0001 and absf(float(player_target.get("y", 9.9)) - 0.0) < 0.0001 and not bool(direct_shoot_player.get("logic_shooting", true))
	# Shootp arms the timer to 120 -- directly (timer -1.0 in,
	# shootp with a null unit -> 120.0).
	proof["control_shootp_arms_timer"] = absf(float(direct_shootp.get("logic_control_time", 9.9)) - 120.0) < 0.0001
	# Shootp sets logicShooting from the p2 flag -- directly (p2
	# 1.0 -> true, p2 0.0 -> false).
	proof["control_shootp_sets_logic_shooting"] = bool(direct_shootp.get("logic_shooting", false)) and not bool(direct_shootp_flag_off.get("logic_shooting", true))
	# Shootp with a Posc defers targetPosition and leaves
	# targetPos untouched -- directly (target_is_posc true ->
	# target_position_deferred true, targetPos stays (0, 0):
	# targetPosition needs hasAmmo / peekAmmo + Predict).
	var posc_target: Dictionary = direct_shootp_posc.get("target_pos", {})
	proof["control_shootp_defers_target_position"] = bool(direct_shootp_posc.get("target_position_deferred", false)) and absf(float(posc_target.get("x", 9.9)) - 0.0) < 0.0001 and absf(float(posc_target.get("y", 9.9)) - 0.0) < 0.0001
	# Shootp is blocked while a player controls the unit --
	# directly (unit non-null + is player -> timer stays -1.0,
	# logicShooting stays false, nothing deferred).
	proof["control_shootp_blocked_when_player"] = absf(float(direct_shootp_player.get("logic_control_time", 9.9)) - (-1.0)) < 0.0001 and not bool(direct_shootp_player.get("logic_shooting", true)) and not bool(direct_shootp_player.get("target_position_deferred", true))
	# A non-shoot/shootp type changes nothing -- directly
	# ("enabled" -> timer stays -1.0, targetPos stays (0, 0),
	# logicShooting stays false, nothing deferred; the
	# BuildingComp super.control enabled/config cases are their
	# own slices).
	var other_target: Dictionary = direct_other.get("target_pos", {})
	proof["control_other_type_noop"] = absf(float(direct_other.get("logic_control_time", 9.9)) - (-1.0)) < 0.0001 and absf(float(other_target.get("x", 9.9)) - 0.0) < 0.0001 and absf(float(other_target.get("y", 9.9)) - 0.0) < 0.0001 and not bool(direct_other.get("logic_shooting", true)) and not bool(direct_other.get("target_position_deferred", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretControlProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
