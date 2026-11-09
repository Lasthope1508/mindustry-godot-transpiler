extends Node

const main_scene := preload("res://scenes/Main.tscn")
const consume_state := preload("res://src/game/SourceConsumeState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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
	var factory_impl: String = String(blocks_by_id["ground-factory"].implementation)
	var recon_impl: String = String(blocks_by_id["additive-reconstructor"].implementation)
	var drill_impl: String = String(blocks_by_id["mechanical-drill"].implementation)
	var pump_impl: String = String(blocks_by_id["mechanical-pump"].implementation)

	# --- a unit factory pays Rules.unitCost: global 2.0 x team 0.5. ---
	var factory: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": factory_impl, "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0, "teams": {1: {"unitCostMultiplier": 0.5}}}})
	proof["cost_multiplier_factory_unit_cost"] = is_equal_approx(float(factory.get("multiplier", -1.0)), 1.0)
	proof["cost_multiplier_factory_is_unit_factory"] = factory_impl == "UnitFactory"

	# --- a reconstructor on another team pays that team's unitCost. ---
	var recon: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": recon_impl, "team_id": 2, "rules_state": {"unitCostMultiplier": 1.0, "teams": {2: {"unitCostMultiplier": 3.0}}}})
	proof["cost_multiplier_reconstructor_team"] = is_equal_approx(float(recon.get("multiplier", -1.0)), 3.0)
	proof["cost_multiplier_reconstructor_is_reconstructor"] = recon_impl == "Reconstructor"

	# --- a unit factory with default rules pays 1.0. ---
	var factory_defaults: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": factory_impl, "team_id": 1, "rules_state": {}})
	proof["cost_multiplier_factory_defaults"] = is_equal_approx(float(factory_defaults.get("multiplier", -1.0)), 1.0)

	# --- non-factories ignore the rules and keep the 1.0 default. ---
	var drill: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": drill_impl, "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0, "teams": {1: {"unitCostMultiplier": 0.5}}}})
	proof["cost_multiplier_drill_default"] = is_equal_approx(float(drill.get("multiplier", -1.0)), 1.0)
	var pump: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": pump_impl, "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0, "teams": {1: {"unitCostMultiplier": 0.5}}}})
	proof["cost_multiplier_pump_default"] = is_equal_approx(float(pump.get("multiplier", -1.0)), 1.0)

	# --- a build without the keys keeps the 1.0 default. ---
	var bare: Dictionary = consume_state.source_cost_multiplier_for_block_state({})
	proof["cost_multiplier_bare_build_default"] = is_equal_approx(float(bare.get("multiplier", -1.0)), 1.0)

	# --- live drill: the tick sets the frame keys and the consumers
	# use the per-block Callable (the drill keeps 1.0 through it). ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var frame: Dictionary = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["cost_multiplier_live_frame_keys"] = String(frame.get("block_implementation", "")) == "Drill" and int(frame.get("team_id", -1)) == 1 and frame.get("rules_state", null) is Dictionary
	var live_consumers: Array = frame.get("consumers", [])
	proof["cost_multiplier_live_has_consumers"] = not live_consumers.is_empty()
	if not live_consumers.is_empty():
		var live_multiplier: float = float(live_consumers[0].cost_multiplier.call(frame).get("multiplier", -1.0))
		proof["cost_multiplier_live_drill_one"] = is_equal_approx(live_multiplier, 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("CostMultiplierForBlockProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
