extends RefCounted
class_name SourceUnitFactoryBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")
const source_mindustry_time := preload("res://src/runtime/Time.gd")
const source_inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd")
const source_consume_item_state := preload("res://src/game/SourceConsumeItemsState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consume_state := preload("res://src/game/SourceConsumeState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

# Every block whose build is a unit-factory build: the three classes
# that set each consumer's multiplier to Rules.unitCost
# (UnitFactory.java:109, Reconstructor.java:149,
# UnitAssembler.java:175). Their builds run updateTile() every tick
# (UnitFactoryBuild.updateTile(), UnitFactory.java:392;
# ReconstructorBuild.updateTile(), Reconstructor.java:317;
# UnitAssemblerBuild.updateTile(), UnitAssembler.java:429), and each
# of them runs updateConsumption() through the Building update, so
# the live cheating value decides whether the factory consumes.
const SOURCE_UNIT_FACTORY_BUILD_IMPLEMENTATIONS := ["UnitFactory", "Reconstructor", "UnitAssembler"]
const SOURCE_UNIT_FACTORY_BUILDING_META_KEY := "source_unit_factory_building"

static func _is_unit_factory_build_implementation(implementation: String) -> bool:
	return SOURCE_UNIT_FACTORY_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_unit_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The factory tick wires the frame keys the consumption path
	# reads (the N2108 turret pattern): block_implementation is the
	# block's implementation, team_id and rules_state are what Java
	# reads as b.team and state.rules, and cheating is the team's
	# live TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's factory skips consumption like Java's
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

static func source_unit_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill, ContinuousLiquidTurret and turret
	# frames). A factory-family sprite gets an empty frame bound;
	# the live-loop tick fills its keys every tick. Any other block,
	# or an already-bound sprite, binds nothing.
	if block == null or not _is_unit_factory_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_unit_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:
	# BuildingComp.updateConsumption() (BuildingComp.java:1943-1951):
	# when cheating, everything is valid and consumption is skipped
	# (`if(!block.hasConsumers || cheating()){`, the early return
	# sets potentialEfficiency from enabled and productionValid and
	# efficiency from shouldConsume, with no consumer updated). The
	# shared efficiency machinery already implements that method, so
	# this adapter runs it with the frame's live cheating flag and
	# no bound consumer actors: the live-loop tick driver (N2120)
	# binds the actors and runs the first and second passes itself,
	# so this adapter stays the direct N2109/N2111 wrapper over an
	# empty actor list. A cheating factory takes the early return
	# and pays nothing, while a non-cheating one runs the machinery
	# over its (still empty here) actor list. skipped_consumption is the
	# Java early-return condition itself.
	var cheating := bool(frame.get("cheating", false))
	var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(has_consumers, cheating, enabled, production_valid, should_consume, efficiency_scale, [], [], [], frame)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE,
		"cheating": cheating,
		"skipped_consumption": bool(not has_consumers or cheating),
		"potential_efficiency": float(consumption.get("potential_efficiency", 0.0)),
		"efficiency": float(consumption.get("efficiency", 0.0)),
		"optional_efficiency": float(consumption.get("optional_efficiency", 0.0)),
		"should_consume_power": bool(consumption.get("should_consume_power", false)),
	}

static func _team_rules_state(rules_state: Variant, team_id: int) -> Dictionary:
	# TeamRules.get (Rules.java:391-394) creates a fresh TeamRule for
	# a missing team; the N2099 cheating helper reads the same way
	# (an int key, or a string key from JSON).
	if not rules_state is Dictionary:
		return {}
	var teams: Dictionary = (rules_state as Dictionary).get("teams", {})
	if teams.has(team_id):
		return teams[team_id]
	if teams.has(str(team_id)):
		return teams[str(team_id)]
	return {}

static func source_unit_factory_activate_state(rules_state: Variant, team_id: int) -> Dictionary:
	# Team.activateUnitFactories() (Team.java:127-129): the factory
	# activates once the game tick reaches the activation delay,
	# `state.tick >= state.rules.unitActivationDelay(this)`.
	# unitActivationDelay (Rules.java:315-317) is the global delay
	# (Rules.java:93, default 0f) plus the team's own
	# (Rules.java:351, default 0f). The tick is the live game tick:
	# MindustryTime.time accumulates seconds since the game started
	# (Time.gd, updated every _process), so the tick is time * 60
	# (Arc Time.delta is seconds * 60, arc Time.java:26). A null or
	# empty rules state is the Java `new Rules()` default, so the
	# delay is 0 and the factory activates from tick 0.
	var delay: float = source_rules_defaults.UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT
	if rules_state is Dictionary:
		delay = float((rules_state as Dictionary).get("unitFactoryActivationDelay", delay))
		delay += float(_team_rules_state(rules_state, team_id).get("unitFactoryActivationDelay", source_rules_defaults.UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT))
	var tick: float = float(source_mindustry_time.time) * source_time_defaults.TICK_RATE
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ACTIVATE_STATE,
		"activate_unit_factories": tick >= delay,
		"unit_activation_delay": delay,
		"tick": tick,
	}

