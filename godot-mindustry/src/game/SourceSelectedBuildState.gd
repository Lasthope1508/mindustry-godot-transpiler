extends RefCounted
class_name SourceSelectedBuildState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_power_defaults := preload("res://src/game/SourcePowerDefaults.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")
const source_overdrive_projector_state := preload("res://src/game/SourceOverdriveProjectorState.gd")

const SOURCE_BLOCK_HAS_POWER_DEFAULT := source_block_defaults.HAS_POWER_DEFAULT
const SOURCE_BLOCK_CONSUMES_POWER_DEFAULT := source_block_defaults.CONSUMES_POWER_DEFAULT
const SOURCE_BLOCK_OUTPUTS_POWER_DEFAULT := source_block_defaults.OUTPUTS_POWER_DEFAULT
const SOURCE_BLOCK_SCALED_HEALTH_DEFAULT := source_block_defaults.SCALED_HEALTH_DEFAULT
const SOURCE_BUILD_BOOSTER_USE_TIME_DEFAULT := source_projector_defaults.BUILD_BOOSTER_USE_TIME_DEFAULT
const SOURCE_CONSUME_GENERATOR_ITEM_DURATION_DEFAULT := source_power_defaults.CONSUME_GENERATOR_ITEM_DURATION_DEFAULT
const SOURCE_POWER_NODE_MAX_NODES_DEFAULT := source_power_defaults.POWER_NODE_MAX_NODES_DEFAULT
const SOURCE_POWER_NODE_LASER_RANGE_DEFAULT := source_power_defaults.POWER_NODE_LASER_RANGE_DEFAULT

static func selected_build(build_palette: Array, selected_build_index: int):
	if build_palette.is_empty():
		return null
	return build_palette[selected_build_index]

static func properties(block) -> Dictionary:
	return source_block_metadata_state.block_properties(block)

static func implementation_name(block) -> String:
	if block == null:
		return ""
	if block is Dictionary:
		return str(block.get("implementation", ""))
	if block is Object:
		return str(block.get("implementation"))
	return ""

static func is_mend_projector(block) -> bool:
	return implementation_name(block) == "MendProjector"

static func is_overdrive_projector(block) -> bool:
	return implementation_name(block) == "OverdriveProjector"

static func health(block) -> float:
	return source_block_metadata_state.block_health_value(block)

static func scaled_health(block) -> float:
	var selected_properties := properties(block)
	return float(selected_properties.get("scaledHealth", SOURCE_BLOCK_SCALED_HEALTH_DEFAULT))

static func heal_percent(block) -> float:
	var selected_properties := properties(block)
	var heal_percent_default := source_projector_defaults.MEND_HEAL_PERCENT_DEFAULT if implementation_name(block) == "MendProjector" else 0.0
	return float(selected_properties.get("healPercent", heal_percent_default))

static func phase_boost(block) -> float:
	var selected_properties := properties(block)
	var phase_boost_default := source_projector_defaults.MEND_PHASE_BOOST_DEFAULT if implementation_name(block) == "MendProjector" else 0.0
	return float(selected_properties.get("phaseBoost", phase_boost_default))

static func phase_range_boost(block) -> float:
	var selected_properties := properties(block)
	var phase_range_boost_default := 0.0
	if implementation_name(block) == "MendProjector":
		phase_range_boost_default = source_projector_defaults.MEND_PHASE_RANGE_BOOST_DEFAULT
	if implementation_name(block) == "OverdriveProjector":
		phase_range_boost_default = source_projector_defaults.OVERDRIVE_PHASE_RANGE_BOOST_DEFAULT
	return float(selected_properties.get("phaseRangeBoost", phase_range_boost_default))

static func can_overdrive(block) -> bool:
	return source_block_metadata_state.block_can_overdrive(block)

static func has_power(block) -> bool:
	var selected_properties := properties(block)
	return bool(selected_properties.get("hasPower", SOURCE_BLOCK_HAS_POWER_DEFAULT))

static func consumes_power(block) -> bool:
	var selected_properties := properties(block)
	return bool(selected_properties.get("consumesPower", SOURCE_BLOCK_CONSUMES_POWER_DEFAULT))

static func outputs_power(block) -> bool:
	var selected_properties := properties(block)
	return bool(selected_properties.get("outputsPower", SOURCE_BLOCK_OUTPUTS_POWER_DEFAULT))

