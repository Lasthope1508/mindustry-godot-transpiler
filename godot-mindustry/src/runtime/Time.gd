extends RefCounted
class_name MindustryTime

static var delta: float = 0.0
static var time: float = 0.0

static func update(delta_seconds: float) -> void:
	delta = delta_seconds
	time += delta_seconds
