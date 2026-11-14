import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07RepairTowerPowerStatusTests(unittest.TestCase):
    def test_c07_repair_tower_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2176']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175 proved the
        # pure power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump, beam-drill,
        # mend-projector, overdrive-projector, force-projector,
        # base-shield, regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret and shield-wall drivers -- but the
        # RepairTower (unit-repair-tower, consumePower 1f,
        # Blocks.java:6582) has NO driver at all: it extends
        # Block (RepairTower.java:18), not a factory or crafter,
        # so no existing driver matches it, and its updateTile
        # heal advance (RepairTower.java:78, `target.heal(
        # healAmount * edelta());`) heals by edelta()
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), so a repair tower with no power would never
        # heal -- its targets' health would sit frozen as if
        # power.status were 1.0. N2176 is the repair tower's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the radar driver (N2173).
        # The repair tower's power draw is STATIC, not
        # conditional: `consumePower(1f);` (Blocks.java:6582)
        # registers a plain ConsumePower, so the catalog
        # consumePower 1.0 is present and the plain radar gate
        # (block.properties.has("consumePower")) works -- no
        # RepairTurret-style `or consumesPower` adaptation is
        # needed. RepairTowerBuild DOES override shouldConsume:
        # `return targets.size > 0;` (RepairTower.java:89-91),
        # and updateConsumption forces efficiency to zero when
        # the gate is false (BuildingComp.java:1960, `boolean
        # update = shouldConsume() && productionValid();` +
        # 1992-1994, `if(!update){` / efficiency =
        # optionalEfficiency = 0f). RED decision (the
        # PointDefenseTurret N2151 precedent, whose `return
        # super.shouldConsume() && target != null;` gate was
        # deferred the same way, and the RepairTurret N2174
        # precedent): the port tracks NO live target on any
        # placed-building frame, so this slice folds power-only
        # and defers the gate with a documented limit -- with no
        # targets requestedPower is 0 so power.status reads 1.0
        # while Java efficiency is 0; the observable gap is
        # efficiency 1.0 vs 0.0 with no targets. Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2176']['source_symbols'],
            [
                'source_repair_tower_power_status_row_state_result.row',
                'source_repair_tower_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2176']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_power_status_row_state_result.row': 'SourceRepairTowerBuildState.source_repair_tower_power_status_row_state',
                    'source_repair_tower_power_status_row_state_result.has_power_row': 'SourceRepairTowerBuildState.source_repair_tower_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2176']['runtime_proof'], '/root/C07RepairTowerPowerStatusProof')
        self.assertEqual(
            ledger['N2176']['tests'],
            [
                'test_c07_repair_tower_power_status_registration',
                'test_all_c07_repair_tower_power_status_input_evidence_is_exact',
                'test_repair_tower_power_status_row_state',
                'test_reference_graph_and_actual_c07_repair_tower_power_status',
            ],
        )
        self.assertTrue(ledger['N2176']['deferred_exprs'])

    def test_all_c07_repair_tower_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2176']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_power_status_row_state_result.row': 'SourceRepairTowerBuildState.source_repair_tower_power_status_row_state',
                    'source_repair_tower_power_status_row_state_result.has_power_row': 'SourceRepairTowerBuildState.source_repair_tower_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2176']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_power_status_row_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new repair-tower
        # build state: the live frame value is
        # ConsumePower.efficiency (ConsumePower.java:39, `return
        # build.power.status;`), folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency;
        # a missing stamp folds to 1.0 before the first graph
        # update, the assembler fold (UnitAssembler.java:469,
        # `float powerStatus = !enabled ? 0f : power == null ?
        # 1f : power.status;`).
        self.assertIn('static func source_repair_tower_power_status_row_state', repair_tower)
        self.assertIn('return build.power.status;', repair_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', repair_tower)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the repair
        # tower's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(1f);` (Blocks.java:6582) and a second,
        # deferred liquid consumer `consumeLiquid(Liquids.ozone,
        # 3f / 60f);` (Blocks.java:6583). The repair tower's
        # updateTile heal advance (RepairTower.java:78,
        # `target.heal(healAmount * edelta());`, keep on ONE
        # comment line, the N2148 shootWarmup lesson: a split line
        # fails this test) heals by edelta(), and edelta() is
        # efficiency * delta (BuildingComp.java:1927-1929,
        # `return efficiency * delta();`).
        # RepairTowerBuild overrides shouldConsume
        # (RepairTower.java:89, `public boolean shouldConsume(){`
        # with `return targets.size > 0;`,
        # RepairTower.java:90); updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). RED decision (the PointDefenseTurret
        # N2151 precedent and the RepairTurret N2174 precedent):
        # the port tracks no live target on any placed-building
        # frame, so this slice folds power-only and defers the
        # gate with a documented limit; the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). The repair tower is its own
        # family (RepairTower.java:18, `public class RepairTower
        # extends Block{`; RepairTowerBuild,
        # RepairTower.java:46, `public class RepairTowerBuild
        # extends Building implements Ranged{`). Class fields:
        # `static final float refreshInterval = 6f;`
        # (RepairTower.java:19), `public float range = 80f;`
        # (RepairTower.java:21), `public float healAmount = 1f;`
        # (RepairTower.java:24); constructor `update = true;`
        # (RepairTower.java:29), `suppressable = true;`
        # (RepairTower.java:31), `flags =
        # EnumSet.of(BlockFlag.repair);` (RepairTower.java:32).
        # The target refresh itself is gated on
        # potentialEfficiency (RepairTower.java:59,
        # `if(potentialEfficiency > 0 && (refresh += Time.delta)
        # >= refreshInterval){`), and the warmup lerp
        # (RepairTower.java:84, `warmup = Mathf.lerpDelta(warmup,
        # any ? efficiency : 0f, 0.08f);`) follows efficiency.
        # canConsume (BuildingComp.java:1917, `public boolean
        # canConsume(){` with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) and the shouldConsume default
        # (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with `return enabled;`,
        # BuildingComp.java:756) are the surrounding gates.
        # Single def -- unit-repair-tower only (size 2, range
        # 100f, healAmount 1.5f, graphite 90 / silicon 90 /
        # tungsten 80, Blocks.java:6575-6583). RepairTurret
        # (repair-point / repair-turret) is a different class
        # and NOT covered by this driver.
        self.assertIn('"is_power": true', repair_tower)
        self.assertIn('block.properties.has("consumePower")', repair_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', repair_tower)
        self.assertIn('consumePower(1f);', repair_tower)
        self.assertIn('consumeLiquid(Liquids.ozone, 3f / 60f);', repair_tower)
        self.assertIn('public class RepairTower extends Block{', repair_tower)
        self.assertIn('public class RepairTowerBuild extends Building implements Ranged{', repair_tower)
        self.assertIn('static final float refreshInterval = 6f;', repair_tower)
        self.assertIn('public float range = 80f;', repair_tower)
        self.assertIn('public float healAmount = 1f;', repair_tower)
        self.assertIn('update = true;', repair_tower)
        self.assertIn('suppressable = true;', repair_tower)
        self.assertIn('flags = EnumSet.of(BlockFlag.repair);', repair_tower)
        self.assertIn('if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', repair_tower)
        self.assertIn('target.heal(healAmount * edelta());', repair_tower)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);', repair_tower)
        self.assertIn('public boolean shouldConsume(){', repair_tower)
        self.assertIn('return targets.size > 0;', repair_tower)
        self.assertIn('public boolean canConsume(){', repair_tower)
        self.assertIn('return potentialEfficiency > 0;', repair_tower)
        self.assertIn('return enabled;', repair_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_tower)
        self.assertIn('if(!update){', repair_tower)
        self.assertIn('return efficiency * delta();', repair_tower)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', repair_tower)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', repair_tower)
        self.assertIn('static func source_repair_tower_tick_buildings_state', repair_tower)
        # The repair tower needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the radar precedent, N2173).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_repair_tower_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_repair_tower_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no heal / warmup /
        # target / suppression keys: the updateTile advance
        # (RepairTower.java:57-86) waits for its own slice, so
        # the heal advance (RepairTower.java:78) is what the
        # efficiency keys prove.
        proof = REPAIR_TOWER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'repair_tower_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'repair_tower_has_power_consumer',
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
