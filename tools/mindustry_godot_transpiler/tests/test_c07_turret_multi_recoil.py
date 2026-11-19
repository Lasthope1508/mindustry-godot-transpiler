import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_MULTI_RECOIL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretMultiRecoilProof.gd'


class C07TurretMultiRecoilTests(unittest.TestCase):
    def test_c07_turret_multi_recoil_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2256']['godot_owner'], 'SourceTurretBuildState.source_turret_multi_recoil_state')
        # TurretBuild.updateTile (Turret.java:490-544) decays
        # the per-barrel recoil counters after the singular
        # recoil decay: `if(recoils > 0){` /
        # `if(curRecoils == null) curRecoils = new float[recoils];` /
        # `for(int i = 0; i < recoils; i++){` /
        # `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` /
        # `}` (Turret.java:520-525). N2254 deferred this loop on
        # the claim duo recoils is -1 -- that cited only the
        # class default (`public int recoils = -1;`,
        # Turret.java:142) and missed the duo override
        # (`recoils = 2;`, Blocks.java:3301, inside the duo
        # block 3257-3330; the port catalog agrees,
        # content_registry_blocks.json duo entry has
        # `"recoils": 2`). The loop DOES apply to duo: its two
        # drawer barrel parts carry recoilIndex 0 / 1
        # (Blocks.java:3302-3311) and DrawTurret reads
        # `tb.curRecoils[part.recoilIndex]`
        # (DrawTurret.java:104/115), so without the decay the
        # barrel recoil never falls back toward 0. This slice
        # adds the one pure function on the shared TurretBuild
        # driver file (updateTile is TurretBuild's method,
        # common to every turret, not ItemTurret-only) plus one
        # driver tick in the duo branch AFTER the N2254
        # singular recoil/heat decay (Java order :519 then
        # :520-525). One new result symbol: cur_recoils.
        self.assertEqual(
            ledger['N2256']['source_symbols'],
            [
                'source_turret_multi_recoil_state_result.cur_recoils',
            ],
        )
        for name in ledger['N2256']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_multi_recoil_state_result.cur_recoils': 'SourceTurretBuildState.source_turret_multi_recoil_state',
                }[name])
        self.assertEqual(ledger['N2256']['runtime_proof'], '/root/C07TurretMultiRecoilProof')
        self.assertEqual(
            ledger['N2256']['tests'],
            [
                'test_c07_turret_multi_recoil_registration',
                'test_all_c07_turret_multi_recoil_input_evidence_is_exact',
                'test_turret_multi_recoil_state',
                'test_reference_graph_and_actual_c07_turret_multi_recoil',
            ],
        )
        self.assertTrue(ledger['N2256']['deferred_exprs'])

    def test_all_c07_turret_multi_recoil_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2256']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_multi_recoil_state_result.cur_recoils': 'SourceTurretBuildState.source_turret_multi_recoil_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2256']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_multi_recoil_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile (Turret.java:490-544) decays
        # the per-barrel recoil counters right after the
        # singular recoil decay: `if(recoils > 0){` /
        # `if(curRecoils == null) curRecoils = new float[recoils];` /
        # `for(int i = 0; i < recoils; i++){` /
        # `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` /
        # `}` (:520-525). The field is `public @Nullable float[]
        # curRecoils;` (:285), null until the first updateTile
        # tick allocates it. Duo pins: recoils 2
        # (Blocks.java:3301 -- NOT the -1 class default at
        # Turret.java:142), recoilTime 20 (reload, via
        # `if(recoilTime < 0f) recoilTime = reload;`, :208), so
        # each entry steps toward 0 by delta / 20, never past
        # 0. The pure function builds a NEW array of length
        # recoils (missing entries read as 0.0, so a null /
        # absent frame key inits to zeros) and returns it as
        # the single `cur_recoils` key -- it never mutates its
        # input array. The driver tick reads
        # frame["cur_recoils"] (default [] -- no cur_recoils
        # key existed before this slice), calls the pure
        # function with recoils 2 / recoil_time 20.0 / delta
        # seconds, then stamps cur_recoils back on the frame
        # so the next tick decays from the stamped values and
        # the drawer reads live counters.
        self.assertIn('static func source_turret_multi_recoil_state(cur_recoils: Array, recoils: int, recoil_time: float, delta: float) -> Dictionary:', turret)
        self.assertIn('return {"cur_recoils": decayed}', turret)
        self.assertIn('if(recoils > 0){', turret)
        self.assertIn('if(curRecoils == null) curRecoils = new float[recoils];', turret)
        self.assertIn('curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);', turret)
        self.assertIn('public @Nullable float[] curRecoils;', turret)
        self.assertIn('public int recoils = -1;', turret)
        self.assertIn('recoils = 2;', turret)
        self.assertIn('public float recoilTime = -1f;', turret)
        self.assertIn('if(recoilTime < 0f) recoilTime = reload;', turret)
        self.assertIn('curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch right
        # AFTER the N2254 singular recoil/heat decay (Java order
        # :519 then :520-525) and before the aim/shoot call:
        # it reads frame["cur_recoils"] (default []), calls the
        # new pure function with duo recoils 2 and recoilTime
        # 20.0, then stamps cur_recoils back on the frame.
        self.assertIn('var multi_recoil: Dictionary = source_turret_multi_recoil_state(frame.get("cur_recoils", []), 2, 20.0, seconds)', turret)
        self.assertIn('frame["cur_recoils"] = multi_recoil.get("cur_recoils", [])', turret)
        # The proof's keys drive the decay through the real
        # driver (both entries decay toward 0 / neither entry
        # passes 0 / an absent key inits to zeros / the step
        # matches delta / recoilTime / the decayed array is
        # stamped on the frame / the decay runs after the
        # singular recoil/heat decay / the second entry decays
        # independently of the first). There are no
        # multi-recoil stamp / recoilOffset / charge /
        # queuedBullets / findTarget keys: those wait for their
        # own slices.
        proof = TURRET_MULTI_RECOIL_PROOF.read_text(encoding='utf-8')
        for key in [
            'multi_recoil_decays_toward_zero',
            'multi_recoil_both_entries_decay',
            'multi_recoil_never_past_zero',
            'multi_recoil_init_zeros_when_absent',
            'multi_recoil_rate_matches_recoil_time',
            'multi_recoil_stamped_to_frame_after_decay',
            'multi_recoil_decay_runs_after_singular_decay',
            'multi_recoil_second_entry_decays_independently',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_multi_recoil(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretMultiRecoilProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_MULTI_RECOIL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'multi_recoil_decays_toward_zero',
            'multi_recoil_both_entries_decay',
            'multi_recoil_never_past_zero',
            'multi_recoil_init_zeros_when_absent',
            'multi_recoil_rate_matches_recoil_time',
            'multi_recoil_stamped_to_frame_after_decay',
            'multi_recoil_decay_runs_after_singular_decay',
            'multi_recoil_second_entry_decays_independently',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
