extends RefCounted
class_name SourceLightBlockBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

# The LightBlock implementation (LightBlock.java:21, `public class LightBlock extends Block{`): illuminator (consumePower 0.05f, Blocks.java:6767, `consumePower(0.05f);`; brightness 0.75f, radius 140f, graphite 12 / silicon 8 / lead 8, Category.effect, BuildVisibility.lightingOnly, Blocks.java:6763-6767). LightBlock extends Block directly, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_light_block_building", the radar precedent), and this slice adds the light-block key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceLightBlock* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the LightBuild.drawLight scales the emitted light by brightness * efficiency (LightBlock.java:128, `Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);`) -- so an illuminator that cannot draw its 0.05f emits at brightness 0, as if power.status were 1.0.
const SOURCE_LIGHT_BLOCK_BUILD_IMPLEMENTATIONS := ["LightBlock"]
const SOURCE_LIGHT_BLOCK_BUILDING_META_KEY := "source_light_block_building"
const SOURCE_LIGHT_BLOCK_DRAW_TOP_ALPHA := 0.6

static func _is_light_block_build_implementation(implementation: String) -> bool:
	return SOURCE_LIGHT_BLOCK_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_light_block_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The light-block tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (LightBlock.java:21, `public class LightBlock extends
	# Block{`; LightBuild, LightBlock.java:67,
	# `public class LightBuild extends Building{`), team_id and
	# rules_state are what Java reads as b.team and
	# state.rules, and cheating is the team's live TeamRule
	# value (TeamComp.cheating(), TeamComp.java:17-19 `return
	# team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's illuminator skips consumption like
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
	# for this illuminator (N2125); the tick preserves a disabled
	# illuminator instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# smoothTime starts at 1f (LightBlock.java:69, `public float
	# smoothTime = 1f;`), so a freshly placed illuminator binds
	# that value; the driver advances it every tick (N2189/N2241).
	return {"smooth_time": 1.0}

static func source_light_block_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the light-block frame meta key
	# ("source_light_block_building"). A LightBlock sprite gets its
	# initial frame bound (smooth_time 1f, the Java initial value,
	# LightBlock.java:69); the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_light_block_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_LIGHT_BLOCK_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_LIGHT_BLOCK_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_LIGHT_BLOCK_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_light_block_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an illuminator does not take the early return. The illuminator's power draw is STATIC, not conditional: `consumePower(0.05f);` (Blocks.java:6767) registers a plain ConsumePower, so the catalog consumePower 0.05 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The illuminator's updateTile (LightBlock.java:104-106, `smoothTime = Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`) only advances smoothTime -- the smoothTime advance is the tick, and drawLight (LightBlock.java:127-128, `Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);`) scales the emitted light by brightness * efficiency; because there is no baseEfficiency-style floor, the light emits at brightness 0 when the gate fails; the folded efficiency is what the efficiency keys prove, and the color config is live since N2443 (source_light_block_sense_color_state / source_light_block_config_color_state, below); the draw rows are live since N2374 (source_light_block_draw_state / source_light_block_draw_light_state, below).
	# LightBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755-756, `return enabled;`) applies -- the power-only fold is EXACT, no deferral needed (the StackConveyor N2180 / Accelerator N2183 precedent). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates.
	# The illuminator is its own family (LightBlock.java:21, `public class LightBlock extends Block{`; LightBuild, LightBlock.java:67, `public class LightBuild extends Building{`), a power / effect block with no parent driver: no existing family state covers it. Class fields: `public float brightness = 0.9f;` (LightBlock.java:22), `public float radius = 200f;` (LightBlock.java:23), `public @Load("@-top") TextureRegion topRegion;` (LightBlock.java:24); constructor `public LightBlock(String name){` (LightBlock.java:26), `hasPower = true;` (LightBlock.java:28), `update = true;` (LightBlock.java:29), `configurable = true;` (LightBlock.java:30), `saveConfig = true;` (LightBlock.java:31), `envEnabled |= Env.space;` (LightBlock.java:32), `swapDiagonalPlacement = true;` (LightBlock.java:33). init sets the light radius and clip (LightBlock.java:40, `lightRadius = radius*2.5f;` with LightBlock.java:41, `lightClipSize = Math.max(lightClipSize, lightRadius * 3f);` and LightBlock.java:42, `emitLight = true;`). Build fields: `public int color = Pal.accent.rgba();` (LightBlock.java:68), `public float smoothTime = 1f;` (LightBlock.java:69).
	# Single def -- illuminator only (brightness 0.75f, radius 140f, graphite 12 / silicon 8 / lead 8, Blocks.java:6763-6767): `illuminator = new LightBlock("illuminator"){{` (Blocks.java:6763) with `requirements(Category.effect, BuildVisibility.lightingOnly, with(Items.graphite, 12, Items.silicon, 8, Items.lead, 8));` (Blocks.java:6764), `brightness = 0.75f;` (Blocks.java:6765), `radius = 140f;` (Blocks.java:6766) and `consumePower(0.05f);` (Blocks.java:6767). No second LightBlock def exists; there is no family split to manage. The color config (LightBlock.java:35, 72-94, 109-127, 132-136) waits for its own slice; the smoothTime advance (LightBlock.java:104-106) is N2189, unified with N2241 (source_light_block_smooth_time_state, below). The draw rows (LightBlock.java:96-102, 127-128) are live since N2374; the read / write / sense rows (LightBlock.java:137-148) wait for their own slices.
	# Documented limits: (1) power-only first pass -- the illuminator's static power consumer (consumePower 0.05f, Blocks.java:6767) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume override -- LightBuild has none, so the BuildingComp default `return enabled;` applies and the power-only fold is EXACT. (3) smoothTime advance DONE (N2189/N2241) -- smoothTime lerp (LightBlock.java:104-106) advances every tick toward the live timeScale; the drawLight radius clamp min(smoothTime, 2f) (LightBlock.java:128) is what the light_radius_scale key proves, and drawLight presentation is live since N2374 (source_light_block_draw_light_state, below). (4) Config/color rows live (N2443) -- config / configured / control / sense / buildConfiguration / onConfigureBuildTapped / config() (LightBlock.java:35, 72-94, 109-127, 132-133) are live in the sense + config pures below (source_light_block_sense_color_state / source_light_block_config_color_state); the logic-executor / picker-UI call sites wait for their own slices. (5) Single def -- illuminator only (brightness 0.75f, radius 140f, graphite 12 / silicon 8 / lead 8); Per-def stat rows live (N2500) -- source_light_block_per_def_stats_state returns the def rows with the class defaults (size 1, brightness 0.9f, radius 200f, no requirements) for an unknown def id; the def sets NO size line, so size 1 is the Block class default (Block.java:215). Init rows live (N2500) -- source_light_block_init_rows_state derives lightRadius = radius*2.5f, lightClipSize = max(in, lightRadius * 3f), emitLight = true (LightBlock.init(), LightBlock.java:39-43). (6) Draw rows live (N2374) -- draw / drawLight (LightBlock.java:96-102, 127-128) are live in the draw pures below; write / read (LightBlock.java:137-148) wait for their own slices. (7) DrawPlace rows live (N2439) -- drawPlace / changePlacementPath / minimapColor (LightBlock.java:48-66) are live in the draw-place pure below; the placement-UI / placer / minimap call sites wait for their own slices.
	# Source lines (all 82 exact exprs, verified verbatim in upstream at RED):
	# - `return build.power.status;`
	# - `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`
	# - `hasConsumers = consumers.length > 0;`
	# - `public class LightBlock extends Block{`
	# - `public float brightness = 0.9f;`
	# - `public float radius = 200f;`
	# - `public @Load("@-top") TextureRegion topRegion;`
	# - `public LightBlock(String name){`
	# - `super(name);`
	# - `hasPower = true;`
	# - `update = true;`
	# - `configurable = true;`
	# - `saveConfig = true;`
	# - `envEnabled |= Env.space;`
	# - `swapDiagonalPlacement = true;`
	# - `config(Integer.class, (LightBuild tile, Integer value) -> tile.color = value);`
	# - `public void init(){`
	# - `lightRadius = radius*2.5f;`
	# - `lightClipSize = Math.max(lightClipSize, lightRadius * 3f);`
	# - `emitLight = true;`
	# - `super.init();`
	# - `public void drawPlace(int x, int y, int rotation, boolean valid){`
	# - `super.drawPlace(x, y, rotation, valid);`
	# - `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);`
	# - `public void changePlacementPath(Seq<Point2> points, int rotation){`
	# - `var placeRadius2 = Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;`
	# - `Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);`
	# - `public int minimapColor(Tile tile){`
	# - `var build = (LightBuild)tile.build;`
	# - `return build == null ? 0 : build.color | 0xff;`
	# - `public class LightBuild extends Building{`
	# - `public int color = Pal.accent.rgba();`
	# - `public float smoothTime = 1f;`
	# - `public void configured(Unit player, Object value){`
	# - `super.configured(player, value);`
	# - `if(!headless) renderer.minimap.update(tile);`
	# - `public void control(LAccess type, double p1, double p2, double p3, double p4){`
	# - `if(type == LAccess.color){`
	# - `color = Tmp.c1.fromDouble(p1).rgba8888();`
	# - `super.control(type, p1, p2, p3, p4);`
	# - `public double sense(LAccess sensor){`
	# - `if(sensor == LAccess.color) return Tmp.c1.set(color).toDoubleBits();`
	# - `return super.sense(sensor);`
	# - `public void draw(){`
	# - `super.draw();`
	# - `Draw.color(Tmp.c1.set(color).a(0.6f));`
	# - `Draw.rect(topRegion, x, y);`
	# - `Draw.color();`
	# - `public void updateTile(){`
	# - `smoothTime = Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`
	# - `public void buildConfiguration(Table table){`
	# - `table.button(Icon.pencil, Styles.cleari, () -> {`
	# - `ui.picker.show(Tmp.c1.set(color).a(0.5f), false, res -> configure(res.rgba()));`
	# - `deselect();`
	# - `}).size(40f);`
	# - `public boolean onConfigureBuildTapped(Building other){`
	# - `if(this == other){`
	# - `return false;`
	# - `return true;`
	# - `public void drawLight(){`
	# - `Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);`
	# - `public Integer config(){`
	# - `return color;`
	# - `public void write(Writes write){`
	# - `super.write(write);`
	# - `write.i(color);`
	# - `public void read(Reads read, byte revision){`
	# - `super.read(read, revision);`
	# - `color = read.i();`
	# - `illuminator = new LightBlock("illuminator"){{`
	# - `requirements(Category.effect, BuildVisibility.lightingOnly, with(Items.graphite, 12, Items.silicon, 8, Items.lead, 8));`
	# - `brightness = 0.75f;`
	# - `radius = 140f;`
	# - `consumePower(0.05f);`
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

static func source_light_block_smooth_time_state(smooth_time: float, time_scale: float, source_delta: float) -> Dictionary:
	# LightBuild.updateTile() does exactly one thing (LightBlock.java:104-106): `smoothTime = Mathf.lerpDelta(smoothTime, timeScale, 0.1f);` (LightBlock.java:105). lerpDelta is Arc's delta-corrected lerp (Mathf.java:430-432, `return lerp(fromValue, toValue, clamp(progress * Time.delta));`), built on lerp (Mathf.java:425-427, `return fromValue + (toValue - fromValue) * progress;`) and clamp to [0, 1] (Mathf.java:402-404, `return Math.max(Math.min(value, 1f), 0f);`); the port already implements it as SourceMathState.source_lerp_delta, so this pure step composes it rather than re-implementing it. source_delta is Time.delta in 60fps ticks (arc Time.java:26, `private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);`); the driver converts its seconds argument with seconds * 60 at the live-loop boundary (the N2093 pump / conveyor precedent). The lerp target is the building's live timeScale, the BuildingComp field (BuildingComp.java:98, `private transient float timeScale = 1f, timeScaleDuration;`), read through timeScale() (BuildingComp.java:599-601, `public float timeScale(){` with `return timeScale;`), decaying back to 1f when its duration runs out (BuildingComp.java:2265-2266, `if((timeScaleDuration -= Time.delta) <= 0f){` / `timeScale = 1f;`); timeScale also scales delta() (BuildingComp.java:1922-1923, `return Time.delta * timeScale;`). smoothTime starts at 1f (LightBlock.java:69, `public float smoothTime = 1f;`). The step returns the advanced smooth_time and the drawLight radius clamp (LightBlock.java:127-128, `Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);`): light_radius_scale is min(smooth_time, 2f), the factor scaling lightRadius; drawLight presentation is live since N2374 (source_light_block_draw_light_state, below). The updateTile gate (BuildingComp.java:2276, `if(enabled || !block.noUpdateDisabled){`) always runs for a LightBlock because noUpdateDisabled defaults false (Block.java:170, `public boolean noUpdateDisabled = false;`), so the driver advances unconditionally.
	# Source lines (the 12 new exact exprs, verified verbatim in upstream at RED):
	# - `return lerp(fromValue, toValue, clamp(progress * Time.delta));`
	# - `return fromValue + (toValue - fromValue) * progress;`
	# - `return Math.max(Math.min(value, 1f), 0f);`
	# - `private transient float timeScale = 1f, timeScaleDuration;`
	# - `public float timeScale(){`
	# - `return timeScale;`
	# - `if((timeScaleDuration -= Time.delta) <= 0f){`
	# - `timeScale = 1f;`
	# - `private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);`
	# - `return Time.delta * timeScale;`
	# - `if(enabled || !block.noUpdateDisabled){`
	# - `public boolean noUpdateDisabled = false;`
	var advanced: float = source_math_state.source_lerp_delta(smooth_time, time_scale, 0.1, source_delta)
	return {"smooth_time": advanced, "light_radius_scale": minf(advanced, 2.0)}

static func source_light_block_draw_state(x_value: float, y_value: float, color_value: int) -> Dictionary:
	# The draw rows (LightBuild.draw(), LightBlock.java:96-102), the pure draw-call dict -- the port never draws for real (the N2356 ShockwaveTower pattern: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void draw(){`
	# `super.draw();`
	# `Draw.color(Tmp.c1.set(color).a(0.6f));`
	# `Draw.rect(topRegion, x, y);`
	# `Draw.color();`
	# topRegion is the `@-top` region (`public @Load("@-top") TextureRegion topRegion;`, LightBlock.java:24); the color is `public int color = Pal.accent.rgba();` (LightBlock.java:68), tinted at alpha 0.6f -- NOT the 0.5f picker alpha (buildConfiguration, LightBlock.java:112). The color is an explicit param: it is NOT frame state (the color config is live since N2443, source_light_block_config_color_state, below). super.draw() is Building.draw() (the base region); the pure records that the super call happens, not its content (the BaseTurret draw_place precedent). Draw never runs in the tick, so there is no tick wiring (pure-only). Draw rows live (N2374).
	var top_call: Dictionary = {
		"call": "Draw.rect(topRegion, x, y);",
		"region": "topRegion",
		"color": color_value,
		"alpha": SOURCE_LIGHT_BLOCK_DRAW_TOP_ALPHA,
		"x": x_value,
		"y": y_value,
	}
	return {
		"super_draw_called": true,
		"super_draw_expr": "super.draw();",
		"color_expr": "Draw.color(Tmp.c1.set(color).a(0.6f));",
		"rect_expr": "Draw.rect(topRegion, x, y);",
		"reset_expr": "Draw.color();",
		"x": x_value,
		"y": y_value,
		"color": color_value,
		"top_alpha": SOURCE_LIGHT_BLOCK_DRAW_TOP_ALPHA,
		"top_call": top_call,
	}

static func source_light_block_draw_light_state(x_value: float, y_value: float, color_value: int, smooth_time: float, light_radius: float, brightness: float, efficiency: float) -> Dictionary:
	# The drawLight rows (LightBuild.drawLight(), LightBlock.java:126-128), the pure draw-call dict:
	# `public void drawLight(){`
	# `Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);`
	# lightRadius is radius*2.5f (`lightRadius = radius*2.5f;`, LightBlock.java:40); brightness 0.9f / radius 200f are the class defaults (`public float brightness = 0.9f;` / `public float radius = 200f;`, LightBlock.java:22-23), overridden by the illuminator def to 0.75f / 140f (Blocks.java:6765-6766), so the def lightRadius is 350. The light color is Tmp.c1.set(color) with NO .a() call -- full alpha, unlike the 0.6f draw alpha. The radius clamp min(smoothTime, 2f) is the same clamp the N2189/N2241 smooth_time pure proves as light_radius_scale; smoothTime (`public float smoothTime = 1f;`, LightBlock.java:69) and efficiency ride the live frame, while lightRadius / brightness are caller-supplied so the pure stays def-agnostic (the N2356 range precedent) -- the init row is live since N2500 (source_light_block_init_rows_state, below). An unpowered illuminator emits at brightness 0 (the N2185 fold: brightness * efficiency with efficiency 0). Draw never runs in the tick, so there is no tick wiring (pure-only). Draw rows live (N2374).
	var light_radius_scale: float = minf(smooth_time, 2.0)
	var light_brightness: float = brightness * efficiency
	var light_call: Dictionary = {
		"call": "Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);",
		"x": x_value,
		"y": y_value,
		"radius": light_radius * light_radius_scale,
		"color": color_value,
		"brightness": light_brightness,
	}
	return {
		"light_expr": "Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);",
		"x": x_value,
		"y": y_value,
		"color": color_value,
		"smooth_time": smooth_time,
		"light_radius": light_radius,
		"brightness": brightness,
		"efficiency": efficiency,
		"light_radius_scale": light_radius_scale,
		"light_radius_value": light_radius * light_radius_scale,
		"light_brightness": light_brightness,
		"light_call": light_call,
	}

static func source_light_block_draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, radius: float, offset: float, build_color: Variant) -> Dictionary:
	# The draw-place rows (LightBlock.drawPlace(), LightBlock.java:48-53; changePlacementPath(), LightBlock.java:55-59; minimapColor(), LightBlock.java:61-66), the pure draw-call dict -- the port never draws for real (the N2356 ShockwaveTower / N2396 MassDriver drawPlace pattern: the pure returns the draw calls as data). Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void drawPlace(int x, int y, int rotation, boolean valid){`
	# `super.drawPlace(x, y, rotation, valid);`
	# `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);`
	# `public void changePlacementPath(Seq<Point2> points, int rotation){`
	# `var placeRadius2 = Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;`
	# `Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);`
	# `public int minimapColor(Tile tile){`
	# `var build = (LightBuild)tile.build;`
	# `return build == null ? 0 : build.color | 0xff;`
	# The dash circle uses the Block offset (`offset = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761 -- 0 for the size-1 LightBlock, `public int size = 1;`, Block.java:215), unlike the MassDriver dash circle (no offset, MassDriver.java:83). tilesize is the Java constant 8 (`public static final int tilesize = 8;`, Vars.java:135 -- NEVER the game tile_size 32, the N2375 lesson). Pal.placing IS the accent color (`placing = accent,`, Pal.java:95). radius is the class default 200f (`public float radius = 200f;`, LightBlock.java:23), overridden by the illuminator def to 140f (`radius = 140f;`, Blocks.java:6766) -- caller-supplied, def-agnostic (the N2356 range precedent). The calculateNodes callee is `public static void calculateNodes(Seq<Point2> points, Block block, int rotation, Boolf2<Point2, Point2> overlapper){` (Placement.java:92); the pure records the call + predicate threshold, it does NOT port the node algorithm (the N2396 CALL precedent -- the port has no placement point list). The color is `public int color = Pal.accent.rgba();` (LightBlock.java:68); build_color is a Variant null-or-int -- null when the tile has no build. super.drawPlace is Block.drawPlace (drawPotentialLinks + drawOverlay, SourceBlockDrawState) and is NOT modeled here: the pure records that the super call happens, not its content (the BaseTurret draw_place precedent). Pure-only: drawPlace never runs in the tick -- it is called by the placement UI, changePlacementPath by the placer, minimapColor by the minimap, and the call sites wait for UI slices. draw() / drawLight() are untouched (live since N2374). DrawPlace rows live (N2439).
	var tile_size: float = 8.0
	var place_x: float = float(tile_x) * tile_size + offset
	var place_y: float = float(tile_y) * tile_size + offset
	var dash_radius: float = radius * 0.75
	var place_radius2: float = pow(radius * 0.7 / tile_size, 2.0) * 3.0
	var minimap_color: int = 0 if build_color == null else (int(build_color) | 0xff)
	var super_place_call: Dictionary = {
		"call": "super.drawPlace(x, y, rotation, valid);",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotation": rotation,
		"valid": valid,
	}
	var dash_call: Dictionary = {
		"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);",
		"x": place_x,
		"y": place_y,
		"radius": dash_radius,
		"color": "Pal.placing",
	}
	var calculate_nodes_call: Dictionary = {
		"call": "Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);",
		"callee": "Placement.calculateNodes",
		"rotation": rotation,
		"predicate": "point.dst2(other) <= placeRadius2",
		"predicate_threshold": place_radius2,
	}
	return {
		"super_expr": "super.drawPlace(x, y, rotation, valid);",
		"dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);",
		"place_radius2_expr": "var placeRadius2 = Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;",
		"calculate_nodes_expr": "Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);",
		"minimap_expr": "return build == null ? 0 : build.color | 0xff;",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"place_x": place_x,
		"place_y": place_y,
		"rotation": rotation,
		"valid": valid,
		"radius": radius,
		"offset": offset,
		"build_color": build_color,
		"dash_radius": dash_radius,
		"super_place_call": super_place_call,
		"dash_call": dash_call,
		"place_radius2": place_radius2,
		"calculate_nodes_call": calculate_nodes_call,
		"minimap_color": minimap_color,
	}

