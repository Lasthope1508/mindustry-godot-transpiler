import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SHOOT_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretShootStampProof.gd'


class C07TurretShootStampTests(unittest.TestCase):
    def test_c07_turret_shoot_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2255']['godot_owner'], 'SourceTurretBuildState.source_turret_shoot_stamp_state')
        # TurretBuild.bullet (Turret.java:779-812) stamps the
        # recoil and the heat and counts the shot after the
        # bullet is created: `curRecoil = 1f;` (Turret.java:806),
        # `heat = 1f;` (:810) and `totalShots++;` (:811). The
        # driver never stamped any of the three -- N2252 only
        # stamped frame["bullet_spawn"] and N2254 only decayed
        # the values toward 0 -- so a duo that shoots keeps
        # cur_recoil 0 / heat 0 / total_shots 0 live. This slice
        # adds the one pure function on the shared TurretBuild
        # driver file (bullet() is TurretBuild's method, common
        # to every turret, not ItemTurret-only) plus one driver
        # tick in the duo shot branch AFTER the
        # spawn_turret_bullet call (Java order :806-811 after
        # the bullet is created at :797). Three new result
        # symbols: cur_recoil + heat + total_shots.
        self.assertEqual(
            ledger['N2255']['source_symbols'],
            [
                'source_turret_shoot_stamp_state_result.cur_recoil',
                'source_turret_shoot_stamp_state_result.heat',
                'source_turret_shoot_stamp_state_result.total_shots',
            ],
        )
        for name in ledger['N2255']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_shoot_stamp_state_result.cur_recoil': 'SourceTurretBuildState.source_turret_shoot_stamp_state',
                    'source_turret_shoot_stamp_state_result.heat': 'SourceTurretBuildState.source_turret_shoot_stamp_state',
                    'source_turret_shoot_stamp_state_result.total_shots': 'SourceTurretBuildState.source_turret_shoot_stamp_state',
                }[name])
        self.assertEqual(ledger['N2255']['runtime_proof'], '/root/C07TurretShootStampProof')
        self.assertEqual(
            ledger['N2255']['tests'],
            [
                'test_c07_turret_shoot_stamp_registration',
                'test_all_c07_turret_shoot_stamp_input_evidence_is_exact',
                'test_turret_shoot_stamp_state',
                'test_reference_graph_and_actual_c07_turret_shoot_stamp',
            ],
        )
        self.assertTrue(ledger['N2255']['deferred_exprs'])

    def test_all_c07_turret_shoot_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2255']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_shoot_stamp_state_result.cur_recoil': 'SourceTurretBuildState.source_turret_shoot_stamp_state',
                    'source_turret_shoot_stamp_state_result.heat': 'SourceTurretBuildState.source_turret_shoot_stamp_state',
                    'source_turret_shoot_stamp_state_result.total_shots': 'SourceTurretBuildState.source_turret_shoot_stamp_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2255']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_shoot_stamp_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.bullet (Turret.java:779-812) stamps the
        # recoil and the heat and counts the shot after the
        # bullet is created and handled: `curRecoil = 1f;`
        # (Turret.java:806), `heat = 1f;` (:810) and
        # `totalShots++;` (:811). The fields are `public float
        # curRecoil, heat, logicControlTime = -1;` (:284) and
        # `public int totalShots, barrelCounter;` (:287), both
        # default 0. The multi-recoil stamp (`if(recoils >
        # 0){` / `curRecoils[barrelCounter % recoils] = 1f;` /
        # `}`, :807-809) is NOT this slice: duo recoils is -1
        # (Turret.java:142), so the branch is skipped, and a
        # def with recoils > 0 waits for its own slice. The
        # effects / sound / shake lines (:799-805) are NOT
        # this slice either. The result is a 3-key dict:
        # `cur_recoil` 1.0, `heat` 1.0 and `total_shots`
        # (the pre-shot count + 1). The inputs are the
        # pre-shot frame values, so the pure function maps
        # any decayed recoil / heat to 1.0 and any count to
        # count + 1.
        self.assertIn('static func source_turret_shoot_stamp_state(cur_recoil: float, heat: float, total_shots: int) -> Dictionary:', turret)
        self.assertIn('return {"cur_recoil": 1.0, "heat": 1.0, "total_shots": total_shots + 1}', turret)
        self.assertIn('curRecoil = 1f;', turret)
        self.assertIn('heat = 1f;', turret)
        self.assertIn('totalShots++;', turret)
        self.assertIn('if(recoils > 0){', turret)
        self.assertIn('curRecoils[barrelCounter % recoils] = 1f;', turret)
        self.assertIn('public float curRecoil, heat, logicControlTime = -1;', turret)
        self.assertIn('public int totalShots, barrelCounter;', turret)
        self.assertIn('public int recoils = -1;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo shot branch
        # AFTER the spawn_turret_bullet call (Java order
        # :806-811 after the bullet is created at :797): it
        # reads frame["cur_recoil"] / frame["heat"] /
        # frame["total_shots"] (defaults 0.0 / 0.0 / 0 -- no
        # total_shots key existed before this slice), calls the
        # new pure function, then stamps cur_recoil + heat +
        # total_shots back on the frame so the next tick decays
        # from 1.0 (N2254) and counts from the stamped total.
        self.assertIn('var shoot_stamp: Dictionary = source_turret_shoot_stamp_state(float(frame.get("cur_recoil", 0.0)), float(frame.get("heat", 0.0)), int(frame.get("total_shots", 0)))', turret)
        self.assertIn('frame["cur_recoil"] = shoot_stamp.get("cur_recoil", 1.0)', turret)
        self.assertIn('frame["heat"] = shoot_stamp.get("heat", 1.0)', turret)
        self.assertIn('frame["total_shots"] = shoot_stamp.get("total_shots", 0)', turret)
        # The proof's keys drive the stamp through the real
        # driver (the recoil is 1.0 after a shot / the heat is
        # 1.0 after a shot / total_shots increments by 1 per
        # shot / consecutive shots count up / the three values
        # are stamped on the frame after the spawn / the stamp
        # runs after the bullet_spawn stamp). There are no
        # multi-recoil / effects / sound / charge /
        # queuedBullets / findTarget keys: those wait for their
        # own slices.
        proof = TURRET_SHOOT_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'recoil_stamped_to_1_after_shot',
            'heat_stamped_to_1_after_shot',
            'total_shots_increments_after_shot',
            'total_shots_counts_consecutive_shots',
            'recoil_stamped_to_frame_after_spawn',
            'heat_stamped_to_frame_after_spawn',
            'total_shots_stamped_to_frame_after_spawn',
            'stamp_runs_after_bullet_spawn',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_shoot_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretShootStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SHOOT_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'recoil_stamped_to_1_after_shot',
            'heat_stamped_to_1_after_shot',
            'total_shots_increments_after_shot',
            'total_shots_counts_consecutive_shots',
            'recoil_stamped_to_frame_after_spawn',
            'heat_stamped_to_frame_after_spawn',
            'total_shots_stamped_to_frame_after_spawn',
            'stamp_runs_after_bullet_spawn',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
