extends RefCounted
class_name SourceBlockInitSandboxVisibilityState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func sandbox_visibility_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	var sandbox_visibility_applied: bool = build_visibility == "BuildVisibility.sandboxOnly"
	var hide_details_after: bool = false if sandbox_visibility_applied else hide_details_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_SANDBOX_VISIBILITY_STATE, "source": "core/src/mindustry/world/Block.java", "build_visibility_source": "core/src/mindustry/world/meta/BuildVisibility.java", "unlockable_content_source": "core/src/mindustry/ctype/UnlockableContent.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_visibility_field_expr": "public BuildVisibility buildVisibility = BuildVisibility.hidden;", "hide_details_field_expr": "public boolean hideDetails = true;", "sandbox_visibility_guard_expr": "if(buildVisibility == BuildVisibility.sandboxOnly){", "sandbox_only_expr": "sandboxOnly = new BuildVisibility(() -> Vars.state == null || Vars.state.rules.infiniteResources),", "hide_details_assign_expr": "hideDetails = false;", "build_visibility": build_visibility, "hide_details_before": hide_details_before, "sandbox_visibility_applied": sandbox_visibility_applied, "hide_details_after": hide_details_after}

static func generated_block_init_sandbox_visibility_bridge_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [build_visibility, hide_details_before], null, {"mindustry_init_bridge_mode": "sandbox_visibility"})
	var canonical = sandbox_visibility_state(build_visibility, hide_details_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_SANDBOX_VISIBILITY_STATE, "generated_owner": "block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
