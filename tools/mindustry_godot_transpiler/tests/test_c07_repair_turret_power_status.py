import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07RepairTurretPowerStatusTests(unittest.TestCase):
    def test_c07_repair_turret_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2174']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173 proved the pure
        # power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump, beam-drill,
        # mend-projector, overdrive-projector, force-projector,
        # base-shield, regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad and radar drivers
        # -- but the RepairTurret (repair-point, powerUse 1f,
        # Blocks.java:6391; repair-turret, powerUse 5f,
        # Blocks.java:6402) has NO driver at all: it extends
        # Block (RepairTurret.java:25), not a factory or crafter,
        # so no existing driver matches it, and its updateTile
        # heal advance (RepairTurret.java:207, `target.heal(repairSpeed
        # * strength * edelta() * multiplier);`) heals by edelta()
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), so a repair turret with no power would never
        # heal -- its target's health would sit frozen as if
        # power.status were 1.0. N2174 is the repair turret's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the radar driver (N2173).
        # The repair turret's power draw is CONDITIONAL, not
        # static: `consumePowerCond(powerUse, (RepairPointBuild
        # entity) -> entity.target != null);`
        # (RepairTurret.java:89), and ConsumePowerCondition only
        # draws when its condition holds
        # (ConsumePowerCondition.java:17, `return consume.get(entity)
        # ? usage : 0f;`) -- the catalog consumePower None is
        # CORRECT for this family, it records no static
        # consumePower def. The pure row is still the same
        # ConsumePower read (`return build.power.status;`,
        # ConsumePower.java:39) -- ConsumePowerCondition does not
        # override efficiency(), so the row folds power.status
        # exactly like the static case. RepairPointBuild DOES
        # override shouldConsume: `return target != null &&
        # enabled;` (RepairTurret.java:222), and updateConsumption
        # forces efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1994,
        # `if(!update){` / efficiency = optionalEfficiency = 0f).
        # RED decision (the PointDefenseTurret N2151 precedent,
        # whose `return super.shouldConsume() && target != null;`
        # gate was deferred the same way): the port tracks NO
        # live target on any placed-building frame, so this
        # slice folds power-only and defers the gate with a
        # documented limit -- with no target requestedPower is 0
        # so power.status reads 1.0 while Java efficiency is 0;
        # the observable gap is efficiency 1.0 vs 0.0 with no
        # target. Two new result symbols: the row and its
        # presence flag.
        self.assertEqual(
            ledger['N2174']['source_symbols'],
            [
                'source_repair_turret_power_status_row_state_result.row',
                'source_repair_turret_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2174']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_power_status_row_state_result.row': 'SourceRepairTurretBuildState.source_repair_turret_power_status_row_state',
                    'source_repair_turret_power_status_row_state_result.has_power_row': 'SourceRepairTurretBuildState.source_repair_turret_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2174']['runtime_proof'], '/root/C07RepairTurretPowerStatusProof')
        self.assertEqual(
            ledger['N2174']['tests'],
            [
                'test_c07_repair_turret_power_status_registration',
                'test_all_c07_repair_turret_power_status_input_evidence_is_exact',
                'test_repair_turret_power_status_row_state',
                'test_reference_graph_and_actual_c07_repair_turret_power_status',
            ],
        )
        self.assertTrue(ledger['N2174']['deferred_exprs'])

    def test_all_c07_repair_turret_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2174']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_power_status_row_state_result.row': 'SourceRepairTurretBuildState.source_repair_turret_power_status_row_state',
                    'source_repair_turret_power_status_row_state_result.has_power_row': 'SourceRepairTurretBuildState.source_repair_turret_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/consumers/ConsumePowerCondition.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2174']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_power_status_row_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new repair-turret
        # build state: the live frame value is
        # ConsumePower.efficiency (ConsumePower.java:39, `return
        # build.power.status;`), folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency;
        # a missing stamp folds to 1.0 before the first graph
        # update, the assembler fold (UnitAssembler.java:469,
        # `float powerStatus = !enabled ? 0f : power == null ?
        # 1f : power.status;`).
        self.assertIn('static func source_repair_turret_power_status_row_state', repair_turret)
        self.assertIn('return build.power.status;', repair_turret)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', repair_turret)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the repair
        # turret's conditional power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The conditional registration
        # (RepairTurret.java:89, `consumePowerCond(powerUse,
        # (RepairPointBuild entity) -> entity.target != null);`)
        # draws only while a target is locked
        # (ConsumePowerCondition.java:17, `return consume.get(entity)
        # ? usage : 0f;`); the two defs carry powerUse 1f
        # (repair-point, Blocks.java:6391) and 5f (repair-turret,
        # Blocks.java:6402). The repair turret's updateTile heal
        # advance (RepairTurret.java:207, `target.heal(repairSpeed
        # * strength * edelta() * multiplier);`, keep on ONE
        # comment line, the N2148 shootWarmup lesson: a split line
        # fails this test) heals by edelta(), and edelta() is
        # efficiency * delta (BuildingComp.java:1927-1929,
        # `return efficiency * delta();`).
        # RepairPointBuild overrides shouldConsume
        # (RepairTurret.java:221, `public boolean shouldConsume(){`
        # with `return target != null && enabled;`,
        # RepairTurret.java:222); updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). RED decision (the PointDefenseTurret
        # N2151 precedent): the port tracks no live target on
        # any placed-building frame, so this slice folds
        # power-only and defers the gate with a documented limit;
        # the machinery runs with should_consume=true when enabled
        # (the MendProjector suppression precedent). The repair
        # turret is its own family (RepairTurret.java:25,
        # `public class RepairTurret extends Block{`;
        # RepairPointBuild, RepairTurret.java:153, `public class
        # RepairPointBuild extends Building implements Ranged,
        # RotBlock{`). Two defs (repair-point, `powerUse = 1f;`,
        # Blocks.java:6391; repair-turret, `powerUse = 5f;`,
        # Blocks.java:6402).
        self.assertIn('"is_power": true', repair_turret)
        self.assertIn('block.properties.has("consumePower")', repair_turret)
        self.assertIn('hasConsumers = consumers.length > 0;', repair_turret)
        self.assertIn('consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);', repair_turret)
        self.assertIn('return consume.get(entity) ? usage : 0f;', repair_turret)
        self.assertIn('powerUse = 1f;', repair_turret)
        self.assertIn('powerUse = 5f;', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        self.assertIn('public boolean shouldConsume(){', repair_turret)
        self.assertIn('return target != null && enabled;', repair_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_turret)
        self.assertIn('if(!update){', repair_turret)
        self.assertIn('public class RepairTurret extends Block{', repair_turret)
        self.assertIn('public class RepairPointBuild extends Building implements Ranged, RotBlock{', repair_turret)
        self.assertIn('static func source_repair_turret_tick_buildings_state', repair_turret)
        # The repair turret needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the radar precedent, N2173).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_repair_turret_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_repair_turret_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no heal / strength /
        # rotation / target keys: the updateTile advance
        # (RepairTurret.java:187-219) waits for its own slice, so
        # the heal advance (RepairTurret.java:207) is what the
        # efficiency keys prove.
        proof = REPAIR_TURRET_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'repair_turret_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'repair_turret_has_power_consumer',
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
