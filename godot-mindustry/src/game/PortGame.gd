extends Node2D
class_name PortGame

const CONFIG_PATH := "res://src/generated/playable_content.json"
const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const GeneratedClassRegistry := preload("res://src/generated/GeneratedClassRegistry.gd")
const ContentCatalog := preload("res://src/mindustry/content/ContentCatalog.gd")
const WORLD_W := 24
const WORLD_H := 16
const PINNED_BUILD_BLOCK_IDS := ["conveyor", "router", "junction", "mechanical-drill", "duo", "copper-wall"]
const SELECTED_GENERATED_CLASS_NAMES := ["Items", "Blocks", "UnitTypes", "Damage"]
const SOURCE_DRILL_HARDNESS_MULTIPLIER := 50.0
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
	var result := {"time_scale": current_time_scale, "time_scale_duration": current_duration - source_delta}
	if float(result["time_scale_duration"]) <= 0.0:
		result["time_scale"] = 1.0
		result["time_scale_duration"] = 0.0
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
	return (sin(value / scl) * mag + mag) / 2.0

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

func source_drill_dump_interval(block_id: String, time_scale := 1.0) -> float:
	return source_block_dump_time(block_id) / time_scale

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

func source_drill_delay(block_id: String, item_id: String) -> float:
	if content_catalog == null:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	var item = content_catalog.get_by_id(item_id)
	if block == null or item == null:
		return 0.0
	return float(block.properties.get("drillTime", 300.0)) + SOURCE_DRILL_HARDNESS_MULTIPLIER * float(item.properties.get("hardness", 0))

func source_drill_output_rate(block_id: String, item_id: String, ore_count: int) -> float:
	if ore_count <= 0:
		return 0.0
	var delay := source_drill_delay(block_id, item_id)
	if delay <= 0.0:
		return 0.0
	return 60.0 * float(ore_count) / delay

func source_drill_warmup_speed(block_id: String) -> float:
	if content_catalog == null:
		return SOURCE_DRILL_WARMUP_SPEED
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return SOURCE_DRILL_WARMUP_SPEED
	return float(block.properties.get("warmupSpeed", SOURCE_DRILL_WARMUP_SPEED))

func source_drill_warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:
	return source_approach_delta(current_warmup, speed, warmup_speed, source_delta)

func source_drill_inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float) -> float:
	return source_approach_delta(current_warmup, 0.0, warmup_speed, source_delta)

