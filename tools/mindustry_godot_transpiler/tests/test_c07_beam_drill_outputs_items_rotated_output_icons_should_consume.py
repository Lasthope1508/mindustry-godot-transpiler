import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_OUTPUTS_ITEMS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeProof.gd'


class C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeTests(unittest.TestCase):
    def test_c07_beam_drill_outputs_items_rotated_output_icons_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2417']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_outputs_items_state')
        # BeamDrill.outputsItems() (BeamDrill.java:98-100,
        # `public boolean outputsItems(){` with `return
        # true;`) -- unconditional true, overriding the
        # base Block.outputsItems() (Block.java:601-603,
        # `return hasItems;`).
        # BeamDrill.rotatedOutput(int, int)
        # (BeamDrill.java:103-105, `public boolean
        # rotatedOutput(int x, int y){` with `return
        # false;`) -- unconditional false, overriding the
        # base Block.rotatedOutput(int, int)
        # (Block.java:615-617, `return rotate;`).
        # BeamDrill.icons() (BeamDrill.java:108-110,
        # `public TextureRegion[] icons(){` with `return
        # new TextureRegion[]{region, topRegion};`) -- the
        # two-element return array, region first; the twin
        # of BurstDrill.icons() (N2312), which registers
        # the same return line for BurstDrill -- each class
        # owns its own icons().
        # BeamDrillBuild.shouldConsume()
        # (BeamDrill.java:269-272, `public boolean
        # shouldConsume(){` with `return items.total() <
        # itemCapacity && facingAmount > 0 && enabled;`)
        # -- the return line is evidence-only in N2155
        # (the power-status row); N2417 is the first GD
        # func of its own. NOT this slice:
        # BeamDrill.getDrillTime() (BeamDrill.java:216-218)
        # -- body byte-identical with
        # BurstDrill.getDrillTime, already owned at N2344;
        # the GD already calls it through a Callable, so it
        # is not re-ported. NOT this slice: the
        # shouldConsume tick wiring -- the tick driver still
        # runs should_consume=true when enabled; N2417 ports
        # only the pure predicate. The 12 distinguishing
        # exprs are the 0-hit lines re-probed at base
        # 3de1786d in both ledgers (java_method exact 0-hit
        # for all four methods, local and remote). Four new
        # result symbols: outputs_items, rotated_output,
        # icons, should_consume.
        self.assertEqual(
            ledger['N2417']['source_symbols'],
            [
                'source_beam_drill_outputs_items_state_result.outputs_items',
                'source_beam_drill_rotated_output_state_result.rotated_output',
                'source_beam_drill_icons_state_result.icons',
                'source_beam_drill_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2417']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2417']['runtime_proof'], '/root/C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeProof')
        self.assertEqual(
            ledger['N2417']['tests'],
            [
                'test_c07_beam_drill_outputs_items_rotated_output_icons_should_consume_registration',
                'test_all_c07_beam_drill_outputs_items_rotated_output_icons_should_consume_input_evidence_is_exact',
                'test_beam_drill_outputs_items_rotated_output_icons_should_consume_state',
                'test_reference_graph_and_actual_c07_beam_drill_outputs_items_rotated_output_icons_should_consume',
            ],
        )
        self.assertTrue(ledger['N2417']['deferred_exprs'])

    def test_all_c07_beam_drill_outputs_items_rotated_output_icons_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2417']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2417']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_outputs_items_rotated_output_icons_should_consume_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrill.outputsItems() (BeamDrill.java:98-100):
        # unconditional true; the frame carries no live keys
        # (the N2318 canPickup accessor precedent).
        # BeamDrill.rotatedOutput(int, int)
        # (BeamDrill.java:103-105): unconditional false; x/y
        # are explicit params, unused by the override.
        # BeamDrill.icons() (BeamDrill.java:108-110): the
        # two-element return array, region first; region /
        # topRegion arrive as explicit Variant params (the
        # N2312 BurstDrill.icons precedent).
        # BeamDrillBuild.shouldConsume()
        # (BeamDrill.java:270-274): items.total() /
        # facingAmount / enabled / itemCapacity arrive as
        # explicit params -- no live engine call (the N2398
        # updateTile precedent). NO driver tick line: all
        # four are pure accessors, not per-tick writes.
        self.assertIn('static func source_beam_drill_outputs_items_state(frame: Dictionary) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_rotated_output_state(frame: Dictionary, x: int, y: int) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_icons_state(region: Variant, top_region: Variant) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_should_consume_state(items_total: int, item_capacity: int, facing_amount: int, enabled: bool) -> Dictionary:', state)
        self.assertIn('return {"outputs_items": true}', state)
        self.assertIn('return {"rotated_output": false}', state)
        self.assertIn('return {"icons": icons}', state)
        self.assertIn('return {"should_consume": items_total < item_capacity and facing_amount > 0 and enabled}', state)
        for expr in [
            'public boolean outputsItems(){',
            'return true;',
            'public boolean rotatedOutput(int x, int y){',
            'return false;',
            'public TextureRegion[] icons(){',
            'return new TextureRegion[]{region, topRegion};',
            'public boolean shouldConsume(){',
            'return items.total() < itemCapacity && facingAmount > 0 && enabled;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure functions with
        # synthetic frames / explicit params (no live tick):
        # outputsItems is true whatever the frame holds /
        # rotatedOutput is false for any coords / icons
        # returns [region, topRegion] for both defs /
        # shouldConsume follows the three-way gate with the
        # at-capacity boundary false / the result-key shapes.
        proof = BEAM_DRILL_OUTPUTS_ITEMS_PROOF.read_text(encoding='utf-8')
        for key in [
            'outputs_items_true',
            'outputs_items_ignores_frame',
            'rotated_output_false',
            'rotated_output_ignores_coords',
            'icons_plasma_bore',
            'icons_large_plasma_bore',
            'icons_length_two',
            'should_consume_true_when_room_and_facing_and_enabled',
            'should_consume_false_when_items_full',
            'should_consume_false_when_no_facing',
            'should_consume_false_when_disabled',
            'should_consume_false_at_capacity_boundary',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_outputs_items_rotated_output_icons_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_OUTPUTS_ITEMS_ROTATED_OUTPUT_ICONS_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'outputs_items_true',
            'outputs_items_ignores_frame',
            'rotated_output_false',
            'rotated_output_ignores_coords',
            'icons_plasma_bore',
            'icons_large_plasma_bore',
            'icons_length_two',
            'should_consume_true_when_room_and_facing_and_enabled',
            'should_consume_false_when_items_full',
            'should_consume_false_when_no_facing',
            'should_consume_false_when_disabled',
            'should_consume_false_at_capacity_boundary',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
