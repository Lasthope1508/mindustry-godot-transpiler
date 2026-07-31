extends RefCounted
class_name SourceBlockInitConsumerState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func arrays_state(consume_builder: Array) -> Dictionary:
	var consumers: Array = consume_builder.duplicate()
	var optional_consumers: Array = []
	var non_optional_consumers: Array = []
	var update_consumers: Array = []
	for consumer in consume_builder:
		if not consumer is Dictionary:
			continue
		var ignored: bool = bool(consumer.get("ignored", false))
		if bool(consumer.get("optional", false)) and not ignored:
			optional_consumers.append(consumer)
		if not bool(consumer.get("optional", false)) and not ignored:
			non_optional_consumers.append(consumer)
		if bool(consumer.get("update", true)) and not ignored:
			update_consumers.append(consumer)
	var has_consumers: bool = consumers.size() > 0
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CONSUMER_ARRAYS_STATE, "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void init(){", "super_init_expr": "super.init();", "consumers_expr": "consumers = consumeBuilder.toArray(Consume.class);", "optional_consumers_expr": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);", "non_optional_consumers_expr": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);", "update_consumers_expr": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);", "has_consumers_expr": "hasConsumers = consumers.length > 0;", "consume_optional_field_expr": "public boolean optional;", "consume_update_field_expr": "public boolean update = true;", "consume_ignore_method_expr": "public boolean ignore(){", "consume_builder": consume_builder, "consumers": consumers, "optional_consumers": optional_consumers, "non_optional_consumers": non_optional_consumers, "update_consumers": update_consumers, "has_consumers": has_consumers}

static func generated_consumer_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "consumer_arrays"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [consume_builder], null, metadata)
	var canonical = arrays_state(consume_builder)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CONSUMER_ARRAYS_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func apply_loop_state(consumers: Array) -> Dictionary:
	var apply_calls: Array = []
	for consumer in consumers:
		apply_calls.append({"call": "cons.apply(this);", "consumer": consumer, "block_arg": "this"})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CONSUMER_APPLY_LOOP_STATE, "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void init(){", "super_init_expr": "super.init();", "consumers_loop_expr": "for(Consume cons : consumers){", "consume_apply_expr": "cons.apply(this);", "consume_apply_method_expr": "public void apply(Block block){", "consumers": consumers, "apply_calls": apply_calls, "apply_call_count": apply_calls.size()}

static func generated_consumer_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "consumer_apply_loop"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [consumers], null, metadata)
	var canonical = apply_loop_state(consumers)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CONSUMER_APPLY_LOOP_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