static func source_light_block_sense_color_state(sensor: String, color: int, super_value: Variant = null) -> Dictionary:
	# The sense rows (LightBuild.sense(), LightBlock.java:90-94), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor){`
	# `if(sensor == LAccess.color) return Tmp.c1.set(color).toDoubleBits();`
	# `return super.sense(sensor);`
	# The LAccess token is the exact enum name `color("to");` (LAccess.java:84 -- NOTE: LAccess is mindustry.logic.LAccess, not arc, the N2437 lesson). super.sense is the BuildingComp switch (BuildingComp.java:2093-2125), already modeled by SourceBuildingSenseState (the N2437 precedent), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch. The color value is arc's double-bits encoding (Color.java:756-758):
	# `public double toDoubleBits(){`
	# `return toDoubleBits(r, g, b, a);`
	# `return Double.longBitsToDouble(Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);`
	# i.e. a double denormal whose raw bits are the rgba8888 int zero-extended. Tmp.c1.set(color) unpacks the int (Color.java:504-506):
	# `public Color set(int rgba){`
	# `return rgba8888(rgba);`
	# with R in the top byte (Color.java:286-292):
	# `r = ((value & 0xff000000) >>> 24) / 255f;`
	# and rgba8888() repacks it (Color.java:236-238):
	# `return ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255);`
	# The float32 set(int)->rgba8888() round-trip is EXACT for every channel 0-255 (verified by float32 emulation: (int)((c/255f)*255f) == c for all c), so the denormal's raw bits ARE the color int, and the double value is exactly float(unsigned_rgba) * 2^-1074 (verified for 200k random 32-bit values + endpoints -- a denormal double with fraction B < 2^52 has value B * 2^-1074, exactly representable, so the IEEE multiply is exact). GDScript ints are 64-bit while the Java color is a signed 32-bit int, so the pure zero-extends with `color & 0xffffffff` before the float conversion (a negative Java int like -1 reads as the unsigned 0xffffffff). 5e-324 is the 2^-1074 literal (the smallest positive double denormal); the proof verifies the encoding by dividing back (value / 5e-324 == float(unsigned), exact) instead of is_equal_approx, whose epsilon would swallow any denormal difference. The color is `public int color = Pal.accent.rgba();` (LightBlock.java:68), Pal.accent being `accent = Color.valueOf("ffd37f"),` (Pal.java:79 -- a 6-digit hex, so valueOf defaults alpha to 255 and the default color is 0xffd37fff). Pure-only, like the N2437 sense pure: the tick never calls sense -- sense is called by logic, and the logic call site waits for a logic-executor slice. Config/color rows live (N2443).
	var delegated: bool = sensor != "color"
	var value: Variant = super_value
	if sensor == "color":
		value = float(color & 0xffffffff) * 5e-324
	return {
		"sense_expr": "if(sensor == LAccess.color) return Tmp.c1.set(color).toDoubleBits();",
		"super_expr": "return super.sense(sensor);",
		"double_bits_expr": "return Double.longBitsToDouble(Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);",
		"sensor": sensor,
		"color": color,
		"super_value": super_value,
		"delegated": delegated,
		"value": value,
	}

