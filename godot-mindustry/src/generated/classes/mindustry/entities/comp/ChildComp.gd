# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/ChildComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "ChildComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Rotc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "parent", "type": "Posc"}, {"modifiers": [], "name": "rotWithParent", "type": "boolean"}, {"modifiers": [], "name": "offsetX", "type": "float"}, {"modifiers": [], "name": "offsetY", "type": "float"}, {"modifiers": [], "name": "offsetPos", "type": "float"}, {"modifiers": [], "name": "offsetRot", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_add_0(_args: Array = []) -> Variant:
	var child_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var x: float = float(child_state.get("x", 0.0))
	var y: float = float(child_state.get("y", 0.0))
	var rotation: float = float(child_state.get("rotation", 0.0))
	var offset_x: float = float(child_state.get("offsetX", 0.0))
	var offset_y: float = float(child_state.get("offsetY", 0.0))
	var offset_pos: float = float(child_state.get("offsetPos", 0.0))
	var offset_rot: float = float(child_state.get("offsetRot", 0.0))
	var parent_guard: bool = bool(child_state.get("parent_exists", false))
	var parent_get_x: float = float(child_state.get("parent_get_x", 0.0))
	var parent_get_y: float = float(child_state.get("parent_get_y", 0.0))
	var rot_with_parent: bool = bool(child_state.get("rot_with_parent", false))
	var parent_is_rotc: bool = bool(child_state.get("parent_is_rotc", false))
	var parent_rotc_rotation: float = float(child_state.get("parent_rotc_rotation", 0.0))
	var parent_is_rotblock: bool = bool(child_state.get("parent_is_rotblock", false))
	var parent_rotblock_build_rotation: float = float(child_state.get("parent_rotblock_build_rotation", 0.0))
	var next_offset_x: float = offset_x
	var next_offset_y: float = offset_y
	var next_offset_pos: float = offset_pos
	var next_offset_rot: float = offset_rot
	var rot_with_parent_guard := false
	var parent_rotc_guard := false
	var parent_rotblock_guard := false
	if parent_guard:
		next_offset_x = x - parent_get_x
		next_offset_y = y - parent_get_y
		if rot_with_parent:
			rot_with_parent_guard = true
			if parent_is_rotc:
				parent_rotc_guard = true
				next_offset_pos = -parent_rotc_rotation
				next_offset_rot = rotation - parent_rotc_rotation
			elif parent_is_rotblock:
				parent_rotblock_guard = true
				next_offset_pos = -parent_rotblock_build_rotation
				next_offset_rot = rotation - parent_rotblock_build_rotation
	return {"source_owner": "PortGame.source_child_add_state", "method": "public void add(){", "parent_guard_expr": "if(parent != null){", "offsetX_expr": "offsetX = x - parent.getX();", "offsetY_expr": "offsetY = y - parent.getY();", "rot_with_parent_guard_expr": "if(rotWithParent){", "parent_rotc_guard_expr": "if(parent instanceof Rotc r){", "parent_rotblock_guard_expr": "}else if(parent instanceof RotBlock rot){", "offsetPos_rotc_expr": "offsetPos = -r.rotation();", "offsetRot_rotc_expr": "offsetRot = rotation - r.rotation();", "offsetPos_rotblock_expr": "offsetPos = -rot.buildRotation();", "offsetRot_rotblock_expr": "offsetRot = rotation - rot.buildRotation();", "parentGuard": parent_guard, "offsetX": next_offset_x, "offsetY": next_offset_y, "rotWithParentGuard": rot_with_parent_guard, "parentRotcGuard": parent_rotc_guard, "parentRotBlockGuard": parent_rotblock_guard, "offsetPos": next_offset_pos, "offsetRot": next_offset_rot}

func java_method_update_1(_args: Array = []) -> Variant:
	return null
