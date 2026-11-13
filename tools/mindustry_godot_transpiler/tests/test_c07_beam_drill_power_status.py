import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillPowerStatusProof.gd'


class C07BeamDrillPowerStatusTests(unittest.TestCase):
    def test_c07_beam_drill_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2155']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154 proved the pure
        # power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker and mechanical-pump drivers -- but
        # BeamDrill (BeamDrill.java:25, `public class BeamDrill
        # extends Block{`) has NO placed-buildings driver at all,
        # so plasma-bore (consumePower 0.15f) / large-plasma-bore
        # (consumePower 0.8f) would drill as if power.status were
        # 1.0. N2155 is the BeamDrill family's live read: a new
        # beam-drill driver with a pure power row over the stamped
        # frame value, folded by the shared machinery into the min
        # efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) and the
        # lastDrillSpeed fold (BeamDrill.java:249) follows it.
        # BeamDrill extends Block, not Drill, so it cannot reuse
        # the drill frame key ("source_drill_building", bound by
        # the drill proximity path for DrillBuild); it gets its
        # own family frame key ("source_beam_drill_building").
        # Two new result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2155']['source_symbols'],
            [
                'source_beam_drill_power_status_row_state_result.row',
                'source_beam_drill_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2155']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_beam_drill_power_status_row_state_result.row': 'SourceBeamDrillBuildState.source_beam_drill_power_status_row_state',
                    'source_beam_drill_power_status_row_state_result.has_power_row': 'SourceBeamDrillBuildState.source_beam_drill_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2155']['runtime_proof'], '/root/C07BeamDrillPowerStatusProof')
        self.assertEqual(
            ledger['N2155']['tests'],
            [
                'test_c07_beam_drill_power_status_registration',
                'test_all_c07_beam_drill_power_status_input_evidence_is_exact',
                'test_beam_drill_power_status_row_state',
                'test_reference_graph_and_actual_c07_beam_drill_power_status',
            ],
        )
        self.assertTrue(ledger['N2155']['deferred_exprs'])

    def test_all_c07_beam_drill_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2155']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_beam_drill_power_status_row_state_result.row': 'SourceBeamDrillBuildState.source_beam_drill_power_status_row_state',
                    'source_beam_drill_power_status_row_state_result.has_power_row': 'SourceBeamDrillBuildState.source_beam_drill_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2155']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_power_status_row_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the beam-drill build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        self.assertIn('return build.power.status;', beam_drill)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', beam_drill)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the plasma-bore
        # (0.15f) and large-plasma-bore (0.8f) power consumers
        # count toward hasConsumers (Block.java:1449,
        # `hasConsumers = consumers.length > 0;`). The beam-drill
        # speed follows the folded efficiency (BeamDrill.java:249,
        # `lastDrillSpeed = (facingAmount * multiplier * timeScale)
        # / drillTime * efficiency;` -- keep on ONE comment line,
        # the N2148 shootWarmup lesson: a split line fails this
        # test), with the warmup gate (BeamDrill.java:242,
        # `warmup = Mathf.approachDelta(warmup, Mathf.num(
        # efficiency > 0), 1f / 60f);`) and the boost multiplier
        # (BeamDrill.java:246, `float multiplier = Mathf.lerp(1f,
        # optionalBoostIntensity, optionalEfficiency);`).
        self.assertIn('"is_power": true', beam_drill)
        self.assertIn('block.properties.has("consumePower")', beam_drill)
        self.assertIn('hasConsumers = consumers.length > 0;', beam_drill)
        self.assertIn('warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);', beam_drill)
        self.assertIn('float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);', beam_drill)
        self.assertIn('lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;', beam_drill)
        self.assertIn('static func source_beam_drill_tick_buildings_state', beam_drill)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # beam-drill tick advances no warmup / time / drillTime /
        # lastDrillSpeed / dump yet (BeamDrill.java:237-263 wait
        # for their own slices), so the lastDrillSpeed fold
        # (BeamDrill.java:249) is what the efficiency keys prove.
        proof = BEAM_DRILL_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'plasma_bore_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'plasma_bore_has_power_consumer',
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
