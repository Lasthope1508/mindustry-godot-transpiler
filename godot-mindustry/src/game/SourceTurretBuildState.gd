extends RefCounted
class_name SourceTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_TURRET_BUILD_INNER_CLASS
const SOURCE_TURRET_USE_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_METHOD
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_CHEATING_GUARD

# Every block whose build is a TurretBuild: the three classes that
# extend Turret directly (ItemTurret.java:23, LiquidTurret.java:18,
# PowerTurret.java:8) and the two that extend them (LaserTurret
# extends PowerTurret, LaserTurret.java:15; ContinuousTurret extends
# Turret, ContinuousTurret.java:14). None of ItemTurretBuild,
# LiquidTurretBuild or PowerTurretBuild overrides updateTile, and
# LaserTurretBuild/ContinuousTurretBuild call super.updateTile()
# first (LaserTurret.java:67-68, ContinuousTurret.java:86-87), so
# TurretBuild.updateTile() (Turret.java:490) is the tick for all of
# them. ContinuousLiquidTurret is NOT here: it has its own driver
# (N2103). PointDefenseTurret extends ReloadTurret, TractorBeamTurret
# extends BaseTurret, RepairTurret extends Block and BuildTurret
# extends BaseTurret, so none of them is a TurretBuild.
const SOURCE_TURRET_BUILD_IMPLEMENTATIONS := ["ItemTurret", "LiquidTurret", "PowerTurret", "LaserTurret", "ContinuousTurret"]
const SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION := "ContinuousLiquidTurret"
const SOURCE_TURRET_BUILDING_META_KEY := "source_turret_building"

static func _is_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The turret tick wires the frame keys the ammo path reads
	# (the N2102 pattern): block_implementation is the block's
	# implementation (Turret.java:36, `public class Turret extends
	# ReloadTurret{`), team_id and rules_state are what Java reads
	# as b.team and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's turret skips ammo consumption like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating"). A team with no rule keeps the false
	# default (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill and ContinuousLiquidTurret frames).
	# A Turret-family sprite gets an empty frame bound; the live-loop
	# tick fills its keys every tick. Any other block, or an
	# already-bound sprite, binds nothing. A ContinuousLiquidTurret
	# binds nothing here: it has its own frame and driver (N2103).
	if block == null or not _is_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_turret_use_ammo_state(frame: Dictionary, turret_properties: Dictionary, stacks: Array, total_ammo: int) -> Dictionary:
	# TurretBuild.useAmmo() (Turret.java:680-690): a cheating turret
	# returns its peek ammo without consuming anything
	# (`if(cheating()) return peekAmmo();`) — the live-loop tick sets
	# frame["cheating"] from the team's live TeamRule every tick, so
	# a cheating ItemTurret fires without spending ammo. Otherwise
	# the ammo is consumed through the registered stack path
	# (entry.amount -= ammoPerShot, pop when empty, totalAmmo -=
	# ammoPerShot clamped at 0, return entry.type()).
	# ItemTurretBuild does not override useAmmo (ItemTurret.java has
	# no useAmmo; its build inherits TurretBuild.useAmmo), while
	# LiquidTurretBuild and PowerTurretBuild override it with their
	# own cheating branches (N1201, N1170) and never reach this path.
	var cheating := bool(frame.get("cheating", false))
	if cheating:
		var peeked: Dictionary = source_turret_ammo_state.peek_turret_ammo_state(turret_properties, stacks)
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_BUILD_USE_AMMO_STATE,
			"inner_class": SOURCE_TURRET_BUILD_INNER_CLASS,
			"method": SOURCE_TURRET_USE_AMMO_METHOD,
			"cheating_guard_expr": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
			"cheating": true,
			"returned_ammo": peeked.get("ammo_data", {}),
			"stacks_after": stacks,
			"total_ammo_after": total_ammo,
			"used": false,
		}
	var used: Dictionary = source_turret_ammo_state.use_turret_ammo_state(turret_properties, stacks, total_ammo)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_BUILD_USE_AMMO_STATE,
		"inner_class": SOURCE_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_TURRET_USE_AMMO_METHOD,
		"cheating_guard_expr": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
		"cheating": false,
		"returned_ammo": used.get("ammo_data", {}),
		# The registered stack path names its result
		# "ammo_entries_after" (the ammo stacks after the shot);
		# the useAmmo contract calls them the stacks after.
		"stacks_after": used.get("ammo_entries_after", []),
		"total_ammo_after": int(used.get("total_ammo_after", total_ammo)),
		"used": bool(used.get("used", false)),
	}

@warning_ignore("unused_parameter")
static func source_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the turret tick wiring every tick
	# (TurretBuild.updateTile(), Turret.java:490, runs
	# updateConsumption through super.updateTile(); ItemTurretBuild,
	# LiquidTurretBuild and PowerTurretBuild do not override
	# updateTile, and LaserTurretBuild/ContinuousTurretBuild call
	# super.updateTile() first): each placed Turret-family build
	# gets its frame keys refreshed from the live rules, so the
	# frame's cheating flag tracks team.rules().cheat and useAmmo
	# skips consumption for a cheating team. The frame is bound at
	# placement (source_turret_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop. A
	# ContinuousLiquidTurret is skipped: it has its own driver
	# (N2103). The frame delta is not consumed by the wiring itself
	# (it only refreshes keys); a later slice that ticks shooting or
	# consumption reads it.
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if str(block.implementation) == SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION:
			continue
		if not _is_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
