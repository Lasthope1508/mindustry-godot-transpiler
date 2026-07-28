extends RefCounted
class_name SourceBlockInitPlacementState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func accepts_items_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	var accepts_items_gate: bool = block_group == "BlockGroup.transportation" or category_value == "Category.distribution"
	var accepts_items_after: bool = true if accepts_items_gate else accepts_items_before
	return {"source_owner": "PortGame.source_block_init_accepts_items_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "accepts_items_guard_expr": "if(group == BlockGroup.transportation || category == Category.distribution){", "accepts_items_assign_expr": "acceptsItems = true;", "block_group": block_group, "category": category_value, "accepts_items_before": accepts_items_before, "accepts_items_gate": accepts_items_gate, "accepts_items_after": accepts_items_after}

static func generated_accepts_items_bridge_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "accepts_items"}
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [block_group, category_value, accepts_items_before], null, metadata)
	var canonical = accepts_items_state(block_group, category_value, accepts_items_before)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_init_accepts_items_state",
		"generated_owner": "Block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func offset_state(size_value: int, source_tilesize: float) -> Dictionary:
	var offset_after: float = float((size_value + 1) % 2) * source_tilesize / 2.0
	var size_offset_after: int = -int(float(size_value - 1) / 2.0)
	return {"source_owner": "PortGame.source_block_init_offset_state", "source": "core/src/mindustry/world/Block.java", "vars_source": "core/src/mindustry/Vars.java", "method": "public void init(){", "super_init_expr": "super.init();", "offset_expr": "offset = ((size + 1) % 2) * tilesize / 2f;", "size_offset_expr": "sizeOffset = -((size - 1) / 2);", "tilesize_field_expr": "public static final int tilesize = 8;", "size": size_value, "source_tilesize": source_tilesize, "offset_after": offset_after, "size_offset_after": size_offset_after}

static func generated_offset_bridge_state(size_value: int, source_tilesize: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "offset"}
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [size_value, source_tilesize], null, metadata)
	var canonical = offset_state(size_value, source_tilesize)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_init_offset_state",
		"generated_owner": "Block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
