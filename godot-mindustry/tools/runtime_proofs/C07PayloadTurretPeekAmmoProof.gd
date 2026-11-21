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

	# --- PayloadTurretBuild.peekAmmo() (N2371):
	# PayloadTurretBuild.peekAmmo()
	# (PayloadAmmoTurret.java:133-140) returns the BulletType
	# of the first ammo key (in ammoKeys order) whose content
	# is currently held in the payloads seq, or null when
	# none matches — WITHOUT removing the content:
	# `public BulletType peekAmmo(){`
	# `for(var content : ammoKeys){`
	# `if(payloads.contains(content)){`
	# `return ammoTypes.get(content);`
	# `}`
	# `}`
	# `return null;`
	# `}`
	# on `public class PayloadTurretBuild extends TurretBuild{`
	# (PayloadAmmoTurret.java:94). The distinguishing line
	# against useAmmo (N2363) is the ABSENCE of
	# `payloads.remove(content);`: peekAmmo returns the same
	# BulletType useAmmo returns, but leaves the payloads seq
	# untouched. Against getAmmoContent (N2368): peekAmmo
	# returns a BulletType through ammoTypes, not the content
	# itself. The proof calls the pure function with
	# synthetic inputs (no live tick). NO driver tick line:
	# a pure function.

	var ammo_types: Dictionary = {"copper": "copper-bullet", "lead": "lead-bullet", "titanium": "titanium-bullet"}

	# First match in ammoKeys order wins.
	var first_match: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead", "titanium"], ["lead"], ammo_types)
	proof["peek_ammo_first_match"] = String(first_match.get("peeked_ammo", "")) == "lead-bullet"

	# AmmoKeys order beats payload order: titanium is held
	# too, but copper comes first in ammoKeys.
	var order_matters: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead", "titanium"], ["titanium", "copper"], ammo_types)
	proof["peek_ammo_order_matters"] = String(order_matters.get("peeked_ammo", "")) == "copper-bullet"

	# Empty payloads returns null.
	var none_null: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead", "titanium"], [], ammo_types)
	proof["peek_ammo_none_null"] = none_null.get("peeked_ammo", "not-null") == null

	# Held content outside ammoKeys returns null.
	var no_match: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead", "titanium"], ["silicon"], ammo_types)
	proof["peek_ammo_no_match_null"] = no_match.get("peeked_ammo", "not-null") == null

	# Calling twice with the same inputs gives the same
	# result: nothing is removed (unlike useAmmo, which
	# consumes the content on the first call).
	var first_call: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead"], ["lead", "copper"], ammo_types)
	var second_call: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead"], ["lead", "copper"], ammo_types)
	proof["peek_ammo_no_remove"] = String(first_call.get("peeked_ammo", "")) == "copper-bullet" and String(second_call.get("peeked_ammo", "")) == "copper-bullet"

	# Duplicate held content still returns the first match
	# in ammoKeys order.
	var duplicate_held: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "lead"], ["lead", "lead"], ammo_types)
	proof["peek_ammo_duplicate_held"] = String(duplicate_held.get("peeked_ammo", "")) == "lead-bullet"

	# Held content with no ammoTypes entry returns null
	# (ObjectMap.get on a missing key).
	var missing_type: Dictionary = bridge.source_payload_turret_build_peek_ammo_state(["copper", "silicon"], ["silicon"], ammo_types)
	proof["peek_ammo_missing_type_null"] = missing_type.get("peeked_ammo", "not-null") == null

	# Inputs are read, never written: all three inputs are
	# unchanged after the call.
	var ammo_keys: Array = ["copper", "lead", "titanium"]
	var payload_contents: Array = ["lead"]
	var ammo_types_before: Dictionary = ammo_types.duplicate()
	var ammo_keys_before: Array = ammo_keys.duplicate()
	var payload_contents_before: Array = payload_contents.duplicate()
	bridge.source_payload_turret_build_peek_ammo_state(ammo_keys, payload_contents, ammo_types)
	proof["peek_ammo_input_unmutated"] = ammo_keys == ammo_keys_before and payload_contents == payload_contents_before and ammo_types == ammo_types_before

	# The result carries EXACTLY the one key.
	proof["peek_ammo_returns_only_one_key"] = first_match.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadTurretPeekAmmoProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
