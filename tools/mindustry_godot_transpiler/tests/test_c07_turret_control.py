import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_CONTROL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretControlProof.gd'


class C07TurretControlTests(unittest.TestCase):
    def test_c07_turret_control_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2264']['godot_owner'], 'SourceTurretBuildState.source_turret_control_state')
        # TurretBuild.control() arms the logic-control timer from
        # a logic shoot / shootp instruction, outside updateTile():
        # `if(type == LAccess.shoot && !unit.isPlayer()){`
        # `targetPos.set(World.unconv((float)p1), World.unconv((float)p2));`
        # `logicControlTime = logicControlCooldown;`
        # `logicShooting = !Mathf.zero(p3);`
        # (Turret.java:382-386) and
        # `if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){`
        # `logicControlTime = logicControlCooldown;`
        # `logicShooting = !Mathf.zero(p2);`
        # `if(p1 instanceof Posc pos){`
        # `targetPosition(pos);`
        # (Turret.java:393-400). The cooldown is
        # `public final static float logicControlCooldown = 60 * 2;`
        # (:38 -- 120 ticks of logic control), the timer field is
        # `public float curRecoil, heat, logicControlTime = -1;`
        # (:284), the flag field is
        # `public boolean logicShooting = false;` (:287) and the
        # target field is `public Vec2 targetPos = new Vec2();`
        # (:289). The reader is `logicControlled()`
        # (`return logicControlTime > 0;`, :445-447), so the arm
        # is observable through the isShooting gate (:492) on the
        # very next tick -- the N2261 decay tick only ever reads
        # the frame value, it never arms it. This slice is the
        # EVENT arming, not a per-tick driver tick: control() is
        # called by the logic executor, and no logic executor
        # exists in the driver yet, so there is no driver tick
        # (the N2248 precedent) -- the proof calls the pure
        # function directly. Four new result symbols:
        # logic_control_time, logic_shooting, target_pos,
        # target_position_deferred. The shootp targetPosition(pos)
        # call (:398) waits for its own slice: it needs hasAmmo /
        # peekAmmo plus Predict.intercept (:453-471).
        self.assertEqual(
            ledger['N2264']['source_symbols'],
            [
                'source_turret_control_state_result.logic_control_time',
                'source_turret_control_state_result.logic_shooting',
                'source_turret_control_state_result.target_pos',
                'source_turret_control_state_result.target_position_deferred',
            ],
        )
        for name in ledger['N2264']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_control_state_result.logic_control_time': 'SourceTurretBuildState.source_turret_control_state',
                    'source_turret_control_state_result.logic_shooting': 'SourceTurretBuildState.source_turret_control_state',
                    'source_turret_control_state_result.target_pos': 'SourceTurretBuildState.source_turret_control_state',
                    'source_turret_control_state_result.target_position_deferred': 'SourceTurretBuildState.source_turret_control_state',
                }[name])
        self.assertEqual(ledger['N2264']['runtime_proof'], '/root/C07TurretControlProof')
        self.assertEqual(
            ledger['N2264']['tests'],
            [
                'test_c07_turret_control_registration',
                'test_all_c07_turret_control_input_evidence_is_exact',
                'test_turret_control_state',
                'test_reference_graph_and_actual_c07_turret_control',
            ],
        )
        self.assertTrue(ledger['N2264']['deferred_exprs'])

    def test_all_c07_turret_control_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2264']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_control_state_result.logic_control_time': 'SourceTurretBuildState.source_turret_control_state',
                    'source_turret_control_state_result.logic_shooting': 'SourceTurretBuildState.source_turret_control_state',
                    'source_turret_control_state_result.target_pos': 'SourceTurretBuildState.source_turret_control_state',
                    'source_turret_control_state_result.target_position_deferred': 'SourceTurretBuildState.source_turret_control_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/core/World.java',
            'core/src/mindustry/Vars.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2264']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_control_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.control() (Turret.java:381-402) arms the
        # logic-control timer from a logic shoot / shootp
        # instruction:
        # `if(type == LAccess.shoot && !unit.isPlayer()){`
        # `targetPos.set(World.unconv((float)p1), World.unconv((float)p2));`
        # `logicControlTime = logicControlCooldown;`
        # `logicShooting = !Mathf.zero(p3);`
        # (:382-386) and
        # `if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){`
        # `logicControlTime = logicControlCooldown;`
        # `logicShooting = !Mathf.zero(p2);`
        # `if(p1 instanceof Posc pos){`
        # `targetPosition(pos);`
        # (:393-400). The cooldown is
        # `public final static float logicControlCooldown = 60 * 2;`
        # (:38 -- 120 ticks), the timer field is
        # `public float curRecoil, heat, logicControlTime = -1;`
        # (:284), the flag field is
        # `public boolean logicShooting = false;` (:287) and the
        # target field is `public Vec2 targetPos = new Vec2();`
        # (:289). World.unconv is
        # `public static float unconv(float coord){`
        # `return coord * tilesize;` (World.java:170-172) with
        # `public static final int tilesize = 8;`
        # (Vars.java:135), so a shoot at tile (10, 20) aims at
        # world (80, 160). Mathf.zero is
        # `public static boolean zero(float value){`
        # `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;`
        # (arc Mathf.java:522-524) with
        # `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
        # (:10), so a shoot flag of 0.0000005 reads zero and a
        # flag of 0.00001 reads shooting. The pure function takes
        # the control type, the three numeric params, the unit
        # player/null flags, the current timer / flag / target
        # pos, the Posc flag and the tilesize, and returns the
        # four keys:
        # `{"logic_control_time": .., "logic_shooting": .., "target_pos": {"x": .., "y": ..}, "target_position_deferred": ..}`.
        # A non-shoot/shootp type changes nothing (the
        # BuildingComp super.control enabled/config cases are
        # their own slices); a player-controlled unit blocks
        # both arms; shootp with a Posc defers targetPosition
        # (needs hasAmmo / peekAmmo + Predict.intercept,
        # :453-471) and leaves targetPos untouched.
        self.assertIn('static func source_turret_control_state(control_type: String, p1: float, p2: float, p3: float, unit_is_player: bool, unit_is_null: bool, logic_control_time: float, logic_shooting: bool, target_pos: Dictionary, target_is_posc: bool, tilesize: float) -> Dictionary:', turret)
        self.assertIn('return {"logic_control_time": logic_control_time, "logic_shooting": logic_shooting, "target_pos": target_pos, "target_position_deferred": target_position_deferred}', turret)
        self.assertIn('if(type == LAccess.shoot && !unit.isPlayer()){', turret)
        self.assertIn('targetPos.set(World.unconv((float)p1), World.unconv((float)p2));', turret)
        self.assertIn('logicControlTime = logicControlCooldown;', turret)
        self.assertIn('logicShooting = !Mathf.zero(p3);', turret)
        self.assertIn('public final static float logicControlCooldown = 60 * 2;', turret)
        self.assertIn('if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){', turret)
        self.assertIn('logicShooting = !Mathf.zero(p2);', turret)
        self.assertIn('if(p1 instanceof Posc pos){', turret)
        self.assertIn('targetPosition(pos);', turret)
        self.assertIn('public float curRecoil, heat, logicControlTime = -1;', turret)
        self.assertIn('public boolean logicShooting = false;', turret)
        self.assertIn('public Vec2 targetPos = new Vec2();', turret)
        self.assertIn('public static float unconv(float coord){', turret)
        self.assertIn('return coord * tilesize;', turret)
        self.assertIn('public static final int tilesize = 8;', turret)
        self.assertIn('return Math.abs(value) <= FLOAT_ROUNDING_ERROR;', turret)
        self.assertIn('public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits', turret)
        # The proof's keys drive the arming through direct
        # pure-function calls (control() is event-driven -- no
        # driver tick, the N2248 precedent -- so there is no
        # live duo tick to stamp the frame): shoot arms the
        # timer to 120 / shoot sets the world target pos /
        # shoot sets logicShooting from the p3 flag / the flag
        # reads zero at the 1e-6 epsilon / shoot is blocked
        # while a player controls the unit / shootp arms the
        # timer to 120 / shootp sets logicShooting from the p2
        # flag / shootp with a Posc defers targetPosition and
        # leaves targetPos untouched / shootp is blocked while
        # a player controls the unit / a non-shoot/shootp type
        # changes nothing.
        proof = TURRET_CONTROL_PROOF.read_text(encoding='utf-8')
        for key in [
            'control_shoot_arms_timer',
            'control_shoot_sets_target_pos',
            'control_shoot_sets_logic_shooting',
            'control_shoot_flag_zero_epsilon',
            'control_shoot_blocked_when_player',
            'control_shootp_arms_timer',
            'control_shootp_sets_logic_shooting',
            'control_shootp_defers_target_position',
            'control_shootp_blocked_when_player',
            'control_other_type_noop',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_control(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretControlProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CONTROL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'control_shoot_arms_timer',
            'control_shoot_sets_target_pos',
            'control_shoot_sets_logic_shooting',
            'control_shoot_flag_zero_epsilon',
            'control_shoot_blocked_when_player',
            'control_shootp_arms_timer',
            'control_shootp_sets_logic_shooting',
            'control_shootp_defers_target_position',
            'control_shootp_blocked_when_player',
            'control_other_type_noop',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
