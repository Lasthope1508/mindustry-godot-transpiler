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

	# --- The payload trigger: ConsumePayloadDynamic.trigger
	# (ConsumePayloadDynamic.java:34-39) removes
	# Math.round(amount * multiplier) per plan().requirements stack
	# from the building's payload module
	# (UnitAssembler.java:158), and UnitAssemblerBuild.spawned()
	# (UnitAssembler.java:543-571) clears the module at the end
	# (`blocks.clear();`, PayloadSeq.java:61-64). PayloadSeq.remove
	# (PayloadSeq.java:40-42) is `add(block, -amount)` — no clamp,
	# so a short stack still records the full requested removal.
	# The tank-assembler's tier-0 vanquish plan needs stell 4 +
	# tungsten-wall-large 10 (Blocks.java). ---
	var assembler_block = blocks_by_id["tank-assembler"]
	var plan_zero: Dictionary = factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 0)
	var met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 4, "tungsten-wall-large": 10}}
	var met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(met_frame, plan_zero)
	var met_removed: Dictionary = met.get("removed", {})
	proof["trigger_vanquish_met"] = int(met.get("triggered", -1)) == 2 and int(met_removed.get("stell", -1)) == 4 and int(met_removed.get("tungsten-wall-large", -1)) == 10 and bool(met.get("cleared", false)) and Dictionary(met.get("blocks", {})).is_empty() and int(met.get("total", -1)) == 0 and Dictionary(met_frame.get("blocks", {})).is_empty()

	# --- Short stack: stell 3 of 4 needed still removes 4 —
	# PayloadSeq.remove has no clamp (PayloadSeq.java:40-42) —
	# and the module is cleared afterwards anyway. ---
	var short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 3, "tungsten-wall-large": 10}}
	var short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(short_frame, plan_zero)
	var short_removed: Dictionary = short.get("removed", {})
	proof["trigger_vanquish_short_stell"] = int(short.get("triggered", -1)) == 2 and int(short_removed.get("stell", -1)) == 4 and int(short_removed.get("tungsten-wall-large", -1)) == 10 and Dictionary(short.get("blocks", {})).is_empty() and int(short.get("total", -1)) == 0

	# --- Empty module: nothing held, the trigger still records
	# the full requested removal and clears (an empty clear). ---
	var empty_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}
	var empty: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(empty_frame, plan_zero)
	var empty_removed: Dictionary = empty.get("removed", {})
	proof["trigger_empty_blocks"] = int(empty.get("triggered", -1)) == 2 and int(empty_removed.get("stell", -1)) == 4 and int(empty_removed.get("tungsten-wall-large", -1)) == 10 and Dictionary(empty.get("blocks", {})).is_empty() and int(empty.get("total", -1)) == 0

	# --- Tier-1 conquer plan: locus 6 + carbide-wall-large 20. ---
	var plan_one: Dictionary = factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 1)
	var conquer_met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"locus": 6, "carbide-wall-large": 20}}
	var conquer_met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(conquer_met_frame, plan_one)
	var conquer_met_removed: Dictionary = conquer_met.get("removed", {})
	proof["trigger_conquer_met"] = int(conquer_met.get("triggered", -1)) == 2 and int(conquer_met_removed.get("locus", -1)) == 6 and int(conquer_met_removed.get("carbide-wall-large", -1)) == 20 and Dictionary(conquer_met.get("blocks", {})).is_empty()
	var conquer_short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"locus": 6, "carbide-wall-large": 19}}
	var conquer_short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(conquer_short_frame, plan_one)
	var conquer_short_removed: Dictionary = conquer_short.get("removed", {})
	proof["trigger_conquer_short"] = int(conquer_short.get("triggered", -1)) == 2 and int(conquer_short_removed.get("carbide-wall-large", -1)) == 20 and Dictionary(conquer_short.get("blocks", {})).is_empty()

	# --- Unit cost: the family pays Rules.unitCost through the
	# N2097 callback (UnitAssembler.java:175), so a team at unitCost
	# 2.0 removes twice the plan stacks. ---
	var cost_met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0}, "blocks": {"stell": 8, "tungsten-wall-large": 20}}
	var cost_met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(cost_met_frame, plan_zero)
	var cost_met_removed: Dictionary = cost_met.get("removed", {})
	proof["trigger_unit_cost_two_met"] = int(cost_met.get("triggered", -1)) == 2 and int(cost_met_removed.get("stell", -1)) == 8 and int(cost_met_removed.get("tungsten-wall-large", -1)) == 20 and Dictionary(cost_met.get("blocks", {})).is_empty()
	var cost_short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0}, "blocks": {"stell": 4, "tungsten-wall-large": 10}}
	var cost_short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(cost_short_frame, plan_zero)
	var cost_short_removed: Dictionary = cost_short.get("removed", {})
	proof["trigger_unit_cost_two_short"] = int(cost_short.get("triggered", -1)) == 2 and int(cost_short_removed.get("stell", -1)) == 8 and int(cost_short_removed.get("tungsten-wall-large", -1)) == 20

	# --- Extra payloads past the requirements are cleared too:
	# spawned() always clears the whole module
	# (UnitAssembler.java:571), not just the plan stacks. ---
	var extra_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 100, "tungsten-wall-large": 100, "silicon": 5}}
	var extra: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(extra_frame, plan_zero)
	proof["trigger_extra_blocks_cleared"] = bool(extra.get("cleared", false)) and Dictionary(extra.get("blocks", {})).is_empty() and int(extra.get("total", -1)) == 0 and Dictionary(extra_frame.get("blocks", {})).is_empty()

	# --- Empty requirements: no stacks trigger, nothing removed,
	# but the clear still runs. ---
	var no_req: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state({"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}, {"requirements": []})
	proof["trigger_empty_requirements"] = int(no_req.get("triggered", -1)) == 0 and Dictionary(no_req.get("removed", {})).is_empty() and bool(no_req.get("cleared", false)) and Dictionary(no_req.get("blocks", {})).is_empty() and int(no_req.get("total", -1)) == 0

	# --- No plan: no requirements key reads as no stacks, so the
	# trigger removes nothing and still clears. ---
	var null_plan: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state({"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 2}}, {})
	proof["trigger_null_plan"] = int(null_plan.get("triggered", -1)) == 0 and Dictionary(null_plan.get("removed", {})).is_empty() and bool(null_plan.get("cleared", false)) and Dictionary(null_plan.get("blocks", {})).is_empty() and int(null_plan.get("total", -1)) == 0

	# --- Rounding: unitCost 1.5 needs Math.round(4 * 1.5) = 6
	# stell and Math.round(10 * 1.5) = 15 tungsten-wall-large. ---
	var rounding_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 1.5}, "blocks": {"stell": 6, "tungsten-wall-large": 15}}
	var rounding: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(rounding_frame, plan_zero)
	var rounding_removed: Dictionary = rounding.get("removed", {})
	proof["trigger_rounding_unit_cost_one_half"] = int(rounding.get("triggered", -1)) == 2 and int(rounding_removed.get("stell", -1)) == 6 and int(rounding_removed.get("tungsten-wall-large", -1)) == 15 and Dictionary(rounding.get("blocks", {})).is_empty()

	# --- Duplicate and zero-amount stacks: each PayloadStack row
	# triggers in Java, so duplicate rows accumulate in `removed`,
	# while a zero-amount row removes nothing and is skipped (like
	# the N2129 efficiency, where it cannot change the result). ---
	var dup_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 8, "tungsten-wall-large": 10}}
	var dup_plan: Dictionary = {"requirements": [{"item": "stell", "amount": 4}, {"item": "stell", "amount": 4}, {"item": "tungsten-wall-large", "amount": 0}]}
	var dup: Dictionary = factory_build_state.source_unit_factory_assembler_payload_trigger_state(dup_frame, dup_plan)
	var dup_removed: Dictionary = dup.get("removed", {})
	proof["trigger_duplicate_zero_amount_skipped"] = int(dup.get("triggered", -1)) == 2 and int(dup_removed.get("stell", -1)) == 8 and not dup_removed.has("tungsten-wall-large") and Dictionary(dup.get("blocks", {})).is_empty() and int(dup.get("total", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitAssemblerPayloadTriggerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
