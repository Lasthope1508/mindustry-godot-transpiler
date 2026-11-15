extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
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

	# --- Pure module gate (N2299): `return link != null &&
	# this.payload == null && link.acceptPayload(this, payload);`
	# (UnitAssemblerModule.java:110-111, in world/blocks/units/
	# -- the DEFERRED entry's :125-127 cite is inside
	# onRemoved). The link verdict comes from the assembler
	# gate below (the slice owns both pures).
	var direct_accepts: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_accept_payload_state(true, false, true)
	var link_verdict: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": false, "payload_content_equals": false, "blocks": {}}, [{"item": "router", "amount": 5}], 1.0, true)
	var composed_accepts: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_accept_payload_state(true, false, bool(link_verdict.get("accepts", false)))
	proof["module_accepts_when_linked_empty_link_accepts"] = bool(direct_accepts.get("accepts", false)) and bool(direct_accepts.get("has_link", false)) and bool(direct_accepts.get("has_payload", true)) == false and bool(direct_accepts.get("link_accepts", false)) and bool(link_verdict.get("accepts", false)) and bool(composed_accepts.get("accepts", false))

	var unlinked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_accept_payload_state(false, false, true)
	var occupied: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_accept_payload_state(true, true, true)
	var link_rejects: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_accept_payload_state(true, false, false)
	proof["module_rejects_when_unlinked"] = bool(unlinked.get("accepts", true)) == false and bool(occupied.get("accepts", true)) == false and bool(link_rejects.get("accepts", true)) == false

	# --- Pure assembler gate (N2299): `var plan = plan();` /
	# `return (this.payload == null || (source instanceof
	# UnitAssemblerModuleBuild)) &&` /
	# `plan.requirements.contains(b -> b.item ==
	# payload.content() &&` / `blocks.get(payload.content()) <
	# Mathf.round(b.amount * state.rules.unitCost(team)) -` /
	# `(source instanceof UnitAssemblerModuleBuild &&
	# (this.payload != null && this.payload.contentEquals(
	# payload)) ? 1 : 0));` (UnitAssembler.java:722-727).
	# The quota pins the round-half-up boundary: amount 5 at
	# unit_cost 0.5 is 2.5, which rounds to 3 (roundi(2.5)
	# == 3, like arc Mathf.round's BIG_ENOUGH trick,
	# Mathf.java:500-501) -- so 2 stored accepts and 3 stored
	# rejects.
	var below_quota: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": false, "payload_content_equals": false, "blocks": {"router": 2}}, [{"item": "router", "amount": 5}], 0.5, true)
	proof["assembler_accepts_below_quota"] = bool(below_quota.get("accepts", false)) and bool(below_quota.get("requirement_found", false)) and int(below_quota.get("quota", -1)) == 3 and int(below_quota.get("stored_count", -1)) == 2 and int(below_quota.get("module_adjustment", -1)) == 0

	var at_quota: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": false, "payload_content_equals": false, "blocks": {"router": 3}}, [{"item": "router", "amount": 5}], 0.5, true)
	var no_requirement: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": false, "payload_content_equals": false, "blocks": {}}, [{"item": "conveyor", "amount": 5}], 0.5, true)
	var no_payload_offered: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({}, {"has_payload": false, "payload_content_equals": false, "blocks": {}}, [{"item": "router", "amount": 5}], 0.5, true)
	proof["assembler_rejects_at_quota"] = bool(at_quota.get("accepts", true)) == false and int(at_quota.get("quota", -1)) == 3 and int(at_quota.get("stored_count", -1)) == 3 and bool(no_requirement.get("accepts", true)) == false and bool(no_requirement.get("requirement_found", true)) == false and int(no_requirement.get("quota", -1)) == 0 and bool(no_payload_offered.get("accepts", true)) == false

	# --- The module-source -1 adjustment: the assembler
	# already holds an equal payload and the source is a
	# module, so the quota drops from 3 to 2 -- 2 stored now
	# rejects, 1 stored still accepts. A non-module source
	# with a held assembler payload rejects outright (the
	# first term needs payload empty OR a module source).
	var adjusted_rejects: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": true, "payload_content_equals": true, "blocks": {"router": 2}}, [{"item": "router", "amount": 5}], 0.5, true)
	var adjusted_accepts: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": true, "payload_content_equals": true, "blocks": {"router": 1}}, [{"item": "router", "amount": 5}], 0.5, true)
	var non_module_blocked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_accept_payload_state({"content_item": "router"}, {"has_payload": true, "payload_content_equals": true, "blocks": {}}, [{"item": "router", "amount": 5}], 0.5, false)
	proof["module_source_minus_one_adjustment"] = int(adjusted_rejects.get("module_adjustment", -1)) == 1 and int(adjusted_rejects.get("quota", -1)) == 2 and bool(adjusted_rejects.get("accepts", true)) == false and bool(adjusted_accepts.get("accepts", false)) and bool(non_module_blocked.get("accepts", true)) == false and int(non_module_blocked.get("module_adjustment", -1)) == 0

	# --- Live tick: the unit-assembler-module is a
	# UnitAssemblerModule build with a power consumer
	# (consumePower 3.5f), placed live; the tick driver is
	# called directly (as the N2168 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The frame is seeded with a
	# link candidate, an offered payload, the link assembler
	# state, and the plan; the fresh frame's lastChange is -2
	# against tileChanges 1, so the first tick refreshes the
	# link to the candidate and -- with the link present, no
	# held payload, and the assembler below quota (0 stored
	# of 5) -- exposes both verdicts true on the frame. The
	# N2248 handoff gate reads the live-stamped link
	# verdict (N2314), but the module holds no payload,
	# so nothing hands off here.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var mech_assembler := {"block": "mech-assembler"}
	var unit_assembler_module_cell := Vector2i(28, 21)
	var unit_assembler_module := Sprite2D.new()
	game.add_child(unit_assembler_module)
	game.call("record_placed_block", unit_assembler_module, blocks_by_id["basic-assembler-module"], unit_assembler_module_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to seed the link candidate +
	# offered payload + assembler + plan on it).
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(unit_assembler_module, blocks_by_id["basic-assembler-module"])
	var unit_assembler_module_frame: Dictionary = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})

	unit_assembler_module_frame["link_candidate"] = mech_assembler
	unit_assembler_module_frame["offered_payload"] = {"content_item": "router"}
	unit_assembler_module_frame["assembler"] = {"has_payload": false, "payload_content_equals": false, "blocks": {}}
	unit_assembler_module_frame["plan_requirements"] = [{"item": "router", "amount": 5}]
	unit_assembler_module_frame["unit_cost"] = 1.0
	unit_assembler_module_frame["power_status"] = 1.0
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["live_tick_exposes_both_verdicts"] = unit_assembler_module_frame.get("link", null) == mech_assembler and bool(unit_assembler_module_frame.get("accepts_payload", false)) and bool(unit_assembler_module_frame.get("link_accepts_payload", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleAcceptPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
