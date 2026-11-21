extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# --- TeamData lookup group (N2390):
	# TeamData.getBuildings()+getCount()+getUnits()+unitCache()
	# (Teams.java:318-320 + :322-325 + :418-420 + :422-426,
	# `public Seq<Building> getBuildings(Block block){` /
	# `return buildingTypes.get(block, () -> new Seq<>(false));` /
	# `public int getCount(Block block){` /
	# `var res = buildingTypes.get(block);` /
	# `return res == null ? 0 : res.size;` /
	# `public Seq<Unit> getUnits(UnitType type){` /
	# `return unitCache(type);` /
	# `public Seq<Unit> unitCache(UnitType type){` /
	# `if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;` /
	# `return unitsByType[type.id];`).
	# One grouped slice (main-thread decision 2026-11-21, the
	# N2380 seven-method / N2374 five-accessor group
	# precedent): four one-to-two-line read-only lookup
	# methods on TeamData (`buildingTypes` + `unitsByType`).
	# The proof calls the four pure functions with synthetic
	# inputs (no live tick). getBuildings never stores the
	# default supplier result -- ObjectMap.get with a
	# default never puts.

	# getBuildings() returns the stored Array for a known
	# block, calls the default supplier for a missing block,
	# and does NOT store the default in the map.
	var building_types: Dictionary = {"copper-wall": ["b1", "b2"], "duo": ["b3"]}
	var got_known: Dictionary = teams_state.source_team_data_get_buildings_state(building_types, "copper-wall", func(): return ["fresh"])
	proof["get_buildings_returns_stored_buildings"] = got_known.get("buildings", []) == ["b1", "b2"]
	var got_missing: Dictionary = teams_state.source_team_data_get_buildings_state(building_types, "scrap-wall", func(): return ["fresh"])
	proof["get_buildings_calls_default_when_missing"] = got_missing.get("buildings", []) == ["fresh"]
	proof["get_buildings_does_not_store_default"] = not building_types.has("scrap-wall")
	proof["get_buildings_returns_only_one_key"] = got_known.size() == 1

	# getCount() returns the stored Array size for a known
	# block, 0 for a missing block.
	var counted: Dictionary = teams_state.source_team_data_get_count_state(building_types, "copper-wall")
	proof["get_count_returns_stored_size"] = int(counted.get("count", -1)) == 2
	var counted_missing: Dictionary = teams_state.source_team_data_get_count_state(building_types, "scrap-wall")
	proof["get_count_zero_when_missing"] = int(counted_missing.get("count", -1)) == 0
	proof["get_count_returns_only_one_key"] = counted.size() == 1

	# getUnits() is the unitCache alias: the cached Array
	# for a known type, null when the slot is missing.
	var units_by_type: Array = [["u1", "u2"], null, ["u3"]]
	var units_hit: Dictionary = teams_state.source_team_data_get_units_state(units_by_type, 0)
	proof["get_units_returns_cached_units"] = units_hit.get("units", []) == ["u1", "u2"]
	var units_null_slot: Dictionary = teams_state.source_team_data_get_units_state(units_by_type, 1)
	proof["get_units_null_when_missing"] = units_null_slot.get("units", "not-null") == null

	# unitCache() returns null on a null table, an
	# out-of-range type id, or a null slot.
	var cache_null_table: Dictionary = teams_state.source_team_data_unit_cache_state(null, 0)
	proof["unit_cache_null_when_units_by_type_null"] = cache_null_table.get("units", "not-null") == null
	var cache_out_of_range: Dictionary = teams_state.source_team_data_unit_cache_state(units_by_type, 7)
	proof["unit_cache_null_when_type_out_of_range"] = cache_out_of_range.get("units", "not-null") == null
	var cache_null_slot: Dictionary = teams_state.source_team_data_unit_cache_state(units_by_type, 1)
	proof["unit_cache_null_when_slot_null"] = cache_null_slot.get("units", "not-null") == null
	proof["unit_cache_returns_only_one_key"] = cache_null_table.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamDataLookupProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
