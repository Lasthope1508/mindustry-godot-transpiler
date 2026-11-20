import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_PROGRESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretProgressProof.gd'


class C07TurretProgressTests(unittest.TestCase):
    def test_c07_turret_progress_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2282']['godot_owner'], 'SourceTurretBuildState.source_turret_progress_state')
        # progress() is `public float progress(){ return
        # Mathf.clamp(reloadCounter / reload); }`
        # (Turret.java:425-427) on the fields `public float
        # reloadCounter;` (ReloadTurret.java:26, inherited by
        # TurretBuild via ReloadTurretBuild -- the driver
        # already stamps it live as frame["reload_counter"]
        # from the aim tick, capped at reload by updateReload
        # :720-723) and `public float reload = 10f;`
        # (ReloadTurret.java:10, class default; duo overrides
        # `reload = 20f;`, Blocks.java:3317 -- the driver aim
        # call already passes 20.0). Mathf.clamp(float) is
        # `return Math.max(Math.min(value, 1f), 0f);`
        # (arc Mathf.java:402-404) -- GDScript clampf(value,
        # 0.0, 1.0) is the same min-then-max. The only Java
        # consumer is sense() LAccess.progress (`case progress
        # -> progress();`, Turret.java:414); the sense dispatch
        # is its own later slice, so no consumer is rewired:
        # this slice is stamp-only like N2280/N2281, one pure
        # function plus one driver tick. One new result symbol:
        # progress.
        self.assertEqual(
            ledger['N2282']['source_symbols'],
            [
                'source_turret_progress_state_result.progress',
            ],
        )
        for name in ledger['N2282']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_progress_state')
        self.assertEqual(ledger['N2282']['runtime_proof'], '/root/C07TurretProgressProof')
        self.assertEqual(
            ledger['N2282']['tests'],
            [
                'test_c07_turret_progress_registration',
                'test_all_c07_turret_progress_input_evidence_is_exact',
                'test_turret_progress_state',
                'test_reference_graph_and_actual_c07_turret_progress',
            ],
        )
        self.assertTrue(ledger['N2282']['deferred_exprs'])

    def test_all_c07_turret_progress_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2282']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_progress_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'arc-core/src/arc/math/Mathf.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2282']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_progress_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # progress() (Turret.java:425-427) is `return
        # Mathf.clamp(reloadCounter / reload);`. The pure
        # function takes the two live inputs -- reload_counter
        # (ReloadTurret.java:26, the live counter stamped by
        # the aim tick, frame["reload_counter"]) and reload
        # (ReloadTurret.java:10, class default 10f; duo 20f,
        # Blocks.java:3317, the same 20.0 the driver aim call
        # already passes) -- and returns one key:
        # `{"progress": ..}`. The driver tick runs in the duo
        # branch right AFTER the reload_counter stamp (:1683),
        # once the counter is final for this tick, and stamps
        # the key on the frame. No consumer is rewired: the
        # sense() LAccess.progress dispatch (Turret.java:414)
        # is its own later slice; this slice is stamp-only
        # like N2280/N2281.
        self.assertIn('static func source_turret_progress_state(reload_counter: float, reload: float) -> Dictionary:', turret)
        self.assertIn('var progress: float = clampf(reload_counter / reload, 0.0, 1.0)', turret)
        self.assertIn('return {"progress": progress}', turret)
        self.assertIn('public float progress(){', turret)
        self.assertIn('return Mathf.clamp(reloadCounter / reload);', turret)
        self.assertIn('case progress -> progress();', turret)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', turret)
        self.assertIn('reload = 20f;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch right
        # after the reload_counter stamp: it derives progress
        # live from the frame counter and the duo reload and
        # stamps the key.
        self.assertIn('var progress_state: Dictionary = source_turret_progress_state(float(frame.get("reload_counter", 0.0)), 20.0)', turret)
        self.assertIn('frame["progress"] = progress_state.get("progress", 0.0)', turret)
        self.assertLess(turret.index('frame["reload_counter"] = aim.get("reload_counter", 0.0)'), turret.index('var progress_state: Dictionary = source_turret_progress_state('))
        self.assertLess(turret.index('var progress_state: Dictionary = source_turret_progress_state('), turret.index('frame["shot"] = aim.get("shot", false)'))
        # The pure function sits immediately BEFORE
        # source_turret_is_shooting_state, since Java order is
        # progress :425-427 before isShooting :440-442.
        self.assertLess(turret.index('static func source_turret_progress_state('), turret.index('static func source_turret_is_shooting_state('))
        # The proof's keys pin the clamp through the pure
        # function and the real driver (empty / half / full /
        # above-reload -- directly; the key stamped live on the
        # frame by the driver).
        proof = TURRET_PROGRESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_zero_at_empty_counter',
            'progress_half_at_half_counter',
            'progress_one_at_full_counter',
            'progress_clamped_above_reload',
            'progress_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_progress(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretProgressProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_PROGRESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_zero_at_empty_counter',
            'progress_half_at_half_counter',
            'progress_one_at_full_counter',
            'progress_clamped_above_reload',
            'progress_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
