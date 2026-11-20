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

	# --- Turret senseObject() (N2506):
	# BuildingComp.senseObject() (BuildingComp.java:2128-2136,
	# `public Object senseObject(LAccess sensor){`) switches
	# on the LAccess sensor: `case type -> block;`
	# (BuildingComp.java:2130), `case firstItem -> items ==
	# null ? null : items.first();` (BuildingComp.java:2131),
	# `case config -> block.configSenseable() ? config() :
	# null;` (BuildingComp.java:2132), `case payloadType ->
	# getPayload() instanceof UnitPayload p1 ? p1.unit.type :
	# getPayload() instanceof BuildPayload p2 ? p2.block() :
	# null;` (BuildingComp.java:2133), `default ->
	# noSensed;` (BuildingComp.java:2134). For duo the
	# firstItem leg is live inventory: duo hasItems
	# (ItemTurret.java:28), so BuildingComp.java:145 creates
	# the items module and `first()` (ItemModule.java:182-189)
	# returns the first item with count > 0 in content order
	# ("copper" -- duo ammo is copper / graphite / silicon,
	# Blocks.java:3257-3331) or null when empty ("" encodes
	# null here). Config is null: duo registers no `config()`
	# call, so `configurations` (Block.java:402) holds none
	# of the five handlers and configSenseable()
	# (Block.java:809-812) is false. Payload type is null:
	# the base `getPayload()` returns null
	# (BuildingComp.java:984-985) and no turret file
	# overrides it. The `type` leg returns the block itself,
	# whose port identity is its id string ("duo",
	# Blocks.java:3257). An unhandled sensor returns the
	# `noSensed` sentinel (Senseable.java:6), which the logic
	# converts to a numeric `sense()` fallback
	# (LExecutor.java:697-699). There is no driver tick line:
	# senseObject is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2234 precedent).

	# Type senses the block itself: duo id.
	var type_duo: Dictionary = turret_build_state.source_turret_sense_object_state("type", "duo", "copper")
	proof["sense_object_type_duo"] = bool(type_duo.get("handled", false)) and String(type_duo.get("sense_object", "")) == "duo" and not bool(type_duo.get("is_no_sensed", true))

	# First item is copper: the observed first item.
	var first_item_copper: Dictionary = turret_build_state.source_turret_sense_object_state("firstItem", "duo", "copper")
	proof["sense_object_first_item_copper"] = bool(first_item_copper.get("handled", false)) and String(first_item_copper.get("sense_object", "")) == "copper" and not bool(first_item_copper.get("is_no_sensed", true))

	# First item is null: empty inventory ("" encodes null).
	var first_item_none: Dictionary = turret_build_state.source_turret_sense_object_state("firstItem", "duo", "")
	proof["sense_object_first_item_none"] = bool(first_item_none.get("handled", false)) and first_item_none.get("sense_object", "non-null") == null and not bool(first_item_none.get("is_no_sensed", true))

	# Config is null: duo is not configSenseable.
	var config: Dictionary = turret_build_state.source_turret_sense_object_state("config", "duo", "copper")
	proof["sense_object_config_null"] = bool(config.get("handled", false)) and config.get("sense_object", "non-null") == null and not bool(config.get("is_no_sensed", true))

	# Payload type is null: base getPayload() returns null.
	var payload_type: Dictionary = turret_build_state.source_turret_sense_object_state("payloadType", "duo", "copper")
	proof["sense_object_payload_type_null"] = bool(payload_type.get("handled", false)) and payload_type.get("sense_object", "non-null") == null and not bool(payload_type.get("is_no_sensed", true))

	# An unhandled sensor returns the noSensed sentinel.
	var unknown: Dictionary = turret_build_state.source_turret_sense_object_state("totalItems", "duo", "copper")
	proof["sense_object_unknown_is_no_sensed"] = not bool(unknown.get("handled", true)) and unknown.get("sense_object", "non-null") == null and bool(unknown.get("is_no_sensed", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretSenseObjectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
