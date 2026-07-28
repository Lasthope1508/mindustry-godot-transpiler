extends RefCounted
class_name SourceChildState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceMathState := preload("res://src/game/SourceMathState.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"trns_vec": Callable(game, "source_arc_angles_trns_vec"),
	}

static func add_state(child_state: Dictionary) -> Dictionary:
	var x: float = float(child_state.get("x", 0.0))
	var y: float = float(child_state.get("y", 0.0))
	var rotation_value: float = float(child_state.get("rotation", 0.0))
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
				next_offset_rot = rotation_value - parent_rotc_rotation
			elif parent_is_rotblock:
				parent_rotblock_guard = true
				next_offset_pos = -parent_rotblock_build_rotation
				next_offset_rot = rotation_value - parent_rotblock_build_rotation
	return {
		"method": "public void add(){",
		"parentGuard": parent_guard,
		"offsetX": next_offset_x,
		"offsetY": next_offset_y,
		"rotWithParentGuard": rot_with_parent_guard,
		"parentRotcGuard": parent_rotc_guard,
		"parentRotBlockGuard": parent_rotblock_guard,
		"offsetPos": next_offset_pos,
		"offsetRot": next_offset_rot,
	}

static func update_state(child_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var x: float = float(child_state.get("x", 0.0))
	var y: float = float(child_state.get("y", 0.0))
	var rotation_value: float = float(child_state.get("rotation", 0.0))
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
	var next_x: float = x
	var next_y: float = y
	var next_rotation: float = rotation_value
	var rot_with_parent_guard := false
	var parent_rotc_guard := false
	var parent_rotblock_guard := false
	if parent_guard:
		if rot_with_parent:
			rot_with_parent_guard = true
			if parent_is_rotc:
				parent_rotc_guard = true
				var trns_vec_rotc: Dictionary = trns_vec.call(parent_rotc_rotation + offset_pos, offset_x, offset_y)
				next_x = parent_get_x + float(trns_vec_rotc.get("x", 0.0))
				next_y = parent_get_y + float(trns_vec_rotc.get("y", 0.0))
				next_rotation = parent_rotc_rotation + offset_rot
			elif parent_is_rotblock:
				parent_rotblock_guard = true
				var trns_vec_rotblock: Dictionary = trns_vec.call(parent_rotblock_build_rotation + offset_pos, offset_x, offset_y)
				next_x = parent_get_x + float(trns_vec_rotblock.get("x", 0.0))
				next_y = parent_get_y + float(trns_vec_rotblock.get("y", 0.0))
				next_rotation = parent_rotblock_build_rotation + offset_rot
		else:
			next_x = parent_get_x + offset_x
			next_y = parent_get_y + offset_y
	return {
		"method": "public void update(){",
		"parentGuard": parent_guard,
		"rotWithParentGuard": rot_with_parent_guard,
		"parentRotcGuard": parent_rotc_guard,
		"parentRotBlockGuard": parent_rotblock_guard,
		"x": next_x,
		"y": next_y,
		"rotation": next_rotation,
	}

static func generated_child_add_bridge_state(child_state: Dictionary) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/ChildComp.gd", "java_method_add_0", [child_state], null)
	var canonical = add_state(child_state)
	return {
		"source_owner": "PortGame.source_child_add_state",
		"generated_owner": "ChildComp.java_method_add_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("parentGuard", null) == canonical.get("parentGuard", null) and result.get("offsetX", null) == canonical.get("offsetX", null) and result.get("offsetY", null) == canonical.get("offsetY", null) and result.get("rotWithParentGuard", null) == canonical.get("rotWithParentGuard", null) and result.get("parentRotcGuard", null) == canonical.get("parentRotcGuard", null) and result.get("parentRotBlockGuard", null) == canonical.get("parentRotBlockGuard", null) and result.get("offsetPos", null) == canonical.get("offsetPos", null) and result.get("offsetRot", null) == canonical.get("offsetRot", null),
	}

static func generated_child_update_bridge_state(child_state: Dictionary) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/ChildComp.gd", "java_method_update_1", [child_state], null)
	var trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
		return SourceMathState.source_angles_trns_vec(angle_degrees, x_value, y_value)
	var canonical = update_state(child_state, trns_vec)
	return {
		"source_owner": "PortGame.source_child_update_state",
		"generated_owner": "ChildComp.java_method_update_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("parentGuard", null) == canonical.get("parentGuard", null) and result.get("rotWithParentGuard", null) == canonical.get("rotWithParentGuard", null) and result.get("parentRotcGuard", null) == canonical.get("parentRotcGuard", null) and result.get("parentRotBlockGuard", null) == canonical.get("parentRotBlockGuard", null) and is_equal_approx(float(result.get("x", 0.0)), float(canonical.get("x", 0.0))) and is_equal_approx(float(result.get("y", 0.0)), float(canonical.get("y", 0.0))) and is_equal_approx(float(result.get("rotation", 0.0)), float(canonical.get("rotation", 0.0))),
	}
