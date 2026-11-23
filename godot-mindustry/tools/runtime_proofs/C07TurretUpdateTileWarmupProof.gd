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

	# --- TurretBuild.updateTile() warmup advance (N2308):
	# TurretBuild.updateTile() warmup advance
	# (Turret.java:502-515): `float warmupTarget =
	# (isShooting && canConsume()) || charging() ? 1f :
	# 0f;` / `if(warmupTarget > 0 && !controlled()){` /
	# `warmupHold = 1f;` / `if(warmupHold > 0f){` /
	# `warmupHold -= Time.delta / warmupMaintainTime;` /
	# `warmupTarget = 1f;` / `if(linearWarmup){` /
	# `shootWarmup = Mathf.approachDelta(shootWarmup,
	# warmupTarget, shootWarmupSpeed * (warmupTarget > 0
	# ? efficiency : 1f));` / `}else{` /
	# `shootWarmup = Mathf.lerpDelta(shootWarmup,
	# warmupTarget, shootWarmupSpeed * (warmupTarget > 0
	# ? efficiency : 1f));` on `public class
	# TurretBuild extends ReloadTurretBuild implements
	# ControlBlock{` (Turret.java:277). canConsume() is
	# the TurretBuild override (Turret.java:624-629,
	# `if(heatRequirement > 0 && heatReq <= 0f){` /
	# `return false;` / `return super.canConsume();`)
	# over the BuildingComp gate
	# (BuildingComp.java:1917-1919, `public boolean
	# canConsume(){` / `return potentialEfficiency >
	# 0;`); heatRequirement is per-def (-1f default,
	# Turret.java:53; 20f afflict / 144f malign,
	# Blocks.java:5122/6240) and heatReq is the live
	# field (Turret.java:295), refreshed each tick at
	# Turret.java:538-539 -- both arrive as explicit
	# params, so a cold heat turret (heatReq <= 0)
	# targets 0 even while shooting with power.
	# charging() is Turret.java:715-717 (`return
	# queuedBullets > 0 && shoot.firstShotDelay > 0;`);
	# controlled() is Turret.java:441-443 (`return
	# unit.isPlayer();`).
	# The hold / warmup fields are Turret.java:286
	# (`public float shootWarmup, charge, warmupHold =
	# 0f;`); the per-def knobs are warmupMaintainTime
	# (Turret.java:84, `public float warmupMaintainTime
	# = 0f;`, 120f on titan / smite / malign,
	# Blocks.java:4803/5909/6242), shootWarmupSpeed
	# (Turret.java:136, `public float shootWarmupSpeed
	# = 0.1f;`, 0.04f on smite) and linearWarmup
	# (Turret.java:138, `public boolean linearWarmup =
	# false;`, no def sets it true). The set and the
	# decay run in the SAME tick: a hold set to 1f is
	# decayed by Time.delta / warmupMaintainTime before
	# the warmupTarget = 1f force, so a fresh hold reads
	# 1 - delta/maintain, not 1. With the default
	# warmupMaintainTime 0f the Java float division
	# yields Infinity and the hold goes to -Infinity in
	# the same tick -- the pure function keeps that
	# behavior, no invented guard. The lerp leg is the
	# default (linearWarmup false on every def); the
	# approach leg is the linearWarmup branch. The rate
	# folds efficiency only while the target is positive
	# (`warmupTarget > 0 ? efficiency : 1f`), so a
	# decaying warmup ignores efficiency. There is no
	# driver tick line: the tick frame tracks no
	# is_shooting / charging / controlled /
	# shoot_warmup / warmup_hold keys yet (the N2294
	# updateTile precedent). All calls use delta 1/60
	# (one tick at 60fps) unless noted.

	var delta: float = 1.0 / 60.0

	# Shooting with potentialEfficiency > 0 targets 1
	# (canConsume true); controlled so the hold is not
	# set; lerp leg advances 0 -> 0.1/60.
	var shooting: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_target_shooting"] = is_equal_approx(float(shooting.get("warmup_target", -1.0)), 1.0)

	# Idle (not shooting, not charging) targets 0;
	# warmup stays 0.
	var idle: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, false, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_target_idle"] = is_equal_approx(float(idle.get("warmup_target", -1.0)), 0.0) and is_equal_approx(float(idle.get("shoot_warmup", -1.0)), 0.0)

	# Charging targets 1 even when not shooting.
	var charging: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, false, 1.0, true, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_target_charging"] = is_equal_approx(float(charging.get("warmup_target", -1.0)), 1.0)

	# Shooting with potentialEfficiency 0 targets 0
	# (canConsume false: BuildingComp.java:1918).
	var no_consume: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 0.0, false, true, 0.0, 0.5, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_target_no_consume"] = is_equal_approx(float(no_consume.get("warmup_target", -1.0)), 0.0)

	# A cold heat turret (afflict, heatRequirement 20,
	# heatReq 0) cannot consume even while shooting
	# with power: the Turret override
	# (Turret.java:624-629) returns false, so the
	# target stays 0.
	var heat_blocked: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, 20.0, 0.0)
	proof["warmup_target_heat_blocked"] = is_equal_approx(float(heat_blocked.get("warmup_target", -1.0)), 0.0)

	# The same turret with heat built up (heatReq 5)
	# can consume again and targets 1.
	var heat_ok: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, 20.0, 5.0)
	proof["warmup_target_heat_ok"] = is_equal_approx(float(heat_ok.get("warmup_target", -1.0)), 1.0)

	# A turret with no heat requirement (-1f default)
	# ignores heatReq entirely and targets 1.
	var no_heat_req: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_target_no_heat_requirement"] = is_equal_approx(float(no_heat_req.get("warmup_target", -1.0)), 1.0)

	# An uncontrolled shooter sets the hold to 1f, then
	# decays it the same tick: 1 - (1/60)/120 =
	# 7199/7200; the target is forced to 1.
	var hold_set: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, false, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_hold_set_uncontrolled"] = is_equal_approx(float(hold_set.get("warmup_hold", -1.0)), 7199.0 / 7200.0) and is_equal_approx(float(hold_set.get("warmup_target", -1.0)), 1.0)

	# A controlled shooter (player unit) never sets the
	# hold: it stays 0 even while the target is 1.
	var hold_controlled: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_hold_not_set_controlled"] = is_equal_approx(float(hold_controlled.get("warmup_hold", -1.0)), 0.0) and is_equal_approx(float(hold_controlled.get("warmup_target", -1.0)), 1.0)

	# A stale hold decays by delta/120 and forces the
	# target to 1 even while idle: 0.5 - (1/60)/120 =
	# 0.5 - 1/7200.
	var hold_decay: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, false, 1.0, false, true, 0.5, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_hold_decay_maintain_120"] = is_equal_approx(float(hold_decay.get("warmup_hold", -1.0)), 0.5 - 1.0 / 7200.0) and is_equal_approx(float(hold_decay.get("warmup_target", -1.0)), 1.0)

	# With the default warmupMaintainTime 0f the Java
	# float division yields Infinity: 1 - Infinity =
	# -Infinity, and the target is still forced to 1.
	var hold_zero: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, false, 1.0, false, true, 1.0, 0.0, false, 0.1, 1.0, 0.0, delta, -1.0, 0.0)
	proof["warmup_hold_zero_maintain_infinity"] = is_inf(float(hold_zero.get("warmup_hold", 0.0))) and is_equal_approx(float(hold_zero.get("warmup_target", -1.0)), 1.0)

	# Lerp leg (default): 0 -> 0.1 * (1/60) = 0.1/60.
	var lerp_advance: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_lerp_advance"] = is_equal_approx(float(lerp_advance.get("shoot_warmup", -1.0)), 0.1 / 60.0)

	# Linear leg: approach 0.5 -> 0.5 + 0.1/60.
	var linear_approach: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.5, true, 0.1, 1.0, 120.0, delta, -1.0, 0.0)
	proof["warmup_linear_approach"] = is_equal_approx(float(linear_approach.get("shoot_warmup", -1.0)), 0.5 + 0.1 / 60.0)

	# Efficiency 0.5 halves the advance rate while the
	# target is positive: 0 -> 0.05/60.
	var efficiency_fold: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 0.5, 120.0, delta, -1.0, 0.0)
	proof["warmup_efficiency_fold"] = is_equal_approx(float(efficiency_fold.get("shoot_warmup", -1.0)), 0.05 / 60.0)

	# A decaying warmup ignores efficiency (the rate
	# uses 1f when the target is 0): 0.5 -> 0.5 -
	# 0.5 * 0.1/60.
	var decay_ignores: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, false, 1.0, false, true, 0.0, 0.5, false, 0.1, 0.5, 120.0, delta, -1.0, 0.0)
	proof["warmup_decay_ignores_efficiency"] = is_equal_approx(float(decay_ignores.get("shoot_warmup", -1.0)), 0.5 - 0.5 * 0.1 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretUpdateTileWarmupProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
