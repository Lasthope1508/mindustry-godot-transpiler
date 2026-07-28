extends RefCounted
class_name SourceBlockProducerState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const SOURCE_BLOCK_PRODUCER_SOURCE := "core/src/mindustry/world/blocks/payloads/BlockProducer.java"
const SOURCE_BLOCK_PRODUCER_CLASS_EXPR := "public abstract class BlockProducer extends PayloadBlock{"
const SOURCE_BLOCK_PRODUCER_ICONS_METHOD := "public TextureRegion[] icons(){"
const SOURCE_BLOCK_PRODUCER_ICONS_RETURN_EXPR := "return new TextureRegion[]{region, outRegion, topRegion};"
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_METHOD := "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){"
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR := "Draw.rect(region, plan.drawx(), plan.drawy());"
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR := "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);"
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR := "Draw.rect(topRegion, plan.drawx(), plan.drawy());"
const SOURCE_BLOCK_PRODUCER_SET_BARS_METHOD := "public void setBars(){"
const SOURCE_BLOCK_PRODUCER_SET_BARS_SUPER_EXPR := "super.setBars();"
const SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR := "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));"
const SOURCE_BLOCK_PRODUCER_SET_BARS_PROGRESS_EXPR := "entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)"
const SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR := "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{"
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_METHOD := "public boolean acceptItem(Building source, Item item){"
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_RETURN_EXPR := "return items.get(item) < getMaximumAccepted(item);"
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_METHOD := "public int getMaximumAccepted(Item item){"
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_NULL_GUARD := "if(recipe() == null) return 0;"
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_REQUIREMENT_LOOP := "for(ItemStack stack : recipe().requirements){"
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_MATCH_EXPR := "if(stack.item == item) return stack.amount * 2;"
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_FINAL_RETURN := "return 0;"
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_METHOD := "public boolean acceptPayload(Building source, Payload payload){"
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_RETURN_EXPR := "return false;"
const SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_METHOD := "public boolean shouldConsume(){"
const SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_RETURN_EXPR := "return super.shouldConsume() && recipe() != null;"

