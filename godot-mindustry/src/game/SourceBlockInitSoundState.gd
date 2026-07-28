extends RefCounted
class_name SourceBlockInitSoundState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func generated_state_matches_generated_subset(result: Variant, canonical: Variant) -> bool:
	if result is Dictionary and canonical is Dictionary:
		for key in canonical.keys():
			if not result.has(key):
				return false
			if not generated_state_matches_generated_subset(result.get(key), canonical.get(key)):
				return false
		return true
	if result is Array and canonical is Array:
		if result.size() != canonical.size():
			return false
		for index in range(canonical.size()):
			if not generated_state_matches_generated_subset(result[index], canonical[index]):
				return false
		return true
	return result == canonical

static func destroy_sound_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	var destroy_sound_after: Variant = destroy_sound_before
	var destroy_sound_assigned: bool = destroy_sound_before == "Sounds.unset"
	if destroy_sound_assigned:
		if size_value >= 3:
			destroy_sound_after = "Sounds.blockExplode3"
		elif size_value >= 2:
			destroy_sound_after = {"type": "RandomSound", "sounds": ["Sounds.blockExplode2", "Sounds.blockExplode2Alt"]}
		else:
			destroy_sound_after = {"type": "RandomSound", "sounds": ["Sounds.blockExplode1", "Sounds.blockExplode1Alt"]}
	return {"source_owner": "PortGame.source_block_init_destroy_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "destroy_sound_guard_expr": "if(destroySound == Sounds.unset){", "destroy_sound_assign_expr": "destroySound =", "destroy_sound_size_3_expr": "size >= 3 ? Sounds.blockExplode3 :", "destroy_sound_size_2_expr": "size >= 2 ? new RandomSound(Sounds.blockExplode2, Sounds.blockExplode2Alt) :", "destroy_sound_size_1_expr": "new RandomSound(Sounds.blockExplode1, Sounds.blockExplode1Alt);", "destroy_sound_before": destroy_sound_before, "size": size_value, "destroy_sound_after": destroy_sound_after, "destroy_sound_assigned": destroy_sound_assigned}

static func place_sound_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	var place_sound_after: Variant = place_sound_before
	var place_sound_assigned: bool = place_sound_before == "Sounds.unset"
	if place_sound_assigned:
		if size_value >= 3:
			place_sound_after = "Sounds.blockPlace3"
		elif size_value >= 2:
			place_sound_after = "Sounds.blockPlace2"
		else:
			place_sound_after = "Sounds.blockPlace1"
	return {"source_owner": "PortGame.source_block_init_place_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "place_sound_guard_expr": "if(placeSound == Sounds.unset){", "place_sound_assign_expr": "placeSound =", "place_sound_size_3_expr": "size >= 3 ? Sounds.blockPlace3 :", "place_sound_size_2_expr": "size >= 2 ? Sounds.blockPlace2 :", "place_sound_size_1_expr": "Sounds.blockPlace1;", "place_sound_before": place_sound_before, "size": size_value, "place_sound_after": place_sound_after, "place_sound_assigned": place_sound_assigned}

static func break_sound_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	var break_sound_after: Variant = break_sound_before
	var break_sound_assigned: bool = break_sound_before == "Sounds.unset"
	if break_sound_assigned:
		if size_value >= 3:
			break_sound_after = "Sounds.blockBreak3"
		elif size_value >= 2:
			break_sound_after = "Sounds.blockBreak2"
		else:
			break_sound_after = "Sounds.blockBreak1"
	return {"source_owner": "PortGame.source_block_init_break_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "break_sound_guard_expr": "if(breakSound == Sounds.unset){", "break_sound_assign_expr": "breakSound =", "break_sound_size_3_expr": "size >= 3 ? Sounds.blockBreak3 :", "break_sound_size_2_expr": "size >= 2 ? Sounds.blockBreak2 :", "break_sound_size_1_expr": "Sounds.blockBreak1;", "break_sound_before": break_sound_before, "size": size_value, "break_sound_after": break_sound_after, "break_sound_assigned": break_sound_assigned}

static func generated_block_init_destroy_sound_bridge_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [destroy_sound_before, size_value], null)
	var canonical = destroy_sound_state(destroy_sound_before, size_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_init_destroy_sound_state", "generated_owner": "Block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_init_place_sound_bridge_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "place_sound"}
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [place_sound_before, size_value], null, metadata)
	var canonical = place_sound_state(place_sound_before, size_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_init_place_sound_state", "generated_owner": "Block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_init_break_sound_bridge_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "break_sound"}
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [break_sound_before, size_value], null, metadata)
	var canonical = break_sound_state(break_sound_before, size_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_init_break_sound_state", "generated_owner": "Block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
