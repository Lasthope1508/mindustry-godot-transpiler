extends RefCounted
class_name SourceBlockReinitializeConsumersState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func arrays_state(consume_builder: Array) -> Dictionary:
	var consumers: Array = consume_builder.duplicate()
	var cons_power: Variant = null
	var optional_consumers: Array = []
	var non_optional_consumers: Array = []
	var update_consumers: Array = []
	for consumer in consume_builder:
		if not consumer is Dictionary:
			continue
		var ignored: bool = bool(consumer.get("ignored", false))
		if cons_power == null and bool(consumer.get("is_consume_power", false)):
			cons_power = consumer
		if bool(consumer.get("optional", false)) and not ignored:
			optional_consumers.append(consumer)
		if not bool(consumer.get("optional", false)) and not ignored:
			non_optional_consumers.append(consumer)
		if bool(consumer.get("update", true)) and not ignored:
			update_consumers.append(consumer)
	var has_consumers: bool = consumers.size() > 0
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_ARRAYS_STATE, "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void reinitializeConsumers(){", "consumers_expr": "consumers = consumeBuilder.toArray(Consume.class);", "cons_power_expr": "consPower = (ConsumePower)Structs.find(consumers, c -> c instanceof ConsumePower);", "optional_consumers_expr": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);", "non_optional_consumers_expr": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);", "update_consumers_expr": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);", "has_consumers_expr": "hasConsumers = consumers.length > 0;", "consume_optional_field_expr": "public boolean optional;", "consume_update_field_expr": "public boolean update = true;", "consume_ignore_method_expr": "public boolean ignore(){", "consume_is_power_expr": "c instanceof ConsumePower", "consume_builder": consume_builder, "consumers": consumers, "cons_power": cons_power, "optional_consumers": optional_consumers, "non_optional_consumers": non_optional_consumers, "update_consumers": update_consumers, "has_consumers": has_consumers}

static func item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	var item_filter: Array = []
	for _i in range(max(content_items_size, 0)):
		item_filter.append(false)
	var liquid_filter: Array = []
	for _i in range(max(content_liquids_size, 0)):
		liquid_filter.append(false)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_ITEM_LIQUID_FILTERS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void reinitializeConsumers(){", "item_filter_expr": "itemFilter = new boolean[content.items().size];", "liquid_filter_expr": "liquidFilter = new boolean[content.liquids().size];", "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "item_filter": item_filter, "liquid_filter": liquid_filter, "item_filter_size": item_filter.size(), "liquid_filter_size": liquid_filter.size()}

static func outputs_power_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	var has_power_after: bool = true if outputs_power else has_power_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_OUTPUTS_POWER_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void reinitializeConsumers(){", "outputs_power_expr": "if(outputsPower) hasPower = true;", "outputs_power": outputs_power, "has_power_before": has_power_before, "has_power_after": has_power_after}

static func apply_loop_state(consumers: Array) -> Dictionary:
	var apply_calls: Array = []
	for consumer in consumers:
		apply_calls.append({"call": "cons.apply(this);", "consumer": consumer, "block_arg": "this"})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_APPLY_LOOP_STATE, "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void reinitializeConsumers(){", "consumers_loop_expr": "for(Consume cons : consumers){", "consume_apply_expr": "cons.apply(this);", "consume_apply_method_expr": "public void apply(Block block){", "consumers": consumers, "apply_calls": apply_calls, "apply_call_count": apply_calls.size()}

static func generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_reinitializeConsumers_124", [consume_builder], null)
	var canonical = arrays_state(consume_builder)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_ARRAYS_STATE, "generated_owner": "block.java_method_reinitializeConsumers_124", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_reinitializeConsumers_124", [content_items_size, content_liquids_size], null, {"mindustry_reinitialize_consumers_bridge_mode": "item_liquid_filters"})
	var canonical = item_liquid_filters_state(content_items_size, content_liquids_size)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_ITEM_LIQUID_FILTERS_STATE, "generated_owner": "block.java_method_reinitializeConsumers_124", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_reinitializeConsumers_124", [outputs_power, has_power_before], null, {"mindustry_reinitialize_consumers_bridge_mode": "outputs_power"})
	var canonical = outputs_power_state(outputs_power, has_power_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_OUTPUTS_POWER_STATE, "generated_owner": "block.java_method_reinitializeConsumers_124", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_reinitializeConsumers_124", [consumers], null, {"mindustry_reinitialize_consumers_bridge_mode": "consumer_apply_loop"})
	var canonical = apply_loop_state(consumers)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REINITIALIZE_CONSUMERS_APPLY_LOOP_STATE, "generated_owner": "block.java_method_reinitializeConsumers_124", "result": result, "canonical": canonical, "matches": matches}