static func source_unit_factory_has_upgrade_state(block: Object, payload_unit: String, rules_state: Variant, team_id: int) -> Dictionary:
	# ReconstructorBuild.hasUpgrade (Reconstructor.java:388-391):
	# the held unit upgrades when the block's upgrade map holds a
	# pair for it, the upgrade target is unlocked for this team (or
	# the team is AI-controlled), and the held unit is not banned.
	# upgrade() (Reconstructor.java:393-396) finds the pair whose
	# from-unit is the held type; the registry captures the map as
	# `upgrades` (N2124 emitter change, Blocks.java
	# `upgrades.addAll(...)`). unlockedNowHost()
	# (UnlockableContent.java:261-263) is `!state.isCampaign() ||
	# unlockedHost()`; isCampaign is `rules.sector != null`
	# (GameState.java:73-75), and the port has no persistent unlock
	# store, so a campaign session reads the Rules.researched set
	# (Rules.java:187) from the rules state (a unit there counts as
	# unlocked for the host). isAI() (Team.java:111-114) is
	# `(waves || attackMode || isCampaign) && team != defaultTeam
	# && !pvp` (Rules.java:35, 49, 41, 205: waves, attackMode and
	# pvp default false, defaultTeam is sharded, id 1). isBanned()
	# (Rules.java:310-312) is `unitWhitelist !=
	# bannedUnits.contains(unit)` (Rules.java:146-147, 183:
	# whitelist false, banned set empty by default). The unlock is
	# checked on the upgrade TARGET and the ban on the HELD type,
	# exactly as Java writes them. A null block, an empty payload
	# unit, or a payload unit with no pair has no upgrade.
	var upgrade_unit := ""
	if block != null and payload_unit != "":
		var upgrades: Array = block.properties.get("upgrades", [])
		for pair in upgrades:
			if pair is Array and (pair as Array).size() == 2 and str(pair[0]) == payload_unit:
				upgrade_unit = str(pair[1])
				break
	var rules: Dictionary = {}
	if rules_state is Dictionary:
		rules = rules_state
	var is_campaign: bool = rules.get("sector", null) != null
	var researched: Array = rules.get("researched", [])
	var unlocked: bool = not is_campaign or researched.has(upgrade_unit)
	var default_team: int = int(rules.get("defaultTeam", 1))
	var is_ai: bool = (bool(rules.get("waves", false)) or bool(rules.get("attackMode", false)) or is_campaign) and team_id != default_team and not bool(rules.get("pvp", false))
	var banned_units: Array = rules.get("bannedUnits", [])
	var banned: bool = bool(rules.get("unitWhitelist", false)) != banned_units.has(payload_unit)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_HAS_UPGRADE_STATE,
		"has_upgrade": upgrade_unit != "" and (unlocked or is_ai) and not banned,
		"upgrade_unit": upgrade_unit,
		"unlocked": unlocked,
		"is_ai": is_ai,
		"banned": banned,
	}

static func source_unit_factory_assembler_plan_state(block: Object, tier: int) -> Dictionary:
	# UnitAssemblerBuild.plan() (UnitAssembler.java:386-389):
	# `plans.get(Math.min(currentTier, plans.size - 1))` — the
	# current tier's plan, clamped to the last plan. The registry
	# captures the block's plans as `assemblerPlans` (N2124 emitter
	# change, Blocks.java `plans.add(new
	# AssemblerUnitPlan(...))`): each plan is the unit, the build
	# time and the ConsumePayloadDynamic requirements
	# (AssemblerUnitPlan, UnitAssembler.java:276-290). The plan's
	# itemReq/liquidReq are null in vanilla (only the 3-arg
	# constructor is used, UnitAssembler.java:283-287), so they read
	# as empty here; the dynamic consumers over them are a later
	# slice. A null block or a block without plans has no plan. A
	# negative tier clamps to 0 (Java's currentTier never goes
	# negative; the clamp keeps a bad frame from wrapping to the
	# last plan the way a GDScript negative index would).
	if block == null:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PLAN_STATE}
	var plans: Array = block.properties.get("assemblerPlans", [])
	if plans.is_empty():
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PLAN_STATE}
	var index: int = mini(maxi(tier, 0), plans.size() - 1)
	var plan: Dictionary = plans[index]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PLAN_STATE,
		"unit": str(plan.get("unit", "")),
		"time": float(plan.get("time", 0.0)),
		"requirements": Array(plan.get("requirements", [])),
		"item_req": [],
		"liquid_req": [],
	}

