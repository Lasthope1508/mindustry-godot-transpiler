extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
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

	# --- Pure gate (N2193): ShockwaveTowerBuild overrides
	# shouldConsume (ShockwaveTower.java:121, `public boolean
	# shouldConsume(){` with `return reloadCounter < reload;`,
	# ShockwaveTower.java:122) over the reload counter
	# (ShockwaveTower.java:67, `public float reloadCounter =
	# Mathf.random(reload);`), which the N2192 charge alone writes
	# (ShockwaveTower.java:73, `if(potentialEfficiency > 0 &&
	# (reloadCounter += edelta()) >= reload && timer(timerCheck,
	# checkInterval)){`). The per-def reload is 80f
	# (Blocks.java:2044), overriding the class default `60f *
	# 1.5f` (ShockwaveTower.java:26), so the gate threshold the
	# counter runs against is 80f. An absent `reload_counter`
	# key means "no observation yet" and preserves the N2177
	# behavior (should_consume = enabled) -- the N2191 precedent
	# -- never "fully charged".
	var below: Dictionary = shockwave_tower_build_state.source_shockwave_tower_should_consume_state({"reload_counter": 10.0, "enabled": true})
	proof["gate_passes_below_reload"] = bool(below.get("should_consume", false)) == true

	var at_reload: Dictionary = shockwave_tower_build_state.source_shockwave_tower_should_consume_state({"reload_counter": 80.0, "enabled": true})
	proof["gate_blocks_at_reload"] = bool(at_reload.get("should_consume", true)) == false

	# Gate blocks when disabled: counter 10.0 but enabled=false
	# -- the pure gate reads false, and the shared machinery's
	# disabled branch (update_consumption_disabled_state) zeroes
	# efficiency when the driver runs it with that gate value.
	# This key runs the pure gate plus the machinery directly
	# instead of the live driver: the driver skips the whole
	# consumption block when enabled is false, so a live tick
	# cannot stamp a fresh efficiency -- the gate value and the
	# machinery branch it feeds are the observable (the N2191
	# proof pattern).
	var disabled_gate: Dictionary = shockwave_tower_build_state.source_shockwave_tower_should_consume_state({"reload_counter": 10.0, "enabled": false})
	var disabled_consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, false, false, true, bool(disabled_gate.get("should_consume", true)), 1.0, [{"result": 0.5, "is_power": true}], [], [], {})
	proof["gate_blocks_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and is_equal_approx(float(disabled_consumption.get("efficiency", -1.0)), 0.0)

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the gate BEFORE
	# the consumption setup (the Java order, updateConsumption
	# :2274 reads shouldConsume() at :1960), reading the
	# reload_counter the previous tick's charge stamped; the
	# charge itself runs AFTER apply_update_consumption_state and
	# cannot change the counter the gate just read on a 1/60s
	# tick in a way the efficiency keys observe -- the gate value
	# is what the consumption machinery folds.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})

	# Absent key preserves the power fold: NO reload_counter key
	# at half power -- the gate preserves the N2177 behavior
	# (should_consume = enabled), so efficiency folds the power
	# min 0.5. This pins the RED absent-default decision: null
	# means "no observation yet", not "fully charged".
	shockwave_tower_frame.erase("reload_counter")
	shockwave_tower_frame["power_status"] = 0.5
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["gate_absent_preserves_power_fold"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when fully charged: reload_counter=80.0 (at
	# reload, not < reload) at full power -- the gate overrides
	# the power fold, efficiency 0 (BuildingComp.java:1960 +
	# 1992-1993, `if(!update){` / `efficiency =
	# optionalEfficiency = 0f;`), even though the power row
	# alone would fold 1.0.
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["gate_blocks_when_fully_charged"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.0)

	# Gate passes below reload at half power: reload_counter=10.0
	# -- the power fold applies, efficiency 0.5.
	shockwave_tower_frame["reload_counter"] = 10.0
	shockwave_tower_frame["power_status"] = 0.5
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["gate_passes_below_reload_live"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
