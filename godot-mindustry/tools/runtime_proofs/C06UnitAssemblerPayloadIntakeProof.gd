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

	# --- The payload intake: the accept gates decide whether the
	# incoming payload fits the current plan, and yeetPayload adds
	# one of its content to the building's payload module
	# (UnitAssembler.java:688-690, `blocks.add(payload.content(),
	# 1);`). acceptUnitPayload (UnitAssembler.java:710-714) takes a
	# unit whose type is a requirement row under the cap
	# (`blocks.get(unit.type()) < Mathf.round(b.amount *
	# state.rules.unitCost(team))`); acceptPayload
	# (UnitAssembler.java:722-727) takes a block payload only when
	# the building holds nothing or the source is a module
	# (`(this.payload == null || (source instanceof
	# UnitAssemblerModuleBuild))`), under the same cap minus one
	# when the source is a module still holding the same content
	# (`contentEquals(payload)`). The tank-assembler's tier-0
	# vanquish plan needs stell 4 + tungsten-wall-large 10
	# (Blocks.java). ---
	var assembler_block = blocks_by_id["tank-assembler"]
	var plan_zero: Dictionary = factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 0)

	# --- Empty module: stell is a requirement row under its cap
	# (4 at unitCost 1.0), so the intake accepts and adds one. ---
	var empty_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}
	var empty: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(empty_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": false})
	var empty_blocks: Dictionary = empty.get("blocks", {})
	proof["intake_vanquish_stell_empty"] = bool(empty.get("accepted", false)) and int(empty.get("added", -1)) == 1 and int(empty_blocks.get("stell", -1)) == 1 and int(empty.get("total", -1)) == 1 and int(Dictionary(empty_frame.get("blocks", {})).get("stell", -1)) == 1

	# --- One stell held: still under the cap, so the intake
	# accepts again. ---
	var one_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 1}}
	var one: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(one_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": false})
	var one_blocks: Dictionary = one.get("blocks", {})
	proof["intake_vanquish_stell_again"] = bool(one.get("accepted", false)) and int(one.get("added", -1)) == 1 and int(one_blocks.get("stell", -1)) == 2 and int(one.get("total", -1)) == 2

	# --- At the cap: 4 held is not < Math.round(4 * 1.0) = 4, so
	# the gate rejects and nothing changes. ---
	var cap_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 4}}
	var cap: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(cap_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": false})
	var cap_blocks: Dictionary = cap.get("blocks", {})
	proof["intake_vanquish_stell_at_cap"] = not bool(cap.get("accepted", true)) and int(cap.get("added", -1)) == 0 and int(cap_blocks.get("stell", -1)) == 4 and int(cap.get("total", -1)) == 4

	# --- Unit cost: the family pays Rules.unitCost through the
	# N2097 callback (UnitAssembler.java:175), so a team at unitCost
	# 2.0 caps stell at 8 and 4 held still accepts. ---
	var cost_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0}, "blocks": {"stell": 4}}
	var cost: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(cost_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": false})
	var cost_blocks: Dictionary = cost.get("blocks", {})
	proof["intake_vanquish_stell_unit_cost_two"] = bool(cost.get("accepted", false)) and int(cost.get("added", -1)) == 1 and int(cost_blocks.get("stell", -1)) == 5 and int(cost.get("total", -1)) == 5

	# --- Module source holding the same payload: the in-transit
	# stell already counts as one, so the cap drops to 3 and 2 held
	# still accepts. ---
	var module_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 2}, "payload": "stell"}
	var module: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(module_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": true})
	var module_blocks: Dictionary = module.get("blocks", {})
	proof["intake_module_same_held_accepted"] = bool(module.get("accepted", false)) and int(module.get("added", -1)) == 1 and int(module_blocks.get("stell", -1)) == 3 and int(module.get("total", -1)) == 3

	# --- Module source at the adjusted cap: 3 held is not < 4 - 1,
	# so the gate rejects. ---
	var module_cap_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"stell": 3}, "payload": "stell"}
	var module_cap: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(module_cap_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": true})
	var module_cap_blocks: Dictionary = module_cap.get("blocks", {})
	proof["intake_module_same_held_at_adjusted_cap"] = not bool(module_cap.get("accepted", true)) and int(module_cap.get("added", -1)) == 0 and int(module_cap_blocks.get("stell", -1)) == 3 and int(module_cap.get("total", -1)) == 3

	# --- Non-module source with a held payload: the building holds
	# something and the source is not a module, so the gate rejects
	# whatever the cap. ---
	var held_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}, "payload": "stell"}
	var held: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(held_frame, plan_zero, {"content": "stell", "kind": "block", "source_is_module": false})
	var held_blocks: Dictionary = held.get("blocks", {})
	proof["intake_non_module_held_rejected"] = not bool(held.get("accepted", true)) and int(held.get("added", -1)) == 0 and Dictionary(held_blocks).is_empty() and int(held.get("total", -1)) == 0

	# --- Unit payload: acceptUnitPayload has no held-payload
	# precondition, so a dagger fits a synthetic dagger plan and
	# adds one. ---
	var unit_plan: Dictionary = {"requirements": [{"item": "dagger", "amount": 4}]}
	var unit_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}
	var unit: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(unit_frame, unit_plan, {"content": "dagger", "kind": "unit", "source_is_module": false})
	var unit_blocks: Dictionary = unit.get("blocks", {})
	proof["intake_unit_dagger_accepted"] = bool(unit.get("accepted", false)) and int(unit.get("added", -1)) == 1 and int(unit_blocks.get("dagger", -1)) == 1 and int(unit.get("total", -1)) == 1

	# --- Unit payload past the cap: 4 daggers held is not < 4, so
	# the gate rejects. ---
	var unit_cap_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {"dagger": 4}}
	var unit_cap: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(unit_cap_frame, unit_plan, {"content": "dagger", "kind": "unit", "source_is_module": false})
	var unit_cap_blocks: Dictionary = unit_cap.get("blocks", {})
	proof["intake_unit_dagger_at_cap"] = not bool(unit_cap.get("accepted", true)) and int(unit_cap.get("added", -1)) == 0 and int(unit_cap_blocks.get("dagger", -1)) == 4 and int(unit_cap.get("total", -1)) == 4

	# --- Unknown content: silicon is no requirement row of the
	# vanquish plan, so the gate rejects and nothing changes. ---
	var unknown_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}
	var unknown: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(unknown_frame, plan_zero, {"content": "silicon", "kind": "block", "source_is_module": false})
	var unknown_blocks: Dictionary = unknown.get("blocks", {})
	proof["intake_unknown_content_rejected"] = not bool(unknown.get("accepted", true)) and int(unknown.get("added", -1)) == 0 and Dictionary(unknown_blocks).is_empty() and int(unknown.get("total", -1)) == 0

	# --- Plan-less: no requirements key reads as no rows, so the
	# gate rejects. ---
	var no_plan_frame: Dictionary = {"block_implementation": "UnitAssembler", "team_id": 1, "blocks": {}}
	var no_plan: Dictionary = factory_build_state.source_unit_factory_assembler_payload_intake_state(no_plan_frame, {}, {"content": "stell", "kind": "block", "source_is_module": false})
	var no_plan_blocks: Dictionary = no_plan.get("blocks", {})
	proof["intake_plan_less_rejected"] = not bool(no_plan.get("accepted", true)) and int(no_plan.get("added", -1)) == 0 and Dictionary(no_plan_blocks).is_empty() and int(no_plan.get("total", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitAssemblerPayloadIntakeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
