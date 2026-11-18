import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceItemTurretBuildState.gd'
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ITEM_TURRET_VALIDATE_TARGET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemTurretValidateTargetProof.gd'


class C07ItemTurretValidateTargetTests(unittest.TestCase):
    def test_c07_item_turret_validate_target_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2251']['godot_owner'], 'SourceItemTurretBuildState.source_item_turret_validate_target_state')
        # validateTarget() is the gate at the top of
        # TurretBuild.updateTile() (`if(!validateTarget())
        # target = null;`, Turret.java:491) and the aim/shoot
        # branch (`if(validateTarget()){`, Turret.java:573 --
        # N2250 takes the verdict in as target_valid because
        # Units.invalidateTarget waited for its own slice).
        # validateTarget is `return
        # !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();` (Turret.java:631-633), and
        # validateTarget calls the NO-range overload of
        # Units.invalidateTarget (Units.java:160-162), so range
        # is Float.MAX_VALUE and the range clause is dead in
        # validateTarget: the pure function takes NO range
        # param. Units.invalidateTarget (Units.java:151-157)
        # invalidates when the target is null, when it is a
        # Teamc on the effective team, when it is a Healthc
        # that is not valid, or when it is a Unit that is not
        # targetable by the effective team. The effective team
        # is Team.derelict when canHeal() and the turret team
        # otherwise; canHeal() is `targetHealing && hasAmmo()
        # && peekAmmo().collidesTeam && peekAmmo().heals()`
        # (Turret.java:635-637). Team.derelict is id 0
        # (Team.java:33, `derelict = new Team(0, "derelict",
        # Color.valueOf("4d4e58")),`). targetHealing defaults
        # false (Turret.java:95, `public boolean targetHealing
        # = false;`) and the duo def (Blocks.java:3257-3324)
        # never sets it, so the derelict branch is dead for
        # duo -- but the pure function still takes the
        # already-resolved effective-team bool as a param, so
        # later ItemTurret defs with targetHealing true work
        # unchanged. controlled() is `unit.isPlayer()`
        # (Turret.java:441-443) and logicControlled() is
        # `logicControlTime > 0` (Turret.java:445-447,
        # `public float curRecoil, heat, logicControlTime =
        # -1;`, Turret.java:284): either one rescues even a
        # null target, exactly as Java's `||` does. The port
        # has NO controlled / logic_controlled frame flags yet
        # (no match in SourceTurretBuildState.gd or
        # SourceItemTurretBuildState.gd), so the driver and
        # the proof stamp them in from the frame with false
        # defaults -- the live player/logic wiring waits for
        # its own slice. One pure function on
        # SourceItemTurretBuildState.gd, plus one driver tick
        # line in SourceTurretBuildState.gd at the head of the
        # duo branch (before the N2250 aim/shoot call) that
        # clears frame["target"] / frame["has_target"] when
        # the verdict is invalid and feeds the verdict into
        # the aim/shoot target_valid arg (which today passes
        # `bool(frame.get("has_target", false))`, NOT a
        # hardcoded true -- the scope note said hardcoded
        # true, the disk says has_target). Two new result
        # symbols: valid + target_cleared.
        self.assertEqual(
            ledger['N2251']['source_symbols'],
            [
                'source_item_turret_validate_target_state_result.valid',
                'source_item_turret_validate_target_state_result.target_cleared',
            ],
        )
        for name in ledger['N2251']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/Units.java',
                    'core/src/mindustry/game/Team.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_turret_validate_target_state_result.valid': 'SourceItemTurretBuildState.source_item_turret_validate_target_state',
                    'source_item_turret_validate_target_state_result.target_cleared': 'SourceItemTurretBuildState.source_item_turret_validate_target_state',
                }[name])
        self.assertEqual(ledger['N2251']['runtime_proof'], '/root/C07ItemTurretValidateTargetProof')
        self.assertEqual(
            ledger['N2251']['tests'],
            [
                'test_c07_item_turret_validate_target_registration',
                'test_all_c07_item_turret_validate_target_input_evidence_is_exact',
                'test_item_turret_validate_target_state',
                'test_reference_graph_and_actual_c07_item_turret_validate_target',
            ],
        )
        self.assertTrue(ledger['N2251']['deferred_exprs'])

    def test_all_c07_item_turret_validate_target_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2251']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_turret_validate_target_state_result.valid': 'SourceItemTurretBuildState.source_item_turret_validate_target_state',
                    'source_item_turret_validate_target_state_result.target_cleared': 'SourceItemTurretBuildState.source_item_turret_validate_target_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/game/Team.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2251']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_turret_validate_target_state(self):
        item_turret = ITEM_TURRET_STATE.read_text(encoding='utf-8')
        # validateTarget() (Turret.java:631-633) is the pure
        # predicate that gates updateTile: `return
        # !Units.invalidateTarget(target, canHeal() ?
        # Team.derelict : team, x, y) || controlled() ||
        # logicControlled();`. It calls the no-range overload
        # (`return invalidateTarget(target, team, x, y,
        # Float.MAX_VALUE);`, Units.java:160-162), so the
        # range clause (`range != Float.MAX_VALUE &&
        # !target.within(x, y, range + (target instanceof
        # Sized hb ? hb.hitSize()/2f : 0f))`,
        # Units.java:153) is dead here and the pure function
        # takes NO range param. The four live invalidate
        # clauses (Units.java:151-157) are: target null
        # (`return target == null ||`), same effective team
        # (`(target instanceof Teamc t && t.team() == team)
        # ||`), dead Healthc (`(target instanceof Healthc h
        # && !h.isValid()) ||`), untargetable Unit (`(target
        # instanceof Unit u && !u.targetable(team));`). The
        # effective team is Team.derelict (id 0, Team.java:33)
        # when canHeal() (`return targetHealing && hasAmmo()
        # && peekAmmo().collidesTeam && peekAmmo().heals();`,
        # Turret.java:635-637) and the turret team otherwise;
        # the resolution happens at the driver/test, NOT in
        # the pure function, which takes the resolved bool
        # target_same_team_effective. targetHealing defaults
        # false (Turret.java:95) and duo never sets it
        # (Blocks.java:3257-3324), so for duo the effective
        # team is always the turret team. controlled() is
        # `unit.isPlayer()` (Turret.java:441-443) and
        # logicControlled() is `logicControlTime > 0`
        # (Turret.java:445-447); either rescues the verdict
        # even when the target is null, because Java's `||`
        # short-circuits after the invalidate term. The
        # result is a 2-key dict: `valid` (the verdict) and
        # `target_cleared` (= !valid, what updateTile does at
        # Turret.java:491, `if(!validateTarget()) target =
        # null;`). findTarget (Turret.java:651-662) is NOT
        # this slice -- it needs the live entity scan and
        # waits for its own slice, same as the
        # suppression/targets live list.
        self.assertIn('static func source_item_turret_validate_target_state(target_is_null: bool, target_same_team_effective: bool, target_health_valid: bool, target_unit_targetable: bool, controlled: bool, logic_controlled: bool) -> Dictionary:', item_turret)
        self.assertIn('var invalidate: bool = target_is_null or target_same_team_effective or not target_health_valid or not target_unit_targetable', item_turret)
        self.assertIn('var valid: bool = not invalidate or controlled or logic_controlled', item_turret)
        self.assertIn('return {"valid": valid, "target_cleared": not valid}', item_turret)
        self.assertIn('return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();', item_turret)
        self.assertIn('return target == null ||', item_turret)
        self.assertIn('(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||', item_turret)
        self.assertIn('(target instanceof Teamc t && t.team() == team) ||', item_turret)
        self.assertIn('(target instanceof Healthc h && !h.isValid()) ||', item_turret)
        self.assertIn('(target instanceof Unit u && !u.targetable(team));', item_turret)
        self.assertIn('return invalidateTarget(target, team, x, y, Float.MAX_VALUE);', item_turret)
        self.assertIn('return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();', item_turret)
        self.assertIn('public boolean targetHealing = false;', item_turret)
        self.assertIn('derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),', item_turret)
        self.assertIn('public boolean controlled(){', item_turret)
        self.assertIn('return unit.isPlayer();', item_turret)
        self.assertIn('public boolean logicControlled(){', item_turret)
        self.assertIn('return logicControlTime > 0;', item_turret)
        self.assertIn('if(!validateTarget()) target = null;', item_turret)
        self.assertIn('if(validateTarget()){', item_turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), at the head of the duo
        # branch before the N2250 aim/shoot call: it calls the
        # new pure function with the frame target bools (the
        # frame target dict carries only x/y/vx/vy/hit_size, so
        # the team/health/targetable/controlled bools are
        # stamped in from the frame with vacuous defaults --
        # health_valid / unit_targetable default true, same
        # team / controlled / logic_controlled default false),
        # clears frame["target"] and frame["has_target"] when
        # the verdict is invalid, and feeds the verdict into
        # the aim/shoot target_valid arg.
        driver = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('source_item_turret_build_state.source_item_turret_validate_target_state(', driver)
        self.assertIn('frame.get("target", null) == null', driver)
        self.assertIn('bool(frame.get("target_same_team_effective", false))', driver)
        self.assertIn('bool(frame.get("target_health_valid", true))', driver)
        self.assertIn('bool(frame.get("target_unit_targetable", true))', driver)
        self.assertIn('bool(frame.get("controlled", false))', driver)
        self.assertIn('bool(frame.get("logic_controlled", false))', driver)
        self.assertIn('if not bool(validate.get("valid", true)):', driver)
        self.assertIn('frame["target"] = null', driver)
        self.assertIn('frame["has_target"] = false', driver)
        self.assertIn('validate.get("valid", false)', driver)
        # The proof's keys drive validateTarget through the
        # real driver (a null target is invalid / a same-team
        # target is invalid / a dead Healthc target is
        # invalid / an untargetable Unit is invalid / a
        # controlled build keeps even a null target / a
        # logic-controlled build keeps even a null target / a
        # healthy enemy target is valid / the driver clears
        # an invalid target from the frame). There are no
        # findTarget keys: acquisition waits for its own
        # slice.
        proof = ITEM_TURRET_VALIDATE_TARGET_PROOF.read_text(encoding='utf-8')
        for key in [
            'validate_null_target_invalid',
            'validate_same_team_invalid',
            'validate_dead_target_invalid',
            'validate_untargetable_unit_invalid',
            'validate_controlled_saves_invalid_target',
            'validate_logic_controlled_saves_invalid_target',
            'validate_healthy_enemy_valid',
            'validate_driver_clears_invalid_target',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_item_turret_validate_target(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemTurretValidateTargetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_TURRET_VALIDATE_TARGET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'validate_null_target_invalid',
            'validate_same_team_invalid',
            'validate_dead_target_invalid',
            'validate_untargetable_unit_invalid',
            'validate_controlled_saves_invalid_target',
            'validate_logic_controlled_saves_invalid_target',
            'validate_healthy_enemy_valid',
            'validate_driver_clears_invalid_target',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
