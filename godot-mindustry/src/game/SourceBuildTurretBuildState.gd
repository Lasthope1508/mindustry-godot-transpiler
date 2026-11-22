extends RefCounted
class_name SourceBuildTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The BuildTurret implementation (BuildTurret.java:27, `public class BuildTurret extends BaseTurret{`): build-tower (consumePower 3f, Blocks.java:2005, `consumePower(3f);`; size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60, Category.effect, Blocks.java:1997-2006). BuildTurret extends BaseTurret, NOT a TurretBuild -- SourceTurretBuildState.gd says so explicitly ("RepairTurret extends Block and BuildTurret extends BaseTurret, so none of them is a TurretBuild"), so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_build_turret_building", the radar precedent), and this slice adds the build-turret key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceBuildTurret* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the BuildTurretBuild.updateTile only scales the builder unit by potentialEfficiency (BuildTurret.java:136-137, `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);` / `unit.speedMultiplier(potentialEfficiency * timeScale);`) -- so a tower that cannot draw its 3f never builds, as if power.status were 1.0. Liquid care: the tower also consumes nitrogen (`consumeLiquid(Liquids.nitrogen, 3f / 60f);`, Blocks.java:2006) -- the row this slice folds is the CONSUMER-side read (`return build.power.status;`, ConsumePower.java:39), exactly like every pure-consumer slice; the LIQUID side waits for its own slice. Suppression rows: `suppressable = true;` (BuildTurret.java:46); `if(checkSuppression()){` (:132) zeroes `efficiency = potentialEfficiency = 0f;` (:133); suppression state waits for its own slice.
const SOURCE_BUILD_TURRET_BUILD_IMPLEMENTATIONS := ["BuildTurret"]
const SOURCE_BUILD_TURRET_BUILDING_META_KEY := "source_build_turret_building"

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
	return {}

