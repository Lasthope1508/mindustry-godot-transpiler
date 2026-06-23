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
const SOURCE_CONVEYOR_TILE_SPEED_SCALE := 55.0

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
var initial_world_block_count := 0
var initial_occupied_cell_count := 0
var last_placed_block_id := ""
var last_placed_block_size := 0
var last_placed_cell := Vector2i.ZERO
var last_placed_occupied_cell_count := 0
var last_place_blocked := false
var core_inventory := 0
var core_items: Dictionary = {"copper": 0}
var core_item_capacity := 0
var core_max_health := 0.0
var core_health := 0.0
var drill_output_item_id := "copper"
var drill_ore_cell_count := 0
var drill_output_rate := 0.0
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
var turret_shot_count := 0
var last_turret_fired_ammo_item := ""
var last_turret_fired_damage := 0.0
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

func place_selected_block_at_mouse() -> void:
	place_selected_block_at_world(get_global_mouse_position())

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

func source_drill_output_rate(block_id: String, item_id: String, ore_count: int) -> float:
	if content_catalog == null or ore_count <= 0:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	var item = content_catalog.get_by_id(item_id)
	if block == null or item == null:
		return 0.0
	var delay := float(block.properties.get("drillTime", 300.0)) + SOURCE_DRILL_HARDNESS_MULTIPLIER * float(item.properties.get("hardness", 0))
	if delay <= 0.0:
		return 0.0
	return 60.0 * float(ore_count) / delay

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

func block_world_size(block) -> float:
	return float(tile_size * block_size(block))

func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:
	sprite.texture = block_texture(block)
	sprite.position = grid_to_world(cell) + Vector2.ONE * (block_world_size(block) - float(tile_size)) * 0.5
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

func unregister_turret_cell(cell: Vector2i) -> void:
	var key := cell_key(cell)
	if not turret_cooldowns.has(key):
		return
	turret_cooldowns.erase(key)
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
	simulate_factory(delta)
	simulate_turrets(delta)
	simulate_bullets(delta)
	simulate_enemy_units(delta)
	update_camera(delta)
	update_hud()

func simulate_factory(delta: float) -> void:
	if path_points.is_empty():
		return
	if drill_output_rate > 0.0:
		item_progress += delta * drill_output_rate
		while item_progress >= 1.0:
			item_progress -= 1.0
			add_core_item(drill_output_item_id, 1)
			produced_total += 1
	transport_progress = fmod(transport_progress + delta * conveyor_path_progress_rate, 1.0)
	for i in item_sprites.size():
		var phase := fmod(transport_progress + float(i) / float(item_sprites.size()), 1.0)
		var idx := int(floor(phase * float(path_points.size() - 1)))
		var next_idx = min(idx + 1, path_points.size() - 1)
		var local_t := fmod(phase * float(path_points.size() - 1), 1.0)
		item_sprites[i].position = path_points[idx].lerp(path_points[next_idx], local_t)
		item_sprites[i].visible = true

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
	var reload_seconds := source_turret_reload_seconds(duo)
	var range_pixels := source_turret_range(duo)
	for cell in turret_cells:
		var key := cell_key(cell)
		var cooldown = max(0.0, float(turret_cooldowns.get(key, 0.0)) - delta)
		if cooldown <= 0.0:
			var target = find_enemy_target(grid_to_world(cell), range_pixels)
			if target != null:
				var data := use_turret_ammo(cell, duo)
				if not data.is_empty():
					spawn_turret_bullet(grid_to_world(cell), target, data)
					cooldown = reload_seconds
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

func source_turret_reload_seconds(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("reload", 10.0)) / 60.0

func source_turret_range(turret) -> float:
	if turret == null:
		return 0.0
	return float(turret.properties.get("range", 80.0))

func source_bullet_lifetime_seconds(data: Dictionary) -> float:
	return float(data.get("lifetime", 40.0)) / 60.0

func source_bullet_world_speed(data: Dictionary) -> float:
	return float(data.get("speed", 1.0)) * 60.0

func source_bullet_hit_size(data: Dictionary) -> float:
	return float(data.get("hitSize", 4.0))

func source_bullet_damage(data: Dictionary) -> float:
	return float(data.get("damage", 1.0))

func source_bullet_ammo_multiplier(data: Dictionary) -> float:
	return float(data.get("ammoMultiplier", 2.0))

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

func spawn_turret_bullet(origin: Vector2, target, data: Dictionary) -> void:
	if data.is_empty():
		return
	last_turret_fired_ammo_item = str(data.get("item", ""))
	last_turret_fired_damage = source_bullet_damage(data)
	turret_shot_count += 1
	var sprite := Sprite2D.new()
	sprite.texture = source_bullet_texture(str(data.get("sprite", "bullet")))
	sprite.position = origin
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = source_bullet_scale(data, size)
	get_node("World/BulletLayer").add_child(sprite)
	bullets.append({"sprite": sprite, "target": target, "speed": source_bullet_world_speed(data), "damage": source_bullet_damage(data), "hit_size": source_bullet_hit_size(data), "lifetime_remaining": source_bullet_lifetime_seconds(data)})

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
		var direction: Vector2 = target_sprite.position - sprite.position
		if direction.length() <= float(bullet.get("hit_size", 4.0)):
			target["health"] = float(target.get("health", 0.0)) - float(bullet.get("damage", 1.0))
			if float(target.get("health", 0.0)) <= 0.0:
				target_sprite.queue_free()
			sprite.queue_free()
			continue
		sprite.position += direction.normalized() * float(bullet.get("speed", 100.0)) * delta
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
		"selected_turret_ammo_sprite": selected_turret_ammo_sprite(),
		"selected_turret_ammo_lifetime_seconds": selected_turret_ammo_lifetime_seconds(),
		"selected_turret_ammo_world_speed": selected_turret_ammo_world_speed(),
		"selected_turret_ammo_dimensions": selected_turret_ammo_dimensions(),
		"selected_turret_ammo_hit_size": selected_turret_ammo_hit_size(),
		"selected_turret_ammo_damage": selected_turret_ammo_damage(),
		"selected_turret_ammo_multiplier": selected_turret_ammo_multiplier(),
		"selected_turret_ammo_count": selected_turret_ammo_count(),
		"selected_turret_max_ammo": selected_turret_max_ammo(),
		"selected_turret_ammo_per_shot": selected_turret_ammo_per_shot(),
		"selected_turret_consume_ammo_once": selected_turret_consume_ammo_once(),
		"selected_turret_total_ammo": selected_turret_total_ammo(),
		"selected_turret_ammo_stack_count": selected_turret_ammo_stack_count(),
		"selected_turret_loaded_ammo_item": selected_turret_loaded_ammo_item(),
		"selected_turret_reload_seconds": selected_turret_reload_seconds(),
		"selected_turret_range": selected_turret_range(),
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
