extends RefCounted
class_name SourceTurretBuildState

const source_predict_state := preload("res://src/game/SourcePredictState.gd")
const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

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
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this turret (N2125); the tick preserves a disabled turret
	# instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func source_turret_sense_frame_stamp_state(frame: Dictionary, health: float, unit_sense_value: float) -> Dictionary:
	# The sense stamp (N2520): the turret driver tick stamps the
	# live sense inputs it CAN supply today into the frame, so
	# the N2519-wired dispatch `source_building_comp_sense_state`
	# stops reporting handled:false for them when a live turret
	# ticks (BuildingComp.sense() is `public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126). The tick is
	# TurretBuild.updateTile() (`public void updateTile(){`,
	# Turret.java:490), which runs for every Turret-family build
	# the tick already visits. Exactly six keys are written:
	# - `health` is the live health passed in (`case health ->
	# health;`, BuildingComp.java:2101);
	# - `is_dead` is `health <= 0.0` (the kill trigger
	# `if(health <= 0f && !dead()){`, BuildingComp.java:2170,
	# sets `dead = true;` in killed(), :2243 -- the
	# port-consistent reading, SourceBuildingDamageState.gd:40
	# `"was_dead": current_health <= 0.0`, NOT a guess about
	# the `dead` field);
	# - `tile_build_is_self` is the constant true -- the tick
	# only iterates live placed buildings, so `tile.build ==
	# self()` holds (the first conjunct of `isValid()`,
	# `return tile.build == self() && !dead();`,
	# BuildingComp.java:2031);
	# - `is_control_block` is the constant true -- every
	# turret build implements ControlBlock (`public class
	# TurretBuild extends ReloadTurretBuild implements
	# ControlBlock{`, Turret.java:277);
	# - `unit_sense_value` is passed in (the tick passes 0.0
	# today -- the proxy unit has no player controller
	# attached, so every camera* leg reads 0: `case cameraX,
	# cameraY, cameraWidth, cameraHeight -> this instanceof
	# ControlBlock c ? c.unit().sense(sensor) : 0;`,
	# BuildingComp.java:2122, delegating to `case cameraX ->
	# controller instanceof Player player ? World.conv
	# (player.con == null ? Core.camera.position.x :
	# player.con.viewX) : 0;`, UnitComp.java:283-286).
	# The four graph keys (`last_scaled_power_in` /
	# `last_scaled_power_out` / `last_power_stored` /
	# `last_capacity`) are stamped by the N2522 power-graph
	# last-values stamp, not by this function. The items pair
	# (`items_is_null` / `items_total`) is stamped by the
	# N2521 ammo-items stamp, not by this function. The frame
	# itself is returned (the N2108 tick-frame precedent).
	frame["health"] = health
	frame["is_dead"] = health <= 0.0
	frame["tile_build_is_self"] = true
	frame["is_control_block"] = true
	frame["unit_sense_value"] = unit_sense_value
	return frame

static func source_turret_ammo_items_stamp_state(frame: Dictionary, has_items: bool) -> Dictionary:
	# The ammo-items stamp (N2521): the turret driver tick stamps
	# the live item inventory into the frame, so the N2519-wired
	# dispatch `source_building_comp_sense_state` stops reporting
	# handled:false for the totalItems leg when a live turret
	# ticks (BuildingComp.sense() is `public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126). The tick is
	# TurretBuild.updateTile() (`public void updateTile(){`,
	# Turret.java:490), which runs for every Turret-family build
	# the tick already visits. Exactly two keys are written:
	# - `items_is_null` is `not has_items` -- only ItemTurret
	# has an item module (`if(block.hasItems) items = new
	# ItemModule();`, BuildingComp.java:145; `hasItems = true;`,
	# ItemTurret.java:28, the ONLY hasItems set among the 5
	# ticked implementations), so every other Turret-family
	# build has `items == null` (`case totalItems -> items ==
	# null ? 0 : items.total();`, BuildingComp.java:2107);
	# - `items_total` is the constant 0 -- the `items` module
	# is NEVER written for an ItemTurretBuild:
	# `ItemTurretBuild.handleItem` (ItemTurret.java:155-185)
	# overrides `BuildingComp.handleItem` (:860-862,
	# `items.add(item, 1);`) WITHOUT calling super, so it only
	# updates `totalAmmo` (`totalAmmo += type.ammoMultiplier;`,
	# :168) and the ammo-weighted `ammo` entries; `handleStack`
	# (:141-147) loops `handleItem` and `read()` restores
	# `ammo` + `totalAmmo`, never `items`. The module exists
	# but stays empty, so `items.total()` is 0 always
	# (`public int total(){`, ItemModule.java:174-176). The
	# port's `turret_ammo_stacks` are the Java `ammo` Seq
	# (ammo-weighted entries), NOT the `items` module -- summing
	# them would invent behavior (a duo with copper 5 +
	# graphite 3 stacks would read 8.0 while Java reads 0.0),
	# so the tick reads NO stacks dict for this stamp.
	# The stamp OVERWRITES any stale `items_total` already on
	# the frame. The four graph keys (`last_scaled_power_in` /
	# `last_scaled_power_out` / `last_power_stored` /
	# `last_capacity`) are stamped by the N2522 power-graph
	# last-values stamp, not by this function. The frame itself
	# is returned (the N2108 tick-frame precedent).
	frame["items_is_null"] = not has_items
	frame["items_total"] = 0
	return frame

static func source_turret_power_graph_last_values_stamp_state(frame: Dictionary, power_graph_update: Dictionary) -> Dictionary:
	# The power-graph last-values stamp (N2522): the turret
	# driver tick stamps the live graph snapshot into the frame,
	# so the N2519-wired dispatch
	# `source_building_comp_sense_state` stops reporting
	# handled:false for the powerNet* legs when a live turret
	# ticks (BuildingComp.sense() is `public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126). The tick is
	# TurretBuild.updateTile() (`public void updateTile(){`,
	# Turret.java:490), which runs for every Turret-family build
	# the tick already visits. Exactly four keys are written,
	# copied verbatim from the graph update the live loop already
	# ran this tick (`source_factory_update_power_graph_state`,
	# SourceFactoryRuntimeState.gd:199, whose `update` is the
	# `update_state` output — PowerGraph.update() is
	# `public void update(){` (PowerGraph.java:216-260):
	# - `last_scaled_power_in` from `update["balance_state"]
	# ["last_scaled_power_in"]`
	# (`lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;`,
	# PowerGraph.java:233; `case powerNetIn -> power == null ? 0
	# : power.graph.getLastScaledPowerIn() * 60;`,
	# BuildingComp.java:2113);
	# - `last_scaled_power_out` from `update["balance_state"]
	# ["last_scaled_power_out"]`
	# (`lastScaledPowerOut = powerNeeded / Time.delta;`,
	# PowerGraph.java:234; `case powerNetOut -> power == null ?
	# 0 : power.graph.getLastScaledPowerOut() * 60;`,
	# BuildingComp.java:2114);
	# - `last_capacity` from `update["balance_state"]
	# ["last_capacity"]` (`lastCapacity = getTotalBatteryCapacity();`,
	# PowerGraph.java:235; `case powerNetCapacity -> power ==
	# null ? 0 : power.graph.getLastCapacity();`,
	# BuildingComp.java:2116);
	# - `last_power_stored` from `update["last_power_stored"]`
	# (top-level on BOTH branches,
	# `lastPowerStored = getBatteryStored();`,
	# PowerGraph.java:236; `case powerNetStored -> power == null
	# ? 0 : power.graph.getLastPowerStored();`,
	# BuildingComp.java:2115).
	# A key is stamped ONLY when present in the update: on the
	# cheat branch `balance_state` is `{}` (Java returns before
	# :233-236, PowerGraph.java:217-224, so the fields keep their
	# previous values) and the stamp leaves the scaled/capacity
	# keys untouched, so the frame keeps the previous tick's
	# values, exactly like Java's fields. An empty `{}` update
	# stamps NOTHING — the dispatch keeps handled:false for
	# powerNet*, the N2519 absent-key fallback. `last_power_stored`
	# IS present on the cheat branch in the port owner
	# (`SourcePowerGraphState.update_state` reports the fresh
	# stored total there, while Java keeps the old field value —
	# a PRE-EXISTING owner deviation from N2142-era, NOT changed
	# by this slice; the stamp copies the owner's snapshot
	# verbatim, so a later owner fix flows through
	# automatically). The stamp does NOT recompute any formula
	# (the formula lives once in `update_balance_state`,
	# SourcePowerGraphBalanceState.gd:116-119) and does NOT call
	# the graph update. `power == null` handling stays in the
	# dispatch legs (they return 0.0 when `not has_power`), so
	# stamping graph values for a power-less turret is safe.
	# Per-graph vs global: Java reads each building's OWN graph
	# (`power.graph.getLastScaledPowerIn()`); the port groups ALL
	# placed buildings into ONE graph (`_group_state`,
	# SourcePlacedPowerGraphState.gd:254-284, has no connectivity
	# split — `PowerGraph.addGraph` merge is not ported), so the
	# building→graph lookup IS the single global placed graph,
	# and the live loop's update is that graph's update. A
	# per-graph split waits for connectivity grouping. The frame
	# itself is returned (the N2108 tick-frame precedent).
	var update_state: Dictionary = power_graph_update.get("update", {})
	var balance_state: Dictionary = update_state.get("balance_state", {})
	if balance_state.has("last_scaled_power_in"):
		frame["last_scaled_power_in"] = float(balance_state.get("last_scaled_power_in", 0.0))
	if balance_state.has("last_scaled_power_out"):
		frame["last_scaled_power_out"] = float(balance_state.get("last_scaled_power_out", 0.0))
	if balance_state.has("last_capacity"):
		frame["last_capacity"] = float(balance_state.get("last_capacity", 0.0))
	if update_state.has("last_power_stored"):
		frame["last_power_stored"] = float(update_state.get("last_power_stored", 0.0))
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

static func source_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a power turret does not take the early return. PowerTurret's
	# own live read is the same value (PowerTurret.java:30,
	# `return power == null ? 0f : power.status;`), and the
	# warmup fold is what the efficiency keys prove (Turret.java:512, `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`).
	# Documented limits: (1) the tick models no other consumers --
	# foreshadow's item ammo and lustre's liquid nitrogen are not
	# first-pass rows in this driver yet, so the folded efficiency
	# is the min over the *modeled* consumers (power only); those
	# rows wait for their own slices. (2) The shouldConsume gate
	# is wired by N2291 (source_turret_should_consume_state,
	# TurretBuild.shouldConsume(), Turret.java:364-366, `return
	# isShooting || reloadCounter < reload;`): the tick does not
	# track targeting/reload state yet, so the driver reads frame
	# defaults (is_shooting=false, reload_counter=0.0,
	# reload=10f) and the gate preserves should_consume=true
	# when enabled. `!enabled` is handled by the machinery's
	# disabled branch, not here.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_turret_cooling_state(frame: Dictionary, has_coolant: bool, coolant_amount: float, coolant_efficiency: float, heat_capacity: float, coolant_multiplier: float, ammo_reload_multiplier: float, reload: float, edelta: float) -> Dictionary:
	# updateCooling() (ReloadTurret.java:28-38, called from
	# Turret.java:550 `if(reloadWhileCharging || !charging()){` /
	# `updateReload();` / `updateCooling(); }` -- "turret always
	# reloads regardless of whether it's targeting something"):
	# the gate (`if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){`, ReloadTurret.java:29) uses canReload() =
	# `reloadCounter < reload` (`return reloadCounter < reload;`,
	# ReloadTurret.java:46-48); capacity is the consumed
	# liquid's heatCapacity (`float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);`, ReloadTurret.java:30 -- ConsumeCoolant extends
	# ConsumeLiquidFilter, so the filter branch applies; the
	# 0.4f fallback belongs to the coolant-pick slice, not this
	# function); amount = `coolant.amount *
	# coolant.efficiency(this)` (`float amount = coolant.amount * coolant.efficiency(this);`, ReloadTurret.java:31);
	# `coolant.update(this);` (ReloadTurret.java:32) removes
	# `amount * edelta() * multiplier`
	# (ConsumeLiquidFilter.java:44-49, multiplier default 1f,
	# `public Floatf<Building> multiplier = b -> 1f;`,
	# Consume.java:18) -- the pure function returns that as
	# coolant_consumed for a later wiring slice to apply, since
	# the frame carries no liquid inventory; the reload boost is
	# `reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();` (ReloadTurret.java:33) with
	# coolantMultiplier = 5f for the Turret family
	# (`public float coolantMultiplier = 5f;`, BaseTurret.java:32 --
	# no override in ItemTurret / Turret / PowerTurret; only
	# PointDefenseTurret 2f, LaserTurret / ContinuousTurret /
	# TractorBeamTurret 1f) and ammoReloadMultiplier() the
	# Turret.java:727 override (`return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;`, NOT the
	# ReloadTurret.java:41-43 default 1f). The coolEffect chance
	# (`if(Mathf.chance(0.06 * amount)){`, ReloadTurret.java:35)
	# is a random visual, NOT in the pure function (the N2240
	# random-pitch precedent). `edelta()` is `efficiency * delta()`
	# (BuildingComp.java:1927-1929, `return efficiency * delta();`),
	# passed in precomputed. `cooling_applied` is false whenever
	# the gate fails, and `coolant_consumed` is 0.0 then;
	# `reload_counter` is unchanged when the gate fails.
	# NO driver tick call site: the frame carries no liquid
	# state and the catalog records `coolant` for NO block, so
	# the driver tick cannot read a coolant amount today; the
	# Turret.java:550 call-site gate (`reloadWhileCharging ||
	# !charging()`) belongs to the driver-tick slice. LIVE
	# CONSEQUENCE (Java-faithful): DORMANT live today -- the
	# driver tick never calls this function, so live behavior
	# does not change. When liquid-module wiring lands, the
	# gate opens for defs with coolant + liquid (duo defines
	# `coolant = consumeCoolant(0.1f);`, Blocks.java:3324, but
	# hasLiquids false so efficiency stays 0 and it stays a
	# no-op; defs with real liquid boost reload). The
	# Turret-family coolant pick reuses
	# `source_point_defense_turret_coolant_state` (N2248)
	# as-is -- no twin: its ConsumeCoolant filter /
	# getConsumed pick / efficiency / removal / heatCapacity /
	# coolEffect-chance math is class-level
	# ConsumeCoolant/ConsumeLiquidFilter logic with no
	# PointDefense-specific branch (only the name is
	# PointDefense-specific); the future coolant-pick slice
	# calls it directly. LaserTurret / ContinuousTurret
	# override updateCooling into a no-op
	# (LaserTurret.java:48-50, ContinuousTurret.java:49-51),
	# so meltdown (coolant 0.5f, Blocks.java:4346) never uses
	# this function -- out of scope, no slice needed unless
	# Java changes.
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var cooling_applied: bool = false
	var coolant_consumed: float = 0.0
	if has_coolant and reload_counter < reload and coolant_efficiency > 0.0 and efficiency > 0.0:
		var amount: float = coolant_amount * coolant_efficiency
		coolant_consumed = amount * edelta
		reload_counter += amount * edelta * heat_capacity * coolant_multiplier * ammo_reload_multiplier
		cooling_applied = true
	return {"reload_counter": reload_counter, "cooling_applied": cooling_applied, "coolant_consumed": coolant_consumed}

static func source_reload_turret_base_reload_speed_state(efficiency: float) -> Dictionary:
	# baseReloadSpeed() (ReloadTurret.java:45-47):
	# `protected float baseReloadSpeed(){` /
	# `return efficiency;` -- the base reload-speed factor
	# TurretBuild.updateReload() multiplies
	# (`reloadCounter += delta() * ammoReloadMultiplier() *
	# baseReloadSpeed();`, Turret.java:719-721, N746) -- but
	# N746 registers updateReload, not baseReloadSpeed, so
	# this slice owns the factor itself. `efficiency` is
	# returned WHOLE: no clamp, no floor -- 0 stays 0.0,
	# > 1 passes through, and a negative value passes
	# through (Java has no Math.min/max here; the cap in
	# updateReload is on reloadCounter, not on this
	# factor). `efficiency` is the Building field
	# (`transient float efficiency;`,
	# BuildingComp.java:84-85, "Base efficiency. Takes the
	# minimum value of all consumers"). Do NOT confuse with
	# ammoReloadMultiplier() (ReloadTurret.java:41-43,
	# returns the constant 1f) or
	# TurretBuild.ammoReloadMultiplier() (N746, a ternary
	# on peekAmmo) -- baseReloadSpeed never looks at ammo.
	# NO driver tick call site: the pure function takes the
	# field as a parameter; the tick wiring that feeds it
	# belongs to the driver-tick slice. DORMANT live today
	# -- the driver tick never calls this function, so live
	# behavior does not change.
	return {"base_reload_speed": efficiency}

static func source_reload_turret_can_reload_state(reload_counter: float, reload: float) -> Dictionary:
	# canReload() (ReloadTurret.java:49-51):
	# `protected boolean canReload(){` /
	# `return reloadCounter < reload;` -- the gate
	# updateCooling() calls first (`if(canReload() &&
	# coolant != null && coolant.efficiency(this) > 0 &&
	# efficiency > 0){`, ReloadTurret.java:29) and the
	# gate TurretBuild.shouldConsume() embeds as half of
	# an OR (`return isShooting || reloadCounter < reload;`,
	# Turret.java:364-366, N2291) -- but neither slice
	# registers canReload(): N2525 registers updateCooling
	# and N2291 registers shouldConsume, so this slice
	# owns the gate itself. The comparison is STRICT `<`:
	# counter == reload is false, 0 < 0 is false, and a
	# negative counter is NOT clamped (Java has no
	# Math.max here; capping lives in updateReload, not
	# in canReload). `reloadCounter` is the
	# ReloadTurretBuild field (`public float reloadCounter;`,
	# ReloadTurret.java:26, Java float default 0f) and
	# `reload` is the ReloadTurret field (`public float
	# reload = 10f;`, ReloadTurret.java:10). NO driver
	# tick call site: the pure function takes the two
	# fields as parameters; the tick wiring that feeds
	# them belongs to the driver-tick slice. DORMANT live
	# today -- the driver tick never calls this function,
	# so live behavior does not change.
	return {"can_reload": reload_counter < reload}

static func source_turret_range_state(frame: Dictionary, range_value: float, min_range: float, tracking_range: float, has_peek_ammo: bool, range_change: float, min_range_change: float) -> Dictionary:
	# range() / minRange() / trackingRange() (Turret.java:334-350,
	# the three TurretBuild accessors): `public float minRange(){` /
	# `if(peekAmmo() != null){` /
	# `return minRange + peekAmmo().minRangeChange;` /
	# `return minRange;` (:334-338) /
	# `public float range(){` /
	# `if(peekAmmo() != null){` /
	# `return range + peekAmmo().rangeChange;` /
	# `return range;` (:340-346) /
	# `public float trackingRange(){` /
	# `return range() + trackingRange - range;` (:348-350).
	# `range` is the BaseTurret field (`public float range = 80f;`,
	# BaseTurret.java:21); `minRange` is the Turret field
	# (`public float minRange = 0f;`, Turret.java:74 -- only ripple
	# sets it, `minRange = 50f;`, Blocks.java:4076); `trackingRange`
	# is the Turret field (`public float trackingRange = 0f;`,
	# Turret.java:72 -- no def records it in the catalog, so it
	# arrives as 0f and the init() normalization
	# (`trackingRange = Math.max(range, trackingRange);`,
	# Turret.java:217-219) is folded into this function: a raw 0f
	# must NOT shrink the tracking range below range()).
	# `rangeChange` / `minRangeChange` are BulletType defaults
	# (`public float rangeChange = 0f;`, BulletType.java:157;
	# `public float minRangeChange = 0f;`, :163 -- duo graphite
	# sets `rangeChange = 16f;`, Blocks.java:3276, copper and
	# silicon leave both at 0f, :3259-3295; NO def sets
	# minRangeChange today, so the parameter stays for
	# Java-faithfulness when content changes).
	# `has_peek_ammo` is `peekAmmo() != null`
	# (the ammo stack non-empty), NOT `hasAmmo()` (which also
	# folds canConsume(), Turret.java:705-708); the tick's
	# `peek_turret_ammo` returns an empty dict when there is no
	# ammo. The three accessors are ONE function because they
	# share the peekAmmo() read and the same consumers:
	# `findTarget()` (`float trackRange = trackingRange(), range = range();`,
	# Turret.java:652-656 -- findTarget stays BLOCKED,
	# live entity scan) and the updateTile() within-check
	# (`within(target, range() + hitSize/1.9f)`, :590). The frame
	# is passed for the SourceTurretBuildState pure-function
	# signature convention; this function reads no frame key
	# today (all inputs are parameters) and stamps nothing --
	# the consumers stamp the results onto the frame in later
	# slices. NO driver tick call site: the frame stamps no
	# `tracking_range` / `min_range` live keys. The aim inline
	# (`SourceItemTurretBuildState.gd:506`, `shoot_range = range +
	# range_change + hit_size / 1.9`) is a within-check, NOT
	# range() -- left alone; rewiring aim onto this function is
	# a consumer slice. LIVE CONSEQUENCE (Java-faithful):
	# DORMANT live today -- the driver tick never calls this
	# function, so live behavior does not change.
	var range_out: float = range_value + range_change if has_peek_ammo else range_value
	var min_range_out: float = min_range + min_range_change if has_peek_ammo else min_range
	var tracking_range_out: float = range_out + maxf(range_value, tracking_range) - range_value
	return {"range": range_out, "min_range": min_range_out, "tracking_range": tracking_range_out}

static func source_turret_controlled_stamp_state(frame: Dictionary, unit_is_player: bool) -> Dictionary:
	# controlled() (`public boolean controlled(){` /
	# `return unit.isPlayer();`, Turret.java:441-443) is the
	# one-line predicate on the turret's own unit
	# (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`,
	# Turret.java:291). It rescues validateTarget (`return
	# !Units.invalidateTarget(target, canHeal() ? Team.derelict
	# : team, x, y) || controlled() || logicControlled();`,
	# Turret.java:631-633, N2251), picks the player branch of
	# isShooting (`isShooting = alwaysShooting || (unit.controller()
	# instanceof Player ? unit.isShooting() : logicControlled() ?
	# logicShooting : target != null);`, :492, N2277) and gates
	# the warmup hold (`if(warmupTarget > 0 && !controlled()){` /
	# `warmupHold = 1f;`, :503, N2253). The driver validate /
	# isShooting / warmup calls used to read `frame["controlled"]`
	# with a false default, but the key was NEVER stamped anywhere
	# -- so the three readers always saw the absent default; this
	# slice stamps it live right before the validate call (the
	# N2278 logicControlled precedent, Java order :491 validate
	# reads it). The tick reads the live `unit_is_player` frame
	# input (absent today, so false: the port has NO player unit
	# -- every turret unit is the BlockUnitc from
	# UnitTypes.block.create(team) (:291), PortGame.gd carries no
	# player, and the proxy unit has no player controller attached
	# -- so unit.isPlayer() is false for every live turret (the
	# N2520 `unit_sense_value = 0.0` precedent). When player
	# control lands, the tick passes the live value and this stamp
	# needs no change. Exactly one key is written: `controlled`.
	# The frame itself is returned (the N2108 tick-frame precedent).
	frame["controlled"] = unit_is_player
	return frame

static func source_turret_sense_state(frame: Dictionary, sensor: String, total_ammo: int, max_ammo: int, rotation: float, target_pos: Vector2, is_shooting: bool, reload_counter: float, reload: float, tilesize: float) -> Dictionary:
	match sensor:
		"ammo":
			return {"handled": true, "sense_value": float(total_ammo), "sense_value_is_nan": false}
		"ammoCapacity":
			return {"handled": true, "sense_value": float(max_ammo), "sense_value_is_nan": false}
		"rotation":
			return {"handled": true, "sense_value": float(rotation), "sense_value_is_nan": false}
		"shootX":
			return {"handled": true, "sense_value": target_pos.x / tilesize, "sense_value_is_nan": false}
		"shootY":
			return {"handled": true, "sense_value": target_pos.y / tilesize, "sense_value_is_nan": false}
		"shooting":
			return {"handled": true, "sense_value": 1.0 if is_shooting else 0.0, "sense_value_is_nan": false}
		"progress":
			return {"handled": true, "sense_value": float(source_turret_progress_state(frame, reload_counter, reload).get("progress", 0.0)), "sense_value_is_nan": false}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

