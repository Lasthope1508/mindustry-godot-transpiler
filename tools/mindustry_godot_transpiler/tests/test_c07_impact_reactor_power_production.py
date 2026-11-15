import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_POWER_PRODUCTION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorPowerProductionProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ImpactReactorPowerProductionTests(unittest.TestCase):
    def test_c07_impact_reactor_power_production_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2186']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state')
        # N2182 folded the consumer-side power.status row for the
        # impact reactor (impact-reactor, consumePower 25f,
        # Blocks.java:2642) -- but the PRODUCER side waited for its
        # own slice: ImpactReactorBuild.updateTile only warms up
        # while the folded efficiency is ~1 AND power.status is ~1
        # (ImpactReactor.java:79, `if(efficiency >= 0.9999f &&
        # power.status >= 0.99f){`), then `productionEfficiency =
        # Mathf.pow(warmup, 5f);` (ImpactReactor.java:100) and
        # `getPowerProduction()` returns `enabled ?
        # powerProduction * productionEfficiency : 0f;`
        # (PowerGenerator.java:156-158) -- 130f at full warmup, 0f
        # when disabled or cold. Without this slice the port would
        # behave as if the reactor produced nothing (no warmup /
        # production state at all) while Java warms it up and
        # produces 130f. N2186 is the producer side: one pure
        # function (frame + delta -> {"warmup",
        # "production_efficiency", "total_progress",
        # "power_production"}) on the same family file N2182 built,
        # advanced by the SAME driver
        # (source_impact_reactor_tick_buildings_state, the
        # placed-reactor tick) after the consumption fold, stamped
        # onto the same frame -- no new file, no new driver, no new
        # frame key. RED decisions (resolved at RED, recorded in
        # the register docstring): (1) the warmup advance does NOT
        # consume -- the `timer(timerUse, itemDuration /
        # timeScale)` -> `consume()` call (ImpactReactor.java:91-92)
        # burns blast-compound + cryofluid, both waiting for their
        # own item/liquid slices; the advance is modeled with
        # productionValid default true (the N2182 precedent). (2)
        # The impactPower event (`Events.fire
        # (Trigger.impactPower)`, ImpactReactor.java:87-88) is
        # DEFERRED to its own event slice; the proof carries no
        # impactPower key. (3) Driver placement: the same N2182
        # driver, no new driver function. (4) Gate inputs: the
        # driver reads the FOLDED efficiency already on the frame
        # (frame["efficiency"], set by update_consumption_state
        # earlier in the same tick) and the live power.status
        # (frame["power_status"], stamped by the N2142 graph
        # update), not a fresh fold. (5) LerpDelta: the port
        # already has the frame-rate independent delta-scaled
        # helper `SourceMathState.source_lerp_delta(from_value,
        # to_value, progress, source_delta)` (SourceMathState.gd,
        # the SourceBlockProducerBuildUpdateState precedent) --
        # GREEN uses it, nothing invented. Frame keys are
        # snake_case, the port's frame-key convention
        # (power_status, efficiency): `warmup`,
        # `production_efficiency`, `total_progress`,
        # `power_production`. The power bar's net output
        # (ImpactReactor.java:50, `Math.max
        # (entity.getPowerProduction() - consPower.usage, 0)`) is
        # display and waits for its own slice; the proof carries
        # no net-bar key. The family has a SINGLE def:
        # impact-reactor is the only ImpactReactor
        # (Blocks.java:2632) -- there is no second ImpactReactor
        # def to split from. Four new result symbols: the warmup,
        # the production efficiency, the total progress and the
        # live production.
        self.assertEqual(
            ledger['N2186']['source_symbols'],
            [
                'source_impact_reactor_power_production_state_result.warmup',
                'source_impact_reactor_power_production_state_result.production_efficiency',
                'source_impact_reactor_power_production_state_result.total_progress',
                'source_impact_reactor_power_production_state_result.power_production',
            ],
        )
        for name in ledger['N2186']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/power/ImpactReactor.java',
                    'core/src/mindustry/world/blocks/power/PowerGenerator.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_power_production_state_result.warmup': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                    'source_impact_reactor_power_production_state_result.production_efficiency': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                    'source_impact_reactor_power_production_state_result.total_progress': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                    'source_impact_reactor_power_production_state_result.power_production': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                }[name])
        self.assertEqual(ledger['N2186']['runtime_proof'], '/root/C07ImpactReactorPowerProductionProof')
        self.assertEqual(
            ledger['N2186']['tests'],
            [
                'test_c07_impact_reactor_power_production_registration',
                'test_all_c07_impact_reactor_power_production_input_evidence_is_exact',
                'test_impact_reactor_power_production_state',
                'test_reference_graph_and_actual_c07_impact_reactor_power_production',
            ],
        )
        self.assertTrue(ledger['N2186']['deferred_exprs'])

    def test_all_c07_impact_reactor_power_production_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2186']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_power_production_state_result.warmup': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                    'source_impact_reactor_power_production_state_result.production_efficiency': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                    'source_impact_reactor_power_production_state_result.total_progress': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
                    'source_impact_reactor_power_production_state_result.power_production': 'SourceImpactReactorBuildState.source_impact_reactor_power_production_state',
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
        for expr in ledger['N2186']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_power_production_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The producer side lives on the same impact-reactor build
        # state N2182 built: the pure function advances warmup per
        # the hard gate (ImpactReactor.java:79, `if(efficiency >=
        # 0.9999f && power.status >= 0.99f){`, keep on ONE comment
        # line, the N2148 shootWarmup lesson: a split line fails
        # this test) -- warmup rises toward 1f while the gate holds
        # (ImpactReactor.java:82, `warmup =
        # Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);`
        # with ImpactReactor.java:19, `public float warmupSpeed =
        # 0.001f;`, snapped by ImpactReactor.java:83-84,
        # `if(Mathf.equal(warmup, 1f, 0.001f)){` / `warmup = 1f;`)
        # and cools toward 0f when it fails
        # (ImpactReactor.java:95, `warmup =
        # Mathf.lerpDelta(warmup, 0f, 0.01f);`); the lerp is the
        # port's frame-rate independent delta-scaled helper
        # (SourceMathState.source_lerp_delta, the
        # SourceBlockProducerBuildUpdateState precedent -- GREEN
        # uses it, nothing invented). Then `totalProgress +=
        # warmup * Time.delta;` (ImpactReactor.java:98) and
        # `productionEfficiency = Mathf.pow(warmup, 5f);`
        # (ImpactReactor.java:100), so a half-warm reactor
        # produces 1/32 of full output. The live production is
        # `getPowerProduction()` (PowerGenerator.java:156-158,
        # `return enabled ? powerProduction * productionEfficiency
        # : 0f;`) with `powerProduction = 130f;`
        # (Blocks.java:2636) -- 130f at full warmup, 0f when
        # disabled or cold. The gate reads the FOLDED efficiency
        # already on the frame (set by update_consumption_state
        # earlier in the same tick, the N2182 driver) and the live
        # power.status (frame["power_status"], stamped by the
        # N2142 graph update): a reactor that cannot draw its 25f
        # (Blocks.java:2642, `consumePower(25f);`) never warms up
        # and never produces, and there is no baseEfficiency-style
        # floor -- the warmup decays to 0 and production is 0 when
        # the gate fails. The consume timer
        # (ImpactReactor.java:91, `if(timer(timerUse,
        # itemDuration / timeScale)){` with
        # ImpactReactor.java:92, `consume();`) does NOT run here:
        # N2186 advances warmup only, the burn of blast-compound
        # (Blocks.java:2643, `consumeItem(Items.blastCompound);`)
        # and cryofluid 0.25f (Blocks.java:2644,
        # `consumeLiquid(Liquids.cryofluid, 0.25f);`) waits for its
        # own item/liquid slice. The first-production event
        # (ImpactReactor.java:87, `if(!prevOut && consPower !=
        # null && (getPowerProduction() >
        # consPower.requestedPower(this))){` with
        # ImpactReactor.java:88, `Events.fire
        # (Trigger.impactPower);`, computed from
        # ImpactReactor.java:80, `boolean prevOut = consPower !=
        # null && getPowerProduction() <=
        # consPower.requestedPower(this);`) is DEFERRED to its own
        # event slice; the proof carries no impactPower key. The
        # production efficiency persists across saves:
        # `write.f(productionEfficiency);`
        # (PowerGenerator.java:166) with
        # `productionEfficiency = read.f();`
        # (PowerGenerator.java:172) -- persistence waits for its
        # own slice. The parent PowerGenerator
        # (PowerGenerator.java:22, `public class PowerGenerator
        # extends PowerDistributor{`; GeneratorBuild,
        # PowerGenerator.java:93, `public class GeneratorBuild
        # extends Building{`) supplies the production side:
        # `public float powerProduction;`
        # (PowerGenerator.java:25), `public float generateTime;`
        # (PowerGenerator.java:94), `public float
        # productionEfficiency = 0.0f;`
        # (PowerGenerator.java:96), warmup() returns
        # productionEfficiency when enabled
        # (PowerGenerator.java:105, `return enabled ?
        # productionEfficiency : 0f;`), and `public float
        # getPowerProduction(){` (PowerGenerator.java:156).
        # ImpactReactorBuild fields: `public float warmup,
        # totalProgress;` (ImpactReactor.java:75); the accessors
        # `public float warmup(){` (ImpactReactor.java:103) with
        # `return warmup;` and `public float totalProgress(){`
        # (ImpactReactor.java:107) with `return totalProgress;`
        # expose the warmup state. The power bar
        # `addBar("power", (GeneratorBuild entity) -> new Bar(()
        # ->` (ImpactReactor.java:44) shows the net output
        # (`Strings.fixed(Math.max(entity.getPowerProduction() -
        # (consPower == null ? 0f : consPower.usage), 0) * 60 *
        # entity.timeScale(), 1)),`, ImpactReactor.java:50) --
        # display, not tick state; the proof carries no net-bar
        # key. The warmup-time stats `float max =
        # -(float)Math.log(0.001f) / warmupSpeed / 60f;`
        # (ImpactReactor.java:64) and `float equal =
        # -(float)Math.log(1f - Mathf.pow(consPower.usage /
        # powerProduction, 1f / 5f)) / warmupSpeed / 60f;`
        # (ImpactReactor.java:65) derive from the warmup speed,
        # with `stats.add(Stat.productionTime, itemDuration /
        # 60f, StatUnit.seconds);` (ImpactReactor.java:60).
        # ImpactReactorBuild has NO shouldConsume override, so the
        # BuildingComp default applies
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
        # delta();`) are the surrounding gates; the first pass
        # folds the N2182 power row into the min efficiency
        # (BuildingComp.java:1969-1976, `for(var cons :
        # block.nonOptionalConsumers){` /
        # `minEfficiency = Math.min(minEfficiency, result);`)
        # from the canonical read (`return build.power.status;`,
        # ConsumePower.java:39), with a missing stamp folding to
        # 1.0 (UnitAssembler.java:469, `float powerStatus =
        # !enabled ? 0f : power == null ? 1f : power.status;`).
        # Single def -- impact-reactor only (size 4, health 900,
        # powerProduction 130f, itemDuration 140f,
        # liquidCapacity 80f, lead 500 / silicon 300 / graphite
        # 400 / thorium 100 / surge-alloy 250 / metaglass 250,
        # Blocks.java:2632-2645). No second ImpactReactor def
        # exists; there is no family split to manage.
        self.assertIn('static func source_impact_reactor_power_production_state(frame: Dictionary, delta: float) -> Dictionary:', impact_reactor)
        self.assertIn('source_impact_reactor_power_production_state(frame', impact_reactor)
        self.assertIn('frame["warmup"]', impact_reactor)
        self.assertIn('frame["production_efficiency"]', impact_reactor)
        self.assertIn('frame["total_progress"]', impact_reactor)
        self.assertIn('frame["power_production"]', impact_reactor)
        self.assertIn('source_lerp_delta', impact_reactor)
        self.assertIn('SourceMathState.gd', impact_reactor)
        self.assertIn('if(efficiency >= 0.9999f && power.status >= 0.99f){', impact_reactor)
        self.assertIn('boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);', impact_reactor)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);', impact_reactor)
        self.assertIn('public float warmupSpeed = 0.001f;', impact_reactor)
        self.assertIn('if(Mathf.equal(warmup, 1f, 0.001f)){', impact_reactor)
        self.assertIn('warmup = 1f;', impact_reactor)
        self.assertIn('if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){', impact_reactor)
        self.assertIn('Events.fire(Trigger.impactPower);', impact_reactor)
        self.assertIn('if(timer(timerUse, itemDuration / timeScale)){', impact_reactor)
        self.assertIn('consume();', impact_reactor)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);', impact_reactor)
        self.assertIn('totalProgress += warmup * Time.delta;', impact_reactor)
        self.assertIn('productionEfficiency = Mathf.pow(warmup, 5f);', impact_reactor)
        self.assertIn('public float warmup, totalProgress;', impact_reactor)
        self.assertIn('public float getPowerProduction(){', impact_reactor)
        self.assertIn('return enabled ? powerProduction * productionEfficiency : 0f;', impact_reactor)
        self.assertIn('public float productionEfficiency = 0.0f;', impact_reactor)
        self.assertIn('return enabled ? productionEfficiency : 0f;', impact_reactor)
        self.assertIn('write.f(productionEfficiency);', impact_reactor)
        self.assertIn('productionEfficiency = read.f();', impact_reactor)
        self.assertIn('public float warmup(){', impact_reactor)
        self.assertIn('return warmup;', impact_reactor)
        self.assertIn('public float totalProgress(){', impact_reactor)
        self.assertIn('return totalProgress;', impact_reactor)
        self.assertIn('public class PowerGenerator extends PowerDistributor{', impact_reactor)
        self.assertIn('public float powerProduction;', impact_reactor)
        self.assertIn('public class GeneratorBuild extends Building{', impact_reactor)
        self.assertIn('public float generateTime;', impact_reactor)
        self.assertIn('addBar("power", (GeneratorBuild entity) -> new Bar(() ->', impact_reactor)
        self.assertIn('Strings.fixed(Math.max(entity.getPowerProduction() - (consPower == null ? 0f : consPower.usage), 0) * 60 * entity.timeScale(), 1)),', impact_reactor)
        self.assertIn('stats.add(Stat.productionTime, itemDuration / 60f, StatUnit.seconds);', impact_reactor)
        self.assertIn('float max = -(float)Math.log(0.001f) / warmupSpeed / 60f;', impact_reactor)
        self.assertIn('float equal = -(float)Math.log(1f - Mathf.pow(consPower.usage / powerProduction, 1f / 5f)) / warmupSpeed / 60f;', impact_reactor)
        self.assertIn('powerProduction = 130f;', impact_reactor)
        self.assertIn('itemDuration = 140f;', impact_reactor)
        self.assertIn('consumePower(25f);', impact_reactor)
        self.assertIn('consumeItem(Items.blastCompound);', impact_reactor)
        self.assertIn('consumeLiquid(Liquids.cryofluid, 0.25f);', impact_reactor)
        self.assertIn('return build.power.status;', impact_reactor)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', impact_reactor)
        self.assertIn('public boolean shouldConsume(){', impact_reactor)
        self.assertIn('return enabled;', impact_reactor)
        self.assertIn('boolean update = shouldConsume() && productionValid();', impact_reactor)
        self.assertIn('if(!update){', impact_reactor)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', impact_reactor)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', impact_reactor)
        self.assertIn('return efficiency * delta();', impact_reactor)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_impact_reactor_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_impact_reactor_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure function with synthetic
        # frames (no long live tick: warmupSpeed 0.001f approaches
        # 1f exponentially, so the proof calls the pure function
        # directly): warmup rises under full power, cools without
        # it, productionEfficiency is pow(warmup, 5), production
        # is 130x productionEfficiency when enabled, 0 when
        # disabled, 0 when cold. There are no consume-timer /
        # impactPower / net-bar keys: the consume call waits for
        # its own item/liquid slice, the event waits for its own
        # event slice, the net bar is display.
        proof = IMPACT_REACTOR_POWER_PRODUCTION_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_rises_under_full_power',
            'warmup_cools_without_power',
            'production_efficiency_is_pow_warmup_5',
            'power_production_is_130_times_production_efficiency',
            'power_production_zero_when_disabled',
            'power_production_zero_when_cold',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_impact_reactor_power_production(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorPowerProductionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_POWER_PRODUCTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_rises_under_full_power',
            'warmup_cools_without_power',
            'production_efficiency_is_pow_warmup_5',
            'power_production_is_130_times_production_efficiency',
            'power_production_zero_when_disabled',
            'power_production_zero_when_cold',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
