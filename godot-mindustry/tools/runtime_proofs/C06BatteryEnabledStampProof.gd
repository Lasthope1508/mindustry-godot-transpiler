extends Node

const main_scene := preload("res://scenes/Main.tscn")
const building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")
const battery_distribution_state := preload("res://src/game/SourcePowerGraphBatteryDistributionState.gd")
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

	# --- Battery live enabled stamp: PowerGraph reads the live
	# Building.enabled on every battery pass -- `if(battery.enabled){`
	# in getBatteryStored / getBatteryCapacity / getTotalBatteryCapacity
	# / useBatteries (PowerGraph.java:123, 135, 147, 163) and
	# `if(battery.enabled && battery.block.consPower.capacity > 0f){`
	# in chargeBatteries (PowerGraph.java:180). The flag itself is
	# BuildingComp's `transient boolean enabled = true;`
	# (BuildingComp.java:77). The battery dicts built by
	# block_battery_state carry the statically derived enabled, so
	# the stamp overwrites each dict's enabled with the live
	# Building.enabled read through block_properties(block); a
	# battery whose block carries no live enabled keeps its static
	# value. ---
	var enabled_battery := {"block": {"enabled": true}, "enabled": true, "power_status": 0.5, "capacity": 1000.0}
	var disabled_battery := {"block": {"enabled": false}, "enabled": true, "power_status": 1.0, "capacity": 1000.0}
	var missing_battery := {"block": {}, "enabled": true, "power_status": 0.5, "capacity": 1000.0}

	# --- A battery whose live building is enabled stays enabled. ---
	var enabled_only: Dictionary = building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": [enabled_battery]})
	var enabled_stamped: Array = enabled_only.get("batteries", [])
	proof["enabled_stamp_enabled_true"] = enabled_stamped.size() == 1 and bool(enabled_stamped[0].get("enabled", false)) == true

	# --- A battery whose live building is disabled stamps false,
	# even though its static enabled was true. ---
	var disabled_only: Dictionary = building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": [disabled_battery]})
	var disabled_stamped: Array = disabled_only.get("batteries", [])
	proof["enabled_stamp_disabled_false"] = disabled_stamped.size() == 1 and bool(disabled_stamped[0].get("enabled", true)) == false

	# --- A battery whose block carries no live enabled keeps its
	# statically derived value (true for a battery block). ---
	var missing_only: Dictionary = building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": [missing_battery]})
	var missing_stamped: Array = missing_only.get("batteries", [])
	proof["enabled_stamp_missing_keeps_static"] = missing_stamped.size() == 1 and bool(missing_stamped[0].get("enabled", false)) == true

	# --- Mixed [true, false, missing] counts 2 enabled, 1 disabled. ---
	var mixed: Dictionary = building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": [enabled_battery, disabled_battery, missing_battery]})
	proof["enabled_stamp_mixed_enabled_count"] = int(mixed.get("enabled_count", -1)) == 2
	proof["enabled_stamp_mixed_disabled_count"] = int(mixed.get("disabled_count", -1)) == 1

	# --- The disabled battery drops out of the stored power the
	# graph reports: enabled 0.5 x 1000 = 500, disabled 1.0 x 1000
	# excluded. (The mixed frame's missing battery also counts as
	# enabled, so this key stamps a dedicated [enabled, disabled]
	# frame instead of reusing the mixed one.) ---
	var stored_frame: Dictionary = building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": [enabled_battery, disabled_battery]})
	var stamped_batteries: Array = stored_frame.get("batteries", [])
	var stored_state: Dictionary = battery_distribution_state.battery_state(stamped_batteries)
	proof["enabled_stamp_disabled_excluded_from_stored"] = is_equal_approx(float(stored_state.get("stored", -1.0)), 500.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06BatteryEnabledStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
