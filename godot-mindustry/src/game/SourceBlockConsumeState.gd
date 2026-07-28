extends RefCounted
class_name SourceBlockConsumeState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func _matches_subset(result: Variant, canonical: Variant) -> bool:
	if result is Dictionary and canonical is Dictionary:
		for key in canonical.keys():
			if not result.has(key):
				return false
			if not _matches_subset(result.get(key), canonical.get(key)):
				return false
		return true
	if result is Array and canonical is Array:
		if result.size() != canonical.size():
			return false
		for index in range(canonical.size()):
			if not _matches_subset(result[index], canonical[index]):
				return false
		return true
	return result == canonical

static func consume_liquid_state(liquid: Variant, amount: float) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumeLiquid", "liquid": liquid, "amount": amount}
	return {"source_owner": "PortGame.source_block_consume_liquid_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeLiquid consumeLiquid(Liquid liquid, float amount){", "return_expr": "return consume(new ConsumeLiquid(liquid, amount));", "constructor_expr": "new ConsumeLiquid(liquid, amount)", "consume_call_expr": "consume(new ConsumeLiquid(liquid, amount))", "liquid": liquid, "amount": amount, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_liquids_state(stacks: Variant) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumeLiquids", "stacks": stacks}
	return {"source_owner": "PortGame.source_block_consume_liquids_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeLiquids consumeLiquids(LiquidStack... stacks){", "return_expr": "return consume(new ConsumeLiquids(stacks));", "constructor_expr": "new ConsumeLiquids(stacks)", "consume_call_expr": "consume(new ConsumeLiquids(stacks))", "stacks": stacks, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_power_state(power_per_tick: float) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumePower", "powerPerTick": power_per_tick, "capacity": 0.0, "buffered": false}
	return {"source_owner": "PortGame.source_block_consume_power_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which directly uses power without buffering it.", "param": "@param powerPerTick The amount of power which is required each tick for 100% efficiency.", "method": "public ConsumePower consumePower(float powerPerTick){", "return_expr": "return consume(new ConsumePower(powerPerTick, 0.0f, false));", "constructor_expr": "new ConsumePower(powerPerTick, 0.0f, false)", "consume_call_expr": "consume(new ConsumePower(powerPerTick, 0.0f, false))", "powerPerTick": power_per_tick, "capacity": 0.0, "buffered": false, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_power_cond_state(usage: float, cons: Variant) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumePowerCondition", "usage": usage, "condition": cons}
	return {"source_owner": "PortGame.source_block_consume_power_cond_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which only consumes power when the condition is met.", "method": "public <T extends Building> ConsumePower consumePowerCond(float usage, Boolf<T> cons){", "return_expr": "return consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons));", "constructor_expr": "new ConsumePowerCondition(usage, (Boolf<Building>)cons)", "condition_cast_expr": "(Boolf<Building>)cons", "consume_call_expr": "consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons))", "usage": usage, "condition": cons, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_power_dynamic_state(usage: Variant) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumePowerDynamic", "usage": usage}
	return {"source_owner": "PortGame.source_block_consume_power_dynamic_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer that consumes a dynamic amount of power.", "method": "public <T extends Building> ConsumePower consumePowerDynamic(Floatf<T> usage){", "return_expr": "return consume(new ConsumePowerDynamic((Floatf<Building>)usage));", "constructor_expr": "new ConsumePowerDynamic((Floatf<Building>)usage)", "usage_cast_expr": "(Floatf<Building>)usage", "consume_call_expr": "consume(new ConsumePowerDynamic((Floatf<Building>)usage))", "usage": usage, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_power_dynamic_displayed_state(displayed: float, usage: Variant) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumePowerDynamic", "displayed": displayed, "usage": usage}
	return {"source_owner": "PortGame.source_block_consume_power_dynamic_displayed_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer that consumes a dynamic amount of power.", "method": "public <T extends Building> ConsumePower consumePowerDynamic(float displayed, Floatf<T> usage){", "return_expr": "return consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage));", "constructor_expr": "new ConsumePowerDynamic(displayed, (Floatf<Building>)usage)", "usage_cast_expr": "(Floatf<Building>)usage", "consume_call_expr": "consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage))", "displayed": displayed, "usage": usage, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_power_buffered_state(power_capacity: float) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumePower", "powerPerTick": 0.0, "capacity": power_capacity, "buffered": true}
	return {"source_owner": "PortGame.source_block_consume_power_buffered_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which stores power.", "param": "@param powerCapacity The maximum capacity in power units.", "method": "public ConsumePower consumePowerBuffered(float powerCapacity){", "return_expr": "return consume(new ConsumePower(0f, powerCapacity, true));", "constructor_expr": "new ConsumePower(0f, powerCapacity, true)", "consume_call_expr": "consume(new ConsumePower(0f, powerCapacity, true))", "powerCapacity": power_capacity, "powerPerTick": 0.0, "buffered": true, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_item_single_state(item: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_block_consume_item_single_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItem(Item item){", "return_expr": "return consumeItem(item, 1);", "delegate_call_expr": "consumeItem(item, 1)", "item": item, "amount": 1, "delegate_called": true}

static func consume_item_amount_state(item: Variant, amount: int) -> Dictionary:
	var item_stack: Dictionary = {"type": "ItemStack", "item": item, "amount": amount}
	var constructed_consume: Dictionary = {"type": "ConsumeItems", "items": [item_stack]}
	return {"source_owner": "PortGame.source_block_consume_item_amount_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItem(Item item, int amount){", "return_expr": "return consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}));", "item_stack_expr": "new ItemStack(item, amount)", "item_stack_array_expr": "new ItemStack[]{new ItemStack(item, amount)}", "constructor_expr": "new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)})", "consume_call_expr": "consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}))", "item": item, "amount": amount, "item_stack": item_stack, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_items_varargs_state(items: Array) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumeItems", "items": items}
	return {"source_owner": "PortGame.source_block_consume_items_varargs_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItems(ItemStack... items){", "return_expr": "return consume(new ConsumeItems(items));", "constructor_expr": "new ConsumeItems(items)", "consume_call_expr": "consume(new ConsumeItems(items))", "items": items, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_coolant_single_state(amount: float) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumeCoolant", "amount": amount}
	return {"source_owner": "PortGame.source_block_consume_coolant_single_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeCoolant consumeCoolant(float amount){", "return_expr": "return consume(new ConsumeCoolant(amount));", "constructor_expr": "new ConsumeCoolant(amount)", "consume_call_expr": "consume(new ConsumeCoolant(amount))", "amount": amount, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_coolant_filtered_state(amount: float, allow_liquid: bool, allow_gas: bool) -> Dictionary:
	var constructed_consume: Dictionary = {"type": "ConsumeCoolant", "amount": amount, "allowLiquid": allow_liquid, "allowGas": allow_gas}
	return {"source_owner": "PortGame.source_block_consume_coolant_filtered_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeCoolant consumeCoolant(float amount, boolean allowLiquid, boolean allowGas){", "return_expr": "return consume(new ConsumeCoolant(amount, allowLiquid, allowGas));", "constructor_expr": "new ConsumeCoolant(amount, allowLiquid, allowGas)", "consume_call_expr": "consume(new ConsumeCoolant(amount, allowLiquid, allowGas))", "amount": amount, "allowLiquid": allow_liquid, "allowGas": allow_gas, "constructed_consume": constructed_consume, "consume_called": true}

static func consume_generic_state(consume: Variant, consume_is_power: bool, consume_builder_before: Array, consume_builder_without_power: Array, cons_power_before: Variant) -> Dictionary:
	var remove_power_called: bool = consume_is_power
	var consume_builder_after: Array = consume_builder_without_power.duplicate() if consume_is_power else consume_builder_before.duplicate()
	consume_builder_after.append(consume)
	var cons_power_after: Variant = consume if consume_is_power else cons_power_before
	return {"source_owner": "PortGame.source_block_consume_generic_state", "source": "core/src/mindustry/world/Block.java", "method": "public <T extends Consume> T consume(T consume){", "power_guard_expr": "if(consume instanceof ConsumePower){", "comment": "//there can only be one power consumer", "remove_power_expr": "consumeBuilder.removeAll(b -> b instanceof ConsumePower);", "cons_power_expr": "consPower = (ConsumePower)consume;", "add_expr": "consumeBuilder.add(consume);", "return_expr": "return consume;", "consume": consume, "consume_is_power": consume_is_power, "consume_builder_before": consume_builder_before, "consume_builder_without_power": consume_builder_without_power, "consume_builder_after": consume_builder_after, "cons_power_before": cons_power_before, "cons_power_after": cons_power_after, "remove_power_called": remove_power_called, "add_called": true, "returned_consume": consume}

static func generated_block_consume_liquid_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeLiquid_99", [liquid, amount], null)
	var canonical = consume_liquid_state(liquid, amount)
	return {"source_owner": "PortGame.source_block_consume_liquid_state", "generated_owner": "Block.java_method_consumeLiquid_99", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_liquids_bridge_state(stacks: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeLiquids_100", [stacks], null)
	var canonical = consume_liquids_state(stacks)
	return {"source_owner": "PortGame.source_block_consume_liquids_state", "generated_owner": "Block.java_method_consumeLiquids_100", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_power_bridge_state(power_per_tick: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumePower_101", [power_per_tick], null)
	var canonical = consume_power_state(power_per_tick)
	return {"source_owner": "PortGame.source_block_consume_power_state", "generated_owner": "Block.java_method_consumePower_101", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_power_cond_bridge_state(usage: float, cons: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumePowerCond_102", [usage, cons], null)
	var canonical = consume_power_cond_state(usage, cons)
	return {"source_owner": "PortGame.source_block_consume_power_cond_state", "generated_owner": "Block.java_method_consumePowerCond_102", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_power_dynamic_bridge_state(usage: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumePowerDynamic_103", [usage], null)
	var canonical = consume_power_dynamic_state(usage)
	return {"source_owner": "PortGame.source_block_consume_power_dynamic_state", "generated_owner": "Block.java_method_consumePowerDynamic_103", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_power_dynamic_displayed_bridge_state(displayed: float, usage: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumePowerDynamic_104", [displayed, usage], null)
	var canonical = consume_power_dynamic_displayed_state(displayed, usage)
	return {"source_owner": "PortGame.source_block_consume_power_dynamic_displayed_state", "generated_owner": "Block.java_method_consumePowerDynamic_104", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_power_buffered_bridge_state(power_capacity: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumePowerBuffered_105", [power_capacity], null)
	var canonical = consume_power_buffered_state(power_capacity)
	return {"source_owner": "PortGame.source_block_consume_power_buffered_state", "generated_owner": "Block.java_method_consumePowerBuffered_105", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_item_single_bridge_state(item: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeItem_106", [item], null)
	var canonical = consume_item_single_state(item)
	return {"source_owner": "PortGame.source_block_consume_item_single_state", "generated_owner": "Block.java_method_consumeItem_106", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_item_amount_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeItem_107", [item, amount], null)
	var canonical = consume_item_amount_state(item, amount)
	return {"source_owner": "PortGame.source_block_consume_item_amount_state", "generated_owner": "Block.java_method_consumeItem_107", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_items_varargs_bridge_state(items: Array) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeItems_108", items, null)
	var canonical = consume_items_varargs_state(items)
	return {"source_owner": "PortGame.source_block_consume_items_varargs_state", "generated_owner": "Block.java_method_consumeItems_108", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_coolant_single_bridge_state(amount: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeCoolant_109", [amount], null)
	var canonical = consume_coolant_single_state(amount)
	return {"source_owner": "PortGame.source_block_consume_coolant_single_state", "generated_owner": "Block.java_method_consumeCoolant_109", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_coolant_filtered_bridge_state(amount: float, allow_liquid: bool, allow_gas: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumeCoolant_110", [amount, allow_liquid, allow_gas], null)
	var canonical = consume_coolant_filtered_state(amount, allow_liquid, allow_gas)
	return {"source_owner": "PortGame.source_block_consume_coolant_filtered_state", "generated_owner": "Block.java_method_consumeCoolant_110", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}

static func generated_block_consume_generic_bridge_state(consume: Variant, consume_is_power: bool, consume_builder_before: Array, consume_builder_without_power: Array, cons_power_before: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consume_111", [consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before], null)
	var canonical = consume_generic_state(consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before)
	return {"source_owner": "PortGame.source_block_consume_generic_state", "generated_owner": "Block.java_method_consume_111", "result": result, "canonical": canonical, "matches": _matches_subset(result, canonical)}
