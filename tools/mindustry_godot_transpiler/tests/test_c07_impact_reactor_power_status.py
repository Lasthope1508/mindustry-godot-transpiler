import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ImpactReactorPowerStatusTests(unittest.TestCase):
    def test_c07_impact_reactor_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2182']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178/N2179/N2180/N2181 proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower,
        # shockwave-tower, item-bridge, liquid-bridge,
        # stack-conveyor and stack-router drivers -- but the
        # ImpactReactor (impact-reactor, consumePower 25f,
        # Blocks.java:2642) has NO driver at all: it extends
        # PowerGenerator (ImpactReactor.java:17, `public class
        # ImpactReactor extends PowerGenerator{`), not a factory
        # or crafter or bridge or conveyor or router, so no
        # existing driver matches it.
        # Consume-vs-produce care: the reactor is a GENERATOR --
        # `outputsPower = consumesPower = true;`
        # (ImpactReactor.java:28) with powerProduction 130f
        # (Blocks.java:2636) against a 25f draw -- so the row
        # this slice folds is the CONSUMER-side read
        # (ConsumePower.java:39, `return build.power.status;`),
        # exactly like every pure-consumer slice; the PRODUCER
        # side (`getPowerProduction()`,
        # PowerGenerator.java:156-158, `return enabled ?
        # powerProduction * productionEfficiency : 0f;`, with
        # `productionEfficiency = Mathf.pow(warmup, 5f);`,
        # ImpactReactor.java:100) waits for its own slice. The
        # coupling is the warmup gate (ImpactReactor.java:79,
        # `if(efficiency >= 0.9999f && power.status >= 0.99f){`):
        # a reactor that cannot draw its 25f never warms up and
        # never produces, while the port without this slice would
        # behave as if power.status were 1.0. N2182 is the
        # impact reactor's live read: a pure power row over the
        # stamped frame value, folded by the shared machinery
        # into the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its
        # own driver, wired into simulate_factory like the
        # stack-router driver (N2181).
        # The family has a SINGLE def: impact-reactor is the only
        # ImpactReactor (Blocks.java:2632) -- there is no second
        # ImpactReactor def to split from. The reactor also
        # consumes an item (blast-compound, Blocks.java:2643)
        # and a liquid (cryofluid 0.25f, Blocks.java:2644) --
        # the tick models the power row only; the item / liquid
        # rows wait for their own slices, so the folded
        # efficiency is the min over the modeled consumers
        # (power only). The power draw is STATIC:
        # `consumePower(25f);` (Blocks.java:2642) registers a
        # plain ConsumePower, so the catalog consumePower 25.0
        # is present and the plain radar gate
        # (block.properties.has("consumePower")) works -- no
        # RepairTurret-style `or consumesPower` adaptation is
        # needed. ImpactReactorBuild has NO shouldConsume
        # override (nor does GeneratorBuild / PowerGenerator),
        # so the BuildingComp default applies
        # (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with BuildingComp.java:756, `return
        # enabled;`), and updateConsumption forces efficiency
        # to zero when the gate is false (BuildingComp.java:1960,
        # `boolean update = shouldConsume() &&
        # productionValid();` + 1992-1994, `if(!update){` /
        # efficiency = optionalEfficiency = 0f). There is NO
        # gate to defer here: the power-only fold is EXACT for
        # this family, because the only gate is `enabled`,
        # which the driver already checks. Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2182']['source_symbols'],
            [
                'source_impact_reactor_power_status_row_state_result.row',
                'source_impact_reactor_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2182']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_power_status_row_state_result.row': 'SourceImpactReactorBuildState.source_impact_reactor_power_status_row_state',
                    'source_impact_reactor_power_status_row_state_result.has_power_row': 'SourceImpactReactorBuildState.source_impact_reactor_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2182']['runtime_proof'], '/root/C07ImpactReactorPowerStatusProof')
        self.assertEqual(
            ledger['N2182']['tests'],
            [
                'test_c07_impact_reactor_power_status_registration',
                'test_all_c07_impact_reactor_power_status_input_evidence_is_exact',
                'test_impact_reactor_power_status_row_state',
                'test_reference_graph_and_actual_c07_impact_reactor_power_status',
            ],
        )
        self.assertTrue(ledger['N2182']['deferred_exprs'])

    def test_all_c07_impact_reactor_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2182']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_power_status_row_state_result.row': 'SourceImpactReactorBuildState.source_impact_reactor_power_status_row_state',
                    'source_impact_reactor_power_status_row_state_result.has_power_row': 'SourceImpactReactorBuildState.source_impact_reactor_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2182']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_power_status_row_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new impact-reactor build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the impact
        # reactor's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(25f);` (Blocks.java:2642) against
        # `powerProduction = 130f;` (Blocks.java:2636).
        # The reactor's updateTile (ImpactReactor.java:79,
        # `if(efficiency >= 0.9999f && power.status >= 0.99f){`,
        # keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test) only warms up
        # while efficiency is ~1 AND power.status is ~1
        # (ImpactReactor.java:82, `warmup =
        # Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`
        # with ImpactReactor.java:100, `productionEfficiency =
        # Mathf.pow(warmup, 5f);`) -- so a reactor that cannot
        # draw its 25f never warms up and never produces; the
        # folded efficiency is what the efficiency keys prove,
        # and the warmup / production advance waits for its own
        # slice. The producer side (`getPowerProduction()`,
        # PowerGenerator.java:156-158, `return enabled ?
        # powerProduction * productionEfficiency : 0f;`) is NOT
        # folded here: this slice folds only the consumer-side
        # power.status, exactly like every pure-consumer slice.
        # The power bar shows the NET output
        # (ImpactReactor.java:50, `Strings.fixed(Math.max(entity.getPowerProduction() - (consPower == null ? 0f : consPower.usage), 0) * 60 * entity.timeScale(), 1)),`).
        # ImpactReactorBuild has NO shouldConsume override, so
        # the BuildingComp default applies
        # (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with `return enabled;`,
        # BuildingComp.java:756); updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). There is NO gate to defer here: the
        # power-only fold is EXACT, because the only gate is
        # `enabled`, which the driver already checks. canConsume
        # (BuildingComp.java:1917, `public boolean canConsume(){`
        # with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) and edelta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`) are the surrounding gates.
        # The impact reactor is its own family
        # (ImpactReactor.java:17, `public class ImpactReactor
        # extends PowerGenerator{`; ImpactReactorBuild,
        # ImpactReactor.java:74, `public class
        # ImpactReactorBuild extends GeneratorBuild{`), a power
        # block, NOT related to any factory / turret / defense /
        # bridge / conveyor / router family. Its parent
        # PowerGenerator (PowerGenerator.java:22, `public class
        # PowerGenerator extends PowerDistributor{`;
        # GeneratorBuild, PowerGenerator.java:93, `public class
        # GeneratorBuild extends Building{`) supplies the
        # production side: `public float powerProduction;`
        # (PowerGenerator.java:25), `public float
        # productionEfficiency = 0.0f;`
        # (PowerGenerator.java:96), `public float generateTime;`
        # (PowerGenerator.java:94), warmup() returns
        # productionEfficiency when enabled
        # (PowerGenerator.java:105, `return enabled ?
        # productionEfficiency : 0f;`), and getPowerProduction
        # (PowerGenerator.java:156-157). Class fields:
        # `public final int timerUse = timers++;`
        # (ImpactReactor.java:18), `public float warmupSpeed =
        # 0.001f;` (ImpactReactor.java:19), `public float
        # itemDuration = 60f;` (ImpactReactor.java:20);
        # constructor `public ImpactReactor(String name){`
        # (ImpactReactor.java:22), `hasPower = true;`
        # (ImpactReactor.java:24), `hasLiquids = true;`
        # (ImpactReactor.java:25), `liquidCapacity = 30f;`
        # (ImpactReactor.java:26), `hasItems = true;`
        # (ImpactReactor.java:27), `outputsPower =
        # consumesPower = true;` (ImpactReactor.java:28),
        # `flags = EnumSet.of(BlockFlag.reactor,
        # BlockFlag.generator);` (ImpactReactor.java:29),
        # `lightRadius = 115f;` (ImpactReactor.java:30),
        # `emitLight = true;` (ImpactReactor.java:31),
        # `envEnabled = Env.any;` (ImpactReactor.java:32),
        # `drawer = new DrawMulti(new DrawRegion("-bottom"),
        # new DrawPlasma(), new DrawDefault());`
        # (ImpactReactor.java:34), `explosionShake = 6f;`
        # (ImpactReactor.java:36), `explosionShakeDuration =
        # 16f;` (ImpactReactor.java:37), `explosionDamage =
        # 1900 * 4;` (ImpactReactor.java:38),
        # `explosionMinWarmup = 0.3f;`
        # (ImpactReactor.java:39), `explodeEffect =
        # Fx.impactReactorExplosion;`
        # (ImpactReactor.java:40), `explodeSound =
        # Sounds.explosionReactor2;` (ImpactReactor.java:41).
        # Build fields: `public float warmup, totalProgress;`
        # (ImpactReactor.java:75). The warmup branch
        # (ImpactReactor.java:80, `boolean prevOut = consPower
        # != null && getPowerProduction() <=
        # consPower.requestedPower(this);` with
        # ImpactReactor.java:88, `Events.fire(Trigger.impactPower);`)
        # fires the impact-power event when production first
        # exceeds the requested power, and the consume timer
        # (ImpactReactor.java:91, `if(timer(timerUse,
        # itemDuration / timeScale)){` with
        # ImpactReactor.java:92, `consume();`) burns the
        # blast-compound / cryofluid on schedule; the else
        # branch (ImpactReactor.java:95, `warmup =
        # Mathf.lerpDelta(warmup, 0f, 0.01f);`) cools the
        # reactor down, and `totalProgress += warmup *
        # Time.delta;` (ImpactReactor.java:98) tracks it.
        # Single def -- impact-reactor only (size 4, health 900,
        # powerProduction 130f, itemDuration 140f,
        # liquidCapacity 80f, lead 500 / silicon 300 / graphite
        # 400 / thorium 100 / surge-alloy 250 / metaglass 250,
        # Blocks.java:2632-2645). No second ImpactReactor def
        # exists; there is no family split to manage.
        self.assertIn('return build.power.status;', impact_reactor)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', impact_reactor)
        self.assertIn('hasConsumers = consumers.length > 0;', impact_reactor)
        self.assertIn('public class ImpactReactor extends PowerGenerator{', impact_reactor)
        self.assertIn('public final int timerUse = timers++;', impact_reactor)
        self.assertIn('public float warmupSpeed = 0.001f;', impact_reactor)
        self.assertIn('public float itemDuration = 60f;', impact_reactor)
        self.assertIn('public ImpactReactor(String name){', impact_reactor)
        self.assertIn('hasPower = true;', impact_reactor)
        self.assertIn('hasLiquids = true;', impact_reactor)
        self.assertIn('liquidCapacity = 30f;', impact_reactor)
        self.assertIn('hasItems = true;', impact_reactor)
        self.assertIn('outputsPower = consumesPower = true;', impact_reactor)
        self.assertIn('flags = EnumSet.of(BlockFlag.reactor, BlockFlag.generator);', impact_reactor)
        self.assertIn('lightRadius = 115f;', impact_reactor)
        self.assertIn('emitLight = true;', impact_reactor)
        self.assertIn('envEnabled = Env.any;', impact_reactor)
        self.assertIn('drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawPlasma(), new DrawDefault());', impact_reactor)
        self.assertIn('explosionShake = 6f;', impact_reactor)
        self.assertIn('explosionShakeDuration = 16f;', impact_reactor)
        self.assertIn('explosionDamage = 1900 * 4;', impact_reactor)
        self.assertIn('explosionMinWarmup = 0.3f;', impact_reactor)
        self.assertIn('explodeEffect = Fx.impactReactorExplosion;', impact_reactor)
        self.assertIn('explodeSound = Sounds.explosionReactor2;', impact_reactor)
        self.assertIn('public class ImpactReactorBuild extends GeneratorBuild{', impact_reactor)
        self.assertIn('public float warmup, totalProgress;', impact_reactor)
        self.assertIn('if(efficiency >= 0.9999f && power.status >= 0.99f){', impact_reactor)
        self.assertIn('boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);', impact_reactor)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);', impact_reactor)
        self.assertIn('if(Mathf.equal(warmup, 1f, 0.001f)){', impact_reactor)
        self.assertIn('warmup = 1f;', impact_reactor)
        self.assertIn('if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){', impact_reactor)
        self.assertIn('Events.fire(Trigger.impactPower);', impact_reactor)
        self.assertIn('if(timer(timerUse, itemDuration / timeScale)){', impact_reactor)
        self.assertIn('consume();', impact_reactor)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);', impact_reactor)
        self.assertIn('totalProgress += warmup * Time.delta;', impact_reactor)
        self.assertIn('productionEfficiency = Mathf.pow(warmup, 5f);', impact_reactor)
        self.assertIn('public float warmup(){', impact_reactor)
        self.assertIn('return warmup;', impact_reactor)
        self.assertIn('public float totalProgress(){', impact_reactor)
        self.assertIn('return totalProgress;', impact_reactor)
        self.assertIn('addBar("power", (GeneratorBuild entity) -> new Bar(() ->', impact_reactor)
        self.assertIn('Strings.fixed(Math.max(entity.getPowerProduction() - (consPower == null ? 0f : consPower.usage), 0) * 60 * entity.timeScale(), 1)),', impact_reactor)
        self.assertIn('stats.add(Stat.productionTime, itemDuration / 60f, StatUnit.seconds);', impact_reactor)
        self.assertIn('float max = -(float)Math.log(0.001f) / warmupSpeed / 60f;', impact_reactor)
        self.assertIn('float equal = -(float)Math.log(1f - Mathf.pow(consPower.usage / powerProduction, 1f / 5f)) / warmupSpeed / 60f;', impact_reactor)
        self.assertIn('public class PowerGenerator extends PowerDistributor{', impact_reactor)
        self.assertIn('public float powerProduction;', impact_reactor)
        self.assertIn('public class GeneratorBuild extends Building{', impact_reactor)
        self.assertIn('public float generateTime;', impact_reactor)
        self.assertIn('public float productionEfficiency = 0.0f;', impact_reactor)
        self.assertIn('return enabled ? productionEfficiency : 0f;', impact_reactor)
        self.assertIn('public float getPowerProduction(){', impact_reactor)
        self.assertIn('return enabled ? powerProduction * productionEfficiency : 0f;', impact_reactor)
        self.assertIn('write.f(productionEfficiency);', impact_reactor)
        self.assertIn('productionEfficiency = read.f();', impact_reactor)
        self.assertIn('impactReactor = new ImpactReactor("impact-reactor"){{', impact_reactor)
        self.assertIn('requirements(Category.power, with(Items.lead, 500, Items.silicon, 300, Items.graphite, 400, Items.thorium, 100, Items.surgeAlloy, 250, Items.metaglass, 250));', impact_reactor)
        self.assertIn('size = 4;', impact_reactor)
        self.assertIn('health = 900;', impact_reactor)
        self.assertIn('powerProduction = 130f;', impact_reactor)
        self.assertIn('itemDuration = 140f;', impact_reactor)
        self.assertIn('ambientSound = Sounds.loopPulse;', impact_reactor)
        self.assertIn('ambientSoundVolume = 0.08f;', impact_reactor)
        self.assertIn('liquidCapacity = 80f;', impact_reactor)
        self.assertIn('consumePower(25f);', impact_reactor)
        self.assertIn('consumeItem(Items.blastCompound);', impact_reactor)
        self.assertIn('consumeLiquid(Liquids.cryofluid, 0.25f);', impact_reactor)
        self.assertIn('public boolean shouldConsume(){', impact_reactor)
        self.assertIn('return enabled;', impact_reactor)
        self.assertIn('public boolean canConsume(){', impact_reactor)
        self.assertIn('return potentialEfficiency > 0;', impact_reactor)
        self.assertIn('boolean update = shouldConsume() && productionValid();', impact_reactor)
        self.assertIn('if(!update){', impact_reactor)
        self.assertIn('return efficiency * delta();', impact_reactor)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', impact_reactor)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', impact_reactor)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_impact_reactor_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_impact_reactor_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress /
        # unloading / target / acceptItem keys: the updateTile
        # advance (ImpactReactor.java:28-70, eff fold 29,
        # progress advance 35, unload branch 47-60) waits for
        # its own slice, so the eff fold
        # (ImpactReactor.java:29) is what the efficiency keys
        # prove. The efficiency_zero_at_no_power key proves the
        # folded efficiency is 0 -- it does NOT claim the router
        # stops, because baseEfficiency 1f keeps the unload at eff
        # 1f; the glow is the only hard power gate.
        proof = IMPACT_REACTOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'impact_reactor_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_impact_reactor_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'impact_reactor_has_power_consumer',
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
