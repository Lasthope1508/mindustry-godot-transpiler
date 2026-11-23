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

	# --- PayloadTurretBuild.currentAmmo() (N2358):
	# PayloadTurretBuild.currentAmmo()
	# (PayloadAmmoTurret.java:97-105) returns the first ammo
	# key (in ammoKeys order) whose content is currently held
	# in the payloads seq, or null when none matches:
	# `public UnlockableContent currentAmmo(){`
	# `for(var content : ammoKeys){`
	# `if(payloads.contains(content)){`
	# `return content;`
	# `}`
	# `}`
	# `return null;`
	# `}`
	# on `public class PayloadTurretBuild extends TurretBuild{`
	# (PayloadAmmoTurret.java:94). The payloads.contains
	# lookup is NOT ported: the payload contents arrive as
	# the explicit payload_contents param and ammoKeys as
	# the explicit ammo_keys param (the N2330 param
	# precedent). NO driver tick line: a pure accessor
	# the HUD caller reads. The proof calls the pure
	# function with synthetic array inputs (no live tick).

	# First match in ammoKeys order wins.
	var first_match: Dictionary = bridge.source_payload_ammo_turret_build_current_ammo_state(["copper", "lead", "titanium"], ["lead"])
	proof["current_ammo_first_match"] = String(first_match.get("current_ammo", "")) == "lead"

	# AmmoKeys order beats payload order: titanium is held
	# too, but copper comes first in ammoKeys.
	var order_matters: Dictionary = bridge.source_payload_ammo_turret_build_current_ammo_state(["copper", "lead", "titanium"], ["titanium", "copper"])
	proof["current_ammo_order_matters"] = String(order_matters.get("current_ammo", "")) == "copper"

	# Empty payloads returns null.
	var none_held: Dictionary = bridge.source_payload_ammo_turret_build_current_ammo_state(["copper", "lead", "titanium"], [])
	proof["current_ammo_none_null"] = none_held.get("current_ammo", "not-null") == null

	# Held content outside ammoKeys returns null.
	var no_match: Dictionary = bridge.source_payload_ammo_turret_build_current_ammo_state(["copper", "lead", "titanium"], ["silicon"])
	proof["current_ammo_no_match_null"] = no_match.get("current_ammo", "not-null") == null

	# Inputs are read, never written: both arrays are
	# unchanged after the call.
	var ammo_keys: Array = ["copper", "lead", "titanium"]
	var payload_contents: Array = ["lead"]
	var ammo_keys_before: Array = ammo_keys.duplicate()
	var payload_contents_before: Array = payload_contents.duplicate()
	bridge.source_payload_ammo_turret_build_current_ammo_state(ammo_keys, payload_contents)
	proof["current_ammo_input_unmutated"] = ammo_keys == ammo_keys_before and payload_contents == payload_contents_before

	# The result carries ONLY the one current_ammo key.
	proof["current_ammo_returns_only_one_key"] = first_match.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadAmmoTurretCurrentAmmoProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
