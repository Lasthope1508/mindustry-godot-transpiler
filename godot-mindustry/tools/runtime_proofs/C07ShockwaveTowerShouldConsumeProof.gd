extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Pure gate (N2187): ShockwaveTowerBuild.shouldConsume()
	# (ShockwaveTower.java:121, `public boolean shouldConsume(){`
	# with `return reloadCounter < reload;`, ShockwaveTower.java:122)
	# -- the tower consumes only while its reload counter is
	# below reload. reload is the def value from the catalog
	# block (`reload = 80f;`, Blocks.java:2043), falling back to
	# the class default (`public float reload = 60f * 1.5f;`,
	# ShockwaveTower.java:26). The counter is frame state
	# (`public float reloadCounter = Mathf.random(reload);`,
	# ShockwaveTower.java:67); a fresh frame starts at 0.0 --
	# Java's random init is uniform in [0, reload)
	# (Mathf.java:279-282, 0 inclusive, range exclusive), so the
	# gate is always true at spawn and 0.0 preserves that
	# outcome, while the exact random offset (time-to-first-fire)
	# waits for its own slice. The boundary is strict: at
	# exactly reload the gate is already false.
	var below_gate: Dictionary = shockwave_tower_build_state.source_shockwave_tower_should_consume_state({"reload_counter": 40.0}, blocks_by_id["shockwave-tower"])
	proof["gate_true_below_reload"] = bool(below_gate.get("should_consume", false)) and is_equal_approx(float(below_gate.get("reload_counter", -1.0)), 40.0)

	var at_gate: Dictionary = shockwave_tower_build_state.source_shockwave_tower_should_consume_state({"reload_counter": 80.0}, blocks_by_id["shockwave-tower"])
	proof["gate_false_at_reload"] = bool(at_gate.get("should_consume", true)) == false and is_equal_approx(float(at_gate.get("reload_counter", -1.0)), 80.0)

	var above_gate: Dictionary = shockwave_tower_build_state.source_shockwave_tower_should_consume_state({"reload_counter": 120.0}, blocks_by_id["shockwave-tower"])
	proof["gate_false_above_reload"] = bool(above_gate.get("should_consume", true)) == false and is_equal_approx(float(above_gate.get("reload_counter", -1.0)), 120.0)

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172/N2173/N2174/N2175/N2176/N2177 proofs do), not simulate_factory,
	# so the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The shockwave tower tick models no other
	# consumers, so with a power consumer the first pass holds
	# only the power row. When the gate is false updateConsumption
	# forces efficiency to zero (BuildingComp.java:1960, `boolean
	# update = shouldConsume() && productionValid();` + 1992,
	# `if(!update){`); when the gate is true the N2177 power fold
	# is preserved. The counter charges by edelta() each tick
	# (ShockwaveTower.java:73, `(reloadCounter += edelta())`,
	# edelta() = efficiency * delta(), BuildingComp.java:1927-1929)
	# once updateConsumption has folded this tick's efficiency
	# (BuildingComp.java:2274 updateConsumption() runs before
	# :2277 updateTile()).
	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})

	# Fully reloaded at full power: the gate is false, so
	# efficiency folds to 0 even though power.status is 1.0 --
	# the N2177 gap (efficiency 1.0 vs Java 0.0) is closed.
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.0)

	# Uncharged at half power: the gate is true, so the N2177
	# power fold is preserved -- efficiency folds the power min 0.5.
	shockwave_tower_frame["reload_counter"] = 0.0
	shockwave_tower_frame["power_status"] = 0.5
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.5)

	# Counter charge: at full power the counter advances by
	# edelta() = efficiency * delta = 1.0 * (1/60) per tick.
	shockwave_tower_frame["reload_counter"] = 10.0
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["reload_counter_advances_by_edelta"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(shockwave_tower_frame.get("reload_counter", -1.0)), 10.0 + 1.0 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
