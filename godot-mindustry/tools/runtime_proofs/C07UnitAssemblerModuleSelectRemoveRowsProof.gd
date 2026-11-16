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

	# --- onRemoved / drawSelect rows (N2447):
	# UnitAssemblerModuleBuild.drawSelect() (UnitAssemblerModule.java:118-123)
	# is the TODO draw area? plus the link highlight
	# (Drawf.selected(link, Pal.accent) when linked -- the Building
	# overload, Drawf.java:330); onRemoved() (:125-131) is super.onRemoved()
	# plus the module unregister (link.removeModule(this) when linked).
	# Both are pure-only: the pure takes the caller-supplied link (the
	# N2351 frame-input format {"block", "cell": Vector2i} -- a link
	# without a cell reads as null, defensive like N2351) and returns the
	# two calls as data (the N2396 CALL-record precedent). The TODO has no
	# Java behaviour and is not ported; super.onRemoved() is recorded, not
	# modeled; removeModule itself is the assembler's method
	# (UnitAssembler.java:358) and is recorded as a call, not ported.
	# Pure-only: drawSelect is called by the selection UI and onRemoved by
	# the removal lifecycle, never by the tick, so this proof has no
	# live-tick key.

	# --- Null link: with no link both calls are null and has_link is
	# false (the Java `if(link != null){` gate in both methods).
	var unlinked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_select_remove_state(null)
	proof["select_null"] = unlinked.get("select_call", {}) == null and not bool(unlinked.get("has_link", true))
	proof["remove_null"] = unlinked.get("remove_call", {}) == null and not bool(unlinked.get("has_link", true))

	# --- Linked: with a link at cell (10, 20) the select call records
	# drawSelected on the link in Pal.accent, and the remove call records
	# removeModule on the same link. The select expr is the Java call and
	# the remove super expr records super.onRemoved().
	var linked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_select_remove_state({"block": "tank-assembler", "cell": Vector2i(10, 20)})
	var linked_select: Dictionary = linked.get("select_call", {})
	var linked_select_target: Dictionary = linked_select.get("target", {})
	var linked_remove: Dictionary = linked.get("remove_call", {})
	var linked_remove_target: Dictionary = linked_remove.get("target", {})
	proof["select_link"] = bool(linked.get("has_link", false)) and not linked_select.is_empty() and str(linked_select.get("method", "")) == "drawSelected" and str(linked_select_target.get("block", "")) == "tank-assembler" and linked_select_target.get("cell", Vector2i.ZERO) == Vector2i(10, 20) and str(linked.get("select_expr", "")) == "Drawf.selected(link, Pal.accent);"
	proof["select_accent"] = str(linked_select.get("color", "")) == "Pal.accent"
	proof["remove_link"] = bool(linked.get("has_link", false)) and not linked_remove.is_empty() and str(linked_remove.get("method", "")) == "removeModule" and str(linked_remove_target.get("block", "")) == "tank-assembler" and linked_remove_target.get("cell", Vector2i.ZERO) == Vector2i(10, 20) and str(linked.get("remove_expr", "")) == "link.removeModule(this);" and str(linked.get("remove_super_expr", "")) == "super.onRemoved();"

	# --- No-cell defensive: a link dict without a cell reads as null
	# (the N2351 precedent -- the cell helper skips a link without a
	# cell), and a non-Dictionary link reads as null too (the N2358
	# precedent) -- both calls null, has_link false, in both cases.
	var no_cell: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_select_remove_state({"block": "tank-assembler"})
	var not_a_dict: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_select_remove_state("tank-assembler")
	proof["link_no_cell_defensive"] = no_cell.get("select_call", {}) == null and no_cell.get("remove_call", {}) == null and not bool(no_cell.get("has_link", true)) and not_a_dict.get("select_call", {}) == null and not_a_dict.get("remove_call", {}) == null and not bool(not_a_dict.get("has_link", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleSelectRemoveRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
