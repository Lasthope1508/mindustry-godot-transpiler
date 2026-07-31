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
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_FACTORY_HEAT_LERP_PROGRESS := source_factory_defaults.HEAT_LERP_PROGRESS
const SOURCE_TILESIZE := source_world_defaults.TILESIZE
const SOURCE_PAYLOAD_ARRIVAL_EPSILON := source_world_defaults.PAYLOAD_ARRIVAL_EPSILON

func java_method_icons_0(_args: Array = []) -> Variant:
	var region: Variant = _args[0] if _args.size() > 0 else null
	var out_region: Variant = _args[1] if _args.size() > 1 else null
	var top_region: Variant = _args[2] if _args.size() > 2 else null
	var icons: Array = [region, out_region, top_region]
	return {"source_owner": "port_game.source_block_producer_icons_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public TextureRegion[] icons(){", "return_expr": "return new TextureRegion[]{region, outRegion, topRegion};", "region": region, "out_region": out_region, "top_region": top_region, "icons": icons}

func java_method_drawPlanRegion_1(_args: Array = []) -> Variant:
	var region: Variant = _args[0] if _args.size() > 0 else null
	var out_region: Variant = _args[1] if _args.size() > 1 else null
	var top_region: Variant = _args[2] if _args.size() > 2 else null
	var plan_drawx: float = float(_args[3] if _args.size() > 3 else 0.0)
	var plan_drawy: float = float(_args[4] if _args.size() > 4 else 0.0)
	var plan_rotation: float = float(_args[5] if _args.size() > 5 else 0.0)
	var out_region_rotation: float = plan_rotation * 90.0
	var draw_calls: Array = [{"call": "Draw.rect(region, plan.drawx(), plan.drawy());", "region": region, "x": plan_drawx, "y": plan_drawy}, {"call": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "region": out_region, "x": plan_drawx, "y": plan_drawy, "rotation": out_region_rotation}, {"call": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": top_region, "x": plan_drawx, "y": plan_drawy}]
	return {"source_owner": "port_game.source_block_producer_draw_plan_region_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "draw_region_expr": "Draw.rect(region, plan.drawx(), plan.drawy());", "draw_out_region_expr": "Draw.rect(outRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);", "draw_top_region_expr": "Draw.rect(topRegion, plan.drawx(), plan.drawy());", "region": region, "out_region": out_region, "top_region": top_region, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "plan_rotation": plan_rotation, "out_region_rotation": out_region_rotation, "draw_calls": draw_calls}

func java_method_setBars_2(_args: Array = []) -> Variant:
	var recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var entity_progress: float = float(_args[1] if _args.size() > 1 else 0.0)
	var recipe_build_time: float = float(_args[2] if _args.size() > 2 else 1.0)
	var progress_bar_fraction: float = 0.0 if recipe_null else entity_progress / recipe_build_time
	var progress_bar_call: Dictionary = {"call": "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "name": "progress", "bar_text": "bar.progress", "color": "Pal.ammo", "fraction": progress_bar_fraction}
	return {"source_owner": "port_game.source_block_producer_set_bars_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "class_expr": "public abstract class BlockProducer extends PayloadBlock{", "override_expr": "@Override", "method": "public void setBars(){", "super_set_bars_expr": "super.setBars();", "add_bar_expr": "addBar(\"progress\", (BlockProducerBuild entity) -> new Bar(\"bar.progress\", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));", "bar_text": "bar.progress", "bar_color": "Pal.ammo", "bar_progress_expr": "entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)", "recipe_null": recipe_null, "entity_progress": entity_progress, "recipe_build_time": recipe_build_time, "super_set_bars_called": true, "progress_bar_added": true, "progress_bar_fraction": progress_bar_fraction, "progress_bar_call": progress_bar_call}

func java_inner_class_BlockProducerBuild_method_acceptItem_1(_args: Array = []) -> Variant:
	var source_building: Variant = _args[0] if _args.size() > 0 else null
	var item: Variant = _args[1] if _args.size() > 1 else null
	var item_count: int = int(_args[2] if _args.size() > 2 else 0)
	var maximum_accepted: int = int(_args[3] if _args.size() > 3 else 0)
	var accept_item: bool = item_count < maximum_accepted
	return {"source_owner": "port_game.source_block_producer_build_accept_item_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean acceptItem(Building source, Item item){", "return_expr": "return items.get(item) < getMaximumAccepted(item);", "source_building": source_building, "item": item, "item_count": item_count, "maximum_accepted": maximum_accepted, "accept_item": accept_item}

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
	return {"source_owner": "port_game.source_block_producer_build_get_maximum_accepted_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public int getMaximumAccepted(Item item){", "null_guard": "if(recipe() == null) return 0;", "requirement_loop": "for(ItemStack stack : recipe().requirements){", "match_expr": "if(stack.item == item) return stack.amount * 2;", "final_return": "return 0;", "item": item, "recipe_null": recipe_null, "requirements": requirements, "matched_requirement": matched_requirement, "maximum_accepted": maximum_accepted}

func java_inner_class_BlockProducerBuild_method_acceptPayload_3(_args: Array = []) -> Variant:
	var source_building: Variant = _args[0] if _args.size() > 0 else null
	var payload: Variant = _args[1] if _args.size() > 1 else null
	var accept_payload: bool = false
	return {"source_owner": "port_game.source_block_producer_build_accept_payload_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean acceptPayload(Building source, Payload payload){", "return_expr": "return false;", "source_building": source_building, "payload": payload, "accept_payload": accept_payload}

func java_inner_class_BlockProducerBuild_method_shouldConsume_4(_args: Array = []) -> Variant:
	var super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)
	var recipe_null: bool = bool(_args[1] if _args.size() > 1 else true)
	var should_consume: bool = super_should_consume and not recipe_null
	return {"source_owner": "port_game.source_block_producer_build_should_consume_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public boolean shouldConsume(){", "return_expr": "return super.shouldConsume() && recipe() != null;", "super_should_consume": super_should_consume, "recipe_null": recipe_null, "should_consume": should_consume}

func java_inner_class_BlockProducerBuild_method_updateTile_5(_args: Array = []) -> Variant:
	var recipe_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var efficiency: float = float(_args[1] if _args.size() > 1 else 0.0)
	var payload_null: bool = bool(_args[2] if _args.size() > 2 else true)
	var produce: bool = not recipe_null and efficiency > 0.0 and payload_null
	return {"source_owner": "port_game.source_block_producer_build_update_tile_produce_gate_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "super_call": "super.updateTile();", "recipe_assignment": "var recipe = recipe();", "produce_expr": "boolean produce = recipe != null && efficiency > 0 && payload == null;", "recipe_null": recipe_null, "efficiency": efficiency, "payload_null": payload_null, "produce": produce}

func java_inner_class_BlockProducerBuild_method_updateTile_progress_accumulation_5(_args: Array = []) -> Variant:
	var produce: bool = bool(_args[0] if _args.size() > 0 else false)
	var progress_before: float = float(_args[1] if _args.size() > 1 else 0.0)
	var build_speed: float = float(_args[2] if _args.size() > 2 else 0.0)
	var edelta: float = float(_args[3] if _args.size() > 3 else 0.0)
	var progress_delta: float = build_speed * edelta if produce else 0.0
	var progress_after: float = progress_before + progress_delta
	return {"source_owner": "port_game.source_block_producer_build_update_tile_progress_accumulation_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "if_produce_expr": "if(produce){", "progress_expr": "progress += buildSpeed * edelta();", "produce": produce, "progress_before": progress_before, "build_speed": build_speed, "edelta": edelta, "progress_delta": progress_delta, "progress_after": progress_after}

func java_inner_class_BlockProducerBuild_method_updateTile_completion_guard_5(_args: Array = []) -> Variant:
	var progress: float = float(_args[0] if _args.size() > 0 else 0.0)
	var recipe_build_time: float = float(_args[1] if _args.size() > 1 else 0.0)
	var completion_guard: bool = progress >= recipe_build_time
	var consume_called: bool = completion_guard
	return {"source_owner": "port_game.source_block_producer_build_update_tile_completion_guard_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "completion_guard_expr": "if(progress >= recipe.buildTime){", "consume_expr": "consume();", "progress": progress, "recipe_build_time": recipe_build_time, "completion_guard": completion_guard, "consume_called": consume_called}

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
	return {"source_owner": "port_game.source_block_producer_build_update_tile_payload_creation_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "payload_expr": "payload = new BuildPayload(recipe, team);", "place_effect_expr": "payload.block().placeEffect.at(x, y, payload.size() / tilesize);", "completion_guard": completion_guard, "recipe": recipe, "team": team, "x": x, "y": y, "payload_size": payload_size, "tilesize": tilesize, "payload_after": payload_after, "place_effect_called": place_effect_called, "effect_radius": effect_radius}

func java_inner_class_BlockProducerBuild_method_updateTile_pay_vector_progress_reset_5(_args: Array = []) -> Variant:
	var completion_guard: bool = bool(_args[0] if _args.size() > 0 else false)
	var pay_vector_x: float = float(_args[1] if _args.size() > 1 else 0.0)
	var pay_vector_y: float = float(_args[2] if _args.size() > 2 else 0.0)
	var progress_before: float = float(_args[3] if _args.size() > 3 else 0.0)
	var pay_vector_after: Dictionary = {"x": pay_vector_x, "y": pay_vector_y}
	var progress_after: float = progress_before
	if completion_guard:
		pay_vector_after = {"x": 0.0, "y": 0.0}
		progress_after = fmod(progress_before, 1.0)
	return {"source_owner": "port_game.source_block_producer_build_update_tile_pay_vector_progress_reset_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "parent_source": "core/src/mindustry/world/blocks/payloads/PayloadBlock.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "completion_guard_expr": "if(progress >= recipe.buildTime){", "pay_vector_field": "public Vec2 payVector = new Vec2();", "progress_field": "public float progress, time, heat;", "pay_vector_set_zero_expr": "payVector.setZero();", "progress_modulo_expr": "progress %= 1f;", "completion_guard": completion_guard, "pay_vector_x": pay_vector_x, "pay_vector_y": pay_vector_y, "progress_before": progress_before, "pay_vector_after": pay_vector_after, "progress_after": progress_after}

func java_inner_class_BlockProducerBuild_method_updateTile_heat_time_5(_args: Array = []) -> Variant:
	var produce: bool = bool(_args[0] if _args.size() > 0 else false)
	var heat_before: float = float(_args[1] if _args.size() > 1 else 0.0)
	var time_before: float = float(_args[2] if _args.size() > 2 else 0.0)
	var time_delta: float = float(_args[3] if _args.size() > 3 else 0.0)
	var produce_num: float = 1.0 if produce else 0.0
	var heat_after: float = heat_before + (produce_num - heat_before) * clampf(SOURCE_FACTORY_HEAT_LERP_PROGRESS * time_delta, 0.0, 1.0)
	var time_after: float = time_before + heat_after * time_delta
	return {"source_owner": "port_game.source_block_producer_build_update_tile_heat_time_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "arc_source": "arc-core/src/arc/math/Mathf.java", "building_source": "core/src/mindustry/entities/comp/BuildingComp.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "method": "public void updateTile(){", "field_expr": "public float progress, time, heat;", "heat_expr": "heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);", "time_expr": "time += heat * delta();", "mathf_num_method": "public static int num(boolean b){", "mathf_lerp_delta_method": "public static float lerpDelta(float fromValue, float toValue, float progress){\n        return lerp(fromValue, toValue, clamp(progress * Time.delta));\n    }", "building_delta_method": "public float delta(){", "produce": produce, "produce_num": produce_num, "heat_before": heat_before, "time_before": time_before, "time_delta": time_delta, "heat_after": heat_after, "time_after": time_after}

func java_inner_class_BlockProducerBuild_method_updateTile_move_out_payload_5(_args: Array = []) -> Variant:
	var payload_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var pay_vector_x: float = float(_args[1] if _args.size() > 1 else 0.0)
	var pay_vector_y: float = float(_args[2] if _args.size() > 2 else 0.0)
	var pay_rotation_before: float = float(_args[3] if _args.size() > 3 else 0.0)
	var rotdeg_value: float = float(_args[4] if _args.size() > 4 else 0.0)
	var size_value: float = float(_args[5] if _args.size() > 5 else 0.0)
	var tilesize: float = float(_args[6] if _args.size() > 6 else SOURCE_TILESIZE)
	var payload_rotate_speed: float = float(_args[7] if _args.size() > 7 else 0.0)
	var payload_speed: float = float(_args[8] if _args.size() > 8 else 0.0)
	var time_delta: float = float(_args[9] if _args.size() > 9 else 0.0)
	var front_present: bool = bool(_args[10] if _args.size() > 10 else false)
	var front_solid: bool = bool(_args[11] if _args.size() > 11 else false)
	var front_outputs_payload: bool = bool(_args[12] if _args.size() > 12 else false)
	var front_accepts_payload: bool = bool(_args[13] if _args.size() > 13 else false)
	var move_payload_result: bool = bool(_args[14] if _args.size() > 14 else false)
	var half_extent: float = size_value * tilesize / 2.0
	var dest: Variant = null
	var pay_vector_after: Dictionary = {"x": pay_vector_x, "y": pay_vector_y}
	var pay_rotation_after: float = pay_rotation_before
	var update_payload_called: bool = false
	var can_dump: bool = false
	var can_move: bool = false
	var distance_to_dest: float = 0.0
	var distance_to_dest2: float = 0.0
	var pushed_output_fraction: Variant = null
	var arrived: bool = false
	var move_payload_called: bool = false
	var dump_payload_called: bool = false
	var payload_after_present: bool = payload_present
	if payload_present:
		update_payload_called = true
		var radians: float = deg_to_rad(rotdeg_value)
		dest = {"x": half_extent * cos(radians), "y": half_extent * sin(radians)}
		var rotation_speed: float = payload_rotate_speed * time_delta
		var angle_a: float = fmod(fmod(pay_rotation_before, 360.0) + 360.0, 360.0)
		var angle_b: float = fmod(fmod(rotdeg_value, 360.0) + 360.0, 360.0)
		var forward_angle_dist: float = angle_a - angle_b + 360.0 if (angle_a - angle_b) < 0.0 else angle_a - angle_b
		var backward_angle_dist: float = angle_b - angle_a + 360.0 if (angle_b - angle_a) < 0.0 else angle_b - angle_a
		var angle_distance: float = min(forward_angle_dist, backward_angle_dist)
		if abs(angle_distance) < rotation_speed:
			pay_rotation_after = rotdeg_value
		else:
			var angle_mod: float = fmod(fmod(pay_rotation_before, 360.0) + 360.0, 360.0)
			var to_mod: float = fmod(fmod(rotdeg_value, 360.0) + 360.0, 360.0)
			if (angle_mod > to_mod) == ((360.0 - abs(angle_mod - to_mod)) > abs(angle_mod - to_mod)):
				pay_rotation_after = angle_mod - rotation_speed
			else:
				pay_rotation_after = angle_mod + rotation_speed
		var target_x: float = float(dest.get("x", 0.0))
		var target_y: float = float(dest.get("y", 0.0))
		var dx_approach: float = pay_vector_x - target_x
		var dy_approach: float = pay_vector_y - target_y
		var approach_alpha: float = payload_speed * time_delta
		var approach_alpha2: float = approach_alpha * approach_alpha
		var approach_len2: float = dx_approach * dx_approach + dy_approach * dy_approach
		if approach_len2 > approach_alpha2:
			var scl: float = sqrt(approach_alpha2 / approach_len2)
			pay_vector_after = {"x": pay_vector_x - dx_approach * scl, "y": pay_vector_y - dy_approach * scl}
		else:
			pay_vector_after = {"x": target_x, "y": target_y}
		can_dump = (not front_present) or (not front_solid)
		can_move = front_present and (front_outputs_payload or front_accepts_payload)
		var dx: float = target_x - float(pay_vector_after.get("x", 0.0))
		var dy: float = target_y - float(pay_vector_after.get("y", 0.0))
		distance_to_dest2 = dx * dx + dy * dy
		distance_to_dest = sqrt(distance_to_dest2)
		if can_dump and not can_move:
			pushed_output_fraction = 1.0 - (distance_to_dest / half_extent)
		arrived = distance_to_dest2 < SOURCE_PAYLOAD_ARRIVAL_EPSILON * SOURCE_PAYLOAD_ARRIVAL_EPSILON
		if arrived:
			pay_vector_after = {"x": clampf(float(pay_vector_after.get("x", 0.0)), -half_extent, half_extent), "y": clampf(float(pay_vector_after.get("y", 0.0)), -half_extent, half_extent)}
			if can_move:
				move_payload_called = true
				payload_after_present = not move_payload_result
			elif can_dump:
				dump_payload_called = true
	return {"source_owner": "port_game.source_block_producer_build_update_tile_move_out_payload_state", "source": "core/src/mindustry/world/blocks/payloads/BlockProducer.java", "parent_source": "core/src/mindustry/world/blocks/payloads/PayloadBlock.java", "arc_source": "arc-core/src/arc/math/Angles.java; arc-core/src/arc/math/geom/Vec2.java; arc-core/src/arc/math/geom/Position.java", "inner_class": "public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{", "override_expr": "@Override", "update_tile_method": "public void updateTile(){", "move_out_payload_expr": "moveOutPayload();", "method": "public void moveOutPayload(){", "payload_null_guard": "if(payload == null) return;", "update_payload_expr": "updatePayload();", "dest_expr": "Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);", "pay_rotation_expr": "payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());", "pay_vector_expr": "payVector.approach(dest, payloadSpeed * delta());", "front_expr": "Building front = front();", "can_dump_expr": "boolean canDump = front == null || !front.tile.solid();", "can_move_expr": "boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);", "push_output_expr": "pushOutput(payload, 1f - (payVector.dst(dest) / (size * tilesize / 2f)));", "arrived_guard": "if(payVector.within(dest, 0.001f)){", "clamp_expr": "payVector.clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);", "move_payload_expr": "if(movePayload(payload)){", "payload_clear_expr": "payload = null;", "dump_payload_expr": "dumpPayload();", "payload_present": payload_present, "pay_vector_x": pay_vector_x, "pay_vector_y": pay_vector_y, "pay_rotation_before": pay_rotation_before, "rotdeg_value": rotdeg_value, "size_value": size_value, "tilesize": tilesize, "payload_rotate_speed": payload_rotate_speed, "payload_speed": payload_speed, "time_delta": time_delta, "front_present": front_present, "front_solid": front_solid, "front_outputs_payload": front_outputs_payload, "front_accepts_payload": front_accepts_payload, "move_payload_result": move_payload_result, "half_extent": half_extent, "dest": dest, "update_payload_called": update_payload_called, "pay_rotation_after": pay_rotation_after, "pay_vector_after": pay_vector_after, "can_dump": can_dump, "can_move": can_move, "distance_to_dest": distance_to_dest, "distance_to_dest2": distance_to_dest2, "pushed_output_fraction": pushed_output_fraction, "arrived": arrived, "move_payload_called": move_payload_called, "dump_payload_called": dump_payload_called, "payload_after_present": payload_after_present}
