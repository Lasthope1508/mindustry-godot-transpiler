extends "res://src/mindustry/content/UnlockableContent.gd"
class_name MindustryLiquid

var color_hex := ""
var gas := false
var temperature := 0.5
var viscosity := 0.5
var flammability := 0.0
var explosiveness := 0.0
var heat_capacity := 0.5

func _init(data: Dictionary = {}) -> void:
	super(data, "liquid")
	color_hex = str(data.get("color", ""))
	gas = bool(properties.get("gas", false))
	temperature = float(properties.get("temperature", 0.5))
	viscosity = float(properties.get("viscosity", 0.5))
	flammability = float(properties.get("flammability", 0.0))
	explosiveness = float(properties.get("explosiveness", 0.0))
	heat_capacity = float(properties.get("heatCapacity", 0.5))
