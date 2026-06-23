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
var placed_blocks: Dictionary = {}
var core_inventory := 0
var core_health := 500.0
var produced_total := 0
var item_progress := 0.0
var item_sprites: Array[Sprite2D] = []
var enemy_units: Array = []
var bullets: Array = []
var turret_cells: Array = []
var turret_cooldowns: Dictionary = {}
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
	for y in WORLD_H:
		for x in WORLD_W:
			add_sprite(terrain, "stone_floor", grid_to_world(Vector2i(x, y)))
	for y in range(6, 11):
		for x in range(5, 8):
			add_sprite(terrain, "ore_copper", grid_to_world(Vector2i(x, y)))
	add_sprite(blocks, "mechanical_drill", grid_to_world(drill_pos))
	for x in range(drill_pos.x + 1, core_pos.x):
		add_sprite(blocks, "conveyor", grid_to_world(Vector2i(x, drill_pos.y)))
	add_sprite(blocks, "core_shard", grid_to_world(core_pos))
	add_source_block(blocks, "duo", duo_pos)
	path_points.clear()
	for x in range(drill_pos.x + 1, core_pos.x + 1):
		path_points.append(grid_to_world(Vector2i(x, drill_pos.y)))
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

func place_selected_block_at_world(world_pos: Vector2) -> void:
	if build_palette.is_empty():
		return
	var cell := world_to_grid(world_pos)
	if cell.x < 0 or cell.y < 0 or cell.x >= WORLD_W or cell.y >= WORLD_H:
		return
	var block = build_palette[selected_build_index]
	if not can_afford(block):
		return
	var blocks := get_node("World/BlockLayer")
	var key := cell_key(cell)
	if placed_blocks.has(key):
		unregister_turret_cell(cell)
		placed_blocks[key].queue_free()
	spend_requirements(block)
	var sprite := Sprite2D.new()
	sprite.texture = block_texture(block)
	sprite.position = grid_to_world(cell)
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = Vector2(tile_size / size.x, tile_size / size.y)
	blocks.add_child(sprite)
	placed_blocks[key] = sprite
	register_turret_cell(cell, block)

func add_source_block(parent: Node, block_id: String, cell: Vector2i) -> void:
	if content_catalog == null:
		return
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = block_texture(block)
	sprite.position = grid_to_world(cell)
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = Vector2(tile_size / size.x, tile_size / size.y)
	parent.add_child(sprite)
	placed_blocks[cell_key(cell)] = sprite
	register_turret_cell(cell, block)

func register_turret_cell(cell: Vector2i, block) -> void:
	if block == null or not block.is_turret():
		return
	var key := cell_key(cell)
	if not turret_cooldowns.has(key):
		turret_cells.append(cell)
	turret_cooldowns[key] = 0.0

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

func block_texture(block) -> Texture2D:
	if block_texture_cache.has(block.id):
		return block_texture_cache[block.id]
	var texture := load_png_texture(block.texture_path)
	block_texture_cache[block.id] = texture
	return texture

func can_afford(block) -> bool:
	for requirement in block.properties.get("requirements", []):
		if requirement.get("item", "") == "copper" and core_inventory < int(requirement.get("amount", 0)):
			return false
	return true

func spend_requirements(block) -> void:
	for requirement in block.properties.get("requirements", []):
		if requirement.get("item", "") == "copper":
			core_inventory = max(0, core_inventory - int(requirement.get("amount", 0)))

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
	item_progress += delta * 0.45
	if item_progress >= 1.0:
		item_progress -= 1.0
		core_inventory += 1
		produced_total += 1
	for i in item_sprites.size():
		var phase := fmod(item_progress + float(i) / float(item_sprites.size()), 1.0)
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
			sprite.scale = Vector2(tile_size / size.x, tile_size / size.y)
	units_layer.add_child(sprite)
	enemy_units.append({"sprite": sprite, "type": unit_type, "health": float(unit_type.properties.get("health", 100.0))})

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
		if direction.length() <= float(tile_size) * 0.35:
			core_health = max(0.0, core_health - 15.0)
			sprite.queue_free()
			continue
		var unit_type = enemy.get("type")
		var speed = max(20.0, float(unit_type.properties.get("speed", 0.5)) * float(tile_size) * 5.0)
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

func simulate_turrets(delta: float) -> void:
	if content_catalog == null or turret_cells.is_empty():
		return
	var duo = content_catalog.get_by_id("duo")
	if duo == null:
		return
	var reload_seconds = max(0.1, float(duo.properties.get("reload", 60.0)) / 60.0)
	var range_pixels = float(duo.properties.get("range", 0.0))
	for cell in turret_cells:
		var key := cell_key(cell)
		var cooldown = max(0.0, float(turret_cooldowns.get(key, 0.0)) - delta)
		if cooldown <= 0.0:
			var target = find_enemy_target(grid_to_world(cell), range_pixels)
			if target != null:
				spawn_turret_bullet(grid_to_world(cell), target, duo)
				cooldown = reload_seconds
		turret_cooldowns[key] = cooldown

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

func spawn_turret_bullet(origin: Vector2, target, turret) -> void:
	var ammo: Array = turret.properties.get("ammo", [])
	if ammo.is_empty():
		return
	var data: Dictionary = ammo[0]
	var sprite := Sprite2D.new()
	sprite.texture = textures.get("item")
	sprite.position = origin
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = Vector2(tile_size / size.x, tile_size / size.y) * 0.45
	get_node("World/BulletLayer").add_child(sprite)
	bullets.append({"sprite": sprite, "target": target, "speed": float(data.get("speed", 2.5)) * float(tile_size) * 4.0, "damage": float(data.get("damage", 1.0))})

func simulate_bullets(delta: float) -> void:
	var active: Array = []
	for bullet in bullets:
		var sprite = bullet.get("sprite")
		var target = bullet.get("target")
		if not is_instance_valid(sprite) or target == null:
			continue
		var target_sprite = target.get("sprite")
		if not is_instance_valid(target_sprite):
			sprite.queue_free()
			continue
		var direction: Vector2 = target_sprite.position - sprite.position
		if direction.length() <= 6.0:
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
		"placed_block_count": placed_blocks.size(),
		"selected_build_index": selected_build_index,
		"selected_build_id": selected.id if selected else "",
		"core_inventory": core_inventory,
		"wave_index": wave_index,
		"enemy_count": enemy_units.size(),
		"bullet_count": bullets.size(),
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
