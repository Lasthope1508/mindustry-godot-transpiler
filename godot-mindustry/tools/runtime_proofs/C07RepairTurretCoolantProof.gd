extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- Pure coolant multiplier (N2209): RepairPointBuild.
	# updateTile computes the heal multiplier as `float
	# multiplier = 1f;` then `if(acceptCoolant){ multiplier
	# = 1f + liquids.current().heatCapacity *
	# coolantMultiplier * optionalEfficiency; }`
	# (RepairTurret.java:188-190), and heals with it:
	# `target.heal(repairSpeed * strength * edelta() *
	# multiplier);` (RepairTurret.java:207). The coolant
	# consumer is optional (`consume(new
	# ConsumeCoolant(coolantUse)).optional(true, true);`,
	# RepairTurret.java:86), so its efficiency folds into
	# optionalEfficiency in the optional pass
	# (BuildingComp.java:1979-1981,
	# `optionalEfficiency = Math.min(optionalEfficiency,
	# cons.efficiency(self()));`), which updateConsumption
	# initializes to 1f before the pass
	# (BuildingComp.java:1965, `efficiency =
	# optionalEfficiency = 1f;`). Per-def, only repair-turret
	# accepts coolant: coolantUse 0.16f, coolantMultiplier
	# 1.6f, acceptCoolant true (Blocks.java:6404-6406);
	# class defaults are coolantUse 0.5f, coolantMultiplier
	# 1f, acceptCoolant false (RepairTurret.java:39-45).
	# The multiplier is a read the updateTile heal advance
	# uses, not a tick write: NO driver tick line belongs
	# here (the N2208 precedent), so the proof calls the pure
	# function
	# source_repair_turret_coolant_multiplier_state(frame,
	# accept_coolant, coolant_multiplier) directly with
	# synthetic frames. An absent
	# `liquids_current_heat_capacity` key reads 0.0 -- no
	# current coolant liquid observed yet, so no boost. An
	# absent `optional_efficiency` key reads 1.0 -- the
	# pre-pass init (BuildingComp.java:1965). The 0.5 heat
	# capacity below is the Liquid class default
	# (`public float heatCapacity = 0.5f;`, Liquid.java:42).

	# No boost without coolant: accept_coolant=false (the
	# repair-point def) at heat capacity 0.5 and
	# optionalEfficiency 1.0 -- the Java `if(acceptCoolant){`
	# guard leaves multiplier at 1f.
	var no_coolant: Dictionary = repair_turret_build_state.source_repair_turret_coolant_multiplier_state({"liquids_current_heat_capacity": 0.5, "optional_efficiency": 1.0}, false, 1.6)
	proof["multiplier_one_without_coolant"] = is_equal_approx(float(no_coolant.get("heal_multiplier", -1.0)), 1.0) and bool(no_coolant.get("coolant_active", true)) == false

	# Boost with coolant: accept_coolant=true (the
	# repair-turret def, coolantMultiplier 1.6f) at heat
	# capacity 0.5 and optionalEfficiency 1.0 -- 1.0 + 0.5 *
	# 1.6 * 1.0 = 1.8.
	var boosted: Dictionary = repair_turret_build_state.source_repair_turret_coolant_multiplier_state({"liquids_current_heat_capacity": 0.5, "optional_efficiency": 1.0}, true, 1.6)
	proof["multiplier_boost_with_coolant"] = is_equal_approx(float(boosted.get("heal_multiplier", -1.0)), 1.8) and bool(boosted.get("coolant_active", false)) == true

	# Scales with optionalEfficiency: accept_coolant=true at
	# heat capacity 0.5 and optionalEfficiency 0.5 -- 1.0 +
	# 0.5 * 1.6 * 0.5 = 1.4. The optional coolant row folds
	# optionalEfficiency from the liquid amount, so a
	# half-fed coolant consumer boosts half as much.
	var half: Dictionary = repair_turret_build_state.source_repair_turret_coolant_multiplier_state({"liquids_current_heat_capacity": 0.5, "optional_efficiency": 0.5}, true, 1.6)
	proof["multiplier_scales_with_optional_efficiency"] = is_equal_approx(float(half.get("heal_multiplier", -1.0)), 1.4)

	# No boost without liquid: accept_coolant=true but NO
	# `liquids_current_heat_capacity` key -- the absent key
	# reads 0.0, so 1.0 + 0.0 * 1.6 * 1.0 = 1.0. This pins
	# the RED absent-default decision: no observation yet
	# means no boost, never a crash.
	var no_liquid: Dictionary = repair_turret_build_state.source_repair_turret_coolant_multiplier_state({"optional_efficiency": 1.0}, true, 1.6)
	proof["multiplier_one_without_liquid"] = is_equal_approx(float(no_liquid.get("heal_multiplier", -1.0)), 1.0)

	# Absent optional_efficiency defaults to 1.0:
	# accept_coolant=true at heat capacity 0.5 with NO
	# `optional_efficiency` key -- the pre-pass init
	# (BuildingComp.java:1965, `efficiency =
	# optionalEfficiency = 1f;`), so 1.0 + 0.5 * 1.6 * 1.0
	# = 1.8.
	var no_opt: Dictionary = repair_turret_build_state.source_repair_turret_coolant_multiplier_state({"liquids_current_heat_capacity": 0.5}, true, 1.6)
	proof["multiplier_absent_optional_efficiency_defaults_one"] = is_equal_approx(float(no_opt.get("heal_multiplier", -1.0)), 1.8)

	# No boost when optionalEfficiency is zero:
	# accept_coolant=true at heat capacity 0.5 and
	# optionalEfficiency 0.0 -- 1.0 + 0.5 * 1.6 * 0.0 = 1.0.
	# A coolant consumer starved of liquid contributes no
	# boost even though the block accepts coolant.
	var starved: Dictionary = repair_turret_build_state.source_repair_turret_coolant_multiplier_state({"liquids_current_heat_capacity": 0.5, "optional_efficiency": 0.0}, true, 1.6)
	proof["multiplier_one_when_optional_efficiency_zero"] = is_equal_approx(float(starved.get("heal_multiplier", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretCoolantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
