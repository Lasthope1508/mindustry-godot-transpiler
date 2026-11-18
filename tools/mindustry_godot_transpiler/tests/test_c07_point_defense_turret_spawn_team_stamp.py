import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BULLET_SPAWN_STATE = ROOT / 'godot-mindustry/src/game/SourceBulletSpawnState.gd'
BULLET_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceBulletRuntimeState.gd'
BULLET_RUNTIME_PORT_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceBulletRuntimePortBridge.gd'
TURRET_SIMULATION_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretSimulationState.gd'
SPAWN_TEAM_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretSpawnTeamStampProof.gd'


class C07PointDefenseTurretSpawnTeamStampTests(unittest.TestCase):
    def test_c07_point_defense_turret_spawn_team_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2243']['godot_owner'], 'SourceBulletSpawnState.source_spawn_turret_bullet_from_state')
        # N2242 left should_consume dead in live play: live
        # `game["bullets"]` dicts carry no team (the only writer,
        # SourceBulletSpawnState.gd source_spawn_turret_bullet_from_state,
        # appends sprite / target / velocity / speed / damage /
        # hitSize / lifetime_remaining only), so the N2242 wiring
        # excludes every live bullet and the N2239 acquire never
        # sees an enemy target. Java gives every live Bullet a
        # team: the firing building passes its own team into the
        # create chain (`handleBullet(type.create(this, team, ...`,
        # Turret.java:790; `bullet.team = team;`,
        # BulletType.java:954; `@Import Team team;`,
        # BulletComp.java:29). This slice stamps the firing
        # turret's team onto each live bullet dict at spawn,
        # threading it turret-sim -> bridge -> runtime -> spawn
        # state. One new result symbol: team.
        self.assertEqual(
            ledger['N2243']['source_symbols'],
            [
                'spawn_turret_bullet_from_state_result.team',
            ],
        )
        for name in ledger['N2243']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'core/src/mindustry/entities/comp/BulletComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'spawn_turret_bullet_from_state_result.team': 'SourceBulletSpawnState.source_spawn_turret_bullet_from_state',
                }[name])
        self.assertEqual(ledger['N2243']['runtime_proof'], '/root/C07PointDefenseTurretSpawnTeamStampProof')
        self.assertEqual(
            ledger['N2243']['tests'],
            [
                'test_c07_point_defense_turret_spawn_team_stamp_registration',
                'test_all_c07_point_defense_turret_spawn_team_stamp_input_evidence_is_exact',
                'test_point_defense_turret_spawn_team_stamp_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_spawn_team_stamp',
            ],
        )
        self.assertTrue(ledger['N2243']['deferred_exprs'])

    def test_all_c07_point_defense_turret_spawn_team_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2243']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'spawn_turret_bullet_from_state_result.team': 'SourceBulletSpawnState.source_spawn_turret_bullet_from_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2243']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_spawn_team_stamp_state(self):
        spawn_state = BULLET_SPAWN_STATE.read_text(encoding='utf-8')
        runtime_state = BULLET_RUNTIME_STATE.read_text(encoding='utf-8')
        port_bridge = BULLET_RUNTIME_PORT_BRIDGE.read_text(encoding='utf-8')
        simulation_state = TURRET_SIMULATION_STATE.read_text(encoding='utf-8')
        # The team threads through the whole spawn chain as one
        # extra `team_id: int` parameter -- no new synonym, the
        # name is the SourceTurretBuildState.gd:199 precedent
        # (`var team_id: int = int(sprite.get_meta(...))`). Java
        # fires the bullet with the building's own team
        # (`handleBullet(type.create(this, team, bulletX, bulletY,
        # shootAngle, -1f, (1f - velocityRnd) +
        # Mathf.random(velocityRnd), lifeScl, null, mover,
        # targetPos.x, targetPos.y), xOffset, yOffset, shootAngle
        # - rotation);`, Turret.java:790) and the create chain
        # stamps it (`bullet.team = team;`,
        # BulletType.java:954; the owner overload forwards
        # `owner.team()`, BulletType.java:862-863; every live
        # Bullet carries the field, `@Import Team team;`,
        # BulletComp.java:29). The sim loop's `cell` is a Vector2i
        # grid cell from `game["turret_cells"]` and NEITHER
        # fire_context nor shot_context carries a team today, so
        # the loop reads the firing cell's team from the placed
        # sprite that owns the cell -- placed sprites carry
        # `origin_cell` meta (SourcePlacedBlockState.gd:90) and the
        # team meta key (SourceBlockGeometry.gd:161,
        # SOURCE_BUILD_TEAM_META_KEY, derelict default 0, the
        # SourceTurretBuildState.gd:199 precedent) -- and passes
        # it into the spawn call. The appended live dict gains
        # exactly one key, `"team": team_id`; nothing else in the
        # dict changes, and the N2242 mapping function is untouched
        # (it already reads `team` when present).
        self.assertIn('static func source_spawn_turret_bullet_from_state(game, origin: Vector2, target, bullet_spawn_state: Dictionary, bullet_texture: Texture2D, team_id: int) -> void:', spawn_state)
        self.assertIn('"team": team_id', spawn_state)
        self.assertIn('static func spawn_turret_bullet(game, origin: Vector2, target, data: Dictionary, team_id: int, shoot_angle_degrees := 0.0) -> void:', runtime_state)
        self.assertIn('source_bullet_spawn_state.source_spawn_turret_bullet_from_state(game, origin, target, bullet_spawn_state, bullet_texture, team_id)', runtime_state)
        self.assertIn('func spawn_turret_bullet(origin: Vector2, target, data: Dictionary, team_id: int, shoot_angle_degrees := 0.0) -> void:', port_bridge)
        self.assertIn('source_bullet_runtime_state.spawn_turret_bullet(self, origin, target, data, team_id, shoot_angle_degrees)', port_bridge)
        self.assertIn('game.call("spawn_turret_bullet", bullet_origin, target, data, team_id, shoot_angle_degrees)', simulation_state)
        self.assertIn('SOURCE_BUILD_TEAM_META_KEY', simulation_state)
        self.assertIn('get_meta("origin_cell"', simulation_state)
        self.assertIn('handleBullet(type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y), xOffset, yOffset, shootAngle - rotation);', spawn_state)
        self.assertIn('bullet.team = team;', spawn_state)
        self.assertIn('@Import Team team;', spawn_state)
        # The proof's keys drive the stamp through the real chain
        # (a fired bullet's live dict carries the firing turret's
        # team / a second-team turret's bullet carries the other
        # team / the N2242 wiring then includes both bullets with
        # their correct teams, so the acquire can see them).
        proof = SPAWN_TEAM_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'spawn_team_stamp_carries_firing_turret_team',
            'spawn_team_stamp_second_team_carries_other_team',
            'spawn_team_stamp_wiring_includes_both_with_correct_teams',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_spawn_team_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretSpawnTeamStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_SPAWN_TEAM_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'spawn_team_stamp_carries_firing_turret_team',
            'spawn_team_stamp_second_team_carries_other_team',
            'spawn_team_stamp_wiring_includes_both_with_correct_teams',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
