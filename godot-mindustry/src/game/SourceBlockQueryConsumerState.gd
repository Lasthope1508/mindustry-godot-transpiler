class_name SourceBlockQueryConsumerState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func has_consumer_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_HAS_CONSUMER_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasConsumer(Consume cons){", "return_expr": "return consumeBuilder.contains(cons);", "consumeBuilder_contains": consume_builder_contains, "cons": cons, "has_consumer": consume_builder_contains}

static func remove_consumer_state(consumers_length: int, cons: Variant) -> Dictionary:
	var illegal_state_exception_thrown: bool = consumers_length > 0
	var consume_builder_remove_called: bool = not illegal_state_exception_thrown
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REMOVE_CONSUMER_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumer(Consume cons){", "guard_expr": "if(consumers.length > 0){", "exception_expr": "throw new IllegalStateException(\"You can only remove consumers before init(). After init(), all consumers have already been initialized.\");", "exception_message": "You can only remove consumers before init(). After init(), all consumers have already been initialized.", "remove_expr": "consumeBuilder.remove(cons);", "consumers_length": consumers_length, "cons": cons, "illegal_state_exception_thrown": illegal_state_exception_thrown, "consume_builder_remove_called": consume_builder_remove_called}

static func remove_consumers_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	var cons_power_cleared: bool = not consume_builder_contains_power_after_remove
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REMOVE_CONSUMERS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumers(Boolf<Consume> b){", "remove_all_expr": "consumeBuilder.removeAll(b);", "comment": "//the power was removed, unassign it", "power_guard_expr": "if(!consumeBuilder.contains(c -> c instanceof ConsumePower)){", "cons_power_expr": "consPower = null;", "consumeBuilder_contains_power_after_remove": consume_builder_contains_power_after_remove, "b": b, "consume_builder_remove_all_called": true, "cons_power_cleared": cons_power_cleared}

static func generated_block_has_consumer_bridge_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_hasConsumer_96", [consume_builder_contains, cons], null)
	var canonical = has_consumer_state(consume_builder_contains, cons)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_HAS_CONSUMER_STATE, "generated_owner": "block.java_method_hasConsumer_96", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_remove_consumer_bridge_state(consumers_length: int, cons: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_removeConsumer_97", [consumers_length, cons], null)
	var canonical = remove_consumer_state(consumers_length, cons)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REMOVE_CONSUMER_STATE, "generated_owner": "block.java_method_removeConsumer_97", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_removeConsumers_98", [consume_builder_contains_power_after_remove, b], null)
	var block_remove_consumers_result = result
	var canonical = remove_consumers_state(consume_builder_contains_power_after_remove, b)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(block_remove_consumers_result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REMOVE_CONSUMERS_STATE, "generated_owner": "block.java_method_removeConsumers_98", "result": result, "canonical": canonical, "matches": matches}
