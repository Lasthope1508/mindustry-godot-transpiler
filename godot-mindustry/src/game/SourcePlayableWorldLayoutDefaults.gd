extends RefCounted
class_name SourcePlayableWorldLayoutDefaults

const WORLD_SIZE := Vector2i(48, 32)
const WORLD_BACKGROUND_MIN_CELLS := Vector2i(160, 90)
const ORE_COPPER_MIN := Vector2i(5, 6)
const ORE_COPPER_MAX := Vector2i(7, 10)
# South of the Drill at (7, 8); a free 4x4 region for the shallow-water
# floor, so a pump has water to pump (C04). No building or ore there.
const WATER_MIN := Vector2i(5, 14)
const WATER_MAX := Vector2i(8, 17)
const DRILL_POS := Vector2i(7, 8)
const CORE_POS := Vector2i(17, 8)
# East of the size-3 Core footprint (x 16..18); the old (18, 7) was a
# Core cell, and Tile.setBlock removes any Building on its footprint.
const DUO_POS := Vector2i(19, 7)
# East of the size-1 Duo at (19, 7); a free size-1 cell for the solar
# panel, the bootstrap world's power producer.
const SOLAR_PANEL_POS := Vector2i(21, 7)
const BATTERY_POS := Vector2i(23, 7)
const LANCER_POS := Vector2i(25, 7)
