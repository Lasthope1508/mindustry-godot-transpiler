extends RefCounted
class_name SourceMendProjectorDisplayState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_mend_projector_source_text_state := preload("res://src/game/SourceMendProjectorSourceTextState.gd")

const SOURCE_MEND_PROJECTOR_RANGE_METHOD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_RANGE_METHOD
const SOURCE_MEND_PROJECTOR_RANGE_RETURN := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_RANGE_RETURN
const SOURCE_MEND_PROJECTOR_RANGE_FIELD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_RANGE_FIELD
const SOURCE_MEND_PROJECTOR_RANGE_PHASE_RANGE_BOOST_FIELD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_RANGE_PHASE_RANGE_BOOST_FIELD
const SOURCE_MEND_PROJECTOR_RANGE_REAL_RANGE_EXPR := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_RANGE_REAL_RANGE_EXPR

const SOURCE_MEND_PROJECTOR_LIGHT_METHOD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_LIGHT_METHOD
const SOURCE_MEND_PROJECTOR_LIGHT_CALL := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_LIGHT_CALL
const SOURCE_MEND_PROJECTOR_LIGHT_RADIUS_EXPR := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_LIGHT_RADIUS_EXPR
const SOURCE_MEND_PROJECTOR_LIGHT_ALPHA_EXPR := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_LIGHT_ALPHA_EXPR

const SOURCE_MEND_PROJECTOR_SELECT_METHOD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_SELECT_METHOD
const SOURCE_MEND_PROJECTOR_SELECT_REAL_RANGE := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_SELECT_REAL_RANGE
const SOURCE_MEND_PROJECTOR_SELECT_EACH_BLOCK := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_SELECT_EACH_BLOCK
const SOURCE_MEND_PROJECTOR_SELECT_SELECTED_CALL := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_SELECT_SELECTED_CALL
const SOURCE_MEND_PROJECTOR_SELECT_DASH_CIRCLE := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_SELECT_DASH_CIRCLE
const SOURCE_MEND_PROJECTOR_SELECT_BASE_COLOR_FIELD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_SELECT_BASE_COLOR_FIELD

const SOURCE_MEND_PROJECTOR_PLACE_METHOD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PLACE_METHOD
const SOURCE_MEND_PROJECTOR_PLACE_SUPER := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PLACE_SUPER
const SOURCE_MEND_PROJECTOR_PLACE_DASH_CIRCLE := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PLACE_DASH_CIRCLE
const SOURCE_MEND_PROJECTOR_PLACE_EACH_BLOCK := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PLACE_EACH_BLOCK
const SOURCE_MEND_PROJECTOR_PLACE_SELECTED_CALL := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PLACE_SELECTED_CALL

const SOURCE_MEND_PROJECTOR_DRAW_METHOD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_DRAW_METHOD
const SOURCE_MEND_PROJECTOR_DRAW_F_EXPR := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_DRAW_F_EXPR
const SOURCE_MEND_PROJECTOR_DRAW_COLOR_BLEND := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_DRAW_COLOR_BLEND
const SOURCE_MEND_PROJECTOR_DRAW_TOP_ALPHA := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_DRAW_TOP_ALPHA
const SOURCE_MEND_PROJECTOR_DRAW_SQUARE_RADIUS := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_DRAW_SQUARE_RADIUS

static func projector_range(mend_projector, phase_heat := 0.0) -> float:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	var base_range := float(properties.get("range", source_projector_defaults.MEND_RANGE_DEFAULT))
	var phase_range_boost := float(properties.get("phaseRangeBoost", source_projector_defaults.MEND_PHASE_RANGE_BOOST_DEFAULT))
	return base_range + phase_heat * phase_range_boost

static func select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	return {
		"range": projector_range(mend_projector, phase_heat),
		"color": str(properties.get("baseColor", source_projector_defaults.MEND_BASE_COLOR_DEFAULT)),
		"phase_heat": phase_heat,
	}

static func place_state(mend_projector) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	return {
		"range": float(properties.get("range", source_projector_defaults.MEND_RANGE_DEFAULT)),
		"color": str(properties.get("baseColor", source_projector_defaults.MEND_BASE_COLOR_DEFAULT)),
	}

static func light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	if not bool(properties.get("emitLight", source_projector_defaults.MEND_EMIT_LIGHT_DEFAULT)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return {
		"color": str(properties.get("baseColor", source_projector_defaults.MEND_BASE_COLOR_DEFAULT)),
		"radius": float(properties.get("lightRadius", source_projector_defaults.MEND_LIGHT_RADIUS_DEFAULT)) * smooth_efficiency,
		"alpha": source_projector_defaults.PROJECTOR_LIGHT_OPACITY_DEFAULT * smooth_efficiency,
	}

static func projector_block_size(mend_projector) -> int:
	return source_block_metadata_state.block_size(mend_projector)

static func draw_state(mend_projector, heat: float, phase_heat: float, tile_size: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	if mend_projector == null or not lod_l2:
		return {"visible": false, "f": 0.0, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "top_rect": false, "lod_alpha2": 0.0, "square_alpha": 0.0, "square_stroke": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0, "square_radius": 0.0}
	var f := 1.0 - fmod(source_time_ticks / source_projector_defaults.PROJECTOR_TIME_LOOP_PERIOD, 1.0)
	var block_size_value := float(projector_block_size(mend_projector))
	return {
		"visible": true,
		"f": f,
		"base_color": str(properties.get("baseColor", source_projector_defaults.MEND_BASE_COLOR_DEFAULT)),
		"phase_color": str(properties.get("phaseColor", source_projector_defaults.MEND_BASE_COLOR_DEFAULT)),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_math_state.source_absin(source_time_ticks, 50.0 / source_math_defaults.PI2, 1.0) * 0.5 * lod_alpha2,
		"top_rect": true,
		"lod_alpha2": lod_alpha2,
		"square_alpha": lod_alpha2,
		"square_stroke": (2.0 * f + 0.2) * heat,
		"stroke": (2.0 * f + 0.2) * heat,
		"line_r": max(0.0, clamp(2.0 - f * 2.0, 0.0, 1.0) * block_size_value * float(tile_size) / 2.0 - f - 0.2),
		"line_w": clamp(0.5 - f, 0.0, 1.0) * block_size_value * float(tile_size),
		"square_radius": min(1.0 + (1.0 - f) * float(projector_block_size(mend_projector)) * float(tile_size) / 2.0, float(projector_block_size(mend_projector)) * float(tile_size) / 2.0),
	}
