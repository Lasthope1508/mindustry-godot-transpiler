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

	# --- Turret peekAmmo() (N2329): the TurretBuild ammo-type accessor
	# (Turret.java:693-695):
	# `/** @return the ammo type that will be returned if useAmmo is called. */`
	# `public @Nullable BulletType peekAmmo(){`
	# `return ammo.size == 0 ? null : ammo.peek().type();`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). ammo is the TurretBuild field (`public Seq<AmmoEntry>
	# ammo = new Seq<>();`, Turret.java:282) and arrives as an explicit
	# param (the N2313 hasAmmo precedent): the ammo list as an Array of
	# {amount, item, type} dicts (the peek_ammo_stack_state convention
	# -- Seq.peek() is the last entry). AmmoEntry.type() (`public abstract
	# BulletType type();`, Turret.java:260) is NOT re-ported here: for
	# ItemEntry it resolves through the block ammoTypes map (`return
	# ammoTypes.get(item);`, ItemTurret.java:236-238) and the map itself
	# is NOT ported -- the BulletType NAME arrives as the explicit "type"
	# value on each entry dict. peekAmmo() reads only the peek: no amount
	# check and no swap, unlike hasAmmo() (N2313). NO driver tick line: a
	# pure accessor its callers read, not a per-tick write. The proof
	# calls the pure function with synthetic frames (no live tick).

	# The building frame (`this`) -- peekAmmo() does not read frame fields.
	var frame: Dictionary = {"marker": "turret-frame", "x": 5, "y": 7}

	# Empty ammo list is null (ammo.size == 0 fails).
	var empty_result: Dictionary = turret_build_state.source_turret_peek_ammo_state(frame, [])
	proof["peek_ammo_empty_null"] = empty_result.get("peek_ammo", "not-null") == null

	# A single stack returns its type name (the AmmoEntry.type() result).
	var single: Array = [{"amount": 2, "item": "copper", "type": "standard-copper"}]
	var single_result: Dictionary = turret_build_state.source_turret_peek_ammo_state(frame, single)
	proof["peek_ammo_single_returns_type"] = str(single_result.get("peek_ammo", "")) == "standard-copper"

	# The peek is the LAST entry (Seq.peek()), not the first:
	# [{copper}, {lead}] returns the lead entry's type.
	var two_stacks: Array = [{"amount": 2, "item": "copper", "type": "standard-copper"}, {"amount": 1, "item": "lead", "type": "standard-lead"}]
	var two_result: Dictionary = turret_build_state.source_turret_peek_ammo_state(frame, two_stacks)
	proof["peek_ammo_peek_is_last"] = str(two_result.get("peek_ammo", "")) == "standard-lead"

	# An entry without a "type" value is null (type() resolved to nothing).
	var no_type: Array = [{"amount": 2, "item": "copper"}]
	var no_type_result: Dictionary = turret_build_state.source_turret_peek_ammo_state(frame, no_type)
	proof["peek_ammo_missing_type_null"] = no_type_result.get("peek_ammo", "not-null") == null

	# The amount is ignored: peekAmmo() never checks amounts (unlike
	# hasAmmo()) -- an entry with amount 0 still returns its type.
	var zero_amount: Array = [{"amount": 0, "item": "copper", "type": "standard-copper"}]
	var zero_result: Dictionary = turret_build_state.source_turret_peek_ammo_state(frame, zero_amount)
	proof["peek_ammo_amount_ignored"] = str(zero_result.get("peek_ammo", "")) == "standard-copper"

	# The input ammo list is NOT mutated: peekAmmo() only reads the peek
	# (pure function -- the caller keeps its own list).
	proof["peek_ammo_input_unmutated"] = two_stacks.size() == 2 and str((two_stacks[0] as Dictionary).get("item", "")) == "copper" and str((two_stacks[1] as Dictionary).get("item", "")) == "lead" and str((two_stacks[1] as Dictionary).get("type", "")) == "standard-lead"

	# The result carries ONLY its one key: no frame echo, no extra state.
	proof["returns_only_one_key"] = empty_result.size() == 1 and single_result.size() == 1 and two_result.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretPeekAmmoProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