static func source_light_block_config_color_state(color: int, action: String, action_value: Variant, is_self_tap: bool, headless: bool) -> Dictionary:
	# The config / color rows (LightBlock config(Integer), LightBlock.java:35; configured(), LightBlock.java:72-76; control(), LightBlock.java:78-88; buildConfiguration(), LightBlock.java:109-115; onConfigureBuildTapped(), LightBlock.java:117-127; config(), LightBlock.java:132-133), the pure config fold -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `config(Integer.class, (LightBuild tile, Integer value) -> tile.color = value);`
	# `public void configured(Unit player, Object value){`
	# `super.configured(player, value);`
	# `if(!headless) renderer.minimap.update(tile);`
	# `public void control(LAccess type, double p1, double p2, double p3, double p4){`
	# `if(type == LAccess.color){`
	# `color = Tmp.c1.fromDouble(p1).rgba8888();`
	# `super.control(type, p1, p2, p3, p4);`
	# `public void buildConfiguration(Table table){`
	# `table.button(Icon.pencil, Styles.cleari, () -> {`
	# `ui.picker.show(Tmp.c1.set(color).a(0.5f), false, res -> configure(res.rgba()));`
	# `deselect();`
	# `}).size(40f);`
	# `public boolean onConfigureBuildTapped(Building other){`
	# `if(this == other){`
	# `return false;`
	# `return true;`
	# `public Integer config(){`
	# `return color;`
	# The action is a discriminated input: "configure" applies the config(Integer) handler (color = action_value, the Integer value), "control" applies the LAccess.color control (color = action_value, the caller-supplied raw low 32 bits of p1 -- fromDouble takes the low 32 bits of the double's raw bits, Color.java:174-176, `return rgba8888((int)(Double.doubleToRawLongBits(value)));`, and the set->rgba8888 round-trip is EXACT, so the control color IS those bits; GDScript has no double bitcast, so the logic executor owns the bitcast and supplies the int, the N2435 caller-supplied precedent), "none" leaves the color untouched. The super configured() runs the config handler with NO equality check anywhere in the chain (BuildingComp.java:1429, `block.configurations.get(type).get(this, value);`; InputHandler.tileConfig, InputHandler.java:706-728, calls configured unconditionally), so a configure updates the minimap even when the new color equals the old one: minimap_updated = (action is configure/control) && !headless, with NO color-changed condition (Java-verified; the brief's formula carried a color-changed condition Java does not have). The picker is recorded as a CALL (icon pencil, size 40f, picker alpha 0.5f -- NOT the 0.6f draw alpha), the UI itself is NOT ported (the N2396 CALL precedent). The tap result records onConfigureBuildTapped: a self tap deselects and returns false, any other tap returns true. config() returns the post-action color. The color field is `public int color = Pal.accent.rgba();` (LightBlock.java:68); headless is caller-supplied (Vars.headless). Pure-only: config/control run from the picker UI and the logic executor, the tap from the configure UI -- the call sites wait for their own slices. Config/color rows live (N2443).
	var is_action: bool = action == "configure" or action == "control"
	var new_color: int = color
	if is_action:
		new_color = int(action_value)
	var minimap_updated: bool = is_action and not headless
	var tapped_result: Dictionary = {"deselect": is_self_tap, "return_value": not is_self_tap}
	var picker_call: Dictionary = {"icon": "pencil", "size": 40.0, "color_a": 0.5}
	return {
		"configure_expr": "config(Integer.class, (LightBuild tile, Integer value) -> tile.color = value);",
		"configured_expr": "if(!headless) renderer.minimap.update(tile);",
		"control_expr": "color = Tmp.c1.fromDouble(p1).rgba8888();",
		"picker_expr": "ui.picker.show(Tmp.c1.set(color).a(0.5f), false, res -> configure(res.rgba()));",
		"tapped_expr": "public boolean onConfigureBuildTapped(Building other){",
		"config_expr": "return color;",
		"color": new_color,
		"minimap_updated": minimap_updated,
		"tapped_result": tapped_result,
		"picker_call": picker_call,
		"config_value": new_color,
		"action": action,
		"action_value": action_value,
		"is_self_tap": is_self_tap,
		"headless": headless,
	}

