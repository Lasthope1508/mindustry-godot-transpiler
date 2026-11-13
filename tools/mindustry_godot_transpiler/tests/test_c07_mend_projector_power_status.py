import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorPowerStatusProof.gd'


class C07MendProjectorPowerStatusTests(unittest.TestCase):
    def test_c07_mend_projector_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2156']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155 proved the pure
        # power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump and beam-drill
        # drivers -- but MendProjector (MendProjector.java:21,
        # `public class MendProjector extends Block{`) has NO
        # placed-buildings driver at all, so mender (consumePower
        # 0.3f) / mend-projector (consumePower 1.5f) would heal as
        # if power.status were 1.0. N2156 is the MendProjector
        # family's live read: a new mend-projector driver with a
        # pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) and the heal fold
        # (MendProjector.java:113) follows it. MendProjector
        # extends Block, not a drill or factory, so it cannot reuse
        # an existing frame key; it gets its own family frame key
        # ("source_mend_projector_building", the mechanical-pump /
        # beam-drill precedent). Two new result symbols: the row
        # and its presence flag.
        self.assertEqual(
            ledger['N2156']['source_symbols'],
            [
                'source_mend_projector_power_status_row_state_result.row',
                'source_mend_projector_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2156']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_power_status_row_state_result.row': 'SourceMendProjectorBuildState.source_mend_projector_power_status_row_state',
                    'source_mend_projector_power_status_row_state_result.has_power_row': 'SourceMendProjectorBuildState.source_mend_projector_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2156']['runtime_proof'], '/root/C07MendProjectorPowerStatusProof')
        self.assertEqual(
            ledger['N2156']['tests'],
            [
                'test_c07_mend_projector_power_status_registration',
                'test_all_c07_mend_projector_power_status_input_evidence_is_exact',
                'test_mend_projector_power_status_row_state',
                'test_reference_graph_and_actual_c07_mend_projector_power_status',
            ],
        )
        self.assertTrue(ledger['N2156']['deferred_exprs'])

    def test_all_c07_mend_projector_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2156']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_power_status_row_state_result.row': 'SourceMendProjectorBuildState.source_mend_projector_power_status_row_state',
                    'source_mend_projector_power_status_row_state_result.has_power_row': 'SourceMendProjectorBuildState.source_mend_projector_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2156']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_power_status_row_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the mend-projector build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_mend_projector_power_status_row_state', mend_projector)
        self.assertIn('return build.power.status;', mend_projector)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', mend_projector)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the mender
        # (0.3f) and mend-projector (1.5f) power consumers
        # count toward hasConsumers (Block.java:1449,
        # `hasConsumers = consumers.length > 0;`). The heal
        # follows the folded efficiency (MendProjector.java:113,
        # `other.heal(other.maxHealth() * (healPercent + phaseHeat
        # * phaseBoost) / 100f * efficiency);` -- keep on ONE
        # comment line, the N2148 shootWarmup lesson: a split line
        # fails this test), with the smooth-efficiency gate
        # (MendProjector.java:96, `smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`)
        # and the heat gate (MendProjector.java:97, `heat =
        # Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f,
        # 0.08f);`) and the charge advance (MendProjector.java:98,
        # `charge += heat * delta();`).
        self.assertIn('"is_power": true', mend_projector)
        self.assertIn('block.properties.has("consumePower")', mend_projector)
        self.assertIn('hasConsumers = consumers.length > 0;', mend_projector)
        self.assertIn('smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);', mend_projector)
        self.assertIn('heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);', mend_projector)
        self.assertIn('charge += heat * delta();', mend_projector)
        self.assertIn('other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);', mend_projector)
        self.assertIn('static func source_mend_projector_tick_buildings_state', mend_projector)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress/heal keys:
        # the mend-projector tick advances no smoothEfficiency /
        # heat / charge / phaseHeat / heal yet
        # (MendProjector.java:96-120 wait for their own slices),
        # so the heal fold (MendProjector.java:113) is what the
        # efficiency keys prove.
        proof = MEND_PROJECTOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'mender_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_mend_projector_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'mender_has_power_consumer',
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
