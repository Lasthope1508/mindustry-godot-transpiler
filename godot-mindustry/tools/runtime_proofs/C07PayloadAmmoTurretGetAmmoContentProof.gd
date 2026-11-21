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

	# --- PayloadTurretBuild.getAmmoContent() (N2368):
	# PayloadTurretBuild.getAmmoContent()
	# (PayloadAmmoTurret.java:148-157) returns the first ammo
	# key (in ammoKeys order) whose content is currently held
	# in the payloads seq, but ONLY when the payloads seq is
	# non-empty (`if(!payloads.isEmpty()){` guard) — or null
	# when payloads is empty or no key matches:
	# `public UnlockableContent getAmmoContent(){`
	# `if(!payloads.isEmpty()){`
	# `for(var content : ammoKeys){`
	# `if(payloads.contains(content)){`
	# `return content;`
	# `}`
	# `}`
	# `}`
	# `return null;`
	# `}`
	# on `public class PayloadTurretBuild extends TurretBuild{`
	# (PayloadAmmoTurret.java:94). The guard is the
	# distinguishing line against currentAmmo (N2358), which
	# scans unconditionally — same returned value, different
	# body, NO dedup. Against useAmmo (N2363): getAmmoContent
	# does NOT remove the content and does NOT return a
	# BulletType — it returns the content itself. The proof
	# calls the pure function with synthetic inputs (no live
	# tick). NO driver tick line: a pure accessor.

	# First match in ammoKeys order wins.
	var first_match: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead", "titanium"], ["lead"])
	proof["get_ammo_content_first_match"] = String(first_match.get("ammo_content", "")) == "lead"

	# AmmoKeys order beats payload order: titanium is held
	# too, but copper comes first in ammoKeys.
	var order_matters: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead", "titanium"], ["titanium", "copper"])
	proof["get_ammo_content_order_matters"] = String(order_matters.get("ammo_content", "")) == "copper"

	# Empty payloads returns null through the non-empty
	# guard (`if(!payloads.isEmpty()){`).
	var empty_guard: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead", "titanium"], [])
	proof["get_ammo_content_empty_guard_null"] = empty_guard.get("ammo_content", "not-null") == null

	# Held content outside ammoKeys returns null.
	var no_match: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead", "titanium"], ["silicon"])
	proof["get_ammo_content_no_match_null"] = no_match.get("ammo_content", "not-null") == null

	# Calling twice with the same inputs gives the same
	# result: nothing is removed (unlike useAmmo, which
	# consumes the content on the first call).
	var first_call: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead"], ["lead", "copper"])
	var second_call: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead"], ["lead", "copper"])
	proof["get_ammo_content_no_remove"] = String(first_call.get("ammo_content", "")) == "copper" and String(second_call.get("ammo_content", "")) == "copper"

	# Duplicate held content still returns the first match
	# in ammoKeys order.
	var duplicate_held: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_content_state(["copper", "lead"], ["lead", "lead"])
	proof["get_ammo_content_duplicate_held"] = String(duplicate_held.get("ammo_content", "")) == "lead"

	# Inputs are read, never written: both arrays are
	# unchanged after the call.
	var ammo_keys: Array = ["copper", "lead", "titanium"]
	var payload_contents: Array = ["lead"]
	var ammo_keys_before: Array = ammo_keys.duplicate()
	var payload_contents_before: Array = payload_contents.duplicate()
	bridge.source_payload_ammo_turret_build_get_ammo_content_state(ammo_keys, payload_contents)
	proof["get_ammo_content_input_unmutated"] = ammo_keys == ammo_keys_before and payload_contents == payload_contents_before

	# The result carries EXACTLY the one key.
	proof["get_ammo_content_returns_only_one_key"] = first_match.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadAmmoTurretGetAmmoContentProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
