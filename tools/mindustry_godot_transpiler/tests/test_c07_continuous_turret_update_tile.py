import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretUpdateTileProof.gd'


class C07ContinuousTurretUpdateTileTests(unittest.TestCase):
    def test_c07_continuous_turret_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2362']['godot_owner'], 'PortGame.source_continuous_turret_build_update_tile_state')
        # ContinuousTurretBuild.updateTile() (ContinuousTurret.java:86-101):
        # `@Override`
        # `public void updateTile(){`
        # `super.updateTile();`
        # `bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);`
        # `if(bullets.any()){`
        # `for(var entry : bullets){`
        # `updateBullet(entry);`
        # `wasShooting = true;`
        # `heat = 1f;`
        # `curRecoil = recoil;`
        # `}`
        # `}`
        # on `public class ContinuousTurretBuild extends TurretBuild{`
        # (ContinuousTurret.java:38) inside
        # `public class ContinuousTurret extends Turret{`. This
        # is the ContinuousTurret tick: prune dead bullets, then
        # when any bullet survives, flag wasShooting, set heat
        # to 1f and curRecoil to recoil. super.updateTile() is
        # the TurretBuild base tick (Turret.java:490) -- it resets
        # wasShooting to false (Turret.java:517) and decays heat
        # / curRecoil toward 0, so this slice reads the post-super
        # frame: was_shooting is true exactly when pruned bullets
        # remain, heat / cur_recoil keep their input values when
        # no bullet remains. updateBullet(entry) is a CALLEE --
        # NOT ported in this slice (batch 13+, draft §4e); only
        # the call line is registered as evidence. Four new
        # result symbols: bullets, was_shooting, heat,
        # cur_recoil. The bullets Seq is NOT ported: it arrives
        # as an explicit param, an Array of {is_added,
        # type_null, owner_is_self} dicts (the N2330 param
        # precedent).
        self.assertEqual(
            ledger['N2362']['source_symbols'],
            [
                'source_continuous_turret_build_update_tile_state_result.bullets',
                'source_continuous_turret_build_update_tile_state_result.was_shooting',
                'source_continuous_turret_build_update_tile_state_result.heat',
                'source_continuous_turret_build_update_tile_state_result.cur_recoil',
            ],
        )
        for name in ledger['N2362']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2362']['runtime_proof'], '/root/C07ContinuousTurretUpdateTileProof')
        self.assertEqual(
            ledger['N2362']['tests'],
            [
                'test_c07_continuous_turret_update_tile_registration',
                'test_all_c07_continuous_turret_update_tile_input_evidence_is_exact',
                'test_continuous_turret_update_tile_state',
                'test_reference_graph_and_actual_c07_continuous_turret_update_tile',
            ],
        )
        self.assertTrue(ledger['N2362']['deferred_exprs'])

    def test_all_c07_continuous_turret_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2362']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2362']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_update_tile_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.updateTile()
        # (ContinuousTurret.java:86-101) prunes bullets whose
        # bullet is not added, whose type is null, or whose
        # owner is not this turret; when any bullet survives
        # it sets wasShooting, heat = 1f, curRecoil = recoil.
        # super.updateTile() (Turret.java:490) resets
        # wasShooting to false first, so was_shooting is true
        # exactly when pruned bullets remain. heat / cur_recoil
        # keep their input values when no bullet remains.
        # updateBullet(entry) is a callee, NOT ported here.
        self.assertIn('static func source_continuous_turret_build_update_tile_state(bullets: Array, recoil: float, heat: float, cur_recoil: float) -> Dictionary:', bridge)
        self.assertIn('return {"bullets": pruned, "was_shooting": was_shooting, "heat": next_heat, "cur_recoil": next_cur_recoil}', bridge)
        for expr in [
            'public class ContinuousTurret extends Turret{',
            'public class ContinuousTurretBuild extends TurretBuild{',
            '@Override',
            'public void updateTile(){',
            'super.updateTile();',
            'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);',
            'if(bullets.any()){',
            'for(var entry : bullets){',
            'updateBullet(entry);',
            'wasShooting = true;',
            'heat = 1f;',
            'curRecoil = recoil;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof drives the pure function with synthetic
        # bullet entries (no live tick): dead entries pruned
        # / live entries kept in order / flags set when a
        # bullet survives / no flags when none survives /
        # the input array is not mutated.
        proof = CONTINUOUS_TURRET_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'dead_bullets_pruned',
            'live_bullets_kept',
            'shooting_flags_set',
            'no_bullets_no_flags',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dead_bullets_pruned',
            'live_bullets_kept',
            'shooting_flags_set',
            'no_bullets_no_flags',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
