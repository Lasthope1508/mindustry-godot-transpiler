extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _drill_case(block_name: String, ambient_sound: Variant, group: Variant) -> Dictionary:
	return state.source_drill_default_constructor_state({}, block_name, ambient_sound, group)


func _burst_case(block_name: String, ambient_sound: Variant, drill_effect: Variant) -> Dictionary:
	return state.source_burst_drill_default_constructor_state({}, block_name, ambient_sound, drill_effect)


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

	# --- Drill(String name) + BurstDrill(String name) (N2403):
	# Drill(String name) (Drill.java:76-88) sets the three
	# Drill-only field defaults: the block group (`group =
	# BlockGroup.drills;`) and the ambient sound
	# (`ambientSound = Sounds.loopDrill;`,
	# `ambientSoundVolume = 0.019f;`).
	# BurstDrill(String name) (BurstDrill.java:35-45) sets
	# the four BurstDrill-only field defaults: the drill
	# effect (`drillEffectRnd = 0f;`, `drillEffect =
	# Fx.shockwave;`) and the ambient sound
	# (`ambientSoundVolume = 0.18f;`, `ambientSound =
	# Sounds.drillCharge;`). The proof drives the pure
	# functions with synthetic frames (no live tick):
	# mechanical-drill (Blocks.java:2865) and
	# impact-drill (Blocks.java:3070) names; the ambient
	# sound, group and drill-effect params pass through
	# in both shapes. NOT ambient C (N2304 HELD -- the
	# SoundControl updateLoops mixer), NO driver tick
	# line: the ctors are load-time block definition setup.

	# The Drill block name passes through.
	var drill: Dictionary = _drill_case("mechanical-drill", "loopDrill", "drills")
	proof["defaults_drill_name_passthrough"] = drill.get("name", null) == "mechanical-drill"

	# The Drill block group passes through.
	proof["defaults_drill_group_passthrough"] = drill.get("group", null) == "drills"

	# The Drill ambient sound ref passes through.
	proof["defaults_drill_ambient_sound_passthrough"] = drill.get("ambient_sound", null) == "loopDrill"

	# The Drill ambient sound volume is 0.019 (the Block
	# base default is 0.05, Block.java:353).
	proof["defaults_drill_ambient_sound_volume"] = is_equal_approx(float(drill.get("ambient_sound_volume", -1.0)), 0.019)

	# The Drill result carries ONLY its own keys, and a
	# second call with another block name passes its name
	# through too.
	var drill2: Dictionary = _drill_case("laser-drill", "loopDrill", "drills")
	proof["returns_only_drill_keys"] = drill.size() == 4 and drill2.size() == 4 and drill2.get("name", null) == "laser-drill"

	# The BurstDrill block name passes through.
	var burst: Dictionary = _burst_case("impact-drill", "drillCharge", "shockwave")
	proof["defaults_burst_name_passthrough"] = burst.get("name", null) == "impact-drill"

	# The drill effect random factor is 0 (the Drill base
	# default is -1, Drill.java:55).
	proof["defaults_burst_drill_effect_rnd"] = is_equal_approx(float(burst.get("drill_effect_rnd", -1.0)), 0.0)

	# The drill effect ref passes through.
	proof["defaults_burst_drill_effect_passthrough"] = burst.get("drill_effect", null) == "shockwave"

	# The BurstDrill ambient sound volume is 0.18 (the
	# Block base default is 0.05, Block.java:353).
	proof["defaults_burst_ambient_sound_volume"] = is_equal_approx(float(burst.get("ambient_sound_volume", -1.0)), 0.18)

	# The BurstDrill ambient sound ref passes through.
	proof["defaults_burst_ambient_sound_passthrough"] = burst.get("ambient_sound", null) == "drillCharge"

	# The BurstDrill result carries ONLY its own keys, and
	# a second call with another block name passes its name
	# through too.
	var burst2: Dictionary = _burst_case("eruption-drill", "drillCharge", "shockwave")
	proof["returns_only_burst_keys"] = burst.size() == 5 and burst2.size() == 5 and burst2.get("name", null) == "eruption-drill"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillBurstDrillDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
