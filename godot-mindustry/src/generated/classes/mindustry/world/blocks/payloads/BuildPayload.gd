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
	return null

func java_method_place_2(_args: Array = []) -> Variant:
	return null

func java_method_contentEquals_3(_args: Array = []) -> Variant:
	return null

func java_method_content_4(_args: Array = []) -> Variant:
	var build_block: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_build_payload_content_state", "source": "core/src/mindustry/world/blocks/payloads/BuildPayload.java", "class_expr": "public class BuildPayload implements Payload{", "field_expr": "public Building build;", "override_expr": "@Override", "method": "public UnlockableContent content(){", "return_expr": "return build.block;", "content": build_block}

func java_method_update_5(_args: Array = []) -> Variant:
	return null

func java_method_destroyed_6(_args: Array = []) -> Variant:
	return null

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
	return null

func java_method_icon_17(_args: Array = []) -> Variant:
	return null
