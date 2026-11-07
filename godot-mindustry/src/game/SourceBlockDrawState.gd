extends RefCounted
class_name SourceBlockDrawState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_draw_source_text_state := preload("res://src/game/SourceBlockDrawSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_DRAW_SOURCE := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SOURCE
const SOURCE_BLOCK_DRAW_BASE_METHOD := source_block_source_text_state.SOURCE_BLOCK_DRAW_BASE_METHOD
const SOURCE_BLOCK_DRAW_BASE_CACHED_METHOD := source_block_source_text_state.SOURCE_BLOCK_DRAW_BASE_CACHED_METHOD
const SOURCE_BLOCK_DRAW_SHADOW_METHOD := source_block_source_text_state.SOURCE_BLOCK_DRAW_SHADOW_METHOD
const SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_METHOD := source_block_source_text_state.SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_METHOD
const SOURCE_BLOCK_DRAW_PLACE_METHOD := source_block_source_text_state.SOURCE_BLOCK_DRAW_PLACE_METHOD
const SOURCE_BLOCK_DRAW_OVERLAY_METHOD := source_block_source_text_state.SOURCE_BLOCK_DRAW_OVERLAY_METHOD
const SOURCE_BLOCK_DISPLAY_SHADOW_METHOD := source_block_source_text_state.SOURCE_BLOCK_DISPLAY_SHADOW_METHOD
const SOURCE_BLOCK_DRAW_BASE_BUILD_GUARD_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_BUILD_GUARD_EXPR
const SOURCE_BLOCK_DRAW_BASE_BUILD_DRAW_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_BUILD_DRAW_CALL
const SOURCE_BLOCK_DRAW_BASE_CACHED_BUILD_GUARD_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_CACHED_BUILD_GUARD_EXPR
const SOURCE_BLOCK_DRAW_BASE_CACHED_BUILD_DRAW_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_CACHED_BUILD_DRAW_CALL
const SOURCE_BLOCK_DRAW_BASE_DRAW_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_DRAW_CALL
const SOURCE_BLOCK_DRAW_SHADOW_COLOR_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SHADOW_COLOR_EXPR
const SOURCE_BLOCK_DRAW_SHADOW_DRAW_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SHADOW_DRAW_CALL
const SOURCE_BLOCK_DRAW_SHADOW_RESET_COLOR_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SHADOW_RESET_COLOR_EXPR
const SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_CALL
const SOURCE_BLOCK_DRAW_PLACE_LINKS_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_LINKS_CALL
const SOURCE_BLOCK_DRAW_PLACE_OVERLAY_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_OVERLAY_CALL
const SOURCE_BLOCK_DRAW_OVERLAY_COMMENT := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_OVERLAY_COMMENT
const SOURCE_BLOCK_DISPLAY_SHADOW_RETURN_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DISPLAY_SHADOW_RETURN_EXPR
const SOURCE_BLOCK_DRAW_BASE_JAVA_METHOD_DRAW_BASE_0 := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_JAVA_METHOD_DRAW_BASE_0
const SOURCE_BLOCK_DRAW_BASE_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_BASE_CACHED_JAVA_METHOD_DRAW_BASE_CACHED_1 := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_CACHED_JAVA_METHOD_DRAW_BASE_CACHED_1
const SOURCE_BLOCK_DRAW_BASE_CACHED_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_BASE_CACHED_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_SHADOW_JAVA_METHOD_DRAW_SHADOW_2 := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SHADOW_JAVA_METHOD_DRAW_SHADOW_2
const SOURCE_BLOCK_DRAW_SHADOW_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SHADOW_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_JAVA_METHOD_DRAW_ENVIRONMENT_LIGHT_4 := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_JAVA_METHOD_DRAW_ENVIRONMENT_LIGHT_4
const SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_PLACE_JAVA_METHOD_DRAW_PLACE_5 := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_JAVA_METHOD_DRAW_PLACE_5
const SOURCE_BLOCK_DRAW_PLACE_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_OVERLAY_JAVA_METHOD_DRAW_OVERLAY_10 := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_OVERLAY_JAVA_METHOD_DRAW_OVERLAY_10
const SOURCE_BLOCK_DRAW_OVERLAY_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_OVERLAY_GENERATED_OWNER
const SOURCE_BLOCK_DISPLAY_SHADOW_JAVA_METHOD_DISPLAY_SHADOW_11 := source_block_draw_source_text_state.SOURCE_BLOCK_DISPLAY_SHADOW_JAVA_METHOD_DISPLAY_SHADOW_11
const SOURCE_BLOCK_DISPLAY_SHADOW_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DISPLAY_SHADOW_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_SIDE_REGION_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SIDE_REGION_METHOD
const SOURCE_BLOCK_DRAW_SIDE_REGION_DIRECTION_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SIDE_REGION_DIRECTION_EXPR
const SOURCE_BLOCK_DRAW_SIDE_REGION_HALF_SIZE_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SIDE_REGION_HALF_SIZE_EXPR
const SOURCE_BLOCK_DRAW_SIDE_REGION_DRAW_CALL := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SIDE_REGION_DRAW_CALL
const SOURCE_BLOCK_DRAW_SIDE_REGION_JAVA_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SIDE_REGION_JAVA_METHOD
const SOURCE_BLOCK_DRAW_SIDE_REGION_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SIDE_REGION_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_METHOD
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_GATE_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_GATE_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_TILE_GUARD_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_TILE_GUARD_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_SCAN_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_SCAN_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_BEAM_SCAN_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_BEAM_SCAN_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_LASER_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_LASER_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_BEAM_LASER_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_BEAM_LASER_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_SQUARE_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_SQUARE_EXPR
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_JAVA_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_JAVA_METHOD
const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_METHOD
const SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD
const SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_DELEGATION_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_DELEGATION_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_PIXELATE_GUARD_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_PIXELATE_GUARD_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_FONT_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_FONT_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_SCALE_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_SCALE_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_LAYOUT_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_LAYOUT_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_POSITION_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_POSITION_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_DRAW_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_DRAW_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_LINE_GUARD_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_LINE_GUARD_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_DARK_LINE_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_DARK_LINE_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_LIGHT_LINE_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_LIGHT_LINE_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_RESET_EXPR := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_RESET_EXPR
const SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_JAVA_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_JAVA_METHOD
const SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_PLACE_TEXT_JAVA_METHOD := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_JAVA_METHOD
const SOURCE_BLOCK_DRAW_PLACE_TEXT_GENERATED_OWNER := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_GENERATED_OWNER
const SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY
const SOURCE_BLOCK_DRAW_SOURCE_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_SOURCE_KEY
const SOURCE_BLOCK_DRAW_METHOD_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_METHOD_KEY
const SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY
const SOURCE_BLOCK_DRAW_RESULT_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_RESULT_KEY
const SOURCE_BLOCK_DRAW_CANONICAL_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_CANONICAL_KEY
const SOURCE_BLOCK_DRAW_MATCHES_KEY := source_block_draw_source_text_state.SOURCE_BLOCK_DRAW_MATCHES_KEY

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func draw_base_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	var selected_region: Variant = region_value if variants == 0 else variant_region
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_BASE_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_BASE_METHOD, "build_guard_expr": SOURCE_BLOCK_DRAW_BASE_BUILD_GUARD_EXPR, "build_draw_call": SOURCE_BLOCK_DRAW_BASE_BUILD_DRAW_CALL, "draw_call": SOURCE_BLOCK_DRAW_BASE_DRAW_CALL, "tile_build_present": tile_build_present, "variants": variants, "region": region_value, "variant_region": variant_region, "selected_region": selected_region, "tile_drawx": tile_drawx, "tile_drawy": tile_drawy, "draw_delegated_to_build": tile_build_present}

