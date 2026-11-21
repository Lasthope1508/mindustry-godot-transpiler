import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_UPDATE_TILE_LEG1_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretUpdateTileLeg1Proof.gd'


class C07LaserTurretUpdateTileLeg1Tests(unittest.TestCase):
    def test_c07_laser_turret_update_tile_leg1_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2372']['godot_owner'], 'PortGame.source_laser_turret_build_update_tile_leg1_state')
        # LEG 1 of LaserTurretBuild.updateTile()
        # (LaserTurret.java:67-89): the whole bullets.any()
        # branch -- prune dead bullet entries, update each
        # survivor's bullet position/rotation/time/keepAlive
        # and decay its life, then set wasShooting/heat/
        # curRecoil. Leg 2 (the else-if reloadCounter > 0
        # branch, LaserTurret.java:90-108) is a LATER slice:
        # the two legs' write-sets are disjoint (leg 1
        # writes bullets/wasShooting/heat/curRecoil, leg 2
        # writes reloadCounter/liquids), the only join is
        # the if/else-if guard, and leg 1 returns the branch
        # flag "reload_branch": "bullets" (leg 2 later
        # returns "coolant"|"edelta"). Leg-split approved by
        # the main thread (write-sets disjoint, BurstDrill
        # updateTile leg precedent N2294+N2149+N2296).
        # `super.updateTile();` (LaserTurret.java:68) is a
        # shared callee, NOT a distinguishing expr (exact
        # hit in 7 local slices). `heat = 1f;` /
        # `wasShooting = true;` / `curRecoil = 1f;`
        # (LaserTurret.java:87-89) are state outputs in the
        # returned dict, NOT distinguishing exprs. The
        # shared lines `entry.bullet.rotation(angle);` /
        # `entry.bullet.set(bulletX, bulletY);` /
        # `entry.bullet.keepAlive = true;` (exact 1 hit
        # local: N2366, different class), `for(var entry :
        # bullets){` (N2362), the three float declarators
        # (N2366), `if(bullets.any()){` (N2362, N2364,
        # N2367) are text-shares across classes/methods,
        # registered under this java_method (the N632-N639
        # vs N1078-N1085 precedent). NO driver line: a pure
        # function the tick reads, not a per-tick write.
        # Five new result symbols: bullets, was_shooting,
        # heat, cur_recoil, reload_branch.
        self.assertEqual(
            ledger['N2372']['java_method'],
            'LaserTurretBuild.updateTile()',
        )
        self.assertEqual(
            ledger['N2372']['source_symbols'],
            [
                'source_laser_turret_build_update_tile_leg1_state_result.bullets',
                'source_laser_turret_build_update_tile_leg1_state_result.was_shooting',
                'source_laser_turret_build_update_tile_leg1_state_result.heat',
                'source_laser_turret_build_update_tile_leg1_state_result.cur_recoil',
                'source_laser_turret_build_update_tile_leg1_state_result.reload_branch',
            ],
        )
        for name in ledger['N2372']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2372']['runtime_proof'], '/root/C07LaserTurretUpdateTileLeg1Proof')
        self.assertEqual(
            ledger['N2372']['tests'],
            [
                'test_c07_laser_turret_update_tile_leg1_registration',
                'test_all_c07_laser_turret_update_tile_leg1_input_evidence_is_exact',
                'test_laser_turret_update_tile_leg1_state',
                'test_reference_graph_and_actual_c07_laser_turret_update_tile_leg1',
            ],
        )
        self.assertTrue(ledger['N2372']['deferred_exprs'])

    def test_all_c07_laser_turret_update_tile_leg1_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2372']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2372']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_update_tile_leg1_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.updateTile() leg 1
        # (LaserTurret.java:67-89): prune dead bullet
        # entries (`bullets.removeAll(...)`), then for each
        # survivor move its bullet to the rotated muzzle
        # offset (`Angles.trnsx/trnsy`, 3-arg overloads),
        # set its rotation/position, refresh its time
        # (`lifetime * optimalLifeFract`) and keepAlive,
        # decay its life (`Time.delta * timeScale /
        # Math.max(efficiency, 0.00001f)`), then set
        # wasShooting/heat/curRecoil. The bullets seq is
        # NOT ported -- it arrives as an explicit Array of
        # entry dicts (the N2330 param precedent); the
        # input array is never mutated, the pruned+updated
        # list is fresh. NO driver line.
        self.assertIn('static func source_laser_turret_build_update_tile_leg1_state(bullets: Array, x: float, y: float, rotation: float, shoot_x: float, shoot_y: float, efficiency: float, time_scale: float, source_delta: float, heat: float, cur_recoil: float) -> Dictionary:', bridge)
        self.assertIn('return {"bullets": pruned, "was_shooting": was_shooting, "heat": next_heat, "cur_recoil": next_cur_recoil, "reload_branch": reload_branch}', bridge)
        for expr in [
            'public class LaserTurret extends PowerTurret{',
            'public class LaserTurretBuild extends PowerTurretBuild{',
            '@Override',
            'public void updateTile(){',
            'bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.life <= 0f || b.bullet.owner != this);',
            'if(bullets.any()){',
            'for(var entry : bullets){',
            'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),',
            'bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),',
            'angle = rotation + entry.rotation;',
            'entry.bullet.rotation(angle);',
            'entry.bullet.set(bulletX, bulletY);',
            'entry.bullet.time = entry.bullet.type.lifetime * entry.bullet.type.optimalLifeFract;',
            'entry.bullet.keepAlive = true;',
            'entry.life -= Time.delta * timeScale / Math.max(efficiency, 0.00001f);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): dead
        # entries are pruned / live entries survive / the
        # bullet moves to the rotated muzzle offset / its
        # time refreshes and keepAlive sets / its life
        # decays / wasShooting/heat/curRecoil set when a
        # bullet is around / everything passes through
        # when no bullet is around / each result carries
        # only its five keys.
        proof = LASER_TURRET_UPDATE_TILE_LEG1_PROOF.read_text(encoding='utf-8')
        for key in [
            'prunes_dead_bullets',
            'keeps_live_bullets',
            'updates_entry_bullet_position',
            'refreshes_bullet_time_and_keep_alive',
            'decays_entry_life',
            'sets_was_shooting_heat_recoil_when_bullets',
            'passes_through_when_no_bullets',
            'returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_update_tile_leg1(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretUpdateTileLeg1Proof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_UPDATE_TILE_LEG_1_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'prunes_dead_bullets',
            'keeps_live_bullets',
            'updates_entry_bullet_position',
            'refreshes_bullet_time_and_keep_alive',
            'decays_entry_life',
            'sets_was_shooting_heat_recoil_when_bullets',
            'passes_through_when_no_bullets',
            'returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
