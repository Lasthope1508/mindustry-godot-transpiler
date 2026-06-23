extends "res://src/mindustry/content/UnlockableContent.gd"
class_name MindustryItem

var color_hex := ""
var hardness := 0
var cost := 1.0
var flammability := 0.0
var explosiveness := 0.0
var radioactivity := 0.0
var charge := 0.0
var buildable := true

func _init(data: Dictionary = {}) -> void:
	super(data, "item")
	color_hex = str(data.get("color", ""))
	hardness = int(properties.get("hardness", 0))
	cost = float(properties.get("cost", 1.0))
	flammability = float(properties.get("flammability", 0.0))
	explosiveness = float(properties.get("explosiveness", 0.0))
	radioactivity = float(properties.get("radioactivity", 0.0))
	charge = float(properties.get("charge", 0.0))
	buildable = bool(properties.get("buildable", true))
