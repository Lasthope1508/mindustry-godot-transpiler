import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BULLET_ENTRY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretBulletEntryProof.gd'


class C07TurretBulletEntryTests(unittest.TestCase):
    def test_c07_turret_bullet_entry_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2410']['godot_owner'], 'SourceTurretBuildState.source_turret_bullet_entry_state')
        # TurretBuild.BulletEntry ctor (Turret.java:867-873), one
        # ctor slice (batch 28 slot 3): the 2 unowned field
        # assignments only. `this.x = x;` and `this.y = y;` are
        # already exact_exprs of N1115 and `this.rotation =
        # rotation;` is already an exact_expr of N1770 -- none
        # of the three is re-registered here. One GD function
        # on SourceTurretBuildState.gd (the TurretBuild file);
        # BulletEntry is an inner data class, not a Build, so
        # the port is a pure function returning the record
        # Dictionary (main-thread decision 2026-11-22, recorded
        # in allocations.json N2410) -- it takes the 5 ctor
        # params as explicit params (the N2188 precedent) and
        # returns all 5 record fields. The inline
        # `bullet_entry` dict in the Continuous/LaserTurret
        # bridges is not a ctor func -- no dedup, no probe.
        self.assertEqual(
            ledger['N2410']['java_method'],
            'BulletEntry(Bullet, float, float, float, float)',
        )
        self.assertEqual(
            ledger['N2410']['source_symbols'],
            [
                'source_turret_bullet_entry_state_result.bullet',
                'source_turret_bullet_entry_state_result.x',
                'source_turret_bullet_entry_state_result.y',
                'source_turret_bullet_entry_state_result.rotation',
                'source_turret_bullet_entry_state_result.life',
            ],
        )
        for name in ledger['N2410']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_bullet_entry_state'))
        self.assertEqual(ledger['N2410']['runtime_proof'], '/root/C07TurretBulletEntryProof')
        self.assertEqual(
            ledger['N2410']['tests'],
            [
                'test_c07_turret_bullet_entry_registration',
                'test_all_c07_turret_bullet_entry_input_evidence_is_exact',
                'test_turret_bullet_entry_state',
                'test_reference_graph_and_actual_c07_turret_bullet_entry',
            ],
        )
        self.assertTrue(ledger['N2410']['deferred_exprs'])

    def test_all_c07_turret_bullet_entry_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2410']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_bullet_entry_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2410']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_bullet_entry_state(self):
        state = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.BulletEntry ctor (Turret.java:867-873):
        # the ctor assigns 5 fields on the inner record; the
        # 2 other lines are owned by N1115/N1770 (see the
        # registration test) and are NOT re-registered.
        self.assertIn('static func source_turret_bullet_entry_state(bullet: Variant, x: float, y: float, rotation: float, life: float) -> Dictionary:', state)
        for expr in [
            'this.bullet = bullet;',
            'this.life = life;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): one
        # call returns all 5 record fields, returns only
        # those 5 keys, passes the bullet ref through
        # unchanged, keeps life a float, and is idempotent
        # on a second call with the same args.
        proof = BULLET_ENTRY_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_fields_all_five',
            'ctor_returns_only_five_keys',
            'ctor_bullet_passthrough',
            'ctor_life_float',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_bullet_entry(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretBulletEntryProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_BULLET_ENTRY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_fields_all_five',
            'ctor_returns_only_five_keys',
            'ctor_bullet_passthrough',
            'ctor_life_float',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
