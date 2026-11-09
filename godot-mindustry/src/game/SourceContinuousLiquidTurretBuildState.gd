extends RefCounted
class_name SourceContinuousLiquidTurretBuildState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consume_state := preload("res://src/game/SourceConsumeState.gd")
const source_consume_liquid_filter_state := preload("res://src/game/SourceConsumeLiquidFilterState.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS
const SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS
const SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_COMMENT := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_COMMENT
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_ACTIVATE_GUARD_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_ACTIVATE_GUARD_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_DEACTIVATE_GUARD_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_DEACTIVATE_GUARD_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_SWITCH_RETURN := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_SWITCH_RETURN
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_DEFAULT_CASE := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_DEFAULT_CASE
const SOURCE_CONTINUOUS_LIQUID_TURRET_CURRENT_AMMO_TYPE_SENSOR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_CURRENT_AMMO_TYPE_SENSOR
const SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_COMMENT := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_COMMENT
const SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_RETURN_EXPR

const SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION := "ContinuousLiquidTurret"
const SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY := "source_continuous_liquid_turret_building"

static func _continuous_liquid_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_ACTIVE_SOUND_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_RETURN_EXPR, "should_active_sound": was_shooting and enabled, "was_shooting": was_shooting, "enabled": enabled}

static func get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_CONTENT_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_RETURN_EXPR, "ammo_content": ammo_content, "liquids_null": liquids_null, "current_amount": current_amount, "current_liquid": current_liquid}

static func get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var ammo_fraction := current_amount / liquid_capacity if liquid_capacity != 0.0 else 0.0
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_FRACTION_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_RETURN_EXPR, "ammo_fraction": ammo_fraction, "current_amount": current_amount, "liquid_capacity": liquid_capacity}

static func update_tile_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var activate_threshold := liquid_consumed * 4.0
	var activated_after := activated_before
	if current_amount >= activate_threshold:
		activated_after = true
	elif current_amount < liquid_consumed:
		activated_after = false
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_UPDATE_TILE_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_METHOD, "comment": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_COMMENT, "activate_guard_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_ACTIVATE_GUARD_EXPR, "deactivate_guard_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_DEACTIVATE_GUARD_EXPR, "activated_after": activated_after, "current_amount": current_amount, "liquid_consumed": liquid_consumed, "activated_before": activated_before, "super_update_tile_called": true}

static func source_tick_frame_state(frame: Dictionary, block_implementation: String, liquids: Dictionary, liquid_names_by_id: Array, ammo_types: Dictionary) -> Dictionary:
	# The turret tick wires the frame keys the cost multiplier reads
	# (N2101) before the consumers run: current_liquid is
	# b.liquids.current() — the last received/loaded liquid
	# (LiquidModule.java:80-83) — read in the port from the liquid
	# module's "current" via SourceLiquidModuleState
	# .source_current_state and resolved to its content name (Java
	# resolves a liquid by id through content.liquid(id);
	# LiquidModule.java:24 seeds current with content.liquid(0));
	# ammo_types is the block's ammoTypes (ObjectMap<Liquid,
	# BulletType>, ContinuousLiquidTurret.java:14) in port form; and
	# block_implementation is set like the drill tick sets it (N2097),
	# so the N2101 branch dispatches. A module without a current id,
	# or an id with no content name, leaves current_liquid null and
	# the multiplier keeps its 1.0 default.
	frame["block_implementation"] = block_implementation
	var current_liquid: Variant = null
	if liquids.has("current") and liquids["current"] is int:
		var current_id: int = int(source_liquid_module_state.source_current_state(liquids).get("current", -1))
		if current_id >= 0 and current_id < liquid_names_by_id.size():
			current_liquid = liquid_names_by_id[current_id]
	frame["current_liquid"] = current_liquid
	frame["ammo_types"] = ammo_types
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill frame on proximity update). A
	# ContinuousLiquidTurret sprite gets an empty frame bound; the
	# live-loop tick fills its keys every tick (N2102). Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or str(block.implementation) != SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION:
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_consumed_liquid_state(frame: Dictionary, liquids: Dictionary, liquid_names_by_id: Array) -> Dictionary:
	# ConsumeLiquidFilter.getConsumed (ConsumeLiquidFilter.java): the
	# current liquid when the filter admits it and its amount is
	# positive, else the first content liquid the filter admits with
	# amount left; null when none has any. The filter is
	# ammoTypes.containsKey (ContinuousLiquidTurret.java:40); the port
	# reads it through the registered get_consumed_state, with liquid
	# ids as identities so the result matches the bound consumer rows.
	var ammo_types: Dictionary = frame.get("ammo_types", {})
	var current_id: int = int(source_liquid_module_state.source_current_state(liquids).get("current", -1))
	var current_liquid: Variant = null
	if current_id >= 0 and current_id < liquid_names_by_id.size():
		current_liquid = current_id
	var current_filter := false
	var current_amount := 0.0
	if current_liquid != null:
		current_filter = ammo_types.has(String(liquid_names_by_id[current_id]))
		current_amount = float(source_liquid_module_state.source_get_state(liquids, current_id).get("amount", 0.0))
	var content_liquids: Array = []
	var filter_flags: Array = []
	var build_amounts: Array = []
	for index in range(liquid_names_by_id.size()):
		content_liquids.append(index)
		filter_flags.append(ammo_types.has(String(liquid_names_by_id[index])))
		build_amounts.append(float(source_liquid_module_state.source_get_state(liquids, index).get("amount", 0.0)))
	var consumed: Dictionary = source_consume_liquid_filter_state.get_consumed_state(current_liquid, current_filter, current_amount, content_liquids, filter_flags, build_amounts)
	return {"consumed_liquid": consumed.get("consumed_liquid", null), "consumed_index": consumed.get("consumed_index", -1)}

