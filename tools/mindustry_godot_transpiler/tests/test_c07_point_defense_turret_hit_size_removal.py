import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_HIT_SIZE_REMOVAL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretHitSizeRemovalProof.gd'


class C07PointDefenseTurretHitSizeRemovalTests(unittest.TestCase):
    def test_c07_point_defense_turret_hit_size_removal_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2247']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_bullet_removal_state')
        # N2247 closes three documented limits the earlier
        # PointDefenseTurret slices left behind. (1) Bullet
        # hitSize: the N2239 acquire approximates the Java
        # intersect rect by the bullet point, and the N2242
        # wiring drops the live dict's hitSize, so a bullet
        # whose centre is outside the range rect but whose
        # hitbox overlaps it is never acquired
        # (PointDefenseTurret.java:65-67, `target =
        # Groups.bullet.intersect(x - range, y - range, range*2,
        # range*2).min(...)`, intersect tests the bullet hitbox,
        # BulletComp.java:28 `abstract class BulletComp
        # implements ... Hitboxc ...`, hitSize the BulletType
        # class default 4f, BulletType.java:43, `public float
        # hitSize = 4;`). (2) Live bullet removal: a lethally
        # shot target is nulled in the frame (N2240) but its
        # live dict stays in `game["bullets"]` forever, so the
        # sim keeps moving a dead bullet
        # (PointDefenseTurret.java:94-97, `if(target.damage()
        # > realDamage){ target.damage(target.damage() -
        # realDamage); }else{ target.remove(); }`, and :69-71,
        # `if(target != null && !target.isAdded()){ target =
        # null; }`). One new pure function plus the hitSize
        # key on the observed dicts plus the acquire overlap
        # test plus one driver tick line. Two new result
        # symbols: remaining_bullets / removed.
        self.assertEqual(
            ledger['N2247']['source_symbols'],
            [
                'source_point_defense_turret_bullet_removal_state_result.remaining_bullets',
                'source_point_defense_turret_bullet_removal_state_result.removed',
            ],
        )
        for name in ledger['N2247']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/entities/comp/BulletComp.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_bullet_removal_state_result.remaining_bullets': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_bullet_removal_state',
                    'source_point_defense_turret_bullet_removal_state_result.removed': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_bullet_removal_state',
                }[name])
        self.assertEqual(ledger['N2247']['runtime_proof'], '/root/C07PointDefenseTurretHitSizeRemovalProof')
        self.assertEqual(
            ledger['N2247']['tests'],
            [
                'test_c07_point_defense_turret_hit_size_removal_registration',
                'test_all_c07_point_defense_turret_hit_size_removal_input_evidence_is_exact',
                'test_point_defense_turret_hit_size_removal',
                'test_reference_graph_and_actual_c07_point_defense_turret_hit_size_removal',
            ],
        )
        self.assertTrue(ledger['N2247']['deferred_exprs'])

    def test_all_c07_point_defense_turret_hit_size_removal_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2247']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_bullet_removal_state_result.remaining_bullets': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_bullet_removal_state',
                    'source_point_defense_turret_bullet_removal_state_result.removed': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_bullet_removal_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/content/Blocks.java',
            # Groups.java is build-generated from GroupDefs.java
            # (@GroupDef(value = Bulletc.class, spatial = true,
            # collide = true) G bullet;, GroupDefs.java:9), so
            # it never exists on disk: the on-disk source is
            # GroupDefs.java, not Groups.java.
            'core/src/mindustry/entities/GroupDefs.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2247']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_hit_size_removal(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # (1) hitSize: the live bullet dict already carries
        # hitSize from the spawn side
        # (SourceBulletSpawnState.gd:41, `"hitSize":
        # float(bullet_spawn_state.get("hit_size", 0.0))`), but
        # the N2242 wiring drops it, so the observed dicts the
        # N2239 acquire consumes carry no hitSize and the
        # acquire tests the bullet point against the Java
        # intersect rect. Java's intersect tests the bullet
        # hitbox (BulletComp implements Hitboxc,
        # BulletComp.java:28; hitSize is the BulletType hitbox
        # size, `public float hitSize = 4;`,
        # BulletType.java:43, stamped onto the live bullet at
        # spawn, `bullet.hitSize = hitSize;`,
        # BulletType.java:970), so a bullet whose centre sits
        # just outside the rect but whose hitbox overlaps it
        # IS inside the intersect. The fix is an overlap test:
        # |bx - x| <= range + hitSize/2 and |by - y| <= range
        # + hitSize/2, with the BulletType 4f default when the
        # observed dict carries no hit_size. The min-dst2 pick
        # still uses the bullet centre (Java `b.dst2(this)` is
        # centre distance, PointDefenseTurret.java:67).
        self.assertIn('"hit_size": float(bullet.get("hitSize", 4.0))', point_defense)
        self.assertIn('var hit_size: float = float(bullet.get("hit_size", 4.0))', point_defense)
        self.assertIn('if absf(float(bullet.get("x", 0.0)) - x) > range + hit_size / 2.0:', point_defense)
        self.assertIn('if absf(float(bullet.get("y", 0.0)) - y) > range + hit_size / 2.0:', point_defense)
        self.assertIn('target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', point_defense)
        self.assertIn('public float hitSize = 4;', point_defense)
        self.assertIn('bullet.hitSize = hitSize;', point_defense)
        # (2) Live bullet removal: the aim/shoot half nulls
        # the frame target on a lethal shot (N2240,
        # `target_removed`), but the live bullet dict stays in
        # `game["bullets"]`, so the next tick's acquire can
        # re-acquire a dead bullet by id and the sim keeps
        # moving it. Java removes the bullet itself
        # (`target.remove();`, PointDefenseTurret.java:96, in
        # the else branch of `if(target.damage() >
        # realDamage){`, :94), which is what makes
        # `!target.isAdded()` true on the next tick (:69-71,
        # `if(target != null && !target.isAdded()){ target =
        # null; }`). The pure function filters the live list
        # by the removed id (the simulate_bullets
        # pending_removals precedent,
        # SourceBulletTargetRuntimeState.gd:77-110); the driver
        # calls it on the lethally-shot tick and writes the
        # filtered list back to the live list, so a damaged
        # (non-lethal) target keeps its dict and every other
        # bullet is untouched.
        self.assertIn('static func source_point_defense_turret_bullet_removal_state(live_bullets: Array, removed_id: int) -> Dictionary:', point_defense)
        self.assertIn('return {"remaining_bullets": remaining_bullets, "removed": removed}', point_defense)
        self.assertIn('source_point_defense_turret_bullet_removal_state(', point_defense)
        self.assertIn('if(target != null && !target.isAdded()){', point_defense)
        self.assertIn('target.remove();', point_defense)
        self.assertIn('if(target.damage() > realDamage){', point_defense)
        # The proof's keys drive the hitSize overlap and the
        # removal through the real driver (hit_size mapped
        # from the live dict / hit_size defaults to the
        # BulletType 4f / bullet touching the range edge by
        # hitbox is acquired / bullet fully outside by hitbox
        # is not / lethally shot bullet leaves the live list
        # / damaged bullet stays / other bullets untouched /
        # removal reports false when the id is absent).
        proof = POINT_DEFENSE_HIT_SIZE_REMOVAL_PROOF.read_text(encoding='utf-8')
        for key in [
            'hitsize_maps_live_bullet_hit_size',
            'hitsize_defaults_to_bullet_type_default',
            'hitsize_acquires_bullet_touching_range_edge',
            'hitsize_ignores_bullet_fully_outside_range',
            'removal_drops_lethally_shot_bullet_from_live_list',
            'removal_keeps_damaged_bullet_in_live_list',
            'removal_keeps_other_bullets',
            'removal_reports_removed_false_when_id_absent',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_hit_size_removal(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretHitSizeRemovalProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_HIT_SIZE_REMOVAL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'hitsize_maps_live_bullet_hit_size',
            'hitsize_defaults_to_bullet_type_default',
            'hitsize_acquires_bullet_touching_range_edge',
            'hitsize_ignores_bullet_fully_outside_range',
            'removal_drops_lethally_shot_bullet_from_live_list',
            'removal_keeps_damaged_bullet_in_live_list',
            'removal_keeps_other_bullets',
            'removal_reports_removed_false_when_id_absent',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