static func source_light_block_per_def_stats_state(def_id: String) -> Dictionary:
	# The per-def stat rows (the VERIFICATION slice: the values
	# are already constants in this driver's header -- the
	# N2304 / N2442 / N2489 / N2490 precedent): the def's size /
	# brightness / radius / requirements for illuminator, the
	# single LightBlock def (Blocks.java:6763-6767), with the
	# CLASS defaults for an unknown def id (the N2304 fallback
	# precedent). The def block (each exact expr on ONE comment
	# line, the N2148 lesson):
	# `illuminator = new LightBlock("illuminator"){{`
	# `requirements(Category.effect, BuildVisibility.lightingOnly, with(Items.graphite, 12, Items.silicon, 8, Items.lead, 8));`
	# `brightness = 0.75f;`
	# `radius = 140f;`
	# The class defaults (LightBlock.java:22-23, Block.java:215/356):
	# `public float brightness = 0.9f;`
	# `public float radius = 200f;`
	# `public int size = 1;`
	# `public ItemStack[] requirements = {};`
	# LightBlock extends Block (`public class LightBlock extends Block{`,
	# LightBlock.java:21). The def sets NO size line, so size 1
	# is the inherited Block class default (Block.java:215) --
	# the N2494 precedent: the size symbol cites Block.java,
	# not the def block. The requirements dict is the {item:
	# amount} dict from the def (the N2490 precedent); the
	# catalog carries the same rows as an Array of {item,
	# amount} dicts (content_registry.json, illuminator) but
	# NO size / brightness / radius keys -- those values come
	# from Java only. The requirements call carries
	# BuildVisibility.lightingOnly -- recorded, NOT modeled
	# (visibility is not modeled). An unknown def id falls
	# back to the CLASS defaults -- size 1, brightness 0.9f,
	# radius 200f, and NO requirements (the Block default is
	# the empty array). Pure-only: the caller reads it; the
	# existing pures are unchanged.
	if def_id == "illuminator":
		return {
			"size": 1,
			"brightness": 0.75,
			"radius": 140.0,
			"requirements": {"graphite": 12, "silicon": 8, "lead": 8},
		}
	return {
		"size": 1,
		"brightness": 0.9,
		"radius": 200.0,
		"requirements": {},
	}