static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# The block's consumeBuilder carries one ConsumeLiquidFilter row
	# per ammo liquid (N2104 captured the class init's filter into
	# consumeLiquid at liquidConsumed 1/60); the port binds one
	# RuntimeConsumer actor per row (the drill model, N2097/N2100),
	# each removing its own liquid at amount * edelta * multiplier
	# through the N2101 cost-multiplier callback. Actors are bound
	# once — a frame that already carries them binds nothing — and a
	# block without consumeLiquid rows binds none.
	var rows: Array = []
	if block != null and block.properties.has("consumeLiquid"):
		rows = source_consume_liquid_state.source_bind_liquid_consumers_state(block, catalog).get("consumers", [])
	var consumers: Array = frame.get("consumers", [])
	var bound := false
	if consumers.is_empty() and not rows.is_empty():
		for row in rows:
			consumers.append(source_consume_liquid_state.source_runtime_consumer_state(row, amounts, [], source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
		frame["consumers"] = consumers
		bound = true
	return {"bound": bound, "consumers": consumers, "rows": rows}

static func source_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the turret tick wiring every tick
	# (ContinuousLiquidTurretBuild.updateTile(), which calls
	# super.updateTile(), ContinuousTurret.java:86-87, running
	# updateConsumption and the multiplier lambda): each placed
	# ContinuousLiquidTurret gets its frame keys refreshed from its
	# live liquid module via N2102's source_tick_frame_state, so the
	# N2101 multiplier is actually paid live. The frame is bound at
	# placement (source_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop.
	# The ammo map is the block's ammoTypes (ObjectMap<Liquid,
	# BulletType>, ContinuousLiquidTurret.java:14) read off the
	# block's registry properties (N2104 captured sublimate's
	# Blocks.java:4604-4631 map — ozone 1.2f, cyanogen the BulletType
	# 2f default — into properties["ammoTypes"]); a block that
	# carries no ammoTypes keeps the {} default and the multiplier
	# pays 1.0. The tick also runs the filter consumer
	# (ContinuousLiquidTurret.java:40-51, liquidConsumed 1f/60f):
	# RuntimeConsumer actors bound from the block's consumeLiquid
	# rows (N2104) remove amount * edelta * multiplier from
	# getConsumed each tick through BuildingComp.updateConsumption's
	# second pass — only the consumed liquid's actor counts, so a
	# second ammo liquid at rest neither blocks efficiency nor
	# drains. The live flow cache stays unbound (the drill's
	# lifecycle slice owns it).
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_names_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_names_by_id.append(String(liquid.id))
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if str(block.implementation) != SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION:
			continue
		var bound: Dictionary = source_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		var ammo_types: Dictionary = block.properties.get("ammoTypes", {})
		var wired: Dictionary = source_tick_frame_state(frame, str(block.implementation), liquids, liquid_names_by_id, ammo_types)
		# The frame keys the consumer path reads (the drill pattern,
		# N2097/N2099): the block implementation is set by the tick
		# wiring above; the team and live rules let the multiplier
		# callback and the cheating gate read what Java reads
		# (b.team, state.rules).
		frame["team_id"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		frame["rules_state"] = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		frame["cheating"] = bool(source_rules_state.source_team_cheating_state(frame["rules_state"], frame["team_id"]).get("cheating", false))
		frame["enabled"] = bool(frame.get("enabled", true))
		assert(liquids.get("flow", null) == null, "Live flow cache binding requires its own lifecycle slice")
		var consumer_bound: Dictionary = source_bind_consumer_state(frame, block, catalog, liquids)
		var rows: Array = consumer_bound.get("rows", [])
		var consumers: Array = consumer_bound.get("consumers", [])
		# updateConsumption (BuildingComp.java:1943-2004) runs inside
		# super.updateTile(): the first pass takes the minimum
		# efficiency of the non-optional consumers, the second pass
		# updates each update consumer when update (shouldConsume
		# && productionValid) and efficiency > 0. shouldConsume is
		# super.shouldConsume() && activated — enabled (BuildingComp
		# .java:755-757) and the hysteresis value from the previous
		# tick (the hysteresis itself updates after this pass, as in
		# Java's updateTile order).
		var activated_before: bool = bool(frame.get("activated", false))
		var should_consume: bool = bool(frame.get("enabled", true)) and activated_before
		var valid: bool = source_building_access_state.production_valid_state()
		var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
		frame["efficiency"] = setup.get("efficiency", 1.0)
		frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
		var groups: Dictionary = source_consume_state.classify_consumer_arrays(rows, "ignored", "optional", "update")
		var consumed: Dictionary = source_consumed_liquid_state(frame, liquids, liquid_names_by_id)
		var consumed_id: Variant = consumed.get("consumed_liquid", null)
		var consumed_actor: Variant = null
		var consumed_row: Variant = null
		for index in range(rows.size()):
			if consumed_id != null and int(rows[index].get("liquid", -1)) == int(consumed_id):
				if index < consumers.size():
					consumed_actor = consumers[index]
					consumed_row = rows[index]
				break
		var required_results: Array = []
		var optional_results: Array = []
		var updates: Array = []
		if consumed_actor != null:
			consumed_actor.source_delta = seconds * source_time_defaults.TICK_RATE
			consumed_actor.time_scale = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			if bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
				if groups["non_optional_consumers"].has(consumed_row):
					required_results.append({"result": consumed_actor.efficiency(frame), "is_power": false})
				if groups["optional_consumers"].has(consumed_row):
					optional_results.append({"result": consumed_actor.efficiency(frame)})
			if groups["update_consumers"].has(consumed_row):
				updates.append(consumed_actor)
		elif bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)) and not groups["non_optional_consumers"].is_empty():
			required_results.append({"result": 0.0, "is_power": false})
		var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(groups["has_consumers"], bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, updates, frame)
		source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# ContinuousLiquidTurretBuild.updateTile() runs
		# super.updateTile() first and only then updates activated
		# (ContinuousLiquidTurret.java:71-81): the hysteresis reads
		# the current amount against liquidConsumed, so a turret
		# that just received liquid starts consuming on the next
		# tick, not this one.
		if not rows.is_empty():
			var current_id: int = int(source_liquid_module_state.source_current_state(liquids).get("current", -1))
			var current_amount := 0.0
			if current_id >= 0:
				current_amount = float(source_liquid_module_state.source_get_state(liquids, current_id).get("amount", 0.0))
			frame["activated"] = update_tile_state(current_amount, float(rows[0].get("amount", 0.0)), activated_before).get("activated_after", activated_before)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var sense_object_value: Variant = super_sense_object_value
	if sensor == SOURCE_CONTINUOUS_LIQUID_TURRET_CURRENT_AMMO_TYPE_SENSOR:
		sense_object_value = current_liquid
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SENSE_OBJECT_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_METHOD, "switch_return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_SWITCH_RETURN, "current_ammo_type_case": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE, "default_case": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_DEFAULT_CASE, "sense_object_value": sense_object_value, "sensor": sensor, "current_liquid": current_liquid, "super_sense_object_value": super_sense_object_value}

static func can_consume_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var can_consume := has_correct_ammo and super_can_consume
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_CAN_CONSUME_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_RETURN_EXPR, "can_consume": can_consume, "has_correct_ammo": has_correct_ammo, "super_can_consume": super_can_consume}

