extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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

	# --- Bridge-conduit def row (N2501): the
	# AMENDMENT slice -- the N2494 pure carries
	# only the phase-conduit row, and
	# bridge-conduit (the second LiquidBridge
	# def, Blocks.java:2374-2384) falls back to
	# the class defaults. This slice adds the
	# SECOND def branch with the pure signature
	# and return keys UNCHANGED (the N2446
	# amendment precedent): size 1, range 4,
	# liquidCapacity 100f, arrowPeriod 0.4f,
	# arrowTimeScl 6.2f, requirements graphite 4
	# / metaglass 8. The def sets NO size line
	# (size 1 is the inherited Block default,
	# Block.java:215) and NO arrowPeriod /
	# arrowTimeScl lines, so its arrows ride the
	# ItemBridge class defaults (arrowPeriod
	# 0.4f, ItemBridge.java:37; arrowTimeScl
	# 6.2f, ItemBridge.java:38) -- unlike
	# phase-conduit, which overrides both (0.9f
	# / 2.75f). The def DOES set arrowSpacing 6f
	# (Blocks.java:2378) and fadeIn = moveArrows
	# = false (:2377), but neither is a return
	# key of the pure, so neither is ported here.
	# Phase-conduit + the class fallback are
	# UNCHANGED. Pure-only: the caller reads it;
	# the advance + shouldConsume pures take
	# these values as caller-supplied inputs and
	# are unchanged.

	# --- Def row: bridge-conduit -- size 1,
	# range 4, liquidCapacity 100f, arrowPeriod
	# 0.4f, arrowTimeScl 6.2f, requirements
	# graphite 4 / metaglass 8.
	var conduit: Dictionary = liquid_bridge_build_state.source_liquid_bridge_per_def_stats_state("bridge-conduit")
	var conduit_requirements: Dictionary = conduit.get("requirements", {})
	proof["row_conduit"] = int(conduit.get("size", -1)) == 1 and int(conduit.get("range", -1)) == 4 and is_equal_approx(float(conduit.get("liquid_capacity", -1.0)), 100.0) and is_equal_approx(float(conduit.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(conduit.get("arrow_time_scl", -1.0)), 6.2) and int(conduit_requirements.get("graphite", -1)) == 4 and int(conduit_requirements.get("metaglass", -1)) == 8

	# --- Phase-conduit row UNCHANGED -- size 1,
	# range 12, liquidCapacity 100f, arrowPeriod
	# 0.9f, arrowTimeScl 2.75f, requirements
	# phase-fabric 5 / silicon 7 / metaglass 20
	# / titanium 10 -- and the class fallback
	# UNCHANGED -- size 1, range 0,
	# liquidCapacity 10f, arrowPeriod 0.4f,
	# arrowTimeScl 6.2f, NO requirements.
	var phase: Dictionary = liquid_bridge_build_state.source_liquid_bridge_per_def_stats_state("phase-conduit")
	var phase_requirements: Dictionary = phase.get("requirements", {})
	var fallback: Dictionary = liquid_bridge_build_state.source_liquid_bridge_per_def_stats_state("no-such-def")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	proof["row_phase_unchanged"] = int(phase.get("size", -1)) == 1 and int(phase.get("range", -1)) == 12 and is_equal_approx(float(phase.get("liquid_capacity", -1.0)), 100.0) and is_equal_approx(float(phase.get("arrow_period", -1.0)), 0.9) and is_equal_approx(float(phase.get("arrow_time_scl", -1.0)), 2.75) and int(phase_requirements.get("phase-fabric", -1)) == 5 and int(phase_requirements.get("silicon", -1)) == 7 and int(phase_requirements.get("metaglass", -1)) == 20 and int(phase_requirements.get("titanium", -1)) == 10 and int(fallback.get("size", -1)) == 1 and int(fallback.get("range", -1)) == 0 and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 10.0) and is_equal_approx(float(fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(fallback.get("arrow_time_scl", -1.0)), 6.2) and fallback_requirements.is_empty()

	# --- Range / capacity: bridge-conduit links
	# 4 tiles and holds 100f -- the SAME capacity
	# as phase-conduit (100f) but a THIRD of its
	# range (12) -- while the class defaults link
	# 0 tiles and hold 10f.
	proof["row_range_capacity"] = int(conduit.get("range", -1)) == 4 and is_equal_approx(float(conduit.get("liquid_capacity", -1.0)), 100.0) and int(phase.get("range", -1)) == 12 and is_equal_approx(float(phase.get("liquid_capacity", -1.0)), 100.0) and int(fallback.get("range", -1)) == 0 and is_equal_approx(float(fallback.get("liquid_capacity", -1.0)), 10.0)

	# --- Arrows: bridge-conduit draws arrows at
	# the CLASS defaults (period 0.4f / time
	# scale 6.2f -- the def sets neither line)
	# while phase-conduit overrides both (0.9f /
	# 2.75f).
	proof["row_arrows"] = is_equal_approx(float(conduit.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(conduit.get("arrow_time_scl", -1.0)), 6.2) and is_equal_approx(float(fallback.get("arrow_period", -1.0)), 0.4) and is_equal_approx(float(fallback.get("arrow_time_scl", -1.0)), 6.2) and is_equal_approx(float(phase.get("arrow_period", -1.0)), 0.9) and is_equal_approx(float(phase.get("arrow_time_scl", -1.0)), 2.75)

	# --- Requirements: the bridge-conduit dict
	# carries exactly the two items (graphite 4,
	# metaglass 8); phase-conduit carries four;
	# the class fallback carries none.
	proof["row_requirements"] = conduit_requirements.size() == 2 and int(conduit_requirements.get("graphite", -1)) == 4 and int(conduit_requirements.get("metaglass", -1)) == 8 and phase_requirements.size() == 4 and fallback_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2275 transport pure through the link
	# validation -- range 4 vs 12 changes which
	# partner links. A partner 6 tiles away on
	# the same axis (dx 6, dy 0) is positions-
	# valid iff |dx| <= range (positionsValid,
	# ItemBridge.java:157-165, same y -> |dx| <=
	# range; the verdict is caller-supplied, the
	# N2463 precedent, because range varies per
	# def -- the other linkValid predicates
	# (tiles exist, same def, same team, no
	# double link) hold by construction, so
	# had_valid_link == positions_valid here):
	# bridge-conduit (range 4) reads 6 > 4 ->
	# NOT valid -> had_valid_link false -> the
	# transport pure takes the unlinked branch
	# (warmup = 0f, ItemBridge.java:337; flow
	# 0.0, moved false); phase-conduit (range
	# 12) reads 6 <= 12 -> valid -> had_valid_link
	# true -> a warm bridge holding 50 of liquid
	# 0 against an empty partner moves 50.0 at
	# the def capacity 100f (fract 0.5), moved
	# true, warmup stays 1.0. EXACT ASSERTION:
	# conduit flow 0.0 + warmup 0.0 + moved false
	# vs phase flow 50.0 + warmup 1.0 + moved
	# true, both at liquid_capacity 100f from
	# their own rows -- the range, not the
	# capacity, decides the link.
	var partner_dx: int = 6
	var conduit_positions_valid: bool = partner_dx <= int(conduit.get("range", 0))
	var phase_positions_valid: bool = partner_dx <= int(phase.get("range", 0))
	var frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "moved": false}
	var liquids: Dictionary = {"current": 0, "liquids": [50.0]}
	var conduit_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": float(conduit.get("liquid_capacity", 0.0)), "liquids": {"current": 0, "liquids": [0.0]}}
	var phase_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": float(phase.get("liquid_capacity", 0.0)), "liquids": {"current": 0, "liquids": [0.0]}}
	var conduit_advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(frame, 1.0, float(conduit.get("liquid_capacity", 0.0)), 1.0, conduit_positions_valid, liquids, conduit_partner)
	var phase_advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(frame, 1.0, float(phase.get("liquid_capacity", 0.0)), 1.0, phase_positions_valid, liquids, phase_partner)
	proof["row_live_input"] = conduit_positions_valid == false and phase_positions_valid == true and is_equal_approx(float(conduit_advanced.get("flow", -1.0)), 0.0) and is_equal_approx(float(conduit_advanced.get("warmup", -1.0)), 0.0) and bool(conduit_advanced.get("moved", true)) == false and is_equal_approx(float(phase_advanced.get("flow", -1.0)), 50.0) and is_equal_approx(float(phase_advanced.get("warmup", -1.0)), 1.0) and bool(phase_advanced.get("moved", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeBridgeConduitRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
