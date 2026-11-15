extends Node

const main_scene := preload("res://scenes/Main.tscn")
const constructor_build_state := preload("res://src/game/SourceConstructorBuildState.gd")
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

	# --- Pure shouldConsume gate (N2216):
	# BlockProducerBuild.shouldConsume()
	# (BlockProducer.java:102-104, `public boolean
	# shouldConsume(){` with `return super.shouldConsume() &&
	# recipe() != null;`, BlockProducer.java:103) -- the gate
	# reads the live recipe AND the enabled flag (`super` is
	# the BuildingComp default `return enabled;`,
	# BuildingComp.java:755-756; PayloadBlockBuild does NOT
	# override shouldConsume, so the gate is really `enabled
	# && recipe() != null`). The field is `public @Nullable
	# Block recipe;` (Constructor.java:59) on ConstructorBuild
	# (`public class ConstructorBuild extends
	# BlockProducerBuild{`, Constructor.java:58). The gate HAS
	# the enabled term via super -- the pure gate reads
	# frame["enabled"] too (the ItemBridge N2188 / RepairTurret
	# N2212 precedent). The gate reads only the null-ness of
	# frame["recipe"], so the present-recipe fixture below is a
	# minimal test-only Dictionary -- no real Block is built;
	# the port has no live recipe config fill on the building
	# frame yet (the config set / configClear path,
	# Constructor.java:31-38, waits for its own slice).
	var has_recipe: Dictionary = constructor_build_state.source_constructor_should_consume_state({"recipe": {"block": "conveyor"}})
	proof["gate_true_when_recipe_present"] = bool(has_recipe.get("should_consume", false)) and bool(has_recipe.get("has_recipe", false))

	var no_recipe: Dictionary = constructor_build_state.source_constructor_should_consume_state({"recipe": null})
	proof["gate_false_when_recipe_null"] = bool(no_recipe.get("should_consume", true)) == false and bool(no_recipe.get("has_recipe", true)) == false

	var disabled_has_recipe: Dictionary = constructor_build_state.source_constructor_should_consume_state({"recipe": {"block": "conveyor"}, "enabled": false})
	proof["gate_false_when_disabled"] = bool(disabled_has_recipe.get("should_consume", true)) == false and bool(disabled_has_recipe.get("has_recipe", false))

	# --- Live tick: the constructor is a Constructor build
	# with a power consumer (constructor, consumePower 2.5f;
	# large-constructor, consumePower 3f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/
	# N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/
	# N2170/N2171/N2172/N2173/N2174 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The constructor tick models
	# no other consumers, so with a power consumer the first
	# pass holds only the power row; when the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var constructor_cell := Vector2i(28, 21)
	var constructor := Sprite2D.new()
	game.add_child(constructor)
	game.call("record_placed_block", constructor, blocks_by_id["constructor"], constructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the recipe on it).
	constructor_build_state.source_constructor_bind_frame_state(constructor, blocks_by_id["constructor"])
	var constructor_frame: Dictionary = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})

	# A freshly bound frame carries the recipe key defaulting
	# to null (the Java field default) -- no recipe yet, so
	# the gate reads false and the constructor does not consume.
	proof["frame_recipe_default_null"] = constructor_frame.has("recipe") and constructor_frame["recipe"] == null

	# No recipe: gate false -> efficiency 0 even at half power.
	constructor_frame["recipe"] = null
	constructor_frame["power_status"] = 0.5
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(constructor_frame.get("efficiency", -1.0)), 0.0)

	# Recipe present: gate true -> efficiency folds the power
	# min 0.5 (the N2161 power fold preserved).
	constructor_frame["recipe"] = {"block": "conveyor"}
	# N2265: the dynamic row folds 0.0 without the recipe
	# requirements on hand, so seed the conveyor stack
	# (catalog requirements: copper 1) before ticking.
	constructor_frame["items"] = {"copper": 1}
	constructor_frame["power_status"] = 0.5
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(constructor_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ConstructorShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