static func source_building_comp_sense_state(frame: Dictionary, sensor: String, tilesize: float, world_x: float, world_y: float, team_color_r: float, team_color_g: float, team_color_b: float, block_solid: bool, block_size: int, max_health: float, range_value: float, has_items: bool, item_capacity: int, has_liquids: bool, liquid_capacity: float, total_liquids: float, has_cons_power: bool, power_capacity: float, power_buffered: bool, has_power: bool, time_scale: float, is_player: bool, payload_count: int) -> Dictionary:
	# BuildingComp.sense() (BuildingComp.java:2093-2126):
	# `public double sense(LAccess sensor){` /
	# return switch(sensor){
	# case x -> World.conv(x);
	# case y -> World.conv(y);
	# case color -> Color.toDoubleBits(team.color.r, team.color.g, team.color.b, 1f);
	# case dead -> !isValid() ? 1 : 0;
	# case solid -> block.solid || checkSolid() ? 1 : 0;
	# case team -> team.id;
	# case health -> health;
	# case maxHealth -> maxHealth;
	# case efficiency -> efficiency;
	# case timescale -> timeScale;
	# case range -> this instanceof Ranged r ? r.range() / tilesize : 0;
	# case rotation -> rotation;
	# case totalItems -> items == null ? 0 : items.total();
	# case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();
	# case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);
	# case itemCapacity -> block.hasItems ? block.itemCapacity : 0;
	# case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;
	# case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;
	# case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;
	# case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;
	# case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();
	# case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();
	# case enabled -> enabled ? 1 : 0;
	# case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;
	# case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);
	# case size -> block.size;
	# case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;
	# default -> Float.NaN; //gets converted to null in logic
	# };
	# The sensor spellings are the LAccess enum names
	# (LAccess.java): `x,`
	# `y,`
	# `color("to");`
	# `dead,`
	# `solid,`
	# `team,`
	# `health,`
	# `maxHealth,`
	# `efficiency,`
	# `timescale,`
	# `range,`
	# `rotation,`
	# `totalItems,`
	# `totalLiquids,`
	# `totalPower,`
	# `itemCapacity,`
	# `liquidCapacity,`
	# `powerCapacity,`
	# `powerNetStored,`
	# `powerNetCapacity,`
	# `powerNetIn,`
	# `powerNetOut,`
	# `enabled("to"),`
	# `controlled,`
	# `payloadCount,`
	# `size,`
	# `cameraX,`
	# `cameraY,`
	# `cameraWidth,`
	# `cameraHeight,`
	# `x`/`y` read World.conv (`public static float conv(float coord){`
	# `return coord / tilesize;`
	# World.java:165-166; `public static final int tilesize = 8;`,
	# Vars.java:135) over the explicit world_x/world_y params
	# (the frame carries no building position key, the
	# N2212/N2220 per-def-param precedent). `color` reads arc
	# toDoubleBits (`public static double toDoubleBits(float r, float g, float b, float a){`
	# `return Double.longBitsToDouble(Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);`
	# arc Color.java:166-167; `public static int rgba8888(float r, float g, float b, float a){`
	# `return ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255);`
	# :211-212, RGBA layout) over the explicit team_color_*
	# params with alpha 1f; the 32 bits are reinterpreted as a
	# double through a PackedByteArray (encode_u32 low +
	# decode_double, high 4 bytes zero). Sharded is
	# Pal.accent, `accent = Color.valueOf("ffd37f"),`
	# (Pal.java:79); derelict is
	# `derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),`
	# (Team.java:33); sharded is
	# `sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),`
	# (Team.java:34). `dead` is wired (N2519): `isValid()` is
	# `return tile.build == self() && !dead();`
	# (BuildingComp.java:2031) and its two conjuncts arrive
	# as the `tile_build_is_self` + `is_dead` frame keys
	# when present (absent keys keep handled:false); the
	# branch delegates to
	# `source_building_comp_sense_dead_state`. `solid` reads block_solid (duo true,
	# `solid = true;`, BaseTurret.java:40) because
	# `checkSolid()` returns false in BuildingComp
	# (`public boolean checkSolid(){`, :1734-1736).
	# `team` reads the live frame team_id, absent folding to
	# 0 (derelict id 0). `health` is wired (N2519): the
	# live building health arrives as the `health` frame
	# key when present (absent key keeps handled:false);
	# the branch delegates to
	# `source_building_comp_sense_health_state`. `maxHealth` reads
	# max_health (`maxHealth(block.health);`,
	# BuildingComp.java:142; duo `health = 250;`,
	# Blocks.java:3321). `efficiency` reads the live frame
	# efficiency, absent folding to 0.0 (`transient float efficiency;`,
	# BuildingComp.java:85). `timescale` reads the explicit
	# time_scale param (`private transient float timeScale = 1f, timeScaleDuration;`,
	# BuildingComp.java:98). `range` reads range_value /
	# tilesize (duo is Ranged, `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`,
	# BaseTurret.java:113; `public float range(){`
	# `return range + peekAmmo().rangeChange;`
	# Turret.java:342-347; duo `range = 160;`,
	# Blocks.java:3316, graphite `rangeChange = 16f;`,
	# :3276). `rotation` reads the live frame rotation,
	# absent folding to 90.0 (`public float rotation = 90;`,
	# BaseTurret.java:114). `totalItems` is wired (N2519):
	# duo hasItems (`hasItems = true;`, ItemTurret.java:28)
	# so the total is live inventory, arriving as the
	# `items_is_null` + `items_total` frame keys when
	# present (absent keys keep handled:false); the branch
	# delegates to `source_building_comp_sense_total_items_state`.
	# `totalLiquids` reads total_liquids when has_liquids,
	# else 0 (duo hasLiquids false -> liquids null -> 0).
	# `totalPower` folds to 0 when power or consPower is
	# absent (duo has no consumePower, only
	# `coolant = consumeCoolant(0.1f);`, Blocks.java:3324)
	# and otherwise reads the live frame power_status
	# (absent folds to 1.0, N2142) times the capacity when
	# buffered, else times 1. `itemCapacity` reads
	# item_capacity when has_items (`public int itemCapacity = 10;`,
	# Block.java:75, ItemTurret never overrides it).
	# `liquidCapacity` reads liquid_capacity when
	# has_liquids (`public float liquidCapacity = -1f;`,
	# Block.java:77). `powerCapacity` reads power_capacity
	# when has_cons_power. `powerNetIn`/`powerNetOut`/
	# `powerNetStored`/`powerNetCapacity` fold to 0 when
	# power is absent (duo) and, when it is present, read
	# their own graph frame key when present
	# (`last_scaled_power_in` / `last_scaled_power_out` /
	# `last_power_stored` / `last_capacity`, N2519 wiring)
	# and delegate to the matching leg function (absent
	# key keeps handled=false).
	# `enabled` reads the live frame enabled, absent
	# folding to true (`transient boolean enabled = true;`,
	# BuildingComp.java:77). `controlled` reads is_player:
	# `isControlled()` is `return unit().isPlayer();`
	# (ControlBlock.java:10-12) over the non-null proxy
	# unit (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`,
	# Turret.java:291; `public Unit unit(){`, :434-439) and
	# `public static final int ctrlProcessor = 1, ctrlPlayer = 2, ctrlCommand = 3;`
	# (GlobalVars.java:24) gives 2 for a player-controlled
	# block. `payloadCount` reads payload_count (base
	# `public @Nullable Payload getPayload(){`
	# :984 and `public @Nullable PayloadSeq getPayloads(){`
	# :993 both return null, so duo is 0). `size` reads
	# block_size (`public int size = 1;`, Block.java:215).
	# `cameraX`/`cameraY`/`cameraWidth`/`cameraHeight` are
	# wired (N2519): the UnitComp.sense delegation for the
	# proxy unit arrives as the `is_control_block` +
	# `unit_sense_value` frame keys when present (absent
	# keys keep handled:false); the branch delegates to
	# `source_building_comp_sense_camera_state`. The default (unknown
	# sensor) reports handled false + NaN, the same as
	# N2283. There is no driver tick line: sense is a logic
	# read, not a tick write (the N2206/N2208/N2223/N2283
	# precedent); the proof calls the pure function directly
	# with synthetic frames, and the logic-processor
	# dispatch hook is its own later slice. The result is
	# the N2206/N2208/N2223/N2283 sense wire shape:
	# `handled`, `sense_value`, `sense_value_is_nan`.
	if sensor == "x":
		var x_value: float = world_x / tilesize
		return {"handled": true, "sense_value": x_value, "sense_value_is_nan": false}
	if sensor == "y":
		var y_value: float = world_y / tilesize
		return {"handled": true, "sense_value": y_value, "sense_value_is_nan": false}
	if sensor == "color":
		var color_bits: int = (int(team_color_r * 255.0) << 24) | (int(team_color_g * 255.0) << 16) | (int(team_color_b * 255.0) << 8) | int(1.0 * 255.0)
		var color_bytes := PackedByteArray()
		color_bytes.resize(8)
		color_bytes.encode_u32(0, color_bits)
		var color_value: float = color_bytes.decode_double(0)
		return {"handled": true, "sense_value": color_value, "sense_value_is_nan": false}
	if sensor == "dead":
		if frame.has("tile_build_is_self") and frame.has("is_dead"):
			return source_building_comp_sense_dead_state(bool(frame.get("tile_build_is_self")), bool(frame.get("is_dead")))
		return {"handled": false, "sense_value": null, "sense_value_is_nan": true}
	if sensor == "solid":
		var solid_value: float = 1.0 if block_solid else 0.0
		return {"handled": true, "sense_value": solid_value, "sense_value_is_nan": false}
	if sensor == "team":
		var team_value: float = float(frame.get("team_id", 0))
		return {"handled": true, "sense_value": team_value, "sense_value_is_nan": false}
	if sensor == "health":
		if frame.has("health"):
			return source_building_comp_sense_health_state(float(frame.get("health")))
		return {"handled": false, "sense_value": null, "sense_value_is_nan": true}
	if sensor == "maxHealth":
		var max_health_value: float = max_health
		return {"handled": true, "sense_value": max_health_value, "sense_value_is_nan": false}
	if sensor == "efficiency":
		var efficiency_value: float = float(frame.get("efficiency", 0.0))
		return {"handled": true, "sense_value": efficiency_value, "sense_value_is_nan": false}
	if sensor == "timescale":
		var timescale_value: float = time_scale
		return {"handled": true, "sense_value": timescale_value, "sense_value_is_nan": false}
	if sensor == "range":
		var range_tiles: float = range_value / tilesize
		return {"handled": true, "sense_value": range_tiles, "sense_value_is_nan": false}
	if sensor == "rotation":
		var observed: Variant = frame.get("rotation", null)
		var rotation_value: float = 90.0 if observed == null else float(observed)
		return {"handled": true, "sense_value": rotation_value, "sense_value_is_nan": false}
	if sensor == "totalItems":
		if frame.has("items_is_null") and frame.has("items_total"):
			return source_building_comp_sense_total_items_state(bool(frame.get("items_is_null")), int(frame.get("items_total")))
		return {"handled": false, "sense_value": null, "sense_value_is_nan": true}
	if sensor == "totalLiquids":
		var total_liquids_value: float = total_liquids if has_liquids else 0.0
		return {"handled": true, "sense_value": total_liquids_value, "sense_value_is_nan": false}
	if sensor == "totalPower":
		var total_power_value: float = 0.0
		if has_power and has_cons_power:
			var power_status: float = float(frame.get("power_status", 1.0))
			total_power_value = power_status * (power_capacity if power_buffered else 1.0)
		return {"handled": true, "sense_value": total_power_value, "sense_value_is_nan": false}
	if sensor == "itemCapacity":
		var item_capacity_value: float = float(item_capacity) if has_items else 0.0
		return {"handled": true, "sense_value": item_capacity_value, "sense_value_is_nan": false}
	if sensor == "liquidCapacity":
		var liquid_capacity_value: float = liquid_capacity if has_liquids else 0.0
		return {"handled": true, "sense_value": liquid_capacity_value, "sense_value_is_nan": false}
	if sensor == "powerCapacity":
		var power_capacity_value: float = power_capacity if has_cons_power else 0.0
		return {"handled": true, "sense_value": power_capacity_value, "sense_value_is_nan": false}
	if sensor == "powerNetIn" or sensor == "powerNetOut" or sensor == "powerNetStored" or sensor == "powerNetCapacity":
		if not has_power:
			var power_net_value: float = 0.0
			return {"handled": true, "sense_value": power_net_value, "sense_value_is_nan": false}
		if sensor == "powerNetIn":
			if frame.has("last_scaled_power_in"):
				return source_building_comp_sense_power_net_in_state(not has_power, float(frame.get("last_scaled_power_in")))
		elif sensor == "powerNetOut":
			if frame.has("last_scaled_power_out"):
				return source_building_comp_sense_power_net_out_state(not has_power, float(frame.get("last_scaled_power_out")))
		elif sensor == "powerNetStored":
			if frame.has("last_power_stored"):
				return source_building_comp_sense_power_net_stored_state(not has_power, float(frame.get("last_power_stored")))
		elif sensor == "powerNetCapacity":
			if frame.has("last_capacity"):
				return source_building_comp_sense_power_net_capacity_state(not has_power, float(frame.get("last_capacity")))
		return {"handled": false, "sense_value": null, "sense_value_is_nan": true}
	if sensor == "enabled":
		var enabled_value: float = 1.0 if bool(frame.get("enabled", true)) else 0.0
		return {"handled": true, "sense_value": enabled_value, "sense_value_is_nan": false}
	if sensor == "controlled":
		var controlled_value: float = 2.0 if is_player else 0.0
		return {"handled": true, "sense_value": controlled_value, "sense_value_is_nan": false}
	if sensor == "payloadCount":
		var payload_count_value: float = float(payload_count)
		return {"handled": true, "sense_value": payload_count_value, "sense_value_is_nan": false}
	if sensor == "size":
		var size_value: float = float(block_size)
		return {"handled": true, "sense_value": size_value, "sense_value_is_nan": false}
	if sensor == "cameraX" or sensor == "cameraY" or sensor == "cameraWidth" or sensor == "cameraHeight":
		if frame.has("is_control_block") and frame.has("unit_sense_value"):
			return source_building_comp_sense_camera_state(sensor, bool(frame.get("is_control_block")), float(frame.get("unit_sense_value")))
		return {"handled": false, "sense_value": null, "sense_value_is_nan": true}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

static func source_building_comp_sense_dead_state(tile_build_is_self: bool, is_dead: bool) -> Dictionary:
	# BuildingComp.sense() `dead` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case dead -> !isValid() ? 1 : 0;`
	# (:2098) -- `isValid()` is `public boolean isValid(){` /
	# `return tile.build == self() && !dead();`
	# (:2030-2032). The two conjuncts are passed in as params
	# (the N2212/N2220 per-def-param precedent): the tile
	# state is not stamped in the frame yet, so
	# `tile_build_is_self` is `tile.build == self()` (:2031,
	# first conjunct) and `is_dead` is `dead()` (:2031,
	# second conjunct, negated in `isValid()`). The sensor
	# spelling is the LAccess enum name: `dead,`
	# (LAccess.java:47). The result is the N2283/N2284 sense
	# wire shape: handled + sense_value +
	# sense_value_is_nan; the leg never yields NaN (the
	# default `default -> Float.NaN; //gets converted to null in logic`,
	# :2123, never fires here). There is no driver tick
	# line: the leg is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510
	# precedent); the proof calls the pure function directly
	# with synthetic inputs. This does NOT wire into
	# source_building_comp_sense_state: dead stays
	# handled:false in the big dispatch until a later wiring
	# slice connects this leg (same as N2508's Content leg
	# living beside N2284).
	var is_valid: bool = tile_build_is_self and not is_dead
	var dead_value: float = 0.0 if is_valid else 1.0
	return {"handled": true, "sense_value": dead_value, "sense_value_is_nan": false}

static func source_building_comp_sense_health_state(health: float) -> Dictionary:
	# BuildingComp.sense() `health` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case health -> health;`
	# (:2101) -- `health` is the building's current health
	# field (`float health;`, HealthComp.java:11 --
	# BuildingComp mixes HealthComp). The live health is
	# passed in as a param (the N2212/N2220 per-def-param
	# precedent): the live building health is not stamped
	# in the frame yet, so a future frame-stamp slice will
	# supply it. The value is returned exactly, no
	# clamping, no rounding, no healthf() conversion
	# (`healthf()` is a different accessor,
	# HealthComp.java:20, NOT this leg). The sensor
	# spelling is the LAccess enum name: `health,`
	# (LAccess.java:22). The result is the N2283/N2284 sense
	# wire shape: handled + sense_value +
	# sense_value_is_nan; the leg never yields NaN (the
	# default `default -> Float.NaN; //gets converted to null in logic`,
	# :2123, never fires here). There is no driver tick
	# line: the leg is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511
	# precedent); the proof calls the pure function directly
	# with synthetic inputs. This does NOT wire into
	# source_building_comp_sense_state: health stays
	# handled:false in the big dispatch until a later wiring
	# slice connects this leg (same as N2511's dead leg
	# living beside N2284).
	return {"handled": true, "sense_value": health, "sense_value_is_nan": false}

static func source_building_comp_sense_total_items_state(items_is_null: bool, items_total: int) -> Dictionary:
	# BuildingComp.sense() `totalItems` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case totalItems -> items == null ? 0 : items.total();`
	# (:2107) -- `items` is the building's item module
	# (`@Nullable ItemModule items;`, BuildingComp.java:81)
	# and `items.total()` its total item count
	# (`public int total(){`, ItemModule.java:174 --
	# returns int). The two
	# params are the live input a future frame-stamp slice
	# will supply (the N2212/N2220 per-def-param
	# precedent): the live inventory total is not stamped
	# in the frame yet, so `items_is_null` is `items ==
	# null` (:2107, first branch of the ternary) and
	# `items_total` is `items.total()`. The value is
	# returned exactly: 0.0 when items is null, else
	# `float(items_total)` (Java `sense()` returns double;
	# the int widens exactly), no clamping, no rounding.
	# The sensor spelling is the LAccess enum name:
	# `totalItems,` (LAccess.java:7). The result is the
	# N2283/N2284 sense wire shape: handled + sense_value +
	# sense_value_is_nan; the leg never yields NaN (the
	# default `default -> Float.NaN; //gets converted to null in logic`,
	# :2123, never fires here). There is no driver tick
	# line: the leg is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512
	# precedent); the proof calls the pure function directly
	# with synthetic inputs. This does NOT wire into
	# source_building_comp_sense_state: totalItems stays
	# handled:false in the big dispatch until a later wiring
	# slice connects this leg (same as N2511's dead leg and
	# N2512's health leg living beside N2284).
	var total_items_value: float = 0.0 if items_is_null else float(items_total)
	return {"handled": true, "sense_value": total_items_value, "sense_value_is_nan": false}

static func source_building_comp_sense_power_net_in_state(power_is_null: bool, last_scaled_power_in: float) -> Dictionary:
	# BuildingComp.sense() `powerNetIn` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`
	# (:2114) -- `power` is the building's power module
	# (`@Nullable PowerModule power;`, BuildingComp.java:80)
	# and `power.graph.getLastScaledPowerIn()` the graph's
	# last scaled power-in per tick (`public float getLastScaledPowerIn(){`,
	# PowerGraph.java:45-47 -- returns float; updated :233
	# `lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta`). The
	# `* 60` converts the per-tick value to a per-second
	# rate. The two params are the live input a future
	# frame-stamp slice will supply (the N2212/N2220
	# per-def-param precedent): the live graph values are
	# not stamped in the frame yet, so `power_is_null` is
	# `power == null` (:2114, first branch of the ternary)
	# and `last_scaled_power_in` is
	# `power.graph.getLastScaledPowerIn()`. The value is
	# returned exactly: 0.0 when power is null, else
	# `last_scaled_power_in * 60.0` (Java `sense()` returns
	# double; the float widens exactly), no clamping, no
	# rounding. The sensor spelling is the LAccess enum
	# name: `powerNetIn,` (LAccess.java:16). The result is
	# the N2283/N2284 sense wire shape: handled +
	# sense_value + sense_value_is_nan; the leg never
	# yields NaN (the default `default -> Float.NaN;
	# //gets converted to null in logic`, :2123, never
	# fires here). There is no driver tick line: the leg
	# is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513
	# precedent); the proof calls the pure function
	# directly with synthetic inputs. This does NOT wire
	# into source_building_comp_sense_state: powerNetIn
	# stays handled:false in the big dispatch until a
	# later wiring slice connects this leg (same as
	# N2511's dead leg, N2512's health leg and N2513's
	# totalItems leg living beside N2284).
	var power_net_in_value: float = 0.0 if power_is_null else last_scaled_power_in * 60.0
	return {"handled": true, "sense_value": power_net_in_value, "sense_value_is_nan": false}

static func source_building_comp_sense_power_net_out_state(power_is_null: bool, last_scaled_power_out: float) -> Dictionary:
	# BuildingComp.sense() `powerNetOut` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`
	# (:2115) -- `power` is the building's power module
	# (`@Nullable PowerModule power;`, BuildingComp.java:80)
	# and `power.graph.getLastScaledPowerOut()` the graph's
	# last scaled power-out per tick (`public float getLastScaledPowerOut(){`,
	# PowerGraph.java:49-51 -- returns float; updated :234
	# `lastScaledPowerOut = powerNeeded / Time.delta`). The
	# `* 60` converts the per-tick value to a per-second
	# rate. The two params are the live input a future
	# frame-stamp slice will supply (the N2212/N2220
	# per-def-param precedent): the live graph values are
	# not stamped in the frame yet, so `power_is_null` is
	# `power == null` (:2115, first branch of the ternary)
	# and `last_scaled_power_out` is
	# `power.graph.getLastScaledPowerOut()`. The value is
	# returned exactly: 0.0 when power is null, else
	# `last_scaled_power_out * 60.0` (Java `sense()` returns
	# double; the float widens exactly), no clamping, no
	# rounding. The sensor spelling is the LAccess enum
	# name: `powerNetOut,` (LAccess.java:17). The result is
	# the N2283/N2284 sense wire shape: handled +
	# sense_value + sense_value_is_nan; the leg never
	# yields NaN (the default `default -> Float.NaN;
	# //gets converted to null in logic`, :2123, never
	# fires here). There is no driver tick line: the leg
	# is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514
	# precedent); the proof calls the pure function
	# directly with synthetic inputs. This does NOT wire
	# into source_building_comp_sense_state: powerNetOut
	# stays handled:false in the big dispatch until a
	# later wiring slice connects this leg (same as
	# N2511's dead leg, N2512's health leg, N2513's
	# totalItems leg and N2514's powerNetIn leg living
	# beside N2284).
	var power_net_out_value: float = 0.0 if power_is_null else last_scaled_power_out * 60.0
	return {"handled": true, "sense_value": power_net_out_value, "sense_value_is_nan": false}

static func source_building_comp_sense_power_net_stored_state(power_is_null: bool, last_power_stored: float) -> Dictionary:
	# BuildingComp.sense() `powerNetStored` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();`
	# (:2116) -- `power` is the building's power module
	# (`@Nullable PowerModule power;`, BuildingComp.java:80)
	# and `power.graph.getLastPowerStored()` the graph's
	# last stored battery power (`public float getLastPowerStored(){`,
	# PowerGraph.java:73-75 -- returns float; updated :236
	# `lastPowerStored = getBatteryStored()`). There is NO
	# `* 60` here, unlike powerNetIn/powerNetOut -- the
	# stored value is an absolute amount (battery charge),
	# not a per-tick rate, so it is returned as-is. The two
	# params are the live input a future frame-stamp slice
	# will supply (the N2212/N2220 per-def-param precedent):
	# the live graph values are not stamped in the frame
	# yet, so `power_is_null` is `power == null` (:2116,
	# first branch of the ternary) and `last_power_stored`
	# is `power.graph.getLastPowerStored()`. The value is
	# returned exactly: 0.0 when power is null, else
	# `last_power_stored` (Java `sense()` returns double;
	# the float widens exactly), no clamping, no rounding.
	# The sensor spelling is the LAccess enum name:
	# `powerNetStored,` (LAccess.java:14). The result is
	# the N2283/N2284 sense wire shape: handled +
	# sense_value + sense_value_is_nan; the leg never
	# yields NaN (the default `default -> Float.NaN;
	# //gets converted to null in logic`, :2123, never
	# fires here). There is no driver tick line: the leg
	# is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515
	# precedent); the proof calls the pure function
	# directly with synthetic inputs. This does NOT wire
	# into source_building_comp_sense_state: powerNetStored
	# stays handled:false in the big dispatch until a
	# later wiring slice connects this leg (same as
	# N2511's dead leg, N2512's health leg, N2513's
	# totalItems leg, N2514's powerNetIn leg and N2515's
	# powerNetOut leg living beside N2284).
	var power_net_stored_value: float = 0.0 if power_is_null else last_power_stored
	return {"handled": true, "sense_value": power_net_stored_value, "sense_value_is_nan": false}

static func source_building_comp_sense_power_net_capacity_state(power_is_null: bool, last_capacity: float) -> Dictionary:
	# BuildingComp.sense() `powerNetCapacity` leg (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();`
	# (:2117) -- `power` is the building's power module
	# (`@Nullable PowerModule power;`, BuildingComp.java:80)
	# and `power.graph.getLastCapacity()` the graph's
	# last total battery capacity (`public float getLastCapacity(){`,
	# PowerGraph.java:53-54 -- returns float; updated :235
	# `lastCapacity = getTotalBatteryCapacity()`). There is NO
	# `* 60` here, unlike powerNetIn/powerNetOut -- the
	# capacity is an absolute amount (total battery
	# capacity), not a per-tick rate, so it is returned as-is.
	# The two params are the live input a future frame-stamp
	# slice will supply (the N2212/N2220 per-def-param
	# precedent): the live graph values are not stamped in
	# the frame yet, so `power_is_null` is `power == null`
	# (:2117, first branch of the ternary) and `last_capacity`
	# is `power.graph.getLastCapacity()`. The value is
	# returned exactly: 0.0 when power is null, else
	# `last_capacity` (Java `sense()` returns double;
	# the float widens exactly), no clamping, no rounding.
	# The sensor spelling is the LAccess enum name:
	# `powerNetCapacity,` (LAccess.java:15). The result is
	# the N2283/N2284 sense wire shape: handled +
	# sense_value + sense_value_is_nan; the leg never
	# yields NaN (the default `default -> Float.NaN;
	# //gets converted to null in logic`, :2123, never
	# fires here). There is no driver tick line: the leg
	# is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516
	# precedent); the proof calls the pure function
	# directly with synthetic inputs. This does NOT wire
	# into source_building_comp_sense_state: powerNetCapacity
	# stays handled:false in the big dispatch until a
	# later wiring slice connects this leg (same as
	# N2511's dead leg, N2512's health leg, N2513's
	# totalItems leg, N2514's powerNetIn leg, N2515's
	# powerNetOut leg and N2516's powerNetStored leg
	# living beside N2284).
	var power_net_capacity_value: float = 0.0 if power_is_null else last_capacity
	return {"handled": true, "sense_value": power_net_capacity_value, "sense_value_is_nan": false}

static func source_building_comp_sense_camera_state(sensor: String, is_control_block: bool, unit_sense_value: float) -> Dictionary:
	# BuildingComp.sense() `cameraX/cameraY/cameraWidth/cameraHeight` legs
	# (`public double sense(LAccess sensor){`,
	# BuildingComp.java:2093-2126): `case cameraX, cameraY, cameraWidth,
	# cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`
	# (:2122, the last leg of sense()) -- the sensor spellings are the
	# LAccess enum names: `cameraX,` `cameraY,` `cameraWidth,`
	# `cameraHeight,` (LAccess.java:37-40). The four legs share ONE Java
	# case line and ONE delegation expression, so one pure function ports
	# all four with a `sensor` param (splitting into four slices would
	# quadruple near-identical functions for zero additional Java
	# coverage). The delegation target already exists in the port:
	# `SourceUnitSensorState.laccess_state`
	# (SourceUnitSensorState.gd:41-44) ports the UnitComp.sense camera
	# legs -- `case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`
	# (UnitComp.java:283, and cameraY/cameraWidth/cameraHeight
	# analogously at :284-286) -- 0 when the controller is not a
	# Player, else `World.conv` of the player view / core camera value. This slice ports ONLY the BuildingComp gate
	# (`instanceof ControlBlock` + fallback 0 + pass-through of the unit
	# sense value); it does NOT re-port the unit-side camera math.
	# The three params are the live input a future frame-stamp/wiring
	# slice will supply (the N2212/N2220 per-def-param precedent):
	# `sensor` is one of the four camera labels, `is_control_block` is
	# `this instanceof ControlBlock` (:2122, the gate of the ternary)
	# and `unit_sense_value` is `c.unit().sense(sensor)` -- the
	# already-ported unit sense result for this sensor. The value is
	# returned exactly: 0.0 when not a control block, else
	# `unit_sense_value` (Java `sense()` returns double; the float
	# widens exactly), no clamping, no rounding, no World.conv here
	# (the conv already happened inside the unit sense call). The
	# function does NOT validate the sensor: the dispatch guarantees
	# one of the four labels, same as the N2511-N2517 fixed-sensor
	# functions do not validate theirs. The result is the
	# N2283/N2284 sense wire shape: handled + sense_value +
	# sense_value_is_nan; the leg never yields NaN (the default
	# `default -> Float.NaN; //gets converted to null in logic`, :2123,
	# never fires here). There is no driver tick line: the leg is a
	# logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517
	# precedent); the proof calls the pure function directly with
	# synthetic inputs. This does NOT wire into
	# source_building_comp_sense_state: camera* stay handled:false in
	# the big dispatch until a later wiring slice connects this leg
	# (same as N2511's dead leg, N2512's health leg, N2513's totalItems
	# leg, N2514's powerNetIn leg, N2515's powerNetOut leg, N2516's
	# powerNetStored leg and N2517's powerNetCapacity leg living beside
	# N2284).
	var camera_value: float = 0.0 if not is_control_block else unit_sense_value
	return {"handled": true, "sense_value": camera_value, "sense_value_is_nan": false}

static func source_turret_sense_object_state(sensor: String, block_id: String, first_item: String) -> Dictionary:
	# BuildingComp.senseObject() (BuildingComp.java:2128-2136):
	# `public Object senseObject(LAccess sensor){` /
	# return switch(sensor){
	# case type -> block;
	# case firstItem -> items == null ? null : items.first();
	# case config -> block.configSenseable() ? config() : null;
	# case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;
	# default -> noSensed;
	# };
	# The sensor spellings are the LAccess enum names:
	#     firstItem,
	#     type,
	#     payloadType,
	#     config(true, "to"),
	# The `type` leg returns the block itself; the port identity of a block is its id string: duo (`duo = new ItemTurret("duo"){{`, Blocks.java:3257) of the building (`public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`, Turret.java:277).
	# The `firstItem` leg is LIVE inventory, not a constant: duo hasItems (`hasItems = true;`, ItemTurret.java:28), so `if(block.hasItems) items = new ItemModule();` (BuildingComp.java:145) runs and items is non-null; `first()` (`public @Nullable Item first(){`, ItemModule.java:182-189) scans items[] in content order and returns the first item with count > 0 (`return content.item(i);`), else null. The frame carries no items key, so the observed first item is an explicit String param `first_item` (the N2212/N2220 per-def-param precedent): "" encodes null (items null or empty), otherwise the item id ("copper" -- duo ammo is copper / graphite / silicon, Blocks.java:3257-3331; copper is content order first).
	# `config` is constant null for duo, pinned not guessed: `configSenseable()` (`public boolean configSenseable(){`, Block.java:809-812, `return configurations.containsKey(Item.class) || configurations.containsKey(Liquid.class) || configurations.containsKey(UnlockableContent.class) ||` / `configurations.containsKey(Block.class) || configurations.containsKey(UnitType.class);`) is true only when `configurations` (`public ObjectMap<Class<?>, Cons2> configurations = new ObjectMap<>();`, Block.java:402) holds one of the five handlers, and no `config(` registration exists in any turret file, so duo's map has none of them and configSenseable() is false -- the short-circuit returns null regardless of `config()` (base returns null anyway, `public Object config(){`, BuildingComp.java:2024, no turret override).
	# `payloadType` is constant null for duo, pinned not guessed: the base `getPayload()` returns null (`public @Nullable Payload getPayload(){`, BuildingComp.java:984-985) and no turret file overrides it, so neither instanceof arm can fire.
	# An unhandled sensor falls through to the `noSensed` sentinel (`Object noSensed = new Object();`, Senseable.java:6), which the logic converts to a numeric `sense()` fallback (`if(objOut == Senseable.noSensed){` / `to.setnum(se.sense(la));`, LExecutor.java:697-699) -- the port reports it as `handled: false` + `is_no_sensed: true`, the sense() N2223 `sense_value_is_nan` precedent, so the caller knows to fall back to `source_turret_sense_state` / `source_building_comp_sense_state`. There is no driver tick line: senseObject is a logic read, not a tick write (the N2206/N2208/N2223/N2283/N2284/N2234 precedent); the logic-processor dispatch hook is its own later slice.
	if sensor == "type":
		return {"handled": true, "sense_object": block_id, "is_no_sensed": false}
	if sensor == "firstItem":
		var first_item_value: Variant = first_item if first_item != "" else null
		return {"handled": true, "sense_object": first_item_value, "is_no_sensed": false}
	if sensor == "config" or sensor == "payloadType":
		return {"handled": true, "sense_object": null, "is_no_sensed": false}
	return {"handled": false, "sense_object": null, "is_no_sensed": true}

static func source_logic_sense_dispatch_state(sensor: String, target_is_null: bool, sense_object_handled: bool, sense_object: Variant, sense_value: float) -> Dictionary:
	# SenseI.run() (LExecutor.java:681-718):
	# `public static class SenseI implements LInstruction{` /
	# `public void run(LExecutor exec){` /
	# `Object target = from.obj();` /
	# `Object sense = type.obj();` /
	# `if(target == null && sense == LAccess.dead){` /
	# `to.setnum(1);` /
	# `return;` /
	# `}` /
	# `//note that remote units/buildings can be sensed as well` /
	# `if(target instanceof Senseable se){` /
	# `if(sense instanceof Content co){` /
	# `to.setnum(se.sense(co));` /
	# `}else if(sense instanceof LAccess la){` /
	# `Object objOut = se.senseObject(la);` /
	# `if(objOut == Senseable.noSensed){` /
	# `//numeric output` /
	# `to.setnum(se.sense(la));` /
	# `}else{` /
	# `//object output` /
	# `to.setobj(objOut);` /
	# `}` /
	# `}` /
	# `}else{` /
	# `if(sense == LAccess.size || sense == LAccess.bufferSize){` /
	# `if(target instanceof CharSequence seq){` /
	# `to.setnum(seq.length());` /
	# `return;` /
	# `}else if(target instanceof Seq<?> seq){` /
	# `to.setnum(seq.size);` /
	# `return;` /
	# `}` /
	# `}` /
	# `to.setobj(null);` /
	# `}` /
	# `}` -- the logic-processor `sense` op dispatch. It composes
	# the three functions the previous slices built:
	# `source_turret_sense_state` (N2283, Turret.sense,
	# `public double sense(LAccess sensor){`, Turret.java:405-419,
	# `case ammo -> totalAmmo;`, :414), `source_building_comp_sense_state`
	# (N2284, super.sense, BuildingComp.java:2093-2126) and
	# `source_turret_sense_object_state` (N2506, senseObject,
	# `public Object senseObject(LAccess sensor){`,
	# BuildingComp.java:2128-2136). The hook itself decides only
	# which output the logic variable receives -- object or number
	# -- and does NOT re-implement any sensor leg: the numeric
	# fallback value is passed in as `sense_value` (the
	# N2212/N2220 per-def-param precedent), and the senseObject
	# outcome is passed in as `sense_object` + `sense_object_handled`.
	# The null-target dead leg is checked FIRST, before senseObject
	# (LExecutor.java:685-687): a null target + `dead` writes num 1
	# even when senseObject would have handled the sensor. `dead` is
	# `    dead,` (LAccess.java:47). A handled senseObject writes its
	# object with `to.setobj(objOut);` (LExecutor.java:701-703) --
	# including a null object: the `config` / `payloadType` legs
	# return null from senseObject (N2506) and that null is NOT the
	# sentinel, so the dispatch writes obj null and never falls back
	# to numeric sense. On the sentinel (`Object noSensed = new Object();`,
	# Senseable.java:6; `default Object senseObject(LAccess sensor){` /
	# `return noSensed;`, Senseable.java:14-16) the dispatch writes
	# the numeric sense value (`to.setnum(se.sense(la));`,
	# LExecutor.java:697-699) and reports `is_no_sensed: true`.
	# The Content leg (`if(sense instanceof Content co){` /
	# `to.setnum(se.sense(co));`, LExecutor.java:692-693) is deferred:
	# it needs BuildingComp.sense(Content) live inventory counts.
	# The non-Senseable size/bufferSize legs (`if(sense == LAccess.size
	# || sense == LAccess.bufferSize){`, LExecutor.java:704-717) are
	# deferred: the target is no building at all. There is no driver
	# tick line: the dispatch is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506 precedent); the proof calls
	# the pure function directly with synthetic inputs. The result is
	# a 4-key dict: `handled` + `output_kind` ("num" / "obj") +
	# `output_value` + `is_no_sensed`.
	if target_is_null and sensor == "dead":
		return {"handled": true, "output_kind": "num", "output_value": 1.0, "is_no_sensed": false}
	if sense_object_handled:
		return {"handled": true, "output_kind": "obj", "output_value": sense_object, "is_no_sensed": false}
	return {"handled": true, "output_kind": "num", "output_value": sense_value, "is_no_sensed": true}