func drill_warmup_at_cell(x: int, y: int) -> float:
	return float(drill_warmups.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_warmup_at_cell(x: int, y: int, warmup: float) -> void:
	drill_warmups[cell_key(Vector2i(x, y))] = warmup

func source_drill_last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:
	if ore_count <= 0:
		return 0.0
	var delay := source_drill_delay(block_id, item_id)
	if delay <= 0.0:
		return 0.0
	return speed * float(ore_count) * warmup / delay

func source_drill_last_speed_for_cell(x: int, y: int, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_drill_last_speed(str(sprite.get_meta("source_block_id", "")), item_id, ore_count, warmup, speed)

func drill_last_speed_at_cell(x: int, y: int) -> float:
	return float(drill_last_speeds.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_last_speed_at_cell(x: int, y: int, value: float) -> void:
	drill_last_speeds[cell_key(Vector2i(x, y))] = value

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

func source_drill_output_delta(block_id: String, item_id: String, ore_count: int, seconds: float, time_scale := 1.0, warmup := 1.0) -> float:
	var scaled_source_delta := source_building_delta(seconds * SOURCE_TICK_RATE, time_scale)
	return source_drill_output_rate(block_id, item_id, ore_count) * scaled_source_delta / SOURCE_TICK_RATE * warmup

func source_drill_output_delta_for_cell(x: int, y: int, item_id: String, ore_count: int, seconds: float, warmup := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_drill_output_delta(str(sprite.get_meta("source_block_id", "")), item_id, ore_count, seconds, float(sprite.get_meta("source_block_time_scale", 1.0)), warmup)

func source_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	if dominant_items > 0 and progress >= delay and items_total < item_capacity:
		var amount := int(progress / delay)
		return {"amount": amount, "progress": fmod(progress, delay)}
	return {"amount": 0, "progress": progress}

func source_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	if not has_dominant_item:
		return 0.0
	return clampf(progress / delay, 0.0, 1.0)

func source_conveyor_world_speed(block_id: String) -> float:
	if content_catalog == null:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return 0.0
	return float(block.properties.get("speed", 0.0)) * float(tile_size) * SOURCE_CONVEYOR_TILE_SPEED_SCALE

func source_conveyor_path_progress_rate(block_id: String) -> float:
	if path_points.size() < 2:
		return 0.0
	var path_length := float(max(1, path_points.size() - 1) * tile_size)
	return source_conveyor_world_speed(block_id) / path_length

func source_conveyor_path_progress_delta(block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	var scaled_source_delta := source_building_edelta(seconds * SOURCE_TICK_RATE, time_scale, efficiency)
	return source_conveyor_path_progress_rate(block_id) * scaled_source_delta / SOURCE_TICK_RATE

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

func source_bullet_texture(sprite_id: String) -> Texture2D:
	var path := "res://assets/core/assets-raw/sprites/effects/%s.png" % sprite_id
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

func source_core_accept_item(item_id: String) -> bool:
	return core_item_count(item_id) < core_item_capacity

func source_core_handle_item(item_id: String) -> bool:
	if not source_core_accept_item(item_id):
		return false
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
		return {"removed": 0, "remaining": item_count}
	var removed := mini(amount, item_count)
	return {"removed": removed, "remaining": item_count - removed}

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

func source_building_should_consume_state(enabled_state: bool) -> bool:
	return enabled_state

func source_building_production_valid_state() -> bool:
	return true

func source_building_consume_trigger_valid_state() -> bool:
	return false

func source_building_power_production_state() -> float:
	return 0.0

func source_building_progress_increase(base_time: float, edelta_value: float) -> float:
	return 1.0 / base_time * edelta_value

func source_building_display_efficiency(edelta_value: float) -> float:
	return source_building_progress_increase(1.0, edelta_value) / edelta_value

func source_building_should_ambient_sound(should_consume_state: bool) -> bool:
	return should_consume_state

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
		return {"recache": false}
	return {"recache": true, "building_cache_layer": building_cache_layer, "tile": tile_state}

func source_building_payload_draw_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var cached_draw := {}
	var dynamic_draw := {}
	if draw_cached:
		cached_draw = source_building_draw_cached_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)
	if draw_dynamic:
		dynamic_draw = source_building_draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)
	return {"saved_z": current_z, "cached_visible": draw_cached, "cached_z": building_cache_layer_z, "cached_draw": cached_draw, "dynamic_visible": draw_dynamic, "dynamic_z": current_z, "dynamic_draw": dynamic_draw}

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

func source_building_player_placed_state(config_state: Variant) -> Variant:
	return config_state

func source_building_placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	if net_client:
		return {"returned": true, "power_link_scan": false, "configure": false, "configure_pos": -1}
	var should_link_power := (consumes_power or outputs_power) and has_power and connected_power
	if not should_link_power:
		return {"returned": false, "power_link_scan": false, "configure": false, "configure_pos": -1}
	var configure := not linked_to_self
	return {"returned": false, "power_link_scan": true, "configure": configure, "configure_pos": source_pos if configure else -1}

func source_building_on_repaired_state(has_fog_radius: bool) -> Dictionary:
	return {"placed": true, "fog_force_update": has_fog_radius}

func source_building_is_commandable_state(block_commandable: bool) -> bool:
	return block_commandable

func source_building_is_payload_state(tile_is_empty_tile: bool) -> bool:
	return tile_is_empty_tile

func source_building_overwrote_state(previous_state: Variant) -> Variant:
	return previous_state

func source_building_on_removed_state(current_state: Variant) -> Variant:
	return current_state

func source_building_unit_on_state(unit_state: Variant) -> Variant:
	return unit_state

func source_building_unit_on_any_state(unit_state: Variant) -> Variant:
	return unit_state

func source_building_unit_removed_state(unit_state: Variant) -> Variant:
	return unit_state

func source_building_puddle_on_state(puddle_state: Variant) -> Variant:
	return puddle_state

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

func source_building_tapped_state(current_state: Variant) -> Variant:
	return current_state

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

func source_building_splash_liquid_state(amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	var splash := clampf(amount / 4.0, 0.0, 10.0)
	var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))
	var delays: Array[float] = []
	for i in deposit_count:
		delays.append(float(i) / 2.0)
	return {
		"splash": splash,
		"deposit_count": deposit_count,
		"delays": delays,
		"random_range": float(source_block_size) * source_tilesize / 2.0,
		"deposit_if_tile_exists": true,
	}

func source_building_on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	var can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid
	if not has_liquids_module or current_amount <= 0.0 or not can_drop_liquid:
		return {"deposit_linked_tiles": false, "per_cell": 0.0}
	return {
		"deposit_linked_tiles": true,
		"per_cell": current_amount / float(source_block_size * source_block_size) * 2.0,
	}

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
	return {"explosiveness": explosiveness, "flammability": flammability, "power": power}

func source_building_on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	var explosiveness := current_explosiveness
	var flammability := current_flammability
	if has_liquids:
		for liquid_state in liquid_states:
			flammability += float(liquid_state.get("flammability", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
			explosiveness += float(liquid_state.get("explosiveness", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
	return {"explosiveness": explosiveness, "flammability": flammability}

func source_building_on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> float:
	if has_cons_power and cons_power_buffered:
		return current_power + power_status * cons_power_capacity
	return current_power

func source_building_on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	var should_splash := has_liquids and damage_explosions
	return {
		"splash_liquids": should_splash,
		"liquid_count": liquid_states.size() if should_splash else 0,
		"liquids": liquid_states.duplicate() if should_splash else [],
	}

func source_building_on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	return {
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
		"create_rubble": should_create_rubble,
		"x": source_x,
		"y": source_y,
		"size": source_block_size if should_create_rubble else 0,
	}

func source_building_on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var should_play_sound := not headless
	return {
		"play_destroy_sound": should_play_sound,
		"sound": destroy_sound if should_play_sound else "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}

func source_building_on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var should_play_reactive_sound := not headless
	var silent_state := {
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
			"play_power_sound": true,
			"power_sound_kind": "big",
			"sound": "blockExplodeElectricBig",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		}
	if power > 2000.0:
		return {
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
	if clear_on_double_tap:
		if same_building:
			return {"deselect": true, "configure_null": true, "consumed": false}
		return {"deselect": false, "configure_null": false, "consumed": true}
	return {"deselect": false, "configure_null": false, "consumed": not same_building}
func source_building_on_configure_tapped_state(_x: float, _y: float) -> bool:
	return false
func source_building_on_configure_closed_state() -> void:
	pass
func source_building_configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return {"should_show": true, "should_hide": false}

func source_building_should_show_configure_state(_player: Variant) -> bool:
	return bool(source_building_configure_menu_visibility_state(_player)["should_show"])

func source_building_should_hide_configure_state(_player: Variant) -> bool:
	return bool(source_building_configure_menu_visibility_state(_player)["should_hide"])
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

func source_building_picked_up_state(previous_state: Variant) -> Variant:
	return previous_state

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
		"on_proximity_removed": true,
		"tmp_tiles_cleared": true,
		"nearby_count": nearby_count,
		"queued_removals": clampi(removable_count, 0, nearby_count),
		"proximity_updates": clampi(removable_count, 0, nearby_count),
		"proximity_cleared": true,
	}

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

func source_building_on_nearby_build_added_state(other_state: Variant) -> Variant:
	return other_state

func source_building_consume_state(consumers: Array, self_state: Variant) -> Dictionary:
	var triggered: Array = []
	for consumer in consumers:
		triggered.append({"consumer": consumer, "self": self_state})
	return {"triggered": triggered}

func source_building_can_consume_state(potential_efficiency: float) -> bool:
	return potential_efficiency > 0.0

func source_building_efficiency_scale_state() -> float:
	return 1.0

func source_building_update_efficiency_multiplier_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return {
		"efficiency": efficiency * efficiency_scale,
		"optional_efficiency": optional_efficiency * efficiency_scale,
	}

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

func source_building_update_consumption_setup_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return {
		"update": should_consume_state and production_valid,
		"min_efficiency": 1.0,
		"efficiency": 1.0,
		"optional_efficiency": 1.0,
		"should_consume_power": true,
	}

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

func source_building_update_consumption_optional_pass_state(optional_consumer_results: Array) -> Dictionary:
	var optional_efficiency := 1.0
	for result in optional_consumer_results:
		optional_efficiency = min(optional_efficiency, float(result))
	return {
		"optional_efficiency": optional_efficiency,
	}

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
		"x": world_x / source_tilesize,
		"y": world_y / source_tilesize,
	}

func source_building_sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"efficiency": efficiency,
		"timescale": time_scale,
		"range": ranged_range / source_tilesize if has_range else 0.0,
		"rotation": rotation_value,
	}

func source_building_sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:
	return {
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
		"item_capacity": block_item_capacity if block_has_items else 0.0,
		"liquid_capacity": block_liquid_capacity if block_has_liquids else 0.0,
		"power_capacity": cons_power_capacity if has_cons_power else 0.0,
		"power_net_in": power_net_in,
		"power_net_out": power_net_out,
		"power_net_stored": power_net_stored,
		"power_net_capacity": power_net_capacity,
	}

func source_building_sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:
	return {
		"enabled": 1.0 if enabled_state else 0.0,
		"controlled": ctrl_player_value if is_control_block and is_controlled else 0.0,
	}

func source_building_sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:
	var payload_count := 0.0
	if has_payload_seq:
		payload_count += payload_seq_total
	if has_single_payload:
		payload_count += 1.0
	return {
		"payload_count": payload_count,
		"size": block_size_value,
	}

func source_building_sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	match sensor:
		"type":
			return {"no_sensed": false, "value": block_value}
		"firstItem":
			return {"no_sensed": false, "value": first_item_value if has_items_module else null}
		"config":
			return {"no_sensed": false, "value": config_value if config_senseable else null}
		"payloadType":
			if single_payload_kind == "unit" or single_payload_kind == "block":
				return {"no_sensed": false, "value": single_payload_content}
			return {"no_sensed": false, "value": null}
		_:
			return {"no_sensed": true, "value": null}

func source_building_sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	if content_type == "item" and has_items_module:
		return {"sensed": true, "value": item_amount}
	if content_type == "liquid" and has_liquids_module:
		return {"sensed": true, "value": liquid_amount}
	if (content_type == "unit" or content_type == "block") and has_payloads:
		return {"sensed": true, "value": payload_amount}
	return {"sensed": false, "value": null}

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
	if prop != "health":
		return {"health": current_health, "build_destroyed_called": false, "build_destroyed": null, "health_changed": false}
	var next_health := clampf(value, 0.0, max_health_value)
	if next_health <= 0.0 and not dead_state:
		return {"health": next_health, "build_destroyed_called": true, "build_destroyed": self_state, "health_changed": false}
	return {"health": next_health, "build_destroyed_called": false, "build_destroyed": null, "health_changed": true}

func source_building_set_prop_team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	if prop != "team":
		return {"team_id": current_team_id, "change_team_called": false, "change_team": null}
	var next_team_id := int(value)
	if current_team_id != next_team_id:
		return {"team_id": next_team_id, "change_team_called": true, "change_team": next_team_id}
	return {"team_id": current_team_id, "change_team_called": false, "change_team": null}

func source_building_set_prop_total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	if prop == "totalPower" and has_power and has_cons_power and cons_power_buffered:
		var next_status := clampf(value / cons_power_capacity, 0.0, 1.0)
		return {"power_status": next_status, "updated": true}
	return {"power_status": current_power_status, "updated": false}

func source_building_set_prop_team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	if prop == "team" and value_is_team and current_team_value != team_value:
		return {"team": team_value, "change_team_called": true, "change_team": team_value}
	return {"team": current_team_value, "change_team_called": false, "change_team": null}

func source_building_set_prop_item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	if content_type != "item" or not has_items_module:
		return {"action": "none", "item": item_value, "amount": current_amount, "delta": 0, "accepted": 0}
	var amount := int(value)
	if current_amount == amount:
		return {"action": "none", "item": item_value, "amount": amount, "delta": 0, "accepted": 0}
	if current_amount < amount:
		return {"action": "handle_stack", "item": item_value, "amount": amount, "delta": amount - current_amount, "accepted": accepted_stack}
	if amount >= 0:
		return {"action": "remove_stack", "item": item_value, "amount": amount, "delta": current_amount - amount, "accepted": 0}
	return {"action": "none", "item": item_value, "amount": amount, "delta": 0, "accepted": 0}

func source_building_set_prop_liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, block_consumes_liquid: bool) -> Dictionary:
	if content_type != "liquid" or not has_liquids_module:
		return {"action": "none", "liquid": liquid_value, "amount": current_amount}
	var amount := clampf(value, 0.0, block_liquid_capacity)
	var can_set := amount < current_amount
	if not can_set:
		can_set = accept_liquid_result and (current_liquid_matches or current_amount <= 0.1 or block_consumes_liquid)
	if can_set:
		return {"action": "set_liquid", "liquid": liquid_value, "amount": amount}
	return {"action": "none", "liquid": liquid_value, "amount": current_amount}

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
		"dead": true,
		"event": {"type": "BlockDestroyEvent", "tile": tile_value},
		"on_destroyed_called": true,
		"next_step": "tile_remove_gate",
	}

func source_building_killed_removal_side_effects_state(tile_is_empty_tile: bool) -> Dictionary:
	return {
		"tile_remove_called": not tile_is_empty_tile,
		"remove_called": true,
		"after_destroyed_called": true,
	}

func source_building_check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	if not allow_update_result:
		return {"enabled": false, "changed": current_enabled}
	return {"enabled": current_enabled, "changed": false}

func source_building_update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	var next_duration := current_time_scale_duration - time_delta
	if next_duration <= 0.0:
		return {"time_scale": 1.0, "time_scale_duration": next_duration}
	return {"time_scale": current_time_scale, "time_scale_duration": next_duration}

func source_building_update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	var should_loop: bool = not headless_mode and ambient_sound_value != sounds_none_value and should_ambient_sound_result
	if not should_loop:
		return {"loop_called": false, "sound": ambient_sound_value, "volume": 0.0}
	return {"loop_called": true, "sound": ambient_sound_value, "volume": block_ambient_sound_volume * ambient_volume_value}

func source_building_update_consumption_call_state() -> Dictionary:
	return {"update_consumption_called": true}

func source_building_update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	var update_tile_called: bool = enabled_state or not block_no_update_disabled
	return {"update_tile_called": update_tile_called}

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
		raw_progress += source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, delta, drill_warmup) * drill_delay
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
	var output_delta := source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, seconds, warmup_after)
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
	return float(sprite.get_meta("source_block_health", 0.0)) < float(sprite.get_meta("source_block_max_health", 0.0))

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

func source_angle_to_target(origin: Vector2, target) -> float:
	if target == null:
		return 0.0
	var sprite = target.get("sprite")
	if not is_instance_valid(sprite):
		return 0.0
	var direction: Vector2 = sprite.position - origin
	if direction == Vector2.ZERO:
		return 0.0
	return rad_to_deg(direction.angle())

func source_angle_distance(current_degrees: float, target_degrees: float) -> float:
	return abs(wrapf(target_degrees - current_degrees, -180.0, 180.0))

func source_move_angle_toward(current_degrees: float, target_degrees: float, max_delta: float) -> float:
	var delta := wrapf(target_degrees - current_degrees, -180.0, 180.0)
	if abs(delta) <= max_delta:
		return target_degrees
	return current_degrees + sign(delta) * max_delta

func source_bullet_range_change(data: Dictionary) -> float:
	return float(data.get("rangeChange", 0.0))

func source_bullet_inaccuracy(data: Dictionary) -> float:
	return float(data.get("inaccuracy", 0.0))

func source_turret_total_inaccuracy(turret, data: Dictionary) -> float:
	return source_turret_inaccuracy(turret) + source_bullet_inaccuracy(data)

func source_turret_range_for_ammo(turret, data: Dictionary) -> float:
	return source_turret_range(turret) + source_bullet_range_change(data)

func source_bullet_lifetime_seconds(data: Dictionary) -> float:
	return float(data.get("lifetime", 40.0)) / 60.0

func source_bullet_world_speed(data: Dictionary) -> float:
	return float(data.get("speed", 1.0)) * 60.0

func source_bullet_velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(shoot_angle_degrees)) * source_bullet_world_speed(data)

func source_bullet_hit_size(data: Dictionary) -> float:
	return float(data.get("hitSize", 4.0))

func source_bullet_damage(data: Dictionary) -> float:
	return float(data.get("damage", 1.0))

func source_bullet_ammo_multiplier(data: Dictionary) -> float:
	return float(data.get("ammoMultiplier", 2.0))

func source_bullet_reload_multiplier(data: Dictionary) -> float:
	return float(data.get("reloadMultiplier", 1.0))

func source_bullet_scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	var width := float(data.get("width", 4.0))
	var height := float(data.get("height", width))
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
	sprite.texture = source_bullet_texture(str(data.get("sprite", "bullet")))
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