static func source_unit_factory_assembler_cons_item_efficiency_state(frame: Dictionary, plan: Dictionary) -> Dictionary:
	# ConsumeItemDynamic.efficiency (ConsumeItemDynamic.java:57-59)
	# for the assembler's consItem (UnitAssembler.java:159:
	# `consume(consItem = new ConsumeItemDynamic((UnitAssemblerBuild
	# build) -> build.plan().itemReq != null ? build.plan().itemReq
	# : ItemStack.empty))`): `consumeTriggerValid() ||
	# items.has(itemReq at multiplier)` — consumeTriggerValid() is
	# false (BuildingComp.java:764-766), so this is the items.has
	# check over the plan's itemReq at the family's Rules.unitCost
	# multiplier (the N2097 callback). Vanilla assembler plans
	# carry no itemReq, so the check is over ItemStack.empty and the
	# efficiency is 1.0. A plan with itemReq gates on the frame's
	# item module holding each stack at Math.round(amount *
	# multiplier) (the drill's RuntimeConsumer model, N2097/N2120).
	var item_req: Array = plan.get("item_req", [])
	if item_req.is_empty():
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CONS_ITEM_EFFICIENCY_STATE, "item_efficiency": 1.0}
	var items: Dictionary = frame.get("items", {})
	var multiplier: float = float(source_consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", 1.0))
	var trigger_valid: bool = source_building_access_state.consume_trigger_valid_state()
	var efficiency := 1.0
	for stack in item_req:
		if not stack is Dictionary:
			continue
		var required: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if not trigger_valid and source_inventory.item_count(items, str(stack.get("item", ""))) < required:
			efficiency = 0.0
			break
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CONS_ITEM_EFFICIENCY_STATE, "item_efficiency": efficiency}

static func source_unit_factory_assembler_payload_state(frame: Dictionary, plan: Dictionary) -> Dictionary:
	# ConsumePayloadDynamic.efficiency (ConsumePayloadDynamic.java:24-32)
	# for the assembler's consPayload (UnitAssembler.java:158:
	# `consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild
	# build) -> build.plan().requirements));`): `float mult =
	# multiplier.get(build); for(PayloadStack stack :
	# payloads.get(build)){ if(!build.getPayloads().contains(stack.item,
	# Math.round(stack.amount * mult))){ return 0f; } } return 1f;`
	# — the payload half of UnitAssemblerBuild.shouldConsume()
	# (UnitAssembler.java:389-391, `consPayload.efficiency(this) > 0`).
	# The building's payload module is UnitAssemblerBuild.blocks
	# (UnitAssembler.java:323, `public PayloadSeq blocks = new
	# PayloadSeq();`), returned by getPayloads()
	# (UnitAssembler.java:717-719, `return blocks;`): an
	# ObjectIntMap<UnlockableContent> of held payload counts plus
	# its total (PayloadSeq.java:10-14, 26-30, 60-64). The port
	# carries it as the frame's `blocks` dict (content name to held
	# count; a missing key reads as an empty module — Java constructs
	# the field empty, never null). PayloadSeq.contains(block,
	# amount) (PayloadSeq.java:71-73) is `get(block) >= amount`, so
	# each requirement stack is held when blocks holds at least
	# Math.round(amount * multiplier). The multiplier is the
	# family's Rules.unitCost callback (UnitAssembler.java:175,
	# `consumeBuilder.each(c -> c.multiplier = b ->
	# state.rules.unitCost(b.team))`), read through the N2097
	# callback like the assembler's cons-item efficiency (N2124);
	# the Consume default (Consume.java:18, `public Floatf<Building>
	# multiplier = b -> 1f;`) is what a frame outside the family
	# keeps. The plan is the current tier's AssemblerUnitPlan from
	# source_unit_factory_assembler_plan_state: its requirements are
	# the ConsumePayloadDynamic rows (vanquish: stell 4 +
	# tungsten-wall-large 10; conquer: locus 6 + carbide-wall-large
	# 20), its itemReq/liquidReq are empty in vanilla. The function
	# is pure: it reads the module and returns the efficiency, a
	# snapshot of the module and its total (PayloadSeq.total(),
	# PayloadSeq.java:22-24). It is not wired into the shouldConsume
	# gate yet — the gate keeps reading the frame's
	# payload_efficiency default (1.0, N2124) until the wiring slice
	# lands it with the blocks the payload intake fills. The
	# payload trigger (ConsumePayloadDynamic.trigger,
	# ConsumePayloadDynamic.java:34-39, `build.getPayloads().remove
	# (stack.item, Math.round(stack.amount * mult));`), the intake
	# (yeetPayload, UnitAssembler.java:688-690, `blocks.add
	# (payload.content(), 1);`, and acceptPayload,
	# UnitAssembler.java:722-727, `blocks.get(payload.content()) <
	# Mathf.round(b.amount * state.rules.unitCost(team))`), and the
	# spawned() clear (UnitAssembler.java:544-571, `blocks.clear();`)
	# are later slices.
	var blocks: Dictionary = frame.get("blocks", {})
	if not blocks is Dictionary:
		blocks = {}
	var requirements: Array = plan.get("requirements", [])
	var multiplier: float = float(source_consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", 1.0))
	var efficiency := 1.0
	for stack in requirements:
		if not stack is Dictionary:
			continue
		var required: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if int(blocks.get(str(stack.get("item", "")), 0)) < required:
			efficiency = 0.0
			break
	var total := 0
	for held in blocks.values():
		total += int(held)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PAYLOAD_STATE, "payload_efficiency": efficiency, "blocks": blocks.duplicate(), "total": total}

