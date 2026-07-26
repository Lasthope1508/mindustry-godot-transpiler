class_name SourceBlockQueryState
extends RefCounted

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


static func outputs_items_state(has_items: bool) -> Dictionary:
	return {"source_owner": "PortGame.source_block_outputs_items_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** If true, buildings have an ItemModule. */", "field_expr": "public @NoPatch boolean hasItems;", "method": "public boolean outputsItems(){", "return_expr": "return hasItems;", "has_items": has_items, "outputs_items": has_items}


static func can_place_on_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return {"source_owner": "PortGame.source_block_can_place_on_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be placed on the specified tile. */", "method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){", "return_expr": "return true;", "tile": tile, "team": team, "rotation": rotation_value, "can_place": true}


static func can_break_state(tile: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_block_can_break_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be broken on the specified tile. */", "method": "public boolean canBreak(Tile tile){", "return_expr": "return true;", "tile": tile, "can_break": true}


static func rotated_output_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return {"source_owner": "PortGame.source_block_rotated_output_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** whether this is rotatable */", "field_expr": "public boolean rotate;", "method": "public boolean rotatedOutput(int x, int y){", "return_expr": "return rotate;", "rotate": rotate_value, "x": x_value, "y": y_value, "rotated_output": rotate_value}


static func rotated_output_tile_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	var base_state := rotated_output_state(rotate_value, from_x, from_y)
	return {"source_owner": "PortGame.source_block_rotated_output_tile_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean rotatedOutput(int fromX, int fromY, Tile destination){", "delegate_call": "rotatedOutput(fromX, fromY)", "return_expr": "return rotatedOutput(fromX, fromY);", "rotate": rotate_value, "fromX": from_x, "fromY": from_y, "destination": destination, "base_state": base_state, "rotated_output": base_state["rotated_output"]}


static func synthetic_state(update_value: bool, destructible_value: bool) -> Dictionary:
	var synthetic_value: bool = update_value or destructible_value
	return {"source_owner": "PortGame.source_block_synthetic_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean synthetic(){", "return_expr": "return update || destructible;", "update": update_value, "destructible": destructible_value, "synthetic": synthetic_value}


static func check_force_dark_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_block_check_force_dark_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean checkForceDark(Tile tile){", "return_expr": "return forceDark;", "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}


static func is_darkened_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	var synthetic_state := synthetic_state(update_value, destructible_value)
	var check_force_dark_state := check_force_dark_state(force_dark_value, tile)
	var is_darkened_value: bool = solid_value and ((not bool(synthetic_state["synthetic"]) and fills_tile_value) or bool(check_force_dark_state["check_force_dark"]))
	return {"source_owner": "PortGame.source_block_is_darkened_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** If true, the 'map edge' darkness will be applied to this block. */", "method": "public boolean isDarkened(Tile tile){", "return_expr": "return solid && ((!synthetic() && fillsTile) || checkForceDark(tile));", "solid": solid_value, "fillsTile": fills_tile_value, "synthetic_state": synthetic_state, "check_force_dark_state": check_force_dark_state, "tile": tile, "is_darkened": is_darkened_value}


static func consumes_item_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	var consumes_item_value: bool = bool(item_filter[item_id])
	return {"source_owner": "PortGame.source_block_consumes_item_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesItem(Item item){", "return_expr": "return itemFilter[item.id];", "itemFilter": item_filter, "item_id": item_id, "item": item, "consumes_item": consumes_item_value}


static func consumes_liquid_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	var consumes_liquid_value: bool = bool(liquid_filter[liquid_id])
	return {"source_owner": "PortGame.source_block_consumes_liquid_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesLiquid(Liquid liq){", "return_expr": "return liquidFilter[liq.id];", "liquidFilter": liquid_filter, "liq_id": liquid_id, "liq": liq, "consumes_liquid": consumes_liquid_value}


static func has_building_state(destructible_value: bool, update_value: bool) -> Dictionary:
	var has_building_value: bool = destructible_value or update_value
	return {"source_owner": "PortGame.source_block_has_building_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasBuilding(){", "return_expr": "return destructible || update;", "destructible": destructible_value, "update": update_value, "has_building": has_building_value}


static func is_multiblock_state(size_value: int) -> Dictionary:
	var is_multiblock_value: bool = size_value > 1
	return {"source_owner": "PortGame.source_block_is_multiblock_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean isMultiblock(){", "return_expr": "return size > 1;", "size": size_value, "is_multiblock": is_multiblock_value}


static func is_air_state(id_value: int) -> Dictionary:
	var is_air_value: bool = id_value == 0
	return {"source_owner": "PortGame.source_block_is_air_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean isAir(){", "return_expr": "return id == 0;", "id": id_value, "is_air": is_air_value}


static func can_be_built_state(build_visibility_value: String) -> Dictionary:
	var can_be_built_value: bool = build_visibility_value != "hidden" and build_visibility_value != "debugOnly"
	return {"source_owner": "PortGame.source_block_can_be_built_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean canBeBuilt(){", "return_expr": "return buildVisibility != BuildVisibility.hidden && buildVisibility != BuildVisibility.debugOnly;", "buildVisibility": build_visibility_value, "hidden_constant": "BuildVisibility.hidden", "debug_only_constant": "BuildVisibility.debugOnly", "can_be_built": can_be_built_value}


static func is_static_state(cache_layer_value: String) -> Dictionary:
	var is_static_value: bool = cache_layer_value == "walls"
	return {"source_owner": "PortGame.source_block_is_static_state", "source": "core/src/mindustry/world/Block.java", "cache_layer_source": "core/src/mindustry/graphics/CacheLayer.java", "method": "public boolean isStatic(){", "return_expr": "return cacheLayer == CacheLayer.walls;", "cacheLayer": cache_layer_value, "walls_constant": "CacheLayer.walls", "is_static": is_static_value}


static func has_consumer_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_block_has_consumer_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasConsumer(Consume cons){", "return_expr": "return consumeBuilder.contains(cons);", "consumeBuilder_contains": consume_builder_contains, "cons": cons, "has_consumer": consume_builder_contains}


static func remove_consumer_state(consumers_length: int, cons: Variant) -> Dictionary:
	var illegal_state_exception_thrown: bool = consumers_length > 0
	var consume_builder_remove_called: bool = not illegal_state_exception_thrown
	return {"source_owner": "PortGame.source_block_remove_consumer_state", "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumer(Consume cons){", "guard_expr": "if(consumers.length > 0){", "exception_expr": "throw new IllegalStateException(\"You can only remove consumers before init(). After init(), all consumers have already been initialized.\");", "exception_message": "You can only remove consumers before init(). After init(), all consumers have already been initialized.", "remove_expr": "consumeBuilder.remove(cons);", "consumers_length": consumers_length, "cons": cons, "illegal_state_exception_thrown": illegal_state_exception_thrown, "consume_builder_remove_called": consume_builder_remove_called}


static func remove_consumers_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	var cons_power_cleared: bool = not consume_builder_contains_power_after_remove
	return {"source_owner": "PortGame.source_block_remove_consumers_state", "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumers(Boolf<Consume> b){", "remove_all_expr": "consumeBuilder.removeAll(b);", "comment": "//the power was removed, unassign it", "power_guard_expr": "if(!consumeBuilder.contains(c -> c instanceof ConsumePower)){", "cons_power_expr": "consPower = null;", "consumeBuilder_contains_power_after_remove": consume_builder_contains_power_after_remove, "b": b, "consume_builder_remove_all_called": true, "cons_power_cleared": cons_power_cleared}


static func generated_block_outputs_items_bridge_state(has_items: bool) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_outputsItems_17([has_items])
	var canonical = outputs_items_state(has_items)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_outputs_items_state", "generated_owner": "Block.java_method_outputsItems_17", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_can_place_on_bridge_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_canPlaceOn_18([tile, team, rotation_value])
	var canonical = can_place_on_state(tile, team, rotation_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_can_place_on_state", "generated_owner": "Block.java_method_canPlaceOn_18", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_can_break_bridge_state(tile: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_canBreak_19([tile])
	var canonical = can_break_state(tile)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_can_break_state", "generated_owner": "Block.java_method_canBreak_19", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_rotated_output_bridge_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_rotatedOutput_20([rotate_value, x_value, y_value])
	var canonical = rotated_output_state(rotate_value, x_value, y_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_rotated_output_state", "generated_owner": "Block.java_method_rotatedOutput_20", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_rotated_output_tile_bridge_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_rotatedOutput_21([rotate_value, from_x, from_y, destination])
	var canonical = rotated_output_tile_state(rotate_value, from_x, from_y, destination)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_rotated_output_tile_state", "generated_owner": "Block.java_method_rotatedOutput_21", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_synthetic_bridge_state(update_value: bool, destructible_value: bool) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_synthetic_22([update_value, destructible_value])
	var canonical = synthetic_state(update_value, destructible_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_synthetic_state", "generated_owner": "Block.java_method_synthetic_22", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_check_force_dark_bridge_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_checkForceDark_23([force_dark_value, tile])
	var canonical = check_force_dark_state(force_dark_value, tile)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_check_force_dark_state", "generated_owner": "Block.java_method_checkForceDark_23", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_is_darkened_bridge_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_isDarkened_24([solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile])
	var canonical = is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_is_darkened_state", "generated_owner": "Block.java_method_isDarkened_24", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_consumes_item_bridge_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_consumesItem_33([item_filter, item_id, item])
	var canonical = consumes_item_state(item_filter, item_id, item)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_consumes_item_state", "generated_owner": "Block.java_method_consumesItem_33", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_consumes_liquid_bridge_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_consumesLiquid_34([liquid_filter, liquid_id, liq])
	var canonical = consumes_liquid_state(liquid_filter, liquid_id, liq)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_consumes_liquid_state", "generated_owner": "Block.java_method_consumesLiquid_34", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_has_building_bridge_state(destructible_value: bool, update_value: bool) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_hasBuilding_70([destructible_value, update_value])
	var canonical = has_building_state(destructible_value, update_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_has_building_state", "generated_owner": "Block.java_method_hasBuilding_70", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_is_multiblock_bridge_state(size_value: int) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_isMultiblock_74([size_value])
	var canonical = is_multiblock_state(size_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_is_multiblock_state", "generated_owner": "Block.java_method_isMultiblock_74", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_is_air_bridge_state(id_value: int) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_isAir_91([id_value])
	var canonical = is_air_state(id_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_is_air_state", "generated_owner": "Block.java_method_isAir_91", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_can_be_built_bridge_state(build_visibility_value: String) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_canBeBuilt_92([build_visibility_value])
	var canonical = can_be_built_state(build_visibility_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_can_be_built_state", "generated_owner": "Block.java_method_canBeBuilt_92", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_is_static_bridge_state(cache_layer_value: String) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_isStatic_94([cache_layer_value])
	var canonical = is_static_state(cache_layer_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_is_static_state", "generated_owner": "Block.java_method_isStatic_94", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_has_consumer_bridge_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_hasConsumer_96([consume_builder_contains, cons])
	var canonical = has_consumer_state(consume_builder_contains, cons)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_has_consumer_state", "generated_owner": "Block.java_method_hasConsumer_96", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_remove_consumer_bridge_state(consumers_length: int, cons: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_removeConsumer_97([consumers_length, cons])
	var canonical = remove_consumer_state(consumers_length, cons)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": "PortGame.source_block_remove_consumer_state", "generated_owner": "Block.java_method_removeConsumer_97", "result": result, "canonical": canonical, "matches": matches}


static func generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/Block.gd")
	var instance = script.new()
	var result = instance.java_method_removeConsumers_98([consume_builder_contains_power_after_remove, b])
	var block_remove_consumers_result = result
	var canonical = remove_consumers_state(consume_builder_contains_power_after_remove, b)
	var matches: bool = generated_state_matches_generated_subset(block_remove_consumers_result, canonical)
	return {"source_owner": "PortGame.source_block_remove_consumers_state", "generated_owner": "Block.java_method_removeConsumers_98", "result": result, "canonical": canonical, "matches": matches}
