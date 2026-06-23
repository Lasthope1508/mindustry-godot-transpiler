extends "res://src/mindustry/content/UnlockableContent.gd"
class_name MindustryBlock

var size := 1
var health := 0
var category := ""
var reload := 0.0
var attack_range := 0.0
var ammo: Array = []

func _init(data: Dictionary = {}) -> void:
	super(data, "block")
	size = int(properties.get("size", 1))
	health = int(properties.get("health", 0))
	category = str(properties.get("category", ""))
	reload = float(properties.get("reload", 0.0))
	attack_range = float(properties.get("range", 0.0))
	ammo = properties.get("ammo", [])

func is_core() -> bool:
	return implementation == "CoreBlock"

func is_distribution() -> bool:
	return implementation in ["Conveyor", "StackConveyor", "ArmoredConveyor", "Router", "Junction"]

func is_turret() -> bool:
	return implementation in ["ItemTurret", "PowerTurret", "LiquidTurret", "ContinuousTurret"]
