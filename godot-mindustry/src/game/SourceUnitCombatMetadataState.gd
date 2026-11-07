extends RefCounted
class_name SourceUnitCombatMetadataState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_text := preload("res://src/game/SourceUnitCombatMetadataSourceTextState.gd")

static func can_shoot_state(unit_state: Dictionary) -> Dictionary:
	var can_shoot := not bool(unit_state.get("disarmed", false)) and not (bool(unit_state.get("type_can_boost", false)) and bool(unit_state.get("is_flying", false)))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAN_SHOOT_STATE, "can_shoot": can_shoot, "disarmed": bool(unit_state.get("disarmed", false)), "type_can_boost": bool(unit_state.get("type_can_boost", false)), "is_flying": bool(unit_state.get("is_flying", false))}

static func is_enemy_state(unit_is_enemy: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IS_ENEMY_STATE, "is_enemy": unit_is_enemy}

static func collides_state(hittable: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_COLLIDES_STATE, "hittable": hittable, "collides": hittable}

static func item_capacity_state(type_item_capacity: int) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_ITEM_CAPACITY_STATE, "item_capacity": type_item_capacity}

static func bounds_state(hit_size: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_BOUNDS_STATE, "hit_size": hit_size, "bounds": hit_size * 2.0}
