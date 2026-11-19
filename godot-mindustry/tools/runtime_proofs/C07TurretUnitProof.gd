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

	# --- Turret unit() (N2307): the TurretBuild unit accessor
	# (Turret.java:434-439):
	# `public Unit unit(){`
	# `unit.tile(this);`
	# `unit.team(team);`
	# `return (Unit)unit;`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). unit is the TurretBuild field (`public BlockUnitc
	# unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291),
	# created once from UnitTypes.block -- NOT re-ported here; it arrives
	# as an explicit param (the N2268/N2261 precedent). team_id is the
	# building team as an int (the tick-frame convention). The function
	# performs the sync itself: it copies the input unit dict, sets tile
	# to the building frame (`this`) and team_id to the building team,
	# and returns the synced unit. NO driver tick line: a read accessor
	# its callers read, not a per-tick write. The proof calls the pure
	# function with synthetic frames (no live tick).

	# The building frame (`this`) and a unit carrying marker keys.
	var frame: Dictionary = {"marker": "turret-frame", "x": 5, "y": 7}
	var unit: Dictionary = {"id": 1, "health": 100.0}

	# unit() returns the same unit: the marker keys survive the sync.
	var synced: Dictionary = turret_build_state.source_turret_unit_state(frame, unit, 2)
	var returned: Dictionary = synced.get("unit", {})
	proof["unit_returns_same_unit"] = int(returned.get("id", -1)) == 1 and is_equal_approx(float(returned.get("health", -1.0)), 100.0)

	# unit.tile(this): the synced unit's tile is the building frame.
	proof["unit_tile_is_frame"] = (returned.get("tile", {}) as Dictionary).get("marker", "") == "turret-frame"

	# unit.team(team): the synced unit's team_id is the building team.
	proof["unit_team_is_team_id"] = int(returned.get("team_id", -1)) == 2

	# The input unit dict is NOT mutated: the sync lands on a copy
	# (pure function -- the caller keeps its own unit dict).
	proof["unit_input_unmutated"] = not unit.has("tile") and not unit.has("team_id")

	# An empty unit dict syncs cleanly: tile + team_id are the only keys.
	var empty_synced: Dictionary = turret_build_state.source_turret_unit_state(frame, {}, 0)
	var empty_returned: Dictionary = empty_synced.get("unit", {})
	proof["unit_empty_dict"] = empty_returned.size() == 2 and int(empty_returned.get("team_id", -1)) == 0

	# Other keys survive the sync (health is not touched by unit()).
	var rich: Dictionary = {"id": 9, "health": 42.5, "ammo": 3}
	var rich_synced: Dictionary = turret_build_state.source_turret_unit_state(frame, rich, 1)
	var rich_returned: Dictionary = rich_synced.get("unit", {})
	proof["unit_preserves_keys"] = int(rich_returned.get("id", -1)) == 9 and is_equal_approx(float(rich_returned.get("health", -1.0)), 42.5) and int(rich_returned.get("ammo", -1)) == 3

	# The result carries ONLY its one key: no frame echo, no extra state.
	proof["returns_only_one_key"] = synced.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretUnitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
