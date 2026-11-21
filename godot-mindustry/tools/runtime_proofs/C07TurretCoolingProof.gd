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

	# --- Turret updateCooling() coolant fold (N2525):
	# `protected void updateCooling(){` /
	# `if(canReload() && coolant != null &&
	# coolant.efficiency(this) > 0 && efficiency > 0){` /
	# `float capacity = coolant instanceof ConsumeLiquidFilter
	# filter ? filter.getConsumed(this).heatCapacity :
	# (coolant.consumes(liquids.current()) ?
	# liquids.current().heatCapacity : 0.4f);` /
	# `float amount = coolant.amount *
	# coolant.efficiency(this);` / `coolant.update(this);` /
	# `reloadCounter += amount * edelta() * capacity *
	# coolantMultiplier * ammoReloadMultiplier();` /
	# `if(Mathf.chance(0.06 * amount)){`
	# (ReloadTurret.java:28-38), the shared
	# ReloadTurretBuild implementation every ReloadTurret
	# subclass runs from Turret.java:550
	# (`if(reloadWhileCharging || !charging()){` /
	# `updateReload();` / `updateCooling(); }`). The pure
	# function mirrors `source_point_defense_turret_cooling_state`
	# (N2241) with one added parameter,
	# `ammo_reload_multiplier` (the Turret.java:727 override,
	# NOT the ReloadTurret.java:41-43 default 1f);
	# `coolantMultiplier` is 5f for the Turret family
	# (BaseTurret.java:32); `capacity` is the consumed
	# liquid's heatCapacity, passed in with the 0.4f fallback
	# belonging to the coolant-pick slice; `edelta()` is
	# `efficiency * delta()` (BuildingComp.java:1927-1929),
	# passed in precomputed; the coolEffect chance is a
	# random visual, NOT in the pure function; `coolant.update(this)`
	# removes `amount * edelta() * multiplier` -- returned as
	# `coolant_consumed` for a later wiring slice, since the
	# frame carries no liquid inventory. NO driver tick call
	# site: the frame carries no liquid state and the catalog
	# records `coolant` for NO block, so the driver tick
	# cannot read a coolant amount today. The proof drives
	# the pure function on a duo frame (reload 20f, coolant
	# 0.1f at Blocks.java:3324) with exact-binary amounts
	# (0.25 / 0.5) so the float equalities are exact:
	# 1 the reload boost applies (0.25 * 1.0 * 0.5 * 5.0 *
	# 1.0 = 0.625), 2 the gate blocks without coolant, 3 the
	# gate blocks when reloaded (reload_counter == reload),
	# 4 the gate blocks at zero coolant efficiency, 5 the
	# ammoReloadMultiplier override scales the boost
	# (2.0 -> 1.25, the Turret.java:727 override vs the
	# ReloadTurret.java:41-43 default 1f).
	var base_frame: Dictionary = {"reload_counter": 0.0, "efficiency": 1.0}

	# Phase 1: the reload boost applies -- amount 0.25 *
	# efficiency 1.0, consumed 0.25, boost 0.25 * 1.0 * 0.5
	# * 5.0 * 1.0 = 0.625.
	var cooling: Dictionary = turret_build_state.source_turret_cooling_state(base_frame, true, 0.25, 1.0, 0.5, 5.0, 1.0, 20.0, 1.0)
	proof["cooling_boosts_reload_counter"] = float(cooling.get("reload_counter", -1.0)) == 0.625 and bool(cooling.get("cooling_applied", false)) == true and float(cooling.get("coolant_consumed", -1.0)) == 0.25

	# Phase 2: the gate blocks without coolant -- nothing
	# changes, nothing is consumed.
	cooling = turret_build_state.source_turret_cooling_state(base_frame, false, 0.25, 1.0, 0.5, 5.0, 1.0, 20.0, 1.0)
	proof["cooling_gate_blocks_without_coolant"] = float(cooling.get("reload_counter", -1.0)) == 0.0 and bool(cooling.get("cooling_applied", true)) == false and float(cooling.get("coolant_consumed", -1.0)) == 0.0

	# Phase 3: the gate blocks when reloaded --
	# reload_counter == reload, so canReload() is false.
	var reloaded_frame: Dictionary = {"reload_counter": 20.0, "efficiency": 1.0}
	cooling = turret_build_state.source_turret_cooling_state(reloaded_frame, true, 0.25, 1.0, 0.5, 5.0, 1.0, 20.0, 1.0)
	proof["cooling_gate_blocks_when_reloaded"] = float(cooling.get("reload_counter", -1.0)) == 20.0 and bool(cooling.get("cooling_applied", true)) == false and float(cooling.get("coolant_consumed", -1.0)) == 0.0

	# Phase 4: the gate blocks at zero coolant efficiency --
	# no liquid, so efficiency is 0 and nothing is consumed.
	cooling = turret_build_state.source_turret_cooling_state(base_frame, true, 0.25, 0.0, 0.5, 5.0, 1.0, 20.0, 1.0)
	proof["cooling_gate_blocks_zero_efficiency"] = float(cooling.get("reload_counter", -1.0)) == 0.0 and bool(cooling.get("cooling_applied", true)) == false and float(cooling.get("coolant_consumed", -1.0)) == 0.0

	# Phase 5: the ammoReloadMultiplier override scales the
	# boost -- 2.0 doubles it to 1.25, while the consumed
	# amount stays 0.25 (the multiplier touches only the
	# reload boost, ReloadTurret.java:33).
	cooling = turret_build_state.source_turret_cooling_state(base_frame, true, 0.25, 1.0, 0.5, 5.0, 2.0, 20.0, 1.0)
	proof["cooling_ammo_reload_multiplier_scales_boost"] = float(cooling.get("reload_counter", -1.0)) == 1.25 and bool(cooling.get("cooling_applied", false)) == true and float(cooling.get("coolant_consumed", -1.0)) == 0.25

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretCoolingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