static func source_light_block_init_rows_state(radius: float, light_clip_size_in: float) -> Dictionary:
	# The init rows (LightBlock.init(), LightBlock.java:39-43):
	# `lightRadius = radius*2.5f;`
	# `lightClipSize = Math.max(lightClipSize, lightRadius * 3f);`
	# `emitLight = true;`
	# lightRadius is radius * 2.5f (:40); lightClipSize takes
	# the MAX of the existing value and lightRadius * 3f (:41),
	# so the pure takes the incoming lightClipSize as a
	# caller-supplied input -- a fresh block reads 0f, the
	# field is uninitialized (`public float lightClipSize;`,
	# Block.java:223, Java float default 0f); emitLight is
	# always true (:42). The def radius 140f derives
	# lightRadius 350f / lightClipSize max(in, 1050f); the
	# class radius 200f derives 500f / max(in, 1500f). The
	# later Block.init() maxes (super.init(), LightBlock.java:44
	# -- Block.java:1399 maxes against clipSize, >= size *
	# tilesize = 8 for a size-1 block, and Block.java:1421-1422
	# maxes against lightRadius * 2f) are both subsumed by the
	# * 3f max here, so this pure's result IS the final init
	# value for a LightBlock. Pure-only: the caller
	# (block-init path) reads it; the existing pures are
	# unchanged.
	var light_radius: float = radius * 2.5
	var light_clip_size: float = maxf(light_clip_size_in, light_radius * 3.0)
	return {
		"light_radius": light_radius,
		"light_clip_size": light_clip_size,
		"emit_light": true,
	}


