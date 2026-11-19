import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SUPER_CONTROL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretSuperControlProof.gd'


class C07TurretSuperControlTests(unittest.TestCase):
    def test_c07_turret_super_control_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2267']['godot_owner'], 'SourceTurretBuildState.source_turret_super_control_state')
        # TurretBuild.control() ends both overloads with a
        # super.control() call (Turret.java:388/:402,
        # `super.control(type, p1, p2, p3, p4);`), so the
        # BuildingComp cases run for every logic control
        # instruction the turret does not handle itself. The
        # double overload (BuildingComp.java:2150-2155) only
        # handles enabled:
        # `public void control(LAccess type, double p1, double p2, double p3, double p4){`
        # `if(type == LAccess.enabled){`
        # `enabled = !Mathf.zero((float)p1);`
        # `}`
        # `}` -- the field is `transient boolean enabled =
        # true;` (:77), the flag the shouldConsume /
        # efficiency folds read (frame["enabled"], default
        # true). The Object overload (:2157-2162) only
        # handles config:
        # `public void control(LAccess type, Object p1, double p2, double p3, double p4){`
        # `//don't execute configure instructions that copy logic building configures; this can cause extreme lag`
        # `if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){`
        # `//change config only if it's new`
        # `configured(null, p1);`
        # `}`
        # `}`. LAccess pins the two types:
        # `enabled("to"), //"to" is standard for single
        # parameter access` (LAccess.java:80) and
        # `config(true, "to"),` (:83) -- enabled takes the
        # double overload, config the Object overload.
        # Mathf.zero is `return Math.abs(value) <=
        # FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524)
        # with `public static final float
        # FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
        # (:10), so a p1 of 0.0000005 reads zero (disabled)
        # and a p1 of 0.00001 reads non-zero (enabled).
        # `logicConfigurable` is `public boolean
        # logicConfigurable = false;` (Block.java:270) and
        # only becomes true in init() (:1463-1466) when some
        # configuration key is an UnlockableContent -- duo
        # registers no configuration at all (no `config(` in
        # ItemTurret.java, Turret.java, ReloadTurret.java or
        # BaseTurret.java), so for duo the config guard never
        # fires and configured() is never called. There is NO
        # driver tick: control() is event-driven (the N2248
        # precedent, N2264/N2266) -- the logic executor does
        # not exist in the driver yet, so the pure function is
        # called directly by the proof. Two new result
        # symbols: enabled, config_applied.
        self.assertEqual(
            ledger['N2267']['source_symbols'],
            [
                'source_turret_super_control_state_result.enabled',
                'source_turret_super_control_state_result.config_applied',
            ],
        )
        for name in ledger['N2267']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_super_control_state_result.enabled': 'SourceTurretBuildState.source_turret_super_control_state',
                    'source_turret_super_control_state_result.config_applied': 'SourceTurretBuildState.source_turret_super_control_state',
                }[name])
        self.assertEqual(ledger['N2267']['runtime_proof'], '/root/C07TurretSuperControlProof')
        self.assertEqual(
            ledger['N2267']['tests'],
            [
                'test_c07_turret_super_control_registration',
                'test_all_c07_turret_super_control_input_evidence_is_exact',
                'test_turret_super_control_state',
                'test_reference_graph_and_actual_c07_turret_super_control',
            ],
        )
        self.assertTrue(ledger['N2267']['deferred_exprs'])

    def test_all_c07_turret_super_control_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2267']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_super_control_state_result.enabled': 'SourceTurretBuildState.source_turret_super_control_state',
                    'source_turret_super_control_state_result.config_applied': 'SourceTurretBuildState.source_turret_super_control_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/world/Block.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2267']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_super_control_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp super.control() (BuildingComp.java:
        # 2150-2162) is what TurretBuild.control() falls
        # through to (Turret.java:388/:402, `super.control
        # (type, p1, p2, p3, p4);`): the double overload
        # (:2150-2155) only handles enabled
        # (`if(type == LAccess.enabled){`
        # `enabled = !Mathf.zero((float)p1);`, :2151-2152)
        # and the Object overload (:2157-2162) only handles
        # config (`if(type == LAccess.config &&
        # block.logicConfigurable && !(p1 instanceof
        # LogicBuild)){` `configured(null, p1);`, :2159-2161
        # -- the lag comment at :2158, the "only if it's new"
        # comment at :2160). The enabled field is
        # `transient boolean enabled = true;` (:77); the
        # config guard reads `public boolean
        # logicConfigurable = false;` (Block.java:270, set
        # true in init() :1463-1466 only when some
        # configuration key is an UnlockableContent -- duo
        # registers none, so false for duo). LAccess pins
        # `enabled("to"), //"to" is standard for single
        # parameter access` (LAccess.java:80) and
        # `config(true, "to"),` (:83). Mathf.zero is
        # `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;`
        # (arc Mathf.java:522-524) with `public static final
        # float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`
        # (:10). The pure function takes the control type,
        # the p1 flag, the current enabled flag, the
        # logic_configurable flag and the LogicBuild flag,
        # and returns the two keys `{"enabled": ..,
        # "config_applied": ..}` -- the config case only
        # reports that Java would call configured(null, p1);
        # the handler dispatch itself waits for its own slice.
        # There is NO driver tick: control() is event-driven
        # (the N2248 precedent, N2264/N2266), the logic
        # executor does not exist in the driver yet.
        self.assertIn('static func source_turret_super_control_state(control_type: String, p1: float, enabled: bool, logic_configurable: bool, p1_is_logic_build: bool) -> Dictionary:', turret)
        self.assertIn('return {"enabled": enabled, "config_applied": config_applied}', turret)
        self.assertIn('public void control(LAccess type, double p1, double p2, double p3, double p4){', turret)
        self.assertIn('if(type == LAccess.enabled){', turret)
        self.assertIn('enabled = !Mathf.zero((float)p1);', turret)
        self.assertIn('public void control(LAccess type, Object p1, double p2, double p3, double p4){', turret)
        self.assertIn("//don't execute configure instructions that copy logic building configures; this can cause extreme lag", turret)
        self.assertIn('if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){', turret)
        self.assertIn("//change config only if it's new", turret)
        self.assertIn('configured(null, p1);', turret)
        self.assertIn('transient boolean enabled = true;', turret)
        self.assertIn('public boolean logicConfigurable = false;', turret)
        self.assertIn('return Math.abs(value) <= FLOAT_ROUNDING_ERROR;', turret)
        self.assertIn('public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits', turret)
        self.assertIn('enabled("to"), //"to" is standard for single parameter access', turret)
        self.assertIn('config(true, "to"),', turret)
        self.assertIn('super.control(type, p1, p2, p3, p4);', turret)
        # The proof's keys drive super.control through the
        # pure function: enabled with p1 0 disables / enabled
        # with p1 1 enables / the flag reads zero at the 1e-6
        # epsilon (0.0000005 disables) / the flag reads
        # non-zero above it (0.00001 enables) / a non-enabled
        # type leaves enabled untouched / config applies when
        # the block is logic-configurable and the arg is not a
        # LogicBuild / config is blocked when the block is not
        # logic-configurable (duo) / config is blocked when
        # the arg is a LogicBuild / the duo live case disables
        # the placed duo and reports no config applied.
        proof = TURRET_SUPER_CONTROL_PROOF.read_text(encoding='utf-8')
        for key in [
            'super_enabled_disables',
            'super_enabled_enables',
            'super_enabled_flag_zero_epsilon',
            'super_enabled_flag_nonzero',
            'super_enabled_other_type_noop',
            'super_config_applies_when_configurable',
            'super_config_blocked_when_not_configurable',
            'super_config_blocked_when_logic_build',
            'super_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_super_control(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretSuperControlProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SUPER_CONTROL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'super_enabled_disables',
            'super_enabled_enables',
            'super_enabled_flag_zero_epsilon',
            'super_enabled_flag_nonzero',
            'super_enabled_other_type_noop',
            'super_config_applies_when_configurable',
            'super_config_blocked_when_not_configurable',
            'super_config_blocked_when_logic_build',
            'super_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
