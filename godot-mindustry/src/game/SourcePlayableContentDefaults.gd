extends RefCounted
class_name SourcePlayableContentDefaults

const ITEM_COPPER := "copper"
const BLOCK_STONE_FLOOR := "stone_floor"
const BLOCK_ORE_COPPER := "ore_copper"
const BLOCK_MECHANICAL_DRILL := "mechanical-drill"
const BLOCK_CONVEYOR := "conveyor"
const BLOCK_ROUTER := "router"
const BLOCK_JUNCTION := "junction"
const BLOCK_CORE_SHARD := "core-shard"
const BLOCK_DUO := "duo"
const BLOCK_SOLAR_PANEL := "solar-panel"
const BLOCK_BATTERY := "battery"
const BLOCK_LANCER := "lancer"
const BLOCK_MECHANICAL_PUMP := "mechanical-pump"
const BLOCK_CONDUIT := "conduit"
const BLOCK_COPPER_WALL := "copper-wall"

static func selected_generated_class_names() -> Array[String]:
	return ["Items", "Blocks", "UnitTypes", "Damage"]

static func pinned_build_block_ids() -> Array[String]:
	return [BLOCK_CONVEYOR, BLOCK_ROUTER, BLOCK_JUNCTION, BLOCK_MECHANICAL_DRILL, BLOCK_DUO, BLOCK_COPPER_WALL]
