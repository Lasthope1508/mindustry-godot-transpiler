import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07AcceleratorPowerStatusTests(unittest.TestCase):
    def test_c07_accelerator_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2183']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178/N2179/N2180/N2181/N2182 proved the pure power-row
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
        # stack-conveyor, stack-router and impact-reactor drivers
        # -- but the Accelerator (interplanetary-accelerator,
        # consumePower 10f, Blocks.java:6829) has NO driver at
        # all: it extends Block (Accelerator.java:35, `public
        # class Accelerator extends Block{`), not a factory or
        # crafter or bridge or conveyor or router or power
        # generator, so no existing driver matches it.
        # Battery care: the accelerator is a LAUNCH block -- its
        # canLaunch (Accelerator.java:239-240) needs BOTH
        # efficiency > 0f AND a full battery
        # (powerBufferRequirement 1,000,000f, Blocks.java:6826)
        # -- so the row this slice folds is the CONSUMER-side
        # read (ConsumePower.java:39, `return build.power.status;`),
        # exactly like every pure-consumer slice; the BATTERY
        # side (getBatteryStored / useBatteries,
        # Accelerator.java:240, 270, and the
        # powerBufferRequirement bar, Accelerator.java:105-109)
        # waits for its own slice. The coupling is the progress
        # advance (Accelerator.java:142-144, `if(efficiency >=
        # 0f){` / `progress += Time.delta * efficiency /
        # buildDuration;`): a core that cannot draw its 10f
        # charges at efficiency 0 and never reaches progress 1f,
        # while the port without this slice would behave as if
        # power.status were 1.0. N2183 is the accelerator's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency
        # is build.power.status) in its own driver, wired into
        # simulate_factory like the impact-reactor driver (N2182).
        # The family has a SINGLE def: interplanetary-accelerator
        # is the only Accelerator (Blocks.java:6823) -- there is
        # no second Accelerator def to split from. The
        # accelerator also consumes items (the core-nucleus
        # requirements, Accelerator.java:91, `consumeItems(
        # launchBlock.requirements);`) -- the tick models the
        # power row only; the item rows wait for their own
        # slices, so the folded efficiency is the min over the
        # modeled consumers (power only). The power draw is
        # STATIC: `consumePower(10f);` (Blocks.java:6829)
        # registers a plain ConsumePower, so the catalog
        # consumePower 10.0 is present and the plain radar gate
        # (block.properties.has("consumePower")) works -- no
        # RepairTurret-style `or consumesPower` adaptation is
        # needed. AcceleratorBuild has NO shouldConsume
        # override, so the BuildingComp default applies
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
            ledger['N2183']['source_symbols'],
            [
                'source_accelerator_power_status_row_state_result.row',
                'source_accelerator_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2183']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_power_status_row_state_result.row': 'SourceAcceleratorBuildState.source_accelerator_power_status_row_state',
                    'source_accelerator_power_status_row_state_result.has_power_row': 'SourceAcceleratorBuildState.source_accelerator_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2183']['runtime_proof'], '/root/C07AcceleratorPowerStatusProof')
        self.assertEqual(
            ledger['N2183']['tests'],
            [
                'test_c07_accelerator_power_status_registration',
                'test_all_c07_accelerator_power_status_input_evidence_is_exact',
                'test_accelerator_power_status_row_state',
                'test_reference_graph_and_actual_c07_accelerator_power_status',
            ],
        )
        self.assertTrue(ledger['N2183']['deferred_exprs'])

    def test_all_c07_accelerator_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2183']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_power_status_row_state_result.row': 'SourceAcceleratorBuildState.source_accelerator_power_status_row_state',
                    'source_accelerator_power_status_row_state_result.has_power_row': 'SourceAcceleratorBuildState.source_accelerator_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2183']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_power_status_row_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new accelerator build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the accelerator's
        # static power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`). The single def carries `consumePower(10f);`
        # (Blocks.java:6829) against a battery requirement of
        # `powerBufferRequirement = 1_000_000f;`
        # (Blocks.java:6826).
        # The accelerator's updateTile (Accelerator.java:131,
        # `heat = Mathf.lerpDelta(heat, launching ? 1f :
        # efficiency, 0.05f);` with Accelerator.java:132,
        # `statusLerp = Mathf.lerpDelta(statusLerp, power.status,
        # 0.05f);`) lerps heat toward efficiency and statusLerp
        # toward power.status, advances time by efficiency
        # (Accelerator.java:135, `time += Time.delta *
        # efficiency;`) and progress by efficiency
        # (Accelerator.java:143, `progress += Time.delta *
        # efficiency / buildDuration;`) -- so an accelerator
        # that cannot draw its 10f never reaches progress 1f;
        # the folded efficiency is what the efficiency keys
        # prove, and the progress / launch / battery advance
        # waits for its own slice. `progress()` returns the
        # progress (Accelerator.java:149, `public float
        # progress(){` with Accelerator.java:150, `return
        # progress;`), `isCoreBuilt()` is progress >= 1f
        # (Accelerator.java:153, `public boolean isCoreBuilt(){`
        # with Accelerator.java:154, `return progress >= 1f;`),
        # and canLaunch needs efficiency > 0f AND a full battery
        # (Accelerator.java:239, `public boolean canLaunch(){`
        # with Accelerator.java:240) -- the battery half of that
        # gate waits for its own slice; this slice folds only
        # power.status. The launch itself consumes the stored
        # items and the battery (Accelerator.java:270,
        # `power.graph.useBatteries(powerBufferRequirement);`
        # with Accelerator.java:289, `Events.fire(
        # Trigger.acceleratorUse);`) -- the launch waits for its
        # own slice.
        # AcceleratorBuild has NO shouldConsume override, so
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
        # The accelerator is its own family
        # (Accelerator.java:35, `public class Accelerator
        # extends Block{`; AcceleratorBuild, Accelerator.java:119,
        # `public class AcceleratorBuild extends Building
        # implements LaunchAnimator{`), a campaign / effect block,
        # NOT related to any factory / turret / defense / bridge
        # / conveyor / router / power-generator family. Class
        # fields: `public Block launchBlock =
        # Blocks.coreNucleus;` (Accelerator.java:40), `public
        # float powerBufferRequirement;`
        # (Accelerator.java:41), `public float launchDuration =
        # 120f;` (Accelerator.java:50), `public float
        # chargeDuration = 220f;` (Accelerator.java:51),
        # `public float buildDuration = 120f;`
        # (Accelerator.java:52); constructor `public
        # Accelerator(String name){` (Accelerator.java:70),
        # `update = true;` (Accelerator.java:72), `solid =
        # true;` (Accelerator.java:73), `hasItems = true;`
        # (Accelerator.java:74), `hasPower = true;`
        # (Accelerator.java:75), `itemCapacity = 8000;`
        # (Accelerator.java:76), `configurable = true;`
        # (Accelerator.java:77), `emitLight = true;`
        # (Accelerator.java:78), `lightRadius = 70f;`
        # (Accelerator.java:79), `lightColor = Pal.accent;`
        # (Accelerator.java:80). init fills the item capacity
        # from the launch block's requirements
        # (Accelerator.java:85, `itemCapacity = 0;` with
        # Accelerator.java:86, `capacities = new int[
        # content.items().size];` and Accelerator.java:91,
        # `consumeItems(launchBlock.requirements);`). The
        # powerBufferRequirement bar (Accelerator.java:105,
        # `if(powerBufferRequirement > 0f){` with
        # Accelerator.java:106, `addBar(
        # "powerBufferRequirement", b -> new Bar(`) shows the
        # stored battery over the requirement
        # (Accelerator.java:109, `() -> b.power.graph.
        # getBatteryStored() / powerBufferRequirement`).
        # Build fields: `public float heat, statusLerp;`
        # (Accelerator.java:120), `public float progress;`
        # (Accelerator.java:121), `public float time,
        # launchHeat;` (Accelerator.java:122), `public boolean
        # launching;` (Accelerator.java:123), `public float
        # launchTime;` (Accelerator.java:124). Single def --
        # interplanetary-accelerator only (size 7, scaledHealth
        # 80, powerBufferRequirement 1,000,000f, copper 16000 /
        # silicon 11000 / thorium 13000 / titanium 12000 /
        # surge-alloy 6000 / phase-fabric 5000,
        # Blocks.java:6823-6832). No second Accelerator def
        # exists; there is no family split to manage.
        self.assertIn('return build.power.status;', accelerator)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', accelerator)
        self.assertIn('hasConsumers = consumers.length > 0;', accelerator)
        self.assertIn('public class Accelerator extends Block{', accelerator)
        self.assertIn('public Block launchBlock = Blocks.coreNucleus;', accelerator)
        self.assertIn('public float powerBufferRequirement;', accelerator)
        self.assertIn('public float launchDuration = 120f;', accelerator)
        self.assertIn('public float chargeDuration = 220f;', accelerator)
        self.assertIn('public float buildDuration = 120f;', accelerator)
        self.assertIn('public Accelerator(String name){', accelerator)
        self.assertIn('update = true;', accelerator)
        self.assertIn('solid = true;', accelerator)
        self.assertIn('hasItems = true;', accelerator)
        self.assertIn('hasPower = true;', accelerator)
        self.assertIn('itemCapacity = 8000;', accelerator)
        self.assertIn('configurable = true;', accelerator)
        self.assertIn('emitLight = true;', accelerator)
        self.assertIn('lightRadius = 70f;', accelerator)
        self.assertIn('lightColor = Pal.accent;', accelerator)
        self.assertIn('itemCapacity = 0;', accelerator)
        self.assertIn('capacities = new int[content.items().size];', accelerator)
        self.assertIn('consumeItems(launchBlock.requirements);', accelerator)
        self.assertIn('if(powerBufferRequirement > 0f){', accelerator)
        self.assertIn('addBar("powerBufferRequirement", b -> new Bar(', accelerator)
        self.assertIn('() -> b.power.graph.getBatteryStored() / powerBufferRequirement', accelerator)
        self.assertIn('public class AcceleratorBuild extends Building implements LaunchAnimator{', accelerator)
        self.assertIn('public float heat, statusLerp;', accelerator)
        self.assertIn('public float progress;', accelerator)
        self.assertIn('public float time, launchHeat;', accelerator)
        self.assertIn('public boolean launching;', accelerator)
        self.assertIn('public float launchTime;', accelerator)
        self.assertIn('heat = Mathf.lerpDelta(heat, launching ? 1f : efficiency, 0.05f);', accelerator)
        self.assertIn('statusLerp = Mathf.lerpDelta(statusLerp, power.status, 0.05f);', accelerator)
        self.assertIn('time += Time.delta * efficiency;', accelerator)
        self.assertIn('time = Mathf.slerpDelta(time, 0f, 0.4f);', accelerator)
        self.assertIn('launchHeat = Mathf.lerpDelta(launchHeat, launching ? 1f : 0f, 0.1f);', accelerator)
        self.assertIn('if(efficiency >= 0f){', accelerator)
        self.assertIn('progress += Time.delta * efficiency / buildDuration;', accelerator)
        self.assertIn('progress = Math.min(progress, 1f);', accelerator)
        self.assertIn('public float progress(){', accelerator)
        self.assertIn('return progress;', accelerator)
        self.assertIn('public boolean isCoreBuilt(){', accelerator)
        self.assertIn('return progress >= 1f;', accelerator)
        self.assertIn('public boolean canLaunch(){', accelerator)
        self.assertIn('return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;', accelerator)
        self.assertIn('if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){', accelerator)
        self.assertIn('power.graph.useBatteries(powerBufferRequirement);', accelerator)
        self.assertIn('progress = 0f;', accelerator)
        self.assertIn('Events.fire(Trigger.acceleratorUse);', accelerator)
        self.assertIn('public int getMaximumAccepted(Item item){', accelerator)
        self.assertIn('return capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0);', accelerator)
        self.assertIn('return items.get(item) < getMaximumAccepted(item);', accelerator)
        self.assertIn('write.f(progress);', accelerator)
        self.assertIn('progress = read.f();', accelerator)
        self.assertIn('public float launchDuration(){', accelerator)
        self.assertIn('return launchDuration + chargeDuration;', accelerator)
        self.assertIn('interplanetaryAccelerator = new Accelerator("interplanetary-accelerator"){{', accelerator)
        self.assertIn('requirements(Category.effect, BuildVisibility.campaignOnly, with(Items.copper, 16000, Items.silicon, 11000, Items.thorium, 13000, Items.titanium, 12000, Items.surgeAlloy, 6000, Items.phaseFabric, 5000));', accelerator)
        self.assertIn('researchCostMultiplier = 0.1f;', accelerator)
        self.assertIn('powerBufferRequirement = 1_000_000f;', accelerator)
        self.assertIn('size = 7;', accelerator)
        self.assertIn('consumePower(10f);', accelerator)
        self.assertIn('buildCostMultiplier = 0.5f;', accelerator)
        self.assertIn('scaledHealth = 80;', accelerator)
        self.assertIn('public boolean shouldConsume(){', accelerator)
        self.assertIn('return enabled;', accelerator)
        self.assertIn('public boolean canConsume(){', accelerator)
        self.assertIn('return potentialEfficiency > 0;', accelerator)
        self.assertIn('boolean update = shouldConsume() && productionValid();', accelerator)
        self.assertIn('if(!update){', accelerator)
        self.assertIn('return efficiency * delta();', accelerator)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', accelerator)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', accelerator)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_accelerator_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_accelerator_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress / launch /
        # battery keys: the progress advance
        # (Accelerator.java:143) and the canLaunch battery gate
        # (Accelerator.java:240) wait for their own slices, so the
        # eff fold is what the efficiency keys prove. The
        # efficiency_zero_at_no_power key proves the folded
        # efficiency is 0 -- it does NOT claim the accelerator
        # stops launching, because canLaunch also needs a full
        # battery (powerBufferRequirement 1,000,000f) and
        # progress 1f; the power row is the only hard gate here.
        proof = ACCELERATOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'accelerator_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_accelerator_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accelerator_has_power_consumer',
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