static func source_logic_sense_content_state(content_kind: String, has_items: bool, item_count: float, has_liquids: bool, liquid_amount: float, has_payloads: bool, payload_unit_count: float, payload_block_count: float) -> Dictionary:
	# SenseI.run() Content leg (LExecutor.java:692-693):
	# `if(sense instanceof Content co){` /
	# `to.setnum(se.sense(co));` -- the logic-processor `sense` op
	# with a `Content` sensor calls BuildingComp.sense(Content)
	# (BuildingComp.java:2139-2147):
	# `public double sense(Content content){` /
	# `if(content instanceof Item i && items != null) return items.get(i);` /
	# `if(content instanceof Liquid l && liquids != null) return liquids.get(l);` /
	# `if(getPayloads() != null){` /
	# `if(content instanceof UnitType u) return getPayloads().get(u);` /
	# `if(content instanceof Block b) return getPayloads().get(b);` /
	# `}` /
	# `return Float.NaN; //invalid sense` /
	# `}` -- it is the other branch of the same SenseI.run()
	# dispatch as `source_logic_sense_dispatch_state` (N2507,
	# `public static class SenseI implements LInstruction{`,
	# LExecutor.java:668; `if(target instanceof Senseable se){`,
	# :691), so it sits immediately after that hook. The counts
	# are passed in as params (the N2212/N2220 per-def-param
	# precedent): the pure function does not read the frame. The
	# instanceof checks are ordered Item -> Liquid -> payloads,
	# so an Item sensor with `items == null` does NOT fall into
	# the payload legs -- a non-payload Content kind reaches NaN
	# even when payloads exist. The leg always writes with
	# `to.setnum`, never `to.setobj`, so `output_kind` is always
	# "num" and `handled` is true for every modeled leg.
	# `is_invalid` is true only on the NaN leg (the N2284
	# `sense_value_is_nan` precedent). There is no driver tick
	# line: the leg is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507 precedent); the
	# proof calls the pure function directly with synthetic inputs.
	if content_kind == "item" and has_items:
		return {"handled": true, "output_kind": "num", "output_value": item_count, "is_invalid": false}
	if content_kind == "liquid" and has_liquids:
		return {"handled": true, "output_kind": "num", "output_value": liquid_amount, "is_invalid": false}
	if content_kind == "unit" and has_payloads:
		return {"handled": true, "output_kind": "num", "output_value": payload_unit_count, "is_invalid": false}
	if content_kind == "block" and has_payloads:
		return {"handled": true, "output_kind": "num", "output_value": payload_block_count, "is_invalid": false}
	return {"handled": true, "output_kind": "num", "output_value": NAN, "is_invalid": true}

static func source_logic_sense_laccess_state(sensor: String, turret_handled: bool, turret_sense_value: Variant, comp_handled: bool, comp_sense_value: Variant) -> Dictionary:
	# SenseI.run() LAccess leg (LExecutor.java:694-703):
	# `}else if(sense instanceof LAccess la){` /
	# `Object objOut = se.senseObject(la);` /
	# `if(objOut == Senseable.noSensed){` /
	# `to.setnum(se.sense(la));` /
	# `}else{` / `to.setobj(objOut);` / `}` -- on the
	# noSensed sentinel the dispatch writes the numeric
	# `se.sense(la)` value (`public static class SenseI implements LInstruction{`,
	# LExecutor.java:668; `if(target instanceof Senseable se){`,
	# :691). For a duo turret that value is Turret.sense
	# (`public double sense(LAccess sensor){`,
	# Turret.java:405-419: `case ammo -> totalAmmo;` /
	# `case rotation -> rotation;` /
	# `case progress -> progress();`), whose `default`
	# falls through to super.sense (`default ->
	# super.sense(sensor);`, Turret.java:415;
	# BuildingComp.sense, BuildingComp.java:2093-2126),
	# whose default is NaN (`default -> Float.NaN; //gets
	# converted to null in logic`, :2123). Java dispatch
	# order is Turret.sense FIRST, so a sensor handled by
	# Turret.sense never reaches BuildingComp.sense -- the
	# only overlap is `rotation`, handled by both switches
	# over the same live frame value. The two sense outcomes
	# are passed in as params (the N2212/N2220 per-def-param
	# precedent, same as N2507 passing in `sense_value`); the
	# pure function does not re-implement the 30 sensor legs.
	# The result is the N2283/N2284 sense wire shape:
	# handled + sense_value + sense_value_is_nan. There is
	# no driver tick line: the leg is a logic read, not a
	# tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509
	# precedent); the proof calls the pure function directly
	# with synthetic inputs.
	if turret_handled:
		return {"handled": true, "sense_value": turret_sense_value, "sense_value_is_nan": false}
	if comp_handled:
		return {"handled": true, "sense_value": comp_sense_value, "sense_value_is_nan": false}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

static func source_logic_sense_size_state(sensor: String, target_kind: String, string_length: float, seq_size: float) -> Dictionary:
	# SenseI.run() non-Senseable else-branch (LExecutor.java:705-717):
	# `}else{` /
	# `if(sense == LAccess.size || sense == LAccess.bufferSize){` /
	# `if(target instanceof CharSequence seq){` /
	# `to.setnum(seq.length());` /
	# `return;` /
	# `}else if(target instanceof Seq<?> seq){` /
	# `to.setnum(seq.size);` /
	# `return;` /
	# `}` /
	# `to.setobj(null);` /
	# `}` -- the logic-processor `sense` op when the target is NOT
	# a Senseable (`if(target instanceof Senseable se){`,
	# LExecutor.java:691; `public static class SenseI implements
	# LInstruction{`, :668): a size / bufferSize sensor on a
	# CharSequence logic var writes its length with to.setnum, on
	# a Seq<?> logic var writes its size with to.setnum, and any
	# other sensor or target falls through to to.setobj(null).
	# The sensor spellings are the LAccess enum names: `size,`
	# (LAccess.java:45) and `bufferSize,` (:43). The CharSequence
	# arm is checked before the Seq arm (`if` / `else if`), so a
	# target matching both would take the length leg. Both
	# to.setnum legs return early, so they never reach the
	# fall-through. The null-target dead leg (`if(target == null
	# && sense == LAccess.dead){` / `to.setnum(1);`, :685-686) is
	# checked FIRST, before this branch, and was already ported
	# by N2507 -- a null target only reaches this branch when
	# sense != dead, and instanceof is false for null on both
	# arms. The length / size are passed in as params (the
	# N2212/N2220 per-def-param precedent): the pure function
	# does not read the frame. `is_null` is true only on the
	# fall-through leg (the N2507 `is_no_sensed` / N2508
	# `is_invalid` precedent). There is no driver tick line:
	# the legs are logic reads, not tick writes (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508 precedent);
	# the proof calls the pure function directly with synthetic
	# inputs.
	if (sensor == "size" or sensor == "bufferSize") and target_kind == "string":
		return {"handled": true, "output_kind": "num", "output_value": string_length, "is_null": false}
	if (sensor == "size" or sensor == "bufferSize") and target_kind == "seq":
		return {"handled": true, "output_kind": "num", "output_value": seq_size, "is_null": false}
	return {"handled": true, "output_kind": "obj", "output_value": null, "is_null": true}

static func source_turret_is_shooting_state(always_shooting: bool, is_player: bool, player_is_shooting: bool, logic_controlled: bool, logic_shooting: bool, has_target: bool) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) sets the
	# shooting flag at the head of the tick, first line after
	# the validateTarget verdict:
	# `isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);`
	# (Turret.java:492). alwaysShooting is
	# `public boolean alwaysShooting = false;` (:103); the
	# player branch is `public boolean controlled(){` /
	# `return unit.isPlayer();` (:441-443) with the unit's own
	# isShooting; the logic branch is `public boolean
	# logicControlled(){` / `return logicControlTime > 0;`
	# (:445-447) with `public boolean logicShooting = false;`
	# (:288, set by the control() setters :384/:394, N2264);
	# the default branch is target != null after the :491
	# verdict (N2251). The flag feeds the warmup target
	# (`float warmupTarget = (isShooting && canConsume()) ||
	# charging() ? 1f : 0f;`, :502, N2253) and shouldConsume
	# (Turret.java:364-366, N2241). Duo has no player and no
	# logic by default, so isShooting is target != null after
	# the verdict -- but the driver had no frame["is_shooting"]
	# stamp and no standalone pure function: N2253 folded the
	# formula inline as the warmup call's is_shooting arg.
	# The result is a 1-key dict: `is_shooting`.
	var is_shooting: bool = always_shooting or (player_is_shooting if is_player else (logic_shooting if logic_controlled else has_target))
	return {"is_shooting": is_shooting}

static func source_turret_recoil_heat_state(cur_recoil: float, heat: float, recoil_time: float, cooldown_time: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-532) decays the
	# recoil and the heat after the warmup advance and before it
	# aims or shoots: `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);`
	# (Turret.java:519) and `heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);`
	# (:526). approachDelta is `public static float approachDelta(float from, float to, float speed){` /
	# `return approach(from, to, Time.delta * speed);` (arc Mathf.java:420-422) with
	# approach `public static float approach(float from, float to, float speed){` /
	# `return from + Mathf.clamp(to - from, -speed, speed);` (:415-417), so each tick
	# moves the value toward 0 by delta / recoilTime (resp. delta / cooldownTime),
	# never past 0. Class defaults are `public float recoil = 1f;` (:140),
	# `public int recoils = -1;` (:142), `public float recoilTime = -1f;` (:144),
	# `public float recoilPow = 1.8f;` (:146), `public float cooldownTime = 20f;` (:148);
	# the init is `if(recoilTime < 0f) recoilTime = reload;` /
	# `if(cooldownTime < 0f) cooldownTime = reload;` (:208-209 -- duo reload is 20,
	# N2250, so recoilTime is 20 and cooldownTime stays 20, a 0.05-per-tick rate).
	# The fields are `public float curRecoil, heat, logicControlTime = -1;` (:284).
	# The multi-recoil loop (`if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` / `}`,
	# :520-525) is NOT this slice: it waits for its own slice (N2256) -- duo recoils is 2
	# (`recoils = 2;`, Blocks.java:3301), not the -1 class default, so the loop applies
	# to duo. The shoot stamp (`curRecoil = 1f;` /
	# `heat = 1f;`, :807-810) and the draw offset
	# (`recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);`, :532)
	# are NOT this slice either: the shoot stamp waits with the shoot-stamp slice
	# (N2252 only stamped frame["bullet_spawn"]) and the offset is draw-side.
	# The result is a 2-key dict: `cur_recoil` (after the approachDelta step toward 0)
	# and `heat` (after the approachDelta step toward 0). Delta is the live-loop
	# seconds value, the same convention as the N2253 warmup.
	cur_recoil = cur_recoil + clampf(0.0 - cur_recoil, -delta / recoil_time, delta / recoil_time)
	heat = heat + clampf(0.0 - heat, -delta / cooldown_time, delta / cooldown_time)
	return {"cur_recoil": cur_recoil, "heat": heat}

static func source_turret_multi_recoil_state(cur_recoils: Array, recoils: int, recoil_time: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-532) decays the
	# per-barrel recoil counters right after the singular recoil
	# decay: `if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` / `}`
	# (Turret.java:520-525). The field is `public @Nullable float[] curRecoils;` (:285),
	# null until the first updateTile tick allocates it, and the class default is
	# `public int recoils = -1;` (:142) -- but duo overrides it: `recoils = 2;`
	# (Blocks.java:3301, inside the duo block 3257-3330), so the loop DOES apply
	# to duo: its two drawer barrel parts carry recoilIndex 0 / 1 (Blocks.java:3302-3311)
	# and DrawTurret reads `tb.curRecoils[part.recoilIndex]` (DrawTurret.java:104/115),
	# so without the decay the barrel recoil never falls back toward 0. The init is
	# `if(recoilTime < 0f) recoilTime = reload;` (:208 -- duo reload is 20, N2250, so
	# recoilTime is 20 and each entry steps toward 0 by delta / 20, never past 0,
	# the same approachDelta as the singular decay (`curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);`,
	# :519; arc Mathf.java:415-422). The result is a 1-key dict: `cur_recoils`, a NEW
	# array of length recoils (missing entries read as 0.0, so a null / absent frame
	# key inits to zeros) -- the input array is never mutated. Delta is the
	# live-loop seconds value, the same convention as the N2254 recoil/heat decay.
	var decayed: Array = []
	if recoils > 0:
		for i in range(recoils):
			var value: float = 0.0
			if i < cur_recoils.size():
				value = float(cur_recoils[i])
			decayed.append(value + clampf(0.0 - value, -delta / recoil_time, delta / recoil_time))
	return {"cur_recoils": decayed}

@warning_ignore("unused_parameter")
static func source_turret_shoot_stamp_state(cur_recoil: float, heat: float, total_shots: int) -> Dictionary:
	# TurretBuild.bullet() (Turret.java:779-812) stamps the recoil
	# and the heat and counts the shot after the bullet is created
	# and handled: `curRecoil = 1f;` (Turret.java:806),
	# `heat = 1f;` (:810) and `totalShots++;` (:811). The fields are
	# `public float curRecoil, heat, logicControlTime = -1;` (:284) and
	# `public int totalShots, barrelCounter;` (:287), both default 0.
	# The multi-recoil stamp (`if(recoils > 0){` /
	# `curRecoils[barrelCounter % recoils] = 1f;` / `}`, :807-809) is
	# NOT this slice: it waits for its own slice (N2257) -- duo
	# recoils is 2 (`recoils = 2;`, Blocks.java:3301), not the -1
	# class default (`public int recoils = -1;`, :142), so the
	# branch applies to duo. The effects / sound / shake lines
	# (:799-805) are NOT this slice either. The result is a 3-key
	# dict: `cur_recoil` 1.0, `heat` 1.0 and `total_shots` (the
	# pre-shot count + 1). The inputs are the pre-shot frame values,
	# so the pure function maps any decayed recoil / heat to 1.0 and
	# any count to count + 1; the next tick decays from 1.0 (N2254).
	return {"cur_recoil": 1.0, "heat": 1.0, "total_shots": total_shots + 1}

static func source_turret_multi_recoil_stamp_state(cur_recoils: Array, barrel: int, recoils: int) -> Dictionary:
	# TurretBuild.bullet() (Turret.java:779-812) stamps the
	# per-barrel recoil counter of the barrel that just fired
	# after the bullet is created and handled: `curRecoil = 1f;`
	# / `if(recoils > 0){` / `curRecoils[barrelCounter % recoils] = 1f;` / `}` /
	# `heat = 1f;` / `totalShots++;` (Turret.java:806-811).
	# The field is `public @Nullable float[] curRecoils;` (:285),
	# null until the first updateTile tick allocates it (N2256
	# decay), and the class default is `public int recoils = -1;`
	# (:142) -- but duo overrides it: `recoils = 2;`
	# (Blocks.java:3301, inside the duo block 3257-3330), so the
	# branch DOES apply to duo: its two drawer barrel parts
	# carry recoilIndex 0 / 1 (Blocks.java:3302-3311) and
	# DrawTurret reads `tb.curRecoils[part.recoilIndex]`
	# (DrawTurret.java:104/115). The counter is
	# `public int totalShots, barrelCounter;` (:287); the barrel
	# is the pre-increment barrelCounter -- pattern.shoot runs
	# before the `}, () -> barrelCounter++);` incrementer
	# (Turret.java:770). The result is a 1-key dict:
	# `cur_recoils`, a NEW array of length recoils (missing
	# entries read as 0.0, so a null / absent frame key inits
	# to zeros) with entry barrel % recoils stamped to 1.0 and
	# every other entry untouched -- the input array is never
	# mutated. When recoils <= 0 the Java guard does nothing,
	# so the function returns the input unchanged.
	var stamped: Array = []
	if recoils > 0:
		for i in range(recoils):
			var value: float = 0.0
			if i < cur_recoils.size():
				value = float(cur_recoils[i])
			stamped.append(value)
		stamped[barrel % recoils] = 1.0
		return {"cur_recoils": stamped}
	return {"cur_recoils": cur_recoils}

static func source_turret_recoil_offset_state(rotation: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) recomputes
	# the draw offset every tick, after the recoil/heat decay
	# (:519/:526) and before turnToTarget (:595-596) and
	# updateShooting (:601/:609): `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);`
	# (Turret.java:532). The field is `public Vec2 recoilOffset = new Vec2();`
	# (:280, `/** Turret sprite offset, based on recoil. Updated
	# every frame. */`), the power curve is `public float recoilPow = 1.8f;`
	# (:146, `/** power curve applied to visual recoil */`) and the
	# class default is `public float recoil = 1f;`
	# (:140, `/** Visual amount by which the turret recoils back
	# per shot. */`) -- duo overrides it with `recoil = 0.5f;`
	# (Blocks.java:3315, inside the duo block 3257-3330). The
	# field is `public float curRecoil, heat, logicControlTime = -1;`
	# (:284). trns sets the vector from the angle and the length
	# (x = cos(rotation) * mag, y = sin(rotation) * mag, mag =
	# -pow(cur_recoil, recoil_pow) * recoil), so a fresh shot
	# (curRecoil 1.0) kicks the sprite back along its rotation by
	# exactly recoil, and no recoil leaves the offset at zero.
	# The result is a 1-key dict: `recoil_offset`, a
	# `{"x": .., "y": ..}` dict -- the frame's JSON-friendly
	# convention, same as frame["target_pos"] from the N2250
	# aim state. The formula itself was already proven once on
	# the legacy PortGame path (N742,
	# `PortGame.source_turret_recoil_offset`, MCP: recoil 0.5 /
	# rotation 0 / curRecoil 1 -> Vector2(-0.5, 0.0)); this is
	# the LIVE frame tick on the new duo driver.
	var magnitude: float = -pow(cur_recoil, recoil_pow) * recoil
	var offset_x: float = cos(deg_to_rad(rotation)) * magnitude
	var offset_y: float = sin(deg_to_rad(rotation)) * magnitude
	return {"recoil_offset": {"x": offset_x, "y": offset_y}}

static func source_turret_charge_state(charge: float, queued_bullets: int, first_shot_delay: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) advances the
	# charge every tick, after the recoil/heat decay (:519/:526)
	# and before the recoilOffset draw (:532):
	# `charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;`
	# (Turret.java:527), where charging is
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
	# (Turret.java:715-717). The field is
	# `public float shootWarmup, charge, warmupHold = 0f;`
	# (:286), the queue counter is
	# `public int queuedBullets = 0;` (:293), and the delay is
	# `public float firstShotDelay = 0;`
	# (ShootPattern.java:11, `/** delay in ticks before first shot */`)
	# -- duo never overrides it (`shoot = new ShootAlternate(3.5f);`,
	# Blocks.java:3299, inside the duo block 3257-3330; ShootAlternate
	# only sets the spread). approachDelta is
	# `public static float approachDelta(float from, float to, float speed){`
	# / `return approach(from, to, Time.delta * speed);`
	# (arc Mathf.java:420-422) with approach
	# `public static float approach(float from, float to, float speed){`
	# / `return from + Mathf.clamp(to - from, -speed, speed);`
	# (:415-417), so a charging tick moves the charge toward 1 by
	# delta / firstShotDelay, never past 1, and a non-charging tick
	# resets it to 0 outright (not a decay). charging is derived
	# inside the function (queuedBullets > 0 and firstShotDelay > 0),
	# so firstShotDelay <= 0 never divides by zero. The result is
	# a 2-key dict: `charge` and `charging`.
	var charging: bool = queued_bullets > 0 and first_shot_delay > 0.0
	if charging:
		charge = charge + clampf(1.0 - charge, -delta / first_shot_delay, delta / first_shot_delay)
	else:
		charge = 0.0
	return {"charge": charge, "charging": charging}

static func source_turret_unit_sync_state(unit_tile: Vector2i, rotation: float, unit_team: int, team_id: int, tile_team: int, block_size: float, tilesize: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) syncs its
	# block unit every tick, after the charge advance (:527) and
	# before the recoilOffset draw (:532):
	# `unit.tile(this);`
	# `unit.rotation(rotation);`
	# `unit.team(team);`
	# (Turret.java:529-531). The unit is the per-building
	# BlockUnitc,
	# `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
	# (:291), created on the building team. tile() re-asserts the
	# tile link (`this.tile = tile;`, BlockUnitComp.java:18) and
	# re-derives the hit size
	# (`hitSize(tile.block.size * tilesize * 0.7f);`, :23 -- the
	# port already has it as
	# SourceBlockGeometry.block_unit_tile_hit_size, scale 0.7);
	# rotation is the plain RotComp field assignment; team()
	# re-syncs the unit team and only calls back into the
	# building when the teams drifted
	# (`if(tile != null && this.team != team){` /
	# `tile.changeTeam(team);`, BlockUnitComp.java:79/:83 -- tile
	# is `this` at this call site, so the null guard is always
	# true). The post-sync unit team is always the building team
	# (team() sets this.team = team when the guard passes, and
	# keeps it when already synced); changeTeam is called only
	# when BOTH guards pass -- the unit team drifted from the
	# building team AND the tile team drifted too. The result is
	# a 5-key dict: `unit_tile`, `unit_rotation`, `unit_team`,
	# `unit_hit_size` and `tile_change_team_called`.
	var hit_size: float = source_block_geometry.block_unit_tile_hit_size(block_size, tilesize)
	var tile_change_team_called: bool = unit_team != team_id and tile_team != team_id
	return {"unit_tile": unit_tile, "unit_rotation": rotation, "unit_team": team_id, "unit_hit_size": hit_size, "tile_change_team_called": tile_change_team_called}

static func source_turret_unit_max_health_state(block_health: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) syncs its
	# block unit every tick:
	# `unit.tile(this);`
	# (Turret.java:529) -- and tile() sets up the block stats,
	# first line:
	# `maxHealth(tile.block.health);`
	# (BlockUnitComp.java:21) sets the unit maxHealth field
	# (`transient float maxHealth = 1f;`,
	# HealthComp.java:13; the float setter is generated by the
	# component annotation processor, so there is no explicit
	# method in HealthComp.java). Duo health is 250
	# (Blocks.java:3319 `health = 250;`). The result is a 1-key
	# dict: `unit_max_health`. The live tile health
	# (`health(tile.health);`, BlockUnitComp.java:22) is NOT
	# here: the frame carries no live tile_health input, so it
	# waits for its own slice.
	return {"unit_max_health": block_health}

static func source_turret_unit_health_state(tile_health: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) syncs its
	# block unit every tick:
	# `unit.tile(this);`
	# (Turret.java:529) -- and tile() sets up the block stats,
	# second line:
	# `health(tile.health);`
	# (BlockUnitComp.java:22) sets the unit health field
	# (`float health;`, HealthComp.java:11; the float setter
	# is generated by the component annotation processor, so
	# there is no explicit method in HealthComp.java). Duo
	# health is 250 at full health (Blocks.java:3319
	# `health = 250;`). The live tile health comes from the
	# placed-block health meta: SourcePlacedBlockState
	# .health(sprite) reads the sprite meta
	# `source_block_health`, set to the block health at
	# placement (SourcePlacedBlockState.initialize_sprite),
	# so a damaged duo stamps its live health, not a
	# constant. The result is a 1-key dict: `unit_health`.
	return {"unit_health": tile_health}

static func source_turret_unit_world_position_state(cell: Vector2i, block_size: float, tilesize: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) syncs its
	# block unit every tick:
	# `unit.tile(this);`
	# (Turret.java:529) -- and tile() positions the unit in
	# world coordinates, as its last line:
	# `set(tile);`
	# (BlockUnitComp.java:24) ->
	# `set(pos.getX(), pos.getY());`
	# (PosComp.java:24) -> Tile.getX()/getY() are drawx()/drawy():
	# `return drawx();`
	# (Tile.java:728) /
	# `return drawy();`
	# (Tile.java:733), drawx() is `block().offset + worldx()`
	# (Tile.java:176) with worldx() `x * tilesize` (:167), and
	# Block.offset is
	# `offset = ((size + 1) % 2) * tilesize / 2f;`
	# (Block.java:761) -- 0 for odd sizes, tilesize/2 for even
	# sizes. The port already has drawx/drawy as
	# SourceBlockGeometry.tile_drawx_state / tile_drawy_state.
	# The result is a 3-key dict: `unit_world_x`,
	# `unit_world_y` and `unit_tile` (the tile link re-asserted,
	# same as the N2260 unit sync).
	var block_offset: float = fmod(block_size + 1.0, 2.0) * tilesize / 2.0
	var unit_world_x: float = source_block_geometry.tile_drawx_state(cell.x, tilesize, block_offset)
	var unit_world_y: float = source_block_geometry.tile_drawy_state(cell.y, tilesize, block_offset)
	return {"unit_world_x": unit_world_x, "unit_world_y": unit_world_y, "unit_tile": cell}

static func source_turret_logic_control_time_state(logic_control_time: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-560) decays the
	# logic-control timer every tick, after the recoilOffset draw
	# (:532) and before the heat-requirement fold (:538-540):
	# `if(logicControlTime > 0){`
	# `logicControlTime -= Time.delta;`
	# (Turret.java:534-536). The field is
	# `public float curRecoil, heat, logicControlTime = -1;`
	# (:284), so the timer starts at -1 (never logic-controlled)
	# and only a logic shoot control arms it
	# (`logicControlTime = logicControlCooldown;`, :384/:394, with
	# `public final static float logicControlCooldown = 60 * 2;`,
	# :38 -- 120 ticks of logic control). The reader is
	# `logicControlled()` (`return logicControlTime > 0;`,
	# :445-447), so the decay is observable through the isShooting
	# gate (:492) on the very next tick. The decay has NO clamp: a
	# timer of 0.001 with delta 1/60 lands negative (0.001 -
	# 0.0166... = -0.0156...), exactly what Java does -- the next
	# tick's guard then leaves it alone. The result is a 1-key
	# dict: `logic_control_time`.
	if logic_control_time > 0.0:
		logic_control_time -= delta
	return {"logic_control_time": logic_control_time}

static func source_turret_rotate_sync_state(rotation: float, rotate: bool, building_rotation: int) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-560) syncs the
	# underlying building rotation every tick, after the
	# logic-control timer decay (:534-536) and before the
	# heat-requirement fold (:538-540):
	# `if(rotate){`
	# `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`
	# (Turret.java:542-545). `rotate` is true for every turret
	# (Turret constructor, `rotate = true;`, :163) and duo never
	# overrides it (Blocks.java:3257-3331 sets only
	# `rotateSpeed = 10f;`). `rotation` is the turret's own float
	# aim rotation in degrees (frame["rotation"], default 90.0);
	# the synced field is the shadowed int 0-3 Building rotation
	# (`transient int rotation;`, BuildingComp.java:69, default 0)
	# -- the comment on the line says it plainly: "sync underlying
	# rotation; 0-3 rotation is a shadowed field". arc
	# `Mathf.round(float)` is
	# `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
	# (Mathf.java:500-502) -- round half UP toward +inf, like Java
	# Math.round, NOT half away from zero: -0.5 rounds to 0, -1.5
	# rounds to -1 -- so the port rounds with `floor(x + 0.5)`
	# (the SourceBlockRequirementsState precedent), never with
	# Godot's `round()`. arc `Mathf.mod(float, float)` is
	# `return ((f % n) + n) % n;` (Mathf.java:574-576) -- a proper
	# mod for negatives, so -1 maps to 3. When rotate is false
	# Java skips the assignment entirely, so the building rotation
	# is returned unchanged. The result is a 1-key dict:
	# `building_rotation`.
	if rotate:
		var rounded: int = int(floor(rotation / 90.0 + 0.5))
		building_rotation = ((rounded % 4) + 4) % 4
	return {"building_rotation": building_rotation}

static func source_turret_activation_timer_state(activation_timer: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) gates the
	# aim/shoot half on the activation timer, right after the
	# rotate sync (:542-545) and before the hasAmmo block
	# (:566+): `if(activationTimer > 0){` /
	# `activationTimer -= Time.delta;` / `return;`
	# (Turret.java:561-564). The field is
	# `public float activationTimer = 0;`
	# (BaseTurret.java:115, set to activationTime in
	# placed() :119-120 --
	# `activationTimer = activationTime;`), where
	# `public float activationTime = 0f;`
	# (BaseTurret.java:27) is the class default. Duo never overrides activationTime
	# (Blocks.java:3257-3331), and no turret def in Blocks.java
	# sets it above 0, so the duo timer is always 0.0 and the
	# gate never fires -- the same vacuous-guard precedent as
	# the N2270 heat fold and the N2263 heatReq fold: the tick
	# still stamps both keys so the frame mirrors the
	# TurretBuild fields. The timer decays by delta while
	# positive, with NO clamp (a timer of 0.001 with delta 1/60
	# lands below zero, the N2261 precedent); the elapsed
	# verdict is the gate itself evaluated on the INPUT timer
	# -- Java returns before the rest of the tick when the
	# input is positive, even if this tick's decay would cross
	# zero. It is the same `activationTimer <= 0` clause
	# BaseTurret.status() uses (:144). The early-return skip
	# of the aim/shoot half is NOT wired in this slice: the
	# gate never fires for duo (activationTime 0 for every
	# def), so restructuring the aim block for a never-firing
	# guard is churn, and it waits for a def with
	# activationTime > 0. The result is a 2-key dict:
	# `activation_timer` and `activation_timer_elapsed`.
	var activation_timer_after: float = activation_timer - delta if activation_timer > 0.0 else activation_timer
	var activation_timer_elapsed: bool = activation_timer <= 0.0
	return {"activation_timer": activation_timer_after, "activation_timer_elapsed": activation_timer_elapsed}