@warning_ignore("unused_parameter")
static func source_light_block_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the light-block tick wiring every
	# tick (LightBuild.updateTile(), LightBlock.java:104-106,
	# only lerps smoothTime toward timeScale
	# (LightBlock.java:105, `smoothTime =
	# Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`), so the
	# drawLight brightness (LightBlock.java:128) follows the
	# folded efficiency; no placed-buildings driver
	# ticks LightBlock blocks, so this driver is the
	# placed-illuminator tick): each placed LightBlock build gets
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
		if not _is_light_block_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_light_block_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_light_block_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# N2189/N2241: the updateTile smoothTime advance runs every tick,
		# unconditionally -- the updateTile gate
		# (BuildingComp.java:2276, `if(enabled ||
		# !block.noUpdateDisabled){`) always runs for a LightBlock
		# because noUpdateDisabled defaults false (Block.java:170).
		# The lerp target is the building's live timeScale
		# (BuildingComp.java:98), read from the sprite meta the
		# port already tracks (default 1.0); the driver converts
		# its seconds argument to Time.delta ticks (seconds * 60,
		# the N2093 pump / conveyor precedent) for the lerpDelta
		# step (LightBlock.java:105, `smoothTime =
		# Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`). A frame
		# bound before N2189/N2241 has no smooth_time key and folds to
		# the Java initial value 1f (LightBlock.java:69) through
		# the .get() default (the N2223 precedent).
		var live_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var advanced: Dictionary = source_light_block_smooth_time_state(float(frame.get("smooth_time", 1.0)), live_time_scale, seconds * source_time_defaults.TICK_RATE)
		frame["smooth_time"] = advanced.get("smooth_time", 1.0)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an illuminator with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the drawLight brightness (LightBlock.java:128)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so an illuminator does not take the early return. The illuminator's power draw is STATIC: `consumePower(0.05f);` (Blocks.java:6767) registers a plain ConsumePower, so the catalog consumePower 0.05 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An illuminator with no power consumer is untouched by the power fold: the tick models no other consumers yet (the updateTile smoothTime advance is N2189/N2241, above), and LightBuild has NO shouldConsume override -- the BuildingComp default `return enabled;` applies, so the power-only fold is EXACT (the N2180/N2183 precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_light_block_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