static func source_build_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the build-turret frame meta key
	# ("source_build_turret_building"). A BuildTurret sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_build_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BUILD_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BUILD_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BUILD_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_build_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a build tower does not take the early return. The tower's power draw is STATIC, not conditional: `consumePower(3f);` (Blocks.java:2005) registers a plain ConsumePower, so the catalog consumePower 3.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The tower's updateTile (BuildTurret.java:121-139, `rotation = unit.rotation();` / `if(unit.activelyBuilding()){` / `unit.lookAt(angleTo(unit.buildPlan()));` / `if(checkSuppression()){` / `efficiency = potentialEfficiency = 0f;` / `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);` / `unit.speedMultiplier(potentialEfficiency * timeScale);` / `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`) scales the builder unit by potentialEfficiency -- and because there is no baseEfficiency-style floor, the tower never builds when the gate fails; the folded efficiency is what the efficiency keys prove, and the plan search / follow / mimic / validate advance waits for its own slice.
	# BuildTurretBuild DOES override shouldConsume (BuildTurret.java:229-230, `public boolean shouldConsume(){` / `return unit.plans().size > 0 && !isHealSuppressed();`), and updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision: fold power-only and defer the gate (the PointDefenseTurret N2151 precedent); the port tracks no live build-plan state on any placed-building frame, so the driver needs a plans frame input or a documented deferral. N2201 wires the gate through source_build_turret_should_consume_state(frame): plans_count > 0 and not heal_suppressed and enabled when a plans observation is present, enabled when the frame carries no plans_count key (the N2184 behavior preserved; no live plans are stamped on any placed-building frame yet). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates.
	# The build tower is its own family (BuildTurret.java:27, `public class BuildTurret extends BaseTurret{`; BuildTurretBuild, BuildTurret.java:92, `public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{`), a defense / effect block, NOT a TurretBuild: SourceTurretBuildState.gd excludes it explicitly, and BaseTurretBuild (BaseTurret.java:113, `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`) overrides neither shouldConsume nor updateTile -- the gate and the tick both come from BuildTurretBuild itself. Class fields: `public final int timerTarget = timers++, timerTarget2 = timers++;` (BuildTurret.java:28), `public int targetInterval = 15;` (BuildTurret.java:29), `public float buildSpeed = 1f;` (BuildTurret.java:33), `public float buildBeamOffset = 5f;` (BuildTurret.java:34), `public float elevation = -1f;` (BuildTurret.java:38), `public Color heatColor = Pal.accent.cpy().a(0.9f);` (BuildTurret.java:39); constructor `public BuildTurret(String name){` (BuildTurret.java:41), `group = BlockGroup.turrets;` (BuildTurret.java:43), `sync = false;` (BuildTurret.java:44), `rotateSpeed = 10f;` (BuildTurret.java:45), `suppressable = true;` (BuildTurret.java:46). init lifts the elevation and builds the hidden builder unit type (BuildTurret.java:53, `if(elevation < 0) elevation = size / 2f;` with BuildTurret.java:56, `unitType = new UnitType("turret-unit-" + name){{`). Build fields: `public BlockUnitc unit = (BlockUnitc)unitType.create(team);` (BuildTurret.java:93), `public @Nullable Unit following;` (BuildTurret.java:94), `public @Nullable BlockPlan lastPlan;` (BuildTurret.java:95), `public float warmup;` (BuildTurret.java:96).
	# Single def -- build-tower only (size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60, Blocks.java:1997-2006): `buildTower = new BuildTurret("build-tower"){{` (Blocks.java:1997) with `requirements(Category.effect, with(Items.silicon, 150, Items.oxide, 40, Items.thorium, 60));` (Blocks.java:1998), `outlineColor = Pal.darkOutline;` (Blocks.java:1999), `range = 200f;` (Blocks.java:2001), `size = 3;` (Blocks.java:2002), `buildSpeed = 1.5f;` (Blocks.java:2003), `consumePower(3f);` (Blocks.java:2005) and `consumeLiquid(Liquids.nitrogen, 3f / 60f);` (Blocks.java:2006). No second BuildTurret def exists; there is no family split to manage. The plan search (`}else if(unit.buildPlan() == null && timer(timerTarget, targetInterval)){`, :156; `Queue<BlockPlan> blocks = team.data().plans;`, :157), mimic (`Units.nearby(team, x, y, range, u -> {`, :176), validation (`boolean valid =`, :204) and `unit.updateBuildLogic();` (:225) advance waits for their own slices. The draw / write / read / sense rows (BuildTurret.java:232-319) wait for their own slices.
	# Documented limits: (1) power-only first pass -- the tower's static power consumer (consumePower 3f, Blocks.java:2005) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the tower also consumes nitrogen (Blocks.java:2006), which waits for its own slice. (2) shouldConsume gate -- BuildTurretBuild overrides shouldConsume (BuildTurret.java:229-230) on live build plans; N2201 wires the gate through source_build_turret_should_consume_state(frame) -- with no plans_count observation stamped yet the frame carries no plans_count key, so the gate preserves the N2184 behavior (should_consume = enabled) until the future plan-acquisition slice stamps it. (3) No updateTile plan / mimic / validate advance -- plan search / follow / mimic / validate / updateBuildLogic (BuildTurret.java:156-225) wait for their own slices; the proof carries no plan / follow / warmup keys, the eff fold (BuildTurret.java:136-137) is what the efficiency keys prove. (4) No liquid-side modeling -- consumeLiquid nitrogen 3f/60f (Blocks.java:2006) waits for its own slice. (5) No suppression modeling -- checkSuppression / isHealSuppressed (BuildTurret.java:46, 132-133, 230) waits for its own slice. (6) Single def -- build-tower only (size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60); per-def stat values wait for their own verification slice. (7) No draw / read / write / sense modeling -- draw / write / read / sense (BuildTurret.java:232-319) wait for their own slices.
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

static func source_build_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# BuildTurretBuild overrides shouldConsume (BuildTurret.java:229, `public boolean shouldConsume(){` with `return unit.plans().size > 0 && !isHealSuppressed();`, BuildTurret.java:230) over the builder unit's plan queue (BuildTurret.java:93, `public BlockUnitc unit = (BlockUnitc)unitType.create(team);`), and updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){` + 1993, `efficiency = optionalEfficiency = 0f;`). The suppression conjunct is isHealSuppressed() (BuildingComp.java:487, `public boolean isHealSuppressed(){` with `return block.suppressable && Time.time <= healSuppressionTime;`, BuildingComp.java:488); the tower is suppressable (BuildTurret.java:46, `suppressable = true;`). A missing power stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`), and the power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`); edelta() is efficiency * delta (BuildingComp.java:1928, `return efficiency * delta();`). The default shouldConsume is `return enabled;` (BuildingComp.java:755-756). The build is BuildTurretBuild (BuildTurret.java:92, `public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{`). The frame carries the live plans observation as `plans_count` (int) and the suppression observation as `heal_suppressed` (bool); the function reads plans_count with a null default, so an absent key means "no observation yet", not "no plans": plans_count=0 blocks the gate, plans_count>0 with enabled passes it, plans_count>0 with enabled=false blocks it, plans_count>0 with heal_suppressed=true blocks it -- all observed cases run through the one conjunction, `int(plans_count) > 0 and not heal_suppressed and enabled`; NO plans_count key preserves the N2184 behavior, `should_consume = enabled`, because no placed-building frame carries live build plans today and defaulting absent to false would zero efficiency for every live build tower. The gate activates when the future plan-acquisition slice stamps `plans_count` from `unit.plans().size` (BuildTurret.java:230).
	var enabled: bool = bool(frame.get("enabled", true))
	var plans_count: Variant = frame.get("plans_count", null)
	if plans_count == null:
		return {"should_consume": enabled}
	var heal_suppressed: bool = bool(frame.get("heal_suppressed", false))
	return {"should_consume": int(plans_count) > 0 and not heal_suppressed and enabled}

