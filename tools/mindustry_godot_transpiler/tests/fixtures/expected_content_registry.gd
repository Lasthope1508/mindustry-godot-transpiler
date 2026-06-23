# Generated from Mindustry upstream.
# Source: core/src/mindustry/content/{Items,Liquids,Blocks,UnitTypes}.java
# Upstream commit: 2bdedfed25932ebf11330d3584092c50e2e26d96
# Do not edit by hand.
extends RefCounted
class_name MindustryContentRegistry

const UPSTREAM_COMMIT := "2bdedfed25932ebf11330d3584092c50e2e26d96"
const COUNTS := {"blocks": 1, "items": 1, "liquids": 0, "units": 1}
const ITEMS := [{"color": "d99d73", "field": "copper", "id": "copper", "implementation": "Item", "properties": {"hardness": 1}, "texture": "res://assets/core/assets-raw/sprites/items/item-copper.png"}]
const LIQUIDS := []
const BLOCKS := [{"field": "duo", "id": "duo", "implementation": "ItemTurret", "properties": {"ammo": [{"damage": 9, "item": "copper", "lifetime": 60.0, "speed": 2.5}], "range": 110.0, "reload": 20.0}, "texture": "res://assets/core/assets-raw/sprites/blocks/turrets/duo.png"}]
const UNITS := [{"field": "dagger", "id": "dagger", "implementation": "UnitType", "properties": {"health": 150, "hitSize": 8.0, "speed": 0.5}, "texture": "res://assets/core/assets-raw/sprites/units/dagger.png"}]
const WAVES := {"groups": [{"end": 10, "max": 30, "unit": "dagger", "unitScaling": 2.0}], "version": 7}

static func counts() -> Dictionary:
	return COUNTS
