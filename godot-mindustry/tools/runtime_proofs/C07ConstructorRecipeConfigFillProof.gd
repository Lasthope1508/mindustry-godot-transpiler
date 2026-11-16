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

	# --- Live recipe config fill (N2462, DEFERRED #95):
	# the tick wires the EXISTING N2455 config pure
	# (source_constructor_config_state, Constructor.java:
	# 32-37 + :31/:38) into the live tick -- no new pure,
	# no register (the N2413 wiring-only precedent). The
	# input handler's pending config action arrives on the
	# frame as frame["recipe_config"] = {action: "set" /
	# "clear" / "none", block: the family recipe fixture
	# {"block": <catalog id>} or null, can_produce: the
	# caller-supplied verdict of
	# source_constructor_can_produce_state} (the N2449
	# discriminated-action precedent); an absent key is
	# action "none" (no-op). The tick stamps frame["recipe"]
	# + frame["progress"] BEFORE the recipe resolution, the
	# shouldConsume gate and the consumption fold -- Java
	# order: config is an input-handler event, applied
	# before the tick's consumption fold, so the gate sees
	# the new recipe the same tick. The reset runs BEFORE
	# the canProduce gate (:33 before :34); "clear" never
	# resets; a set of the SAME block resets nothing, so
	# re-applying the frame input every tick is harmless.
	# The conveyor fixture (catalog requirements: copper 1,
	# the N2216 precedent) is the recipe block throughout.
	# The constructor tick is called directly (the N2216
	# pattern), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status.
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
	# frame dict before the tick to seed recipe_config).
	constructor_build_state.source_constructor_bind_frame_state(constructor, blocks_by_id["constructor"])
	var constructor_frame: Dictionary = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})

	# --- Fill set stamps: a "set" action with a producible
	# block stamps the recipe on the frame the same tick.
	constructor_frame["recipe"] = null
	constructor_frame["progress"] = 0.0
	constructor_frame["items"] = {}
	constructor_frame["recipe_config"] = {"action": "set", "block": {"block": "conveyor"}, "can_produce": true}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["fill_set_stamps"] = constructor_frame.get("recipe", null) == {"block": "conveyor"}

	# --- Fill set resets progress: a "set" of a DIFFERENT
	# block resets progress to 0.0 (:33 before :34). No
	# items are seeded, so the dynamic row folds 0.0 and
	# the advance does not move progress after the reset.
	constructor_frame["recipe"] = null
	constructor_frame["progress"] = 0.5
	constructor_frame["items"] = {}
	constructor_frame["recipe_config"] = {"action": "set", "block": {"block": "conveyor"}, "can_produce": true}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["fill_set_resets_progress"] = is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.0) and constructor_frame.get("recipe", null) == {"block": "conveyor"}

	# --- Fill clear: a "clear" action nulls the recipe with
	# NO progress reset (configClear, :31/:38).
	constructor_frame["recipe"] = {"block": "conveyor"}
	constructor_frame["progress"] = 0.5
	constructor_frame["items"] = {}
	constructor_frame["recipe_config"] = {"action": "clear", "block": null, "can_produce": false}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["fill_clear"] = constructor_frame.get("recipe", {"block": "conveyor"}) == null and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.5)

	# --- Fill none: an absent frame["recipe_config"] key
	# AND an explicit "none" action both leave the recipe
	# and progress untouched. No items are seeded, so the
	# advance does not move progress in either tick.
	constructor_frame["recipe"] = {"block": "conveyor"}
	constructor_frame["progress"] = 0.5
	constructor_frame["items"] = {}
	constructor_frame.erase("recipe_config")
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	var none_absent_ok: bool = constructor_frame.get("recipe", null) == {"block": "conveyor"} and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.5)
	constructor_frame["recipe_config"] = {"action": "none", "block": null, "can_produce": false}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	var none_explicit_ok: bool = constructor_frame.get("recipe", null) == {"block": "conveyor"} and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.5)
	proof["fill_none"] = none_absent_ok and none_explicit_ok

	# --- Fill idempotent: re-applying "set" with the SAME
	# block resets nothing (:33's recipe != block guard is
	# false after the first apply), so two ticks leave the
	# recipe and progress untouched; "clear" on a null
	# recipe stays null. No items are seeded, so the
	# advance does not move progress in any tick.
	constructor_frame["recipe"] = {"block": "conveyor"}
	constructor_frame["progress"] = 0.5
	constructor_frame["items"] = {}
	constructor_frame["recipe_config"] = {"action": "set", "block": {"block": "conveyor"}, "can_produce": true}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	var set_same_ok: bool = constructor_frame.get("recipe", null) == {"block": "conveyor"} and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.5)
	constructor_frame["recipe"] = null
	constructor_frame["progress"] = 0.5
	constructor_frame["recipe_config"] = {"action": "clear", "block": null, "can_produce": false}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	var clear_null_ok: bool = constructor_frame.get("recipe", {"block": "conveyor"}) == null and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.5)
	proof["fill_idempotent"] = set_same_ok and clear_null_ok

	# --- Fill gate opens: the fill lands BEFORE the
	# consumption fold, so a constructor with a seeded
	# recipe_config gains its recipe and the shouldConsume
	# gate opens the SAME tick -- efficiency folds the
	# power min 0.5 instead of being forced to 0, and
	# progress advances 0.6 (buildSpeed) * 0.5 (efficiency)
	# * 1 tick = 0.3 (conveyor buildTime 1.0, so no
	# completion this tick).
	constructor_frame["recipe"] = null
	constructor_frame["progress"] = 0.0
	constructor_frame["items"] = {"copper": 1}
	constructor_frame["power_status"] = 0.5
	constructor_frame["recipe_config"] = {"action": "set", "block": {"block": "conveyor"}, "can_produce": true}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["fill_gate_opens"] = constructor_frame.get("recipe", null) == {"block": "conveyor"} and is_equal_approx(float(constructor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(constructor_frame.get("progress", -1.0)), 0.3)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ConstructorRecipeConfigFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
