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

	# --- The payload module: UnitAssemblerBuild.blocks
	# (UnitAssembler.java:323, `public PayloadSeq blocks = new
	# PayloadSeq();`), returned by getPayloads()
	# (UnitAssembler.java:717-719). ConsumePayloadDynamic.efficiency
	# (ConsumePayloadDynamic.java:24-32) is 1.0 only when every
	# requirement stack is held at Math.round(amount * multiplier)
	# (PayloadSeq.contains, PayloadSeq.java:71-73, get(block) >=
	# amount). The tank-assembler's tier-0 vanquish plan needs
	# stell 4 + tungsten-wall-large 10 (Blocks.java). ---
	var assembler_block = blocks_by_id["tank-assembler"]
	var plan_zero: Dictionary = factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 0)
	var met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 4, "tungsten-wall-large": 10}}
	var met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(met_frame, plan_zero)
	proof["payload_vanquish_met_efficiency_one"] = is_equal_approx(float(met.get("payload_efficiency", -1.0)), 1.0)
	proof["payload_vanquish_met_total_fourteen"] = int(met.get("total", -1)) == 14

	# --- One stack short: stell 3 of 4 needed reads 0.0. ---
	var short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 3, "tungsten-wall-large": 10}}
	var short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(short_frame, plan_zero)
	proof["payload_vanquish_short_stell_zero"] = is_equal_approx(float(short.get("payload_efficiency", -1.0)), 0.0)

	# --- Empty module: no payload held, nothing is contained. ---
	var empty_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}
	var empty: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(empty_frame, plan_zero)
	proof["payload_vanquish_empty_blocks_zero"] = is_equal_approx(float(empty.get("payload_efficiency", -1.0)), 0.0)
	proof["payload_vanquish_empty_total_zero"] = int(empty.get("total", -1)) == 0

	# --- No blocks key: Java constructs the field empty, never
	# null, so a missing key reads as an empty module. ---
	var missing_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1}
	var missing: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(missing_frame, plan_zero)
	proof["payload_missing_blocks_zero"] = is_equal_approx(float(missing.get("payload_efficiency", -1.0)), 0.0)

	# --- Tier-1 conquer plan: locus 6 + carbide-wall-large 20. ---
	var plan_one: Dictionary = factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 1)
	var conquer_met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"locus": 6, "carbide-wall-large": 20}}
	var conquer_met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(conquer_met_frame, plan_one)
	proof["payload_conquer_met_one"] = is_equal_approx(float(conquer_met.get("payload_efficiency", -1.0)), 1.0)
	var conquer_short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"locus": 6, "carbide-wall-large": 19}}
	var conquer_short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(conquer_short_frame, plan_one)
	proof["payload_conquer_short_zero"] = is_equal_approx(float(conquer_short.get("payload_efficiency", -1.0)), 0.0)

	# --- Unit cost: the family pays Rules.unitCost through the
	# N2097 callback (UnitAssembler.java:175), so a team at unitCost
	# 2.0 needs twice the plan stacks. ---
	var cost_short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0}, "blocks": {"stell": 4, "tungsten-wall-large": 10}}
	var cost_short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(cost_short_frame, plan_zero)
	proof["payload_unit_cost_two_short_zero"] = is_equal_approx(float(cost_short.get("payload_efficiency", -1.0)), 0.0)
	var cost_met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0}, "blocks": {"stell": 8, "tungsten-wall-large": 20}}
	var cost_met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(cost_met_frame, plan_zero)
	proof["payload_unit_cost_two_met_one"] = is_equal_approx(float(cost_met.get("payload_efficiency", -1.0)), 1.0)

	# --- Extra payloads past the requirements change nothing:
	# the check is per-stack containment, and the total counts
	# everything the module holds. ---
	var extra_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 100, "tungsten-wall-large": 100, "silicon": 5}}
	var extra: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(extra_frame, plan_zero)
	proof["payload_extra_blocks_one"] = is_equal_approx(float(extra.get("payload_efficiency", -1.0)), 1.0)
	proof["payload_extra_blocks_total"] = int(extra.get("total", -1)) == 205

	# --- Empty requirements: the loop over no stacks returns 1.0
	# (ConsumePayloadDynamic.efficiency, ConsumePayloadDynamic.java:24-32). ---
	var no_req: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state({"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}, {"requirements": []})
	proof["payload_empty_requirements_one"] = is_equal_approx(float(no_req.get("payload_efficiency", -1.0)), 1.0)

	# --- Rounding: unitCost 1.5 needs Math.round(4 * 1.5) = 6
	# stell and Math.round(10 * 1.5) = 15 tungsten-wall-large. ---
	var rounding_short_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 1.5}, "blocks": {"stell": 5, "tungsten-wall-large": 15}}
	var rounding_short: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(rounding_short_frame, plan_zero)
	proof["payload_rounding_short_zero"] = is_equal_approx(float(rounding_short.get("payload_efficiency", -1.0)), 0.0)
	var rounding_met_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 1.5}, "blocks": {"stell": 6, "tungsten-wall-large": 15}}
	var rounding_met: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state(rounding_met_frame, plan_zero)
	proof["payload_rounding_met_one"] = is_equal_approx(float(rounding_met.get("payload_efficiency", -1.0)), 1.0)

	# --- No plan: no requirements key reads as no stacks, so the
	# efficiency is 1.0. ---
	var null_plan: Dictionary = factory_build_state.source_unit_factory_assembler_payload_state({"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}, {})
	proof["payload_null_plan_one"] = is_equal_approx(float(null_plan.get("payload_efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitAssemblerPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