static func source_turret_is_active_state(has_target: bool, was_shooting: bool, enabled: bool, activation_timer: float) -> Dictionary:
	# TurretBuild.isActive() (Turret.java:449-450):
	# `public boolean isActive(){` /
	# `return (target != null || wasShooting) && enabled && activationTimer <= 0;`
	# -- the liveness verdict for a turret build. `target !=
	# null` is the frame's has_target (the N2277 precedent:
	# the driver keeps target / has_target in sync through
	# the validateTarget verdict, N2251). `wasShooting` is
	# `public boolean wasShooting, isShooting;`
	# (Turret.java:292, set false at :517 and true at :600 /
	# :608 in updateTile); the frame's was_shooting is stamped
	# from the aim result every tick. `enabled` is
	# `transient boolean enabled = true;`
	# (BuildingComp.java:77), preserved on the frame every
	# tick. `activationTimer` is `public float
	# activationTimer = 0;` (BaseTurret.java:115), decayed
	# live by the N2279 tick. The only Java consumer is
	# LaserTurret.shouldConsume() (`if(bullets.any() ||
	# isActive()) return true;`, LaserTurret.java:55) -- duo
	# never calls isActive(), so this slice is stamp-only
	# like N2274-N2276: the driver stamps the verdict on the
	# frame and no consumer is rewired (the LaserTurret
	# consumer also needs the bullets live list, which the
	# port does not have yet). The result is a 1-key dict:
	# `is_active`.
	var is_active: bool = (has_target or was_shooting) and enabled and activation_timer <= 0.0
	return {"is_active": is_active}

static func source_turret_heat_req_state(heat_requirement: float, heat_total: float, side_heat: Array, heat_req: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-560) folds the
	# heat requirement every tick, after the logic-control timer
	# decay (:534-536) and before the rotate sync (:542-545):
	# `if(heatRequirement > 0){`
	# `heatReq = calculateHeat(sideHeat);`
	# (Turret.java:538-540). `heatRequirement` defaults to -1
	# (`public float heatRequirement = -1f;`, Turret.java:53)
	# and duo never sets it (Blocks.java:3257-3331), so the
	# guard is false for duo and heatReq stays at its field
	# default 0 (`public float heatReq;`, Turret.java:295).
	# Only afflict (PowerTurret, `heatRequirement = 20f;`,
	# Blocks.java:5122) and malign (PowerTurret,
	# `heatRequirement = 144f;`, Blocks.java:6240) set a
	# positive requirement among turrets.
	# `calculateHeat(sideHeat)` is
	# `public float calculateHeat(float[] sideHeat){`
	# (BuildingComp.java:406) returning
	# `return calculateHeat(sideHeat, null);` (:407), which
	# fills the per-side array (`Arrays.fill(sideHeat, 0f);`,
	# :411) from the live proximity scan of same-team HeatBlock
	# heaters and returns the total heat. That scan is a live
	# entity scan -- BLOCKED, same class as findTarget -- so
	# the scan itself is deferred and this function takes the
	# scan result (heat_total and the per-side array) as
	# inputs, applying only the guard + assign. The per-side
	# array field is `public float[] sideHeat = new float[4];`
	# (Turret.java:296). When the requirement is not positive
	# Java skips the assignment entirely, so both keys are
	# returned unchanged. The result is a 2-key dict:
	# `heat_req` and `side_heat`.
	if heat_requirement > 0.0:
		heat_req = heat_total
	return {"heat_req": heat_req, "side_heat": side_heat}

static func source_turret_control_state(control_type: String, p1: float, p2: float, p3: float, unit_is_player: bool, unit_is_null: bool, logic_control_time: float, logic_shooting: bool, target_pos: Dictionary, target_is_posc: bool, tilesize: float) -> Dictionary:
	# TurretBuild.control() (Turret.java:381-402) arms the logic-control
	# timer from a logic shoot / shootp instruction, outside updateTile():
	# `if(type == LAccess.shoot && !unit.isPlayer()){`
	# `targetPos.set(World.unconv((float)p1), World.unconv((float)p2));`
	# `logicControlTime = logicControlCooldown;`
	# `logicShooting = !Mathf.zero(p3);`
	# (Turret.java:382-386) and
	# `if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){`
	# `logicControlTime = logicControlCooldown;`
	# `logicShooting = !Mathf.zero(p2);`
	# `if(p1 instanceof Posc pos){`
	# `targetPosition(pos);`
	# (Turret.java:393-400). The cooldown is
	# `public final static float logicControlCooldown = 60 * 2;`
	# (Turret.java:38 -- 120 ticks of logic control), the timer field is
	# `public float curRecoil, heat, logicControlTime = -1;`
	# (Turret.java:284), the flag field is
	# `public boolean logicShooting = false;` (Turret.java:287) and the
	# target field is `public Vec2 targetPos = new Vec2();`
	# (Turret.java:289). World.unconv is
	# `public static float unconv(float coord){`
	# `return coord * tilesize;` (World.java:170-172) with
	# `public static final int tilesize = 8;` (Vars.java:135), so a shoot
	# at tile (10, 20) aims at world (80, 160). Mathf.zero is
	# `public static boolean zero(float value){`
	# `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;`
	# (arc Mathf.java:522-524) with
	# `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
	# (Mathf.java:10). The shoot overload reads p1/p2 as the tile coords
	# and p3 as the shoot flag; the shootp overload reads p2 as the shoot
	# flag and p1 as the Posc object (so the caller passes 0.0 for p1
	# and the Posc-ness via target_is_posc). targetPosition(pos)
	# (`public void targetPosition(Posc pos){`, Turret.java:453, with
	# `if(!hasAmmo() || pos == null) return;`, :454) needs hasAmmo /
	# peekAmmo plus Predict.intercept, so the shootp arm only reports
	# target_position_deferred and leaves targetPos untouched. This is
	# an EVENT, not a per-tick step: control() is called by the logic
	# executor, and no logic executor exists in the driver yet, so
	# there is no driver tick (the N2248 precedent). The result is a
	# 4-key dict: `logic_control_time`, `logic_shooting`, `target_pos`
	# and `target_position_deferred`.
	var target_position_deferred := false
	if control_type == "shoot" and not unit_is_player:
		target_pos = {"x": p1 * tilesize, "y": p2 * tilesize}
		logic_control_time = 120.0
		logic_shooting = absf(p3) > 0.000001
	elif control_type == "shootp" and (unit_is_null or not unit_is_player):
		logic_control_time = 120.0
		logic_shooting = absf(p2) > 0.000001
		if target_is_posc:
			target_position_deferred = true
	return {"logic_control_time": logic_control_time, "logic_shooting": logic_shooting, "target_pos": target_pos, "target_position_deferred": target_position_deferred}

static func source_turret_efficiency_multiplier_state(efficiency: float, heat_requirement: float, heat_req: float, cheating: bool, max_heat_efficiency: float) -> Dictionary:
	# TurretBuild.updateEfficiencyMultiplier()
	# (Turret.java:674-679) folds the heat requirement into
	# efficiency every tick, inside updateConsumption()
	# (BuildingComp.java:1949 cheating path / :1996 normal
	# path), which BuildingComp.update() calls BEFORE
	# updateTile() (:2274-2278) -- so the fold reads the
	# PREVIOUS tick's heatReq (recomputed only later in
	# updateTile(), :538-540, N2263):
	# `if(heatRequirement > 0){`
	# `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
	# (Turret.java:675-677). The override replaces the base
	# (BuildingComp.java:1932-1935,
	# `float scale = efficiencyScale();` /
	# `efficiency *= scale;` /
	# `optionalEfficiency *= scale;`): it does not call super
	# and never touches optionalEfficiency.
	# `heatRequirement` defaults to -1
	# (`public float heatRequirement = -1f;`, Turret.java:53)
	# and duo never sets it (Blocks.java:3257-3331), so the
	# guard is false for duo and efficiency stays at the
	# first-pass value (BuildingComp.java:1946, 1.0 when enabled
	# and production-valid). Only afflict (PowerTurret,
	# `heatRequirement = 20f;`, Blocks.java:5122) and malign
	# (PowerTurret, `heatRequirement = 144f;`,
	# Blocks.java:6240) set a positive requirement among
	# turrets, with `public float maxHeatEfficiency = 3f;`
	# (Turret.java:55) capping the fold at 3x. `cheating()`
	# is `public boolean cheating(){` /
	# `return team.rules().cheat;` (TeamComp.java:17-19, N2099
	# stamps it live on frame["cheating"] every tick): a
	# cheating team floors the ratio at 1.0, a non-cheating
	# team with no heat folds to 0. The result is a 1-key
	# dict: `efficiency`.
	if heat_requirement > 0.0:
		var floor_value: float = 1.0 if cheating else 0.0
		efficiency *= minf(maxf(heat_req / heat_requirement, floor_value), max_heat_efficiency)
	return {"efficiency": efficiency}

static func source_turret_target_position_control_state(has_ammo: bool, pos: Dictionary, pos_is_hitboxc: bool, delta_x: float, delta_y: float, accurate_delay: bool, move_while_charging: bool, first_shot_delay: float, time_delta: float, predict_target: bool, bullet_speed: float, turret_x: float, turret_y: float, target_pos: Dictionary) -> Dictionary:
	# TurretBuild.targetPosition(Posc pos) (Turret.java:453-471),
	# the method the control() shootp overload calls
	# (`targetPosition(pos);`, Turret.java:398, N2264 deferred
	# it -- the shootp arm only reported
	# target_position_deferred because the call needs hasAmmo /
	# peekAmmo plus Predict.intercept):
	# `public void targetPosition(Posc pos){`
	# `if(!hasAmmo() || pos == null) return;`
	# `BulletType bullet = peekAmmo();`
	# `var offset = Tmp.v1.setZero();`
	# `if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){`
	# `offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);`
	# `}`
	# `if(predictTarget && bullet.speed >= 0.01f){`
	# `targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));`
	# `}else{`
	# `targetPos.set(pos);`
	# `}`
	# `if(targetPos.isZero()){`
	# `targetPos.set(pos);`
	# `}`
	# (`:453-471`). The intercept is the Position overload
	# (Predict.java: `public static Vec2 intercept(Position src, Position dst, float offsetx, float offsety, float v){`):
	# the target's per-frame displacement (Hitboxc deltaX/deltaY)
	# is the velocity, the turret building is not a Hitboxc so no
	# shooter velocity is subtracted, and the float overload
	# divides the displacement by Time.delta
	# (`dstvx /= Time.delta;`) before solving the quadratic for
	# the smallest positive root, else the current position
	# (SourcePredictState.source_predict_intercept_state, N2122).
	# Duo pins: `public boolean accurateDelay = true;`
	# (Turret.java:78) but `public boolean moveWhileCharging = true;`
	# (:80), so the offset branch is OFF for duo -- the offset
	# stays zero even though firstShotDelay would scale it;
	# `public boolean predictTarget = true;` (:105); duo copper is
	# `new BasicBulletType(2.5f, 9)` (Blocks.java:3260, speed 2.5,
	# damage 9) so the `bullet.speed >= 0.01f` gate is on and the
	# intercept runs; `shoot = new ShootAlternate(3.5f);`
	# (Blocks.java:3299) with `public float firstShotDelay = 0;`
	# (ShootPattern.java:11), so even the accurateDelay offset
	# would be zero for duo. The pos is a Dictionary {"x", "y"}
	# (an empty dict is a null pos); the current targetPos is
	# `public Vec2 targetPos = new Vec2();` (Turret.java:289).
	# A zero time_delta never occurs in a live tick (Time.delta
	# is positive while updateTile runs), so the offset scale
	# guards it to zero instead of dividing by zero. This is an
	# EVENT, not a per-tick step: control() is called by the
	# logic executor, and no logic executor exists in the driver
	# yet, so there is no driver tick (the N2248 precedent,
	# N2264). The result is a 1-key dict: `target_pos`.
	if not has_ammo or pos.is_empty():
		return {"target_pos": target_pos}
	var pos_x: float = float(pos.get("x", 0.0))
	var pos_y: float = float(pos.get("y", 0.0))
	var offset_x := 0.0
	var offset_y := 0.0
	if accurate_delay and not move_while_charging and pos_is_hitboxc and time_delta != 0.0:
		offset_x = delta_x * (first_shot_delay / time_delta)
		offset_y = delta_y * (first_shot_delay / time_delta)
	var next_pos := {"x": pos_x, "y": pos_y}
	if predict_target and bullet_speed >= 0.01:
		var intercept: Dictionary = source_predict_state.source_predict_intercept_state(turret_x, turret_y, pos_x + offset_x, pos_y + offset_y, delta_x, delta_y, bullet_speed, time_delta)
		next_pos = {"x": float(intercept.get("intercept_x", pos_x + offset_x)), "y": float(intercept.get("intercept_y", pos_y + offset_y))}
	if float(next_pos.get("x", 0.0)) == 0.0 and float(next_pos.get("y", 0.0)) == 0.0:
		next_pos = {"x": pos_x, "y": pos_y}
	return {"target_pos": next_pos}

static func source_turret_super_control_state(control_type: String, p1: float, enabled: bool, logic_configurable: bool, p1_is_logic_build: bool) -> Dictionary:
	# BuildingComp super.control() (BuildingComp.java:2150-2162),
	# what TurretBuild.control() falls through to at the end of
	# both overloads (Turret.java:388/:402,
	# `super.control(type, p1, p2, p3, p4);`), so these cases run
	# for every logic control instruction the turret does not
	# handle itself. The double overload (:2150-2155) only
	# handles enabled:
	# `public void control(LAccess type, double p1, double p2, double p3, double p4){`
	# `if(type == LAccess.enabled){`
	# `enabled = !Mathf.zero((float)p1);`
	# `}`
	# `}`
	# and the Object overload (:2157-2162) only handles config:
	# `public void control(LAccess type, Object p1, double p2, double p3, double p4){`
	# `//don't execute configure instructions that copy logic building configures; this can cause extreme lag`
	# `if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){`
	# `//change config only if it's new`
	# `configured(null, p1);`
	# `}`
	# `}`
	# The enabled field is `transient boolean enabled = true;`
	# (BuildingComp.java:77), the flag the shouldConsume /
	# efficiency folds read (frame["enabled"], default true).
	# LAccess pins `enabled("to"), //"to" is standard for single parameter access` (LAccess.java:80)
	# and `config(true, "to"),` (:83) -- enabled takes the double overload, config the Object overload. Mathf.zero is `return
	# Math.abs(value) <= FLOAT_ROUNDING_ERROR;` (arc
	# Mathf.java:522-524) with `public static final float
	# FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits` (:10), so a
	# p1 of 0.0000005 reads zero (disabled) and a p1 of
	# 0.00001 reads non-zero (enabled). logicConfigurable is
	# `public boolean logicConfigurable = false;`
	# (Block.java:270), set true in init() (:1463-1466) only
	# when some configuration key is an UnlockableContent --
	# duo registers no configuration at all (no `config(` in
	# ItemTurret.java, Turret.java, ReloadTurret.java or
	# BaseTurret.java), so for duo the config guard never fires
	# and configured() is never called. The config case only
	# reports config_applied -- that Java would call
	# configured(null, p1); the handler dispatch itself waits
	# for its own slice (it needs the block's configurations
	# map, which is empty for duo). This is an EVENT, not a
	# per-tick step: control() is called by the logic executor,
	# and no logic executor exists in the driver yet, so there
	# is no driver tick (the N2248 precedent, N2264/N2266).
	# The result is a 2-key dict: `enabled`, `config_applied`.
	var config_applied := false
	if control_type == "enabled":
		enabled = not (absf(p1) <= 0.000001)
	elif control_type == "config":
		config_applied = logic_configurable and not p1_is_logic_build
	return {"enabled": enabled, "config_applied": config_applied}

static func source_turret_configured_dispatch_state(value_kind: String, value_is_anonymous: bool, superclass_kind: String, has_handler: bool, building_config_kind: String, builder_is_player: bool) -> Dictionary:
	# BuildingComp.configured() (BuildingComp.java:1414-1432),
	# `public void configured(@Nullable Unit builder, @Nullable Object value){`
	# what the super.control() config case calls
	# (BuildingComp.java:2161, `configured(null, p1);`, via the
	# :2159 guard pinned by N2267). The type is resolved first:
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
	# either -- configured() is a noop for duo. This is an
	# EVENT, not a per-tick step: configured() is called from
	# control(), and no logic executor exists in the driver yet,
	# so there is no driver tick (the N2248 precedent,
	# N2264/N2266/N2267). The result is a 4-key dict:
	# `resolved_type`, `handler_applied`, `config_copied`,
	# `last_access_updated`.
	var resolved_type := value_kind
	if value_kind == "null":
		resolved_type = "void"
	elif value_kind == "Item" or value_kind == "Block" or value_kind == "Liquid" or value_kind == "UnitType":
		resolved_type = value_kind
	elif value_is_anonymous:
		resolved_type = superclass_kind
	var handler_applied := has_handler
	var config_copied := false
	if not has_handler and value_kind == "Building" and building_config_kind != "null" and building_config_kind != "Building":
		config_copied = true
	var last_access_updated := builder_is_player
	return {"resolved_type": resolved_type, "handler_applied": handler_applied, "config_copied": config_copied, "last_access_updated": last_access_updated}

static func source_turret_queued_bullets_state(queued_bullets: int, first_shot_delay: float, queued_now: int, fired_now: int, reload_counter: float, reload: float, shoot_warmup: float, min_warmup: float) -> Dictionary:
	# TurretBuild keeps a cross-tick counter of bullets that have
	# been queued to fire but have not fired yet:
	# `public int queuedBullets = 0;`
	# (Turret.java:293). shoot() (Turret.java:741-777) increments
	# it once per bullet the shoot pattern queues:
	# `protected void shoot(BulletType type){`
	# `queuedBullets++;`
	# (:754); when the pattern delay is positive the bullet is
	# deferred:
	# `if(delay > 0f){`
	# `Time.run(delay, () -> {`
	# `bullet(type, xOffset, yOffset, angle, mover);`
	# `});`
	# (:756-764), otherwise it fires at once:
	# `bullet(type, xOffset, yOffset, angle, mover);`
	# (:765). bullet() (Turret.java:772-777) decrements it first
	# thing:
	# `protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){`
	# `queuedBullets --;`
	# (:773). While any bullet is still queued and the def has a
	# first-shot delay, the turret is charging:
	# `public boolean charging(){`
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
	# (:715-717) -- and updateShooting() (Turret.java:731-740)
	# refuses to shoot while charging:
	# `protected void updateShooting(){`
	# `if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){`
	# `shoot(type);`
	# `reloadCounter %= reload;`
	# `}`
	# (:733-738). updateShooting() runs from updateTile():
	# `updateShooting();`
	# (:601/:609). The delay branch also plays the charge sound
	# when a shot begins:
	# `if(shoot.firstShotDelay > 0){`
	# `chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
	# (:747-748) --
	# `/** Sound emitted when shoot.firstShotDelay is >0 and shooting begins. */`
	# (:125). The field default is
	# `public float firstShotDelay = 0;`
	# (ShootPattern.java:11), and the only def that sets it is
	# lancer:
	# `lancer = new PowerTurret("lancer"){{`
	# `range = 165f;`
	# `shoot.firstShotDelay = 40f;`
	# `reload = 80f;`
	# (Blocks.java:3560-3567). Duo never sets it
	# (Blocks.java:3257-3331) so its delay is 0, charging() is
	# always false for duo, and its delay-0 bullets fire at once,
	# leaving the counter at 0.
	# `public float minWarmup = 0f;`
	# (Turret.java:76) is the warmup floor in the gate. There is
	# NO driver tick: the delayed bullets are Time.run callbacks
	# with no driver equivalent, and the gate is evaluated per
	# shoot event, not per tick (the N2248 precedent,
	# N2264/N2266/N2267/N2268) -- the logic executor does not
	# exist in the driver yet, so the pure function is called
	# directly. The result is a 4-key dict: `queued_bullets`
	# (the counter after this tick's queue/fire transitions),
	# `charging` (the :716 gate on the pre-update counter, the
	# :733 ordering -- the gate reads the counter before shoot()
	# queues), `can_shoot` (the :733 gate) and
	# `reload_counter_after` (fmod when the gate passes, else
	# unchanged).
	var charging: bool = queued_bullets > 0 and first_shot_delay > 0.0
	var can_shoot: bool = reload_counter >= reload and not charging and shoot_warmup >= min_warmup
	var queued_bullets_after: int = queued_bullets + queued_now - fired_now
	var reload_counter_after: float = fmod(reload_counter, reload) if can_shoot else reload_counter
	return {"queued_bullets": queued_bullets_after, "charging": charging, "can_shoot": can_shoot, "reload_counter_after": reload_counter_after}

static func source_turret_heat_requirement_state(block: Object) -> Dictionary:
	# Turret heat requirement + cap read (Turret.java:53/:55,
	# `public float heatRequirement = -1f;` /
	# `public float maxHeatEfficiency = 3f;`): the catalog
	# captures the block initializer's own assignment, else the
	# class default -- afflict overrides to 20 / 1
	# (Blocks.java:5122-5123, `heatRequirement = 20f;` /
	# `maxHeatEfficiency = 1f;`) and malign to 144 / 1
	# (Blocks.java:6240-6241, `heatRequirement = 144f;` /
	# `maxHeatEfficiency = 1f;`). Only afflict and malign set a
	# positive requirement among turrets; every other turret
	# reads the class defaults, so the fold guard
	# (`if(heatRequirement > 0){`, Turret.java:675) stays off.
	# A null block, or a block whose catalog carries no
	# override, reads the class defaults -1.0 / 3.0. The driver
	# feeds the read values into the N2265 fold
	# (`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`,
	# Turret.java:676). The result is a 2-key dict:
	# `heat_requirement` (the turret heat requirement in heat
	# units) and `max_heat_efficiency` (the cap on the fold).
	var heat_requirement := -1.0
	var max_heat_efficiency := 3.0
	if block != null:
		heat_requirement = float(block.properties.get("heatRequirement", -1.0))
		max_heat_efficiency = float(block.properties.get("maxHeatEfficiency", 3.0))
	return {"heat_requirement": heat_requirement, "max_heat_efficiency": max_heat_efficiency}

static func source_turret_charge_sound_state(block: Object) -> Dictionary:
	# Turret charge sound state (Turret.java:125-126/:132/:747-749,
	# `/** Sound emitted when shoot.firstShotDelay is >0 and
	# shooting begins. */ public Sound chargeSound = Sounds.none;`
	# / `public float soundPitchMin = 0.9f, soundPitchMax = 1.1f;`
	# / `if(shoot.firstShotDelay > 0){ chargeSound.at(bulletX,
	# bulletY, Mathf.random(soundPitchMin, soundPitchMax));
	# type.chargeEffect.at(bulletX, bulletY, rotation); }`): the
	# catalog captures the block initializer's own assignment,
	# else the class defaults -- only lancer sets either
	# (Blocks.java:3564/:3579, `shoot.firstShotDelay = 40f;` /
	# `chargeSound = Sounds.chargeLancer;`); every other turret
	# reads the defaults 0.0 / "none" (ShootPattern.java:11,
	# `public float firstShotDelay = 0;`), so the guard
	# (`if(shoot.firstShotDelay > 0){`, Turret.java:747) stays
	# off and no charge sound plays. A null block, or a block
	# whose catalog carries no override, reads the class
	# defaults. The result is a 3-key dict: `first_shot_delay`
	# (the first-shot delay in ticks), `charge_sound` (the
	# Sounds.* name to emit) and `charge_emitted` (exactly the
	# :747 guard, first_shot_delay > 0). There is no driver tick:
	# the emission happens inside shoot(), an event the driver
	# has no equivalent for yet (precedent N2268 / N2269). The
	# bullet type's chargeEffect (Turret.java:749,
	# BulletType.java:79, `public Effect chargeEffect =
	# Fx.none;`) is its own slice (N2273,
	# source_turret_charge_effect_state) -- the catalog now
	# captures the shootType MultiEffect construction.
	var first_shot_delay := 0.0
	var charge_sound := "none"
	if block != null:
		first_shot_delay = float(block.properties.get("firstShotDelay", 0.0))
		charge_sound = str(block.properties.get("chargeSound", "none"))
	var charge_emitted: bool = first_shot_delay > 0.0
	return {"first_shot_delay": first_shot_delay, "charge_sound": charge_sound, "charge_emitted": charge_emitted}

static func source_turret_charge_effect_state(block: Object) -> Dictionary:
	# Turret charge effect state (Turret.java:747-750,
	# `if(shoot.firstShotDelay > 0){ chargeSound.at(bulletX,
	# bulletY, Mathf.random(soundPitchMin, soundPitchMax));
	# type.chargeEffect.at(bulletX, bulletY, rotation); }` /
	# BulletType.java:78-79, `/** Effect created when charging
	# starts; only usable in single-shot weapons with a
	# firstShotDelay / shotDelay. */` and
	# `public Effect chargeEffect = Fx.none;`): the catalog
	# captures the block initializer's own assignment, else the
	# class defaults -- only lancer sets either, in `lancer =
	# new PowerTurret("lancer"){{` (Blocks.java:3560):
	# `shoot.firstShotDelay = 40f;` (Blocks.java:3564) and
	# `chargeEffect = new MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);`
	# (Blocks.java:3586, on its LaserBulletType shootType,
	# `shootType = new LaserBulletType(140){{`, Blocks.java:3583).
	# Every other turret reads the defaults 0.0 / "none"
	# (ShootPattern.java:11, `public float firstShotDelay = 0;`),
	# so the guard (`if(shoot.firstShotDelay > 0){`,
	# Turret.java:747) stays off and no charge effect plays. A
	# null block, or a block whose catalog carries no override,
	# reads the class defaults. The result is a 3-key dict:
	# `first_shot_delay` (the first-shot delay in ticks, kept for
	# consistency with N2271 -- the guard reads it, and the two
	# charge slices share the same guard input), `charge_effect`
	# (the MultiEffect construction verbatim, without `new`, or
	# "none" for the Fx.none default) and `charge_effect_emitted`
	# (exactly the :747 guard, first_shot_delay > 0). There is no
	# driver tick: the emission happens inside shoot(), an event
	# the driver has no equivalent for yet (precedent N2268 /
	# N2269 / N2271). This is the second half of the :747 guard
	# N2271 started (the charge sound); the sound side is
	# untouched here.
	var first_shot_delay := 0.0
	var charge_effect := "none"
	if block != null:
		first_shot_delay = float(block.properties.get("firstShotDelay", 0.0))
		charge_effect = str(block.properties.get("chargeEffect", "none"))
	var charge_effect_emitted: bool = first_shot_delay > 0.0
	return {"first_shot_delay": first_shot_delay, "charge_effect": charge_effect, "charge_effect_emitted": charge_effect_emitted}

static func source_turret_can_consume_heat_gate_state(heat_requirement: float, heat_req: float, super_can_consume: bool) -> Dictionary:
	# TurretBuild.canConsume() heat gate (Turret.java:623-629,
	# `public boolean canConsume(){`
	# `if(heatRequirement > 0 && heatReq <= 0f){`
	# `return false;`
	# `}`
	# `return super.canConsume();`
	# `}`): false exactly when the turret needs heat and has
	# none, super.canConsume() otherwise. `heatRequirement`
	# defaults to -1 (Turret.java:52-53, `/** Minimum input
	# heat required to fire. */ public float heatRequirement =
	# -1f;`) and `heatReq` is the live per-build field
	# (Turret.java:295, `public float heatReq;`), recomputed
	# by calculateHeat -- which stays BLOCKED (live proximity
	# scan, BuildingComp.java:410-461), so the gate takes
	# heat_req as a live input parameter. Only afflict
	# (`heatRequirement = 20f;`, Blocks.java:5122) and malign
	# (`heatRequirement = 144f;`, Blocks.java:6240) set a
	# positive requirement among turrets, so every other
	# turret reads the -1 default and the gate passes through
	# super_can_consume unchanged. The result is a 1-key dict:
	# `can_consume` (whether the turret may consume). There is
	# no driver tick: canConsume() is evaluated per
	# consumption check, not per tick, and the driver has no
	# shouldConsume gate yet (precedent N2268 / N2269 /
	# N2271). The N2270 fold already scales efficiency to 0
	# for an unheated afflict / malign; this gate is the
	# consumption-side half of the same rule.
	var can_consume: bool = super_can_consume
	if heat_requirement > 0.0 and heat_req <= 0.0:
		can_consume = false
	return {"can_consume": can_consume}

@warning_ignore("unused_parameter")
static func source_turret_should_consume_state(frame: Dictionary, is_shooting: bool, reload_counter: float, reload: float) -> Dictionary:
	# TurretBuild overrides shouldConsume (Turret.java:364-366):
	# `public boolean shouldConsume(){`
	# `return isShooting || reloadCounter < reload;`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277), over the base default BuildingComp.shouldConsume
	# (BuildingComp.java:755-757): `public boolean shouldConsume(){`
	# `return enabled;`
	# updateConsumption forces efficiency to zero when the gate is false
	# (BuildingComp.java:1960): `boolean update = shouldConsume() && productionValid();`
	# (BuildingComp.java:1993): `efficiency = optionalEfficiency = 0f;`
	# The two inputs are TurretBuild fields: isShooting (Turret.java:292):
	# `public boolean wasShooting, isShooting;`
	# set in updateTile :492; and reloadCounter (ReloadTurret.java:26):
	# `public float reloadCounter;`
	# advanced in updateReload (Turret.java:720-723) and capped at reload
	# (Turret.java:723): `reloadCounter = Math.min(reloadCounter, reload);`
	# against the per-def reload time (ReloadTurret.java:10):
	# `public float reload = 10f;`
	# The same comparison is the canReload gate (ReloadTurret.java:50):
	# `return reloadCounter < reload;`
	# frame is accepted for the family call shape and reads no live frame
	# key: isShooting / reloadCounter / reload arrive as explicit params
	# (the N2188 precedent), because the tick frame tracks only
	# cheating / enabled / power_status / efficiency today. The comparison
	# is strict (< reload): a counter equal to reload is idle, matching
	# Java exactly.
	return {"should_consume": is_shooting or reload_counter < reload}

