extends RefCounted
class_name Vec2

var x: float = 0.0
var y: float = 0.0

func _init(px: float = 0.0, py: float = 0.0) -> void:
	x = px
	y = py

func to_vector2() -> Vector2:
	return Vector2(x, y)
