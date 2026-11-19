import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretStatusProof.gd'


class C07TurretStatusTests(unittest.TestCase):
    def test_c07_turret_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2285']['godot_owner'], 'SourceTurretBuildState.source_turret_status_state')
        # TurretBuild.status() (Turret.java:369-374):
        # `public BlockStatus status(){`
        # `if(enabled && !hasAmmo()) return BlockStatus.noInput;`
        # ``
        # `return super.status();`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). The super chain has two layers:
        # BaseTurretBuild.status() (BaseTurret.java:143-145,
        # `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`)
        # over BuildingComp.status() (BuildingComp.java:632-646),
        # already live as N1888 PortGame.source_building_status_state.
        # enabled arrives from the tick frame (stamped by
        # source_turret_tick_frame_state, absent reads true); has_ammo
        # arrives as an explicit bool carrying hasAmmo()
        # (Turret.java:698-712, ammo-swap side effect + canConsume +
        # cheating -- NOT ported here, the N2311/N2261 precedent);
        # activation_timer arrives as an explicit float carrying
        # BaseTurretBuild.activationTimer (BaseTurret.java:115,
        # default 0); building_status arrives as an explicit String
        # carrying the live N1888 result. NO driver line: status()
        # is a read accessor its callers read, not a per-tick write
        # (the N2249/N2221 precedent). One new result symbol:
        # status.
        self.assertEqual(
            ledger['N2285']['source_symbols'],
            [
                'source_turret_status_state_result.status',
            ],
        )
        for name in ledger['N2285']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2285']['runtime_proof'], '/root/C07TurretStatusProof')
        self.assertEqual(
            ledger['N2285']['tests'],
            [
                'test_c07_turret_status_registration',
                'test_all_c07_turret_status_input_evidence_is_exact',
                'test_turret_status_state',
                'test_reference_graph_and_actual_c07_turret_status',
            ],
        )
        self.assertTrue(ledger['N2285']['deferred_exprs'])

    def test_all_c07_turret_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2285']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/meta/BlockStatus.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2285']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_status_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.status() (Turret.java:369-374):
        # `public BlockStatus status(){`
        # `if(enabled && !hasAmmo()) return BlockStatus.noInput;`
        # ``
        # `return super.status();`
        # `}`
        # BaseTurretBuild.status() (BaseTurret.java:143-145):
        # `public BlockStatus status() {`
        # `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`
        # `}`
        # BuildingComp.status() (BuildingComp.java:632-646) is the
        # live N1888 helper; its result arrives as building_status.
        # enabled && !has_ammo returns noInput first; activation_timer
        # <= 0 returns building_status; otherwise inactive. The first
        # leg needs BOTH conditions: a disabled turret with no ammo
        # falls through to super.status(), which itself returns
        # logicDisable for !enabled -- so the function adds no
        # enabled check of its own in the super leg.
        self.assertIn('static func source_turret_status_state(frame: Dictionary, has_ammo: bool, activation_timer: float, building_status: String) -> Dictionary:', turret)
        self.assertIn('return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}', turret)
        self.assertIn('return {"status": building_status}', turret)
        self.assertIn('return {"status": SOURCE_TURRET_STATUS_INACTIVE}', turret)
        for expr in [
            'public BlockStatus status(){',
            'if(enabled && !hasAmmo()) return BlockStatus.noInput;',
            'return super.status();',
            'public boolean hasAmmo(){',
            'public float activationTimer = 0;',
            'public BlockStatus status() {',
            'return (activationTimer <= 0)? super.status() : BlockStatus.inactive;',
            'if(!enabled){',
            'return BlockStatus.logicDisable;',
            'if(!shouldConsume()){',
            'return BlockStatus.noOutput;',
            'if(efficiency <= 0 || !productionValid()){',
            'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;',
            'transient boolean enabled = true;',
            'inactive(Color.lightGray);',
            'noInput(Pal.remove),',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public class BaseTurret extends Block{',
            'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with synthetic
        # frames (no live tick: status is a pure accessor over the
        # frame's enabled plus three explicit params): enabled with
        # no ammo returns noInput even while activating / the
        # building leg passes active through at timer zero / the
        # building leg passes noInput through / a disabled turret
        # with ammo falls through to the building leg's logicDisable
        # / a positive timer returns inactive even with an active
        # building leg / a disabled turret with no ammo and a
        # positive timer still returns inactive (the first leg needs
        # enabled, the BaseTurret leg does not check it) / a
        # disabled turret with no ammo at timer zero falls through
        # to the building leg's logicDisable / a negative timer
        # still takes the building leg (<= 0) / the result carries
        # only the one status key.
        proof = TURRET_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'status_no_input_enabled_no_ammo',
            'status_building_active',
            'status_building_no_input',
            'status_building_logic_disable',
            'status_inactive',
            'status_inactive_disabled_no_ammo',
            'status_disabled_no_ammo_falls_to_building',
            'status_negative_timer_building_leg',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'status_no_input_enabled_no_ammo',
            'status_building_active',
            'status_building_no_input',
            'status_building_logic_disable',
            'status_inactive',
            'status_inactive_disabled_no_ammo',
            'status_disabled_no_ammo_falls_to_building',
            'status_negative_timer_building_leg',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
