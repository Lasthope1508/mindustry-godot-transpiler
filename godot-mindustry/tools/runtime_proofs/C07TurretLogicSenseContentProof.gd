extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret logic-processor sense Content leg (N2508):
	# SenseI.run() (LExecutor.java:681-718,
	# `public static class SenseI implements LInstruction{`,
	# :668) calls BuildingComp.sense(Content) for a `Content`
	# sensor (`if(sense instanceof Content co){` /
	# `to.setnum(se.sense(co));`, LExecutor.java:692-693).
	# BuildingComp.sense(Content) (BuildingComp.java:2139-2147)
	# reads the sensed Content from the live inventories: an
	# Item reads items.get(i) when items exists
	# (`if(content instanceof Item i && items != null) return items.get(i);`,
	# :2140), a Liquid reads liquids.get(l) when liquids exists
	# (`if(content instanceof Liquid l && liquids != null) return liquids.get(l);`,
	# :2141), a UnitType / Block reads getPayloads().get(...)
	# when payloads exist (`if(getPayloads() != null){` /
	# `if(content instanceof UnitType u) return getPayloads().get(u);` /
	# `if(content instanceof Block b) return getPayloads().get(b);`,
	# :2142-2144), and anything else returns Float.NaN
	# (`return Float.NaN; //invalid sense`, :2146). The leg
	# always writes with to.setnum, never to.setobj, so
	# output_kind is always "num". The counts are passed in as
	# params (the N2212/N2220 per-def-param precedent); the
	# pure function does not read the frame. There is no driver
	# tick line: the leg is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507 precedent).

	# Item copper: 12 copper in items reads 12.0 as num.
	var item_result: Dictionary = turret_build_state.source_logic_sense_content_state("item", true, 12.0, false, 0.0, false, 0.0, 0.0)
	proof["content_item_copper_num"] = bool(item_result.get("handled", false)) and String(item_result.get("output_kind", "")) == "num" and float(item_result.get("output_value", 0.0)) == 12.0 and not bool(item_result.get("is_invalid", true))

	# Liquid water: 7.5 water in liquids reads 7.5 as num.
	var liquid_result: Dictionary = turret_build_state.source_logic_sense_content_state("liquid", false, 0.0, true, 7.5, false, 0.0, 0.0)
	proof["content_liquid_water_num"] = bool(liquid_result.get("handled", false)) and String(liquid_result.get("output_kind", "")) == "num" and float(liquid_result.get("output_value", 0.0)) == 7.5 and not bool(liquid_result.get("is_invalid", true))

	# UnitType dagger: 3 dagger payloads read 3.0 as num.
	var unit_result: Dictionary = turret_build_state.source_logic_sense_content_state("unit", false, 0.0, false, 0.0, true, 3.0, 0.0)
	proof["content_unit_dagger_num"] = bool(unit_result.get("handled", false)) and String(unit_result.get("output_kind", "")) == "num" and float(unit_result.get("output_value", 0.0)) == 3.0 and not bool(unit_result.get("is_invalid", true))

	# Block duo: 2 duo payloads read 2.0 as num.
	var block_result: Dictionary = turret_build_state.source_logic_sense_content_state("block", false, 0.0, false, 0.0, true, 0.0, 2.0)
	proof["content_block_duo_num"] = bool(block_result.get("handled", false)) and String(block_result.get("output_kind", "")) == "num" and float(block_result.get("output_value", 0.0)) == 2.0 and not bool(block_result.get("is_invalid", true))

	# Item sensor with no items is invalid even when payloads
	# exist: the instanceof checks are ordered Item -> Liquid ->
	# payloads, so a non-payload Content kind never falls into
	# the payload legs.
	var no_items_result: Dictionary = turret_build_state.source_logic_sense_content_state("item", false, 0.0, false, 0.0, true, 3.0, 2.0)
	proof["content_item_no_items_invalid"] = bool(no_items_result.get("handled", false)) and String(no_items_result.get("output_kind", "")) == "num" and is_nan(float(no_items_result.get("output_value", 0.0))) and bool(no_items_result.get("is_invalid", false))

	# An unknown Content kind is an invalid sense: NaN.
	var unknown_result: Dictionary = turret_build_state.source_logic_sense_content_state("team", true, 12.0, true, 7.5, true, 3.0, 2.0)
	proof["content_unknown_kind_invalid"] = bool(unknown_result.get("handled", false)) and String(unknown_result.get("output_kind", "")) == "num" and is_nan(float(unknown_result.get("output_value", 0.0))) and bool(unknown_result.get("is_invalid", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretLogicSenseContentProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
