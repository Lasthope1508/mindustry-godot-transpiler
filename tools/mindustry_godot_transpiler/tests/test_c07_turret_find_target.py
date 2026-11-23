import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_FIND_TARGET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretFindTargetProof.gd'


class C07TurretFindTargetTests(unittest.TestCase):
    def test_c07_turret_find_target_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2316']['godot_owner'], 'SourceTurretBuildState.source_turret_find_target_state')
        # TurretBuild.findTarget() / findEnemy() /
        # validateTarget() / canHeal() (Turret.java:631-663):
        # `protected boolean validateTarget(){` /
        # `return !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();` (:631-633),
        # `protected boolean canHeal(){` /
        # `return targetHealing && hasAmmo() &&
        # peekAmmo().collidesTeam && peekAmmo().heals();`
        # (:635-637), `protected Posc findEnemy(float
        # range){` (:639-649) and `protected void
        # findTarget(){` (:651-663). The targeting
        # selection itself runs on observed dicts (the
        # N2242 live-bullets precedent): the live Units
        # queries (nearbyEnemies scan,
        # indexer.findEnemyTile / findTile, inFogTo) stay
        # on the driver side, which stamps the candidate
        # flags; this slice ports only the pure selection
        # (predicate filters, UnitSorts.closest cost, the
        # targetPriority tie-break, the units-before-
        # buildings order and the findTarget fallback
        # chain). RED decisions (recorded in the register
        # docstring): (1) five pure functions on
        # SourceTurretBuildState.gd next to the N2261
        # estimateDps / N2308 warmup rows -- can_heal,
        # invalidate_target, validate_target, find_enemy,
        # find_target. (2) All live values arrive as
        # explicit params (the N2188 precedent) -- range /
        # track_range, hasAmmo / peekAmmo flags,
        # controlled / logicControlled, unitFilter /
        # buildingFilter / unitSort via candidate flags
        # and the dst2 cost. (3) NO driver line: updateTile
        # calls findTarget() at :570 and validateTarget()
        # at :491/:573 -- the driver is its own later
        # slice (the N2244 fogRadius / N2261 estimateDps
        # accessor precedent). (4) The team passed to
        # invalidateTarget is Team.derelict when canHeal()
        # holds, else the turret team -- the driver
        # computes target_same_team against that team; the
        # pure functions never hard-code a team id. (5)
        # SourceTurretTargetingState.gd is NOT reused: it
        # only picks the nearest candidate by distance and
        # has no slice owner -- it lacks the predicate
        # filters, the targetPriority tie-break and the
        # building fallback this slice ports. Five new
        # result symbols: can_heal, target_invalid,
        # validate_target, find_enemy.target,
        # find_target.target. This slice closes no deferred
        # item: findTarget was never a deferred entry of
        # the Turret chain.
        self.assertEqual(
            ledger['N2316']['source_symbols'],
            [
                'source_turret_can_heal_state_result.can_heal',
                'source_turret_invalidate_target_state_result.target_invalid',
                'source_turret_validate_target_state_result.validate_target',
                'source_turret_find_enemy_state_result.target',
                'source_turret_find_target_state_result.target',
            ],
        )
        for name in ledger['N2316']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/Units.java',
                    'core/src/mindustry/entities/UnitSorts.java',
                    'core/src/mindustry/ai/BlockIndexer.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2316']['runtime_proof'], '/root/C07TurretFindTargetProof')
        self.assertEqual(
            ledger['N2316']['tests'],
            [
                'test_c07_turret_find_target_registration',
                'test_all_c07_turret_find_target_input_evidence_is_exact',
                'test_turret_find_target_state',
                'test_reference_graph_and_actual_c07_turret_find_target',
            ],
        )
        self.assertTrue(ledger['N2316']['deferred_exprs'])
        self.assertIn(
            'Turret findTarget() Windows Godot proof',
            ' '.join(ledger['N2316']['deferred_exprs']),
        )

    def test_all_c07_turret_find_target_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2316']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/UnitSorts.java',
            'core/src/mindustry/ai/BlockIndexer.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2316']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_find_target_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.findTarget() / findEnemy() /
        # validateTarget() / canHeal() (Turret.java:631-663).
        # canHeal: `return targetHealing && hasAmmo() &&
        # peekAmmo().collidesTeam && peekAmmo().heals();`
        # (:636). validateTarget: `return
        # !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();` (:632), where
        # invalidateTarget with range Float.MAX_VALUE
        # (Units.java:160-162) drops the within-range
        # branch entirely (Units.java:151-158) and keeps
        # only the four observed flags. findEnemy: the
        # air-only branch calls Units.bestEnemy with
        # `e -> !e.dead() && !e.isGrounded() &&
        # unitFilter.get(e)` (:641); the general branch
        # computes `boolean buildings = targetGround &&
        # targetBlocks && (ammo == null ||
        # ammo.targetBlocks), missiles = ammo == null ||
        # ammo.targetMissiles;` (:644) and calls
        # Units.bestTarget (:645-647), which checks units
        # first via bestEnemy and only then buildings via
        # findEnemyTile (Units.java:284-294). bestEnemy
        # skips dead / pred-fail / derelict / out-of-range
        # / untargetable / in-fog candidates and picks by
        # sort.cost with the targetPriority tie-break
        # (Units.java:318-338, `if((result == null ||
        # cost < cdist || e.type.targetPriority >
        # cpriority) && e.type.targetPriority >=
        # cpriority){`); the default sort is
        # UnitSorts.closest = Unit::dst2
        # (UnitSorts.java:11). findTarget: `float
        # trackRange = trackingRange(), range = range();`
        # then findEnemy(range), then findEnemy(trackRange)
        # only when `!Mathf.equal(trackRange, range)` and
        # no target yet, then Units.findAllyTile when still
        # null and canHeal() (:651-663). Mathf.equal is an
        # epsilon compare (Mathf.java:544-546, `return
        # Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;`,
        # FLOAT_ROUNDING_ERROR = 0.000001f) -- not `==`
        # and not GDScript is_equal_approx (whose epsilon
        # is 0.00001). No driver line: updateTile calls
        # findTarget() at :570 and validateTarget() at
        # :491/:573 -- the driver is its own later slice.
        self.assertIn('static func source_turret_can_heal_state(frame: Dictionary, target_healing: bool, has_ammo: bool, peek_collides_team: bool, peek_heals: bool) -> Dictionary:', turret)
        self.assertIn('return {"can_heal": target_healing and has_ammo and peek_collides_team and peek_heals}', turret)
        self.assertIn('static func source_turret_invalidate_target_state(frame: Dictionary, target_is_null: bool, target_same_team: bool, target_health_invalid: bool, target_unit_not_targetable: bool) -> Dictionary:', turret)
        self.assertIn('return {"target_invalid": target_is_null or target_same_team or target_health_invalid or target_unit_not_targetable}', turret)
        self.assertIn('static func source_turret_validate_target_state(frame: Dictionary, target_invalid: bool, is_controlled: bool, is_logic_controlled: bool) -> Dictionary:', turret)
        self.assertIn('return {"validate_target": (not target_invalid) or is_controlled or is_logic_controlled}', turret)
        self.assertIn('static func source_turret_find_enemy_state(frame: Dictionary, team_is_derelict: bool, range: float, target_air: bool, target_ground: bool, target_blocks: bool, ammo_is_null: bool, ammo_target_blocks: bool, ammo_target_missiles: bool, unit_candidates: Array, building_candidates: Array) -> Dictionary:', turret)
        self.assertIn('if (best == null or cost < best_cost or priority > best_priority) and priority >= best_priority:', turret)
        self.assertIn('static func source_turret_find_target_state(frame: Dictionary, range: float, track_range: float, found_standard: Variant, found_track: Variant, can_heal: bool, ally_tile: Variant) -> Dictionary:', turret)
        self.assertIn('if absf(track_range - range) > 0.000001 and target == null:', turret)
        for expr in [
            'protected boolean validateTarget(){',
            'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();',
            'protected boolean canHeal(){',
            'return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();',
            'protected Posc findEnemy(float range){',
            'if(targetAir && !targetGround){',
            'return Units.bestEnemy(team, x, y, range, e -> !e.dead() && !e.isGrounded() && unitFilter.get(e), unitSort);',
            'boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;',
            'e -> !e.dead() && unitFilter.get(e) && (e.isGrounded() || targetAir) && (!e.isGrounded() || targetGround) && (missiles || !(e instanceof TimedKillc)),',
            'b -> buildings && buildingFilter.get(b), unitSort);',
            'protected void findTarget(){',
            'float trackRange = trackingRange(), range = range();',
            'target = findEnemy(range);',
            'if(!Mathf.equal(trackRange, range) && target == null){',
            'target = findEnemy(trackRange);',
            'if(target == null && canHeal()){',
            'target = Units.findAllyTile(team, x, y, range, b -> b.damaged() && b != this);',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public boolean targetHealing = false;',
            'public Sortf unitSort = UnitSorts.closest;',
            'public boolean controlled(){',
            'return unit.isPlayer();',
            'public boolean logicControlled(){',
            'return logicControlTime > 0;',
            'public @Nullable BulletType peekAmmo(){',
            'public boolean hasAmmo(){',
            'public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){',
            'return invalidateTarget(target, team, x, y, Float.MAX_VALUE);',
            '(target instanceof Teamc t && t.team() == team) ||',
            '(target instanceof Healthc h && !h.isValid()) ||',
            '(target instanceof Unit u && !u.targetable(team));',
            'public static Teamc bestTarget(Team team, float x, float y, float range, Boolf<Unit> unitPred, Boolf<Building> tilePred, Sortf sort){',
            'Unit unit = bestEnemy(team, x, y, range, unitPred, sort);',
            'return findEnemyTile(team, x, y, range, tilePred);',
            'public static Unit bestEnemy(Team team, float x, float y, float range, Boolf<Unit> predicate, Sortf sort){',
            'if(e.dead() || !predicate.get(e) || e.team == Team.derelict || !e.within(x, y, range + e.hitSize/2f) || !e.targetable(team) || e.inFogTo(team)) return;',
            'float cost = sort.cost(e, x, y);',
            'if((result == null || cost < cdist || e.type.targetPriority > cpriority) && e.type.targetPriority >= cpriority){',
            'public static Building findAllyTile(Team team, float x, float y, float range, Boolf<Building> pred){',
            'return indexer.findTile(team, x, y, range, pred);',
            'public static Building findEnemyTile(Team team, float x, float y, float range, Boolf<Building> pred){',
            'closest = Unit::dst2,',
            'buildingDefault = b -> b.block.priority,',
            'float dist = candidate.dst(x, y) - candidate.hitSize() / 2f;',
            'float bdst = next.dst(x, y) - next.hitSize() / 2f;',
            'if(bdst < range && (closest == null ||',
            'public boolean collidesTeam = false;',
            'public boolean heals(){',
            'return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;',
            'public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure functions directly
        # with explicit params and observed dicts: validate
        # true on a valid target, false on an invalid
        # uncontrolled target, true on an invalid but
        # controlled target; invalidate true for a null or
        # same-team target; canHeal false with targetHealing
        # off and true with every gate on; the air-only
        # branch skips a grounded unit; units win over
        # buildings (and a timed-kill unit is skipped when
        # the ammo does not target missiles); a farther
        # higher-priority unit beats a closer lower-priority
        # one; findTarget falls back to the tracking range
        # and then to an ally tile when canHeal holds.
        proof = TURRET_FIND_TARGET_PROOF.read_text(encoding='utf-8')
        for key in [
            'validate_target_valid',
            'validate_target_invalid_uncontrolled',
            'validate_target_invalid_controlled',
            'invalidate_target_null_and_same_team',
            'can_heal_false_target_healing_off',
            'can_heal_true_all_gates',
            'find_enemy_air_only_skips_grounded',
            'find_enemy_units_before_buildings',
            'find_enemy_priority_beats_distance',
            'find_target_falls_back_to_track_range',
            'find_target_falls_back_to_ally_tile',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_find_target(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretFindTargetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_FIND_TARGET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'validate_target_valid',
            'validate_target_invalid_uncontrolled',
            'validate_target_invalid_controlled',
            'invalidate_target_null_and_same_team',
            'can_heal_false_target_healing_off',
            'can_heal_true_all_gates',
            'find_enemy_air_only_skips_grounded',
            'find_enemy_units_before_buildings',
            'find_enemy_priority_beats_distance',
            'find_target_falls_back_to_track_range',
            'find_target_falls_back_to_ally_tile',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
