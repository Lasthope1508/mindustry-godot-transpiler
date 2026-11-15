extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- Producer side (N2186): ImpactReactorBuild.updateTile
	# only warms up while the folded efficiency is ~1 AND
	# power.status is ~1 (ImpactReactor.java:79, `if(efficiency
	# >= 0.9999f && power.status >= 0.99f){`), then
	# `productionEfficiency = Mathf.pow(warmup, 5f);`
	# (ImpactReactor.java:100) and `getPowerProduction()`
	# returns `enabled ? powerProduction *
	# productionEfficiency : 0f;` (PowerGenerator.java:156-158)
	# -- 130f at full warmup, 0f when disabled or cold. The
	# proof calls the pure function with synthetic frames (no
	# long live tick: warmupSpeed 0.001f approaches 1f
	# exponentially). There are no consume-timer / impactPower /
	# net-bar keys: the consume call waits for its own
	# item/liquid slice, the event waits for its own event
	# slice, the net bar is display.
	var delta: float = 1.0 / 60.0

	# Warmup rises under full power: efficiency 1, power.status
	# 1, enabled, warmup 0.5 -> the gate holds and the lerp
	# toward 1f (ImpactReactor.java:82, `warmup =
	# Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`)
	# moves warmup up.
	var rising: Dictionary = impact_reactor_build_state.source_impact_reactor_power_production_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "warmup": 0.5, "total_progress": 0.0}, delta)
	proof["warmup_rises_under_full_power"] = float(rising.get("warmup", -1.0)) > 0.5

	# Warmup cools without power: efficiency 0 / power.status 0
	# -> the gate fails and the else branch (ImpactReactor.java:95,
	# `warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);`) moves
	# warmup down.
	var cooling: Dictionary = impact_reactor_build_state.source_impact_reactor_power_production_state({"efficiency": 0.0, "power_status": 0.0, "enabled": true, "warmup": 0.5, "total_progress": 0.0}, delta)
	proof["warmup_cools_without_power"] = float(cooling.get("warmup", -1.0)) < 0.5

	# Production efficiency is pow(warmup, 5): a half-warm
	# reactor produces 1/32 of full output
	# (ImpactReactor.java:100, `productionEfficiency =
	# Mathf.pow(warmup, 5f);`).
	var half_warm: Dictionary = impact_reactor_build_state.source_impact_reactor_power_production_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "warmup": 0.5, "total_progress": 0.0}, delta)
	proof["production_efficiency_is_pow_warmup_5"] = is_equal_approx(float(half_warm.get("production_efficiency", -1.0)), pow(float(half_warm.get("warmup", -1.0)), 5.0))

	# Production is 130x production efficiency at full warmup
	# (Blocks.java:2636, `powerProduction = 130f;`).
	var full_warm: Dictionary = impact_reactor_build_state.source_impact_reactor_power_production_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "warmup": 1.0, "total_progress": 0.0}, delta)
	proof["power_production_is_130_times_production_efficiency"] = is_equal_approx(float(full_warm.get("power_production", -1.0)), 130.0 * float(full_warm.get("production_efficiency", -1.0))) and is_equal_approx(float(full_warm.get("power_production", -1.0)), 130.0)

	# Production is 0 when disabled (PowerGenerator.java:157,
	# `return enabled ? powerProduction *
	# productionEfficiency : 0f;`).
	var disabled: Dictionary = impact_reactor_build_state.source_impact_reactor_power_production_state({"efficiency": 1.0, "power_status": 1.0, "enabled": false, "warmup": 1.0, "total_progress": 0.0}, delta)
	proof["power_production_zero_when_disabled"] = is_equal_approx(float(disabled.get("power_production", -1.0)), 0.0)

	# Production is 0 when cold: warmup 0 -> production
	# efficiency pow(0, 5) = 0 -> production 0.
	var cold: Dictionary = impact_reactor_build_state.source_impact_reactor_power_production_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "warmup": 0.0, "total_progress": 0.0}, delta)
	proof["power_production_zero_when_cold"] = is_equal_approx(float(cold.get("power_production", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorPowerProductionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
