import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_PROGRESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretProgressProof.gd'


class C07TurretProgressTests(unittest.TestCase):
    def test_c07_turret_progress_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2292']['godot_owner'], 'SourceTurretBuildState.source_turret_progress_state')
        # TurretBuild overrides progress (Turret.java:425-427,
        # `public float progress(){` / `return
        # Mathf.clamp(reloadCounter / reload);`) over the base
        # default BuildingComp.progress (BuildingComp.java:617-619,
        # `public float progress(){` / `return 0f;`). The inputs
        # are reloadCounter (ReloadTurret.java:26, `public float
        # reloadCounter;`, advanced in updateReload,
        # Turret.java:720-723 and capped at reload, Turret.java:723,
        # `reloadCounter = Math.min(reloadCounter, reload);`)
        # against the per-def reload time (ReloadTurret.java:10,
        # `public float reload = 10f;`). arc Mathf.clamp with one
        # argument clamps to [0, 1] (the MendProjector precedent,
        # SourceMendProjectorState.gd:41, `clamp(charge /
        # reload_value, 0.0, 1.0)`). The only live consumer is
        # sense() case progress (Turret.java:414, `case progress
        # -> progress();`) -- the assigned N2255 slice; setBars
        # (Turret.java:192-202) never reads progress(). This
        # closes the deferred item recorded in N2253. RED
        # decisions (recorded in the register docstring): (1)
        # one pure function on SourceTurretBuildState.gd next to
        # the N2253 shouldConsume row, (frame, reload_counter,
        # reload), following the N2188 explicit-param
        # precedent -- frame reads no live key, the two inputs
        # arrive as explicit params. (2) NO driver line: the
        # tick frame tracks neither reloadCounter nor reload
        # yet, and wiring frame defaults would stamp a constant
        # 0.0 progress -- pure function only, the N2251 / N2252
        # precedent; sense() (N2255) calls it with explicit
        # params. (3) sense() stays DEFERRED (assigned N2255).
        # One new result symbol: progress.
        self.assertEqual(
            ledger['N2292']['source_symbols'],
            [
                'source_turret_progress_state_result.progress',
            ],
        )
        for name in ledger['N2292']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2292']['runtime_proof'], '/root/C07TurretProgressProof')
        self.assertEqual(
            ledger['N2292']['tests'],
            [
                'test_c07_turret_progress_registration',
                'test_all_c07_turret_progress_input_evidence_is_exact',
                'test_turret_progress_state',
                'test_reference_graph_and_actual_c07_turret_progress',
            ],
        )
        self.assertTrue(ledger['N2292']['deferred_exprs'])
        self.assertNotIn(
            'TurretBuild.progress() (Turret.java:425-427)',
            ' '.join(ledger['N2292']['deferred_exprs']),
        )

    def test_all_c07_turret_progress_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2292']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2292']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_progress_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.progress() (Turret.java:425-427):
        # `return Mathf.clamp(reloadCounter / reload);`
        # over reloadCounter (ReloadTurret.java:26, capped at
        # reload, Turret.java:723) against reload
        # (ReloadTurret.java:10, `public float reload =
        # 10f;`). The base default it overrides is
        # BuildingComp.progress (BuildingComp.java:617-619,
        # `return 0f;`). arc Mathf.clamp with one argument
        # clamps to [0, 1] (the MendProjector precedent,
        # SourceMendProjectorState.gd:41). No driver line:
        # the only consumer is sense() case progress
        # (Turret.java:414, N2255), and the tick frame tracks
        # neither reloadCounter nor reload yet, so wiring
        # frame defaults would stamp a constant 0.0.
        self.assertIn('static func source_turret_progress_state(frame: Dictionary, reload_counter: float, reload: float) -> Dictionary:', turret)
        self.assertIn('return {"progress": clampf(reload_counter / reload, 0.0, 1.0)}', turret)
        for expr in [
            'public float progress(){',
            'return Mathf.clamp(reloadCounter / reload);',
            'public float reloadCounter;',
            'public float reload = 10f;',
            'reloadCounter = Math.min(reloadCounter, reload);',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'return 0f;',
            'case progress -> progress();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: an empty counter reads 0, a
        # half counter reads 0.5, a full counter reads 1, a
        # counter past reload clamps to 1 (live it is capped
        # at reload, Turret.java:723), and a negative counter
        # clamps to 0.
        proof = TURRET_PROGRESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_zero',
            'progress_half',
            'progress_full',
            'progress_beyond_reload',
            'progress_negative',
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
            'progress_zero',
            'progress_half',
            'progress_full',
            'progress_beyond_reload',
            'progress_negative',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
