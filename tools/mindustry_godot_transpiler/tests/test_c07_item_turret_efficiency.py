import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_TURRET_BUILD = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildPortBridge.gd'
EFFICIENCY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemTurretEfficiencyProof.gd'


class C07ItemTurretEfficiencyTests(unittest.TestCase):
    def test_c07_item_turret_efficiency_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2419']['godot_owner'], 'PortGame.source_item_turret_efficiency_state')
        # Anonymous ConsumeItemFilter.efficiency(Building
        # build) inside ItemTurret.init()
        # (ItemTurret.java:83-88), one efficiency slice
        # (batch 31 slot 3): the 1 distinguishing return
        # expr only. `//valid when it can shoot` is the
        # comment on the line above it (:85). The
        # signature `public float efficiency(Building
        # build){` is generic (15 ledger records) and is
        # registered per the N2318 precedent. N1177 owns
        # ItemTurret.init() but NOT this efficiency leg;
        # N1467 owns the base ConsumeItemFilter
        # .efficiency() body (`return
        # build.consumeTriggerValid() ||
        # getConsumed(build) != null ? 1f : 0f;`), a
        # different expr -- neither is re-registered
        # here. The PAT twin (`return build instanceof
        # PayloadTurretBuild it && it.payloads.any() ? 1f
        # : 0f;`) is N2396-owned, a different expr. One
        # GD function on
        # SourceItemTurretBuildPortBridge.gd (the
        # ItemTurret file, NOT a new file -- N2416 ctor
        # precedent). The owner is PortGame.* (this file
        # is a PortBridge -- N2358/N2384/N2396
        # precedent), NOT the file class name. The
        # result is frame data only (one float); no Draw
        # is ported.
        self.assertEqual(
            ledger['N2419']['java_method'],
            'ItemTurret.init() ConsumeItemFilter.efficiency(Building build)',
        )
        self.assertEqual(
            ledger['N2419']['source_symbols'],
            [
                'source_item_turret_efficiency_state_result.efficiency',
            ],
        )
        for name in ledger['N2419']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_item_turret_efficiency_state'))
        self.assertEqual(ledger['N2419']['runtime_proof'], '/root/C07ItemTurretEfficiencyProof')
        self.assertEqual(
            ledger['N2419']['tests'],
            [
                'test_c07_item_turret_efficiency_registration',
                'test_all_c07_item_turret_efficiency_input_evidence_is_exact',
                'test_item_turret_efficiency_state',
                'test_reference_graph_and_actual_c07_item_turret_efficiency',
            ],
        )
        self.assertTrue(ledger['N2419']['deferred_exprs'])

    def test_all_c07_item_turret_efficiency_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2419']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_item_turret_efficiency_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2419']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_turret_efficiency_state(self):
        defaults = ITEM_TURRET_BUILD.read_text(encoding='utf-8')
        # Anonymous ConsumeItemFilter.efficiency(Building
        # build) inside ItemTurret.init()
        # (ItemTurret.java:83-88): 1.0 exactly when the
        # build is an ItemTurretBuild with ammo and the
        # peeked entry holds at least ammoPerShot -- or
        # the build is cheating -- else 0.0. Valid when
        # it can shoot.
        self.assertIn('static func source_item_turret_efficiency_state(is_item_turret_build: bool, ammo_size: int, peek_amount: int, ammo_per_shot: int, cheating: bool) -> Dictionary:', defaults)
        for expr in [
            'return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;',
            'public float efficiency(Building build){',
            '//valid when it can shoot',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): 1.0
        # when it can shoot, 1.0 when cheating even with
        # too little peeked ammo, 0.0 when not an
        # ItemTurretBuild, 0.0 with no ammo, 0.0 when the
        # peeked amount is below ammoPerShot without
        # cheating, 1.0 at exactly ammoPerShot, and the
        # result carries only the efficiency key.
        proof = EFFICIENCY_PROOF.read_text(encoding='utf-8')
        for key in [
            'efficiency_full_when_can_shoot',
            'efficiency_full_when_cheating',
            'efficiency_zero_when_not_item_turret_build',
            'efficiency_zero_when_no_ammo',
            'efficiency_zero_when_peek_below_per_shot',
            'efficiency_full_at_exact_per_shot',
            'efficiency_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_item_turret_efficiency(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemTurretEfficiencyProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_TURRET_EFFICIENCY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'efficiency_full_when_can_shoot',
            'efficiency_full_when_cheating',
            'efficiency_zero_when_not_item_turret_build',
            'efficiency_zero_when_no_ammo',
            'efficiency_zero_when_peek_below_per_shot',
            'efficiency_full_at_exact_per_shot',
            'efficiency_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
