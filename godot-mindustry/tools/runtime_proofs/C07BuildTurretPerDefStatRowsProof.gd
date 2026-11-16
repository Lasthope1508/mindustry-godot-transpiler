extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
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

	# --- Per-def stat rows (N2499): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2489 /
	# N2490 / N2498 precedent). The single
	# BuildTurret def build-tower
	# (Blocks.java:1997-2006) sets size 3, range
	# 200f, buildSpeed 1.5f and requirements
	# silicon 150 / oxide 40 / thorium 60. An
	# unknown def id falls back to the CLASS
	# defaults (the N2304 fallback precedent):
	# size 1 (Block.java:215), range 80f -- the
	# range field lives on BaseTurret, NOT on
	# Block or BuildTurret (`public float range =
	# 80f;`, BaseTurret.java:21; `public class
	# BuildTurret extends BaseTurret{`,
	# BuildTurret.java:27), buildSpeed 1f
	# (BuildTurret.java:33) and NO requirements
	# (the Block default is the empty array,
	# Block.java:356). Pure-only: the caller reads
	# it; the existing pures are unchanged.

	# --- Def row: build-tower -- size 3, range
	# 200f, buildSpeed 1.5f, requirements silicon
	# 150 / oxide 40 / thorium 60.
	var turret: Dictionary = build_turret_build_state.source_build_turret_per_def_stats_state("build-tower")
	var turret_requirements: Dictionary = turret.get("requirements", {})
	proof["stats_turret"] = int(turret.get("size", -1)) == 3 and is_equal_approx(float(turret.get("range_value", -1.0)), 200.0) and is_equal_approx(float(turret.get("build_speed", -1.0)), 1.5) and int(turret_requirements.get("silicon", -1)) == 150 and int(turret_requirements.get("oxide", -1)) == 40 and int(turret_requirements.get("thorium", -1)) == 60

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, range 80f, buildSpeed 1f, and NO
	# requirements.
	var fallback: Dictionary = build_turret_build_state.source_build_turret_per_def_stats_state("no-such-def")
	var empty_fallback: Dictionary = build_turret_build_state.source_build_turret_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("range_value", -1.0)), 80.0) and is_equal_approx(float(fallback.get("build_speed", -1.0)), 1.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and is_equal_approx(float(empty_fallback.get("range_value", -1.0)), 80.0) and is_equal_approx(float(empty_fallback.get("build_speed", -1.0)), 1.0) and empty_requirements.is_empty()

	# --- Size / range: the def is size 3 with
	# range 200f; the class defaults are size 1
	# with range 80f (the BaseTurret field
	# default, BaseTurret.java:21).
	proof["stats_size_range"] = int(turret.get("size", -1)) == 3 and is_equal_approx(float(turret.get("range_value", -1.0)), 200.0) and int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("range_value", -1.0)), 80.0)

	# --- Build speed: the def builds at 1.5f;
	# the class default is 1f
	# (BuildTurret.java:33).
	proof["stats_build_speed"] = is_equal_approx(float(turret.get("build_speed", -1.0)), 1.5) and is_equal_approx(float(fallback.get("build_speed", -1.0)), 1.0)

	# --- Requirements: the def dict carries
	# exactly the three items (silicon 150, oxide
	# 40, thorium 60); the class fallback carries
	# none.
	proof["stats_requirements"] = turret_requirements.size() == 3 and int(turret_requirements.get("silicon", -1)) == 150 and int(turret_requirements.get("oxide", -1)) == 40 and int(turret_requirements.get("thorium", -1)) == 60 and fallback_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2451 stats pure as its caller-supplied
	# build_speed -- the def 1.5f reads stat_value
	# 1.5 (displays as 150%) while the class
	# fallback 1f reads stat_value 1.0 (displays
	# as 100%), both under the exact "buildSpeed"
	# token.
	var def_stats: Dictionary = build_turret_build_state.source_build_turret_stats_state(float(turret.get("build_speed", 0.0)))
	var fallback_stats: Dictionary = build_turret_build_state.source_build_turret_stats_state(float(fallback.get("build_speed", 0.0)))
	proof["stats_live_input"] = is_equal_approx(float(def_stats.get("stat_value", -1.0)), 1.5) and str(def_stats.get("stat_key", "")) == "buildSpeed" and is_equal_approx(float(fallback_stats.get("stat_value", -1.0)), 1.0) and str(fallback_stats.get("stat_key", "")) == "buildSpeed"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
