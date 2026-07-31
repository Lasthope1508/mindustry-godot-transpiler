extends RefCounted
class_name SourceBlockLoadState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func base_regions_state(name_value: String) -> Dictionary:
	var region_value: String = "Core.atlas.find(%s)" % name_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_BASE_REGIONS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "super_load_expr": "super.load();", "region_expr": "region = Core.atlas.find(name);", "content_regions_expr": "ContentRegions.loadRegions(this);", "name": name_value, "region": region_value, "super_load_called": true, "content_regions_loaded": true}

static func team_regions_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	var team_regions: Array = []
	for _i in range(teams.size()):
		team_regions.append(team_region)
	var assignments: Array = []
	for team in teams:
		if not team is Dictionary:
			continue
		var team_id: int = int(team.get("id", 0))
		var team_name: String = str(team.get("name", ""))
		var team_has_palette: bool = bool(team.get("hasPalette", false))
		var assigned_region: Variant = team_region
		if team_region_found and team_has_palette:
			assigned_region = "Core.atlas.find(%s-team-%s, %s)" % [name_value, team_name, str(team_region)]
		if team_id >= 0 and team_id < team_regions.size():
			team_regions[team_id] = assigned_region
		assignments.append({"team_id": team_id, "team_name": team_name, "team_has_palette": team_has_palette, "assigned_region": assigned_region})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_TEAM_REGIONS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "comment": "//load specific team regions", "team_regions_expr": "teamRegions = new TextureRegion[Team.all.length];", "team_loop_expr": "for(Team team : Team.all){", "team_assignment_expr": "teamRegions[team.id] = teamRegion.found() && team.hasPalette ? Core.atlas.find(name + \"-team-\" + team.name, teamRegion) : teamRegion;", "name": name_value, "team_region_found": team_region_found, "team_region": team_region, "teams": teams, "team_all_length": teams.size(), "team_regions": team_regions, "assignments": assignments}

static func variant_regions_state(name_value: String, variants: int) -> Dictionary:
	var variants_guard: bool = variants != 0
	var variant_regions: Array = []
	var variant_region_value: Variant = null
	if variants_guard:
		for i in range(variants):
			variant_regions.append("Core.atlas.find(%s%d)" % [name_value, i + 1])
		if variant_regions.size() > 0:
			variant_region_value = variant_regions[0]
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_VARIANT_REGIONS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "variants_guard_expr": "if(variants != 0){", "variant_regions_expr": "variantRegions = new TextureRegion[variants];", "variant_loop_expr": "for(int i = 0; i < variants; i++){", "variant_assignment_expr": "variantRegions[i] = Core.atlas.find(name + (i + 1));", "region_assignment_expr": "region = variantRegions[0];", "name": name_value, "variants": variants, "variants_guard": variants_guard, "variant_regions": variant_regions, "region": variant_region_value}

static func variant_shadow_regions_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	var variants_guard: bool = variants != 0
	var custom_shadow_guard: bool = variants_guard and custom_shadow
	var variant_shadow_regions: Array = []
	if custom_shadow_guard:
		for i in range(variants):
			variant_shadow_regions.append("Core.atlas.find(%s-shadow%d)" % [name_value, i + 1])
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_VARIANT_SHADOW_REGIONS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "variants_guard_expr": "if(variants != 0){", "custom_shadow_guard_expr": "if(customShadow){", "variant_shadow_regions_expr": "variantShadowRegions = new TextureRegion[variants];", "variant_shadow_loop_expr": "for(int i = 0; i < variants; i++){", "variant_shadow_assignment_expr": "variantShadowRegions[i] = Core.atlas.find(name + \"-shadow\" + (i + 1));", "name": name_value, "variants": variants, "custom_shadow": custom_shadow, "variants_guard": variants_guard, "custom_shadow_guard": custom_shadow_guard, "variant_shadow_regions": variant_shadow_regions}

static func generated_block_load_base_regions_bridge_state(name_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_load_126", [name_value], null)
	var canonical = base_regions_state(name_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_BASE_REGIONS_STATE, "generated_owner": "block.java_method_load_126", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_load_team_regions_bridge_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_load_126", [name_value, team_region_found, team_region, teams], null, {"mindustry_load_bridge_mode": "team_regions"})
	var canonical = team_regions_state(name_value, team_region_found, team_region, teams)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_TEAM_REGIONS_STATE, "generated_owner": "block.java_method_load_126", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_load_variant_regions_bridge_state(name_value: String, variants: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_load_126", [name_value, variants], null, {"mindustry_load_bridge_mode": "variant_regions"})
	var canonical = variant_regions_state(name_value, variants)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_VARIANT_REGIONS_STATE, "generated_owner": "block.java_method_load_126", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_load_variant_shadow_regions_bridge_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_load_126", [name_value, variants, custom_shadow], null, {"mindustry_load_bridge_mode": "variant_shadow_regions"})
	var canonical = variant_shadow_regions_state(name_value, variants, custom_shadow)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LOAD_VARIANT_SHADOW_REGIONS_STATE, "generated_owner": "block.java_method_load_126", "result": result, "canonical": canonical, "matches": matches}
