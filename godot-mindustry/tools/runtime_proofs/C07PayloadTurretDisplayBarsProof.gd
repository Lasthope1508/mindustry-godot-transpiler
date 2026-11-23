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

	# --- PayloadTurretBuild.displayBars()+updateTile()+getPayloads() (N2381):
	# PayloadTurretBuild.displayBars()+updateTile()+getPayloads()
	# (PayloadAmmoTurret.java:143-145/:165-168/:171-177) groups three
	# one-to-three-line overrides: getPayloads returns the payloads
	# seq (`return payloads;`); updateTile syncs totalAmmo from
	# `payloads.total()` then calls the TurretBuild super tick
	# (`super.updateTile();` -- callee/context); displayBars adds the
	# "stat.ammo" bar (`bars.add(new Bar("stat.ammo", Pal.ammo,
	# () -> (float)totalAmmo / maxAmmo)).growX();`) then opens a new
	# row (`bars.row();`). `super.displayBars(bars);` is
	# callee/context. The proof calls the three pure functions with
	# synthetic inputs (no live tick). NO driver tick line of its
	# own: updateTile only syncs the frame field, displayBars is a
	# UI spec, getPayloads is a pure accessor.

	# displayBars adds the ammo bar to the current row and opens a
	# new row after it: one empty row in, the ammo bar plus a fresh
	# empty row out, fraction (float)15 / 30.
	var added: Dictionary = bridge.source_payload_ammo_turret_build_display_bars_state([[]], 15, 30)
	proof["display_bars_adds_ammo_bar"] = added.get("bars", []) == [[{"label": "stat.ammo", "fraction": 0.5}], []] and added.get("ammo_fraction", -1.0) == 0.5

	# displayBars with a full magazine reports fraction 1.0.
	var full: Dictionary = bridge.source_payload_ammo_turret_build_display_bars_state([[]], 30, 30)
	proof["display_bars_fraction_full"] = full.get("ammo_fraction", -1.0) == 1.0

	# displayBars with maxAmmo 0 never divides by zero: the guard
	# reports fraction 0.0 (a Bar clamps its fraction anyway).
	var zero_max: Dictionary = bridge.source_payload_ammo_turret_build_display_bars_state([[]], 5, 0)
	proof["display_bars_fraction_zero_max"] = zero_max.get("ammo_fraction", -1.0) == 0.0

	# displayBars appends the ammo bar to the existing current row
	# (after the health bar) and still opens a new row after it.
	var appended: Dictionary = bridge.source_payload_ammo_turret_build_display_bars_state([[{"label": "stat.health", "fraction": 0.8}]], 10, 40)
	proof["display_bars_appends_to_existing_row"] = appended.get("bars", []) == [[{"label": "stat.health", "fraction": 0.8}, {"label": "stat.ammo", "fraction": 0.25}], []]

	# Inputs are read, never written: the bars table is unchanged
	# after the call.
	var bars_in: Array = [[{"label": "stat.health", "fraction": 0.8}]]
	var bars_before: Array = bars_in.duplicate(true)
	bridge.source_payload_ammo_turret_build_display_bars_state(bars_in, 10, 40)
	proof["display_bars_inputs_unmutated"] = bars_in == bars_before

	# The displayBars result carries EXACTLY the two keys.
	proof["display_bars_returns_only_two_keys"] = added.size() == 2

	# updateTile counts the held payloads: three entries total 3.
	var synced: Dictionary = bridge.source_payload_ammo_turret_build_update_tile_state(["copper", "lead", "copper"])
	proof["update_tile_total_ammo_counts_payloads"] = synced.get("total_ammo", -1) == 3

	# updateTile of empty payloads syncs totalAmmo to zero.
	var synced_empty: Dictionary = bridge.source_payload_ammo_turret_build_update_tile_state([])
	proof["update_tile_empty_payloads_zero"] = synced_empty.get("total_ammo", -1) == 0

	# The updateTile result carries EXACTLY the one key.
	proof["update_tile_returns_only_one_key"] = synced.size() == 1

	# getPayloads returns the held contents in order.
	var held: Dictionary = bridge.source_payload_ammo_turret_build_get_payloads_state(["copper", "lead"])
	proof["get_payloads_returns_contents"] = held.get("payloads", []) == ["copper", "lead"]

	# getPayloads of empty payloads returns empty.
	var held_empty: Dictionary = bridge.source_payload_ammo_turret_build_get_payloads_state([])
	proof["get_payloads_empty_returns_empty"] = held_empty.get("payloads", ["not-empty"]).is_empty()

	# getPayloads returns a copy: mutating the returned array
	# leaves the input untouched.
	var contents: Array = ["copper", "lead"]
	var copied: Dictionary = bridge.source_payload_ammo_turret_build_get_payloads_state(contents)
	(copied.get("payloads", []) as Array).append("titanium")
	proof["get_payloads_returns_copy"] = contents == ["copper", "lead"]

	# The getPayloads result carries EXACTLY the one key.
	proof["get_payloads_returns_only_one_key"] = held.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadTurretDisplayBarsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