# TurretBuild.progress() (Turret.java:425-427):
# `public float progress(){`
# `return Mathf.clamp(reloadCounter / reload);`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), over the base default BuildingComp.progress
# (BuildingComp.java:617-619): `public float progress(){`
# `return 0f;`
# The two inputs are the same reload pair N2291 wires for
# shouldConsume: reloadCounter (ReloadTurret.java:26):
# `public float reloadCounter;`
# advanced in updateReload (Turret.java:720-723) and capped at reload
# (Turret.java:723): `reloadCounter = Math.min(reloadCounter, reload);`
# against the per-def reload time (ReloadTurret.java:10):
# `public float reload = 10f;`
# arc Mathf.clamp with one argument clamps to [0, 1] (the
# MendProjector precedent, SourceMendProjectorState.gd:41:
# `clamp(charge / reload_value, 0.0, 1.0)`), so a counter past
# reload reads 1 and a negative counter reads 0. The only live
# consumer is sense() case progress (Turret.java:414):
# `case progress -> progress();`
# -- the assigned N2293 slice; setBars (Turret.java:192-202)
# never reads progress(). frame is accepted for the family call
# shape and reads no live frame key: reloadCounter / reload
# arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: wiring frame
# defaults would stamp a constant 0.0 progress (0.0 / 10f),
# not a live value -- pure function only, the N2251 / N2252
# precedent; sense() (N2293) calls it with explicit params.
@warning_ignore("unused_parameter")
static func source_turret_progress_state(frame: Dictionary, reload_counter: float, reload: float) -> Dictionary:
	return {"progress": clampf(reload_counter / reload, 0.0, 1.0)}

# TurretBuild.sense() (Turret.java:406-419):
# `public double sense(LAccess sensor){`
# `return switch(sensor){`
# `case ammo -> totalAmmo;`
# `case ammoCapacity -> maxAmmo;`
# `case rotation -> rotation;`
# `case shootX -> World.conv(targetPos.x);`
# `case shootY -> World.conv(targetPos.y);`
# `case shooting -> isShooting ? 1 : 0;`
# `case progress -> progress();`
# `default -> super.sense(sensor);`
# `};`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), over the base default BuildingComp.sense
# (BuildingComp.java:2093): `public double sense(LAccess sensor){`
# whose default is `default -> Float.NaN; //gets converted to null in logic`
# (BuildingComp.java:2123). The sensor spellings are the LAccess
# enum names `ammo,` (LAccess.java:18), `ammoCapacity,` (:19),
# `progress,` (:28), `rotation,` (:30), `shootX,` (:35),
# `shootY,` (:36), `shooting,` (:49). The inputs are TurretBuild
# fields: totalAmmo (Turret.java:283, `public int totalAmmo;`),
# maxAmmo (Turret.java:47, `public int maxAmmo = 30;`), targetPos
# (Turret.java:290, `public Vec2 targetPos = new Vec2();`),
# isShooting (Turret.java:292, `public boolean wasShooting,
# isShooting;`), and rotation, the BaseTurret float rotation
# (BaseTurret.java:114, `public float rotation = 90;`). World.conv
# (World.java:165-166, `public static float conv(float coord){`
# / `return coord / tilesize;`) divides by tilesize (Vars.java:135,
# `public static final int tilesize = 8;`). The progress case calls
# the N2292 pure function (`return Mathf.clamp(reloadCounter /
# reload);`, Turret.java:426) with explicit params (reloadCounter,
# ReloadTurret.java:26, `public float reloadCounter;`; reload,
# ReloadTurret.java:10, `public float reload = 10f;`). All live
# values arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: sense is a logic
# read, not a tick write (the N2206 / N2208 / N2223 precedent); the
# logic-processor dispatch hook is its own later slice. The default
# leg falls through to super.sense, so it returns handled=false
# with a null NaN value for the caller to fall through.
@warning_ignore("unused_parameter")
# TurretBuild.fogRadius() (Turret.java:420-423):
# `public float fogRadius(){`
# `return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The range is the BaseTurret def range
# (BaseTurret.java:21, `public float range = 80f;`) and the
# multiplier is the BaseTurret def fogRadiusMultiplier
# (BaseTurret.java:24, `public float fogRadiusMultiplier = 1f;`) on
# `public class BaseTurret extends Block{` (BaseTurret.java:20).
# tilesize is the world constant (Vars.java:135, `public static
# final int tilesize = 8;`); the ammo range change is the peeked
# bullet's rangeChange (BulletType.java:157, `public float rangeChange = 0f;`, default 0f).
# Unlike range() (Turret.java:342-345, `public float range(){` with `return range + peekAmmo().rangeChange;`),
# which adds rangeChange whenever peekAmmo() is non-null
# (Turret.java:693, `public @Nullable BulletType peekAmmo(){`), fogRadius() adds it only when hasAmmo()
# (Turret.java:698, `public boolean hasAmmo(){`) -- the stricter
# gate (ammo present, enough for a shot, canConsume,
# Turret.java:698-712) -- so the pure function takes has_ammo as
# an explicit bool, not a peeked bullet. The accessor is what the
# fog system reads (FogControl.java:161,
# `Mathf.round(build.fogRadius())`; FogRenderer.java:68,
# `build.fogRadius() * tilesize`); the fog system itself waits for
# its own slice. All live values arrive as explicit params (the
# N2188 precedent), because the tick frame tracks only
# cheating / enabled / power_status / efficiency today. Ammo
# absent preserves the base range: has_ammo false adds 0f (the
# N2291/N2292 absent-preserves precedent). NO driver line:
# fogRadius() is a load-time accessor the fog system reads, not a
# per-tick write (the N2249 precedent).
@warning_ignore("unused_parameter")
static func source_turret_fog_radius_state(frame: Dictionary, range: float, has_ammo: bool, ammo_range_change: float, tilesize: float, fog_radius_multiplier: float) -> Dictionary:
	return {"fog_radius": (range + (ammo_range_change if has_ammo else 0.0)) / tilesize * fog_radius_multiplier}

# TurretBuild.updateTile() warmup advance (Turret.java:502-515):
# `float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;`
# `if(warmupTarget > 0 && !controlled()){`
# `warmupHold = 1f;`
# `}`
# `if(warmupHold > 0f){`
# `warmupHold -= Time.delta / warmupMaintainTime;`
# `warmupTarget = 1f;`
# `}`
# `if(linearWarmup){`
# `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`
# `}else{`
# `shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), inside `public void updateTile(){` (Turret.java:490).
# canConsume() is the TurretBuild override (Turret.java:624-629,
# `public boolean canConsume(){` /
# `if(heatRequirement > 0 && heatReq <= 0f){` /
# `return false;` / `return super.canConsume();`) over the
# BuildingComp gate (BuildingComp.java:1917-1919,
# `public boolean canConsume(){` / `return potentialEfficiency > 0;`).
# heatRequirement is per-def (Turret.java:53,
# `public float heatRequirement = -1f;`; 20f on afflict and 144f on
# malign, Blocks.java:5122/6240) and heatReq is the live field
# (Turret.java:295, `public float heatReq;`), refreshed each tick
# (Turret.java:538-539, `if(heatRequirement > 0){` /
# `heatReq = calculateHeat(sideHeat);`); both arrive as explicit
# params, so a cold heat turret (heatReq <= 0) cannot consume
# even while shooting with power, while a turret with no heat
# requirement (-1f default) ignores heatReq entirely. charging()
# is Turret.java:715-717 (`public boolean charging(){` /
# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`); controlled()
# is Turret.java:441-443 (`public boolean controlled(){` /
# `return unit.isPlayer();`). The hold / warmup fields are Turret.java:286
# (`public float shootWarmup, charge, warmupHold = 0f;`); the per-def knobs
# are warmupMaintainTime (Turret.java:84,
# `public float warmupMaintainTime = 0f;`, `warmupMaintainTime = 120f;` on
# titan / smite / malign, Blocks.java:4803/5909/6242), shootWarmupSpeed
# (Turret.java:136, `public float shootWarmupSpeed = 0.1f;`,
# `shootWarmupSpeed = 0.04f;` on smite, Blocks.java:5904) and linearWarmup
# (Turret.java:138, `public boolean linearWarmup = false;`, no def sets it
# true). The folded efficiency is BuildingComp.java:85
# (`transient float efficiency;`).
# The approach / lerp legs reuse the ported SourceMathState helpers (N489/N490,
# source_approach_delta / source_lerp_delta), which already encode arc
# Mathf.approachDelta / lerpDelta (arc Mathf.java:420/430). The set and the decay
# run in the SAME tick: a hold set to 1f is decayed by Time.delta /
# warmupMaintainTime before the warmupTarget = 1f force, so a fresh hold reads
# 1 - delta/maintain, not 1. With the default warmupMaintainTime 0f the Java float
# division yields Infinity and the hold goes to -Infinity in the same tick -- the
# pure function keeps that behavior, no invented guard. The lerp leg is the
# default (linearWarmup false on every def); the approach leg is the linearWarmup
# branch. The rate folds efficiency only while the target is positive
# (`warmupTarget > 0 ? efficiency : 1f`), so a decaying warmup ignores efficiency.
# All live values arrive as explicit params (the N2188 precedent), because the
# tick frame tracks only cheating / enabled / power_status / efficiency today:
# is_shooting is set by updateTile :492 (not ported yet), charging / controlled read
# reload / unit state the frame does not track yet, and the frame tracks no
# shoot_warmup / warmup_hold keys yet. NO driver line: the driver waits until those
# frame keys are tracked (the N2294 updateTile precedent); the warmup fold the
# power-status row mentions (Turret.java:512-514) is this advance, called with
# explicit params. delta is Time.delta through delta() (BuildingComp.java:1922-1923,
# `public float delta(){` / `return Time.delta * timeScale;`), raw tick seconds, the
# N2248 convention.
@warning_ignore("unused_parameter")
static func source_turret_update_tile_warmup_state(frame: Dictionary, is_shooting: bool, potential_efficiency: float, charging: bool, controlled: bool, warmup_hold: float, shoot_warmup: float, linear_warmup: bool, shoot_warmup_speed: float, efficiency: float, warmup_maintain_time: float, delta: float, heat_requirement: float, heat_req: float) -> Dictionary:
	var can_consume: bool = potential_efficiency > 0.0 and not (heat_requirement > 0.0 and heat_req <= 0.0)
	var warmup_target: float = 1.0 if (is_shooting and can_consume) or charging else 0.0
	var new_warmup_hold: float = warmup_hold
	if warmup_target > 0.0 and not controlled:
		new_warmup_hold = 1.0
	if new_warmup_hold > 0.0:
		new_warmup_hold -= delta / warmup_maintain_time
		warmup_target = 1.0
	var rate: float = shoot_warmup_speed * (efficiency if warmup_target > 0.0 else 1.0)
	var new_shoot_warmup: float
	if linear_warmup:
		new_shoot_warmup = source_math_state.source_approach_delta(shoot_warmup, warmup_target, rate, delta)
	else:
		new_shoot_warmup = source_math_state.source_lerp_delta(shoot_warmup, warmup_target, rate, delta)
	return {"warmup_target": warmup_target, "warmup_hold": new_warmup_hold, "shoot_warmup": new_shoot_warmup}

# TurretBuild.updateTile() remaining driver-tick legs (Turret.java:494-499,
# :548-557, :566-608):
# `if(unit.isPlayer()){ //there's no reason to update this when a player isn't controlling it`
# `unit.ammo(getAmmoFraction());`
# `soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());`
# `if(reloadWhileCharging || !charging()){`
# `updateReload();`
# `if(state.rules.fog){`
# `float newRange = hasAmmo() ? peekAmmo().rangeChange : 0f;`
# `if(newRange != lastRangeChange){`
# `lastRangeChange = newRange;`
# `fogControl.forceUpdate(team, this);`
# `if(hasAmmo()){`
# `if(Float.isNaN(reloadCounter)) reloadCounter = 0;`
# `if(timer(timerTarget, target != null ? newTargetInterval : targetInterval)){`
# `findTarget();`
# `boolean canShoot;`
# `if(controlled()){ //player behavior`
# `targetPos.set(unit.aimX(), unit.aimY());`
# `canShoot = unit.isShooting();`
# `}else if(logicControlled()){ //logic behavior`
# `canShoot = logicShooting;`
# `}else{ //default AI behavior`
# `if(!controlled()){`
# `unit.aimX(targetPos.x);`
# `unit.aimY(targetPos.y);`
# `if(alwaysShooting){`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), inside `public void updateTile(){` (Turret.java:490).
# The guard lines are registered with their Java trailing comments, so they
# are distinct from the same bare text owned elsewhere (`if(unit.isPlayer()){`
# alone is N1899 BuildingComp.handleUnitPayload; `}else{` alone is owned by
# sixteen slices). NOT registered here: `updateCooling();` (N2241),
# `wasShooting = true;` (N2362), `updateShooting();` (remote N2269),
# `if(soundLoop != null){` (N2350). Call-sites already owned arrive as
# Callables/params, never re-registered: updateReload/updateCooling (N2241),
# findTarget (N2316), validateTarget/charging/controlled/logicControlled
# (N2324/N2297), getAmmoFraction (N2348/N2355),
# shouldActiveSound/activeSoundVolume (N2346).
# getAmmoFraction() is Turret.java:324-326 (`public float getAmmoFraction(){` /
# `return 1f;`, "ammo as a fraction of capacity; used for direct turret control
# HUD"); the unit ammo write only runs for a player-controlled unit, so a
# non-player unit applies nothing (null). soundLoop is the nullable
# TurretBuild field (Turret.java:298, `public @Nullable SoundLoop
# soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound,
# loopSoundVolume));`); the update call passes the build position plus
# shouldActiveSound() (Turret.java:826-828, `public boolean
# shouldActiveSound(){` / `return shootWarmup > 0.01f && loopSound !=
# Sounds.none;`) and activeSoundVolume() (Turret.java:822-824, `public float
# activeSoundVolume(){` / `return shootWarmup;`), both N2346, so an absent
# loop carries a null update. reloadWhileCharging is the per-def flag
# (Turret.java:82, `public boolean reloadWhileCharging = true;`); charging()
# is Turret.java:715-717 (`public boolean charging(){` / `return queuedBullets
# > 0 && shoot.firstShotDelay > 0;`); the gate opens whenever the turret is
# not charging, or while charging when the def allows it, and updateReload()
# (Turret.java:719-720, body N2241) is a call-site: the frame records that it
# was called, never re-ports its body. The fog leg reads state.rules.fog and
# the peeked ammo range change (peekAmmo().rangeChange, Turret.java:344);
# with no ammo the new range is 0f, and fogControl.forceUpdate(team, this)
# (FogControl.java:177) runs only when the range actually changed.
# lastRangeChange is the TurretBuild field (Turret.java:300, `float
# lastRangeChange;`). The hasAmmo block first normalizes a NaN reloadCounter
# to 0 (Float.isNaN, the Java float check), then fires findTarget() (body
# N2316) only when the target timer is ready (timer() is TimerComp.java:10,
# `public boolean timer(int index, float time){`; timerTarget is
# Turret.java:40, `public final int timerTarget = timers++;`, and the
# interval is newTargetInterval with a target, targetInterval without --
# Turret.java:42-44, `public float targetInterval = 20;`). Inside a valid
# target the player branch sets targetPos from the unit aim and reads
# canShoot from unit.isShooting(); the logic branch reads canShoot from
# logicShooting (Turret.java:288, `public boolean logicShooting = false;`);
# the default-AI branch (targetPosition/within, remote N2250) is NOT ported,
# so can_shoot stays null there -- the frame never invents a within() read.
# The aim write runs exactly when !controlled(), after the branch, on the
# (possibly updated) targetPos (targetPos is Turret.java:290, `public Vec2
# targetPos = new Vec2();`; controlled() is Turret.java:441-443, `public
# boolean controlled(){` / `return unit.isPlayer();`; logicControlled() is
# Turret.java:445-447). alwaysShooting is the per-def flag (Turret.java:103,
# `public boolean alwaysShooting = false;`); only its gate is recorded --
# wasShooting = true and updateShooting() inside it belong to N2362 /
# remote N2269. All live values arrive as explicit params (the N2188
# precedent): the tick frame tracks no ammo/sound/reload/fog/target keys yet,
# so there is NO driver tick line (the N2308/N2294 updateTile precedent);
# the driver waits until those frame keys are tracked. Proof asserts frame
# only, never a real shot.
@warning_ignore("unused_parameter")
static func source_turret_update_tile_driver_state(frame: Dictionary, is_player: bool, ammo_fraction: float, has_sound_loop: bool, x: float, y: float, should_active_sound: bool, active_sound_volume: float, reload_while_charging: bool, charging: bool, fog: bool, has_ammo: bool, ammo_range_change: float, last_range_change: float, reload_counter: float, timer_target_ready: bool, validate_target: bool, controlled: bool, logic_controlled: bool, target_pos: Vector2, unit_aim_x: float, unit_aim_y: float, unit_is_shooting: bool, logic_shooting: bool, always_shooting: bool) -> Dictionary:
	var unit_ammo_fraction: Variant = ammo_fraction if is_player else null
	var sound_loop_update: Variant = null
	if has_sound_loop:
		sound_loop_update = {"x": x, "y": y, "active": should_active_sound, "volume": active_sound_volume}
	var reload_gate_open: bool = reload_while_charging or not charging
	var update_reload_called: bool = reload_gate_open
	var new_last_range_change: float = last_range_change
	var fog_range_changed := false
	var fog_force_update_called := false
	if fog:
		var new_range: float = ammo_range_change if has_ammo else 0.0
		if new_range != last_range_change:
			new_last_range_change = new_range
			fog_range_changed = true
			fog_force_update_called = true
	var new_reload_counter: float = reload_counter
	var find_target_called := false
	var new_target_pos: Vector2 = target_pos
	var can_shoot: Variant = null
	var new_unit_aim_x: float = unit_aim_x
	var new_unit_aim_y: float = unit_aim_y
	var always_shooting_gate := false
	if has_ammo:
		if is_nan(new_reload_counter):
			new_reload_counter = 0.0
		if timer_target_ready:
			find_target_called = true
		if validate_target:
			if controlled:
				new_target_pos = Vector2(unit_aim_x, unit_aim_y)
				can_shoot = unit_is_shooting
			elif logic_controlled:
				can_shoot = logic_shooting
			else:
				# Default AI behavior: targetPosition(target) /
				# canShoot = within(...) is remote N2250 -- not
				# ported, so can_shoot stays null.
				pass
			if not controlled:
				new_unit_aim_x = new_target_pos.x
				new_unit_aim_y = new_target_pos.y
		if always_shooting:
			always_shooting_gate = true
	return {"unit_ammo_fraction": unit_ammo_fraction, "sound_loop_update": sound_loop_update, "reload_gate_open": reload_gate_open, "update_reload_called": update_reload_called, "last_range_change": new_last_range_change, "fog_range_changed": fog_range_changed, "fog_force_update_called": fog_force_update_called, "reload_counter": new_reload_counter, "find_target_called": find_target_called, "target_pos": new_target_pos, "can_shoot": can_shoot, "unit_aim_x": new_unit_aim_x, "unit_aim_y": new_unit_aim_y, "always_shooting_gate": always_shooting_gate}

# TurretBuild.estimateDps() (Turret.java:329-332):
# `public float estimateDps(){`
# `if(!hasAmmo()) return 0f;`
# `return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The shots are the ShootPattern def shots
# (ShootPattern.java:9, `public int shots = 1;`, default 1; def
# salvo has shots > 1) and the reload is the ReloadTurret def
# reload (ReloadTurret.java:10, `public float reload = 10f;`).
# The potential efficiency is the BuildingComp field
# (BuildingComp.java:89, `transient float potentialEfficiency;`,
# Java default 0.0f, machinery-set later) and the time scale is
# Time.timeScale through delta() (BuildingComp.java:1922-1923,
# `public float delta(){` / `return Time.delta * timeScale;`).
# The peeked bullet's DPS is BulletType.estimateDPS()
# (BulletType.java:414, `public float estimateDPS(){`, recursive
# over spawnUnit / despawnUnit / fragBullet / spawnBullets with
# the cachedDps cache). hasAmmo() (Turret.java:698, `public
# boolean hasAmmo(){`) has a side effect -- it swaps the ammo
# queue when the first entry is short (Turret.java:698-712) --
# so the pure function takes has_ammo as an explicit bool, never
# calls hasAmmo(). peekAmmo() (Turret.java:693, `public
# @Nullable BulletType peekAmmo(){`) is likewise not ported here:
# the caller passes the peeked bullet's DPS explicitly (0.0 when
# peekAmmo() is null, the Java ternary leg). All live values
# arrive as explicit params (the N2188 precedent), because the
# tick frame tracks only cheating / enabled / power_status /
# efficiency today. No ammo returns 0.0 (the Java early return);
# reload = 0 keeps the Java float-division behavior (Infinity
# for a nonzero numerator) -- no invented guard. NO driver line:
# estimateDps() is a read accessor the RTS AI calls
# (RtsAI.java:336, `dps[0] += t.estimateDps();`), not a
# per-tick write (the N2244/N2249 precedent); the AI caller
# waits for its own slice.
@warning_ignore("unused_parameter")
static func source_turret_estimate_dps_state(frame: Dictionary, has_ammo: bool, shots: int, reload: float, peek_ammo_estimate_dps: float, potential_efficiency: float, time_scale: float) -> Dictionary:
	return {"estimate_dps": 0.0 if not has_ammo else float(shots) / reload * 60.0 * peek_ammo_estimate_dps * potential_efficiency * time_scale}

# TurretBuild.canHeal() (Turret.java:635-637):
# `protected boolean canHeal(){`
# `return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). targetHealing is the def flag (Turret.java:95,
# `public boolean targetHealing = false;`); hasAmmo() is the gate
# (Turret.java:698, `public boolean hasAmmo(){`) with its ammo-swap
# side effect (Turret.java:698-712), so the pure function takes
# has_ammo as an explicit bool, never calls hasAmmo(). peekAmmo()
# (Turret.java:693, `public @Nullable BulletType peekAmmo(){`) is
# likewise not ported here: the caller passes the peeked bullet's
# flags explicitly -- collidesTeam (BulletType.java:127,
# `public boolean collidesTeam = false;`) and heals()
# (BulletType.java:447, `public boolean heals(){`). Java calls
# peekAmmo() twice but hasAmmo() short-circuits first, so a null
# peek never reaches the field reads; the explicit bools carry the
# same short-circuit (they are meaningful only when has_ammo).
# All live values arrive as explicit params (the N2188 precedent),
# because the tick frame tracks no ammo state yet. NO driver line:
# canHeal() is a predicate the targeting chain reads, not a tick
# write; findTarget() (:651-663) and validateTarget() (:631-633)
# call it with explicit params below.
@warning_ignore("unused_parameter")
static func source_turret_can_heal_state(frame: Dictionary, target_healing: bool, has_ammo: bool, peek_collides_team: bool, peek_heals: bool) -> Dictionary:
	return {"can_heal": target_healing and has_ammo and peek_collides_team and peek_heals}

# Units.invalidateTarget() (Units.java:151-158), the 4-arg overload
# validateTarget() calls (Units.java:160-162,
# `return invalidateTarget(target, team, x, y, Float.MAX_VALUE);`):
# `public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){`
# `return target == null ||`
# `(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||`
# `(target instanceof Teamc t && t.team() == team) ||`
# `(target instanceof Healthc h && !h.isValid()) ||`
# `(target instanceof Unit u && !u.targetable(team));`
# Called with range Float.MAX_VALUE, the within-range branch is
# dead (`range != Float.MAX_VALUE` is false), so only four observed
# flags remain: the target is null, the target is a Teamc on the
# team argument, the target is a Healthc that is not valid, or the
# target is a Unit that is not targetable by that team. The team
# argument is Team.derelict when canHeal() holds, else the turret
# team (Turret.java:632) -- the driver computes target_same_team
# against that team; the pure function never hard-codes a team id.
# The driver computes the flags per the instanceof semantics (a
# null target makes the other three false); the live Units query
# itself stays on the driver side. NO driver line: the invalidation
# is a predicate the updateTile driver reads (:491/:573), not a
# tick write of its own.
@warning_ignore("unused_parameter")
static func source_turret_invalidate_target_state(frame: Dictionary, target_is_null: bool, target_same_team: bool, target_health_invalid: bool, target_unit_not_targetable: bool) -> Dictionary:
	return {"target_invalid": target_is_null or target_same_team or target_health_invalid or target_unit_not_targetable}

# TurretBuild.validateTarget() (Turret.java:631-633):
# `protected boolean validateTarget(){`
# `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). controlled() is Turret.java:441-443
# (`public boolean controlled(){` / `return unit.isPlayer();`) and
# logicControlled() is Turret.java:445-447
# (`public boolean logicControlled(){` / `return logicControlTime > 0;`)
# -- controlled() is its own slice (N2324) and logicControlled() is
# N2297; both arrive here as explicit bools (the N2188
# precedent), because the tick frame tracks no unit/player or logic
# key yet. A target that is still valid keeps the turret on it; an
# invalid target is kept only while a player or logic controls the
# turret. NO driver line: updateTile calls validateTarget() at :491
# and :573 -- the driver is its own later slice.
@warning_ignore("unused_parameter")
static func source_turret_validate_target_state(frame: Dictionary, target_invalid: bool, is_controlled: bool, is_logic_controlled: bool) -> Dictionary:
	return {"validate_target": (not target_invalid) or is_controlled or is_logic_controlled}

# TurretBuild.shouldTurn() (Turret.java:669-671):
# `public boolean shouldTurn(){`
# `return moveWhileCharging || !charging();`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). moveWhileCharging is the Turret def field
# (Turret.java:80, `public boolean moveWhileCharging = true;`)
# and arrives as the explicit bool move_while_charging (the
# N2311/N2261 precedent -- a def field, not build state).
# charging() (Turret.java:715-717, `public boolean charging(){`
# / `return queuedBullets > 0 && shoot.firstShotDelay > 0;`)
# is NOT re-ported here: the caller passes its result as the
# explicit bool charging (the N2311/N2340 precedent -- the
# caller passes the live value); remote N2269 owns charging()
# (dedup at merge). The frame carries no tracked key for this
# predicate (the minRange :593 precedent -- the tick frame
# tracks no charging state yet), so all live values arrive as
# explicit params. NO driver line: shouldTurn() is a predicate
# the updateTile() tick driver reads (:595 `if(shouldTurn()){`
# before turnToTarget(targetRot)) -- wiring it into the driver
# waits for the updateTile() caller slice.
@warning_ignore("unused_parameter")
static func source_turret_should_turn_state(frame: Dictionary, move_while_charging: bool, charging: bool) -> Dictionary:
	return {"should_turn": move_while_charging or not charging}

# TurretBuild.minRange() (Turret.java:334-339):
# `public float minRange(){`
# `if(peekAmmo() != null){`
# `return minRange + peekAmmo().minRangeChange;`
# `}`
# `return minRange;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The def minimum is the Turret field
# (Turret.java:74, `public float minRange = 0f;`,
# "Minimum bullet range. Used for artillery only."). The ammo
# change is the peeked bullet's minRangeChange
# (BulletType.java:163, `public float minRangeChange = 0f;`,
# default 0f, "When used in a turret with multiple ammo types,
# this can be set to a non-zero value to influence minRange")
# on `public class BulletType extends Content implements Cloneable{`
# (BulletType.java:29). The gate is peekAmmo() != null
# (Turret.java:693, `public @Nullable BulletType peekAmmo(){` /
# `return ammo.size == 0 ? null : ammo.peek().type();`), NOT
# hasAmmo() (Turret.java:698, `public boolean hasAmmo(){`),
# which has the ammo-swap side effect (Turret.java:698-712)
# and can be false while peekAmmo() is non-null -- so the pure
# function takes has_ammo as an explicit bool carrying the
# peekAmmo() null check (the isActive :509 precedent, where the
# param is_shooting carries wasShooting), never calls
# hasAmmo(). peekAmmo() is likewise not ported here: the caller
# passes the peeked bullet's minRangeChange explicitly (0.0 when
# peekAmmo() is null, the Java fall-through leg). All live values
# arrive as explicit params (the N2188 precedent), because the
# tick frame tracks no ammo state yet. No ammo returns the bare
# def minimum (the Java fall-through leg); with ammo the change
# is added even when it is 0f (the BulletType default). NO
# driver line: minRange() is a read accessor its callers read,
# not a per-tick write (the N2249 precedent) -- drawSelect()
# reads it for the min-range dash circle (Turret.java:485,
# `Drawf.dashCircle(x, y, minRange(), team.color);`) and the
# shoot leg clamps the bullet life scale with it
# (Turret.java:787, `Mathf.clamp(..., minRange() / type.range,
# range() / type.range)`); both callers wait for their own
# slices. (drawPlace() :253 reads the minRange FIELD directly,
# `Drawf.dashCircle(..., minRange, Pal.placing);`, already
# ported as N1162 turret_draw_place.min_range -- that is the
# field, not this method.)
@warning_ignore("unused_parameter")
static func source_turret_min_range_state(frame: Dictionary, min_range: float, has_ammo: bool, ammo_min_range_change: float) -> Dictionary:
	return {"min_range": min_range + ammo_min_range_change if has_ammo else min_range}