static func should_consume_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var should_consume := super_should_consume and activated
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_CONSUME_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_RETURN_EXPR, "should_consume": should_consume, "super_should_consume": super_should_consume, "activated": activated}

static func use_ammo_state(peek_ammo: Variant) -> Dictionary:
	var returned_ammo: Variant = peek_ammo
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_USE_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_METHOD, "comment": SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_COMMENT, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_RETURN_EXPR, "returned_ammo": returned_ammo, "peek_ammo": peek_ammo}

static func peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_PEEK_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_RETURN_EXPR, "peek_ammo": ammo_type, "current_liquid": current_liquid}

static func has_ammo_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var ammo_type_present: bool = ammo_type != null
	var has_ammo := has_correct_ammo and ammo_type_present and current_amount > 0.0 and activated
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_RETURN_EXPR, "has_ammo": has_ammo, "ammo_type_present": ammo_type_present, "has_correct_ammo": has_correct_ammo, "current_liquid": current_liquid, "ammo_type": ammo_type, "current_amount": current_amount, "activated": activated}

static func has_correct_ammo_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var has_correct_ammo: bool = (not bullets_any) or first_bullet_type == peek_ammo
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_CORRECT_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_RETURN_EXPR, "has_correct_ammo": has_correct_ammo, "bullets_any": bullets_any, "first_bullet_type": first_bullet_type, "peek_ammo": peek_ammo}

