extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- Per-def stat rows (N2497): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2490
	# precedent). The single ImpactReactor def
	# impact-reactor (Blocks.java:2632-2645) sets
	# size 4, health 900, powerProduction 130f,
	# itemDuration 140f, liquidCapacity 80f and
	# requirements lead 500 / silicon 300 /
	# graphite 400 / thorium 100 / surge-alloy 250
	# / metaglass 250. An unknown def id falls back
	# to the CLASS defaults (the N2304 fallback
	# precedent): size 1 (Block.java:215), health 40
	# POST-INIT (the class field is the -1 sentinel,
	# Block.java:190, resolved by init() to
	# round(1 * 1 * 40, 5) = 40, Block.java:1378-1395),
	# powerProduction 0f (declared without an
	# initializer, PowerGenerator.java:25),
	# itemDuration 60f (ImpactReactor.java:20),
	# liquidCapacity 30f (ImpactReactor.java:26)
	# and NO requirements (the Block default is the
	# empty array, Block.java:356). Pure-only: the
	# caller reads it; the advance + shouldConsume
	# pures take these values as caller-supplied
	# inputs and are unchanged.

	# --- Def row: impact-reactor -- size 4, health
	# 900, powerProduction 130f, itemDuration 140f,
	# liquidCapacity 80f, requirements lead 500 /
	# silicon 300 / graphite 400 / thorium 100 /
	# surge-alloy 250 / metaglass 250.
	var reactor: Dictionary = impact_reactor_build_state.source_impact_reactor_per_def_stats_state("impact-reactor")
	var reactor_requirements: Dictionary = reactor.get("requirements", {})
	proof["stats_reactor"] = int(reactor.get("size", -1)) == 4 and int(reactor.get("health", -1)) == 900 and is_equal_approx(float(reactor.get("power_production", -1.0)), 130.0) and is_equal_approx(float(reactor.get("item_duration", -1.0)), 140.0) and is_equal_approx(float(reactor.get("liquid_capacity", -1.0)), 80.0) and int(reactor_requirements.get("lead", -1)) == 500 and int(reactor_requirements.get("silicon", -1)) == 300 and int(reactor_requirements.get("graphite", -1)) == 400 and int(reactor_requirements.get("thorium", -1)) == 100 and int(reactor_requirements.get("surge-alloy", -1)) == 250 and int(reactor_requirements.get("metaglass", -1)) == 250

	# --- Size / health: the def is size 4 with 900
	# health while the class defaults are size 1
	# with 40 health (the post-init effective
	# health, not the -1 sentinel).
	var fallback: Dictionary = impact_reactor_build_state.source_impact_reactor_per_def_stats_state("no-such-def")
	proof["stats_size_health"] = int(reactor.get("size", -1)) == 4 and int(reactor.get("health", -1)) == 900 and int(fallback.get("size", -1)) == 1 and int(fallback.get("health", -1)) == 40

	# --- Power / duration: the def produces 130f
	# over a 140f item duration while the class
	# defaults produce 0f over 60f -- the def
	# overrides BOTH class fields.
	proof["stats_power_duration"] = is_equal_approx(float(reactor.get("power_production", -1.0)), 130.0) and is_equal_approx(float(reactor.get("item_duration", -1.0)), 140.0) and is_equal_approx(float(fallback.get("power_production", -1.0)), 0.0) and is_equal_approx(float(fallback.get("item_duration", -1.0)), 60.0)

	# --- Requirements: the def dict carries
	# exactly the six items (lead 500, silicon 300,
	# graphite 400, thorium 100, surge-alloy 250,
	# metaglass 250); the class fallback carries
	# none.
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	proof["stats_requirements"] = reactor_requirements.size() == 6 and int(reactor_requirements.get("lead", -1)) == 500 and int(reactor_requirements.get("silicon", -1)) == 300 and int(reactor_requirements.get("graphite", -1)) == 400 and int(reactor_requirements.get("thorium", -1)) == 100 and int(reactor_requirements.get("surge-alloy", -1)) == 250 and int(reactor_requirements.get("metaglass", -1)) == 250 and fallback_requirements.is_empty()

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, health 40 post-init, powerProduction
	# 0f, itemDuration 60f, liquidCapacity 30f, and
	# NO requirements.
	var empty_fallback: Dictionary = impact_reactor_build_state.source_impact_reactor_per_def_stats_state("")
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and int(fallback.get("health", -1)) == 40 and is_equal_approx(float(fallback.get("power_production", -1.0)), 0.0) and is_equal_approx(float(fallback.get("item_duration", -1.0)), 60.0) and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 30.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and int(empty_fallback.get("health", -1)) == 40 and is_equal_approx(float(empty_fallback.get("power_production", -1.0)), 0.0) and is_equal_approx(float(empty_fallback.get("item_duration", -1.0)), 60.0) and is_equal_approx(float(empty_fallback.get("liquid_capacity", -1.0)), 30.0) and empty_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2450 stats pure as its caller-supplied
	# inputs -- the def itemDuration 140f reads
	# 140/60 seconds production time with the
	# "115.12 seconds ~ 21.16 seconds power
	# equilibrium" warmup label (25f usage over
	# 130f production), while the class fallback
	# itemDuration 60f reads 1 second with NO
	# warmup label (the class has no ConsumePower
	# -- consumePower(25f) is def-only,
	# Blocks.java:2642 -- so has_cons_power is
	# false and the pure never divides by the 0f
	# class powerProduction).
	var reactor_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(float(reactor.get("item_duration", 0.0)), true, 0.001, 25.0, float(reactor.get("power_production", 0.0)), true)
	var fallback_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(float(fallback.get("item_duration", 0.0)), true, 0.001, 25.0, float(fallback.get("power_production", 0.0)), false)
	proof["stats_live_input"] = is_equal_approx(float(reactor_stats.get("production_time_seconds", -1.0)), 140.0 / 60.0) and str(reactor_stats.get("warmup_time_label", "")) == "115.12 seconds ~ 21.16 seconds power equilibrium" and is_equal_approx(float(fallback_stats.get("production_time_seconds", -1.0)), 1.0) and fallback_stats.get("warmup_time_label", "x") == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
