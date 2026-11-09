extends Node

const main_scene := preload("res://scenes/Main.tscn")
const consume_state := preload("res://src/game/SourceConsumeState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var turret_impl: String = String(blocks_by_id["sublimate"].implementation)
	var factory_impl: String = String(blocks_by_id["ground-factory"].implementation)
	var drill_impl: String = String(blocks_by_id["mechanical-drill"].implementation)
	proof["turret_is_continuous_liquid_turret"] = turret_impl == "ContinuousLiquidTurret"

	# Sublimate's ammo map (Blocks.java:4604-4631): ozone fires a
	# ContinuousFlameBulletType with ammoMultiplier = 1.2f
	# (Blocks.java:4608); cyanogen fires one with no ammoMultiplier set,
	# so it keeps the BulletType default 2f (BulletType.java:95).
	var sublimate_ammo: Dictionary = {"ozone": {"ammoMultiplier": 1.2}, "cyanogen": {"ammoMultiplier": 2.0}}

	# --- the turret pays 1 / ammoMultiplier for its current liquid. ---
	var ozone: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": turret_impl, "current_liquid": "ozone", "ammo_types": sublimate_ammo})
	proof["turret_ozone_multiplier"] = is_equal_approx(float(ozone.get("multiplier", -1.0)), 1.0 / 1.2)
	var cyanogen: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": turret_impl, "current_liquid": "cyanogen", "ammo_types": sublimate_ammo})
	proof["turret_cyanogen_multiplier"] = is_equal_approx(float(cyanogen.get("multiplier", -1.0)), 0.5)

	# --- a liquid with no ammo type pays the 1.0 default. ---
	var water: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": turret_impl, "current_liquid": "water", "ammo_types": sublimate_ammo})
	proof["turret_water_no_ammo"] = is_equal_approx(float(water.get("multiplier", -1.0)), 1.0)

	# --- no current liquid, or no ammo map, pays the 1.0 default. ---
	var no_current: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": turret_impl, "ammo_types": sublimate_ammo})
	proof["turret_no_current_liquid"] = is_equal_approx(float(no_current.get("multiplier", -1.0)), 1.0)
	var no_ammo_types: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": turret_impl, "current_liquid": "ozone"})
	proof["turret_no_ammo_types"] = is_equal_approx(float(no_ammo_types.get("multiplier", -1.0)), 1.0)

	# --- the port reads b.liquids.current() from the liquid module:
	# LiquidModule.current() is the last received/loaded liquid
	# (LiquidModule.java:80-83); the port keeps it in the module
	# frame's "current" (SourceLiquidModuleState.source_current_state).
	# Adding ozone to an empty module makes ozone the current liquid. ---
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var ozone_id: int = int(liquid_catalog["liquid_id_by_name"].get("ozone", -1))
	var module: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_add_state(module, ozone_id, 5.0, [])
	var current: Dictionary = liquid_module_state.source_current_state(module)
	proof["turret_liquid_module_current"] = int(current.get("current", -1)) == ozone_id
	var current_frame: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": turret_impl, "current_liquid": "ozone", "ammo_types": sublimate_ammo})
	proof["turret_current_liquid_ozone"] = is_equal_approx(float(current_frame.get("multiplier", -1.0)), 1.0 / 1.2)

	# --- N2096-N2099 behavior is unchanged for other blocks. ---
	var factory: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": factory_impl, "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0, "teams": {1: {"unitCostMultiplier": 0.5}}}})
	proof["factory_unit_cost_regression"] = is_equal_approx(float(factory.get("multiplier", -1.0)), 1.0)
	proof["factory_is_unit_factory"] = factory_impl == "UnitFactory"
	var drill: Dictionary = consume_state.source_cost_multiplier_for_block_state({"block_implementation": drill_impl, "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0, "teams": {1: {"unitCostMultiplier": 0.5}}}})
	proof["drill_default_regression"] = is_equal_approx(float(drill.get("multiplier", -1.0)), 1.0)
	var bare: Dictionary = consume_state.source_cost_multiplier_for_block_state({})
	proof["bare_build_default"] = is_equal_approx(float(bare.get("multiplier", -1.0)), 1.0)

	# --- live drill: the tick sets the frame keys and the consumers
	# use the per-block Callable (the drill keeps 1.0 through it). ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var frame: Dictionary = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["live_frame_keys"] = String(frame.get("block_implementation", "")) == "Drill" and int(frame.get("team_id", -1)) == 1 and frame.get("rules_state", null) is Dictionary
	var live_consumers: Array = frame.get("consumers", [])
	proof["live_has_consumers"] = not live_consumers.is_empty()
	if not live_consumers.is_empty():
		var live_multiplier: float = float(live_consumers[0].cost_multiplier.call(frame).get("multiplier", -1.0))
		proof["live_drill_one"] = is_equal_approx(live_multiplier, 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ContinuousLiquidTurretCostMultiplierProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
