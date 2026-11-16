extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))

	# --- UpdateEffect chance rows (N2481):
	# SolidPumpBuild.updateTile()
	# (SolidPump.java:122-141). The pump branch
	# is `if(efficiency > 0 && typeLiquid() <
	# liquidCapacity - 0.001f){`
	# (SolidPump.java:126); inside it, `if(Mathf.
	# chance(delta() * updateEffectChance))`
	# (SolidPump.java:131) gates `updateEffect.
	# at(x + Mathf.range(size * 2f), y +
	# Mathf.range(size * 2f));` (SolidPump.
	# java:132). The fields are `public Effect
	# updateEffect = Fx.none;` (SolidPump.
	# java:23) and `public float updateEffect
	# Chance = 0.02f;` (SolidPump.java:24); the
	# water-extractor def overrides NEITHER
	# (Blocks.java:2920-2930), so the live call
	# records the Fx.none token. Mathf.chance
	# is `return d >= 1f || rand.nextFloat() <
	# d;` (arc Mathf.java:240-242) -- the d >=
	# 1f short-circuit fires unconditionally --
	# and Mathf.range is `return random(-range,
	# range);` (arc Mathf.java:220-222), so the
	# position rolls span [-4f, 4f] for the
	# size-2 water-extractor (`size = 2;`,
	# Blocks.java:2924). NO RNG in the pure
	# (the N2421/N2468 precedent): the chance
	# roll + the two position rolls are
	# caller-supplied already-rolled inputs.
	# Pure-only: the tick never calls the
	# chance pure -- the effect call sites
	# wait for renderer/effect slices.
	#
	# Fixture: the building sits at (100, 200)
	# in world units; delta is source_delta *
	# time_scale (1.0 * 1.0 = one tick unless
	# stated), the chance is the class default
	# 0.02, and the effect token is Fx.none
	# unless stated.

	# --- Roll hit: with the gate open, a
	# chance roll below delta * chance (0.01 <
	# 1.0 * 0.02) fires the effect at x +
	# range_roll_x, y + range_roll_y. The d >=
	# 1f short-circuit fires unconditionally
	# even at roll 0.999 (threshold 2.0 at
	# source_delta 100.0).
	var hit: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.01, 1.5, -2.5)
	var hit_call: Dictionary = hit.get("effect_call", {})
	var short_circuit: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 100.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.999, 0.0, 0.0)
	var short_circuit_call: Dictionary = short_circuit.get("effect_call", {})
	proof["fx_roll_hit"] = hit_call is Dictionary and str(hit_call.get("effect", "")) == "Fx.none" and is_equal_approx(float(hit_call.get("x", 0.0)), 101.5) and is_equal_approx(float(hit_call.get("y", 0.0)), 197.5) and short_circuit_call is Dictionary and str(short_circuit_call.get("effect", "")) == "Fx.none" and is_equal_approx(float(short_circuit_call.get("x", 0.0)), 100.0) and is_equal_approx(float(short_circuit_call.get("y", 0.0)), 200.0)

	# --- Roll miss: with the gate open, a
	# chance roll at or above the threshold
	# fires nothing -- exactly at the threshold
	# (0.02, the STRICT < comparison) and well
	# above it (0.5). A zero roll at zero
	# delta (threshold 0.0) misses too: 0.0 <
	# 0.0 is false.
	var miss_boundary: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.02, 1.5, -2.5)
	var miss_high: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.5, 1.5, -2.5)
	var miss_zero_delta: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 0.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, 1.5, -2.5)
	proof["fx_roll_miss"] = miss_boundary.get("effect_call", {}) == null and miss_high.get("effect_call", {}) == null and miss_zero_delta.get("effect_call", {}) == null

	# --- Gate closed: with the pump branch
	# shut, even a roll of 0.0 (a certain hit)
	# fires nothing -- and the d >= 1f
	# short-circuit does not override the gate
	# either (threshold 2.0, gate false).
	var closed_certain: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(false, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, 1.5, -2.5)
	var closed_short_circuit: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(false, 100.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.999, 0.0, 0.0)
	proof["fx_gate_closed"] = closed_certain.get("effect_call", {}) == null and closed_short_circuit.get("effect_call", {}) == null

	# --- Position rolls: the offsets land
	# verbatim -- the +-4f size-2 boundary
	# (range size * 2f = 4f) reaches (104, 196)
	# and (96, 204), and zero rolls land exactly
	# on the building pos (100, 200).
	var corner_high: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, 4.0, -4.0)
	var corner_high_call: Dictionary = corner_high.get("effect_call", {})
	var corner_low: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, -4.0, 4.0)
	var corner_low_call: Dictionary = corner_low.get("effect_call", {})
	var center: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, 0.0, 0.0)
	var center_call: Dictionary = center.get("effect_call", {})
	proof["fx_position_rolls"] = is_equal_approx(float(corner_high_call.get("x", 0.0)), 104.0) and is_equal_approx(float(corner_high_call.get("y", 0.0)), 196.0) and is_equal_approx(float(corner_low_call.get("x", 0.0)), 96.0) and is_equal_approx(float(corner_low_call.get("y", 0.0)), 204.0) and is_equal_approx(float(center_call.get("x", 0.0)), 100.0) and is_equal_approx(float(center_call.get("y", 0.0)), 200.0)

	# --- Fx.none token: the class default
	# updateEffect is Fx.none (SolidPump.
	# java:23) and the water-extractor def
	# does not override it, so the live call
	# records "Fx.none". A def override would
	# pass through verbatim -- the pure records
	# the token, it does not hardcode none
	# (Fx.pulverize is the oil-extractor's
	# updateEffect, Blocks.java:2967, used here
	# only as a passthrough value).
	var none_call: Dictionary = hit.get("effect_call", {})
	var override: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(true, 1.0, 1.0, 0.05, "Fx.pulverize", 100.0, 200.0, 0.0, 0.0, 0.0)
	var override_call: Dictionary = override.get("effect_call", {})
	proof["fx_none_token"] = str(none_call.get("effect", "")) == "Fx.none" and str(override_call.get("effect", "")) == "Fx.pulverize"

	# --- Live input: the gate verdict comes
	# from the LIVE N2220 advance -- an enabled
	# frame (efficiency 1.0, valid_tiles 1.0,
	# empty store) pumps max_pump 0.11 > 0, so
	# the branch was open and a roll of 0.0
	# fires; a disabled frame (efficiency 0.0)
	# pumps max_pump 0.0, so the branch was
	# shut and the same roll fires nothing.
	# (max_pump > 0 proves the branch only
	# because the fixture fraction is 1.0 --
	# at fraction 0 an open branch still pumps
	# 0.)
	var live_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var live_open: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 1.0, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": live_liquids}, 1.0, 1.0, water_id, 40.0, 0.11)
	var live_open_gate: bool = float(live_open.get("max_pump", 0.0)) > 0.0
	var live_hit: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(live_open_gate, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, 1.0, 1.0)
	var live_hit_call: Dictionary = live_hit.get("effect_call", {})
	var idle_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var live_closed: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 0.0, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": idle_liquids}, 1.0, 1.0, water_id, 40.0, 0.11)
	var live_closed_gate: bool = float(live_closed.get("max_pump", 0.0)) > 0.0
	var live_miss: Dictionary = solid_pump_build_state.source_solid_pump_update_effect_chance_state(live_closed_gate, 1.0, 1.0, 0.02, "Fx.none", 100.0, 200.0, 0.0, 1.0, 1.0)
	proof["fx_live_input"] = live_open_gate and live_hit_call is Dictionary and is_equal_approx(float(live_hit_call.get("x", 0.0)), 101.0) and is_equal_approx(float(live_hit_call.get("y", 0.0)), 201.0) and not live_closed_gate and live_miss.get("effect_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpUpdateEffectChanceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
