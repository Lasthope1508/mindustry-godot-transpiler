extends Node

const spawn_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- SpawnGroup.toString() (N2492):
	# SpawnGroup.toString() (SpawnGroup.java:159-170):
	#     public String toString(){
	#         return "SpawnGroup{" +
	#         "type=" + type +
	#         ", end=" + end +
	#         ", begin=" + begin +
	#         ", spacing=" + spacing +
	#         ", max=" + max +
	#         ", unitScaling=" + unitScaling +
	#         ", unitAmount=" + unitAmount +
	#         ", effect=" + effect +
	#         ", items=" + items +
	#         '}';
	#     }
	# A mechanical concatenation of exactly the 9 fields
	# in Java order. The proof calls the pure function
	# with synthetic inputs (no live tick, no game
	# state): type/effect arrive as their print strings
	# (the N2457 name model), items as the N2457
	# {"item", "amount"} Dictionary model or null.

	# A full group renders the exact Java string: field
	# order, ", " separators and the ItemStack rendering
	# `item + ": " + amount` (ItemStack.java:82-84) are
	# all pinned by this one equality.
	proof["to_string_full_group"] = spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 2.5, 4, "burning", {"item": "copper", "amount": 10}).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=2.5, unitAmount=4, effect=burning, items=copper: 10}"

	# TRAP: the field default unitScaling is `never`
	# (SpawnGroup.java:36), (float)Integer.MAX_VALUE:
	# Java Float.toString renders it scientific as
	# "2.1474836E9" -- GD str() on the un-narrowed
	# double would print "2147483648.0". This call is
	# also the all-defaults group (end = never as an
	# int prints decimal).
	proof["to_string_never_scaling_scientific"] = spawn_state.source_spawn_group_to_string_state("dagger", 2147483647, 0, 1, 40, 2147483648.0, 1, null, null).get("to_string") == "SpawnGroup{type=dagger, end=2147483647, begin=0, spacing=1, max=40, unitScaling=2.1474836E9, unitAmount=1, effect=null, items=null}"

	# TRAP: Java concatenation prints a null reference
	# as "null" -- for type, for the @Nullable effect
	# ("Null to disable", :47) and for the @Nullable
	# items ("Null to disable", :49).
	proof["to_string_null_effect_and_items"] = spawn_state.source_spawn_group_to_string_state(null, 5, 1, 2, 10, 1.5, 3, null, null).get("to_string") == "SpawnGroup{type=null, end=5, begin=1, spacing=2, max=10, unitScaling=1.5, unitAmount=3, effect=null, items=null}"

	# TRAP: whole floats keep the decimal point --
	# Float.toString(1.0f) is "1.0", not "1", and
	# Float.toString(100.0f) is "100.0".
	proof["to_string_whole_float_keeps_point"] = spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 1.0, 4, null, null).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=1.0, unitAmount=4, effect=null, items=null}" and spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 100.0, 4, null, null).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=100.0, unitAmount=4, effect=null, items=null}"

	# TRAP: zero keeps its sign -- Float.toString(0.0f)
	# is "0.0" and Float.toString(-0.0f) is "-0.0".
	# The negative zero is produced by negating a
	# variable at runtime: in this Godot build a
	# script's float zero constants all take the sign
	# of the first zero constant in the file, so a
	# literal negative zero is not reliable here (the
	# GD function reads the sign off the float32 bit
	# pattern instead of String.num for the same
	# reason).
	var zero: float = 0.0
	var neg_zero: float = zero
	neg_zero = -neg_zero
	proof["to_string_zero_scaling_signs"] = spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, zero, 4, null, null).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=0.0, unitAmount=4, effect=null, items=null}" and spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, neg_zero, 4, null, null).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=-0.0, unitAmount=4, effect=null, items=null}"

	# TRAP: shields (:38) and shieldScaling (:40) are
	# NOT printed by toString -- they appear in equals
	# (N2457) and hashCode only. The rendered string
	# must contain neither name.
	var full_text: String = spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 2.5, 4, "burning", {"item": "copper", "amount": 10}).get("to_string")
	proof["to_string_omits_shield_fields"] = not full_text.contains("shields") and not full_text.contains("shieldScaling")

	# Float.toString switches notation at 1e-3: 0.001f
	# still prints plain as "0.001", 0.0001f prints
	# scientific as "1.0E-4".
	proof["to_string_small_scaling_notation"] = spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 0.001, 4, null, null).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=0.001, unitAmount=4, effect=null, items=null}" and spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 0.0001, 4, null, null).get("to_string") == "SpawnGroup{type=dagger, end=10, begin=2, spacing=3, max=40, unitScaling=1.0E-4, unitAmount=4, effect=null, items=null}"

	# The result carries exactly the one envelope key
	# (the N2365 Dictionary envelope precedent).
	var one_key_result: Dictionary = spawn_state.source_spawn_group_to_string_state("dagger", 10, 2, 3, 40, 2.5, 4, "burning", null)
	proof["to_string_returns_only_one_key"] = one_key_result.size() == 1 and one_key_result.has("to_string")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SpawnGroupToStringProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
