extends Node

const main_scene := preload("res://scenes/Main.tscn")
const consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
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
	var sublimate = blocks_by_id["sublimate"]
	proof["turret_is_continuous_liquid_turret"] = String(sublimate.implementation) == "ContinuousLiquidTurret"

	# --- the registry entry carries the ammo map: sublimate's `ammo(...)`
	# call (Blocks.java:4604-4631) maps ozone to a ContinuousFlameBulletType
	# with ammoMultiplier = 1.2f and cyanogen to one with no ammoMultiplier
	# set, so it takes the BulletType default of 2f (BulletType.java:95). ---
	var properties: Dictionary = sublimate.properties
	proof["registry_has_ammo_types"] = properties.has("ammoTypes")
	var ammo_types: Dictionary = properties.get("ammoTypes", {})
	proof["ammo_types_count"] = ammo_types.size() == 2
	proof["ammo_ozone_multiplier"] = is_equal_approx(float(Dictionary(ammo_types.get("ozone", {})).get("ammoMultiplier", -1.0)), 1.2)
	proof["ammo_cyanogen_multiplier"] = is_equal_approx(float(Dictionary(ammo_types.get("cyanogen", {})).get("ammoMultiplier", -1.0)), 2.0)

	# --- the class init consumes through a ConsumeLiquidFilter over exactly
	# the ammo liquids (ContinuousLiquidTurret.java:40-51) at `liquidConsumed`
	# (1f / 60f, :15), so the registry carries one consumeLiquid descriptor
	# per ammo liquid at that amount. ---
	proof["registry_has_consume_liquid"] = properties.has("consumeLiquid")
	var consume_liquid: Array = properties.get("consumeLiquid", [])
	proof["consume_liquid_count"] = consume_liquid.size() == 2
	var amounts_by_liquid: Dictionary = {}
	for descriptor in consume_liquid:
		amounts_by_liquid[str(descriptor.get("liquid", ""))] = float(descriptor.get("amount", -1.0))
	proof["consume_ozone_amount"] = is_equal_approx(float(amounts_by_liquid.get("ozone", -1.0)), 1.0 / 60.0)
	proof["consume_cyanogen_amount"] = is_equal_approx(float(amounts_by_liquid.get("cyanogen", -1.0)), 1.0 / 60.0)
	proof["consume_liquids_match_ammo"] = amounts_by_liquid.keys().has("ozone") and amounts_by_liquid.keys().has("cyanogen") and amounts_by_liquid.size() == ammo_types.size()

	# --- the runtime reads the registry entry: the consumer definitions
	# come off the block, and a RuntimeConsumer can now be bound for
	# sublimate — before this slice the block had no consumeLiquid, so
	# no consumer could be bound for it at all. ---
	var definitions: Dictionary = consume_liquid_state.source_liquid_consumer_definitions_state(sublimate)
	proof["definitions_state_reads_registry"] = Array(definitions.get("consume_builder", [])).size() == 2
	var bound: Dictionary = consume_liquid_state.source_bind_liquid_consumers_state(sublimate, catalog)
	var consumers: Array = bound.get("consumers", [])
	proof["bind_two_consumers"] = consumers.size() == 2
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog["liquid_id_by_name"]
	var bound_amounts_ok := true
	var bound_liquids_ok := true
	for consumer in consumers:
		bound_amounts_ok = bound_amounts_ok and is_equal_approx(float(consumer.get("amount", -1.0)), 1.0 / 60.0)
		bound_liquids_ok = bound_liquids_ok and int(consumer.get("liquid", -1)) in [int(liquid_id_by_name.get("ozone", -1)), int(liquid_id_by_name.get("cyanogen", -1))]
	proof["bind_amounts"] = bound_amounts_ok
	proof["bind_liquids_are_ammo_liquids"] = bound_liquids_ok

	# --- applying the consumers sets the liquid filter for both ammo
	# liquids (ConsumeLiquidFilter.apply sets block.liquidFilter[liquid.id],
	# ConsumeLiquidFilter.java:26-28). ---
	var applied: Dictionary = consume_liquid_state.source_apply_liquid_consumers_state(sublimate, catalog)
	var liquid_filter: Array = applied.get("liquid_filter", [])
	proof["apply_sets_liquid_filter"] = bool(liquid_filter[int(liquid_id_by_name.get("ozone", -1))]) and bool(liquid_filter[int(liquid_id_by_name.get("cyanogen", -1))])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ContinuousLiquidTurretAmmoRegistryProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
