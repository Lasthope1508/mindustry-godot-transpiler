extends Node2D
class_name PortGame

const CONFIG_PATH := "res://src/generated/playable_content.json"
const SOURCE_SYMBOL_REGISTRY_PATH := "res://src/generated/source_symbol_registry.json"
const SOURCE_SYMBOL_AUDIT_REPORT_PATH := "res://src/generated/source_symbol_audit_report.json"
const SOURCE_SLICE_LEDGER_PATH := "res://src/generated/source_slice_ledger.json"
const SOURCE_API_CONTRACTS_PATH := "res://src/generated/source_api_contracts.json"
const SOURCE_STATE_SCHEMA_PATH := "res://src/generated/source_state_schema.json"
const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const GeneratedClassRegistry := preload("res://src/generated/GeneratedClassRegistry.gd")
const ContentCatalog := preload("res://src/mindustry/content/ContentCatalog.gd")
const WORLD_W := 24
const WORLD_H := 16
const PINNED_BUILD_BLOCK_IDS := ["conveyor", "router", "junction", "mechanical-drill", "duo", "copper-wall"]
const SELECTED_GENERATED_CLASS_NAMES := ["Items", "Blocks", "UnitTypes", "Damage"]
const SOURCE_DRILL_HARDNESS_MULTIPLIER := 50.0
const SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT := 300.0
const SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT := 0
const SOURCE_DRILL_WARMUP_SPEED := 0.015
const SOURCE_BLOCK_DUMP_TIME := 5.0
const SOURCE_CONVEYOR_TILE_SPEED_SCALE := 55.0
const SOURCE_TICK_RATE := 60.0
const SOURCE_TILESIZE := 8.0
const SOURCE_UNIT_WARP_DST := 8.0
const SOURCE_FINAL_WORLD_BOUNDS := 250.0
const SOURCE_FLOAT_ROUNDING_ERROR := 0.000001
const SOURCE_RECOIL_POW := 1.8
const SOURCE_PI2 := PI * 2.0
const SOURCE_ARC_PI := 3.1415927
const SOURCE_ARC_RAD_FULL := SOURCE_ARC_PI * 2.0
const SOURCE_ARC_SIN_BITS := 14
const SOURCE_ARC_SIN_MASK := 16383
const SOURCE_ARC_SIN_COUNT := SOURCE_ARC_SIN_MASK + 1
const SOURCE_ARC_RAD_TO_INDEX := SOURCE_ARC_SIN_COUNT / SOURCE_ARC_RAD_FULL
const SOURCE_INT64_MIN := -9223372036854775807 - 1
const SOURCE_INT64_MAX := 9223372036854775807
const SOURCE_RAND_MURMUR_CONST1 := -49064778989728563
const SOURCE_RAND_MURMUR_CONST2 := -4265267296055464877
const SOURCE_UINT16_MASK := 65535
const SOURCE_RAND_NORM_FLOAT := 1.0 / 16777216.0
const SOURCE_RAND_MURMUR_CONST1_WORDS := [0x8ccd, 0xed55, 0xafd7, 0xff51]
const SOURCE_RAND_MURMUR_CONST2_WORDS := [0xec53, 0x1a85, 0xb9fe, 0xc4ce]
const SOURCE_LONG_MIN_WORDS := [0, 0, 0, 0x8000]

var tile_size := 32
var config: Dictionary = {}
var textures: Dictionary = {}
var block_texture_cache: Dictionary = {}
var content_counts: Dictionary = {"items": 0, "liquids": 0, "blocks": 0, "units": 0}
var generated_class_count := 0
var loaded_generated_scripts: Dictionary = {}
var loaded_generated_class_names: Array[String] = []
var loaded_generated_instances: Dictionary = {}
var loaded_generated_instance_names: Array[String] = []
var all_generated_scripts: Dictionary = {}
var all_generated_instances: Dictionary = {}
var all_generated_load_failures: Array[String] = []
var all_generated_instance_failures: Array[String] = []
var content_catalog: RefCounted
var build_palette: Array = []
var selected_build_index := 0
var ore_items_by_cell: Dictionary = {}
var placed_blocks: Dictionary = {}
var placed_block_origins: Dictionary = {}
var mend_projector_charges: Dictionary = {}
var mend_projector_smooth_efficiency: Dictionary = {}
var mend_projector_heat: Dictionary = {}
var mend_projector_phase_heat: Dictionary = {}
var mend_projector_optional_efficiency: Dictionary = {}
var mend_projector_booster_items: Dictionary = {}
var mend_projector_booster_timers: Dictionary = {}
var overdrive_projector_charges: Dictionary = {}
var overdrive_projector_smooth_efficiency: Dictionary = {}
var overdrive_projector_heat: Dictionary = {}
var overdrive_projector_phase_heat: Dictionary = {}
var overdrive_projector_optional_efficiency: Dictionary = {}
var overdrive_projector_booster_items: Dictionary = {}
var overdrive_projector_use_progress: Dictionary = {}
var initial_world_block_count := 0
var initial_occupied_cell_count := 0
var last_placed_block_id := ""
var last_placed_block_size := 0
var last_placed_cell := Vector2i.ZERO
var last_placed_occupied_cell_count := 0
var last_place_blocked := false
var last_mend_projector_healed_amount := 0.0
var last_mend_projector_healed_block_id := ""
var last_mend_projector_healed_cell := Vector2i.ZERO
var last_overdrive_projector_boost_range := 0.0
var last_overdrive_projector_boost := 0.0
var last_overdrive_projector_boost_duration := 0.0
var last_overdrive_projector_boosted_block_id := ""
var last_overdrive_projector_boosted_cell := Vector2i.ZERO
var core_inventory := 0
var core_items: Dictionary = {"copper": 0}
var core_item_capacity := 0
var core_incinerates := true
var core_incinerate_non_buildable := false
var core_max_health := 0.0
var core_health := 0.0
var drill_output_item_id := "copper"
var drill_ore_cell_count := 0
var drill_output_rate := 0.0
var drill_warmups: Dictionary = {}
var drill_time_drilled: Dictionary = {}
var drill_last_speeds: Dictionary = {}
var drill_items: Dictionary = {}
var drill_dump_timer := 0.0
var drill_dump_cursor := 0
var building_dump_accum := 0.0
var produced_total := 0
var item_progress := 0.0
var transport_progress := 0.0
var conveyor_world_speed := 0.0
var conveyor_path_progress_rate := 0.0
var item_sprites: Array[Sprite2D] = []
var enemy_units: Array = []
var bullets: Array = []
var turret_cells: Array = []
var turret_cooldowns: Dictionary = {}
var turret_ammo_stacks: Dictionary = {}
var turret_total_ammo: Dictionary = {}
var turret_barrel_counters: Dictionary = {}
var turret_rotations: Dictionary = {}
var turret_recoils: Dictionary = {}
var turret_shot_count := 0
var last_turret_fired_ammo_item := ""
var last_turret_fired_damage := 0.0
var last_turret_fired_reload_multiplier := 1.0
var last_turret_fired_range := 0.0
var last_turret_fired_shoot_y := 0.0
var last_turret_fired_shoot_x_offset := 0.0
var last_turret_fired_inaccuracy_range := 0.0
var last_turret_fired_inaccuracy_offset := 0.0
var last_turret_target_rotation := 0.0
var last_turret_rotation := 0.0
var last_turret_angle_delta := 0.0
var last_turret_recoil := 0.0
var last_turret_recoils := 0
var last_turret_cur_recoil := 0.0
var last_turret_recoil_offset := Vector2.ZERO
var wave_index := 1
var wave_cooldown := 0.0
var path_points: Array[Vector2] = []
var hud_label: Label
var camera: Camera2D
var drill_pos := Vector2i(7, 8)
var core_pos := Vector2i(17, 8)
var duo_pos := Vector2i(18, 7)

func _ready() -> void:
	load_config()
	load_content_registry()
	load_textures()
	bind_nodes()
	build_block_palette()
	build_world()
	build_hud()

func load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("Missing playable content manifest: " + CONFIG_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
		tile_size = int(config.get("tile_size", 32))

func source_symbol_registry_state(symbol: String = "") -> Dictionary:
	var text := FileAccess.get_file_as_string(SOURCE_SYMBOL_REGISTRY_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "count": 0, "symbol": symbol, "entry": {}}
	var symbols: Dictionary = parsed.get("symbols", {})
	var entry: Dictionary = {}
	if symbol != "":
		entry = symbols.get(symbol, {})
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": symbols.size(),
		"symbol": symbol,
		"entry": entry,
	}

func source_symbol_audit_state() -> Dictionary:
	var text := FileAccess.get_file_as_string(SOURCE_SYMBOL_AUDIT_REPORT_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "totalSourceFunctions": 0, "legacyUnregisteredOwnerCount": 0}
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"totalSourceFunctions": int(parsed.get("totalSourceFunctions", 0)),
		"registeredSourceOwnerCount": int(parsed.get("registeredSourceOwnerCount", 0)),
		"exemptSourceOwnerCount": int(parsed.get("exemptSourceOwnerCount", 0)),
		"legacyUnregisteredOwnerCount": int(parsed.get("legacyUnregisteredOwnerCount", 0)),
		"policy": parsed.get("policy", {}),
	}

func source_slice_ledger_state(slice_id: String = "") -> Dictionary:
	var text := FileAccess.get_file_as_string(SOURCE_SLICE_LEDGER_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "count": 0, "sliceId": slice_id, "entry": {}}
	var slices: Dictionary = parsed.get("slices", {})
	var entry: Dictionary = {}
	if slice_id != "":
		entry = slices.get(slice_id, {})
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": slices.size(),
		"sliceId": slice_id,
		"entry": entry,
		"policy": parsed.get("policy", {}),
	}

func source_api_contract_state(contract_owner: String = "") -> Dictionary:
	var text := FileAccess.get_file_as_string(SOURCE_API_CONTRACTS_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "count": 0, "owner": contract_owner, "entry": {}}
	var contracts: Dictionary = parsed.get("contracts", {})
	var entry: Dictionary = {}
	if contract_owner != "":
		entry = contracts.get(contract_owner, {})
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": contracts.size(),
		"owner": contract_owner,
		"entry": entry,
		"policy": parsed.get("policy", {}),
	}

func source_state_schema_state(schema_name: String = "") -> Dictionary:
	var text := FileAccess.get_file_as_string(SOURCE_STATE_SCHEMA_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"loaded": false, "count": 0, "schemaName": schema_name, "entry": {}}
	var schemas: Dictionary = parsed.get("schemas", {})
	var entry: Dictionary = {}
	if schema_name != "":
		entry = schemas.get(schema_name, {})
	return {
		"loaded": true,
		"version": int(parsed.get("version", 0)),
		"count": schemas.size(),
		"schemaName": schema_name,
		"entry": entry,
		"policy": parsed.get("policy", {}),
	}

func load_content_registry() -> void:
	content_catalog = ContentCatalog.new()
	content_counts = content_catalog.counts()
	generated_class_count = GeneratedClassRegistry.count()
	load_all_generated_scripts()
	load_selected_generated_scripts()
	if content_counts != ContentRegistry.counts():
		push_error("Generated registry counts do not match loaded content catalog")

func load_all_generated_scripts() -> void:
	all_generated_scripts.clear()
	all_generated_instances.clear()
	all_generated_load_failures.clear()
	all_generated_instance_failures.clear()
	for entry in GeneratedClassRegistry.all_classes():
		var java_key := "%s.%s" % [str(entry.get("java_package", "")), str(entry.get("java_name", ""))]
		var script = ResourceLoader.load(str(entry.get("gdscript_path", "")))
		if script == null:
			all_generated_load_failures.append(java_key)
			continue
		all_generated_scripts[java_key] = script
		var instance = script.new()
		if instance == null:
			all_generated_instance_failures.append(java_key)
			continue
		all_generated_instances[java_key] = instance

func load_selected_generated_scripts() -> void:
	loaded_generated_scripts.clear()
	loaded_generated_class_names.clear()
	loaded_generated_instances.clear()
	loaded_generated_instance_names.clear()
	for java_name in SELECTED_GENERATED_CLASS_NAMES:
		var entry := GeneratedClassRegistry.find_by_java_name(java_name)
		if entry.is_empty():
			push_error("Generated class missing from registry: " + java_name)
			continue
		var script = ResourceLoader.load(str(entry.get("gdscript_path", "")))
		if script == null:
			push_error("Generated class script failed to load: " + java_name)
			continue
		loaded_generated_scripts[java_name] = script
		loaded_generated_class_names.append(java_name)
		var instance = script.new()
		if instance == null:
			push_error("Generated class script failed to instantiate: " + java_name)
			continue
		loaded_generated_instances[java_name] = instance
		loaded_generated_instance_names.append(java_name)

func load_textures() -> void:
	if config.is_empty():
		return
	textures["item"] = load_png_texture(config["item"]["texture"])
	for key in config["blocks"].keys():
		textures[key] = load_png_texture(config["blocks"][key]["texture"])
	for unit in content_catalog.get_many("unit"):
		if unit.has_texture():
			textures["unit:" + unit.id] = load_png_texture(unit.texture_path)

func build_block_palette() -> void:
	build_palette.clear()
	if content_catalog == null:
		return
	for block_id in PINNED_BUILD_BLOCK_IDS:
		var block = content_catalog.get_by_id(block_id)
		if block != null and block.has_texture():
			build_palette.append(block)
	for block in content_catalog.get_many("block"):
		if block.has_texture() and not build_palette.has(block):
			build_palette.append(block)


func load_png_texture(path: String) -> Texture2D:
	var resource := ResourceLoader.load(path)
	if resource is Texture2D:
		return resource
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("Could not load texture: " + path)
		return null
	return ImageTexture.create_from_image(image)

func bind_nodes() -> void:
	camera = get_node_or_null("Camera2D")
	if camera:
		camera.make_current()
	hud_label = Label.new()
	hud_label.position = Vector2(16, 16)
	var hud := get_node_or_null("UI/Hud")
	if hud:
		hud.add_child(hud_label)

func build_world() -> void:
	var terrain := get_node("World/TerrainLayer")
	var blocks := get_node("World/BlockLayer")
	var units := get_node("World/UnitLayer")
	ore_items_by_cell.clear()
	for y in WORLD_H:
		for x in WORLD_W:
			add_sprite(terrain, "stone_floor", grid_to_world(Vector2i(x, y)))
	for y in range(6, 11):
		for x in range(5, 8):
			add_ore_cell(terrain, "ore_copper", "copper", Vector2i(x, y))
	add_source_block(blocks, "mechanical-drill", drill_pos)
	drill_ore_cell_count = source_drill_ore_count("mechanical-drill", drill_pos, drill_output_item_id)
	drill_output_rate = source_drill_output_rate("mechanical-drill", drill_output_item_id, drill_ore_cell_count)
	for x in range(drill_pos.x + 1, core_pos.x):
		add_source_block(blocks, "conveyor", Vector2i(x, drill_pos.y))
	add_source_block(blocks, "core-shard", core_pos)
	core_max_health = source_block_health("core-shard")
	core_item_capacity = source_block_item_capacity("core-shard")
	core_health = core_max_health
	add_source_block(blocks, "duo", duo_pos)
	initial_world_block_count = placed_block_origins.size()
	initial_occupied_cell_count = placed_blocks.size()
	path_points.clear()
	for x in range(drill_pos.x + 1, core_pos.x + 1):
		path_points.append(grid_to_world(Vector2i(x, drill_pos.y)))
	conveyor_world_speed = source_conveyor_world_speed("conveyor")
	conveyor_path_progress_rate = source_conveyor_path_progress_rate("conveyor")
	for i in 3:
		var sprite := add_sprite(units, "item", path_points[0])
		sprite.visible = false
		item_sprites.append(sprite)
	spawn_enemy_wave()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		select_build_slot(event.keycode)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		place_selected_block_at_world(event.position)

func select_build_slot(keycode: int) -> void:
	if keycode == KEY_TAB:
		if Input.is_key_pressed(KEY_SHIFT):
			select_previous_build_slot()
		else:
			select_next_build_slot()
		return
	if keycode < KEY_1 or keycode > KEY_6:
		return
	var index := keycode - KEY_1
	if index < build_palette.size():
		selected_build_index = index

func select_next_build_slot() -> void:
	if build_palette.is_empty():
		return
	selected_build_index = (selected_build_index + 1) % build_palette.size()

func select_previous_build_slot() -> void:
	if build_palette.is_empty():
		return
	selected_build_index = (selected_build_index - 1 + build_palette.size()) % build_palette.size()

func select_build_block_by_id(block_id: String) -> bool:
	for index in build_palette.size():
		if build_palette[index].id == block_id:
			selected_build_index = index
			return true
	return false

func selected_build_health() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	return float(selected.properties.get("health", 0.0))

func selected_build_scaled_health() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	return float(selected.properties.get("scaledHealth", 0.0))

func selected_build_heal_percent() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	return float(selected.properties.get("healPercent", 0.0))

func selected_build_phase_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	return float(selected.properties.get("phaseBoost", 0.0))

func selected_build_phase_range_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	return float(selected.properties.get("phaseRangeBoost", 0.0))

func selected_build_can_overdrive() -> bool:
	if build_palette.is_empty():
		return true
	var selected = build_palette[selected_build_index]
	return bool(selected.properties.get("canOverdrive", true))

func source_overdrive_projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	if overdrive_projector == null:
		return 0.0
	var base_range := float(overdrive_projector.properties.get("range", 0.0))
	var phase_range_boost := float(overdrive_projector.properties.get("phaseRangeBoost", 0.0))
	return base_range + phase_heat * phase_range_boost

func source_overdrive_projector_select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	if overdrive_projector == null:
		return {"range": 0.0, "color": ""}
	return {
		"range": source_overdrive_projector_range(overdrive_projector, phase_heat),
		"color": str(overdrive_projector.properties.get("baseColor", "")),
	}

func source_overdrive_projector_place_state(overdrive_projector) -> Dictionary:
	return source_overdrive_projector_select_state(overdrive_projector, 0.0)

func source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	if overdrive_projector == null or target_block == null:
		return {"real_range": 0.0, "distance": distance, "can_overdrive": false, "in_range": false, "eligible": false}
	var real_range := source_overdrive_projector_range(overdrive_projector, phase_heat)
	var can_overdrive := bool(target_block.properties.get("canOverdrive", true))
	var in_range := distance <= real_range
	return {
		"real_range": real_range,
		"distance": distance,
		"can_overdrive": can_overdrive,
		"in_range": in_range,
		"eligible": in_range and can_overdrive,
	}

func selected_build_overdrive_target_filter_state_for_block_id(target_block_id: String, distance: float, phase_heat := 0.0) -> Dictionary:
	if build_palette.is_empty() or content_catalog == null:
		return {"real_range": 0.0, "distance": distance, "can_overdrive": false, "in_range": false, "eligible": false}
	var selected = build_palette[selected_build_index]
	var target = content_catalog.get_by_id(target_block_id)
	if selected.implementation != "OverdriveProjector":
		return {"real_range": 0.0, "distance": distance, "can_overdrive": false, "in_range": false, "eligible": false}
	return source_overdrive_projector_target_filter_state(selected, target, distance, phase_heat)

func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:
	var result := {"time_scale": current_time_scale, "time_scale_duration": current_duration}
	if not can_overdrive:
		return result
	if intensity >= current_time_scale - 0.001:
		result["time_scale_duration"] = max(current_duration, duration)
	result["time_scale"] = max(current_time_scale, intensity)
	return result

func source_building_time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float) -> Dictionary:
	var decayed_duration := current_duration - source_delta
	var result := {"field": "private transient float timeScale = 1f, timeScaleDuration;", "method": "public void update(){", "decay_gate": "if((timeScaleDuration -= Time.delta) <= 0f){", "reset": "timeScale = 1f;", "time_scale": current_time_scale, "time_scale_duration": decayed_duration}
	if float(result["time_scale_duration"]) <= 0.0:
		result["time_scale"] = 1.0
	return result

func source_building_delta(source_delta: float, time_scale: float) -> float:
	return source_delta * time_scale

func source_building_edelta(source_delta: float, time_scale: float, efficiency: float) -> float:
	return efficiency * source_building_delta(source_delta, time_scale)

func source_overdrive_projector_light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	if overdrive_projector == null or not bool(overdrive_projector.properties.get("emitLight", false)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return {
		"color": str(overdrive_projector.properties.get("baseColor", "")),
		"radius": float(overdrive_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency,
		"alpha": 0.7 * smooth_efficiency,
	}

func source_overdrive_projector_draw_state(overdrive_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)
	if overdrive_projector == null or not lod_l2:
		return {"visible": false, "f": f, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	var line_r: float = max(0.0, clamp(2.0 - f * 2.0, 0.0, 1.0) * float(block_size(overdrive_projector)) * float(tile_size) / 2.0 - f - 0.2)
	var line_w: float = clamp(0.5 - f, 0.0, 1.0) * float(block_size(overdrive_projector)) * float(tile_size)
	return {
		"visible": true,
		"f": f,
		"base_color": str(overdrive_projector.properties.get("baseColor", "")),
		"phase_color": str(overdrive_projector.properties.get("phaseColor", overdrive_projector.properties.get("baseColor", ""))),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2,
		"stroke": (2.0 * f + 0.1) * heat,
		"line_r": line_r,
		"line_w": line_w,
	}

func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	if overdrive_projector == null:
		return 0.0
	var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))
	var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))
	return (speed_boost + phase_heat * speed_boost_phase) * efficiency

func source_overdrive_projector_boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	if overdrive_projector == null:
		return 0.0
	var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))
	var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))
	var has_boost := bool(overdrive_projector.properties.get("hasBoost", false))
	var denominator := speed_boost + speed_boost_phase if has_boost else speed_boost
	if denominator <= 0.0:
		return 0.0
	return source_overdrive_projector_real_boost(overdrive_projector, phase_heat, efficiency) / denominator

func selected_build_overdrive_real_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_real_boost(selected)

func selected_build_overdrive_phase_real_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_real_boost(selected, 1.0)

func selected_build_overdrive_boost_bar_fraction() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_boost_bar_fraction(selected)

func selected_build_overdrive_phase_boost_bar_fraction() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_boost_bar_fraction(selected, 1.0)

func selected_build_overdrive_place_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return {"range": 0.0, "color": ""}
	return source_overdrive_projector_place_state(selected)

func selected_build_overdrive_phase_select_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return {"range": 0.0, "color": ""}
	return source_overdrive_projector_select_state(selected, 1.0)

func selected_build_overdrive_light_state_for_smooth_efficiency(smooth_efficiency: float) -> Dictionary:
	if build_palette.is_empty():
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_overdrive_projector_light_state(selected, smooth_efficiency)

func selected_build_overdrive_draw_state_for_inputs(heat: float, phase_heat: float, source_time_ticks := 0.0) -> Dictionary:
	if build_palette.is_empty():
		return {"visible": false, "f": 0.0, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return {"visible": false, "f": 0.0, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	return source_overdrive_projector_draw_state(selected, heat, phase_heat, source_time_ticks)

func selected_build_booster_item() -> String:
	if build_palette.is_empty():
		return ""
	var selected = build_palette[selected_build_index]
	return str(selected.properties.get("boosterItem", ""))

func selected_build_booster_use_time() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	return float(selected.properties.get("boosterUseTime", 0.0))

func selected_build_place_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = build_palette[selected_build_index]
	if selected.implementation != "MendProjector":
		return {"range": 0.0, "color": ""}
	return source_mend_projector_place_state(selected)

func source_mend_projector_repair_amount(mend_projector, target_block, phase_heat := 0.0, efficiency := 1.0) -> float:
	if mend_projector == null or target_block == null:
		return 0.0
	var heal_percent := float(mend_projector.properties.get("healPercent", 0.0))
	var phase_boost := float(mend_projector.properties.get("phaseBoost", 0.0))
	var target_health := float(target_block.properties.get("health", 0.0))
	return target_health * (heal_percent + phase_heat * phase_boost) / 100.0 * efficiency

func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
	if mend_projector == null or not bool(mend_projector.properties.get("emitLight", false)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return {
		"color": str(mend_projector.properties.get("baseColor", "")),
		"radius": float(mend_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency,
		"alpha": 0.7 * smooth_efficiency,
	}

func source_mend_projector_progress(mend_projector, charge: float) -> float:
	if mend_projector == null:
		return 0.0
	var reload := float(mend_projector.properties.get("reload", 0.0))
	if reload <= 0.0:
		return 0.0
	return clamp(charge / reload, 0.0, 1.0)

func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	if mend_projector == null:
		return {"range": 0.0, "color": ""}
	return {
		"range": source_mend_projector_range(mend_projector, phase_heat),
		"color": str(mend_projector.properties.get("baseColor", "")),
	}

func source_mend_projector_place_state(mend_projector) -> Dictionary:
	return source_mend_projector_select_state(mend_projector, 0.0)
func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)
	if mend_projector == null or not lod_l2:
		return {"visible": false, "f": f, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "square_alpha": 0.0, "square_stroke": 0.0, "square_radius": 0.0}
	return {
		"visible": true,
		"f": f,
		"base_color": str(mend_projector.properties.get("baseColor", "")),
		"phase_color": str(mend_projector.properties.get("phaseColor", mend_projector.properties.get("baseColor", ""))),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2,
		"square_alpha": lod_alpha2,
		"square_stroke": (2.0 * f + 0.2) * heat,
		"square_radius": min(1.0 + (1.0 - f) * float(block_size(mend_projector)) * float(tile_size) / 2.0, float(block_size(mend_projector)) * float(tile_size) / 2.0),
	}

func source_absin(value: float, scl: float, mag: float) -> float:
	if scl == 0.0:
		return 0.0
	return (sin(value / (scl * 2.0)) * mag + mag) / 2.0

func source_approach(from_value: float, to_value: float, speed: float) -> float:
	return from_value + clamp(to_value - from_value, -speed, speed)

func source_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return source_approach(from_value, to_value, source_delta * speed)

func source_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return from_value + (to_value - from_value) * clamp(progress * source_delta, 0.0, 1.0)

func selected_build_repair_amount() -> float:
	if build_palette.is_empty() or content_catalog == null:
		return 0.0
	var selected = build_palette[selected_build_index]
	var mend_projector = content_catalog.get_by_id("mend-projector")
	return source_mend_projector_repair_amount(mend_projector, selected)

func place_selected_block_at_mouse() -> void:
	place_selected_block_at_world(get_global_mouse_position())

func place_selected_block_at_cell(x: int, y: int) -> bool:
	return place_selected_block_at_world(grid_to_world(Vector2i(x, y)))

func place_selected_block_at_world(world_pos: Vector2) -> bool:
	if build_palette.is_empty():
		last_place_blocked = true
		return false
	var cell := world_to_grid(world_pos)
	var block = build_palette[selected_build_index]
	if not can_place_block_at_cell(block, cell):
		last_place_blocked = true
		return false
	if not can_afford(block):
		last_place_blocked = true
		return false
	var blocks := get_node("World/BlockLayer")
	spend_requirements(block)
	var sprite := Sprite2D.new()
	configure_block_sprite(sprite, block, cell)
	blocks.add_child(sprite)
	record_placed_block(sprite, block, cell)
	last_placed_block_id = block.id
	last_placed_block_size = block_size(block)
	last_placed_cell = cell
	last_placed_occupied_cell_count = block_size(block) * block_size(block)
	last_place_blocked = false
	register_turret_cell(cell, block)
	return true

func add_source_block(parent: Node, block_id: String, cell: Vector2i) -> void:
	if content_catalog == null:
		return
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return
	var sprite := Sprite2D.new()
	configure_block_sprite(sprite, block, cell)
	parent.add_child(sprite)
	record_placed_block(sprite, block, cell)
	register_turret_cell(cell, block)

func occupied_cells(cell: Vector2i, block) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in block_size(block):
		for x in block_size(block):
			cells.append(cell + Vector2i(x, y))
	return cells

func is_cell_in_world(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < WORLD_W and cell.y < WORLD_H

func can_place_block_at_cell(block, cell: Vector2i) -> bool:
	for occupied_cell in occupied_cells(cell, block):
		if not is_cell_in_world(occupied_cell):
			return false
		if placed_blocks.has(cell_key(occupied_cell)):
			return false
	return true

func record_placed_block(sprite: Sprite2D, block, cell: Vector2i) -> void:
	var cell_keys: Array[String] = []
	placed_block_origins[cell_key(cell)] = sprite
	for occupied_cell in occupied_cells(cell, block):
		cell_keys.append(cell_key(occupied_cell))
		placed_blocks[cell_key(occupied_cell)] = sprite
	sprite.set_meta("occupied_cells", cell_keys)
	sprite.set_meta("origin_cell", cell)
	sprite.set_meta("source_block_id", block.id)
	sprite.set_meta("source_block_max_health", float(block.properties.get("health", 0.0)))
	sprite.set_meta("source_block_health", float(block.properties.get("health", 0.0)))
	sprite.set_meta("source_block_time_scale", 1.0)
	sprite.set_meta("source_block_time_scale_duration", 0.0)

func block_sprite_at_cell(cell: Vector2i):
	return placed_blocks.get(cell_key(cell))

func block_from_sprite(sprite):
	if content_catalog == null or not is_instance_valid(sprite):
		return null
	return content_catalog.get_by_id(str(sprite.get_meta("source_block_id", "")))

func source_block_health_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return float(sprite.get_meta("source_block_health", 0.0))

func source_block_time_scale_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 1.0
	return float(sprite.get_meta("source_block_time_scale", 1.0))

func source_block_time_scale_duration_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return float(sprite.get_meta("source_block_time_scale_duration", 0.0))

func decay_block_time_scale_sprite(sprite, source_delta: float) -> void:
	if not is_instance_valid(sprite):
		return
	var result := source_building_time_scale_decay_state(float(sprite.get_meta("source_block_time_scale", 1.0)), float(sprite.get_meta("source_block_time_scale_duration", 0.0)), source_delta)
	sprite.set_meta("source_block_time_scale", float(result.get("time_scale", 1.0)))
	sprite.set_meta("source_block_time_scale_duration", float(result.get("time_scale_duration", 0.0)))

func simulate_block_time_scales(delta: float) -> void:
	var source_delta := delta * SOURCE_TICK_RATE
	for key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(key)
		decay_block_time_scale_sprite(sprite, source_delta)

func step_block_time_scales(seconds: float) -> Dictionary:
	simulate_block_time_scales(seconds)
	return {
		"last_overdrive_projector_boosted_block_id": last_overdrive_projector_boosted_block_id,
		"last_overdrive_projector_boosted_cell": {"x": last_overdrive_projector_boosted_cell.x, "y": last_overdrive_projector_boosted_cell.y},
		"time_scale": source_block_time_scale_at_cell(last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y),
		"time_scale_duration": source_block_time_scale_duration_at_cell(last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y),
	}

func damage_block_at_cell(x: int, y: int, amount: float) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	sprite.set_meta("source_block_health", max(0.0, float(sprite.get_meta("source_block_health", 0.0)) - amount))
	return float(sprite.get_meta("source_block_health", 0.0))

func repair_block_sprite(sprite, amount: float) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	var before := float(sprite.get_meta("source_block_health", 0.0))
	var after: float = min(float(sprite.get_meta("source_block_max_health", 0.0)), before + amount)
	sprite.set_meta("source_block_health", after)
	return after - before

func boost_mend_projector_at_cell(x: int, y: int) -> bool:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return false
	var item_id := str(block.properties.get("boosterItem", ""))
	if item_id == "" or core_item_count(item_id) <= 0:
		return false
	core_items[item_id] = int(core_items.get(item_id, 0)) - 1
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	var key := cell_key(origin_cell)
	mend_projector_booster_items[key] = int(mend_projector_booster_items.get(key, 0)) + 1
	mend_projector_optional_efficiency[key] = 1.0
	return true

func mend_projector_phase_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(mend_projector_phase_heat.get(cell_key(origin_cell), 0.0))

func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(mend_projector_smooth_efficiency.get(cell_key(origin_cell), 0.0))

func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_mend_projector_light_state(block, mend_projector_smooth_efficiency_at_cell(x, y))

func mend_projector_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(mend_projector_heat.get(cell_key(origin_cell), 0.0))

func mend_projector_charge_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(mend_projector_charges.get(cell_key(origin_cell), 0.0))

func mend_projector_progress_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return 0.0
	return source_mend_projector_progress(block, mend_projector_charge_at_cell(x, y))

func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return {"range": 0.0, "color": ""}
	return source_mend_projector_select_state(block, mend_projector_phase_heat_at_cell(x, y))
func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "MendProjector":
		return source_mend_projector_draw_state(null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return source_mend_projector_draw_state(block, mend_projector_heat_at_cell(x, y), mend_projector_phase_heat_at_cell(x, y), source_time_ticks)

func boost_overdrive_projector_at_cell(x: int, y: int) -> bool:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "OverdriveProjector":
		return false
	var item_id := str(block.properties.get("boosterItem", ""))
	if item_id == "" or core_item_count(item_id) <= 0:
		return false
	core_items[item_id] = int(core_items.get(item_id, 0)) - 1
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	var key := cell_key(origin_cell)
	overdrive_projector_booster_items[key] = int(overdrive_projector_booster_items.get(key, 0)) + 1
	overdrive_projector_optional_efficiency[key] = 1.0
	return true

func overdrive_projector_phase_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(overdrive_projector_phase_heat.get(cell_key(origin_cell), 0.0))

func overdrive_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(overdrive_projector_smooth_efficiency.get(cell_key(origin_cell), 0.0))

func overdrive_projector_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(overdrive_projector_heat.get(cell_key(origin_cell), 0.0))

func overdrive_projector_charge_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(overdrive_projector_charges.get(cell_key(origin_cell), 0.0))

func overdrive_projector_use_progress_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return float(overdrive_projector_use_progress.get(cell_key(origin_cell), 0.0))

func overdrive_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "OverdriveProjector":
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_overdrive_projector_light_state(block, overdrive_projector_smooth_efficiency_at_cell(x, y))

func overdrive_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if block == null or block.implementation != "OverdriveProjector":
		return source_overdrive_projector_draw_state(null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return source_overdrive_projector_draw_state(block, overdrive_projector_heat_at_cell(x, y), overdrive_projector_phase_heat_at_cell(x, y), source_time_ticks)

func overdrive_projector_state_at_cell(x: int, y: int) -> Dictionary:
	return {
		"heat": overdrive_projector_heat_at_cell(x, y),
		"smooth_efficiency": overdrive_projector_smooth_efficiency_at_cell(x, y),
		"phase_heat": overdrive_projector_phase_heat_at_cell(x, y),
		"charge": overdrive_projector_charge_at_cell(x, y),
		"use_progress": overdrive_projector_use_progress_at_cell(x, y),
	}

func block_size(block) -> int:
	return max(1, int(block.properties.get("size", 1)))

func source_block_health(block_id: String) -> float:
	if content_catalog == null:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return 0.0
	return float(block.properties.get("health", 0.0))

func source_block_item_capacity(block_id: String) -> int:
	if content_catalog == null:
		return 0
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return 0
	return int(block.properties.get("itemCapacity", 0))

func source_block_dump_time(block_id: String) -> float:
	if content_catalog == null:
		return SOURCE_BLOCK_DUMP_TIME
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return SOURCE_BLOCK_DUMP_TIME
	return float(block.properties.get("dumpTime", SOURCE_BLOCK_DUMP_TIME))

const SOURCE_DRILL_DUMP_INTERVAL_TIMER_GATE := "if(timer(timerDump, dumpTime / timeScale)){"
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_CALL := "dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);"
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_COMMENT := "Dump timer ID."
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_FIELD := "protected final int timerDump = timers++;"
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_COMMENT := "How often to try dumping items in ticks, e.g. 5 = 12 times/sec"
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_FIELD := "public int dumpTime = 5;"
const SOURCE_DRILL_INACTIVE_WARMUP_LAST_SPEED_RESET := "lastDrillSpeed = 0f;"
const SOURCE_DRILL_INACTIVE_WARMUP_WARMUP_DECAY := "warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);"
const SOURCE_DRILL_INACTIVE_WARMUP_WARMUP_SPEED_COMMENT := "Speed at which the drill speeds up."
const SOURCE_DRILL_INACTIVE_WARMUP_WARMUP_SPEED_FIELD := "public float warmupSpeed = 0.015f;"
const SOURCE_DRILL_WARMUP_SPEED_COMMENT := "Speed at which the drill speeds up."
const SOURCE_DRILL_WARMUP_SPEED_FIELD := "public float warmupSpeed = 0.015f;"
const SOURCE_DRILL_WARMUP_SPEED_KEY := "warmupSpeed"
const SOURCE_DRILL_WARMUP_SPEED_DEFAULT := 0.015
const SOURCE_DRILL_WARMUP_STATE_ACTIVE_WARMUP := "warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);"
const SOURCE_DRILL_WARMUP_STATE_CURRENT_WARMUP := "warmup"
const SOURCE_DRILL_WARMUP_STATE_SPEED := "speed"
const SOURCE_DRILL_WARMUP_STATE_WARMUP_SPEED := "warmupSpeed"
const SOURCE_DRILL_WARMUP_STATE_SOURCE_DELTA := "Time.delta"

func source_drill_dump_interval(block_id: String, time_scale := 1.0) -> float:
	return source_block_dump_time(block_id) / time_scale

const SOURCE_DRILL_ORE_COUNT_METHOD := "protected void countOre(Tile tile){"
const SOURCE_DRILL_ORE_COUNT_RETURN_ITEM_RESET := "returnItem = null;"
const SOURCE_DRILL_ORE_COUNT_RETURN_COUNT_RESET := "returnCount = 0;"
const SOURCE_DRILL_ORE_COUNT_LINKED_TILES_LOOP := "for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){"
const SOURCE_DRILL_ORE_COUNT_CAN_MINE_GATE := "if(canMine(other)){"
const SOURCE_DRILL_ORE_COUNT_INCREMENT := "oreCount.increment(getDrop(other), 0, 1);"
const SOURCE_DRILL_ORE_COUNT_RETURN_ITEM := "returnItem = itemArray.peek();"
const SOURCE_DRILL_ORE_COUNT_RETURN_COUNT := "returnCount = oreCount.get(itemArray.peek(), 0);"

func source_drill_ore_count(block_id: String, cell: Vector2i, item_id: String) -> int:
	if content_catalog == null:
		return 0
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return 0
	var count := 0
	for occupied_cell in occupied_cells(cell, block):
		if str(ore_items_by_cell.get(cell_key(occupied_cell), "")) == item_id:
			count += 1
	return count

const SOURCE_DRILL_DELAY_METHOD := "public float getDrillTime(Item item){"
const SOURCE_DRILL_DELAY_RESULT := "return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);"
const SOURCE_DRILL_DELAY_HARDNESS_MULTIPLIER_FIELD := "public float hardnessDrillMultiplier = 50f;"
const SOURCE_DRILL_DELAY_DRILL_TIME_COMMENT := "Base time to drill one ore, in frames."
const SOURCE_DRILL_DELAY_DRILL_TIME_FIELD := "public float drillTime = 300;"
const SOURCE_DRILL_DELAY_DRILL_MULTIPLIERS_COMMENT := "Multipliers of drill speed for each item. Defaults to 1."
const SOURCE_DRILL_DELAY_DRILL_MULTIPLIERS_FIELD := "public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();"
const SOURCE_DRILL_DELAY_ITEM_HARDNESS_COMMENT := "drill hardness of the item"
const SOURCE_DRILL_DELAY_ITEM_HARDNESS_FIELD := "public int hardness = 0;"

func source_drill_delay(block_id: String, item_id: String) -> float:
	if content_catalog == null:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	var item = content_catalog.get_by_id(item_id)
	if block == null or item == null:
		return 0.0
	var drill_multipliers = block.properties.get("drillMultipliers", {})
	var drill_multiplier := 1.0
	if typeof(drill_multipliers) == TYPE_DICTIONARY:
		drill_multiplier = float(drill_multipliers.get(item_id, 1.0))
	return (float(block.properties.get("drillTime", SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT)) + SOURCE_DRILL_HARDNESS_MULTIPLIER * float(item.properties.get("hardness", SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT))) / drill_multiplier

const SOURCE_DRILL_OUTPUT_RATE_DRAW_PLACE := "float width = drawPlaceText(Core.bundle.formatFloat(\"bar.drillspeed\", 60f / getDrillTime(returnItem) * returnCount, 2), x, y, valid);"
const SOURCE_DRILL_OUTPUT_RATE_RATE_EXPR := "60f / getDrillTime(returnItem) * returnCount"
const SOURCE_DRILL_OUTPUT_RATE_RETURN_ITEM := "returnItem"
const SOURCE_DRILL_OUTPUT_RATE_RETURN_COUNT := "returnCount"

func source_drill_output_rate(block_id: String, item_id: String, return_count: int) -> float:
	if return_count <= 0:
		return 0.0
	var delay := source_drill_delay(block_id, item_id)
	if delay <= 0.0:
		return 0.0
	return 60.0 * float(return_count) / delay

func source_drill_warmup_speed(block_id: String) -> float:
	if content_catalog == null:
		return SOURCE_DRILL_WARMUP_SPEED_DEFAULT
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return SOURCE_DRILL_WARMUP_SPEED_DEFAULT
	return float(block.properties.get(SOURCE_DRILL_WARMUP_SPEED_KEY, SOURCE_DRILL_WARMUP_SPEED_DEFAULT))

func source_drill_warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:
	return source_approach_delta(current_warmup, speed, warmup_speed, source_delta)

func source_drill_inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float) -> float:
	return source_approach_delta(current_warmup, 0.0, warmup_speed, source_delta)

func drill_warmup_at_cell(x: int, y: int) -> float:
	return float(drill_warmups.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_warmup_at_cell(x: int, y: int, warmup: float) -> void:
	drill_warmups[cell_key(Vector2i(x, y))] = warmup

const SOURCE_DRILL_LAST_SPEED_DELAY := "float delay = getDrillTime(dominantItem);"
const SOURCE_DRILL_LAST_SPEED_SPEED_EXPR := "float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;"
const SOURCE_DRILL_LAST_SPEED_ASSIGNMENT := "lastDrillSpeed = (speed * dominantItems * warmup) / delay;"
const SOURCE_DRILL_LAST_SPEED_LIQUID_BOOST_FIELD := "public float liquidBoostIntensity = 1.6f;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_TILE_FIELD := "transient Tile tile;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_BLOCK_FIELD := "transient Block block;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_TILE_X := "return tile.x;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_TILE_Y := "return tile.y;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_DELEGATE := "lastDrillSpeed = (speed * dominantItems * warmup) / delay;"

func source_drill_last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:
	if ore_count <= 0:
		return 0.0
	var delay := source_drill_delay(block_id, item_id)
	if delay <= 0.0:
		return 0.0
	return speed * float(ore_count) * warmup / delay

func source_drill_last_speed_for_cell(x: int, y: int, item_id: String, dominant_items: int, warmup: float, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_drill_last_speed(str(sprite.get_meta("source_block_id", "")), item_id, dominant_items, warmup, speed)

func drill_last_speed_at_cell(x: int, y: int) -> float:
	return float(drill_last_speeds.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_last_speed_at_cell(x: int, y: int, value: float) -> void:
	drill_last_speeds[cell_key(Vector2i(x, y))] = value

const SOURCE_DRILL_TIME_DRILLED_FIELD := "public float timeDrilled;"
const SOURCE_DRILL_TIME_DRILLED_INCREMENT := "timeDrilled += warmup * delta();"
const SOURCE_DRILL_TIME_DRILLED_WARMUP := "warmup"
const SOURCE_DRILL_TIME_DRILLED_SOURCE_DELTA := "delta()"
const SOURCE_DRILL_TIME_DRILLED_DELTA_RETURN := "return Time.delta * timeScale;"

func source_drill_time_drilled_delta(warmup: float, seconds: float, time_scale := 1.0) -> float:
	return warmup * source_building_delta(seconds * SOURCE_TICK_RATE, time_scale)

func drill_time_drilled_at_cell(x: int, y: int) -> float:
	return float(drill_time_drilled.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_time_drilled_at_cell(x: int, y: int, value: float) -> void:
	drill_time_drilled[cell_key(Vector2i(x, y))] = value

func step_drill_time_drilled_cell(x: int, y: int, seconds: float, warmup: float) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var key := cell_key(Vector2i(x, y))
	var value := float(drill_time_drilled.get(key, 0.0)) + source_drill_time_drilled_delta(warmup, seconds, float(sprite.get_meta("source_block_time_scale", 1.0)))
	drill_time_drilled[key] = value
	return value

func step_drill_warmup_cell(x: int, y: int, seconds: float, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var key := cell_key(Vector2i(x, y))
	var source_delta := seconds * SOURCE_TICK_RATE
	var warmup := source_drill_warmup_state(float(drill_warmups.get(key, 0.0)), speed, source_drill_warmup_speed(str(sprite.get_meta("source_block_id", ""))), source_delta)
	drill_warmups[key] = warmup
	return warmup

const SOURCE_DRILL_OUTPUT_DELTA_PROGRESS_INCREMENT := "progress += delta() * dominantItems * speed * warmup;"
const SOURCE_DRILL_OUTPUT_DELTA_SOURCE_DELTA := "delta()"
const SOURCE_DRILL_OUTPUT_DELTA_DOMINANT_ITEMS := "dominantItems"
const SOURCE_DRILL_OUTPUT_DELTA_SPEED := "speed"
const SOURCE_DRILL_OUTPUT_DELTA_WARMUP := "warmup"

func source_drill_output_delta(dominant_items: int, seconds: float, time_scale := 1.0, warmup := 1.0, speed := 1.0) -> float:
	var scaled_source_delta := source_building_delta(seconds * SOURCE_TICK_RATE, time_scale)
	return scaled_source_delta * float(dominant_items) * speed * warmup

const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TILE_FIELD := "transient Tile tile;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_BLOCK_FIELD := "transient Block block;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TILE_X := "return tile.x;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TILE_Y := "return tile.y;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TIME_SCALE_FIELD := "private transient float timeScale = 1f, timeScaleDuration;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TIME_SCALE_METHOD := "public float timeScale(){"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TIME_SCALE_RETURN := "return timeScale;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_DELEGATE := "progress += delta() * dominantItems * speed * warmup;"

func source_drill_output_delta_for_cell(x: int, y: int, dominant_items: int, seconds: float, warmup := 1.0, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_drill_output_delta(dominant_items, seconds, float(sprite.get_meta("source_block_time_scale", 1.0)), warmup, speed)

const SOURCE_DRILL_OUTPUT_BATCH_GATE := "if(dominantItems > 0 && progress >= delay && items.total() < itemCapacity){"
const SOURCE_DRILL_OUTPUT_BATCH_AMOUNT := "int amount = (int)(progress / delay);"
const SOURCE_DRILL_OUTPUT_BATCH_PROGRESS_MOD := "progress %= delay;"

func source_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	if dominant_items > 0 and progress >= delay and items_total < item_capacity:
		var amount := int(progress / delay)
		return {"amount": amount, "progress": fmod(progress, delay)}
	return {"amount": 0, "progress": progress}

const SOURCE_DRILL_PROGRESS_FRACTION_METHOD := "public float progress(){"
const SOURCE_DRILL_PROGRESS_FRACTION_RETURN := "return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));"
const SOURCE_DRILL_PROGRESS_FRACTION_DOMINANT_ITEM_NULL := "dominantItem == null"
const SOURCE_DRILL_PROGRESS_FRACTION_PROGRESS_RATIO := "progress / getDrillTime(dominantItem)"
const SOURCE_DRILL_PROGRESS_FRACTION_MATHF_CLAMP := "return Math.max(Math.min(value, 1f), 0f);"

func source_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	if not has_dominant_item:
		return 0.0
	return clampf(progress / delay, 0.0, 1.0)

const SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED := "float mspeed = speed * tilesize * 55f;"
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE := "unit.impulse((tx * mspeed + centerx) * delta(), (ty * mspeed + centery) * delta());"
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT := "/** size of tiles in units */"
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD := "public static final int tilesize = 8;"
const SOURCE_CONVEYOR_WORLD_SPEED_KEY := "speed"
const SOURCE_CONVEYOR_WORLD_SPEED_TILE_SPEED_SCALE := 55.0

func source_conveyor_world_speed(block_id: String) -> float:
	if content_catalog == null:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return 0.0
	return float(block.properties.get(SOURCE_CONVEYOR_WORLD_SPEED_KEY, 0.0)) * float(tile_size) * SOURCE_CONVEYOR_WORLD_SPEED_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_UNIT_WORLD_SPEED := "float mspeed = speed * tilesize * 55f;"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_ITEM_POSITIONS := "public float[] xs = new float[capacity], ys = new float[capacity];"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_MOVED := "float moved = speed * edelta();"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_YS_ADD := "ys[i] += maxmove;"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_PASS_THRESHOLD := "if(ys[i] >= 1f && pass(ids[i])){"

func source_conveyor_path_progress_rate(block_id: String) -> float:
	if path_points.size() < 2:
		return 0.0
	var path_length := float(max(1, path_points.size() - 1) * tile_size)
	return source_conveyor_world_speed(block_id) / path_length

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MOVED := "float moved = speed * edelta();"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MAXMOVE := "float maxmove = Mathf.clamp(nextpos - ys[i], 0, moved);"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_YS_ADD := "ys[i] += maxmove;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_METHOD := "public float edelta(){"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_RETURN := "return efficiency * delta();"

func source_conveyor_path_progress_delta(block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	var scaled_source_delta := source_building_edelta(seconds * SOURCE_TICK_RATE, time_scale, efficiency)
	return source_conveyor_path_progress_rate(block_id) * scaled_source_delta / SOURCE_TICK_RATE

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_FIELD := "transient Tile tile;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_BLOCK_FIELD := "transient Block block;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_X := "return tile.x;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_Y := "return tile.y;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_FIELD := "private transient float timeScale = 1f, timeScaleDuration;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_METHOD := "public float timeScale(){"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_RETURN := "return timeScale;"

func source_conveyor_path_progress_delta_for_cell(x: int, y: int, seconds: float, efficiency := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_conveyor_path_progress_delta(str(sprite.get_meta("source_block_id", "")), seconds, float(sprite.get_meta("source_block_time_scale", 1.0)), efficiency)

func block_world_size(block) -> float:
	return float(tile_size * block_size(block))

func source_block_sprite_base_position(block, cell: Vector2i) -> Vector2:
	return grid_to_world(cell) + Vector2.ONE * (block_world_size(block) - float(tile_size)) * 0.5

func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:
	sprite.texture = block_texture(block)
	sprite.position = source_block_sprite_base_position(block, cell)
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = Vector2(block_world_size(block) / size.x, block_world_size(block) / size.y)

func register_turret_cell(cell: Vector2i, block) -> void:
	if block == null or not block.is_turret():
		return
	var key := cell_key(cell)
	if not turret_cooldowns.has(key):
		turret_cells.append(cell)
	turret_cooldowns[key] = 0.0
	if not turret_ammo_stacks.has(key):
		turret_ammo_stacks[key] = []
	if not turret_total_ammo.has(key):
		turret_total_ammo[key] = 0
	if not turret_barrel_counters.has(key):
		turret_barrel_counters[key] = 0
	if not turret_rotations.has(key):
		turret_rotations[key] = 0.0
	if not turret_recoils.has(key):
		turret_recoils[key] = 0.0

func unregister_turret_cell(cell: Vector2i) -> void:
	var key := cell_key(cell)
	if not turret_cooldowns.has(key):
		return
	turret_cooldowns.erase(key)
	turret_barrel_counters.erase(key)
	turret_rotations.erase(key)
	turret_recoils.erase(key)
	var kept: Array = []
	for existing in turret_cells:
		if cell_key(existing) != key:
			kept.append(existing)
	turret_cells = kept
	turret_ammo_stacks.erase(key)
	turret_total_ammo.erase(key)

func block_texture(block) -> Texture2D:
	if block_texture_cache.has(block.id):
		return block_texture_cache[block.id]
	var texture := load_png_texture(block.texture_path)
	block_texture_cache[block.id] = texture
	return texture

const SOURCE_BULLET_TEXTURE_SPRITE_FIELD := "public String sprite;"
const SOURCE_BULLET_TEXTURE_BACK_SPRITE_FIELD := "public @Nullable String backSprite;"
const SOURCE_BULLET_TEXTURE_DEFAULT_SPRITE_CTOR := "this(speed, damage, \"bullet\");"
const SOURCE_BULLET_TEXTURE_FRONT_REGION_LOAD := "frontRegion = Core.atlas.find(sprite);"
const SOURCE_BULLET_TEXTURE_DEFAULT := "bullet"
const SOURCE_BULLET_TEXTURE_ASSET_ROOT := "res://assets/core/assets-raw/sprites/effects"

func source_bullet_texture(sprite_id: String) -> Texture2D:
	var resolved_sprite := sprite_id if sprite_id != "" else SOURCE_BULLET_TEXTURE_DEFAULT
	var path := "%s/%s.png" % [SOURCE_BULLET_TEXTURE_ASSET_ROOT, resolved_sprite]
	return load_png_texture(path)

func can_afford(block) -> bool:
	sync_copper_inventory_alias()
	for requirement in block.properties.get("requirements", []):
		var item_id := str(requirement.get("item", ""))
		var amount := int(requirement.get("amount", 0))
		if item_id != "" and core_item_count(item_id) < amount:
			return false
	return true

func spend_requirements(block) -> void:
	sync_copper_inventory_alias()
	for requirement in block.properties.get("requirements", []):
		var item_id := str(requirement.get("item", ""))
		var amount := int(requirement.get("amount", 0))
		if item_id != "":
			set_core_item_count(item_id, core_item_count(item_id) - amount)

func sync_copper_inventory_alias() -> void:
	core_items["copper"] = clamp_core_item_amount(max(int(core_items.get("copper", 0)), core_inventory))
	core_inventory = int(core_items.get("copper", 0))

func clamp_core_item_amount(amount: int) -> int:
	return mini(max(0, amount), core_item_capacity)

func set_core_item_count(item_id: String, amount: int) -> void:
	core_items[item_id] = clamp_core_item_amount(amount)
	if item_id == "copper":
		core_inventory = int(core_items.get("copper", 0))

func add_core_item(item_id: String, amount: int) -> void:
	set_core_item_count(item_id, core_item_count(item_id) + amount)

func core_item_count(item_id: String) -> int:
	if item_id == "copper" and core_inventory > int(core_items.get("copper", 0)):
		core_items["copper"] = core_inventory
	return int(core_items.get(item_id, 0))

const SOURCE_CORE_ACCEPT_ITEM_METHOD := "public boolean acceptItem(Building source, Item item){"
const SOURCE_CORE_ACCEPT_ITEM_RESULT := "return state.rules.coreIncinerates || items.get(item) < getMaximumAccepted(item);"
const SOURCE_CORE_ACCEPT_ITEM_MAXIMUM_METHOD := "public int getMaximumAccepted(Item item){"
const SOURCE_CORE_ACCEPT_ITEM_MAXIMUM_RESULT := "return state.rules.coreIncinerates ? Integer.MAX_VALUE/2 : storageCapacity;"
const SOURCE_CORE_ACCEPT_ITEM_RULES_CORE_INCINERATES_FIELD := "public boolean coreIncinerates = true;"
const SOURCE_CORE_HANDLE_ITEM_METHOD := "public void handleItem(Building source, Item item){"
const SOURCE_CORE_HANDLE_ITEM_INCINERATE := "boolean incinerate = incinerateNonBuildable && !item.buildable;"
const SOURCE_CORE_HANDLE_ITEM_FULL_OR_INCINERATE_GATE := "if(items.get(item) >= storageCapacity || incinerate){"
const SOURCE_CORE_HANDLE_ITEM_SUPER_HANDLE := "super.handleItem(source, item);"
const SOURCE_CORE_HANDLE_ITEM_BUILDING_HANDLE_ADD := "items.add(item, 1);"
const SOURCE_CORE_HANDLE_ITEM_INCINERATE_NON_BUILDABLE_FIELD := "public boolean incinerateNonBuildable = false;"
const SOURCE_CORE_HANDLE_ITEM_ITEM_BUILDABLE_COMMENT := "If true, this material is used by buildings. If false, this material will be incinerated in certain cores."
const SOURCE_CORE_HANDLE_ITEM_ITEM_BUILDABLE_FIELD := "public boolean buildable = true;"

func source_core_accept_item(item_id: String) -> bool:
	return core_incinerates or core_item_count(item_id) < core_item_capacity

func source_core_handle_item(item_id: String) -> bool:
	if not source_core_accept_item(item_id):
		return false
	var item_buildable := true
	if content_catalog != null:
		var item = content_catalog.get_by_id(item_id)
		if item != null:
			item_buildable = bool(item.properties.get("buildable", true))
	var incinerate := core_incinerate_non_buildable and not item_buildable
	if core_item_count(item_id) >= core_item_capacity or incinerate:
		return true
	add_core_item(item_id, 1)
	return true

func source_building_handle_item_count(current_count: int) -> int:
	return current_count + 1

func source_building_accept_item_state(consumes_item: bool, item_count: int, maximum_accepted: int) -> bool:
	return consumes_item and item_count < maximum_accepted

func source_building_maximum_accepted(block_item_capacity: int) -> int:
	return block_item_capacity

func source_building_handle_stack_count(current_count: int, amount: int) -> int:
	return current_count + amount

func source_building_accept_stack_state(accepts_item: bool, has_items: bool, same_team_or_null_source: bool, maximum_accepted: int, item_count: int, amount: int) -> int:
	if accepts_item and has_items and same_team_or_null_source:
		return mini(maximum_accepted - item_count, amount)
	return 0

func source_building_remove_stack_state(has_items_module: bool, item_count: int, amount: int) -> Dictionary:
	if not has_items_module:
		return {
			"method": "public int removeStack(Item item, int amount){",
			"null_guard": "if(items == null) return 0;",
			"min_assign": "",
			"no_sleep_call": "",
			"items_remove_call": "",
			"return_amount": "return 0;",
			"has_items_module": has_items_module,
			"item_count": item_count,
			"amount": amount,
			"removed": 0,
			"remaining": item_count,
		}
	var removed := mini(amount, item_count)
	return {
		"method": "public int removeStack(Item item, int amount){",
		"null_guard": "",
		"min_assign": "amount = Math.min(amount, items.get(item));",
		"no_sleep_call": "noSleep();",
		"items_remove_call": "items.remove(item, amount);",
		"return_amount": "return amount;",
		"has_items_module": has_items_module,
		"item_count": item_count,
		"amount": amount,
		"removed": removed,
		"remaining": item_count - removed,
	}

func source_building_accept_payload_state() -> bool:
	return false

func source_building_handle_payload_state(payload_state: Variant) -> Variant:
	return payload_state

func source_payload_forward_offset(payload_block_size: int) -> int:
	return floori(float(payload_block_size) / 2.0) + 1

func source_move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:
	return has_next_tile and has_next_build and same_team and accepts_payload

func source_dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:
	return (loop_index + dump_cursor) % proximity_size

func source_dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:
	if proximity_size == 0:
		return {"moved": false, "cdump": dump_cursor, "handled_index": -1}
	var dump := dump_cursor
	var next_dump := dump_cursor
	for i in range(proximity_size):
		var other_index := source_dump_payload_index(i, dump, proximity_size)
		next_dump = source_increment_dump_cursor(next_dump, proximity_size)
		if other_index < accepts_payload_by_index.size() and bool(accepts_payload_by_index[other_index]):
			return {"moved": true, "cdump": next_dump, "handled_index": other_index}
	return {"moved": false, "cdump": next_dump, "handled_index": -1}

func source_block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:
	if existing_always_replace:
		return true
	if existing_privileged:
		return false
	return existing_replaceable and (not same_block or (new_rotate and new_quick_rotate)) and ((not new_group_is_none and same_group) or same_block) and (new_size == existing_size or (new_size >= existing_size and (same_subclass or group_any_replace)))

func source_building_can_be_replaced_state(other_can_replace_block: bool) -> bool:
	return other_can_replace_block

func source_building_should_consume_state(enabled_state: bool) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public boolean shouldConsume(){",
		"return_enabled": "return enabled;",
	}
	var result: Dictionary = {"should_consume": enabled_state}
	result.merge(source_exprs)
	return result

func source_building_production_valid_state() -> Dictionary:
	return {
		"method": "public boolean productionValid(){",
		"default_return": "return true;",
		"production_valid": true,
	}

func source_building_consume_trigger_valid_state() -> bool:
	return false

func source_building_power_production_state() -> Dictionary:
	return {
		"method": "public float getPowerProduction(){",
		"default_return": "return 0f;",
		"power_production": 0.0,
	}

func source_building_progress_increase(base_time: float, edelta_value: float) -> float:
	return 1.0 / base_time * edelta_value

func source_building_display_efficiency(edelta_value: float) -> float:
	return source_building_progress_increase(1.0, edelta_value) / edelta_value

func source_building_should_ambient_sound(should_consume_state: bool) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public boolean shouldAmbientSound(){",
		"return_should_consume": "return shouldConsume();",
	}
	var result: Dictionary = {"should_ambient_sound": should_consume_state}
	result.merge(source_exprs)
	return result

func source_building_draw_status_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	if not (enable_draw_status and consumers_length > 0):
		return {"visible": false}
	var multiplier := 1.0 if block_size_value > 1 else 0.64
	var brcx := source_x + (float(block_size_value) * source_tilesize / 2.0) - (source_tilesize * multiplier / 2.0)
	var brcy := source_y - (float(block_size_value) * source_tilesize / 2.0) + (source_tilesize * multiplier / 2.0)
	return {"visible": true, "multiplier": multiplier, "brcx": brcx, "brcy": brcy, "gray_square_size": 2.5 * multiplier, "status_square_size": 1.5 * multiplier}

func source_building_draw_cracks_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	if not draw_cracks or not damaged_state or block_size_value > max_crack_size:
		return {"visible": false}
	var crack_index := clampi(int((1.0 - health_fraction) * float(crack_regions)), 0, crack_regions - 1)
	var lightness := 0.1 + (1.0 - health_fraction) * 0.6
	var crack_rotation_degrees := (position_id % 4) * 90
	return {"visible": true, "region_size_index": block_size_value - 1, "crack_index": crack_index, "lightness": lightness, "rotation_degrees": crack_rotation_degrees}

func source_building_draw_select_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	var inactive_unit_factory := block_status == "inactiveUnitFactory"
	var remaining_activation_delay := maxf(0.0, unit_activation_delay - state_tick)
	return {"overlay_visible": true, "overlay_x": source_x, "overlay_y": source_y, "overlay_rotation": source_rotation, "place_text_visible": inactive_unit_factory, "place_text_bundle_key": "rules.unitfactoryactivation.objective", "place_text_time": remaining_activation_delay, "place_text_tile_x": tile_x, "place_text_tile_y": tile_y}

func source_building_draw_item_selection_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	if not has_selection:
		return {"visible": false}
	var dx := source_x - float(block_size_value) * source_tilesize / 2.0
	var dy := source_y + float(block_size_value) * source_tilesize / 2.0
	var selection_width := icon_small / 4.0 * selection_icon_ratio
	var selection_height := icon_small / 4.0
	return {"visible": true, "dx": dx, "dy": dy, "shadow_color": "darkGray", "shadow_alpha": 1.0, "shadow_y": dy - 1.0, "foreground_y": dy, "selection_width": selection_width, "selection_height": selection_height}

func source_building_draw_disabled_state(source_x: float, source_y: float) -> Dictionary:
	var disabled_icon_size := 6.0
	return {"visible": true, "icon": "cancel", "color": "scarlet", "alpha": 0.8, "x": source_x, "y": source_y, "width": disabled_icon_size, "height": disabled_icon_size}

func source_building_drawrot_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> float:
	return float(rotation_quadrants * 90) if block_rotate and block_rotate_draw else 0.0

func source_arc_is_power_of_two(value: int) -> bool:
	return value != 0 and (value & (value - 1)) == 0

func _source_words_from_nonnegative(value: int) -> Array:
	var remaining: int = value
	var words: Array = []
	for _index in 4:
		words.append(remaining & SOURCE_UINT16_MASK)
		remaining = remaining >> 16
	return words

func _source_words_clone(words: Array) -> Array:
	return [int(words[0]), int(words[1]), int(words[2]), int(words[3])]

func _source_words_xor(left: Array, right: Array) -> Array:
	return [int(left[0]) ^ int(right[0]), int(left[1]) ^ int(right[1]), int(left[2]) ^ int(right[2]), int(left[3]) ^ int(right[3])]

func _source_words_add(left: Array, right: Array) -> Array:
	var result: Array = [0, 0, 0, 0]
	var carry := 0
	for index in 4:
		var sum_value: int = int(left[index]) + int(right[index]) + carry
		result[index] = sum_value & SOURCE_UINT16_MASK
		carry = sum_value >> 16
	return result

func _source_words_shift_left(words: Array, bits: int) -> Array:
	var result: Array = [0, 0, 0, 0]
	var word_shift: int = bits >> 4
	var bit_shift: int = bits % 16
	for index in 4:
		var source_index: int = index - word_shift
		var value := 0
		if source_index >= 0:
			value = int(words[source_index]) << bit_shift
			if bit_shift > 0 and source_index > 0:
				value |= int(words[source_index - 1]) >> (16 - bit_shift)
		result[index] = value & SOURCE_UINT16_MASK
	return result

func _source_words_unsigned_shift_right(words: Array, bits: int) -> Array:
	var result: Array = [0, 0, 0, 0]
	var word_shift: int = bits >> 4
	var bit_shift: int = bits % 16
	for index in 4:
		var source_index: int = index + word_shift
		var value := 0
		if source_index < 4:
			value = int(words[source_index]) >> bit_shift
			if bit_shift > 0 and source_index < 3:
				value |= int(words[source_index + 1]) << (16 - bit_shift)
		result[index] = value & SOURCE_UINT16_MASK
	return result

func _source_words_mul(left: Array, right: Array) -> Array:
	var accum: Array = [0, 0, 0, 0]
	for left_index in 4:
		for right_index in 4:
			var target_index: int = left_index + right_index
			if target_index < 4:
				accum[target_index] = int(accum[target_index]) + int(left[left_index]) * int(right[right_index])
	var result: Array = [0, 0, 0, 0]
	var carry := 0
	for index in 4:
		var total: int = int(accum[index]) + carry
		result[index] = total & SOURCE_UINT16_MASK
		carry = total >> 16
	return result

func _source_words_to_nonnegative(words: Array) -> int:
	return int(words[0]) + (int(words[1]) << 16) + (int(words[2]) << 32) + (int(words[3]) << 48)

func _source_words_to_signed(words: Array) -> int:
	if (int(words[3]) & 0x8000) == 0:
		return _source_words_to_nonnegative(words)
	var inverted: Array = [int(words[0]) ^ SOURCE_UINT16_MASK, int(words[1]) ^ SOURCE_UINT16_MASK, int(words[2]) ^ SOURCE_UINT16_MASK, int(words[3]) ^ SOURCE_UINT16_MASK]
	var magnitude_words: Array = _source_words_add(inverted, [1, 0, 0, 0])
	if int(magnitude_words[3]) == 0x8000 and int(magnitude_words[2]) == 0 and int(magnitude_words[1]) == 0 and int(magnitude_words[0]) == 0:
		return SOURCE_INT64_MIN
	return -_source_words_to_nonnegative(magnitude_words)

func _source_arc_rand_murmur_hash3_words(words: Array) -> Array:
	var x: Array = _source_words_clone(words)
	x = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))
	x = _source_words_mul(x, SOURCE_RAND_MURMUR_CONST1_WORDS)
	x = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))
	x = _source_words_mul(x, SOURCE_RAND_MURMUR_CONST2_WORDS)
	x = _source_words_xor(x, _source_words_unsigned_shift_right(x, 33))
	return x

func _source_arc_rand_murmur_hash3(value: int) -> int:
	return _source_words_to_signed(_source_arc_rand_murmur_hash3_words(_source_words_from_nonnegative(value)))

func _source_arc_rand_set_seed(source_seed: int) -> Dictionary:
	var seed_words: Array = SOURCE_LONG_MIN_WORDS.duplicate() if source_seed == 0 else _source_words_from_nonnegative(source_seed)
	var seed0: Array = _source_arc_rand_murmur_hash3_words(seed_words)
	return {"seed0": seed0, "seed1": _source_arc_rand_murmur_hash3_words(seed0)}

func _source_arc_rand_next_long_words(rand_state: Dictionary) -> Array:
	var s1: Array = (rand_state["seed0"] as Array).duplicate()
	var s0: Array = (rand_state["seed1"] as Array).duplicate()
	rand_state["seed0"] = s0
	s1 = _source_words_xor(s1, _source_words_shift_left(s1, 23))
	var seed1: Array = _source_words_xor(_source_words_xor(_source_words_xor(s1, s0), _source_words_unsigned_shift_right(s1, 17)), _source_words_unsigned_shift_right(s0, 26))
	rand_state["seed1"] = seed1
	return _source_words_add(seed1, s0)

func _source_arc_rand_next_int_unbounded(rand_state: Dictionary) -> int:
	return _source_words_to_signed(_source_arc_rand_next_long_words(rand_state))

func _source_arc_rand_next_long_bound(rand_state: Dictionary, bound: int) -> int:
	if bound <= 0:
		push_error("Rand.nextLong bound must be positive")
		return 0
	while true:
		var bits: int = _source_words_to_nonnegative(_source_words_unsigned_shift_right(_source_arc_rand_next_long_words(rand_state), 1))
		var value: int = bits % bound
		if bits - value + (bound - 1) >= 0:
			return value
	return 0

func _source_arc_rand_next_int_bound(rand_state: Dictionary, bound: int) -> int:
	return _source_arc_rand_next_long_bound(rand_state, bound)

func _source_arc_rand_next_float(rand_state: Dictionary) -> float:
	return float(_source_words_to_nonnegative(_source_words_unsigned_shift_right(_source_arc_rand_next_long_words(rand_state), 40))) * SOURCE_RAND_NORM_FLOAT

func source_arc_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	var rand_state := _source_arc_rand_set_seed(source_seed)
	if source_arc_is_power_of_two(max_value):
		_source_arc_rand_next_int_unbounded(rand_state)
	return _source_arc_rand_next_int_bound(rand_state, max_value - min_value + 1) + min_value

func source_arc_random_seed_float_max(source_seed: int, max_value: float) -> float:
	var rand_state := _source_arc_rand_set_seed(source_seed * 99999)
	return _source_arc_rand_next_float(rand_state) * max_value

func source_arc_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return lerp(from_value, to_value, clamp(progress * source_delta, 0.0, 1.0))

func source_arc_chance_delta_threshold(chance: float, source_delta: float) -> float:
	return chance * source_delta

func source_arc_mathf_sin_table_value(index: int) -> float:
	if index == 0 or index == 8192:
		return 0.0
	if index == 4096:
		return 1.0
	if index == 12288:
		return -1.0
	return sin((float(index) + 0.5) / float(SOURCE_ARC_SIN_COUNT) * SOURCE_ARC_RAD_FULL)

func source_arc_mathf_sin_lookup(radians: float) -> float:
	var index := int(radians * SOURCE_ARC_RAD_TO_INDEX) & SOURCE_ARC_SIN_MASK
	return source_arc_mathf_sin_table_value(index)

func source_arc_mathf_cos_lookup(radians: float) -> float:
	var index := int((radians + SOURCE_ARC_PI / 2.0) * SOURCE_ARC_RAD_TO_INDEX) & SOURCE_ARC_SIN_MASK
	return source_arc_mathf_sin_table_value(index)

func source_arc_mathf_sin_scaled(radians: float, scl: float, mag: float) -> float:
	return source_arc_mathf_sin_lookup(radians / scl) * mag

func source_arc_mathf_cos_scaled(radians: float, scl: float, mag: float) -> float:
	return source_arc_mathf_cos_lookup(radians / scl) * mag

func source_arc_vec2_limit(vec: Vector2, limit: float) -> Vector2:
	var limit2 := limit * limit
	var len2 := vec.length_squared()
	if len2 > limit2:
		return vec * sqrt(limit2 / len2)
	return vec

func source_building_draw_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var draw_rotation := source_building_drawrot_state(block_rotate, block_rotate_draw, rotation_quadrants)
	if variants == 0 or not has_variant_regions:
		return {"visible": true, "region_kind": "region", "variant_index": -1, "x": source_x, "y": source_y, "rotation_degrees": draw_rotation, "draw_team_top": true}
	var max_variant_index: int = max(0, variant_region_count - 1)
	var variant_index: int = source_arc_random_seed_int(tile_pos, 0, max_variant_index)
	return {"visible": true, "region_kind": "variant_region", "variant_index": variant_index, "x": source_x, "y": source_y, "rotation_degrees": draw_rotation, "draw_team_top": true}

func source_building_draw_cached_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func source_building_recache_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	if headless:
		return {
			"method": "public void recache(){",
			"headless_gate": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
			"recache_call": "",
			"recache": false,
			"building_cache_layer": building_cache_layer,
			"tile": tile_state,
		}
	return {
		"method": "public void recache(){",
		"headless_gate": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
		"recache_call": "renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
		"recache": true,
		"building_cache_layer": building_cache_layer,
		"tile": tile_state,
	}

func source_building_payload_draw_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var cached_draw := {}
	var dynamic_draw := {}
	if draw_cached:
		cached_draw = source_building_draw_cached_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)
	if draw_dynamic:
		dynamic_draw = source_building_draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)
	return {"method": "public void payloadDraw(){", "saved_z_call": "float z = Draw.z();", "cached_gate": "if(block.drawCached){" if draw_cached else "", "cached_z_call": "Draw.z(block.buildingCacheLayer.layer);" if draw_cached else "", "cached_draw_call": "drawCached();" if draw_cached else "", "dynamic_gate": "if(block.drawDynamic){" if draw_dynamic else "", "restore_z_call": "Draw.z(z);" if draw_dynamic else "", "dynamic_draw_call": "draw();" if draw_dynamic else "", "saved_z": current_z, "cached_visible": draw_cached, "cached_z": building_cache_layer_z, "cached_draw": cached_draw, "dynamic_visible": draw_dynamic, "dynamic_z": current_z, "dynamic_draw": dynamic_draw}

func source_building_draw_team_top_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	if not team_region_found:
		return {"visible": false}
	return {"visible": true, "tint_color": team_color if team_region_matches_team else "", "x": source_x, "y": source_y, "color_reset": true}

func source_building_draw_liquid_light_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	if amount <= 0.01:
		return {"visible": false}
	var fract := 1.0
	var opacity := light_alpha * fract
	if opacity <= 0.001:
		return {"visible": false}
	return {"visible": true, "x": source_x, "y": source_y, "radius": block_size_value * 30.0 * fract, "color": light_color, "opacity": opacity, "alpha": opacity * amount, "fract": fract}

func source_building_draw_light_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	var selected_color := current_liquid_color if light_liquid_is_null else light_liquid_color
	var selected_alpha := current_liquid_alpha if light_liquid_is_null else light_liquid_alpha
	if not has_liquids or not draw_liquid_light or selected_alpha <= 0.001:
		return {"visible": false, "visual_liquid": visual_liquid}
	var target := 1.0 if selected_liquid_amount >= 0.01 else 0.0
	var next_visual_liquid := source_arc_lerp_delta(visual_liquid, target, 0.06, source_delta)
	var light_state := source_building_draw_liquid_light_state(source_x, source_y, block_size_value, selected_color, selected_alpha, next_visual_liquid)
	light_state["visual_liquid"] = next_visual_liquid
	return light_state

func source_building_draw_team_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return {"visible": true, "region": "block-border", "color": team_color, "x": source_x - block_size_value * source_tilesize / 2.0 + 4.0, "y": source_y - block_size_value * source_tilesize / 2.0 + 4.0, "color_reset": true}

func source_building_is_heal_suppressed_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> bool:
	return block_suppressable and source_time <= heal_suppression_time

func source_building_check_suppression_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	var suppressed := source_building_is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)
	if not suppressed:
		return {"suppressed": false, "particle_visible": false}
	var particle_range := block_size_value * source_tilesize / 2.0 - 1.0
	var chance_threshold := source_arc_chance_delta_threshold(0.03, source_delta)
	return {"suppressed": true, "particle_visible": "chanceDelta", "chance_threshold": chance_threshold, "effect": "regenSuppressParticle", "color": suppress_color, "particle_range": particle_range, "x_min": source_x - particle_range, "x_max": source_x + particle_range, "y_min": source_y - particle_range, "y_max": source_y + particle_range}

func source_building_player_placed_state(config_state: Variant) -> Dictionary:
	return {
		"method": "public void playerPlaced(Object config){",
		"comment": "Called after the block is placed by this client.",
		"call_super": "@CallSuper",
		"no_op": true,
		"config_state": config_state,
	}

func source_building_placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	var should_link_power := (consumes_power or outputs_power) and has_power and connected_power
	if net_client:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "", "power_node_scan": "", "link_guard": "", "configure_call": "", "returned": true, "power_link_scan": false, "configure": false, "configure_pos": -1}
	if not should_link_power:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "", "returned": false, "power_link_scan": false, "configure": false, "configure_pos": -1}
	var configure := not linked_to_self
	return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "other.configureAny(pos());" if configure else "", "returned": false, "power_link_scan": true, "configure": configure, "configure_pos": source_pos if configure else -1}

func source_building_on_repaired_state(has_fog_radius: bool) -> Dictionary:
	return {
		"method": "public void onRepaired(){",
		"call_super": "@CallSuper",
		"placed_call": "placed();",
		"fog_gate": "if(block.flags.contains(BlockFlag.hasFogRadius)){" if has_fog_radius else "",
		"fog_call": "fogControl.forceUpdate(team, self());" if has_fog_radius else "",
		"has_fog_radius": has_fog_radius,
		"placed": true,
		"fog_force_update": has_fog_radius,
	}

func source_building_is_commandable_state(block_commandable: bool) -> bool:
	return block_commandable

func source_building_is_payload_state(tile_is_empty_tile: bool) -> bool:
	return tile_is_empty_tile

func source_building_overwrote_state(previous_state: Variant) -> Dictionary:
	return {
		"method": "public void overwrote(Seq<Building> previous){",
		"comment": "Called when a block is placed over some other blocks. This seq will always have at least one item.",
		"no_op": true,
		"previous_state": previous_state,
	}

func source_building_on_removed_state(current_state: Variant) -> Dictionary:
	return {
		"method": "public void onRemoved(){",
		"no_op": true,
		"current_state": current_state,
	}

const SOURCE_BUILDING_UNIT_ON_COMMENT := "/** Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  */"
const SOURCE_BUILDING_UNIT_ON_METHOD := "public void unitOn(Unit unit){"
const SOURCE_BUILDING_UNIT_ON_EMPTY_BODY := "public void unitOn(Unit unit){\n    }"

func source_building_unit_on_state(unit_state: Variant) -> Variant:
	return unit_state

const SOURCE_BUILDING_UNIT_ON_ANY_COMMENT := "/** Called every frame a unit is on this. Applies to any unit.  */"
const SOURCE_BUILDING_UNIT_ON_ANY_METHOD := "public void unitOnAny(Unit unit){"
const SOURCE_BUILDING_UNIT_ON_ANY_EMPTY_BODY := "public void unitOnAny(Unit unit){\n    }"

func source_building_unit_on_any_state(unit_state: Variant) -> Variant:
	return unit_state

const SOURCE_BUILDING_UNIT_REMOVED_COMMENT := "/** Called when a unit that spawned at this tile is removed. */"
const SOURCE_BUILDING_UNIT_REMOVED_METHOD := "public void unitRemoved(Unit unit){"
const SOURCE_BUILDING_UNIT_REMOVED_EMPTY_BODY := "public void unitRemoved(Unit unit){\n    }"

func source_building_unit_removed_state(unit_state: Variant) -> Variant:
	return unit_state

func source_building_puddle_on_state(puddle_state: Variant) -> Dictionary:
	return {
		"comment": "Called when a puddle is on this building. Only called at an interval (40 ticks).",
		"method": "public void puddleOn(Puddle puddle){",
		"no_op": true,
		"puddle_state": puddle_state,
	}

func source_building_configured_type_state(value_state: Dictionary) -> String:
	if bool(value_state.get("is_null", false)):
		return "void"
	var type_name := str(value_state.get("superclass", "")) if bool(value_state.get("is_anonymous_class", false)) else str(value_state.get("class", ""))
	var value_kind := str(value_state.get("kind", ""))
	if value_kind == "Item":
		type_name = "Item"
	if value_kind == "Block":
		type_name = "Block"
	if value_kind == "Liquid":
		type_name = "Liquid"
	if value_kind == "UnitType":
		type_name = "UnitType"
	return type_name

func source_building_configured_last_access_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	var result := {"last_accessed": current_last_accessed, "updated": false}
	if bool(builder_state.get("exists", false)) and bool(builder_state.get("is_player", false)):
		result["last_accessed"] = str(builder_state.get("colored_name", ""))
		result["updated"] = true
	return result

func source_building_configured_direct_handler_state(has_configuration: bool, configured_type: String, value_state: Variant) -> Dictionary:
	return {"handled": has_configuration, "handler_type": configured_type, "value": value_state}

func source_building_configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:
	var result := {"copy_branch": value_is_building, "recurse": false, "config": null}
	if value_is_building and copied_config != null and not copied_config_is_building:
		result["recurse"] = true
		result["config"] = copied_config
	return result

func source_building_tapped_state(current_state: Variant) -> Dictionary:
	return {
		"comment": "/** Called when the block is tapped by the local player. */",
		"method": "public void tapped(){",
		"empty_body": "public void tapped(){\n\n    }",
		"current_state": current_state,
		"no_op": true,
	}

func source_building_after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	if not has_destroy_bullet:
		return {"create_bullet": false}
	return {
		"create_bullet": true,
		"team": team_id if destroy_bullet_same_team else "derelict",
		"x": source_x,
		"y": source_y,
		"rotation": source_arc_random_seed_float_max(building_id, 360.0),
	}

func source_building_explosion_item_cap_state(item_capacity: int) -> int:
	return item_capacity

func source_building_splash_liquid_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	var splash := clampf(amount / 4.0, 0.0, 10.0)
	var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))
	var delays: Array[float] = []
	for i in deposit_count:
		delays.append(float(i) / 2.0)
	return {
		"method": "public void splashLiquid(Liquid liquid, float amount){",
		"splash_expr": "float splash = Mathf.clamp(amount / 4f, 0f, 10f);",
		"loop": "for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){",
		"delay_expr": "Time.run(i / 2f, () -> {",
		"tile_world": "Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));",
		"deposit_guard": "if(other != null){",
		"deposit": "Puddles.deposit(other, liquid, splash);",
		"liquid": liquid,
		"splash": splash,
		"deposit_count": deposit_count,
		"delays": delays,
		"random_range": float(source_block_size) * source_tilesize / 2.0,
		"deposit_if_tile_exists": true,
	}

func source_building_on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	var can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid
	var base := {
		"method": "public void onDeconstructed(@Nullable Unit builder){",
		"has_liquids_module": has_liquids_module,
		"current_amount": current_amount,
		"current_incinerable": current_incinerable,
		"deconstruct_drop_all_liquid": deconstruct_drop_all_liquid,
		"source_block_size": source_block_size,
		"can_drop_liquid": can_drop_liquid,
	}
	if not has_liquids_module or current_amount <= 0.0 or not can_drop_liquid:
		base.merge({"deposit_linked_tiles": false, "per_cell": 0.0, "deposit_call": false}, true)
		return base
	base.merge({
		"deposit_linked_tiles": true,
		"per_cell": current_amount / float(source_block_size * source_block_size) * 2.0,
		"deposit_call": true,
	}, true)
	return base

func source_building_on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	var explosiveness := base_explosiveness
	var flammability := 0.0
	var power := 0.0
	if has_items:
		for item_state in item_states:
			var item_amount: int = min(int(item_state.get("amount", 0)), item_cap)
			explosiveness += float(item_state.get("explosiveness", 0.0)) * float(item_amount)
			flammability += float(item_state.get("flammability", 0.0)) * float(item_amount)
			power += float(item_state.get("charge", 0.0)) * pow(float(item_amount), 1.1) * 150.0
	return {
		"method": "public void onDestroyed(){",
		"base_explosiveness": base_explosiveness,
		"has_items": has_items,
		"item_cap": item_cap,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"power": power,
	}

func source_building_on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	var explosiveness := current_explosiveness
	var flammability := current_flammability
	if has_liquids:
		for liquid_state in liquid_states:
			flammability += float(liquid_state.get("flammability", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
			explosiveness += float(liquid_state.get("explosiveness", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
	return {
		"method": "public void onDestroyed(){",
		"current_explosiveness": current_explosiveness,
		"current_flammability": current_flammability,
		"has_liquids": has_liquids,
		"explosiveness": explosiveness,
		"flammability": flammability,
	}

func source_building_on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	var apply_buffered_power := has_cons_power and cons_power_buffered
	var buffered_power_contribution := power_status * cons_power_capacity if apply_buffered_power else 0.0
	return {
		"method": "public void onDestroyed(){",
		"current_power": current_power,
		"has_cons_power": has_cons_power,
		"cons_power_buffered": cons_power_buffered,
		"power_status": power_status,
		"cons_power_capacity": cons_power_capacity,
		"apply_buffered_power": apply_buffered_power,
		"buffered_power_contribution": buffered_power_contribution,
		"power": current_power + buffered_power_contribution,
	}

func source_building_on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	var should_splash := has_liquids and damage_explosions
	return {
		"method": "public void onDestroyed(){",
		"has_liquids": has_liquids,
		"damage_explosions": damage_explosions,
		"splash_liquids": should_splash,
		"call": "liquids.each(this::splashLiquid);" if should_splash else "",
		"liquid_count": liquid_states.size() if should_splash else 0,
		"liquids": liquid_states.duplicate() if should_splash else [],
	}

func source_building_on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	return {
		"method": "public void onDestroyed(){",
		"comment": "//cap explosiveness so fluid tanks/vaults don't instakill units",
		"call": "Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);",
		"x": source_x,
		"y": source_y,
		"flammability": flammability * flammability_scale,
		"explosiveness": explosiveness * 3.5 * explosiveness_scale,
		"power": power,
		"radius": source_tilesize * float(source_block_size) / 2.0,
		"damage_explosions": damage_explosions,
		"effect": destroy_effect,
		"shake": base_shake,
	}

func source_building_on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:
	var should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid
	return {
		"method": "public void onDestroyed(){",
		"source_x": source_x,
		"source_y": source_y,
		"floor_solid": floor_solid,
		"floor_is_liquid": floor_is_liquid,
		"source_block_size": source_block_size,
		"create_rubble": should_create_rubble,
		"call": "Effect.rubble(x, y, block.size);" if should_create_rubble else "",
		"x": source_x,
		"y": source_y,
		"size": source_block_size if should_create_rubble else 0,
	}

func source_building_on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var should_play_sound := not headless
	return {
		"method": "public void onDestroyed(){",
		"headless": headless,
		"destroy_sound": destroy_sound,
		"destroy_pitch_min": destroy_pitch_min,
		"destroy_pitch_max": destroy_pitch_max,
		"destroy_sound_volume": destroy_sound_volume,
		"play_destroy_sound": should_play_sound,
		"sound": destroy_sound if should_play_sound else "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}

func source_building_on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var should_play_reactive_sound := not headless
	var silent_state := {
		"method": "public void onDestroyed(){",
		"headless": headless,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"play_reactive_sound": false,
		"reactive_sound_kind": "",
		"sound": "",
		"sound_choices": [],
		"chance": 0.0,
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}
	if not should_play_reactive_sound:
		return silent_state
	if explosiveness > 40.0:
		return {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"explosiveness": explosiveness,
			"flammability": flammability,
			"play_reactive_sound": true,
			"reactive_sound_kind": "explosive",
			"sound": "",
			"sound_choices": ["blockExplodeExplosive", "blockExplodeExplosiveAlt"],
			"chance": 0.5,
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		}
	if flammability > 5.0:
		return {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"explosiveness": explosiveness,
			"flammability": flammability,
			"play_reactive_sound": true,
			"reactive_sound_kind": "flammable",
			"sound": "blockExplodeFlammable",
			"sound_choices": [],
			"chance": 0.0,
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		}
	return silent_state

func source_building_on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var should_play_power_sound := not headless
	var silent_state := {
		"method": "public void onDestroyed(){",
		"headless": headless,
		"power": power,
		"play_power_sound": false,
		"power_sound_kind": "",
		"sound": "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}
	if not should_play_power_sound:
		return silent_state
	if power > 30000.0:
		return {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"power": power,
			"play_power_sound": true,
			"power_sound_kind": "big",
			"sound": "blockExplodeElectricBig",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		}
	if power > 2000.0:
		return {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"power": power,
			"play_power_sound": true,
			"power_sound_kind": "normal",
			"sound": "blockExplodeElectric",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		}
	return silent_state

func source_building_display_name_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> String:
	if team_is_derelict:
		return localized_name + "\n" + derelict_label
	if team_is_player or team_emoji.is_empty():
		return localized_name
	return localized_name + " " + team_emoji

func source_building_display_icon_state(block_ui_icon: Variant) -> Variant:
	return block_ui_icon

func source_building_flow_items_state(items_module: Variant) -> Variant:
	return items_module

func source_building_display_ui_gates_state(team_is_player: bool, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	var display_flow := (block_category == "distribution" or block_category == "liquid") and block_display_flow
	return {
		"display_header": true,
		"display_same_team_details": team_is_player,
		"display_bars": team_is_player,
		"display_consumption": team_is_player,
		"display_flow": team_is_player and display_flow,
		"display_last_accessed": team_is_player and net_active and has_last_accessed,
	}

func source_arc_strings_fixed_one_decimal(value: float) -> String:
	var negative: bool = value < 0.0
	var abs_value: float = absf(value)
	var scaled: int = int(floor(abs_value * 10.0 + 0.0001))
	var whole: int = int(float(scaled) / 10.0)
	var decimal: int = scaled % 10
	var prefix: String = "-" if negative else ""
	return prefix + str(whole) + "." + str(decimal)

func source_building_display_flow_rate_label(flow_rate: float, per_second_label: String) -> String:
	if flow_rate < 0.0:
		return "..."
	return source_arc_strings_fixed_one_decimal(flow_rate) + " " + per_second_label

func source_building_cursor_state(block_configurable: bool, interactable_player_team: bool) -> String:
	return "hand" if block_configurable and interactable_player_team else "arrow"

func source_building_on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	var base := {
		"method": "public boolean onConfigureBuildTapped(Building other){",
		"clear_on_double_tap": clear_on_double_tap,
		"same_building": same_building,
		"clear_on_double_tap_gate": clear_on_double_tap,
		"same_building_gate": clear_on_double_tap and same_building,
	}
	if clear_on_double_tap:
		if same_building:
			base.merge({"deselect": true, "configure_null": true, "consumed": false}, true)
			return base
		base.merge({"deselect": false, "configure_null": false, "consumed": true}, true)
		return base
	base.merge({"deselect": false, "configure_null": false, "consumed": not same_building}, true)
	return base
func source_building_on_configure_tapped_state(x: float, y: float) -> Dictionary:
	return {"method": "public boolean onConfigureTapped(float x, float y){", "x": x, "y": y, "consumed": false}
func source_building_on_configure_closed_state() -> Dictionary:
	return {"method": "public void onConfigureClosed(){}", "no_op": true}
func source_building_configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return {"should_show": true, "should_hide": false}

func source_building_should_show_configure_state(_player: Variant) -> Dictionary:
	var source_exprs: Dictionary = {
		"comment": "/** Returns whether this config menu should show when the specified player taps it. */",
		"method": "public boolean shouldShowConfigure(Player player){",
		"return_true": "return true;",
	}
	var result: Dictionary = {"should_show": true}
	result.merge(source_exprs)
	return result

func source_building_should_hide_configure_state(_player: Variant) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public boolean shouldHideConfigure(Player player){",
		"return_false": "return false;",
	}
	var result: Dictionary = {"should_hide": false}
	result.merge(source_exprs)
	return result
func source_building_block_half_extent(block_size_value: int, source_tilesize: float) -> float:
	return float(block_size_value) * source_tilesize / 2.0

func source_building_draw_configure_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return {
		"color": "Pal.accent",
		"stroke": 1.0,
		"shape": "square",
		"x": source_x,
		"y": source_y,
		"radius": source_building_block_half_extent(block_size_value, source_tilesize) + 1.0,
		"reset": true,
	}
func source_building_check_solid_state() -> bool:
	return false

func source_building_handle_damage_state(amount: float) -> float:
	return amount

func source_building_absorb_lasers_state(block_absorb_lasers: bool) -> bool:
	return block_absorb_lasers

func source_building_is_insulated_state(block_insulated: bool) -> bool:
	return block_insulated

func source_building_collide_state(_other: Variant) -> bool:
	return true

func source_building_collision_damage_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	var damage := bullet_building_damage
	var armor := block_armor * bullet_armor_multiplier * bullet_block_armor_multiplier
	if not bullet_pierce_armor:
		damage = max(damage - armor, 0.1 * damage)
	return {
		"was_dead": current_health <= 0.0,
		"raw_damage": bullet_building_damage,
		"armor": armor,
		"damage": damage,
		"removed": true,
	}

func source_building_damage_delegate_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return {
		"source_team": source_team,
		"damage": damage_amount,
		"delegates_to_damage": true,
	}

func source_building_bullet_damage_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return {
		"bullet": bullet,
		"source_team": source_team,
		"damage": damage_amount,
		"delegates_to_source_damage": true,
		"fires_bullet_damage_event": true,
	}

func source_building_change_team_delegate_state(next_team: Variant) -> Dictionary:
	return {
		"next_team": next_team,
		"delegates_to_change_team": true,
		"update_power": true,
	}

func source_building_change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	if current_team == next_team:
		return {
			"team": current_team,
			"last_team": current_team,
			"returned": true,
			"remove_index": false,
			"assign_next": false,
		}
	var team_after_force = force_team if force_team != null else current_team
	var last_team = team_after_force
	if last_team == next_team:
		return {
			"team": team_after_force,
			"last_team": last_team,
			"returned": true,
			"remove_index": false,
			"assign_next": false,
		}
	return {
		"team": next_team,
		"last_team": last_team,
		"returned": false,
		"remove_index": was_valid,
		"assign_next": true,
	}

func source_building_change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:
	if power_present and update_power:
		return {
			"old_graph": old_graph,
			"team": team,
			"proximity_reflow": true,
		}
	return {
		"old_graph": old_graph,
		"team": team,
		"proximity_reflow": false,
	}

func source_building_change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:
	if link_count <= 0:
		return {
			"link_count": link_count,
			"team": team,
			"old_graph": old_graph,
			"remove_index": false,
			"reflow_self": false,
			"update_power_graph": false,
		}
	return {
		"link_count": link_count,
		"team": team,
		"old_graph": old_graph,
		"remove_index": true,
		"reflow_self": true,
		"update_power_graph": true,
	}

func source_building_change_team_final_state(was: bool, last_team: Variant) -> Dictionary:
	return {
		"was": was,
		"add_index": was,
		"team_change_event": was,
		"event_last": last_team,
		"check_allow_update": true,
	}

func source_building_can_pickup_state(block_can_pickup: bool) -> bool:
	return block_can_pickup

func source_building_picked_up_state(previous_state: Variant) -> Dictionary:
	return {
		"method": "public void pickedUp(){",
		"comment": "Called right before this building is picked up.",
		"no_op": true,
		"previous_state": previous_state,
	}

func source_building_after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	if power_present and has_cons_power and not cons_power_buffered:
		return {
			"power_present": power_present,
			"new_power_graph": power_present,
			"clear_links": power_present,
			"status": 0.0,
		}
	return {
		"power_present": power_present,
		"new_power_graph": power_present,
		"clear_links": power_present,
		"status": current_status,
	}

func source_building_remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:
	return {
		"method": "public void removeFromProximity(){",
		"on_proximity_removed_call": "onProximityRemoved();",
		"tmp_tiles_clear_call": "tmpTiles.clear();",
		"edges_get_call": "Point2[] nearby = Edges.getEdges(block.size);",
		"world_build_call": "Building other = world.build(tile.x + point.x, tile.y + point.y);",
		"tmp_tiles_add_call": "tmpTiles.add(other);",
		"remove_self_call": "other.proximity.remove(self(), true);",
		"other_update_call": "other.onProximityUpdate();",
		"proximity_clear_call": "proximity.clear();",
		"on_proximity_removed": true,
		"tmp_tiles_cleared": true,
		"nearby_count": nearby_count,
		"queued_removals": clampi(removable_count, 0, nearby_count),
		"proximity_updates": clampi(removable_count, 0, nearby_count),
		"proximity_cleared": true,
	}

const SOURCE_BUILDING_UPDATE_PROXIMITY_METHOD := "public void updateProximity(){"
const SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_CLEAR := "tmpTiles.clear();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_PROXIMITY_CLEAR := "proximity.clear();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_EDGES := "Point2[] nearby = Edges.getEdges(block.size);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_WORLD_BUILD := "Building other = world.build(tile.x + point.x, tile.y + point.y);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_TEAM_GUARD := "if(other == null || other.team != team) continue;"
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_UNIQUE := "other.proximity.addUnique(self());"
const SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_ADD := "tmpTiles.add(other);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_SELF := "proximity.add(tile);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADDED := "onProximityAdded();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_UPDATE := "onProximityUpdate();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_OTHER_UPDATE := "other.onProximityUpdate();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_RECACHE := "if(!headless && block.drawCached) recache();"

func source_building_update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return {
		"tmp_tiles_cleared": true,
		"proximity_cleared": true,
		"nearby_count": nearby_count,
		"same_team_count": clampi(same_team_count, 0, nearby_count),
		"add_unique_calls": clampi(same_team_count, 0, nearby_count),
		"on_proximity_added": true,
		"self_proximity_update": true,
		"other_proximity_updates": clampi(same_team_count, 0, nearby_count),
		"recache": (not headless) and draw_cached,
	}

func source_building_on_nearby_build_added_state(other_state: Variant) -> Dictionary:
	return {
		"method": "public void onNearbyBuildAdded(Building other){}",
		"no_op": true,
		"other_state": other_state,
	}

func source_building_consume_state(consumers: Array, self_state: Variant) -> Dictionary:
	var triggered: Array = []
	for consumer in consumers:
		triggered.append({"consumer": consumer, "self": self_state})
	return {"triggered": triggered}

func source_building_can_consume_state(potential_efficiency: float) -> bool:
	return potential_efficiency > 0.0

const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_COMMENT := "/** Called after efficiency is updated but before consumers are updated. Use to apply your own multiplier. */"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_METHOD := "public void updateEfficiencyMultiplier(){"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_SCALE := "float scale = efficiencyScale();"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_EFFICIENCY := "efficiency *= scale;"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_OPTIONAL := "optionalEfficiency *= scale;"

func source_building_efficiency_scale_state() -> float:
	return 1.0

func source_building_update_efficiency_multiplier_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return {
		"efficiency": efficiency * efficiency_scale,
		"optional_efficiency": optional_efficiency * efficiency_scale,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_COMMENT := "//everything is valid when cheating"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_GUARD := "if(!block.hasConsumers || cheating()){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POTENTIAL := "potentialEfficiency = enabled && productionValid() ? 1f : 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_EFFICIENCY := "efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POWER := "shouldConsumePower = true;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_MULTIPLIER := "updateEfficiencyMultiplier();"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_RETURN := "return;"

func source_building_update_consumption_initial_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	if has_consumers and not cheating:
		return {"returned": false}
	var potential_efficiency := 1.0 if enabled_state and production_valid else 0.0
	var efficiency := potential_efficiency if should_consume_state else 0.0
	var multiplied := source_building_update_efficiency_multiplier_state(efficiency, efficiency, efficiency_scale)
	return {
		"potential_efficiency": potential_efficiency,
		"efficiency": multiplied.get("efficiency", efficiency),
		"optional_efficiency": multiplied.get("optional_efficiency", efficiency),
		"should_consume_power": true,
		"returned": true,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_COMMENT := "//disabled -> nothing works"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_GUARD := "if(!enabled){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_EFFICIENCIES := "potentialEfficiency = efficiency = optionalEfficiency = 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_POWER := "shouldConsumePower = false;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_RETURN := "return;"

func source_building_update_consumption_disabled_state(enabled_state: bool) -> Dictionary:
	if enabled_state:
		return {"returned": false}
	return {
		"potential_efficiency": 0.0,
		"efficiency": 0.0,
		"optional_efficiency": 0.0,
		"should_consume_power": false,
		"returned": true,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_UPDATE := "boolean update = shouldConsume() && productionValid();"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_MIN := "float minEfficiency = 1f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_COMMENT := "//assume efficiency is 1 for the calculations below"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_EFFICIENCIES := "efficiency = optionalEfficiency = 1f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_POWER := "shouldConsumePower = true;"

func source_building_update_consumption_setup_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return {
		"update": should_consume_state and production_valid,
		"min_efficiency": 1.0,
		"efficiency": 1.0,
		"optional_efficiency": 1.0,
		"should_consume_power": true,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_COMMENT := "//first pass: get the minimum efficiency of any consumer"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_LOOP := "for(var cons : block.nonOptionalConsumers){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_RESULT := "float result = cons.efficiency(self());"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_GATE := "if(cons != block.consPower && result <= 0.0000001f){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_STATE := "shouldConsumePower = false;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_MIN := "minEfficiency = Math.min(minEfficiency, result);"

func source_building_update_consumption_non_optional_pass_state(non_optional_consumer_results: Array) -> Dictionary:
	var min_efficiency := 1.0
	var should_consume_power := true
	for consumer in non_optional_consumer_results:
		var result := float(consumer.get("result", 0.0))
		if not bool(consumer.get("is_power", false)) and result <= 0.0000001:
			should_consume_power = false
		min_efficiency = min(min_efficiency, result)
	return {
		"min_efficiency": min_efficiency,
		"should_consume_power": should_consume_power,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_COMMENT := "//same for optionals"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_LOOP := "for(var cons : block.optionalConsumers){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_MIN := "optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));"

func source_building_update_consumption_optional_pass_state(optional_consumer_results: Array) -> Dictionary:
	var optional_efficiency := 1.0
	for result in optional_consumer_results:
		optional_efficiency = min(optional_efficiency, float(result))
	return {
		"optional_efficiency": optional_efficiency,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_COMMENT := "//efficiency is now this minimum value"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_ASSIGN := "efficiency = minEfficiency;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_OPTIONAL_MIN := "optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_POTENTIAL_ASSIGN := "potentialEfficiency = efficiency;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_NO_UPDATE_ZERO := "efficiency = optionalEfficiency = 0f;"

func source_building_update_consumption_efficiency_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	var efficiency := min_efficiency
	optional_efficiency = min(optional_efficiency, min_efficiency)
	var potential_efficiency := efficiency
	if not update:
		efficiency = 0.0
		optional_efficiency = 0.0
	return {
		"efficiency": efficiency,
		"optional_efficiency": optional_efficiency,
		"potential_efficiency": potential_efficiency,
	}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_MULTIPLIER := "updateEfficiencyMultiplier();"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_COMMENT := "//second pass: update every consumer based on efficiency"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_GUARD := "if(update && efficiency > 0){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_LOOP := "for(var cons : block.updateConsumers){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_UPDATE := "cons.update(self());"

func source_building_update_consumption_second_pass_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	var updated_consumers := []
	if update and efficiency > 0.0:
		for consumer in update_consumers:
			updated_consumers.append({
				"consumer": consumer,
				"self": self_state,
			})
	return {
		"updated_consumers": updated_consumers,
		"update_count": updated_consumers.size(),
	}

func source_building_ambient_volume(efficiency: float) -> float:
	return efficiency

func source_building_config_default() -> Variant:
	return null

func source_building_is_valid(tile_build_matches_self: bool, dead_state: bool) -> bool:
	return tile_build_matches_self and not dead_state

func source_building_heal_state(_amount: Variant = null) -> Dictionary:
	return {
		"amount": _amount,
		"health_changed": true,
	}

func source_building_hit_size(block_size_value: int, source_tilesize: float) -> float:
	return float(block_size_value) * source_tilesize

func source_building_kill_state(self_state := {}) -> Dictionary:
	return {
		"call": "buildDestroyed",
		"self": self_state,
	}

func source_building_damage_dead_guard_state(dead_state: bool) -> Dictionary:
	return {
		"returned": dead_state,
		"continues": not dead_state,
	}

func source_building_damage_block_health_scale_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	if is_zero_approx(block_health_multiplier):
		return {
			"damage": health + 1.0,
			"last_damage_time": source_time,
		}
	return {
		"damage": damage_amount / block_health_multiplier,
		"last_damage_time": source_time,
	}

func source_building_damage_handle_damage_gate_state(net_client: bool, health: float, damage_amount: float, handled_damage: float) -> Dictionary:
	if not net_client:
		return {
			"health": health - handled_damage,
			"damage": damage_amount,
			"handled_damage": handled_damage,
			"handle_damage_called": true,
		}
	return {
		"health": health,
		"damage": damage_amount,
		"handled_damage": null,
		"handle_damage_called": false,
	}

func source_building_damage_health_changed_call_state() -> Dictionary:
	return {
		"health_changed": true,
	}

func source_building_health_changed_state(net_server: bool, self_state := {}) -> Dictionary:
	var build_health_update = self_state
	if not net_server:
		build_health_update = null
	return {
		"build_health_update_called": net_server,
		"build_health_update": build_health_update,
		"notify_health_changed": self_state,
	}

func source_building_sense_position_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return {
		"method": "public double sense(LAccess sensor){",
		"switch_case": "return switch(sensor){",
		"x_case": "case x -> World.conv(x);",
		"y_case": "case y -> World.conv(y);",
		"world_conv_method": "public static float conv(float coord){",
		"world_conv_return": "return coord / tilesize;",
		"world_x": world_x,
		"world_y": world_y,
		"source_tilesize": source_tilesize,
		"x": world_x / source_tilesize,
		"y": world_y / source_tilesize,
	}

func source_building_sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	var source_state := {
		"method": "public double sense(LAccess sensor){",
		"health_case": "case health -> health;",
		"max_health_case": "case maxHealth -> maxHealth;",
		"efficiency_case": "case efficiency -> efficiency;",
		"timescale_case": "case timescale -> timeScale;",
		"range_case": "case range -> this instanceof Ranged r ? r.range() / tilesize : 0;",
		"rotation_case": "case rotation -> rotation;",
		"health_input": health,
		"max_health_input": max_health,
		"efficiency_input": efficiency,
		"time_scale": time_scale,
		"ranged_range": ranged_range,
		"source_tilesize": source_tilesize,
		"has_range": has_range,
		"rotation_value": rotation_value,
	}
	source_state["health"] = health
	source_state["max_health"] = max_health
	source_state["efficiency"] = efficiency
	source_state["timescale"] = time_scale
	source_state["range"] = ranged_range / source_tilesize if has_range else 0.0
	source_state["rotation"] = rotation_value
	return source_state

func source_building_sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:
	return {
		"method": "public double sense(LAccess sensor){",
		"total_items_case": "case totalItems -> items == null ? 0 : items.total();",
		"total_liquids_comment": "//totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks",
		"total_liquids_case": "case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();",
		"total_power_case": "case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);",
		"total_items": total_items,
		"total_liquids": total_liquids,
		"total_power": total_power,
	}

func source_building_sense_capacity_power_net_state(block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float) -> Dictionary:
	var power_net_in := 0.0
	var power_net_out := 0.0
	var power_net_stored := 0.0
	var power_net_capacity := 0.0
	if has_power_module:
		power_net_in = last_scaled_power_in * SOURCE_TICK_RATE
		power_net_out = last_scaled_power_out * SOURCE_TICK_RATE
		power_net_stored = last_power_stored
		power_net_capacity = last_power_capacity
	return {
		"method": "public double sense(LAccess sensor){",
		"item_capacity_case": "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;",
		"liquid_capacity_case": "case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;",
		"power_capacity_case": "case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;",
		"power_net_in_case": "case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;",
		"power_net_out_case": "case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;",
		"power_net_stored_case": "case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();",
		"power_net_capacity_case": "case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();",
		"block_has_items": block_has_items,
		"block_item_capacity": block_item_capacity,
		"block_has_liquids": block_has_liquids,
		"block_liquid_capacity": block_liquid_capacity,
		"has_cons_power": has_cons_power,
		"cons_power_capacity": cons_power_capacity,
		"has_power_module": has_power_module,
		"last_scaled_power_in": last_scaled_power_in,
		"last_scaled_power_out": last_scaled_power_out,
		"last_power_stored": last_power_stored,
		"last_power_capacity": last_power_capacity,
		"item_capacity": block_item_capacity if block_has_items else 0.0,
		"liquid_capacity": block_liquid_capacity if block_has_liquids else 0.0,
		"power_capacity": cons_power_capacity if has_cons_power else 0.0,
		"power_net_in": power_net_in,
		"power_net_out": power_net_out,
		"power_net_stored": power_net_stored,
		"power_net_capacity": power_net_capacity,
	}

func source_building_sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:
	var source_state := {
		"method": "public double sense(LAccess sensor){",
		"enabled_case": "case enabled -> enabled ? 1 : 0;",
		"controlled_case": "case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;",
		"enabled_state": enabled_state,
		"is_control_block": is_control_block,
		"is_controlled": is_controlled,
		"ctrl_player_value": ctrl_player_value,
	}
	source_state["enabled"] = 1.0 if enabled_state else 0.0
	source_state["controlled"] = ctrl_player_value if is_control_block and is_controlled else 0.0
	return source_state

func source_building_sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:
	var payload_count := 0.0
	if has_payload_seq:
		payload_count += payload_seq_total
	if has_single_payload:
		payload_count += 1.0
	return {
		"method": "public double sense(LAccess sensor){",
		"payload_count_case": "case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);",
		"size_case": "case size -> block.size;",
		"has_payload_seq": has_payload_seq,
		"payload_seq_total": payload_seq_total,
		"has_single_payload": has_single_payload,
		"block_size_value": block_size_value,
		"payload_count": payload_count,
		"size": block_size_value,
	}

func source_building_sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	var source_state := {
		"method": "public Object senseObject(LAccess sensor){",
		"type_case": "case type -> block;",
		"first_item_case": "case firstItem -> items == null ? null : items.first();",
		"config_case": "case config -> block.configSenseable() ? config() : null;",
		"payload_type_case": "case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;",
		"default_case": "default -> noSensed;",
		"sensor": sensor,
		"block_value": block_value,
		"has_items_module": has_items_module,
		"first_item_value": first_item_value,
		"config_senseable": config_senseable,
		"config_value": config_value,
		"single_payload_kind": single_payload_kind,
		"single_payload_content": single_payload_content,
		"no_sensed": false,
		"value": null,
	}
	match sensor:
		"type":
			source_state["value"] = block_value
			return source_state
		"firstItem":
			source_state["value"] = first_item_value if has_items_module else null
			return source_state
		"config":
			source_state["value"] = config_value if config_senseable else null
			return source_state
		"payloadType":
			if single_payload_kind == "unit" or single_payload_kind == "block":
				source_state["value"] = single_payload_content
				return source_state
			return source_state
		_:
			source_state["no_sensed"] = true
			return source_state

func source_building_sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	var source_state := {
		"method": "public double sense(Content content){",
		"item_case": "if(content instanceof Item i && items != null) return items.get(i);",
		"liquid_case": "if(content instanceof Liquid l && liquids != null) return liquids.get(l);",
		"payloads_guard": "if(getPayloads() != null){",
		"unit_payload_case": "if(content instanceof UnitType u) return getPayloads().get(u);",
		"block_payload_case": "if(content instanceof Block b) return getPayloads().get(b);",
		"invalid_return": "return Float.NaN; //invalid sense",
		"content_type": content_type,
		"has_items_module": has_items_module,
		"item_amount": item_amount,
		"has_liquids_module": has_liquids_module,
		"liquid_amount": liquid_amount,
		"has_payloads": has_payloads,
		"payload_amount": payload_amount,
	}
	if content_type == "item" and has_items_module:
		source_state["sensed"] = true
		source_state["value"] = item_amount
		return source_state
	if content_type == "liquid" and has_liquids_module:
		source_state["sensed"] = true
		source_state["value"] = liquid_amount
		return source_state
	if (content_type == "unit" or content_type == "block") and has_payloads:
		source_state["sensed"] = true
		source_state["value"] = payload_amount
		return source_state
	source_state["sensed"] = false
	source_state["value"] = null
	return source_state

func source_building_control_enabled_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	var next_enabled := current_enabled
	if control_type == "enabled":
		next_enabled = not absf(p1) <= SOURCE_FLOAT_ROUNDING_ERROR
	return {"enabled": next_enabled}

func source_building_control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	if control_type == "config" and block_logic_configurable and not p1_is_logic_build:
		return {"configured_called": true, "builder": null, "value": p1_value}
	return {"configured_called": false, "builder": null, "value": null}

func source_building_set_prop_health_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public void setProp(LAccess prop, double value){",
		"switch_prop": "switch(prop){",
		"health_case": "case health -> {",
		"clamp_assign": "health = (float)Mathf.clamp(value, 0, maxHealth);",
		"destroy_gate": "if(health <= 0f && !dead()){",
		"build_destroyed_call": "Call.buildDestroyed(self());",
		"else_branch": "}else{",
		"health_changed_call": "healthChanged();",
	}
	if prop != "health":
		var non_health_result: Dictionary = {"health": current_health, "build_destroyed_called": false, "build_destroyed": null, "health_changed": false}
		non_health_result.merge(source_exprs)
		return non_health_result
	var next_health := clampf(value, 0.0, max_health_value)
	if next_health <= 0.0 and not dead_state:
		var destroyed_result: Dictionary = {"health": next_health, "build_destroyed_called": true, "build_destroyed": self_state, "health_changed": false}
		destroyed_result.merge(source_exprs)
		return destroyed_result
	var changed_result: Dictionary = {"health": next_health, "build_destroyed_called": false, "build_destroyed": null, "health_changed": true}
	changed_result.merge(source_exprs)
	return changed_result

func source_building_set_prop_team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public void setProp(LAccess prop, double value){",
		"team_case": "case team -> {",
		"team_lookup": "Team team = Team.get((int)value);",
		"change_gate": "if(this.team != team){",
		"change_team_call": "changeTeam(team);",
	}
	if prop != "team":
		var non_team_result: Dictionary = {"team_id": current_team_id, "change_team_called": false, "change_team": null}
		non_team_result.merge(source_exprs)
		return non_team_result
	var next_team_id := int(value)
	if current_team_id != next_team_id:
		var changed_result: Dictionary = {"team_id": next_team_id, "change_team_called": true, "change_team": next_team_id}
		changed_result.merge(source_exprs)
		return changed_result
	var same_result: Dictionary = {"team_id": current_team_id, "change_team_called": false, "change_team": null}
	same_result.merge(source_exprs)
	return same_result

func source_building_set_prop_total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public void setProp(LAccess prop, double value){",
		"total_power_case": "case totalPower -> {",
		"total_power_guard": "if(power != null && block.consPower != null && block.consPower.buffered){",
		"status_assign": "power.status = Mathf.clamp((float)(value / block.consPower.capacity));",
	}
	if prop == "totalPower" and has_power and has_cons_power and cons_power_buffered:
		var next_status := clampf(value / cons_power_capacity, 0.0, 1.0)
		var updated_result: Dictionary = {"power_status": next_status, "updated": true}
		updated_result.merge(source_exprs)
		return updated_result
	var unchanged_result: Dictionary = {"power_status": current_power_status, "updated": false}
	unchanged_result.merge(source_exprs)
	return unchanged_result

func source_building_set_prop_team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public void setProp(LAccess prop, Object value){",
		"switch_prop": "switch(prop){",
		"team_case": "case team -> {",
		"team_gate": "if(value instanceof Team team && this.team != team){",
		"change_team_call": "changeTeam(team);",
	}
	if prop == "team" and value_is_team and current_team_value != team_value:
		var changed_result: Dictionary = {"team": team_value, "change_team_called": true, "change_team": team_value}
		changed_result.merge(source_exprs)
		return changed_result
	var same_result: Dictionary = {"team": current_team_value, "change_team_called": false, "change_team": null}
	same_result.merge(source_exprs)
	return same_result

func source_building_set_prop_item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public void setProp(UnlockableContent content, double value){",
		"item_gate": "if(content instanceof Item item && items != null){",
		"amount_assign": "int amount = (int)value;",
		"amount_diff_gate": "if(items.get(item) != amount){",
		"increase_gate": "if(items.get(item) < amount){",
		"handle_stack_call": "handleStack(item, acceptStack(item, amount - items.get(item), null), null);",
		"remove_gate": "}else if(amount >= 0){",
		"remove_stack_call": "removeStack(item, items.get(item) - amount);",
	}
	if content_type != "item" or not has_items_module:
		var no_item_result: Dictionary = {"action": "none", "item": item_value, "amount": current_amount, "delta": 0, "accepted": 0}
		no_item_result.merge(source_exprs)
		return no_item_result
	var amount := int(value)
	if current_amount == amount:
		var same_result: Dictionary = {"action": "none", "item": item_value, "amount": amount, "delta": 0, "accepted": 0}
		same_result.merge(source_exprs)
		return same_result
	if current_amount < amount:
		var handle_result: Dictionary = {"action": "handle_stack", "item": item_value, "amount": amount, "delta": amount - current_amount, "accepted": accepted_stack}
		handle_result.merge(source_exprs)
		return handle_result
	if amount >= 0:
		var remove_result: Dictionary = {"action": "remove_stack", "item": item_value, "amount": amount, "delta": current_amount - amount, "accepted": 0}
		remove_result.merge(source_exprs)
		return remove_result
	var negative_result: Dictionary = {"action": "none", "item": item_value, "amount": amount, "delta": 0, "accepted": 0}
	negative_result.merge(source_exprs)
	return negative_result

func source_building_set_prop_liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	var source_exprs: Dictionary = {
		"method": "public void setProp(UnlockableContent content, double value){",
		"liquid_gate": "}else if(content instanceof Liquid liquid && liquids != null){",
		"clamp_assign": "float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);",
		"decreasing_comment": "//decreasing amount is always allowed",
		"set_gate": "if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){",
		"liquids_set_call": "liquids.set(liquid, amount);",
	}
	if content_type != "liquid" or not has_liquids_module:
		var no_liquid_result: Dictionary = {"action": "none", "liquid": liquid_value, "amount": current_amount}
		no_liquid_result.merge(source_exprs)
		return no_liquid_result
	var amount := clampf(value, 0.0, block_liquid_capacity)
	var can_set := amount < current_amount
	if not can_set:
		can_set = accept_liquid_result and (current_liquid_matches or current_liquid_amount <= 0.1 or block_consumes_liquid)
	if can_set:
		var set_result: Dictionary = {"action": "set_liquid", "liquid": liquid_value, "amount": amount}
		set_result.merge(source_exprs)
		return set_result
	var blocked_result: Dictionary = {"action": "none", "liquid": liquid_value, "amount": current_amount}
	blocked_result.merge(source_exprs)
	return blocked_result

func source_building_in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:
	if same_team or not rules_fog:
		return {"returned": true, "value": false}
	return {"returned": false, "value": null}

func source_building_in_fog_discovery_gate_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	var grid := {
		"size": block_size_value,
		"offset": block_size_offset,
		"tile_x": tile_x,
		"tile_y": tile_y,
	}
	if not is_discovered:
		return {"returned": true, "value": true, "grid": grid}
	return {"returned": false, "value": null, "grid": grid}

func source_building_in_fog_visibility_loop_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	var checked_tiles: Array = []
	for x in range(block_size_value):
		for y in range(block_size_value):
			var check_x := tile_x + x + block_size_offset
			var check_y := tile_y + y + block_size_offset
			checked_tiles.append({"x": check_x, "y": check_y})
			for visible_tile in visible_tiles:
				if int(visible_tile.get("x", -2147483648)) == check_x and int(visible_tile.get("y", -2147483648)) == check_y:
					return {"in_fog": false, "checked_tiles": checked_tiles, "visible_tile": {"x": check_x, "y": check_y}}
	return {"in_fog": true, "checked_tiles": checked_tiles, "visible_tile": null}

func source_building_killed_initial_side_effects_state(tile_value: Variant) -> Dictionary:
	return {
		"method": "public void killed(){",
		"tile_value": tile_value,
		"dead": true,
		"event": {"type": "BlockDestroyEvent", "tile": tile_value},
		"on_destroyed_called": true,
		"next_step": "tile_remove_gate",
	}

func source_building_killed_removal_side_effects_state(tile_not_empty_tile: bool) -> Dictionary:
	return {
		"method": "public void killed(){",
		"tile_not_empty_tile": tile_not_empty_tile,
		"tile_remove_gate": tile_not_empty_tile,
		"tile_remove_called": tile_not_empty_tile,
		"remove_called": true,
		"after_destroyed_called": true,
	}

func source_building_check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	if not allow_update_result:
		return {"enabled": false, "changed": current_enabled}
	return {"enabled": current_enabled, "changed": false}

const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_FIELD := "private transient float timeScale = 1f, timeScaleDuration;"
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_GATE := "if((timeScaleDuration -= Time.delta) <= 0f){"
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_RESET := "timeScale = 1f;"

func source_building_update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	var next_duration := current_time_scale_duration - time_delta
	if next_duration <= 0.0:
		return {"time_scale": 1.0, "time_scale_duration": next_duration}
	return {"time_scale": current_time_scale, "time_scale_duration": next_duration}

const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_GATE := "if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_LOOP := "control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_VOLUME_EXPR := "block.ambientSoundVolume * ambientVolume()"

func source_building_update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	var should_loop: bool = not headless_mode and ambient_sound_value != sounds_none_value and should_ambient_sound_result
	if not should_loop:
		return {"loop_called": false, "sound": ambient_sound_value, "volume": 0.0}
	return {"loop_called": true, "sound": ambient_sound_value, "volume": block_ambient_sound_volume * ambient_volume_value}

const SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL := "updateConsumption();"

func source_building_update_consumption_call_state() -> Dictionary:
	return {"update_consumption_called": true}

const SOURCE_BUILDING_UPDATE_TILE_GATE_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_TILE_GATE_GUARD := "if(enabled || !block.noUpdateDisabled){"
const SOURCE_BUILDING_UPDATE_TILE_GATE_CALL := "updateTile();"

func source_building_update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	var update_tile_called: bool = enabled_state or not block_no_update_disabled
	return {"update_tile_called": update_tile_called}

const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_COMMENT := "/** When a block is newly revealed outside of camera view range, it is updated on the minimap. */"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_METHOD := "public void updateFogVisibility(){"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GATE := "if(!wasVisible && !inFogTo(player.team())){"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_FLAGS := "visibleFlags |= (1L << player.team().id);"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_WAS_VISIBLE := "wasVisible = true;"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_SHADOW := "renderer.blocks.updateShadow(self());"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_MINIMAP := "renderer.minimap.update(tile);"

func source_building_update_fog_visibility_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state := {}, tile_state := {}) -> Dictionary:
	var should_update: bool = not was_visible and not in_fog_to_player_team
	if not should_update:
		return {
			"visible_flags": visible_flags,
			"was_visible": was_visible,
			"update_shadow": null,
			"minimap_update": null,
		}
	var updated_flags: int = visible_flags | (1 << player_team_id)
	return {
		"visible_flags": updated_flags,
		"was_visible": true,
		"update_shadow": self_state,
		"minimap_update": tile_state,
	}

func source_building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var hitbox_size: float = float(block_size_value) * source_tilesize
	return {
		"set_centered": {"x": world_x, "y": world_y, "width": hitbox_size, "height": hitbox_size},
	}

const SOURCE_BUILDING_TO_STRING_OVERRIDE := "@Override"
const SOURCE_BUILDING_TO_STRING_REPLACE := "@Replace"
const SOURCE_BUILDING_TO_STRING_METHOD := "public String toString(){"
const SOURCE_BUILDING_TO_STRING_RETURN := "return \"Building#\" + id() + \"[\" + tileX() + \",\" + tileY() + \"]:\" + block;"

func source_building_to_string_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> String:
	return "Building#" + str(id_value) + "[" + str(tile_x_value) + "," + str(tile_y_value) + "]:" + str(block_value)

func source_building_handle_liquid_amount(current_amount: float, amount: float) -> float:
	return current_amount + amount

func source_building_accept_liquid_state(has_liquids: bool, consumes_liquid: bool) -> bool:
	return has_liquids and consumes_liquid

func source_move_forward_accept_state(has_front: bool, same_team: bool, front_accepts: bool) -> bool:
	return has_front and same_team and front_accepts

func source_move_forward_to_core(item_id: String, has_front := true, same_team := true) -> bool:
	if not source_move_forward_accept_state(has_front, same_team, source_core_accept_item(item_id)):
		return false
	return source_core_handle_item(item_id)

func source_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	if proximity_size != 0:
		return (current_dump + 1) % proximity_size
	return current_dump

func set_drill_dump_cursor(value: int) -> void:
	drill_dump_cursor = value

func increment_drill_dump(proximity_size: int) -> int:
	drill_dump_cursor = source_increment_dump_cursor(drill_dump_cursor, proximity_size)
	return drill_dump_cursor

const SOURCE_DUMP_ACCUMULATE_ATTEMPT_FIELD := "private transient float dumpAccum;"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_ADD_DELTA := "dumpAccum += delta();"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_WHILE_GATE := "while(dumpAccum >= 1f){"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_DUMP_CALL := "res |= dump(item);"
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_SUBTRACT_ONE := "dumpAccum -=1f;"

func source_dump_accumulate_attempt_state(current_accum: float, source_delta: float) -> Dictionary:
	var next_accum := current_accum + source_delta
	var dump_attempts := 0
	while next_accum >= 1.0:
		dump_attempts += 1
		next_accum -= 1.0
	return {"dump_attempts": dump_attempts, "dump_accum": next_accum}

func step_building_dump_accum(source_delta: float) -> Dictionary:
	var state := source_dump_accumulate_attempt_state(building_dump_accum, source_delta)
	building_dump_accum = float(state["dump_accum"])
	return state

func drill_item_count(item_id: String) -> int:
	return int(drill_items.get(item_id, 0))

func drill_items_total() -> int:
	var total := 0
	for amount in drill_items.values():
		total += int(amount)
	return total

func add_drill_item(item_id: String, amount: int) -> void:
	drill_items[item_id] = drill_item_count(item_id) + amount

func source_offload_to_inventory(item_id: String, amount: int) -> void:
	add_drill_item(item_id, amount)

func remove_drill_item(item_id: String, amount: int) -> int:
	var removed = mini(amount, drill_item_count(item_id))
	drill_items[item_id] = drill_item_count(item_id) - removed
	return removed

func source_dump_drill_item_to_core(item_id: String) -> bool:
	if drill_item_count(item_id) <= 0:
		return false
	if not source_core_accept_item(item_id):
		increment_drill_dump(1)
		return false
	if not source_core_handle_item(item_id):
		increment_drill_dump(1)
		return false
	remove_drill_item(item_id, 1)
	increment_drill_dump(1)
	return true

func requirements_text(block) -> String:
	var parts: Array[String] = []
	for requirement in block.properties.get("requirements", []):
		parts.append("%s %s" % [str(requirement.get("amount", 0)), str(requirement.get("item", ""))])
	return ", ".join(parts) if not parts.is_empty() else "free"

func add_sprite(parent: Node, key: String, pos: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = textures.get(key)
	sprite.position = pos
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = Vector2(tile_size / size.x, tile_size / size.y)
	parent.add_child(sprite)
	return sprite

func add_ore_cell(parent: Node, key: String, item_id: String, cell: Vector2i) -> Sprite2D:
	ore_items_by_cell[cell_key(cell)] = item_id
	return add_sprite(parent, key, grid_to_world(cell))

func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / tile_size), floori(pos.y / tile_size))

func cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]

func build_hud() -> void:
	update_hud()

func _process(delta: float) -> void:
	MindustryTime.update(delta)
	simulate_block_time_scales(delta)
	simulate_factory(delta)
	simulate_mend_projectors(delta)
	simulate_overdrive_projectors(delta)
	simulate_turrets(delta)
	simulate_bullets(delta)
	simulate_enemy_units(delta)
	update_camera(delta)
	update_hud()

func simulate_factory(delta: float) -> void:
	if path_points.is_empty():
		return
	if drill_output_rate > 0.0:
		step_drill_time_drilled_cell(drill_pos.x, drill_pos.y, delta, drill_warmup_at_cell(drill_pos.x, drill_pos.y))
		set_drill_last_speed_at_cell(drill_pos.x, drill_pos.y, source_drill_last_speed_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, drill_warmup_at_cell(drill_pos.x, drill_pos.y)))
		var drill_warmup := step_drill_warmup_cell(drill_pos.x, drill_pos.y, delta)
		var drill_delay := source_drill_delay("mechanical-drill", drill_output_item_id)
		var raw_progress := item_progress * drill_delay
		raw_progress += source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_ore_cell_count, delta, drill_warmup)
		var output_batch := source_drill_output_batch(raw_progress, drill_delay, drill_ore_cell_count, drill_items_total(), source_block_item_capacity("mechanical-drill"))
		item_progress = source_drill_progress_fraction(float(output_batch["progress"]), drill_delay, drill_ore_cell_count > 0)
		source_offload_to_inventory(drill_output_item_id, int(output_batch["amount"]))
		produced_total += int(output_batch["amount"])
	else:
		set_drill_last_speed_at_cell(drill_pos.x, drill_pos.y, 0.0)
		set_drill_warmup_at_cell(drill_pos.x, drill_pos.y, source_drill_inactive_warmup_state(drill_warmup_at_cell(drill_pos.x, drill_pos.y), source_drill_warmup_speed("mechanical-drill"), delta * SOURCE_TICK_RATE))
	simulate_drill_dump(delta)
	transport_progress = fmod(transport_progress + source_conveyor_path_progress_delta_for_cell(drill_pos.x + 1, drill_pos.y, delta), 1.0)
	for i in item_sprites.size():
		var phase := fmod(transport_progress + float(i) / float(item_sprites.size()), 1.0)
		var idx := int(floor(phase * float(path_points.size() - 1)))
		var next_idx = min(idx + 1, path_points.size() - 1)
		var local_t := fmod(phase * float(path_points.size() - 1), 1.0)
		item_sprites[i].position = path_points[idx].lerp(path_points[next_idx], local_t)
		item_sprites[i].visible = true

func simulate_drill_dump(delta: float) -> void:
	drill_dump_timer += delta * SOURCE_TICK_RATE
	var dump_interval := source_drill_dump_interval("mechanical-drill", source_block_time_scale_at_cell(drill_pos.x, drill_pos.y))
	if dump_interval <= 0.0:
		return
	if drill_dump_timer >= dump_interval:
		drill_dump_timer -= dump_interval
		source_dump_drill_item_to_core(drill_output_item_id)

func step_factory_transport(seconds: float) -> Dictionary:
	var before := transport_progress
	var progress_delta := source_conveyor_path_progress_delta_for_cell(drill_pos.x + 1, drill_pos.y, seconds)
	simulate_factory(seconds)
	return {
		"transport_progress_before": before,
		"transport_progress_delta": progress_delta,
		"transport_progress": transport_progress,
		"conveyor_time_scale": source_block_time_scale_at_cell(drill_pos.x + 1, drill_pos.y),
		"conveyor_progress_delta": progress_delta,
	}

func step_factory_drill(seconds: float) -> Dictionary:
	var before := item_progress
	var warmup_before := drill_warmup_at_cell(drill_pos.x, drill_pos.y)
	simulate_factory(seconds)
	var warmup_after := drill_warmup_at_cell(drill_pos.x, drill_pos.y)
	var output_delta := source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_ore_cell_count, seconds, warmup_after)
	return {
		"item_progress_before": before,
		"drill_warmup_before": warmup_before,
		"drill_warmup": drill_warmup_at_cell(drill_pos.x, drill_pos.y),
		"drill_time_drilled": drill_time_drilled_at_cell(drill_pos.x, drill_pos.y),
		"drill_last_speed": drill_last_speed_at_cell(drill_pos.x, drill_pos.y),
		"drill_output_delta": output_delta,
		"item_progress": item_progress,
		"drill_time_scale": source_block_time_scale_at_cell(drill_pos.x, drill_pos.y),
		"produced_total": produced_total,
	}

func source_block_is_damaged(sprite) -> bool:
	if not is_instance_valid(sprite):
		return false
	return float(sprite.get_meta("source_block_health", 0.0)) < float(sprite.get_meta("source_block_max_health", 0.0)) - 0.001

func source_mend_projector_range(mend_projector, phase_heat := 0.0) -> float:
	if mend_projector == null:
		return 0.0
	return float(mend_projector.properties.get("range", 0.0)) + phase_heat * float(mend_projector.properties.get("phaseRangeBoost", 0.0))

func find_damaged_block_in_mend_range(mend_cell: Vector2i, mend_projector, phase_heat := 0.0):
	var mend_origin := source_block_sprite_base_position(mend_projector, mend_cell)
	var real_range := source_mend_projector_range(mend_projector, phase_heat)
	for origin_key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(origin_key)
		if not source_block_is_damaged(sprite):
			continue
		var target_block = block_from_sprite(sprite)
		if target_block == null:
			continue
		var target_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var target_origin := source_block_sprite_base_position(target_block, target_cell)
		if mend_origin.distance_to(target_origin) <= real_range:
			return sprite
	return null

func simulate_mend_projectors(delta: float) -> void:
	var source_delta := delta * SOURCE_TICK_RATE
	for key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(key)
		var block = block_from_sprite(sprite)
		if block == null:
			continue
		if block.implementation != "MendProjector":
			continue
		mend_projector_smooth_efficiency[key] = source_lerp_delta(float(mend_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)
		mend_projector_heat[key] = source_lerp_delta(float(mend_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)
		mend_projector_optional_efficiency[key] = 1.0 if int(mend_projector_booster_items.get(key, 0)) > 0 else 0.0
		mend_projector_phase_heat[key] = source_lerp_delta(float(mend_projector_phase_heat.get(key, 0.0)), float(mend_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)
		mend_projector_booster_timers[key] = float(mend_projector_booster_timers.get(key, 0.0)) + source_delta
		if float(mend_projector_booster_timers.get(key, 0.0)) >= float(block.properties.get("boosterUseTime", 0.0)):
			mend_projector_booster_items[key] = max(0, int(mend_projector_booster_items.get(key, 0)) - 1)
			mend_projector_booster_timers[key] = 0.0
			mend_projector_optional_efficiency[key] = 1.0 if int(mend_projector_booster_items.get(key, 0)) > 0 else 0.0
		mend_projector_charges[key] = float(mend_projector_charges.get(key, 0.0)) + float(mend_projector_heat.get(key, 0.0)) * source_delta
		if float(mend_projector_charges.get(key, 0.0)) < float(block.properties.get("reload", 0.0)):
			continue
		mend_projector_charges[key] = 0.0
		var mend_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var phase_heat := float(mend_projector_phase_heat.get(key, 0.0))
		var target = find_damaged_block_in_mend_range(mend_cell, block, phase_heat)
		var target_block = block_from_sprite(target)
		if target_block == null:
			continue
		var healed := repair_block_sprite(target, source_mend_projector_repair_amount(block, target_block, phase_heat))
		last_mend_projector_healed_amount = healed
		last_mend_projector_healed_block_id = str(target.get_meta("source_block_id", ""))
		last_mend_projector_healed_cell = target.get_meta("origin_cell", Vector2i.ZERO)

func step_mend_projectors(seconds: float) -> Dictionary:
	simulate_mend_projectors(seconds)
	return {
		"last_mend_projector_healed_amount": last_mend_projector_healed_amount,
		"last_mend_projector_healed_block_id": last_mend_projector_healed_block_id,
		"last_mend_projector_healed_cell": {"x": last_mend_projector_healed_cell.x, "y": last_mend_projector_healed_cell.y},
	}

func find_overdrive_boost_target(overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):
	if overdrive_projector == null:
		return null
	var overdrive_origin := source_block_sprite_base_position(overdrive_projector, overdrive_cell)
	for origin_key in placed_block_origins.keys():
		var target = placed_block_origins.get(origin_key)
		var target_block = block_from_sprite(target)
		if target_block == null:
			continue
		var target_cell: Vector2i = target.get_meta("origin_cell", Vector2i.ZERO)
		var target_origin := source_block_sprite_base_position(target_block, target_cell)
		var distance := overdrive_origin.distance_to(target_origin)
		var filter_state := source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance, phase_heat)
		if bool(filter_state.get("eligible", false)):
			return target
	return null

func apply_overdrive_boost_to_sprite(target, intensity: float, duration: float) -> void:
	if not is_instance_valid(target):
		return
	var target_block = block_from_sprite(target)
	if target_block == null:
		return
	var result := source_building_apply_boost_state(float(target.get_meta("source_block_time_scale", 1.0)), float(target.get_meta("source_block_time_scale_duration", 0.0)), intensity, duration, bool(target_block.properties.get("canOverdrive", true)))
	target.set_meta("source_block_time_scale", float(result.get("time_scale", 1.0)))
	target.set_meta("source_block_time_scale_duration", float(result.get("time_scale_duration", 0.0)))
	last_overdrive_projector_boosted_block_id = str(target.get_meta("source_block_id", ""))
	last_overdrive_projector_boosted_cell = target.get_meta("origin_cell", Vector2i.ZERO)

func simulate_overdrive_projectors(delta: float) -> void:
	var source_delta := delta * SOURCE_TICK_RATE
	for key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(key)
		var block = block_from_sprite(sprite)
		if block == null:
			continue
		if block.implementation != "OverdriveProjector":
			continue
		overdrive_projector_smooth_efficiency[key] = source_lerp_delta(float(overdrive_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)
		overdrive_projector_heat[key] = source_lerp_delta(float(overdrive_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)
		overdrive_projector_charges[key] = float(overdrive_projector_charges.get(key, 0.0)) + float(overdrive_projector_heat.get(key, 0.0)) * source_delta
		overdrive_projector_optional_efficiency[key] = 1.0 if int(overdrive_projector_booster_items.get(key, 0)) > 0 else 0.0
		if bool(block.properties.get("hasBoost", false)):
			overdrive_projector_phase_heat[key] = source_lerp_delta(float(overdrive_projector_phase_heat.get(key, 0.0)), float(overdrive_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)
		if float(overdrive_projector_charges.get(key, 0.0)) >= float(block.properties.get("reload", 0.0)):
			var phase_heat := float(overdrive_projector_phase_heat.get(key, 0.0))
			overdrive_projector_charges[key] = 0.0
			last_overdrive_projector_boost_range = source_overdrive_projector_range(block, phase_heat)
			last_overdrive_projector_boost = source_overdrive_projector_real_boost(block, phase_heat, 1.0)
			last_overdrive_projector_boost_duration = float(block.properties.get("reload", 0.0)) + 1.0
			var overdrive_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var target = find_overdrive_boost_target(overdrive_cell, block, phase_heat)
			apply_overdrive_boost_to_sprite(target, last_overdrive_projector_boost, last_overdrive_projector_boost_duration)
		overdrive_projector_use_progress[key] = float(overdrive_projector_use_progress.get(key, 0.0)) + source_delta
		if float(block.properties.get("useTime", 0.0)) > 0.0 and float(overdrive_projector_use_progress.get(key, 0.0)) >= float(block.properties.get("useTime", 0.0)):
			overdrive_projector_booster_items[key] = max(0, int(overdrive_projector_booster_items.get(key, 0)) - 1)
			overdrive_projector_use_progress[key] = fmod(float(overdrive_projector_use_progress.get(key, 0.0)), float(block.properties.get("useTime", 0.0)))
			overdrive_projector_optional_efficiency[key] = 1.0 if int(overdrive_projector_booster_items.get(key, 0)) > 0 else 0.0

func step_overdrive_projectors(seconds: float) -> Dictionary:
	simulate_overdrive_projectors(seconds)
	for key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(key)
		var block = block_from_sprite(sprite)
		if block != null and block.implementation == "OverdriveProjector":
			var origin_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var state := overdrive_projector_state_at_cell(origin_cell.x, origin_cell.y)
			state["last_overdrive_projector_boost_range"] = last_overdrive_projector_boost_range
			state["last_overdrive_projector_boost"] = last_overdrive_projector_boost
			state["last_overdrive_projector_boost_duration"] = last_overdrive_projector_boost_duration
			state["last_overdrive_projector_boosted_block_id"] = last_overdrive_projector_boosted_block_id
			state["last_overdrive_projector_boosted_cell"] = {"x": last_overdrive_projector_boosted_cell.x, "y": last_overdrive_projector_boosted_cell.y}
			return state
	return {
		"heat": 0.0,
		"smooth_efficiency": 0.0,
		"phase_heat": 0.0,
		"charge": 0.0,
		"use_progress": 0.0,
		"last_overdrive_projector_boost_range": last_overdrive_projector_boost_range,
		"last_overdrive_projector_boost": last_overdrive_projector_boost,
		"last_overdrive_projector_boost_duration": last_overdrive_projector_boost_duration,
		"last_overdrive_projector_boosted_block_id": last_overdrive_projector_boosted_block_id,
		"last_overdrive_projector_boosted_cell": {"x": last_overdrive_projector_boosted_cell.x, "y": last_overdrive_projector_boosted_cell.y},
	}

func selected_enemy_unit():
	if content_catalog == null:
		return null
	var dagger = content_catalog.get_by_id("dagger")
	if dagger != null:
		return dagger
	var units: Array = content_catalog.get_many("unit")
	return units[0] if not units.is_empty() else null

func spawn_enemy_wave() -> void:
	var spawned := 0
	for group in ContentRegistry.WAVES.get("groups", []):
		var count := spawned_for_wave(group, wave_index - 1)
		if count <= 0:
			continue
		var unit_type = content_catalog.get_by_id(str(group.get("unit", "")))
		if unit_type == null:
			continue
		for i in count:
			spawn_enemy_unit(unit_type, spawned + i)
		spawned += count
	if spawned == 0:
		var fallback = selected_enemy_unit()
		if fallback != null:
			spawn_enemy_unit(fallback, 0)

func spawned_for_wave(group: Dictionary, wave_zero: int) -> int:
	var begin := int(group.get("begin", 0))
	var end := int(group.get("end", 2147483647))
	var spacing: int = max(1, int(group.get("spacing", 1)))
	if wave_zero < begin or wave_zero > end or (wave_zero - begin) % spacing != 0:
		return 0
	var amount := int(group.get("unitAmount", 1))
	var scaling := float(group.get("unitScaling", 2147483647.0))
	var scaled: int = 0 if scaling >= 2147483647.0 else int((float(wave_zero - begin) / float(spacing)) / scaling)
	return mini(amount + scaled, int(group.get("max", 40)))

func spawn_enemy_unit(unit_type, index: int) -> void:
	var units_layer := get_node("World/UnitLayer")
	var sprite := Sprite2D.new()
	sprite.texture = textures.get("unit:" + unit_type.id)
	sprite.position = grid_to_world(Vector2i(WORLD_W - 2 + index, 6 + (index % 5)))
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			var hit_size := source_unit_hit_size(unit_type)
			sprite.scale = Vector2(hit_size / size.x, hit_size / size.y)
	units_layer.add_child(sprite)
	enemy_units.append({"sprite": sprite, "type": unit_type, "health": source_unit_health(unit_type)})

func simulate_enemy_units(delta: float) -> void:
	if core_health <= 0.0:
		return
	var alive := []
	var target := grid_to_world(core_pos)
	for enemy in enemy_units:
		var sprite = enemy.get("sprite")
		if not is_instance_valid(sprite):
			continue
		var direction: Vector2 = target - sprite.position
		var unit_type = enemy.get("type")
		if direction.length() <= float(tile_size) * 0.35:
			core_health = max(0.0, core_health - source_unit_weapon_damage(unit_type))
			sprite.queue_free()
			continue
		var speed := source_unit_world_speed(unit_type)
		sprite.position += direction.normalized() * speed * delta
		alive.append(enemy)
	enemy_units = alive
	if enemy_units.is_empty():
		wave_cooldown += delta
		if wave_cooldown >= 3.0:
			wave_index += 1
			wave_cooldown = 0.0
			spawn_enemy_wave()
	else:
		wave_cooldown = 0.0

func source_unit_weapon_damage(unit_type) -> float:
	if unit_type == null:
		return 0.0
	var weapons: Array = unit_type.properties.get("weapons", [])
	if weapons.is_empty():
		return 0.0
	var weapon: Dictionary = weapons[0]
	var bullet: Dictionary = weapon.get("bullet", {})
	return float(bullet.get("damage", 0.0))

func source_unit_world_speed(unit_type) -> float:
	if unit_type == null:
		return 0.0
	return float(unit_type.properties.get("speed", 0.0)) * 60.0

func source_unit_hit_size(unit_type) -> float:
	if unit_type == null:
		return 0.0
	return float(unit_type.properties.get("hitSize", 6.0))

func source_unit_health(unit_type) -> float:
	if unit_type == null:
		return 0.0
	return float(unit_type.properties.get("health", 200.0))

func source_unit_is_grounded(elevation_value: float) -> bool:
	return elevation_value < 0.001

func source_unit_is_flying(elevation_value: float) -> bool:
	return elevation_value >= 0.09

func source_unit_check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	var grounded: bool = source_unit_is_grounded(elevation_value)
	var flying: bool = source_unit_is_flying(elevation_value)
	return {
		"grounded": grounded,
		"flying": flying,
		"targetable": (grounded and target_ground) or (flying and target_air),
	}

func source_unit_can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	var grounded: bool = source_unit_is_grounded(elevation_value)
	return {
		"grounded": grounded,
		"can_drown": grounded and type_can_drown,
	}

func source_unit_drown_floor_state(floor_on_value: Variant) -> Variant:
	return floor_on_value

func source_unit_wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:
	var wobble_input := source_time + float(unit_id % 10) * 12.0
	var dx := source_arc_mathf_sin_scaled(wobble_input, 25.0, 0.05) * source_delta * elevation_value
	var dy := source_arc_mathf_cos_scaled(wobble_input, 25.0, 0.05) * source_delta * elevation_value
	return {
		"x": current_x + dx,
		"y": current_y + dy,
		"dx": dx,
		"dy": dy,
		"wobble_input": wobble_input,
	}

func source_unit_move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:
	var vel := Vector2(vel_x, vel_y)
	var target := Vector2(vector_x, vector_y)
	var delta := source_arc_vec2_limit(target - vel, acceleration * target.length() * source_delta)
	var next_vel := vel + delta
	return {
		"vel_x": next_vel.x,
		"vel_y": next_vel.y,
		"delta_x": delta.x,
		"delta_y": delta.y,
		"target_x": target.x,
		"target_y": target.y,
		"limit": acceleration * target.length() * source_delta,
	}

func source_unit_move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return {
		"vector": {"x": vector_x, "y": vector_y},
		"acceleration": type_accel,
		"call": "moveAt",
	}

func source_unit_approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	var vel := Vector2(vel_x, vel_y)
	var target := Vector2(vector_x, vector_y)
	var alpha := source_delta * type_accel * speed_value
	var diff := vel - target
	var alpha2 := alpha * alpha
	var len2 := diff.length_squared()
	var next_vel := Vector2.ZERO
	if len2 > alpha2:
		var scl := sqrt(alpha2 / len2)
		next_vel = vel - diff * scl
	else:
		next_vel = target
	return {
		"alpha": alpha,
		"vel_x": next_vel.x,
		"vel_y": next_vel.y,
		"target_x": target.x,
		"target_y": target.y,
	}

func source_unit_rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	var amount := Vector2(vec_x, vec_y).length()
	var radians := deg_to_rad(unit_rotation_degrees)
	var movement := Vector2(amount * source_arc_mathf_cos_lookup(radians), amount * source_arc_mathf_sin_lookup(radians))
	return {
		"call": "moveAt",
		"movement": {"x": movement.x, "y": movement.y},
		"amount": amount,
	}

func source_arc_mathf_mod_float(value: float, divisor: float) -> float:
	return fmod(fmod(value, divisor) + divisor, divisor)

func source_arc_angles_forward_distance(angle1: float, angle2: float) -> float:
	return abs(angle1 - angle2)

func source_arc_angles_backward_distance(angle1: float, angle2: float) -> float:
	return 360.0 - abs(angle1 - angle2)

func source_arc_angles_angle_dist(angle_a: float, angle_b: float) -> float:
	angle_a = source_arc_mathf_mod_float(angle_a, 360.0)
	angle_b = source_arc_mathf_mod_float(angle_b, 360.0)
	var forward := angle_a - angle_b + 360.0 if (angle_a - angle_b) < 0.0 else angle_a - angle_b
	var backward := angle_b - angle_a + 360.0 if (angle_b - angle_a) < 0.0 else angle_b - angle_a
	return min(forward, backward)

func source_arc_angles_move_toward(angle: float, to: float, speed: float) -> float:
	if abs(source_arc_angles_angle_dist(angle, to)) < speed:
		return to
	angle = source_arc_mathf_mod_float(angle, 360.0)
	to = source_arc_mathf_mod_float(to, 360.0)
	if (angle > to) == (source_arc_angles_backward_distance(angle, to) > source_arc_angles_forward_distance(angle, to)):
		angle -= speed
	else:
		angle += speed
	return angle

func source_unit_vec2_angle(vec_x: float, vec_y: float) -> float:
	var angle := rad_to_deg(atan2(vec_y, vec_x))
	if angle < 0.0:
		angle += 360.0
	return angle

func source_unit_rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var vector_is_zero := vec_x == 0.0 and vec_y == 0.0
	var target_rotation := source_unit_vec2_angle(vec_x, vec_y) if not vector_is_zero else current_rotation
	var next_rotation := current_rotation
	if not vector_is_zero:
		next_rotation = source_arc_angles_move_toward(current_rotation, target_rotation, type_rotate_speed * source_delta * speed_multiplier_value)
	return {
		"vector_is_zero": vector_is_zero,
		"target_rotation": target_rotation,
		"rotation": next_rotation,
	}

func source_unit_aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return {
		"target": {"x": pos_x, "y": pos_y},
		"aim_call": "aim(Position)",
		"look_at_call": "lookAt(Position)",
		"call_order": ["aim", "lookAt"],
	}

func source_unit_aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return {
		"target": {"x": target_x, "y": target_y},
		"aim_call": "aim(float, float)",
		"look_at_call": "lookAt(float, float)",
		"call_order": ["aim", "lookAt"],
	}

func source_unit_look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var rotation_speed := type_rotate_speed * source_delta * speed_multiplier_value
	var next_rotation := source_arc_angles_move_toward(current_rotation, target_angle, rotation_speed)
	return {
		"target_angle": target_angle,
		"rotation_speed": rotation_speed,
		"rotation": next_rotation,
	}

func source_arc_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	var angle := rad_to_deg(atan2(to_y - from_y, to_x - from_x))
	if angle < 0.0:
		angle += 360.0
	return angle

func source_unit_look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var target_angle := source_arc_angles_angle(unit_x, unit_y, target_x, target_y)
	var angle_state := source_unit_look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta)
	return {
		"call": "lookAt(angleTo(pos))",
		"target": {"x": target_x, "y": target_y},
		"target_angle": angle_state["target_angle"],
		"rotation_speed": angle_state["rotation_speed"],
		"rotation": angle_state["rotation"],
	}

func source_unit_look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var target_angle := source_arc_angles_angle(unit_x, unit_y, target_x, target_y)
	var angle_state := source_unit_look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta)
	return {
		"call": "lookAt(angleTo(x, y))",
		"target": {"x": target_x, "y": target_y},
		"target_angle": angle_state["target_angle"],
		"rotation_speed": angle_state["rotation_speed"],
		"rotation": angle_state["rotation"],
	}

func source_unit_controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return {
		"is_ai": controller_is_ai_controller,
		"allow_command": controller_is_command_ai,
		"is_commandable": controller_is_command_ai,
	}

func source_unit_can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	if not other_exists:
		return {"branch": "null", "can_target": false}
	if other_is_unit:
		return {
			"branch": "unit",
			"can_target": other_unit_check_target_result,
			"unit_check_target_air": type_target_air,
			"unit_check_target_ground": type_target_ground,
		}
	return {
		"branch": "building" if other_is_building else "other",
		"can_target": other_is_building and type_target_ground,
	}

func source_unit_command_state(controller_is_command_ai: bool) -> Dictionary:
	if controller_is_command_ai:
		return {
			"returned_command_ai": true,
			"throws": false,
			"exception_type": "",
			"message": "",
		}
	return {
		"returned_command_ai": false,
		"throws": true,
		"exception_type": "IllegalArgumentException",
		"message": "Unit cannot be commanded - check isCommandable() first.",
	}

func source_unit_is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return {
		"is_missile": unit_is_timed_killc,
		"instanceof": "TimedKillc",
	}

func source_unit_count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return {
		"count": team_data_count_type_result,
		"type_id": type_id,
		"call": "team.data().countType(type)",
	}

func source_unit_cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	if (team_is_wave_team and not rules_pvp) or (state_is_campaign and team_is_wave_team) or rules_disable_unit_cap or team_ignore_unit_cap:
		return {
			"cap": 2147483647,
			"uncapped": true,
			"call": "Units.getCap(team)",
		}
	if rules_unit_cap_variable:
		return {
			"cap": max(0, rules_unit_cap + team_data_unit_cap),
			"uncapped": false,
			"call": "Units.getCap(team)",
		}
	return {
		"cap": max(0, rules_unit_cap),
		"uncapped": false,
		"call": "Units.getCap(team)",
	}

func source_unit_set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return {
		"assigned_type_id": type_id,
		"maxHealth": type_health,
		"drag": type_drag,
		"armor": type_armor,
		"hitSize": type_hit_size,
		"setupWeapons": mounts_length != type_weapons_size,
		"refreshAbilities": abilities_length != type_abilities_size or (abilities_length > 0 and first_ability_is_empty_data_ability),
		"createController": controller_is_null,
		"call": "setType(UnitType type)",
	}

func source_weapons_setup_mounts_state(weapon_states: Array) -> Dictionary:
	var mounts: Array = []
	for index in weapon_states.size():
		var weapon_state: Dictionary = weapon_states[index]
		mounts.append({
			"index": index,
			"weapon": str(weapon_state.get("weapon", "weapon%d" % index)),
			"call": "def.weapons.get(i).mountType.get(def.weapons.get(i))",
			"constructor": "public WeaponMount(Weapon weapon)",
			"rotation": float(weapon_state.get("baseRotation", 0.0)),
		})
	return {
		"array": "mounts = new WeaponMount[def.weapons.size]",
		"loop": "for(int i = 0; i < mounts.length; i++)",
		"mounts": mounts,
	}

func source_weapons_set_rotation_state(mount_states: Array, source_rotation: float) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"assignment": "mount.rotation = rotation",
			"sourceParameter": "rotation",
			"rotation": source_rotation,
		})
	return {
		"loop": "for(WeaponMount mount : mounts)",
		"mounts": mounts,
	}

func source_weapons_control_state(mount_states: Array, rotate_value: bool, shoot_value: bool) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var controllable := bool(mount_state.get("controllable", true))
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"controlled": controllable,
			"guard": "mount.weapon.controllable",
			"rotateAssignment": "mount.rotate = rotate",
			"shootAssignment": "mount.shoot = shoot",
			"rotate": rotate_value if controllable else bool(mount_state.get("rotate", false)),
			"shoot": shoot_value if controllable else bool(mount_state.get("shoot", false)),
		})
	return {
		"loop": "for(WeaponMount mount : mounts)",
		"delegate": "controlWeapons(rotateShoot, rotateShoot)",
		"isRotate": rotate_value,
		"isShooting": shoot_value,
		"mounts": mounts,
	}

func source_weapons_control_rotate_shoot_state(mount_states: Array, rotate_shoot: bool) -> Dictionary:
	return source_weapons_control_state(mount_states, rotate_shoot, rotate_shoot)

func source_weapons_aim_state(mount_states: Array, unit_x: float, unit_y: float, target_x: float, target_y: float, aim_dst: float) -> Dictionary:
	var aim_vector := Vector2(target_x, target_y) - Vector2(unit_x, unit_y)
	if aim_vector.length() < aim_dst and aim_vector.length_squared() > 0.0:
		aim_vector = aim_vector.normalized() * aim_dst
	var final_x := aim_vector.x + unit_x
	var final_y := aim_vector.y + unit_y
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var controllable := bool(mount_state.get("controllable", true))
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"controlled": controllable,
			"guard": "mount.weapon.controllable",
			"aimXAssignment": "mount.aimX = x",
			"aimYAssignment": "mount.aimY = y",
			"aimX": final_x if controllable else float(mount_state.get("aimX", 0.0)),
			"aimY": final_y if controllable else float(mount_state.get("aimY", 0.0)),
		})
	return {
		"tmp": "Tmp.v1.set(x, y).sub(this.x, this.y)",
		"minDistance": "if(Tmp.v1.len() < type.aimDst) Tmp.v1.setLength(type.aimDst)",
		"zeroVectorSetLength": "oldLen2 == 0 returns this",
		"aimX": final_x,
		"aimY": final_y,
		"mounts": mounts,
	}

func source_weapons_aim_position_state(mount_states: Array, unit_x: float, unit_y: float, position_x: float, position_y: float, aim_dst: float) -> Dictionary:
	return source_weapons_aim_state(mount_states, unit_x, unit_y, position_x, position_y, aim_dst)

func source_weapons_can_shoot_state(disarmed_value: bool) -> Dictionary:
	var can_shoot := not disarmed_value
	return {
		"return": "!disarmed",
		"disarmed": disarmed_value,
		"canShoot": can_shoot,
	}

func source_weapons_remove_continuous_bullet_cleanup_state(mount_states: Array, unit_id: int) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var bullet_state: Dictionary = mount_state.get("bullet", {})
		var has_bullet := not bullet_state.is_empty()
		var owns_bullet := has_bullet and int(bullet_state.get("owner", -1)) == unit_id
		var continuous := bool(mount_state.get("continuous", false))
		var cleanup := continuous and has_bullet and owns_bullet
		var result_bullet = null
		var bullet_time = null
		if has_bullet:
			bullet_time = float(bullet_state.get("lifetime", 0.0)) - 10.0
			if not cleanup:
				bullet_time = float(bullet_state.get("time", 0.0))
				result_bullet = {
					"owner": int(bullet_state.get("owner", -1)),
					"time": bullet_time,
					"lifetime": float(bullet_state.get("lifetime", 0.0)),
				}
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"guard": "mount.weapon.continuous && mount.bullet != null && mount.bullet.owner == self()",
			"continuous": continuous,
			"hadBullet": has_bullet,
			"ownsBullet": owns_bullet,
			"cleanup": cleanup,
			"timeAssignment": "mount.bullet.time = mount.bullet.lifetime - 10f",
			"clearAssignment": "mount.bullet = null",
			"bulletTime": bullet_time,
			"bullet": result_bullet,
		})
	return {
		"loop": "for(WeaponMount mount : mounts)",
		"unit": unit_id,
		"mounts": mounts,
	}

func source_weapons_remove_sound_stop_state(mount_states: Array) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var has_sound := bool(mount_state.get("sound", false))
		var stop_call = null
		if has_sound:
			stop_call = {
				"call": "mount.sound.stop()",
				"method": "public void stop()",
				"idGuard": "if(id != -1)",
				"effects": ["Core.audio.stop(id)", "id = -1", "volume = 0f"],
			}
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"guard": "mount.sound != null",
			"hasSound": has_sound,
			"stopCall": stop_call,
		})
	return {
		"loop": "for(WeaponMount mount : mounts)",
		"mounts": mounts,
	}

func source_weapons_update_dispatch_state(mount_states: Array, unit_id: int) -> Dictionary:
	var dispatches: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		dispatches.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"unit": unit_id,
			"call": "mount.weapon.update(self(), mount)",
			"unitArg": "self()",
			"mountArg": "mount",
			"weaponUpdateMethod": "public void update(Unit unit, WeaponMount mount)",
		})
	return {
		"loop": "for(WeaponMount mount : mounts)",
		"mountsField": "@SyncLocal WeaponMount[] mounts = {}",
		"dispatches": dispatches,
	}

func source_mathf_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return from_value + clampf(to_value - from_value, -source_delta * speed, source_delta * speed)

func source_mathf_dst(x1: float, y1: float, x2: float, y2: float) -> float:
	var xd := x2 - x1
	var yd := y2 - y1
	return sqrt(xd * xd + yd * yd)

func source_mathf_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return from_value + (to_value - from_value) * clampf(progress * source_delta, 0.0, 1.0)

func source_weapon_update_passive_timers_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float) -> Dictionary:
	var can_shoot := bool(unit_state.get("canShoot", false))
	var reload_multiplier := float(unit_state.get("reloadMultiplier", 1.0))
	var current_reload := float(mount_state.get("reload", 0.0))
	var current_recoil := float(mount_state.get("recoil", 0.0))
	var current_smooth_reload := float(mount_state.get("smoothReload", 0.0))
	var current_charge := float(mount_state.get("charge", 0.0))
	var current_warmup := float(mount_state.get("warmup", 0.0))
	var charging := bool(mount_state.get("charging", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var bullet_state = mount_state.get("bullet", null)
	var has_bullet: bool = bullet_state != null and not (bullet_state is Dictionary and bullet_state.is_empty())
	var reload_time := float(weapon_state.get("reload", 1.0))
	var recoil_time := float(weapon_state.get("recoilTime", reload_time))
	var recoils_count := int(weapon_state.get("recoils", -1))
	var smooth_reload_speed := float(weapon_state.get("smoothReloadSpeed", 0.15))
	var first_shot_delay := float(weapon_state.get("firstShotDelay", 0.0))
	var continuous := bool(weapon_state.get("continuous", false))
	var shoot_warmup_speed := float(weapon_state.get("shootWarmupSpeed", 0.1))
	var linear_warmup := bool(weapon_state.get("linearWarmup", false))
	var new_reload: float = maxf(current_reload - source_delta * reload_multiplier, 0.0)
	var new_recoil := source_mathf_approach_delta(current_recoil, 0.0, reload_multiplier / recoil_time, source_delta)
	var new_recoils: Array = []
	var mount_recoils = mount_state.get("recoils", [])
	if recoils_count > 0:
		for i in range(recoils_count):
			var recoil_value := 0.0
			if mount_recoils is Array and i < mount_recoils.size():
				recoil_value = float(mount_recoils[i])
			new_recoils.append(source_mathf_approach_delta(recoil_value, 0.0, reload_multiplier / recoil_time, source_delta))
	var new_smooth_reload := source_mathf_lerp_delta(current_smooth_reload, new_reload / reload_time, smooth_reload_speed, source_delta)
	var new_charge := 0.0
	if charging and first_shot_delay > 0.0:
		new_charge = source_mathf_approach_delta(current_charge, 1.0, 1.0 / first_shot_delay, source_delta)
	var warmup_target := 1.0 if ((can_shoot and mount_shoot) or (continuous and has_bullet) or charging) else 0.0
	var new_warmup := 0.0
	if linear_warmup:
		new_warmup = source_mathf_approach_delta(current_warmup, warmup_target, shoot_warmup_speed, source_delta)
	else:
		new_warmup = source_mathf_lerp_delta(current_warmup, warmup_target, shoot_warmup_speed, source_delta)
	return {
		"canShootCall": "boolean can = unit.canShoot()",
		"canShoot": can_shoot,
		"lastReload": current_reload,
		"reload": new_reload,
		"recoil": new_recoil,
		"recoils": new_recoils,
		"smoothReload": new_smooth_reload,
		"charge": new_charge,
		"warmupTarget": warmup_target,
		"warmup": new_warmup,
		"reloadAssignment": "mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0)",
		"recoilAssignment": "mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime)",
		"smoothReloadAssignment": "mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed)",
		"chargeAssignment": "mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0",
		"warmupTargetSource": "(can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f",
		"warmupMode": "Mathf.approachDelta" if linear_warmup else "Mathf.lerpDelta",
		"deltaSource": "Time.delta",
	}

func source_arc_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	var radians := deg_to_rad(angle_degrees)
	var cos_value := cos(radians)
	var sin_value := sin(radians)
	var new_x := x_value * cos_value - y_value * sin_value
	var new_y := x_value * sin_value + y_value * cos_value
	return {
		"x": new_x,
		"y": new_y,
		"angle": angle_degrees,
		"source": "rv.set(x, y).rotate(angle)",
		"vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos",
	}

func source_weapon_update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_x := float(weapon_state.get("x", 5.0))
	var weapon_y := float(weapon_state.get("y", 0.0))
	var angle_degrees := unit_rotation - 90.0
	var rotated := source_arc_angles_trns_vec(angle_degrees, weapon_x, weapon_y)
	var mount_x := unit_x + float(rotated["x"])
	var mount_y := unit_y + float(rotated["y"])
	return {
		"angle": angle_degrees,
		"trnsx": float(rotated["x"]),
		"trnsy": float(rotated["y"]),
		"mountX": mount_x,
		"mountY": mount_y,
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y)",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y)",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos",
	}

func source_weapon_update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	var controllable := bool(weapon_state.get("controllable", true))
	var auto_target := bool(weapon_state.get("autoTarget", false))
	var current_retarget := float(mount_state.get("retarget", 0.0))
	var target_interval := float(weapon_state.get("targetInterval", 40.0))
	var target_switch_interval := float(weapon_state.get("targetSwitchInterval", 70.0))
	var current_target_exists := bool(mount_state.get("targetExists", false))
	var gate := (not controllable) and auto_target
	var retarget_after_decrement := current_retarget - source_delta
	var next_retarget := current_retarget
	var target_exists := current_target_exists
	var finder_call: Variant = null
	if gate:
		next_retarget = retarget_after_decrement
	if gate and retarget_after_decrement <= 0.0:
		finder_call = {
			"call": "findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround)",
			"mountX": mount_x,
			"mountY": mount_y,
			"range": float(bullet_state.get("range", 0.0)),
			"air": bool(bullet_state.get("collidesAir", true)),
			"ground": bool(bullet_state.get("collidesGround", true)),
		}
		target_exists = find_target_result_exists
		next_retarget = target_switch_interval if target_exists else target_interval
	return {
		"gate": gate,
		"retarget": next_retarget,
		"retargetAfterDecrement": retarget_after_decrement,
		"findTargetCalled": finder_call != null,
		"findTargetCall": finder_call,
		"targetExists": target_exists,
		"gateSource": "if(!controllable && autoTarget)",
		"retargetSource": "if((mount.retarget -= Time.delta) <= 0f)",
		"findTargetSource": "mount.target = findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround)",
		"intervalSource": "mount.retarget = mount.target == null ? targetInterval : targetSwitchInterval",
	}

func source_weapon_update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	var controllable := bool(weapon_state.get("controllable", true))
	var auto_target := bool(weapon_state.get("autoTarget", false))
	var target_exists := bool(mount_state.get("targetExists", false))
	var gate := (not controllable) and auto_target
	var check_called := gate and target_exists
	var check_call: Variant = null
	if check_called:
		check_call = {
			"call": "checkTarget(unit, mount.target, mountX, mountY, bullet.range)",
			"mountX": mount_x,
			"mountY": mount_y,
			"range": float(bullet_state.get("range", 0.0)),
			"shootY": float(weapon_state.get("shootY", 3.0)),
			"rangeWithShootY": float(bullet_state.get("range", 0.0)) + absf(float(weapon_state.get("shootY", 3.0))),
		}
	if check_called and check_target_result:
		target_exists = false
	return {
		"gate": gate,
		"checkTargetCalled": check_called,
		"checkTargetCall": check_call,
		"checkTargetResult": check_target_result if check_called else false,
		"targetExists": target_exists,
		"targetCleared": check_called and check_target_result,
		"gateSource": "if(!controllable && autoTarget)",
		"guardSource": "if(mount.target != null && checkTarget(unit, mount.target, mountX, mountY, bullet.range))",
		"clearSource": "mount.target = null",
		"checkTargetSource": "Units.invalidateTarget(target, unit.team, x, y, range + Math.abs(shootY))",
		"invalidateTargetSource": "target == null || out of range || same team || invalid health || unit not targetable",
	}

func source_weapon_update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	var target_exists := bool(mount_state.get("targetExists", false))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var bullet_range := float(bullet_state.get("range", 0.0))
	var shoot_y := float(weapon_state.get("shootY", 3.0))
	var target_hit_size := float(mount_state.get("targetHitSize", 0.0)) if bool(mount_state.get("targetSized", false)) else 0.0
	var predict_target := bool(weapon_state.get("predictTarget", true))
	var within_range := bullet_range + absf(shoot_y) + target_hit_size / 2.0
	var shoot := false
	if target_exists:
		shoot = target_within_result and can_shoot
		if predict_target:
			aim_x = float(predicted_aim.get("x", aim_x))
			aim_y = float(predicted_aim.get("y", aim_y))
		else:
			aim_x = float(mount_state.get("targetX", aim_x))
			aim_y = float(mount_state.get("targetY", aim_y))
	var next_rotate := shoot
	return {
		"targetExists": target_exists,
		"withinRange": within_range,
		"targetWithin": target_within_result if target_exists else false,
		"canShoot": can_shoot,
		"shoot": shoot,
		"rotate": next_rotate,
		"aimX": aim_x,
		"aimY": aim_y,
		"predictTarget": predict_target,
		"mountX": mount_x,
		"mountY": mount_y,
		"withinSource": "mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f))",
		"shootSource": "shoot = mount.target.within(...) && can",
		"predictSource": "Predict.intercept(unit, mount.target, bullet)",
		"directAimSource": "mount.target.x()/mount.target.y()",
		"shootRotateSource": "mount.shoot = mount.rotate = shoot",
	}

func source_weapon_update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float) -> Dictionary:
	var mount_rotate := bool(mount_state.get("rotate", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var current_rotation := float(mount_state.get("rotation", 0.0))
	var current_target_rotation := float(mount_state.get("targetRotation", 0.0))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var weapon_x := float(weapon_state.get("x", 5.0))
	var weapon_y := float(weapon_state.get("y", 0.0))
	var rotate_speed := float(weapon_state.get("rotateSpeed", 20.0))
	var rotation_limit := float(weapon_state.get("rotationLimit", 361.0))
	var base_rotation := float(weapon_state.get("baseRotation", 0.0))
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var gate := bool(weapon_state.get("rotate", false)) and (mount_rotate or mount_shoot) and can_shoot
	var non_rotate_branch := not bool(weapon_state.get("rotate", false))
	var axis_angle := unit_rotation - 90.0
	var axis_vec := source_arc_angles_trns_vec(axis_angle, weapon_x, weapon_y)
	var axis_x := unit_x + float(axis_vec["x"])
	var axis_y := unit_y + float(axis_vec["y"])
	var target_rotation := current_target_rotation
	var next_rotation := current_rotation
	var limit_dst := 0.0
	if gate:
		target_rotation = source_arc_angles_angle(axis_x, axis_y, aim_x, aim_y) - unit_rotation
		next_rotation = source_arc_angles_move_toward(current_rotation, target_rotation, rotate_speed * source_delta)
	if gate and rotation_limit < 360.0:
		limit_dst = source_arc_angles_angle_dist(next_rotation, base_rotation)
		if limit_dst > rotation_limit / 2.0:
			next_rotation = source_arc_angles_move_toward(next_rotation, base_rotation, limit_dst - rotation_limit / 2.0)
	elif non_rotate_branch:
		next_rotation = base_rotation
		target_rotation = source_arc_angles_angle(unit_x, unit_y, aim_x, aim_y)
	return {
		"gate": gate,
		"axisAngle": axis_angle,
		"axisX": axis_x,
		"axisY": axis_y,
		"targetRotation": target_rotation,
		"rotation": next_rotation,
		"rotationLimit": rotation_limit,
		"baseRotation": base_rotation,
		"limitDistance": limit_dst,
		"rotationLimitApplied": gate and rotation_limit < 360.0 and limit_dst > rotation_limit / 2.0,
		"nonRotateApplied": non_rotate_branch,
		"canShoot": can_shoot,
		"mountRotate": mount_rotate,
		"mountShoot": mount_shoot,
		"gateSource": "if(rotate && (mount.rotate || mount.shoot) && can)",
		"axisXSource": "axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y)",
		"axisYSource": "axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y)",
		"targetRotationSource": "mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation",
		"rotationSource": "mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta)",
		"rotationLimitSource": "if(rotationLimit < 360)",
		"limitDistanceSource": "float dst = Angles.angleDist(mount.rotation, baseRotation)",
		"limitMoveSource": "mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f)",
		"nonRotateSource": "else if(!rotate)",
		"baseRotationSource": "mount.rotation = baseRotation",
		"angleToSource": "mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY)",
	}

func source_weapon_update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float) -> Dictionary:
	var rotate_weapon := bool(weapon_state.get("rotate", false))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", 0.0))
	var shoot_x := float(weapon_state.get("shootX", 0.0))
	var shoot_y := float(weapon_state.get("shootY", 3.0))
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_rotation := unit_rotation - 90.0 + (mount_rotation if rotate_weapon else base_rotation)
	var bullet_vec := source_arc_angles_trns_vec(weapon_rotation, shoot_x, shoot_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	var shoot_angle := unit_rotation + mount_rotation
	if not rotate_weapon:
		shoot_angle = source_arc_angles_angle(bullet_x, bullet_y, aim_x, aim_y) + (unit_rotation - source_arc_angles_angle(unit_x, unit_y, aim_x, aim_y)) + base_rotation
	return {
		"rotate": rotate_weapon,
		"weaponRotation": weapon_rotation,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"shootAngle": shoot_angle,
		"mountX": mount_x,
		"mountY": mount_y,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"baseRotation": base_rotation,
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation)",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY)",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY)",
		"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY)",
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
	}

func source_weapon_update_always_shooting_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var shoot := bool(mount_state.get("shoot", false))
	var always_shooting := bool(weapon_state.get("alwaysShooting", false))
	if always_shooting:
		shoot = true
	return {
		"shoot": shoot,
		"alwaysShooting": always_shooting,
		"alwaysShootingSource": "if(alwaysShooting) mount.shoot = true",
		"continuousReservedSource": "if(continuous && mount.bullet != null)",
	}

func source_weapon_update_continuous_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var bullet_is_added := bool(bullet_state.get("isAdded", false))
	var bullet_time := float(bullet_state.get("time", 0.0))
	var bullet_lifetime := float(bullet_state.get("lifetime", 0.0))
	var bullet_type_matches := bool(bullet_state.get("typeMatches", false))
	var gate := continuous and bullet_exists
	var invalid := gate and ((not bullet_is_added) or bullet_time >= bullet_lifetime or (not bullet_type_matches))
	if invalid:
		bullet_exists = false
	return {
		"gate": gate,
		"invalid": invalid,
		"bulletExists": bullet_exists,
		"continuous": continuous,
		"bulletIsAdded": bullet_is_added,
		"bulletTime": bullet_time,
		"bulletLifetime": bullet_lifetime,
		"bulletTypeMatches": bullet_type_matches,
		"guardSource": "if(continuous && mount.bullet != null)",
		"invalidConditionSource": "if(!mount.bullet.isAdded() || mount.bullet.time >= mount.bullet.lifetime || mount.bullet.type != bullet)",
		"clearSource": "mount.bullet = null",
	}

func source_weapon_update_continuous_live_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var bullet_is_added := bool(bullet_state.get("isAdded", false))
	var bullet_time := float(bullet_state.get("time", 0.0))
	var bullet_lifetime := float(bullet_state.get("lifetime", 0.0))
	var bullet_type_matches := bool(bullet_state.get("typeMatches", false))
	var gate := continuous and bullet_exists
	var invalid := gate and ((not bullet_is_added) or bullet_time >= bullet_lifetime or (not bullet_type_matches))
	var live := gate and not invalid
	var weapon_reload := float(weapon_state.get("reload", 1.0))
	var bullet_recoil := float(bullet_state.get("recoil", 0.0))
	var next_reload := float(mount_state.get("reload", 0.0))
	var next_recoil := float(mount_state.get("recoil", 0.0))
	var next_bullet_rotation := weapon_rotation + 90.0
	var next_bullet_x := float(bullet_state.get("x", bullet_x))
	var next_bullet_y := float(bullet_state.get("y", bullet_y))
	var next_vel_x := float(unit_state.get("velX", 0.0))
	var next_vel_y := float(unit_state.get("velY", 0.0))
	var recoil_vec := source_arc_angles_trns_vec(next_bullet_rotation + 180.0, bullet_recoil * source_delta, 0.0)
	if live:
		next_bullet_x = bullet_x
		next_bullet_y = bullet_y
		next_reload = weapon_reload
		next_recoil = 1.0
		next_vel_x += float(recoil_vec.get("x", 0.0))
		next_vel_y += float(recoil_vec.get("y", 0.0))
	else:
		next_bullet_rotation = float(bullet_state.get("rotation", next_bullet_rotation))
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"bulletRotation": next_bullet_rotation,
		"bulletX": next_bullet_x,
		"bulletY": next_bullet_y,
		"reload": next_reload,
		"recoil": next_recoil,
		"velX": next_vel_x,
		"velY": next_vel_y,
		"velAddX": float(recoil_vec.get("x", 0.0)) if live else 0.0,
		"velAddY": float(recoil_vec.get("y", 0.0)) if live else 0.0,
		"bulletRotationSource": "mount.bullet.rotation(weaponRotation + 90)",
		"bulletSetSource": "mount.bullet.set(bulletX, bulletY)",
		"reloadSource": "mount.reload = reload",
		"recoilSource": "mount.recoil = 1f",
		"velocityAddSource": "unit.vel.add(Tmp.v1.trns(mount.bullet.rotation() + 180f, mount.bullet.type.recoil * Time.delta))",
		"soundReservedSource": "if(shootSound != Sounds.none && !headless)",
	}

func source_weapon_update_continuous_sound_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, runtime_state: Dictionary, bullet_x: float, bullet_y: float) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var bullet_is_added := bool(bullet_state.get("isAdded", false))
	var bullet_time := float(bullet_state.get("time", 0.0))
	var bullet_lifetime := float(bullet_state.get("lifetime", 0.0))
	var bullet_type_matches := bool(bullet_state.get("typeMatches", false))
	var gate := continuous and bullet_exists
	var invalid := gate and ((not bullet_is_added) or bullet_time >= bullet_lifetime or (not bullet_type_matches))
	var live := gate and not invalid
	var shoot_sound_is_none := bool(weapon_state.get("shootSoundIsNone", false))
	var headless := bool(runtime_state.get("headless", false))
	var sound_gate := live and (not shoot_sound_is_none) and (not headless)
	var has_sound := bool(mount_state.get("hasSound", false))
	var created_sound := sound_gate and not has_sound
	var sound_update_call = null
	if created_sound:
		has_sound = true
	if sound_gate:
		sound_update_call = {
			"x": bullet_x,
			"y": bullet_y,
			"play": true,
			"call": "mount.sound.update(bulletX, bulletY, true)",
		}
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"soundGate": sound_gate,
		"hasSound": has_sound,
		"createdSound": created_sound,
		"soundUpdateCall": sound_update_call,
		"shootSoundIsNone": shoot_sound_is_none,
		"headless": headless,
		"soundGuardSource": "if(shootSound != Sounds.none && !headless)",
		"soundCreateSource": "if(mount.sound == null) mount.sound = new SoundLoop(shootSound, 1f)",
		"soundUpdateSource": "mount.sound.update(bulletX, bulletY, true)",
		"soundLoopUpdateSource": "update(x, y, play, 1f)",
		"laserLengthReservedSource": "//target length of laser",
	}

func source_weapon_update_continuous_laser_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var bullet_is_added := bool(bullet_state.get("isAdded", false))
	var bullet_time := float(bullet_state.get("time", 0.0))
	var bullet_lifetime := float(bullet_state.get("lifetime", 0.0))
	var bullet_type_matches := bool(bullet_state.get("typeMatches", false))
	var gate := continuous and bullet_exists
	var invalid := gate and ((not bullet_is_added) or bullet_time >= bullet_lifetime or (not bullet_type_matches))
	var live := gate and not invalid
	var mount_aim_x := float(mount_state.get("aimX", bullet_x))
	var mount_aim_y := float(mount_state.get("aimY", bullet_y))
	var bullet_aim_x := float(bullet_state.get("aimX", bullet_x))
	var bullet_aim_y := float(bullet_state.get("aimY", bullet_y))
	var weapon_range := float(bullet_state.get("range", 0.0))
	var aim_change_speed := float(weapon_state.get("aimChangeSpeed", 0.0))
	var shoot_length: float = min(source_mathf_dst(bullet_x, bullet_y, mount_aim_x, mount_aim_y), weapon_range)
	var cur_length: float = source_mathf_dst(bullet_x, bullet_y, bullet_aim_x, bullet_aim_y)
	var result_length: float = source_mathf_approach_delta(cur_length, shoot_length, aim_change_speed, source_delta)
	var aim_vec := source_arc_angles_trns_vec(shoot_angle, result_length, 0.0)
	var next_last_length := float(mount_state.get("lastLength", 0.0))
	var next_bullet_aim_x := bullet_aim_x
	var next_bullet_aim_y := bullet_aim_y
	if live:
		next_last_length = result_length
		next_bullet_aim_x = bullet_x + float(aim_vec.get("x", 0.0))
		next_bullet_aim_y = bullet_y + float(aim_vec.get("y", 0.0))
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"shootLength": shoot_length,
		"curLength": cur_length,
		"resultLength": result_length,
		"lastLength": next_last_length,
		"bulletAimX": next_bullet_aim_x,
		"bulletAimY": next_bullet_aim_y,
		"weaponRange": weapon_range,
		"aimChangeSpeed": aim_change_speed,
		"shootLengthSource": "float shootLength = Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY), range())",
		"curLengthSource": "float curLength = Mathf.dst(bulletX, bulletY, mount.bullet.aimX, mount.bullet.aimY)",
		"resultLengthSource": "float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed)",
		"aimEndpointSource": "Tmp.v1.trns(shootAngle, mount.lastLength = resultLength).add(bulletX, bulletY)",
		"bulletAimXSource": "mount.bullet.aimX = Tmp.v1.x",
		"bulletAimYSource": "mount.bullet.aimY = Tmp.v1.y",
		"rangeSource": "return bullet.range",
		"alwaysContinuousReservedSource": "if(alwaysContinuous && mount.shoot)",
	}

func source_status_apply_result(status_effect: String, duration: float, status_immune: bool) -> Dictionary:
	var status_applied := status_effect != "none" and status_effect != "" and not status_immune
	var status_application: Dictionary = {}
	if status_applied:
		status_application = {"effect": status_effect, "duration": duration}
	return {
		"statusApplied": status_applied,
		"statusApplication": status_application,
		"statusApplyGuardSource": "if(effect == StatusEffects.none || effect == null || isImmune(effect)) return",
	}

func source_weapon_update_always_continuous_keepalive_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var bullet_is_added := bool(bullet_state.get("isAdded", false))
	var bullet_time := float(bullet_state.get("time", 0.0))
	var bullet_lifetime := float(bullet_state.get("lifetime", 0.0))
	var bullet_type_matches := bool(bullet_state.get("typeMatches", false))
	var gate := continuous and bullet_exists
	var invalid := gate and ((not bullet_is_added) or bullet_time >= bullet_lifetime or (not bullet_type_matches))
	var live := gate and not invalid
	var always_continuous := bool(weapon_state.get("alwaysContinuous", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var mount_warmup := float(mount_state.get("warmup", 0.0))
	var optimal_life_fract := float(bullet_state.get("optimalLifeFract", 0.0))
	var keepalive_gate := live and always_continuous and mount_shoot
	var next_bullet_time := bullet_time
	var next_keep_alive := bool(bullet_state.get("keepAlive", false))
	if keepalive_gate:
		next_bullet_time = bullet_lifetime * optimal_life_fract * mount_warmup
		next_keep_alive = true
	var shoot_status := "" if weapon_state.get("shootStatus", "none") == null else str(weapon_state.get("shootStatus", "none"))
	var shoot_status_duration := float(weapon_state.get("shootStatusDuration", 0.0))
	var status_immune := bool(unit_state.get("statusImmune", false))
	var status_result := source_status_apply_result(shoot_status, shoot_status_duration, status_immune)
	var status_applied := keepalive_gate and bool(status_result.get("statusApplied", false))
	var status_application: Dictionary = {}
	if status_applied:
		status_application = status_result.get("statusApplication", {})
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"alwaysContinuous": always_continuous,
		"mountShoot": mount_shoot,
		"keepaliveGate": keepalive_gate,
		"bulletTime": next_bullet_time,
		"keepAlive": next_keep_alive,
		"shootStatus": shoot_status,
		"shootStatusDuration": shoot_status_duration,
		"statusImmune": status_immune,
		"statusApplied": status_applied,
		"statusApplication": status_application,
		"guardSource": "if(alwaysContinuous && mount.shoot)",
		"timeSource": "mount.bullet.time = mount.bullet.lifetime * mount.bullet.type.optimalLifeFract * mount.warmup",
		"keepAliveSource": "mount.bullet.keepAlive = true",
		"unitApplySource": "unit.apply(shootStatus, shootStatusDuration)",
		"statusApplyGuardSource": status_result.get("statusApplyGuardSource", ""),
	}

func source_weapon_update_continuous_idle_heat_sound_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var continuous_live_gate := continuous and bullet_exists
	var idle_gate := not continuous_live_gate
	var current_heat := float(mount_state.get("heat", 0.0))
	var reload_multiplier := float(unit_state.get("reloadMultiplier", 1.0))
	var cooldown_time := float(weapon_state.get("cooldownTime", 20.0))
	var next_heat := current_heat
	if idle_gate:
		next_heat = max(current_heat - source_delta * reload_multiplier / cooldown_time, 0.0)
	var has_sound := bool(mount_state.get("hasSound", false))
	var sound_update_call = null
	if idle_gate and has_sound:
		sound_update_call = {
			"x": bullet_x,
			"y": bullet_y,
			"play": false,
		}
	return {
		"continuous": continuous,
		"bulletExists": bullet_exists,
		"continuousLiveGate": continuous_live_gate,
		"idleGate": idle_gate,
		"heat": next_heat,
		"reloadMultiplier": reload_multiplier,
		"cooldownTime": cooldown_time,
		"hasSound": has_sound,
		"soundUpdateCall": sound_update_call,
		"heatSource": "mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0)",
		"soundGuardSource": "if(mount.sound != null)",
		"soundUpdateSource": "mount.sound.update(bulletX, bulletY, false)",
	}

func source_weapon_update_alternating_side_flip_state(mount_state: Dictionary, weapon_state: Dictionary, unit_mount_states: Array) -> Dictionary:
	var current_side := bool(mount_state.get("side", false))
	var was_flipped := current_side
	var flip_sprite := bool(weapon_state.get("flipSprite", false))
	var alternate := bool(weapon_state.get("alternate", true))
	var other_side := int(weapon_state.get("otherSide", -1))
	var current_reload := float(mount_state.get("reload", 0.0))
	var last_reload := float(mount_state.get("lastReload", current_reload))
	var weapon_reload := float(weapon_state.get("reload", 1.0))
	var crosses_half_reload := current_reload <= weapon_reload / 2.0 and last_reload > weapon_reload / 2.0
	var flip_gate := other_side >= 0 and alternate and current_side == flip_sprite and other_side < unit_mount_states.size() and crosses_half_reload
	var next_unit_mount_states: Array = []
	for mount_item in unit_mount_states:
		var mount_copy: Dictionary = {}
		if typeof(mount_item) == TYPE_DICTIONARY:
			mount_copy = (mount_item as Dictionary).duplicate()
		next_unit_mount_states.append(mount_copy)
	var next_mount_side := current_side
	if flip_gate:
		next_unit_mount_states[other_side]["side"] = not bool(next_unit_mount_states[other_side].get("side", false))
		next_mount_side = not current_side
	return {
		"wasFlipped": was_flipped,
		"flipGate": flip_gate,
		"crossesHalfReload": crosses_half_reload,
		"mountSide": next_mount_side,
		"otherSide": other_side,
		"unitMounts": next_unit_mount_states,
		"guardSource": "if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f)",
		"otherSideFlipSource": "unit.mounts[otherSide].side = !unit.mounts[otherSide].side",
		"mountSideFlipSource": "mount.side = !mount.side",
		"shootGateSource": "(!alternate || wasFlipped == flipSprite) &&",
	}

func source_weapon_update_active_sound_loop_state(mount_state: Dictionary, weapon_state: Dictionary, runtime_state: Dictionary, can_shoot: bool, unit_id: int) -> Dictionary:
	var headless := bool(runtime_state.get("headless", false))
	var active_sound := str(weapon_state.get("activeSound", "none"))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var mount_warmup := float(mount_state.get("warmup", 0.0))
	var min_warmup := float(weapon_state.get("minWarmup", 0.0))
	var active_sound_volume := float(weapon_state.get("activeSoundVolume", 1.0))
	var active_sound_gate := not headless and active_sound != "none" and mount_shoot and can_shoot and mount_warmup >= min_warmup
	var sound_loop_call = null
	if active_sound_gate:
		sound_loop_call = {
			"sound": active_sound,
			"unit": unit_id,
			"volume": active_sound_volume,
		}
	return {
		"activeSoundGate": active_sound_gate,
		"headless": headless,
		"activeSound": active_sound,
		"mountShoot": mount_shoot,
		"canShoot": can_shoot,
		"mountWarmup": mount_warmup,
		"minWarmup": min_warmup,
		"activeSoundVolume": active_sound_volume,
		"soundLoopCall": sound_loop_call,
		"guardSource": "if(!headless && activeSound != Sounds.none && mount.shoot && can && mount.warmup >= minWarmup)",
		"loopSource": "Vars.control.sound.loop(activeSound, unit, activeSoundVolume)",
		"soundControlGuardSource": "if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return",
		"velLenReservedSource": "float velLen = unit.isRemote() ? unit.vel.len() : unit.deltaLen() / Time.delta",
	}

func source_weapon_update_velocity_length_state(unit_state: Dictionary, source_delta: float) -> Dictionary:
	var is_remote := bool(unit_state.get("isRemote", false))
	var vel_x := float(unit_state.get("velX", 0.0))
	var vel_y := float(unit_state.get("velY", 0.0))
	var delta_x := float(unit_state.get("deltaX", 0.0))
	var delta_y := float(unit_state.get("deltaY", 0.0))
	var remote_vel_len := sqrt(vel_x * vel_x + vel_y * vel_y)
	var local_delta_len := sqrt(delta_x * delta_x + delta_y * delta_y)
	var vel_len := remote_vel_len if is_remote else local_delta_len / source_delta
	return {
		"velLen": vel_len,
		"isRemote": is_remote,
		"remoteVelLen": remote_vel_len,
		"localDeltaLen": local_delta_len,
		"sourceDelta": source_delta,
		"branch": "unit.vel.len" if is_remote else "unit.deltaLen / Time.delta",
		"velLenSource": "float velLen = unit.isRemote() ? unit.vel.len() : unit.deltaLen() / Time.delta",
		"isRemoteSource": "boolean isRemote(){ return ((Object)this) instanceof Unitc u && u.isPlayer() && !isLocal(); }",
		"deltaLenSource": "float deltaLen(){ return Mathf.len(deltaX, deltaY); }",
		"vec2LenSource": "public float len(){ return (float)Math.sqrt(x * x + y * y); }",
		"timeDeltaSource": "public static float delta = 1f",
		"shootGateSource": "velLen >= minShootVelocity &&",
	}

func source_weapon_update_shoot_gate_prefix_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, was_flipped: bool, vel_len: float) -> Dictionary:
	var mount_shoot := bool(mount_state.get("shoot", false))
	var mount_warmup := float(mount_state.get("warmup", 0.0))
	var total_shots := int(mount_state.get("totalShots", 0))
	var alternate := bool(weapon_state.get("alternate", true))
	var flip_sprite := bool(weapon_state.get("flipSprite", false))
	var min_warmup := float(weapon_state.get("minWarmup", 0.0))
	var min_shoot_velocity := float(weapon_state.get("minShootVelocity", -1.0))
	var bullet_kill_shooter := bool(bullet_state.get("killShooter", false))
	var kill_shooter_once_blocked := bullet_kill_shooter and total_shots > 0
	var alternate_gate := (not alternate) or was_flipped == flip_sprite
	var warmup_gate := mount_warmup >= min_warmup
	var velocity_gate := vel_len >= min_shoot_velocity
	var shoot_gate_prefix := mount_shoot and can_shoot and not kill_shooter_once_blocked and alternate_gate and warmup_gate and velocity_gate
	return {
		"shootGatePrefix": shoot_gate_prefix,
		"mountShoot": mount_shoot,
		"canShoot": can_shoot,
		"killShooterOnceBlocked": kill_shooter_once_blocked,
		"alternateGate": alternate_gate,
		"warmupGate": warmup_gate,
		"velocityGate": velocity_gate,
		"totalShots": total_shots,
		"velLen": vel_len,
		"minShootVelocity": min_shoot_velocity,
		"shootCommentSource": "//shoot if applicable",
		"mountShootGateSource": "if(mount.shoot &&",
		"canGateSource": "can &&",
		"killShooterGateSource": "!(bullet.killShooter && mount.totalShots > 0) &&",
		"alternateGateSource": "(!alternate || wasFlipped == flipSprite) &&",
		"warmupGateSource": "mount.warmup >= minWarmup &&",
		"velocityGateSource": "velLen >= minShootVelocity &&",
		"reloadGateReservedSource": "(mount.reload <= 0.0001f || (alwaysContinuous && mount.bullet == null)) &&",
	}

func source_weapon_update_reload_gate_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var mount_reload := float(mount_state.get("reload", 0.0))
	var always_continuous := bool(weapon_state.get("alwaysContinuous", false))
	var mount_bullet_null := not bool(mount_state.get("hasBullet", false))
	var reload_ready := mount_reload <= 0.0001
	var always_continuous_ready := always_continuous and mount_bullet_null
	var reload_gate := reload_ready or (always_continuous and mount_bullet_null)
	return {
		"reloadGate": reload_gate,
		"reloadReady": reload_ready,
		"alwaysContinuousReady": always_continuous_ready,
		"mountReload": mount_reload,
		"alwaysContinuous": always_continuous,
		"mountBulletNull": mount_bullet_null,
		"reloadGateSource": "(mount.reload <= 0.0001f || (alwaysContinuous && mount.bullet == null)) &&",
		"coneGateReservedSource": "(alwaysShooting || Angles.within(rotate ? mount.rotation : unit.rotation + baseRotation, mount.targetRotation, shootCone))",
		"weaponAlwaysContinuousSource": "public boolean alwaysContinuous;",
		"mountReloadSource": "public float reload;",
		"mountBulletSource": "public @Nullable Bullet bullet;",
	}

func source_angles_angle_dist(a: float, b: float) -> float:
	return source_arc_angles_angle_dist(a, b)

func source_weapon_update_cone_gate_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	var always_shooting := bool(weapon_state.get("alwaysShooting", false))
	var weapon_rotate := bool(weapon_state.get("rotate", false))
	var base_rotation := float(weapon_state.get("baseRotation", 0.0))
	var shoot_cone := float(weapon_state.get("shootCone", 5.0))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var target_rotation := float(mount_state.get("targetRotation", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var current_rotation := mount_rotation if weapon_rotate else unit_rotation + base_rotation
	var angle_distance := source_angles_angle_dist(current_rotation, target_rotation)
	var within_cone := angle_distance <= shoot_cone
	var cone_gate := always_shooting or within_cone
	return {
		"coneGate": cone_gate,
		"alwaysShooting": always_shooting,
		"rotate": weapon_rotate,
		"currentRotation": current_rotation,
		"targetRotation": target_rotation,
		"shootCone": shoot_cone,
		"angleDistance": angle_distance,
		"withinCone": within_cone,
		"coneGateSource": "(alwaysShooting || Angles.within(rotate ? mount.rotation : unit.rotation + baseRotation, mount.targetRotation, shootCone))",
		"anglesWithinSource": "return angleDist(a, b) <= margin",
		"anglesAngleDistSource": "return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)",
		"shootCallReservedSource": "shoot(unit, mount, bulletX, bulletY, shootAngle)",
	}

func source_weapon_update_shoot_call_reload_state(mount_state: Dictionary, weapon_state: Dictionary, unit_id: int, bullet_x: float, bullet_y: float, shoot_angle: float, shoot_gate: bool) -> Dictionary:
	var current_reload := float(mount_state.get("reload", 0.0))
	var weapon_reload := float(weapon_state.get("reload", 1.0))
	var next_reload := weapon_reload if shoot_gate else current_reload
	var shoot_call = null
	if shoot_gate:
		shoot_call = {
			"unit": unit_id,
			"x": bullet_x,
			"y": bullet_y,
			"rotation": shoot_angle,
		}
	return {
		"shootGate": shoot_gate,
		"mountReload": next_reload,
		"previousReload": current_reload,
		"weaponReload": weapon_reload,
		"shootCall": shoot_call,
		"shootCallSource": "shoot(unit, mount, bulletX, bulletY, shootAngle)",
		"reloadResetSource": "mount.reload = reload",
		"shootMethodReservedSource": "protected void shoot(Unit unit, WeaponMount mount, float shootX, float shootY, float rotation)",
		"shootStatusApplyReservedSource": "unit.apply(shootStatus, shootStatusDuration)",
	}

func source_weapon_shoot_charge_start_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, shoot_x: float, shoot_y: float, charge_rotation: float) -> Dictionary:
	var shoot_status := "" if weapon_state.get("shootStatus", "none") == null else str(weapon_state.get("shootStatus", "none"))
	var shoot_status_duration := float(weapon_state.get("shootStatusDuration", 300.0))
	var status_immune := bool(unit_state.get("statusImmune", false))
	var status_result := source_status_apply_result(shoot_status, shoot_status_duration, status_immune)
	var first_shot_delay := float(weapon_state.get("firstShotDelay", 0.0))
	var charge_gate := first_shot_delay > 0.0
	var mount_charging := bool(mount_state.get("charging", false))
	var charge_sound := str(weapon_state.get("chargeSound", "none"))
	var sound_pitch_min := float(weapon_state.get("soundPitchMin", 1.0))
	var sound_pitch_max := float(weapon_state.get("soundPitchMax", 1.0))
	var charge_sound_call: Variant = null
	var keep_velocity := bool(bullet_state.get("keepVelocity", true))
	var parentize_effects := bool(weapon_state.get("parentizeEffects", false))
	var unit_id := int(unit_state.get("id", 0))
	var charge_effect_parent: Variant = null
	if keep_velocity or parentize_effects:
		charge_effect_parent = unit_id
	var charge_effect_call: Variant = null
	if charge_gate:
		mount_charging = true
		charge_sound_call = {
			"sound": charge_sound,
			"x": shoot_x,
			"y": shoot_y,
			"pitchMin": sound_pitch_min,
			"pitchMax": sound_pitch_max,
		}
		charge_effect_call = {
			"effect": str(bullet_state.get("chargeEffect", "none")),
			"x": shoot_x,
			"y": shoot_y,
			"rotation": charge_rotation,
			"effectParent": charge_effect_parent,
		}
	return {
		"statusApplied": status_result.get("statusApplied", false),
		"statusApplication": status_result.get("statusApplication", {}),
		"chargeGate": charge_gate,
		"mountCharging": mount_charging,
		"chargeSoundCall": charge_sound_call,
		"chargeEffectCall": charge_effect_call,
		"firstShotDelay": first_shot_delay,
		"keepVelocity": keep_velocity,
		"parentizeEffects": parentize_effects,
		"statusApplySource": "unit.apply(shootStatus, shootStatusDuration)",
		"statusApplyGuardSource": status_result.get("statusApplyGuardSource", ""),
		"chargeGateSource": "if(shoot.firstShotDelay > 0)",
		"mountChargingSource": "mount.charging = true",
		"chargeSoundSource": "chargeSound.at(shootX, shootY, Mathf.random(soundPitchMin, soundPitchMax))",
		"chargeEffectSource": "bullet.chargeEffect.at(shootX, shootY, rotation, bullet.keepVelocity || parentizeEffects ? unit : null)",
		"shootLoopReservedSource": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
	}

func source_shoot_pattern_default_events(shoot_state: Dictionary) -> Array:
	var shots := int(shoot_state.get("shots", 1))
	var first_shot_delay := float(shoot_state.get("firstShotDelay", 0.0))
	var shot_delay := float(shoot_state.get("shotDelay", 0.0))
	var events := []
	for i in shots:
		events.append({
			"xOffset": 0.0,
			"yOffset": 0.0,
			"angleOffset": 0.0,
			"delay": first_shot_delay + shot_delay * float(i),
			"mover": null,
		})
	return events

func source_weapon_shoot_default_pattern_dispatch_state(mount_state: Dictionary, shoot_state: Dictionary) -> Dictionary:
	var total_shots := int(mount_state.get("totalShots", 0))
	var barrel_counter := int(mount_state.get("barrelCounter", 0))
	var pattern_events := source_shoot_pattern_default_events(shoot_state)
	var bullet_calls := []
	var scheduled_calls := []
	for event in pattern_events:
		total_shots += 1
		var event_barrel := barrel_counter
		var event_delay := float(event.get("delay", 0.0))
		var bullet_call := {
			"xOffset": float(event.get("xOffset", 0.0)),
			"yOffset": float(event.get("yOffset", 0.0)),
			"angleOffset": float(event.get("angleOffset", 0.0)),
			"mover": event.get("mover", null),
			"barrel": event_barrel,
		}
		if event_delay > 0.0:
			scheduled_calls.append({
				"delay": event_delay,
				"setBarrelCounter": event_barrel,
				"bulletCall": bullet_call,
				"restoreBarrelCounter": barrel_counter,
			})
		else:
			bullet_calls.append(bullet_call)
	return {
		"patternEvents": pattern_events,
		"bulletCalls": bullet_calls,
		"scheduledCalls": scheduled_calls,
		"totalShots": total_shots,
		"barrelCounter": barrel_counter,
		"barrelIncrementerCalls": 0,
		"shootDispatchSource": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
		"patternCompatSource": "shoot(totalShots, handler)",
		"patternHandlerSource": "handler.shoot(0, 0, 0, firstShotDelay + shotDelay * i)",
		"totalShotsSource": "mount.totalShots ++",
		"barrelCaptureSource": "int barrel = mount.barrelCounter",
		"timeRunSource": "Time.run(delay, () -> {",
		"restoreBarrelSource": "mount.barrelCounter = prev",
		"directBulletSource": "bullet(unit, mount, xOffset, yOffset, angle, mover)",
		"barrelIncrementerSource": "() -> mount.barrelCounter++",
	}

func source_weapon_bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var unit_added := bool(unit_state.get("isAdded", false))
	var bullet_continues := unit_added
	var mount_charging := bool(mount_state.get("charging", false))
	if bullet_continues:
		mount_charging = false
	return {
		"unitAdded": unit_added,
		"bulletContinues": bullet_continues,
		"mountCharging": mount_charging,
		"unitAddedGuardSource": "if(!unit.isAdded()) return",
		"chargingResetSource": "mount.charging = false",
		"geometryReservedSource": "float xSpread = Mathf.range(xRand)",
	}

func source_weapon_bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float) -> Dictionary:
	var guard_state := source_weapon_bullet_initial_guard_state(unit_state, mount_state)
	var bullet_continues := bool(guard_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": guard_state.get("mountCharging", false),
			"xSpreadSource": "xSpread = Mathf.range(xRand)",
			"ySpreadSource": "ySpread = Mathf.range(yRand)",
			"shootAngleReservedSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
		}
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_x := float(weapon_state.get("x", 5.0))
	var weapon_y := float(weapon_state.get("y", 0.0))
	var weapon_rotate := bool(weapon_state.get("rotate", false))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", 0.0))
	var shoot_x := float(weapon_state.get("shootX", 0.0))
	var shoot_y := float(weapon_state.get("shootY", 3.0))
	var weapon_rotation := unit_rotation - 90.0 + (mount_rotation if weapon_rotate else base_rotation)
	var mount_vec := source_arc_angles_trns_vec(unit_rotation - 90.0, weapon_x, weapon_y)
	var mount_x := unit_x + float(mount_vec["x"])
	var mount_y := unit_y + float(mount_vec["y"])
	var bullet_offset_x := shoot_x + x_offset + x_spread
	var bullet_offset_y := shoot_y + y_offset + y_spread
	var bullet_vec := source_arc_angles_trns_vec(weapon_rotation, bullet_offset_x, bullet_offset_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	return {
		"bulletContinues": true,
		"mountCharging": guard_state.get("mountCharging", false),
		"xSpread": x_spread,
		"ySpread": y_spread,
		"weaponRotation": weapon_rotation,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletOffsetX": bullet_offset_x,
		"bulletOffsetY": bullet_offset_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"xSpreadSource": "xSpread = Mathf.range(xRand)",
		"ySpreadSource": "ySpread = Mathf.range(yRand)",
		"mathfRangeSource": "return random(-range, range)",
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation)",
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y)",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y)",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread)",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread)",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"shootAngleReservedSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
	}

func source_weapon_bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float) -> Dictionary:
	var geometry_state := source_weapon_bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread)
	var bullet_continues := bool(geometry_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": geometry_state.get("mountCharging", false),
			"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
			"lifeSclSource": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f",
			"angleSource": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy)",
		}
	var mount_x := float(geometry_state["mountX"])
	var mount_y := float(geometry_state["mountY"])
	var bullet_x := float(geometry_state["bulletX"])
	var bullet_y := float(geometry_state["bulletY"])
	var adjusted_weapon_state := weapon_state.duplicate(true)
	adjusted_weapon_state["shootX"] = float(weapon_state.get("shootX", 0.0)) + x_offset + x_spread
	adjusted_weapon_state["shootY"] = float(weapon_state.get("shootY", 3.0)) + y_offset + y_spread
	var bullet_rotation_state := source_weapon_update_bullet_origin_state(mount_state, adjusted_weapon_state, unit_state, mount_x, mount_y)
	var shoot_angle := float(bullet_rotation_state["shootAngle"]) + angle_offset
	var life_scl := 1.0
	var bullet_scale_life := bool(bullet_state.get("scaleLife", false))
	var bullet_range := float(bullet_state.get("range", 0.0))
	var target_distance := source_mathf_dst(bullet_x, bullet_y, float(mount_state.get("aimX", 0.0)), float(mount_state.get("aimY", 0.0)))
	if bullet_scale_life:
		var life_ratio := target_distance / bullet_range
		life_scl = clampf(life_ratio, 0.0, 1.0)
	var weapon_inaccuracy := float(weapon_state.get("inaccuracy", 0.0))
	var bullet_inaccuracy := float(bullet_state.get("inaccuracy", 0.0))
	var angle := shoot_angle + angle_spread
	return {
		"bulletContinues": true,
		"mountCharging": geometry_state.get("mountCharging", false),
		"shootAngle": shoot_angle,
		"bulletRotation": float(bullet_rotation_state["shootAngle"]),
		"lifeScl": life_scl,
		"angle": angle,
		"angleSpread": angle_spread,
		"inaccuracyRange": weapon_inaccuracy + bullet_inaccuracy,
		"bulletScaleLife": bullet_scale_life,
		"bulletRange": bullet_range,
		"targetDistance": target_distance,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
		"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
		"lifeSclSource": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f",
		"mathfDstSource": "public static float dst(float x1, float y1, float x2, float y2)",
		"mathfClampSource": "return Math.max(Math.min(value, 1f), 0f)",
		"angleSource": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy)",
		"mathfRangeSource": "return random(-range, range)",
	}

func source_weapon_bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	var unit_id: Variant = unit_state.get("id", null)
	var controller_is_missile_ai := str(controller_state.get("type", "")) == "MissileAI"
	var missile_shooter: Variant = controller_state.get("shooter", null)
	var shooter: Variant = controller_state.get("shooter", null) if controller_is_missile_ai else unit_id
	return {
		"unit": unit_id,
		"controllerIsMissileAI": controller_is_missile_ai,
		"missileShooter": missile_shooter,
		"shooter": shooter,
		"shooterSelectionSource": "Entityc shooter = unit.controller() instanceof MissileAI ai ? ai.shooter : unit",
		"missileShooterSource": "public @Nullable Unit shooter",
		"unitControllerSource": "public UnitController controller(){ return controller; }",
		"bulletCreateReservedSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		"bulletCreateNullShooterFallbackSource": "bullet.shooter = (shooter == null ? owner : shooter)",
	}

func source_weapon_bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant) -> Dictionary:
	var angle_life_state := source_weapon_bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread)
	var bullet_continues := bool(angle_life_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": angle_life_state.get("mountCharging", false),
			"bulletCreateCall": null,
			"mountBulletSetFromCreateCall": false,
			"bulletCreateCallSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		}
	var shooter_state := source_weapon_bullet_shooter_state(unit_state, controller_state)
	var velocity_rnd := float(weapon_state.get("velocityRnd", 0.0))
	var extra_velocity := float(weapon_state.get("extraVelocity", 0.0))
	var velocity_scl := (1.0 - velocity_rnd) + velocity_random + extra_velocity
	var bullet_create_call := {
		"owner": unit_state.get("id", null),
		"shooter": shooter_state.get("shooter", null),
		"team": unit_state.get("team", null),
		"x": angle_life_state["bulletX"],
		"y": angle_life_state["bulletY"],
		"angle": angle_life_state["angle"],
		"damage": -1.0,
		"velocityScl": velocity_scl,
		"lifetimeScl": angle_life_state["lifeScl"],
		"data": null,
		"mover": mover,
		"aimX": float(mount_state.get("aimX", 0.0)),
		"aimY": float(mount_state.get("aimY", 0.0)),
		"target": mount_state.get("target", null),
	}
	return {
		"bulletContinues": true,
		"mountCharging": angle_life_state.get("mountCharging", false),
		"bulletCreateCall": bullet_create_call,
		"mountBulletSetFromCreateCall": true,
		"velocityRnd": velocity_rnd,
		"velocityRandom": velocity_random,
		"extraVelocity": extra_velocity,
		"velocityScl": velocity_scl,
		"angleLifeState": angle_life_state,
		"shooterState": shooter_state,
		"bulletCreateCallSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		"mathfRandomSource": "return rand.nextFloat() * range",
		"handleBulletReservedSource": "handleBullet(unit, mount, mount.bullet)",
	}

func source_weapon_bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	var bullet_continues := bool(create_call_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"handleBulletCalled": false,
			"handleBulletCall": null,
			"handleBulletSource": "handleBullet(unit, mount, mount.bullet)",
		}
	var handle_bullet_call := {
		"unit": unit_state.get("id", null),
		"mount": mount_state.get("id", null),
		"mountBullet": created_bullet,
		"bullet": created_bullet,
	}
	return {
		"bulletContinues": true,
		"handleBulletCalled": true,
		"handleBulletCall": handle_bullet_call,
		"mountBullet": created_bullet,
		"handleBulletSource": "handleBullet(unit, mount, mount.bullet)",
		"handleBulletInternalsReservedSource": "protected void handleBullet(Unit unit, WeaponMount mount, Bullet bullet)",
		"continuousBranchReservedSource": "if(continuous)",
		"soundReservedSource": "if(!continuous)",
	}

func source_weapon_handle_bullet_continuous_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", false))
	if not continuous:
		return {
			"continuous": false,
			"continuousGate": false,
			"aimUpdateReservedSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY)",
		}
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_rotate := bool(weapon_state.get("rotate", false))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", 0.0))
	var weapon_x := float(weapon_state.get("x", 5.0))
	var weapon_y := float(weapon_state.get("y", 0.0))
	var shoot_x := float(weapon_state.get("shootX", 0.0))
	var shoot_y := float(weapon_state.get("shootY", 3.0))
	var weapon_rotation := unit_rotation - 90.0 + (mount_rotation if weapon_rotate else base_rotation)
	var mount_vec := source_arc_angles_trns_vec(unit_rotation - 90.0, weapon_x, weapon_y)
	var mount_x := unit_x + float(mount_vec["x"])
	var mount_y := unit_y + float(mount_vec["y"])
	var bullet_vec := source_arc_angles_trns_vec(weapon_rotation, shoot_x, shoot_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	return {
		"continuous": true,
		"continuousGate": true,
		"weaponRotation": weapon_rotation,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"lastLength": float(mount_state.get("lastLength", 0.0)),
		"continuousGateSource": "if(continuous)",
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation)",
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y)",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y)",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY)",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY)",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"aimUpdateReservedSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY)",
	}

func source_weapon_handle_bullet_aim_update_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var geometry_state := source_weapon_handle_bullet_continuous_geometry_state(unit_state, mount_state, weapon_state)
	if not bool(geometry_state.get("continuousGate", false)):
		return {
			"continuous": false,
			"continuousGate": false,
			"bulletAimUpdated": false,
			"bulletAimX": float(bullet_state.get("aimX", 0.0)),
			"bulletAimY": float(bullet_state.get("aimY", 0.0)),
			"aimUpdateSkippedSource": "if(continuous)",
		}
	var bullet_rotation_state := source_weapon_update_bullet_origin_state(mount_state, weapon_state, unit_state, float(geometry_state["mountX"]), float(geometry_state["mountY"]))
	var bullet_rotation := float(bullet_rotation_state["shootAngle"])
	var aim_length := float(geometry_state["shootY"]) + float(geometry_state["lastLength"])
	var aim_vec := source_arc_angles_trns_vec(bullet_rotation, aim_length, 0.0)
	var bullet_aim_x := float(aim_vec["x"]) + float(geometry_state["bulletX"])
	var bullet_aim_y := float(aim_vec["y"]) + float(geometry_state["bulletY"])
	return {
		"continuous": true,
		"continuousGate": true,
		"bulletAimUpdated": true,
		"weaponRotation": float(geometry_state["weaponRotation"]),
		"mountX": float(geometry_state["mountX"]),
		"mountY": float(geometry_state["mountY"]),
		"bulletX": float(geometry_state["bulletX"]),
		"bulletY": float(geometry_state["bulletY"]),
		"bulletRotation": bullet_rotation,
		"aimLength": aim_length,
		"bulletAimX": bullet_aim_x,
		"bulletAimY": bullet_aim_y,
		"previousBulletAimX": float(bullet_state.get("aimX", 0.0)),
		"previousBulletAimY": float(bullet_state.get("aimY", 0.0)),
		"aimUpdateSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY)",
		"bulletAimXSource": "bullet.aimX = Tmp.v1.x",
		"bulletAimYSource": "bullet.aimY = Tmp.v1.y",
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
		"vec2TrnsSource": "return set(amount, 0).rotate(angle)",
		"vec2AddSource": "this.x += x; this.y += y",
	}

func source_weapon_bullet_sound_state(create_call_state: Dictionary, weapon_state: Dictionary, sound_pitch: float) -> Dictionary:
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"soundCall": null,
			"effectsReservedSource": "if(mount.allowShootEffects)",
		}
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	if bullet_create_call.is_empty():
		return {
			"bulletContinues": true,
			"soundCall": null,
			"soundSkipped": true,
			"effectsReservedSource": "if(mount.allowShootEffects)",
		}
	var continuous := bool(weapon_state.get("continuous", false))
	var sound_name := str(weapon_state.get("shootSound", "shoot"))
	var branch_source := "if(!continuous)"
	var call_source := "shootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume)"
	if continuous:
		sound_name = str(weapon_state.get("initialShootSound", "none"))
		branch_source = "}else{"
		call_source = "initialShootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume)"
	var sound_call := {
		"sound": sound_name,
		"x": float(bullet_create_call.get("x", 0.0)),
		"y": float(bullet_create_call.get("y", 0.0)),
		"pitch": sound_pitch,
		"volume": float(weapon_state.get("shootSoundVolume", 1.0)),
	}
	return {
		"bulletContinues": true,
		"continuous": continuous,
		"soundCall": sound_call,
		"soundPitchMin": float(weapon_state.get("soundPitchMin", 0.8)),
		"soundPitchMax": float(weapon_state.get("soundPitchMax", 1.0)),
		"soundBranchSource": branch_source,
		"soundCallSource": "shootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume)",
		"initialSoundCallSource": "initialShootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume)",
		"selectedSoundCallSource": call_source,
		"mathfRandomSource": "return start + rand.nextFloat() * (end - start)",
		"effectsReservedSource": "if(mount.allowShootEffects)",
	}

func source_weapon_bullet_effects_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"effectsGate": false,
			"effectCalls": [],
			"recoilReservedSource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
		}
	var allow_shoot_effects := bool(mount_state.get("allowShootEffects", true))
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	if not allow_shoot_effects or bullet_create_call.is_empty():
		return {
			"bulletContinues": true,
			"effectsGate": false,
			"effectCalls": [],
			"effectsGateSource": "if(mount.allowShootEffects)",
			"recoilReservedSource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
		}
	var weapon_x := float(weapon_state.get("x", 5.0))
	var x_sign := -1.0 if weapon_x < 0.0 else 1.0
	var mount_x := float(create_call_state.get("mountX", bullet_create_call.get("x", 0.0)))
	var mount_y := float(create_call_state.get("mountY", bullet_create_call.get("y", 0.0)))
	var bullet_x := float(bullet_create_call.get("x", 0.0))
	var bullet_y := float(bullet_create_call.get("y", 0.0))
	var angle_value := float(bullet_create_call.get("angle", 0.0))
	var hit_color = bullet_state.get("hitColor", "white")
	var unit_id = unit_state.get("id", unit_state)
	var effect_calls := [
		{
			"effect": str(weapon_state.get("ejectEffect", "none")),
			"x": mount_x,
			"y": mount_y,
			"angle": angle_value * x_sign,
			"kind": "ejectEffect",
		},
		{
			"effect": str(bullet_state.get("shootEffect", "shootSmall")),
			"x": bullet_x,
			"y": bullet_y,
			"angle": angle_value,
			"color": hit_color,
			"unit": unit_id,
			"kind": "shootEffect",
		},
		{
			"effect": str(bullet_state.get("smokeEffect", "shootSmallSmoke")),
			"x": bullet_x,
			"y": bullet_y,
			"angle": angle_value,
			"color": hit_color,
			"unit": unit_id,
			"kind": "smokeEffect",
		},
	]
	return {
		"bulletContinues": true,
		"effectsGate": true,
		"effectCalls": effect_calls,
		"weaponX": weapon_x,
		"xSign": x_sign,
		"effectsGateSource": "if(mount.allowShootEffects)",
		"ejectEffectSource": "ejectEffect.at(mountX, mountY, angle * Mathf.sign(this.x))",
		"shootEffectSource": "bullet.shootEffect.at(bulletX, bulletY, angle, bullet.hitColor, unit)",
		"smokeEffectSource": "bullet.smokeEffect.at(bulletX, bulletY, angle, bullet.hitColor, unit)",
		"mathfSignSource": "return (f < 0 ? -1 : 1)",
		"recoilReservedSource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
	}

func source_weapon_bullet_recoil_velocity_state(create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var unit_vel: Dictionary = unit_state.get("vel", {"x": 0.0, "y": 0.0})
	var unit_vel_before := {
		"x": float(unit_vel.get("x", 0.0)),
		"y": float(unit_vel.get("y", 0.0)),
	}
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"recoilVelocityApplied": false,
			"unitVelBefore": unit_vel_before,
			"unitVelAfter": unit_vel_before.duplicate(),
			"recoilVector": {"x": 0.0, "y": 0.0, "angle": 0.0},
			"recoilVelocitySource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
			"vec2TrnsSource": "return set(amount, 0).rotate(angle)",
			"vec2AddSource": "x += v.x; y += v.y",
			"shakeReservedSource": "Effect.shake(shake, shake, bulletX, bulletY)",
		}
	var angle_life_state: Dictionary = create_call_state.get("angleLifeState", {})
	var shoot_angle := float(angle_life_state.get("shootAngle", 0.0))
	var bullet_recoil := float(bullet_state.get("recoil", 0.0))
	var recoil_vec := source_arc_angles_trns_vec(shoot_angle + 180.0, bullet_recoil, 0.0)
	var unit_vel_after := {
		"x": float(unit_vel_before["x"]) + float(recoil_vec.get("x", 0.0)),
		"y": float(unit_vel_before["y"]) + float(recoil_vec.get("y", 0.0)),
	}
	return {
		"bulletContinues": true,
		"recoilVelocityApplied": true,
		"shootAngle": shoot_angle,
		"bulletRecoil": bullet_recoil,
		"unitVelBefore": unit_vel_before,
		"unitVelAfter": unit_vel_after,
		"recoilVector": recoil_vec,
		"recoilVelocitySource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
		"vec2TrnsSource": "return set(amount, 0).rotate(angle)",
		"vec2AddSource": "x += v.x; y += v.y",
		"shakeReservedSource": "Effect.shake(shake, shake, bulletX, bulletY)",
	}

func source_weapon_bullet_shake_state(create_call_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"shakeEffectCalled": false,
			"shakeCall": null,
			"shakeCallSource": "Effect.shake(shake, shake, bulletX, bulletY)",
			"effectCameraGuardSource": "if(Core.camera == null) return",
			"effectFalloffSource": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration)",
			"mountRecoilReservedSource": "mount.recoil = 1f",
		}
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	if bullet_create_call.is_empty():
		return {
			"bulletContinues": true,
			"shakeEffectCalled": false,
			"shakeCall": null,
			"shakeCallSource": "Effect.shake(shake, shake, bulletX, bulletY)",
			"effectCameraGuardSource": "if(Core.camera == null) return",
			"effectFalloffSource": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration)",
			"mountRecoilReservedSource": "mount.recoil = 1f",
		}
	var shake_intensity := float(weapon_state.get("shake", 0.0))
	var effect_shake_call := {
		"intensity": shake_intensity,
		"duration": shake_intensity,
		"x": float(bullet_create_call.get("x", 0.0)),
		"y": float(bullet_create_call.get("y", 0.0)),
	}
	return {
		"bulletContinues": true,
		"shakeEffectCalled": true,
		"shakeCall": effect_shake_call,
		"shakeCallSource": "Effect.shake(shake, shake, bulletX, bulletY)",
		"effectCameraGuardSource": "if(Core.camera == null) return",
		"effectDistanceSource": "float distance = Core.camera.position.dst(x, y)",
		"effectDistanceFloorSource": "if(distance < 1) distance = 1",
		"effectFalloffSource": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration)",
		"rendererShakeSource": "Vars.renderer.shake(intensity, duration)",
		"mountRecoilReservedSource": "mount.recoil = 1f",
	}

func source_weapon_bullet_mount_recoil_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var current_recoil := float(mount_state.get("recoil", 0.0))
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"mountRecoilApplied": false,
			"mountRecoilBefore": current_recoil,
			"mountRecoil": current_recoil,
			"mountRecoilSource": "mount.recoil = 1f",
			"recoilSlotsReservedSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
			"heatReservedSource": "mount.heat = 1f",
		}
	return {
		"bulletContinues": true,
		"mountRecoilApplied": true,
		"mountRecoilBefore": current_recoil,
		"mountRecoil": 1.0,
		"mountRecoilSource": "mount.recoil = 1f",
		"recoilSlotsReservedSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
		"heatReservedSource": "mount.heat = 1f",
	}

func source_weapon_bullet_recoil_slots_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var recoils_count := int(weapon_state.get("recoils", -1))
	var barrel_counter := int(mount_state.get("barrelCounter", 0))
	var raw_recoils = mount_state.get("recoils", [])
	var recoils_values: Array = []
	if raw_recoils is Array:
		recoils_values = raw_recoils.duplicate()
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"recoilSlotsApplied": false,
			"recoils": recoils_values,
			"recoilIndex": -1,
			"recoilsCount": recoils_count,
			"barrelCounter": barrel_counter,
			"recoilSlotsSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
			"updateInitSource": "if(mount.recoils == null) mount.recoils = new float[recoils]",
			"heatReservedSource": "mount.heat = 1f",
		}
	if recoils_count <= 0:
		return {
			"bulletContinues": true,
			"recoilSlotsApplied": false,
			"recoils": recoils_values,
			"recoilIndex": -1,
			"recoilsCount": recoils_count,
			"barrelCounter": barrel_counter,
			"recoilSlotsSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
			"updateInitSource": "if(mount.recoils == null) mount.recoils = new float[recoils]",
			"heatReservedSource": "mount.heat = 1f",
		}
	var recoil_index := barrel_counter % recoils_count
	while recoils_values.size() < recoils_count:
		recoils_values.append(0.0)
	recoils_values[recoil_index] = 1.0
	return {
		"bulletContinues": true,
		"recoilSlotsApplied": true,
		"recoils": recoils_values,
		"recoilIndex": recoil_index,
		"recoilsCount": recoils_count,
		"barrelCounter": barrel_counter,
		"recoilSlotsSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
		"updateInitSource": "if(mount.recoils == null) mount.recoils = new float[recoils]",
		"heatReservedSource": "mount.heat = 1f",
	}

func source_weapon_bullet_heat_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var current_heat := float(mount_state.get("heat", 0.0))
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"mountHeatApplied": false,
			"mountHeatBefore": current_heat,
			"mountHeat": current_heat,
			"mountHeatSource": "mount.heat = 1f",
			"bulletMethodComplete": false,
		}
	return {
		"bulletContinues": true,
		"mountHeatApplied": true,
		"mountHeatBefore": current_heat,
		"mountHeat": 1.0,
		"mountHeatSource": "mount.heat = 1f",
		"bulletMethodComplete": true,
	}

func source_bullet_type_create_initial_gate_state(create_call_state: Dictionary, bullet_type_state: Dictionary, random_angle_offset: float, create_chance_roll: float) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var random_angle := random_angle_offset
	var create_chance := float(bullet_type_state.get("createChance", 1.0))
	if not bool(create_call_state.get("bulletContinues", false)) or bullet_create_call.is_empty():
		return {
			"bulletContinues": false,
			"bulletCreateCalled": false,
			"bulletCreateReturnsNull": true,
			"createChance": create_chance,
			"createChanceRoll": create_chance_roll,
			"createChancePassed": false,
			"angleOffsetSource": "angle += angleOffset + Mathf.range(randomAngleOffset)",
			"mathfRangeSource": "return random(-range, range)",
			"createChanceSource": "if(!Mathf.chance(createChance)) return null",
			"mathfChanceSource": "return d >= 1f || rand.nextFloat() < d",
			"ignoreSpawnAngleSource": "if(ignoreSpawnAngle) angle = 0",
			"spawnUnitReservedSource": "if(spawnUnit != null)",
		}
	var angle_offset := float(bullet_type_state.get("angleOffset", 0.0))
	var angle := float(bullet_create_call.get("angle", 0.0)) + angle_offset + random_angle
	var chance_passed := create_chance >= 1.0 or create_chance_roll < create_chance
	if not chance_passed:
		return {
			"bulletContinues": true,
			"bulletCreateCalled": true,
			"bulletCreateReturnsNull": true,
			"createChance": create_chance,
			"createChanceRoll": create_chance_roll,
			"createChancePassed": false,
			"angle": angle,
			"angleOffset": angle_offset,
			"randomAngleOffset": random_angle,
			"ignoreSpawnAngleApplied": false,
			"angleOffsetSource": "angle += angleOffset + Mathf.range(randomAngleOffset)",
			"mathfRangeSource": "return random(-range, range)",
			"createChanceSource": "if(!Mathf.chance(createChance)) return null",
			"mathfChanceSource": "return d >= 1f || rand.nextFloat() < d",
			"ignoreSpawnAngleSource": "if(ignoreSpawnAngle) angle = 0",
			"spawnUnitReservedSource": "if(spawnUnit != null)",
		}
	var ignore_spawn_angle := false
	if bool(bullet_type_state.get("ignoreSpawnAngle", false)):
		ignore_spawn_angle = true
		angle = 0.0
	return {
		"bulletContinues": true,
		"bulletCreateCalled": true,
		"bulletCreateReturnsNull": false,
		"createChance": create_chance,
		"createChanceRoll": create_chance_roll,
		"createChancePassed": true,
		"angle": angle,
		"angleOffset": angle_offset,
		"randomAngleOffset": random_angle,
		"ignoreSpawnAngleApplied": ignore_spawn_angle,
		"angleOffsetSource": "angle += angleOffset + Mathf.range(randomAngleOffset)",
		"mathfRangeSource": "return random(-range, range)",
		"createChanceSource": "if(!Mathf.chance(createChance)) return null",
		"mathfChanceSource": "return d >= 1f || rand.nextFloat() < d",
		"ignoreSpawnAngleSource": "if(ignoreSpawnAngle) angle = 0",
		"spawnUnitReservedSource": "if(spawnUnit != null)",
	}

func source_bullet_type_create_spawn_unit_state(initial_gate_state: Dictionary, bullet_type_state: Dictionary, net_client: bool, owner_health_state: Dictionary, shooter_state: Dictionary) -> Dictionary:
	var spawn_unit: Dictionary = bullet_type_state.get("spawnUnit", {})
	var kill_shooter := bool(bullet_type_state.get("killShooter", false))
	var owner_is_health := bool(owner_health_state.get("isHealthc", false))
	var owner_dead := bool(owner_health_state.get("dead", false))
	var owner_killed := false
	if not bool(initial_gate_state.get("bulletContinues", false)) or bool(initial_gate_state.get("bulletCreateReturnsNull", false)):
		return {
			"bulletContinues": false,
			"spawnUnitBranchEntered": false,
			"bulletCreateReturnsNull": true,
			"spawnedUnit": null,
			"ownerKilled": false,
			"spawnUnitSource": "if(spawnUnit != null)",
			"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
		}
	if spawn_unit.is_empty():
		return {
			"bulletContinues": true,
			"spawnUnitBranchEntered": false,
			"bulletCreateReturnsNull": false,
			"spawnedUnit": null,
			"ownerKilled": false,
			"spawnUnitSource": "if(spawnUnit != null)",
			"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
		}
	owner_killed = kill_shooter and owner_is_health and not owner_dead
	if net_client:
		return {
			"bulletContinues": true,
			"spawnUnitBranchEntered": true,
			"spawnSkippedClient": true,
			"bulletCreateReturnsNull": true,
			"spawnedUnit": null,
			"ownerKilled": owner_killed,
			"spawnUnitSource": "if(spawnUnit != null)",
			"clientGuardSource": "if(!net.client())",
			"spawnedUnitCreateSource": "Unit spawned = spawnUnit.create(team)",
			"spawnedVelocitySource": "spawned.vel.trns(angle, spawnUnit.speed)",
			"shooterAssignSource": "if(spawned.controller() instanceof MissileAI ai)",
			"killShooterSource": "if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill()",
			"returnNullSource": "return null",
			"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
		}
	var bullet_create_call: Dictionary = initial_gate_state.get("bulletCreateCall", {})
	var angle := float(initial_gate_state.get("angle", bullet_create_call.get("angle", 0.0)))
	var spawned_unit := {
		"type": str(spawn_unit.get("id", spawn_unit.get("name", ""))),
		"team": bullet_create_call.get("team", ""),
		"x": float(bullet_create_call.get("x", 0.0)),
		"y": float(bullet_create_call.get("y", 0.0)),
		"rotation": angle,
		"velocityApplied": false,
		"velocity": null,
		"missileAIShooter": null,
		"added": true,
		"notified": true,
	}
	if float(spawn_unit.get("missileAccelTime", 0.0)) <= 0.0:
		spawned_unit["velocityApplied"] = true
		spawned_unit["velocity"] = {"angle": angle, "speed": float(spawn_unit.get("speed", 0.0))}
	if bool(spawn_unit.get("controllerIsMissileAI", false)):
		if str(shooter_state.get("kind", "")) == "Unit":
			spawned_unit["missileAIShooter"] = shooter_state.get("id", null)
		if str(shooter_state.get("kind", "")) == "ControlBlock":
			spawned_unit["missileAIShooter"] = shooter_state.get("unit", null)
	return {
		"bulletContinues": true,
		"spawnUnitBranchEntered": true,
		"spawnSkippedClient": false,
		"bulletCreateReturnsNull": true,
		"spawnedUnit": spawned_unit,
		"ownerKilled": owner_killed,
		"spawnUnitSource": "if(spawnUnit != null)",
		"clientGuardSource": "if(!net.client())",
		"spawnedUnitCreateSource": "Unit spawned = spawnUnit.create(team)",
		"spawnedSetSource": "spawned.set(x, y)",
		"spawnedRotationSource": "spawned.rotation = angle",
		"spawnedVelocitySource": "spawned.vel.trns(angle, spawnUnit.speed)",
		"shooterAssignSource": "if(spawned.controller() instanceof MissileAI ai)",
		"controlShooterAssignSource": "ai.shooter = control.unit()",
		"spawnedAddSource": "spawned.add()",
		"notifySpawnSource": "Units.notifyUnitSpawn(spawned)",
		"killShooterSource": "if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill()",
		"returnNullSource": "return null",
		"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
	}

func source_bullet_type_create_bullet_identity_state(create_call_state: Dictionary, initial_gate_state: Dictionary, spawn_unit_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var shooter = bullet_create_call.get("shooter", null)
	var bullet_owner = bullet_create_call.get("owner", null)
	if not bool(initial_gate_state.get("bulletContinues", false)) or bool(initial_gate_state.get("bulletCreateReturnsNull", false)):
		return {
			"bulletContinues": false,
			"bulletAllocated": false,
			"bulletCreateReturnsNull": true,
			"bullet": null,
			"bulletCreateSource": "Bullet bullet = Bullet.create()",
			"aimTileReservedSource": "if(!(aimX == -1f && aimY == -1f)){",
		}
	if bool(spawn_unit_state.get("spawnUnitBranchEntered", false)) and bool(spawn_unit_state.get("bulletCreateReturnsNull", false)):
		return {
			"bulletContinues": true,
			"bulletAllocated": false,
			"bulletCreateReturnsNull": true,
			"bullet": null,
			"bulletCreateSource": "Bullet bullet = Bullet.create()",
			"aimTileReservedSource": "if(!(aimX == -1f && aimY == -1f)){",
		}
	var bullet_identity := {
		"type": bullet_type_state.get("id", bullet_type_state.get("name", "")),
		"owner": bullet_owner,
		"shooter": bullet_owner if shooter == null else shooter,
		"team": bullet_create_call.get("team", ""),
		"time": 0.0,
		"originX": float(bullet_create_call.get("x", 0.0)),
		"originY": float(bullet_create_call.get("y", 0.0)),
	}
	return {
		"bulletContinues": true,
		"bulletAllocated": true,
		"bulletCreateReturnsNull": false,
		"bullet": bullet_identity,
		"bulletCreateSource": "Bullet bullet = Bullet.create()",
		"typeSource": "bullet.type = this",
		"ownerSource": "bullet.owner = owner",
		"shooterSource": "bullet.shooter = (shooter == null ? owner : shooter)",
		"teamSource": "bullet.team = team",
		"timeSource": "bullet.time = 0f",
		"originXSource": "bullet.originX = x",
		"originYSource": "bullet.originY = y",
		"aimTileReservedSource": "if(!(aimX == -1f && aimY == -1f)){",
	}

func source_bullet_type_create_aim_state(identity_state: Dictionary, create_call_state: Dictionary, target_state: Dictionary, world_tile_from_aim: Variant) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var raw_bullet_state = identity_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(identity_state.get("bulletAllocated", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(identity_state.get("bulletContinues", false)),
			"bulletAimApplied": false,
			"bullet": null,
			"aimTileSource": "bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY)",
			"worldTileWorldSource": "return tile(Math.round(x / tilesize), Math.round(y / tilesize))",
			"initVelReservedSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
		}
	var aim_x := float(bullet_create_call.get("aimX", -1.0))
	var aim_y := float(bullet_create_call.get("aimY", -1.0))
	var has_aim_tile := not (aim_x == -1.0 and aim_y == -1.0)
	var aim_tile: Variant = null
	if has_aim_tile:
		if str(target_state.get("kind", "")) == "Building":
			aim_tile = target_state.get("tile", null)
		else:
			aim_tile = world_tile_from_aim
	bullet_state = bullet_state.duplicate()
	bullet_state["aimTile"] = aim_tile
	bullet_state["aimX"] = aim_x
	bullet_state["aimY"] = aim_y
	return {
		"bulletContinues": true,
		"bulletAimApplied": true,
		"hasAimTile": has_aim_tile,
		"bullet": bullet_state,
		"aimTileSource": "bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY)",
		"aimXSource": "bullet.aimX = aimX",
		"aimYSource": "bullet.aimY = aimY",
		"worldTileWorldSource": "return tile(Math.round(x / tilesize), Math.round(y / tilesize))",
		"initVelReservedSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
	}

func source_bullet_type_create_velocity_position_state(aim_state: Dictionary, initial_gate_state: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, velocity_scale_random_factor: float) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var raw_bullet_state = aim_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(aim_state.get("bulletAimApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(aim_state.get("bulletContinues", false)),
			"bulletVelocityPositionApplied": false,
			"bullet": null,
			"initVelSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
			"bulletCompInitVelSource": "vel.trns(angle, amount); rotation = angle",
			"setSource": "bullet.set(x, y)",
			"lastXSource": "bullet.lastX = x",
			"lastYSource": "bullet.lastY = y",
			"lifetimeReservedSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
		}
	var angle := float(initial_gate_state.get("angle", bullet_create_call.get("angle", 0.0)))
	var x := float(bullet_create_call.get("x", 0.0))
	var y := float(bullet_create_call.get("y", 0.0))
	var speed := float(bullet_type_state.get("speed", 0.0))
	var velocity_scl := float(bullet_create_call.get("velocityScl", 1.0))
	var velocity_scale_rand_min := float(bullet_type_state.get("velocityScaleRandMin", 1.0))
	var velocity_scale_rand_max := float(bullet_type_state.get("velocityScaleRandMax", 1.0))
	var velocity_random_multiplier := velocity_scale_random_factor if velocity_scale_rand_min != 1.0 or velocity_scale_rand_max != 1.0 else 1.0
	var velocity_amount := speed * velocity_scl * velocity_random_multiplier
	bullet_state = bullet_state.duplicate()
	bullet_state["velocity"] = {"angle": angle, "speed": velocity_amount}
	bullet_state["rotation"] = angle
	bullet_state["x"] = x
	bullet_state["y"] = y
	bullet_state["lastX"] = x
	bullet_state["lastY"] = y
	return {
		"bulletContinues": true,
		"bulletVelocityPositionApplied": true,
		"velocityScaleRandMin": velocity_scale_rand_min,
		"velocityScaleRandMax": velocity_scale_rand_max,
		"velocityScaleRandomFactor": velocity_scale_random_factor,
		"velocityRandomMultiplier": velocity_random_multiplier,
		"velocityAmount": velocity_amount,
		"bullet": bullet_state,
		"initVelSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
		"bulletCompInitVelSource": "vel.trns(angle, amount); rotation = angle",
		"setSource": "bullet.set(x, y)",
		"lastXSource": "bullet.lastX = x",
		"lastYSource": "bullet.lastY = y",
		"lifetimeReservedSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
	}

func source_bullet_type_create_lifetime_payload_damage_state(velocity_position_state: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, life_scale_random_factor: float, damage_multiplier_factor: float) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var raw_bullet_state = velocity_position_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(velocity_position_state.get("bulletVelocityPositionApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(velocity_position_state.get("bulletContinues", false)),
			"bulletLifetimePayloadDamageApplied": false,
			"bullet": null,
			"lifetimeSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
			"dataSource": "bullet.data = data",
			"hitSizeSource": "bullet.hitSize = hitSize",
			"moverSource": "bullet.mover = mover",
			"damageSource": "bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier()",
			"damageMultiplierSource": "return type.damageMultiplier(self())",
			"buildingDamageMultiplierSource": "bullet.buildingDamageMultiplier = buildingDamageMultiplier",
			"trailClearReservedSource": "if(bullet.trail != null){",
			"addReservedSource": "bullet.add()",
		}
	var lifetime := float(bullet_type_state.get("lifetime", 40.0))
	var lifetime_scl := float(bullet_create_call.get("lifetimeScl", 1.0))
	var life_scale_rand_min := float(bullet_type_state.get("lifeScaleRandMin", 1.0))
	var life_scale_rand_max := float(bullet_type_state.get("lifeScaleRandMax", 1.0))
	var life_random_multiplier := life_scale_random_factor if life_scale_rand_min != 1.0 or life_scale_rand_max != 1.0 else 1.0
	var lifetime_amount := lifetime * lifetime_scl * life_random_multiplier
	var create_damage := float(bullet_create_call.get("damage", -1.0))
	var type_damage := float(bullet_type_state.get("damage", 1.0))
	var base_damage := type_damage if create_damage < 0.0 else create_damage
	var hit_size := float(bullet_type_state.get("hitSize", 4.0))
	var building_damage_multiplier := float(bullet_type_state.get("buildingDamageMultiplier", 1.0))
	bullet_state = bullet_state.duplicate()
	bullet_state["lifetime"] = lifetime_amount
	bullet_state["data"] = bullet_create_call.get("data", null)
	bullet_state["hitSize"] = hit_size
	bullet_state["mover"] = bullet_create_call.get("mover", null)
	bullet_state["damage"] = base_damage * damage_multiplier_factor
	bullet_state["buildingDamageMultiplier"] = building_damage_multiplier
	return {
		"bulletContinues": true,
		"bulletLifetimePayloadDamageApplied": true,
		"lifeScaleRandMin": life_scale_rand_min,
		"lifeScaleRandMax": life_scale_rand_max,
		"lifeScaleRandomFactor": life_scale_random_factor,
		"lifeRandomMultiplier": life_random_multiplier,
		"lifetimeAmount": lifetime_amount,
		"baseDamage": base_damage,
		"damageMultiplierFactor": damage_multiplier_factor,
		"damageAmount": base_damage * damage_multiplier_factor,
		"bullet": bullet_state,
		"lifetimeSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
		"dataSource": "bullet.data = data",
		"hitSizeSource": "bullet.hitSize = hitSize",
		"moverSource": "bullet.mover = mover",
		"damageSource": "bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier()",
		"damageMultiplierSource": "return type.damageMultiplier(self())",
		"buildingDamageMultiplierSource": "bullet.buildingDamageMultiplier = buildingDamageMultiplier",
		"trailClearReservedSource": "if(bullet.trail != null){",
		"addReservedSource": "bullet.add()",
	}

func source_bullet_type_create_trail_add_state(lifetime_payload_damage_state: Dictionary) -> Dictionary:
	var raw_bullet_state = lifetime_payload_damage_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(lifetime_payload_damage_state.get("bulletLifetimePayloadDamageApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(lifetime_payload_damage_state.get("bulletContinues", false)),
			"bulletTrailAddApplied": false,
			"trailCleared": false,
			"bulletAdded": false,
			"typeInitCalled": false,
			"typeInitCall": null,
			"bullet": null,
			"trailNullGuardSource": "if(bullet.trail != null){",
			"trailClearSource": "bullet.trail.clear()",
			"trailClearImplSource": "points.clear()",
			"bulletAddSource": "bullet.add()",
			"bulletCompAddSource": "type.init(self())",
			"keepVelocityReservedSource": "if(keepVelocity && owner instanceof Velc v){",
		}
	bullet_state = bullet_state.duplicate(true)
	var raw_trail_state = bullet_state.get("trail", null)
	var trail_state: Dictionary = raw_trail_state if raw_trail_state is Dictionary else {}
	var trail_cleared := false
	if raw_trail_state != null:
		trail_cleared = true
		if raw_trail_state is Dictionary:
			trail_state = trail_state.duplicate(true)
			trail_state["points"] = []
			bullet_state["trail"] = trail_state
	var type_init_call := {"call": "type.init(self())", "bullet": bullet_state}
	return {
		"bulletContinues": true,
		"bulletTrailAddApplied": true,
		"trailCleared": trail_cleared,
		"bulletAdded": true,
		"typeInitCalled": true,
		"typeInitCall": type_init_call,
		"bullet": bullet_state,
		"trailNullGuardSource": "if(bullet.trail != null){",
		"trailClearSource": "bullet.trail.clear()",
		"trailClearImplSource": "points.clear()",
		"bulletAddSource": "bullet.add()",
		"bulletCompAddSource": "type.init(self())",
		"keepVelocityReservedSource": "if(keepVelocity && owner instanceof Velc v){",
	}

const SOURCE_BULLET_VELOCITY_VECTOR_FIELD := "Vec2 vel = new Vec2();"
const SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS := "vel.trns(angle, amount);"
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD := "public Vec2 trns(float angle, float amount){"
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN := "return set(amount, 0).rotate(angle);"
const SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE := "existing Vec2 velocity"
const SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE := "vel.trns(angle, amount)"

func source_bullet_velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	if velocity_state.has("x") or velocity_state.has("y"):
		return {
			"x": float(velocity_state.get("x", 0.0)),
			"y": float(velocity_state.get("y", 0.0)),
			"source": SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE,
		}
	var angle := float(velocity_state.get("angle", 0.0))
	var speed := float(velocity_state.get("speed", 0.0))
	var vec := source_arc_angles_trns_vec(angle, speed, 0.0)
	return {
		"x": float(vec.get("x", 0.0)),
		"y": float(vec.get("y", 0.0)),
		"angle": angle,
		"speed": speed,
		"source": SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE,
	}

func source_bullet_type_create_keep_velocity_state(trail_add_state: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary) -> Dictionary:
	var raw_bullet_state = trail_add_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(trail_add_state.get("bulletTrailAddApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(trail_add_state.get("bulletContinues", false)),
			"keepVelocityApplied": false,
			"scaleKeepVelocityApplied": false,
			"returnedBullet": null,
			"bullet": null,
			"keepVelocitySource": "if(keepVelocity && owner instanceof Velc v){",
			"vec2LenSource": "return (float)Math.sqrt(x * x + y * y)",
			"vec2AddSource": "x += v.x; y += v.y",
			"lifetimeScaleSource": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen)",
			"returnSource": "return bullet",
		}
	var keep_velocity := bool(bullet_type_state.get("keepVelocity", true))
	var scale_keep_velocity := bool(bullet_type_state.get("scaleKeepVelocity", false))
	var owner_is_velc := bool(owner_state.get("isVelc", false))
	bullet_state = bullet_state.duplicate(true)
	var raw_velocity_state = bullet_state.get("velocity", {})
	var velocity_state: Dictionary = raw_velocity_state if raw_velocity_state is Dictionary else {}
	var bullet_vel_before := source_bullet_velocity_vector_state(velocity_state)
	var raw_owner_vel = owner_state.get("vel", {"x": 0.0, "y": 0.0})
	var owner_vel: Dictionary = raw_owner_vel if raw_owner_vel is Dictionary else {"x": 0.0, "y": 0.0}
	var len_before := sqrt(float(bullet_vel_before.get("x", 0.0)) * float(bullet_vel_before.get("x", 0.0)) + float(bullet_vel_before.get("y", 0.0)) * float(bullet_vel_before.get("y", 0.0)))
	if not (keep_velocity and owner_is_velc):
		return {
			"bulletContinues": true,
			"keepVelocityApplied": false,
			"scaleKeepVelocityApplied": false,
			"keepVelocity": keep_velocity,
			"ownerIsVelc": owner_is_velc,
			"lenBefore": len_before,
			"lenAfter": len_before,
			"bulletVelBefore": bullet_vel_before,
			"bulletVelAfter": bullet_vel_before.duplicate(),
			"returnedBullet": bullet_state,
			"bullet": bullet_state,
			"keepVelocitySource": "if(keepVelocity && owner instanceof Velc v){",
			"vec2LenSource": "return (float)Math.sqrt(x * x + y * y)",
			"vec2AddSource": "x += v.x; y += v.y",
			"lifetimeScaleSource": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen)",
			"returnSource": "return bullet",
		}
	var bullet_vel_after := {
		"x": float(bullet_vel_before.get("x", 0.0)) + float(owner_vel.get("x", 0.0)),
		"y": float(bullet_vel_before.get("y", 0.0)) + float(owner_vel.get("y", 0.0)),
	}
	var new_len := sqrt(float(bullet_vel_after["x"]) * float(bullet_vel_after["x"]) + float(bullet_vel_after["y"]) * float(bullet_vel_after["y"]))
	var scale_applied := false
	if scale_keep_velocity and new_len > 0.0:
		scale_applied = true
		bullet_state["lifetime"] = float(bullet_state.get("lifetime", 0.0)) * minf(1.0, len_before / new_len)
	bullet_state["velocity"] = bullet_vel_after
	return {
		"bulletContinues": true,
		"keepVelocityApplied": true,
		"scaleKeepVelocityApplied": scale_applied,
		"keepVelocity": keep_velocity,
		"scaleKeepVelocity": scale_keep_velocity,
		"ownerIsVelc": owner_is_velc,
		"ownerVel": owner_vel,
		"lenBefore": len_before,
		"lenAfter": new_len,
		"bulletVelBefore": bullet_vel_before,
		"bulletVelAfter": bullet_vel_after,
		"returnedBullet": bullet_state,
		"bullet": bullet_state,
		"keepVelocitySource": "if(keepVelocity && owner instanceof Velc v){",
		"vec2LenSource": "return (float)Math.sqrt(x * x + y * y)",
		"vec2AddSource": "x += v.x; y += v.y",
		"lifetimeScaleSource": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen)",
		"returnSource": "return bullet",
	}

func source_bullet_type_init_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var init_bullet_state := bullet_state.duplicate(true)
	var init_owner_state := owner_health_state.duplicate(true)
	var kill_shooter := bool(bullet_type_state.get("killShooter", false))
	var owner_is_healthc := bool(init_owner_state.get("isHealthc", false))
	var owner_dead := bool(init_owner_state.get("dead", false))
	var kill_shooter_applied := false
	if kill_shooter and owner_is_healthc and not owner_dead:
		kill_shooter_applied = true
		init_owner_state["health"] = minf(float(init_owner_state.get("health", 0.0)), 0.0)
		init_owner_state["dead"] = true
		init_owner_state["killedCalled"] = true
		init_owner_state["removed"] = true
	var instant_disappear := bool(bullet_type_state.get("instantDisappear", false))
	if instant_disappear:
		init_bullet_state["time"] = float(bullet_type_state.get("lifetime", 40.0)) + 1.0
	return {
		"bullet": init_bullet_state,
		"owner": init_owner_state,
		"killShooter": kill_shooter,
		"ownerIsHealthc": owner_is_healthc,
		"ownerDeadBefore": owner_dead,
		"killShooterApplied": kill_shooter_applied,
		"instantDisappear": instant_disappear,
		"instantDisappearApplied": instant_disappear,
		"spawnBulletsDeferred": true,
		"killShooterSource": "if(killShooter && b.owner() instanceof Healthc h && !h.dead()){",
		"healthKillSource": "health = Math.min(health, 0); dead = true; killed(); remove()",
		"instantDisappearSource": "b.time = lifetime + 1f",
		"spawnBulletsReservedSource": "if(spawnBullets.size > 0){",
	}

func source_bullet_type_init_spawn_bullets_state(init_initial_state: Dictionary, bullet_type_state: Dictionary, spawn_bullet_random_offsets: Array) -> Dictionary:
	var raw_bullet_state = init_initial_state.get("bullet", {})
	var init_bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	var spawn_bullets: Array = bullet_type_state.get("spawnBullets", [])
	var spawn_calls: Array = []
	for index in spawn_bullets.size():
		var spawn_bullet = spawn_bullets[index]
		var random_offset := float(spawn_bullet_random_offsets[index]) if index < spawn_bullet_random_offsets.size() else 0.0
		var create_call := {
			"bulletType": spawn_bullet,
			"owner": init_bullet_state,
			"x": float(init_bullet_state.get("x", 0.0)),
			"y": float(init_bullet_state.get("y", 0.0)),
			"angle": float(init_bullet_state.get("rotation", 0.0)) + random_offset,
			"randomOffset": random_offset,
			"sourceCall": "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread))",
		}
		spawn_calls.append(create_call)
	return {
		"bullet": init_bullet_state,
		"spawnBulletCount": spawn_bullets.size(),
		"spawnBulletCalls": spawn_calls,
		"spawnBulletsApplied": spawn_bullets.size() > 0,
		"spawnBulletRandomSpread": float(bullet_type_state.get("spawnBulletRandomSpread", 0.0)),
		"spawnBulletRandomOffsets": spawn_bullet_random_offsets.duplicate(),
		"spawnBulletsSource": "if(spawnBullets.size > 0){",
		"spawnBulletCreateSource": "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread))",
		"mathfRangeSource": "return random(-range, range)",
		"updateBoundarySource": "public void update(Bullet b){",
	}

func source_bullet_type_update_dispatch_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var call_order := [
		"updateTrail(b)",
		"updateHoming(b)",
		"updateWeaving(b)",
		"updateTrailEffects(b)",
		"updateBulletInterval(b)",
	]
	return {
		"bullet": update_bullet_state,
		"callOrder": call_order,
		"updateMethodSource": "public void update(Bullet b){",
		"nextMethodReservedSource": "public void updateBulletInterval(Bullet b){",
	}

func source_bullet_type_update_bullet_interval_state(bullet_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, interval_random_offsets: Array) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var interval_bullet = bullet_type_state.get("intervalBullet", null)
	var gate_passed := interval_bullet != null and float(update_bullet_state.get("time", 0.0)) >= float(bullet_type_state.get("intervalDelay", -1.0)) and timer_get_result
	var interval_calls: Array = []
	var interval_bullets := int(bullet_type_state.get("intervalBullets", 1))
	var interval_spread := float(bullet_type_state.get("intervalSpread", 0.0))
	var interval_angle := float(bullet_type_state.get("intervalAngle", 0.0))
	var base_angle := float(update_bullet_state.get("rotation", 0.0))
	if gate_passed:
		for i in interval_bullets:
			var random_offset := float(interval_random_offsets[i]) if i < interval_random_offsets.size() else 0.0
			var spread_offset := (float(i) - (float(interval_bullets) - 1.0) / 2.0) * interval_spread
			interval_calls.append({
				"bulletType": interval_bullet,
				"owner": update_bullet_state,
				"x": float(update_bullet_state.get("x", 0.0)),
				"y": float(update_bullet_state.get("y", 0.0)),
				"angle": base_angle + random_offset + interval_angle + spread_offset,
				"randomOffset": random_offset,
				"spreadOffset": spread_offset,
			})
	return {
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"timerGetResult": timer_get_result,
		"timerIndex": 2,
		"timerTime": float(bullet_type_state.get("bulletInterval", 20.0)),
		"baseAngle": base_angle,
		"intervalBulletCount": interval_calls.size(),
		"intervalBulletCalls": interval_calls,
		"intervalRandomOffsets": interval_random_offsets.duplicate(),
		"gateSource": "if(intervalBullet != null && b.time >= intervalDelay && b.timer.get(2, bulletInterval)){",
		"createSource": "intervalBullet.create(b, b.x, b.y, ang + Mathf.range(intervalRandomSpread) + intervalAngle + ((i - (intervalBullets - 1f)/2f) * intervalSpread))",
		"updateHomingBoundarySource": "public void updateHoming(Bullet b){",
	}

func source_bullet_type_update_trail_state(bullet_state: Dictionary, bullet_type_state: Dictionary, headless_value: bool, trail_interp_value: float, absin_value: float, source_delta: float) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var trail_length := int(bullet_type_state.get("trailLength", -1))
	var gate_passed := not headless_value and trail_length > 0
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"trailUpdated": false,
			"gatePassed": false,
			"gateSource": "if(!headless && trailLength > 0){",
			"updateSource": "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)))",
			"initBoundarySource": "public void init(){",
		}
	var raw_trail_state = update_bullet_state.get("trail", null)
	var trail_state: Dictionary = raw_trail_state if raw_trail_state is Dictionary else {}
	var trail_created := raw_trail_state == null or not (raw_trail_state is Dictionary)
	trail_state["length"] = trail_length
	var sin_scale := 1.0 + (absin_value if float(bullet_type_state.get("trailSinMag", 0.0)) > 0.0 else 0.0)
	var width := trail_interp_value * sin_scale
	trail_state["lastX"] = float(update_bullet_state.get("x", 0.0))
	trail_state["lastY"] = float(update_bullet_state.get("y", 0.0))
	trail_state["lastW"] = width
	trail_state["counter"] = float(trail_state.get("counter", 0.0)) + source_delta
	update_bullet_state["trail"] = trail_state
	return {
		"bullet": update_bullet_state,
		"trail": trail_state,
		"trailCreated": trail_created,
		"trailUpdated": true,
		"gatePassed": true,
		"width": width,
		"sinScale": sin_scale,
		"trailInterpValue": trail_interp_value,
		"absinValue": absin_value,
		"gateSource": "if(!headless && trailLength > 0){",
		"updateSource": "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)))",
		"initBoundarySource": "public void init(){",
	}

func source_bullet_type_update_homing_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var homing_power := float(bullet_type_state.get("homingPower", 0.0))
	var homing_delay := float(bullet_type_state.get("homingDelay", -1.0))
	var gate_passed := homing_power > 0.0001 and float(update_bullet_state.get("time", 0.0)) >= homing_delay
	var aim_x := float(update_bullet_state.get("aimX", -1.0))
	var aim_y := float(update_bullet_state.get("aimY", -1.0))
	var real_aim_x := float(update_bullet_state.get("x", 0.0)) if aim_x < 0.0 else aim_x
	var real_aim_y := float(update_bullet_state.get("y", 0.0)) if aim_y < 0.0 else aim_y
	var reported_real_aim_x: Variant = null
	var reported_real_aim_y: Variant = null
	if gate_passed:
		reported_real_aim_x = real_aim_x
		reported_real_aim_y = real_aim_y
	return {
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"realAimComputed": gate_passed,
		"realAimX": reported_real_aim_x,
		"realAimY": reported_real_aim_y,
		"aimX": aim_x,
		"aimY": aim_y,
		"homingPower": homing_power,
		"homingDelay": homing_delay,
		"homingRange": float(bullet_type_state.get("homingRange", 50.0)),
		"targetSelectionDeferred": true,
		"followAimDeferred": true,
		"gateSource": "if(homingPower > 0.0001f && b.time >= homingDelay){",
		"realAimXSource": "float realAimX = b.aimX < 0 ? b.x : b.aimX",
		"realAimYSource": "float realAimY = b.aimY < 0 ? b.y : b.aimY",
		"targetReservedSource": "Teamc target",
		"followAimReservedSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u)",
	}

func source_bullet_type_update_homing_target_velocity_state(homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
	var update_bullet_state: Dictionary = homing_initial_state.get("bullet", {}).duplicate(true)
	var gate_passed := bool(homing_initial_state.get("gatePassed", false)) and target_state is Dictionary
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"homingVelocityApplied": false,
			"targetGatePassed": false,
			"targetGateSource": "if(target != null){",
			"setAngleSource": "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f))",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var current_rotation := float(update_bullet_state.get("rotation", float(velocity_state.get("angle", 0.0))))
	var homing_power := float(homing_initial_state.get("homingPower", 0.0))
	var target_angle := source_arc_angles_angle(float(update_bullet_state.get("x", 0.0)), float(update_bullet_state.get("y", 0.0)), float(target_state.get("x", 0.0)), float(target_state.get("y", 0.0)))
	var max_turn := homing_power * source_delta * 50.0
	var next_angle := source_arc_angles_move_toward(current_rotation, target_angle, max_turn)
	var speed := float(velocity_state.get("speed", sqrt(velocity_x * velocity_x + velocity_y * velocity_y)))
	var next_velocity := source_arc_angles_trns_vec(next_angle, speed, 0.0)
	update_bullet_state["rotation"] = next_angle
	update_bullet_state["velocity"] = {"angle": next_angle, "speed": speed, "x": next_velocity["x"], "y": next_velocity["y"]}
	return {
		"bullet": update_bullet_state,
		"homingVelocityApplied": true,
		"targetGatePassed": true,
		"currentRotation": current_rotation,
		"targetAngle": target_angle,
		"maxTurn": max_turn,
		"nextAngle": next_angle,
		"speed": speed,
		"velocity": update_bullet_state["velocity"],
		"targetGateSource": "if(target != null){",
		"setAngleSource": "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f))",
		"angleToSource": "return Angles.angle(getX(), getY(), other.getX(), other.getY())",
		"vec2SetAngleSource": "this.set(len(), 0f); this.rotateRad(radians)",
	}

func source_bullet_type_update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	var update_bullet_state: Dictionary = homing_target_velocity_state.get("bullet", {}).duplicate(true)
	var follow_aim_speed := float(bullet_type_state.get("followAimSpeed", 0.0))
	var gate_passed := follow_aim_speed > 0.0 and shooter_state is Dictionary and bool(shooter_state.get("isUnit", false))
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"followAimApplied": false,
			"followAimGatePassed": false,
			"followAimGateSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u){",
			"followAimSetAngleSource": "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta))",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var target_angle := source_arc_angles_angle(float(update_bullet_state.get("x", 0.0)), float(update_bullet_state.get("y", 0.0)), float(shooter_state.get("aimX", 0.0)), float(shooter_state.get("aimY", 0.0)))
	var current_velocity_angle := float(velocity_state.get("angle", update_bullet_state.get("rotation", 0.0)))
	var max_turn := follow_aim_speed * source_delta
	var next_angle := source_arc_angles_move_toward(current_velocity_angle, target_angle, max_turn)
	var speed := float(velocity_state.get("speed", sqrt(velocity_x * velocity_x + velocity_y * velocity_y)))
	var next_velocity := source_arc_angles_trns_vec(next_angle, speed, 0.0)
	update_bullet_state["rotation"] = next_angle
	update_bullet_state["velocity"] = {"angle": next_angle, "speed": speed, "x": next_velocity["x"], "y": next_velocity["y"]}
	return {
		"bullet": update_bullet_state,
		"followAimApplied": true,
		"followAimGatePassed": true,
		"currentVelocityAngle": current_velocity_angle,
		"targetAngle": target_angle,
		"maxTurn": max_turn,
		"nextAngle": next_angle,
		"speed": speed,
		"velocity": update_bullet_state["velocity"],
		"followAimGateSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u){",
		"followAimAngleSource": "float angle = b.angleTo(u.aimX, u.aimY)",
		"followAimSetAngleSource": "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta))",
	}

func source_bullet_type_update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var weave_mag := float(bullet_type_state.get("weaveMag", 0.0))
	var gate_passed := weave_mag != 0.0
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"weaveApplied": false,
			"weaveGatePassed": false,
			"weaveGateSource": "if(weaveMag != 0){",
			"rotateRadExactSource": "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad)",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var weave_scale := float(bullet_type_state.get("weaveScale", 1.0))
	var random_sign := -1.0 if bool(bullet_type_state.get("weaveRandom", true)) and random_seed_result == 1 else 1.0
	var rotation_radians := sin((float(update_bullet_state.get("time", 0.0)) + PI * weave_scale / 2.0) / weave_scale) * weave_mag * random_sign * source_delta * deg_to_rad(1.0)
	var next_x := velocity_x * cos(rotation_radians) - velocity_y * sin(rotation_radians)
	var next_y := velocity_x * sin(rotation_radians) + velocity_y * cos(rotation_radians)
	update_bullet_state["velocity"] = {"x": next_x, "y": next_y, "angle": source_arc_angles_angle(0.0, 0.0, next_x, next_y), "speed": sqrt(next_x * next_x + next_y * next_y)}
	return {
		"bullet": update_bullet_state,
		"weaveApplied": true,
		"weaveGatePassed": true,
		"rotationRadians": rotation_radians,
		"randomSign": random_sign,
		"randomSeedResult": random_seed_result,
		"velocity": update_bullet_state["velocity"],
		"weaveGateSource": "if(weaveMag != 0){",
		"rotateRadExactSource": "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad)",
		"vec2RotateRadExactSource": "float newX = this.x * cos - this.y * sin; float newY = this.x * sin + this.y * cos",
	}

func source_bullet_type_update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	var update_bullet_state: Dictionary = weaving_state.get("bullet", {}).duplicate(true)
	var rotate_speed := float(bullet_type_state.get("rotateSpeed", 0.0))
	var gate_passed := rotate_speed != 0.0
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"rotateSpeedApplied": false,
			"rotateSpeedGatePassed": false,
			"rotateSpeedGateSource": "if(rotateSpeed != 0){",
			"rotateSpeedSource": "b.vel.rotate(rotateSpeed * Time.delta)",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var rotation_radians := rotate_speed * source_delta * deg_to_rad(1.0)
	var next_x := velocity_x * cos(rotation_radians) - velocity_y * sin(rotation_radians)
	var next_y := velocity_x * sin(rotation_radians) + velocity_y * cos(rotation_radians)
	update_bullet_state["velocity"] = {"x": next_x, "y": next_y, "angle": source_arc_angles_angle(0.0, 0.0, next_x, next_y), "speed": sqrt(next_x * next_x + next_y * next_y)}
	return {
		"bullet": update_bullet_state,
		"rotateSpeedApplied": true,
		"rotateSpeedGatePassed": true,
		"rotationRadians": rotation_radians,
		"velocity": update_bullet_state["velocity"],
		"rotateSpeedGateSource": "if(rotateSpeed != 0){",
		"rotateSpeedSource": "b.vel.rotate(rotateSpeed * Time.delta)",
		"vec2RotateSource": "return rotateRad(degrees * Mathf.degreesToRadians)",
	}

func source_vec2_limit(vector_state: Dictionary, limit: float) -> Dictionary:
	var vector_x := float(vector_state.get("x", 0.0))
	var vector_y := float(vector_state.get("y", 0.0))
	var len2 := vector_x * vector_x + vector_y * vector_y
	var limit2 := limit * limit
	if len2 > limit2:
		var limit_scale := sqrt(limit2 / len2)
		return {"x": vector_x * limit_scale, "y": vector_y * limit_scale}
	return {"x": vector_x, "y": vector_y}

func source_bullet_type_update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	var update_bullet_state: Dictionary = rotate_speed_state.get("bullet", {}).duplicate(true)
	var gate_passed := bool(bullet_type_state.get("circleShooter", false)) and bool(owner_health_state.get("isHealthc", false)) and bool(owner_health_state.get("isValid", false))
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"circleShooterApplied": false,
			"circleShooterGatePassed": false,
			"circleShooterGateSource": "if(circleShooter && b.owner instanceof Healthc h && h.isValid()){",
			"circleShooterVelocitySource": "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed)",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var tmp_x := float(owner_health_state.get("x", 0.0)) - float(update_bullet_state.get("x", 0.0))
	var tmp_y := float(owner_health_state.get("y", 0.0)) - float(update_bullet_state.get("y", 0.0))
	var tmp_len := sqrt(tmp_x * tmp_x + tmp_y * tmp_y)
	var circle_radius := float(bullet_type_state.get("circleShooterRadius", 13.0))
	var circle_radius_smooth := float(bullet_type_state.get("circleShooterRadiusSmooth", 10.0))
	var circle_rotate_speed := float(bullet_type_state.get("circleShooterRotateSpeed", 0.3))
	var speed := float(bullet_type_state.get("speed", 1.0))
	var circle_rotation_degrees: float = 90.0 * (0.0 + (1.0 - 0.0) * (1.0 - clamp((tmp_len - circle_radius) / circle_radius_smooth, 0.0, 1.0)))
	var rotation_radians := circle_rotation_degrees * deg_to_rad(1.0)
	var tmp_rotated := {"x": tmp_x * cos(rotation_radians) - tmp_y * sin(rotation_radians), "y": tmp_x * sin(rotation_radians) + tmp_y * cos(rotation_radians)}
	var tmp_limit := speed * circle_rotate_speed * source_delta
	var limited_tmp := source_vec2_limit(tmp_rotated, tmp_limit)
	var limited_velocity := source_vec2_limit({"x": velocity_x + float(limited_tmp.get("x", 0.0)), "y": velocity_y + float(limited_tmp.get("y", 0.0))}, speed)
	update_bullet_state["velocity"] = {"x": float(limited_velocity.get("x", 0.0)), "y": float(limited_velocity.get("y", 0.0)), "angle": source_arc_angles_angle(0.0, 0.0, float(limited_velocity.get("x", 0.0)), float(limited_velocity.get("y", 0.0))), "speed": sqrt(float(limited_velocity.get("x", 0.0)) * float(limited_velocity.get("x", 0.0)) + float(limited_velocity.get("y", 0.0)) * float(limited_velocity.get("y", 0.0)))}
	return {
		"bullet": update_bullet_state,
		"circleShooterApplied": true,
		"circleShooterGatePassed": true,
		"tmpBeforeRotate": {"x": tmp_x, "y": tmp_y, "len": tmp_len},
		"rotationDegrees": circle_rotation_degrees,
		"rotationRadians": rotation_radians,
		"tmpLimit": tmp_limit,
		"limitedTmp": limited_tmp,
		"velocity": update_bullet_state["velocity"],
		"circleShooterGateSource": "if(circleShooter && b.owner instanceof Healthc h && h.isValid()){",
		"circleShooterTmpSource": "Tmp.v1.set(h).sub(b)",
		"circleShooterRotateSource": "Tmp.v1.rotate(90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth)))",
		"circleShooterVelocitySource": "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed)",
	}

const SOURCE_BULLET_ROTATION_COMMENT := "/** @return the bullet's rotation. */"
const SOURCE_BULLET_ROTATION_METHOD := "public float rotation(){"
const SOURCE_BULLET_ROTATION_RETURN := "return vel.isZero(0.001f) ? rotation : vel.angle();"
const SOURCE_BULLET_ROTATION_ZERO_MARGIN := 0.001

func source_bullet_rotation_degrees(bullet_state: Dictionary) -> float:
	var velocity_state: Dictionary = bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var velocity_len2 := velocity_x * velocity_x + velocity_y * velocity_y
	if velocity_len2 < SOURCE_BULLET_ROTATION_ZERO_MARGIN:
		return float(bullet_state.get("rotation", 0.0))
	return source_arc_angles_angle(0.0, 0.0, velocity_x, velocity_y)

func source_bullet_type_update_trail_effects_chance_state(bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var velocity_len2 := velocity_x * velocity_x + velocity_y * velocity_y
	var trail_min_velocity := float(bullet_type_state.get("trailMinVelocity", 0.0))
	var can_spawn := trail_min_velocity <= 0.0 or velocity_len2 >= trail_min_velocity * trail_min_velocity
	var trail_chance := float(bullet_type_state.get("trailChance", -0.0001))
	var gate_passed := trail_chance > 0.0 and can_spawn
	if not gate_passed or not chance_delta_result:
		return {
			"bullet": update_bullet_state,
			"trailChanceEffectApplied": false,
			"canSpawn": can_spawn,
			"chanceGatePassed": gate_passed,
			"chanceDeltaResult": chance_delta_result,
			"effectCalls": [],
			"canSpawnSource": "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity",
			"chanceGateSource": "if(trailChance > 0 && canSpawn){",
			"chanceDeltaSource": "if(Mathf.chanceDelta(trailChance)){",
			"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
		}
	var trail_spread := float(bullet_type_state.get("trailSpread", 0.0))
	var tmp_offset: Dictionary = {"x": 0.0, "y": 0.0}
	if trail_spread > 0.0:
		tmp_offset = random_offset_state.duplicate(true)
	var effect_rotation: float = source_bullet_rotation_degrees(update_bullet_state) if bool(bullet_type_state.get("trailRotation", false)) else float(bullet_type_state.get("trailParam", 2.0))
	var effect_call := {"x": float(update_bullet_state.get("x", 0.0)) + float(tmp_offset.get("x", 0.0)), "y": float(update_bullet_state.get("y", 0.0)) + float(tmp_offset.get("y", 0.0)), "rotation": effect_rotation, "color": bullet_type_state.get("trailColor", "Pal.missileYellowBack"), "effect": bullet_type_state.get("trailEffect", "Fx.missileTrail")}
	return {
		"bullet": update_bullet_state,
		"trailChanceEffectApplied": true,
		"canSpawn": can_spawn,
		"chanceGatePassed": gate_passed,
		"chanceDeltaResult": chance_delta_result,
		"trailSpread": trail_spread,
		"tmpOffset": tmp_offset,
		"effectCalls": [effect_call],
		"canSpawnSource": "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity",
		"chanceGateSource": "if(trailChance > 0 && canSpawn){",
		"chanceDeltaSource": "if(Mathf.chanceDelta(trailChance)){",
		"spreadRandomSource": "Tmp.v1.rnd(Mathf.random(trailSpread))",
		"spreadZeroSource": "Tmp.v1.setZero()",
		"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
	}

func source_bullet_type_update_trail_effects_interval_state(chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = chance_state.get("bullet", {}).duplicate(true)
	var effect_calls: Array = chance_state.get("effectCalls", []).duplicate(true)
	var can_spawn := bool(chance_state.get("canSpawn", false))
	var trail_interval := float(bullet_type_state.get("trailInterval", 0.0))
	var gate_passed := trail_interval > 0.0 and can_spawn
	if not gate_passed or not timer_get_result:
		return {
			"bullet": update_bullet_state,
			"trailIntervalEffectApplied": false,
			"canSpawn": can_spawn,
			"intervalGatePassed": gate_passed,
			"timerGetResult": timer_get_result,
			"effectCalls": effect_calls,
			"intervalGateSource": "if(trailInterval > 0f && canSpawn){",
			"timerSource": "if(b.timer(0, trailInterval)){",
			"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
		}
	var trail_spread := float(bullet_type_state.get("trailSpread", 0.0))
	var tmp_offset: Dictionary = {"x": 0.0, "y": 0.0}
	if trail_spread > 0.0:
		tmp_offset = random_offset_state.duplicate(true)
	var effect_rotation: float = source_bullet_rotation_degrees(update_bullet_state) if bool(bullet_type_state.get("trailRotation", false)) else float(bullet_type_state.get("trailParam", 2.0))
	var effect_call := {"x": float(update_bullet_state.get("x", 0.0)) + float(tmp_offset.get("x", 0.0)), "y": float(update_bullet_state.get("y", 0.0)) + float(tmp_offset.get("y", 0.0)), "rotation": effect_rotation, "color": bullet_type_state.get("trailColor", "Pal.missileYellowBack"), "effect": bullet_type_state.get("trailEffect", "Fx.missileTrail")}
	effect_calls.append(effect_call)
	return {
		"bullet": update_bullet_state,
		"trailIntervalEffectApplied": true,
		"canSpawn": can_spawn,
		"intervalGatePassed": gate_passed,
		"timerGetResult": timer_get_result,
		"trailSpread": trail_spread,
		"tmpOffset": tmp_offset,
		"effectCalls": effect_calls,
		"intervalGateSource": "if(trailInterval > 0f && canSpawn){",
		"timerSource": "if(b.timer(0, trailInterval)){",
		"spreadRandomSource": "Tmp.v1.rnd(Mathf.random(trailSpread))",
		"spreadZeroSource": "Tmp.v1.setZero()",
		"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
	}

func source_bullet_type_init_type_defaults_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state := bullet_type_state.duplicate(true)
	var pierce_cap := int(update_type_state.get("pierceCap", -1))
	var pierce_applied := pierce_cap >= 1
	if pierce_applied:
		update_type_state["pierce"] = true
	var set_defaults := bool(update_type_state.get("setDefaults", true))
	var lightning := int(update_type_state.get("lightning", 0))
	var status_before := str(update_type_state.get("status", "none"))
	var status_shocked_applied := set_defaults and lightning > 0 and status_before == "none"
	if status_shocked_applied:
		update_type_state["status"] = "shocked"
	var despawn_hit_applied := set_defaults and (update_type_state.get("fragBullet", null) != null or float(update_type_state.get("splashDamageRadius", 0.0)) > 0.0 or lightning > 0)
	if despawn_hit_applied:
		update_type_state["despawnHit"] = true
	return {
		"bulletType": update_type_state,
		"pierceApplied": pierce_applied,
		"setDefaults": set_defaults,
		"lightning": lightning,
		"statusBefore": status_before,
		"statusShockedApplied": status_shocked_applied,
		"despawnHitApplied": despawn_hit_applied,
		"pierceGateSource": "if(pierceCap >= 1){",
		"pierceAssignSource": "pierce = true",
		"setDefaultsGateSource": "if(setDefaults){",
		"lightningGateSource": "if(lightning > 0){",
		"statusGateSource": "if(status == StatusEffects.none){",
		"statusAssignSource": "status = StatusEffects.shocked",
		"despawnHitGateSource": "if(fragBullet != null || splashDamageRadius > 0 || lightning > 0){",
		"despawnHitAssignSource": "despawnHit = true",
	}

func source_bullet_type_init_frag_velocity_state(type_defaults_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = type_defaults_state.get("bulletType", {}).duplicate(true)
	var frag_bullet_value = update_type_state.get("fragBullet", null)
	var gate_passed := frag_bullet_value != null
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"fragBulletVelocityApplied": false,
			"fragGatePassed": false,
			"fragGateSource": "if(fragBullet != null){",
			"fragKeepVelocitySource": "fragBullet.keepVelocity = false",
			"fragScaleKeepVelocitySource": "fragBullet.scaleKeepVelocity = false",
		}
	var frag_bullet_state := (frag_bullet_value as Dictionary).duplicate(true)
	frag_bullet_state["keepVelocity"] = false
	frag_bullet_state["scaleKeepVelocity"] = false
	update_type_state["fragBullet"] = frag_bullet_state
	return {
		"bulletType": update_type_state,
		"fragBulletVelocityApplied": true,
		"fragGatePassed": true,
		"fragBullet": frag_bullet_state,
		"fragGateSource": "if(fragBullet != null){",
		"fragKeepVelocitySource": "fragBullet.keepVelocity = false",
		"fragScaleKeepVelocitySource": "fragBullet.scaleKeepVelocity = false",
	}

func source_bullet_type_init_lightning_type_state(frag_velocity_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = frag_velocity_state.get("bulletType", {}).duplicate(true)
	var gate_passed := update_type_state.get("lightningType", null) == null
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"lightningTypeApplied": false,
			"lightningTypeGatePassed": false,
			"lightningType": update_type_state.get("lightningType", null),
			"lightningTypeGateSource": "if(lightningType == null){",
			"lightningTypeChoiceSource": "!collidesAir ? Bullets.damageLightningGround : !collidesGround ? Bullets.damageLightningAir : Bullets.damageLightning",
		}
	var lightning_type := ""
	lightning_type = "Bullets.damageLightning"
	if not bool(update_type_state.get("collidesAir", true)):
		lightning_type = "Bullets.damageLightningGround"
	elif not bool(update_type_state.get("collidesGround", true)):
		lightning_type = "Bullets.damageLightningAir"
	update_type_state["lightningType"] = lightning_type
	return {
		"bulletType": update_type_state,
		"lightningTypeApplied": true,
		"lightningTypeGatePassed": true,
		"lightningType": lightning_type,
		"collidesAir": bool(update_type_state.get("collidesAir", true)),
		"collidesGround": bool(update_type_state.get("collidesGround", true)),
		"lightningTypeGateSource": "if(lightningType == null){",
		"lightningTypeChoiceSource": "!collidesAir ? Bullets.damageLightningGround : !collidesGround ? Bullets.damageLightningAir : Bullets.damageLightning",
	}

func source_bullet_type_init_light_radius_state(lightning_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = lightning_type_state.get("bulletType", {}).duplicate(true)
	var light_radius := float(update_type_state.get("lightRadius", -1.0))
	var gate_passed := light_radius <= -1.0
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"lightRadiusApplied": false,
			"lightRadiusGatePassed": false,
			"lightRadius": light_radius,
			"lightRadiusGateSource": "if(lightRadius <= -1){",
			"lightRadiusAssignSource": "lightRadius = Math.max(18, hitSize * 5f)",
		}
	var resolved_light_radius: float = max(18.0, float(update_type_state.get("hitSize", 4.0)) * 5.0)
	update_type_state["lightRadius"] = resolved_light_radius
	return {
		"bulletType": update_type_state,
		"lightRadiusApplied": true,
		"lightRadiusGatePassed": true,
		"lightRadius": resolved_light_radius,
		"hitSize": float(update_type_state.get("hitSize", 4.0)),
		"lightRadiusGateSource": "if(lightRadius <= -1){",
		"lightRadiusAssignSource": "lightRadius = Math.max(18, hitSize * 5f)",
	}

func source_bullet_type_init_draw_size_state(light_radius_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = light_radius_state.get("bulletType", {}).duplicate(true)
	var draw_size := float(update_type_state.get("drawSize", 40.0))
	var computed_draw_size := float(update_type_state.get("trailLength", -1)) * float(update_type_state.get("speed", 1.0)) * 2.0
	var resolved_draw_size: float = max(draw_size, computed_draw_size)
	update_type_state["drawSize"] = resolved_draw_size
	return {
		"bulletType": update_type_state,
		"drawSize": resolved_draw_size,
		"drawSizeBefore": draw_size,
		"computedDrawSize": computed_draw_size,
		"trailLength": int(update_type_state.get("trailLength", -1)),
		"speed": float(update_type_state.get("speed", 1.0)),
		"drawSizeAssignSource": "drawSize = Math.max(drawSize, trailLength * speed * 2f)",
	}

func source_bullet_type_init_range_assignment_state(draw_size_state: Dictionary, calculate_range_result: float) -> Dictionary:
	var update_type_state: Dictionary = draw_size_state.get("bulletType", {}).duplicate(true)
	var range_before := float(update_type_state.get("range", 0.0))
	update_type_state["range"] = calculate_range_result
	return {
		"bulletType": update_type_state,
		"range": calculate_range_result,
		"rangeBefore": range_before,
		"rangeAssignSource": "range = calculateRange()",
		"calculateRangeDeferred": true,
	}

func source_bullet_type_calculate_range_override_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var range_override := float(update_type_state.get("rangeOverride", -1.0))
	var gate_passed := range_override > 0.0
	var resolved_range: Variant = null
	if gate_passed:
		resolved_range = range_override
	return {
		"bulletType": update_type_state,
		"rangeOverride": range_override,
		"rangeOverrideGatePassed": gate_passed,
		"returnEarly": gate_passed,
		"range": resolved_range,
		"rangeOverrideReturnSource": "if(rangeOverride > 0) return rangeOverride",
	}

func source_bullet_type_calculate_range_spawn_unit_state(override_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = override_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(override_state.get("returnEarly", false))
	var spawn_unit_value = update_type_state.get("spawnUnit", null)
	var gate_passed := (not prior_return) and spawn_unit_value != null
	var resolved_range: Variant = override_state.get("range", null)
	var spawn_unit_state: Dictionary = {}
	var returned_spawn_unit: Variant = null
	if gate_passed:
		spawn_unit_state = (spawn_unit_value as Dictionary).duplicate(true)
		resolved_range = float(spawn_unit_state.get("lifetime", 0.0)) * float(spawn_unit_state.get("speed", 0.0))
		returned_spawn_unit = spawn_unit_state
	return {
		"bulletType": update_type_state,
		"spawnUnitRangeGatePassed": gate_passed,
		"returnEarly": prior_return or gate_passed,
		"range": resolved_range,
		"spawnUnit": returned_spawn_unit,
		"spawnUnitReturnSource": "if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed",
	}

func source_bullet_type_calculate_range_despawn_unit_state(spawn_unit_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = spawn_unit_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(spawn_unit_state.get("returnEarly", false))
	var despawn_unit_value = update_type_state.get("despawnUnit", null)
	var gate_passed := (not prior_return) and despawn_unit_value != null
	var resolved_range: Variant = spawn_unit_state.get("range", null)
	var despawn_unit_state: Dictionary = {}
	var returned_despawn_unit: Variant = null
	if gate_passed:
		despawn_unit_state = (despawn_unit_value as Dictionary).duplicate(true)
		resolved_range = float(despawn_unit_state.get("lifetime", 0.0)) * float(despawn_unit_state.get("speed", 0.0))
		returned_despawn_unit = despawn_unit_state
	return {
		"bulletType": update_type_state,
		"despawnUnitRangeGatePassed": gate_passed,
		"returnEarly": prior_return or gate_passed,
		"range": resolved_range,
		"despawnUnit": returned_despawn_unit,
		"despawnUnitReturnSource": "if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed",
	}

func source_bullet_type_calculate_range_fallback_state(despawn_unit_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = despawn_unit_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(despawn_unit_state.get("returnEarly", false))
	var resolved_range: Variant = despawn_unit_state.get("range", null)
	var speed := float(update_type_state.get("speed", 1.0))
	var lifetime := float(update_type_state.get("lifetime", 40.0))
	var drag := float(update_type_state.get("drag", 0.0))
	var max_range := float(update_type_state.get("maxRange", -1.0))
	var zero_drag := absf(drag) <= 0.000001
	var fallback_range := 0.0
	var fallback_gate_passed := not prior_return
	if fallback_gate_passed:
		if zero_drag:
			fallback_range = speed * lifetime
		else:
			fallback_range = speed * (1.0 - pow(1.0 - drag, lifetime)) / drag
		resolved_range = max(fallback_range, max_range)
	return {
		"bulletType": update_type_state,
		"fallbackRangeGatePassed": fallback_gate_passed,
		"returnEarly": prior_return or fallback_gate_passed,
		"range": resolved_range,
		"fallbackRange": fallback_range,
		"zeroDrag": zero_drag,
		"drag": drag,
		"maxRange": max_range,
		"fallbackReturnSource": "return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange)",
	}

func source_bullet_type_continuous_damage_default_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	return {
		"bulletType": update_type_state,
		"continuousDamage": -1.0,
		"continuousDamageReturnSource": "return -1f",
	}

func source_bullet_type_heals_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heals := heal_percent > 0.0 or heal_amount > 0.0
	return {
		"bulletType": update_type_state,
		"healPercent": heal_percent,
		"healAmount": heal_amount,
		"heals": heals,
		"healsReturnSource": "return healPercent > 0 || healAmount > 0",
	}

func source_bullet_type_test_collision_state(bullet_type_state: Dictionary, bullet_state: Dictionary, tile_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_tile_state: Dictionary = tile_state.duplicate(true)
	var heals_state := source_bullet_type_heals_state(update_type_state)
	var heals := bool(heals_state.get("heals", false))
	var tile_team = update_tile_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var tile_healthf := float(update_tile_state.get("healthf", 0.0))
	var collides_tile: bool = not heals or tile_team != bullet_team or tile_healthf < 1.0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"tile": update_tile_state,
		"heals": heals,
		"tileTeam": tile_team,
		"bulletTeam": bullet_team,
		"tileHealthf": tile_healthf,
		"collides": collides_tile,
		"testCollisionReturnSource": "return !heals() || tile.team != bullet.team || tile.healthf() < 1f",
	}

func source_bullet_type_hit_tile_fire_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var make_fire := bool(update_type_state.get("makeFire", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var fire_gate_passed: bool = make_fire and build_team != bullet_team
	var build_tile = update_build_state.get("tile", null)
	var fires_create_call: Variant = null
	if fire_gate_passed:
		fires_create_call = {"call": "Fires.create(build.tile)", "tile": build_tile}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"makeFire": make_fire,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"fireGatePassed": fire_gate_passed,
		"fireCreated": fire_gate_passed,
		"firesCreateCall": fires_create_call,
		"hitTileFireGateSource": "if(makeFire && build.team != b.team)",
		"firesCreateSource": "Fires.create(build.tile)",
		"healBranchBoundarySource": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock))",
	}

func source_bullet_type_hit_tile_heal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var heals_state := source_bullet_type_heals_state(update_type_state)
	var heals := bool(heals_state.get("heals", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var block_is_construct := bool(update_build_state.get("blockIsConstructBlock", false))
	var heal_gate_passed: bool = heals and build_team == bullet_team and not block_is_construct
	var build_max_health := float(update_build_state.get("maxHealth", 0.0))
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heal_applied_amount := heal_percent / 100.0 * build_max_health + heal_amount
	var heal_color := str(update_type_state.get("healColor", "Pal.heal"))
	var heal_sound_volume := float(update_type_state.get("healSoundVolume", 1.0))
	var build_x := float(update_build_state.get("x", 0.0))
	var build_y := float(update_build_state.get("y", 0.0))
	var build_block = update_build_state.get("block", null)
	var heal_effect_call: Variant = null
	var build_heal_call: Variant = null
	var heal_sound_call: Variant = null
	if heal_gate_passed:
		heal_effect_call = {"call": "healEffect.at(build.x, build.y, 0f, healColor, build.block)", "x": build_x, "y": build_y, "rotation": 0.0, "color": heal_color, "block": build_block}
		build_heal_call = {"call": "build.heal(healPercent / 100f * build.maxHealth + healAmount)", "amount": heal_applied_amount}
		heal_sound_call = {"call": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume)", "pitchBase": 1.0, "pitchRange": 0.1, "volume": heal_sound_volume}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"heals": heals,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"blockIsConstructBlock": block_is_construct,
		"healGatePassed": heal_gate_passed,
		"healAppliedAmount": heal_applied_amount,
		"healed": heal_gate_passed,
		"hitCalled": heal_gate_passed,
		"healEffectCall": heal_effect_call,
		"buildHealCall": build_heal_call,
		"healSoundCall": heal_sound_call,
		"enemyDirectBranchDeferred": true,
		"pierceDeferred": true,
		"hitTileHealGateSource": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock))",
		"healEffectSource": "healEffect.at(build.x, build.y, 0f, healColor, build.block)",
		"healAmountSource": "healPercent / 100f * build.maxHealth + healAmount",
		"healSoundSource": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume)",
		"hitCallSource": "hit(b)",
		"deferredBranchSource": "}else if(build.team != b.team && direct){",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

func source_bullet_type_hit_tile_enemy_direct_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var update_hit_tile_state: Dictionary = hit_tile_state.duplicate(true)
	var direct := bool(update_hit_tile_state.get("direct", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var enemy_direct_gate_passed: bool = build_team != bullet_team and direct
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"hitTile": update_hit_tile_state,
		"direct": direct,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"enemyDirectGatePassed": enemy_direct_gate_passed,
		"hitCalled": enemy_direct_gate_passed,
		"lifestealDeferred": true,
		"pierceDeferred": true,
		"hitTileEnemyDirectGateSource": "}else if(build.team != b.team && direct)",
		"enemyHitCallSource": "hit(b)",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

func source_bullet_type_hit_tile_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var update_hit_tile_state: Dictionary = hit_tile_state.duplicate(true)
	var update_owner_health_state: Dictionary = owner_health_state.duplicate(true)
	var direct := bool(update_hit_tile_state.get("direct", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var enemy_direct_gate_passed: bool = build_team != bullet_team and direct
	var lifesteal := float(update_type_state.get("lifesteal", 0.0))
	var damage := float(update_type_state.get("damage", 0.0))
	var build_health := float(update_build_state.get("health", 0.0))
	var owner_is_healthc := bool(update_owner_health_state.get("isHealthc", false))
	var lifesteal_gate_passed: bool = lifesteal > 0.0 and owner_is_healthc
	var lifesteal_result := maxf(minf(build_health, damage), 0.0)
	var owner_heal_called := enemy_direct_gate_passed and lifesteal_gate_passed
	var owner_heal_amount := lifesteal_result * lifesteal if owner_heal_called else 0.0
	var owner_heal_call = null
	if owner_heal_called:
		owner_heal_call = {
			"call": "o.heal(result * lifesteal)",
			"amount": owner_heal_amount,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"hitTile": update_hit_tile_state,
		"ownerHealth": update_owner_health_state,
		"direct": direct,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"enemyDirectGatePassed": enemy_direct_gate_passed,
		"lifesteal": lifesteal,
		"damage": damage,
		"buildHealth": build_health,
		"ownerIsHealthc": owner_is_healthc,
		"lifestealGatePassed": lifesteal_gate_passed,
		"lifestealResult": lifesteal_result if owner_heal_called else 0.0,
		"ownerHealCalled": owner_heal_called,
		"ownerHealAmount": owner_heal_amount,
		"ownerHealCall": owner_heal_call,
		"pierceDeferred": true,
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"lifestealResultSource": "float result = Math.max(Math.min(build.health, damage), 0)",
		"ownerHealSource": "o.heal(result * lifesteal)",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

func source_bullet_type_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_pierce_state: Dictionary = pierce_state.duplicate(true)
	var pierce_damage_factor := float(update_type_state.get("pierceDamageFactor", 0.0))
	var remove_after_pierce := bool(update_type_state.get("removeAfterPierce", false))
	var initial_health := float(update_pierce_state.get("initialHealth", 0.0))
	var x := float(update_pierce_state.get("x", 0.0))
	var y := float(update_pierce_state.get("y", 0.0))
	var bullet_damage := float(update_bullet_state.get("damage", 0.0))
	var zero_pierce_damage_factor := absf(pierce_damage_factor) <= 0.000001
	var sub := 0.0 if zero_pierce_damage_factor else maxf(initial_health * pierce_damage_factor, 0.0)
	var damage_subtract := bullet_damage if is_nan(sub) else minf(bullet_damage, sub)
	var next_damage := bullet_damage - damage_subtract
	var remove_gate_passed := remove_after_pierce and next_damage <= 0.0
	update_bullet_state["damage"] = next_damage
	if remove_gate_passed:
		update_bullet_state["hit"] = true
		update_bullet_state["removed"] = true
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"pierce": update_pierce_state,
		"pierceDamageFactor": pierce_damage_factor,
		"removeAfterPierce": remove_after_pierce,
		"initialHealth": initial_health,
		"x": x,
		"y": y,
		"zeroPierceDamageFactor": zero_pierce_damage_factor,
		"sub": sub,
		"damageBefore": bullet_damage,
		"damageSubtract": damage_subtract,
		"damage": next_damage,
		"removeGatePassed": remove_gate_passed,
		"hit": bool(update_bullet_state.get("hit", false)),
		"removeCalled": bool(update_bullet_state.get("removed", false)),
		"subSource": "float sub = Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0)",
		"damageSubtractSource": "b.damage -= Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub)",
		"removeAfterPierceSource": "if(removeAfterPierce && b.damage <= 0)",
		"hitAssignmentSource": "b.hit = true",
		"removeCallSource": "b.remove()",
	}

func source_bullet_type_damage_multiplier_state(bullet_state: Dictionary, bullet_owner_state: Dictionary, rules_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_owner_state: Dictionary = bullet_owner_state.duplicate(true)
	var update_rules_state: Dictionary = rules_state.duplicate(true)
	var owner_is_unit := bool(update_owner_state.get("isUnit", false))
	var owner_unit_damage_multiplier := float(update_owner_state.get("unitDamageMultiplier", 1.0))
	var owner_is_building := bool(update_owner_state.get("isBuilding", false))
	var rules_unit_damage := float(update_rules_state.get("unitDamage", 1.0))
	var rules_block_damage := float(update_rules_state.get("blockDamage", 1.0))
	var damage_multiplier := 1.0
	var branch := "fallback"
	if owner_is_unit:
		damage_multiplier = owner_unit_damage_multiplier * rules_unit_damage
		branch = "unit"
	elif owner_is_building:
		damage_multiplier = rules_block_damage
		branch = "building"
	return {
		"bullet": update_bullet_state,
		"owner": update_owner_state,
		"rules": update_rules_state,
		"team": update_bullet_state.get("team", null),
		"ownerIsUnit": owner_is_unit,
		"ownerUnitDamageMultiplier": owner_unit_damage_multiplier,
		"ownerIsBuilding": owner_is_building,
		"rulesUnitDamage": rules_unit_damage,
		"rulesBlockDamage": rules_block_damage,
		"damageMultiplier": damage_multiplier,
		"branch": branch,
		"unitBranchSource": "if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team)",
		"buildingBranchSource": "if(b.owner instanceof Building) return state.rules.blockDamage(b.team)",
		"fallbackSource": "return 1f",
	}

func source_bullet_type_hit_default_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var hit_x := float(update_bullet_state.get("x", 0.0))
	var hit_y := float(update_bullet_state.get("y", 0.0))
	var create_frags := true
	return {
		"bullet": update_bullet_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"hitCall": {
			"call": "hit(b, b.x, b.y, true)",
			"x": hit_x,
			"y": hit_y,
			"createFrags": create_frags,
		},
		"hitDefaultCallSource": "hit(b, b.x, b.y, true)",
		"hitOverloadBoundarySource": "public void hit(Bullet b, float x, float y)",
	}

func source_bullet_type_hit_xy_default_state(bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var create_frags := true
	return {
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"hitCall": {
			"call": "hit(b, x, y, true)",
			"x": hit_x,
			"y": hit_y,
			"createFrags": create_frags,
		},
		"hitXYDefaultCallSource": "hit(b, x, y, true)",
		"hitCreateFragsBoundarySource": "public void hit(Bullet b, float x, float y, boolean createFrags)",
	}

func source_bullet_type_hit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var hit_effect: Variant = update_type_state.get("hitEffect", "Fx.hitBulletSmall")
	var hit_sound: Variant = update_type_state.get("hitSound", "Sounds.none")
	var hit_sound_pitch := float(update_type_state.get("hitSoundPitch", 1.0))
	var hit_sound_pitch_range := float(update_type_state.get("hitSoundPitchRange", 0.1))
	var hit_sound_volume := float(update_type_state.get("hitSoundVolume", 1.0))
	var hit_shake := float(update_type_state.get("hitShake", 0.0))
	var hit_color: Variant = update_type_state.get("hitColor", "Color.white")
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"x": hit_x,
		"y": hit_y,
		"hitEffectCall": {
			"call": "hitEffect.at(x, y, b.rotation(), hitColor)",
			"effect": hit_effect,
			"x": hit_x,
			"y": hit_y,
			"rotation": bullet_rotation,
			"color": hit_color,
		},
		"hitSoundCall": {
			"call": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)",
			"sound": hit_sound,
			"x": hit_x,
			"y": hit_y,
			"pitchBase": hit_sound_pitch,
			"pitchRange": hit_sound_pitch_range,
			"volume": hit_sound_volume,
		},
		"shakeCall": {
			"call": "Effect.shake(hitShake, hitShake, b)",
			"amountX": hit_shake,
			"amountY": hit_shake,
			"bullet": update_bullet_state,
		},
		"hitEffectCallSource": "hitEffect.at(x, y, b.rotation(), hitColor)",
		"hitSoundCallSource": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)",
		"shakeCallSource": "Effect.shake(hitShake, hitShake, b)",
		"fragBranchBoundarySource": "if(createFrags && fragOnHit)",
	}

func source_bullet_type_hit_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_frag_state: Dictionary = hit_frag_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var create_frags := bool(update_hit_frag_state.get("createFrags", false))
	var frag_on_hit := bool(update_type_state.get("fragOnHit", true))
	var delay_frags := bool(update_type_state.get("delayFrags", false))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var frag_bullet_delay_frags := false
	if frag_bullet is Dictionary:
		var frag_bullet_state: Dictionary = frag_bullet
		frag_bullet_delay_frags = bool(frag_bullet_state.get("delayFrags", false))
	var frag_gate_passed := create_frags and frag_on_hit
	var delay_frag_gate_passed := frag_gate_passed and delay_frags and frag_bullet_exists and frag_bullet_delay_frags
	var time_run_call := {}
	var create_frags_call := {}
	if delay_frag_gate_passed:
		time_run_call = {
			"call": "Time.run(0f, () -> createFrags(b, x, y))",
			"delay": 0.0,
			"x": hit_x,
			"y": hit_y,
			"scheduled": true,
		}
	elif frag_gate_passed:
		create_frags_call = {
			"call": "createFrags(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitFrag": update_hit_frag_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"fragOnHit": frag_on_hit,
		"delayFrags": delay_frags,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragBulletDelayFrags": frag_bullet_delay_frags,
		"fragGatePassed": frag_gate_passed,
		"delayFragGatePassed": delay_frag_gate_passed,
		"timeRunCall": time_run_call,
		"createFragsCall": create_frags_call,
		"fragGateSource": "if(createFrags && fragOnHit)",
		"delayGateSource": "if(delayFrags && fragBullet != null && fragBullet.delayFrags)",
		"timeRunCallSource": "Time.run(0f, () -> createFrags(b, x, y))",
		"createFragsCallSource": "createFrags(b, x, y)",
		"postFragBoundarySource": "createPuddles(b, x, y)",
	}

func source_bullet_type_hit_post_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_frag_dispatch_state: Dictionary = hit_frag_dispatch_state.duplicate(true)
	var hit_x := float(update_hit_frag_dispatch_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_frag_dispatch_state.get("y", update_hit_xy_state.get("y", 0.0)))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitFragDispatch": update_hit_frag_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"createPuddlesCall": {
			"call": "createPuddles(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createIncendCall": {
			"call": "createIncend(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createUnitsCall": {
			"call": "createUnits(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createPuddlesCallSource": "createPuddles(b, x, y)",
		"createIncendCallSource": "createIncend(b, x, y)",
		"createUnitsCallSource": "createUnits(b, x, y)",
		"suppressionBoundarySource": "if(suppressionRange > 0)",
	}

func source_bullet_type_create_incend_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_incend_state: Dictionary, incend_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_incend_state: Dictionary = create_incend_state.duplicate(true)
	var update_random_state: Dictionary = incend_random_state.duplicate(true)
	var incend_x := float(update_create_incend_state.get("x", 0.0))
	var incend_y := float(update_create_incend_state.get("y", 0.0))
	var incend_chance := float(update_type_state.get("incendChance", 1.0))
	var incend_spread := float(update_type_state.get("incendSpread", 8.0))
	var incend_amount := int(update_type_state.get("incendAmount", 0))
	var chance_passed: Variant = update_random_state.get("chancePassed", null)
	var incend_gate_passed: bool = incend_chance > 0.0 and chance_passed == true
	var create_incend_call: Dictionary = {"called": false}
	if incend_gate_passed:
		create_incend_call = {
			"call": "Damage.createIncend(x, y, incendSpread, incendAmount)",
			"x": incend_x,
			"y": incend_y,
			"incendSpread": incend_spread,
			"incendAmount": incend_amount,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createIncend": update_create_incend_state,
		"incendRandom": update_random_state,
		"x": incend_x,
		"y": incend_y,
		"incendChance": incend_chance,
		"incendSpread": incend_spread,
		"incendAmount": incend_amount,
		"chancePassed": chance_passed,
		"chancePassedProvided": chance_passed != null,
		"incendGatePassed": incend_gate_passed,
		"createIncendCall": create_incend_call,
		"chanceSource": "Mathf.chance(incendChance)",
		"createIncendSource": "Damage.createIncend(x, y, incendSpread, incendAmount);",
	}

func source_bullet_type_create_units_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_state: Dictionary, create_units_random_state: Dictionary, net_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_units_state: Dictionary = create_units_state.duplicate(true)
	var update_random_state: Dictionary = create_units_random_state.duplicate(true)
	var update_net_state: Dictionary = net_state.duplicate(true)
	var unit_x := float(update_create_units_state.get("x", 0.0))
	var unit_y := float(update_create_units_state.get("y", 0.0))
	var net_client := bool(update_net_state.get("client", false))
	var despawn_unit: Variant = update_type_state.get("despawnUnit", null)
	var despawn_unit_chance := float(update_type_state.get("despawnUnitChance", 1.0))
	var despawn_unit_count := int(update_type_state.get("despawnUnitCount", 1))
	var despawn_unit_radius := float(update_type_state.get("despawnUnitRadius", 0.1))
	var face_outwards := bool(update_type_state.get("faceOutwards", false))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var chance_passed: Variant = update_random_state.get("chancePassed", null)
	var create_units_gate_passed: bool = not net_client and despawn_unit != null and chance_passed == true
	var loop_iterations := despawn_unit_count if create_units_gate_passed else 0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnits": update_create_units_state,
		"createUnitsRandom": update_random_state,
		"net": update_net_state,
		"x": unit_x,
		"y": unit_y,
		"netClient": net_client,
		"despawnUnit": despawn_unit,
		"despawnUnitChance": despawn_unit_chance,
		"despawnUnitCount": despawn_unit_count,
		"despawnUnitRadius": despawn_unit_radius,
		"faceOutwards": face_outwards,
		"bulletTeam": bullet_team,
		"chancePassed": chance_passed,
		"chancePassedProvided": chance_passed != null,
		"createUnitsGatePassed": create_units_gate_passed,
		"loopIterations": loop_iterations,
		"gateSource": "if(!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)){",
		"loopBoundarySource": "for(int i = 0; i < despawnUnitCount; i++){",
		"randomOffsetBoundarySource": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
		"spawnBoundarySource": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
		"rotationBoundarySource": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
		"notifyBoundarySource": "Units.notifyUnitSpawn(u);",
	}

func source_bullet_type_create_units_random_offset_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_initial_state: Dictionary, create_units_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = create_units_initial_state.duplicate(true)
	var update_random_state: Dictionary = create_units_random_state.duplicate(true)
	var length_samples: Array = update_random_state.get("lengthSamples", [])
	var theta_samples: Array = update_random_state.get("thetaSamples", [])
	var unit_offset_plans: Array = []
	var create_units_gate_passed := bool(update_initial_state.get("createUnitsGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var despawn_unit_radius := float(update_type_state.get("despawnUnitRadius", update_initial_state.get("despawnUnitRadius", 0.1)))
	var base_x := float(update_initial_state.get("x", 0.0))
	var base_y := float(update_initial_state.get("y", 0.0))
	if create_units_gate_passed:
		for i in loop_iterations:
			var length_sample: Variant = length_samples[i] if i < length_samples.size() else null
			var theta_sample: Variant = theta_samples[i] if i < theta_samples.size() else null
			var tmp_v1_x: Variant = null
			var tmp_v1_y: Variant = null
			if length_sample != null and theta_sample != null:
				tmp_v1_x = cos(float(theta_sample)) * float(length_sample)
				tmp_v1_y = sin(float(theta_sample)) * float(length_sample)
			unit_offset_plans.append({
				"index": i,
				"baseX": base_x,
				"baseY": base_y,
				"length": length_sample,
				"lengthSampleProvided": length_sample != null,
				"lengthRandomCall": {"call": "Mathf.random(despawnUnitRadius)", "range": despawn_unit_radius, "value": length_sample},
				"theta": theta_sample,
				"thetaSampleProvided": theta_sample != null,
				"thetaRandomCall": {"call": "Mathf.random(0f, Mathf.PI2)", "start": 0.0, "end": SOURCE_ARC_RAD_FULL, "value": theta_sample},
				"tmpV1X": tmp_v1_x,
				"tmpV1Y": tmp_v1_y,
				"call": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius))",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsInitial": update_initial_state,
		"createUnitsRandom": update_random_state,
		"createUnitsGatePassed": create_units_gate_passed,
		"loopIterations": loop_iterations,
		"despawnUnitRadius": despawn_unit_radius,
		"x": base_x,
		"y": base_y,
		"unitOffsetPlans": unit_offset_plans,
		"randomLengthSource": "Mathf.random(despawnUnitRadius)",
		"vec2RndSource": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
		"randomDirectionSource": "float theta = Mathf.random(0f, Mathf.PI2);",
		"spawnBoundarySource": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
	}

func source_bullet_type_create_units_spawn_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_random_offset_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_random_offset_state: Dictionary = create_units_random_offset_state.duplicate(true)
	var unit_offset_plans: Array = update_random_offset_state.get("unitOffsetPlans", [])
	var spawn_calls: Array = []
	var despawn_unit: Variant = update_type_state.get("despawnUnit", update_random_offset_state.get("despawnUnit", null))
	var bullet_team: Variant = update_bullet_state.get("team", update_random_offset_state.get("bulletTeam", null))
	var create_units_gate_passed := bool(update_random_offset_state.get("createUnitsGatePassed", false))
	if create_units_gate_passed:
		for plan in unit_offset_plans:
			var base_x: Variant = plan.get("baseX", update_random_offset_state.get("x", null))
			var base_y: Variant = plan.get("baseY", update_random_offset_state.get("y", null))
			var tmp_v1_x: Variant = plan.get("tmpV1X", null)
			var tmp_v1_y: Variant = plan.get("tmpV1Y", null)
			var spawn_x: Variant = null
			var spawn_y: Variant = null
			if base_x != null and tmp_v1_x != null:
				spawn_x = float(base_x) + float(tmp_v1_x)
			if base_y != null and tmp_v1_y != null:
				spawn_y = float(base_y) + float(tmp_v1_y)
			spawn_calls.append({
				"index": int(plan.get("index", spawn_calls.size())),
				"despawnUnit": despawn_unit,
				"team": bullet_team,
				"x": spawn_x,
				"y": spawn_y,
				"baseX": base_x,
				"baseY": base_y,
				"tmpV1X": tmp_v1_x,
				"tmpV1Y": tmp_v1_y,
				"call": "despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsRandomOffset": update_random_offset_state,
		"createUnitsGatePassed": create_units_gate_passed,
		"despawnUnit": despawn_unit,
		"bulletTeam": bullet_team,
		"unitOffsetPlans": unit_offset_plans,
		"spawnCalls": spawn_calls,
		"spawnSource": "despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)",
		"rotationBoundarySource": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
		"notifyBoundarySource": "Units.notifyUnitSpawn(u);",
	}

func source_bullet_type_create_units_rotation_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_spawn_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_spawn_state: Dictionary = create_units_spawn_state.duplicate(true)
	var spawn_calls: Array = update_spawn_state.get("spawnCalls", [])
	var face_outwards := bool(update_type_state.get("faceOutwards", update_spawn_state.get("faceOutwards", false)))
	var bullet_rotation: Variant = update_bullet_state.get("rotation", null)
	var rotation_assignments: Array = []
	for spawn_call in spawn_calls:
		var tmp_v1_x: Variant = spawn_call.get("tmpV1X", null)
		var tmp_v1_y: Variant = spawn_call.get("tmpV1Y", null)
		var tmp_v1_angle: Variant = null
		if tmp_v1_x != null and tmp_v1_y != null:
			tmp_v1_angle = rad_to_deg(atan2(float(tmp_v1_y), float(tmp_v1_x)))
			if tmp_v1_angle < 0.0:
				tmp_v1_angle = float(tmp_v1_angle) + 360.0
		var unit_rotation: Variant = tmp_v1_angle if face_outwards else bullet_rotation
		rotation_assignments.append({
			"index": int(spawn_call.get("index", rotation_assignments.size())),
			"faceOutwards": face_outwards,
			"bulletRotation": bullet_rotation,
			"tmpV1X": tmp_v1_x,
			"tmpV1Y": tmp_v1_y,
			"tmpV1Angle": tmp_v1_angle,
			"unitRotation": unit_rotation,
			"assignment": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation()",
		})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsSpawn": update_spawn_state,
		"faceOutwards": face_outwards,
		"bulletRotation": bullet_rotation,
		"spawnCalls": spawn_calls,
		"rotationAssignments": rotation_assignments,
		"rotationSource": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
		"vec2AngleSource": "public float angle(){ float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees; if(angle < 0) angle += 360; return angle; }",
		"bulletRotationSource": "return vel.isZero(0.001f) ? rotation : vel.angle();",
		"notifyBoundarySource": "Units.notifyUnitSpawn(u);",
	}

func source_bullet_type_create_units_notify_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_rotation_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_rotation_state: Dictionary = create_units_rotation_state.duplicate(true)
	var rotation_assignments: Array = update_rotation_state.get("rotationAssignments", [])
	var notify_calls: Array = []
	for rotation_assignment in rotation_assignments:
		notify_calls.append({
			"index": int(rotation_assignment.get("index", notify_calls.size())),
			"unitRotation": rotation_assignment.get("unitRotation", null),
			"call": "Units.notifyUnitSpawn(u)",
		})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createUnitsRotation": update_rotation_state,
		"rotationAssignments": rotation_assignments,
		"notifyCalls": notify_calls,
		"notifySource": "Units.notifyUnitSpawn(u);",
	}

func source_bullet_type_despawned_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var despawn_hit := bool(update_type_state.get("despawnHit", false))
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var hit_call := {}
	var create_units_call := {}
	if despawn_hit:
		hit_call = {
			"call": "hit(b, b.x, b.y, false)",
			"x": bullet_x,
			"y": bullet_y,
			"createFrags": false,
			"called": true,
		}
	else:
		create_units_call = {
			"call": "createUnits(b, b.x, b.y)",
			"x": bullet_x,
			"y": bullet_y,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnHit": despawn_hit,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"hitCall": hit_call,
		"createUnitsCall": create_units_call,
		"despawnEffectBoundarySource": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
		"despawnSoundBoundarySource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}

func source_bullet_type_despawned_effect_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_dispatch_state: Dictionary = despawned_dispatch_state.duplicate(true)
	var bullet_x: Variant = update_despawned_dispatch_state.get("bulletX", update_bullet_state.get("x", null))
	var bullet_y: Variant = update_despawned_dispatch_state.get("bulletY", update_bullet_state.get("y", null))
	var despawn_effect: Variant = update_type_state.get("despawnEffect", "Fx.hitBulletSmall")
	var hit_color: Variant = update_type_state.get("hitColor", "Color.white")
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnedDispatch": update_despawned_dispatch_state,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"despawnEffectCall": {
			"call": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor)",
			"effect": despawn_effect,
			"x": bullet_x,
			"y": bullet_y,
			"rotation": bullet_rotation,
			"color": hit_color,
		},
		"despawnEffectCallSource": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
		"despawnSoundBoundarySource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}

func source_bullet_type_despawned_sound_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_effect_state: Dictionary, despawn_sound_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_effect_state: Dictionary = despawned_effect_state.duplicate(true)
	var update_despawn_sound_random_state: Dictionary = despawn_sound_random_state.duplicate(true)
	var despawn_sound: Variant = update_type_state.get("despawnSound", "Sounds.none")
	var hit_sound_pitch_range := float(update_type_state.get("hitSoundPitchRange", 0.1))
	var range_sample: Variant = update_despawn_sound_random_state.get("rangeSample", null)
	var sound_pitch: Variant = null
	if range_sample != null:
		sound_pitch = 1.0 + float(range_sample)
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnedEffect": update_despawned_effect_state,
		"despawnSoundRandom": update_despawn_sound_random_state,
		"despawnSoundCall": {
			"call": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange))",
			"sound": despawn_sound,
			"bullet": update_bullet_state,
			"pitchBase": 1.0,
			"pitchRange": hit_sound_pitch_range,
			"rangeSample": range_sample,
			"pitch": sound_pitch,
		},
		"despawnSoundCallSource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"mathfRangeSource": "public static float range(float range){ return random(-range, range); }",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}

func source_bullet_type_despawned_shake_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_sound_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_sound_state: Dictionary = despawned_sound_state.duplicate(true)
	var despawn_shake := float(update_type_state.get("despawnShake", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnedSound": update_despawned_sound_state,
		"despawnShake": despawn_shake,
		"shakeCall": {
			"call": "Effect.shake(despawnShake, despawnShake, b)",
			"intensity": despawn_shake,
			"duration": despawn_shake,
			"position": update_bullet_state,
		},
		"shakeCallSource": "Effect.shake(despawnShake, despawnShake, b);",
		"effectShakePositionSource": "public static void shake(float intensity, float duration, Position loc){ shake(intensity, duration, loc.getX(), loc.getY()); }",
		"removedBoundarySource": "public void removed(Bullet b){",
	}

func source_bullet_type_removed_trail_fade_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var trail_length := int(update_type_state.get("trailLength", -1))
	var trail_width := float(update_type_state.get("trailWidth", 2.0))
	var trail_color: Variant = update_type_state.get("trailColor", "Pal.missileYellowBack")
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var trail_state: Variant = update_bullet_state.get("trail", null)
	var trail_exists := trail_state != null
	var trail_size: Variant = null
	var trail_copy: Variant = null
	if trail_state is Dictionary:
		trail_size = trail_state.get("size", null)
	var gate_passed := trail_length > 0 and trail_exists and trail_size != null and int(trail_size) > 0
	var trail_fade_call: Variant = null
	if gate_passed:
		if trail_state is Dictionary:
			trail_copy = (trail_state as Dictionary).duplicate(true)
		else:
			trail_copy = trail_state
		trail_fade_call = {
			"call": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy())",
			"x": bullet_x,
			"y": bullet_y,
			"width": trail_width,
			"color": trail_color,
			"trailCopy": trail_copy,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"trailLength": trail_length,
		"trailWidth": trail_width,
		"trailColor": trail_color,
		"trailExists": trail_exists,
		"trailSize": trail_size,
		"gatePassed": gate_passed,
		"trailFadeCall": trail_fade_call,
		"gateSource": "if(trailLength > 0 && b.trail != null && b.trail.size() > 0){",
		"trailFadeCallSource": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy());",
		"trailCopySource": "public Trail copy(){ Trail out = new Trail(length); out.points.addAll(points); return out; }",
		"trailSizeSource": "public int size(){ return points.size/3; }",
		"fragBoundarySource": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
	}

func source_bullet_type_removed_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, removed_trail_fade_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_removed_trail_fade_state: Dictionary = removed_trail_fade_state.duplicate(true)
	var bullet_frags := int(update_bullet_state.get("frags", 0))
	var frag_on_despawn := bool(update_type_state.get("fragOnDespawn", true))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var frag_gate_passed := bullet_frags == 0 and frag_on_despawn and frag_bullet_exists
	var create_frags_call := {}
	if frag_gate_passed:
		create_frags_call = {
			"call": "createFrags(b, b.x, b.y)",
			"x": bullet_x,
			"y": bullet_y,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"removedTrailFade": update_removed_trail_fade_state,
		"bulletFrags": bullet_frags,
		"fragOnDespawn": frag_on_despawn,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragGatePassed": frag_gate_passed,
		"createFragsCall": create_frags_call,
		"fragGateSource": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
		"createFragsCallSource": "createFrags(b, b.x, b.y);",
		"buildingDamageBoundarySource": "public float buildingDamage(Bullet b){",
	}

func source_bullet_type_hit_suppression_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_post_frag_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_post_frag_dispatch_state: Dictionary = hit_post_frag_dispatch_state.duplicate(true)
	var hit_x := float(update_hit_post_frag_dispatch_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_post_frag_dispatch_state.get("y", update_hit_xy_state.get("y", 0.0)))
	var bullet_x := float(update_bullet_state.get("x", 0.0))
	var bullet_y := float(update_bullet_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var suppression_range := float(update_type_state.get("suppressionRange", -1.0))
	var suppression_duration := float(update_type_state.get("suppressionDuration", 60.0 * 8.0))
	var suppression_effect_chance := float(update_type_state.get("suppressionEffectChance", 50.0))
	var suppress_color: Variant = update_type_state.get("suppressColor", "Pal.sapBullet")
	var suppression_gate_passed := suppression_range > 0.0
	var suppression_vector := {"x": bullet_x, "y": bullet_y}
	var apply_suppression_call := {}
	if suppression_gate_passed:
		apply_suppression_call = {
			"call": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)",
			"team": bullet_team,
			"x": bullet_x,
			"y": bullet_y,
			"range": suppression_range,
			"reload": suppression_duration,
			"maxDelay": 0.0,
			"applyParticleChance": suppression_effect_chance,
			"source": suppression_vector,
			"effectColor": suppress_color,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitPostFragDispatch": update_hit_post_frag_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"bulletTeam": bullet_team,
		"suppressionRange": suppression_range,
		"suppressionDuration": suppression_duration,
		"suppressionEffectChance": suppression_effect_chance,
		"suppressColor": suppress_color,
		"suppressionGatePassed": suppression_gate_passed,
		"suppressionVector": suppression_vector,
		"applySuppressionCall": apply_suppression_call,
		"suppressionGateSource": "if(suppressionRange > 0)",
		"pooledVec2CommentSource": "//bullets are pooled, require separate Vec2 instance",
		"applySuppressionCallSource": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)",
		"splashDamageBoundarySource": "createSplashDamage(b, x, y)",
	}

func source_bullet_type_hit_splash_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_suppression_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_suppression_state: Dictionary = hit_suppression_state.duplicate(true)
	var hit_x := float(update_hit_suppression_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_suppression_state.get("y", update_hit_xy_state.get("y", 0.0)))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitSuppression": update_hit_suppression_state,
		"x": hit_x,
		"y": hit_y,
		"createSplashDamageCall": {
			"call": "createSplashDamage(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createSplashDamageCallSource": "createSplashDamage(b, x, y)",
		"createSplashDamageMethodBoundarySource": "public void createSplashDamage(Bullet b, float x, float y)",
		"lightningBoundarySource": "for(int i = 0; i < lightning; i++)",
	}

func source_bullet_type_create_splash_damage_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_splash_damage_dispatch_state: Dictionary, damage_multiplier_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_splash_damage_dispatch_state: Dictionary = hit_splash_damage_dispatch_state.duplicate(true)
	var update_damage_multiplier_state: Dictionary = damage_multiplier_state.duplicate(true)
	var hit_x := float(update_hit_splash_damage_dispatch_state.get("x", 0.0))
	var hit_y := float(update_hit_splash_damage_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var bullet_absorbed := bool(update_bullet_state.get("absorbed", false))
	var splash_damage_radius := float(update_type_state.get("splashDamageRadius", -1.0))
	var splash_damage := float(update_type_state.get("splashDamage", 0.0))
	var damage_multiplier := float(update_damage_multiplier_state.get("damageMultiplier", 1.0))
	var splash_damage_pierce := bool(update_type_state.get("splashDamagePierce", false))
	var collides_air := bool(update_type_state.get("collidesAir", true))
	var collides_ground := bool(update_type_state.get("collidesGround", true))
	var scaled_splash_damage := bool(update_type_state.get("scaledSplashDamage", false))
	var armor_multiplier := float(update_type_state.get("armorMultiplier", 1.0))
	var splash_damage_gate_passed := splash_damage_radius > 0.0 and not bullet_absorbed
	var damage_amount := splash_damage * damage_multiplier
	var damage_call := {}
	if splash_damage_gate_passed:
		damage_call = {
			"call": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"damage": damage_amount,
			"complete": splash_damage_pierce,
			"air": collides_air,
			"ground": collides_ground,
			"scaled": scaled_splash_damage,
			"source": update_bullet_state,
			"armorMult": armor_multiplier,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitSplashDamageDispatch": update_hit_splash_damage_dispatch_state,
		"damageMultiplierState": update_damage_multiplier_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"bulletAbsorbed": bullet_absorbed,
		"splashDamageRadius": splash_damage_radius,
		"splashDamage": splash_damage,
		"damageMultiplier": damage_multiplier,
		"damageAmount": damage_amount,
		"splashDamagePierce": splash_damage_pierce,
		"collidesAir": collides_air,
		"collidesGround": collides_ground,
		"scaledSplashDamage": scaled_splash_damage,
		"armorMultiplier": armor_multiplier,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"damageCall": damage_call,
		"splashDamageGateSource": "if(splashDamageRadius > 0 && !b.absorbed)",
		"damageCallSource": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)",
		"statusBoundarySource": "if(status != StatusEffects.none)",
	}

func source_bullet_type_create_splash_damage_status_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_damage_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_damage_dispatch_state: Dictionary = create_splash_damage_damage_dispatch_state.duplicate(true)
	var hit_x := float(update_damage_dispatch_state.get("x", 0.0))
	var hit_y := float(update_damage_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_damage_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var status := str(update_type_state.get("status", "none"))
	var status_duration := float(update_type_state.get("statusDuration", 60.0 * 8.0))
	var collides_air := bool(update_damage_dispatch_state.get("collidesAir", update_type_state.get("collidesAir", true)))
	var collides_ground := bool(update_damage_dispatch_state.get("collidesGround", update_type_state.get("collidesGround", true)))
	var splash_damage_gate_passed := bool(update_damage_dispatch_state.get("splashDamageGatePassed", false))
	var status_gate_passed := splash_damage_gate_passed and status != "none"
	var status_call := {}
	if status_gate_passed:
		status_call = {
			"call": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"effect": status,
			"duration": status_duration,
			"air": collides_air,
			"ground": collides_ground,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createSplashDamageDamageDispatch": update_damage_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"splashDamageRadius": splash_damage_radius,
		"status": status,
		"statusDuration": status_duration,
		"collidesAir": collides_air,
		"collidesGround": collides_ground,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"statusGatePassed": status_gate_passed,
		"statusCall": status_call,
		"statusGateSource": "if(status != StatusEffects.none)",
		"statusCallSource": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)",
		"healsBoundarySource": "if(heals())",
	}

func source_bullet_type_create_splash_damage_heal_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_status_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_status_dispatch_state: Dictionary = create_splash_damage_status_dispatch_state.duplicate(true)
	var update_nearby_blocks_state: Dictionary = nearby_blocks_state.duplicate(true)
	var hit_x := float(update_status_dispatch_state.get("x", 0.0))
	var hit_y := float(update_status_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_status_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var splash_damage_gate_passed := bool(update_status_dispatch_state.get("splashDamageGatePassed", false))
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heal_color: Variant = update_type_state.get("healColor", "Pal.heal")
	var heal_effect: Variant = update_type_state.get("healEffect", "Fx.healBlockFull")
	var heals := heal_percent > 0.0 or heal_amount > 0.0
	var heal_gate_passed := splash_damage_gate_passed and heals
	var nearby_blocks: Array = update_nearby_blocks_state.get("blocks", [])
	var each_block_call := {}
	var heal_applications: Array = []
	if heal_gate_passed:
		each_block_call = {
			"call": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"predicate": "Building::damaged",
			"called": true,
		}
		for raw_block in nearby_blocks:
			if not raw_block is Dictionary:
				continue
			var other: Dictionary = raw_block.duplicate(true)
			if not bool(other.get("damaged", false)):
				continue
			var other_x := float(other.get("x", 0.0))
			var other_y := float(other.get("y", 0.0))
			var other_block: Variant = other.get("block", null)
			var other_max_health := float(other.get("maxHealth", 0.0))
			var heal_applied_amount := heal_percent / 100.0 * other_max_health + heal_amount
			heal_applications.append({
				"other": other,
				"healAppliedAmount": heal_applied_amount,
				"healEffectCall": {
					"call": "healEffect.at(other.x, other.y, 0f, healColor, other.block)",
					"effect": heal_effect,
					"x": other_x,
					"y": other_y,
					"rotation": 0.0,
					"color": heal_color,
					"block": other_block,
				},
				"otherHealCall": {
					"call": "other.heal(healPercent / 100f * other.maxHealth() + healAmount)",
					"amount": heal_applied_amount,
				},
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createSplashDamageStatusDispatch": update_status_dispatch_state,
		"nearbyBlocks": update_nearby_blocks_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"splashDamageRadius": splash_damage_radius,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"healPercent": heal_percent,
		"healAmount": heal_amount,
		"healColor": heal_color,
		"healEffect": heal_effect,
		"heals": heals,
		"healGatePassed": heal_gate_passed,
		"eachBlockCall": each_block_call,
		"healApplications": heal_applications,
		"healsGateSource": "if(heals())",
		"eachBlockCallSource": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})",
		"healEffectCallSource": "healEffect.at(other.x, other.y, 0f, healColor, other.block)",
		"otherHealCallSource": "other.heal(healPercent / 100f * other.maxHealth() + healAmount)",
		"makeFireBoundarySource": "if(makeFire)",
	}

func source_bullet_type_create_splash_damage_make_fire_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_heal_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_heal_dispatch_state: Dictionary = create_splash_damage_heal_dispatch_state.duplicate(true)
	var update_nearby_blocks_state: Dictionary = nearby_blocks_state.duplicate(true)
	var hit_x := float(update_heal_dispatch_state.get("x", 0.0))
	var hit_y := float(update_heal_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_heal_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var splash_damage_gate_passed := bool(update_heal_dispatch_state.get("splashDamageGatePassed", false))
	var make_fire := bool(update_type_state.get("makeFire", false))
	var make_fire_gate_passed := splash_damage_gate_passed and make_fire
	var nearby_blocks: Array = update_nearby_blocks_state.get("blocks", [])
	var each_block_call := {}
	var fire_applications: Array = []
	if make_fire_gate_passed:
		each_block_call = {
			"call": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))",
			"team": null,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"predicate": "other.team != b.team",
			"called": true,
		}
		for raw_block in nearby_blocks:
			if not raw_block is Dictionary:
				continue
			var other: Dictionary = raw_block.duplicate(true)
			if other.get("team", null) == bullet_team:
				continue
			var other_tile: Variant = other.get("tile", null)
			fire_applications.append({
				"other": other,
				"firesCreateCall": {
					"call": "Fires.create(other.tile)",
					"tile": other_tile,
				},
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createSplashDamageHealDispatch": update_heal_dispatch_state,
		"nearbyBlocks": update_nearby_blocks_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"splashDamageRadius": splash_damage_radius,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"makeFire": make_fire,
		"makeFireGatePassed": make_fire_gate_passed,
		"eachBlockCall": each_block_call,
		"fireApplications": fire_applications,
		"makeFireGateSource": "if(makeFire)",
		"eachBlockCallSource": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))",
		"firesCreateCallSource": "Fires.create(other.tile)",
		"createFragsBoundarySource": "public void createFrags(Bullet b, float x, float y){",
	}

func source_bullet_type_create_frags_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_frags_state: Dictionary = create_frags_state.duplicate(true)
	var frag_x := float(update_create_frags_state.get("x", 0.0))
	var frag_y := float(update_create_frags_state.get("y", 0.0))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var frag_on_absorb := bool(update_type_state.get("fragOnAbsorb", true))
	var bullet_absorbed := bool(update_bullet_state.get("absorbed", false))
	var pierce_frag_cap := int(update_type_state.get("pierceFragCap", -1))
	var bullet_frags := int(update_bullet_state.get("frags", 0))
	var frag_bullets := int(update_type_state.get("fragBullets", 9))
	var frag_gate_passed := frag_bullet_exists and (frag_on_absorb or not bullet_absorbed) and (pierce_frag_cap < 0 or bullet_frags < pierce_frag_cap)
	var loop_iterations := frag_bullets if frag_gate_passed else 0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFrags": update_create_frags_state,
		"x": frag_x,
		"y": frag_y,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragOnAbsorb": frag_on_absorb,
		"bulletAbsorbed": bullet_absorbed,
		"pierceFragCap": pierce_frag_cap,
		"bulletFrags": bullet_frags,
		"fragBullets": frag_bullets,
		"fragGatePassed": frag_gate_passed,
		"loopIterations": loop_iterations,
		"fragGateSource": "if(fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap))",
		"loopBoundarySource": "for(int i = 0; i < fragBullets; i++){",
		"randomLenBoundarySource": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
	}

func source_bullet_type_create_frags_random_geometry_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_initial_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = create_frags_initial_state.duplicate(true)
	var update_random_state: Dictionary = frag_random_state.duplicate(true)
	var len_samples: Array = update_random_state.get("lenSamples", [])
	var range_samples: Array = update_random_state.get("rangeSamples", [])
	var fragment_plans: Array = []
	var frag_gate_passed := bool(update_initial_state.get("fragGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var frag_bullets := int(update_type_state.get("fragBullets", update_initial_state.get("fragBullets", 9)))
	var frag_offset_min := float(update_type_state.get("fragOffsetMin", 1.0))
	var frag_offset_max := float(update_type_state.get("fragOffsetMax", 7.0))
	var frag_random_spread := float(update_type_state.get("fragRandomSpread", 360.0))
	var frag_angle := float(update_type_state.get("fragAngle", 0.0))
	var frag_spread := float(update_type_state.get("fragSpread", 0.0))
	var rotation_value := float(update_bullet_state.get("rotation", 0.0))
	var x_value := float(update_initial_state.get("x", 0.0))
	var y_value := float(update_initial_state.get("y", 0.0))
	if frag_gate_passed:
		for i in loop_iterations:
			var len_sample: Variant = len_samples[i] if i < len_samples.size() else null
			var range_sample: Variant = range_samples[i] if i < range_samples.size() else null
			var angle_value: Variant = null
			if range_sample != null:
				angle_value = rotation_value + float(range_sample) + frag_angle + frag_spread * float(i) - (float(frag_bullets) - 1.0) * frag_spread / 2.0
			fragment_plans.append({
				"index": i,
				"x": x_value,
				"y": y_value,
				"len": len_sample,
				"lenSampleProvided": len_sample != null,
				"lenRandomCall": {"call": "Mathf.random(fragOffsetMin, fragOffsetMax)", "min": frag_offset_min, "max": frag_offset_max, "value": len_sample},
				"rangeSample": range_sample,
				"rangeSampleProvided": range_sample != null,
				"angleRandomCall": {"call": "Mathf.range(fragRandomSpread / 2)", "range": frag_random_spread / 2.0, "value": range_sample},
				"angle": angle_value,
				"rotation": rotation_value,
				"fragAngle": frag_angle,
				"spreadOffset": frag_spread * float(i) - (float(frag_bullets) - 1.0) * frag_spread / 2.0,
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFragsInitial": update_initial_state,
		"fragRandom": update_random_state,
		"fragGatePassed": frag_gate_passed,
		"loopIterations": loop_iterations,
		"fragOffsetMin": frag_offset_min,
		"fragOffsetMax": frag_offset_max,
		"fragRandomSpread": frag_random_spread,
		"fragAngle": frag_angle,
		"fragSpread": frag_spread,
		"rotation": rotation_value,
		"fragmentPlans": fragment_plans,
		"randomLenSource": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
		"angleFormulaSource": "float a = b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f;",
		"createCallBoundarySource": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
	}

func source_bullet_type_create_frags_create_call_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_geometry_state: Dictionary = create_frags_random_geometry_state.duplicate(true)
	var update_random_state: Dictionary = frag_random_state.duplicate(true)
	var velocity_samples: Array = update_random_state.get("velocitySamples", [])
	var life_samples: Array = update_random_state.get("lifeSamples", [])
	var fragment_plans: Array = update_geometry_state.get("fragmentPlans", [])
	var fragment_create_calls: Array = []
	var frag_gate_passed := bool(update_geometry_state.get("fragGatePassed", false))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_velocity_min := float(update_type_state.get("fragVelocityMin", 0.2))
	var frag_velocity_max := float(update_type_state.get("fragVelocityMax", 1.0))
	var frag_life_min := float(update_type_state.get("fragLifeMin", 1.0))
	var frag_life_max := float(update_type_state.get("fragLifeMax", 1.0))
	if frag_gate_passed:
		for fragment_plan in fragment_plans:
			var plan: Dictionary = fragment_plan
			var index := int(plan.get("index", fragment_create_calls.size()))
			var len_sample: Variant = plan.get("len", null)
			var angle_value: Variant = plan.get("angle", null)
			var base_x := float(plan.get("x", 0.0))
			var base_y := float(plan.get("y", 0.0))
			var velocity_sample: Variant = velocity_samples[index] if index < velocity_samples.size() else null
			var life_sample: Variant = life_samples[index] if index < life_samples.size() else null
			var frag_x: Variant = null
			var frag_y: Variant = null
			var trns_x: Variant = null
			var trns_y: Variant = null
			if len_sample != null and angle_value != null:
				var len_value := float(len_sample)
				var offset := source_arc_angles_trns_vec(angle_value, len_value, 0.0)
				trns_x = offset.get("x", null)
				trns_y = offset.get("y", null)
				frag_x = base_x + float(trns_x)
				frag_y = base_y + float(trns_y)
			fragment_create_calls.append({
				"index": index,
				"fragBullet": frag_bullet,
				"ownerBullet": update_bullet_state,
				"baseX": base_x,
				"baseY": base_y,
				"len": len_sample,
				"angle": angle_value,
				"trnsx": trns_x,
				"trnsy": trns_y,
				"x": frag_x,
				"y": frag_y,
				"velocity": velocity_sample,
				"velocitySampleProvided": velocity_sample != null,
				"velocityRandomCall": {"call": "Mathf.random(fragVelocityMin, fragVelocityMax)", "min": frag_velocity_min, "max": frag_velocity_max, "value": velocity_sample},
				"life": life_sample,
				"lifeSampleProvided": life_sample != null,
				"lifeRandomCall": {"call": "Mathf.random(fragLifeMin, fragLifeMax)", "min": frag_life_min, "max": frag_life_max, "value": life_sample},
				"call": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFragsRandomGeometry": update_geometry_state,
		"fragRandom": update_random_state,
		"fragGatePassed": frag_gate_passed,
		"fragBullet": frag_bullet,
		"fragVelocityMin": frag_velocity_min,
		"fragVelocityMax": frag_velocity_max,
		"fragLifeMin": frag_life_min,
		"fragLifeMax": frag_life_max,
		"fragmentCreateCalls": fragment_create_calls,
		"trnsxSource": "Angles.trnsx(a, len)",
		"trnsySource": "Angles.trnsy(a, len)",
		"velocityRandomSource": "Mathf.random(fragVelocityMin, fragVelocityMax)",
		"lifeRandomSource": "Mathf.random(fragLifeMin, fragLifeMax)",
		"createCallSource": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
		"fragsIncrementBoundarySource": "b.frags++;",
	}

func source_bullet_type_create_frags_increment_state(bullet_state: Dictionary, create_frags_create_call_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_call_state: Dictionary = create_frags_create_call_state.duplicate(true)
	var frag_gate_passed := bool(update_create_call_state.get("fragGatePassed", false))
	var bullet_frags_before := int(update_bullet_state.get("frags", 0))
	var bullet_frags_after := bullet_frags_before
	var frags_incremented := frag_gate_passed
	if frags_incremented:
		bullet_frags_after = bullet_frags_before + 1
	update_bullet_state["frags"] = bullet_frags_after
	return {
		"bullet": update_bullet_state,
		"createFragsCreateCall": update_create_call_state,
		"fragGatePassed": frag_gate_passed,
		"bulletFragsBefore": bullet_frags_before,
		"bulletFragsAfter": bullet_frags_after,
		"fragsIncremented": frags_incremented,
		"fragsIncrementSource": "b.frags++;",
	}

func source_bullet_type_create_puddles_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_puddles_state: Dictionary = create_puddles_state.duplicate(true)
	var puddle_x := float(update_create_puddles_state.get("x", 0.0))
	var puddle_y := float(update_create_puddles_state.get("y", 0.0))
	var puddle_liquid: Variant = update_type_state.get("puddleLiquid", "water")
	var puddles := int(update_type_state.get("puddles", 0))
	var puddle_range := float(update_type_state.get("puddleRange", 0.0))
	var puddle_amount := float(update_type_state.get("puddleAmount", 5.0))
	var puddle_gate_passed := puddle_liquid != null and puddles > 0
	var loop_iterations := puddles if puddle_gate_passed else 0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createPuddles": update_create_puddles_state,
		"x": puddle_x,
		"y": puddle_y,
		"puddleLiquid": puddle_liquid,
		"puddles": puddles,
		"puddleRange": puddle_range,
		"puddleAmount": puddle_amount,
		"puddleGatePassed": puddle_gate_passed,
		"loopIterations": loop_iterations,
		"puddleGateSource": "if(puddleLiquid != null && puddles > 0){",
		"loopBoundarySource": "for(int i = 0; i < puddles; i++){",
		"tileBoundarySource": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
		"depositBoundarySource": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
	}

func source_bullet_type_create_puddles_tile_world_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_initial_state: Dictionary, puddle_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = create_puddles_initial_state.duplicate(true)
	var update_random_state: Dictionary = puddle_random_state.duplicate(true)
	var x_range_samples: Array = update_random_state.get("xRangeSamples", [])
	var y_range_samples: Array = update_random_state.get("yRangeSamples", [])
	var tile_world_calls: Array = []
	var puddle_gate_passed := bool(update_initial_state.get("puddleGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var puddle_range := float(update_type_state.get("puddleRange", update_initial_state.get("puddleRange", 0.0)))
	var base_x := float(update_initial_state.get("x", 0.0))
	var base_y := float(update_initial_state.get("y", 0.0))
	if puddle_gate_passed:
		for i in loop_iterations:
			var x_range_sample: Variant = x_range_samples[i] if i < x_range_samples.size() else null
			var y_range_sample: Variant = y_range_samples[i] if i < y_range_samples.size() else null
			var tile_x: Variant = null
			var tile_y: Variant = null
			if x_range_sample != null:
				tile_x = base_x + float(x_range_sample)
			if y_range_sample != null:
				tile_y = base_y + float(y_range_sample)
			tile_world_calls.append({
				"index": i,
				"baseX": base_x,
				"baseY": base_y,
				"xRangeSample": x_range_sample,
				"xRangeSampleProvided": x_range_sample != null,
				"xRangeCall": {"call": "Mathf.range(puddleRange)", "range": puddle_range, "value": x_range_sample},
				"yRangeSample": y_range_sample,
				"yRangeSampleProvided": y_range_sample != null,
				"yRangeCall": {"call": "Mathf.range(puddleRange)", "range": puddle_range, "value": y_range_sample},
				"tileWorldX": tile_x,
				"tileWorldY": tile_y,
				"call": "world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange))",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createPuddlesInitial": update_initial_state,
		"puddleRandom": update_random_state,
		"puddleGatePassed": puddle_gate_passed,
		"loopIterations": loop_iterations,
		"puddleRange": puddle_range,
		"x": base_x,
		"y": base_y,
		"tileWorldCalls": tile_world_calls,
		"xRangeSource": "Mathf.range(puddleRange)",
		"yRangeSource": "Mathf.range(puddleRange)",
		"tileWorldSource": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
		"depositBoundarySource": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
	}

func source_bullet_type_create_puddles_deposit_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_tile_world_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_tile_world_state: Dictionary = create_puddles_tile_world_state.duplicate(true)
	var tile_world_calls: Array = update_tile_world_state.get("tileWorldCalls", [])
	var deposit_calls: Array = []
	var puddle_gate_passed := bool(update_tile_world_state.get("puddleGatePassed", false))
	var puddle_liquid: Variant = update_type_state.get("puddleLiquid", update_tile_world_state.get("puddleLiquid", "water"))
	var puddle_amount := float(update_type_state.get("puddleAmount", update_tile_world_state.get("puddleAmount", 5.0)))
	if puddle_gate_passed:
		for tile_call in tile_world_calls:
			var tile_world_call: Dictionary = tile_call
			deposit_calls.append({
				"index": int(tile_world_call.get("index", deposit_calls.size())),
				"tile": tile_world_call,
				"puddleLiquid": puddle_liquid,
				"puddleAmount": puddle_amount,
				"call": "Puddles.deposit(tile, puddleLiquid, puddleAmount)",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createPuddlesTileWorld": update_tile_world_state,
		"puddleGatePassed": puddle_gate_passed,
		"puddleLiquid": puddle_liquid,
		"puddleAmount": puddle_amount,
		"tileWorldCalls": tile_world_calls,
		"depositCalls": deposit_calls,
		"depositSource": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
	}

func source_bullet_type_hit_entity_damage_cap_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var entity_is_unit := bool(update_entity_state.get("isUnit", false))
	var entity_unit_dead := bool(update_entity_state.get("unitDead", false))
	var was_dead: bool = entity_is_unit and entity_unit_dead
	var entity_is_healthc := bool(update_entity_state.get("isHealthc", false))
	var healthc_gate_passed := entity_is_healthc
	var damage := float(update_bullet_state.get("damage", 0.0))
	var entity_is_shieldc := bool(update_entity_state.get("isShieldc", false))
	var entity_shield := float(update_entity_state.get("shield", 0.0))
	var shield := 0.0
	var max_damage_fraction := float(update_type_state.get("maxDamageFraction", 0.0))
	var entity_max_health := float(update_entity_state.get("maxHealth", 0.0))
	var health := float(update_hit_entity_state.get("health", 0.0))
	var cap := 0.0
	var max_damage_fraction_gate_passed := healthc_gate_passed and max_damage_fraction > 0.0
	if healthc_gate_passed:
		shield = maxf(entity_shield, 0.0) if entity_is_shieldc else 0.0
		cap = entity_max_health * max_damage_fraction + shield
		if max_damage_fraction_gate_passed:
			damage = minf(damage, cap)
			health = minf(health, cap)
		else:
			health += shield
	update_hit_entity_state["health"] = health
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"wasDead": was_dead,
		"healthcGatePassed": healthc_gate_passed,
		"damage": damage,
		"shield": shield,
		"maxDamageFraction": max_damage_fraction,
		"maxDamageFractionGatePassed": max_damage_fraction_gate_passed,
		"cap": cap,
		"effectiveHealth": health,
		"lifestealDeferred": true,
		"armorDamageDeferred": true,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"wasDeadSource": "boolean wasDead = entity instanceof Unit u && u.dead",
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"damageSource": "float damage = b.damage",
		"shieldSource": "float shield = entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f",
		"maxDamageFractionGateSource": "if(maxDamageFraction > 0)",
		"capSource": "float cap = h.maxHealth() * maxDamageFraction + shield",
		"damageCapSource": "damage = Math.min(damage, cap)",
		"healthCapCommentSource": "//cap health to effective health for handlePierce to handle it properly",
		"healthCapSource": "health = Math.min(health, cap)",
		"healthShieldSource": "health += shield",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
	}

func source_bullet_type_hit_entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_owner_health_state: Dictionary = owner_health_state.duplicate(true)
	var healthc_gate_passed := bool(update_damage_cap_state.get("healthcGatePassed", false))
	var lifesteal := float(update_type_state.get("lifesteal", 0.0))
	var owner_is_healthc := bool(update_owner_health_state.get("isHealthc", false))
	var lifesteal_gate_passed := healthc_gate_passed and lifesteal > 0.0 and owner_is_healthc
	var entity_health := float(update_entity_state.get("health", 0.0))
	var damage := float(update_damage_cap_state.get("damage", update_bullet_state.get("damage", 0.0)))
	var lifesteal_result := 0.0
	if lifesteal_gate_passed:
		lifesteal_result = maxf(minf(entity_health, damage), 0.0)
	var owner_heal_amount := lifesteal_result * lifesteal if lifesteal_gate_passed else 0.0
	var owner_heal_call: Variant = null
	if lifesteal_gate_passed:
		owner_heal_call = {
			"call": "o.heal(result * lifesteal)",
			"amount": owner_heal_amount,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"damageCap": update_damage_cap_state,
		"ownerHealth": update_owner_health_state,
		"healthcGatePassed": healthc_gate_passed,
		"lifesteal": lifesteal,
		"ownerIsHealthc": owner_is_healthc,
		"lifestealGatePassed": lifesteal_gate_passed,
		"entityHealth": entity_health,
		"damage": damage,
		"lifestealResult": lifesteal_result,
		"ownerHealCalled": lifesteal_gate_passed,
		"ownerHealAmount": owner_heal_amount,
		"ownerHealCall": owner_heal_call,
		"armorDamageDeferred": true,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"lifestealResultSource": "float result = Math.max(Math.min(h.health(), damage), 0)",
		"ownerHealSource": "o.heal(result * lifesteal)",
		"pierceArmorBoundarySource": "if(pierceArmor)",
	}

func source_bullet_type_hit_entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_lifesteal_state: Dictionary = lifesteal_state.duplicate(true)
	var healthc_gate_passed := bool(update_damage_cap_state.get("healthcGatePassed", false))
	var damage := float(update_damage_cap_state.get("damage", update_bullet_state.get("damage", 0.0)))
	var pierce_armor := bool(update_type_state.get("pierceArmor", false))
	var armor_multiplier := float(update_type_state.get("armorMultiplier", 1.0))
	var pierce_armor_gate_passed := healthc_gate_passed and pierce_armor
	var armor_multiplier_gate_passed := healthc_gate_passed and not pierce_armor and armor_multiplier != 1.0
	var damage_gate_passed := healthc_gate_passed and not pierce_armor and armor_multiplier == 1.0
	var health_damage_call: Variant = null
	if pierce_armor_gate_passed:
		health_damage_call = {
			"call": "h.damagePierce(damage)",
			"damage": damage,
		}
	elif armor_multiplier_gate_passed:
		health_damage_call = {
			"call": "h.damageArmorMult(damage, armorMultiplier)",
			"damage": damage,
			"armorMultiplier": armor_multiplier,
		}
	elif damage_gate_passed:
		health_damage_call = {
			"call": "h.damage(damage)",
			"damage": damage,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"damageCap": update_damage_cap_state,
		"lifesteal": update_lifesteal_state,
		"healthcGatePassed": healthc_gate_passed,
		"damage": damage,
		"pierceArmor": pierce_armor,
		"armorMultiplier": armor_multiplier,
		"pierceArmorGatePassed": pierce_armor_gate_passed,
		"armorMultiplierGatePassed": armor_multiplier_gate_passed,
		"damageGatePassed": damage_gate_passed,
		"damagePierceCalled": pierce_armor_gate_passed,
		"damageArmorMultCalled": armor_multiplier_gate_passed,
		"damageCalled": damage_gate_passed,
		"healthDamageCall": health_damage_call,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"damageLocalSource": "float damage = b.damage",
		"pierceArmorSource": "if(pierceArmor)",
		"damagePierceSource": "h.damagePierce(damage)",
		"armorMultiplierSource": "}else if(armorMultiplier != 1)",
		"damageArmorMultSource": "h.damageArmorMult(damage, armorMultiplier)",
		"damageSource": "}else{ h.damage(damage); }",
		"unitBoundarySource": "if(entity instanceof Unit unit)",
	}

func source_bullet_type_hit_entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_armor_damage_state: Dictionary = armor_damage_state.duplicate(true)
	var unit_gate_passed := bool(update_entity_state.get("isUnit", false))
	var knockback := float(update_type_state.get("knockback", 0.0))
	var impact := bool(update_type_state.get("impact", false))
	var status = update_type_state.get("status", null)
	var status_duration := float(update_type_state.get("statusDuration", 480.0))
	var entity_x := float(update_entity_state.get("x", 0.0))
	var entity_y := float(update_entity_state.get("y", 0.0))
	var bullet_x := float(update_bullet_state.get("x", 0.0))
	var bullet_y := float(update_bullet_state.get("y", 0.0))
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	var impulse_vector := Vector2.ZERO
	if unit_gate_passed:
		var base_vector := Vector2(entity_x - bullet_x, entity_y - bullet_y)
		if base_vector != Vector2.ZERO:
			impulse_vector = base_vector.normalized() * (knockback * 80.0)
	if unit_gate_passed and impact:
		var impulse_length := impulse_vector.length()
		var impact_angle := bullet_rotation + (180.0 if knockback < 0.0 else 0.0)
		impulse_vector = Vector2.RIGHT.rotated(deg_to_rad(impact_angle)) * impulse_length
	var impulse_call: Variant = null
	var status_apply_call: Variant = null
	var bullet_damage_event_call: Variant = null
	if unit_gate_passed:
		impulse_call = {
			"call": "unit.impulse(Tmp.v3)",
			"vector": {"x": impulse_vector.x, "y": impulse_vector.y},
		}
		status_apply_call = {
			"call": "unit.apply(status, statusDuration)",
			"status": status,
			"duration": status_duration,
		}
		bullet_damage_event_call = {
			"call": "Events.fire(bulletDamageEvent.set(unit, b))",
			"unit": update_entity_state,
			"bullet": update_bullet_state,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"armorDamage": update_armor_damage_state,
		"unitGatePassed": unit_gate_passed,
		"knockback": knockback,
		"impact": impact,
		"status": status,
		"statusDuration": status_duration,
		"entityX": entity_x,
		"entityY": entity_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"bulletRotation": bullet_rotation,
		"impulseVector": {"x": impulse_vector.x, "y": impulse_vector.y},
		"impulseCalled": unit_gate_passed,
		"impulseCall": impulse_call,
		"statusApplyCalled": unit_gate_passed,
		"statusApplyCall": status_apply_call,
		"bulletDamageEventFired": unit_gate_passed,
		"bulletDamageEventCall": bullet_damage_event_call,
		"destroyEventDeferred": true,
		"pierceDeferred": true,
		"unitGateSource": "if(entity instanceof Unit unit)",
		"impulseVectorSource": "Tmp.v3.set(unit).sub(b).nor().scl(knockback * 80f)",
		"impactAngleSource": "if(impact) Tmp.v3.setAngle(b.rotation() + (knockback < 0 ? 180f : 0f))",
		"unitImpulseSource": "unit.impulse(Tmp.v3)",
		"unitApplySource": "unit.apply(status, statusDuration)",
		"bulletDamageEventSource": "Events.fire(bulletDamageEvent.set(unit, b))",
		"destroyEventBoundarySource": "if(!wasDead && entity instanceof Unit unit && unit.dead)",
	}

func source_bullet_type_hit_entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_unit_effects_state: Dictionary = unit_effects_state.duplicate(true)
	var was_dead := bool(update_damage_cap_state.get("wasDead", false))
	var unit_gate_passed := bool(update_entity_state.get("isUnit", false))
	var unit_dead := bool(update_entity_state.get("unitDead", false))
	var destroy_event_gate_passed := (not was_dead) and unit_gate_passed and unit_dead
	var unit_destroy_event_call: Variant = null
	if destroy_event_gate_passed:
		unit_destroy_event_call = {
			"call": "Events.fire(new UnitBulletDestroyEvent(unit, b))",
			"unit": update_entity_state,
			"bullet": update_bullet_state,
		}
	return {
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"damageCap": update_damage_cap_state,
		"unitEffects": update_unit_effects_state,
		"wasDead": was_dead,
		"unitGatePassed": unit_gate_passed,
		"unitDead": unit_dead,
		"destroyEventGatePassed": destroy_event_gate_passed,
		"unitDestroyEventFired": destroy_event_gate_passed,
		"unitDestroyEventCall": unit_destroy_event_call,
		"pierceDeferred": true,
		"wasDeadSource": "boolean wasDead = entity instanceof Unit u && u.dead",
		"destroyEventGateSource": "if(!wasDead && entity instanceof Unit unit && unit.dead)",
		"unitDestroyEventSource": "Events.fire(new UnitBulletDestroyEvent(unit, b))",
		"handlePierceBoundarySource": "handlePierce(b, health, entity.x(), entity.y())",
	}

func source_bullet_type_hit_entity_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_unit_destroy_event_state: Dictionary = unit_destroy_event_state.duplicate(true)
	var effective_health := float(update_damage_cap_state.get("effectiveHealth", 0.0))
	var entity_x := float(update_entity_state.get("x", 0.0))
	var entity_y := float(update_entity_state.get("y", 0.0))
	var pierce_state := {"initialHealth": effective_health, "x": entity_x, "y": entity_y}
	var handle_pierce_state := source_bullet_type_handle_pierce_state(update_type_state, update_bullet_state, pierce_state)
	var handle_pierce_call := {
		"call": "handlePierce(b, health, entity.x(), entity.y())",
		"initialHealth": effective_health,
		"x": entity_x,
		"y": entity_y,
	}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"damageCap": update_damage_cap_state,
		"unitDestroyEvent": update_unit_destroy_event_state,
		"pierce": pierce_state,
		"handlePierce": handle_pierce_state,
		"bulletAfterPierce": handle_pierce_state.get("bullet", update_bullet_state),
		"effectiveHealth": effective_health,
		"entityX": entity_x,
		"entityY": entity_y,
		"handlePierceCalled": true,
		"handlePierceCall": handle_pierce_call,
		"damage": float(handle_pierce_state.get("damage", update_bullet_state.get("damage", 0.0))),
		"removeCalled": bool(handle_pierce_state.get("removeCalled", false)),
		"handlePierceCallSource": "handlePierce(b, health, entity.x(), entity.y())",
		"handlePierceMethodSource": "public void handlePierce(Bullet b, float initialHealth, float x, float y)",
	}

func source_bullet_type_building_damage_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var damage := float(update_bullet_state.get("damage", 0.0))
	var building_damage_multiplier := float(update_bullet_state.get("buildingDamageMultiplier", 1.0))
	var building_damage := damage * building_damage_multiplier
	return {
		"bullet": update_bullet_state,
		"damage": damage,
		"buildingDamageMultiplier": building_damage_multiplier,
		"buildingDamage": building_damage,
		"buildingDamageReturnSource": "return b.damage() * b.buildingDamageMultiplier",
		"shieldDamageBoundarySource": "public float shieldDamage(Bullet b){",
	}

func source_bullet_type_shield_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var damage := float(update_bullet_state.get("damage", 0.0))
	var shield_damage_multiplier := float(update_type_state.get("shieldDamageMultiplier", 1.0))
	var shield_damage := damage * shield_damage_multiplier
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"damage": damage,
		"shieldDamageMultiplier": shield_damage_multiplier,
		"shieldDamage": shield_damage,
		"shieldDamageReturnSource": "return b.damage() * shieldDamageMultiplier",
		"drawBoundarySource": "public void draw(Bullet b){",
	}

func source_bullet_type_draw_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var draw_calls := ["drawTrail(b)", "drawParts(b)"]
	return {
		"bullet": update_bullet_state,
		"drawCalls": draw_calls,
		"drawTrailCalled": true,
		"drawPartsCalled": true,
		"drawReturnSource": "drawTrail(b); drawParts(b);",
		"drawTrailBoundarySource": "public void drawTrail(Bullet b){",
	}

func source_bullet_type_draw_trail_state(bullet_type_state: Dictionary, bullet_state: Dictionary, current_draw_z: float) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var trail_length := int(update_type_state.get("trailLength", -1))
	var trail_exists := update_bullet_state.get("trail", null) != null
	var gate_passed := trail_length > 0 and trail_exists
	var draw_z_below := current_draw_z - 0.0001
	var trail_width := float(update_type_state.get("trailWidth", 2.0))
	var trail_color := str(update_type_state.get("trailColor", "Pal.missileYellowBack"))
	var trail_draw_call: Variant = null
	if gate_passed:
		trail_draw_call = {"call": "b.trail.draw(trailColor, trailWidth)", "color": trail_color, "width": trail_width}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"trailDrawn": gate_passed,
		"drawZBefore": current_draw_z,
		"drawZBelow": draw_z_below if gate_passed else current_draw_z,
		"drawZRestored": current_draw_z,
		"trailColor": trail_color,
		"trailWidth": trail_width,
		"trailDrawCall": trail_draw_call,
		"gateSource": "if(trailLength > 0 && b.trail != null){",
		"drawZCaptureSource": "float z = Draw.z()",
		"drawZBelowSource": "Draw.z(z - 0.0001f)",
		"drawZRestoreSource": "Draw.z(z)",
		"drawPartsBoundarySource": "public void drawParts(Bullet b){",
	}

func source_bullet_type_draw_parts_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var parts: Array = update_type_state.get("parts", [])
	var gate_passed := parts.size() > 0
	var fin := float(update_bullet_state.get("fin", 0.0))
	var part_params := {
		"warmup": fin,
		"reload": 0.0,
		"smoothReload": 0.0,
		"heat": 0.0,
		"recoil": 0.0,
		"charge": 0.0,
		"life": fin,
		"x": float(update_bullet_state.get("x", 0.0)),
		"y": float(update_bullet_state.get("y", 0.0)),
		"rotation": float(update_bullet_state.get("rotation", 0.0)),
	}
	var part_draw_calls: Array = []
	if gate_passed:
		for i in parts.size():
			part_draw_calls.append({"part": parts[i], "params": part_params.duplicate(true), "call": "parts.get(i).draw(DrawPart.params)"})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"partParams": part_params,
		"partDrawCalls": part_draw_calls,
		"partsDrawn": part_draw_calls.size(),
		"paramsSetSource": "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation())",
		"paramsLifeSource": "DrawPart.params.life = b.fin()",
		"partDrawSource": "parts.get(i).draw(DrawPart.params)",
	}

func source_bullet_type_draw_light_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var light_opacity := float(update_type_state.get("lightOpacity", 0.3))
	var light_radius := float(update_type_state.get("lightRadius", -1.0))
	var light_color := str(update_type_state.get("lightColor", "Pal.powerLight"))
	var gate_passed := light_opacity > 0.0 and light_radius > 0.0
	var drawf_light_call: Variant = null
	if gate_passed:
		drawf_light_call = {"call": "Drawf.light(b, lightRadius, lightColor, lightOpacity)", "radius": light_radius, "color": light_color, "opacity": light_opacity}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"lightDrawn": gate_passed,
		"lightOpacity": light_opacity,
		"lightRadius": light_radius,
		"lightColor": light_color,
		"drawfLightCall": drawf_light_call,
		"earlyReturnSource": "if(lightOpacity <= 0f || lightRadius <= 0f) return",
		"drawfLightSource": "Drawf.light(b, lightRadius, lightColor, lightOpacity)",
		"initBoundarySource": "public void init(Bullet b){",
	}

func source_unit_player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	var logic_privileged_blocked := controller_is_logic_ai and logic_controller_exists and logic_controller_block_privileged
	return {
		"playerControllable": type_player_controllable and not logic_privileged_blocked,
		"logicPrivilegedBlocked": logic_privileged_blocked,
		"call": "playerControllable()",
	}

func source_unit_targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	var payload_targetable := type_vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		"targetable": type_targetable or payload_targetable,
		"payloadTargetable": payload_targetable,
		"targeter_id": targeter_id,
		"call": "type.targetable(self(), targeter)",
	}

func source_unit_killable_state(type_killable: bool) -> Dictionary:
	return {
		"killable": type_killable,
		"call": "type.killable(self())",
	}

func source_unit_hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	var payload_hittable := type_vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		"hittable": type_hittable or payload_hittable,
		"payloadHittable": payload_hittable,
		"call": "type.hittable(self())",
	}

func source_unit_after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return {
		"type_id": type_id,
		"controller_exists": controller_exists,
		"call_order": ["setType", "controller.unit"],
		"setType_arg": "this.type",
		"controllerUnitArg": "self()",
	}

func source_unit_after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	var reset_controller := not (controller_is_ai_controller and ai_keep_state)
	return {
		"type_id": type_id,
		"controller_exists": controller_exists,
		"controllerIsAIController": controller_is_ai_controller,
		"aiKeepState": ai_keep_state,
		"resetController": reset_controller,
		"call_order": ["setType", "controller.unit", "controller(type.createController)"] if reset_controller else ["setType", "controller.unit"],
		"setType_arg": "this.type",
		"controllerUnitArg": "self()",
		"createControllerArg": "self()",
	}

func source_unit_after_read_all_state(controller_exists: bool) -> Dictionary:
	return {
		"controller_exists": controller_exists,
		"call": "controller.afterRead(self())",
		"afterReadArg": "self()",
	}

func source_unit_add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	var over_cap := type_use_unit_cap and count_after_add > cap_value and not spawned_by_core and not dead and not rules_editor
	var rollback_update_count: Variant = null
	if over_cap:
		rollback_update_count = {"call": "team.data().updateCount(type, -1)", "amount": -1}
	return {
		"initialUpdateCount": {"call": "team.data().updateCount(type, 1)", "amount": 1},
		"guard": {
			"typeUseUnitCap": type_use_unit_cap,
			"countAfterAdd": count_after_add,
			"cap": cap_value,
			"spawnedByCore": spawned_by_core,
			"dead": dead,
			"rulesEditor": rules_editor,
		},
		"unitCapDeath": over_cap,
		"rollbackUpdateCount": rollback_update_count,
		"call_order": ["team.data().updateCount(+1)", "Call.unitCapDeath", "team.data().updateCount(-1)"] if over_cap else ["team.data().updateCount(+1)"],
	}

func source_unit_remove_state(trail_exists: bool, trail_size: int, trail_width: float, type_trail_color_exists: bool, team_color: String, type_trail_color: String) -> Dictionary:
	var fade_trail := trail_exists and trail_size > 0
	var trail_color := type_trail_color if type_trail_color_exists else team_color
	var trail_fade_call: Variant = null
	if fade_trail:
		trail_fade_call = {
			"call": "Fx.trailFade.at",
			"xArg": "x",
			"yArg": "y",
			"rotationArg": "trail.width()",
			"rotation": trail_width,
			"color": trail_color,
			"dataArg": "trail.copy()",
		}
	return {
		"updateCount": {"call": "team.data().updateCount(type, -1)", "amount": -1},
		"controllerRemoved": {"call": "controller.removed(self())", "arg": "self()"},
		"trail": {
			"exists": trail_exists,
			"size": trail_size,
			"width": trail_width,
			"typeTrailColorExists": type_trail_color_exists,
		},
		"trailFade": fade_trail,
		"trailFadeCall": trail_fade_call,
		"call_order": ["team.data().updateCount(-1)", "controller.removed", "Fx.trailFade.at"] if fade_trail else ["team.data().updateCount(-1)", "controller.removed"],
	}

func source_unit_landed_state(type_mech_land_shake: float) -> Dictionary:
	var shake := type_mech_land_shake > 0.0
	var shake_call: Variant = null
	if shake:
		shake_call = {
			"call": "Effect.shake(type.mechLandShake, type.mechLandShake, this)",
			"intensity": type_mech_land_shake,
			"duration": type_mech_land_shake,
			"locArg": "this",
		}
	return {
		"shake": shake,
		"shakeCall": shake_call,
		"typeLanded": {"call": "type.landed(self())", "arg": "self()"},
		"call_order": ["Effect.shake", "type.landed"] if shake else ["type.landed"],
	}

func source_unit_heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	var set_was_healed := current_health < max_health and amount > 0.0
	return {
		"guard": {"healthLessThanMax": current_health < max_health, "amountPositive": amount > 0.0},
		"wasHealed": true if set_was_healed else current_was_healed,
		"setWasHealed": set_was_healed,
		"unitCompHealthDelta": 0.0,
		"healthMutationSource": "HealthComp.heal(float amount)",
	}

func source_unit_update_heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	var reset_heal_time := was_healed_value and current_heal_time <= -1.0
	var heal_time := 1.0 if reset_heal_time else current_heal_time
	heal_time -= source_delta / 20.0
	return {
		"healTime": heal_time,
		"wasHealed": false,
		"resetHealTime": reset_heal_time,
		"decay": source_delta / 20.0,
		"order": ["updateDrowning", "healTime gate", "healTime decay", "wasHealed reset"],
	}

func source_unit_update_captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	var kill_unit := team_is_only_ai and state_is_campaign and sector_is_captured
	return {
		"guard": {"team.isOnlyAI()": team_is_only_ai, "state.isCampaign()": state_is_campaign, "state.getSector().isCaptured()": sector_is_captured},
		"kill": kill_unit,
		"call": "kill()" if kill_unit else "",
	}

func source_unit_update_sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	var sound_enabled := not headless_value
	var velocity_len := sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
	var progress := clampf(velocity_len / type_speed, 0.0, 1.0) if type_speed != 0.0 else 1.0
	var pitch := type_move_sound_pitch_min + (type_move_sound_pitch_max - type_move_sound_pitch_min) * progress
	var loop_sound_call: Variant = null
	var move_sound_call: Variant = null
	if sound_enabled:
		loop_sound_call = {
			"call": "control.sound.loop(type.loopSound, this, type.loopSoundVolume)",
			"sound": type_loop_sound,
			"volume": type_loop_sound_volume,
		}
		if type_move_sound != "Sounds.none":
			move_sound_call = {
				"call": "control.sound.loop(type.moveSound, this, type.moveSoundVolume * progress, pitch)",
				"sound": type_move_sound,
				"progress": progress,
				"volume": type_move_sound_volume * progress,
				"pitch": pitch,
			}
	return {
		"soundEnabled": sound_enabled,
		"velocityLen": velocity_len,
		"progress": progress,
		"pitch": pitch,
		"loopSound": loop_sound_call,
		"moveSound": move_sound_call,
	}

func source_unit_update_unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	var env_death := not type_supports_env and not dead_value
	var unit_env_death_call: Variant = null
	var update_count_call: Variant = null
	if env_death:
		unit_env_death_call = {
			"call": "Call.unitEnvDeath(self())",
		}
		update_count_call = {
			"call": "team.data().updateCount(type, -1)",
			"amount": -1,
		}
	return {
		"envDeath": env_death,
		"guard": {"!type.supportsEnv(state.rules.env)": not type_supports_env, "!dead": not dead_value},
		"unitEnvDeath": unit_env_death_call,
		"updateCount": update_count_call,
		"callOrder": ["Call.unitEnvDeath(self())", "team.data().updateCount(type, -1)"] if env_death else [],
	}

func source_unit_update_abilities_loop_state(ability_ids: Array) -> Dictionary:
	var updates := []
	for ability_id in ability_ids:
		updates.append({
			"call": "a.update(self())",
			"ability": ability_id,
		})
	return {
		"updates": updates,
		"updateCount": updates.size(),
	}

func source_unit_update_trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	var trail_scale := elevation_value if type_use_engine_elevation else 1.0
	var offset := type_engine_offset / 2.0 + type_engine_offset / 2.0 * trail_scale
	var angle := source_rotation_degrees + 180.0
	var cx := x_value + cos(deg_to_rad(angle)) * offset
	var cy := y_value + sin(deg_to_rad(angle)) * offset
	if not trail_exists:
		return {
			"trailExists": false,
			"scale": trail_scale,
			"offset": offset,
			"position": {"x": cx, "y": cy},
			"lengthSet": null,
			"trailUpdate": null,
		}
	return {
		"trailExists": true,
		"scale": trail_scale,
		"offset": offset,
		"position": {"x": cx, "y": cy},
		"lengthSet": {"call": "trail.length = type.trailLength", "length": type_trail_length},
		"trailUpdate": {"call": "trail.update(cx, cy)", "x": cx, "y": cy},
	}

func source_unit_update_drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	var floor_factor := floor_drag_multiplier if grounded_value else 1.0
	var unit_drag := type_drag * floor_factor * unit_drag_multiplier * rules_drag_multiplier
	return {
		"drag": unit_drag,
		"floorFactor": floor_factor,
		"grounded": grounded_value,
		"formula": "type.drag * (isGrounded() ? floorOn().dragMultiplier : 1f) * dragMultiplier * state.rules.dragMultiplier",
		"inputs": {
			"type.drag": type_drag,
			"floorOn().dragMultiplier": floor_drag_multiplier,
			"dragMultiplier": unit_drag_multiplier,
			"state.rules.dragMultiplier": rules_drag_multiplier,
		},
	}

func source_unit_update_spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	var guard := (not team_is_wave_team) and state_has_spawns_value and ((not net_client_value) or is_local_value) and hittable_value
	var relative_size := drop_zone_radius + hit_size / 2.0 + 1.0
	var knockbacks := []
	if guard:
		for spawn in spawns:
			var spawn_x := float(spawn.get("x", 0.0))
			var spawn_y := float(spawn.get("y", 0.0))
			var dx := unit_x - spawn_x
			var dy := unit_y - spawn_y
			var distance := sqrt(dx * dx + dy * dy)
			var within_spawn := distance * distance < relative_size * relative_size
			if within_spawn:
				var strength := 0.1 + 1.0 - distance / relative_size
				var knockback_scale := 0.45 * source_delta
				var length_factor := strength / distance if distance != 0.0 else 0.0
				knockbacks.append({
					"call": "velAddNet(Tmp.v1.set(this).sub(spawn.worldx(), spawn.worldy()).setLength(0.1f + 1f - dst(spawn) / relativeSize).scl(0.45f * Time.delta))",
					"spawn": {"x": spawn_x, "y": spawn_y},
					"distance": distance,
					"strength": strength,
					"velocity": {"x": dx * length_factor * knockback_scale, "y": dy * length_factor * knockback_scale},
				})
	return {
		"guard": guard,
		"relativeSize": relative_size,
		"knockbacks": knockbacks,
	}

func source_unit_update_falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	var guard := dead_value or health_value <= 0.0
	var next_drag := 0.01 if guard else current_drag
	return {
		"guard": guard,
		"drag": next_drag,
		"call": "drag = 0.01f" if guard else "",
		"source": "if(dead || health <= 0){",
	}

func source_unit_update_falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var effect_call: Variant = null
	if falling_guard and chance_delta_result:
		effect_call = {
			"call": "type.fallEffect.at(x + Tmp.v1.x, y + Tmp.v1.y)",
			"x": unit_x + tmp_v1_x,
			"y": unit_y + tmp_v1_y,
			"tmp": {"call": "Tmp.v1.rnd(Mathf.range(hitSize))", "x": tmp_v1_x, "y": tmp_v1_y},
			"range": {"call": "Mathf.range(hitSize)", "hitSize": hit_size},
		}
	return {
		"fallingGuard": falling_guard,
		"chance": {"call": "Mathf.chanceDelta(0.1)", "result": chance_delta_result},
		"effect": effect_call,
	}

func source_unit_update_falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var offset := type_engine_offset / 2.0 + type_engine_offset / 2.0 * elevation_value
	var angle := source_rotation_degrees + 180.0
	var effect_call: Variant = null
	if falling_guard and chance_delta_result:
		effect_call = {
			"call": "type.fallEngineEffect.at(x + Angles.trnsx(rotation + 180, offset) + Mathf.range(range), y + Angles.trnsy(rotation + 180, offset) + Mathf.range(range), Mathf.random())",
			"x": unit_x + cos(deg_to_rad(angle)) * offset + x_range_value,
			"y": unit_y + sin(deg_to_rad(angle)) * offset + y_range_value,
			"rotation": random_rotation_value,
			"range": {"call": "Mathf.range(type.engineSize)", "value": engine_range_value, "type.engineSize": type_engine_size},
			"xRange": {"call": "Mathf.range(range)", "value": x_range_value},
			"yRange": {"call": "Mathf.range(range)", "value": y_range_value},
			"offset": offset,
		}
	return {
		"fallingGuard": falling_guard,
		"chance": {"call": "Mathf.chanceDelta(0.2)", "result": chance_delta_result},
		"angle": angle,
		"offset": offset,
		"effect": effect_call,
	}

func source_unit_update_falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var next_elevation := elevation_value
	if falling_guard:
		next_elevation -= type_fall_speed * source_delta
	var wreck_health_threshold := -max_health * type_wreck_health_multiplier
	var destroy_call: Variant = null
	if falling_guard and (is_grounded_value or health_value <= wreck_health_threshold):
		destroy_call = {
			"call": "Call.unitDestroy(id)",
			"id": unit_id,
		}
	return {
		"fallingGuard": falling_guard,
		"elevationBefore": elevation_value,
		"elevation": next_elevation,
		"descent": {"call": "elevation -= type.fallSpeed * Time.delta", "type.fallSpeed": type_fall_speed, "Time.delta": source_delta},
		"grounded": is_grounded_value,
		"wreckHealthThreshold": wreck_health_threshold,
		"destroy": destroy_call,
	}

func source_unit_update_tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and tile_build_exists
	var callback: Variant = null
	if guard:
		callback = {
			"call": "tile.build.unitOnAny(self())",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"tileBuildExists": tile_build_exists,
		"unitOnAny": callback,
	}

func source_unit_update_tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and is_grounded_value and not type_hovering
	var callback: Variant = null
	if guard and tile_build_exists:
		callback = {
			"call": "tile.build.unitOn(self())",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"isGrounded": is_grounded_value,
		"typeHovering": type_hovering,
		"tileBuildExists": tile_build_exists,
		"unitOn": callback,
	}

func source_unit_update_floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	var guard := tile_exists and is_grounded_value and not type_hovering
	var damage_call: Variant = null
	if guard and floor_damage_taken > 0.0:
		var scaled_damage := floor_damage_taken * source_delta
		var with_effect := hit_time <= -10.0 + hit_duration
		damage_call = {
			"call": "damageContinuous(floor.damageTaken)",
			"floor.damageTaken": floor_damage_taken,
			"Time.delta": source_delta,
			"scaledDamage": scaled_damage,
			"withEffect": with_effect,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"isGrounded": is_grounded_value,
		"typeHovering": type_hovering,
		"damage": damage_call,
	}

func source_unit_update_solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and not can_pass_on_value
	var next_elevation := current_elevation
	var kill_call: Variant = null
	if guard and type_can_boost:
		next_elevation = 1.0
	elif guard and (not net_client_value) and not ((not headless_value) and is_remote_value):
		kill_call = {
			"call": "kill()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"canPassOn": can_pass_on_value,
		"typeCanBoost": type_can_boost,
		"elevation": next_elevation,
		"netClient": net_client_value,
		"headless": headless_value,
		"isRemote": is_remote_value,
		"kill": kill_call,
	}

func source_unit_update_ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	var guard := (not net_client_value) and (not dead_value) and should_update_controller_value
	var controller_update: Variant = null
	if guard:
		controller_update = {
			"call": "controller.updateUnit()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"netClient": net_client_value,
		"dead": dead_value,
		"shouldUpdateController": should_update_controller_value,
		"controllerUpdate": controller_update,
	}

func source_unit_update_invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	var guard := not controller_is_valid_value
	var reset_controller: Variant = null
	if guard:
		reset_controller = {
			"call": "resetController()",
			"effect": "controller(type.createController(self()))",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"controllerIsValid": controller_is_valid_value,
		"resetController": reset_controller,
	}

func source_unit_update_spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	var guard := spawned_by_core_value and (not is_player_value) and (not dead_value)
	var despawn_call: Variant = null
	if guard:
		despawn_call = {
			"call": "Call.unitDespawn(self())",
			"effect": "Fx.unitDespawn.at(unit.x, unit.y, 0, unit)",
			"remove": "unit.remove()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"spawnedByCore": spawned_by_core_value,
		"isPlayer": is_player_value,
		"dead": dead_value,
		"despawn": despawn_call,
	}

func source_unit_icon_state(type_ui_icon: String) -> Dictionary:
	return {
		"call": "icon()",
		"return": "type.uiIcon",
		"uiIcon": type_ui_icon,
	}

func source_unit_destroy_initial_payload_state(is_added_value: bool, killable_value: bool, item_explosiveness: float, item_flammability: float, item_charge: float, stack_amount: int) -> Dictionary:
	var should_return := (not is_added_value) or (not killable_value)
	var explosiveness: Variant = null
	var flammability: Variant = null
	var power: Variant = null
	if not should_return:
		explosiveness = 2.0 + item_explosiveness * float(stack_amount) * 1.53
		flammability = item_flammability * float(stack_amount) / 1.9
		power = item_charge * pow(float(stack_amount), 1.11) * 160.0
	return {
		"returnGuard": should_return,
		"isAdded": is_added_value,
		"killable": killable_value,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"power": power,
	}

func source_unit_destroy_explosion_dispatch_state(spawned_by_core_value: bool, source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, bounds_value: float, type_leg_length: float, rules_damage_explosions: bool, rules_unit_crash_damage: float, item_flammability: float, team_id: int, death_explosion_effect: String) -> Dictionary:
	if not spawned_by_core_value:
		return {
			"call": "Damage.dynamicExplosion",
			"x": source_x,
			"y": source_y,
			"flammability": flammability,
			"explosiveness": explosiveness,
			"power": power,
			"radius": (bounds_value + type_leg_length / 1.7) / 2.0,
			"damage": rules_damage_explosions and rules_unit_crash_damage > 0.0,
			"fire": item_flammability > 1.0,
			"team": team_id,
			"explosionFx": death_explosion_effect,
			"baseShake": 0.0,
		}
	return {
		"call": "type.deathExplosionEffect.at",
		"x": source_x,
		"y": source_y,
		"rotation": bounds_value / 2.0 / 8.0,
		"effect": death_explosion_effect,
	}

func source_unit_destroy_visual_effects_state(source_x: float, source_y: float, hit_size: float, type_death_shake: float, type_create_scorch: bool, unit_id: int) -> Dictionary:
	var shake := 3.0 + hit_size / 3.0 if type_death_shake < 0.0 else type_death_shake
	var scorch_call: Variant = null
	if type_create_scorch:
		scorch_call = {
			"call": "Effect.scorch(x, y, (int)(hitSize / 5))",
			"x": source_x,
			"y": source_y,
			"size": int(hit_size / 5.0),
		}
	return {
		"shake": shake,
		"scorch": scorch_call,
		"shakeCall": {
			"call": "Effect.shake(shake, shake, this)",
			"intensity": shake,
			"duration": shake,
			"unit": unit_id,
		},
	}

func source_unit_destroy_sound_and_event_state(death_sound: String, death_sound_volume: float, unit_id: int) -> Dictionary:
	return {
		"soundCall": {
			"call": "type.deathSound.at(this, 1f, type.deathSoundVolume)",
			"sound": death_sound,
			"pitch": 1.0,
			"volume": death_sound_volume,
			"unit": unit_id,
		},
		"eventCall": {
			"event": "Events.fire(new UnitDestroyEvent(self()))",
			"eventClass": "UnitDestroyEvent",
			"unit": unit_id,
		},
	}

func source_unit_destroy_suicide_bomb_trigger_state(explosiveness: float, is_local_value: bool, was_player_value: bool) -> Dictionary:
	var trigger := explosiveness > 7.0 and (is_local_value or was_player_value)
	return {
		"guard": "explosiveness > 7f && (isLocal() || wasPlayer)",
		"explosiveness": explosiveness,
		"isLocal": is_local_value,
		"wasPlayer": was_player_value,
		"trigger": trigger,
		"event": "Events.fire(Trigger.suicideBomb)" if trigger else "",
	}

func source_unit_destroy_shoot_on_death_mounts_state(mount_states: Array, has_target_value: bool, source_x: float, source_y: float, source_rotation_degrees: float, unit_id: int) -> Dictionary:
	var actions: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var shoot_on_death := bool(mount_state.get("shootOnDeath", false))
		var bullet_kill_shooter := bool(mount_state.get("bulletKillShooter", false))
		var total_shots := int(mount_state.get("totalShots", 0))
		var shoot_on_death_effect := str(mount_state.get("shootOnDeathEffect", ""))
		var should_update := shoot_on_death and not (bullet_kill_shooter and total_shots > 0)
		var action := {
			"mount": int(mount_state.get("mount", index)),
			"guard": "mount.weapon.shootOnDeath && !(mount.weapon.bullet.killShooter && mount.totalShots > 0)",
			"updateMount": should_update,
		}
		if should_update:
			var effect_call: Variant = null
			if shoot_on_death_effect != "" and not has_target_value:
				effect_call = {
					"allowShootEffects": false,
					"effectCall": "mount.weapon.shootOnDeathEffect.at(x, y, rotation)",
					"effect": shoot_on_death_effect,
					"x": source_x,
					"y": source_y,
					"rotation": source_rotation_degrees,
				}
			action = {
				"mount": int(mount_state.get("mount", index)),
				"guard": "mount.weapon.shootOnDeath && !(mount.weapon.bullet.killShooter && mount.totalShots > 0)",
				"updateMount": should_update,
				"effect": effect_call,
				"reload": 0.0,
				"shoot": true,
				"update": "mount.weapon.update(self(), mount)",
				"unit": unit_id,
			}
		actions.append(action)
	return {
		"hasTarget": has_target_value,
		"actions": actions,
	}

func source_unit_destroy_crash_landing_damage_state(type_flying: bool, spawned_by_core_value: bool, type_create_wreck: bool, rules_unit_crash_damage: float, hit_size: float, type_crash_damage_multiplier: float, shields_empty: bool, shield_absorbed: bool, team_id: int, source_x: float, source_y: float) -> Dictionary:
	var should_check_crash := type_flying and not spawned_by_core_value and type_create_wreck and rules_unit_crash_damage > 0.0
	var crash_damage_value: Variant = null
	var damage_radius_value: Variant = null
	var shield_lookup: Variant = null
	var shield_guard: Variant = null
	var damage_call: Variant = null
	if should_check_crash:
		shield_lookup = "indexer.getEnemy(team, BlockFlag.shield)"
		var crash_damage := pow(hit_size, 0.75) * type_crash_damage_multiplier * 2.5 * rules_unit_crash_damage
		var damage_radius := pow(hit_size, 0.94) * 1.25
		crash_damage_value = crash_damage
		damage_radius_value = damage_radius
		var should_damage := shields_empty or not shield_absorbed
		shield_guard = "shields.isEmpty() || !shields.contains(b -> b instanceof ExplosionShield s && s.absorbExplosion(x, y, crashDamage))"
		if should_damage:
			damage_call = {
				"damageCall": "Damage.damage(team, x, y, Mathf.pow(hitSize, 0.94f) * 1.25f, crashDamage, true, false, true)",
				"team": team_id,
				"x": source_x,
				"y": source_y,
				"radius": damage_radius,
				"damage": crash_damage,
				"complete": true,
				"air": false,
				"ground": true,
			}
	return {
		"guard": "type.flying && !spawnedByCore && type.createWreck && state.rules.unitCrashDamage(team) > 0",
		"shouldCheckCrash": should_check_crash,
		"shieldLookup": shield_lookup,
		"crashDamage": crash_damage_value,
		"shieldGuard": shield_guard,
		"shieldAbsorbed": shield_absorbed if should_check_crash else false,
		"damageRadius": damage_radius_value,
		"damageCall": damage_call,
	}

func source_unit_destroy_wreck_decal_state(headless_value: bool, type_create_scorch: bool, wreck_regions: Array, tmp_offsets: Array, source_x: float, source_y: float, source_rotation_degrees: float, type_hit_size: float) -> Dictionary:
	var should_create_decals := not headless_value and type_create_scorch
	var range_value := type_hit_size / 4.0
	var reported_range: Variant = null
	var decals: Array = []
	if should_create_decals:
		reported_range = range_value
		for index in wreck_regions.size():
			var region_state: Dictionary = wreck_regions[index]
			if bool(region_state.get("found", false)):
				var offset_state: Dictionary = {}
				if index < tmp_offsets.size():
					offset_state = tmp_offsets[index]
				var offset_x := float(offset_state.get("x", 0.0))
				var offset_y := float(offset_state.get("y", 0.0))
				decals.append({
					"region": str(region_state.get("region", "wreck%d" % index)),
					"index": index,
					"foundGuard": "type.wreckRegions[i].found()",
					"randomCall": "Tmp.v1.rnd(range)",
					"range": range_value,
					"x": source_x + offset_x,
					"y": source_y + offset_y,
					"rotation": source_rotation_degrees - 90.0,
					"decalCall": "Effect.decal(type.wreckRegions[i], x + Tmp.v1.x, y + Tmp.v1.y, rotation - 90)",
				})
	return {
		"guard": "!headless && type.createScorch",
		"shouldCreateDecals": should_create_decals,
		"loop": "for(int i = 0; i < type.wreckRegions.length; i++)",
		"range": reported_range,
		"decals": decals,
	}

func source_unit_destroy_ability_death_state(ability_states: Array, unit_id: int) -> Dictionary:
	var calls: Array = []
	for index in ability_states.size():
		var ability_state: Dictionary = ability_states[index]
		calls.append({
			"index": index,
			"ability": str(ability_state.get("ability", "ability%d" % index)),
			"call": "a.death(self())",
			"unit": unit_id,
			"abilityDefault": "public void death(Unit unit){}",
		})
	return {
		"loop": "for(Ability a : abilities)",
		"calls": calls,
	}

func source_unit_destroy_type_killed_remove_state(unit_id: int) -> Dictionary:
	return {
		"order": [
			{
				"call": "type.killed(self())",
				"unit": unit_id,
				"unitTypeDefault": "public void killed(Unit unit){}",
			},
			{
				"call": "remove()",
				"unit": unit_id,
				"unitRemoveOverride": "public void remove()",
			},
		],
	}

func source_unit_killed_state(is_local_value: bool, current_health: float, type_flying: bool, type_create_wreck: bool, wreck_sound: String, wreck_sound_volume: float, unit_id: int) -> Dictionary:
	var should_destroy := not type_flying or not type_create_wreck
	var clamped_health: float = minf(current_health, 0.0)
	var destroy_call: Variant = null
	var wreck_sound_call: Variant = null
	if should_destroy:
		destroy_call = "destroy()"
	else:
		wreck_sound_call = {
			"call": "type.wreckSound.at(this, 1f, type.wreckSoundVolume)",
			"sound": wreck_sound,
			"pitch": 1.0,
			"volume": wreck_sound_volume,
			"unit": unit_id,
		}
	return {
		"wasPlayer": is_local_value,
		"health": clamped_health,
		"dead": true,
		"guard": "!type.flying || !type.createWreck",
		"destroyCalled": should_destroy,
		"destroyCall": destroy_call,
		"wreckSoundCall": wreck_sound_call,
	}

func source_unit_kill_sync_state(dead_value: bool, net_client: bool, killable_value: bool, unit_id: int) -> Dictionary:
	var should_return := dead_value or net_client or not killable_value
	var remote_call: Variant = null
	if not should_return:
		remote_call = {
			"call": "Call.unitDeath(id)",
			"unit": unit_id,
			"remote": "@Remote(called = Loc.server)",
			"serverLookup": "Groups.unit.getByID(uid)",
			"serverHandler": "unit.killed()",
			"removedEntity": "netClient.addRemovedEntity(uid)",
		}
	return {
		"guard": "dead || net.client() || !killable()",
		"shouldReturn": should_return,
		"dead": dead_value,
		"netClient": net_client,
		"killable": killable_value,
		"remoteCall": remote_call,
	}

func source_unit_update_drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	var can_drown_on_floor := floor_exists and floor_is_liquid and floor_drown_time > 0.0 and can_drown_value
	var drown_time_before_clamp := current_drown_time
	var drown_increment := 0.0
	var effect_call: Variant = null
	var kill_unit := false
	var event_call: Variant = null
	var last_drown_floor_set := false
	if can_drown_on_floor:
		last_drown_floor_set = true
		drown_increment = source_delta / (hit_size / 8.0 * type_drown_time_multiplier * floor_drown_time)
		drown_time_before_clamp += drown_increment
		if chance_delta_result:
			effect_call = {
				"call": "floor.drownUpdateEffect.at(x, y, hitSize, floor.mapColor)",
				"chance": "Mathf.chanceDelta(0.05f)",
			}
		kill_unit = drown_time_before_clamp >= 0.999 and not net_client
		if kill_unit:
			event_call = {"event": "Events.fire(new UnitDrownEvent(self()))"}
	else:
		drown_time_before_clamp -= source_delta / 50.0
	var clamped_drown_time: float = clampf(drown_time_before_clamp, 0.0, 1.0)
	return {
		"canDrownOnFloor": can_drown_on_floor,
		"lastDrownFloorSet": last_drown_floor_set,
		"drownIncrement": drown_increment,
		"drownTimeBeforeClamp": drown_time_before_clamp,
		"drownTime": clamped_drown_time,
		"effectCall": effect_call,
		"kill": kill_unit,
		"eventCall": event_call,
		"netClient": net_client,
	}

func source_unit_update_type_hook_state() -> Dictionary:
	return {
		"call": "type.update(self())",
		"arg": "self()",
		"unitTypeHook": "public void update(Unit unit)",
		"order": "first statement in UnitComp.update()",
	}

func source_unit_update_bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	var next_x := current_x
	var next_y := current_y
	var bot := 0.0
	var left := 0.0
	var top := world_unit_height
	var right := world_unit_width
	var dx := 0.0
	var dy := 0.0
	var vel_add_net: Variant = null
	var can_apply_net_local := false
	var grounded: bool = source_unit_is_grounded(elevation_value)
	var use_limited_area := rules_limit_map_area and not team_is_ai
	if not type_bounded:
		return {
			"bounded": false,
			"x": next_x,
			"y": next_y,
			"velAddNet": vel_add_net,
			"grounded": grounded,
			"kill": false,
		}
	if use_limited_area:
		bot = float(rules_limit_y) * SOURCE_TILESIZE
		left = float(rules_limit_x) * SOURCE_TILESIZE
		top = float(rules_limit_height) * SOURCE_TILESIZE + bot
		right = float(rules_limit_width) * SOURCE_TILESIZE + left
	if (not net_client) or is_local:
		can_apply_net_local = true
		if next_x < left:
			dx += (-(next_x - left) / SOURCE_UNIT_WARP_DST)
		if next_y < bot:
			dy += (-(next_y - bot) / SOURCE_UNIT_WARP_DST)
		if next_x > right - SOURCE_TILESIZE:
			dx -= (next_x - (right - SOURCE_TILESIZE)) / SOURCE_UNIT_WARP_DST
		if next_y > top - SOURCE_TILESIZE:
			dy -= (next_y - (top - SOURCE_TILESIZE)) / SOURCE_UNIT_WARP_DST
		vel_add_net = {"x": dx * source_delta, "y": dy * source_delta}
		var margin := SOURCE_TILESIZE * 1.0
		next_x = clampf(next_x, left - margin, right - SOURCE_TILESIZE + margin)
		next_y = clampf(next_y, bot - margin, top - SOURCE_TILESIZE + margin)
	if grounded:
		next_x = clampf(next_x, left, right - SOURCE_TILESIZE)
		next_y = clampf(next_y, bot, top - SOURCE_TILESIZE)
	var kill_unit := next_x < -SOURCE_FINAL_WORLD_BOUNDS + left or next_y < -SOURCE_FINAL_WORLD_BOUNDS + bot or next_x >= right + SOURCE_FINAL_WORLD_BOUNDS or next_y >= top + SOURCE_FINAL_WORLD_BOUNDS
	return {
		"bounded": true,
		"limits": {"bot": bot, "left": left, "top": top, "right": right, "limitedArea": use_limited_area},
		"canApplyNetLocal": can_apply_net_local,
		"dx": dx,
		"dy": dy,
		"velAddNet": vel_add_net,
		"grounded": grounded,
		"x": next_x,
		"y": next_y,
		"kill": kill_unit,
	}

func source_unit_update_nan_health_state(current_health: float) -> Dictionary:
	var health_is_nan := is_nan(current_health)
	return {
		"guard": "Float.isNaN(health)",
		"health": 0.0 if health_is_nan else current_health,
		"kill": health_is_nan,
	}

func source_unit_update_flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	var changed := is_flying_value != was_flying_value
	var land_effect: Variant = null
	if changed and was_flying_value and tile_exists:
		land_effect = {
			"call": "Fx.unitLand.at(x, y, floor.isLiquid ? 1f : 0.5f, tile.getFloorColor())",
			"rotation": 1.0 if floor_is_liquid else 0.5,
			"color": tile_floor_color,
		}
	return {
		"changed": changed,
		"landEffect": land_effect,
		"wasFlying": is_flying_value,
	}

func source_unit_update_walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	var grounded := source_unit_is_grounded(elevation_value)
	var gate := (not type_hovering) and grounded and type_emit_walk_effect
	var distance := sqrt(delta_x * delta_x + delta_y * delta_y)
	var threshold := 7.0 + hit_size_value / 8.0
	var splash_timer := current_splash_timer
	var walk_effect: Variant = null
	var walk_sound: Variant = null
	if gate:
		splash_timer += distance
		if splash_timer >= threshold:
			walk_effect = {
				"call": "floor.walkEffect.at(x, y, hitSize() / 8f, tile != null ? tile.getFloorColor() : floor.mapColor)",
				"rotation": hit_size_value / 8.0,
				"color": tile_floor_color if tile_exists else floor_map_color,
			}
			splash_timer = 0.0
			if type_emit_walk_sound:
				walk_sound = {
					"call": "floor.walkSound.at(x, y, Mathf.random(floor.walkSoundPitchMin, floor.walkSoundPitchMax), floor.walkSoundVolume)",
					"pitch": random_pitch_value,
					"pitchMin": floor_walk_sound_pitch_min,
					"pitchMax": floor_walk_sound_pitch_max,
					"volume": floor_walk_sound_volume,
				}
	return {
		"grounded": grounded,
		"gate": gate,
		"distance": distance,
		"threshold": threshold,
		"splashTimer": splash_timer,
		"walkEffect": walk_effect,
		"walkSound": walk_sound,
	}

func source_unit_move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return {
		"movement": {"x": movement_x, "y": movement_y},
		"call": "moveAt" if type_omni_movement else "rotateMove",
	}

func source_unit_floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	var flying: bool = source_unit_is_flying(elevation_value)
	var uses_air_floor: bool = flying or type_hovering
	var on_speed_multiplier: float = 1.0 if uses_air_floor else floor_on_speed_multiplier
	var result: float = pow(on_speed_multiplier, type_floor_multiplier) * speed_multiplier_value
	return {
		"flying": flying,
		"uses_air_floor": uses_air_floor,
		"on_speed_multiplier": on_speed_multiplier,
		"speed_multiplier": result,
	}

func source_unit_unloaded_state(unit_state: Variant) -> Variant:
	return unit_state

func source_unit_update_boosting_default_event_state(boost: bool) -> Dictionary:
	return {
		"boost": boost,
		"event": false,
	}

func source_unit_update_boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	var returned: bool = (not type_can_boost) or dead_state
	return {
		"returned": returned,
		"can_update_boosting": not returned,
		"elevation": elevation_value,
	}

func source_unit_update_boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	var flying: bool = source_unit_is_flying(elevation_value)
	var should_boost: bool = boost or on_solid_result or (flying and not can_land_result)
	return {
		"flying": flying,
		"should_boost": should_boost,
	}

func source_arc_mathf_num(value: bool) -> int:
	return 1 if value else 0

func source_unit_update_boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	var target_elevation: float = float(source_arc_mathf_num(should_boost)) if type_can_boost else 0.0
	var speed: float = type_rise_speed if should_boost else type_descent_speed
	var next_elevation: float = source_approach_delta(current_elevation, target_elevation, speed, source_delta)
	return {
		"target_elevation": target_elevation,
		"speed": speed,
		"elevation": next_elevation,
	}

func source_unit_update_boosting_event_state(event: bool) -> Dictionary:
	return {
		"event_fired": event,
		"trigger": "unitCommandBoost" if event else "",
	}

func simulate_turrets(delta: float) -> void:
	if content_catalog == null or turret_cells.is_empty():
		return
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return
	for cell in turret_cells:
		var key := cell_key(cell)
		update_turret_recoil(cell, duo, delta, float(turret_rotations.get(key, 0.0)))
		var cooldown = max(0.0, float(turret_cooldowns.get(key, 0.0)) - delta)
		if cooldown <= 0.0:
			var data := peek_turret_ammo(cell, duo)
			if data.is_empty():
				turret_cooldowns[key] = cooldown
				continue
			var range_pixels := source_turret_range_for_ammo(duo, data)
			var target = find_enemy_target(grid_to_world(cell), range_pixels)
			if target != null:
				var target_rotation := source_angle_to_target(grid_to_world(cell), target)
				var current_rotation := float(turret_rotations.get(key, target_rotation))
				current_rotation = source_move_angle_toward(current_rotation, target_rotation, source_turret_rotate_speed(duo) * delta * SOURCE_TICK_RATE)
				turret_rotations[key] = current_rotation
				var angle_delta := source_angle_distance(current_rotation, target_rotation)
				last_turret_target_rotation = target_rotation
				last_turret_rotation = current_rotation
				last_turret_angle_delta = angle_delta
				if angle_delta >= source_turret_shoot_cone(duo):
					turret_cooldowns[key] = cooldown
					continue
				data = use_turret_ammo(cell, duo)
				if not data.is_empty():
					var shoot_x_offset := use_turret_shoot_x_offset(cell, duo)
					var bullet_origin := source_turret_bullet_origin(grid_to_world(cell), target, duo, shoot_x_offset)
					var inaccuracy_range := source_turret_total_inaccuracy(duo, data)
					var inaccuracy_offset := randf_range(-inaccuracy_range, inaccuracy_range)
					var shoot_angle_degrees := current_rotation + inaccuracy_offset
					last_turret_fired_range = range_pixels
					last_turret_fired_shoot_y = source_turret_shoot_y(duo)
					last_turret_fired_shoot_x_offset = shoot_x_offset
					last_turret_fired_inaccuracy_range = inaccuracy_range
					last_turret_fired_inaccuracy_offset = inaccuracy_offset
					turret_recoils[key] = 1.0
					last_turret_cur_recoil = 1.0
					last_turret_recoil = source_turret_recoil(duo)
					last_turret_recoils = source_turret_recoils(duo)
					last_turret_recoil_offset = source_turret_recoil_offset(duo, current_rotation, last_turret_cur_recoil)
					apply_turret_recoil_offset(cell, duo, last_turret_recoil_offset)
					spawn_turret_bullet(bullet_origin, target, data, shoot_angle_degrees)
					cooldown = source_turret_reload_seconds_for_ammo(duo, data)
		turret_cooldowns[key] = cooldown

func selected_turret_ammo_sprite() -> String:
	if content_catalog == null:
		return ""
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return ""
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return ""
	var data: Dictionary = ammo[0]
	return str(data.get("sprite", "bullet"))

func selected_turret_ammo_lifetime_seconds() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_lifetime_seconds(data)

func selected_turret_limit_range_margin() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return float(duo.properties.get("limitRangeMargin", 0.0))

func selected_turret_ammo_world_speed() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_world_speed(data)

func selected_turret_ammo_dimensions() -> Dictionary:
	if content_catalog == null:
		return {}
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return {}
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return {}
	var data: Dictionary = ammo[0]
	var width := float(data.get("width", 4.0))
	return {"width": width, "height": float(data.get("height", width))}

func selected_turret_ammo_hit_size() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_hit_size(data)

func selected_turret_ammo_damage() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_damage(data)

func selected_turret_ammo_multiplier() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_ammo_multiplier(data)

func selected_turret_ammo_reload_multiplier() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_reload_multiplier(data)

func selected_turret_ammo_range_change() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	var ammo: Array = duo.properties.get("ammo", [])
	if ammo.is_empty():
		return 0.0
	var data: Dictionary = ammo[0]
	return source_bullet_range_change(data)

func selected_turret_ammo_count() -> int:
	if content_catalog == null:
		return 0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0
	return duo.properties.get("ammo", []).size()

func selected_turret_max_ammo() -> int:
	if content_catalog == null:
		return 0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0
	return int(duo.properties.get("maxAmmo", 30))

func selected_turret_ammo_per_shot() -> int:
	if content_catalog == null:
		return 0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0
	return int(duo.properties.get("ammoPerShot", 1))

func selected_turret_consume_ammo_once() -> bool:
	if content_catalog == null:
		return false
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return false
	return bool(duo.properties.get("consumeAmmoOnce", true))

func selected_turret_total_ammo() -> int:
	return int(turret_total_ammo.get(cell_key(duo_pos), 0))

func selected_turret_cooldown_seconds() -> float:
	return float(turret_cooldowns.get(cell_key(duo_pos), 0.0))

func selected_turret_ammo_stack_count() -> int:
	var stacks: Array = turret_ammo_stacks.get(cell_key(duo_pos), [])
	return stacks.size()

func selected_turret_loaded_ammo_item() -> String:
	var stacks: Array = turret_ammo_stacks.get(cell_key(duo_pos), [])
	if stacks.is_empty():
		return ""
	var stack: Dictionary = stacks[stacks.size() - 1]
	return str(stack.get("item", ""))

func source_turret_ammo_data(turret, item_id: String) -> Dictionary:
	if turret == null:
		return {}
	for data in turret.properties.get("ammo", []):
		if data is Dictionary and str(data.get("item", "")) == item_id:
			return data
	return {}

func peek_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	if turret == null:
		return {}
	var key := cell_key(cell)
	var stacks: Array = turret_ammo_stacks.get(key, [])
	var ammo_per_shot := int(turret.properties.get("ammoPerShot", 1))
	if stacks.is_empty():
		return {}
	var active_stack: Dictionary = stacks[stacks.size() - 1]
	if int(active_stack.get("amount", 0)) >= ammo_per_shot:
		return source_turret_ammo_data(turret, str(active_stack.get("item", "")))
	if stacks.size() >= 2:
		for index in stacks.size():
			var stack: Dictionary = stacks[index]
			if int(stack.get("amount", 0)) >= ammo_per_shot:
				return source_turret_ammo_data(turret, str(stack.get("item", "")))
	return {}

func handle_turret_item(cell: Vector2i, turret, item_id: String) -> bool:
	var data := source_turret_ammo_data(turret, item_id)
	if data.is_empty():
		return false
	var key := cell_key(cell)
	var amount := int(source_bullet_ammo_multiplier(data))
	var total := int(turret_total_ammo.get(key, 0))
	var max_ammo := int(turret.properties.get("maxAmmo", 30))
	if total + amount > max_ammo:
		return false
	var stacks: Array = turret_ammo_stacks.get(key, [])
	var found := -1
	for index in stacks.size():
		var stack: Dictionary = stacks[index]
		if str(stack.get("item", "")) == item_id:
			found = index
			break
	if found >= 0:
		var stack: Dictionary = stacks[found]
		stack["amount"] = int(stack.get("amount", 0)) + amount
		stacks[found] = stack
		if found != stacks.size() - 1:
			var last_stack = stacks[stacks.size() - 1]
			stacks[stacks.size() - 1] = stacks[found]
			stacks[found] = last_stack
	else:
		stacks.append({"item": item_id, "amount": amount})
	turret_ammo_stacks[key] = stacks
	turret_total_ammo[key] = total + amount
	return true

func use_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	if turret == null:
		return {}
	var key := cell_key(cell)
	var stacks: Array = turret_ammo_stacks.get(key, [])
	var ammo_per_shot := int(turret.properties.get("ammoPerShot", 1))
	if stacks.size() >= 2 and int((stacks[stacks.size() - 1] as Dictionary).get("amount", 0)) < ammo_per_shot:
		for index in stacks.size():
			var stack: Dictionary = stacks[index]
			if int(stack.get("amount", 0)) >= ammo_per_shot:
				var last_stack = stacks[stacks.size() - 1]
				stacks[stacks.size() - 1] = stacks[index]
				stacks[index] = last_stack
				break
	if stacks.is_empty():
		return {}
	var active_stack: Dictionary = stacks[stacks.size() - 1]
	if int(active_stack.get("amount", 0)) < ammo_per_shot:
		turret_ammo_stacks[key] = stacks
		return {}
	var data := source_turret_ammo_data(turret, str(active_stack.get("item", "")))
	if data.is_empty():
		return {}
	active_stack["amount"] = int(active_stack.get("amount", 0)) - ammo_per_shot
	if int(active_stack.get("amount", 0)) <= 0:
		stacks.pop_back()
	else:
		stacks[stacks.size() - 1] = active_stack
	turret_ammo_stacks[key] = stacks
	turret_total_ammo[key] = maxi(0, int(turret_total_ammo.get(key, 0)) - ammo_per_shot)
	return data

func load_selected_turret_ammo(item_id: String, amount: int) -> int:
	if content_catalog == null:
		return 0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0
	var loaded := 0
	for _i in amount:
		if handle_turret_item(duo_pos, duo, item_id):
			loaded += 1
		else:
			break
	return loaded

func use_selected_turret_ammo_once() -> Dictionary:
	if content_catalog == null:
		return {}
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return {}
	return use_turret_ammo(duo_pos, duo)

func selected_turret_reload_seconds() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_reload_seconds(duo)

func selected_turret_range() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_range(duo)

func selected_turret_shoot_y() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_shoot_y(duo)

func selected_turret_shoot_pattern() -> Dictionary:
	if content_catalog == null:
		return {}
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return {}
	return source_turret_shoot_pattern(duo)

func selected_turret_inaccuracy() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_inaccuracy(duo)

func selected_turret_rotate_speed() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_rotate_speed(duo)

func selected_turret_shoot_cone() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_shoot_cone(duo)

func selected_turret_recoil() -> float:
	if content_catalog == null:
		return 0.0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0.0
	return source_turret_recoil(duo)

func selected_turret_recoils() -> int:
	if content_catalog == null:
		return 0
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return 0
	return source_turret_recoils(duo)

func source_turret_reload_seconds(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("reload", 10.0)) / 60.0

func source_turret_reload_seconds_for_ammo(turret, data: Dictionary) -> float:
	if data.is_empty():
		return source_turret_reload_seconds(turret)
	return source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)

func source_turret_range(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("range", 80.0))

func source_turret_shoot_y(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("shootY", 0.0))

func source_turret_inaccuracy(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("inaccuracy", 0.0))

func source_turret_rotate_speed(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("rotateSpeed", 5.0))

func source_turret_shoot_cone(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("shootCone", 8.0))

func source_turret_recoil(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("recoil", 1.0))

func source_turret_recoils(turret) -> int:
	if turret == null:
		return 0
	return int(turret.properties.get("recoils", -1))

func source_turret_recoil_time(turret) -> float:
	if turret == null:
		return 1.0
	return source_turret_reload_seconds(turret) * SOURCE_TICK_RATE

func source_turret_recoil_offset(turret, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(recoil_rotation_degrees)) * (-pow(cur_recoil, SOURCE_RECOIL_POW) * source_turret_recoil(turret))

func update_turret_recoil(cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	var key := cell_key(cell)
	var cur_recoil := float(turret_recoils.get(key, 0.0))
	if source_turret_recoil_time(turret) > 0.0:
		cur_recoil = max(0.0, cur_recoil - delta * SOURCE_TICK_RATE / source_turret_recoil_time(turret))
	turret_recoils[key] = cur_recoil
	last_turret_cur_recoil = cur_recoil
	last_turret_recoil = source_turret_recoil(turret)
	last_turret_recoils = source_turret_recoils(turret)
	last_turret_recoil_offset = source_turret_recoil_offset(turret, recoil_rotation_degrees, cur_recoil)
	apply_turret_recoil_offset(cell, turret, last_turret_recoil_offset)

func apply_turret_recoil_offset(cell: Vector2i, turret, offset: Vector2) -> void:
	var sprite = placed_block_origins.get(cell_key(cell))
	if is_instance_valid(sprite):
		sprite.position = source_block_sprite_base_position(turret, cell) + offset

func source_turret_shoot_pattern(turret) -> Dictionary:
	if turret == null:
		return {}
	return turret.properties.get("shootPattern", {})

func use_turret_shoot_x_offset(cell: Vector2i, turret) -> float:
	var pattern := source_turret_shoot_pattern(turret)
	if str(pattern.get("type", "")) != "ShootAlternate":
		return 0.0
	var spread := float(pattern.get("spread", 0.0))
	var key := cell_key(cell)
	var counter := int(turret_barrel_counters.get(key, 0))
	var index := counter % 2
	var offset := (float(index) - 0.5) * spread
	turret_barrel_counters[key] = counter + 1
	return offset

func source_turret_bullet_origin(origin: Vector2, target, turret, shoot_x_offset := 0.0) -> Vector2:
	if target == null:
		return origin
	var sprite = target.get("sprite")
	if not is_instance_valid(sprite):
		return origin
	var direction: Vector2 = sprite.position - origin
	if direction == Vector2.ZERO:
		return origin
	var shoot_y_origin := origin + direction.normalized() * source_turret_shoot_y(turret)
	var side := Vector2(-direction.y, direction.x).normalized()
	return shoot_y_origin + side * shoot_x_offset

func source_angle_to_target(origin, target) -> float:
	if target == null:
		return 0.0
	var origin_x := 0.0
	var origin_y := 0.0
	if typeof(origin) == TYPE_DICTIONARY:
		origin_x = float(origin.get("x", 0.0))
		origin_y = float(origin.get("y", 0.0))
	else:
		origin_x = float(origin.x)
		origin_y = float(origin.y)
	if target.has("x") and target.has("y"):
		return source_arc_angles_angle(origin_x, origin_y, float(target.get("x", 0.0)), float(target.get("y", 0.0)))
	var sprite = target.get("sprite")
	if not is_instance_valid(sprite):
		return 0.0
	var direction: Vector2 = sprite.position - Vector2(origin_x, origin_y)
	if direction == Vector2.ZERO:
		return 0.0
	return source_arc_angles_angle(origin_x, origin_y, sprite.position.x, sprite.position.y)

func source_angle_distance(current_degrees: float, target_degrees: float) -> float:
	return abs(wrapf(target_degrees - current_degrees, -180.0, 180.0))

func source_move_angle_toward(current_degrees: float, target_degrees: float, max_delta: float) -> float:
	var delta := wrapf(target_degrees - current_degrees, -180.0, 180.0)
	if abs(delta) <= max_delta:
		return target_degrees
	return current_degrees + sign(delta) * max_delta

const SOURCE_BULLET_RANGE_CHANGE_COMMENT := "/** When used in a turret with multiple ammo types, this can be set to a non-zero value to influence range. */"
const SOURCE_BULLET_RANGE_CHANGE_FIELD := "public float rangeChange = 0f;"
const SOURCE_BULLET_RANGE_CHANGE_KEY := "rangeChange"
const SOURCE_BULLET_RANGE_CHANGE_DEFAULT := 0.0

func source_bullet_range_change(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_RANGE_CHANGE_KEY, SOURCE_BULLET_RANGE_CHANGE_DEFAULT))

const SOURCE_BULLET_INACCURACY_COMMENT := "/** Extra inaccuracy when firing. */"
const SOURCE_BULLET_INACCURACY_FIELD := "public float inaccuracy = 0f;"
const SOURCE_BULLET_INACCURACY_KEY := "inaccuracy"
const SOURCE_BULLET_INACCURACY_DEFAULT := 0.0

func source_bullet_inaccuracy(data: Dictionary) -> float:
	return float(data.get("inaccuracy", 0.0))

func source_turret_total_inaccuracy(turret, data: Dictionary) -> float:
	return source_turret_inaccuracy(turret) + source_bullet_inaccuracy(data)

func source_turret_range_for_ammo(turret, data: Dictionary) -> float:
	return source_turret_range(turret) + source_bullet_range_change(data)

const SOURCE_BULLET_LIFETIME_COMMENT := "/** Lifetime in ticks. */"
const SOURCE_BULLET_LIFETIME_FIELD := "public float lifetime = 40f;"
const SOURCE_BULLET_LIFETIME_KEY := "lifetime"
const SOURCE_BULLET_LIFETIME_DEFAULT := 40.0
const SOURCE_BULLET_LIFETIME_TICKS_PER_SECOND := 60.0

func source_bullet_lifetime_seconds(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_LIFETIME_KEY, SOURCE_BULLET_LIFETIME_DEFAULT)) / SOURCE_BULLET_LIFETIME_TICKS_PER_SECOND

const SOURCE_BULLET_WORLD_SPEED_COMMENT := "/** Speed in units/tick. */"
const SOURCE_BULLET_WORLD_SPEED_FIELD := "public float speed = 1f;"
const SOURCE_BULLET_WORLD_SPEED_STAT_CASE := "case speed -> type.speed * 60f / tilesize;"
const SOURCE_BULLET_WORLD_SPEED_KEY := "speed"
const SOURCE_BULLET_WORLD_SPEED_DEFAULT := 1.0
const SOURCE_BULLET_WORLD_SPEED_TICKS_PER_SECOND := 60.0

func source_bullet_world_speed(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_WORLD_SPEED_KEY, SOURCE_BULLET_WORLD_SPEED_DEFAULT)) * SOURCE_BULLET_WORLD_SPEED_TICKS_PER_SECOND

const SOURCE_BULLET_VELOCITY_SPEED_FIELD := "public float speed = 1f;"
const SOURCE_BULLET_VELOCITY_INIT_VEL_CALL := "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));"
const SOURCE_BULLET_VELOCITY_COMP_INIT_VEL_METHOD := "public void initVel(float angle, float amount){"
const SOURCE_BULLET_VELOCITY_COMP_TRNS := "vel.trns(angle, amount);"
const SOURCE_BULLET_VELOCITY_COMP_ROTATION := "rotation = angle;"

func source_bullet_velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(shoot_angle_degrees)) * source_bullet_world_speed(data)

const SOURCE_BULLET_HIT_SIZE_FIELD := "public float hitSize = 4;"
const SOURCE_BULLET_HIT_SIZE_KEY := "hitSize"
const SOURCE_BULLET_HIT_SIZE_DEFAULT := 4.0

func source_bullet_hit_size(data: Dictionary) -> float:
	return float(data.get("hitSize", 4.0))

const SOURCE_BULLET_DAMAGE_FIELD := "public float damage = 1f;"
const SOURCE_BULLET_DAMAGE_KEY := "damage"
const SOURCE_BULLET_DAMAGE_DEFAULT := 1.0

func source_bullet_damage(data: Dictionary) -> float:
	return float(data.get("damage", 1.0))

const SOURCE_BULLET_AMMO_MULTIPLIER_COMMENT := "/** How many bullets get created per ammo item/liquid. */"
const SOURCE_BULLET_AMMO_MULTIPLIER_FIELD := "public float ammoMultiplier = 2f;"
const SOURCE_BULLET_AMMO_MULTIPLIER_KEY := "ammoMultiplier"
const SOURCE_BULLET_AMMO_MULTIPLIER_DEFAULT := 2.0

func source_bullet_ammo_multiplier(data: Dictionary) -> float:
	return float(data.get("ammoMultiplier", 2.0))

const SOURCE_BULLET_RELOAD_MULTIPLIER_COMMENT := "/** Multiplied by turret reload speed to get final shoot speed. */"
const SOURCE_BULLET_RELOAD_MULTIPLIER_FIELD := "public float reloadMultiplier = 1f;"
const SOURCE_BULLET_RELOAD_MULTIPLIER_KEY := "reloadMultiplier"
const SOURCE_BULLET_RELOAD_MULTIPLIER_DEFAULT := 1.0

func source_bullet_reload_multiplier(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_RELOAD_MULTIPLIER_KEY, SOURCE_BULLET_RELOAD_MULTIPLIER_DEFAULT))

const SOURCE_BULLET_SCALE_FIELD := "public float width = 5f, height = 7f;"
const SOURCE_BULLET_SCALE_WIDTH_KEY := "width"
const SOURCE_BULLET_SCALE_HEIGHT_KEY := "height"
const SOURCE_BULLET_SCALE_WIDTH_DEFAULT := 5.0
const SOURCE_BULLET_SCALE_HEIGHT_DEFAULT := 7.0

func source_bullet_scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	var width := float(data.get(SOURCE_BULLET_SCALE_WIDTH_KEY, SOURCE_BULLET_SCALE_WIDTH_DEFAULT))
	var height := float(data.get(SOURCE_BULLET_SCALE_HEIGHT_KEY, SOURCE_BULLET_SCALE_HEIGHT_DEFAULT))
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	return Vector2(width / texture_size.x, height / texture_size.y)

func find_enemy_target(origin: Vector2, range_pixels: float):
	var best = null
	var best_distance := range_pixels
	for enemy in enemy_units:
		var sprite = enemy.get("sprite")
		if not is_instance_valid(sprite):
			continue
		var distance := origin.distance_to(sprite.position)
		if distance <= best_distance:
			best_distance = distance
			best = enemy
	return best

func spawn_turret_bullet(origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:
	if data.is_empty():
		return
	last_turret_fired_ammo_item = str(data.get("item", ""))
	last_turret_fired_damage = source_bullet_damage(data)
	last_turret_fired_reload_multiplier = source_bullet_reload_multiplier(data)
	turret_shot_count += 1
	var velocity := source_bullet_velocity(data, shoot_angle_degrees)
	var sprite := Sprite2D.new()
	sprite.texture = source_bullet_texture(str(data.get("sprite", SOURCE_BULLET_TEXTURE_DEFAULT)))
	sprite.position = origin
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = source_bullet_scale(data, size)
	get_node("World/BulletLayer").add_child(sprite)
	bullets.append({"sprite": sprite, "target": target, "velocity": velocity, "speed": source_bullet_world_speed(data), "damage": source_bullet_damage(data), "hit_size": source_bullet_hit_size(data), "lifetime_remaining": source_bullet_lifetime_seconds(data)})

func simulate_bullets(delta: float) -> void:
	var active: Array = []
	for bullet in bullets:
		var sprite = bullet.get("sprite")
		var target = bullet.get("target")
		if not is_instance_valid(sprite) or target == null:
			continue
		var lifetime_remaining := float(bullet.get("lifetime_remaining", 0.0)) - delta
		bullet["lifetime_remaining"] = lifetime_remaining
		if lifetime_remaining <= 0.0:
			sprite.queue_free()
			continue
		var target_sprite = target.get("sprite")
		if not is_instance_valid(target_sprite):
			sprite.queue_free()
			continue
		var target_direction: Vector2 = target_sprite.position - sprite.position
		if target_direction.length() <= float(bullet.get("hit_size", 4.0)):
			target["health"] = float(target.get("health", 0.0)) - float(bullet.get("damage", 1.0))
			if float(target.get("health", 0.0)) <= 0.0:
				target_sprite.queue_free()
			sprite.queue_free()
			continue
		sprite.position += (bullet.get("velocity", Vector2.ZERO) as Vector2) * delta
		active.append(bullet)
	bullets = active

func update_camera(delta: float) -> void:
	if camera == null:
		return
	var movement := Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		movement.x += 1.0
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		movement.y += 1.0
	if movement != Vector2.ZERO:
		camera.position += movement.normalized() * 420.0 * delta
	if Input.is_key_pressed(KEY_Q):
		camera.zoom *= 1.0 + delta
	if Input.is_key_pressed(KEY_E):
		camera.zoom *= 1.0 - min(delta, 0.5)

func get_runtime_summary() -> Dictionary:
	var selected = build_palette[selected_build_index] if not build_palette.is_empty() else null
	return {
		"generated_class_count": generated_class_count,
		"all_generated_script_count": all_generated_scripts.size(),
		"all_generated_instance_count": all_generated_instances.size(),
		"all_generated_load_failures": all_generated_load_failures.duplicate(),
		"all_generated_instance_failures": all_generated_instance_failures.duplicate(),
		"loaded_generated_class_names": loaded_generated_class_names.duplicate(),
		"loaded_generated_instance_names": loaded_generated_instance_names.duplicate(),
		"content_counts": content_counts.duplicate(),
		"build_palette_size": build_palette.size(),
		"initial_world_block_count": initial_world_block_count,
		"initial_occupied_cell_count": initial_occupied_cell_count,
		"placed_block_count": placed_block_origins.size(),
		"occupied_cell_count": placed_blocks.size(),
		"last_placed_block_id": last_placed_block_id,
		"last_placed_block_size": last_placed_block_size,
		"last_placed_cell": {"x": last_placed_cell.x, "y": last_placed_cell.y},
		"last_placed_occupied_cell_count": last_placed_occupied_cell_count,
		"last_place_blocked": last_place_blocked,
		"selected_build_index": selected_build_index,
		"selected_build_id": selected.id if selected else "",
		"selected_build_health": selected_build_health(),
		"selected_build_scaled_health": selected_build_scaled_health(),
		"selected_build_heal_percent": selected_build_heal_percent(),
		"selected_build_phase_boost": selected_build_phase_boost(),
		"selected_build_phase_range_boost": selected_build_phase_range_boost(),
		"selected_build_can_overdrive": selected_build_can_overdrive(),
		"selected_build_overdrive_real_boost": selected_build_overdrive_real_boost(),
		"selected_build_overdrive_phase_real_boost": selected_build_overdrive_phase_real_boost(),
		"selected_build_overdrive_boost_bar_fraction": selected_build_overdrive_boost_bar_fraction(),
		"selected_build_overdrive_phase_boost_bar_fraction": selected_build_overdrive_phase_boost_bar_fraction(),
		"selected_build_overdrive_place_state": selected_build_overdrive_place_state(),
		"selected_build_overdrive_phase_select_state": selected_build_overdrive_phase_select_state(),
		"last_overdrive_projector_boost_range": last_overdrive_projector_boost_range,
		"last_overdrive_projector_boost": last_overdrive_projector_boost,
		"last_overdrive_projector_boost_duration": last_overdrive_projector_boost_duration,
		"last_overdrive_projector_boosted_block_id": last_overdrive_projector_boosted_block_id,
		"last_overdrive_projector_boosted_cell": {"x": last_overdrive_projector_boosted_cell.x, "y": last_overdrive_projector_boosted_cell.y},
		"selected_build_booster_item": selected_build_booster_item(),
		"selected_build_booster_use_time": selected_build_booster_use_time(),
		"selected_build_repair_amount": selected_build_repair_amount(),
		"selected_build_place_state": selected_build_place_state(),
		"last_mend_projector_healed_amount": last_mend_projector_healed_amount,
		"last_mend_projector_healed_block_id": last_mend_projector_healed_block_id,
		"last_mend_projector_healed_cell": {"x": last_mend_projector_healed_cell.x, "y": last_mend_projector_healed_cell.y},
		"core_inventory": core_inventory,
		"core_items": core_items.duplicate(),
		"core_item_capacity": core_item_capacity,
		"drill_output_item_id": drill_output_item_id,
		"drill_ore_cell_count": drill_ore_cell_count,
		"drill_output_rate": drill_output_rate,
		"drill_items": drill_items.duplicate(),
		"drill_items_total": drill_items_total(),
		"drill_dump_timer": drill_dump_timer,
		"drill_dump_cursor": drill_dump_cursor,
		"building_dump_accum": building_dump_accum,
		"conveyor_world_speed": conveyor_world_speed,
		"conveyor_path_progress_rate": conveyor_path_progress_rate,
		"wave_index": wave_index,
		"enemy_count": enemy_units.size(),
		"bullet_count": bullets.size(),
		"turret_shot_count": turret_shot_count,
		"last_turret_fired_ammo_item": last_turret_fired_ammo_item,
		"last_turret_fired_damage": last_turret_fired_damage,
		"last_turret_fired_reload_multiplier": last_turret_fired_reload_multiplier,
		"last_turret_fired_range": last_turret_fired_range,
		"last_turret_fired_shoot_y": last_turret_fired_shoot_y,
		"last_turret_fired_shoot_x_offset": last_turret_fired_shoot_x_offset,
		"last_turret_fired_inaccuracy_range": last_turret_fired_inaccuracy_range,
		"last_turret_fired_inaccuracy_offset": last_turret_fired_inaccuracy_offset,
		"last_turret_target_rotation": last_turret_target_rotation,
		"last_turret_rotation": last_turret_rotation,
		"last_turret_angle_delta": last_turret_angle_delta,
		"last_turret_recoil": last_turret_recoil,
		"last_turret_recoils": last_turret_recoils,
		"last_turret_cur_recoil": last_turret_cur_recoil,
		"last_turret_recoil_offset": {"x": last_turret_recoil_offset.x, "y": last_turret_recoil_offset.y},
		"selected_turret_ammo_sprite": selected_turret_ammo_sprite(),
		"selected_turret_ammo_lifetime_seconds": selected_turret_ammo_lifetime_seconds(),
		"selected_turret_ammo_world_speed": selected_turret_ammo_world_speed(),
		"selected_turret_ammo_dimensions": selected_turret_ammo_dimensions(),
		"selected_turret_ammo_hit_size": selected_turret_ammo_hit_size(),
		"selected_turret_ammo_damage": selected_turret_ammo_damage(),
		"selected_turret_ammo_multiplier": selected_turret_ammo_multiplier(),
		"selected_turret_ammo_reload_multiplier": selected_turret_ammo_reload_multiplier(),
		"selected_turret_ammo_range_change": selected_turret_ammo_range_change(),
		"selected_turret_ammo_count": selected_turret_ammo_count(),
		"selected_turret_max_ammo": selected_turret_max_ammo(),
		"selected_turret_ammo_per_shot": selected_turret_ammo_per_shot(),
		"selected_turret_consume_ammo_once": selected_turret_consume_ammo_once(),
		"selected_turret_total_ammo": selected_turret_total_ammo(),
		"selected_turret_cooldown_seconds": selected_turret_cooldown_seconds(),
		"selected_turret_ammo_stack_count": selected_turret_ammo_stack_count(),
		"selected_turret_loaded_ammo_item": selected_turret_loaded_ammo_item(),
		"selected_turret_reload_seconds": selected_turret_reload_seconds(),
		"selected_turret_range": selected_turret_range(),
		"selected_turret_shoot_y": selected_turret_shoot_y(),
		"selected_turret_shoot_pattern": selected_turret_shoot_pattern(),
		"selected_turret_inaccuracy": selected_turret_inaccuracy(),
		"selected_turret_rotate_speed": selected_turret_rotate_speed(),
		"selected_turret_shoot_cone": selected_turret_shoot_cone(),
		"selected_turret_recoil": selected_turret_recoil(),
		"selected_turret_recoils": selected_turret_recoils(),
		"selected_turret_limit_range_margin": selected_turret_limit_range_margin(),
		"selected_enemy_weapon_damage": source_unit_weapon_damage(selected_enemy_unit()),
		"selected_enemy_world_speed": source_unit_world_speed(selected_enemy_unit()),
		"selected_enemy_hit_size": source_unit_hit_size(selected_enemy_unit()),
		"selected_enemy_health": source_unit_health(selected_enemy_unit()),
		"core_max_health": core_max_health,
		"core_health": core_health,
	}

func update_hud() -> void:
	if hud_label == null:
		return
	var copper = content_catalog.get_by_id("copper") if content_catalog else null
	var copper_name: String = copper.display_name() if copper else "Copper"
	var selected = build_palette[selected_build_index] if not build_palette.is_empty() else null
	var selected_name: String = selected.display_name() if selected else "None"
	var selected_cost := requirements_text(selected) if selected else "none"
	hud_label.text = "Mindustry Godot slice\nLoaded content objects: %d items / %d liquids / %d blocks / %d units\nGenerated Java classes: %d\nAll generated script instances: %d / %d\nLoaded generated scripts: %d (%s)\nInstanced generated scripts: %d (%s)\nBuild: %s cost %s (1-6 select, left click place)\n%s in core: %d\nTotal produced: %d\nWave: %d enemies: %d bullets: %d core health: %d\nArrows move camera, Q/E zoom" % [content_counts.get("items", 0), content_counts.get("liquids", 0), content_counts.get("blocks", 0), content_counts.get("units", 0), generated_class_count, all_generated_instances.size(), generated_class_count, loaded_generated_class_names.size(), ", ".join(loaded_generated_class_names), loaded_generated_instance_names.size(), ", ".join(loaded_generated_instance_names), selected_name, selected_cost, copper_name, core_inventory, produced_total, wave_index, enemy_units.size(), bullets.size(), int(core_health)]
