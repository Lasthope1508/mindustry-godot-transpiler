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

	# --- Live tick: the handoff-gate wiring (N2314): the
	# unit-assembler-module is a UnitAssemblerModule build
	# with a power consumer (consumePower 3.5f), placed live;
	# the tick driver is called directly (as the N2168 proof
	# does), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Java is
	# `link.acceptPayload(this, payload)`
	# (UnitAssemblerModule.java:138, the full gate
	# `if(moveInPayload() && link != null &&
	# link.moduleFits(block, x, y, rotation) &&
	# !link.wasOccupied && link.acceptPayload(this, payload)
	# && efficiency > 0){`), i.e. the ASSEMBLER's gate
	# (UnitAssembler.java:722-727) -- NOT the module's own
	# gate (UnitAssemblerModule.java:110-111). The tick
	# evaluates the LINK verdict BEFORE the advance and
	# stamps frame["accept_payload"] from it, so the
	# advance (signature and call unchanged) reads the live
	# verdict; the stamp OVERWRITES any seeded frame input.
	# The module verdict does NOT drive the gate. One module
	# is ticked sequentially (the N2308 proof pattern), the
	# frame reset between cases; the held payload arrives
	# (pay_vector ZERO, so moveInPayload returns true on
	# the first tick) and the link refresh is forced with
	# last_change -2 whenever the link candidate changes.
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
	# frame dict before the tick to seed the payload + link
	# candidate + predicates + offer on it).
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(unit_assembler_module, blocks_by_id["basic-assembler-module"])
	var unit_assembler_module_frame: Dictionary = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})

	var accepting_assembler := {"has_payload": false, "payload_content_equals": false, "blocks": {}}
	var router_plan := [{"item": "router", "amount": 5}]

	unit_assembler_module_frame["power_status"] = 1.0
	unit_assembler_module_frame["link_candidate"] = mech_assembler
	unit_assembler_module_frame["module_fits"] = true
	unit_assembler_module_frame["was_occupied"] = false
	unit_assembler_module_frame["offered_payload"] = {"content_item": "router"}
	unit_assembler_module_frame["assembler"] = accepting_assembler
	unit_assembler_module_frame["plan_requirements"] = router_plan
	unit_assembler_module_frame["unit_cost"] = 1.0

	# Tick 1: the link accepts (router offered, assembler
	# empty, plan router 5 -- 0 stored of 5), so the tick
	# stamps accept_payload true and -- with full power --
	# the handoff fires, clearing the frame payload.
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["handoff_fires_when_link_accepts"] = is_equal_approx(float(unit_assembler_module_frame.get("efficiency", -1.0)), 1.0) and unit_assembler_module_frame.get("link", null) == mech_assembler and bool(unit_assembler_module_frame.get("link_refreshed", false)) and bool(unit_assembler_module_frame.get("accept_payload", false)) and bool(unit_assembler_module_frame.get("link_accepts_payload", false)) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", false)) and unit_assembler_module_frame.get("payload", {"block": "conveyor"}) == null

	# Tick 2: the link rejects (5 stored of 5 -- at quota),
	# so the tick stamps accept_payload false and the
	# handoff is blocked: the payload stays held even though
	# it arrived and the link fits.
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["assembler"] = {"has_payload": false, "payload_content_equals": false, "blocks": {"router": 5}}
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["handoff_blocked_when_link_rejects"] = bool(unit_assembler_module_frame.get("accept_payload", true)) == false and bool(unit_assembler_module_frame.get("link_accepts_payload", true)) == false and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", true)) == false and unit_assembler_module_frame.get("payload", null) != null

	# Tick 3: no link (the refresh is forced with
	# last_change -2 and a null candidate), so the handoff
	# is blocked even though the link verdict is true --
	# the gate needs link != null too. The module verdict
	# reads false (no link).
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["last_change"] = -2
	unit_assembler_module_frame["link_candidate"] = null
	unit_assembler_module_frame["assembler"] = accepting_assembler
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["handoff_blocked_without_link"] = unit_assembler_module_frame.get("link", {}) == null and bool(unit_assembler_module_frame.get("link_refreshed", false)) and bool(unit_assembler_module_frame.get("link_accepts_payload", false)) and bool(unit_assembler_module_frame.get("accepts_payload", true)) == false and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", true)) == false and unit_assembler_module_frame.get("payload", null) != null

	# Tick 4: the live tick wires the gate -- a stale
	# accept_payload=false seed is OVERWRITTEN by the true
	# link verdict, and the handoff fires. The link is
	# re-found (last_change -2 forces the refresh back to
	# the candidate).
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["last_change"] = -2
	unit_assembler_module_frame["link_candidate"] = mech_assembler
	unit_assembler_module_frame["accept_payload"] = false
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["live_tick_wires_the_gate"] = bool(unit_assembler_module_frame.get("accept_payload", false)) and bool(unit_assembler_module_frame.get("link_accepts_payload", false)) and unit_assembler_module_frame.get("link", null) == mech_assembler and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", false)) and unit_assembler_module_frame.get("payload", {"block": "conveyor"}) == null

	# Tick 5: the module verdict does NOT drive the gate --
	# the module gate evaluated on the PRE-tick state is
	# false (the module holds a payload: link present &&
	# payload held && link accepts is false), yet the
	# handoff fires on the link verdict. The post-tick
	# module verdict reads true (the payload cleared), so
	# the key pins the pre-tick pure verdict, not the frame.
	var pre_tick_module_verdict: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_accept_payload_state(true, true, true)
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["module_verdict_does_not_drive_gate"] = bool(pre_tick_module_verdict.get("accepts", true)) == false and bool(unit_assembler_module_frame.get("accept_payload", false)) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", false)) and unit_assembler_module_frame.get("payload", {"block": "conveyor"}) == null

	# Tick 6: efficiency zero (power_status 0.0) blocks the
	# handoff even though the link verdict is true -- the
	# gate needs efficiency > 0 too. The verdict still
	# stamps accept_payload true; only the gate fails.
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["power_status"] = 0.0
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["handoff_blocked_when_efficiency_zero"] = is_equal_approx(float(unit_assembler_module_frame.get("efficiency", -1.0)), 0.0) and bool(unit_assembler_module_frame.get("accept_payload", false)) and bool(unit_assembler_module_frame.get("link_accepts_payload", false)) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", true)) == false and unit_assembler_module_frame.get("payload", null) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleHandoffGateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