# TurretBuild.activeSoundVolume() (Turret.java:822-824):
# `public float activeSoundVolume(){`
# `return shootWarmup;`
# `}`
# and TurretBuild.shouldActiveSound() (Turret.java:826-829):
# `public boolean shouldActiveSound(){`
# `return shootWarmup > 0.01f && loopSound != Sounds.none;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). shootWarmup is the TurretBuild field
# (Turret.java:286, `public float shootWarmup, charge, warmupHold
# = 0f;`) and arrives as the explicit float shoot_warmup (the
# updateTile warmup :502 precedent -- the field is written by
# updateTile :512/:514, NOT ported here: this slice only reads
# it). loopSound is the Turret def field (Turret.java:128,
# `public Sound loopSound = Sounds.none;`); the `loopSound !=
# Sounds.none` check arrives as the explicit bool has_loop_sound
# (the minRange has_ammo precedent -- a null/non-none check
# carried as an explicit bool, GDScript has no Sound object
# here). The frame carries no tracked key for either accessor
# (the minRange :593 precedent -- the tick frame tracks no
# warmup/loop-sound state yet), so all live values arrive as
# explicit params. Evidence, not ownership: the body `return
# shootWarmup;` already appears in N2297[3] (warmup(),
# Turret.java:355, a different method with the same one-line
# body) -- it does not own activeSoundVolume(). NO driver
# line: both are read accessors/predicates the updateTile()
# tick reads at :499 (`soundLoop.update(x, y,
# shouldActiveSound(), activeSoundVolume());`) -- wiring them
# into the driver waits for the updateTile caller slice.
# soundLoop itself (Turret.java:298) is NOT ported: this slice
# never touches real audio.
@warning_ignore("unused_parameter")
static func source_turret_active_sound_volume_state(frame: Dictionary, shoot_warmup: float) -> Dictionary:
	return {"active_sound_volume": shoot_warmup}

@warning_ignore("unused_parameter")
static func source_turret_should_active_sound_state(frame: Dictionary, shoot_warmup: float, has_loop_sound: bool) -> Dictionary:
	return {"should_active_sound": shoot_warmup > 0.01 and has_loop_sound}

# The BlockStatus.inactive value (BlockStatus.java:12,
# `inactive(Color.lightGray);`) has no N1888 constant: the
# BuildingComp.status() helper only returns logicDisable /
# noOutput / noInput / active, so the activation-timer leg of
# TurretBuild.status() carries its own family-local const.
# BaseTurretBuild.status() (N2475) shares this const -- it is
# the same BlockStatus.inactive value.
const SOURCE_TURRET_STATUS_INACTIVE := "inactive"

# TurretBuild.status() (Turret.java:369-374):
# `public BlockStatus status(){`
# `if(enabled && !hasAmmo()) return BlockStatus.noInput;`
# ``
# `return super.status();`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). The super chain has two layers:
# BaseTurretBuild.status() (BaseTurret.java:143-145):
# `public BlockStatus status() {`
# `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`
# `}`
# on `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:113) in `public class BaseTurret extends Block{`
# (BaseTurret.java:20), over BuildingComp.status()
# (BuildingComp.java:632-646):
# `public BlockStatus status(){`
# `if(!enabled){`
# `return BlockStatus.logicDisable;`
# `}`
# `if(!shouldConsume()){`
# `return BlockStatus.noOutput;`
# `}`
# `if(efficiency <= 0 || !productionValid()){`
# `return BlockStatus.noInput;`
# `}`
# `return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;`
# `}`
# -- already live as N1888 PortGame.source_building_status_state,
# whose result arrives here as the explicit building_status param.
# enabled is the Building field (`transient boolean enabled = true;`,
# BuildingComp.java:77), read from the tick frame (stamped by
# source_turret_tick_frame_state, absent reads true, the N2125
# precedent). has_ammo is an explicit bool carrying hasAmmo()
# (Turret.java:698-712, `public boolean hasAmmo(){`, with the
# ammo-swap side effect, the canConsume() gate and the cheating()
# leg) -- NOT ported here, the N2311/N2261 precedent, because no
# slice owns hasAmmo() yet. activation_timer is an explicit float
# carrying BaseTurretBuild.activationTimer (`public float
# activationTimer = 0;`, BaseTurret.java:115, set to activationTime
# on placed()). The noInput leg is `noInput(Pal.remove),`
# (BlockStatus.java:9); the inactive leg is BlockStatus.inactive.
# The first leg needs BOTH conditions: a disabled turret with no
# ammo falls through to super.status(), which itself returns
# logicDisable for !enabled -- so the function adds no enabled
# check of its own in the super leg. NO driver tick line: status()
# is a read accessor its callers read, not a per-tick write (the
# N2249/N2221 precedent).
static func source_turret_status_state(frame: Dictionary, has_ammo: bool, activation_timer: float, building_status: String) -> Dictionary:
	var enabled: bool = bool(frame.get("enabled", true))
	if enabled and not has_ammo:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}
	if activation_timer <= 0.0:
		return {"status": building_status}
	return {"status": SOURCE_TURRET_STATUS_INACTIVE}

# TurretBuild.warmup() (Turret.java:354-356):
# `public float warmup(){`
# `return shootWarmup;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). shoot_warmup is the TurretBuild field (`public float
# shootWarmup, charge, warmupHold = 0f;`, Turret.java:286, default 0f),
# advanced toward warmupTarget by the updateTile warmup leg (N2308,
# Turret.java:502-515) -- NOT re-ported here (the N2311/N2261
# precedent): it arrives as an explicit param. NO driver tick line:
# warmup() is a read accessor its callers read, not a per-tick write
# (the N2249/N2221 precedent) -- the minWarmup fire gate reads it
# (Turret.java:733) and the sound loop reads it; both callers wait
# for their own slices.
@warning_ignore("unused_parameter")
static func source_turret_warmup_state(frame: Dictionary, shoot_warmup: float) -> Dictionary:
	return {"warmup": shoot_warmup}

# TurretBuild.drawrot() (Turret.java:359-361):
# `public float drawrot(){`
# `return rotation - 90;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). rotation is the RotComp float aim angle
# (`@SyncField(false) @SyncLocal float rotation;`, RotComp.java:8,
# default 0.0) -- NOT the Building int rotation 0-3 (`transient int
# rotation;`, BuildingComp.java:69). The caller binds it from the
# frame bound by source_turret_bind_frame_state (frame["rotation"],
# the carrier N2322's write/read already use, default 0.0); it
# arrives here as an explicit param (the N2311/N2261 precedent).
# NO driver tick line: drawrot() is a read accessor the draw path
# reads, not a per-tick write (the N2249/N2221 precedent).
@warning_ignore("unused_parameter")
static func source_turret_drawrot_state(frame: Dictionary, rotation: float) -> Dictionary:
	return {"drawrot": rotation - 90.0}

# TurretBuild.drawSelect() (Turret.java:481-488):
# `public void drawSelect(){`
# `super.drawSelect();`
# ``
# `if(drawMinRange){`
# `Drawf.dashCircle(x, y, minRange(), team.color);`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). super.drawSelect() is the base
# BuildingComp.drawSelect() (BuildingComp.java:1242-1248) -- ALREADY
# LIVE as N573 PortGame.source_building_draw_select_state, NOT
# re-ported here: it runs first at the call site and its output does
# not feed the Turret leg. draw_min_range is the block-level Turret
# def field (`public boolean drawMinRange;`, Turret.java:70, "If true,
# a range ring is also drawn for minRange."), default false -- a def
# field, not build state, so it arrives as an explicit param (the
# N2311/N2261 precedent). min_range is the LIVE minRange() value
# (`public float minRange(){`, Turret.java:334, `return minRange +
# peekAmmo().minRangeChange;`, Turret.java:335) -- computed by the
# caller through N2282 source_turret_min_range_state and passed in as
# an explicit param, NOT re-ported here. team_color is `team.color`
# (Turret.java:485), passed as an explicit String (the
# SourceBuildingDrawState draw_team precedent). Drawf.dashCircle is
# NOT played back: the function returns the draw-command state the
# circle depends on (whether it is drawn, center, radius, color).
# When drawMinRange is false no circle is drawn, so the radius reads
# 0.0 (all four keys are always present, schema-stable). NO driver
# tick line: drawSelect() is selection UI, not per-tick state (the
# N2249/N2221 precedent). This is a different method from N2329
# peekAmmo() (which minRange() reads) and from drawPlace()
# (Turret.java:252-253, which reads the minRange FIELD directly --
# already ported as N1162 turret_draw_place.min_range).
static func source_turret_draw_select_state(x: float, y: float, draw_min_range: bool, min_range: float, team_color: String) -> Dictionary:
	if draw_min_range:
		return {"draw_min_range_circle": true, "center": Vector2(x, y), "radius": min_range, "color": team_color}
	return {"draw_min_range_circle": false, "center": Vector2(x, y), "radius": 0.0, "color": team_color}

# BaseTurretBuild.buildRotation() (BaseTurret.java:129-131):
# `public float buildRotation(){`
# `return rotation;`
# `}`
# on `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:113) in `public class BaseTurret extends Block{`
# (BaseTurret.java:20). This reads the INHERITED `rotation` field
# (`public float rotation = 90;`, BaseTurret.java:114, default 90) --
# the OPPOSITE of N2477 BuildTurretBuild.buildRotation()
# (BuildTurret.java:107-110, `return unit.rotation();`): field 33
# with a unit at 77 returns 33 here, 77 there. No clamp, no angle
# normalisation: a negative rotation or one > 360 passes through
# whole. This is a different method from BaseTurretBuild.range()
# (N739, bare `range()`, BaseTurret.java:124-126). The body literal
# `return rotation;` is a shared RotBlock literal already an
# exact_expr of N2233 (RepairPointBuild.buildRotation(), line
# Windows), N1839 and N2223 -- no slice cites it for
# BaseTurretBuild, so this is the first GD function owned as
# BaseTurretBuild.buildRotation() (generic-literal note, N2479;
# no twin-register approval required). NO driver tick line:
# buildRotation() is a read accessor its callers read, not a
# per-tick write (the N2249/N2221 precedent).
static func source_base_turret_build_rotation_state(rotation: float) -> Dictionary:
	return {"build_rotation": rotation}

# BaseTurretBuild.drawSelect() (BaseTurret.java:133-135):
# `public void drawSelect(){`
# `Drawf.dashCircle(x, y, range(), team.color);`
# `}`
# on `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:110). The whole method is one line: it draws one dash
# circle around the building. The center is the building world position,
# the radius is the LIVE range() value (`public float range(){`,
# BaseTurret.java:124, `return range;`, BaseTurret.java:125 -- computed
# by the caller and passed in as the explicit range_value param, NOT
# re-ported here; the field `range` (BaseTurret.java:22, `public float
# range = 80f;`) is evidence only, the N2311/N2261 precedent), the color
# is the building team color (`team.color`, passed as an explicit String,
# the SourceBuildingDrawState draw_team precedent). Drawf.dashCircle
# arrives as an explicit Callable param (the N2377 drawer precedent:
# guarded with is_valid(), invoked with .call()), NOT re-ported here;
# Drawf itself is NOT ported. NO driver tick line: drawSelect() is
# selection UI, not per-tick state (the N2249/N2221 precedent). This is
# a different method from N2334 TurretBuild.drawSelect() (selection UI,
# Turret.java:481-488, the min-range circle, which calls
# super.drawSelect() first) and from drawPlace()
# (BaseTurret.java:84-92, which draws the range circle at place time).
static func source_base_turret_build_draw_select_state(x: float, y: float, range_value: float, team_color: String, dash_circle: Callable) -> Dictionary:
	var dash_circle_called: bool = false
	if dash_circle.is_valid():
		dash_circle.call(x, y, range_value, team_color)
		dash_circle_called = true
	return {"dash_circle_called": dash_circle_called, "center": Vector2(x, y), "radius": range_value, "color": team_color}

# BaseTurretBuild.status() (BaseTurret.java:143-145):
# `public BlockStatus status() {`
# `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`
# `}`
# on `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:113) in `public class BaseTurret extends Block{`
# (BaseTurret.java:20). The boundary is `<= 0`: timer 0 returns
# super.status(), NOT inactive (a port using `< 0` is wrong).
# super.status() is BuildingComp.status()
# (BuildingComp.java:632-646) -- already live as N1888
# PortGame.source_building_status_state, whose result arrives
# here as the explicit base_status param (the N1256/N2374
# precedent: a precomputed input, NOT re-ported here).
# activationTimer is the BaseTurretBuild field (`public float
# activationTimer = 0;`, BaseTurret.java:115, default 0), set
# to activationTime by placed() (BaseTurret.java:119-122).
# The inactive leg is BlockStatus.inactive -- NOT
# inactiveUnitFactory, a different enum value (BlockStatus.java).
# This is a different method from TurretBuild.status() (N2285,
# Turret.java:369-374), which adds the hasAmmo leg and calls
# super.status() -- i.e. THIS method -- for its tail; N2285
# inlines this leg in source_turret_status_state, and this
# slice adds the first GD function owned as
# BaseTurretBuild.status(), for the inheritors that do not
# override status() (RadarBuild / BuildTurretBuild /
# ReloadTurretBuild). The inactive leg reuses the family-local
# const SOURCE_TURRET_STATUS_INACTIVE (N2285; BlockStatus.inactive
# has no N1888 constant). NO driver tick line: status() is a
# read accessor its callers read, not a per-tick write (the
# N2249/N2221 precedent).
static func source_base_turret_build_status_state(activation_timer: float, base_status: String) -> Dictionary:
	if activation_timer <= 0.0:
		return {"status": base_status}
	return {"status": SOURCE_TURRET_STATUS_INACTIVE}

# TurretBuild.draw() (Turret.java:476-478):
# `public void draw(){`
# `drawer.draw(this);`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The whole method is one line: it delegates the
# draw to the block-level drawer (`public DrawBlock drawer = new DrawTurret();`,
# Turret.java:155) -- the DrawBlock that draws the whole turret. The drawer arrives as an
# explicit Callable param (the SourceBlockGeometry world_tile_lookup precedent: guarded
# with is_valid(), invoked with .call()), NOT re-ported here;
# DrawTurret itself is NOT ported. The build (`this`) arrives as
# an explicit Dictionary param. NO driver tick line: draw() is a
# render delegate, not per-tick state (the N2249/N2221 precedent).
# This is a different method from N2334 drawSelect() (selection
# UI, Turret.java:481-488) and from drawPlace() (Turret.java:252-253,
# already ported as N1162 turret_draw_place.min_range).
static func source_turret_draw_state(drawer: Callable, build: Dictionary) -> Dictionary:
	var drawer_called: bool = false
	if drawer.is_valid():
		drawer.call(build)
		drawer_called = true
	return {"draw_delegated": true, "drawer_called": drawer_called}

# TurretBuild.canControl() (Turret.java:376-378):
# `public boolean canControl(){`
# `return playerControllable;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). player_controllable is the block-level Turret
# field (`public boolean playerControllable = true;`, Turret.java:97,
# "If true, this turret can be controlled by players."), default
# true -- a def field, not build state, so it arrives as an explicit
# param (the N2311/N2261 precedent). NO driver tick line:
# canControl() is a read accessor the control dispatch reads, not a
# per-tick write (the N2249/N2221 precedent).
@warning_ignore("unused_parameter")
static func source_turret_can_control_state(frame: Dictionary, player_controllable: bool) -> Dictionary:
	return {"can_control": player_controllable}

# TurretBuild.logicControlled() (Turret.java:445-447):
# `public boolean logicControlled(){`
# `return logicControlTime > 0;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). logic_control_time is the TurretBuild field
# (`public float curRecoil, heat, logicControlTime = -1;`,
# Turret.java:284, default -1), set to logicControlCooldown
# (`public final static float logicControlCooldown = 60 * 2;`,
# Turret.java:38) by control() (Turret.java:384/394) while logic
# holds the turret; it arrives as an explicit param (the
# N2311/N2261 precedent), because the tick frame tracks no logic
# key yet. NO driver tick line: logicControlled() is a read
# accessor its callers read, not a per-tick write (the N2249/N2221
# precedent) -- updateTile's isShooting computation reads it
# (Turret.java:492) and findTarget's validateTarget reads it
# (Turret.java:632); both callers wait for their own slices.
# controlled() (Turret.java:441-443, `return unit.isPlayer();`)
# is its own slice (N2324), below.
@warning_ignore("unused_parameter")
static func source_turret_logic_controlled_state(frame: Dictionary, logic_control_time: float) -> Dictionary:
	return {"logic_controlled": logic_control_time > 0.0}

# TurretBuild.controlled() (Turret.java:441-443):
# `public boolean controlled(){`
# `return unit.isPlayer();`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). unit is the TurretBuild field
# (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`,
# Turret.java:291), synced by unit() (N2307): controlled() reads the
# result of unit() (`unit.isPlayer();`, Turret.java:442).
# isPlayer() itself (`public boolean isPlayer(){` /
# `return controller instanceof Player;`, UnitComp.java:949-951) is
# NOT re-ported here (Unit/BlockUnitc are not ported): its result
# arrives as the explicit is_player param (the N2311/N2261
# precedent). NO driver tick line: controlled() is a read accessor
# its callers read, not a per-tick write (the N2249/N2221 precedent)
# -- validateTarget() reads it (Turret.java:632) and updateTile's
# player-control branch reads it (Turret.java:494); both callers
# wait for their own slices. NOT control() (Turret.java:384-394,
# remote N2264): a different method -- it sets logicControlTime and
# the player controller, it does not read unit.isPlayer().
@warning_ignore("unused_parameter")
static func source_turret_controlled_state(frame: Dictionary, is_player: bool) -> Dictionary:
	return {"controlled": is_player}

# TurretBuild.unit() (Turret.java:434-439):
# `public Unit unit(){`
# `unit.tile(this);`
# `unit.team(team);`
# `return (Unit)unit;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). unit is the TurretBuild field
# `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
# (Turret.java:291), created once from UnitTypes.block -- NOT re-ported
# here (Unit/BlockUnitc are not ported): it arrives as an explicit param
# (the N2311/N2261 precedent).
# team_id is the building team as an int (the tick-frame convention:
# source_turret_tick_frame_state binds frame["team_id"]); the Building
# team is `@Import Team team;` (BuildingComp.java:62) and the unit team
# field defaults to derelict (`Team team = Team.derelict;`,
# TeamComp.java:15). The function performs the sync itself: it copies
# the input unit dict, sets tile to the building frame (`this`,
# `unit.tile(this);` resolving to
# `public void tile(Building tile){` (BlockUnitComp.java:17), on the
# tile field `@ReadOnly transient Building tile;`
# (BlockUnitComp.java:14)) and team_id to the building team, and
# returns the synced unit. The stat derivation INSIDE
# BlockUnitComp.tile(Building) (maxHealth/health/hitSize/set,
# BlockUnitComp.java:17-27) is NOT applied here: tile() is a separate
# method on a different component -- it stays deferred for its own
# slice. NO driver tick line: unit() is a read accessor its callers
# read, not a per-tick write (the N2249/N2221 precedent) --
# controlled() reads the result (`unit.isPlayer();`,
# Turret.java:442) and is its own slice (N2324).
static func source_turret_unit_state(frame: Dictionary, unit: Dictionary, team_id: int) -> Dictionary:
	var synced: Dictionary = unit.duplicate()
	synced["tile"] = frame
	synced["team_id"] = team_id
	return {"unit": synced}

# TurretBuild.hasAmmo() (Turret.java:698-713):
# `public boolean hasAmmo(){`
# `//skip first entry if it has less than the required amount of ammo`
# `if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){`
# `for(int i = 0; i < ammo.size; i ++){`
# `if(ammo.get(i).amount >= ammoPerShot){`
# `ammo.swap(ammo.size - 1, i);`
# `break;`
# `}`
# `}`
# `//used for "side-ammo" like gas in some turrets`
# `if(!canConsume()) return false;`
# `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). ammo is the TurretBuild field
# (`public Seq<AmmoEntry> ammo = new Seq<>();`, Turret.java:282) and
# ammoPerShot the block field (`public int ammoPerShot = 1;`, Turret.java:49).
# Both arrive as explicit params (the N2311/N2261 precedent): the ammo list as an Array of
# {amount, item} dicts (the peek_ammo_stack_state convention -- Seq.peek()
# is the last entry). canConsume() (Turret.java:624) and cheating() are
# NOT re-ported here: their results arrive as explicit bool params.
# The swap runs BEFORE the canConsume() gate (Java order), so the
# returned ammo_stacks_after carries the swap even when has_ammo is
# false for can_consume. NO driver tick line: hasAmmo() is a predicate
# its callers read, not a per-tick write (the N2249/N2221 precedent) --
# estimateDps() (N2301) and targetPosition() (Turret.java:454) read the
# result; targetPosition() still waits for peekAmmo() (T6).
@warning_ignore("unused_parameter")
static func source_turret_has_ammo_state(frame: Dictionary, ammo_stacks: Array, ammo_per_shot: int, can_consume: bool, cheating: bool) -> Dictionary:
	var stacks_after: Array = ammo_stacks.duplicate(true)
	if stacks_after.size() >= 2:
		var peeked: Dictionary = stacks_after[stacks_after.size() - 1] if stacks_after[stacks_after.size() - 1] is Dictionary else {}
		if int(peeked.get("amount", 0)) < ammo_per_shot:
			for index in stacks_after.size():
				var candidate: Dictionary = stacks_after[index] if stacks_after[index] is Dictionary else {}
				if int(candidate.get("amount", 0)) >= ammo_per_shot:
					var last_entry: Dictionary = stacks_after[stacks_after.size() - 1] if stacks_after[stacks_after.size() - 1] is Dictionary else {}
					stacks_after[stacks_after.size() - 1] = candidate
					stacks_after[index] = last_entry
					break
	if not can_consume:
		return {"has_ammo": false, "ammo_stacks_after": stacks_after}
	var has_ammo := false
	if stacks_after.size() > 0:
		var peeked_after: Dictionary = stacks_after[stacks_after.size() - 1] if stacks_after[stacks_after.size() - 1] is Dictionary else {}
		has_ammo = int(peeked_after.get("amount", 0)) >= ammo_per_shot or cheating
	return {"has_ammo": has_ammo, "ammo_stacks_after": stacks_after}

# TurretBuild.peekAmmo() (Turret.java:693-695):
# `/** @return the ammo type that will be returned if useAmmo is called. */`
# `public @Nullable BulletType peekAmmo(){`
# `return ammo.size == 0 ? null : ammo.peek().type();`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). ammo is the TurretBuild field
# (`public Seq<AmmoEntry> ammo = new Seq<>();`, Turret.java:282) and
# arrives as an explicit param (the N2313 hasAmmo precedent): the ammo
# list as an Array of {amount, item, type} dicts (the
# peek_ammo_stack_state convention -- Seq.peek() is the last entry).
# AmmoEntry is the abstract entry type (`public static abstract class
# AmmoEntry{`, Turret.java:257) with `public int amount;` and
# `public abstract BulletType type();` (Turret.java:258-260). type() is
# NOT re-ported here: for ItemEntry it resolves through the block
# ammoTypes map (`return ammoTypes.get(item);`, ItemTurret.java:236-238)
# and the map itself is NOT ported -- the BulletType NAME arrives as
# the explicit "type" value on each entry dict, and the function
# returns that name (or null). peekAmmo() reads only the peek: no
# amount check and no swap, unlike hasAmmo() (N2313) -- an entry with
# amount 0 still returns its type, and the input list is never
# mutated. NO driver tick line: peekAmmo() is a pure accessor its
# callers read, not a per-tick write (the N2249/N2221 precedent) --
# targetPosition() (Turret.java:454, remote N2266) and useAmmo()
# (N2108) read the result; neither caller is ported here.
@warning_ignore("unused_parameter")
static func source_turret_peek_ammo_state(frame: Dictionary, ammo_stacks: Array) -> Dictionary:
	if ammo_stacks.is_empty():
		return {"peek_ammo": null}
	var peeked: Dictionary = ammo_stacks[ammo_stacks.size() - 1] if ammo_stacks[ammo_stacks.size() - 1] is Dictionary else {}
	var peeked_type: Variant = peeked.get("type", null)
	return {"peek_ammo": peeked_type}

# TurretBuild.getAmmoContent() (Turret.java:319-321):
# `@Nullable`
# `public UnlockableContent getAmmoContent(){`
# `return null;`
# `}`
# and TurretBuild.getAmmoFraction() (Turret.java:324-326):
# `/** @return ammo as a fraction of capacity; used for direct turret control HUD */`
# `public float getAmmoFraction(){`
# `return 1f;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`.
# Both are base-class defaults, not overrides: the base
# TurretBuild has no ammo content (null) and counts as full
# (1f); the subclass overrides (ItemTurretBuild N1180/N1181,
# LiquidTurretBuild N1197/N1198, ContinuousLiquidTurretBuild
# N1220/N1221, PowerTurretBuild N1168) own their own bodies
# and are NOT touched here. Both are constants: no live
# input besides the frame itself, which carries no tracked
# key for either accessor (the isShooting :429 precedent --
# the frame is the family-convention first arg, kept even
# when the function reads nothing from it). NO driver line:
# both are pure defaults its callers read, not per-tick
# writes (the N2249 precedent) -- updateTile :495 reads
# getAmmoFraction() and DrawTurret :108-112 reads
# getAmmoContent(); neither caller is ported here.
@warning_ignore("unused_parameter")
static func source_turret_get_ammo_content_state(frame: Dictionary) -> Dictionary:
	return {"ammo_content": null}

@warning_ignore("unused_parameter")
static func source_turret_get_ammo_fraction_state(frame: Dictionary) -> Dictionary:
	return {"ammo_fraction": 1.0}

# TurretBuild.remove() (Turret.java:303-308):
# `@Override`
# `public void remove(){`
# `super.remove();`
# `if(soundLoop != null){`
# `soundLoop.stop();`
# `}`
# `}`
# and TurretBuild.onDestroyed() (Turret.java:311-317):
# `@Override`
# `public void onDestroyed(){`
# `super.onDestroyed();`
# `if(soundLoop != null){`
# `soundLoop.stop();`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`.
# Both stop the sound loop when it is non-null and do
# nothing when it is null; the two bodies differ only in
# the super call. soundLoop is the TurretBuild field
# (Turret.java:298) `public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));`
# and arrives as the explicit bool
# has_sound_loop (the minRange has_ammo precedent -- a
# null check carried as an explicit bool; GDScript has no
# SoundLoop object here). super.remove() /
# super.onDestroyed() are the Building base -- deferred,
# not ported. NO driver line: the engine lifecycle calls
# remove() / onDestroyed(); no call site is ported here
# (the shouldTurn/isShooting precedent -- updateTile :499
# only UPDATES the loop, it never removes or destroys it).
# NO SoundLoop playback: both functions only return the
# stopped flag, never real audio (the N2346 precedent).
@warning_ignore("unused_parameter")
static func source_turret_remove_state(frame: Dictionary, has_sound_loop: bool) -> Dictionary:
	return {"sound_loop_stopped": has_sound_loop}

@warning_ignore("unused_parameter")
static func source_turret_on_destroyed_state(frame: Dictionary, has_sound_loop: bool) -> Dictionary:
	return {"sound_loop_stopped": has_sound_loop}

