extends RefCounted
class_name SourceUnitAssemblerModuleBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The UnitAssemblerModule implementation (UnitAssemblerModule.java:18, `public class UnitAssemblerModule extends PayloadBlock{`): basic-assembler-module (consumePower 3.5f, Blocks.java:6568, `consumePower(3.5f);`; size 5, tier 1, UnitAssemblerModule.java:22, `public int tier = 1;`). UnitAssemblerModule sets acceptsPayload=true (UnitAssemblerModule.java:28, `acceptsPayload = true;`), and its build extends PayloadBlockBuild<Payload> (UnitAssemblerModule.java:71, `public class UnitAssemblerModuleBuild extends PayloadBlockBuild<Payload>{`). The module finds its linked assembler on tileChanges (UnitAssemblerModule.java:79, `link = getLink(team, tile.x, tile.y, rotation);`) and forwards its payload when the forward gate holds (UnitAssemblerModule.java:138, `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`). UnitAssemblerModule extends PayloadBlock, NOT UnitAssembler, so it cannot reuse the unit-factory driver (implementations ["UnitFactory", "Reconstructor", "UnitAssembler"], SourceUnitFactoryBuildState.gd:31); this driver uses its own family frame key ("source_unit_assembler_module_building", the payload-deconstructor precedent), and this slice adds the unit-assembler-module key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The module has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){`) applies. The port has NO SourceUnitAssemblerModule* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the forward gate (UnitAssemblerModule.java:138) follows the folded efficiency.
const SOURCE_UNIT_ASSEMBLER_MODULE_BUILD_IMPLEMENTATIONS := ["UnitAssemblerModule"]
const SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY := "source_unit_assembler_module_building"
# payloadSpeed 0.7f and payloadRotateSpeed 5f are the PayloadBlock class
# defaults (PayloadBlock.java:18, `public float payloadSpeed = 0.7f,
# payloadRotateSpeed = 5f;`); the module does not override them. The
# arrival margin is the hasArrived isZero(0.01f) squared-length margin
# (PayloadBlock.java:242-244, Vec2.java:679-681, `return len2() < margin;`).
const SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_SPEED := 0.7
const SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_ROTATE_SPEED := 5.0
const SOURCE_UNIT_ASSEMBLER_MODULE_ARRIVAL_MARGIN := 0.01
# tier is the UnitAssemblerModule class field (`public int tier = 1;`,
# UnitAssemblerModule.java:22); the single def basic-assembler-module
# sets no tier (Blocks.java:6566-6573) and the catalog carries no tier
# key, so the driver passes the class default explicitly (N2348, the
# N2333 acceptMultipleItems precedent).
const SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT := 1

static func _is_unit_assembler_module_build_implementation(implementation: String) -> bool:
	return SOURCE_UNIT_ASSEMBLER_MODULE_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_unit_assembler_module_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The unit-assembler-module tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (UnitAssemblerModule.java:18, `public class UnitAssemblerModule extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# unit-assembler-module skips consumption like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating"). A team with no rule keeps the false default
	# (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this unit-assembler-module (N2125); the tick preserves a disabled
	# unit-assembler-module instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public UnitAssemblerBuild link;` (UnitAssemblerModule.java:72,
	# null until the first findLink), `public int lastChange = -2;`
	# (UnitAssemblerModule.java:73), the held payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92), the payload
	# offset (`public Vec2 payVector = new Vec2();`, PayloadBlock.java:94)
	# and `public float payRotation;` (PayloadBlock.java:95). The frame
	# inputs (tile_changes, link_candidate,
	# link_candidates, module_fits, was_occupied,
	# rotation) are NOT bound here: the advance reads
	# them with frame.get defaults (1 / null / false / false /
	# 0), the N2228 regen-projector precedent, and the
	# tick fills link_candidate from the N2358 discovery
	# when link_candidates is supplied (a tick with no
	# link_candidates input keeps the seeded
	# link_candidate). accept_payload is
	# NOT a frame input anymore: the tick stamps it live from
	# the link verdict before the advance (N2314).
	return {"link": null, "last_change": -2, "payload": null, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0}

static func source_unit_assembler_module_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the unit-assembler-module frame meta key
	# ("source_unit_assembler_module_building"). A UnitAssemblerModule sprite gets a
	# frame bound with the Java build-field defaults (link null /
	# last_change -2 / payload null / pay_vector zero / pay_rotation 0,
	# N2248); the live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_unit_assembler_module_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_unit_assembler_module_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-assembler-module does not take the early return. The forward gate follows the folded efficiency (UnitAssemblerModule.java:138, `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`) and the module has no shouldConsume override, so the default (BuildingComp.java:755, `public boolean shouldConsume(){`) applies -- the row folds under the live default, not the MendProjector-suppression precedent. The basic-assembler-module (consumePower 3.5f, Blocks.java:6568, `consumePower(3.5f);`) has no liquid consumer, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the module has no liquid/item consumer, so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume default applies -- the module has no override; the machinery runs with should_consume=true when enabled. (3) updateTile advance live (N2248) -- the lastChange refresh + findLink re-discovery + moveInPayload + the handoff gate (UnitAssemblerModule.java:132-141) run in source_unit_assembler_module_update_tile_advance_state; the N2168 proof still carries no link/payload/tier keys (the efficiency > 0 gate (UnitAssemblerModule.java:138) is what the efficiency keys prove) while the N2248 proof carries the link/payload keys. getLink discovery live (N2358) -- the moduleFits geometry pure + the discovery pure over an EXPLICIT frame-input candidate list, the tick filling frame["link_candidate"] before the N2248 advance (the live team-wide flagged fill still waits -- see DEFERRED); the wasOccupied predicate evaluation, the handoff-to-intake wiring, and the live payload fill wait for their own slices -- see DEFERRED. (4) No link/draw/onRemoved rows -- see DEFERRED. canPlaceOn live (N2345) -- the placement gate (UnitAssemblerModule.java:48-51) runs in source_unit_assembler_module_can_place_on_state, reading the frame link verdict (N2248); the live placement call site waits for its own slice. acceptPayload rows live (N2299) -- the module gate (UnitAssemblerModule.java:110-111) and the link assembler gate (UnitAssembler.java:722-727) run in source_unit_assembler_module_accept_payload_state / source_unit_assembler_accept_payload_state, and the tick exposes both verdicts on the frame (accepts_payload / link_accepts_payload). Handoff-gate wiring live (N2314) -- the N2248 handoff gate reads the LINK verdict live: the tick stamps frame["accept_payload"] from link_accepts_payload before the advance, so a live module hands off when the link accepts; the module verdict does NOT drive the gate. Tier stamp live (N2348) -- tier() (UnitAssemblerModule.java:85-86) returns the class field tier = 1 (UnitAssemblerModule.java:22); the tick stamps frame["tier"] every tick (the catalog carries no tier key and the def sets no tier, so the driver passes the class default explicitly); the checkTier pure is live since N2133; checkTier wiring live (N2351) -- the module tick feeds updateModules/removeModule events into the assembler frame modules list through the unit-factory cell helper (the link cell comes from the {"block", "cell"} frame-input format; a link without a cell skips); the getLink discovery produces those links since N2358 (from an explicit candidate list; the live flagged fill waits for its own slice). (5) No variant verification -- there is only one module def (basic-assembler-module).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_unit_assembler_module_accept_payload_state(has_link: bool, has_payload: bool, link_accepts: bool) -> Dictionary:
	# The module acceptPayload gate (UnitAssemblerModuleBuild.
	# acceptPayload(), UnitAssemblerModule.java:110-111 -- the
	# file is in world/blocks/units/, NOT payloads/, and
	# :110-111 is the gate: the DEFERRED entry's :125-127 cite
	# is inside onRemoved):
	# `public boolean acceptPayload(Building source, Payload payload){`
	# `return link != null && this.payload == null && link.acceptPayload(this, payload);`
	# -- link present (`public UnitAssemblerBuild link;`,
	# UnitAssemblerModule.java:72) && own payload empty (the
	# held payload, `public @Nullable T payload;`,
	# PayloadBlock.java:92) && the link assembler accepts the
	# offered payload. The link verdict comes from Pure 2
	# (source_unit_assembler_accept_payload_state, the slice
	# owns both) -- it is a parameter here, not a frame input.
	# The result echoes the three gate terms with the verdict
	# so the proof pins each term.
	var accepts: bool = has_link and not has_payload and link_accepts
	return {"accepts": accepts, "has_link": has_link, "has_payload": has_payload, "link_accepts": link_accepts}

@warning_ignore("unused_parameter")
static func source_unit_assembler_module_tier_state(block_id: String, tier_default: int) -> Dictionary:
	# tier() (UnitAssemblerModule.java:85, `public int tier(){` with
	# `return tier;`, UnitAssemblerModule.java:86) returns the block's
	# tier field (`public int tier = 1;`, UnitAssemblerModule.java:22),
	# also surfaced in setStats (`stats.add(Stat.moduleTier, tier);`,
	# UnitAssemblerModule.java:33). The assembler consumes it in
	# checkTier() (UnitAssembler.java:364-378): `modules.sort(b -> b.tier());`
	# then the max-tier walk (`if(mod.tier() == max || mod.tier() == max + 1){`
	# / `max = mod.tier();`), with the tier-gap break. moduleFits
	# (UnitAssembler.java:338-351) is geometry only -- no tier term.
	# The catalog carries no tier key for basic-assembler-module and
	# the def sets no tier (Blocks.java:6566-6573), so the single def
	# keeps the class default: the driver passes it explicitly as
	# tier_default (the N2333 acceptMultipleItems precedent) and the
	# pure returns it. block_id is the def the tier belongs to -- a
	# future def that overrides tier passes its own value as
	# tier_default; the pure itself is def-agnostic.
	var tier: int = tier_default
	return {"tier": tier}

static func source_unit_assembler_accept_payload_state(payload: Dictionary, assembler: Dictionary, plan_requirements: Array, unit_cost: float, source_is_module: bool) -> Dictionary:
	# The link assembler acceptPayload gate (UnitAssemblerBuild.
	# acceptPayload(), UnitAssembler.java:722-727), the gate the
	# module gate delegates to:
	# `public boolean acceptPayload(Building source, Payload payload){`
	# `var plan = plan();`
	# `return (this.payload == null || (source instanceof UnitAssemblerModuleBuild)) &&`
	# `plan.requirements.contains(b -> b.item == payload.content() &&`
	# `blocks.get(payload.content()) < Mathf.round(b.amount * state.rules.unitCost(team)) -`
	# `(source instanceof UnitAssemblerModuleBuild && (this.payload != null && this.payload.contentEquals(payload)) ? 1 : 0));`
	# plan() is the current unit plan (UnitAssembler.java:
	# 383-386, `return plans.get(Math.min(currentTier, plans.size - 1));`)
	# with its requirements Seq<PayloadStack>; the caller
	# supplies the plan requirements as an Array of Dicts
	# {item, amount} (PayloadStack.amount is an int,
	# PayloadStack.java:9, `public int amount = 1;`). blocks
	# is the assembler's stored-blocks map
	# `public PayloadSeq blocks = new PayloadSeq();`
	# (UnitAssembler.java:323), supplied as a Dictionary item
	# -> count; the stored count is blocks.get(content)
	# `public int get(UnlockableContent block){`
	# (PayloadSeq.java:66-68, delegating to ObjectIntMap.get,
	# which returns 0 for a missing key,
	# ObjectIntMap.java:285-286, `return get(key, 0);`) -- an
	# unknown count is 0, which ACCEPTS when a requirement
	# exists (an empty blocks map means nothing stored yet, so
	# the count check passes). unit_cost is the rules
	# unit-cost multiplier (Rules.java:275-277)
	# `return unitCostMultiplier * teams.get(team).unitCostMultiplier;`
	# (both factors default 1f, so the frame input defaults
	# 1.0). Mathf.round is arc's BIG_ENOUGH trick
	# (Mathf.java:500-501)
	# `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
	# with BIG_ENOUGH_ROUND = 16*1024 + 0.5f, i.e. floor(x +
	# 0.5) -- NOT Java Math.round, though the two agree on
	# non-negative values; the port uses roundi, which matches
	# on this non-negative domain (amount >= 0, unit_cost >=
	# 0): roundi(2.5) == 3. The -1 adjustment applies when the
	# source is a module AND the assembler already holds an
	# equal payload -- contentEquals is the Payload interface
	# method (`boolean contentEquals(Payload other);`,
	# Payload.java:39), the build comparison for BuildPayload
	# `return other instanceof BuildPayload bp && bp.block() == build.block;`
	# (BuildPayload.java:43) -- and accounts for the in-flight
	# payload. The verdict is Java-exact
	# any-match: plan.requirements.contains accepts when ANY
	# matching requirement's count check passes; the reported
	# quota is the FIRST matching requirement's quota (plans
	# carry one stack per content in every def, so the two
	# agree in practice). No requirement for the item means no
	# quota (0) and a reject; no payload offered (empty
	# content_item) matches no requirement and rejects. The
	# function does NOT mutate its inputs.
	var content_item: String = str(payload.get("content_item", ""))
	var assembler_has_payload: bool = bool(assembler.get("has_payload", false))
	var payload_content_equals: bool = bool(assembler.get("payload_content_equals", false))
	var blocks: Dictionary = assembler.get("blocks", {})
	var stored_count: int = int(blocks.get(content_item, 0))
	var module_adjustment: int = 1 if (source_is_module and assembler_has_payload and payload_content_equals) else 0
	var requirement_found := false
	var quota := 0
	var any_requirement_passes := false
	for requirement in plan_requirements:
		if not (requirement is Dictionary):
			continue
		if content_item == "" or str(requirement.get("item", "")) != content_item:
			continue
		var requirement_quota: int = roundi(float(int(requirement.get("amount", 0))) * unit_cost) - module_adjustment
		if not requirement_found:
			requirement_found = true
			quota = requirement_quota
		if stored_count < requirement_quota:
			any_requirement_passes = true
	var accepts: bool = (not assembler_has_payload or source_is_module) and any_requirement_passes
	return {"accepts": accepts, "requirement_found": requirement_found, "quota": quota, "stored_count": stored_count, "module_adjustment": module_adjustment}

# --- N2345: canPlaceOn placement gate (DEFERRED #41) ---
# The canPlaceOn pure evaluates the getLink verdict the frame already
# carries. Java's override (UnitAssemblerModule.java:48-51):
# `public boolean canPlaceOn(Tile tile, Team team, int rotation){`
# `return getLink(team, tile.x, tile.y, rotation) != null;`
# -- a module can be placed only where a fitting assembler is linked.
# getLink (UnitAssemblerModule.java:65-69):
# `public @Nullable UnitAssemblerBuild getLink(Team team, int x, int y, int rotation){`
# `return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));`
# -- the first flagged assembler whose moduleFits holds. The build
# field is `public UnitAssemblerBuild link;`
# (UnitAssemblerModule.java:72), refreshed by findLink
# (UnitAssemblerModule.java:75-83):
# `link = getLink(team, tile.x, tile.y, rotation);`
# on tileChanges -- the N2248 advance ports that refresh, so the frame
# link IS the getLink verdict. The pure takes the frame only: Java
# receives tile / team / rotation, but the port has no live building
# query, so the verdict arrives through the frame link (the N2330 UCL
# canPlaceOn precedent). No link stamped (absent or null) means CANNOT
# place -- the Java-exact default: the link field defaults null (:72,
# no initializer; _initial_frame binds null) and getLink returns null
# when no assembler fits. This is RESTRICTIVE, unlike the N2330
# permissive canCreate default. The pure does NOT read link_candidate:
# the candidate only becomes the link on refresh. canPlaceOn is a
# placement gate, NOT tick wiring: the driver never calls this pure
# each tick, and the live placement call site (the valid-place hook,
# SourceBlockGeometry.gd:1149-1151) waits for its own slice. Cite
# correction: the brief and the resolved DEFERRED entry cited :53-55,
# but the method is :48-51 at this pin (signature :49, return :50);
# :53-55 is inside drawPlanRegion.
static func source_unit_assembler_module_can_place_on_state(frame: Dictionary) -> Dictionary:
	return {"can_place_on": frame.get("link", null) != null}

# --- N2358: getLink discovery (DEFERRED #317) ---
# Pure (a) -- moduleFits (UnitAssembler.java:338-351),
# geometry only (NO tier term -- the tier climb lives in
# checkTier, UnitAssembler.java:364-378, live since
# N2133):
# `public boolean moduleFits(Block other, float ox, float oy, int rotation){`
# `float`
# `dx = ox + Geometry.d4x(rotation) * (other.size/2f + 0.5f) * tilesize,`
# `dy = oy + Geometry.d4y(rotation) * (other.size/2f + 0.5f) * tilesize;`
# `Vec2 spawn = getUnitSpawn();`
# `if(Tile.relativeTo(ox, oy, spawn.x, spawn.y) != rotation){`
# `return false;`
# `float dst = Math.max(Math.abs(dx - spawn.x), Math.abs(dy - spawn.y));`
# `return Mathf.equal(dst, tilesize * areaSize / 2f - tilesize/2f);`
# getUnitSpawn() (UnitAssembler.java:332-336):
# `public Vec2 getUnitSpawn(){`
# `float len = tilesize * (areaSize + size)/2f;`
# `float unitX = x + Geometry.d4x(rotation) * len, unitY = y + Geometry.d4y(rotation) * len;`
# `return Tmp.v4.set(unitX, unitY);`
# -- the spawn uses the ASSEMBLER rotation and world pos
# (the build fields of the UnitAssemblerBuild), while the
# dx/dy reach and the relativeTo check use the MODULE
# rotation (the moduleFits parameter, passed by getLink
# from the module's own rotation): the two rotations
# differ in general, so the pure takes both. The d4
# tables are local arrays indexed through posmod
# (rotation, 4) (the BeamDrill precedent for
# Geometry.d4x/d4y, arc Geometry.java:23-24,
# `public final static int[] d4x = {1, 0, -1, 0};`
# `public final static int[] d4y = {0, 1, 0, -1};`,
# indexed through `return d4x[Mathf.mod(i, 4)];` /
# `return d4y[Mathf.mod(i, 4)];`, arc Geometry.java:47-52).
# Tile.relativeTo is NOT re-invented: the float overload
# (Tile.java:103-113,
# `public static int relativeTo(float x, float y, float cx, float cy){`)
# already has its port in tile_relative_float_state
# (SourceBlockGeometry.gd:61-72) and the pure calls it.
# Mathf.equal is the arc tolerance check
# (Mathf.java:544-546,
# `public static boolean equal(float a, float b){`
# `return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;`
# with `public static final float FLOAT_ROUNDING_ERROR = 0.000001f;`,
# Mathf.java:10), inlined as absf(dst - target) <=
# 0.000001. area_size defaults to the UnitAssembler
# class default 11 (UnitAssembler.java:45,
# `public int areaSize = 11;`); the three defs all set
# 13 (Blocks.java:6531/6546/6561). Sizes default to the
# Block class default 1 (Block.java:215,
# `public int size = 1;`). tilesize is 8
# (Vars.java:135, `public static final int tilesize = 8;`),
# passed in so the pure stays testable. The result
# echoes the intermediates (spawn / dx / dy / dst /
# target / relative_to) so the proof pins each term
# (the acceptPayload precedent).
static func source_unit_assembler_module_fits_state(module: Dictionary, assembler: Dictionary, tilesize: float) -> Dictionary:
	var module_x: float = float(module.get("x", 0.0))
	var module_y: float = float(module.get("y", 0.0))
	var module_size: int = int(module.get("size", 1))
	var module_rotation: int = int(module.get("rotation", 0))
	var assembler_x: float = float(assembler.get("x", 0.0))
	var assembler_y: float = float(assembler.get("y", 0.0))
	var assembler_size: int = int(assembler.get("size", 1))
	var assembler_rotation: int = int(assembler.get("rotation", 0))
	var area_size: int = int(assembler.get("area_size", 11))
	var d4x: Array = [1, 0, -1, 0]
	var d4y: Array = [0, 1, 0, -1]
	var spawn_len: float = tilesize * float(area_size + assembler_size) / 2.0
	var spawn := Vector2(assembler_x + float(d4x[posmod(assembler_rotation, 4)]) * spawn_len, assembler_y + float(d4y[posmod(assembler_rotation, 4)]) * spawn_len)
	var relative_to: int = source_block_geometry.tile_relative_float_state(module_x, module_y, spawn.x, spawn.y)
	var reach: float = (float(module_size) / 2.0 + 0.5) * tilesize
	var dx: float = module_x + float(d4x[posmod(module_rotation, 4)]) * reach
	var dy: float = module_y + float(d4y[posmod(module_rotation, 4)]) * reach
	var dst: float = maxf(absf(dx - spawn.x), absf(dy - spawn.y))
	var target: float = tilesize * float(area_size) / 2.0 - tilesize / 2.0
	var fits: bool = relative_to == module_rotation and absf(dst - target) <= 0.000001
	return {"fits": fits, "spawn": spawn, "dx": dx, "dy": dy, "dst": dst, "target": target, "relative_to": relative_to}

# Pure (b) -- getLink discovery
# (UnitAssemblerModule.java:65-69):
# `public @Nullable UnitAssemblerBuild getLink(Team team, int x, int y, int rotation){`
# `var results = Vars.indexer.getFlagged(team, BlockFlag.unitAssembler).<UnitAssemblerBuild>as();`
# `return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));`
# -- the FIRST assembler in list order whose moduleFits
# holds (Java Seq.find). The port has NO team-wide
# flagged-buildings index (Vars.indexer is not ported),
# so the candidate list is an EXPLICIT frame input (the
# N2301 precedent -- the consuming slice defines the
# frame-input format, the producer conforms later; the
# live flagged fill waits for its own slice -- see
# DEFERRED): each candidate is {"block": <id>, "cell":
# <Vector2i>, "rotation": <int>, "size": <int>,
# "area_size": <int>, "x": <float>, "y": <float>} -- x/y
# are the assembler world coords, cell the origin cell.
# The pure returns the first fitting candidate as the
# N2351 link format {"block", "cell": Vector2i} (cell =
# assembler origin cell -- the N2351 checkTier wiring
# reads frame["link"]["cell"] and skips a link without
# a cell), or null with candidate_index -1 when nothing
# fits. Non-dict entries and entries without a block or
# a Vector2i cell skip (they cannot form the N2351 link
# format -- the N2351 defensive-skip precedent); checked
# counts only the candidates the fits pure evaluated,
# and the scan stops at the first fit. The module dict
# is the fits-pure module geometry ({"x", "y", "size",
# "rotation"} -- x/y are the module world coords, x *
# tilesize + offset in getLink terms). The function does
# NOT mutate its inputs.
static func source_unit_assembler_module_get_link_state(module: Dictionary, candidates: Array, tilesize: float) -> Dictionary:
	var link: Variant = null
	var candidate_index := -1
	var checked := 0
	for index in range(candidates.size()):
		var candidate: Variant = candidates[index]
		if not (candidate is Dictionary):
			continue
		var candidate_dict: Dictionary = candidate
		if not candidate_dict.has("block") or not (candidate_dict.get("cell") is Vector2i):
			continue
		var assembler: Dictionary = {"x": float(candidate_dict.get("x", 0.0)), "y": float(candidate_dict.get("y", 0.0)), "size": int(candidate_dict.get("size", 1)), "rotation": int(candidate_dict.get("rotation", 0)), "area_size": int(candidate_dict.get("area_size", 11))}
		checked += 1
		var verdict: Dictionary = source_unit_assembler_module_fits_state(module, assembler, tilesize)
		if bool(verdict.get("fits", false)):
			link = {"block": str(candidate_dict.get("block", "")), "cell": candidate_dict.get("cell")}
			candidate_index = index
			break
	return {"link": link, "candidate_index": candidate_index, "checked": checked}

static func _unit_assembler_module_vec2_approach(pay_vector: Vector2, alpha: float) -> Vector2:
	# Vec2.approach(Vec2 target, float alpha) (Vec2.java:525-537),
	# target Vec2.ZERO here (PayloadBlock.java:194,
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`).
	# `float dx = x - target.x, dy = y - target.y;`
	# `float alpha2 = alpha*alpha;`
	# `float len2 = Mathf.len2(dx, dy);`
	# `if(len2 > alpha2){` scales the offset by
	# `float scl = Mathf.sqrt(alpha2 / len2);` and subtracts it, else
	# `return set(target);` snaps to the target.
	var dx: float = pay_vector.x
	var dy: float = pay_vector.y
	var alpha2: float = alpha * alpha
	var len2: float = dx * dx + dy * dy
	if len2 > alpha2:
		var scl: float = sqrt(alpha2 / len2)
		return Vector2(pay_vector.x - dx * scl, pay_vector.y - dy * scl)
	return Vector2.ZERO

static func _unit_assembler_module_move_in_payload(pay_vector: Vector2, pay_rotation: float, rotation_degrees: float, delta: float) -> Dictionary:
	# PayloadBlockBuild.moveInPayload(true)
	# (PayloadBlock.java:181-197, the no-arg call delegates:
	# `public boolean moveInPayload(){`
	# `return moveInPayload(true);`
	# `public boolean moveInPayload(boolean rotate){`
	# `if(payload == null) return false;`
	# -- the caller checks the payload first, so this helper only
	# runs with a payload present. `updatePayload();` (:189) sets
	# the live payload position
	# `payload.set(x + payVector.x, y + payVector.y, payRotation);`
	# (PayloadBlock.java:174-177) -- DEFERRED, the port's payload
	# dict carries no position. rotate is TRUE here (unlike the
	# deconstructor's moveInPayload(false), N2233), so the
	# rotation branch runs:
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());`
	# -- the module rotates (UnitAssemblerModule.java:26,
	# `rotate = true;`), so the target is rotdeg()
	# `public float rotdeg(){`
	# `return rotation * 90;`
	# (BuildingComp.java:582-584), passed in as rotation_degrees.
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`
	# `return hasArrived();`
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:242-244, Vec2.java:679-681)
	# `return len2() < margin;`
	# -- the SQUARED length, not the length. payloadSpeed 0.7f
	# and payloadRotateSpeed 5f are the PayloadBlock class
	# defaults
	# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
	# (PayloadBlock.java:18); the module does not override them.
	var moved_rotation: float = source_math_state.source_angles_move_toward(pay_rotation, rotation_degrees, SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_ROTATE_SPEED * delta)
	var moved: Vector2 = _unit_assembler_module_vec2_approach(pay_vector, SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_SPEED * delta)
	return {"pay_vector": moved, "pay_rotation": moved_rotation, "arrived": moved.length_squared() < SOURCE_UNIT_ASSEMBLER_MODULE_ARRIVAL_MARGIN}

static func source_unit_assembler_module_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance (UnitAssemblerModuleBuild.updateTile(),
	# UnitAssemblerModule.java:132-141), the pure frame advance -- the
	# build fields are `public UnitAssemblerBuild link;`
	# (UnitAssemblerModule.java:72), `public int lastChange = -2;`
	# (UnitAssemblerModule.java:73), the held payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92), the payload
	# offset (`public Vec2 payVector = new Vec2();`, PayloadBlock.java:94)
	# and `public float payRotation;` (PayloadBlock.java:95), and the
	# advance follows the Java lines in order (each exact expr on ONE
	# comment line, the N2148 lesson):
	# `if(lastChange != world.tileChanges){`
	# `lastChange = world.tileChanges;`
	# `findLink();` -- `public void findLink(){`
	# (UnitAssemblerModule.java:75-83):
	# `link.removeModule(this);` -- live since N2351: the tick
	# wires it through the unit-factory cell helper (the link
	# cell comes from the {"block", "cell"} frame-input format;
	# a link without a cell skips).
	# `link = getLink(team, tile.x, tile.y, rotation);`
	# -- the getLink discovery
	# `public @Nullable UnitAssemblerBuild getLink(Team team, int x, int y, int rotation){`
	# `var results = Vars.indexer.getFlagged(team, BlockFlag.unitAssembler).<UnitAssemblerBuild>as();`
	# `return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));`
	# (UnitAssemblerModule.java:65-69) is live since N2358
	# (source_unit_assembler_module_get_link_state over the
	# explicit frame-input candidate list
	# frame["link_candidates"], the tick filling
	# frame["link_candidate"] before this advance); the live
	# team-wide flagged fill still waits, so a tick with no
	# link_candidates input keeps the seeded link_candidate
	# (the getLink result: an assembler link ref dict, or
	# null when nothing fits; default null).
	# `link.updateModules(this);` -- live since N2351: the tick
	# wires it through the unit-factory cell helper (the link
	# cell comes from the {"block", "cell"} frame-input format;
	# a link without a cell skips).
	# `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`
	# `link.yeetPayload(payload);`
	# `payload = null;`
	# -- moduleFits (`public boolean moduleFits(Block other, float ox, float oy, int rotation){`,
	# UnitAssembler.java:338) is live as a pure since N2358
	# (source_unit_assembler_module_fits_state, used by the
	# discovery) but the handoff gate still reads the frame
	# predicate module_fits (default false, the safe
	# no-assembler value) -- wiring the pure into the gate
	# waits for its own slice; wasOccupied (`public boolean wasOccupied = false;`,
	# UnitAssembler.java:328) is an explicit frame predicate (default
	# false); the live evaluation needs the assembler object and defers. acceptPayload
	# is the LINK verdict, stamped live onto frame["accept_payload"]
	# by the tick before the advance (N2314) -- the advance still
	# reads it with the frame.get default false, so the pure keeps
	# its shape (the N2235 frame-stamp precedent). yeetPayload is the assembler-side receive
	# (`public void yeetPayload(Payload payload){`,
	# UnitAssembler.java:688-695, `blocks.add(payload.content(), 1);`),
	# already ported as the N2131 intake state -- the module side
	# only clears its payload and reports handed_off; the wiring
	# that feeds a handed-off payload into the assembler intake
	# waits for its own slice. moveInPayload() is evaluated FIRST
	# (Java && short-circuit), so the payVector / payRotation
	# advance runs on every tick with a payload, even when the rest
	# of the gate fails; this function keeps that order (the
	# _unit_assembler_module_move_in_payload helper,
	# PayloadBlock.java:181-197, rotate=true). delta() is
	# `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924); source_delta is Time.delta in
	# ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds. tile_changes is the frame
	# input (default 1, `public int tileChanges = 1, floorChanges = 1;`,
	# World.java:35) against lastChange -2, so the first tick
	# refreshes (the N2228 RegenProjector precedent). efficiency
	# defaults 0.0, the Java field default (BuildingComp.java:85
	# `transient float efficiency;`). The function does NOT mutate
	# its input frame.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var tile_changes: int = int(frame.get("tile_changes", 1))
	var last_change: int = int(frame.get("last_change", -2))
	var link: Variant = frame.get("link", null)
	var link_refreshed := false
	if last_change != tile_changes:
		last_change = tile_changes
		link_refreshed = true
		link = frame.get("link_candidate", null)
	var payload: Variant = frame.get("payload", null)
	var pay_vector: Vector2 = frame.get("pay_vector", Vector2.ZERO)
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var moved_in := false
	if payload != null:
		var delta: float = source_delta * time_scale
		var rotation_degrees: float = float(int(frame.get("rotation", 0))) * 90.0
		var moved: Dictionary = _unit_assembler_module_move_in_payload(pay_vector, pay_rotation, rotation_degrees, delta)
		pay_vector = moved["pay_vector"]
		pay_rotation = moved["pay_rotation"]
		moved_in = bool(moved["arrived"])
	var handed_off := false
	if moved_in and link != null and bool(frame.get("module_fits", false)) and not bool(frame.get("was_occupied", false)) and bool(frame.get("accept_payload", false)) and efficiency > 0.0:
		payload = null
		handed_off = true
	return {"last_change": last_change, "link": link, "link_refreshed": link_refreshed, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "moved_in": moved_in, "payload": payload, "handed_off": handed_off}

@warning_ignore("unused_parameter")
static func source_unit_assembler_module_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the unit-assembler-module tick wiring every
	# tick (UnitAssemblerModuleBuild.updateTile(), UnitAssemblerModule.java:132,
	# gates on the forward gate (UnitAssemblerModule.java:138, `if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){`), so the forward follows the folded efficiency; no placed-buildings driver ticks UnitAssemblerModule blocks, so this driver is the placed-unit-assembler-module tick): each placed UnitAssemblerModule build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_unit_assembler_module_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_unit_assembler_module_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_unit_assembler_module_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# N2348: the tier stamp -- tier() (UnitAssemblerModule.java:85-86)
		# returns the block's tier field (`public int tier = 1;`,
		# UnitAssemblerModule.java:22); the catalog carries no tier key
		# for basic-assembler-module and the def sets no tier
		# (Blocks.java:6566-6573), so the driver passes the class
		# default explicitly (the N2333 acceptMultipleItems
		# precedent). tier is a static class field, not
		# consumption-gated, so the stamp runs every tick whether
		# or not the module is enabled, and overwrites any seeded
		# frame input. The checkTier pure is live since N2133
		# (source_unit_factory_assembler_check_tier_state, reading
		# the assembler frame modules list); the cross-building
		# wiring feeding stamped module tiers into that list is
		# live since N2351 (the tick wires link events after
		# the advance below).
		var tier_state: Dictionary = source_unit_assembler_module_tier_state(block_id, SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT)
		frame["tier"] = tier_state["tier"]
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a unit-assembler-module with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the forward gate (UnitAssemblerModule.java:138)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a unit-assembler-module does not take the early return. A unit-assembler-module with no power consumer is untouched: the tick models no other consumers yet (the module has no liquid consumer), and there is no shouldConsume override (BuildingComp.java:755, `public boolean shouldConsume(){`), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_unit_assembler_module_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2248: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled module's efficiency
		# is zeroed by the disabled early return
		# (BuildingComp.java:1954-1957) and the handoff gate
		# (UnitAssemblerModule.java:138, `efficiency > 0`) never
		# fires. The port keeps the enabled gate below as a
		# pragmatic choice (the N2195 coordinator-fix precedent):
		# the driver skips the consumption fold when disabled, so
		# the frame efficiency goes stale and running the advance
		# on it would hand payloads off from a stale efficiency.
		# The driver-wide disabled-early-return slice (deferred
		# in the N2228 register) removes this gate for all
		# families. super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The rotation
		# reads live from the sprite rotation meta
		# (SourceBlockGeometry.SOURCE_BUILD_ROTATION_META_KEY,
		# default 0) -- the moveInPayload rotation target is
		# rotdeg() = rotation * 90 (BuildingComp.java:582-584).
		# The advance reads the link candidate (filled by
		# the N2358 discovery when frame["link_candidates"]
		# is supplied, else the seeded candidate -- see the
		# N2358 fill below) + the module_fits / was_occupied
		# predicates + tile_changes as frame inputs (the
		# N2248 live-fill deferral): a live module with no
		# fill refreshes once (lastChange -2 vs tileChanges
		# 1), reads link null, and never hands off.
		# accept_payload is NOT a frame input
		# anymore: the N2314 stamp below feeds the live link
		# verdict into the gate before the advance runs.
		# N2314: the LINK verdict evaluates BEFORE the advance
		# and stamps frame["accept_payload"] from it (the
		# frame-stamp + frame-fallback pattern, the N2235
		# precedent) -- the advance keeps reading
		# frame["accept_payload"], its signature and call site
		# unchanged. The verdict feeds the gate because Java
		# is `link.acceptPayload(this, payload)`
		# (UnitAssemblerModule.java:138), the ASSEMBLER's gate
		# (UnitAssembler.java:722-727) -- NOT the module's own
		# gate (UnitAssemblerModule.java:110-111), which does
		# NOT drive the handoff. The verdict evaluates from
		# frame-supplied plan/blocks/payload inputs (the live
		# fill waits for its own slice -- see DEFERRED): the
		# offered payload descriptor (default {} -- no payload
		# offered, so the link verdict is false), the assembler
		# dict (default {} -- no link assembler state), the
		# plan requirements (default [] -- no plan), and the
		# unit-cost multiplier (default 1.0, Rules.java:275-277,
		# both factors default 1f). The source IS the module
		# itself (the module gate calls link.acceptPayload(this,
		# payload), UnitAssemblerModule.java:111), so
		# source_is_module is true. The stamp OVERWRITES any
		# seeded frame input: a stale accept_payload seed no
		# longer drives the gate. The verdict runs whether or
		# not the module is enabled (acceptPayload has no
		# enabled check in Java) -- the advance below still
		# runs only when enabled.
		var offered_payload: Dictionary = frame.get("offered_payload", {})
		var assembler_state: Dictionary = frame.get("assembler", {})
		var plan_requirements: Array = frame.get("plan_requirements", [])
		var unit_cost: float = float(frame.get("unit_cost", 1.0))
		var link_verdict: Dictionary = source_unit_assembler_accept_payload_state(offered_payload, assembler_state, plan_requirements, unit_cost, true)
		frame["link_accepts_payload"] = link_verdict["accepts"]
		frame["accept_payload"] = link_verdict["accepts"]
		if bool(frame.get("enabled", true)):
			var previous_link: Variant = frame.get("link", null)
			frame["rotation"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
			# N2358: the getLink discovery -- findLink
			# (UnitAssemblerModule.java:75-83) refreshes the
			# link from getLink (UnitAssemblerModule.java:65-69),
			# so the tick fills frame["link_candidate"] from
			# the discovery BEFORE the N2248 advance reads
			# it -- but ONLY when frame["link_candidates"] is
			# supplied (the N2352 facing_tiles precedent): a
			# tick with no candidate list keeps the seeded
			# link_candidate, so the N2248/N2351 proofs
			# (which seed link_candidate directly and run
			# the live tick) stay green. The candidate list
			# is an EXPLICIT frame input (the port has no
			# team-wide flagged-buildings index -- the live
			# fill waits for its own slice, see DEFERRED).
			# The module world position comes from the sprite
			# origin cell through tile_drawx/y_state with
			# the Block offset formula (Block.java:761/:1429,
			# `offset = ((size + 1) % 2) * tilesize / 2f;` --
			# 0 for the size-5 module) and the catalog size
			# (the BaseShield precedent); the rotation is
			# the frame rotation stamped just above; the
			# tilesize is source_world_defaults.TILESIZE
			# (Vars.java:135,
			# `public static final int tilesize = 8;`).
			if frame.has("link_candidates"):
				var discovery_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
				var discovery_size: int = int(block.properties.get("size", 1))
				var discovery_offset: float = float((discovery_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
				var discovery_module: Dictionary = {"x": source_block_geometry.tile_drawx_state(discovery_cell.x, source_world_defaults.TILESIZE, discovery_offset), "y": source_block_geometry.tile_drawy_state(discovery_cell.y, source_world_defaults.TILESIZE, discovery_offset), "size": discovery_size, "rotation": int(frame.get("rotation", 0))}
				var discovery_candidates: Array = frame.get("link_candidates", [])
				var discovered: Dictionary = source_unit_assembler_module_get_link_state(discovery_module, discovery_candidates, source_world_defaults.TILESIZE)
				frame["link_candidate"] = discovered.get("link", null)
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)
			frame["last_change"] = advanced["last_change"]
			frame["link"] = advanced["link"]
			frame["link_refreshed"] = advanced["link_refreshed"]
			frame["pay_vector"] = advanced["pay_vector"]
			frame["pay_rotation"] = advanced["pay_rotation"]
			frame["moved_in"] = advanced["moved_in"]
			frame["payload"] = advanced["payload"]
			frame["handed_off"] = advanced["handed_off"]
			# N2351: the checkTier wiring -- findLink
			# (UnitAssemblerModule.java:75-83) removes this
			# module from the OLD link (`link.removeModule(this);`)
			# and adds it to the NEW one
			# (`link.updateModules(this);`), so on a link
			# refresh the tick applies the same two events
			# to the assembler frames through the
			# unit-factory cell helper. The link frame-input
			# format is the N2351 coordinator contract:
			# {"block", "cell": Vector2i} -- cell is the
			# assembler origin cell; a link without a cell
			# skips that half (the defined pre-discovery
			# behavior -- the old proofs keep block-only
			# links). The tier is the module's stamped tier
			# (N2348, above). The previous link is captured
			# before the advance overwrites frame["link"].
			if bool(advanced.get("link_refreshed", false)):
				var module_tier: int = int(frame.get("tier", SOURCE_UNIT_ASSEMBLER_MODULE_TIER_DEFAULT))
				if previous_link is Dictionary and (previous_link as Dictionary).has("cell") and (previous_link as Dictionary).get("cell") is Vector2i:
					source_unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(game, (previous_link as Dictionary).get("cell"), module_tier, "remove")
				var refreshed_link: Variant = advanced.get("link", null)
				if refreshed_link is Dictionary and (refreshed_link as Dictionary).has("cell") and (refreshed_link as Dictionary).get("cell") is Vector2i:
					source_unit_factory_build_state.source_unit_factory_modules_event_for_cell_state(game, (refreshed_link as Dictionary).get("cell"), module_tier, "add")
		# N2299: the module verdict evaluates AFTER the advance
		# so it reads the post-advance link / payload (a
		# handed-off payload clears before the verdict reads
		# it), from the link verdict computed above (the
		# module gate calls link.acceptPayload(this, payload),
		# UnitAssemblerModule.java:111); no link means the
		# module verdict is false. It runs whether or not the
		# module is enabled (acceptPayload has no enabled
		# check in Java). The module verdict is EXPOSED on the
		# frame only -- it does NOT drive the handoff gate
		# (N2314: the gate reads the LINK verdict).
		var module_verdict: Dictionary = source_unit_assembler_module_accept_payload_state(frame.get("link", null) != null, frame.get("payload", null) != null, bool(link_verdict.get("accepts", false)))
		frame["accepts_payload"] = module_verdict["accepts"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
