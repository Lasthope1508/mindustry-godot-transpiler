import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ShockwaveTowerPowerStatusTests(unittest.TestCase):
    def test_c07_shockwave_tower_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2177']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176 proved
        # the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall and repair-tower drivers --
        # but the ShockwaveTower (shockwave-tower, consumePower
        # 100f / 60f, Blocks.java:2042) has NO driver at all: it
        # extends Block (ShockwaveTower.java:22), not a factory or
        # crafter, so no existing driver matches it, and its
        # updateTile fire gate (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`) charges its reload counter by edelta()
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), so a shockwave tower with no power would
        # never charge and never fire its wave -- its reload
        # counter would sit frozen as if power.status were 1.0.
        # N2177 is the shockwave tower's live read: a pure power
        # row over the stamped frame value, folded by the shared
        # machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the radar driver (N2173).
        # The shockwave tower's power draw is STATIC, not
        # conditional: `consumePower(100f / 60f);`
        # (Blocks.java:2042) registers a plain ConsumePower, so
        # the catalog consumePower 1.6666666666666667 is present
        # and the plain radar gate
        # (block.properties.has("consumePower")) works -- no
        # RepairTurret-style `or consumesPower` adaptation is
        # needed. ShockwaveTowerBuild DOES override shouldConsume:
        # `return reloadCounter < reload;`
        # (ShockwaveTower.java:121-122), and updateConsumption
        # forces efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1994,
        # `if(!update){` / efficiency = optionalEfficiency =
        # 0f). RED decision (the PointDefenseTurret N2151
        # precedent, whose `return super.shouldConsume() && target
        # != null;` gate was deferred the same way, and the
        # RepairTurret N2174 / RepairTower N2176 precedents): the
        # port tracks NO live reload counter on any
        # placed-building frame, so this slice folds power-only
        # and defers the gate with a documented limit -- when
        # fully reloaded power.status reads 1.0 while Java
        # efficiency is 0; the observable gap is efficiency 1.0
        # vs 0.0 when fully reloaded. Two new result symbols: the
        # row and its presence flag.
        self.assertEqual(
            ledger['N2177']['source_symbols'],
            [
                'source_shockwave_tower_power_status_row_state_result.row',
                'source_shockwave_tower_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2177']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_power_status_row_state_result.row': 'SourceShockwaveTowerBuildState.source_shockwave_tower_power_status_row_state',
                    'source_shockwave_tower_power_status_row_state_result.has_power_row': 'SourceShockwaveTowerBuildState.source_shockwave_tower_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2177']['runtime_proof'], '/root/C07ShockwaveTowerPowerStatusProof')
        self.assertEqual(
            ledger['N2177']['tests'],
            [
                'test_c07_shockwave_tower_power_status_registration',
                'test_all_c07_shockwave_tower_power_status_input_evidence_is_exact',
                'test_shockwave_tower_power_status_row_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_power_status',
            ],
        )
        self.assertTrue(ledger['N2177']['deferred_exprs'])

    def test_all_c07_shockwave_tower_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2177']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_power_status_row_state_result.row': 'SourceShockwaveTowerBuildState.source_shockwave_tower_power_status_row_state',
                    'source_shockwave_tower_power_status_row_state_result.has_power_row': 'SourceShockwaveTowerBuildState.source_shockwave_tower_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2177']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_power_status_row_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new shockwave-tower
        # build state: the live frame value is
        # ConsumePower.efficiency (ConsumePower.java:39, `return
        # build.power.status;`), folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency;
        # a missing stamp folds to 1.0 before the first graph
        # update, the assembler fold (UnitAssembler.java:469,
        # `float powerStatus = !enabled ? 0f : power == null ?
        # 1f : power.status;`).
        self.assertIn('static func source_shockwave_tower_power_status_row_state', shockwave_tower)
        self.assertIn('return build.power.status;', shockwave_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shockwave_tower)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the shockwave
        # tower's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(100f / 60f);` (Blocks.java:2042) and a
        # second, deferred liquid consumer
        # `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f
        # / 60f));` (Blocks.java:2041). The shockwave tower's
        # updateTile fire gate (ShockwaveTower.java:73,
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){`, keep on ONE comment line, the N2148
        # shootWarmup lesson: a split line fails this test)
        # charges its reload counter by edelta(), and edelta() is
        # efficiency * delta (BuildingComp.java:1927-1929,
        # `return efficiency * delta();`).
        # ShockwaveTowerBuild overrides shouldConsume
        # (ShockwaveTower.java:121, `public boolean
        # shouldConsume(){` with `return reloadCounter < reload;`,
        # ShockwaveTower.java:122); updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). RED decision (the PointDefenseTurret
        # N2151 precedent and the RepairTurret N2174 / RepairTower
        # N2176 precedents): the port tracks no live reload
        # counter on any placed-building frame, so this slice
        # folds power-only and defers the gate with a documented
        # limit; the machinery runs with should_consume=true when
        # enabled (the MendProjector suppression precedent). The
        # shockwave tower is its own family
        # (ShockwaveTower.java:22, `public class ShockwaveTower
        # extends Block{`; ShockwaveTowerBuild,
        # ShockwaveTower.java:66, `public class
        # ShockwaveTowerBuild extends Building{`). Class fields:
        # `public int timerCheck = timers ++;`
        # (ShockwaveTower.java:23), `public float range = 110f;`
        # (ShockwaveTower.java:25), `public float reload = 60f *
        # 1.5f;` (ShockwaveTower.java:26), `public float
        # bulletDamage = 160;` (ShockwaveTower.java:27), `public
        # float falloffCount = 20f;` (ShockwaveTower.java:28),
        # `public float shake = 2f;` (ShockwaveTower.java:29),
        # `public float checkInterval = 8f;`
        # (ShockwaveTower.java:31), `public float
        # cooldownMultiplier = 1f;` (ShockwaveTower.java:34);
        # constructor `update = true;`
        # (ShockwaveTower.java:46), `solid = true;`
        # (ShockwaveTower.java:47). Build fields: `public float
        # reloadCounter = Mathf.random(reload);`
        # (ShockwaveTower.java:67), `public float heat = 0f;`
        # (ShockwaveTower.java:68). The wave damage line
        # (ShockwaveTower.java:87, `float waveDamage =
        # Math.min(bulletDamage, bulletDamage * falloffCount /
        # targets.size);`) and the heat decay
        # (ShockwaveTower.java:104, `heat = Mathf.clamp(heat -
        # Time.delta / reload * cooldownMultiplier);`) follow the
        # fire gate. canConsume (BuildingComp.java:1917, `public
        # boolean canConsume(){` with `return potentialEfficiency
        # > 0;`, BuildingComp.java:1918) and the shouldConsume
        # default (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with `return enabled;`,
        # BuildingComp.java:756) are the surrounding gates.
        # sense(LAccess.progress) returns `reloadCounter / reload`
        # (ShockwaveTower.java:110, `if(sensor ==
        # LAccess.progress) return reloadCounter / reload;`) and
        # warmup() returns heat (ShockwaveTower.java:117,
        # `return heat;`) -- both wait for their own slices.
        # Single def -- shockwave-tower only (size 3, range 170f,
        # reload 80f, surge-alloy 50 / silicon 150 / oxide 30 /
        # tungsten 100, Blocks.java:2038-2044). RepairTower
        # (unit-repair-tower) is a different class and NOT covered
        # by this driver.
        self.assertIn('"is_power": true', shockwave_tower)
        self.assertIn('block.properties.has("consumePower")', shockwave_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', shockwave_tower)
        self.assertIn('consumePower(100f / 60f);', shockwave_tower)
        self.assertIn('consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        self.assertIn('public class ShockwaveTowerBuild extends Building{', shockwave_tower)
        self.assertIn('public int timerCheck = timers ++;', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('public float bulletDamage = 160;', shockwave_tower)
        self.assertIn('public float falloffCount = 20f;', shockwave_tower)
        self.assertIn('public float shake = 2f;', shockwave_tower)
        self.assertIn('public float checkInterval = 8f;', shockwave_tower)
        self.assertIn('public float cooldownMultiplier = 1f;', shockwave_tower)
        self.assertIn('update = true;', shockwave_tower)
        self.assertIn('solid = true;', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('if(sensor == LAccess.progress) return reloadCounter / reload;', shockwave_tower)
        self.assertIn('return heat;', shockwave_tower)
        self.assertIn('public boolean shouldConsume(){', shockwave_tower)
        self.assertIn('return reloadCounter < reload;', shockwave_tower)
        self.assertIn('public boolean canConsume(){', shockwave_tower)
        self.assertIn('return potentialEfficiency > 0;', shockwave_tower)
        self.assertIn('return enabled;', shockwave_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shockwave_tower)
        self.assertIn('if(!update){', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', shockwave_tower)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The shockwave tower needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the radar precedent, N2173).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_shockwave_tower_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_shockwave_tower_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no wave / heat /
        # target / sense / warmup keys: the updateTile advance
        # (ShockwaveTower.java:73-104) waits for its own slice, so
        # the reload charge (ShockwaveTower.java:73) is what the
        # efficiency keys prove.
        proof = SHOCKWAVE_TOWER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'shockwave_tower_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shockwave_tower_has_power_consumer',
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
