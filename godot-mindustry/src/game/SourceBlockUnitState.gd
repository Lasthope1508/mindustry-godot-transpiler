extends RefCounted
class_name SourceBlockUnitState

const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func tile_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	var this_tile_after: Variant = tile
	var max_health_call: Dictionary = {"call": "maxHealth(tile.block.health);", "value": tile_block_health}
	var health_call: Dictionary = {"call": "health(tile.health);", "value": tile_health}
	var hit_size: float = source_block_geometry.block_unit_tile_hit_size(tile_block_size, tilesize)
	var hit_size_call: Dictionary = {"call": "hitSize(tile.block.size * tilesize * 0.7f);", "value": hit_size}
	var set_call: Dictionary = {"call": "set(tile);", "tile": tile}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_TILE_STATE, "method": "public void tile(Building tile){", "tile_assignment_expr": "this.tile = tile;", "comment": "//sets up block stats", "max_health_call": max_health_call, "health_call": health_call, "hit_size_call": hit_size_call, "set_call": set_call, "tile": tile, "tile_block_health": tile_block_health, "tile_health": tile_health, "tile_block_size": tile_block_size, "tilesize": tilesize, "this_tile_after": this_tile_after, "hit_size": hit_size}

static func add_state(tile_null: bool) -> Dictionary:
	var runtime_exception_thrown: bool = tile_null
	var runtime_exception_message: String = "Do not add BlockUnit entities to the game, they will simply crash. Internal use only." if runtime_exception_thrown else ""
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_ADD_STATE, "method": "public void add(){", "guard_expr": "if(tile == null){", "throw_expr": "throw new RuntimeException(\"Do not add BlockUnit entities to the game, they will simply crash. Internal use only.\");", "tile_null": tile_null, "runtime_exception_thrown": runtime_exception_thrown, "runtime_exception_message": runtime_exception_message}

static func update_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	var tile_guard: bool = tile_exists
	var team_after: Variant = team
	if tile_guard:
		team_after = tile_team
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_UPDATE_STATE, "method": "public void update(){", "guard_expr": "if(tile != null){", "team_assignment_expr": "team = tile.team;", "tile_exists": tile_exists, "team": team, "tile_team": tile_team, "tile_guard": tile_guard, "team_after": team_after}

static func icon_state(tile_block_ui_icon: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_ICON_STATE, "method": "public TextureRegion icon(){", "return_expr": "return tile.block.uiIcon;", "tile_block_ui_icon": tile_block_ui_icon}

static func ammof_state(ammo: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_AMMOF_STATE, "method": "public float ammof(){", "return_expr": "return ammo;", "ammo": ammo}

static func killed_state() -> Dictionary:
	var tile_kill_call: String = "tile.kill();"
	var tile_kill_called: bool = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_KILLED_STATE, "method": "public void killed(){", "tile_kill_call": tile_kill_call, "tile_kill_called": tile_kill_called}

static func damage_state(v: float, b: bool) -> Dictionary:
	var tile_damage_call: String = "tile.damage(v, b);"
	var tile_damage_called: bool = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_DAMAGE_STATE, "method": "public void damage(float v, boolean b){", "tile_damage_call": tile_damage_call, "tile_damage_called": tile_damage_called, "v": v, "b": b}

static func dead_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	var dead: bool = tile_null or tile_dead
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_DEAD_STATE, "method": "public boolean dead(){", "return_expr": "return tile == null || tile.dead();", "tile_null": tile_null, "tile_dead": tile_dead, "dead": dead}

static func is_valid_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	var is_valid: bool = tile_exists and tile_is_valid
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_IS_VALID_STATE, "method": "public boolean isValid(){", "return_expr": "return tile != null && tile.isValid();", "tile_exists": tile_exists, "tile_is_valid": tile_is_valid, "is_valid": is_valid}

static func is_added_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	var is_added: bool = tile_exists and tile_is_valid
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_IS_ADDED_STATE, "method": "public boolean isAdded(){", "return_expr": "return tile != null && tile.isValid();", "tile_exists": tile_exists, "tile_is_valid": tile_is_valid, "is_added": is_added}

static func team_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	var outer_guard: bool = tile_exists and this_team != team
	var this_team_after: Variant = this_team
	var inner_guard: bool = false
	var tile_change_team_call: Variant = null
	var tile_change_team_called: bool = false
	if outer_guard:
		this_team_after = team
		inner_guard = tile_team != team
		if inner_guard:
			tile_change_team_call = {"call": "tile.changeTeam(team);", "team": team}
			tile_change_team_called = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_TEAM_STATE, "method": "public void team(Team team){", "outer_guard_expr": "if(tile != null && this.team != team){", "this_team_assignment_expr": "this.team = team;", "inner_guard_expr": "if(tile.team != team){", "tile_change_team_call_expr": "tile.changeTeam(team);", "tile_exists": tile_exists, "this_team": this_team, "team": team, "tile_team": tile_team, "outer_guard": outer_guard, "inner_guard": inner_guard, "this_team_after": this_team_after, "tile_change_team_call": tile_change_team_call, "tile_change_team_called": tile_change_team_called}

