import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_IS_ACTIVE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretIsActiveProof.gd'


class C07TurretIsActiveTests(unittest.TestCase):
    def test_c07_turret_is_active_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2279']['godot_owner'], 'SourceTurretBuildState.source_turret_is_active_state')
        # TurretBuild.isActive() (Turret.java:449-451):
        # `public boolean isActive(){`
        # `return (target != null || wasShooting) && enabled && activationTimer <= 0;`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). The three inputs are TurretBuild /
        # BaseTurretBuild / BuildingComp fields: target
        # (`public @Nullable Posc target;`, Turret.java:289),
        # wasShooting (`public boolean wasShooting, isShooting;`,
        # Turret.java:292), enabled (`transient boolean enabled
        # = true;`, BuildingComp.java:77), activationTimer
        # (`public float activationTimer = 0;`,
        # BaseTurret.java:115, set to activationTime on placed(),
        # BaseTurret.java:120 `activationTimer =
        # activationTime;`, against `public float activationTime
        # = 0f;`, BaseTurret.java:27). RED decisions (resolved
        # at RED, recorded in the register docstring): (1) One
        # pure function -- target arrives as the explicit bool
        # target_is_null (the invalidateTarget :488 precedent),
        # wasShooting arrives as the explicit bool is_shooting
        # (the should_consume :164 / sense :267 /
        # update_tile_warmup :384 precedent -- the param is
        # named is_shooting per the family convention, but for
        # isActive() it carries wasShooting, the previous
        # tick's shooting flag, set in updateTile :517/:600/:608),
        # activationTimer arrives as the explicit float
        # activation_timer (the frame tracks no activation
        # timer key -- _initial_frame() returns {} and the
        # file has no activation_timer key), and enabled is
        # read from the frame (the tick frame stamps
        # frame["enabled"], default true, matching the Java
        # field default). (2) The comparison is `<= 0`: a
        # timer of exactly 0 is active, matching Java exactly.
        # (3) NO driver tick line: isActive() is a predicate
        # the tick driver reads, not a tick write of its own --
        # wiring it into the driver waits for its own slice.
        # (4) isActive() has no caller inside Turret.java; its
        # live callers (sound/status paths) are their own
        # slices. One new result symbol:
        # is_active.
        self.assertEqual(
            ledger['N2279']['source_symbols'],
            [
                'source_turret_is_active_state_result.is_active',
            ],
        )
        for name in ledger['N2279']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2279']['runtime_proof'], '/root/C07TurretIsActiveProof')
        self.assertEqual(
            ledger['N2279']['tests'],
            [
                'test_c07_turret_is_active_registration',
                'test_all_c07_turret_is_active_input_evidence_is_exact',
                'test_turret_is_active_state',
                'test_reference_graph_and_actual_c07_turret_is_active',
            ],
        )
        self.assertTrue(ledger['N2279']['deferred_exprs'])

    def test_all_c07_turret_is_active_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2279']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2279']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_is_active_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.isActive() (Turret.java:449-451):
        # `public boolean isActive(){`
        # `return (target != null || wasShooting) && enabled && activationTimer <= 0;`
        # The target arrives as target_is_null, wasShooting as
        # is_shooting, activationTimer as activation_timer, and
        # enabled is read from the frame (default true). The
        # comparison is `<= 0`: a timer of exactly 0 is active.
        # NO driver tick line: isActive() is a predicate the
        # tick driver reads, not a tick write of its own.
        self.assertIn('static func source_turret_is_active_state(frame: Dictionary, target_is_null: bool, is_shooting: bool, activation_timer: float) -> Dictionary:', turret)
        self.assertIn('return {"is_active": (not target_is_null or is_shooting) and bool(frame.get("enabled", true)) and activation_timer <= 0}', turret)
        for expr in [
            'public boolean isActive(){',
            'return (target != null || wasShooting) && enabled && activationTimer <= 0;',
            'public @Nullable Posc target;',
            'public boolean wasShooting, isShooting;',
            'transient boolean enabled = true;',
            'public float activationTimer = 0;',
            'public float activationTime = 0f;',
            'activationTimer = activationTime;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public class BaseTurret extends Block{',
            'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: isActive is a pure
        # predicate over four inputs): active with a target
        # (frame default enabled true, timer 0) / active while
        # shooting with no target / inactive with no target and
        # not shooting / inactive when disabled even with a
        # target / inactive while the activation timer is
        # positive / active at an activation timer of exactly 0
        # / active at a negative activation timer / the result
        # carries only the one is_active key.
        proof = TURRET_IS_ACTIVE_PROOF.read_text(encoding='utf-8')
        for key in [
            'active_with_target',
            'active_while_shooting',
            'inactive_no_target_not_shooting',
            'inactive_when_disabled',
            'inactive_while_activation_timer_positive',
            'active_at_activation_timer_zero',
            'active_at_activation_timer_negative',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_is_active(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretIsActiveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_IS_ACTIVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'active_with_target',
            'active_while_shooting',
            'inactive_no_target_not_shooting',
            'inactive_when_disabled',
            'inactive_while_activation_timer_positive',
            'active_at_activation_timer_zero',
            'active_at_activation_timer_negative',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
