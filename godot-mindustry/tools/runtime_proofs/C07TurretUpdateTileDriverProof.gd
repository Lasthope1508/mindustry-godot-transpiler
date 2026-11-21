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

	# --- TurretBuild.updateTile() remaining driver-tick legs (N2397):
	# TurretBuild.updateTile() remaining driver-tick legs
	# (Turret.java:494-499, :548-557, :566-608): player ammo
	# sync (`if(unit.isPlayer()){ //there's no reason to
	# update this when a player isn't controlling it` /
	# `unit.ammo(getAmmoFraction());`), soundLoop update
	# (`soundLoop.update(x, y, shouldActiveSound(),
	# activeSoundVolume());`), reload gate
	# (`if(reloadWhileCharging || !charging()){` /
	# `updateReload();`), fog range
	# (`if(state.rules.fog){` / `float newRange =
	# hasAmmo() ? peekAmmo().rangeChange : 0f;` /
	# `if(newRange != lastRangeChange){` /
	# `lastRangeChange = newRange;` /
	# `fogControl.forceUpdate(team, this);`) and the
	# hasAmmo targeting block (`if(hasAmmo()){` /
	# `if(Float.isNaN(reloadCounter)) reloadCounter =
	# 0;` / `if(timer(timerTarget, target != null ?
	# newTargetInterval : targetInterval)){` /
	# `findTarget();` / `boolean canShoot;` /
	# `if(controlled()){ //player behavior` /
	# `targetPos.set(unit.aimX(), unit.aimY());` /
	# `canShoot = unit.isShooting();` /
	# `}else if(logicControlled()){ //logic behavior`
	# / `canShoot = logicShooting;` /
	# `}else{ //default AI behavior` /
	# `if(!controlled()){` / `unit.aimX(targetPos.x);`
	# / `unit.aimY(targetPos.y);` /
	# `if(alwaysShooting){`) on `public class
	# TurretBuild extends ReloadTurretBuild implements
	# ControlBlock{` (Turret.java:277), inside
	# `public void updateTile(){`
	# (Turret.java:490). The guard lines are
	# registered with their Java trailing comments, so
	# they are distinct from the same bare text owned
	# elsewhere (`if(unit.isPlayer()){` alone is N1899
	# BuildingComp.handleUnitPayload; `}else{` alone is
	# owned by sixteen slices). NOT registered:
	# `updateCooling();` (N2241), `wasShooting =
	# true;` (N2362), `updateShooting();` (remote
	# N2269), `if(soundLoop != null){` (N2350).
	# Call-sites already owned arrive as
	# Callables/params, never re-registered:
	# updateReload/updateCooling (N2241), findTarget
	# (N2316), validateTarget/charging/controlled/
	# logicControlled (N2324/N2297), getAmmoFraction
	# (N2348/N2355), shouldActiveSound/activeSoundVolume
	# (N2346). All calls use explicit params (the
	# N2188 precedent); the proof asserts frame only,
	# never a real shot.

	# A player-controlled unit applies the ammo
	# fraction (getAmmoFraction(), Turret.java:324-326).
	var ammo_player: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, true, 0.75, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["ammo_sync_player"] = is_equal_approx(float(ammo_player.get("unit_ammo_fraction", -1.0)), 0.75)

	# A non-player unit applies nothing (null).
	var ammo_not_player: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.75, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["ammo_sync_not_player"] = ammo_not_player.get("unit_ammo_fraction", -1.0) == null

	# The soundLoop update carries the build position
	# plus shouldActiveSound() and activeSoundVolume()
	# (Turret.java:499; both N2346).
	var sound_on: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, true, 100.0, 200.0, true, 0.5, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	var sound_update: Dictionary = sound_on.get("sound_loop_update", {})
	proof["sound_loop_update"] = is_equal_approx(float(sound_update.get("x", -1.0)), 100.0) and is_equal_approx(float(sound_update.get("y", -1.0)), 200.0) and bool(sound_update.get("active", false)) == true and is_equal_approx(float(sound_update.get("volume", -1.0)), 0.5)

	# No loop sound (loopSound == none, Turret.java:298)
	# carries a null update.
	var sound_off: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 100.0, 200.0, true, 0.5, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["sound_loop_absent"] = sound_off.get("sound_loop_update", {}) == null

	# The reload gate opens while charging when the def
	# allows it (reloadWhileCharging, Turret.java:82);
	# updateReload() (body N2241) is recorded as called.
	var gate_charging: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, true, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["reload_gate_open_charging_allowed"] = bool(gate_charging.get("reload_gate_open", false)) == true and bool(gate_charging.get("update_reload_called", false)) == true

	# The gate also opens whenever the turret is not
	# charging, even with reloadWhileCharging false.
	var gate_idle: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, false, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["reload_gate_open_not_charging"] = bool(gate_idle.get("reload_gate_open", false)) == true and bool(gate_idle.get("update_reload_called", false)) == true

	# Charging with reloadWhileCharging false closes
	# the gate: updateReload() is not called.
	var gate_closed: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, false, true, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["reload_gate_closed"] = bool(gate_closed.get("reload_gate_open", true)) == false and bool(gate_closed.get("update_reload_called", true)) == false

	# Fog on with ammo: a changed range updates
	# lastRangeChange and force-updates fog
	# (Turret.java:553-557).
	var fog_changed: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, true, true, 5.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["fog_range_changed"] = is_equal_approx(float(fog_changed.get("last_range_change", -1.0)), 5.0) and bool(fog_changed.get("fog_range_changed", false)) == true and bool(fog_changed.get("fog_force_update_called", false)) == true

	# Fog on with an unchanged range: no update.
	var fog_same: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, true, true, 3.0, 3.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["fog_range_unchanged"] = is_equal_approx(float(fog_same.get("last_range_change", -1.0)), 3.0) and bool(fog_same.get("fog_range_changed", true)) == false and bool(fog_same.get("fog_force_update_called", true)) == false

	# Fog on with no ammo: the new range is 0f, so a
	# stale lastRangeChange of 3 still changes to 0.
	var fog_no_ammo: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, true, false, 5.0, 3.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["fog_no_ammo_zero_range"] = is_equal_approx(float(fog_no_ammo.get("last_range_change", -1.0)), 0.0) and bool(fog_no_ammo.get("fog_range_changed", false)) == true and bool(fog_no_ammo.get("fog_force_update_called", false)) == true

	# Fog off: the leg does nothing at all.
	var fog_off: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 5.0, 2.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["fog_disabled"] = is_equal_approx(float(fog_off.get("last_range_change", -1.0)), 2.0) and bool(fog_off.get("fog_range_changed", true)) == false and bool(fog_off.get("fog_force_update_called", true)) == false

	# A NaN reloadCounter resets to 0 inside the
	# hasAmmo block (Turret.java:567).
	var nan_reset: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, NAN, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["reload_counter_nan_reset"] = is_equal_approx(float(nan_reset.get("reload_counter", -1.0)), 0.0)

	# The target timer fires findTarget() (body N2316)
	# only when ready (Turret.java:569-570).
	var timer_ready: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, true, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["find_target_timer_ready"] = bool(timer_ready.get("find_target_called", false)) == true

	var timer_not_ready: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["find_target_timer_not_ready"] = bool(timer_not_ready.get("find_target_called", true)) == false

	# Player branch (controlled): targetPos is set
	# from the unit aim and canShoot reads
	# unit.isShooting(); the aim write is skipped
	# because the turret is controlled.
	var player_branch: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, true, true, false, Vector2.ZERO, 10.0, 20.0, true, false, false)
	proof["can_shoot_player_branch"] = Vector2(player_branch.get("target_pos", Vector2.INF)) == Vector2(10.0, 20.0) and bool(player_branch.get("can_shoot", false)) == true and is_equal_approx(float(player_branch.get("unit_aim_x", -1.0)), 10.0) and is_equal_approx(float(player_branch.get("unit_aim_y", -1.0)), 20.0)

	# Logic branch (logicControlled): canShoot reads
	# logicShooting; the aim write follows
	# !controlled() and takes the (unchanged) targetPos.
	var logic_branch: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, true, false, true, Vector2(30.0, 40.0), 1.0, 2.0, false, false, false)
	proof["can_shoot_logic_branch"] = Vector2(logic_branch.get("target_pos", Vector2.INF)) == Vector2(30.0, 40.0) and bool(logic_branch.get("can_shoot", true)) == false and is_equal_approx(float(logic_branch.get("unit_aim_x", -1.0)), 30.0) and is_equal_approx(float(logic_branch.get("unit_aim_y", -1.0)), 40.0)

	# Default-AI branch: targetPosition/within is
	# remote N2250, so can_shoot stays null; the aim
	# write still follows !controlled() on the
	# incoming targetPos.
	var ai_branch: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, true, false, false, Vector2(50.0, 60.0), 1.0, 2.0, false, false, false)
	proof["can_shoot_default_ai_null"] = ai_branch.get("can_shoot", false) == null and is_equal_approx(float(ai_branch.get("unit_aim_x", -1.0)), 50.0) and is_equal_approx(float(ai_branch.get("unit_aim_y", -1.0)), 60.0)

	# The alwaysShooting gate fires only with ammo
	# (Turret.java:607, inside the hasAmmo block);
	# wasShooting/updateShooting inside it are N2362 /
	# remote N2269, not registered here.
	var always_on: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, true)
	var always_off: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, true, 0.0, 0.0, 0.0, false, false, false, false, Vector2.ZERO, 0.0, 0.0, false, false, false)
	proof["always_shooting_gate"] = bool(always_on.get("always_shooting_gate", false)) == true and bool(always_off.get("always_shooting_gate", true)) == false

	# With no ammo the whole targeting block is
	# skipped: no findTarget, no can_shoot, the NaN
	# reloadCounter is NOT reset, and the
	# alwaysShooting gate stays closed.
	var no_ammo: Dictionary = turret_build_state.source_turret_update_tile_driver_state({}, false, 0.0, false, 0.0, 0.0, false, 0.0, true, false, false, false, 0.0, 0.0, NAN, true, true, false, false, Vector2.ZERO, 0.0, 0.0, false, false, true)
	proof["no_ammo_skips_targeting"] = bool(no_ammo.get("find_target_called", true)) == false and no_ammo.get("can_shoot", false) == null and is_nan(float(no_ammo.get("reload_counter", 0.0))) and bool(no_ammo.get("always_shooting_gate", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretUpdateTileDriverProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
