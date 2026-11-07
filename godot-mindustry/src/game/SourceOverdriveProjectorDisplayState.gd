extends RefCounted
class_name SourceOverdriveProjectorDisplayState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_overdrive_projector_source_text_state := preload("res://src/game/SourceOverdriveProjectorSourceTextState.gd")

const SOURCE_OVERDRIVE_PROJECTOR_RANGE_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_RANGE_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_SELECT_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_SELECT_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_PLACE_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_PLACE_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_LIGHT_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_CALL := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_LIGHT_CALL
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_EMIT_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_LIGHT_EMIT_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_RADIUS_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_LIGHT_RADIUS_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_BASE_COLOR_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_LIGHT_BASE_COLOR_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_SMOOTH_EFFICIENCY_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_LIGHT_SMOOTH_EFFICIENCY_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_DRAW_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_DRAW_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_DRAW_LOD_GUARD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_DRAW_LOD_GUARD
const SOURCE_OVERDRIVE_PROJECTOR_DRAW_LINE_DIMENSIONS := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_DRAW_LINE_DIMENSIONS

static func projector_block_size(overdrive_projector) -> int:
	return source_block_metadata_state.block_size(overdrive_projector)

static func projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	var base_range := float(properties.get("range", source_projector_defaults.OVERDRIVE_RANGE_DEFAULT))
	var phase_range_boost := float(properties.get("phaseRangeBoost", source_projector_defaults.OVERDRIVE_PHASE_RANGE_BOOST_DEFAULT))
	return base_range + phase_heat * phase_range_boost

static func select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return {
		"range": projector_range(overdrive_projector, phase_heat),
		"color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
	}

static func place_state(overdrive_projector) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return {
		"range": float(properties.get("range", source_projector_defaults.OVERDRIVE_RANGE_DEFAULT)),
		"color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
	}

static func light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	if not bool(properties.get("emitLight", source_projector_defaults.OVERDRIVE_EMIT_LIGHT_DEFAULT)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return {
		"color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
		"radius": float(properties.get("lightRadius", source_projector_defaults.OVERDRIVE_LIGHT_RADIUS_DEFAULT)) * smooth_efficiency,
		"alpha": source_projector_defaults.PROJECTOR_LIGHT_OPACITY_DEFAULT * smooth_efficiency,
	}

static func draw_state(overdrive_projector, heat: float, phase_heat: float, tile_size: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	if overdrive_projector == null or not lod_l2:
		return {"visible": false, "f": 0.0, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "top_rect": false, "lod_alpha2": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	var f := 1.0 - fmod(source_time_ticks / source_projector_defaults.PROJECTOR_TIME_LOOP_PERIOD, 1.0)
	var line_r: float = max(0.0, clamp(2.0 - f * 2.0, 0.0, 1.0) * float(projector_block_size(overdrive_projector)) * float(tile_size) / 2.0 - f - 0.2)
	var line_w: float = clamp(0.5 - f, 0.0, 1.0) * float(projector_block_size(overdrive_projector)) * float(tile_size)
	return {
		"visible": true,
		"f": f,
		"base_color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
		"phase_color": str(properties.get("phaseColor", "ffd59e")),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_math_state.source_absin(source_time_ticks, 50.0 / source_math_defaults.PI2, 1.0) * 0.5 * lod_alpha2,
		"top_rect": true,
		"lod_alpha2": lod_alpha2,
		"stroke": (2.0 * f + 0.1) * heat,
		"line_r": line_r,
		"line_w": line_w,
	}