static func source_unit_factory_assembler_payload_trigger_state(frame: Dictionary, plan: Dictionary) -> Dictionary:
	# ConsumePayloadDynamic.trigger (ConsumePayloadDynamic.java:34-39)
	# for the assembler's consPayload (UnitAssembler.java:158:
	# `consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild
	# build) -> build.plan().requirements));`): `float mult =
	# multiplier.get(build); for(PayloadStack stack :
	# payloads.get(build)){ build.getPayloads().remove(stack.item, Math.round(stack.amount * mult)); }` — the payload row of the
	# consume() call at unit completion (BuildingComp.consume(),
	# BuildingComp.java:1911-1915, `public void consume(){
	# for(Consume cons : block.consumers){ cons.trigger(self()); } }`).
	# PayloadSeq.remove(block, amount) (PayloadSeq.java:40-42) is
	# `add(block, -amount)` — no clamp: a short stack goes negative
	# before the clear (unlike ItemModule.remove in N2128, which
	# clamps), so the port records the requested removal per stack.
	# UnitAssemblerBuild.spawned() (UnitAssembler.java:543-571) calls
	# consume() first, then creates the unit, then `progress = 0f;
	# ... blocks.clear();` at the end; PayloadSeq.clear()
	# (PayloadSeq.java:61-64) is `payloads.clear(); total = 0;`, so
	# the module is empty afterwards whatever it held — extra blocks
	# beyond the plan and short or empty modules included. The
	# multiplier is the family's Rules.unitCost callback
	# (UnitAssembler.java:175, `consumeBuilder.each(c -> c.multiplier
	# = b -> state.rules.unitCost(b.team))`), read through the N2097
	# callback like the N2129 efficiency; the Consume default
	# (Consume.java:18, `public Floatf<Building> multiplier = b ->
	# 1f;`) is what a frame outside the family keeps. The function
	# is pure apart from the frame's own module: it removes the
	# requirement stacks from the frame's `blocks` dict, records the
	# requested removal per item, then clears the module. It is not
	# wired into the tick driver or the shouldConsume gate — the tick
	# never calls it; the live production wiring (progress advance +
	# the call at completion) is a later slice.
	var blocks: Dictionary = frame.get("blocks", {})
	if not blocks is Dictionary:
		blocks = {}
	var requirements: Array = plan.get("requirements", [])
	var multiplier: float = float(source_consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", 1.0))
	var triggered := 0
	var removed := {}
	for stack in requirements:
		if not stack is Dictionary:
			continue
		var remove_amount: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if remove_amount == 0:
			continue
		var item_name: String = str(stack.get("item", ""))
		blocks[item_name] = int(blocks.get(item_name, 0)) - remove_amount
		removed[item_name] = int(removed.get(item_name, 0)) + remove_amount
		triggered += 1
	blocks.clear()
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_PAYLOAD_TRIGGER_STATE, "triggered": triggered, "removed": removed, "cleared": true, "blocks": blocks.duplicate(), "total": 0}

