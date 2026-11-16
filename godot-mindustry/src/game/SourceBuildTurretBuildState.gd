extends RefCounted
class_name SourceBuildTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The BuildTurret implementation (BuildTurret.java:27, `public class BuildTurret extends BaseTurret{`): build-tower (consumePower 3f, Blocks.java:2005, `consumePower(3f);`; size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60, Category.effect, Blocks.java:1997-2006). BuildTurret extends BaseTurret, NOT a TurretBuild -- SourceTurretBuildState.gd says so explicitly ("RepairTurret extends Block and BuildTurret extends BaseTurret, so none of them is a TurretBuild"), so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_build_turret_building", the radar precedent), and this slice adds the build-turret key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceBuildTurret* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the BuildTurretBuild.updateTile only scales the builder unit by potentialEfficiency (BuildTurret.java:136-137, `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);` / `unit.speedMultiplier(potentialEfficiency * timeScale);`) -- so a tower that cannot draw its 3f never builds, as if power.status were 1.0. Liquid care: the tower also consumes nitrogen (`consumeLiquid(Liquids.nitrogen, 3f / 60f);`, Blocks.java:2006) -- the row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the LIQUID side is live since N2251 (source_build_turret_liquid_consumer_row_state folds the nitrogen row and removes it on the second pass). Suppression rows: `suppressable = true;` (BuildTurret.java:46); `if(checkSuppression()){` (:132) zeroes `efficiency = potentialEfficiency = 0f;` (:133); suppression state waits for its own slice.
const SOURCE_BUILD_TURRET_BUILD_IMPLEMENTATIONS := ["BuildTurret"]
const SOURCE_BUILD_TURRET_BUILDING_META_KEY := "source_build_turret_building"
# The warmup lerp progress is the Java 0.1f (BuildTurret.java:139,
# `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`).
const SOURCE_BUILD_TURRET_WARMUP_LERP_PROGRESS := 0.1
# The initial rotation is the Java 90 -- BOTH the BaseTurretBuild field
# default (`public float rotation = 90;`, BaseTurret.java:114) and the
# unit init block (`unit.rotation(90f);`, BuildTurret.java:99-101) -- so
# a fresh frame and a fresh unit agree on the facing.
const SOURCE_BUILD_TURRET_INITIAL_ROTATION := 90.0
# Single def -- build-tower only: range 200f (Blocks.java:2001, `range = 200f;`).
const SOURCE_BUILD_TURRET_RANGE := 200.0
# Single def -- build-tower only: buildSpeed 1.5f (Blocks.java:2003,
# `buildSpeed = 1.5f;`) -- the UnitType buildSpeed the builder unit
# reads (`if(type.buildSpeed <= 0f) return;`,
# BuilderComp.java:77; `unitType.buildSpeed = buildSpeed;`,
# BuildTurret.java:77).
const SOURCE_BUILD_TURRET_BUILD_SPEED := 1.5
# Single def -- build-tower only: the required liquid consumer
# is nitrogen 3f/60f per frame (Blocks.java:2006,
# `consumeLiquid(Liquids.nitrogen, 3f / 60f);`).
const SOURCE_BUILD_TURRET_LIQUID := "nitrogen"
const SOURCE_BUILD_TURRET_LIQUID_AMOUNT := 3.0 / 60.0
# Single def -- build-tower only: the effective elevation is 1.5 --
# the field defaults to -1f (`public float elevation = -1f;`,
# BuildTurret.java:38) and init() lifts it (`if(elevation < 0)
# elevation = size / 2f;`, BuildTurret.java:53), so the size-3
# build-tower (Blocks.java:2002, `size = 3;`) shifts its shadow by
# 3 / 2f = 1.5. The draw pure takes elevation as a param; this
# constant is the build-tower value the caller supplies.
const SOURCE_BUILD_TURRET_ELEVATION := 1.5
# Single def -- build-tower only: the heatColor alpha is 0.9 --
# `public Color heatColor = Pal.accent.cpy().a(0.9f);`
# (BuildTurret.java:39), no def override (Blocks.java:1997-2006
# sets neither elevation nor heatColor). The additive body
# multiplies the passed alpha by the color alpha
# (`Draw.color(color, alpha * color.a);`, Drawf.java:186), so the
# effective glow alpha is warmup * 0.9.
const SOURCE_BUILD_TURRET_HEAT_COLOR_ALPHA := 0.9

