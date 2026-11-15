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

	# --- Consume side (N2187): ImpactReactorBuild.updateTile
	# burns blast-compound on a timer INSIDE the warmup hard
	# gate (ImpactReactor.java:91-92, `if(timer(timerUse,
	# itemDuration / timeScale)){` / `consume();`) and drains
	# cryofluid continuously whenever efficiency > 0
	# (ConsumeLiquid.java:37-39, `build.liquids.remove(liquid,
	# amount * build.edelta() * multiplier.get(build));`,
	# 0.25f x edelta per tick). The proof calls the pure
	# function with synthetic frames and a pre-advanced timer
	# stamp (no long live tick: consume_timer = 139.9 + delta
	# 0.2 fires once, -1 blast-compound, timer back to 0).
	# There are no impactPower / net-bar / persistence keys:
	# the event waits for its own event slice, the bar is
	# display, the persistence waits for its own slice.
	var delta: float = 1.0 / 60.0

	# Burn -1 per 140s inside the gate: the timer fires on a
	# pre-advanced consume_timer stamp (139.9 + 0.2 >= 140),
	# -1 blast-compound, timer back to 0 (Interval.java,
	# `if(got) times[id] = Time.time;`, overshoot dropped).
	var burn: Dictionary = impact_reactor_build_state.source_impact_reactor_consume_state({"efficiency": 1.0, "power_status": 1.0, "enabled": true, "time_scale": 1.0, "consume_timer": 139.9, "items": {"blast-compound": 5}, "liquids": {"cryofluid": 80.0}}, 0.2)
	var burn_items: Dictionary = burn.get("items", {}) as Dictionary
	proof["burn_minus_one_per_140s_inside_gate"] = int(burn.get("blast_compound_burned", -1)) == 1 and int(burn_items.get("blast-compound", -1)) == 4 and is_equal_approx(float(burn.get("consume_timer", -1.0)), 0.0)

	# No burn outside the gate: efficiency 0 / power.status 0
	# -> the warmup hard gate fails (ImpactReactor.java:79,
	# `if(efficiency >= 0.9999f && power.status >= 0.99f){`),
	# the timer does not advance and nothing burns.
	var no_burn: Dictionary = impact_reactor_build_state.source_impact_reactor_consume_state({"efficiency": 0.0, "power_status": 0.0, "enabled": true, "time_scale": 1.0, "consume_timer": 139.9, "items": {"blast-compound": 5}, "liquids": {"cryofluid": 80.0}}, 0.2)
	var no_burn_items: Dictionary = no_burn.get("items", {}) as Dictionary
	proof["no_burn_outside_gate"] = int(no_burn.get("blast_compound_burned", -1)) == 0 and int(no_burn_items.get("blast-compound", -1)) == 5 and is_equal_approx(float(no_burn.get("consume_timer", -1.0)), 139.9)

	# Cryofluid drains 0.25f x edelta per tick while
	# efficiency > 0 -- and NOT gated on the warmup hard
	# gate: power.status 0 here, so no burn, but the drain
	# still runs (BuildingComp.java:1997-2000, `if(update &&
	# efficiency > 0){`).
	var drain: Dictionary = impact_reactor_build_state.source_impact_reactor_consume_state({"efficiency": 1.0, "power_status": 0.0, "enabled": true, "time_scale": 1.0, "consume_timer": 0.0, "items": {"blast-compound": 5}, "liquids": {"cryofluid": 80.0}}, delta)
	var drain_liquids: Dictionary = drain.get("liquids", {}) as Dictionary
	proof["cryofluid_drains_per_tick_while_efficiency_positive"] = is_equal_approx(float(drain.get("cryofluid_drained", -1.0)), 0.25 * delta) and is_equal_approx(float(drain_liquids.get("cryofluid", -1.0)), 80.0 - 0.25 * delta)

	# No drain when disabled or efficiency 0: the second
	# pass runs only when `shouldConsume() &&
	# productionValid()` and efficiency > 0
	# (BuildingComp.java:1960, 1997-2000); shouldConsume is
	# `enabled` for the impact reactor (no override).
	var disabled_drain: Dictionary = impact_reactor_build_state.source_impact_reactor_consume_state({"efficiency": 1.0, "power_status": 1.0, "enabled": false, "time_scale": 1.0, "consume_timer": 0.0, "items": {"blast-compound": 5}, "liquids": {"cryofluid": 80.0}}, delta)
	var disabled_drain_liquids: Dictionary = disabled_drain.get("liquids", {}) as Dictionary
	var zero_efficiency_drain: Dictionary = impact_reactor_build_state.source_impact_reactor_consume_state({"efficiency": 0.0, "power_status": 0.0, "enabled": true, "time_scale": 1.0, "consume_timer": 0.0, "items": {"blast-compound": 5}, "liquids": {"cryofluid": 80.0}}, delta)
	var zero_efficiency_drain_liquids: Dictionary = zero_efficiency_drain.get("liquids", {}) as Dictionary
	proof["no_drain_when_disabled_or_efficiency_zero"] = is_equal_approx(float(disabled_drain.get("cryofluid_drained", -1.0)), 0.0) and is_equal_approx(float(zero_efficiency_drain.get("cryofluid_drained", -1.0)), 0.0) and is_equal_approx(float(disabled_drain_liquids.get("cryofluid", -1.0)), 80.0) and is_equal_approx(float(zero_efficiency_drain_liquids.get("cryofluid", -1.0)), 80.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