static func source_unit_factory_should_consume_state(frame: Dictionary, block: Object, game: Object) -> Dictionary:
	# The per-class shouldConsume() bodies, wired into the live loop
	# (N2124 — the N2120 tick passed the frame's enabled flag until
	# they landed):
	#   UnitFactoryBuild.shouldConsume() (UnitFactory.java:445-448):
	#     `if(currentPlan == -1) return false; return enabled &&
	#     payload == null && team.activateUnitFactories();`
	#   ReconstructorBuild.shouldConsume() (Reconstructor.java:367-369):
	#     `return constructing && enabled &&
	#     team.activateUnitFactories();` with constructing()
	#     (:383-385) `payload != null &&
	#     hasUpgrade(payload.unit.type)` and hasUpgrade() (:388-391).
	#   UnitAssemblerBuild.shouldConsume() (UnitAssembler.java:389-391):
	#     `return enabled && !wasOccupied && Units.canCreate(team,
	#     plan().unit) && consPayload.efficiency(this) > 0 &&
	#     consItem.efficiency(this) > 0 &&
	#     team.activateUnitFactories();`
	# The frame carries the Building fields Java reads:
	# current_plan (UnitFactoryBuild.currentPlan, -1 when no plan is
	# set), payload (UnitFactoryBuild/ReconstructorBuild.payload, the
	# held UnitPayload — null when the building holds none; the live
	# loop holds none until the production slice creates one at unit
	# completion), was_occupied (UnitAssemblerBuild.wasOccupied, set
	# by updateTile's spawn check — the port does not model the
	# spawn-solid check yet, so the frame defaults it false) and
	# current_tier (UnitAssemblerBuild.currentTier). The tick driver
	# calls this every tick and passes should_consume to
	# updateConsumption, so a plan-less factory, a payload-less
	# reconstructor, or an occupied assembler stops consuming
	# exactly like Java. Two assembler conjuncts are deferred to
	# their owning slices and read from the frame with permissive
	# defaults that preserve the current live behavior until then:
	# Units.canCreate (Units.java:115-117) needs live per-type unit
	# counts and the unit cap (the unit-group system, C07) —
	# frame["can_create"], default true; consPayload.efficiency
	# (ConsumePayloadDynamic.java:24-32) needs the building's
	# payload module (the payload stacks held, a later slice) —
	# frame["payload_efficiency"], default 1.0. A null block, or an
	# implementation outside the family, consumes nothing.
	var enabled: bool = bool(frame.get("enabled", true))
	var team_id: int = int(frame.get("team_id", 1))
	var rules_state: Variant = {}
	if game != null:
		rules_state = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
	var activated: Dictionary = source_unit_factory_activate_state(rules_state, team_id)
	var activate: bool = bool(activated.get("activate_unit_factories", true))
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_SHOULD_CONSUME_STATE,
		"should_consume": false,
		"enabled": enabled,
		"current_plan": int(frame.get("current_plan", -1)),
		"has_payload": frame.get("payload", null) != null,
		"activate_unit_factories": activate,
		"unit_activation_delay": float(activated.get("unit_activation_delay", 0.0)),
		"tick": float(activated.get("tick", 0.0)),
		"constructing": false,
		"has_upgrade": false,
		"upgrade_unit": "",
		"was_occupied": false,
		"plan_unit": "",
		"can_create": true,
		"payload_efficiency": 1.0,
		"item_efficiency": 1.0,
	}
	var implementation: String = ""
	if block != null:
		implementation = str(block.implementation)
	if implementation == "":
		implementation = str(frame.get("block_implementation", ""))
	if implementation == "UnitFactory":
		result["should_consume"] = int(result["current_plan"]) != -1 and enabled and not bool(result["has_payload"]) and activate
		return result
	if implementation == "Reconstructor":
		var payload: Variant = frame.get("payload", null)
		var payload_unit := ""
		if payload is Dictionary:
			payload_unit = str(payload.get("unit", ""))
		var upgrade: Dictionary = source_unit_factory_has_upgrade_state(block, payload_unit, rules_state, team_id)
		result["constructing"] = payload != null and bool(upgrade.get("has_upgrade", false))
		result["has_upgrade"] = bool(upgrade.get("has_upgrade", false))
		result["upgrade_unit"] = str(upgrade.get("upgrade_unit", ""))
		result["should_consume"] = bool(result["constructing"]) and enabled and activate
		return result
	if implementation == "UnitAssembler":
		result["was_occupied"] = bool(frame.get("was_occupied", false))
		var plan: Dictionary = source_unit_factory_assembler_plan_state(block, int(frame.get("current_tier", 0)))
		result["plan_unit"] = str(plan.get("unit", ""))
		var item_eff: Dictionary = source_unit_factory_assembler_cons_item_efficiency_state(frame, plan)
		result["item_efficiency"] = float(item_eff.get("item_efficiency", 1.0))
		result["can_create"] = bool(frame.get("can_create", true))
		result["payload_efficiency"] = float(frame.get("payload_efficiency", 1.0))
		result["should_consume"] = enabled and not bool(result["was_occupied"]) and activate and float(result["item_efficiency"]) > 0.0 and bool(result["can_create"]) and float(result["payload_efficiency"]) > 0.0
		return result
	return result