# TurretBuild.findEnemy() (Turret.java:639-649):
# `protected Posc findEnemy(float range){`
# `if(targetAir && !targetGround){`
# `return Units.bestEnemy(team, x, y, range, e -> !e.dead() && !e.isGrounded() && unitFilter.get(e), unitSort);`
# `}else{`
# `var ammo = peekAmmo();`
# `boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;`
# `return Units.bestTarget(team, x, y, range,`
# `e -> !e.dead() && unitFilter.get(e) && (e.isGrounded() || targetAir) && (!e.isGrounded() || targetGround) && (missiles || !(e instanceof TimedKillc)),`
# `b -> buildings && buildingFilter.get(b), unitSort);`
# `}`
# `}`
# N2425 owns the ammo binding and the bestTarget call opener quoted
# above (`var ammo = peekAmmo();` at :643 and
# `return Units.bestTarget(team, x, y, range,` at :645): the binding
# arrives as the three ammo flags (ammo_is_null /
# ammo_target_blocks / ammo_target_missiles), which the driver
# derives from the peekAmmo() result (N2329 owns peekAmmo); the
# call itself is the unit loop (units first, bestEnemy) plus the
# building fallback (findEnemyTile) implemented below. No new
# owner/contract/schema: the function, contract and schemas stay
# N2316's; N2425 only registers the two remaining lines.
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). Units.bestTarget (Units.java:284-294,
# `public static Teamc bestTarget(Team team, float x, float y, float range, Boolf<Unit> unitPred, Boolf<Building> tilePred, Sortf sort){`)
# returns null for a derelict team (`if(team == Team.derelict) return null;`),
# checks units first (`Unit unit = bestEnemy(team, x, y, range, unitPred, sort);`)
# and only then buildings (`return findEnemyTile(team, x, y, range, tilePred);`).
# Units.bestEnemy (Units.java:318-338,
# `public static Unit bestEnemy(Team team, float x, float y, float range, Boolf<Unit> predicate, Sortf sort){`)
# skips dead / pred-fail / derelict / out-of-range / untargetable /
# in-fog candidates
# (`if(e.dead() || !predicate.get(e) || e.team == Team.derelict || !e.within(x, y, range + e.hitSize/2f) || !e.targetable(team) || e.inFogTo(team)) return;`)
# and picks by sort.cost
# (`float cost = sort.cost(e, x, y);`)
# with the targetPriority tie-break
# (`if((result == null || cost < cdist || e.type.targetPriority > cpriority) && e.type.targetPriority >= cpriority){`).
# The default sort is UnitSorts.closest = Unit::dst2
# (UnitSorts.java:11, `closest = Unit::dst2,`, over the def
# `public Sortf unitSort = UnitSorts.closest;`, Turret.java:107), so
# the cost is the candidate dst2; unitFilter (Turret.java:109, default
# `u -> true`) and buildingFilter (Turret.java:111) arrive as the
# per-candidate unit_filter / building_filter flags, and the
# branch-specific predicate legs (grounded, timed-kill) are computed
# here from the is_grounded / is_timed_kill flags. The building
# fallback is Units.findEnemyTile (Units.java:222-225,
# `public static Building findEnemyTile(Team team, float x, float y, float range, Boolf<Building> pred){`)
# into BlockIndexer.findEnemyTile (BlockIndexer.java:486-487) with the
# UnitSorts.buildingDefault priority (UnitSorts.java:22,
# `buildingDefault = b -> b.block.priority,`): per building,
# `float dist = candidate.dst(x, y) - candidate.hitSize() / 2f;`
# (BlockIndexer.java:472) must satisfy
# `float bdst = next.dst(x, y) - next.hitSize() / 2f;`
# (BlockIndexer.java:512) with
# `if(bdst < range && (closest == null ||`
# (BlockIndexer.java:513), and the winner is closer-and-at-least-
# equal-priority or strictly higher priority -- the same acceptance
# rule the cross-team loop applies. The live Units queries
# (nearbyEnemies scan, indexer.findEnemyTile / findTile, inFogTo)
# stay on the driver side, which stamps the candidate flags (the
# N2242 live-bullets precedent); the candidates carry an `id` key
# so the driver can resolve the chosen dict back to a live entity
# (the N2242 observed-dict precedent). SourceTurretTargetingState.gd
# is NOT reused: it only picks the nearest candidate by distance and
# has no slice owner -- it lacks the predicate filters, the
# targetPriority tie-break and the building fallback ported here.
# NO driver line: findTarget() (:651-663) calls this with explicit
# params; the updateTile driver is its own later slice.
@warning_ignore("unused_parameter")
static func source_turret_find_enemy_state(frame: Dictionary, team_is_derelict: bool, range: float, target_air: bool, target_ground: bool, target_blocks: bool, ammo_is_null: bool, ammo_target_blocks: bool, ammo_target_missiles: bool, unit_candidates: Array, building_candidates: Array) -> Dictionary:
	if team_is_derelict:
		return {"target": null}
	var air_only: bool = target_air and not target_ground
	var buildings: bool = target_ground and target_blocks and (ammo_is_null or ammo_target_blocks)
	var missiles: bool = ammo_is_null or ammo_target_missiles
	var best: Variant = null
	var best_cost: float = 0.0
	var best_priority: float = -99999.0
	for candidate in unit_candidates:
		if not (candidate is Dictionary):
			continue
		if bool(candidate.get("dead", false)):
			continue
		if bool(candidate.get("team_is_derelict", false)):
			continue
		if not bool(candidate.get("within_range", false)):
			continue
		if not bool(candidate.get("targetable", false)):
			continue
		if bool(candidate.get("in_fog", false)):
			continue
		if not bool(candidate.get("unit_filter", false)):
			continue
		var is_grounded: bool = bool(candidate.get("is_grounded", false))
		if air_only:
			if is_grounded:
				continue
		else:
			if not (is_grounded or target_air):
				continue
			if not ((not is_grounded) or target_ground):
				continue
			if not (missiles or not bool(candidate.get("is_timed_kill", false))):
				continue
		var cost: float = float(candidate.get("dst2", 0.0))
		var priority: float = float(candidate.get("target_priority", 0.0))
		if (best == null or cost < best_cost or priority > best_priority) and priority >= best_priority:
			best = candidate
			best_cost = cost
			best_priority = priority
	if best != null:
		return {"target": best}
	if air_only:
		return {"target": null}
	if not buildings:
		return {"target": null}
	var best_building: Variant = null
	var best_dist: float = 0.0
	var best_bpriority: float = 0.0
	for candidate in building_candidates:
		if not (candidate is Dictionary):
			continue
		if not bool(candidate.get("building_filter", false)):
			continue
		var dist: float = sqrt(float(candidate.get("dst2", 0.0))) - float(candidate.get("hit_size", 0.0)) / 2.0
		if not (dist < range):
			continue
		var bpriority: float = float(candidate.get("priority", 0.0))
		if best_building == null or (dist < best_dist and bpriority >= best_bpriority) or bpriority > best_bpriority:
			best_building = candidate
			best_dist = dist
			best_bpriority = bpriority
	return {"target": best_building}

# TurretBuild.findTarget() (Turret.java:651-663):
# `protected void findTarget(){`
# `float trackRange = trackingRange(), range = range();`
# `target = findEnemy(range);`
# `if(!Mathf.equal(trackRange, range) && target == null){`
# `target = findEnemy(trackRange);`
# `}`
# `if(target == null && canHeal()){`
# `target = Units.findAllyTile(team, x, y, range, b -> b.damaged() && b != this);`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The standard-range target is always preferred:
# the tracking range is tried only when it differs from the standard
# range and nothing was found yet. Mathf.equal is an epsilon compare
# (Mathf.java:544-546, `return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;`,
# with `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`,
# Mathf.java:10) -- not `==` and not GDScript is_equal_approx (whose
# epsilon is 0.00001). The ally-tile fallback is Units.findAllyTile
# (Units.java:217-219,
# `public static Building findAllyTile(Team team, float x, float y, float range, Boolf<Building> pred){`
# / `return indexer.findTile(team, x, y, range, pred);`), which only
# runs when the target is still null and canHeal() holds; the ally
# tile arrives as a pre-filtered observed dict (damaged and not this
# build -- the `b -> b.damaged() && b != this` predicate is the
# driver's). range() and trackingRange() arrive as explicit params
# (the N2188 precedent); the findEnemy calls themselves are the
# driver's, which passes the found standard / track targets in.
# NO driver line: updateTile calls findTarget() at :570 -- the driver
# is its own later slice.
@warning_ignore("unused_parameter")
static func source_turret_find_target_state(frame: Dictionary, range: float, track_range: float, found_standard: Variant, found_track: Variant, can_heal: bool, ally_tile: Variant) -> Dictionary:
	var target: Variant = found_standard
	if absf(track_range - range) > 0.000001 and target == null:
		target = found_track
	if target == null and can_heal:
		target = ally_tile
	return {"target": target}

# TurretBuild.trackingRange() (Turret.java:349-351, `public float trackingRange(){` /
# `return range() + trackingRange - range;`) over the TurretBuild.range() result
# (Turret.java:342-345, `public float range(){` with `return range + peekAmmo().rangeChange;`
# when peekAmmo() is non-null (Turret.java:693, `public @Nullable BulletType peekAmmo(){`),
# else `return range;`), the Turret def trackingRange field (Turret.java:72,
# `public float trackingRange = 0f;`, "Range at which it finds and locks on to the target,
# but does not shoot.") and the BaseTurret def range (BaseTurret.java:21,
# `public float range = 80f;`). The peeked bullet's rangeChange is
# BulletType.java:157, `public float rangeChange = 0f;`, default 0f. init() clamps the
# field (Turret.java:217, `trackingRange = Math.max(range, trackingRange);`), so after init
# trackingRange() >= range(). All live values arrive as explicit params (the N2188
# precedent): the range() result arrives as range_value because range() reads peekAmmo()
# and the tick frame tracks no ammo state yet (the N2316 precedent; the old N739/N740
# range() rows live in PortGame, not on this state). NO driver line: trackingRange() is a
# load-time accessor findTarget reads at Turret.java:652
# (`float trackRange = trackingRange(), range = range();`), not a per-tick write (the
# N2311/N2249 accessor precedent). `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# and `public class BaseTurret extends Block{`.
@warning_ignore("unused_parameter")
static func source_turret_tracking_range_state(frame: Dictionary, range_value: float, tracking_range: float, range: float) -> Dictionary:
	return {"tracking_range": range_value + tracking_range - range}

const TURRET_SAVE_VERSION := 1

static func source_turret_write_state(frame: Dictionary) -> Dictionary:
	# TurretBuild persists exactly TWO fields, its reload counter and its aim rotation
	# (Turret.java:831-834):
	# public void write(Writes write){
	# super.write(write);
	# write.f(reloadCounter);
	# write.f(rotation);
	# The reload counter is the ReloadTurretBuild field (`public float reloadCounter;`,
	# ReloadTurret.java:26), default 0.0, advanced by updateReload (Turret.java:720-723)
	# and read by shouldConsume (Turret.java:364-366, `return isShooting || reloadCounter < reload;`).
	# The rotation is the RotComp float aim angle (`@SyncField(false) @SyncLocal float rotation;`,
	# RotComp.java:8), default 0.0 -- NOT the BaseTurret float rotation (`public float rotation = 90;`,
	# BaseTurret.java:114) that sense() takes as an explicit float param; the two are shadowed
	# (Turret.java:543-544, `//sync underlying rotation; 0-3 rotation is a shadowed field` and
	# `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`). super.write(write)
	# is an empty BuildingComp body (`public void write(Writes write){` with `//overriden by subclasses!`,
	# BuildingComp.java:297-300) -- only the marker is recorded (the N2217 RepairTurret precedent).
	# The write returns ONLY the two persisted values, in Java write order (reloadCounter first,
	# rotation second); nothing else survives save/load. There is NO driver tick line: persistence
	# is not a per-tick call, and the port has no save/load stream to call this function yet.
	# The classes (Turret.java:36, :277): `public class Turret extends ReloadTurret{` and
	# `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`; the parents
	# (ReloadTurret.java:9, :25): `public class ReloadTurret extends BaseTurret{` and
	# `public class ReloadTurretBuild extends BaseTurretBuild{`.
	return {"reload_counter": float(frame.get("reload_counter", 0.0)), "rotation": float(frame.get("rotation", 0.0))}

static func source_turret_read_state(frame: Dictionary, stored_reload_counter: float, stored_rotation: float, revision: int) -> Dictionary:
	# TurretBuild restores the two persisted fields only for saves written at revision >= 1
	# (Turret.java:838-844):
	# public void read(Reads read, byte revision){
	# super.read(read, revision);
	# if(revision >= 1){
	# reloadCounter = read.f();
	# rotation = read.f();
	# because the save version is 1 (`public byte version(){` with `return 1;`, Turret.java:848-850;
	# the BuildingComp base returns 0, BuildingComp.java:669-671, `public byte version(){` with `return 0;`).
	# A revision-0 save leaves the fields where they already are -- the frame's current values
	# (reload_counter default 0.0, rotation default 0.0, the Java field defaults). super.read(read, revision)
	# is an empty BuildingComp body (BuildingComp.java:302-305) -- only the marker is recorded.
	# readSync() (Turret.java:853-862, `public void readSync(Reads read, byte revision){` with
	# `//maintain rotation and reload when syncing so clients don't see turrets snapping around`) is its
	# own slice, not this one. There is NO driver tick line: persistence is not a per-tick call.
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var rotation: float = float(frame.get("rotation", 0.0))
	if revision >= 1:
		reload_counter = stored_reload_counter
		rotation = stored_rotation
	return {"reload_counter": reload_counter, "rotation": rotation}

@warning_ignore("unused_parameter")
static func source_turret_read_sync_state(frame: Dictionary, read_data: Dictionary, revision: int) -> Dictionary:
	# TurretBuild.readSync() (Turret.java:853-861):
	# public void readSync(Reads read, byte revision){
	# //maintain rotation and reload when syncing so clients don't see turrets snapping around
	# float oldRot = rotation, oldReload = reloadCounter;
	# readAll(read, revision);
	# rotation = oldRot;
	# reloadCounter = oldReload;
	# The sync snapshots the aim rotation and the reload counter, applies the sync
	# payload via readAll, then restores both values, so clients do not see turrets
	# snapping around. readAll(read, revision) is the Building base call
	# (BuildingComp.java:283-286, `public void readAll(Reads read, byte revision){`
	# with `readBase(read);` / `read(read, revision);`): the payload it applies
	# arrives here as the already-parsed dict read_data -- Building.readAll itself
	# is NOT ported (the N2330 param precedent), and the call line is shared text
	# with N1776 (BuildingComp.readSync, a different class and method) -- callee
	# evidence, not ownership of TurretBuild.readSync(). The rotation preserved
	# here is the RotComp float aim angle (`@SyncField(false) @SyncLocal float
	# rotation;`, RotComp.java:8), NOT the BaseTurret float rotation
	# (`public float rotation = 90;`, BaseTurret.java:114) that sense() takes as an
	# explicit float param; the two are shadowed (Turret.java:543-544,
	# `//sync underlying rotation; 0-3 rotation is a shadowed field`, the N2322
	# precedent). The reload counter is the ReloadTurretBuild field
	# (`public float reloadCounter;`, ReloadTurret.java:26), default 0.0,
	# advanced by updateReload (Turret.java:720-723). revision is passed through
	# to readAll and the Turret override never branches on it (the N2322 read()
	# guard `if(revision >= 1){` belongs to read(), not to readSync()).
	# read_applied is true exactly when the parsed sync payload is non-empty:
	# the Turret override applies whatever readAll read and then restores the
	# two preserved values. There is NO driver tick line: the engine net sync
	# calls readSync(), and the port has no net stream to call this function yet.
	# The classes (Turret.java:36, :277): `public class Turret extends ReloadTurret{`
	# and `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`.
	var old_rotation: float = float(frame.get("rotation", 0.0))
	var old_reload_counter: float = float(frame.get("reload_counter", 0.0))
	var read_applied: bool = not read_data.is_empty()
	return {"rotation": old_rotation, "reload_counter": old_reload_counter, "read_applied": read_applied}

@warning_ignore("unused_parameter")
static func source_turret_handle_liquid_state(frame: Dictionary, has_coolant: bool, liquid_amount: float) -> Dictionary:
	# TurretBuild.handleLiquid() (Turret.java:615-621):
	# public void handleLiquid(Building source, Liquid liquid, float amount){
	# if(coolant != null && liquids.currentAmount() <= 0.001f){
	# Events.fire(Trigger.turretCool);
	# }
	# super.handleLiquid(source, liquid, amount);
	# }
	# When the turret block has a coolant consumer and the liquid store is
	# (near-)empty, the turret-cool event fires
	# (`Events.fire(Trigger.turretCool);`) -- the port records it as the bool
	# flag turret_cool_fired, it does NOT port Events/Trigger. The base
	# BuildingComp.handleLiquid (BuildingComp.java:872-874,
	# `public void handleLiquid(Building source, Liquid liquid, float amount){`
	# with `liquids.add(liquid, amount);`) is ALWAYS called via super -- the
	# port records it as the flag super_called, it does NOT port
	# Building.handleLiquid (the N585 base slice owns the
	# `liquids.add(liquid, amount);` line). The signature line is shared text
	# with N585 (BuildingComp.handleLiquid base, a different class and
	# method) and N2118 (GenericCrafterBuild evidence) -- callee/context
	# evidence, not ownership of TurretBuild.handleLiquid(); this slice
	# registers the correct java_method = TurretBuild.handleLiquid(). The
	# coolant field lives on the block
	# (`public @Nullable ConsumeLiquidBase coolant;`, BaseTurret.java:34)
	# and arrives here as the explicit bool param has_coolant; the liquid
	# amount is `public float currentAmount(){` (LiquidModule.java:98) and
	# arrives as the explicit float param liquid_amount (the N2330 param
	# precedent). The frame is accepted for the family call shape and read
	# for nothing: handleLiquid writes no frame state. There is NO driver
	# tick line: the engine calls handleLiquid() when liquid enters the
	# building, and the port has no liquid flow to call this function yet.
	# The classes (Turret.java:36, :277): `public class Turret extends ReloadTurret{`
	# and `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`.
	var turret_cool_fired: bool = has_coolant and liquid_amount <= 0.001
	return {"turret_cool_fired": turret_cool_fired, "super_called": true}

@warning_ignore("unused_parameter")
static func source_turret_version_state(frame: Dictionary) -> Dictionary:
	# TurretBuild.version() (Turret.java:848-850):
	# public byte version(){
	# return 1;
	# The save version is 1, so read() applies the persisted reloadCounter/rotation for revision >= 1;
	# the BuildingComp base version() returns 0 (BuildingComp.java:669-671). The frame is accepted for
	# the family call shape and read for nothing: the version is a class constant, not live state.
	# There is NO driver tick line: the version is a load-time constant, not a per-tick write.
	return {"version": 1}

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
		# The sense stamp (N2520): the tick stamps the six
		# live sense inputs it can supply today into the
		# frame, so the N2519-wired dispatch
		# `source_building_comp_sense_state` stops reporting
		# handled:false for the dead / health / camera* legs
		# when a live turret ticks. Health reads the sprite
		# meta `source_block_health` (SourcePlacedBlockState.gd:45,
		# set at placement :82-86 and decremented by damage);
		# a building with no damage record falls back to the
		# block health (`source_block_metadata_state.
		# block_health_value(block)`, the same helper the
		# placement path uses, SourcePlacedBlockState.gd:82),
		# so it is at full health, not dead.
		# `unit_sense_value` is 0.0 today: the proxy unit has
		# no player controller attached, so every camera* leg
		# reads 0 (UnitComp.sense :283-286); when
		# `controlled()` live wiring lands, the tick passes
		# the live player camera value instead. The four
		# graph keys are stamped by the N2522 call right
		# below; the items pair is stamped by the N2521 call
		# right below.
		var sense_health: float = float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_HEALTH_META_KEY, source_block_metadata_state.block_health_value(block)))
		var stamped: Dictionary = source_turret_sense_frame_stamp_state(frame, sense_health, 0.0)
		# The ammo-items stamp (N2521): the tick stamps the
		# live item inventory into the frame, so the N2519-wired
		# dispatch `source_building_comp_sense_state` stops
		# reporting handled:false for the totalItems leg when a
		# live turret ticks. `has_items` is `str(block.
		# implementation) == "ItemTurret"` -- only ItemTurret
		# has an item module (`hasItems = true;`,
		# ItemTurret.java:28); `items_total` stamps the
		# constant 0 because the module is never written for
		# an ItemTurretBuild (its handleItem override never
		# calls super -- see the stamp function comment). The
		# tick reads NO stacks dict here: the port's
		# `turret_ammo_stacks` are the Java `ammo` Seq, not
		# the `items` module.
		var ammo_items_stamped: Dictionary = source_turret_ammo_items_stamp_state(frame, str(block.implementation) == "ItemTurret")
		# The power-graph last-values stamp (N2522): the tick
		# stamps the live graph snapshot into the frame, so
		# the N2519-wired dispatch
		# `source_building_comp_sense_state` stops reporting
		# handled:false for the powerNet* legs when a live
		# turret ticks. The live loop already ran the graph
		# update this tick (`simulate_factory`,
		# SourceFactoryRuntimeState.gd:199) and stored its
		# return on the game (`power_graph_update`, declared
		# in SourcePortGameFactoryStatePortBridge.gd); the
		# tick reads it from the game — it must NOT re-run
		# the update (it is NOT idempotent: it writes battery
		# `power_status` back to sprite metas, so a second
		# run would charge/discharge AGAIN) and must NOT
		# recompute from `game_runtime_state` (that would
		# duplicate the formula, and its batteries read
		# status 0.0). A game with no stored update (a proof
		# calling the tick directly) reads `{}` and the stamp
		# leaves the keys absent — the N2519 fallback.
		var power_graph_update: Variant = game.get("power_graph_update")
		var power_graph_last_values_stamped: Dictionary = source_turret_power_graph_last_values_stamp_state(frame, power_graph_update if power_graph_update is Dictionary else {})
		# The power consumer reads live since N2148 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a turret with a power consumer folds the pure power row
		# into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (Turret.java:512-514)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a power turret does not take the early return. A
		# turret with no power consumer is untouched: the tick
		# models no other consumers yet (foreshadow's item ammo
		# and lustre's liquid nitrogen wait for their own slices),
		# and the shouldConsume gate is wired by N2291
		# (source_turret_should_consume_state, Turret.java:364-366
		# `return isShooting || reloadCounter < reload;`): the
		# tick does not track targeting/reload state yet, so the
		# driver reads frame defaults (is_shooting=false,
		# reload_counter=0.0, reload=10f -- the Java field
		# defaults, boolean false / float 0f /
		# ReloadTurret.java:10) and the gate preserves
		# should_consume=true when enabled. productionValid is
		# the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(source_turret_should_consume_state(frame, bool(frame.get("is_shooting", false)), float(frame.get("reload_counter", 0.0)), float(frame.get("reload", 10.0))).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# The PowerTurret heat fold (Turret.java:674-679, N2270)
			# runs in this generic power-consumer consumption
			# branch, right after the first-pass efficiency stamp:
			# Java order is updateConsumption() with the fold, then
			# updateTile() -- the fold reads the PREVIOUS tick's
			# frame["heat_req"] (the N2263 stamp). The catalog read
			# supplies the per-block requirement / cap: afflict 20f
			# / 1f (Blocks.java:5122-5123), malign 144f / 1f
			# (Blocks.java:6240-6241); a block with no override reads
			# the class defaults -1.0 / 3.0 (Turret.java:53/:55).
			# frame["heat_req"] stays at its field default 0.0 (the
			# live calculateHeat scan waits for its own slice,
			# N2263), so a non-cheating afflict / malign with no
			# heat folds to 0 -- the faithful no-heater behavior.
			# This branch already excludes cheating teams (the
			# N2148 consumption branch), so the fold's cheating
			# floor (1.0) is unreachable live here -- and identical
			# anyway, since the cap is 1.0 for both defs.
			var heat_requirement_state: Dictionary = source_turret_heat_requirement_state(block)
			var power_heat_fold: Dictionary = source_turret_efficiency_multiplier_state(float(frame.get("efficiency", 1.0)), float(heat_requirement_state.get("heat_requirement", -1.0)), float(frame.get("heat_req", 0.0)), bool(frame.get("cheating", false)), float(heat_requirement_state.get("max_heat_efficiency", 3.0)))
			frame["efficiency"] = power_heat_fold.get("efficiency", 1.0)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		if block_id == "duo":
			# The duo half of TurretBuild.updateTile() (Turret.java:490-615,
			# N2250): the aim / reload / shoot half runs on the shared
			# TurretBuild driver, guarded on block `duo` -- the only
			# ItemTurret def this slice ticks. The per-def duo values are
			# range 160, rotateSpeed 10, reload 20, shootCone 15, shootY 3,
			# inaccuracy 2 (Blocks.java:3257-3324, `range = 160;` /
			# `rotateSpeed = 10f;` / `reload = 20f;` / `shootCone = 15f;` /
			# `shootY = 3f;` / `inaccuracy = 2f;`), shootX 0 (the class
			# default, Turret.java:66), ammoPerShot 1 and consumeAmmoOnce
			# true (the class defaults, Turret.java:49/:51). The target
			# verdict is validateTarget (Turret.java:631-633, N2251):
			# the driver judges the acquired target at the head of
			# the duo branch, clears frame["target"] / frame["has_target"]
			# when the verdict is invalid (Turret.java:491,
			# `if(!validateTarget()) target = null;`), and feeds the
			# verdict into the aim/shoot target_valid arg -- target_valid
			# false leaves rotation at its charged value and shoots
			# nothing. findTarget acquisition still waits for its own
			# slice, so until then a frame with has_target false holds
			# no acquired target: the stale target dict (if any) counts
			# as null for the verdict, exactly as Java's target field
			# is null when nothing is acquired. The peeked ammo's reloadMultiplier /
			# rangeChange / speed come from the catalog ammo data
			# (copper 1.0/0/2.5, graphite 0.8/16/3.5, silicon 1.5/0/3,
			# Blocks.java:3259-3295) with the BulletType defaults
			# (BulletType.java:97/:157/:37) when the peeked type omits
			# them. potential_efficiency is the frame's stamped value
			# (duo has no power consumer, so the consumption branch above
			# never stamps it; the absent default is 1.0, the enabled +
			# production-valid first pass, BuildingComp.java:1946 -- the
			# coolant fold waits for its own slice, the driver's existing
			# "models no other consumers yet" approximation). shoot_warmup
			# is the frame's stamped warmup (N2253 advances it with the
			# warmup lerp before the aim/shoot call below; the absent
			# default is the 0.0 field default, and duo minWarmup is 0f
			# so the gate still passes).
			# charging is the frame's stamped flag (duo firstShotDelay is
			# 0, so charging is false live, but the gate is still checked).
			# baseReloadSpeed is efficiency (ReloadTurret.java:45-47,
			# `return efficiency;`), 1.0 before any stamp (the N2240
			# edelta precedent). The shot writes back live: rotation /
			# reload_counter / shot / shoot_event / dest / target_pos /
			# barrel_counter / was_shooting are stamped on the frame every
			# tick, and a shot persists the consumed ammo stacks + total
			# back to the game dicts (the N2247 write-back precedent).
			var duo_key: String = str(game.call("cell_key", cell))
			var duo_stacks_map: Dictionary = game.get("turret_ammo_stacks") if game.get("turret_ammo_stacks") is Dictionary else {}
			var duo_totals_map: Dictionary = game.get("turret_total_ammo") if game.get("turret_total_ammo") is Dictionary else {}
			var duo_entries: Array = duo_stacks_map.get(duo_key, [])
			var duo_total: int = int(duo_totals_map.get(duo_key, 0))
			var duo_peek: Dictionary = source_turret_ammo_state.peek_turret_ammo(game, cell, block)
			# peek_turret_ammo already returns the ammo_data dict
			# itself ({"item", "speed", "reloadMultiplier",
			# "rangeChange", ...}), not a wrapper with an
			# "ammo_data" key -- unwrapping it again yields {}
			# and silently falls back to speed 1.0 /
			# reloadMultiplier 1.0 / rangeChange 0.0.
			var duo_ammo_data: Dictionary = duo_peek
			# validateTarget() at the head of the duo branch
			# (Turret.java:491, `if(!validateTarget()) target = null;`,
			# N2251): a frame with has_target false holds no acquired
			# target, so its target dict (if any) counts as null for
			# the verdict -- in Java the target field is null when
			# nothing is acquired. An invalid verdict clears the frame
			# target and feeds false into the aim/shoot target_valid
			# arg; the team / health / targetable / controlled bools
			# are stamped in from the frame with vacuous defaults
			# (health_valid / unit_targetable true, same team false)
			# until their live wiring lands in its own slice.
			# controlled is NOT a vacuous default anymore: the
			# N2523 tick just below stamps it live from the
			# `unit_is_player` frame input (absent -- so false --
			# today, no player unit in the port,
			# Turret.java:441-443) right after the
			# logic_controlled stamp. logic_controlled
			# is NOT a vacuous default anymore: the N2278 tick just below derives
			# it LIVE from the PREVIOUS tick's logic_control_time
			# (the N2261 decay tick runs later in the driver;
			# Java order :491 validate before :534-536 decay),
			# the same precedent as N2277 deriving it inline for
			# isShooting -- so a logic-controlled duo keeps an
			# otherwise-invalid target through the verdict, exactly
			# as Turret.java:632's `|| logicControlled()` does.
			# canHeal() at the head of the duo branch
			# (Turret.java:635-637, `return targetHealing &&
			# hasAmmo() && peekAmmo().collidesTeam && peekAmmo().
			# heals();`, N2281): the verdict is stamped live
			# right BEFORE the logic_controlled tick and the
			# validateTarget call (Java order :491 validate
			# calls canHeal, before :492 isShooting). Duo never
			# sets targetHealing (Turret.java:95 default false,
			# Blocks.java duo 3257-3331 never overrides it), so
			# the first clause is a false literal; has_ammo is
			# the live duo stacks; ammo_collides_team defaults
			# to the BulletType.java:127 field default false
			# when the peeked ammo data omits it; ammo_heals
			# is healPercent > 0 || healAmount > 0
			# (BulletType.java:447-449) read live from the
			# peeked ammo data. No consumer is rewired: the
			# validateTarget effective-team resolution
			# (Turret.java:632) and the findTarget ally-tile
			# acquisition (:660) both need a live entity scan.
			var can_heal_state: Dictionary = source_turret_can_heal_state(frame, false, not duo_entries.is_empty(), bool(duo_ammo_data.get("collidesTeam", false)), bool(float(duo_ammo_data.get("healPercent", 0.0)) > 0.0 or float(duo_ammo_data.get("healAmount", 0.0)) > 0.0))
			frame["can_heal"] = can_heal_state.get("can_heal", false)
			var logic_controlled_state: Dictionary = source_turret_logic_controlled_state(frame, float(frame.get("logic_control_time", -1.0)))
			frame["logic_controlled"] = logic_controlled_state.get("logic_controlled", false)
			# The controlled stamp (N2523): the tick stamps the
			# live controlled() value into the frame, so the
			# validateTarget call below (Turret.java:491, N2251)
			# and the isShooting (:492, N2277) and warmup (:503,
			# N2253) calls after it stop reading the never-stamped
			# absent default. controlled() is `public boolean
			# controlled(){` / `return unit.isPlayer();`
			# (Turret.java:441-443); the tick reads the live
			# `unit_is_player` frame input (the N2278 precedent,
			# which reads `logic_control_time` the same way), so
			# a proof / driver that sets the input drives the
			# stamp instead of the stamp overwriting it -- and
			# the input is absent on every live frame today (no
			# player unit exists in the port, the N2520
			# precedent), so the stamped value still equals the
			# old absent default on every live frame.
			var controlled_state: Dictionary = source_turret_controlled_stamp_state(frame, bool(frame.get("unit_is_player", false)))
			frame["controlled"] = controlled_state.get("controlled", false)
			var validate: Dictionary = source_item_turret_build_state.source_item_turret_validate_target_state(
				frame.get("target", null) == null or not bool(frame.get("has_target", false)),
				bool(frame.get("target_same_team_effective", false)),
				bool(frame.get("target_health_valid", true)),
				bool(frame.get("target_unit_targetable", true)),
				bool(frame.get("controlled", false)),
				bool(frame.get("logic_controlled", false)))
			if not bool(validate.get("valid", true)):
				frame["target"] = null
				frame["has_target"] = false
			# The isShooting flag (Turret.java:492, N2277) is set
			# right after the validateTarget verdict (:491) and
			# before the warmup target (:502): `isShooting =
			# alwaysShooting || (unit.controller() instanceof
			# Player ? unit.isShooting() : logicControlled() ?
			# logicShooting : target != null);`. Duo has no
			# player and no logic by default (alwaysShooting
			# false, Blocks.java:3257-3331 never overrides it),
			# so isShooting is target != null after the verdict.
			# logicControlled() is derived LIVE from the
			# PREVIOUS tick's logic_control_time (the N2261
			# decay tick runs later in the driver; Java order
			# :492 is before :534-536), the same precedent as
			# N2265 reading the previous tick's heat_req.
			var is_shooting_state: Dictionary = source_turret_is_shooting_state(false, bool(frame.get("controlled", false)), false, float(frame.get("logic_control_time", -1.0)) > 0.0, bool(frame.get("logic_shooting", false)), bool(frame.get("has_target", false)) and bool(validate.get("valid", false)))
			frame["is_shooting"] = is_shooting_state.get("is_shooting", false)
			# The efficiency multiplier fold (Turret.java:674-679,
			# N2265) runs before the warmup advance: Java order is
			# updateConsumption() with the fold, then updateTile()
			# warmup :512-514 -- the warmup lerp reads efficiency
			# as its rate, so the fold must land first. The fold
			# reads the PREVIOUS tick's frame["heat_req"] (the
			# N2263 stamp), exactly as Java reads the previous
			# tick's heatReq field. Duo heatRequirement is -1.0
			# (never overridden), so the guard is off live and
			# efficiency keeps its first-pass 1.0.
			var efficiency_multiplier: Dictionary = source_turret_efficiency_multiplier_state(float(frame.get("efficiency", 1.0)), -1.0, float(frame.get("heat_req", 0.0)), bool(frame.get("cheating", false)), 3.0)
			frame["efficiency"] = efficiency_multiplier.get("efficiency", 1.0)
			# The warmup lerp advance (Turret.java:502-515, N2253)
			# runs before the aim/shoot call: Java order :502-514
			# is before the shoot gate :733, and aim/shoot read
			# shoot_warmup as a gate input. canConsume reads the
			# peek (last) stack amount (Turret.java:711,
			# `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`)
			# against ammoPerShot 1 for duo.
			var duo_peek_amount: int = 0
			if not duo_entries.is_empty():
				var duo_peek_entry: Dictionary = duo_entries[duo_entries.size() - 1]
				duo_peek_amount = int(duo_peek_entry.get("amount", 0))
			var duo_can_consume: bool = not duo_entries.is_empty() and (duo_peek_amount >= 1 or bool(frame.get("cheating", false)))
			# Merge: remote N2253 11-param warmup dropped (content belongs to local N2308) —
			# rewired to source_turret_update_tile_warmup_state. potential_efficiency 1.0/0.0
			# reproduces duo_can_consume exactly (N2308 derives can_consume from it with
			# heat_requirement 0.0, i.e. no heat gating for duo).
			var warmup: Dictionary = source_turret_update_tile_warmup_state(frame, bool(frame.get("is_shooting", false)), 1.0 if duo_can_consume else 0.0, bool(frame.get("charging", false)), bool(frame.get("controlled", false)), float(frame.get("warmup_hold", 0.0)), float(frame.get("shoot_warmup", 0.0)), false, 0.1, float(frame.get("efficiency", 1.0)), 0.0, seconds, 0.0, 0.0)
			frame["shoot_warmup"] = warmup.get("shoot_warmup", 0.0)
			frame["warmup_hold"] = warmup.get("warmup_hold", 0.0)
			# The recoil/heat decay (Turret.java:519/:526, N2254)
			# runs after the warmup advance and before the aim/shoot
			# call: Java order :519/:526 is after :502-515 and before
			# the shoot gate :733. Duo recoilTime is reload 20
			# (Turret.java:208) and cooldownTime is the class default
			# 20 (:148), so the driver passes 20.0 / 20.0.
			var recoil_heat: Dictionary = source_turret_recoil_heat_state(float(frame.get("cur_recoil", 0.0)), float(frame.get("heat", 0.0)), 20.0, 20.0, seconds)
			frame["cur_recoil"] = recoil_heat.get("cur_recoil", 0.0)
			frame["heat"] = recoil_heat.get("heat", 0.0)
			# The multi-recoil decay (Turret.java:520-525, N2256)
			# runs right after the singular recoil/heat decay:
			# Java order :519 then :520-525. Duo recoils is 2
			# (Blocks.java:3301, not the -1 class default at
			# Turret.java:142), recoilTime is reload 20
			# (Turret.java:208), so the driver passes 2 / 20.0.
			var multi_recoil: Dictionary = source_turret_multi_recoil_state(frame.get("cur_recoils", []), 2, 20.0, seconds)
			frame["cur_recoils"] = multi_recoil.get("cur_recoils", [])
			# The charge advance (Turret.java:527, N2259) runs
			# right after the multi-recoil decay: Java order
			# :520-525 decay, :526 heat, :527 charge, :532 offset.
			# charging is `queuedBullets > 0 && shoot.firstShotDelay > 0`
			# (:715-717); duo firstShotDelay is 0 (ShootPattern.java:11,
			# never overridden -- `shoot = new ShootAlternate(3.5f);`,
			# Blocks.java:3299), so the live duo charge is always 0
			# and charging always false, but the frame still gets a
			# live stamp: the warmup tick (N2253) and the shoot gate
			# (:733) read frame["charging"] every tick.
			var charge_state: Dictionary = source_turret_charge_state(float(frame.get("charge", 0.0)), int(frame.get("queued_bullets", 0)), 0.0, seconds)
			frame["charge"] = charge_state.get("charge", 0.0)
			frame["charging"] = charge_state.get("charging", false)
			# The unit maxHealth (BlockUnitComp.tile() :21
			# `maxHealth(tile.block.health);`, N2275) runs BEFORE
			# the unit sync tick: Java order inside tile() is
			# :21 maxHealth, :22 health, :23 hitSize, :24 set --
			# so the maxHealth stamp lands before the N2260 unit
			# sync (hitSize :23) and the N2274 world position
			# (set :24). Duo health is 250 (Blocks.java:3319
			# `health = 250;`, also content_registry_blocks.json
			# blocks/duo/properties/health = 250), so the driver
			# passes 250.0 and stamps frame["unit_max_health"];
			# the default is the duo live value 250.0. The live
			# tile health (`health(tile.health);`, :22) is NOT
			# stamped here: the frame carries no live tile_health
			# input.
			var unit_max_health: Dictionary = source_turret_unit_max_health_state(250.0)
			frame["unit_max_health"] = unit_max_health.get("unit_max_health", 250.0)
			# The unit live health (BlockUnitComp.tile() :22
			# `health(tile.health);`, N2276) runs right after
			# the maxHealth tick: Java order inside tile() is
			# :21 maxHealth, :22 health, :23 hitSize, :24 set --
			# so the health stamp lands after the N2275
			# maxHealth tick and before the N2260 unit sync
			# (hitSize :23) and the N2274 world position
			# (set :24). The live source is the placed-block
			# health meta (SourcePlacedBlockState.health
			# (sprite) reads the sprite meta
			# `source_block_health`, set to the block health
			# at placement), so a damaged duo stamps its live
			# health; the default is the duo live value 250.0
			# (full health at placement, Blocks.java:3319
			# `health = 250;`, also content_registry_blocks
			# .json blocks/duo/properties/health = 250).
			var unit_health: Dictionary = source_turret_unit_health_state(source_placed_block_state.health(sprite))
			frame["unit_health"] = unit_health.get("unit_health", 250.0)
			# The unit sync (Turret.java:529-531, N2260) runs
			# right after the charge advance: Java order :527
			# charge, :529-531 unit sync, :532 offset. The unit
			# is the per-building BlockUnitc (`public BlockUnitc
			# unit = (BlockUnitc)UnitTypes.block.create(team);`,
			# :291), so the driver passes the building cell as
			# the tile, the frame rotation (default 90.0, the aim
			# stamp default) and the previous unit team (default
			# team_id -- the unit is created on the building
			# team), with duo size 1.0 (Block.java:215 default,
			# never overridden) and tilesize 8.0 (Vars.tilesize),
			# then stamps all five keys back on the frame -- the
			# tick runs BEFORE the aim call, so controlled() /
			# unit.controller() read a live unit mirror.
			var unit_sync: Dictionary = source_turret_unit_sync_state(cell, float(frame.get("rotation", 90.0)), int(frame.get("unit_team", team_id)), team_id, team_id, 1.0, 8.0)
			frame["unit_tile"] = unit_sync.get("unit_tile", cell)
			frame["unit_rotation"] = unit_sync.get("unit_rotation", 90.0)
			frame["unit_team"] = unit_sync.get("unit_team", team_id)
			frame["unit_hit_size"] = unit_sync.get("unit_hit_size", 5.6)
			frame["tile_change_team_called"] = unit_sync.get("tile_change_team_called", false)
			# The unit world position (BlockUnitComp.tile()
			# :24 `set(tile);`, N2274) runs right after the
			# unit sync tick: Java order :529-531 sync, :532
			# offset -- tile() positions the unit at the tile's
			# world coordinates (`set(pos.getX(), pos.getY());`,
			# PosComp.java:24; Tile.getX()/getY() are drawx()/
			# drawy(), Tile.java:727-734), so the tick stamps
			# unit_world_x / unit_world_y on the frame with duo
			# size 1.0 (Block.java:215 default, never
			# overridden) and tilesize 8.0 (Vars.tilesize).
			# The x/y defaults are the duo live values for the
			# cell (offset 0, tilesize 8, so cell * 8).
			var unit_world_position: Dictionary = source_turret_unit_world_position_state(cell, 1.0, 8.0)
			frame["unit_world_x"] = unit_world_position.get("unit_world_x", float(cell.x) * 8.0)
			frame["unit_world_y"] = unit_world_position.get("unit_world_y", float(cell.y) * 8.0)
			frame["unit_tile"] = unit_world_position.get("unit_tile", cell)
			# The recoilOffset draw (Turret.java:532, N2258) runs
			# right after the recoil decays: Java order :519/:520-525
			# decay, :532 offset, :595-596 turnToTarget, :601/:609
			# updateShooting -- so the offset uses the PREVIOUS
			# tick's rotation (frame["rotation"], default 90.0 like
			# the aim stamp) and the cur_recoil DECAYED this tick,
			# and it lags a shot by one tick (the tick that shoots
			# still offsets from the pre-shot recoil; the next tick
			# kicks). Duo recoilPow is 1.8 (Turret.java:146) and
			# duo recoil is 0.5 (Blocks.java:3315, not the 1.0
			# class default at Turret.java:140).
			var recoil_offset: Dictionary = source_turret_recoil_offset_state(float(frame.get("rotation", 90.0)), float(frame.get("cur_recoil", 0.0)), 1.8, 0.5)
			frame["recoil_offset"] = recoil_offset.get("recoil_offset", {"x": 0.0, "y": 0.0})
			# The logic-control timer decay (Turret.java:534-536,
			# N2261) runs right after the recoilOffset draw: Java
			# order :532 offset, :534-536 decay, :595-596
			# turnToTarget, :601/:609 updateShooting -- so the
			# tick runs BEFORE the aim call, and the isShooting
			# gate (:492, reading logicControlled()) sees a fresh
			# timer. The field default is -1.0 (:284), so a turret
			# never logic-controlled stays at -1.0 until a logic
			# shoot control arms it (setters :384/:394, own
			# slices); the decay never arms the timer itself.
			var logic_control_time_state: Dictionary = source_turret_logic_control_time_state(float(frame.get("logic_control_time", -1.0)), seconds)
			frame["logic_control_time"] = logic_control_time_state.get("logic_control_time", -1.0)
			# The heatReq fold (Turret.java:538-540, N2263) runs
			# right after the logic-control decay: Java order
			# :534-536 decay, :538-540 heatReq, :542-545 rotate
			# sync -- so the tick runs BEFORE the rotate sync and
			# the aim call. Duo never sets heatRequirement
			# (Blocks.java:3257-3331), so the class default -1.0
			# (Turret.java:53) keeps the guard off and the live
			# duo heatReq stays 0.0 (the field default,
			# Turret.java:295) with a four-zero side_heat (the
			# field default, Turret.java:296) -- only afflict
			# (20f) and malign (144f) set a positive requirement
			# among turrets. The calculateHeat proximity scan
			# (BuildingComp.java:410-461) is a live entity scan
			# (BLOCKED, own slice), so the driver passes the
			# deferred scan total 0.0, which is never assigned
			# while the guard is off; the tick still stamps both
			# keys so the frame mirrors the TurretBuild fields.
			var heat_req_state: Dictionary = source_turret_heat_req_state(-1.0, 0.0, frame.get("side_heat", [0.0, 0.0, 0.0, 0.0]), float(frame.get("heat_req", 0.0)))
			frame["heat_req"] = heat_req_state.get("heat_req", 0.0)
			frame["side_heat"] = heat_req_state.get("side_heat", [0.0, 0.0, 0.0, 0.0])
			# The rotate sync (Turret.java:542-545, N2262) runs
			# right after the heatReq fold: Java order
			# :534-536 decay, :538-540 heatReq (N2263 tick, runs
			# just above), :542-545 rotate sync, :595-596 turnToTarget,
			# :601/:609 updateShooting -- so the tick runs BEFORE
			# the aim call, and the aim reads the synced building
			# rotation. `rotate` is true for duo (Turret
			# constructor :163, never overridden in the duo def,
			# Blocks.java:3257-3331); the building rotation is the
			# shadowed int 0-3 field (BuildingComp.java:69,
			# default 0), synced from the float aim rotation
			# (frame["rotation"], default 90.0) as
			# mod(round(rotation / 90), 4).
			var rotate_sync: Dictionary = source_turret_rotate_sync_state(float(frame.get("rotation", 90.0)), true, int(frame.get("building_rotation", 0)))
			frame["building_rotation"] = rotate_sync.get("building_rotation", 0)
			# The activation timer decay (Turret.java:561-564,
			# N2279) runs right after the rotate sync: Java order
			# :542-545 rotate sync, :561-564 activation gate,
			# :566+ hasAmmo/aim -- so the tick runs BEFORE the aim
			# call. The field default is 0.0 (BaseTurret.java:115),
			# set to activationTime in placed() (:119-120), and
			# duo never overrides activationTime (the class
			# default 0f, BaseTurret.java:27), so a live duo
			# stamps 0.0 and elapsed true every tick; a frame
			# with a positive timer (a def with activationTime
			# > 0, none yet) would decay it by delta and stamp
			# elapsed false. The early-return skip of the
			# aim/shoot half is NOT wired here: the gate never
			# fires for duo, so restructuring the aim block for
			# a never-firing guard is churn, and it waits for a
			# def with activationTime > 0.
			var activation_timer_state: Dictionary = source_turret_activation_timer_state(float(frame.get("activation_timer", 0.0)), seconds)
			frame["activation_timer"] = activation_timer_state.get("activation_timer", 0.0)
			frame["activation_timer_elapsed"] = activation_timer_state.get("activation_timer_elapsed", true)
			var aim: Dictionary = source_item_turret_build_state.source_item_turret_aim_shoot_state(frame, frame.get("target", null),
				bool(validate.get("valid", false)), team_id, sprite.position.x, sprite.position.y, seconds,
				float(frame.get("potential_efficiency", 1.0)), float(frame.get("shoot_warmup", 0.0)), bool(frame.get("charging", false)),
				duo_entries, duo_total, int(frame.get("barrel_counter", 0)),
				160.0, 10.0, 20.0, 15.0, 0.0, 3.0, 2.0, 1, true,
				float(duo_ammo_data.get("reloadMultiplier", 1.0)), float(duo_ammo_data.get("rangeChange", 0.0)), float(duo_ammo_data.get("speed", 1.0)),
				true, 0.0, false, bool(frame.get("cheating", false)), float(frame.get("efficiency", 1.0)))
			frame["rotation"] = aim.get("rotation", 90.0)
			frame["reload_counter"] = aim.get("reload_counter", 0.0)
			# The progress() verdict (Turret.java:425-427,
			# N2282) is stamped right after the reload_counter
			# stamp, once the counter is final for this tick:
			# `return Mathf.clamp(reloadCounter / reload);`
			# with the duo reload 20.0 (Blocks.java:3317, the
			# same 20.0 the aim call above already passes).
			# The only Java consumer is sense()
			# LAccess.progress (`case progress -> progress();`,
			# :414); the sense dispatch is its own later
			# slice, so this slice is stamp-only like
			# N2280/N2281 and no consumer is rewired here.
			var progress_state: Dictionary = source_turret_progress_state(frame, float(frame.get("reload_counter", 0.0)), 20.0)
			frame["progress"] = progress_state.get("progress", 0.0)
			frame["shot"] = aim.get("shot", false)
			frame["shoot_event"] = aim.get("shoot_event", null)
			frame["dest"] = aim.get("dest", null)
			frame["target_pos"] = aim.get("target_pos", null)
			frame["barrel_counter"] = aim.get("barrel_counter_after", 0)
			frame["was_shooting"] = aim.get("was_shooting", false)
			# The isActive() verdict (Turret.java:449-450,
			# N2280) is stamped right after the was_shooting
			# stamp, once every input is its final value for
			# this tick: has_target validated this tick
			# (N2251), was_shooting from this tick's aim,
			# enabled preserved by the frame tick
			# (BuildingComp.java:77, default true), and
			# activation_timer decayed by the N2279 tick
			# above. The frame after a driver tick is the
			# self-consistent snapshot a future consumer
			# (LaserTurret.shouldConsume(),
			# LaserTurret.java:55) reads -- in Java that
			# consumer runs in updateConsumption() BEFORE
			# updateTile() (BuildingComp.java:2274 vs :2277),
			# so a live call sees the previous tick's
			# wasShooting / target; the one-tick difference
			# waits for the LaserTurret consumer slice, and
			# no consumer is rewired here because duo never
			# calls isActive().
			var is_active_state: Dictionary = source_turret_is_active_state(bool(frame.get("has_target", false)), bool(frame.get("was_shooting", false)), bool(frame.get("enabled", true)), float(frame.get("activation_timer", 0.0)))
			frame["is_active"] = is_active_state.get("is_active", false)
			if bool(aim.get("shot", false)):
				duo_stacks_map[duo_key] = aim.get("ammo_entries_after", duo_entries)
				duo_totals_map[duo_key] = int(aim.get("total_ammo_after", duo_total))
				game.set("turret_ammo_stacks", duo_stacks_map)
				game.set("turret_total_ammo", duo_totals_map)
				# bullet() spawn (Turret.java:779-801, N2252): the
				# shoot_event N2250 computed is consumed here -- the
				# pure function derives the spawn origin / angle /
				# velocity from it (ShootAlternate barrel offset,
				# inaccuracy draw, lifeScl 1.0 for duo), the spawn
				# dict is stamped on the frame, and the origin +
				# shoot_angle + the peeked ammo_data go to the
				# existing runtime spawn bridge
				# (SourceBulletRuntimeState.spawn_turret_bullet --
				# the single writer of game["bullets"], N2242/N2243:
				# it converts speed to per-second (x60) and lifetime
				# to seconds (/60) and appends the live dict with
				# the team stamp). The barrel is the pre-increment
				# shoot_event barrel (pattern.shoot runs before the
				# `}, () -> barrelCounter++);` incrementer,
				# Turret.java:770). The random draws are params:
				# x_spread defaults 0.0 (xRand is 0 for duo) and
				# inaccuracy_draw defaults to a live randf_range(-2,
				# 2) draw -- the +-2 degrees faithful to Java -- while
				# the proof seeds a fixed draw through the frame key,
				# so the pure function itself never calls randf.
				var shoot_event: Dictionary = aim.get("shoot_event", {})
				var spawn: Dictionary = source_item_turret_build_state.source_item_turret_bullet_spawn_state(
					shoot_event, sprite.position.x, sprite.position.y, aim.get("target_pos", null),
					int(shoot_event.get("barrel", 0)),
					0.0, 3.0, 3.5, 2, 0, false,
					float(frame.get("x_spread", 0.0)), float(frame.get("inaccuracy_draw", randf_range(-2.0, 2.0))), float(duo_ammo_data.get("speed", 1.0)), float(duo_ammo_data.get("damage", 0.0)),
					float(duo_ammo_data.get("lifetime", 40.0)), float(duo_ammo_data.get("hitSize", 4.0)), 160.0)
				frame["bullet_spawn"] = spawn
				source_bullet_runtime_state.spawn_turret_bullet(game, Vector2(float(spawn.get("bullet_x", 0.0)), float(spawn.get("bullet_y", 0.0))), frame.get("target", null), duo_ammo_data, team_id, float(spawn.get("shoot_angle", 90.0)))
				# The shoot stamp (Turret.java:806-811, N2255)
				# runs after bullet() creates the bullet (:797):
				# `curRecoil = 1f;` / `heat = 1f;` /
				# `totalShots++;` -- the recoil and the heat are
				# 1.0 on the frame until the next tick decays
				# them (N2254), and the shot is counted.
				var shoot_stamp: Dictionary = source_turret_shoot_stamp_state(float(frame.get("cur_recoil", 0.0)), float(frame.get("heat", 0.0)), int(frame.get("total_shots", 0)))
				frame["cur_recoil"] = shoot_stamp.get("cur_recoil", 1.0)
				frame["heat"] = shoot_stamp.get("heat", 1.0)
				frame["total_shots"] = shoot_stamp.get("total_shots", 0)
				# The multi-recoil stamp (Turret.java:807-809, N2257)
				# runs right after the singular shoot stamp: Java
				# order :806 then :807-809, both inside bullet(),
				# after the bullet spawn (:797). The barrel is the
				# pre-increment shoot_event barrel (pattern.shoot
				# runs before the barrelCounter++ incrementer,
				# Turret.java:770) -- NOT frame["barrel_counter"],
				# which the aim tick already stamped with
				# barrel_counter_after = barrelCounter + 1. Duo
				# recoils is 2 (Blocks.java:3301, not the -1 class
				# default at Turret.java:142).
				var multi_recoil_stamp: Dictionary = source_turret_multi_recoil_stamp_state(frame.get("cur_recoils", []), int(shoot_event.get("barrel", 0)), 2)
				frame["cur_recoils"] = multi_recoil_stamp.get("cur_recoils", [])
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}