static func generated_draw_base_result_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	return draw_base_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

static func draw_base_cached_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	var selected_region: Variant = region_value if variants == 0 else variant_region
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_BASE_CACHED_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_BASE_CACHED_METHOD, "build_guard_expr": SOURCE_BLOCK_DRAW_BASE_CACHED_BUILD_GUARD_EXPR, "build_draw_cached_call": SOURCE_BLOCK_DRAW_BASE_CACHED_BUILD_DRAW_CALL, "draw_call": SOURCE_BLOCK_DRAW_BASE_DRAW_CALL, "tile_build_present": tile_build_present, "variants": variants, "region": region_value, "variant_region": variant_region, "selected_region": selected_region, "tile_drawx": tile_drawx, "tile_drawy": tile_drawy, "draw_cached_delegated_to_build": tile_build_present}

static func generated_draw_base_cached_result_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	return draw_base_cached_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

static func draw_shadow_state(tile: Variant, variants: int, custom_shadow_region: Variant, variant_shadow_region: Variant, tile_drawx: float, tile_drawy: float, shadow_alpha: float) -> Dictionary:
	var shadow_region: Variant = custom_shadow_region if variants == 0 else variant_shadow_region
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_SHADOW_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_SHADOW_METHOD, "shadow_color_expr": SOURCE_BLOCK_DRAW_SHADOW_COLOR_EXPR, "draw_call": SOURCE_BLOCK_DRAW_SHADOW_DRAW_CALL, "reset_color_expr": SOURCE_BLOCK_DRAW_SHADOW_RESET_COLOR_EXPR, "tile": tile, "variants": variants, "custom_shadow_region": custom_shadow_region, "variant_shadow_region": variant_shadow_region, "shadow_region": shadow_region, "tile_drawx": tile_drawx, "tile_drawy": tile_drawy, "shadow_alpha": shadow_alpha}

