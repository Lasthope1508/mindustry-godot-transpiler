extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- TurretBuild.canConsume() heat gate (N2272):
	# `public boolean canConsume(){`
	# `if(heatRequirement > 0 && heatReq <= 0f){`
	# `return false;`
	# `}`
	# `return super.canConsume();`
	# `}` (Turret.java:623-629). `heatRequirement` defaults
	# to -1 (Turret.java:52-53, `/** Minimum input heat
	# required to fire. */ public float heatRequirement =
	# -1f;`) and `heatReq` is the live per-build field
	# (Turret.java:295, `public float heatReq;`), recomputed
	# by calculateHeat -- which stays BLOCKED (live proximity
	# scan, BuildingComp.java:410-461), so the gate is modeled
	# purely and takes heat_req as a live input parameter.
	# Only afflict (`heatRequirement = 20f;`,
	# Blocks.java:5122) and malign (`heatRequirement = 144f;`,
	# Blocks.java:6240) set a positive requirement among
	# turrets -- the other Blocks.java setters (surge crucible,
	# cyanogen / phase synthesizer) are HeatCrafter blocks, not
	# turrets. Every other turret reads the -1 default, so the
	# gate passes through super.canConsume() unchanged. There
	# is no driver tick: canConsume() is evaluated per
	# consumption check, not per tick, and the driver has no
	# shouldConsume gate yet (precedent N2268 / N2269 /
	# N2271). The catalog values come from N2270.

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var afflict_block = blocks_by_id["afflict"]
	var malign_block = blocks_by_id["malign"]
	var duo_block = blocks_by_id["duo"]

	var afflict_requirement := float(afflict_block.properties.get("heatRequirement", -1.0))
	var malign_requirement := float(malign_block.properties.get("heatRequirement", -1.0))
	var duo_requirement := float(duo_block.properties.get("heatRequirement", -1.0))

	# --- Catalog capture (Blocks.java:5122/:6240): the block
	# initializer's own heatRequirement assignments; duo
	# carries no key and reads the -1 default.
	proof["catalog_afflict_20"] = is_equal_approx(afflict_requirement, 20.0)
	proof["catalog_malign_144"] = is_equal_approx(malign_requirement, 144.0)
	proof["catalog_duo_default_neg1"] = is_equal_approx(duo_requirement, -1.0)

	# --- Pure gate (N2272): false exactly when
	# heat_requirement > 0 and heat_req <= 0, super_can_consume
	# otherwise.
	var gate_afflict_no_heat: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(afflict_requirement, 0.0, true)
	proof["gate_closed_afflict_no_heat"] = bool(gate_afflict_no_heat.get("can_consume", true)) == false
	var gate_afflict_heated: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(afflict_requirement, 5.0, true)
	proof["gate_open_afflict_heated"] = bool(gate_afflict_heated.get("can_consume", false)) == true
	var gate_malign_no_heat: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(malign_requirement, 0.0, true)
	proof["gate_closed_malign_no_heat"] = bool(gate_malign_no_heat.get("can_consume", true)) == false
	var gate_malign_heated: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(malign_requirement, 10.0, true)
	proof["gate_open_malign_heated"] = bool(gate_malign_heated.get("can_consume", false)) == true
	var gate_duo_super_true: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(duo_requirement, 0.0, true)
	proof["gate_passthrough_duo_super_true"] = bool(gate_duo_super_true.get("can_consume", false)) == true
	var gate_duo_super_false: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(duo_requirement, 0.0, false)
	proof["gate_passthrough_duo_super_false"] = bool(gate_duo_super_false.get("can_consume", true)) == false
	var gate_heated_super_false: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(afflict_requirement, 5.0, false)
	proof["gate_super_false_blocks_heated"] = bool(gate_heated_super_false.get("can_consume", true)) == false
	var gate_negative_heat: Dictionary = turret_build_state.source_turret_can_consume_heat_gate_state(afflict_requirement, -1.0, true)
	proof["gate_negative_heat_req_closed"] = bool(gate_negative_heat.get("can_consume", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretCanConsumeHeatGateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