# TurretBuild.BulletEntry ctor (Turret.java:867-873, `public
# BulletEntry(Bullet bullet, float x, float y, float rotation, float
# life){`): the inner record's only ctor. BulletEntry is a plain
# data holder (Turret.java:864-866, `public static class
# BulletEntry{` / `public Bullet bullet;` / `public float x, y,
# rotation, life;`) -- no Build, no frame, so the port is a pure
# function: the 5 ctor params arrive as explicit params (the N2188
# precedent) and the function returns the record as a Dictionary.
# The 2 ctor assignments below are the only exprs this slice
# owns: each writes one ctor param into the new record field.
# `this.bullet = bullet;`
# `this.life = life;`
# `this.x = x;` -- already the exact_expr of N1115 (the
# `void set(float x, float y){` slice); cited as evidence
# only, never re-registered.
# `this.y = y;` -- also N1115-owned; evidence only.
# `this.rotation = rotation;` -- already the exact_expr
# of N1770 (the `public Building init(...)` slice);
# evidence only. The inline `bullet_entry` dicts in the
# ContinuousTurret/LaserTurret bridges (e.g.
# SourceContinuousTurretBuildPortBridge.gd:293,
# `{"bullet": bullet, "x": offset_x, "y": offset_y,
# "rotation": angle_offset, "life": 0.0}`) are call-site
# literals, not this ctor -- no dedup. The record is
# returned as-is; the callers store entries in a seq
# (ContinuousTurret.java:39 / LaserTurret.java:45,
# `public Seq<BulletEntry> bullets = new Seq<>();`) and
# construct them at ContinuousTurret.java:156 /
# LaserTurret.java:142 (`bullets.add(new
# BulletEntry(bullet, offsetX, offsetY, angleOffset,
# ...));`) -- those call sites are not ported here.
static func source_turret_bullet_entry_state(bullet: Variant, x: float, y: float, rotation: float, life: float) -> Dictionary:
	var bullet_value: Variant = bullet
	var x_value: float = x
	var y_value: float = y
	var rotation_value: float = rotation
	var life_value: float = life
	return {"bullet": bullet_value, "x": x_value, "y": y_value, "rotation": rotation_value, "life": life_value}


# TurretBuild.shoot()/bullet() leftover legs (Turret.java:741-809,
# `protected void shoot(BulletType type){` / `protected void
# bullet(BulletType type, float xOffset, float yOffset, float
# angleOffset, Mover mover){`): the 6 legs remote N2269/N2252 did
# not register -- the barrel capture in the ShootPattern lambda,
# the delayed barrel save/restore around the queued bullet call,
# the ammo-eject effect call, and the shake guard opener. One
# owner + one GD func + one contract (the N2421 design). The
# barrel counter is live build state, so it arrives in the frame
# Dictionary (the N2397 frame precedent) and the delayed action
# reads/writes it there when it runs; the bullet() call and the
# Time.run hook arrive as Callables (the N2395 precedent). The
# 2-arg Angles.trnsx/trnsy overloads (Angles.java:66-70,
# `trnsx(angle, len) = len * cosDeg(angle)`) are the scalar
# cos/sin forms -- NOT the 3-arg rotate overloads (the N2366
# precedent covers the 3-arg form). Mathf.sign(xOffset) is
# signf(x_offset).
# `int barrel = barrelCounter;`
# `int prev = barrelCounter;`
# `barrelCounter = barrel;`
# `barrelCounter = prev;`
# `ammoUseEffect.at(`
# `if(shake > 0){`
# NOT re-registered here: the ammo-eject arg lines (:797-799,
# `x - Angles.trnsx(rotation, ammoEjectBack),` /
# `y - Angles.trnsy(rotation, ammoEjectBack),` /
# `rotation * Mathf.sign(xOffset)`) are implemented as the
# effect position/rotation computation, not separate exprs --
# they are the arguments of the one registered
# `ammoUseEffect.at(` call (the N816 multi-line-call
# precedent). `bullet(type, xOffset, yOffset, angle, mover);`
# (:763/:767) is a call-site of the bullet Callable, owned by
# remote N2269 -- it arrives as the bullet Callable param and
# is never re-ported. `Effect.shake(shake, shake, this);`
# (:803), the body of the shake guard, is registered at
# N2435 (twin-registration under this owner -- the same
# text is already owned at N774 (UnitComp.destroy) and
# N2294 (BurstDrillBuild.updateTile) in other methods).
# The rest of shoot()/bullet() (geometry :743-745,
# charge :748-749, queuedBullets :755/:777, handleBullet/create
# :790, shoot/smoke/sound effects :792-794, recoil/heat
# :806-810) stays with remote N2269/N2252 / future slices.
static func source_turret_shoot_bullet_legs_state(frame: Dictionary, delay: float, bullet: Callable, time_run: Callable, bullet_type: Variant, x_offset: float, y_offset: float, angle_offset: float, mover: Variant, x: float, y: float, rotation: float, ammo_eject_back: float, shake: float, ammo_use_effect: Callable) -> Dictionary:
	# `int barrel = barrelCounter;` (Turret.java:756): capture
	# the barrel counter now -- the Time.run lambda below
	# closes over this local, so a later shot advancing the
	# counter cannot change which barrel this bullet uses.
	var barrel: int = int(frame.get("barrel_counter", 0))
	if delay > 0.0:
		# `Time.run(delay, () -> {` (Turret.java:759): the
		# bullet is queued, not fired -- the action records
		# the delay and runs only when executed.
		var action := func() -> void:
			# `int prev = barrelCounter;` (Turret.java:761)
			var prev: int = int(frame.get("barrel_counter", 0))
			# `barrelCounter = barrel;` (Turret.java:762):
			# restore the barrel this bullet was queued with.
			frame["barrel_counter"] = barrel
			bullet.call(bullet_type, x_offset, y_offset, angle_offset, mover)
			# `barrelCounter = prev;` (Turret.java:764):
			# hand the counter back to whatever it was.
			frame["barrel_counter"] = prev
		time_run.call(delay, action)
	else:
		bullet.call(bullet_type, x_offset, y_offset, angle_offset, mover)
	# `ammoUseEffect.at(` (Turret.java:796): the ammo-eject
	# effect at the turret pos pulled back along the aim
	# angle, rotated by the shot side.
	var effect_x: float = x - ammo_eject_back * cos(deg_to_rad(rotation))
	var effect_y: float = y - ammo_eject_back * sin(deg_to_rad(rotation))
	var effect_rotation: float = rotation * signf(x_offset)
	ammo_use_effect.call(effect_x, effect_y, effect_rotation)
	# `if(shake > 0){` (Turret.java:802): the shake guard
	# opener -- the Effect.shake body (:803) is registered
	# at N2435 (see below).
	var shake_applies: bool = shake > 0.0
	# `Effect.shake(shake, shake, this);` (Turret.java:803): the shake body --
	# Effect.shake(intensity, duration, Position) fires a camera shake of the
	# given intensity for the given duration at the build (Effect.java:210);
	# recorded as data (the N2437 runWave precedent: engine calls not yet
	# wired are recorded in the returned Dictionary).
	var shake_effect: Dictionary = {"intensity": shake, "duration": shake, "x": x, "y": y} if shake_applies else {}
	return {"barrel": barrel, "delayed": delay > 0.0, "ammo_use_effect_x": effect_x, "ammo_use_effect_y": effect_y, "ammo_use_effect_rotation": effect_rotation, "shake_applies": shake_applies, "shake_effect": shake_effect}

static func source_turret_targeting_defaults_state(target_under_blocks: bool = true, under_bullets: bool = false) -> Dictionary:
	# Turret targeting/shoot field defaults (Turret.java:42,
	# :44, :82, :89, :91, :93, :99, :101, :109, :111) -- the
	# decls belong to no method, so this func is their home
	# (N2445, field-decl-only slice, N2440 precedent). The
	# values are the Java field initializers, quoted verbatim
	# below (one expr per comment line, N2378 precedent).
	# `public float targetInterval = 20;`
	# `public float newTargetInterval = -1f;`
	# `public boolean reloadWhileCharging = true;`
	# `public boolean targetAir = true;`
	# `public boolean targetGround = true;`
	# `public boolean targetBlocks = true;`
	# `public boolean displayAmmoMultiplier = true;`
	# `public boolean targetUnderBlocks = true;`
	# `public Boolf<Unit> unitFilter = u -> true;`
	# `public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;`
	# The two Boolf lambdas are data, not Callables: unitFilter
	# is `u -> true` (always true), and buildingFilter is the
	# `targetUnderBlocks || !b.block.underBullets` predicate
	# computed from the two inputs -- target_under_blocks is
	# this slice's :101 default (echoed as both input default
	# and returned key), under_bullets is the per-building
	# Block.underBullets value (Block.java:118, declared
	# without initializer, Java boolean default false; its
	# live read is a later slice).
	var building_filter: bool = target_under_blocks or not under_bullets
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_TARGETING_DEFAULTS_STATE, "target_interval": 20.0, "new_target_interval": -1.0, "reload_while_charging": true, "target_air": true, "target_ground": true, "target_blocks": true, "display_ammo_multiplier": true, "target_under_blocks": target_under_blocks, "unit_filter": true, "building_filter": building_filter}
