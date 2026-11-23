import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_MICRO_ACCESSORS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretMicroAccessorsProof.gd'


class C07TurretMicroAccessorsTests(unittest.TestCase):
    def test_c07_turret_micro_accessors_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2297']['godot_owner'], 'SourceTurretBuildState.source_turret_warmup_state')
        # Four read accessors on TurretBuild (Turret.java:277):
        # `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # warmup() (Turret.java:354-356, `return shootWarmup;`),
        # drawrot() (Turret.java:359-361, `return rotation - 90;`),
        # canControl() (Turret.java:376-378, `return
        # playerControllable;`), logicControlled()
        # (Turret.java:445-447, `return logicControlTime > 0;`).
        # Four pure functions, one per accessor, each with the
        # family-convention frame first arg plus ONE explicit
        # param (the N2311/N2261/N2340 precedent): shoot_warmup
        # is advanced by the updateTile warmup leg (N2308), NOT
        # here; rotation is the RotComp float aim angle
        # (RotComp.java:8), NOT the Building int rotation 0-3
        # (BuildingComp.java:69), bound by the caller from the
        # frame bound by source_turret_bind_frame_state;
        # player_controllable is the block-level Turret field
        # (Turret.java:97, default true); logic_control_time
        # is the TurretBuild field (Turret.java:284, default
        # -1). NO driver tick line for any of the four: read
        # accessors their callers read, not per-tick writes
        # (the N2249/N2221 precedent). controlled()
        # (Turret.java:441-443) is EXPLICITLY OUT OF SCOPE.
        # Four new result symbols: warmup, drawrot,
        # can_control, logic_controlled.
        self.assertEqual(
            ledger['N2297']['source_symbols'],
            [
                'source_turret_warmup_state_result.warmup',
                'source_turret_drawrot_state_result.drawrot',
                'source_turret_can_control_state_result.can_control',
                'source_turret_logic_controlled_state_result.logic_controlled',
            ],
        )
        for name in ledger['N2297']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2297']['runtime_proof'], '/root/C07TurretMicroAccessorsProof')
        self.assertEqual(
            ledger['N2297']['tests'],
            [
                'test_c07_turret_micro_accessors_registration',
                'test_all_c07_turret_micro_accessors_input_evidence_is_exact',
                'test_turret_micro_accessors_state',
                'test_reference_graph_and_actual_c07_turret_micro_accessors',
            ],
        )
        self.assertTrue(ledger['N2297']['deferred_exprs'])

    def test_all_c07_turret_micro_accessors_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2297']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/RotComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2297']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_micro_accessors_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.warmup() (Turret.java:354-356):
        # `public float warmup(){`
        # `return shootWarmup;`
        # `}`
        # TurretBuild.drawrot() (Turret.java:359-361):
        # `public float drawrot(){`
        # `return rotation - 90;`
        # `}`
        # -- rotation is the RotComp float aim angle
        # (RotComp.java:8, `@SyncField(false) @SyncLocal float
        # rotation;`), NOT the Building int rotation 0-3
        # (BuildingComp.java:69, `transient int rotation;`).
        # TurretBuild.canControl() (Turret.java:376-378):
        # `public boolean canControl(){`
        # `return playerControllable;`
        # `}`
        # -- playerControllable is the block-level Turret field
        # (Turret.java:97, `public boolean playerControllable =
        # true;`). TurretBuild.logicControlled()
        # (Turret.java:445-447):
        # `public boolean logicControlled(){`
        # `return logicControlTime > 0;`
        # `}`
        # -- logicControlTime is the TurretBuild field
        # (Turret.java:284, `public float curRecoil, heat,
        # logicControlTime = -1;`), set to logicControlCooldown
        # (`public final static float logicControlCooldown = 60
        # * 2;`, Turret.java:38) by control() while logic holds
        # the turret. controlled() (Turret.java:441-443) is
        # EXPLICITLY OUT OF SCOPE for this slice.
        self.assertIn('static func source_turret_warmup_state(frame: Dictionary, shoot_warmup: float) -> Dictionary:', turret)
        self.assertIn('static func source_turret_drawrot_state(frame: Dictionary, rotation: float) -> Dictionary:', turret)
        self.assertIn('static func source_turret_can_control_state(frame: Dictionary, player_controllable: bool) -> Dictionary:', turret)
        self.assertIn('static func source_turret_logic_controlled_state(frame: Dictionary, logic_control_time: float) -> Dictionary:', turret)
        self.assertIn('return {"warmup": shoot_warmup}', turret)
        self.assertIn('return {"drawrot": rotation - 90.0}', turret)
        self.assertIn('return {"can_control": player_controllable}', turret)
        self.assertIn('return {"logic_controlled": logic_control_time > 0.0}', turret)
        for expr in [
            'public float warmup(){',
            'return shootWarmup;',
            'public float shootWarmup, charge, warmupHold = 0f;',
            'public float drawrot(){',
            'return rotation - 90;',
            '@SyncField(false) @SyncLocal float rotation;',
            'transient int rotation;',
            'public boolean canControl(){',
            'return playerControllable;',
            'public boolean playerControllable = true;',
            'public boolean logicControlled(){',
            'return logicControlTime > 0;',
            'public float curRecoil, heat, logicControlTime = -1;',
            'public final static float logicControlCooldown = 60 * 2;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick: all four are pure
        # accessors over explicit params): warmup returns
        # shoot_warmup as-is at 0.75 / 0.0 / 1.0 / drawrot
        # subtracts 90 at aim 180 / 0 / 45 / canControl
        # passes the def through true and false /
        # logicControlled is true at timer 120, false at the
        # -1 default and at 0 / each result carries only its
        # one key.
        proof = TURRET_MICRO_ACCESSORS_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_returns_shoot_warmup',
            'warmup_zero',
            'warmup_full',
            'drawrot_ninety',
            'drawrot_zero',
            'drawrot_negative',
            'can_control_true',
            'can_control_false',
            'logic_controlled_positive',
            'logic_controlled_default',
            'logic_controlled_zero',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_micro_accessors(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretMicroAccessorsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_MICRO_ACCESSORS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_returns_shoot_warmup',
            'warmup_zero',
            'warmup_full',
            'drawrot_ninety',
            'drawrot_zero',
            'drawrot_negative',
            'can_control_true',
            'can_control_false',
            'logic_controlled_positive',
            'logic_controlled_default',
            'logic_controlled_zero',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
