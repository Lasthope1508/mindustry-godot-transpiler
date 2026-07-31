extends RefCounted
class_name SourceBlockInitFlagsState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func custom_shadow_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	var has_shadow_assigned: bool = custom_shadow
	var has_shadow_after: bool = false if has_shadow_assigned else has_shadow_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CUSTOM_SHADOW_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "custom_shadow_comment": "//disable standard shadow", "custom_shadow_guard_expr": "if(customShadow){", "has_shadow_assign_expr": "hasShadow = false;", "custom_shadow": custom_shadow, "has_shadow_before": has_shadow_before, "has_shadow_after": has_shadow_after, "has_shadow_assigned": has_shadow_assigned}

static func generated_custom_shadow_bridge_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "custom_shadow"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [custom_shadow, has_shadow_before], null, metadata)
	var canonical = custom_shadow_state(custom_shadow, has_shadow_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CUSTOM_SHADOW_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func under_bullets_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	var priority_assigned: bool = under_bullets
	var priority_after: Variant = source_block_defaults.INIT_TARGET_PRIORITY_UNDER if priority_assigned else priority_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_UNDER_BULLETS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "under_bullets_guard_expr": "if(underBullets){", "priority_assign_expr": "priority = TargetPriority.under;", "target_priority_under_expr": "TargetPriority.under", "under_bullets": under_bullets, "priority_before": priority_before, "priority_after": priority_after, "priority_assigned": priority_assigned}

static func generated_under_bullets_bridge_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "under_bullets"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [under_bullets, priority_before], null, metadata)
	var canonical = under_bullets_state(under_bullets, priority_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_UNDER_BULLETS_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func fog_radius_flag_state(fog_radius: int, flags_before: Array) -> Dictionary:
	var flags_after: Array = flags_before.duplicate()
	var has_fog_radius_flag_added: bool = fog_radius > 0
	if has_fog_radius_flag_added and not flags_after.has(source_block_defaults.INIT_BLOCK_FLAG_HAS_FOG_RADIUS):
		flags_after.append(source_block_defaults.INIT_BLOCK_FLAG_HAS_FOG_RADIUS)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_FOG_RADIUS_FLAG_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "fog_radius_guard_expr": "if(fogRadius > 0){", "flags_assign_expr": "flags = flags.with(BlockFlag.hasFogRadius);", "block_flag_has_fog_radius_expr": "BlockFlag.hasFogRadius", "fog_radius": fog_radius, "flags_before": flags_before, "flags_after": flags_after, "has_fog_radius_flag_added": has_fog_radius_flag_added}

static func generated_fog_radius_flag_bridge_state(fog_radius: int, flags_before: Array) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "fog_radius_flag"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [fog_radius, flags_before], null, metadata)
	var canonical = fog_radius_flag_state(fog_radius, flags_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_FOG_RADIUS_FLAG_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func sync_flag_state(sync_value: bool, flags_before: Array) -> Dictionary:
	var flags_after: Array = flags_before.duplicate()
	var synced_flag_added: bool = sync_value
	if synced_flag_added and not flags_after.has(source_block_defaults.INIT_BLOCK_FLAG_SYNCED):
		flags_after.append(source_block_defaults.INIT_BLOCK_FLAG_SYNCED)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_SYNC_FLAG_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "sync_guard_expr": "if(sync){", "flags_assign_expr": "flags = flags.with(BlockFlag.synced);", "block_flag_synced_expr": "BlockFlag.synced", "sync": sync_value, "flags_before": flags_before, "flags_after": flags_after, "synced_flag_added": synced_flag_added}

static func generated_sync_flag_bridge_state(sync_value: bool, flags_before: Array) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "sync_flag"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [sync_value, flags_before], null, metadata)
	var canonical = sync_flag_state(sync_value, flags_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_SYNC_FLAG_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
