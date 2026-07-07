# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/BuildPayload.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "BuildPayload"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Payload"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "build", "type": "Building"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BuildPayload", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}]}, {"modifiers": ["public"], "name": "BuildPayload", "parameters": [{"name": "build", "type": "Building", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "block", "parameters": [], "return_type": "Block"}, {"modifiers": ["public"], "name": "place", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "place", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "contentEquals", "parameters": [{"name": "other", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "content", "parameters": [], "return_type": "UnlockableContent"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unitHolder", "type": "Unit", "varargs": false}, {"name": "buildingHolder", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "destroyed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "buildTime", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "x", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "y", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_block_0(_args: Array = []) -> Variant:
	var build_block: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_build_payload_block_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public Block block(){", "return_expr": "return build.block;", "build_block": build_block}

func java_method_place_1(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var build_block: Variant = _args[1] if _args.size() > 1 else null
	var build_team: Variant = _args[2] if _args.size() > 2 else null
	var rotation_value: int = 0
	return {"source_owner": "PortGame.source_build_payload_place_default_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public void place(Tile tile){", "delegate_expr": "place(tile, 0);", "tile": tile, "build_block": build_block, "build_team": build_team, "delegated_rotation": rotation_value}

func java_method_place_2(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var build_block: Variant = _args[1] if _args.size() > 1 else null
	var build_team: Variant = _args[2] if _args.size() > 2 else null
	var rotation_value: int = int(_args[3] if _args.size() > 3 else 0)
	var set_block_call: Dictionary = {"call": "tile.setBlock(build.block, build.team, rotation, () -> build);", "tile": tile, "block": build_block, "team": build_team, "rotation": rotation_value, "build_supplier": "() -> build"}
	return {"source_owner": "PortGame.source_build_payload_place_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "method": "public void place(Tile tile, int rotation){", "set_block_expr": "tile.setBlock(build.block, build.team, rotation, () -> build);", "dropped_expr": "build.dropped();", "tile": tile, "build_block": build_block, "build_team": build_team, "rotation": rotation_value, "set_block_call": set_block_call, "dropped_called": true}

func java_method_contentEquals_3(_args: Array = []) -> Variant:
	var other_is_build_payload: bool = bool(_args[0] if _args.size() > 0 else false)
	var other_block: Variant = _args[1] if _args.size() > 1 else null
	var build_block: Variant = _args[2] if _args.size() > 2 else null
	var content_equals: bool = other_is_build_payload and other_block == build_block
	return {"source_owner": "PortGame.source_build_payload_content_equals_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public boolean contentEquals(Payload other){", "return_expr": "return other instanceof BuildPayload bp && bp.block() == build.block;", "other_is_build_payload": other_is_build_payload, "other_block": other_block, "build_block": build_block, "content_equals": content_equals}

func java_method_content_4(_args: Array = []) -> Variant:
	var build_block: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_build_payload_content_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public UnlockableContent content(){", "return_expr": "return build.block;", "content": build_block}

func java_method_update_5(_args: Array = []) -> Variant:
	var unit_holder_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var build_block_update_in_units: bool = bool(_args[1] if _args.size() > 1 else false)
	var unit_payload_update: bool = bool(_args[2] if _args.size() > 2 else false)
	var build_block_always_update_in_units: bool = bool(_args[3] if _args.size() > 3 else false)
	var unit_holder: Variant = _args[4] if _args.size() > 4 else null
	var building_holder: Variant = _args[5] if _args.size() > 5 else null
	var returned: bool = unit_holder_present and ((not build_block_update_in_units) or ((not unit_payload_update) and (not build_block_always_update_in_units)))
	var tile_after: Variant = null
	var update_payload_called: bool = false
	var update_payload_call: Variant = null
	if not returned:
		tile_after = "emptyTile"
		update_payload_called = true
		update_payload_call = {"call": "build.updatePayload(unitHolder, buildingHolder);", "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {"source_owner": "PortGame.source_build_payload_update_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){", "guard_expr": "if(unitHolder != null && (!build.block.updateInUnits || (!state.rules.unitPayloadUpdate && !build.block.alwaysUpdateInUnits))) return;", "tile_assign_expr": "build.tile = emptyTile;", "update_payload_expr": "build.updatePayload(unitHolder, buildingHolder);", "unit_holder_present": unit_holder_present, "build_block_update_in_units": build_block_update_in_units, "unit_payload_update": unit_payload_update, "build_block_always_update_in_units": build_block_always_update_in_units, "unitHolder": unit_holder, "buildingHolder": building_holder, "returned": returned, "tile_after": tile_after, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}

func java_method_destroyed_6(_args: Array = []) -> Variant:
	var dead_after: bool = true
	var on_destroyed_called: bool = true
	return {"source_owner": "PortGame.source_build_payload_destroyed_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void destroyed(){", "dead_assign_expr": "build.dead = true;", "on_destroyed_expr": "build.onDestroyed();", "dead_after": dead_after, "on_destroyed_called": on_destroyed_called}

func java_method_requirements_7(_args: Array = []) -> Variant:
	var requirements: Variant = _args[0] if _args.size() > 0 else []
	return {"source_owner": "PortGame.source_build_payload_requirements_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public ItemStack[] requirements(){", "return_expr": "return build.block.requirements;", "requirements": requirements}

func java_method_buildTime_8(_args: Array = []) -> Variant:
	var build_time: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_build_payload_build_time_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public float buildTime(){", "return_expr": "return build.block.buildTime;", "buildTime": build_time}

func java_method_x_9(_args: Array = []) -> Variant:
	var build_x: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_build_payload_x_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public float x(){", "return_expr": "return build.x;", "x": build_x}

func java_method_y_10(_args: Array = []) -> Variant:
	var build_y: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_build_payload_y_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public float y(){", "return_expr": "return build.y;", "y": build_y}

func java_method_size_11(_args: Array = []) -> Variant:
	var build_block_size: float = float(_args[0] if _args.size() > 0 else 0.0)
	var source_tilesize: float = float(_args[1] if _args.size() > 1 else 0.0)
	var size: float = build_block_size * source_tilesize
	return {"source_owner": "PortGame.source_build_payload_size_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public float size(){", "return_expr": "return build.block.size * tilesize;", "build_block_size": build_block_size, "source_tilesize": source_tilesize, "size": size}

func java_method_remove_12(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_build_payload_remove_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void remove(){", "remove_expr": "build.remove();", "remove_called": true}

func java_method_write_13(_args: Array = []) -> Variant:
	var payload_block: int = int(_args[0] if _args.size() > 0 else 0)
	var build_block_id: int = int(_args[1] if _args.size() > 1 else 0)
	var build_version: int = int(_args[2] if _args.size() > 2 else 0)
	var write_calls: Array = [{"call": "write.b(payloadBlock);", "method": "write.b", "value": payload_block}, {"call": "write.s(build.block.id);", "method": "write.s", "value": build_block_id}, {"call": "write.b(build.version());", "method": "write.b", "value": build_version}, {"call": "build.writeAll(write);", "method": "build.writeAll", "called": true}]
	return {"source_owner": "PortGame.source_build_payload_write_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void write(Writes write){", "payload_block_write_expr": "write.b(payloadBlock);", "block_id_write_expr": "write.s(build.block.id);", "version_write_expr": "write.b(build.version());", "write_all_expr": "build.writeAll(write);", "payload_block": payload_block, "build_block_id": build_block_id, "build_version": build_version, "write_all_called": true, "write_calls": write_calls}

func java_method_set_14(_args: Array = []) -> Variant:
	var x: float = float(_args[0] if _args.size() > 0 else 0.0)
	var y: float = float(_args[1] if _args.size() > 1 else 0.0)
	var rotation: float = float(_args[2] if _args.size() > 2 else 0.0)
	var set_call: Dictionary = {"call": "build.set(x, y);", "x": x, "y": y}
	return {"source_owner": "PortGame.source_build_payload_set_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public void set(float x, float y, float rotation){", "set_expr": "build.set(x, y);", "x": x, "y": y, "rotation": rotation, "set_called": true, "set_call": set_call}

func java_method_drawShadow_15(_args: Array = []) -> Variant:
	var build_x: float = float(_args[0] if _args.size() > 0 else 0.0)
	var build_y: float = float(_args[1] if _args.size() > 1 else 0.0)
	var build_block_size: float = float(_args[2] if _args.size() > 2 else 0.0)
	var source_tilesize: float = float(_args[3] if _args.size() > 3 else 0.0)
	var alpha: float = float(_args[4] if _args.size() > 4 else 0.0)
	var shadow_size: float = build_block_size * source_tilesize * 1.85
	var shadow_call: Dictionary = {"call": "Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);", "x": build_x, "y": build_y, "size": shadow_size, "alpha": alpha}
	return {"source_owner": "PortGame.source_build_payload_draw_shadow_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public void drawShadow(float alpha){", "shadow_expr": "Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);", "build_x": build_x, "build_y": build_y, "build_block_size": build_block_size, "source_tilesize": source_tilesize, "alpha": alpha, "shadow_size": shadow_size, "shadow_call": shadow_call}

func java_method_draw_16(_args: Array = []) -> Variant:
	var prev_z: float = float(_args[0] if _args.size() > 0 else 0.0)
	var layer_flying_unit_low: float = float(_args[1] if _args.size() > 1 else 0.0)
	var transform_z: float = float(_args[2] if _args.size() > 2 else prev_z)
	var shadow_z: float = prev_z - 0.001
	var transform_threshold: float = layer_flying_unit_low + 1.0
	var transform_min_limit: float = layer_flying_unit_low - 1.0
	var transformed_z: float = transform_z
	if transform_z < transform_threshold:
		var transform_clamped: float = clampf((transform_z - prev_z) / 100.0, -0.0009, 0.9)
		transformed_z = 0.0011 + min(transform_clamped + prev_z, transform_min_limit)
	var draw_calls: Array = [{"call": "float prevZ = Draw.z();", "value": prev_z}, {"call": "Draw.z(prevZ - 0.001f);", "z": shadow_z}, {"call": "drawShadow(1f);", "alpha": 1.0}, {"call": "Draw.z(prevZ);", "z": prev_z}, {"call": "Draw.zTransform(z ->", "input_z": transform_z, "result": transformed_z}, {"call": "build.tile = emptyTile;", "tile": "emptyTile"}, {"call": "build.payloadDraw();", "called": true}, {"call": "Draw.zTransform();", "called": true}, {"call": "Draw.z(prevZ);", "z": prev_z}]
	return {"source_owner": "PortGame.source_build_payload_draw_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "import_expr": "import static mindustry.Vars.*;", "override_expr": "@Override", "method": "public void draw(){", "prev_z_expr": "float prevZ = Draw.z();", "shadow_z_expr": "Draw.z(prevZ - 0.001f);", "draw_shadow_expr": "drawShadow(1f);", "z_restore_expr": "Draw.z(prevZ);", "z_transform_expr": "Draw.zTransform(z ->", "z_transform_return_expr": "z >= Layer.flyingUnitLow + 1f ? z : 0.0011f + Math.min(Mathf.clamp((z - prevZ)/100f, -0.0009f, 0.9f) + prevZ, Layer.flyingUnitLow - 1f)", "tile_assign_expr": "build.tile = emptyTile;", "payload_draw_expr": "build.payloadDraw();", "z_transform_reset_expr": "Draw.zTransform();", "final_z_restore_expr": "Draw.z(prevZ);", "prev_z": prev_z, "layer_flying_unit_low": layer_flying_unit_low, "transform_z": transform_z, "shadow_z": shadow_z, "transformed_z": transformed_z, "tile_after": "emptyTile", "payload_draw_called": true, "draw_calls": draw_calls}

func java_method_icon_17(_args: Array = []) -> Variant:
	var full_icon: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_build_payload_icon_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public TextureRegion icon(){", "return_expr": "return block().fullIcon;", "full_icon": full_icon, "icon": full_icon}
