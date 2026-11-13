import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE_SHIELD_STATE = ROOT / 'godot-mindustry/src/game/SourceBaseShieldBuildState.gd'
BASE_SHIELD_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldPowerStatusProof.gd'


class C07BaseShieldPowerStatusTests(unittest.TestCase):
    def test_c07_base_shield_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2159']['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158 proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill,
        # solid-pump, point-defense, tractor-beam, fracker,
        # mechanical-pump, beam-drill, mend-projector,
        # overdrive-projector and force-projector drivers -- but
        # BaseShield (BaseShield.java:18, `public class
        # BaseShield extends Block{`) has NO placed-buildings
        # driver at all, so shield-projector and
        # large-shield-projector (consumePower 5f each) would
        # shield as if power.status were 1.0. N2159 is the
        # BaseShield family's live read: a new base-shield
        # driver with a pure power row over the stamped frame
        # value, folded by the shared machinery into the min
        # efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) and the
        # smooth-radius fold (BaseShield.java:89) follows it.
        # BaseShield extends Block, not a drill or factory, so
        # it cannot reuse an existing frame key; it gets its own
        # family frame key ("source_base_shield_building", the
        # mechanical-pump / beam-drill / mend-projector /
        # overdrive-projector / force-projector precedent). Two
        # new result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2159']['source_symbols'],
            [
                'source_base_shield_power_status_row_state_result.row',
                'source_base_shield_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2159']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_base_shield_power_status_row_state_result.row': 'SourceBaseShieldBuildState.source_base_shield_power_status_row_state',
                    'source_base_shield_power_status_row_state_result.has_power_row': 'SourceBaseShieldBuildState.source_base_shield_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2159']['runtime_proof'], '/root/C07BaseShieldPowerStatusProof')
        self.assertEqual(
            ledger['N2159']['tests'],
            [
                'test_c07_base_shield_power_status_registration',
                'test_all_c07_base_shield_power_status_input_evidence_is_exact',
                'test_base_shield_power_status_row_state',
                'test_reference_graph_and_actual_c07_base_shield_power_status',
            ],
        )
        self.assertTrue(ledger['N2159']['deferred_exprs'])

    def test_all_c07_base_shield_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2159']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_base_shield_power_status_row_state_result.row': 'SourceBaseShieldBuildState.source_base_shield_power_status_row_state',
                    'source_base_shield_power_status_row_state_result.has_power_row': 'SourceBaseShieldBuildState.source_base_shield_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/BaseShield.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2159']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_shield_power_status_row_state(self):
        base_shield = BASE_SHIELD_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the base-shield build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_base_shield_power_status_row_state', base_shield)
        self.assertIn('return build.power.status;', base_shield)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', base_shield)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # shield-projector and large-shield-projector (5f each)
        # power consumers count toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`). The smooth radius follows the folded efficiency
        # (BaseShield.java:89, `smoothRadius =
        # Mathf.lerpDelta(smoothRadius, radius * efficiency,
        # 0.05f);` -- keep on ONE comment line, the N2148
        # shootWarmup lesson: a split line fails this test), the
        # shield only engages past radius 1 (BaseShield.java:91,
        # `float rad = radius();`) and the default radius is
        # 200f (BaseShield.java:20, `public float radius =
        # 200f;`, large-shield-projector 400f, Blocks.java:2060,
        # `radius = 400f;`).
        self.assertIn('"is_power": true', base_shield)
        self.assertIn('block.properties.has("consumePower")', base_shield)
        self.assertIn('hasConsumers = consumers.length > 0;', base_shield)
        self.assertIn('smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);', base_shield)
        self.assertIn('float rad = radius();', base_shield)
        self.assertIn('public float radius = 200f;', base_shield)
        self.assertIn('radius = 400f;', base_shield)
        self.assertIn('static func source_base_shield_tick_buildings_state', base_shield)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no shield / radius /
        # broken keys: the base-shield tick advances no
        # smoothRadius / bullet absorb / unit repel / broken /
        # hit yet (BaseShield.java:88-99, 125-147 wait for their
        # own slices), so the smooth-radius fold
        # (BaseShield.java:89) is what the efficiency keys prove.
        proof = BASE_SHIELD_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'shield_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_base_shield_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseShieldPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_SHIELD_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shield_has_power_consumer',
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
