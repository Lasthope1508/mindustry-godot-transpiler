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

	# --- First-production event (N2216):
	# ImpactReactorBuild.updateTile fires the achievement trigger
	# the first tick production exceeds the requested power
	# (ImpactReactor.java:87, `if(!prevOut && consPower != null
	# && (getPowerProduction() >
	# consPower.requestedPower(this))){` with
	# ImpactReactor.java:88, `Events.fire(Trigger.impactPower);`,
	# computed from ImpactReactor.java:80, `boolean prevOut =
	# consPower != null && getPowerProduction() <=
	# consPower.requestedPower(this);`), INSIDE the warmup hard
	# gate (ImpactReactor.java:79, `if(efficiency >= 0.9999f &&
	# power.status >= 0.99f){`). The KEY SUBTLETY:
	# productionEfficiency is only reassigned at
	# ImpactReactor.java:100 (`productionEfficiency =
	# Mathf.pow(warmup, 5f);`), AFTER the event check, so both
	# getPowerProduction() calls read the SAME previous-tick
	# productionEfficiency -- the proof passes that previous
	# tick's value on the frame (the N2186 stamp) and the pure
	# function reads it directly. getPowerProduction() returns
	# `enabled ? powerProduction * productionEfficiency : 0f;`
	# (PowerGenerator.java:156-158) with `powerProduction =
	# 130f;` (Blocks.java:2636), and the requested power is 25f
	# when enabled (`consumePower(25f);`, Blocks.java:2642;
	# shouldConsume() returns enabled, BuildingComp.java:755-756)
	# -- so the event fires the tick 130 * production_efficiency
	# first crosses 25. The proof calls the pure function with
	# synthetic frames (no long live tick: the crossing is a
	# threshold on the previous tick's productionEfficiency).
	# There are no consume-timer / net-bar / persistence keys:
	# the burn is N2187, the bar is display, the persistence
	# waits for its own slice.

	# Fires when production exceeds requested: efficiency 1,
	# power.status 1, enabled, production_efficiency 0.5 ->
	# production 65 > requested 25, prevOut false -> fires.
	var firing: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "production_efficiency": 0.5})
	proof["impact_power_fires_when_production_exceeds_requested"] = bool(firing.get("impact_power_fired", false))

	# No fire when production is below requested:
	# production_efficiency 0.1 -> production 13 <= 25,
	# prevOut true -> no fire.
	var below: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "production_efficiency": 0.1})
	proof["impact_power_no_fire_when_production_below_requested"] = not bool(below.get("impact_power_fired", true))

	# No fire at exact equality: production_efficiency 25/130 ->
	# production 130 * (25/130) == 25.0 exactly in IEEE doubles,
	# so production <= requested, prevOut true -> no fire (the
	# event needs a STRICT excess, `>`).
	var equal: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "production_efficiency": 25.0 / 130.0})
	proof["impact_power_no_fire_at_exact_equality"] = not bool(equal.get("impact_power_fired", true))

	# No fire when disabled: production 0 (enabled false) and
	# requested 0 (shouldConsume false), so 0 <= 0, prevOut true
	# -> no fire, even at full warmup.
	var disabled: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 1.0, "enabled": false, "production_efficiency": 1.0})
	proof["impact_power_no_fire_when_disabled"] = not bool(disabled.get("impact_power_fired", true))

	# No fire when the efficiency gate fails: production 130 >
	# requested 25, but efficiency 0.5 < 0.9999, so the check
	# never runs.
	var no_efficiency: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 0.5, "power_status": 1.0, "enabled": true, "production_efficiency": 1.0})
	proof["impact_power_no_fire_when_efficiency_gate_fails"] = not bool(no_efficiency.get("impact_power_fired", true))

	# No fire when the power.status gate fails: production 130 >
	# requested 25, but power.status 0.5 < 0.99, so the check
	# never runs.
	var no_power: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 0.5, "enabled": true, "production_efficiency": 1.0})
	proof["impact_power_no_fire_when_power_status_gate_fails"] = not bool(no_power.get("impact_power_fired", true))

	# Fires just above threshold: production_efficiency 0.2 ->
	# production 26 > requested 25, prevOut false -> fires.
	var just_above: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "production_efficiency": 0.2})
	proof["impact_power_fires_just_above_threshold"] = bool(just_above.get("impact_power_fired", false))

	# No fire when cold: production_efficiency 0.0 -> production
	# 0 <= requested 25, prevOut true -> no fire.
	var cold: Dictionary = impact_reactor_build_state.source_impact_reactor_impact_power_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "production_efficiency": 0.0})
	proof["impact_power_no_fire_when_cold"] = not bool(cold.get("impact_power_fired", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorImpactPowerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
