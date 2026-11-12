extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	# --- UnitFactory completion: BuildingComp.consume()
	# (BuildingComp.java:1911-1915) triggers every consumer at
	# unit completion (UnitFactory.java:420-436: progress >=
	# plan.time, payload = new UnitPayload(unit), consume()), and
	# only the item rows remove anything
	# (ConsumeItemDynamic.java:53-56: Math.round(amount *
	# multiplier), clamped at what the module holds,
	# ItemModule.java:258-259). The ground-factory dagger plan is
	# silicon 10 + lead 10 over 900 ticks (Blocks.java). ---
	var factory_frame: Dictionary = {"current_plan": 0, "block_implementation": "UnitFactory", "team_id": 1, "items": {"silicon": 15, "lead": 12}}
	var factory_bound: Dictionary = factory_build_state.source_bind_consumer_state(factory_frame, blocks_by_id["ground-factory"], catalog, {})
	var factory_rows: Array = factory_bound.get("rows", [])
	var factory_consumers: Array = factory_bound.get("consumers", [])
	proof["consume_factory_binds_two_rows"] = factory_rows.size() == 2
	var factory_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state(factory_frame, factory_consumers, factory_rows)
	proof["consume_factory_triggered_two"] = int(factory_consumed.get("triggered", -1)) == 2
	proof["consume_factory_removed_silicon_ten"] = int(Dictionary(factory_consumed.get("removed", {})).get("silicon", -1)) == 10
	proof["consume_factory_removed_lead_ten"] = int(Dictionary(factory_consumed.get("removed", {})).get("lead", -1)) == 10
	proof["consume_factory_silicon_left_five"] = int(Dictionary(factory_frame.get("items", {})).get("silicon", -1)) == 5
	proof["consume_factory_lead_left_two"] = int(Dictionary(factory_frame.get("items", {})).get("lead", -1)) == 2

	# --- Clamp: a factory holding less than the plan asks for
	# removes only what it holds, never below zero
	# (ItemModule.remove, ItemModule.java:258-259). ---
	var clamp_frame: Dictionary = {"current_plan": 0, "block_implementation": "UnitFactory", "team_id": 1, "items": {"silicon": 5, "lead": 3}}
	var clamp_bound: Dictionary = factory_build_state.source_bind_consumer_state(clamp_frame, blocks_by_id["ground-factory"], catalog, {})
	var clamp_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state(clamp_frame, clamp_bound.get("consumers", []), clamp_bound.get("rows", []))
	proof["consume_clamp_triggered_two"] = int(clamp_consumed.get("triggered", -1)) == 2
	proof["consume_clamp_removed_silicon_five"] = int(Dictionary(clamp_consumed.get("removed", {})).get("silicon", -1)) == 5
	proof["consume_clamp_removed_lead_three"] = int(Dictionary(clamp_consumed.get("removed", {})).get("lead", -1)) == 3
	proof["consume_clamp_silicon_left_zero"] = int(Dictionary(clamp_frame.get("items", {})).get("silicon", -1)) == 0
	proof["consume_clamp_lead_left_zero"] = int(Dictionary(clamp_frame.get("items", {})).get("lead", -1)) == 0

	# --- No plan: currentPlan -1 binds no dynamic rows
	# (UnitFactory.java:84 reads ItemStack.empty), so the trigger
	# removes nothing. ---
	var no_plan_frame: Dictionary = {"current_plan": -1, "block_implementation": "UnitFactory", "team_id": 1, "items": {"silicon": 10, "lead": 10}}
	var no_plan_bound: Dictionary = factory_build_state.source_bind_consumer_state(no_plan_frame, blocks_by_id["ground-factory"], catalog, {})
	proof["consume_no_plan_binds_zero_rows"] = Array(no_plan_bound.get("rows", [])).size() == 0
	var no_plan_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state(no_plan_frame, no_plan_bound.get("consumers", []), no_plan_bound.get("rows", []))
	proof["consume_no_plan_triggered_zero"] = int(no_plan_consumed.get("triggered", -1)) == 0
	proof["consume_no_plan_removed_empty"] = Dictionary(no_plan_consumed.get("removed", {})).is_empty()

	# --- Reconstructor completion (Reconstructor.java:340-349):
	# progress >= constructTime, the payload unit is upgraded,
	# progress %= 1f, consume(). The additive-reconstructor binds
	# its static rows silicon 40 + graphite 40 (Blocks.java). ---
	var recon_frame: Dictionary = {"current_plan": -1, "block_implementation": "Reconstructor", "team_id": 1, "items": {"silicon": 50, "graphite": 50}}
	var recon_bound: Dictionary = factory_build_state.source_bind_consumer_state(recon_frame, blocks_by_id["additive-reconstructor"], catalog, {})
	proof["consume_reconstructor_binds_two_rows"] = Array(recon_bound.get("rows", [])).size() == 2
	var recon_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state(recon_frame, recon_bound.get("consumers", []), recon_bound.get("rows", []))
	proof["consume_reconstructor_triggered_two"] = int(recon_consumed.get("triggered", -1)) == 2
	proof["consume_reconstructor_removed_silicon_forty"] = int(Dictionary(recon_consumed.get("removed", {})).get("silicon", -1)) == 40
	proof["consume_reconstructor_removed_graphite_forty"] = int(Dictionary(recon_consumed.get("removed", {})).get("graphite", -1)) == 40
	proof["consume_reconstructor_left_ten_each"] = int(Dictionary(recon_frame.get("items", {})).get("silicon", -1)) == 10 and int(Dictionary(recon_frame.get("items", {})).get("graphite", -1)) == 10

	# --- Unit cost: the family pays Rules.unitCost through the
	# N2097 callback (UnitFactory.java:109), so a team at unitCost
	# 2.0 removes twice the plan stacks. ---
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	var team_id := 1
	teams[team_id] = {"unitCostMultiplier": 2.0}
	game_rules["teams"] = teams
	var cost_frame: Dictionary = {"current_plan": 0, "block_implementation": "UnitFactory", "team_id": team_id, "rules_state": game_rules, "items": {"silicon": 25, "lead": 22}}
	var cost_bound: Dictionary = factory_build_state.source_bind_consumer_state(cost_frame, blocks_by_id["ground-factory"], catalog, {})
	var cost_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state(cost_frame, cost_bound.get("consumers", []), cost_bound.get("rows", []))
	proof["consume_unit_cost_two_triggered_two"] = int(cost_consumed.get("triggered", -1)) == 2
	proof["consume_unit_cost_two_removed_silicon_twenty"] = int(Dictionary(cost_consumed.get("removed", {})).get("silicon", -1)) == 20
	proof["consume_unit_cost_two_removed_lead_twenty"] = int(Dictionary(cost_consumed.get("removed", {})).get("lead", -1)) == 20
	teams[team_id] = {"unitCostMultiplier": 1.0}
	game_rules["teams"] = teams

	# --- Assembler: the tank-assembler binds one liquid row
	# (cyanogen 0.15, Blocks.java) and no item rows, so the trigger
	# skips it — ConsumeLiquid has no trigger override, its update
	# drains per tick. Its payload stacks (plan().requirements,
	# UnitAssembler.java:158) are the deferred plan-dynamics slice:
	# no payload module exists in the port yet, so nothing here
	# claims to remove them. ---
	var assembler_liquids := {"cyanogen": 10.0}
	var assembler_frame: Dictionary = {"current_plan": 0, "block_implementation": "UnitAssembler", "team_id": 1, "items": {}}
	var assembler_bound: Dictionary = factory_build_state.source_bind_consumer_state(assembler_frame, blocks_by_id["tank-assembler"], catalog, assembler_liquids)
	proof["consume_assembler_binds_one_liquid_row"] = Array(assembler_bound.get("rows", [])).size() == 1
	var assembler_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state(assembler_frame, assembler_bound.get("consumers", []), assembler_bound.get("rows", []))
	proof["consume_assembler_triggered_zero"] = int(assembler_consumed.get("triggered", -1)) == 0
	proof["consume_assembler_removed_empty"] = Dictionary(assembler_consumed.get("removed", {})).is_empty()
	proof["consume_assembler_cyanogen_unchanged"] = is_equal_approx(float(assembler_liquids.get("cyanogen", -1.0)), 10.0)

	# --- Empty frame: no rows, no consumers, nothing removed. ---
	var empty_consumed: Dictionary = factory_build_state.source_unit_factory_consume_state({}, [], [])
	proof["consume_empty_triggered_zero"] = int(empty_consumed.get("triggered", -1)) == 0
	proof["consume_empty_removed_empty"] = Dictionary(empty_consumed.get("removed", {})).is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitFactoryConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