static func icons_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	var icons: Array = [region, out_region, top_region]
	return {"source_owner": "PortGame.source_block_producer_icons_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "class_expr": SOURCE_BLOCK_PRODUCER_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_ICONS_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_ICONS_RETURN_EXPR, "region": region, "out_region": out_region, "top_region": top_region, "icons": icons}

static func draw_plan_region_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	var out_region_rotation: float = plan_rotation * 90.0
	var draw_calls: Array = [{"call": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR, "region": region, "x": plan_drawx, "y": plan_drawy}, {"call": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR, "region": out_region, "x": plan_drawx, "y": plan_drawy, "rotation": out_region_rotation}, {"call": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR, "region": top_region, "x": plan_drawx, "y": plan_drawy}]
	return {"source_owner": "PortGame.source_block_producer_draw_plan_region_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "class_expr": SOURCE_BLOCK_PRODUCER_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_METHOD, "draw_region_expr": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR, "draw_out_region_expr": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR, "draw_top_region_expr": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR, "region": region, "out_region": out_region, "top_region": top_region, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "plan_rotation": plan_rotation, "out_region_rotation": out_region_rotation, "draw_calls": draw_calls}

static func set_bars_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	var progress_bar_fraction: float = 0.0 if recipe_null else entity_progress / recipe_build_time
	var progress_bar_call: Dictionary = {"call": SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR, "name": "progress", "bar_text": "bar.progress", "color": "Pal.ammo", "fraction": progress_bar_fraction}
	return {"source_owner": "PortGame.source_block_producer_set_bars_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "class_expr": SOURCE_BLOCK_PRODUCER_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_SET_BARS_METHOD, "super_set_bars_expr": SOURCE_BLOCK_PRODUCER_SET_BARS_SUPER_EXPR, "add_bar_expr": SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR, "bar_text": "bar.progress", "bar_color": "Pal.ammo", "bar_progress_expr": SOURCE_BLOCK_PRODUCER_SET_BARS_PROGRESS_EXPR, "recipe_null": recipe_null, "entity_progress": entity_progress, "recipe_build_time": recipe_build_time, "super_set_bars_called": true, "progress_bar_added": true, "progress_bar_fraction": progress_bar_fraction, "progress_bar_call": progress_bar_call}

static func build_accept_item_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	var accept_item: bool = item_count < maximum_accepted
	return {"source_owner": "PortGame.source_block_producer_build_accept_item_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_RETURN_EXPR, "source_building": source_building, "item": item, "item_count": item_count, "maximum_accepted": maximum_accepted, "accept_item": accept_item}

static func build_get_maximum_accepted_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	var maximum_accepted: int = 0
	var matched_requirement: Variant = null
	if not recipe_null:
		for stack in requirements:
			if stack is Dictionary:
				var stack_item: Variant = stack.get("item", null)
				if stack_item == item:
					var stack_amount: int = int(stack.get("amount", 0))
					maximum_accepted = stack_amount * 2
					matched_requirement = stack
					break
	return {"source_owner": "PortGame.source_block_producer_build_get_maximum_accepted_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_METHOD, "null_guard": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_NULL_GUARD, "requirement_loop": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_REQUIREMENT_LOOP, "match_expr": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_MATCH_EXPR, "final_return": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_FINAL_RETURN, "item": item, "recipe_null": recipe_null, "requirements": requirements, "matched_requirement": matched_requirement, "maximum_accepted": maximum_accepted}

static func build_accept_payload_state(source_building: Variant, payload: Variant) -> Dictionary:
	var accept_payload: bool = false
	return {"source_owner": "PortGame.source_block_producer_build_accept_payload_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_RETURN_EXPR, "source_building": source_building, "payload": payload, "accept_payload": accept_payload}

static func build_should_consume_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	var should_consume: bool = super_should_consume and not recipe_null
	return {"source_owner": "PortGame.source_block_producer_build_should_consume_state", "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_RETURN_EXPR, "super_should_consume": super_should_consume, "recipe_null": recipe_null, "should_consume": should_consume}

static func generated_block_producer_icons_bridge_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_method_icons_0", [region, out_region, top_region], null)
	var canonical = icons_state(region, out_region, top_region)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_icons_state", "generated_owner": "BlockProducer.java_method_icons_0", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_draw_plan_region_bridge_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_method_drawPlanRegion_1", [region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation], null)
	var canonical = draw_plan_region_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_draw_plan_region_state", "generated_owner": "BlockProducer.java_method_drawPlanRegion_1", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_set_bars_bridge_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_method_setBars_2", [recipe_null, entity_progress, recipe_build_time], null)
	var canonical = set_bars_state(recipe_null, entity_progress, recipe_build_time)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_set_bars_state", "generated_owner": "BlockProducer.java_method_setBars_2", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_accept_item_bridge_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_acceptItem_1", [source_building, item, item_count, maximum_accepted], null)
	var canonical = build_accept_item_state(source_building, item, item_count, maximum_accepted)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_build_accept_item_state", "generated_owner": "BlockProducer.BlockProducerBuild.acceptItem", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_get_maximum_accepted_bridge_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_getMaximumAccepted_2", [item, recipe_null, requirements], null)
	var canonical = build_get_maximum_accepted_state(item, recipe_null, requirements)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_build_get_maximum_accepted_state", "generated_owner": "BlockProducer.BlockProducerBuild.getMaximumAccepted", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_accept_payload_bridge_state(source_building: Variant, payload: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_acceptPayload_3", [source_building, payload], null)
	var canonical = build_accept_payload_state(source_building, payload)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_build_accept_payload_state", "generated_owner": "BlockProducer.BlockProducerBuild.acceptPayload", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_should_consume_bridge_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_shouldConsume_4", [super_should_consume, recipe_null], null)
	var canonical = build_should_consume_state(super_should_consume, recipe_null)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_producer_build_should_consume_state", "generated_owner": "BlockProducer.BlockProducerBuild.shouldConsume", "result": result, "canonical": canonical, "matches": matches}
