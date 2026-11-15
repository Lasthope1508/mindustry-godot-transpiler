import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07BuildTurretPowerStatusTests(unittest.TestCase):
    def test_c07_build_turret_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2184']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178/N2179/N2180/N2181/N2182/N2183 proved the pure power-row
        # pattern on the factory, adjacent-factory, drill, turret,
        # burst-drill, solid-pump, point-defense, tractor-beam,
        # fracker, mechanical-pump, beam-drill, mend-projector,
        # overdrive-projector, force-projector, base-shield,
        # regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower,
        # shockwave-tower, item-bridge, liquid-bridge,
        # stack-conveyor, stack-router, impact-reactor and
        # accelerator drivers -- but the BuildTurret
        # (build-tower, consumePower 3f, Blocks.java:2005) has NO
        # driver at all: it extends BaseTurret
        # (BuildTurret.java:27, `public class BuildTurret extends
        # BaseTurret{`), and SourceTurretBuildState.gd says so
        # explicitly -- "RepairTurret extends Block and
        # BuildTurret extends BaseTurret, so none of them is a
        # TurretBuild" -- so no existing driver matches it.
        # Liquid care: the build tower also consumes nitrogen
        # (consumeLiquid nitrogen 3f/60f, Blocks.java:2006) -- so
        # the row this slice folds is the CONSUMER-side power
        # read (ConsumePower.java:39, `return
        # build.power.status;`), exactly like every
        # pure-consumer slice; the LIQUID side waits for its own
        # slice. The coupling is the build speed: updateTile
        # scales the builder unit by potentialEfficiency
        # (BuildTurret.java:136, `unit.buildSpeedMultiplier(
        # potentialEfficiency * timeScale);` with
        # BuildTurret.java:137, `unit.speedMultiplier(
        # potentialEfficiency * timeScale);`) -- a tower that
        # cannot draw its 3f builds at efficiency 0, while the
        # port without this slice would behave as if
        # power.status were 1.0. N2184 is the build tower's
        # live read: a pure power row over the stamped frame
        # value, folded by the shared machinery into the min
        # efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its
        # own driver, wired into simulate_factory like the
        # accelerator driver (N2183). The family has a SINGLE
        # def: build-tower is the only BuildTurret
        # (Blocks.java:1997) -- there is no second BuildTurret
        # def to split from. The power draw is STATIC:
        # `consumePower(3f);` (Blocks.java:2005) registers a
        # plain ConsumePower, so the catalog consumePower 3.0
        # is present and the plain radar gate
        # (block.properties.has("consumePower")) works -- no
        # RepairTurret-style `or consumesPower` adaptation is
        # needed. BuildTurretBuild DOES override shouldConsume
        # (BuildTurret.java:229-230, `return unit.plans().size
        # > 0 && !isHealSuppressed();`), and updateConsumption
        # forces efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1994,
        # `if(!update){` / efficiency = optionalEfficiency =
        # 0f) -- RED decision: fold power-only and defer the
        # gate (the PointDefenseTurret N2151 precedent); the
        # port tracks no live build-plan state on any
        # placed-building frame, so the driver needs a plans
        # frame input or a documented deferral. Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2184']['source_symbols'],
            [
                'source_build_turret_power_status_row_state_result.row',
                'source_build_turret_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2184']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_build_turret_power_status_row_state_result.row': 'SourceBuildTurretBuildState.source_build_turret_power_status_row_state',
                    'source_build_turret_power_status_row_state_result.has_power_row': 'SourceBuildTurretBuildState.source_build_turret_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2184']['runtime_proof'], '/root/C07BuildTurretPowerStatusProof')
        self.assertEqual(
            ledger['N2184']['tests'],
            [
                'test_c07_build_turret_power_status_registration',
                'test_all_c07_build_turret_power_status_input_evidence_is_exact',
                'test_build_turret_power_status_row_state',
                'test_reference_graph_and_actual_c07_build_turret_power_status',
            ],
        )
        self.assertTrue(ledger['N2184']['deferred_exprs'])

    def test_all_c07_build_turret_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2184']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_build_turret_power_status_row_state_result.row': 'SourceBuildTurretBuildState.source_build_turret_power_status_row_state',
                    'source_build_turret_power_status_row_state_result.has_power_row': 'SourceBuildTurretBuildState.source_build_turret_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2184']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_power_status_row_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new build-turret build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the build
        # tower's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(3f);` (Blocks.java:2005) against a
        # nitrogen draw of `consumeLiquid(Liquids.nitrogen, 3f
        # / 60f);` (Blocks.java:2006) -- the liquid row waits
        # for its own slice.
        # The tower's updateTile (BuildTurret.java:121) syncs
        # the builder unit (BuildTurret.java:126, `rotation =
        # unit.rotation();` with BuildTurret.java:128,
        # `if(unit.activelyBuilding()){`), zeroes efficiency
        # under suppression (BuildTurret.java:132,
        # `if(checkSuppression()){` with BuildTurret.java:133,
        # `efficiency = potentialEfficiency = 0f;`) and scales
        # the unit's build speed by potentialEfficiency
        # (BuildTurret.java:136, `unit.buildSpeedMultiplier(
        # potentialEfficiency * timeScale);`) -- so a tower
        # that cannot draw its 3f never builds; the folded
        # efficiency is what the efficiency keys prove, and
        # the plan search / follow / validate advance waits
        # for its own slice. `warmup` lerps toward efficiency
        # while actively building (BuildTurret.java:139,
        # `warmup = Mathf.lerpDelta(warmup,
        # unit.activelyBuilding() ? efficiency : 0f, 0.1f);`).
        # The tower searches team plans on a timer
        # (BuildTurret.java:156, `}else if(unit.buildPlan()
        # == null && timer(timerTarget, targetInterval)){`
        # with BuildTurret.java:157, `Queue<BlockPlan> blocks
        # = team.data().plans;`) and mimics nearby builders
        # (BuildTurret.java:176, `Units.nearby(team, x, y,
        # range, u -> {`), validating each plan
        # (BuildTurret.java:204, `boolean valid =` with
        # BuildTurret.java:205, `!(lastPlan != null &&
        # lastPlan.removed) &&`) -- the plan state waits for
        # its own slice. shouldConsume needs a live plan
        # (BuildTurret.java:229, `public boolean
        # shouldConsume(){` with BuildTurret.java:230,
        # `return unit.plans().size > 0 &&
        # !isHealSuppressed();`) -- RED decision: fold
        # power-only and defer the gate (the PointDefenseTurret
        # N2151 precedent); the port tracks no live build-plan
        # state on any placed-building frame. canConsume
        # (BuildingComp.java:1917, `public boolean canConsume(){`
        # with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) and edelta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`) are the surrounding gates.
        # The build tower is its own family
        # (BuildTurret.java:27, `public class BuildTurret
        # extends BaseTurret{`; BuildTurretBuild,
        # BuildTurret.java:92, `public class BuildTurretBuild
        # extends BaseTurretBuild implements ControlBlock,
        # RotBlock{`), a defense / effect block, NOT a
        # TurretBuild: SourceTurretBuildState.gd excludes it
        # explicitly, and BaseTurretBuild
        # (BaseTurret.java:113, `public class BaseTurretBuild
        # extends Building implements Ranged, RotBlock{`)
        # overrides neither shouldConsume nor updateTile -- the
        # gate and the tick both come from BuildTurretBuild
        # itself. Class fields: `public final int timerTarget
        # = timers++, timerTarget2 = timers++;`
        # (BuildTurret.java:28), `public int targetInterval =
        # 15;` (BuildTurret.java:29), `public float buildSpeed
        # = 1f;` (BuildTurret.java:33), `public float
        # buildBeamOffset = 5f;` (BuildTurret.java:34),
        # `public float elevation = -1f;`
        # (BuildTurret.java:38), `public Color heatColor =
        # Pal.accent.cpy().a(0.9f);` (BuildTurret.java:39);
        # constructor `public BuildTurret(String name){`
        # (BuildTurret.java:41), `group =
        # BlockGroup.turrets;` (BuildTurret.java:43), `sync =
        # false;` (BuildTurret.java:44), `rotateSpeed = 10f;`
        # (BuildTurret.java:45), `suppressable = true;`
        # (BuildTurret.java:46). init lifts the elevation and
        # builds the hidden builder unit type
        # (BuildTurret.java:53, `if(elevation < 0) elevation =
        # size / 2f;` with BuildTurret.java:56, `unitType = new
        # UnitType("turret-unit-" + name){{`). Build fields:
        # `public BlockUnitc unit = (BlockUnitc)unitType.
        # create(team);` (BuildTurret.java:93), `public
        # @Nullable Unit following;` (BuildTurret.java:94),
        # `public @Nullable BlockPlan lastPlan;`
        # (BuildTurret.java:95), `public float warmup;`
        # (BuildTurret.java:96). Single def -- build-tower
        # only (size 3, range 200f, buildSpeed 1.5f, silicon
        # 150 / oxide 40 / thorium 60, Blocks.java:1997-2006).
        # No second BuildTurret def exists; there is no family
        # split to manage.
        self.assertIn('return build.power.status;', build_turret)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', build_turret)
        self.assertIn('hasConsumers = consumers.length > 0;', build_turret)
        self.assertIn('public class BuildTurret extends BaseTurret{', build_turret)
        self.assertIn('public final int timerTarget = timers++, timerTarget2 = timers++;', build_turret)
        self.assertIn('public int targetInterval = 15;', build_turret)
        self.assertIn('public float buildSpeed = 1f;', build_turret)
        self.assertIn('public float buildBeamOffset = 5f;', build_turret)
        self.assertIn('public float elevation = -1f;', build_turret)
        self.assertIn('public Color heatColor = Pal.accent.cpy().a(0.9f);', build_turret)
        self.assertIn('public BuildTurret(String name){', build_turret)
        self.assertIn('group = BlockGroup.turrets;', build_turret)
        self.assertIn('sync = false;', build_turret)
        self.assertIn('rotateSpeed = 10f;', build_turret)
        self.assertIn('suppressable = true;', build_turret)
        self.assertIn('public void init(){', build_turret)
        self.assertIn('super.init();', build_turret)
        self.assertIn('if(elevation < 0) elevation = size / 2f;', build_turret)
        self.assertIn('unitType = new UnitType("turret-unit-" + name){{', build_turret)
        self.assertIn('buildBeamOffset = BuildTurret.this.buildBeamOffset;', build_turret)
        self.assertIn('buildRange = BuildTurret.this.range;', build_turret)
        self.assertIn('buildSpeed = BuildTurret.this.buildSpeed;', build_turret)
        self.assertIn('constructor = BlockUnitUnit::create;', build_turret)
        self.assertIn('public void afterPatch(){', build_turret)
        self.assertIn('super.afterPatch();', build_turret)
        self.assertIn('unitType.rotateSpeed = rotateSpeed;', build_turret)
        self.assertIn('unitType.buildBeamOffset = buildBeamOffset;', build_turret)
        self.assertIn('unitType.buildRange = range;', build_turret)
        self.assertIn('unitType.buildSpeed = buildSpeed;', build_turret)
        self.assertIn('public void setStats(){', build_turret)
        self.assertIn('super.setStats();', build_turret)
        self.assertIn('stats.addPercent(Stat.buildSpeed, buildSpeed);', build_turret)
        self.assertIn('public TextureRegion[] icons(){', build_turret)
        self.assertIn('return new TextureRegion[]{baseRegion, region};', build_turret)
        self.assertIn('public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{', build_turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)unitType.create(team);', build_turret)
        self.assertIn('public @Nullable Unit following;', build_turret)
        self.assertIn('public @Nullable BlockPlan lastPlan;', build_turret)
        self.assertIn('public float warmup;', build_turret)
        self.assertIn('unit.rotation(90f);', build_turret)
        self.assertIn('public boolean canControl(){', build_turret)
        self.assertIn('return true;', build_turret)
        self.assertIn('public float buildRotation(){', build_turret)
        self.assertIn('return unit.rotation();', build_turret)
        self.assertIn('public Unit unit(){', build_turret)
        self.assertIn('unit.tile(this);', build_turret)
        self.assertIn('unit.team(team);', build_turret)
        self.assertIn('public void updateTile(){', build_turret)
        self.assertIn('rotation = unit.rotation();', build_turret)
        self.assertIn('if(unit.activelyBuilding()){', build_turret)
        self.assertIn('unit.lookAt(angleTo(unit.buildPlan()));', build_turret)
        self.assertIn('if(checkSuppression()){', build_turret)
        self.assertIn('efficiency = potentialEfficiency = 0f;', build_turret)
        self.assertIn('unit.buildSpeedMultiplier(potentialEfficiency * timeScale);', build_turret)
        self.assertIn('unit.speedMultiplier(potentialEfficiency * timeScale);', build_turret)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);', build_turret)
        self.assertIn('if(!isControlled()){', build_turret)
        self.assertIn('unit.updateBuilding(true);', build_turret)
        self.assertIn('if(following != null){', build_turret)
        self.assertIn('if(!following.isValid() || !following.activelyBuilding()){', build_turret)
        self.assertIn('unit.plans().clear();', build_turret)
        self.assertIn('unit.plans().addFirst(following.buildPlan());', build_turret)
        self.assertIn('lastPlan = null;', build_turret)
        self.assertIn('}else if(unit.buildPlan() == null && timer(timerTarget, targetInterval)){', build_turret)
        self.assertIn('Queue<BlockPlan> blocks = team.data().plans;', build_turret)
        self.assertIn('if(within(block.x * tilesize, block.y * tilesize, range)){', build_turret)
        self.assertIn('unit.addBuild(new BuildPlan(block.x, block.y, block.rotation, block.block, block.config));', build_turret)
        self.assertIn('blocks.addLast(blocks.removeIndex(i));', build_turret)
        self.assertIn('lastPlan = block;', build_turret)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', build_turret)
        self.assertIn('if(u.canBuild() && u.activelyBuilding()){', build_turret)
        self.assertIn('BuildPlan plan = u.buildPlan();', build_turret)
        self.assertIn('Building build = world.build(plan.x, plan.y);', build_turret)
        self.assertIn('if(build instanceof ConstructBuild && within(build, range)){', build_turret)
        self.assertIn('following = u;', build_turret)
        self.assertIn('}else if(unit.buildPlan() != null){', build_turret)
        self.assertIn('BuildPlan req = unit.buildPlan();', build_turret)
        self.assertIn('if(!req.breaking && timer.get(timerTarget2, 30f)){', build_turret)
        self.assertIn('for(Player player : team.data().players){', build_turret)
        self.assertIn('if(player.isBuilder() && player.unit().activelyBuilding() && player.unit().buildPlan().samePos(req) && player.unit().buildPlan().breaking){', build_turret)
        self.assertIn('unit.plans().removeFirst();', build_turret)
        self.assertIn('boolean valid =', build_turret)
        self.assertIn('!(lastPlan != null && lastPlan.removed) &&', build_turret)
        self.assertIn('((req.tile() != null && req.tile().build instanceof ConstructBuild cons && cons.current == req.block) ||', build_turret)
        self.assertIn('Build.validBreak(unit.team(), req.x, req.y) :', build_turret)
        self.assertIn('Build.validPlace(req.block, unit.team(), req.x, req.y, req.rotation)));', build_turret)
        self.assertIn('if(!valid){', build_turret)
        self.assertIn('unit.plans().remove(b -> b.build() == this);', build_turret)
        self.assertIn('unit.updateBuildLogic();', build_turret)
        self.assertIn('public boolean shouldConsume(){', build_turret)
        self.assertIn('return unit.plans().size > 0 && !isHealSuppressed();', build_turret)
        self.assertIn('public void draw(){', build_turret)
        self.assertIn('Draw.rect(baseRegion, x, y);', build_turret)
        self.assertIn('Draw.color();', build_turret)
        self.assertIn('Draw.z(Layer.turret);', build_turret)
        self.assertIn('Drawf.shadow(region, x - elevation, y - elevation, rotation - 90);', build_turret)
        self.assertIn('Draw.rect(region, x, y, rotation - 90);', build_turret)
        self.assertIn('if(glowRegion.found()){', build_turret)
        self.assertIn('Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);', build_turret)
        self.assertIn('if(efficiency > 0){', build_turret)
        self.assertIn('unit.drawBuilding();', build_turret)
        self.assertIn('public float warmup(){', build_turret)
        self.assertIn('return warmup;', build_turret)
        self.assertIn('public void write(Writes write){', build_turret)
        self.assertIn('super.write(write);', build_turret)
        self.assertIn('write.f(rotation);', build_turret)
        self.assertIn('TypeIO.writePlans(write, unit.plans().toArray(BuildPlan.class));', build_turret)
        self.assertIn('public void read(Reads read, byte revision){', build_turret)
        self.assertIn('super.read(read, revision);', build_turret)
        self.assertIn('rotation = read.f();', build_turret)
        self.assertIn('unit.rotation(rotation);', build_turret)
        self.assertIn('var reqs = TypeIO.readPlans(read);', build_turret)
        self.assertIn('public double sense(LAccess sensor){', build_turret)
        self.assertIn('case buildX, buildY -> unit.sense(sensor);', build_turret)
        self.assertIn('default -> super.sense(sensor);', build_turret)
        self.assertIn('public Object senseObject(LAccess sensor){', build_turret)
        self.assertIn('case building, breaking -> unit.senseObject(sensor);', build_turret)
        self.assertIn('default -> super.senseObject(sensor);', build_turret)
        self.assertIn('public class BaseTurret extends Block{', build_turret)
        self.assertIn('public class BaseTurretBuild extends Building implements Ranged, RotBlock{', build_turret)
        self.assertIn('buildTower = new BuildTurret("build-tower"){{', build_turret)
        self.assertIn('requirements(Category.effect, with(Items.silicon, 150, Items.oxide, 40, Items.thorium, 60));', build_turret)
        self.assertIn('outlineColor = Pal.darkOutline;', build_turret)
        self.assertIn('range = 200f;', build_turret)
        self.assertIn('size = 3;', build_turret)
        self.assertIn('buildSpeed = 1.5f;', build_turret)
        self.assertIn('consumePower(3f);', build_turret)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 3f / 60f);', build_turret)
        self.assertIn('return enabled;', build_turret)
        self.assertIn('public boolean canConsume(){', build_turret)
        self.assertIn('return potentialEfficiency > 0;', build_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', build_turret)
        self.assertIn('if(!update){', build_turret)
        self.assertIn('return efficiency * delta();', build_turret)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', build_turret)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', build_turret)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_build_turret_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_build_turret_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no plan / follow /
        # warmup keys: the plan search (BuildTurret.java:156-167)
        # and the mimic / validate advance
        # (BuildTurret.java:176-225) wait for their own slices, so
        # the build-speed fold is what the efficiency keys prove.
        # The efficiency_zero_at_no_power key proves the folded
        # efficiency is 0 -- it does NOT claim the tower stops
        # building, because shouldConsume also needs a live plan
        # (BuildTurret.java:230) and the plan state is deferred;
        # the power row is the only hard gate here.
        proof = BUILD_TURRET_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'build_turret_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'build_turret_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