static func generated_draw_shadow_result_state(tile: Variant, variants: int, custom_shadow_region: Variant, variant_shadow_region: Variant, tile_drawx: float, tile_drawy: float, shadow_alpha: float) -> Dictionary:
	return draw_shadow_state(tile, variants, custom_shadow_region, variant_shadow_region, tile_drawx, tile_drawy, shadow_alpha)

static func draw_environment_light_state(tile_worldx: float, tile_worldy: float, light_radius: float, light_color: Variant, light_alpha: float) -> Dictionary:
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_METHOD, "light_call": SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_CALL, "tile_worldx": tile_worldx, "tile_worldy": tile_worldy, "light_radius": light_radius, "light_color": light_color, "light_alpha": light_alpha}

static func generated_draw_environment_light_result_state(tile_worldx: float, tile_worldy: float, light_radius: float, light_color: Variant, light_alpha: float) -> Dictionary:
	return draw_environment_light_state(tile_worldx, tile_worldy, light_radius, light_color, light_alpha)

static func draw_place_state(x_value: int, y_value: int, rotation: int, valid: bool, source_tilesize: float, offset_value: float) -> Dictionary:
	var overlay_x: float = float(x_value) * source_tilesize + offset_value
	var overlay_y: float = float(y_value) * source_tilesize + offset_value
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_PLACE_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_PLACE_METHOD, "draw_potential_links_call": SOURCE_BLOCK_DRAW_PLACE_LINKS_CALL, "draw_overlay_call": SOURCE_BLOCK_DRAW_PLACE_OVERLAY_CALL, "x": x_value, "y": y_value, "rotation": rotation, "valid": valid, "tilesize": source_tilesize, "offset": offset_value, "overlay_x": overlay_x, "overlay_y": overlay_y}

static func generated_draw_place_result_state(x_value: int, y_value: int, rotation: int, valid: bool, source_tilesize: float, offset_value: float) -> Dictionary:
	return draw_place_state(x_value, y_value, rotation, valid, source_tilesize, offset_value)

static func draw_overlay_state(x_value: float, y_value: float, rotation: int) -> Dictionary:
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_OVERLAY_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, "comment": SOURCE_BLOCK_DRAW_OVERLAY_COMMENT, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_OVERLAY_METHOD, "x": x_value, "y": y_value, "rotation": rotation, "noop": true}

