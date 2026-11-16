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

	# --- Pure canPlaceOn (N2345): UnitAssemblerModule overrides
	# canPlaceOn (UnitAssemblerModule.java:48-51, `return
	# getLink(team, tile.x, tile.y, rotation) != null;` at :50):
	# a module can be placed only where a fitting assembler is
	# linked. The frame already carries that getLink verdict as
	# frame["link"] -- the N2248 advance re-discovers it with
	# findLink (UnitAssemblerModule.java:79) on tileChanges --
	# so the pure source_unit_assembler_module_can_place_on_state
	# reads the verdict the frame carries (the N2330 UCL
	# canPlaceOn precedent) and returns {can_place_on}: true iff
	# frame["link"] != null. No link stamped (absent or null)
	# means CANNOT place -- the Java-exact default (the link
	# field defaults null, UnitAssemblerModule.java:72). The pure
	# does not read link_candidate: the candidate only becomes
	# the link on refresh. canPlaceOn is a placement gate, NOT
	# tick wiring: the driver never calls it each tick, so this
	# proof has no live-tick key -- the live placement call site
	# waits for its own slice.
	var mech_assembler := {"block": "mech-assembler"}
	var tank_assembler := {"block": "tank-assembler"}

	var linked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({"link": mech_assembler})
	var linked_other: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({"link": tank_assembler})
	proof["can_place_on_when_linked"] = bool(linked.get("can_place_on", false)) and bool(linked_other.get("can_place_on", false))

	var unlinked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({"link": null})
	proof["cannot_place_on_when_unlinked"] = bool(unlinked.get("can_place_on", true)) == false

	# No link input at all ({}), and a link candidate that has
	# NOT refreshed into the link yet, both mean cannot place:
	# the pure reads frame["link"] only.
	var no_input: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({})
	var candidate_only: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({"link": null, "link_candidate": mech_assembler})
	proof["cannot_place_on_without_link_input"] = bool(no_input.get("can_place_on", true)) == false and bool(candidate_only.get("can_place_on", true)) == false

	# The post-refresh link: the N2248 advance refreshes the
	# frame link from the candidate on tileChanges, and the pure
	# reads that stamped verdict -- the composition the live
	# placement gate relies on. Without a tile change the link
	# stays null and the pure still refuses.
	var refreshed: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": -2, "tile_changes": 1, "link": null, "link_candidate": mech_assembler}, 1.0, 1.0)
	var after_refresh: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({"link": refreshed.get("link", null)})
	var no_refresh: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": null, "link_candidate": mech_assembler}, 1.0, 1.0)
	var after_no_refresh: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_can_place_on_state({"link": no_refresh.get("link", null)})
	proof["can_place_on_after_link_refresh"] = bool(after_refresh.get("can_place_on", false)) and bool(after_no_refresh.get("can_place_on", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleCanPlaceOnProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
