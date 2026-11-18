import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_RECOIL_HEAT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretRecoilHeatProof.gd'


class C07TurretRecoilHeatTests(unittest.TestCase):
    def test_c07_turret_recoil_heat_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2254']['godot_owner'], 'SourceTurretBuildState.source_turret_recoil_heat_state')
        # TurretBuild.updateTile (Turret.java:490-526) decays the
        # recoil and the heat after the warmup advance and before
        # it aims or shoots: `curRecoil =
        # Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);`
        # (Turret.java:519) and `heat =
        # Mathf.approachDelta(heat, 0, 1 / cooldownTime);`
        # (:526). The driver never read frame["cur_recoil"]
        # or frame["heat"] -- there is no such key in
        # SourceTurretBuildState.gd at all -- so recoil and
        # heat never decayed live. This slice adds the one
        # pure function on the shared TurretBuild driver file
        # (it is TurretBuild.updateTile, common to every
        # turret, not ItemTurret-only) plus one driver tick
        # in the duo branch AFTER the warmup stamp (N2253)
        # and BEFORE the aim/shoot call (Java order :519/:526
        # after :502-515 and before the shoot gate :733).
        # Two new result symbols: cur_recoil + heat.
        self.assertEqual(
            ledger['N2254']['source_symbols'],
            [
                'source_turret_recoil_heat_state_result.cur_recoil',
                'source_turret_recoil_heat_state_result.heat',
            ],
        )
        for name in ledger['N2254']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_recoil_heat_state_result.cur_recoil': 'SourceTurretBuildState.source_turret_recoil_heat_state',
                    'source_turret_recoil_heat_state_result.heat': 'SourceTurretBuildState.source_turret_recoil_heat_state',
                }[name])
        self.assertEqual(ledger['N2254']['runtime_proof'], '/root/C07TurretRecoilHeatProof')
        self.assertEqual(
            ledger['N2254']['tests'],
            [
                'test_c07_turret_recoil_heat_registration',
                'test_all_c07_turret_recoil_heat_input_evidence_is_exact',
                'test_turret_recoil_heat_state',
                'test_reference_graph_and_actual_c07_turret_recoil_heat',
            ],
        )
        self.assertTrue(ledger['N2254']['deferred_exprs'])

    def test_all_c07_turret_recoil_heat_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2254']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_recoil_heat_state_result.cur_recoil': 'SourceTurretBuildState.source_turret_recoil_heat_state',
                    'source_turret_recoil_heat_state_result.heat': 'SourceTurretBuildState.source_turret_recoil_heat_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2254']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_recoil_heat_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile (Turret.java:490-526) decays
        # the recoil and the heat after the warmup advance:
        # `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 /
        # recoilTime);` (Turret.java:519) and `heat =
        # Mathf.approachDelta(heat, 0, 1 / cooldownTime);`
        # (:526). approachDelta is `return approach(from,
        # to, Time.delta * speed);` (arc Mathf.java:420-422)
        # with approach `return from + Mathf.clamp(to -
        # from, -speed, speed);` (:415-417), so each tick
        # moves the value toward 0 by delta / recoilTime
        # (resp. delta / cooldownTime), never past 0. The
        # class defaults are `public float recoil = 1f;`
        # (Turret.java:140), `public int recoils = -1;`
        # (:142), `public float recoilTime = -1f;` (:144),
        # `public float recoilPow = 1.8f;` (:146),
        # `public float cooldownTime = 20f;` (:148); the init
        # is `if(recoilTime < 0f) recoilTime = reload;` /
        # `if(cooldownTime < 0f) cooldownTime = reload;`
        # (:208-209 -- duo reload is 20, N2250, so the
        # driver passes recoil_time 20.0 and cooldown_time
        # 20.0, a 0.05-per-tick rate). The multi-recoil loop
        # (`if(recoils > 0){` / `if(curRecoils == null)
        # curRecoils = new float[recoils];` / `for(int i = 0;
        # i < recoils; i++){` / `curRecoils[i] =
        # Mathf.approachDelta(curRecoils[i], 0, 1 /
        # recoilTime);` / `}`, :520-525) is NOT this slice:
        # duo recoils is -1, so the loop is skipped, and a
        # def with recoils > 0 waits for its own slice. The
        # shoot stamp (`curRecoil = 1f;` / `heat = 1f;`,
        # :807-810) and the draw offset
        # (`recoilOffset.trns(rotation, -Mathf.pow(curRecoil,
        # recoilPow) * recoil);`, :532) are NOT this slice
        # either: the shoot stamp waits with the
        # shoot-stamp slice (N2252 only stamped
        # frame["bullet_spawn"]) and the offset is draw-side.
        # The result is a 2-key dict: `cur_recoil` (after
        # the approachDelta step toward 0) and `heat`
        # (after the approachDelta step toward 0). Delta is
        # the live-loop seconds value, the same convention
        # as the N2253 warmup (SourceFactoryRuntimeState.gd
        # :214 passes delta into
        # source_turret_tick_buildings_state).
        self.assertIn('static func source_turret_recoil_heat_state(cur_recoil: float, heat: float, recoil_time: float, cooldown_time: float, delta: float) -> Dictionary:', turret)
        self.assertIn('cur_recoil = cur_recoil + clampf(0.0 - cur_recoil, -delta / recoil_time, delta / recoil_time)', turret)
        self.assertIn('heat = heat + clampf(0.0 - heat, -delta / cooldown_time, delta / cooldown_time)', turret)
        self.assertIn('return {"cur_recoil": cur_recoil, "heat": heat}', turret)
        self.assertIn('curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', turret)
        self.assertIn('heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);', turret)
        self.assertIn('if(recoils > 0){', turret)
        self.assertIn('curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);', turret)
        self.assertIn('public float recoil = 1f;', turret)
        self.assertIn('public int recoils = -1;', turret)
        self.assertIn('public float recoilTime = -1f;', turret)
        self.assertIn('public float recoilPow = 1.8f;', turret)
        self.assertIn('public float cooldownTime = 20f;', turret)
        self.assertIn('if(recoilTime < 0f) recoilTime = reload;', turret)
        self.assertIn('if(cooldownTime < 0f) cooldownTime = reload;', turret)
        self.assertIn('curRecoil = 1f;', turret)
        self.assertIn('heat = 1f;', turret)
        self.assertIn('recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);', turret)
        self.assertIn('public static float approach(float from, float to, float speed){', turret)
        self.assertIn('return from + Mathf.clamp(to - from, -speed, speed);', turret)
        self.assertIn('public static float approachDelta(float from, float to, float speed){', turret)
        self.assertIn('return approach(from, to, Time.delta * speed);', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the warmup stamp (N2253) and BEFORE the aim/shoot
        # call (Java order :519/:526 after :502-515 and before
        # the shoot gate :733): it reads frame["cur_recoil"]
        # and frame["heat"] (default 0.0 -- neither key
        # existed before this slice), calls the new pure
        # function with the per-def duo values (recoil_time
        # 20.0 = reload, cooldown_time 20.0 = class default)
        # and delta = seconds, then stamps cur_recoil + heat
        # back on the frame so the next tick decays from the
        # stamped values.
        self.assertIn('var recoil_heat: Dictionary = source_turret_recoil_heat_state(float(frame.get("cur_recoil", 0.0)), float(frame.get("heat", 0.0)), 20.0, 20.0, seconds)', turret)
        self.assertIn('frame["cur_recoil"] = recoil_heat.get("cur_recoil", 0.0)', turret)
        self.assertIn('frame["heat"] = recoil_heat.get("heat", 0.0)', turret)
        # The proof's keys drive the recoil and the heat
        # through the real driver (the recoil decays toward 0
        # after a shot / reaches 0 within recoil_time ticks /
        # the heat decays toward 0 after a shot / reaches 0
        # within cooldown_time ticks / the frame carries the
        # decayed recoil and heat before aim reads them / the
        # decay step is exactly delta / recoil_time resp.
        # delta / cooldown_time). There are no multi-recoil /
        # recoilOffset / shoot-stamp / charge / queuedBullets
        # / findTarget keys: those wait for their own slices.
        proof = TURRET_RECOIL_HEAT_PROOF.read_text(encoding='utf-8')
        for key in [
            'recoil_decays_toward_0_after_shot',
            'recoil_reaches_0_within_recoil_time',
            'heat_decays_toward_0_after_shot',
            'heat_reaches_0_within_cooldown_time',
            'recoil_stamped_to_frame_before_aim',
            'heat_stamped_to_frame_before_aim',
            'recoil_decay_rate_is_one_over_recoil_time',
            'heat_decay_rate_is_one_over_cooldown_time',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_recoil_heat(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretRecoilHeatProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_RECOIL_HEAT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'recoil_decays_toward_0_after_shot',
            'recoil_reaches_0_within_recoil_time',
            'heat_decays_toward_0_after_shot',
            'heat_reaches_0_within_cooldown_time',
            'recoil_stamped_to_frame_before_aim',
            'heat_stamped_to_frame_before_aim',
            'recoil_decay_rate_is_one_over_recoil_time',
            'heat_decay_rate_is_one_over_cooldown_time',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
