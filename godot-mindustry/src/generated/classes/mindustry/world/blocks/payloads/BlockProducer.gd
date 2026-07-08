# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/BlockProducer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockProducer"
const JAVA_EXTENDS := "PayloadBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "buildSpeed", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BlockProducer", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_icons_0(_args: Array = []) -> Variant:
	var region: Variant = _args[0] if _args.size() > 0 else null
	var out_region: Variant = _args[1] if _args.size() > 1 else null
	var top_region: Variant = _args[2] if _args.size() > 2 else null
	var icons: Array = [region, out_region, top_region]
	return {"source_owner": "PortGame.source_block_producer_icons_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public TextureRegion[] icons(){", "return_expr": "return new TextureRegion[]{region, outRegion, topRegion};", "region": region, "out_region": out_region, "top_region": top_region, "icons": icons}

func java_method_drawPlanRegion_1(_args: Array = []) -> Variant:
	var region: Variant = _args[0] if _args.size() > 0 else null
	var out_region: Variant = _args[1] if _args.size() > 1 else null
	var top_region: Variant = _args[2] if _args.size() > 2 else null
	var plan_drawx: float = float(_args[3] if _args.size() > 3 else 0.0)
	var plan_drawy: float = float(_args[4] if _args.size() > 4 else 0.0)
	var plan_rotation: float = float(_args[5] if _args.size() > 5 else 0.0)
	var out_region_rotation: float = plan_rotation * 90.0
	var draw_calls: Array = [{"call": "Draw.rect(region, plan.drawx(), plan.drawy());", "region": region, "x": plan_drawx, "y": plan_drawy}, {"call": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "region": out_region, "x": plan_drawx, "y": plan_drawy, "rotation": out_region_rotation}, {"call": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": top_region, "x": plan_drawx, "y": plan_drawy}]
	return {"source_owner": "PortGame.source_block_producer_draw_plan_region_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "draw_region_expr": "Draw.rect(region, plan.drawx(), plan.drawy());", "draw_out_region_expr": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "draw_top_region_expr": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": region, "out_region": out_region, "top_region": top_region, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "plan_rotation": plan_rotation, "out_region_rotation": out_region_rotation, "draw_calls": draw_calls}

func java_method_setBars_2(_args: Array = []) -> Variant:
	var recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var entity_progress: float = float(_args[1] if _args.size() > 1 else 0.0)
	var recipe_build_time: float = float(_args[2] if _args.size() > 2 else 1.0)
	var progress_bar_fraction: float = 0.0 if recipe_null else entity_progress / recipe_build_time
	var progress_bar_call: Dictionary = {"call": "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "name": "progress", "bar_text": "bar.progress", "color": "Pal.ammo", "fraction": progress_bar_fraction}
	return {"source_owner": "PortGame.source_block_producer_set_bars_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void setBars(){", "super_set_bars_expr": "super.setBars();", "add_bar_expr": "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "bar_text": "bar.progress", "bar_color": "Pal.ammo", "bar_progress_expr": "entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)", "recipe_null": recipe_null, "entity_progress": entity_progress, "recipe_build_time": recipe_build_time, "super_set_bars_called": true, "progress_bar_added": true, "progress_bar_fraction": progress_bar_fraction, "progress_bar_call": progress_bar_call}

func java_inner_class_BlockProducerBuild_method_acceptItem_1(_args: Array = []) -> Variant:
	var source_building: Variant = _args[0] if _args.size() > 0 else null
	var item: Variant = _args[1] if _args.size() > 1 else null
	var item_count: int = int(_args[2] if _args.size() > 2 else 0)
	var maximum_accepted: int = int(_args[3] if _args.size() > 3 else 0)
	var accept_item: bool = item_count < maximum_accepted
	return {"source_owner": "PortGame.source_block_producer_build_accept_item_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean acceptItem(Building source, Item item){", "return_expr": "return items.get(item) < getMaximumAccepted(item);", "source_building": source_building, "item": item, "item_count": item_count, "maximum_accepted": maximum_accepted, "accept_item": accept_item}

func java_inner_class_BlockProducerBuild_method_getMaximumAccepted_2(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var recipe_null: bool = bool(_args[1] if _args.size() > 1 else true)
	var requirements: Array = []
	if _args.size() > 2 and _args[2] is Array:
		requirements = _args[2]
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
	return {"source_owner": "PortGame.source_block_producer_build_get_maximum_accepted_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public int getMaximumAccepted(Item item){", "null_guard": "if(recipe() == null) return 0;", "requirement_loop": "for(ItemStack stack : recipe().requirements){", "match_expr": "if(stack.item == item) return stack.amount * 2;", "final_return": "return 0;", "item": item, "recipe_null": recipe_null, "requirements": requirements, "matched_requirement": matched_requirement, "maximum_accepted": maximum_accepted}

func java_inner_class_BlockProducerBuild_method_acceptPayload_3(_args: Array = []) -> Variant:
	var source_building: Variant = _args[0] if _args.size() > 0 else null
	var payload: Variant = _args[1] if _args.size() > 1 else null
	var accept_payload: bool = false
	return {"source_owner": "PortGame.source_block_producer_build_accept_payload_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean acceptPayload(Building source, Payload payload){", "return_expr": "return false;", "source_building": source_building, "payload": payload, "accept_payload": accept_payload}

func java_inner_class_BlockProducerBuild_method_shouldConsume_4(_args: Array = []) -> Variant:
	var super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)
	var recipe_null: bool = bool(_args[1] if _args.size() > 1 else true)
	var should_consume: bool = super_should_consume and not recipe_null
	return {"source_owner": "PortGame.source_block_producer_build_should_consume_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean shouldConsume(){", "return_expr": "return super.shouldConsume() && recipe() != null;", "super_should_consume": super_should_consume, "recipe_null": recipe_null, "should_consume": should_consume}

func java_inner_class_BlockProducerBuild_method_updateTile_5(_args: Array = []) -> Variant:
	var recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var efficiency: float = float(_args[1] if _args.size() > 1 else 0.0)
	var payload_null: bool = bool(_args[2] if _args.size() > 2 else true)
	var produce: bool = not recipe_null and efficiency > 0.0 and payload_null
	return {"source_owner": "PortGame.source_block_producer_build_update_tile_produce_gate_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "super_call": "super.updateTile();", "recipe_assignment": "var recipe = recipe();", "produce_expr": "boolean produce = recipe != null && efficiency > 0 && payload == null;", "recipe_null": recipe_null, "efficiency": efficiency, "payload_null": payload_null, "produce": produce}

func java_inner_class_BlockProducerBuild_method_updateTile_progress_accumulation_5(_args: Array = []) -> Variant:
	var produce: bool = bool(_args[0] if _args.size() > 0 else false)
	var progress_before: float = float(_args[1] if _args.size() > 1 else 0.0)
	var build_speed: float = float(_args[2] if _args.size() > 2 else 0.0)
	var edelta: float = float(_args[3] if _args.size() > 3 else 0.0)
	var progress_delta: float = build_speed * edelta if produce else 0.0
	var progress_after: float = progress_before + progress_delta
	return {"source_owner": "PortGame.source_block_producer_build_update_tile_progress_accumulation_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "if_produce_expr": "if(produce){", "progress_expr": "progress += buildSpeed * edelta();", "produce": produce, "progress_before": progress_before, "build_speed": build_speed, "edelta": edelta, "progress_delta": progress_delta, "progress_after": progress_after}

func java_inner_class_BlockProducerBuild_method_updateTile_completion_guard_5(_args: Array = []) -> Variant:
	var progress: float = float(_args[0] if _args.size() > 0 else 0.0)
	var recipe_build_time: float = float(_args[1] if _args.size() > 1 else 0.0)
	var completion_guard: bool = progress >= recipe_build_time
	var consume_called: bool = completion_guard
	return {"source_owner": "PortGame.source_block_producer_build_update_tile_completion_guard_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "completion_guard_expr": "if(progress >= recipe.buildTime){", "consume_expr": "consume();", "progress": progress, "recipe_build_time": recipe_build_time, "completion_guard": completion_guard, "consume_called": consume_called}

func java_inner_class_BlockProducerBuild_method_updateTile_payload_creation_5(_args: Array = []) -> Variant:
	var completion_guard: bool = bool(_args[0] if _args.size() > 0 else false)
	var recipe: Variant = _args[1] if _args.size() > 1 else null
	var team: Variant = _args[2] if _args.size() > 2 else null
	var x: float = float(_args[3] if _args.size() > 3 else 0.0)
	var y: float = float(_args[4] if _args.size() > 4 else 0.0)
	var payload_size: float = float(_args[5] if _args.size() > 5 else 0.0)
	var tilesize: float = float(_args[6] if _args.size() > 6 else 1.0)
	var payload_after: Variant = null
	if completion_guard:
		payload_after = {"recipe": recipe, "team": team}
	var place_effect_called: bool = completion_guard
	var effect_radius: Variant = null
	if completion_guard:
		effect_radius = payload_size / tilesize
	return {"source_owner": "PortGame.source_block_producer_build_update_tile_payload_creation_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "payload_expr": "payload = new BuildPayload(recipe, team);", "place_effect_expr": "payload.block().placeEffect.at(x, y, payload.size() / tilesize);", "completion_guard": completion_guard, "recipe": recipe, "team": team, "x": x, "y": y, "payload_size": payload_size, "tilesize": tilesize, "payload_after": payload_after, "place_effect_called": place_effect_called, "effect_radius": effect_radius}
