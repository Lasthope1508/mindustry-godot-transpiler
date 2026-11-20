extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- BurstDrill getDrillTime() (N2344):
	# BurstDrill.getDrillTime() (`@Override public
	# float getDrillTime(Item item){`,
	# BurstDrill.java:52-53) returns the drill time
	# divided by the per-item multiplier (`return
	# drillTime / drillMultipliers.get(item, 1f);`,
	# BurstDrill.java:54), with NO hardness term: the
	# base Drill formula (`return (drillTime +
	# hardnessDrillMultiplier * item.hardness) /
	# drillMultipliers.get(item, 1f);`, Drill.java:171)
	# is NOT this slice -- the BurstDrill constructor
	# zeroes the field (`hardnessDrillMultiplier = 0f;`,
	# BurstDrill.java:39, "does not drill in the
	# traditional sense, so this is not even used"), so
	# item.hardness is NOT an input. drillTime is the
	# block field (`public float drillTime = 300;`,
	# Drill.java:36); drillMultipliers is (`public
	# ObjectFloatMap<Item> drillMultipliers = new
	# ObjectFloatMap<>();`, Drill.java:66) and defaults a
	# missing item to 1f. There is NO driver tick line:
	# the BurstDrill tick (N2149/N2294/N2296) already
	# reads `float drillTime = getDrillTime(dominantItem);`
	# (BurstDrill.java:87) through its precomputed
	# drill_time_base / drill_multiplier params; this
	# slice ports only the pure function, not the caller.
	# The proof calls the pure function directly with
	# the per-def drill times and multiplier maps (the
	# N2224/N2225 pattern); item ids ride as strings.
	# Both defs share the function (impact-drill,
	# Blocks.java:3070, drillTime 720f; eruption-drill,
	# Blocks.java:3093, drillTime 281.25f); both put
	# beryllium at 2f (Blocks.java:3083/3114).

	var multipliers_beryllium: Dictionary = {"beryllium": 2.0}
	var multipliers_empty: Dictionary = {}

	# impact-drill (drillTime 720f = 60f * 12f,
	# Blocks.java:3072) + beryllium (2f): 720 / 2 = 360.
	var impact_beryllium: Dictionary = burst_drill_build_state.source_burst_drill_get_drill_time_state({}, 720.0, multipliers_beryllium, "beryllium")
	proof["get_drill_time_impact_beryllium"] = impact_beryllium.get("drill_time", -1.0) == 360.0

	# impact-drill + other item (missing from the map,
	# defaults to 1f): 720 / 1 = 720.
	var impact_other: Dictionary = burst_drill_build_state.source_burst_drill_get_drill_time_state({}, 720.0, multipliers_beryllium, "tungsten")
	proof["get_drill_time_impact_other"] = impact_other.get("drill_time", -1.0) == 720.0

	# eruption-drill (drillTime 281.25f,
	# Blocks.java:3095) + beryllium (2f): 281.25 / 2 = 140.625.
	var eruption_beryllium: Dictionary = burst_drill_build_state.source_burst_drill_get_drill_time_state({}, 281.25, multipliers_beryllium, "beryllium")
	proof["get_drill_time_eruption_beryllium"] = eruption_beryllium.get("drill_time", -1.0) == 140.625

	# eruption-drill + other item (missing from the
	# map, defaults to 1f): 281.25 / 1 = 281.25.
	var eruption_other: Dictionary = burst_drill_build_state.source_burst_drill_get_drill_time_state({}, 281.25, multipliers_beryllium, "oxide")
	proof["get_drill_time_eruption_other"] = eruption_other.get("drill_time", -1.0) == 281.25

	# Class default (drillTime 300f, Drill.java:36)
	# with an empty map: 300 / 1 = 300.
	var class_default: Dictionary = burst_drill_build_state.source_burst_drill_get_drill_time_state({}, 300.0, multipliers_empty, "beryllium")
	proof["get_drill_time_class_default"] = class_default.get("drill_time", -1.0) == 300.0

	# The no-hardness trap: impact-drill + beryllium
	# (hardness 3, Items.java:107) gives 720 / 2 = 360
	# under the override -- NOT the base formula's
	# (720 + 50 * 3) / 2 = 435.
	proof["get_drill_time_no_hardness_term"] = impact_beryllium.get("drill_time", -1.0) == 360.0 and impact_beryllium.get("drill_time", -1.0) != 435.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillGetDrillTimeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
