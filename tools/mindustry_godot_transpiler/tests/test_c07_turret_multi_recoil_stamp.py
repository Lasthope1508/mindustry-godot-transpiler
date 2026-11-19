import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_MULTI_RECOIL_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretMultiRecoilStampProof.gd'


class C07TurretMultiRecoilStampTests(unittest.TestCase):
    def test_c07_turret_multi_recoil_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2257']['godot_owner'], 'SourceTurretBuildState.source_turret_multi_recoil_stamp_state')
        # TurretBuild.bullet() (Turret.java:779-812) stamps the
        # per-barrel recoil counter of the barrel that just
        # fired, after the bullet is created and handled:
        # `curRecoil = 1f;` / `if(recoils > 0){` /
        # `curRecoils[barrelCounter % recoils] = 1f;` / `}` /
        # `heat = 1f;` / `totalShots++;` (Turret.java:806-811).
        # N2255 stamped only the singular curRecoil / heat /
        # totalShots and deferred this branch on the claim duo
        # recoils is -1 -- that cited only the class default
        # (`public int recoils = -1;`, Turret.java:142) and
        # missed the duo override (`recoils = 2;`,
        # Blocks.java:3301, inside the duo block 3257-3330;
        # the port catalog agrees,
        # content_registry_blocks.json duo entry has
        # `"recoils": 2`). The branch DOES apply to duo: its
        # two drawer barrel parts carry recoilIndex 0 / 1
        # (Blocks.java:3302-3311) and DrawTurret reads
        # `tb.curRecoils[part.recoilIndex]`
        # (DrawTurret.java:104/115), so without the stamp the
        # fired barrel never kicks back to 1.0 live. This slice
        # adds the one pure function on the shared TurretBuild
        # driver file (bullet() is TurretBuild's method, common
        # to every turret, not ItemTurret-only) plus one driver
        # tick in the duo branch AFTER the N2255 singular shoot
        # stamp (Java order :806 then :807-809, both inside
        # bullet(), after the bullet spawn :797). One new result
        # symbol: cur_recoils.
        self.assertEqual(
            ledger['N2257']['source_symbols'],
            [
                'source_turret_multi_recoil_stamp_state_result.cur_recoils',
            ],
        )
        for name in ledger['N2257']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_multi_recoil_stamp_state_result.cur_recoils': 'SourceTurretBuildState.source_turret_multi_recoil_stamp_state',
                }[name])
        self.assertEqual(ledger['N2257']['runtime_proof'], '/root/C07TurretMultiRecoilStampProof')
        self.assertEqual(
            ledger['N2257']['tests'],
            [
                'test_c07_turret_multi_recoil_stamp_registration',
                'test_all_c07_turret_multi_recoil_stamp_input_evidence_is_exact',
                'test_turret_multi_recoil_stamp_state',
                'test_reference_graph_and_actual_c07_turret_multi_recoil_stamp',
            ],
        )
        self.assertTrue(ledger['N2257']['deferred_exprs'])

    def test_all_c07_turret_multi_recoil_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2257']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_multi_recoil_stamp_state_result.cur_recoils': 'SourceTurretBuildState.source_turret_multi_recoil_stamp_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2257']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_multi_recoil_stamp_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.bullet() (Turret.java:779-812) stamps the
        # per-barrel recoil counter of the barrel that just
        # fired: `curRecoil = 1f;` / `if(recoils > 0){` /
        # `curRecoils[barrelCounter % recoils] = 1f;` / `}` /
        # `heat = 1f;` / `totalShots++;` (:806-811). The field
        # is `public @Nullable float[] curRecoils;` (:285), null
        # until the first updateTile tick allocates it (N2256
        # decay). Duo pins: recoils 2 (Blocks.java:3301 -- NOT
        # the -1 class default at Turret.java:142), so the
        # stamped entry is barrelCounter % 2. The pure function
        # builds a NEW array of length recoils (missing entries
        # read as 0.0, so a null / absent frame key inits to
        # zeros), sets entry barrel % recoils to 1.0, leaves
        # every other entry untouched, and returns it as the
        # single `cur_recoils` key -- it never mutates its
        # input array. When recoils <= 0 the Java guard does
        # nothing, so the function returns the input unchanged.
        # The driver tick reads frame["cur_recoils"] (default
        # []), calls the pure function with the shoot_event
        # barrel (the PRE-increment barrelCounter -- the aim
        # tick already stamped frame["barrel_counter"] with
        # barrel_counter_after = barrelCounter + 1, so the
        # frame key is the WRONG barrel here) and duo recoils
        # 2, then stamps cur_recoils back on the frame so the
        # drawer reads a live kicked-back barrel and the next
        # tick decays from 1.0 (N2256).
        self.assertIn('static func source_turret_multi_recoil_stamp_state(cur_recoils: Array, barrel: int, recoils: int) -> Dictionary:', turret)
        self.assertIn('return {"cur_recoils": stamped}', turret)
        self.assertIn('curRecoil = 1f;', turret)
        self.assertIn('if(recoils > 0){', turret)
        self.assertIn('curRecoils[barrelCounter % recoils] = 1f;', turret)
        self.assertIn('heat = 1f;', turret)
        self.assertIn('totalShots++;', turret)
        self.assertIn('public @Nullable float[] curRecoils;', turret)
        self.assertIn('public int recoils = -1;', turret)
        self.assertIn('recoils = 2;', turret)
        self.assertIn('public int totalShots, barrelCounter;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch right
        # AFTER the N2255 singular shoot stamp (Java order :806
        # then :807-809, both inside bullet(), after the bullet
        # spawn): it reads frame["cur_recoils"] (default []),
        # calls the new pure function with the shoot_event
        # barrel (pre-increment) and duo recoils 2, then stamps
        # cur_recoils back on the frame.
        self.assertIn('var multi_recoil_stamp: Dictionary = source_turret_multi_recoil_stamp_state(frame.get("cur_recoils", []), int(shoot_event.get("barrel", 0)), 2)', turret)
        self.assertIn('frame["cur_recoils"] = multi_recoil_stamp.get("cur_recoils", [])', turret)
        # The proof's keys drive the stamp through the real
        # driver (the fired barrel stamps to 1.0 / the other
        # barrel stays untouched / the next shot stamps the
        # other barrel / barrel 2 wraps to entry 0 / an absent
        # key inits to zeros / the untouched entries keep their
        # decayed values / the stamped array is on the frame
        # after the shot / the stamp runs after the singular
        # shoot stamp). There are no recoilOffset / charge /
        # queuedBullets / findTarget keys: those wait for their
        # own slices.
        proof = TURRET_MULTI_RECOIL_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'multi_recoil_stamp_sets_fired_barrel',
            'multi_recoil_stamp_other_barrel_untouched',
            'multi_recoil_stamp_alternates_barrels',
            'multi_recoil_stamp_wraps_modulo',
            'multi_recoil_stamp_init_zeros_when_absent',
            'multi_recoil_stamp_preserves_other_entries',
            'multi_recoil_stamp_stamped_to_frame_after_shoot',
            'multi_recoil_stamp_runs_after_singular_stamp',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_multi_recoil_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretMultiRecoilStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_MULTI_RECOIL_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'multi_recoil_stamp_sets_fired_barrel',
            'multi_recoil_stamp_other_barrel_untouched',
            'multi_recoil_stamp_alternates_barrels',
            'multi_recoil_stamp_wraps_modulo',
            'multi_recoil_stamp_init_zeros_when_absent',
            'multi_recoil_stamp_preserves_other_entries',
            'multi_recoil_stamp_stamped_to_frame_after_shoot',
            'multi_recoil_stamp_runs_after_singular_stamp',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
