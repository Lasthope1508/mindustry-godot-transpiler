import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OVERDRIVE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd'
OVERDRIVE_PROJECTOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorPowerStatusProof.gd'


class C07OverdriveProjectorPowerStatusTests(unittest.TestCase):
    def test_c07_overdrive_projector_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2157']['godot_owner'], 'SourceOverdriveProjectorBuildState.source_overdrive_projector_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156 proved
        # the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill,
        # solid-pump, point-defense, tractor-beam, fracker,
        # mechanical-pump, beam-drill and mend-projector drivers
        # -- but OverdriveProjector (OverdriveProjector.java:21,
        # `public class OverdriveProjector extends Block{`) has NO
        # placed-buildings driver at all, so overdrive-projector
        # (consumePower 3.50f) / overdrive-dome (consumePower 10f)
        # would overdrive as if power.status were 1.0. N2157 is
        # the OverdriveProjector family's live read: a new
        # overdrive-projector driver with a pure power row over
        # the stamped frame value, folded by the shared machinery
        # into the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) and the
        # real-boost fold (OverdriveProjector.java:124) follows
        # it. OverdriveProjector extends Block, not a drill or
        # factory, so it cannot reuse an existing frame key; it
        # gets its own family frame key
        # ("source_overdrive_projector_building", the
        # mechanical-pump / beam-drill / mend-projector
        # precedent). Two new result symbols: the row and its
        # presence flag.
        self.assertEqual(
            ledger['N2157']['source_symbols'],
            [
                'source_overdrive_projector_power_status_row_state_result.row',
                'source_overdrive_projector_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2157']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_overdrive_projector_power_status_row_state_result.row': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_power_status_row_state',
                    'source_overdrive_projector_power_status_row_state_result.has_power_row': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2157']['runtime_proof'], '/root/C07OverdriveProjectorPowerStatusProof')
        self.assertEqual(
            ledger['N2157']['tests'],
            [
                'test_c07_overdrive_projector_power_status_registration',
                'test_all_c07_overdrive_projector_power_status_input_evidence_is_exact',
                'test_overdrive_projector_power_status_row_state',
                'test_reference_graph_and_actual_c07_overdrive_projector_power_status',
            ],
        )
        self.assertTrue(ledger['N2157']['deferred_exprs'])

    def test_all_c07_overdrive_projector_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2157']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_overdrive_projector_power_status_row_state_result.row': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_power_status_row_state',
                    'source_overdrive_projector_power_status_row_state_result.has_power_row': 'SourceOverdriveProjectorBuildState.source_overdrive_projector_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/OverdriveProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2157']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_overdrive_projector_power_status_row_state(self):
        overdrive_projector = OVERDRIVE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the overdrive-projector build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_overdrive_projector_power_status_row_state', overdrive_projector)
        self.assertIn('return build.power.status;', overdrive_projector)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', overdrive_projector)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # overdrive-projector (3.50f) and overdrive-dome (10f)
        # power consumers count toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`). The real boost follows the folded efficiency
        # (OverdriveProjector.java:124, `return (speedBoost +
        # phaseHeat * speedBoostPhase) * efficiency;` -- keep on
        # ONE comment line, the N2148 shootWarmup lesson: a split
        # line fails this test), with the smooth-efficiency gate
        # (OverdriveProjector.java:98, `smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`)
        # and the heat gate (OverdriveProjector.java:99, `heat =
        # Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);`)
        # and the charge advance (OverdriveProjector.java:100,
        # `charge += heat * Time.delta;`).
        self.assertIn('"is_power": true', overdrive_projector)
        self.assertIn('block.properties.has("consumePower")', overdrive_projector)
        self.assertIn('hasConsumers = consumers.length > 0;', overdrive_projector)
        self.assertIn('smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);', overdrive_projector)
        self.assertIn('heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);', overdrive_projector)
        self.assertIn('charge += heat * Time.delta;', overdrive_projector)
        self.assertIn('return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_tick_buildings_state', overdrive_projector)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress/boost keys:
        # the overdrive-projector tick advances no
        # smoothEfficiency / heat / charge / phaseHeat /
        # useProgress / boost yet (OverdriveProjector.java:97-120
        # wait for their own slices), so the real-boost fold
        # (OverdriveProjector.java:124) is what the efficiency
        # keys prove.
        proof = OVERDRIVE_PROJECTOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'overdrive_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_overdrive_projector_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07OverdriveProjectorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_OVERDRIVE_PROJECTOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'overdrive_has_power_consumer',
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