static func power_usage(block) -> float:
	var selected_properties := properties(block)
	return float(selected_properties.get("powerUsage", source_block_defaults.SOURCE_BLOCK_POWER_USAGE_DEFAULT))

static func power_capacity(block) -> float:
	var selected_properties := properties(block)
	return float(selected_properties.get("powerCapacity", source_block_defaults.SOURCE_BLOCK_POWER_CAPACITY_DEFAULT))

static func power_buffered(block) -> bool:
	var selected_properties := properties(block)
	return bool(selected_properties.get("powerBuffered", source_block_defaults.SOURCE_BLOCK_POWER_BUFFERED_DEFAULT))

static func power_production(block) -> float:
	var selected_properties := properties(block)
	return float(selected_properties.get("powerProduction", source_block_defaults.SOURCE_BLOCK_POWER_PRODUCTION_DEFAULT))

static func item_duration(block) -> float:
	var selected_properties := properties(block)
	if implementation_name(block) != "ConsumeGenerator" and not selected_properties.has("itemDuration"):
		return 0.0
	return float(selected_properties.get("itemDuration", SOURCE_CONSUME_GENERATOR_ITEM_DURATION_DEFAULT))

static func max_nodes(block) -> int:
	var selected_properties := properties(block)
	if implementation_name(block) != "PowerNode" and not selected_properties.has("maxNodes"):
		return 0
	return int(selected_properties.get("maxNodes", SOURCE_POWER_NODE_MAX_NODES_DEFAULT))

static func laser_range(block) -> float:
	var selected_properties := properties(block)
	if implementation_name(block) != "PowerNode" and not selected_properties.has("laserRange"):
		return 0.0
	return float(selected_properties.get("laserRange", SOURCE_POWER_NODE_LASER_RANGE_DEFAULT))

static func booster_item(block) -> String:
	return source_block_metadata_state.block_booster_item(block)

static func booster_use_time(block) -> float:
	var selected_properties := properties(block)
	if selected_properties.has("boosterUseTime"):
		if implementation_name(block) == "MendProjector":
			return float(selected_properties.get("boosterUseTime", source_projector_defaults.MEND_USE_TIME_DEFAULT))
		if implementation_name(block) == "OverdriveProjector":
			return float(selected_properties.get("boosterUseTime", source_projector_defaults.OVERDRIVE_USE_TIME_DEFAULT))
		return float(selected_properties.get("boosterUseTime", SOURCE_BUILD_BOOSTER_USE_TIME_DEFAULT))
	if implementation_name(block) == "MendProjector":
		return source_mend_projector_state.use_time(block)
	if implementation_name(block) == "OverdriveProjector":
		return source_overdrive_projector_state.use_time(block)
	return SOURCE_BUILD_BOOSTER_USE_TIME_DEFAULT

static func place_state(block) -> Dictionary:
	if is_mend_projector(block):
		return source_mend_projector_state.place_state(block)
	if is_overdrive_projector(block):
		return source_overdrive_projector_state.place_state(block)
	return {"range": 0.0, "color": ""}

static func overdrive_real_boost(block) -> float:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_state.real_boost(block)

static func overdrive_phase_real_boost(block) -> float:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_state.real_boost(block, 1.0)

static func overdrive_boost_bar_fraction(block) -> float:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_state.boost_bar_fraction(block)

static func overdrive_phase_boost_bar_fraction(block) -> float:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_state.boost_bar_fraction(block, 1.0)

static func overdrive_phase_select_state(block) -> Dictionary:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return {"range": 0.0, "color": ""}
	return source_overdrive_projector_state.select_state(block, 1.0)

static func overdrive_place_state(block) -> Dictionary:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return {"range": 0.0, "color": ""}
	return source_overdrive_projector_state.place_state(block)

static func overdrive_light_state_for_smooth_efficiency(block, smooth_efficiency: float) -> Dictionary:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_overdrive_projector_state.light_state(block, smooth_efficiency)

static func overdrive_draw_state_for_inputs(block, heat: float, phase_heat: float, tile_size: float, source_time_ticks := 0.0) -> Dictionary:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return {"visible": false}
	return source_overdrive_projector_state.draw_state(block, heat, phase_heat, tile_size, source_time_ticks, true, 1.0)

static func overdrive_target_filter_state(block, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	if block == null or implementation_name(block) != "OverdriveProjector":
		return {"real_range": 0.0, "distance": distance, "can_overdrive": false, "in_range": false, "eligible": false}
	return source_overdrive_projector_state.target_filter_state(block, target_block, distance, phase_heat)