static func generated_draw_overlay_result_state(x_value: float, y_value: float, rotation: int) -> Dictionary:
	return draw_overlay_state(x_value, y_value, rotation)

static func display_shadow_state(has_shadow: bool, tile: Variant) -> Dictionary:
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DISPLAY_SHADOW_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DISPLAY_SHADOW_METHOD, "return_expr": SOURCE_BLOCK_DISPLAY_SHADOW_RETURN_EXPR, "hasShadow": has_shadow, "tile": tile, "display_shadow": has_shadow}

static func generated_display_shadow_result_state(has_shadow: bool, tile: Variant) -> Dictionary:
	return display_shadow_state(has_shadow, tile)

static func draw_side_region_state(region_width: float, region_scale: float, x_value: float, y_value: float, block_size: float, source_tilesize: float, rotation: int) -> Dictionary:
	var direction: Vector2 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP][posmod(rotation, 4)]
	var half_size: float = block_size * source_tilesize / 2.0
	var edge_offset: float = half_size - region_width / 2.0 * region_scale
	var draw_position := Vector2(x_value, y_value) + direction * edge_offset
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_SIDE_REGION_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_SIDE_REGION_METHOD, "direction_expr": SOURCE_BLOCK_DRAW_SIDE_REGION_DIRECTION_EXPR, "half_size_expr": SOURCE_BLOCK_DRAW_SIDE_REGION_HALF_SIZE_EXPR, "draw_call": SOURCE_BLOCK_DRAW_SIDE_REGION_DRAW_CALL, "region_width": region_width, "region_scale": region_scale, "x": x_value, "y": y_value, "size": block_size, "tilesize": source_tilesize, "rotation": rotation, "direction": direction, "edge_offset": edge_offset, "draw_x": draw_position.x, "draw_y": draw_position.y, "draw_rotation": float(rotation) * 90.0}

static func generated_draw_side_region_result_state(region_width: float, region_scale: float, x_value: float, y_value: float, block_size: float, source_tilesize: float, rotation: int) -> Dictionary:
	return draw_side_region_state(region_width, region_scale, x_value, y_value, block_size, source_tilesize, rotation)

static func generated_block_draw_side_region_bridge_state(region_width: float, region_scale: float, x_value: float, y_value: float, block_size: float, source_tilesize: float, rotation: int) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_SIDE_REGION_JAVA_METHOD, [region_width, region_scale, x_value, y_value, block_size, source_tilesize, rotation])
	var canonical = draw_side_region_state(region_width, region_scale, x_value, y_value, block_size, source_tilesize, rotation)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_SIDE_REGION_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_SIDE_REGION_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func draw_potential_links_state(consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, tile_present: bool, x_value: int, y_value: int, source_tilesize: float, offset_value: float, block_size: float, power_links: Array, beam_links: Array) -> Dictionary:
	var active: bool = (consumes_power or outputs_power) and has_power and connected_power and tile_present
	var power_calls: Array = []
	var beam_calls: Array = []
	if active:
		for link in power_links:
			power_calls.append({"link": link, "laser_from": Vector2(float(x_value) * source_tilesize + offset_value, float(y_value) * source_tilesize + offset_value), "laser_to": Vector2(float(link.get("x", 0.0)), float(link.get("y", 0.0))), "square": true})
		for link in beam_links:
			beam_calls.append({"link": link, "laser_from": Vector2(float(link.get("x", 0.0)), float(link.get("y", 0.0))), "laser_to": Vector2(float(x_value) * source_tilesize + offset_value, float(y_value) * source_tilesize + offset_value), "square": true})
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_METHOD, "power_gate_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_GATE_EXPR, "tile_guard_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_TILE_GUARD_EXPR, "power_scan_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_SCAN_EXPR, "beam_scan_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_BEAM_SCAN_EXPR, "power_laser_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_POWER_LASER_EXPR, "beam_laser_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_BEAM_LASER_EXPR, "square_expr": SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_SQUARE_EXPR, "active": active, "consumes_power": consumes_power, "outputs_power": outputs_power, "has_power": has_power, "connected_power": connected_power, "tile_present": tile_present, "x": x_value, "y": y_value, "tilesize": source_tilesize, "offset": offset_value, "size": block_size, "power_calls": power_calls, "beam_calls": beam_calls}

