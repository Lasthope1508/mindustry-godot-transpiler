extends RefCounted
class_name SourceWaveSpawnRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_SPAWN_GROUP_GET_SPAWNED_BEGIN_END_EXPR := "if(wave < begin || wave > end || (wave - begin) % spacing != 0){"
const SOURCE_SPAWN_GROUP_GET_SPAWNED_AMOUNT_EXPR := "return Math.min(unitAmount + (int)(((wave - begin) / spacing) / unitScaling), max);"
const SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR := "int spawned = group.getSpawned(state.wave - 1);"

const SPAWN_GROUP_BEGIN_DEFAULT := 0
const SPAWN_GROUP_END_DEFAULT := 999999999
const SPAWN_GROUP_SPACING_DEFAULT := 1
const SPAWN_GROUP_UNIT_AMOUNT_DEFAULT := 1
const SPAWN_GROUP_UNIT_SCALING_DEFAULT := 1.0
const SPAWN_GROUP_MAX_DEFAULT := 60

static func spawned_for_wave_state(group: Dictionary, wave_zero: int) -> Dictionary:
	var begin := int(group.get("begin", SPAWN_GROUP_BEGIN_DEFAULT))
	var end := int(group.get("end", SPAWN_GROUP_END_DEFAULT))
	var spacing: int = max(1, int(group.get("spacing", SPAWN_GROUP_SPACING_DEFAULT)))
	var unit_amount := int(group.get("unitAmount", SPAWN_GROUP_UNIT_AMOUNT_DEFAULT))
	var unit_scaling: float = max(float(group.get("unitScaling", SPAWN_GROUP_UNIT_SCALING_DEFAULT)), 0.0001)
	var max_amount := int(group.get("max", SPAWN_GROUP_MAX_DEFAULT))
	var eligible: bool = wave_zero >= begin and wave_zero <= end and (wave_zero - begin) % spacing == 0
	var spawned: int = 0
	if eligible:
		spawned = min(unit_amount + int((float(wave_zero - begin) / float(spacing)) / unit_scaling), max_amount)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_WAVE_SPAWNED_FOR_WAVE_STATE,
		"begin_end_expr": SOURCE_SPAWN_GROUP_GET_SPAWNED_BEGIN_END_EXPR,
		"amount_expr": SOURCE_SPAWN_GROUP_GET_SPAWNED_AMOUNT_EXPR,
		"wave": wave_zero,
		"begin": begin,
		"end": end,
		"spacing": spacing,
		"unitAmount": unit_amount,
		"unitScaling": unit_scaling,
		"max": max_amount,
		"eligible": eligible,
		"spawned": spawned,
	}

# SSOT-registered entry point for SpawnGroup.getSpawned(int) (N2449).
# The validator only discovers functions named source_*/generated_/tile_,
# and the bare spawned_for_wave_state above predates that rule (PortGame-era
# file creation; its exact name is pinned by test_playable.py), so the
# slice registers this thin source_-prefixed forward instead of renaming
# the original. Behavior is identical -- it delegates 1:1.
static func source_spawn_group_get_spawned_state(group: Dictionary, wave_zero: int) -> Dictionary:
	return spawned_for_wave_state(group, wave_zero)

static func wave_spawn_state(groups: Array, wave_index: int, fallback_unit_id: String) -> Dictionary:
	var wave_zero: int = wave_index - 1
	var spawned_groups: Array = []
	var spawn_requests: Array = []
	var request_index: int = 0
	for group_value in groups:
		var group: Dictionary = group_value if group_value is Dictionary else {}
		var spawn_state: Dictionary = spawned_for_wave_state(group, wave_zero)
		var spawned := int(spawn_state.get("spawned", 0))
		if spawned <= 0:
			continue
		var unit_id := str(group.get("unit", fallback_unit_id))
		var group_result := group.duplicate(true)
		group_result["spawned"] = spawned
		group_result["wave"] = wave_zero
		spawned_groups.append(group_result)
		for i in spawned:
			spawn_requests.append({"unit": unit_id, "index": request_index, "group": group_result.duplicate(true)})
			request_index += 1
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_WAVE_SPAWN_STATE,
		"wave_zero_expr": SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR,
		"wave_index": wave_index,
		"wave": wave_zero,
		"groups": spawned_groups,
		"spawn_requests": spawn_requests,
	}


static func source_wave_spawn_can_spawn_state(spawn: int, position: int) -> Dictionary:
	# SpawnGroup.canSpawn(int) (SpawnGroup.java:62-64): the 1 body expr
	# only -- `return spawn == -1 || spawn == position;` (:63). `spawn`
	# is the SpawnGroup field `public int spawn = -1;`
	# (SpawnGroup.java:44, "If not -1, the unit will only spawn in
	# spawnpoints with these packed coordinates."): -1 means every
	# position. GD takes spawn + position as int inputs, never
	# packs/unpacks coords here. No call-site of canSpawn exists
	# outside SpawnGroup.java (grep: 0 hits) -- this slice ports
	# only the predicate. Precedent N2123/N2297 micro-accessors +
	# N2444 isSpawning, same pure-predicate shape.
	return {"can_spawn": spawn == -1 or spawn == position}
