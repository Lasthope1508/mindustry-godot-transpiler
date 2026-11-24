extends Node

const spawn_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- SpawnGroup.equals(Object) (N2457):
	# SpawnGroup.equals(Object) (SpawnGroup.java:181-190): the 5
	# distinct body exprs only -- the signature (:182) and the 4
	# lines of the return statement (:186-189). TRAP: the
	# comparison covers end, begin, spacing, max, unitScaling,
	# shields, shieldScaling, unitAmount, type, effect and items
	# ONLY -- spawn (:44), payloads (:46) and team (:52) are
	# deliberately NOT compared, so two groups differing only in
	# those fields are still equal. TRAP: the three floats use
	# Java Float.compare (NaN == NaN, -0.0f < 0.0f); GD `==`
	# gets both wrong (NaN != NaN, 0.0 == -0.0), so the GD
	# function compares floats through _float_compare. TRAP:
	# GDScript folds the -0.0 literal -- verified on Godot
	# 4.6.2 with standalone scripts: in a file whose first
	# zero constant is +0.0, even `0.0 * -1.0` and the `-0.0`
	# literal collapse to +0.0 bits -- so the proof builds -0.0
	# at runtime with "-0.0".to_float(), which keeps the sign
	# bit (also verified). The proof calls the pure function
	# with synthetic group dicts (no live tick, no wave state).
	# Group dicts use the camelCase keys the file already uses
	# for SpawnGroup (unitScaling, unitAmount); items is a
	# Dictionary {"item": <name>, "amount": <int>} or null,
	# per ItemStack.equals (same item + same amount).

	var base: Dictionary = {
		"type": "dagger",
		"end": 999999999,
		"begin": 0,
		"spacing": 1,
		"max": 40,
		"unitScaling": 2.0,
		"shields": 100.0,
		"shieldScaling": 5.0,
		"unitAmount": 3,
		"effect": null,
		"items": {"item": "copper", "amount": 10},
		"spawn": -1,
		"payloads": null,
		"team": null,
	}

	# Identical fields are equal, and the result has exactly 1 key.
	var identical: Dictionary = spawn_state.source_spawn_group_equals_state(base, base.duplicate(true))
	proof["identical_fields_true"] = identical.get("equals") == true and identical.size() == 1

	# The same dict is equal to itself (Java :183, `this == o`).
	proof["same_dict_true"] = spawn_state.source_spawn_group_equals_state(base, base).get("equals") == true

	# null and wrong-typed others are never equal (Java :184).
	proof["null_and_wrong_type_false"] = spawn_state.source_spawn_group_equals_state(base, null).get("equals") == false and spawn_state.source_spawn_group_equals_state(base, "dagger").get("equals") == false and spawn_state.source_spawn_group_equals_state(base, 42).get("equals") == false

	# TRAP: groups differing ONLY in spawn / payloads / team are
	# still equal -- those fields are deliberately absent from
	# equals (:186-189).
	var uncompared: Dictionary = base.duplicate(true)
	uncompared["spawn"] = 12345
	uncompared["payloads"] = ["dagger"]
	uncompared["team"] = "sharded"
	proof["uncompared_fields_ignored"] = spawn_state.source_spawn_group_equals_state(base, uncompared).get("equals") == true

	# TRAP: Float.compare treats NaN as equal to NaN -- GD `==`
	# says NaN != NaN, so this key forces the _float_compare path.
	var nan_a: Dictionary = base.duplicate(true)
	nan_a["unitScaling"] = NAN
	var nan_b: Dictionary = base.duplicate(true)
	nan_b["unitScaling"] = NAN
	proof["nan_scaling_equal"] = spawn_state.source_spawn_group_equals_state(nan_a, nan_b).get("equals") == true

	# TRAP: Float.compare says -0.0f < 0.0f -- GD `==` says
	# 0.0 == -0.0, so this key forces the sign-of-zero path.
	# -0.0 is built with "-0.0".to_float() (see the header
	# comment: a -0.0 literal would collapse to +0.0).
	var zero_a: Dictionary = base.duplicate(true)
	zero_a["shields"] = "0.0".to_float()
	var zero_b: Dictionary = base.duplicate(true)
	zero_b["shields"] = "-0.0".to_float()
	proof["negative_zero_shields_not_equal"] = spawn_state.source_spawn_group_equals_state(zero_a, zero_b).get("equals") == false and spawn_state.source_spawn_group_equals_state(zero_b, zero_a).get("equals") == false

	# One differing compared field makes groups unequal.
	var max_diff: Dictionary = base.duplicate(true)
	max_diff["max"] = 41
	var amount_diff: Dictionary = base.duplicate(true)
	amount_diff["unitAmount"] = 4
	proof["single_field_diff_false"] = spawn_state.source_spawn_group_equals_state(base, max_diff).get("equals") == false and spawn_state.source_spawn_group_equals_state(base, amount_diff).get("equals") == false

	# Differing items (amount, or dict vs null) make groups
	# unequal -- Structs.eq delegates to ItemStack.equals: same
	# item identity + same amount.
	var items_diff: Dictionary = base.duplicate(true)
	items_diff["items"] = {"item": "copper", "amount": 11}
	var items_null: Dictionary = base.duplicate(true)
	items_null["items"] = null
	proof["items_mismatch_false"] = spawn_state.source_spawn_group_equals_state(base, items_diff).get("equals") == false and spawn_state.source_spawn_group_equals_state(base, items_null).get("equals") == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SpawnGroupEqualsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
