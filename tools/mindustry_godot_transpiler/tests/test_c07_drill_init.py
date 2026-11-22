import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DRILL_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceDrillRuntimePortBridge.gd'
INIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillInitProof.gd'


class C07DrillInitTests(unittest.TestCase):
    def test_c07_drill_init_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2424']['godot_owner'], 'PortGame.source_drill_init_state')
        # Drill.init() (Drill.java:91-97, `public void
        # init(){`) -- this slice is ONLY the 1 line:
        # `if(drillEffectRnd < 0) drillEffectRnd = size;`
        # (:96). NOT this slice: `super.init();` (:92)
        # and the blockedItems guard
        # `if(blockedItems == null && blockedItem !=
        # null){ blockedItems = Seq.with(blockedItem); }`
        # (:93-95) -- both already owned. The 1
        # distinguishing expr is 0-hit in both the local
        # and the remote ledger (re-probed at base
        # f8c57422, remote origin/main e45de296). One pure
        # function on SourceDrillRuntimePortBridge.gd (the
        # Drill file, non-static func -- the PortGame-era
        # style of this file). The owner is PortGame.*
        # (the N691/N692/N693/N696/N697/N701/N703/N2420
        # precedent for the other Drill legs in this
        # file). The Drill field default is
        # `public float drillEffectRnd = -1f;`
        # (Drill.java:55, "Block size by default") -- a
        # negative value means "use the block size", so
        # the resolved radius is size when the field is
        # negative, the field itself otherwise. One new
        # result symbol: drill_effect_rnd.
        self.assertEqual(
            ledger['N2424']['java_method'],
            'Drill.init()',
        )
        self.assertEqual(
            ledger['N2424']['source_symbols'],
            [
                'source_drill_init_state_result.drill_effect_rnd',
            ],
        )
        for name in ledger['N2424']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/Drill.java')
                self.assertEqual(symbol['godot_owner'], 'PortGame.source_drill_init_state')
        self.assertEqual(ledger['N2424']['runtime_proof'], '/root/C07DrillInitProof')
        self.assertEqual(
            ledger['N2424']['tests'],
            [
                'test_c07_drill_init_registration',
                'test_all_c07_drill_init_input_evidence_is_exact',
                'test_drill_init_state',
                'test_reference_graph_and_actual_c07_drill_init',
            ],
        )
        self.assertTrue(ledger['N2424']['deferred_exprs'])

    def test_all_c07_drill_init_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2424']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.source_drill_init_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2424']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_init_state(self):
        defaults = DRILL_BRIDGE.read_text(encoding='utf-8')
        # Drill.init() (Drill.java:91-97): the only free
        # line is `if(drillEffectRnd < 0) drillEffectRnd
        # = size;` (:96) -- the defaulting rule for the
        # drill effect random radius. The Drill field
        # default is `public float drillEffectRnd = -1f;`
        # (Drill.java:55, "Block size by default"): a
        # negative value resolves to the block size, a
        # non-negative value is kept as-is. No driver
        # tick line: init() runs once at block init, not
        # per-tick. The proof drives the pure function
        # with synthetic frames (no live tick).
        self.assertIn('func source_drill_init_state(drill_effect_rnd: float, size: float) -> Dictionary:', defaults)
        self.assertIn('return {"drill_effect_rnd": resolved_drill_effect_rnd}', defaults)
        for expr in [
            'if(drillEffectRnd < 0) drillEffectRnd = size;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick): the default
        # -1f resolves to size / a negative fraction
        # resolves to size / zero is kept / a positive
        # value is kept / the result-key shape.
        proof = INIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'negative_rnd_defaults_to_size',
            'negative_fraction_defaults_to_size',
            'zero_rnd_kept',
            'positive_rnd_kept',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_init(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillInitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_INIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'negative_rnd_defaults_to_size',
            'negative_fraction_defaults_to_size',
            'zero_rnd_kept',
            'positive_rnd_kept',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