static func source_unit_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the factory tick wiring every tick
	# (UnitFactoryBuild.updateTile(), UnitFactory.java:392;
	# ReconstructorBuild.updateTile(), Reconstructor.java:317;
	# UnitAssemblerBuild.updateTile(), UnitAssembler.java:429 — each
	# runs updateConsumption through the Building update): each
	# placed factory-family build gets its frame keys refreshed from
	# the live rules, so the frame's cheating flag tracks
	# team.rules().cheat and updateConsumption skips consumption for
	# a cheating team. The frame is bound at placement
	# (source_unit_factory_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop. The
	# consumption half of updateTile runs here: the bound
	# RuntimeConsumer actors (N2120, one per consumeItem/consumeLiquid
	# row and per current-plan requirement) run through
	# updateConsumption's first and second passes every tick, so a
	# placed unit factory actually consumes — the liquid rows drain
	# per tick and the item rows gate efficiency on the stacks held.
	# The frame delta is not consumed by the wiring itself beyond
	# that; a later slice that ticks production reads it.
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
		if not _is_unit_factory_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_unit_factory_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_unit_factory_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The bound RuntimeConsumer actors (N2120) run through
		# updateConsumption's first pass (minimum efficiency of the
		# non-optional consumers) and second pass (update every
		# update consumer when update, i.e. shouldConsume() &&
		# productionValid(), and efficiency > 0) every tick, so a
		# placed unit factory actually consumes. The binding goes
		# through the reinitialize path, so a sprite re-recorded with
		# a different block (Tile.changeBuild) or a factory whose
		# current plan changed (UnitFactory config) drops the old
		# block's actors and rebinds from the new rows instead of
		# running stale actors against new rows. shouldConsume is
		# the per-class body (N2124:
		# source_unit_factory_should_consume_state — the UnitFactory
		# plan/payload/activation gate, the Reconstructor
		# constructing gate, the UnitAssembler
		# occupied/plan/can-create/payload/item gate); the power
		# consumer stays the power graph's domain (N2080/N2107) and
		# is not bound here.
		frame["enabled"] = bool(frame.get("enabled", true))
		var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		var consumer_bound: Dictionary = source_unit_factory_reinitialize_consumers_state(frame, block, catalog, liquids)
		var rows: Array = consumer_bound.get("rows", [])
		var consumers: Array = consumer_bound.get("consumers", [])
		var should: Dictionary = source_unit_factory_should_consume_state(frame, block, game)
		var should_consume: bool = bool(should.get("should_consume", false))
		var valid: bool = source_building_access_state.production_valid_state()
		var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
		frame["efficiency"] = setup.get("efficiency", 1.0)
		frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
		var groups: Dictionary = source_consume_state.classify_consumer_arrays(rows, "ignored", "optional", "update")
		var required_results: Array = []
		var optional_results: Array = []
		var updates: Array = []
		for index in range(rows.size()):
			var actor = consumers[index]
			actor.source_delta = seconds * source_time_defaults.TICK_RATE
			actor.time_scale = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			if bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
				if groups["non_optional_consumers"].has(rows[index]):
					required_results.append({"result": actor.efficiency(frame), "is_power": false})
				if groups["optional_consumers"].has(rows[index]):
					optional_results.append({"result": actor.efficiency(frame)})
			if groups["update_consumers"].has(rows[index]):
				updates.append(actor)
		var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(_has_consumers_state(block), bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, updates, frame)
		source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_unit_factory_plan_requirements_state(block: Object, plan_index: int) -> Dictionary:
	# The current plan's requirements (UnitFactory.java:207-218,
	# UnitPlan holds the unit, the build time and the ItemStack[]
	# requirements; UnitFactoryBuild.unit(), UnitFactory.java:264-266,
	# reads plans.get(currentPlan)). The registry captures the
	# block's plans as unitPlans (N2120, Blocks.java: the
	# ground-factory's dagger plan is silicon 10 + lead 10 over
	# 900 ticks). A null block, a block without plans, or an index
	# outside the plans (currentPlan -1 — the config handler clamps
	# an out-of-range index to -1, UnitFactory.java:60-62 — or past
	# the end; updateTile forces plan 0 when the block is not
	# configurable, UnitFactory.java:392-394) has no requirements:
	# the ConsumeItemDynamic then reads ItemStack.empty
	# (UnitFactory.java:84), so no item actor binds.
	if block == null:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE}
	var plans: Array = block.properties.get("unitPlans", [])
	if plan_index < 0 or plan_index >= plans.size():
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE}
	var plan: Dictionary = plans[plan_index]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE,
		"unit": str(plan.get("unit", "")),
		"time": float(plan.get("time", 0.0)),
		"items": Array(plan.get("requirements", [])),
	}