static func generated_draw_potential_links_result_state(consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, tile_present: bool, x_value: int, y_value: int, source_tilesize: float, offset_value: float, block_size: float, power_links: Array, beam_links: Array) -> Dictionary:
	return draw_potential_links_state(consumes_power, outputs_power, has_power, connected_power, tile_present, x_value, y_value, source_tilesize, offset_value, block_size, power_links, beam_links)

static func generated_block_draw_potential_links_bridge_state(consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, tile_present: bool, x_value: int, y_value: int, source_tilesize: float, offset_value: float, block_size: float, power_links: Array, beam_links: Array) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_JAVA_METHOD, [consumes_power, outputs_power, has_power, connected_power, tile_present, x_value, y_value, source_tilesize, offset_value, block_size, power_links, beam_links])
	var canonical = draw_potential_links_state(consumes_power, outputs_power, has_power, connected_power, tile_present, x_value, y_value, source_tilesize, offset_value, block_size, power_links, beam_links)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func draw_place_text_state(pixelate: bool, text_value: String, x_value: int, y_value: int, color: Variant, draw_line: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	var dx: float = float(x_value) * source_tilesize + offset_value
	var dy: float = float(y_value) * source_tilesize + offset_value + block_size * source_tilesize / 2.0 + 3.0
	var visible: bool = not pixelate
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_PLACE_TEXT_STATE, SOURCE_BLOCK_DRAW_SOURCE_KEY: SOURCE_BLOCK_DRAW_SOURCE, SOURCE_BLOCK_DRAW_METHOD_KEY: SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD, "pixelate_guard_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_PIXELATE_GUARD_EXPR, "font_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_FONT_EXPR, "scale_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_SCALE_EXPR, "layout_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_LAYOUT_EXPR, "position_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_POSITION_EXPR, "draw_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_DRAW_EXPR, "line_guard_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_LINE_GUARD_EXPR, "dark_line_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_DARK_LINE_EXPR, "light_line_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_LIGHT_LINE_EXPR, "reset_expr": SOURCE_BLOCK_DRAW_PLACE_TEXT_RESET_EXPR, "pixelate": pixelate, "text": text_value, "x": x_value, "y": y_value, "color": color, "draw_line": draw_line, "tilesize": source_tilesize, "offset": offset_value, "size": block_size, "layout_width": layout_width, "layout_height": layout_height, "dx": dx, "dy": dy, "text_draw_y": dy + layout_height + 1.0, "line_y": dy - 1.0, "line_x1": dx - layout_width / 2.0 - 2.0, "line_x2": dx + layout_width / 2.0 + 1.5, "visible": visible, "returned_width": 0.0 if pixelate else layout_width}

static func generated_draw_place_text_result_state(pixelate: bool, text_value: String, x_value: int, y_value: int, color: Variant, draw_line: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	return draw_place_text_state(pixelate, text_value, x_value, y_value, color, draw_line, source_tilesize, offset_value, block_size, layout_width, layout_height)

static func draw_place_text_simple_state(pixelate: bool, text_value: String, x_value: int, y_value: int, valid: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	var color: String = "Pal.accent" if valid else "Pal.remove"
	var result := draw_place_text_state(pixelate, text_value, x_value, y_value, color, true, source_tilesize, offset_value, block_size, layout_width, layout_height)
	result["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_STATE
	result["method"] = SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_METHOD
	result["delegation_expr"] = SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_DELEGATION_EXPR
	result["valid"] = valid
	return result

static func generated_draw_place_text_simple_result_state(pixelate: bool, text_value: String, x_value: int, y_value: int, valid: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	return draw_place_text_simple_state(pixelate, text_value, x_value, y_value, valid, source_tilesize, offset_value, block_size, layout_width, layout_height)

static func generated_block_draw_place_text_bridge_state(pixelate: bool, text_value: String, x_value: int, y_value: int, color: Variant, draw_line: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_PLACE_TEXT_JAVA_METHOD, [pixelate, text_value, x_value, y_value, color, draw_line, source_tilesize, offset_value, block_size, layout_width, layout_height])
	var canonical = draw_place_text_state(pixelate, text_value, x_value, y_value, color, draw_line, source_tilesize, offset_value, block_size, layout_width, layout_height)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_PLACE_TEXT_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_PLACE_TEXT_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_place_text_simple_bridge_state(pixelate: bool, text_value: String, x_value: int, y_value: int, valid: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_JAVA_METHOD, [pixelate, text_value, x_value, y_value, valid, source_tilesize, offset_value, block_size, layout_width, layout_height])
	var canonical = draw_place_text_simple_state(pixelate, text_value, x_value, y_value, valid, source_tilesize, offset_value, block_size, layout_width, layout_height)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_PLACE_TEXT_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_base_bridge_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_BASE_JAVA_METHOD_DRAW_BASE_0, [tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy])
	var canonical = draw_base_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_BASE_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_BASE_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_base_cached_bridge_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_BASE_CACHED_JAVA_METHOD_DRAW_BASE_CACHED_1, [tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy])
	var canonical = draw_base_cached_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_BASE_CACHED_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_BASE_CACHED_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_shadow_bridge_state(tile: Variant, variants: int, custom_shadow_region: Variant, variant_shadow_region: Variant, tile_drawx: float, tile_drawy: float, shadow_alpha: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_SHADOW_JAVA_METHOD_DRAW_SHADOW_2, [tile, variants, custom_shadow_region, variant_shadow_region, tile_drawx, tile_drawy, shadow_alpha])
	var canonical = draw_shadow_state(tile, variants, custom_shadow_region, variant_shadow_region, tile_drawx, tile_drawy, shadow_alpha)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_SHADOW_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_SHADOW_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_environment_light_bridge_state(tile_worldx: float, tile_worldy: float, light_radius: float, light_color: Variant, light_alpha: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_JAVA_METHOD_DRAW_ENVIRONMENT_LIGHT_4, [tile_worldx, tile_worldy, light_radius, light_color, light_alpha])
	var canonical = draw_environment_light_state(tile_worldx, tile_worldy, light_radius, light_color, light_alpha)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_ENVIRONMENT_LIGHT_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_place_bridge_state(x_value: int, y_value: int, rotation: int, valid: bool, source_tilesize: float, offset_value: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_PLACE_JAVA_METHOD_DRAW_PLACE_5, [x_value, y_value, rotation, valid, source_tilesize, offset_value])
	var canonical = draw_place_state(x_value, y_value, rotation, valid, source_tilesize, offset_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_PLACE_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_PLACE_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_draw_overlay_bridge_state(x_value: float, y_value: float, rotation: int) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DRAW_OVERLAY_JAVA_METHOD_DRAW_OVERLAY_10, [x_value, y_value, rotation])
	var canonical = draw_overlay_state(x_value, y_value, rotation)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DRAW_OVERLAY_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DRAW_OVERLAY_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}

static func generated_block_display_shadow_bridge_state(has_shadow: bool, tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_DISPLAY_SHADOW_JAVA_METHOD_DISPLAY_SHADOW_11, [has_shadow, tile])
	var canonical = display_shadow_state(has_shadow, tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {SOURCE_BLOCK_DRAW_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_DISPLAY_SHADOW_STATE, SOURCE_BLOCK_DRAW_GENERATED_OWNER_KEY: SOURCE_BLOCK_DISPLAY_SHADOW_GENERATED_OWNER, SOURCE_BLOCK_DRAW_RESULT_KEY: result, SOURCE_BLOCK_DRAW_CANONICAL_KEY: canonical, SOURCE_BLOCK_DRAW_MATCHES_KEY: matches}