static func source_build_turret_update_tile_plan_state(has_following: bool, following_valid: bool, controlled: bool, build_plan_null: bool, team_plans: Array, valid_place: Callable, req_breaking: bool, req_pos: Vector2i, player_breaking_same_pos: bool, mimic_following_set: bool) -> Dictionary:
	# BuildTurretBuild.updateTile() plan legs (BuildTurret.java:121-227): the plan search / follow / mimic / validate advance N2184 deferred -- one pure function over explicit params, no engine calls. The follower validation clears following when the follower is gone or stopped building (BuildTurret.java:144-148); the search leg iterates the team plan queue and takes the first plan the caller-supplied validPlace gate accepts (the search opener `}else if(unit.buildPlan() == null && timer(timerTarget, targetInterval)){`, :156, is owned at N2184); the mimic leg clears following and scans nearby builders when no plan was found (BuildTurret.java:174-187); the validate leg drops the request when another player is breaking the same position (BuildTurret.java:193-201) and picks the break/place leg of the valid ternary (BuildTurret.java:204-211); the controlled branch forgets everything (BuildTurret.java:217-220). The `Units.nearby` live query itself waits for its own slice -- this function only answers whether mimic starts and whether a candidate's callback returns early. The `Build.validPlace` + infiniteResources/items gate is an explicit Callable param (the N2418 precedent); `timer(timerTarget, targetInterval)` and `timer.get(timerTarget2, 30f)` are caller-side booleans, not modeled here. The 9 exact exprs of N2423 (verbatim, one per line):
	# - `following = null;`
	# - `for(int i = 0; i < blocks.size; i++){`
	# - `var block = blocks.get(i);`
	# - `var btype = block.block;`
	# - `if(Build.validPlace(btype, unit.team(), block.x, block.y, block.rotation) && (state.rules.infiniteResources || team.rules().infiniteResources || team.items().has(btype.requirements, state.rules.buildCostMultiplier))){`
	# - `if(unit.buildPlan() == null){`
	# - `if(following  != null) return;`
	# - `team.data().plans.remove(p -> p.x == req.x && p.y == req.y);`
	# - `(req.breaking ?`
	var following_cleared: bool = (has_following and not following_valid) or build_plan_null or controlled
	var found_plan: Dictionary = {}
	var found_btype: String = ""
	var found_index: int = -1
	if build_plan_null and not controlled:
		for i in range(team_plans.size()):
			var block = team_plans[i]
			if block is Dictionary and valid_place.is_valid() and bool(valid_place.call(block)):
				found_plan = block
				found_btype = str(block.get("block", ""))
				found_index = i
				break
	var mimic: bool = build_plan_null and found_index < 0 and not controlled
	var mimic_early_return: bool = mimic and mimic_following_set
	var remaining_plans: Array = team_plans.duplicate()
	if not build_plan_null and not controlled and player_breaking_same_pos:
		var kept: Array = []
		for plan in team_plans:
			if plan is Dictionary and Vector2i(int(plan.get("x", 0)), int(plan.get("y", 0))) == req_pos:
				continue
			kept.append(plan)
		remaining_plans = kept
	var valid_break_branch: bool = not build_plan_null and not controlled and req_breaking
	return {"following_cleared": following_cleared, "found_plan": found_plan, "found_btype": found_btype, "found_index": found_index, "mimic": mimic, "mimic_early_return": mimic_early_return, "team_plans": remaining_plans, "valid_break_branch": valid_break_branch}

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
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a build tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the build-speed advance (BuildTurret.java:136)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a build tower does not take the early return. The tower's power draw is STATIC: `consumePower(3f);` (Blocks.java:2005) registers a plain ConsumePower, so the catalog consumePower 3.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A build tower with no power consumer is untouched: the tick models no other consumers yet (the updateTile plan / mimic / validate advance waits for its own slice), and BuildTurretBuild DOES override shouldConsume (BuildTurret.java:229-230, `return unit.plans().size > 0 && !isHealSuppressed();`) -- N2201 wires the gate through source_build_turret_should_consume_state(frame): plans_count > 0 and not heal_suppressed and enabled when a plans observation is present, enabled when the frame carries no plans_count key (the N2184 behavior preserved; no live plans are stamped on any placed-building frame yet). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(source_build_turret_should_consume_state(frame).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_build_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
