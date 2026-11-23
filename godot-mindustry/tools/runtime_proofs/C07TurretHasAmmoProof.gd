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

	# --- Turret hasAmmo() (N2313): the TurretBuild ammo predicate
	# (Turret.java:698-713):
	# `public boolean hasAmmo(){`
	# `//skip first entry if it has less than the required amount of ammo`
	# `if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){`
	# `for(int i = 0; i < ammo.size; i ++){`
	# `if(ammo.get(i).amount >= ammoPerShot){`
	# `ammo.swap(ammo.size - 1, i);`
	# `break;`
	# `}`
	# `}`
	# `//used for "side-ammo" like gas in some turrets`
	# `if(!canConsume()) return false;`
	# `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). ammo is the TurretBuild field (`public Seq<AmmoEntry>
	# ammo = new Seq<>();`, Turret.java:282), ammoPerShot the block field
	# (`public int ammoPerShot = 1;`, Turret.java:49). Both arrive as
	# explicit params (the N2311/N2261 precedent): the ammo list as an
	# Array of {amount, item} dicts (the peek_ammo_stack_state convention
	# -- Seq.peek() is the last entry). canConsume() (Turret.java:624) and
	# cheating() are NOT ported here: their results arrive as explicit
	# bool params. The swap runs BEFORE the canConsume() gate (Java
	# order), so the returned ammo_stacks_after carries the swap even
	# when has_ammo is false for can_consume. NO driver tick line: a
	# predicate its callers read, not a per-tick write. The proof calls
	# the pure function with synthetic frames (no live tick).

	# The building frame (`this`) -- hasAmmo() does not read frame fields.
	var frame: Dictionary = {"marker": "turret-frame", "x": 5, "y": 7}

	# Empty ammo list is false (ammo.size > 0 fails).
	var empty_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, [], 1, true, false)
	proof["has_ammo_empty_false"] = empty_result.get("has_ammo", true) == false

	# A single sufficient stack is true (peek holds ammoPerShot).
	var single_enough: Array = [{"amount": 2, "item": "copper"}]
	var single_enough_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, single_enough, 1, true, false)
	proof["has_ammo_single_enough_true"] = single_enough_result.get("has_ammo", false) == true

	# A single short stack is false without cheating.
	var single_short: Array = [{"amount": 0, "item": "copper"}]
	var single_short_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, single_short, 1, true, false)
	proof["has_ammo_single_short_false"] = single_short_result.get("has_ammo", true) == false

	# A single short stack is true with cheating (cheating() bypasses amount).
	var single_cheat_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, single_short, 1, true, true)
	proof["has_ammo_single_short_cheating_true"] = single_cheat_result.get("has_ammo", false) == true

	# A short peek with a sufficient entry swaps it to the peek position:
	# [{copper: 2}, {lead: 0}] with ammoPerShot 1 becomes [{lead: 0}, {copper: 2}].
	var swap_stacks: Array = [{"amount": 2, "item": "copper"}, {"amount": 0, "item": "lead"}]
	var swap_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, swap_stacks, 1, true, false)
	var swap_after: Array = swap_result.get("ammo_stacks_after", [])
	proof["has_ammo_swap_to_sufficient"] = swap_result.get("has_ammo", false) == true and swap_after.size() == 2 and str((swap_after[1] as Dictionary).get("item", "")) == "copper" and int((swap_after[1] as Dictionary).get("amount", 0)) == 2 and str((swap_after[0] as Dictionary).get("item", "")) == "lead"

	# No sufficient entry means no swap: order is unchanged, result false.
	var no_sufficient: Array = [{"amount": 0, "item": "copper"}, {"amount": 0, "item": "lead"}]
	var no_sufficient_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, no_sufficient, 1, true, false)
	var no_sufficient_after: Array = no_sufficient_result.get("ammo_stacks_after", [])
	proof["has_ammo_no_sufficient_no_swap"] = no_sufficient_result.get("has_ammo", true) == false and no_sufficient_after.size() == 2 and str((no_sufficient_after[0] as Dictionary).get("item", "")) == "copper" and str((no_sufficient_after[1] as Dictionary).get("item", "")) == "lead"

	# can_consume false is false even with sufficient ammo -- and the swap
	# still applies (Java order: scan/swap first, gate second):
	# [{copper: 2}, {lead: 0}] becomes [{lead: 0}, {copper: 2}] but has_ammo false.
	var gate_stacks: Array = [{"amount": 2, "item": "copper"}, {"amount": 0, "item": "lead"}]
	var gate_result: Dictionary = turret_build_state.source_turret_has_ammo_state(frame, gate_stacks, 1, false, false)
	var gate_after: Array = gate_result.get("ammo_stacks_after", [])
	proof["has_ammo_cannot_consume_false"] = gate_result.get("has_ammo", true) == false and gate_after.size() == 2 and str((gate_after[1] as Dictionary).get("item", "")) == "copper"

	# The input ammo list is NOT mutated: the swap lands on a deep copy
	# (pure function -- the caller keeps its own list).
	proof["has_ammo_input_unmutated"] = swap_stacks.size() == 2 and str((swap_stacks[0] as Dictionary).get("item", "")) == "copper" and str((swap_stacks[1] as Dictionary).get("item", "")) == "lead" and gate_stacks.size() == 2 and str((gate_stacks[0] as Dictionary).get("item", "")) == "copper"

	# The result carries ONLY its two keys: no frame echo, no extra state.
	proof["returns_only_two_keys"] = swap_result.size() == 2 and empty_result.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretHasAmmoProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
