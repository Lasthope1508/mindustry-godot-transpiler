# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BlockUnitComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockUnitComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Unitc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": ["transient"], "name": "tile", "type": "Building"}, {"modifiers": ["transient"], "name": "ammo", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "tile", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "ammof", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "killed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "damage", "parameters": [{"name": "v", "type": "float", "varargs": false}, {"name": "b", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dead", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isValid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isAdded", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "team", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_TILESIZE := source_world_defaults.TILESIZE

func java_method_tile_0(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var tile_block_health: float = float(_args[1] if _args.size() > 1 else 0.0)
	var tile_health: float = float(_args[2] if _args.size() > 2 else 0.0)
	var tile_block_size: float = float(_args[3] if _args.size() > 3 else 0.0)
	var tilesize: float = float(_args[4] if _args.size() > 4 else SOURCE_TILESIZE)
	var this_tile_after: Variant = tile
	var hit_size: float = tile_block_size * tilesize * 0.7
	var max_health_call: Dictionary = {"call": "maxHealth(tile.block.health);", "value": tile_block_health}
	var health_call: Dictionary = {"call": "health(tile.health);", "value": tile_health}
	var hit_size_call: Dictionary = {"call": "hitSize(tile.block.size * tilesize * 0.7f);", "value": hit_size}
	var set_call: Dictionary = {"call": "set(tile);", "tile": tile}
	return {"source_owner": "port_game.source_block_unit_tile_state", "method": "public void tile(Building tile){", "tile_assignment_expr": "this.tile = tile;", "comment": "//sets up block stats", "max_health_call": max_health_call, "health_call": health_call, "hit_size_call": hit_size_call, "set_call": set_call, "tile": tile, "tile_block_health": tile_block_health, "tile_health": tile_health, "tile_block_size": tile_block_size, "tilesize": tilesize, "this_tile_after": this_tile_after, "hit_size": hit_size}

func java_method_add_1(_args: Array = []) -> Variant:
	var tile_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var runtime_exception_thrown: bool = tile_null
	var runtime_exception_message: String = "Do not add BlockUnit entities to the game, they will simply crash. Internal use only." if runtime_exception_thrown else ""
	return {"source_owner": "port_game.source_block_unit_add_state", "method": "public void add(){", "guard_expr": "if(tile == null){", "throw_expr": "throw new RuntimeException(\"Do not add BlockUnit entities to the game, they will simply crash. Internal use only.\");", "tile_null": tile_null, "runtime_exception_thrown": runtime_exception_thrown, "runtime_exception_message": runtime_exception_message}

func java_method_update_2(_args: Array = []) -> Variant:
	var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)
	var team: Variant = _args[1] if _args.size() > 1 else null
	var tile_team: Variant = _args[2] if _args.size() > 2 else null
	var tile_guard: bool = tile_exists
	var team_after: Variant = team
	if tile_guard:
		team_after = tile_team
	return {"source_owner": "port_game.source_block_unit_update_state", "method": "public void update(){", "guard_expr": "if(tile != null){", "team_assignment_expr": "team = tile.team;", "tile_exists": tile_exists, "team": team, "tile_team": tile_team, "tile_guard": tile_guard, "team_after": team_after}

func java_method_icon_3(_args: Array = []) -> Variant:
	var tile_block_ui_icon: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_block_unit_icon_state", "method": "public TextureRegion icon(){", "return_expr": "return tile.block.uiIcon;", "tile_block_ui_icon": tile_block_ui_icon}

func java_method_ammof_4(_args: Array = []) -> Variant:
	var ammo: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_block_unit_ammof_state", "method": "public float ammof(){", "return_expr": "return ammo;", "ammo": ammo}

func java_method_killed_5(_args: Array = []) -> Variant:
	var tile_kill_call: String = "tile.kill();"
	var tile_kill_called: bool = true
	return {"source_owner": "port_game.source_block_unit_killed_state", "method": "public void killed(){", "tile_kill_call": tile_kill_call, "tile_kill_called": tile_kill_called}

func java_method_damage_6(_args: Array = []) -> Variant:
	var v: float = float(_args[0] if _args.size() > 0 else 0.0)
	var b: bool = bool(_args[1] if _args.size() > 1 else false)
	var tile_damage_call: String = "tile.damage(v, b);"
	var tile_damage_called: bool = true
	return {"source_owner": "port_game.source_block_unit_damage_state", "method": "public void damage(float v, boolean b){", "tile_damage_call": tile_damage_call, "tile_damage_called": tile_damage_called, "v": v, "b": b}

func java_method_dead_7(_args: Array = []) -> Variant:
	var tile_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile_dead: bool = bool(_args[1] if _args.size() > 1 else false)
	var dead: bool = tile_null or tile_dead
	return {"source_owner": "port_game.source_block_unit_dead_state", "method": "public boolean dead(){", "return_expr": "return tile == null || tile.dead();", "tile_null": tile_null, "tile_dead": tile_dead, "dead": dead}

func java_method_isValid_8(_args: Array = []) -> Variant:
	var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile_is_valid: bool = bool(_args[1] if _args.size() > 1 else false)
	var is_valid: bool = tile_exists and tile_is_valid
	return {"source_owner": "port_game.source_block_unit_is_valid_state", "method": "public boolean isValid(){", "return_expr": "return tile != null && tile.isValid();", "tile_exists": tile_exists, "tile_is_valid": tile_is_valid, "is_valid": is_valid}

func java_method_isAdded_9(_args: Array = []) -> Variant:
	var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile_is_valid: bool = bool(_args[1] if _args.size() > 1 else false)
	var is_added: bool = tile_exists and tile_is_valid
	return {"source_owner": "port_game.source_block_unit_is_added_state", "method": "public boolean isAdded(){", "return_expr": "return tile != null && tile.isValid();", "tile_exists": tile_exists, "tile_is_valid": tile_is_valid, "is_added": is_added}

func java_method_team_10(_args: Array = []) -> Variant:
	var tile_exists: bool = bool(_args[0] if _args.size() > 0 else false)
	var this_team: Variant = _args[1] if _args.size() > 1 else null
	var team: Variant = _args[2] if _args.size() > 2 else null
	var tile_team: Variant = _args[3] if _args.size() > 3 else null
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
	return {"source_owner": "port_game.source_block_unit_team_state", "method": "public void team(Team team){", "outer_guard_expr": "if(tile != null && this.team != team){", "this_team_assignment_expr": "this.team = team;", "inner_guard_expr": "if(tile.team != team){", "tile_change_team_call_expr": "tile.changeTeam(team);", "tile_exists": tile_exists, "this_team": this_team, "team": team, "tile_team": tile_team, "outer_guard": outer_guard, "inner_guard": inner_guard, "this_team_after": this_team_after, "tile_change_team_call": tile_change_team_call, "tile_change_team_called": tile_change_team_called}
