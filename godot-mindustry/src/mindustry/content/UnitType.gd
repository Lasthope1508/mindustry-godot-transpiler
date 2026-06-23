extends "res://src/mindustry/content/UnlockableContent.gd"
class_name MindustryUnitType

var speed := 0.0
var health := 0.0
var hit_size := 0.0

func _init(data: Dictionary = {}) -> void:
	super(data, "unit")
	speed = float(properties.get("speed", 0.0))
	health = float(properties.get("health", 0.0))
	hit_size = float(properties.get("hitSize", 0.0))

func move_speed_pixels(tile_size: int) -> float:
	return max(20.0, speed * float(tile_size) * 5.0)
