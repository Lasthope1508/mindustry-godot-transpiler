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

	# --- PayloadTurretBuild.hasAmmo()+acceptPayload()+handlePayload() (N2387):
	# PayloadTurretBuild.hasAmmo()+acceptPayload()+handlePayload()
	# (PayloadAmmoTurret.java:107-110/:112-115/:117-120) groups
	# three one-line Build methods on the payload-ammo intake
	# concern: hasAmmo is `payloads.total() > 0`;
	# acceptPayload is `payloads.total() < maxAmmo` AND the
	# payload content is an ammo type
	# (`ammoTypes.containsKey(payload.content())`); handlePayload
	# adds the payload content to the seq
	# (`payloads.add(payload.content());`). The proof calls the
	# three pure functions with synthetic inputs (no live tick).
	# NO driver tick line of its own: pure intake predicates /
	# seq update.

	var ammo_types: Dictionary = {"copper": "copper-bullet", "lead": "lead-bullet"}

	# hasAmmo is true iff the seq holds at least one unit.
	var held: Dictionary = bridge.source_payload_ammo_turret_build_has_ammo_state(["copper"])
	proof["has_ammo_true_when_nonempty"] = bool(held.get("has_ammo", false))
	var empty_held: Dictionary = bridge.source_payload_ammo_turret_build_has_ammo_state([])
	proof["has_ammo_false_when_empty"] = not bool(empty_held.get("has_ammo", true))

	# acceptPayload accepts a known ammo content below maxAmmo
	# (maxAmmo 3 here, 2 units held).
	var accepted: Dictionary = bridge.source_payload_ammo_turret_build_accept_payload_state(["copper", "lead"], 3, ammo_types, "copper")
	proof["accept_payload_accepts_known_below_max"] = bool(accepted.get("accepts_payload", false))

	# acceptPayload refuses at capacity: 3 units held == maxAmmo 3.
	var at_max: Dictionary = bridge.source_payload_ammo_turret_build_accept_payload_state(["copper", "lead", "copper"], 3, ammo_types, "lead")
	proof["accept_payload_rejects_at_max"] = not bool(at_max.get("accepts_payload", true))

	# acceptPayload refuses an unknown content even with room.
	var unknown: Dictionary = bridge.source_payload_ammo_turret_build_accept_payload_state(["copper"], 3, ammo_types, "titanium")
	proof["accept_payload_rejects_unknown_content"] = not bool(unknown.get("accepts_payload", true))

	# handlePayload appends the content to the seq copy.
	var handled: Dictionary = bridge.source_payload_ammo_turret_build_handle_payload_state(["copper"], "lead")
	var handled_contents: Array = handled.get("payload_contents", [])
	proof["handle_payload_adds_content"] = handled_contents == ["copper", "lead"]

	# A null content is a no-op: PayloadSeq.add returns early
	# on null, so the seq comes back unchanged.
	var handled_null: Dictionary = bridge.source_payload_ammo_turret_build_handle_payload_state(["copper"], null)
	proof["handle_payload_null_content_noop"] = (handled_null.get("payload_contents", []) as Array) == ["copper"]

	# Inputs are read, never written: the payload contents
	# array is unchanged after handlePayload (fresh copy out).
	var contents_before: Array = ["copper"]
	bridge.source_payload_ammo_turret_build_handle_payload_state(contents_before, "lead")
	proof["handle_payload_inputs_unmutated"] = contents_before == ["copper"]

	# Each result carries EXACTLY its own one key.
	proof["has_ammo_returns_only_one_key"] = held.size() == 1
	proof["accept_payload_returns_only_one_key"] = accepted.size() == 1
	proof["handle_payload_returns_only_one_key"] = handled.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadTurretPayloadIntakeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
