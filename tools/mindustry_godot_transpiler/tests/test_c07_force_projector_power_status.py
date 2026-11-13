import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorPowerStatusProof.gd'


class C07ForceProjectorPowerStatusTests(unittest.TestCase):
    def test_c07_force_projector_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2158']['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157
        # proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill,
        # solid-pump, point-defense, tractor-beam, fracker,
        # mechanical-pump, beam-drill, mend-projector and
        # overdrive-projector drivers -- but ForceProjector
        # (ForceProjector.java:30, `public class ForceProjector
        # extends Block{`) has NO placed-buildings driver at
        # all, so force-projector (consumePower 4f) would shield
        # as if power.status were 1.0. N2158 is the
        # ForceProjector family's live read: a new
        # force-projector driver with a pure power row over the
        # stamped frame value, folded by the shared machinery
        # into the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) and the
        # warmup fold (ForceProjector.java:221) follows it.
        # ForceProjector extends Block, not a drill or factory,
        # so it cannot reuse an existing frame key; it gets its
        # own family frame key
        # ("source_force_projector_building", the
        # mechanical-pump / beam-drill / mend-projector /
        # overdrive-projector precedent). Two new result symbols:
        # the row and its presence flag.
        self.assertEqual(
            ledger['N2158']['source_symbols'],
            [
                'source_force_projector_power_status_row_state_result.row',
                'source_force_projector_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2158']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_force_projector_power_status_row_state_result.row': 'SourceForceProjectorBuildState.source_force_projector_power_status_row_state',
                    'source_force_projector_power_status_row_state_result.has_power_row': 'SourceForceProjectorBuildState.source_force_projector_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2158']['runtime_proof'], '/root/C07ForceProjectorPowerStatusProof')
        self.assertEqual(
            ledger['N2158']['tests'],
            [
                'test_c07_force_projector_power_status_registration',
                'test_all_c07_force_projector_power_status_input_evidence_is_exact',
                'test_force_projector_power_status_row_state',
                'test_reference_graph_and_actual_c07_force_projector_power_status',
            ],
        )
        self.assertTrue(ledger['N2158']['deferred_exprs'])

    def test_all_c07_force_projector_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2158']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_force_projector_power_status_row_state_result.row': 'SourceForceProjectorBuildState.source_force_projector_power_status_row_state',
                    'source_force_projector_power_status_row_state_result.has_power_row': 'SourceForceProjectorBuildState.source_force_projector_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2158']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_power_status_row_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the force-projector build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_force_projector_power_status_row_state', force_projector)
        self.assertIn('return build.power.status;', force_projector)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', force_projector)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # force-projector (4f) power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The warmup follows the folded
        # efficiency (ForceProjector.java:221, `warmup =
        # Mathf.lerpDelta(warmup, efficiency, 0.1f);` -- keep on
        # ONE comment line, the N2148 shootWarmup lesson: a split
        # line fails this test), the shield radius scale follows
        # warmup (ForceProjector.java:215, `radscl =
        # Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`)
        # and the real radius folds both
        # (ForceProjector.java:280, `return (radius + phaseHeat *
        # phaseRadiusBoost) * radscl;`).
        self.assertIn('"is_power": true', force_projector)
        self.assertIn('block.properties.has("consumePower")', force_projector)
        self.assertIn('hasConsumers = consumers.length > 0;', force_projector)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);', force_projector)
        self.assertIn('radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);', force_projector)
        self.assertIn('return (radius + phaseHeat * phaseRadiusBoost) * radscl;', force_projector)
        self.assertIn('static func source_force_projector_tick_buildings_state', force_projector)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no shield / warmup /
        # buildup keys: the force-projector tick advances no
        # phaseHeat / radscl / warmup / buildup / broken /
        # deflectBullets yet (ForceProjector.java:207-268 wait for
        # their own slices), so the warmup fold
        # (ForceProjector.java:221) is what the efficiency keys
        # prove.
        proof = FORCE_PROJECTOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'force_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_force_projector_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'force_has_power_consumer',
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