static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# The block's consumeBuilder carries one ConsumeItems row per
	# consumeItem stack and one ConsumeLiquid row per consumeLiquid
	# call (Block.java:1127-1131, 1167-1177); the port binds one
	# RuntimeConsumer actor per row (the drill model, N2097/N2100),
	# item rows through SourceConsumeItemsState and liquid rows
	# through SourceConsumeLiquidState, each paying through the N2097
	# cost-multiplier callback — Rules.unitCost for this family
	# (UnitFactory.java:109, Reconstructor.java:149,
	# UnitAssembler.java:175). The UnitFactory class itself carries
	# no static rows: its items come from the ConsumeItemDynamic
	# over the current plan's requirements (UnitFactory.java:84), so
	# one more item actor binds per requirement of the frame's
	# current plan (frame["current_plan"], -1 when no plan is set).
	# Actors are bound once — a frame that already carries them binds
	# nothing — and a block without consume rows binds none. amounts
	# is the building's liquid module (the turret's shape); the item
	# actors read the frame's item module (frame["items"], the
	# Building.items ItemModule), created empty when the frame has
	# none yet. The vanilla rows: the additive-reconstructor consumes
	# silicon 40 + graphite 40 (Blocks.java:6302-6321) and the
	# exponential/tetrative add cryofluid 1/3 per tick
	# (Blocks.java:6342-6385); the assemblers consume cyanogen
	# 0.15/0.2 per tick (Blocks.java:6521-6565) and their plan
	# itemReq/liquidReq are null in vanilla, so no dynamic rows bind
	# for them — the ConsumePayloadDynamic over the plan's payload
	# stacks (UnitAssembler.java:158) is a later slice, like the
	# SingleBlockProducer dynamic consumer deferred in N2115. The
	# power consumer stays the power graph's domain (N2080/N2107).
	# A bound frame records the block and the plan its actors belong
	# to (frame["block_id"], frame["bound_plan"]), so the live-loop
	# tick can tell a replaced building — or a changed plan — from
	# the one its actors were bound for (N2116, Tile.changeBuild).
	var rows: Array = []
	if block != null and block.properties.has("consumeItem"):
		rows.append_array(source_consume_item_state.source_bind_item_consumers_state(block, catalog).get("consumers", []))
	var plan: Dictionary = source_unit_factory_plan_requirements_state(block, int(frame.get("current_plan", -1)))
	var plan_items: Array = plan.get("items", [])
	if not plan_items.is_empty():
		var catalog_items: Array = catalog.call("get_many", "item")
		for stack in plan_items:
			var matches: Array = catalog_items.filter(func(item): return item.id == stack["item"])
			assert(matches.size() == 1, "ConsumeItemDynamic Java field must resolve uniquely in the typed item catalog")
			var row: Dictionary = (stack as Dictionary).duplicate()
			row["ignored"] = source_consume_state.ignore_state()["ignored"]
			rows.append(row)
	if block != null and block.properties.has("consumeLiquid"):
		rows.append_array(source_consume_liquid_state.source_bind_liquid_consumers_state(block, catalog).get("consumers", []))
	if not frame.has("items"):
		frame["items"] = {}
	var items: Dictionary = frame["items"]
	var consumers: Array = frame.get("consumers", [])
	var bound := false
	# The bound rows live on the frame with the actors (the craft
	# slice reads them back at craft() time, N2117): a frame that
	# already carries actors still gets its rows refreshed from the
	# block, so the craft trigger always runs the block's own rows.
	frame["rows"] = rows
	if consumers.is_empty() and not rows.is_empty():
		for row in rows:
			if row.has("liquid"):
				consumers.append(source_consume_liquid_state.source_runtime_consumer_state(row, amounts, [], source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
			else:
				consumers.append(source_consume_item_state.source_runtime_consumer_state(row, items, source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
		frame["consumers"] = consumers
		frame["block_id"] = str(block.id)
		frame["bound_plan"] = int(frame.get("current_plan", -1))
		bound = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_BIND_CONSUMER_STATE, "bound": bound, "consumers": consumers, "rows": rows}

static func source_unit_factory_reinitialize_consumers_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# Tile.changeBuild (Tile.java:636-657) removes the old Building
	# (`build.remove()`) and inits a brand-new one
	# (`entityprov.get().init(...)`, Block.newBuilding(),
	# Block.java:1002), so a replaced building gets fresh consumers
	# from Block.reinitializeConsumers() (Block.java:1481-1497: the
	# consumeBuilder is re-read, the optional / non-optional /
	# update arrays are rebuilt, and each consumer is applied
	# again). The port reuses the sprite node when the same sprite
	# is re-recorded with a different block (initialize_sprite
	# overwrites the block-id meta but keeps the family frame), so
	# without this the tick keeps running the old block's actors
	# against the new block's rows — and indexes past the end of
	# the actor list when the new block has more rows. A UnitFactory
	# config change is the same shape without a new Building: the
	# plan changes (UnitFactory.java:60-62 resets progress, not the
	# ItemModule), so the old plan's actors go stale while the held
	# items stay. The tick therefore reinitializes through here
	# instead of binding directly: a frame already on this block and
	# plan takes the normal once-only bind path; a frame stamped for
	# another block drops its old RuntimeConsumer actors (N2100's
	# invalidate, the cache-invalidation half of
	# reinitializeConsumers), clears its item and liquid stores for
	# the fresh Building's own empty ItemModule/LiquidModule
	# (BuildingComp.java:145-146, init creates a fresh
	# ItemModule/LiquidModule per Building), and rebinds from the
	# new block's consumeBuilder; a frame stamped for another plan
	# drops its old actors and rebinds from the new plan's
	# requirements, keeping the held items and liquids. A null
	# block reinitializes nothing.
	if block == null:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": false, "bound": false, "consumers": frame.get("consumers", []), "rows": []}
	var block_id: String = str(block.id)
	var stamped: String = str(frame.get("block_id", ""))
	var current_plan: int = int(frame.get("current_plan", -1))
	var stamped_plan: int = int(frame.get("bound_plan", -1))
	if stamped == block_id and stamped_plan == current_plan:
		var bound: Dictionary = source_bind_consumer_state(frame, block, catalog, amounts)
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": false, "bound": bool(bound.get("bound", false)), "consumers": bound.get("consumers", []), "rows": bound.get("rows", [])}
	var reinitialized := stamped != "" or (stamped_plan != current_plan and not Array(frame.get("consumers", [])).is_empty())
	if stamped != "":
		source_consume_liquid_state.source_invalidate_consumer_cache_state(block, frame)
		if stamped != block_id:
			frame["items"] = {}
			amounts.clear()
	var rebound: Dictionary = source_bind_consumer_state(frame, block, catalog, amounts)
	frame["block_id"] = block_id
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": reinitialized, "bound": bool(rebound.get("bound", false)), "consumers": rebound.get("consumers", []), "rows": rebound.get("rows", [])}

static func source_unit_factory_consume_state(frame: Dictionary, consumers: Array, rows: Array) -> Dictionary:
	# BuildingComp.consume() (BuildingComp.java:1911-1915): triggers
	# every consumer (`for(Consume cons : block.consumers){
	# cons.trigger(self()); }`). Consume.trigger is empty by default
	# (Consume.java:50 `public void trigger(Building build){}`),
	# ConsumeLiquid has no trigger override (its update drains per
	# tick, N2112) and ConsumePower has none either, so only the item
	# rows remove anything, through the RuntimeConsumer trigger
	# (ConsumeItems.java:45-48, Math.round(stack.amount * multiplier.get(build))
	# removal clamped at what the module holds, ItemModule.java:258-259).
	# Liquid rows are skipped, not triggered: triggering a liquid
	# actor would invent a removal Java never performs. The frame is
	# the build dict the actors read (their items reference is the
	# frame's own item module).
	# The completion sites that call this in Java are the unit
	# completions, not the per-tick consumption passes — the tick
	# driver never calls it:
	#   UnitFactoryBuild.updateTile() (UnitFactory.java:420-436):
	#     `if(progress >= plan.time){ progress %= 1f; ... payload =
	#     new UnitPayload(unit); ... consume(); }` — the plan's
	#     ConsumeItemDynamic stacks leave then
	#     (ConsumeItemDynamic.java:53-56: `for(ItemStack stack :
	#     items.get(build)){ build.items.remove(stack.item,
	#     Math.round(stack.amount * multiplier.get(build))); }`),
	#     one bound actor per plan requirement (N2120).
	#   ReconstructorBuild.updateTile() (Reconstructor.java:340-349):
	#     `if(progress >= constructTime){ payload.unit =
	#     upgrade(...); ... progress %= 1f; ... consume(); }` — the
	#     static consumeItem stacks leave then, through the same
	#     ConsumeItems trigger.
	#   UnitAssemblerBuild.spawned() (UnitAssembler.java:544-571):
	#     `consume();` first, then the unit is created and
	#     `blocks.clear();` — its ConsumePayloadDynamic over
	#     plan().requirements (UnitAssembler.java:158) removes
	#     payload stacks from the building's payload module, which
	#     the port does not model yet, so the assembler payload
	#     trigger is deferred to the plan-dynamics slice; its
	#     ConsumeItemDynamic over plan().itemReq (UnitAssembler.java:159)
	#     is empty in vanilla and its ConsumeLiquidsDynamic
	#     (UnitAssembler.java:160) has no trigger, so no assembler
	#     row removes anything here yet. The multiplier is the
	#     family's Rules.unitCost callback (the N2097 callback the
	#     actors already pay through, UnitFactory.java:109,
	#     Reconstructor.java:149, UnitAssembler.java:175).
	var triggered := 0
	var removed := {}
	var items: Dictionary = frame.get("items", {})
	for index in range(rows.size()):
		if index >= consumers.size():
			continue
		var row = rows[index]
		if row is Dictionary and row.has("liquid"):
			continue
		var actor = consumers[index]
		if actor == null or not actor.has_method("trigger"):
			continue
		var item_name := ""
		if row is Dictionary:
			item_name = str(row.get("item", ""))
		var before := int(items.get(item_name, 0))
		actor.trigger(frame)
		removed[item_name] = before - int(items.get(item_name, 0))
		triggered += 1
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_CONSUME_STATE,
		"triggered": triggered,
		"removed": removed,
	}

static func _has_consumers_state(block: Object) -> bool:
	# Block.hasConsumers is set from the consumeBuilder size
	# (Block.java); the registry captures the block's consume rows,
	# so a block with any consumeItem, consumeLiquid or consumePower
	# row has consumers. Every vanilla unit-factory block does (the
	# factories consume power 1.2, the reconstructors 3-25, the
	# assemblers 2.5-3, Blocks.java), and the UnitFactory class
	# additionally carries its plan's ConsumeItemDynamic.
	if block == null:
		return false
	var properties: Dictionary = block.properties
	return properties.has("consumeItem") or properties.has("consumeLiquid") or properties.has("consumePower") or properties.has("unitPlans")
