import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_ROTATE_SYNC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretRotateSyncProof.gd'


class C07TurretRotateSyncTests(unittest.TestCase):
    def test_c07_turret_rotate_sync_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2262']['godot_owner'], 'SourceTurretBuildState.source_turret_rotate_sync_state')
        # TurretBuild.updateTile() syncs the underlying
        # building rotation every tick, after the
        # logic-control decay and before the heat-requirement
        # fold:
        # `if(rotate){`
        # `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`
        # (Turret.java:542-545). `rotate` is true for every
        # turret (Turret constructor, `rotate = true;`, :163)
        # and duo never overrides it (Blocks.java:3257-3331
        # sets only `rotateSpeed = 10f;`). `rotation` is the
        # turret's own float aim rotation in degrees
        # (frame["rotation"], default 90.0); the synced field
        # is the shadowed int 0-3 Building rotation
        # (`transient int rotation;`, BuildingComp.java:69,
        # default 0). arc `Mathf.round(float)` is
        # `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
        # (Mathf.java:500-502) -- round half UP toward +inf,
        # like Java Math.round, NOT half away from zero: -0.5
        # rounds to 0, -1.5 rounds to -1. arc
        # `Mathf.mod(float, float)` is
        # `return ((f % n) + n) % n;` (Mathf.java:574-576) --
        # a proper mod for negatives, so -1 maps to 3. This
        # slice is the LIVE frame tick on the new duo driver:
        # one pure function on the shared TurretBuild driver
        # file plus one driver tick in the duo branch AFTER
        # the N2261 logicControlTime tick (Java order :534-536
        # decay, :538-540 heatReq, :542-545 rotate sync) and
        # BEFORE the aim call (Java order :595-596
        # turnToTarget, :601/:609 updateShooting). One new
        # result symbol: building_rotation. The heatReq fold
        # (:538-540) waits for its own slice -- the sync only
        # reads the frame rotation, it never touches heat.
        self.assertEqual(
            ledger['N2262']['source_symbols'],
            [
                'source_turret_rotate_sync_state_result.building_rotation',
            ],
        )
        for name in ledger['N2262']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_rotate_sync_state_result.building_rotation': 'SourceTurretBuildState.source_turret_rotate_sync_state',
                }[name])
        self.assertEqual(ledger['N2262']['runtime_proof'], '/root/C07TurretRotateSyncProof')
        self.assertEqual(
            ledger['N2262']['tests'],
            [
                'test_c07_turret_rotate_sync_registration',
                'test_all_c07_turret_rotate_sync_input_evidence_is_exact',
                'test_turret_rotate_sync_state',
                'test_reference_graph_and_actual_c07_turret_rotate_sync',
            ],
        )
        self.assertTrue(ledger['N2262']['deferred_exprs'])

    def test_all_c07_turret_rotate_sync_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2262']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_rotate_sync_state_result.building_rotation': 'SourceTurretBuildState.source_turret_rotate_sync_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'arc-core/src/arc/math/Mathf.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2262']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_rotate_sync_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-560)
        # syncs the underlying building rotation every tick:
        # `if(rotate){`
        # `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`
        # (:542-545), after the logic-control decay (:534-536)
        # and before the heat-requirement fold (:538-540) and
        # the turnToTarget (:595-596). `rotate` is true for
        # every turret (Turret constructor, `rotate = true;`,
        # :163) and duo never overrides it (Blocks.java:3257-3331
        # sets only `rotateSpeed = 10f;`). `rotation` is the
        # turret's own float aim rotation in degrees
        # (frame["rotation"], default 90.0); the synced field
        # is the shadowed int 0-3 Building rotation
        # (`transient int rotation;`, BuildingComp.java:69,
        # default 0). arc `Mathf.round(float)` is
        # `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
        # (Mathf.java:500-502) -- round half UP toward +inf,
        # like Java Math.round, NOT half away from zero: -0.5
        # rounds to 0, -1.5 rounds to -1. arc
        # `Mathf.mod(float, float)` is
        # `return ((f % n) + n) % n;` (Mathf.java:574-576) --
        # a proper mod for negatives, so -1 maps to 3. The
        # pure function takes the float aim rotation, the
        # rotate flag and the current building rotation and
        # returns the one key:
        # `{"building_rotation": ..}` -- when rotate is false
        # the building rotation is returned unchanged, exactly
        # what Java does by skipping the assignment. The
        # driver tick reads the frame rotation (default 90.0,
        # the aim stamp default), passes rotate=true for duo
        # and the frame building rotation (default 0, the
        # Building field default), then stamps the key back on
        # the frame so the aim call reads a synced rotation.
        self.assertIn('static func source_turret_rotate_sync_state(rotation: float, rotate: bool, building_rotation: int) -> Dictionary:', turret)
        self.assertIn('return {"building_rotation": building_rotation}', turret)
        self.assertIn('if(rotate){', turret)
        self.assertIn('((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);', turret)
        self.assertIn('rotate = true;', turret)
        self.assertIn('return ((f % n) + n) % n;', turret)
        self.assertIn('return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;', turret)
        self.assertIn('transient int rotation;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2261 logicControlTime tick and BEFORE the aim call
        # (Java order :534-536 decay, :538-540 heatReq,
        # :542-545 rotate sync, :595-596 turnToTarget, :601/:609
        # updateShooting): it reads the frame rotation (default
        # 90.0), passes rotate=true for duo and the frame
        # building rotation (default 0), calls the new pure
        # function, then stamps the key back on the frame.
        self.assertIn('var rotate_sync: Dictionary = source_turret_rotate_sync_state(float(frame.get("rotation", 90.0)), true, int(frame.get("building_rotation", 0)))', turret)
        self.assertIn('frame["building_rotation"] = rotate_sync.get("building_rotation", 0)', turret)
        # The proof's keys drive the sync through the pure
        # function and the real driver (0 degrees syncs to 0 /
        # 90 degrees syncs to 1 / 135 degrees rounds half-up to
        # 2 / 360 wraps to 0 and 405 wraps to 1 / -90 wraps to
        # 3 through the proper mod / -45 rounds half-up to 0,
        # pinning arc round against half-away-from-zero / a
        # non-rotating turret keeps its building rotation /
        # the key is stamped on the frame after the tick / the
        # duo live tick syncs a seeded 270-degree rotation to
        # 3). There is no heatReq key: the fold (:538-540)
        # waits for its own slice (needs sideHeat +
        # calculateHeat).
        proof = TURRET_ROTATE_SYNC_PROOF.read_text(encoding='utf-8')
        for key in [
            'rotate_sync_zero_degrees',
            'rotate_sync_ninety_degrees',
            'rotate_sync_rounds_half_up',
            'rotate_sync_wraps_at_360',
            'rotate_sync_negative_wraps',
            'rotate_sync_negative_half_rounds_up',
            'rotate_sync_disabled_keeps_rotation',
            'rotate_sync_stamped_to_frame',
            'rotate_sync_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_rotate_sync(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretRotateSyncProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_ROTATE_SYNC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rotate_sync_zero_degrees',
            'rotate_sync_ninety_degrees',
            'rotate_sync_rounds_half_up',
            'rotate_sync_wraps_at_360',
            'rotate_sync_negative_wraps',
            'rotate_sync_negative_half_rounds_up',
            'rotate_sync_disabled_keeps_rotation',
            'rotate_sync_stamped_to_frame',
            'rotate_sync_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