static func accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	var accept_item: bool = false
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_ITEM_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_METHOD, "override_expr": "@Override", "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_RETURN_EXPR, "accept_item": accept_item, "source_building": source_building, "item": item}

static func accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var liquid_has_ammo_type: bool = ammo_type != null
	var same_liquid: bool = current_liquid == liquid
	var current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present
	var current_required_with_epsilon: Variant = null
	var current_liquid_drained: bool = false
	if liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:
		current_required_with_epsilon = 1.0 / current_ammo_multiplier + source_turret_defaults.LIQUID_AMMO_EPSILON
		current_liquid_drained = current_liquid_amount <= current_required_with_epsilon
	var replacement_allowed: bool = false
	if liquid_has_ammo_type and not same_liquid:
		replacement_allowed = current_liquid_missing_ammo_type or current_liquid_drained
	var accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_LIQUID_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_METHOD, "override_expr": "@Override", "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_RETURN_EXPR, "accept_liquid": accept_liquid, "source_building": source_building, "liquid": liquid, "ammo_type": ammo_type, "current_liquid": current_liquid, "current_liquid_ammo_type_present": current_liquid_ammo_type_present, "current_liquid_amount": current_liquid_amount, "current_ammo_multiplier": current_ammo_multiplier, "liquid_has_ammo_type": liquid_has_ammo_type, "same_liquid": same_liquid, "current_liquid_missing_ammo_type": current_liquid_missing_ammo_type, "current_required_with_epsilon": current_required_with_epsilon, "current_liquid_drained": current_liquid_drained, "replacement_allowed": replacement_allowed}

static func generated_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_shouldActiveSound_0", [was_shooting, enabled])
	var canonical = should_active_sound_state(was_shooting, enabled)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_ACTIVE_SOUND_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.shouldActiveSound", "result": result, "canonical": canonical, "matches": result.get("should_active_sound", null) == canonical.get("should_active_sound", null) and result.get("was_shooting", null) == canonical.get("was_shooting", null) and result.get("enabled", null) == canonical.get("enabled", null)}

static func generated_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoContent_1", [liquids_null, current_amount, current_liquid])
	var canonical = get_ammo_content_state(liquids_null, current_amount, current_liquid)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_CONTENT_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.getAmmoContent", "result": result, "canonical": canonical, "matches": result.get("ammo_content", null) == canonical.get("ammo_content", null) and result.get("liquids_null", null) == canonical.get("liquids_null", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoFraction_2", [current_amount, liquid_capacity])
	var canonical = get_ammo_fraction_state(current_amount, liquid_capacity)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_FRACTION_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.getAmmoFraction", "result": result, "canonical": canonical, "matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_capacity", null) == canonical.get("liquid_capacity", null)}

