import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_LIVE_BULLETS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretLiveBulletsWiringProof.gd'


class C07PointDefenseTurretLiveBulletsWiringTests(unittest.TestCase):
    def test_c07_point_defense_turret_live_bullets_wiring_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2242']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_live_bullets_state')
        # N2241 left should_consume dead in live play: the frame
        # never carries `observed_bullets`, so the target stays
        # null and `should_consume` is false (PointDefenseTurret.java:105-107,
        # `return super.shouldConsume() && target != null;`). The
        # driver only runs the acquire when `frame.has("observed_bullets")`
        # (SourcePointDefenseTurretBuildState.gd) and never stamps
        # that key. This slice is the wiring: map the live
        # `game["bullets"]` dicts to the observed dicts the N2239
        # acquire consumes, and stamp `frame["observed_bullets"]`
        # every driver tick. One pure function plus one driver
        # tick line. One new result symbol: observed_bullets.
        self.assertEqual(
            ledger['N2242']['source_symbols'],
            [
                'source_point_defense_turret_live_bullets_state_result.observed_bullets',
            ],
        )
        for name in ledger['N2242']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/entities/comp/BulletComp.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_live_bullets_state_result.observed_bullets': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_live_bullets_state',
                }[name])
        self.assertEqual(ledger['N2242']['runtime_proof'], '/root/C07PointDefenseTurretLiveBulletsWiringProof')
        self.assertEqual(
            ledger['N2242']['tests'],
            [
                'test_c07_point_defense_turret_live_bullets_wiring_registration',
                'test_all_c07_point_defense_turret_live_bullets_wiring_input_evidence_is_exact',
                'test_point_defense_turret_live_bullets_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_live_bullets_wiring',
            ],
        )
        self.assertTrue(ledger['N2242']['deferred_exprs'])

    def test_all_c07_point_defense_turret_live_bullets_wiring_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2242']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_live_bullets_state_result.observed_bullets': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_live_bullets_state',
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
            # GroupDefs.java, not Groups.java. (RED-test fix,
            # N2239: the 23:00 RED listed Groups.java and the
            # evidence test would FileNotFoundError on it.)
            'core/src/mindustry/entities/GroupDefs.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2242']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_live_bullets_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # The wiring maps the live `game["bullets"]` dicts
        # (SourceBulletSpawnState.gd, the only writer: sprite /
        # target / velocity / speed / damage / hitSize /
        # lifetime_remaining -- no team / hittable / id / type)
        # to the observed dicts the N2239 acquire consumes
        # (id / team / hittable / x / y / damage / has_type).
        # Java reads the live query every retarget
        # (`target = Groups.bullet.intersect(x - range, y -
        # range, range*2, range*2).min(b -> b.team != team &&
        # b.type().hittable, b -> b.dst2(this));`,
        # PointDefenseTurret.java:65-67) and drops a pooled
        # target (`if(target != null && !target.isAdded()){` /
        # `target = null;`, PointDefenseTurret.java:69-71).
        # The mapping, field by field (source-backed, nothing
        # invented): id is the sprite instance id
        # (SourcePlacedBlockState.gd:11 precedent -- stable
        # while the sprite lives, so a freed sprite means the
        # bullet left the live list and the N2239 id-absent
        # invalidation drops the target); x/y are
        # sprite.position (SourceBulletTargetRuntimeState.gd:20-25
        # precedent; an invalid sprite drops the bullet, the
        # simulate_bullets pending_removals precedent); damage
        # is the live dict's damage; team is read ONLY when the
        # live dict carries it -- a team-less bullet is EXCLUDED,
        # never defaulted to -1 (the acquire reads
        # `int(bullet.get("team", -1))`, and -1 != team_id for
        # every real team -- derelict is 0, SourceBlockGeometry.gd:159
        # -- so defaulting -1 would misclassify own-team turret
        # fire, the only live bullets today, as enemy); hittable
        # defaults to the BulletType class default true
        # (BulletType.java:143, `public boolean hittable = true;`;
        # the damageLightning / fireball `hittable = false`
        # types wait for a per-type lookup slice); has_type is
        # true because every live bullet was created with
        # `bullet.type = this` (SourceBulletTypeCreateCoreState.gd
        # bullet_identity_state typeSource). The driver stamps
        # the mapped list every tick, right before the acquire
        # block -- an empty list is still an observation (the
        # N2190/N2195 present-but-empty precedent), so the
        # acquire runs and a pooled target clears. The
        # spawn-side team stamp (turret-sim -> bridge -> runtime
        # chain carries no team today) is DEFERRED to its own
        # slice; this slice maps only what the live dict carries.
        self.assertIn('static func source_point_defense_turret_live_bullets_state(live_bullets: Array) -> Dictionary:', point_defense)
        self.assertIn('sprite.get_instance_id()', point_defense)
        self.assertIn('sprite.position', point_defense)
        self.assertIn('float(bullet.get("damage", 0.0))', point_defense)
        self.assertIn('bullet.get("team", null)', point_defense)
        self.assertIn('bool(bullet.get("hittable", true))', point_defense)
        self.assertIn('return {"observed_bullets": observed_bullets}', point_defense)
        # RED-test fix (GREEN, N2242): the RED test pinned
        # `game.get("bullets", [])` in the driver line, but
        # Object.get() takes at most 1 argument in Godot 4.6 --
        # verified against the 4.6.2 binary ("Too many arguments
        # for get() call. Expected at most 1 but received 2."),
        # so that line could never parse and the whole state file
        # would fail to load. The driver reads the live list with
        # the 1-arg get (the SourceBulletSpawnState.gd:38
        # precedent) and guards the Array cast inline instead.
        self.assertIn('var live_bullets: Array = game.get("bullets") if game.get("bullets") is Array else []', point_defense)
        self.assertIn('frame["observed_bullets"] = source_point_defense_turret_live_bullets_state(live_bullets).get("observed_bullets", [])', point_defense)
        self.assertIn('target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', point_defense)
        self.assertIn('if(target != null && !target.isAdded()){', point_defense)
        self.assertIn('public boolean hittable = true;', point_defense)
        # The proof's keys drive the wiring through the real
        # driver (live bullet position from sprite / stable id
        # from sprite / team-less bullet excluded / team and
        # hittable read when present / hittable defaults true /
        # has_type true / observed stamped every tick / pooled
        # target cleared when the bullet leaves the live list).
        # There are no acquire / aim / shoot keys: those halves
        # (PointDefenseTurret.java:65-101) already have their
        # own slices (N2239/N2240).
        proof = POINT_DEFENSE_LIVE_BULLETS_PROOF.read_text(encoding='utf-8')
        for key in [
            'wiring_maps_live_bullet_position_from_sprite',
            'wiring_assigns_stable_id_from_sprite',
            'wiring_excludes_bullet_without_team',
            'wiring_reads_team_and_hittable_when_present',
            'wiring_defaults_hittable_true',
            'wiring_marks_has_type_true',
            'wiring_stamps_observed_bullets_every_tick',
            'wiring_clears_pooled_target_when_bullet_leaves_live_list',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_live_bullets_wiring(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretLiveBulletsWiringProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_LIVE_BULLETS_WIRING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'wiring_maps_live_bullet_position_from_sprite',
            'wiring_assigns_stable_id_from_sprite',
            'wiring_excludes_bullet_without_team',
            'wiring_reads_team_and_hittable_when_present',
            'wiring_defaults_hittable_true',
            'wiring_marks_has_type_true',
            'wiring_stamps_observed_bullets_every_tick',
            'wiring_clears_pooled_target_when_bullet_leaves_live_list',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
