extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Accelerator getCursor rows (N2452):
	# Accelerator.getCursor() (Accelerator.java:244-245,
	# `return canLaunch() ? SystemCursor.hand :
	# super.getCursor();`) returns the hand cursor when
	# the launch gate passes, else the BuildingComp
	# super branch (BuildingComp.java:1683-1684,
	# `return block.configurable &&
	# interactable(player.team()) ? SystemCursor.hand :
	# SystemCursor.arrow;`). canLaunch()
	# (Accelerator.java:239-240) is the conjunction of
	# the environment half (isValid() / !net.client() /
	# state.isCampaign()) and the tick-state half
	# (efficiency > 0f, battery >= requirement -
	# 0.00001f, progress >= 1f, !launching), which the
	# EXISTING N2271 pure
	# source_accelerator_can_launch_state already
	# evaluates. The new pure takes that gate output as
	# the caller-supplied gate_can_launch and does NOT
	# recompute it: can_launch = gate_can_launch &&
	# is_valid && !is_client && is_campaign, and the
	# cursor is "hand" when can_launch, else "hand" iff
	# configurable && interactable, else "arrow".
	# Verify-first finding: Accelerator DOES set
	# `configurable = true;` in its constructor
	# (Accelerator.java:77), so the super-hand branch is
	# live for this def whenever the building is
	# interactable. The cursor tokens are the
	# SystemCursor names ("hand" / "arrow"), carried as
	# strings, never resolved to a Godot cursor object.
	var requirement := 1000000.0
	var gate_all_ok: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 1000000.0, 1.0, false, requirement)
	var gate_no_eff: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(0.0, 1000000.0, 1.0, false, requirement)

	# --- Launch hand: the full gate passes -- the N2271
	# gate output is true (efficiency 1.0, full battery,
	# progress 1.0, not launching) and the environment
	# is valid / not a client / campaign -- so
	# can_launch is true and the cursor is "hand".
	# The super inputs do not matter here: even a
	# non-configurable, non-interactable accelerator
	# shows the hand when the launch gate passes.
	var launch: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(bool(gate_all_ok.get("can_launch", false)), true, false, true, true, true)
	var launch_plain: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(bool(gate_all_ok.get("can_launch", false)), true, false, true, false, false)
	proof["cursor_hand_launch"] = bool(gate_all_ok.get("can_launch", false)) and bool(launch.get("can_launch", false)) and launch.get("cursor", "") == "hand" and bool(launch_plain.get("can_launch", false)) and launch_plain.get("cursor", "") == "hand"

	# --- Super hand: the tick-state gate fails
	# (efficiency 0, so the N2271 output is false) but
	# the environment is fine and the block is
	# configurable (true for this def,
	# Accelerator.java:77) + interactable -- so
	# can_launch is false and the cursor is still
	# "hand" via the BuildingComp super branch.
	var super_hand: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(bool(gate_no_eff.get("can_launch", true)), true, false, true, true, true)
	proof["cursor_super_hand"] = bool(gate_no_eff.get("can_launch", true)) == false and bool(super_hand.get("can_launch", true)) == false and super_hand.get("cursor", "") == "hand"

	# --- Arrow: the gate fails and the super branch
	# fails too -- once because the block is not
	# configurable, once because it is not
	# interactable, once because it is neither. All
	# three read "arrow" (the N554 BuildingComp
	# precedent: hand needs BOTH predicates).
	var arrow_not_configurable: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(false, true, false, true, false, true)
	var arrow_not_interactable: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(false, true, false, true, true, false)
	var arrow_neither: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(false, true, false, true, false, false)
	proof["cursor_arrow"] = bool(arrow_not_configurable.get("can_launch", true)) == false and arrow_not_configurable.get("cursor", "") == "arrow" and bool(arrow_not_interactable.get("can_launch", true)) == false and arrow_not_interactable.get("cursor", "") == "arrow" and bool(arrow_neither.get("can_launch", true)) == false and arrow_neither.get("cursor", "") == "arrow"

	# --- Environment invalid: the tick-state gate
	# passes but isValid() is false -- can_launch is
	# false. The super inputs are false here so the
	# cursor reads "arrow" and the key isolates the
	# environment half (a configurable + interactable
	# accelerator would still show the super hand).
	var env_invalid: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(bool(gate_all_ok.get("can_launch", false)), false, false, true, false, false)
	proof["env_invalid"] = bool(env_invalid.get("can_launch", true)) == false and env_invalid.get("cursor", "") == "arrow"

	# --- Environment client: the tick-state gate
	# passes but net.client() is true -- can_launch is
	# false (Java checks !net.client()).
	var env_client: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(bool(gate_all_ok.get("can_launch", false)), true, true, true, false, false)
	proof["env_client"] = bool(env_client.get("can_launch", true)) == false and env_client.get("cursor", "") == "arrow"

	# --- Environment not campaign: the tick-state gate
	# passes but state.isCampaign() is false --
	# can_launch is false (the accelerator is a
	# campaign-only launch block).
	var env_not_campaign: Dictionary = accelerator_build_state.source_accelerator_get_cursor_state(bool(gate_all_ok.get("can_launch", false)), true, false, false, false, false)
	proof["env_not_campaign"] = bool(env_not_campaign.get("can_launch", true)) == false and env_not_campaign.get("cursor", "") == "arrow"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorGetCursorRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
