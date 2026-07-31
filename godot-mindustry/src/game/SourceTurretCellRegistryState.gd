extends RefCounted
class_name SourceTurretCellRegistryState

static func register_turret_cell(game: Object, cell: Vector2i, block) -> void:
	if game == null or not _is_turret_block(block):
		return
	var key := str(game.call("cell_key", cell))
	var turret_cells: Array = game.get("turret_cells")
	var turret_cooldowns: Dictionary = game.get("turret_cooldowns")
	var turret_ammo_stacks: Dictionary = game.get("turret_ammo_stacks")
	var turret_total_ammo: Dictionary = game.get("turret_total_ammo")
	var turret_barrel_counters: Dictionary = game.get("turret_barrel_counters")
	var turret_rotations: Dictionary = game.get("turret_rotations")
	var turret_recoils: Dictionary = game.get("turret_recoils")
	if not turret_cooldowns.has(key):
		turret_cells.append(cell)
	turret_cooldowns[key] = 0.0
	if not turret_ammo_stacks.has(key):
		turret_ammo_stacks[key] = []
	if not turret_total_ammo.has(key):
		turret_total_ammo[key] = 0
	if not turret_barrel_counters.has(key):
		turret_barrel_counters[key] = 0
	if not turret_rotations.has(key):
		turret_rotations[key] = 0.0
	if not turret_recoils.has(key):
		turret_recoils[key] = 0.0
	game.set("turret_cells", turret_cells)
	game.set("turret_cooldowns", turret_cooldowns)
	game.set("turret_ammo_stacks", turret_ammo_stacks)
	game.set("turret_total_ammo", turret_total_ammo)
	game.set("turret_barrel_counters", turret_barrel_counters)
	game.set("turret_rotations", turret_rotations)
	game.set("turret_recoils", turret_recoils)

static func unregister_turret_cell(game: Object, cell: Vector2i) -> void:
	if game == null:
		return
	var key := str(game.call("cell_key", cell))
	var turret_cells: Array = game.get("turret_cells")
	var turret_cooldowns: Dictionary = game.get("turret_cooldowns")
	var turret_ammo_stacks: Dictionary = game.get("turret_ammo_stacks")
	var turret_total_ammo: Dictionary = game.get("turret_total_ammo")
	var turret_barrel_counters: Dictionary = game.get("turret_barrel_counters")
	var turret_rotations: Dictionary = game.get("turret_rotations")
	var turret_recoils: Dictionary = game.get("turret_recoils")
	if not turret_cooldowns.has(key):
		return
	turret_cooldowns.erase(key)
	turret_barrel_counters.erase(key)
	turret_rotations.erase(key)
	turret_recoils.erase(key)
	var kept: Array = []
	for existing in turret_cells:
		if str(game.call("cell_key", existing)) != key:
			kept.append(existing)
	turret_cells = kept
	turret_ammo_stacks.erase(key)
	turret_total_ammo.erase(key)
	game.set("turret_cells", turret_cells)
	game.set("turret_cooldowns", turret_cooldowns)
	game.set("turret_ammo_stacks", turret_ammo_stacks)
	game.set("turret_total_ammo", turret_total_ammo)
	game.set("turret_barrel_counters", turret_barrel_counters)
	game.set("turret_rotations", turret_rotations)
	game.set("turret_recoils", turret_recoils)

static func _is_turret_block(block) -> bool:
	if block == null:
		return false
	if block is Dictionary:
		return bool(block.get("is_turret", false))
	if block.has_method("is_turret"):
		return bool(block.call("is_turret"))
	return false
