import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_RECOIL_OFFSET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretRecoilOffsetProof.gd'


class C07TurretRecoilOffsetTests(unittest.TestCase):
    def test_c07_turret_recoil_offset_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2258']['godot_owner'], 'SourceTurretBuildState.source_turret_recoil_offset_state')
        # TurretBuild.updateTile() recomputes the draw offset
        # every tick, after the recoil/heat decay and before
        # the shoot gate:
        # `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);`
        # (Turret.java:532). The field is
        # `public Vec2 recoilOffset = new Vec2();` (:280,
        # `/** Turret sprite offset, based on recoil. Updated
        # every frame. */`), the power curve is
        # `public float recoilPow = 1.8f;` (:146) and the
        # class default is `public float recoil = 1f;` (:140)
        # -- duo overrides it with `recoil = 0.5f;`
        # (Blocks.java:3315, inside the duo block 3257-3330).
        # DrawTurret reads the offset for every draw call
        # (DrawTurret.java:83/94/101/110/124/129/133/140),
        # so without a live tick the duo sprite never kicks
        # back on the new C07 frame driver. The formula
        # itself was already proven once on the legacy
        # PortGame path (N742, `PortGame.source_turret_recoil_offset`,
        # MCP: recoil 0.5 / rotation 0 / curRecoil 1 ->
        # Vector2(-0.5, 0.0)); this slice is the LIVE frame
        # tick on the new duo driver: one pure function on
        # the shared TurretBuild driver file plus one driver
        # tick in the duo branch AFTER the N2254/N2256 decay
        # ticks and BEFORE the aim/shoot call (Java order
        # :519/:520-525 decay, :532 offset, :595-596
        # turnToTarget, :601/:609 updateShooting). One new
        # result symbol: recoil_offset.
        self.assertEqual(
            ledger['N2258']['source_symbols'],
            [
                'source_turret_recoil_offset_state_result.recoil_offset',
            ],
        )
        for name in ledger['N2258']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_recoil_offset_state_result.recoil_offset': 'SourceTurretBuildState.source_turret_recoil_offset_state',
                }[name])
        self.assertEqual(ledger['N2258']['runtime_proof'], '/root/C07TurretRecoilOffsetProof')
        self.assertEqual(
            ledger['N2258']['tests'],
            [
                'test_c07_turret_recoil_offset_registration',
                'test_all_c07_turret_recoil_offset_input_evidence_is_exact',
                'test_turret_recoil_offset_state',
                'test_reference_graph_and_actual_c07_turret_recoil_offset',
            ],
        )
        self.assertTrue(ledger['N2258']['deferred_exprs'])

    def test_all_c07_turret_recoil_offset_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2258']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_recoil_offset_state_result.recoil_offset': 'SourceTurretBuildState.source_turret_recoil_offset_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2258']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_recoil_offset_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-615)
        # recomputes the draw offset every tick:
        # `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);`
        # (:532). The field is
        # `public Vec2 recoilOffset = new Vec2();` (:280),
        # the power curve is `public float recoilPow = 1.8f;`
        # (:146), the class default is
        # `public float recoil = 1f;` (:140), and duo
        # overrides it with `recoil = 0.5f;`
        # (Blocks.java:3315). The pure function takes the
        # rotation, the decayed curRecoil, recoilPow and
        # recoil, applies the trns (x = cos(rotation) * mag,
        # y = sin(rotation) * mag, mag =
        # -pow(curRecoil, recoilPow) * recoil) and returns
        # the offset as one `recoil_offset` dict
        # `{"x": .., "y": ..}` -- the frame's JSON-friendly
        # convention, same as frame["target_pos"] from the
        # N2250 aim state. The driver tick reads
        # frame["rotation"] (default 90.0, the aim stamp
        # default) and frame["cur_recoil"] (already decayed
        # this tick by the N2254 tick), calls the pure
        # function with duo recoilPow 1.8 / recoil 0.5, then
        # stamps recoil_offset back on the frame so the
        # drawer reads a live kicked-back sprite.
        self.assertIn('static func source_turret_recoil_offset_state(rotation: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Dictionary:', turret)
        self.assertIn('return {"recoil_offset": {"x": offset_x, "y": offset_y}}', turret)
        self.assertIn('recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);', turret)
        self.assertIn('public Vec2 recoilOffset = new Vec2();', turret)
        self.assertIn('public float recoilPow = 1.8f;', turret)
        self.assertIn('public float recoil = 1f;', turret)
        self.assertIn('recoil = 0.5f;', turret)
        self.assertIn('public float curRecoil, heat, logicControlTime = -1;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2256 multi-recoil decay tick and BEFORE the aim
        # call (Java order :532 before turnToTarget :595-596
        # and updateShooting :601/:609): it reads the
        # previous tick's rotation and the decayed curRecoil,
        # calls the new pure function with duo 1.8 / 0.5, then
        # stamps recoil_offset back on the frame.
        self.assertIn('var recoil_offset: Dictionary = source_turret_recoil_offset_state(float(frame.get("rotation", 90.0)), float(frame.get("cur_recoil", 0.0)), 1.8, 0.5)', turret)
        self.assertIn('frame["recoil_offset"] = recoil_offset.get("recoil_offset", {"x": 0.0, "y": 0.0})', turret)
        # The proof's keys drive the offset through the real
        # driver (zero offset with no recoil / full -0.5 kick
        # at rotation 0 / full -0.5 kick at rotation 90 / the
        # pow(0.5, 1.8) curve at half recoil / the offset uses
        # the decayed recoil, not the stamped 1.0 / the offset
        # uses the previous tick's rotation, not the fresh aim
        # rotation / the offset is on the frame after the tick
        # / the offset lags the shot by one tick, because
        # Java :532 runs before the shoot gate :733). There
        # are no charge / queuedBullets / findTarget keys:
        # those wait for their own slices.
        proof = TURRET_RECOIL_OFFSET_PROOF.read_text(encoding='utf-8')
        for key in [
            'recoil_offset_zero_when_no_recoil',
            'recoil_offset_full_kick_at_rotation_0',
            'recoil_offset_full_kick_at_rotation_90',
            'recoil_offset_pow_curve',
            'recoil_offset_uses_decayed_recoil',
            'recoil_offset_uses_previous_rotation',
            'recoil_offset_stamped_to_frame',
            'recoil_offset_lags_shot_by_one_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_recoil_offset(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretRecoilOffsetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_RECOIL_OFFSET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'recoil_offset_zero_when_no_recoil',
            'recoil_offset_full_kick_at_rotation_0',
            'recoil_offset_full_kick_at_rotation_90',
            'recoil_offset_pow_curve',
            'recoil_offset_uses_decayed_recoil',
            'recoil_offset_uses_previous_rotation',
            'recoil_offset_stamped_to_frame',
            'recoil_offset_lags_shot_by_one_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