static func generated_block_unit_comp_ammof_bridge_state(ammo: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_ammof_4", [ammo], null)
	var canonical = ammof_state(ammo)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_AMMOF_STATE, "generated_owner": "block_unit_comp.java_method_ammof_4", "result": result, "canonical": canonical, "matches": result.get("ammo", null) == canonical.get("ammo", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_icon_3", [tile_block_ui_icon], null)
	var canonical = icon_state(tile_block_ui_icon)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_ICON_STATE, "generated_owner": "block_unit_comp.java_method_icon_3", "result": result, "canonical": canonical, "matches": result.get("tile_block_ui_icon", null) == canonical.get("tile_block_ui_icon", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_block_unit_comp_tile_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_tile_0", [tile, tile_block_health, tile_health, tile_block_size, tilesize], null)
	var canonical = tile_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_TILE_STATE, "generated_owner": "block_unit_comp.java_method_tile_0", "result": result, "canonical": canonical, "matches": result.get("this_tile_after", null) == canonical.get("this_tile_after", null) and result.get("hit_size", null) == canonical.get("hit_size", null) and result.get("max_health_call", null) == canonical.get("max_health_call", null) and result.get("health_call", null) == canonical.get("health_call", null) and result.get("set_call", null) == canonical.get("set_call", null)}

static func generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_tile_0", [tile, tile_block_health, tile_health, tile_block_size], null)
	var canonical = tile_state(tile, tile_block_health, tile_health, tile_block_size, source_world_defaults.TILESIZE)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_TILE_STATE, "generated_owner": "block_unit_comp.java_method_tile_0", "defaulted_arg": "tilesize", "tilesize": source_world_defaults.TILESIZE, "result": result, "canonical": canonical, "matches": result.get("this_tile_after", null) == canonical.get("this_tile_after", null) and result.get("hit_size", null) == canonical.get("hit_size", null) and result.get("max_health_call", null) == canonical.get("max_health_call", null) and result.get("health_call", null) == canonical.get("health_call", null) and result.get("set_call", null) == canonical.get("set_call", null)}

static func generated_block_unit_comp_add_bridge_state(tile_null: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_add_1", [tile_null], null)
	var canonical = add_state(tile_null)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_ADD_STATE, "generated_owner": "block_unit_comp.java_method_add_1", "result": result, "canonical": canonical, "matches": result.get("runtime_exception_thrown", null) == canonical.get("runtime_exception_thrown", null) and result.get("runtime_exception_message", null) == canonical.get("runtime_exception_message", null)}

static func generated_block_unit_comp_update_bridge_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_update_2", [tile_exists, team, tile_team], null)
	var canonical = update_state(tile_exists, team, tile_team)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_UPDATE_STATE, "generated_owner": "block_unit_comp.java_method_update_2", "result": result, "canonical": canonical, "matches": result.get("tile_guard", null) == canonical.get("tile_guard", null) and result.get("team_after", null) == canonical.get("team_after", null)}

static func generated_block_unit_comp_killed_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_killed_5", [], null)
	var canonical = killed_state()
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_KILLED_STATE, "generated_owner": "block_unit_comp.java_method_killed_5", "result": result, "canonical": canonical, "matches": result.get("tile_kill_call", null) == canonical.get("tile_kill_call", null) and result.get("tile_kill_called", null) == canonical.get("tile_kill_called", null)}

static func generated_block_unit_comp_damage_bridge_state(v: float, b: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_damage_6", [v, b], null)
	var canonical = damage_state(v, b)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_DAMAGE_STATE, "generated_owner": "block_unit_comp.java_method_damage_6", "result": result, "canonical": canonical, "matches": result.get("tile_damage_call", null) == canonical.get("tile_damage_call", null) and result.get("tile_damage_called", null) == canonical.get("tile_damage_called", null) and result.get("v", null) == canonical.get("v", null) and result.get("b", null) == canonical.get("b", null)}

static func generated_block_unit_comp_team_bridge_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_team_10", [tile_exists, this_team, team, tile_team], null)
	var canonical = team_state(tile_exists, this_team, team, tile_team)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_TEAM_STATE, "generated_owner": "block_unit_comp.java_method_team_10", "result": result, "canonical": canonical, "matches": result.get("outer_guard", null) == canonical.get("outer_guard", null) and result.get("inner_guard", null) == canonical.get("inner_guard", null) and result.get("this_team_after", null) == canonical.get("this_team_after", null) and result.get("tile_change_team_called", null) == canonical.get("tile_change_team_called", null)}

static func generated_block_unit_comp_dead_bridge_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_dead_7", [tile_null, tile_dead], null)
	var canonical = dead_state(tile_null, tile_dead)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_DEAD_STATE, "generated_owner": "block_unit_comp.java_method_dead_7", "result": result, "canonical": canonical, "matches": result.get("dead", null) == canonical.get("dead", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_block_unit_comp_is_valid_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_isValid_8", [tile_exists, tile_is_valid], null)
	var canonical = is_valid_state(tile_exists, tile_is_valid)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_IS_VALID_STATE, "generated_owner": "block_unit_comp.java_method_isValid_8", "result": result, "canonical": canonical, "matches": result.get("is_valid", null) == canonical.get("is_valid", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_block_unit_comp_is_added_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BlockUnitComp.gd", "java_method_isAdded_9", [tile_exists, tile_is_valid], null)
	var canonical = is_added_state(tile_exists, tile_is_valid)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UNIT_IS_ADDED_STATE, "generated_owner": "block_unit_comp.java_method_isAdded_9", "result": result, "canonical": canonical, "matches": result.get("is_added", null) == canonical.get("is_added", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}
