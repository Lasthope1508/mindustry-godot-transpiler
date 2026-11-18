import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_ESTIMATE_DPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretEstimateDpsProof.gd'


class C07TurretEstimateDpsTests(unittest.TestCase):
    def test_c07_turret_estimate_dps_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2261']['godot_owner'], 'SourceTurretBuildState.source_turret_estimate_dps_state')
        # TurretBuild overrides estimateDps (Turret.java:329-332,
        # `public float estimateDps(){` / `if(!hasAmmo())
        # return 0f;` / `return shoot.shots / reload * 60f *
        # (peekAmmo() == null ? 0f : peekAmmo().estimateDPS())
        # * potentialEfficiency * timeScale;`) over the
        # ShootPattern def shots (ShootPattern.java:9,
        # `public int shots = 1;`), the ReloadTurret def
        # reload (ReloadTurret.java:10, `public float reload
        # = 10f;`), the BuildingComp potentialEfficiency
        # (BuildingComp.java:89, `transient float
        # potentialEfficiency;`) and timeScale
        # (BuildingComp.java:1922-1923, `public float
        # delta(){` / `return Time.delta * timeScale;`),
        # and the peeked bullet's estimateDPS
        # (BulletType.java:414-431, `public float
        # estimateDPS(){`, recursive over spawnUnit /
        # despawnUnit / fragBullet / spawnBullets with the
        # cachedDps cache). hasAmmo() (Turret.java:698-712)
        # has a side effect (it swaps the ammo queue when
        # the first entry is short) and peekAmmo()
        # (Turret.java:693-695) and BulletType.estimateDPS()
        # are not ported here, so all three arrive as
        # explicit params (the N2188 precedent): has_ammo
        # as a bool and peek_ammo_estimate_dps as the
        # peeked bullet's DPS (0.0 when peekAmmo() is null,
        # the Java ternary leg). The accessor is what the
        # RTS AI reads (RtsAI.java:336, `dps[0] +=
        # t.estimateDps();`); the AI itself waits for its
        # own slice. RED decisions (recorded in the
        # register docstring): (1) one pure function on
        # SourceTurretBuildState.gd next to the N2244
        # fogRadius row, following the N2244 accessor
        # precedent exactly: (frame, has_ammo, shots,
        # reload, peek_ammo_estimate_dps,
        # potential_efficiency, time_scale) and one result
        # key `estimate_dps`. (2) All live values arrive
        # as explicit params (the N2188 precedent) -- the
        # tick frame tracks only cheating / enabled /
        # power_status / efficiency today. (3) No ammo
        # returns 0.0 (the Java early return); a null peek
        # also yields 0.0 through the explicit 0.0 param.
        # (4) reload = 0 keeps the Java float-division
        # behavior (Infinity for a nonzero numerator) --
        # no invented guard; the proof pins it. (5) NO
        # driver line: estimateDps() is a read accessor
        # the RTS AI calls, not a per-tick write (the
        # N2244/N2249 precedent); the AI caller waits for
        # its own slice. One new result symbol:
        # estimate_dps. This slice closes no deferred
        # item: estimateDps() was never a deferred entry
        # of the Turret chain.
        self.assertEqual(
            ledger['N2261']['source_symbols'],
            [
                'source_turret_estimate_dps_state_result.estimate_dps',
            ],
        )
        for name in ledger['N2261']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/entities/pattern/ShootPattern.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/ai/RtsAI.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2261']['runtime_proof'], '/root/C07TurretEstimateDpsProof')
        self.assertEqual(
            ledger['N2261']['tests'],
            [
                'test_c07_turret_estimate_dps_registration',
                'test_all_c07_turret_estimate_dps_input_evidence_is_exact',
                'test_turret_estimate_dps_state',
                'test_reference_graph_and_actual_c07_turret_estimate_dps',
            ],
        )
        self.assertTrue(ledger['N2261']['deferred_exprs'])
        self.assertIn(
            'Turret estimateDps() Windows Godot proof',
            ' '.join(ledger['N2261']['deferred_exprs']),
        )

    def test_all_c07_turret_estimate_dps_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2261']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/ai/RtsAI.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2261']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_estimate_dps_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.estimateDps() (Turret.java:329-332):
        # `public float estimateDps(){`
        # `if(!hasAmmo()) return 0f;`
        # `return shoot.shots / reload * 60f *
        # (peekAmmo() == null ? 0f : peekAmmo().estimateDPS())
        # * potentialEfficiency * timeScale;`
        # over the ShootPattern def shots
        # (ShootPattern.java:9, `public int shots = 1;`),
        # the ReloadTurret def reload
        # (ReloadTurret.java:10, `public float reload =
        # 10f;`), the BuildingComp potentialEfficiency
        # (BuildingComp.java:89, `transient float
        # potentialEfficiency;`) and timeScale
        # (BuildingComp.java:1922-1923, `return Time.delta
        # * timeScale;`), and the peeked bullet's
        # estimateDPS (BulletType.java:414, `public float
        # estimateDPS(){`). hasAmmo() has a side effect
        # (ammo swap, Turret.java:698-712) so it arrives
        # as an explicit bool; peekAmmo()
        # (Turret.java:693, `public @Nullable BulletType
        # peekAmmo(){`) arrives as the explicit DPS of the
        # peeked bullet. No driver line: estimateDps() is
        # a read accessor the RTS AI calls
        # (RtsAI.java:336, `dps[0] += t.estimateDps();`),
        # not a per-tick write (the N2244/N2249 precedent).
        self.assertIn('static func source_turret_estimate_dps_state(frame: Dictionary, has_ammo: bool, shots: int, reload: float, peek_ammo_estimate_dps: float, potential_efficiency: float, time_scale: float) -> Dictionary:', turret)
        self.assertIn('return {"estimate_dps": 0.0 if not has_ammo else float(shots) / reload * 60.0 * peek_ammo_estimate_dps * potential_efficiency * time_scale}', turret)
        for expr in [
            'public float estimateDps(){',
            'if(!hasAmmo()) return 0f;',
            'return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;',
            'public boolean hasAmmo(){',
            'public @Nullable BulletType peekAmmo(){',
            'public int shots = 1;',
            'public float reload = 10f;',
            'transient float potentialEfficiency;',
            'return Time.delta * timeScale;',
            'public float estimateDPS(){',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'dps[0] += t.estimateDps();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: no ammo returns 0.0; a null
        # peek (DPS 0.0) returns 0.0; the standard case
        # (shots 1, reload 10, bullet DPS 10, efficiency 1,
        # timeScale 1) is 60.0; shots 2 doubles it;
        # efficiency 0.5 halves it; timeScale 2 doubles it;
        # and reload 0 keeps Java float-division behavior
        # (Infinity for a nonzero numerator).
        proof = TURRET_ESTIMATE_DPS_PROOF.read_text(encoding='utf-8')
        for key in [
            'estimate_dps_no_ammo',
            'estimate_dps_peek_null',
            'estimate_dps_standard',
            'estimate_dps_shots_double',
            'estimate_dps_efficiency_half',
            'estimate_dps_time_scale_double',
            'estimate_dps_reload_zero_infinity',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_estimate_dps(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretEstimateDpsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_ESTIMATE_DPS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'estimate_dps_no_ammo',
            'estimate_dps_peek_null',
            'estimate_dps_standard',
            'estimate_dps_shots_double',
            'estimate_dps_efficiency_half',
            'estimate_dps_time_scale_double',
            'estimate_dps_reload_zero_infinity',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
