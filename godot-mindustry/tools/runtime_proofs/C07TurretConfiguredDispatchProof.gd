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

	# --- BuildingComp configured() dispatch effect (N2268):
	# configured() (BuildingComp.java:1414-1432) is what the
	# super.control() config case calls (BuildingComp.java:2161,
	# `configured(null, p1);`, via the :2159 guard pinned by
	# N2267). The type is resolved first:
	# `//null is of type void.class; anonymous classes use their superclass.`
	# `Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();`
	# then the instanceof overrides pin the four content kinds:
	# `if(value instanceof Item) type = Item.class;`
	# `if(value instanceof Block) type = Block.class;`
	# `if(value instanceof Liquid) type = Liquid.class;`
	# `if(value instanceof UnitType) type = UnitType.class;`
	# A player builder stamps last access:
	# `if(builder != null && builder.isPlayer()){`
	# `updateLastAccess(builder.getPlayer());`
	# `}` where updateLastAccess is
	# `public void updateLastAccess(Player player){`
	# `lastAccessed = player.coloredName();`
	# and the field is `transient String lastAccessed;`.
	# isPlayer is `public boolean isPlayer(){`
	# `return controller instanceof Player;`
	# (UnitComp.java:949-950). Then the dispatch:
	# `if(block.configurations.containsKey(type)){`
	# `block.configurations.get(type).get(this, value);`
	# `}else if(value instanceof Building build){`
	# `//copy config of another building`
	# `var conf = build.config();`
	# `if(conf != null && !(conf instanceof Building)){`
	# `configured(builder, conf);`
	# `}` -- a registered handler runs for the resolved type,
	# otherwise a Building value copies the other building's
	# config recursively (at most one level: the guard rejects
	# a Building conf, so the recursive call can never take the
	# copy branch again). The configurations map is
	# `public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();`
	# (Block.java:402), filled by
	# `public <T, E extends Building> void config(Class<T> type, Cons2<E, T> config){`
	# `configurations.put(type, config);`
	# and by configClear, which registers the void.class handler
	# `configurations.put(void.class, (tile, value) -> cons.get((E)tile));`
	# for a null value. `config()` itself is
	# `public Object config(){` returning null by default
	# (BuildingComp.java:2024-2027). Duo registers no
	# configuration at all (no `config(` in ItemTurret.java,
	# Turret.java, ReloadTurret.java or BaseTurret.java), so its
	# configurations map is empty: no handler ever applies and
	# config() returns null, so the copy branch never recurses
	# either -- configured() is a noop for duo. There is NO
	# driver tick: configured() is event-driven (called from
	# control(), the N2248 precedent, N2264/N2266/N2267) -- the
	# logic executor does not exist in the driver yet, so the
	# pure function is called directly. The direct pure-function
	# calls pin the cases behind the driver observables below:
	# an Item value with a registered handler applies it / a
	# Block value with a handler applies it / a Liquid value
	# with a handler applies it / a UnitType value with a
	# handler applies it / a null value resolves to void and
	# applies the void handler / an anonymous value resolves to
	# its superclass / a Building value with no handler copies
	# a non-Building config / a Building value does not copy
	# when the other config is null / a Building value does not
	# copy when the other config is itself a Building / a
	# handler beats the Building copy branch / a player builder
	# stamps last access / the duo live case is a noop (no
	# configurations, config() null).

	# The direct pure-function calls pin the cases behind the
	# driver observables below. The value kind is the runtime
	# class kind ("null" for a null value); has_handler is
	# whether block.configurations holds the resolved type;
	# building_config_kind is the other building's config kind;
	# builder_is_player is whether the builder is a player unit.
	var direct_item: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Item", false, "", true, "null", false)
	var direct_block: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Block", false, "", true, "null", false)
	var direct_liquid: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Liquid", false, "", true, "null", false)
	var direct_unit_type: Dictionary = turret_build_state.source_turret_configured_dispatch_state("UnitType", false, "", true, "null", false)
	var direct_null_void: Dictionary = turret_build_state.source_turret_configured_dispatch_state("null", false, "", true, "null", false)
	var direct_anonymous: Dictionary = turret_build_state.source_turret_configured_dispatch_state("other", true, "Building", false, "null", false)
	var direct_building_copies: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Building", false, "", false, "Item", false)
	var direct_building_config_null: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Building", false, "", false, "null", false)
	var direct_building_config_building: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Building", false, "", false, "Building", false)
	var direct_handler_beats_copy: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Building", false, "", true, "Item", false)
	var direct_player: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Item", false, "", false, "null", true)

	# An Item value with a registered handler applies it --
	# directly (the :1418 override resolves Item, and the
	# :1427-1428 branch runs the handler for that type).
	proof["configured_item_handler"] = direct_item.get("resolved_type", "") == "Item" and direct_item.get("handler_applied", false) == true and direct_item.get("config_copied", true) == false
	# A Block value with a handler applies it -- directly
	# (the :1419 override resolves Block).
	proof["configured_block_handler"] = direct_block.get("resolved_type", "") == "Block" and direct_block.get("handler_applied", false) == true and direct_block.get("config_copied", true) == false
	# A Liquid value with a handler applies it -- directly
	# (the :1420 override resolves Liquid).
	proof["configured_liquid_handler"] = direct_liquid.get("resolved_type", "") == "Liquid" and direct_liquid.get("handler_applied", false) == true and direct_liquid.get("config_copied", true) == false
	# A UnitType value with a handler applies it -- directly
	# (the :1421 override resolves UnitType).
	proof["configured_unit_type_handler"] = direct_unit_type.get("resolved_type", "") == "UnitType" and direct_unit_type.get("handler_applied", false) == true and direct_unit_type.get("config_copied", true) == false
	# A null value resolves to void and applies the void
	# handler -- directly (the :1416 ternary maps null to
	# void.class, and configClear registers the void.class
	# handler, Block.java:921-924).
	proof["configured_null_void_handler"] = direct_null_void.get("resolved_type", "") == "void" and direct_null_void.get("handler_applied", false) == true and direct_null_void.get("config_copied", true) == false
	# An anonymous value resolves to its superclass --
	# directly (the :1415-1416 comment and ternary: an
	# anonymous "other" value with superclass Building
	# resolves to Building, and with no handler nothing runs).
	proof["configured_anonymous_uses_superclass"] = direct_anonymous.get("resolved_type", "") == "Building" and direct_anonymous.get("handler_applied", true) == false and direct_anonymous.get("config_copied", true) == false
	# A Building value with no handler copies a non-Building
	# config -- directly (the :1429-1434 else-if branch: the
	# value is a Building, no handler applies, and the other
	# building's config is an Item, so configured(builder,
	# conf) recurses).
	proof["configured_building_copies_config"] = direct_building_copies.get("resolved_type", "") == "Building" and direct_building_copies.get("handler_applied", true) == false and direct_building_copies.get("config_copied", false) == true
	# A Building value does not copy when the other config is
	# null -- directly (the :1432 guard requires conf != null;
	# config() defaults to null, BuildingComp.java:2024-2027).
	proof["configured_building_no_copy_when_config_null"] = direct_building_config_null.get("config_copied", true) == false and direct_building_config_null.get("handler_applied", true) == false
	# A Building value does not copy when the other config is
	# itself a Building -- directly (the :1432 guard requires
	# !(conf instanceof Building)).
	proof["configured_building_no_copy_when_config_building"] = direct_building_config_building.get("config_copied", true) == false and direct_building_config_building.get("handler_applied", true) == false
	# A handler beats the Building copy branch -- directly
	# (the :1427 if runs first; the :1429 else-if only runs
	# when no handler applies, even for a Building value with
	# a copyable config).
	proof["configured_handler_beats_building_copy"] = direct_handler_beats_copy.get("handler_applied", false) == true and direct_handler_beats_copy.get("config_copied", true) == false
	# A player builder stamps last access -- directly (the
	# :1423-1425 branch: builder.isPlayer() is true, so
	# updateLastAccess runs and lastAccessed is stamped).
	proof["configured_player_updates_last_access"] = direct_player.get("last_access_updated", false) == true

	# One duo segment, live on the driver: the placed duo
	# carries the duo pins (no `config(` registration anywhere
	# in the turret chain, so its configurations map is empty;
	# config() returns null by default). Any configured() call
	# on duo is a noop: no handler, no copy, no last access.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)

	var duo_item: Dictionary = turret_build_state.source_turret_configured_dispatch_state("Item", false, "", false, "null", false)
	var duo_null: Dictionary = turret_build_state.source_turret_configured_dispatch_state("null", false, "", false, "null", false)
	proof["configured_duo_live"] = duo_item.get("resolved_type", "") == "Item" and duo_item.get("handler_applied", true) == false and duo_item.get("config_copied", true) == false and duo_item.get("last_access_updated", true) == false and duo_null.get("resolved_type", "") == "void" and duo_null.get("handler_applied", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretConfiguredDispatchProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