static func _is_build_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_BUILD_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_build_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The build-turret tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (BuildTurret.java:27, `public class BuildTurret extends
	# BaseTurret{`; BuildTurretBuild, BuildTurret.java:92,
	# `public class BuildTurretBuild extends BaseTurretBuild
	# implements ControlBlock, RotBlock{`), team_id and
	# rules_state are what Java reads as b.team and
	# state.rules, and cheating is the team's live TeamRule
	# value (TeamComp.cheating(), TeamComp.java:17-19 `return
	# team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's build tower skips consumption like
	# Java's updateConsumption (BuildingComp.java:1944-1945,
	# "everything is valid when cheating"). A team with no
	# rule keeps the false default (Rules.java:328
	# TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this build tower (N2125); the tick preserves a disabled
	# build tower instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"plans": [], "heal_suppressed": false, "liquids": {}, "rotation": SOURCE_BUILD_TURRET_INITIAL_ROTATION, "warmup": 0.0, "unit_look_angle": SOURCE_BUILD_TURRET_INITIAL_ROTATION, "build_speed_multiplier": 0.0, "speed_multiplier": 0.0, "following": null, "last_plan": null, "build_counter": 0.0}

static func source_build_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the build-turret frame meta key
	# ("source_build_turret_building"). A BuildTurret sprite gets a
	# frame bound with the plans key defaulting to [] (the builder
	# unit's plan queue starts empty) and the heal_suppressed key
	# defaulting to false (the isHealSuppressed() mirror,
	# BuildingComp.java:487-489), plus the N2243 advance keys:
	# rotation 90.0 (the BaseTurretBuild field default,
	# BaseTurret.java:114), warmup 0.0, unit_look_angle 90.0 (the
	# unit's initial facing, before any lookAt), and both
	# multipliers 0.0, plus the following key defaulting to
	# null and the last_plan key defaulting to null (N2244)
	# and the build_counter key defaulting to 0.0 (N2272, the
	# `private transient float buildCounter;` mirror,
	# BuilderComp.java:35); the
	# live-loop tick fills its other keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_build_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BUILD_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BUILD_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BUILD_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_build_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# BuildTurretBuild overrides shouldConsume (BuildTurret.java:229, `public boolean shouldConsume(){` with `return unit.plans().size > 0 && !isHealSuppressed();`, BuildTurret.java:230): TWO conditions -- the builder unit's plan queue must be non-empty AND the building must not be heal-suppressed. The unit is `public BlockUnitc unit = (BlockUnitc)unitType.create(team);` (BuildTurret.java:93) on BuildTurretBuild (`public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{`, BuildTurret.java:92); BuildTurret extends BaseTurret (BuildTurret.java:27, `public class BuildTurret extends BaseTurret{`), so the default (`return enabled;`, BuildingComp.java:755-756) does NOT apply here -- and unlike the RepairTurret gate (N2212) this one has NO `&& enabled` term, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). isHealSuppressed() (BuildingComp.java:487, `public boolean isHealSuppressed(){` with `return block.suppressable && Time.time <= healSuppressionTime;`, BuildingComp.java:488) is set through applyHealSuppression (BuildingComp.java:482, `public void applyHealSuppression(float amount, Color suppressColor){` with `healSuppressionTime = Math.max(healSuppressionTime, Time.time + amount);`, BuildingComp.java:483); BuildTurret has `suppressable = true;` (BuildTurret.java:46), so the second term is live. NOTE: checkSuppression() in updateTile (BuildTurret.java:132, `if(checkSuppression()){` with `efficiency = potentialEfficiency = 0f;`, BuildTurret.java:133) is a DIFFERENT gate -- it zeroes efficiency directly and is NOT part of this slice. The frame carries the plans (frame["plans"], default [] for a frame bound before this slice -- the unit's plan queue starts empty) and the suppression mirror (frame["heal_suppressed"], default false); the plan logic is live (N2244, source_build_turret_plan_logic_state fills frame["plans"] from the pure advance, though the driver passes no live team plans / builders / players yet) and the heal suppression application (BuildingComp.java:482-485) waits for its own slice. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The build-speed advance (BuildTurret.java:136, `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);`) follows the folded efficiency. The single def is build-tower (size 3, range 200f, buildSpeed 1.5f, consumePower 3f, consumeLiquid nitrogen 3f/60f, Blocks.java:1997-2006) -- nitrogen is a second consumer and NOT part of this slice.
	var plans: Variant = frame.get("plans", [])
	if not (plans is Array):
		plans = []
	var heal_suppressed: bool = bool(frame.get("heal_suppressed", false))
	return {"should_consume": plans.size() > 0 and not heal_suppressed, "plan_count": plans.size()}

static func source_build_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a build tower does not take the early return. The tower's power draw is STATIC, not conditional: `consumePower(3f);` (Blocks.java:2005) registers a plain ConsumePower, so the catalog consumePower 3.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The tower's updateTile (BuildTurret.java:121-139, `rotation = unit.rotation();` / `if(unit.activelyBuilding()){` / `unit.lookAt(angleTo(unit.buildPlan()));` / `if(checkSuppression()){` / `efficiency = potentialEfficiency = 0f;` / `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);` / `unit.speedMultiplier(potentialEfficiency * timeScale);` / `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`) scales the builder unit by potentialEfficiency -- and because there is no baseEfficiency-style floor, the tower never builds when the gate fails; the folded efficiency is what the efficiency keys prove, and the plan search / follow / mimic / validate advance is live (N2244).
	# BuildTurretBuild DOES override shouldConsume (BuildTurret.java:229-230, `public boolean shouldConsume(){` / `return unit.plans().size > 0 && !isHealSuppressed();`), and updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The shouldConsume gate is live (N2215) -- the pure gate (source_build_turret_should_consume_state) feeds should_consume to the machinery from the frame plans key (empty before any plan is queued, non-empty once the builder unit has plans) and the heal_suppressed key (the isHealSuppressed() mirror, BuildingComp.java:487-489); the plan logic is live (N2244, source_build_turret_plan_logic_state fills frame["plans"] from the pure advance, though the driver passes no live team plans / builders / players yet) and the suppression application is BuildingComp.java:482-485. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates.
	# The build tower is its own family (BuildTurret.java:27, `public class BuildTurret extends BaseTurret{`; BuildTurretBuild, BuildTurret.java:92, `public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{`), a defense / effect block, NOT a TurretBuild: SourceTurretBuildState.gd excludes it explicitly, and BaseTurretBuild (BaseTurret.java:113, `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`) overrides neither shouldConsume nor updateTile -- the gate and the tick both come from BuildTurretBuild itself. Class fields: `public final int timerTarget = timers++, timerTarget2 = timers++;` (BuildTurret.java:28), `public int targetInterval = 15;` (BuildTurret.java:29), `public float buildSpeed = 1f;` (BuildTurret.java:33), `public float buildBeamOffset = 5f;` (BuildTurret.java:34), `public float elevation = -1f;` (BuildTurret.java:38), `public Color heatColor = Pal.accent.cpy().a(0.9f);` (BuildTurret.java:39); constructor `public BuildTurret(String name){` (BuildTurret.java:41), `group = BlockGroup.turrets;` (BuildTurret.java:43), `sync = false;` (BuildTurret.java:44), `rotateSpeed = 10f;` (BuildTurret.java:45), `suppressable = true;` (BuildTurret.java:46). init lifts the elevation and builds the hidden builder unit type (BuildTurret.java:53, `if(elevation < 0) elevation = size / 2f;` with BuildTurret.java:56, `unitType = new UnitType("turret-unit-" + name){{`). Build fields: `public BlockUnitc unit = (BlockUnitc)unitType.create(team);` (BuildTurret.java:93), `public @Nullable Unit following;` (BuildTurret.java:94), `public @Nullable BlockPlan lastPlan;` (BuildTurret.java:95), `public float warmup;` (BuildTurret.java:96).
	# Single def -- build-tower only (size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60, Blocks.java:1997-2006): `buildTower = new BuildTurret("build-tower"){{` (Blocks.java:1997) with `requirements(Category.effect, with(Items.silicon, 150, Items.oxide, 40, Items.thorium, 60));` (Blocks.java:1998), `outlineColor = Pal.darkOutline;` (Blocks.java:1999), `range = 200f;` (Blocks.java:2001), `size = 3;` (Blocks.java:2002), `buildSpeed = 1.5f;` (Blocks.java:2003), `consumePower(3f);` (Blocks.java:2005) and `consumeLiquid(Liquids.nitrogen, 3f / 60f);` (Blocks.java:2006). No second BuildTurret def exists; there is no family split to manage. The plan search (`}else if(unit.buildPlan() == null && timer(timerTarget, targetInterval)){`, :156; `Queue<BlockPlan> blocks = team.data().plans;`, :157), mimic (`Units.nearby(team, x, y, range, u -> {`, :176), validation (`boolean valid =`, :204) advance is live (N2244); `unit.updateBuildLogic();` (:225) is live since N2272. The draw / write / read / sense rows (BuildTurret.java:232-319) wait for their own slices.
	# Documented limits: (1) power + liquid first pass -- the tower's static power consumer (consumePower 3f, Blocks.java:2005) and its required liquid consumer (consumeLiquid nitrogen 3f/60f, Blocks.java:2006 -- liquid row live (N2251)) are the modeled consumers, so the folded efficiency is the min over the *modeled* consumers (power + nitrogen); the single build-tower def has no other consumers. (2) shouldConsume gate live (N2215) -- BuildTurretBuild overrides shouldConsume (`return unit.plans().size > 0 && !isHealSuppressed();`, BuildTurret.java:229-230); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the pure gate reads the frame plans key (default []) and the heal_suppressed key (default false) and feeds should_consume to the machinery; the plan logic is live (N2244) -- the pure advance fills frame["plans"] (the driver passes no live team plans / builders / players yet), while the heal suppression application (BuildingComp.java:482-485) still waits for its own slice. (3) updateTile sync/warmup advance live (N2243) -- rotation follow / lookAt / suppression zeroing / multipliers / warmup lerp (BuildTurret.java:121-140); plan logic live (N2244) -- plan search / follow / mimic / validate / suicide-plan removal (BuildTurret.java:141-225) run through the pure advance; updateBuildLogic live (N2272) -- build counter + validatePlans + plan selection (BuilderComp.java:76+; placement Call.beginPlace / Call.beginBreak / ConstructBuild :148-222 defers, so the driver runs one plan per tick and consumes the counter only when a plan is selected; the frame inputs core_items / plan_tile_states / update_building / can_build have no live fill yet); the eff fold (BuildTurret.java:136-137) is what the efficiency keys prove. (4) Liquid row live (N2251) -- consumeLiquid nitrogen 3f/60f (Blocks.java:2006) folds through source_build_turret_liquid_consumer_row_state and removes amount * edelta * multiplier on the second pass (ConsumeLiquid.java:37-39); the multiplier is the 1f default (Consume.java:18), the def sets none; the live nitrogen intake (conduit/bridge delivery into the tower) waits for its own slice, so a live tower with no intake reads 0 nitrogen and folds efficiency 0. (5) Suppression zeroing live (N2243) -- checkSuppression() (BuildTurret.java:132-133) zeroes efficiency + potentialEfficiency through the frame heal_suppressed mirror (checkSuppression returns true iff isHealSuppressed, BuildingComp.java:1336-1337; the Fx particle defers); no live fill applies suppression yet (applyHealSuppression, BuildingComp.java:482-485, needs game time + suppression application). (6) Single def -- build-tower only (size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60); per-def stat values wait for their own verification slice. (7) Draw rows live (N2431) -- the draw pure (source_build_turret_draw_state) models draw() (:234-251: base rect + turret-layer shadow/region at rotation - 90, the shadow shifted by the field elevation -- 1.5 for the size-3 build-tower after the init lift -- the glow additive by warmup at Layer.turretHeat with effective alpha warmup * 0.9, and the recorded unit.drawBuilding() call when efficiency > 0). Pure-only: the tick never calls draw -- draw is called by the renderer, and the renderer call site waits for a renderer slice. (8) Sense rows live (N2437) -- the sense pure (source_build_turret_sense_state) models sense() (:281-287: buildX/buildY delegate to the builder unit's sensed plan coordinate, every other sensor falls through to the caller-supplied super.sense value, the BuildingComp switch already modeled by SourceBuildingSenseState) and the senseObject pure (source_build_turret_sense_object_state) models senseObject() (:289-295: building/breaking delegate to the builder unit's sensed plan build, every other sensor falls through to the caller-supplied super.senseObject value). Pure-only: the tick never calls sense/senseObject -- sense is called by logic, and the logic call site waits for a logic-executor slice. Read / write (BuildTurret.java:259-278) wait for their own slices.
	# Source lines (all 136 exact exprs, verified verbatim in upstream at RED):
	# - `return build.power.status;`
	# - `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`
	# - `hasConsumers = consumers.length > 0;`
	# - `public class BuildTurret extends BaseTurret{`
	# - `public final int timerTarget = timers++, timerTarget2 = timers++;`
	# - `public int targetInterval = 15;`
	# - `public float buildSpeed = 1f;`
	# - `public float buildBeamOffset = 5f;`
	# - `public float elevation = -1f;`
	# - `public Color heatColor = Pal.accent.cpy().a(0.9f);`
	# - `public BuildTurret(String name){`
	# - `group = BlockGroup.turrets;`
	# - `sync = false;`
	# - `rotateSpeed = 10f;`
	# - `suppressable = true;`
	# - `public void init(){`
	# - `super.init();`
	# - `if(elevation < 0) elevation = size / 2f;`
	# - `unitType = new UnitType("turret-unit-" + name){{`
	# - `buildBeamOffset = BuildTurret.this.buildBeamOffset;`
	# - `buildRange = BuildTurret.this.range;`
	# - `buildSpeed = BuildTurret.this.buildSpeed;`
	# - `constructor = BlockUnitUnit::create;`
	# - `public void afterPatch(){`
	# - `super.afterPatch();`
	# - `unitType.rotateSpeed = rotateSpeed;`
	# - `unitType.buildBeamOffset = buildBeamOffset;`
	# - `unitType.buildRange = range;`
	# - `unitType.buildSpeed = buildSpeed;`
	# - `public void setStats(){`
	# - `super.setStats();`
	# - `stats.addPercent(Stat.buildSpeed, buildSpeed);`
	# - `public TextureRegion[] icons(){`
	# - `return new TextureRegion[]{baseRegion, region};`
	# - `public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{`
	# - `public BlockUnitc unit = (BlockUnitc)unitType.create(team);`
	# - `public @Nullable Unit following;`
	# - `public @Nullable BlockPlan lastPlan;`
	# - `public float warmup;`
	# - `unit.rotation(90f);`
	# - `public boolean canControl(){`
	# - `return true;`
	# - `public float buildRotation(){`
	# - `return unit.rotation();`
	# - `public Unit unit(){`
	# - `unit.tile(this);`
	# - `unit.team(team);`
	# - `public void updateTile(){`
	# - `rotation = unit.rotation();`
	# - `if(unit.activelyBuilding()){`
	# - `unit.lookAt(angleTo(unit.buildPlan()));`
	# - `if(checkSuppression()){`
	# - `efficiency = potentialEfficiency = 0f;`
	# - `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);`
	# - `unit.speedMultiplier(potentialEfficiency * timeScale);`
	# - `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`
	# - `if(!isControlled()){`
	# - `unit.updateBuilding(true);`
	# - `if(following != null){`
	# - `if(!following.isValid() || !following.activelyBuilding()){`
	# - `unit.plans().clear();`
	# - `unit.plans().addFirst(following.buildPlan());`
	# - `lastPlan = null;`
	# - `}else if(unit.buildPlan() == null && timer(timerTarget, targetInterval)){`
	# - `Queue<BlockPlan> blocks = team.data().plans;`
	# - `if(within(block.x * tilesize, block.y * tilesize, range)){`
	# - `unit.addBuild(new BuildPlan(block.x, block.y, block.rotation, block.block, block.config));`
	# - `blocks.addLast(blocks.removeIndex(i));`
	# - `lastPlan = block;`
	# - `Units.nearby(team, x, y, range, u -> {`
	# - `if(u.canBuild() && u.activelyBuilding()){`
	# - `BuildPlan plan = u.buildPlan();`
	# - `Building build = world.build(plan.x, plan.y);`
	# - `if(build instanceof ConstructBuild && within(build, range)){`
	# - `following = u;`
	# - `}else if(unit.buildPlan() != null){`
	# - `BuildPlan req = unit.buildPlan();`
	# - `if(!req.breaking && timer.get(timerTarget2, 30f)){`
	# - `for(Player player : team.data().players){`
	# - `if(player.isBuilder() && player.unit().activelyBuilding() && player.unit().buildPlan().samePos(req) && player.unit().buildPlan().breaking){`
	# - `unit.plans().removeFirst();`
	# - `boolean valid =`
	# - `!(lastPlan != null && lastPlan.removed) &&`
	# - `((req.tile() != null && req.tile().build instanceof ConstructBuild cons && cons.current == req.block) ||`
	# - `Build.validBreak(unit.team(), req.x, req.y) :`
	# - `Build.validPlace(req.block, unit.team(), req.x, req.y, req.rotation)));`
	# - `if(!valid){`
	# - `unit.plans().remove(b -> b.build() == this);`
	# - `unit.updateBuildLogic();`
	# - `public boolean shouldConsume(){`
	# - `return unit.plans().size > 0 && !isHealSuppressed();`
	# - `public void draw(){`
	# - `Draw.rect(baseRegion, x, y);`
	# - `Draw.color();`
	# - `Draw.z(Layer.turret);`
	# - `Drawf.shadow(region, x - elevation, y - elevation, rotation - 90);`
	# - `Draw.rect(region, x, y, rotation - 90);`
	# - `if(glowRegion.found()){`
	# - `Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);`
	# - `if(efficiency > 0){`
	# - `unit.drawBuilding();`
	# - `public float warmup(){`
	# - `return warmup;`
	# - `public void write(Writes write){`
	# - `super.write(write);`
	# - `write.f(rotation);`
	# - `TypeIO.writePlans(write, unit.plans().toArray(BuildPlan.class));`
	# - `public void read(Reads read, byte revision){`
	# - `super.read(read, revision);`
	# - `rotation = read.f();`
	# - `unit.rotation(rotation);`
	# - `var reqs = TypeIO.readPlans(read);`
	# - `public double sense(LAccess sensor){`
	# - `case buildX, buildY -> unit.sense(sensor);`
	# - `default -> super.sense(sensor);`
	# - `public Object senseObject(LAccess sensor){`
	# - `case building, breaking -> unit.senseObject(sensor);`
	# - `default -> super.senseObject(sensor);`
	# - `public class BaseTurret extends Block{`
	# - `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
	# - `buildTower = new BuildTurret("build-tower"){{`
	# - `requirements(Category.effect, with(Items.silicon, 150, Items.oxide, 40, Items.thorium, 60));`
	# - `outlineColor = Pal.darkOutline;`
	# - `range = 200f;`
	# - `size = 3;`
	# - `buildSpeed = 1.5f;`
	# - `consumePower(3f);`
	# - `consumeLiquid(Liquids.nitrogen, 3f / 60f);`
	# - `return enabled;`
	# - `public boolean canConsume(){`
	# - `return potentialEfficiency > 0;`
	# - `boolean update = shouldConsume() && productionValid();`
	# - `if(!update){`
	# - `return efficiency * delta();`
	# - `for(var cons : block.nonOptionalConsumers){`
	# - `minEfficiency = Math.min(minEfficiency, result);`
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_build_turret_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
	# `float ed = build.edelta() * build.efficiencyScale();` /
	# `if(ed <= 0.00000001f) return 0f;` / `//there can be
	# more liquid than necessary, so cap at 1` / `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`): the required liquid
	# consumer's efficiency is the held liquid over the
	# required amount, capped at 1f, and the first pass folds
	# it into the min efficiency (BuildingComp.java:1969-1976,
	# `for(var cons : block.nonOptionalConsumers){` /
	# `minEfficiency = Math.min(minEfficiency, result);`).
	# In the first pass efficiency is assumed 1f
	# (`//assume efficiency is 1 for the calculations below`,
	# BuildingComp.java:1964), so edelta is source_delta *
	# time_scale (delta() is `return Time.delta * timeScale;`,
	# BuildingComp.java:1923; edelta() is `return efficiency *
	# delta();`, BuildingComp.java:1928). The liquid amount
	# reads through the shared liquid module helper
	# (SourceLiquidModuleState.source_get_state, reused
	# through a preload, NOT re-implemented) over the frame
	# liquids key (the Building.liquids LiquidModule dict,
	# default {} for a frame bound before this slice), with
	# the Fracker guard (the store has a "liquids" key and
	# the id is in bounds) -- a missing store reads 0.0 like
	# Java's liquids.get (`return liquids[liquid.id];`,
	# LiquidModule.java:103). The multiplier defaults to 1f
	# (`public Floatf<Building> multiplier = b -> 1f;`,
	# Consume.java:18) and the build-tower def sets none
	# (`consumeLiquid(Liquids.nitrogen, 3f / 60f);`,
	# Blocks.java:2006 -- a plain call, no multiplier). A
	# block with no liquid consumer contributes no row. The
	# row shape mirrors the power row, with is_power false:
	# the shared fold sets shouldConsumePower=false when a
	# non-power row reads <= 1e-7 (BuildingComp.java:1972,
	# `if(cons != block.consPower && result <= 0.0000001f){`
	# / `shouldConsumePower = false;`), so a nitrogen-starved
	# tower stops drawing power too. The amount is PER FRAME,
	# not per second: the def writes 3f/60f, i.e. 3 nitrogen
	# per second (the driver passes the
	# SOURCE_BUILD_TURRET_LIQUID_AMOUNT constant, 3.0 /
	# 60.0). Single def -- build-tower only (Blocks.java:
	# 1997-2006): no per-def amount split (unlike the
	# Separator, N2252) and no absent-row def (unlike the
	# LaunchPad, N2253), though the pure function still takes
	# has_liquid_consumer so the row shape mirrors the power
	# row. The second-pass removal (ConsumeLiquid.update,
	# ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`,
	# only when `if(update && efficiency > 0){`,
	# BuildingComp.java:1999-2003) is the driver's job, with
	# the edelta from the FOLDED efficiency.
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	var result: float = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_build_turret_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance part 1, sync + warmup
	# (BuildTurretBuild.updateTile(), BuildTurret.java:121-140):
	# `unit.tile(this);`
	# (BuildTurret.java:122) and `unit.team(team);`
	# (BuildTurret.java:123) have no port effect -- the port has
	# no Unit object to sync, the frame inputs ARE the unit's
	# state for this building (`public BlockUnitc unit = (BlockUnitc)unitType.create(team);`,
	# BuildTurret.java:93). `rotation = unit.rotation();`
	# (BuildTurret.java:126) syncs the facing;
	# `if(unit.activelyBuilding()){`
	# (BuildTurret.java:128) with
	# `unit.lookAt(angleTo(unit.buildPlan()));`
	# (BuildTurret.java:129) turns the unit toward its plan;
	# `if(checkSuppression()){`
	# (BuildTurret.java:132) with
	# `efficiency = potentialEfficiency = 0f;`
	# (BuildTurret.java:133) zeroes both efficiencies;
	# `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);`
	# (BuildTurret.java:136) and
	# `unit.speedMultiplier(potentialEfficiency * timeScale);`
	# (BuildTurret.java:137) scale the unit;
	# `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`
	# (BuildTurret.java:139) lerps the warmup (`public float warmup;`,
	# BuildTurret.java:96). Java order matters: rotation is read
	# BEFORE the lookAt (:126 precedes :128-130), so this tick's
	# rotation is the pre-lookAt unit rotation and the lookAt
	# only shows up as unit_look_angle (the unit's facing next
	# tick); the warmup reads efficiency AFTER the suppression
	# zeroing (:139 after :133), so a suppressed tower's warmup
	# decays toward 0 even while actively building.
	# checkSuppression() is `public boolean checkSuppression(){`
	# (BuildingComp.java:1336) with `if(isHealSuppressed()){`
	# (BuildingComp.java:1337) -- true iff isHealSuppressed()
	# (`return block.suppressable && Time.time <= healSuppressionTime;`,
	# BuildingComp.java:488), so the advance reads the frame
	# heal_suppressed mirror (default false, the N2215 gate key
	# -- NOT a new `suppressed` synonym, the N2228
	# coordinator-fix precedent); the Fx particle inside
	# checkSuppression defers (presentation). The unit-state
	# inputs arrive as frame inputs with Java-faithful defaults:
	# unit_rotation 90.0 (`unit.rotation(90f);`, the init block,
	# BuildTurret.java:99-101), actively_building false,
	# build_plan_angle 0.0 (the angleTo(plan) input); the live
	# unit-state fill waits for its own slice (no live Unit
	# object behind the frame inputs). potential_efficiency
	# defaults to the folded efficiency
	# (`transient float potentialEfficiency;`,
	# BuildingComp.java:89, assigned `potentialEfficiency = efficiency;`,
	# BuildingComp.java:1989, the N2227 precedent);
	# apply_update_consumption_state stamps the live value after
	# the fold. The rotation field default is
	# `public float rotation = 90;` (BaseTurret.java:114), the
	# same 90 as the unit init block. The lerp reuses the shared
	# SourceMathState.source_lerp_delta, which already
	# implements lerp(from, to, clamp(progress * Time.delta))
	# exactly (arc Mathf.java:430-432, the N2191 accelerator
	# precedent) with the UNSCALED Time.delta -- only the
	# multipliers use the scaled timeScale. source_delta is
	# Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26), never raw seconds.
	# isControlled() is NOT read here -- the controlled branch
	# (:141/:223-225) and the whole plan logic (:141-231:
	# follower validation, plan search, mimic, plan validation,
	# break-plan discard, suicide-plan removal) belong to N2244,
	# and `unit.updateBuildLogic();` (:225) is live since N2272.
	var unit_rotation: float = float(frame.get("unit_rotation", SOURCE_BUILD_TURRET_INITIAL_ROTATION))
	var actively_building: bool = bool(frame.get("actively_building", false))
	var build_plan_angle: float = float(frame.get("build_plan_angle", 0.0))
	var heal_suppressed: bool = bool(frame.get("heal_suppressed", false))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", efficiency))
	var warmup: float = float(frame.get("warmup", 0.0))
	var rotation: float = unit_rotation
	var unit_look_angle: float = build_plan_angle if actively_building else unit_rotation
	var efficiency_after: float = 0.0 if heal_suppressed else efficiency
	var potential_after: float = 0.0 if heal_suppressed else potential_efficiency
	var build_speed_multiplier: float = potential_after * time_scale
	var speed_multiplier: float = potential_after * time_scale
	var warmup_target: float = efficiency_after if actively_building else 0.0
	var warmup_after: float = source_math_state.source_lerp_delta(warmup, warmup_target, SOURCE_BUILD_TURRET_WARMUP_LERP_PROGRESS, source_delta)
	return {"rotation": rotation, "unit_look_angle": unit_look_angle, "efficiency": efficiency_after, "potential_efficiency": potential_after, "build_speed_multiplier": build_speed_multiplier, "speed_multiplier": speed_multiplier, "warmup": warmup_after}

static func source_build_turret_plan_logic_state(frame: Dictionary, controlled: bool, search_ready: bool, break_check_ready: bool, tower_x: float, tower_y: float, range_value: float, team_plans: Array, nearby_builders: Array, players: Array, req_construct_match: bool, req_valid_place_or_break: bool) -> Dictionary:
	# The BuildTurret plan logic -- plan logic live (N2244): the
	# plan-logic half of BuildTurretBuild.updateTile()
	# (BuildTurret.java:141-225). The sync/warmup half
	# (BuildTurret.java:121-140, rotation follow / lookAt /
	# suppression zeroing / multipliers / warmup lerp) is N2243
	# -- this function sits AFTER the N2243 pure function in
	# Java order (merged at integration; the N2243 function
	# precedes it). Autonomous
	# (`if(!isControlled()){`, :141; `unit.updateBuilding(true);`,
	# :142, a flag, no logic): follower validation (:144-155,
	# `if(following != null){` with
	# `if(!following.isValid() || !following.activelyBuilding()){`
	# clearing following + plans, else plans =
	# `unit.plans().addFirst(following.buildPlan());` and
	# `lastPlan = null;`); plan search (:156-173,
	# `}else if(unit.buildPlan() == null && timer(timerTarget,
	# targetInterval)){` with `public int targetInterval = 15;`
	# (:29) as the explicit search_ready input,
	# `Queue<BlockPlan> blocks = team.data().plans;`,
	# `if(within(block.x * tilesize, block.y * tilesize, range)){`
	# with `public static final int tilesize = 8;` (Vars.java:135)
	# and range 200f (Blocks.java:2001, `range = 200f;`),
	# `unit.addBuild(new BuildPlan(block.x, block.y, block.rotation,
	# block.block, block.config));`,
	# `blocks.addLast(blocks.removeIndex(i));` rotating the picked
	# plan to the tail, `lastPlan = block;`); mimic (:174-188,
	# `Units.nearby(team, x, y, range, u -> {`,
	# `if(u.canBuild() && u.activelyBuilding()){`,
	# `BuildPlan plan = u.buildPlan();`,
	# `Building build = world.build(plan.x, plan.y);`,
	# `if(build instanceof ConstructBuild && within(build, range)){`,
	# `following = u;`); validation (:189-216,
	# `}else if(unit.buildPlan() != null){`,
	# `BuildPlan req = unit.buildPlan();`,
	# `if(!req.breaking && timer.get(timerTarget2, 30f)){` as the
	# explicit break_check_ready input,
	# `for(Player player : team.data().players){` with
	# `if(player.isBuilder() && player.unit().activelyBuilding() &&
	# player.unit().buildPlan().samePos(req) &&
	# player.unit().buildPlan().breaking){` discarding the first
	# plan AND the matching team plan
	# (`team.data().plans.remove(p -> p.x == req.x && p.y == req.y);`)
	# with an early `return;` that skips the suicide removal that
	# tick, `boolean valid =` with
	# `!(lastPlan != null && lastPlan.removed) &&` and the
	# ConstructBuild / validBreak / validPlace disjunction
	# (`((req.tile() != null && req.tile().build instanceof
	# ConstructBuild cons && cons.current == req.block) ||`,
	# `Build.validBreak(unit.team(), req.x, req.y) :`,
	# `Build.validPlace(req.block, unit.team(), req.x, req.y,
	# req.rotation)));`), `if(!valid){` discarding the first plan
	# (`unit.plans().removeFirst();`, `lastPlan = null;`));
	# controlled (`}else{ //is being controlled, forget everything`,
	# :217-220, following = lastPlan = null); suicide-plan removal
	# (:223, `unit.plans().remove(b -> b.build() == this);`,
	# BuildPlan.build() is `return world.build(x, y);`,
	# BuildPlan.java:165-167, `public @Nullable Building build(){`).
	# `unit.updateBuildLogic();` (:225, BuilderComp.java:76+,
	# `public void updateBuildLogic(){`) is live since N2272 --
	# the driver calls it after this function, in Java order. buildPlan() is the queue
	# head (`return plans.size == 0 ? null : plans.first();`,
	# BuilderComp.java:313-315). within is the STRICT
	# squared-distance check (`Mathf.dst2(getX(), getY(), x, y) <
	# dst*dst`, Arc Position.java:44-46). BlockPlan.removed is
	# `public boolean removed;` (Teams.java:497) on
	# `public static class BlockPlan{` (Teams.java:492); samePos is
	# x/y equality (`return x == other.x && y == other.y;`,
	# BuildPlan.java:83-85). Explicit inputs: the port has no Unit
	# object (following is a frame dict with id / valid /
	# actively_building / first_plan, or null), no timer infra
	# (search_ready / break_check_ready), no team-plan list /
	# nearby-unit query / player list (team_plans /
	# nearby_builders / players), no Build API (valid_place per
	# team plan, req_valid_place_or_break for the current
	# request), no tile lookup (req_construct_match), and no
	# world.build lookup (build_is_self per plan). The frame
	# carries plans (default []), following (default null, the
	# `public @Nullable Unit following;` mirror, BuildTurret.java:94)
	# and last_plan (default null, the `public @Nullable BlockPlan
	# lastPlan;` mirror, BuildTurret.java:95). addBuild dedupes by
	# position (BuilderComp.java:277-295, `void addBuild(BuildPlan
	# place){`) but the search branch only runs with an empty queue,
	# so no dedupe can trigger there.
	team_plans = team_plans.duplicate()
	var plans: Array = []
	var frame_plans: Variant = frame.get("plans", [])
	if frame_plans is Array:
		plans = (frame_plans as Array).duplicate()
	var following: Variant = frame.get("following", null)
	var last_plan: Variant = frame.get("last_plan", null)
	var branch := "idle"
	var plan_discarded := false
	if not controlled:
		if following != null:
			var follower: Dictionary = following if following is Dictionary else {}
			if not bool(follower.get("valid", false)) or not bool(follower.get("actively_building", false)):
				following = null
				plans = []
				branch = "follower_invalid"
			else:
				plans = []
				var first_plan: Variant = follower.get("first_plan", null)
				if first_plan != null:
					plans.append(first_plan)
				last_plan = null
				branch = "follower_valid"
		elif plans.is_empty() and search_ready:
			var range_sq: float = range_value * range_value
			var picked_index := -1
			for i in team_plans.size():
				var candidate: Variant = team_plans[i]
				if not (candidate is Dictionary):
					continue
				var plan_x: float = float(candidate.get("x", 0)) * 8.0
				var plan_y: float = float(candidate.get("y", 0)) * 8.0
				var dx: float = plan_x - tower_x
				var dy: float = plan_y - tower_y
				if dx * dx + dy * dy < range_sq and bool(candidate.get("valid_place", false)):
					picked_index = i
					break
			if picked_index >= 0:
				var picked: Dictionary = team_plans[picked_index]
				plans.append({"x": picked.get("x", 0), "y": picked.get("y", 0), "rotation": picked.get("rotation", 0), "block": picked.get("block", ""), "config": picked.get("config", null), "breaking": false, "build_is_self": false})
				team_plans.remove_at(picked_index)
				team_plans.append(picked)
				last_plan = picked
				branch = "search_found"
			if plans.is_empty():
				following = null
				for builder in nearby_builders:
					if following != null:
						break
					if not (builder is Dictionary):
						continue
					if bool(builder.get("can_build", false)) and bool(builder.get("actively_building", false)) and bool(builder.get("build_is_construct", false)):
						var build_dx: float = float(builder.get("build_x", 0.0)) - tower_x
						var build_dy: float = float(builder.get("build_y", 0.0)) - tower_y
						if build_dx * build_dx + build_dy * build_dy < range_sq:
							following = builder
							branch = "search_mimic"
				if branch != "search_mimic":
					branch = "search_none"
		elif not plans.is_empty():
			var req: Variant = plans[0]
			var req_dict: Dictionary = req if req is Dictionary else {}
			if not bool(req_dict.get("breaking", false)) and break_check_ready:
				for player in players:
					if not (player is Dictionary):
						continue
					if bool(player.get("is_builder", false)) and bool(player.get("actively_building", false)):
						var player_plan: Variant = player.get("plan", null)
						if player_plan is Dictionary and int(player_plan.get("x", -1)) == int(req_dict.get("x", -2)) and int(player_plan.get("y", -1)) == int(req_dict.get("y", -2)) and bool(player_plan.get("breaking", false)):
							plans.remove_at(0)
							plan_discarded = true
							var kept_team: Array = []
							for team_plan in team_plans:
								if team_plan is Dictionary and int(team_plan.get("x", -1)) == int(req_dict.get("x", -2)) and int(team_plan.get("y", -1)) == int(req_dict.get("y", -2)):
									continue
								kept_team.append(team_plan)
							team_plans = kept_team
							# Java returns here (BuildTurret.java:201): the
							# suicide removal below (and updateBuildLogic)
							# is skipped this tick.
							return {"plans": plans, "following": following, "last_plan": last_plan, "team_plans": team_plans, "branch": "validate_break_discard", "plan_discarded": plan_discarded}
			var last_removed := false
			if last_plan is Dictionary:
				last_removed = bool((last_plan as Dictionary).get("removed", false))
			var valid: bool = not (last_plan != null and last_removed) and (req_construct_match or req_valid_place_or_break)
			if not valid:
				plans.remove_at(0)
				last_plan = null
				plan_discarded = true
				branch = "validate_invalid"
			else:
				branch = "validate_ok"
	else:
		following = null
		last_plan = null
		branch = "controlled"
	var kept_plans: Array = []
	for plan in plans:
		if plan is Dictionary and bool(plan.get("build_is_self", false)):
			continue
		kept_plans.append(plan)
	plans = kept_plans
	return {"plans": plans, "following": following, "last_plan": last_plan, "team_plans": team_plans, "branch": branch, "plan_discarded": plan_discarded}

static func source_build_turret_build_counter_state(build_counter: float, source_delta: float, instant: bool, plan_count: int, update_building: bool, can_build: bool, build_speed: float, core_present: bool, infinite: bool) -> Dictionary:
	# The build-counter half of updateBuildLogic -- counter live
	# (N2272): BuilderComp.updateBuildLogic()
	# (BuilderComp.java:76+, `public void updateBuildLogic(){`),
	# called from BuildTurret.java:225
	# (`unit.updateBuildLogic();`). `if(type.buildSpeed <= 0f)
	# return;` (:77) returns before anything accumulates, so the
	# counter is returned unchanged with no loop and no
	# maxPerFrame; `validatePlans();` (:89) runs before the
	# `if(!updateBuilding || !canBuild()){` guard (:90), which
	# also returns before the counter moves (canBuild() is
	# `return type.buildSpeed > 0 && buildSpeedMultiplier > 0;`,
	# BuilderComp.java:40-41, passed in as can_build -- the port
	# has no live Unit behind the frame). Then
	# `buildCounter += Time.delta;` (:97) -- Time.delta is TICKS
	# (source_delta, seconds * 60 through game_source_delta, arc
	# Time.java:26, never raw seconds); the NaN/Inf guard is
	# `if(Float.isNaN(buildCounter) || Float.isInfinite(buildCounter)) buildCounter = 0f;` (:98);
	# `buildCounter = Math.min(buildCounter, 10f);` (:99) clamps
	# the top only (Java never clamps the bottom). The instant
	# flag is `boolean instant = state.rules.instantBuild && state.rules.infiniteResources;` (:101)
	# and the cap is `int maxPerFrame = instant ? plans.size : 10, count = 0;` (:104),
	# both computed BEFORE the core check, so a core-less tower
	# still reports max_per_frame; `var core = core();` (:106)
	# with `if((core == null && !infinite)) return;` (:108)
	# stops the loop but keeps the accumulated counter (the
	# accumulation precedes the check). run_build_loop is the
	# `while((buildCounter >= 1 || instant) && count++ < maxPerFrame && plans.size > 0){` gate (:110):
	# (counter >= 1.0 || instant) && plan_count > 0 &&
	# iterations_available > 0. iterations_available is the
	# counter / maxPerFrame budget -- instant ? plan_count :
	# int(min(floor(counter), max_per_frame)) -- clamped at 0
	# (a negative counter never runs an iteration); it is NOT
	# gated on plan_count, so with an empty queue and a charged
	# counter it still reports the budget while run_build_loop
	# stays false (the plan_count gate lives on run_build_loop,
	# mirroring the `plans.size > 0` term of the while). The
	# counter is NOT decremented here -- Java subtracts
	# `buildCounter -= 1f;` (:111) per loop iteration, and the
	# driver subtracts 1.0 once when it actually runs one
	# iteration (one plan per tick; the multi-iteration loop
	# waits for the placement slice).
	if build_speed <= 0.0:
		return {"build_counter": build_counter, "run_build_loop": false, "iterations_available": 0, "max_per_frame": 0}
	if not update_building or not can_build:
		return {"build_counter": build_counter, "run_build_loop": false, "iterations_available": 0, "max_per_frame": 0}
	var counter: float = build_counter + source_delta
	if is_nan(counter) or is_inf(counter):
		counter = 0.0
	counter = minf(counter, 10.0)
	var max_per_frame: int = plan_count if instant else 10
	if not core_present and not infinite:
		return {"build_counter": counter, "run_build_loop": false, "iterations_available": 0, "max_per_frame": max_per_frame}
	var iterations_available: int = plan_count if instant else maxi(0, int(minf(floorf(counter), float(max_per_frame))))
	var run_build_loop: bool = (counter >= 1.0 or instant) and plan_count > 0 and iterations_available > 0
	return {"build_counter": counter, "run_build_loop": run_build_loop, "iterations_available": iterations_available, "max_per_frame": max_per_frame}

static func _build_turret_plan_draw_dst2(plan: Variant, tower_x: float, tower_y: float) -> float:
	# plan.dst2(this) (BuilderComp.java:123, `float dst =
	# plan.dst2(this);`): the squared world distance from the
	# tower to the plan's DRAW position -- BuildPlan.getX() /
	# getY() return drawx() / drawy() (BuildPlan.java:179-186),
	# and `return x*tilesize + (block == null ? 0 : block.offset);`
	# (BuildPlan.java:143; drawy :147) puts the plan at the tile
	# origin plus the block offset (0 for odd-size blocks, 4 for
	# even-size ones, `offset = ((size + 1) % 2) * tilesize / 2f;`,
	# Block.java:761) -- NOT the tile center (x*8+4), which is
	# the Tile worldx used by the :155 tile-within check, a
	# placement-step check that defers with placement. The port
	# reads the per-plan block_offset (default 0.0, the odd-size
	# / null-block value) because the plan dicts carry no block
	# size. A malformed (non-dict) plan reads INF -- never
	# within, never selected.
	if not (plan is Dictionary):
		return INF
	var plan_dict: Dictionary = plan
	var block_offset: float = float(plan_dict.get("block_offset", 0.0))
	var draw_x: float = float(plan_dict.get("x", 0)) * 8.0 + block_offset
	var draw_y: float = float(plan_dict.get("y", 0)) * 8.0 + block_offset
	var dx: float = draw_x - tower_x
	var dy: float = draw_y - tower_y
	return dx * dx + dy * dy

static func _build_turret_plan_invalid(plan: Dictionary, tile_state: Dictionary) -> bool:
	# One validatePlans removal check (BuilderComp.java:57-74,
	# `public void validatePlans(){`): the tile lookup is
	# `Tile tile = world.tile(plan.x, plan.y);` (:62) -- tile_exists false is
	# tile == null, remove; `boolean isSameDerelict = (tile !=
	# null && tile.build != null && tile.block() == plan.block &&
	# tile.build.tileX() == plan.x && tile.build.tileY() ==
	# plan.y && tile.team() == Team.derelict);` (:63); remove if
	# `tile == null || (plan.breaking && tile.block() ==
	# Blocks.air) || (!plan.breaking && ((tile.build != null &&
	# tile.build.rotation == plan.rotation && !isSameDerelict) ||
	# !plan.block.rotate) && ((tile.block() == plan.block &&
	# !isSameDerelict) || (plan.block != null &&
	# (plan.block.isOverlay() && plan.block == tile.overlay() ||
	# (plan.block.isFloor() && plan.block == tile.floor())))))`
	# (:64-68). tile_block is the block id string; "air" is
	# Blocks.air. block_rotate defaults false (the Block.rotate
	# field default, Block.java -- most blocks do not rotate);
	# block_is_overlay / block_is_floor default false.
	if not bool(tile_state.get("tile_exists", false)):
		return true
	var breaking: bool = bool(plan.get("breaking", false))
	var tile_block: String = str(tile_state.get("tile_block", ""))
	var plan_block: String = str(plan.get("block", ""))
	if breaking:
		return tile_block == "air"
	var tile_build_exists: bool = bool(tile_state.get("tile_build_exists", false))
	var is_same_derelict: bool = tile_build_exists and tile_block == plan_block and int(tile_state.get("tile_build_x", -1)) == int(plan.get("x", -2)) and int(tile_state.get("tile_build_y", -1)) == int(plan.get("y", -2)) and bool(tile_state.get("tile_team_derelict", false))
	var rotation_match: bool = tile_build_exists and int(tile_state.get("tile_build_rotation", 0)) == int(plan.get("rotation", 0)) and not is_same_derelict
	var block_rotate: bool = bool(tile_state.get("block_rotate", false))
	var first: bool = rotation_match or not block_rotate
	var same_block: bool = tile_block == plan_block and not is_same_derelict
	var overlay_match: bool = plan_block != "" and bool(tile_state.get("block_is_overlay", false)) and plan_block == str(tile_state.get("tile_overlay", ""))
	var floor_match: bool = plan_block != "" and bool(tile_state.get("block_is_floor", false)) and plan_block == str(tile_state.get("tile_floor", ""))
	return first and (same_block or overlay_match or floor_match)

static func _build_turret_plan_should_skip(plan: Variant, core_items: Variant, infinite: bool, build_cost_multiplier: float) -> bool:
	# shouldSkip (BuilderComp.java:246-251, `boolean shouldSkip(
	# BuildPlan plan, @Nullable Building core){`): the guard is
	# `if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;` (:247)
	# -- infinite is already the OR of
	# the state and team rules (the driver passes the state half;
	# the team half is unmodeled, the port's team rules carry
	# only cheat); core_items null is core == null; is_rotation
	# / is_derelict_repair are explicit per-plan bools (the port
	# cannot evaluate `public boolean isRotation(Team team){`,
	# BuildPlan.java:71-75, or `public boolean isDerelictRepair(){`,
	# BuildPlan.java:77-81, live -- both read the tile). Otherwise
	# `return (plan.stuck && !core.items.has(
	# plan.block.requirements)) || (Structs.contains(
	# plan.block.requirements, i -> !core.items.has(i.item,
	# Math.min(i.amount, 15)) && Mathf.round(i.amount *
	# state.rules.buildCostMultiplier) > 0));` (:249-250): the
	# stuck branch needs EVERY requirement stack held at its full
	# amount (ItemModule.has(ItemStack[]) is the all-stacks
	# check); the missing-stack branch fires when ANY stack is
	# short of min(amount, 15) AND rounds to a positive cost at
	# the build cost multiplier. requirements is the per-plan
	# Array of {item, amount} stacks (default [], the N2244 plans
	# carry none -- read through .get so they stay compatible).
	# core_items is the core inventory dict {item: amount} (a
	# malformed non-dict core reads as empty). A malformed
	# (non-dict) plan is never skipped -- it is never within
	# either, so it never gets selected.
	if not (plan is Dictionary):
		return false
	var plan_dict: Dictionary = plan
	if infinite or bool(plan_dict.get("breaking", false)) or core_items == null or bool(plan_dict.get("is_rotation", false)) or bool(plan_dict.get("is_derelict_repair", false)):
		return false
	var core: Dictionary = core_items if core_items is Dictionary else {}
	var requirements: Array = plan_dict.get("requirements", [])
	if not (requirements is Array):
		requirements = []
	if bool(plan_dict.get("stuck", false)):
		var has_all := true
		for stack in requirements:
			if not (stack is Dictionary):
				continue
			if int(core.get(str(stack.get("item", "")), 0)) < int(stack.get("amount", 0)):
				has_all = false
				break
		if not has_all:
			return true
	for stack in requirements:
		if not (stack is Dictionary):
			continue
		var item: String = str(stack.get("item", ""))
		var amount: float = float(stack.get("amount", 0))
		var needed: int = int(minf(amount, 15.0))
		if int(core.get(item, 0)) < needed and roundi(amount * build_cost_multiplier) > 0:
			return true
	return false

static func source_build_turret_build_plan_selection_state(plans: Array, tile_states: Array, core_items: Variant, tower_x: float, tower_y: float, build_range: float, infinite: bool, build_cost_multiplier: float) -> Dictionary:
	# The validate + plan-selection half of updateBuildLogic --
	# selection live (N2272): BuilderComp.updateBuildLogic()
	# (BuilderComp.java:76+), called from BuildTurret.java:225
	# (`unit.updateBuildLogic();`). Step 1, validatePlans
	# (:57-74): each plan is checked against its parallel
	# tile_state entry ({tile_exists, tile_block,
	# tile_build_exists, tile_build_rotation, tile_build_x,
	# tile_build_y, tile_team_derelict, tile_overlay, tile_floor,
	# block_rotate, block_is_overlay, block_is_floor} -- a plan
	# with NO tile_state entry is KEPT (not enough information
	# to remove it; the driver passes an empty list until the
	# live tile-state fill lands, so a live tower never
	# validates a plan away). Step 2, selection (:114-146):
	# `float finalPlaceDst = state.rules.infiniteResources ?
	# Float.MAX_VALUE : type.buildRange;` (:94) -- infinite
	# reads INF here, build_range is the 200f tower range
	# (`unitType.buildRange = range;`, BuildTurret.java:76;
	# `range = 200f;`, Blocks.java:2001). With more than one
	# plan, `if(plans.size > 1){` (:114) rotates through every
	# plan: `float dst = plan.dst2(this);` (:123) in world units
	# from the plan draw position (x*8 + block_offset, NOT the
	# tile center x*8+4 -- BuildPlan.java:143, see
	# _build_turret_plan_draw_dst2); the within check is
	# `boolean within = dst <= finalPlaceDst*finalPlaceDst;` (:124, NON-strict); the
	# first within plan that is not skipped
	# (`if(within && !shouldSkip(plan, core)){`, :126) is found
	# and the loop breaks with it at the head; otherwise the
	# closest within plan is tracked as bestIndex (`}else
	# if(within && dst < bestDst){`, :129 -- strict, so the
	# first plan wins a distance tie); each examined plan
	# rotates (`plans.removeFirst();` / `plans.addLast(plan);`,
	# :134-135). After the loop, the fallback is
	# `if(!foundAny && bestIndex > 0 && !within(buildPlan(), finalPlaceDst)){` (:140) -- it rotates
	# bestIndex times toward the closest within plan -- but
	# ONLY when the head plan is NOT within, and within() here
	# is the STRICT squared-distance check (Arc
	# Position.java:44-46, `Mathf.dst2(getX(), getY(), x, y) <
	# dst*dst`), unlike the NON-strict :124 loop check. With
	# exactly one plan Java skips the loop entirely (:114) and
	# still builds the head plan when it is within (:148-155),
	# so the port evaluates the single plan with the same
	# within / shouldSkip predicates (found_any when it passes,
	# best_index 0 when it is within but skipped). selected is
	# plans[0] after rotation when found_any or best_index >= 0
	# (Java proceeds with buildPlan() after selection, :148 --
	# `BuildPlan current = buildPlan();` -- and
	# `lastActive = current;` (:151) is what the driver stamps as last_plan),
	# else null (no plan within range -- the driver then does
	# not consume the counter). The input arrays are NOT
	# mutated (the validated queue is a fresh Array; plan dicts
	# are shared but never written). Placement (:148-222:
	# Build.validPlaceIgnoreUnits / Call.beginPlace /
	# Call.beginBreak / ConstructBuild construct/deconstruct /
	# sound / events) defers -- including the :155 tile-within
	# check (`if(!within(tile, finalPlaceDst)) continue;`,
	# measured from the TILE center, not the plan draw
	# position), so a selected plan is the plan Java WOULD
	# build this tick, not a placed block.
	var validated: Array = []
	for i in plans.size():
		var plan: Variant = plans[i]
		if not (plan is Dictionary):
			validated.append(plan)
			continue
		if i >= tile_states.size() or not (tile_states[i] is Dictionary):
			validated.append(plan)
			continue
		if _build_turret_plan_invalid(plan, tile_states[i]):
			continue
		validated.append(plan)
	plans = validated
	var final_place_dst: float = INF if infinite else build_range
	var final_dst_sq: float = final_place_dst * final_place_dst
	var found_any := false
	var best_index := -1
	var selected: Variant = null
	if plans.size() > 1:
		var total := 0
		var size: int = plans.size()
		var best_dst: float = INF
		while total < size:
			var head: Variant = plans[0]
			var dst: float = _build_turret_plan_draw_dst2(head, tower_x, tower_y)
			var within: bool = dst <= final_dst_sq
			if within and not _build_turret_plan_should_skip(head, core_items, infinite, build_cost_multiplier):
				found_any = true
				break
			elif within and dst < best_dst:
				best_index = total
				best_dst = dst
			plans.remove_at(0)
			plans.append(head)
			total += 1
		if not found_any and best_index > 0:
			var head_dst: float = _build_turret_plan_draw_dst2(plans[0], tower_x, tower_y)
			if not (head_dst < final_dst_sq):
				for _i in best_index:
					plans.append(plans[0])
					plans.remove_at(0)
	elif plans.size() == 1:
		var only: Variant = plans[0]
		var only_dst: float = _build_turret_plan_draw_dst2(only, tower_x, tower_y)
		var only_within: bool = only_dst <= final_dst_sq
		if only_within and not _build_turret_plan_should_skip(only, core_items, infinite, build_cost_multiplier):
			found_any = true
		elif only_within:
			best_index = 0
	if found_any or best_index >= 0:
		selected = plans[0]
	return {"plans": plans, "selected": selected, "found_any": found_any, "best_index": best_index}

@warning_ignore("unused_parameter")
static func source_build_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the build-turret tick wiring every
	# tick (BuildTurretBuild.updateTile(), BuildTurret.java:121-139,
	# only scales the builder unit by potentialEfficiency
	# (BuildTurret.java:136-137, `unit.buildSpeedMultiplier(
	# potentialEfficiency * timeScale);`), so the build speed
	# follows the folded efficiency; no placed-buildings driver
	# ticks BuildTurret blocks, so this driver is the
	# placed-build-tower tick): each placed BuildTurret build gets
	# its frame keys refreshed from the live rules, so the frame's
	# cheating flag tracks team.rules().cheat and the consumption
	# machinery skips consumption for a cheating team. The frame is
	# bound at placement; a sprite that somehow lacks one gets it
	# bound here instead of crashing the loop.
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
	var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_build_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_build_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_build_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold and the
		# pure liquid row reads the nitrogen amount from it
		# (the Fracker:327 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a build tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the build-speed advance (BuildTurret.java:136)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a build tower does not take the early return. The tower's power draw is STATIC: `consumePower(3f);` (Blocks.java:2005) registers a plain ConsumePower, so the catalog consumePower 3.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A build tower with no power consumer is untouched: the tick folds the liquid row too (N2251, the nitrogen row next to the power row; the updateTile sync/warmup advance, N2243, and plan logic, N2244, are live, wired below; updateBuildLogic live (N2272), wired below), and BuildTurretBuild DOES override shouldConsume (BuildTurret.java:229-230, `return unit.plans().size > 0 && !isHealSuppressed();`) -- N2215 feeds the live gate to the machinery (the pure gate is source_build_turret_should_consume_state, fed the frame); the N2184 RED decision is resolved. The gate has NO enabled term (Java returns the bare plans + suppression check), so the pure gate does not read frame["enabled"] at all; the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_build_turret_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_build_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# The required liquid consumer (N2251): the build
			# tower consumes nitrogen 3f/60f (Blocks.java:2006),
			# so its ConsumeLiquid.efficiency row folds next to
			# the power row. source_delta is Time.delta in
			# ticks (game_source_delta, seconds * 60, arc
			# Time.java:26); timeScale reads live from the
			# sprite meta, default 1.0 (BuildingComp.java:98).
			# The nitrogen id resolves from the liquid catalog
			# with the def constant "nitrogen" (the Fracker
			# precedent); has_liquid_consumer reads the catalog
			# consumeLiquid builder, like the power gate reads
			# consumePower. The multiplier takes the 1f default
			# (Consume.java:18) -- the def sets none.
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var nitrogen_id: int = int(liquid_id_by_name.get(SOURCE_BUILD_TURRET_LIQUID, -1))
			var has_liquid_consumer: bool = bool(block.properties.has("consumeLiquid"))
			var liquid_row: Dictionary = source_build_turret_liquid_consumer_row_state(frame, has_liquid_consumer, nitrogen_id, SOURCE_BUILD_TURRET_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (N2251): ConsumeLiquid.update
			# removes amount * edelta * multiplier
			# (ConsumeLiquid.java:37-39), only when `if(update && efficiency > 0){`
			# (BuildingComp.java:1999-2003) -- and edelta here
			# is the FOLDED efficiency times delta, not the
			# first-pass assumed 1f. The AdjacentFactory
			# updates-array precedent does not fit: it runs
			# RuntimeConsumer actors with an update() method
			# through apply_update_consumption_state, and this
			# driver has no actors -- so the removal is direct,
			# after the fold stamps the folded efficiency on
			# the frame. source_remove_state caps at the held
			# amount (LiquidModule.java:126-127, `//cap to
			# prevent negative removal`), so a starved tower
			# never goes negative.
			if bool(liquid_row.get("has_liquid_row", false)) and should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
				var liquids_store: Dictionary = frame.get("liquids", {})
				if nitrogen_id >= 0 and liquids_store.has("liquids") and nitrogen_id < int(liquids_store["liquids"].size()):
					var cache_sums: Array = []
					if liquids_store.get("flow") != null:
						cache_sums.resize(int(liquids_store["liquids"].size()))
						cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids_store, nitrogen_id, SOURCE_BUILD_TURRET_LIQUID_AMOUNT * folded_edelta, cache_sums)
		# N2243: the updateTile sync/warmup advance runs after
		# consumption, like Java's Building.update()
		# (BuildingComp.java:2274 updateConsumption(), then the
		# updateTile gate `if(enabled || !block.noUpdateDisabled){`
		# at BuildingComp.java:2276-2277; noUpdateDisabled
		# defaults false, Block.java:170, so Java runs updateTile
		# even when disabled -- in Java a disabled build tower's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957).
		# The port keeps the enabled gate below as a pragmatic
		# choice (the N2195 coordinator-fix precedent): the
		# driver skips the consumption fold when disabled, so
		# the frame efficiency goes stale and running the
		# advance on it would charge warmup/multipliers from a
		# stale efficiency. The driver-wide
		# disabled-early-return slice (deferred in the N2243
		# register) removes this gate for all families.
		# super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. timeScale reads
		# live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The unit-state
		# inputs (unit_rotation / actively_building /
		# build_plan_angle) have no live fill yet -- the frame
		# inputs carry the defaults 90.0 / false / 0.0 until
		# the live unit-state fill lands, so a live tower
		# faces 90, never looks at a plan and never warms up.
		# N2244 wires the plan logic AFTER this advance (the
		# Java order, BuildTurret.java:141 after :139).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_build_turret_update_tile_advance_state(frame, source_delta, time_scale)
			frame["rotation"] = advanced["rotation"]
			frame["unit_look_angle"] = advanced["unit_look_angle"]
			frame["efficiency"] = advanced["efficiency"]
			frame["potential_efficiency"] = advanced["potential_efficiency"]
			frame["build_speed_multiplier"] = advanced["build_speed_multiplier"]
			frame["speed_multiplier"] = advanced["speed_multiplier"]
			frame["warmup"] = advanced["warmup"]
		# The updateTile plan logic (N2244, BuildTurret.java:141-225):
		# runs after the consumption fold -- updateConsumption runs
		# before updateTile (BuildingComp.java:2274-2277,
		# `updateConsumption();` then `if(enabled ||
		# !block.noUpdateDisabled){` / `updateTile();`) -- and
		# UNGATED on enabled: BuildTurret sets no noUpdateDisabled,
		# so Java runs updateTile for a disabled tower too. In Java
		# order this wiring sits AFTER the N2243 sync/warmup wiring
		# (BuildTurret.java:121-140 before :141-225); the N2243
		# wiring runs above (merged at integration). The driver passes no live team plans /
		# nearby builders / players yet (empty lists, both timers
		# false, controlled false) and assumes the current request
		# stays valid (req_valid_place_or_break true -- the port
		# cannot evaluate Build.validPlace / validBreak live), so a
		# live tower keeps its plans and the N2215 gate keeps reading
		# them; the pure function proves the search / mimic / discard
		# paths with explicit inputs. The tower world position is the
		# origin cell times tilesize 8 (Vars.java:135; size-3 offset
		# 0, Block.java:217); the pure function is exact given the
		# position. updateBuildLogic (BuilderComp.java:76+) is live
		# since N2272, wired below in Java order (:225 after
		# :141-225).
		var plan_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var plan_tower_x := float(plan_cell.x) * 8.0
		var plan_tower_y := float(plan_cell.y) * 8.0
		var advanced_plan: Dictionary = source_build_turret_plan_logic_state(frame, false, false, false, plan_tower_x, plan_tower_y, SOURCE_BUILD_TURRET_RANGE, [], [], [], false, true)
		frame["plans"] = advanced_plan["plans"]
		frame["following"] = advanced_plan["following"]
		frame["last_plan"] = advanced_plan["last_plan"]
		# The build simulation (N2272, BuilderComp.updateBuildLogic(),
		# BuilderComp.java:76+, called from BuildTurret.java:225,
		# `unit.updateBuildLogic();`): runs after the plan logic in
		# Java order (:225 after :141-225) and UNGATED on enabled,
		# like the plan logic (BuildTurret sets no noUpdateDisabled,
		# so Java runs updateTile for a disabled tower too,
		# BuildingComp.java:2274-2277). The counter pure runs every
		# tick and its result persists on the frame (Java
		# accumulates the counter past the guards even with an empty
		# queue, :97-99 before the :110 loop gate); the selection
		# pure runs only when the loop gate opens, and its
		# validated + rotated plans persist even when no plan is
		# selected (Java's validatePlans removes invalid plans from
		# the queue permanently, :57-74). The counter is consumed
		# (minus 1.0) and last_plan is set only when a plan is
		# selected -- one plan per tick: Java subtracts the counter
		# BEFORE selection (:111) and loops up to maxPerFrame times,
		# but without placement no plan ever leaves the queue, so a
		# multi-iteration loop would re-select the same plan; the
		# loop waits for the placement slice. build_speed is the
		# single-def 1.5f (Blocks.java:2003); infinite / instant /
		# buildCostMultiplier read the rules state with the Java
		# defaults (false / false / 1.0 -- the port's rules state
		# carries no live infiniteResources / instantBuild /
		# buildCostMultiplier yet, and the team.rules().
		# infiniteResources half of `boolean infinite =
		# state.rules.infiniteResources ||
		# team().rules().infiniteResources;` (:95) is unmodeled --
		# the port's team rules carry only cheat); core_items /
		# plan_tile_states / update_building / can_build are frame
		# inputs with Java-faithful defaults (null / [] / true /
		# true) and no live fill yet -- a live tower with no fill
		# keeps its plans unvalidated (no tile states) and never
		# runs the build loop (no core), and a disabled tower may
		# select plans until the live can_build fill lands (Java
		# stops the loop at canBuild() via buildSpeedMultiplier 0,
		# BuilderComp.java:40-41). The tower world position is the
		# same origin-cell position the plan logic uses.
		var build_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var build_rules: Variant = rules_state
		if not (build_rules is Dictionary):
			build_rules = {}
		var build_infinite: bool = bool(build_rules.get("infiniteResources", false))
		var build_instant: bool = bool(build_rules.get("instantBuild", false)) and build_infinite
		var build_core_items: Variant = frame.get("core_items", null)
		var build_plans: Variant = frame.get("plans", [])
		if not (build_plans is Array):
			build_plans = []
		var build_tile_states: Variant = frame.get("plan_tile_states", [])
		if not (build_tile_states is Array):
			build_tile_states = []
		var counter_state: Dictionary = source_build_turret_build_counter_state(float(frame.get("build_counter", 0.0)), build_delta, build_instant, (build_plans as Array).size(), bool(frame.get("update_building", true)), bool(frame.get("can_build", true)), SOURCE_BUILD_TURRET_BUILD_SPEED, build_core_items != null, build_infinite)
		frame["build_counter"] = counter_state["build_counter"]
		if bool(counter_state.get("run_build_loop", false)):
			var selection: Dictionary = source_build_turret_build_plan_selection_state(build_plans, build_tile_states, build_core_items, plan_tower_x, plan_tower_y, SOURCE_BUILD_TURRET_RANGE, build_infinite, float(build_rules.get("buildCostMultiplier", 1.0)))
			frame["plans"] = selection["plans"]
			var selected: Variant = selection.get("selected", null)
			if selected != null:
				frame["build_counter"] = float(counter_state["build_counter"]) - 1.0
				frame["last_plan"] = selected
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_build_turret_draw_state(x_value: float, y_value: float, rotation: float, elevation: float, warmup: float, efficiency: float, glow_found: bool, heat_color: String, unit_present: bool) -> Dictionary:
	# The draw rows (BuildTurretBuild.draw(), BuildTurret.java:234-251), the pure draw-call dict -- the port never draws for real (the N2421 RepairTurret precedent: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void draw(){`
	# `Draw.rect(baseRegion, x, y);`
	# `Draw.color();`
	# `Draw.z(Layer.turret);`
	# `Drawf.shadow(region, x - elevation, y - elevation, rotation - 90);`
	# `Draw.rect(region, x, y, rotation - 90);`
	# `if(glowRegion.found()){`
	# `Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);`
	# `if(efficiency > 0){`
	# `unit.drawBuilding();`
	# The shadow shifts by the FIELD elevation (`public float elevation = -1f;`, BuildTurret.java:38), lifted by init() (`if(elevation < 0) elevation = size / 2f;`, BuildTurret.java:53), so the size-3 build-tower (`size = 3;`, Blocks.java:2002; `buildTower = new BuildTurret("build-tower"){{`, Blocks.java:1997) shifts by 1.5 -- NOT the RepairTurret literal size / 2f: here the field is the shift and the init lift is what sets it. baseRegion is the `@-base` region (`public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;`, BuildTurret.java:31). The shadow overload is Drawf.shadow(TextureRegion, x, y, rotation) (`public static void shadow(TextureRegion region, float x, float y, float rotation){`, Drawf.java:366-370): `Draw.color(Pal.shadow);` + Draw.rect + `Draw.color();`. The glow is the Drawf.additive overload (region, color, alpha, x, y, rotation, layer) (`public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){`, Drawf.java:183-192): `Draw.color(color, alpha * color.a);` + `Draw.blend(Blending.additive);` + Draw.rect + blend/color/z reset. heatColor is `public Color heatColor = Pal.accent.cpy().a(0.9f);` (BuildTurret.java:39) -- the 0.9f alpha makes the effective glow alpha warmup * 0.9; the single build-tower def sets neither elevation nor heatColor (Blocks.java:1997-2006, `range = 200f;` / `buildSpeed = 1.5f;` only). The glow region is the `@-glow` region (`public @Load("@-glow") TextureRegion glowRegion;`, BuildTurret.java:32). The color rides as the symbolic token ("heatColor"), the N2415 / ShockwaveTower precedent; the port never draws for real. warmup is the frame warmup (`public float warmup;`, BuildTurret.java:96, tracked by the N2243 lerp advance). The build call is a call into the builder unit (`public BlockUnitc unit = (BlockUnitc)unitType.create(team);`, BuildTurret.java:93), which Java creates at construction and never nulls -- the pure RECORDS the call, it does not model unit draw; unit_present is a defensive port flag (the port has no live Unit object behind the frame). The gate is a STRICT > 0 -- efficiency exactly 0 draws nothing. The rotation field default is `public float rotation = 90;` (BaseTurret.java:114). Pure-only: the tick never calls draw -- draw is called by the renderer, and the renderer call site waits for a renderer slice.
	var draw_rotation: float = rotation - 90.0
	var base_call: Dictionary = {
		"call": "Draw.rect(baseRegion, x, y);",
		"region": "baseRegion",
		"x": x_value,
		"y": y_value,
	}
	var shadow_call: Dictionary = {
		"call": "Drawf.shadow(region, x - elevation, y - elevation, rotation - 90);",
		"region": "region",
		"x": x_value - elevation,
		"y": y_value - elevation,
		"rotation": draw_rotation,
		"z": "Layer.turret",
	}
	var region_call: Dictionary = {
		"call": "Draw.rect(region, x, y, rotation - 90);",
		"region": "region",
		"x": x_value,
		"y": y_value,
		"rotation": draw_rotation,
		"z": "Layer.turret",
	}
	var effective_alpha: float = warmup * SOURCE_BUILD_TURRET_HEAT_COLOR_ALPHA
	var glow_call: Variant = null
	if glow_found:
		glow_call = {
			"call": "Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);",
			"region": "glowRegion",
			"color": heat_color,
			"alpha": warmup,
			"effective_alpha": effective_alpha,
			"x": x_value,
			"y": y_value,
			"rotation": draw_rotation,
			"layer": "Layer.turretHeat",
		}
	var build_call: Variant = null
	if efficiency > 0.0 and unit_present:
		build_call = {
			"call": "unit.drawBuilding();",
		}
	return {
		"base_expr": "Draw.rect(baseRegion, x, y);",
		"color_expr": "Draw.color();",
		"z_expr": "Draw.z(Layer.turret);",
		"shadow_expr": "Drawf.shadow(region, x - elevation, y - elevation, rotation - 90);",
		"region_expr": "Draw.rect(region, x, y, rotation - 90);",
		"glow_gate_expr": "if(glowRegion.found()){",
		"glow_expr": "Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);",
		"build_gate_expr": "if(efficiency > 0){",
		"build_expr": "unit.drawBuilding();",
		"x": x_value,
		"y": y_value,
		"rotation": rotation,
		"elevation": elevation,
		"warmup": warmup,
		"efficiency": efficiency,
		"glow_found": glow_found,
		"heat_color": heat_color,
		"unit_present": unit_present,
		"draw_rotation": draw_rotation,
		"effective_alpha": effective_alpha,
		"base_call": base_call,
		"shadow_call": shadow_call,
		"region_call": region_call,
		"glow_call": glow_call,
		"build_call": build_call,
	}

static func source_build_turret_sense_state(sensor: String, unit_build_x: float, unit_build_y: float, super_value: Variant = null) -> Dictionary:
	# The sense rows (BuildTurretBuild.sense(), BuildTurret.java:281-287), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor){`
	# `case buildX, buildY -> unit.sense(sensor);`
	# `default -> super.sense(sensor);`
	# The unit is the live BlockUnitc (`public BlockUnitc unit = (BlockUnitc)unitType.create(team);`, BuildTurret.java:93) -- the pure NEVER queries it directly, it takes its sensed values caller-supplied. unit.sense(buildX/buildY) is the plan tile coordinate, or -1 when the unit is not building:
	# `case buildX -> isBuilding() ? buildPlan().x : -1;`
	# `case buildY -> isBuilding() ? buildPlan().y : -1;`
	# (UnitComp.java:290-291). The pure only delegates -- it never computes the -1 itself. The LAccess tokens are the exact enum names (buildX / buildY, LAccess.java:54-55 -- NOTE: LAccess is mindustry.logic.LAccess, not arc). super.sense is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2093-2125):
	# `return switch(sensor){`
	# `default -> Float.NaN; //gets converted to null in logic`
	# covers x / y / color / dead / solid / team / health / maxHealth / efficiency / timescale / range / rotation / totalItems / totalLiquids / totalPower / itemCapacity / liquidCapacity / powerCapacity / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / enabled / controlled / payloadCount / size / cameraX, cameraY, cameraWidth, cameraHeight, and the default branch is Float.NaN (converted to null in logic). The port ALREADY models that switch (SourceBuildingSenseState: sense_position_state, sense_health_process_state, sense_totals_state, sense_capacity_power_net_state, sense_enabled_controlled_state, sense_payload_size_state, sense_camera_default_state), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch; the pure does NOT call the canonical pures, it receives the super value caller-supplied. Pure-only, like the N2391 sense pure: the tick never calls sense (verified: grep `sense` in this driver finds only comments plus these two pures) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a BuildTurret deferral).
	var delegated: bool = sensor == "buildX" or sensor == "buildY"
	var value: Variant = super_value
	if sensor == "buildX":
		value = unit_build_x
	elif sensor == "buildY":
		value = unit_build_y
	return {
		"delegate_expr": "case buildX, buildY -> unit.sense(sensor);",
		"super_expr": "default -> super.sense(sensor);",
		"sensor": sensor,
		"unit_build_x": unit_build_x,
		"unit_build_y": unit_build_y,
		"super_value": super_value,
		"delegated": delegated,
		"value": value,
	}

static func source_build_turret_sense_object_state(sensor: String, unit_building: Variant, unit_breaking: Variant, super_value: Variant = null) -> Dictionary:
	# The senseObject rows (BuildTurretBuild.senseObject(), BuildTurret.java:289-295), the pure logic-object-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public Object senseObject(LAccess sensor){`
	# `case building, breaking -> unit.senseObject(sensor);`
	# `default -> super.senseObject(sensor);`
	# The unit is the live BlockUnitc (`public BlockUnitc unit = (BlockUnitc)unitType.create(team);`, BuildTurret.java:93) -- the pure NEVER queries it directly, it takes its sensed values caller-supplied as null-or-dict descriptors (the plan tile's build). unit.senseObject(building/breaking) is the plan tile's build, or null when the unit is not building that way:
	# `case building -> isBuilding() && !buildPlan().breaking ? buildPlan().tile().build : null;`
	# `case breaking -> isBuilding() && buildPlan().breaking ? buildPlan().tile().build : null;`
	# (UnitComp.java:323-324). The pure only delegates -- it never evaluates isBuilding() / buildPlan().breaking itself. The LAccess tokens are the exact enum names (building / breaking, LAccess.java:59-60 -- NOTE: LAccess is mindustry.logic.LAccess, not arc). super.senseObject is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2128-2136, `public Object senseObject(LAccess sensor){`) covers type / firstItem / config / payloadType, and the default branch is noSensed:
	# `default -> noSensed;`
	# `Object noSensed = new Object();`
	# (Senseable.java:6 -- a sentinel object, NOT null). The port ALREADY models that switch (SourceBuildingSenseState.sense_object_state, which represents noSensed as value null + no_sensed true), so the pure takes the caller's super.senseObject result as super_value (default null = the noSensed default) instead of re-modeling the switch. NOTE the noSensed-to-numeric fallback lives in the logic executor (`if(objOut == Senseable.noSensed){`, LExecutor.java:697-700: the executor falls back to se.sense(la) when the object sense is noSensed) -- NOT in this pure, so the pure passes super_value through untouched. Pure-only, like the sense pure: the tick never calls senseObject -- senseObject is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a BuildTurret deferral).
	var delegated: bool = sensor == "building" or sensor == "breaking"
	var value: Variant = super_value
	if sensor == "building":
		value = unit_building
	elif sensor == "breaking":
		value = unit_breaking
	return {
		"delegate_expr": "case building, breaking -> unit.senseObject(sensor);",
		"super_expr": "default -> super.senseObject(sensor);",
		"sensor": sensor,
		"unit_building": unit_building,
		"unit_breaking": unit_breaking,
		"super_value": super_value,
		"delegated": delegated,
		"value": value,
	}
