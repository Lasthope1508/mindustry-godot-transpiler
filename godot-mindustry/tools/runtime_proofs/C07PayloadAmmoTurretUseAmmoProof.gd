extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourcePayloadAmmoTurretBuildPortBridge.gd")
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

	# --- PayloadTurretBuild.useAmmo() (N2363):
	# PayloadTurretBuild.useAmmo()
	# (PayloadAmmoTurret.java:122-131) consumes the first ammo
	# key (in ammoKeys order) whose content is currently held
	# in the payloads seq: it removes that content from the
	# seq and returns its BulletType from ammoTypes, or null
	# when none matches:
	# `public BulletType useAmmo(){`
	# `for(var content : ammoKeys){`
	# `if(payloads.contains(content)){`
	# `payloads.remove(content);`
	# `return ammoTypes.get(content);`
	# `}`
	# `}`
	# `return null;`
	# `}`
	# on `public class PayloadTurretBuild extends TurretBuild{`
	# (PayloadAmmoTurret.java:94). The payloads.remove
	# MUTATION is modeled as param in/out: the function
	# duplicates payload_contents, erases the consumed
	# content from the copy, and returns the updated list
	# as payload_contents in the result -- the input arrays
	# are never mutated. ammoTypes arrives as the explicit
	# ammo_types Dictionary param (content name -> bullet
	# type name). NO driver tick line: a pure function the
	# shoot path calls. The proof calls the pure function
	# with synthetic inputs (no live tick).

	var ammo_types: Dictionary = {"copper": "copper-bullet", "lead": "lead-bullet", "titanium": "titanium-bullet"}

	# First match in ammoKeys order wins, and only that
	# content is removed from the payloads.
	var first_match: Dictionary = bridge.source_payload_ammo_turret_build_use_ammo_state(["copper", "lead", "titanium"], ["lead"], ammo_types)
	proof["use_ammo_first_match"] = String(first_match.get("used_ammo", "")) == "lead-bullet" and first_match.get("payload_contents", ["not-empty"]) == []

	# AmmoKeys order beats payload order: titanium is held
	# too, but copper comes first in ammoKeys.
	var order_matters: Dictionary = bridge.source_payload_ammo_turret_build_use_ammo_state(["copper", "lead", "titanium"], ["titanium", "copper"], ammo_types)
	proof["use_ammo_order_matters"] = String(order_matters.get("used_ammo", "")) == "copper-bullet" and order_matters.get("payload_contents", ["not-titanium"]) == ["titanium"]

	# Empty payloads returns null and the list stays empty.
	var none_held: Dictionary = bridge.source_payload_ammo_turret_build_use_ammo_state(["copper", "lead", "titanium"], [], ammo_types)
	proof["use_ammo_none_null"] = none_held.get("used_ammo", "not-null") == null and none_held.get("payload_contents", ["not-empty"]) == []

	# Held content outside ammoKeys returns null and the
	# list is unchanged.
	var no_match: Dictionary = bridge.source_payload_ammo_turret_build_use_ammo_state(["copper", "lead", "titanium"], ["silicon"], ammo_types)
	proof["use_ammo_no_match_null"] = no_match.get("used_ammo", "not-null") == null and no_match.get("payload_contents", []) == ["silicon"]

	# Only the FIRST matched content is removed: the
	# duplicate lead stays, copper is gone.
	var removes_one: Dictionary = bridge.source_payload_ammo_turret_build_use_ammo_state(["copper", "lead"], ["lead", "copper", "lead"], ammo_types)
	proof["use_ammo_removes_only_first_match"] = String(removes_one.get("used_ammo", "")) == "copper-bullet" and removes_one.get("payload_contents", []) == ["lead", "lead"]

	# A second call on the returned list consumes the next
	# match in ammoKeys order.
	var second_call: Dictionary = bridge.source_payload_ammo_turret_build_use_ammo_state(["copper", "lead"], removes_one.get("payload_contents", []), ammo_types)
	proof["use_ammo_second_call_consumes_next"] = String(second_call.get("used_ammo", "")) == "lead-bullet" and second_call.get("payload_contents", ["not-empty"]) == ["lead"]

	# Inputs are read, never written: both arrays and the
	# ammo_types dict are unchanged after the call.
	var ammo_keys: Array = ["copper", "lead", "titanium"]
	var payload_contents: Array = ["lead"]
	var ammo_types_before: Dictionary = ammo_types.duplicate()
	var ammo_keys_before: Array = ammo_keys.duplicate()
	var payload_contents_before: Array = payload_contents.duplicate()
	bridge.source_payload_ammo_turret_build_use_ammo_state(ammo_keys, payload_contents, ammo_types)
	proof["use_ammo_input_unmutated"] = ammo_keys == ammo_keys_before and payload_contents == payload_contents_before and ammo_types == ammo_types_before

	# The result carries EXACTLY the two keys.
	proof["use_ammo_returns_only_two_keys"] = first_match.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadAmmoTurretUseAmmoProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