static func generated_update_tile_bridge_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_updateTile_3", [current_amount, liquid_consumed, activated_before])
	var canonical = update_tile_state(current_amount, liquid_consumed, activated_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_UPDATE_TILE_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.updateTile", "result": result, "canonical": canonical, "matches": result.get("activated_after", null) == canonical.get("activated_after", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_consumed", null) == canonical.get("liquid_consumed", null) and result.get("activated_before", null) == canonical.get("activated_before", null) and result.get("super_update_tile_called", false) == canonical.get("super_update_tile_called", false)}

static func generated_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_senseObject_4", [sensor, current_liquid, super_sense_object_value])
	var canonical = sense_object_state(sensor, current_liquid, super_sense_object_value)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SENSE_OBJECT_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.senseObject", "result": result, "canonical": canonical, "matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null) and result.get("sensor", null) == canonical.get("sensor", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null) and result.get("super_sense_object_value", null) == canonical.get("super_sense_object_value", null)}

static func generated_can_consume_bridge_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_canConsume_5", [has_correct_ammo, super_can_consume])
	var canonical = can_consume_state(has_correct_ammo, super_can_consume)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_CAN_CONSUME_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.canConsume", "result": result, "canonical": canonical, "matches": result.get("can_consume", null) == canonical.get("can_consume", null) and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("super_can_consume", null) == canonical.get("super_can_consume", null)}

static func generated_should_consume_bridge_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_shouldConsume_6", [super_should_consume, activated])
	var canonical = should_consume_state(super_should_consume, activated)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_CONSUME_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.shouldConsume", "result": result, "canonical": canonical, "matches": result.get("should_consume", null) == canonical.get("should_consume", null) and result.get("super_should_consume", null) == canonical.get("super_should_consume", null) and result.get("activated", null) == canonical.get("activated", null)}

static func generated_use_ammo_bridge_state(peek_ammo: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_useAmmo_7", [peek_ammo])
	var canonical = use_ammo_state(peek_ammo)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_USE_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.useAmmo", "result": result, "canonical": canonical, "matches": result.get("returned_ammo", null) == canonical.get("returned_ammo", null) and result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_peekAmmo_8", [current_liquid, ammo_type])
	var canonical = peek_ammo_state(current_liquid, ammo_type)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_PEEK_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.peekAmmo", "result": result, "canonical": canonical, "matches": result.get("peek_ammo", null) == canonical.get("peek_ammo", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_has_ammo_bridge_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_hasAmmo_9", [has_correct_ammo, current_liquid, ammo_type, current_amount, activated])
	var canonical = has_ammo_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.hasAmmo", "result": result, "canonical": canonical, "matches": result.get("has_ammo", null) == canonical.get("has_ammo", null) and result.get("ammo_type_present", null) == canonical.get("ammo_type_present", null) and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("activated", null) == canonical.get("activated", null)}

static func generated_has_correct_ammo_bridge_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_hasCorrectAmmo_10", [bullets_any, first_bullet_type, peek_ammo])
	var canonical = has_correct_ammo_state(bullets_any, first_bullet_type, peek_ammo)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_CORRECT_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.hasCorrectAmmo", "result": result, "canonical": canonical, "matches": result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("bullets_any", null) == canonical.get("bullets_any", null) and result.get("first_bullet_type", null) == canonical.get("first_bullet_type", null) and result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_acceptItem_11", [source_building, item])
	var canonical = accept_item_state(source_building, item)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_ITEM_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.acceptItem", "result": result, "canonical": canonical, "matches": result.get("accept_item", null) == canonical.get("accept_item", null) and result.get("source_building", null) == canonical.get("source_building", null) and result.get("item", null) == canonical.get("item", null)}

static func generated_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_acceptLiquid_12", [source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier])
	var canonical = accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_LIQUID_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.acceptLiquid", "result": result, "canonical": canonical, "matches": result.get("accept_liquid", null) == canonical.get("accept_liquid", null) and result.get("replacement_allowed", null) == canonical.get("replacement_allowed", null) and result.get("current_required_with_epsilon", null) == canonical.get("current_required_with_epsilon", null)}
