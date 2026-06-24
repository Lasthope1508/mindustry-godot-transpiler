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
const SOURCE_CONVEYOR_TILE_SPEED_SCALE := 55.0
const SOURCE_TICK_RATE := 60.0
const SOURCE_RECOIL_POW := 1.8
const SOURCE_PI2 := PI * 2.0

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
		item_progress += source_drill_output_delta_for_cell(drill_pos.x, drill_pos.y, drill_output_item_id, drill_ore_cell_count, delta, drill_warmup)
		while item_progress >= 1.0:
			item_progress -= 1.0
			add_core_item(drill_output_item_id, 1)
			produced_total += 1
	else:
		set_drill_last_speed_at_cell(drill_pos.x, drill_pos.y, 0.0)
	transport_progress = fmod(transport_progress + source_conveyor_path_progress_delta_for_cell(drill_pos.x + 1, drill_pos.y, delta), 1.0)
	for i in item_sprites.size():
		var phase := fmod(transport_progress + float(i) / float(item_sprites.size()), 1.0)
		var idx := int(floor(phase * float(path_points.size() - 1)))
		var next_idx = min(idx + 1, path_points.size() - 1)
		var local_t := fmod(phase * float(path_points.size() - 1), 1.0)
		item_sprites[i].position = path_points[idx].lerp(path_points[next_idx], local_t)
		item_sprites[i].visible = true

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
