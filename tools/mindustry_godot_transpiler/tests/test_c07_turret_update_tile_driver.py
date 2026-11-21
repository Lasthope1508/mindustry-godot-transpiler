import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_UPDATE_TILE_DRIVER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretUpdateTileDriverProof.gd'


class C07TurretUpdateTileDriverTests(unittest.TestCase):
    def test_c07_turret_update_tile_driver_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2397']['godot_owner'], 'SourceTurretBuildState.source_turret_update_tile_driver_state')
        # TurretBuild.updateTile() remaining driver-tick legs
        # (Turret.java:494-499, :548-557, :566-608): player ammo
        # sync (`if(unit.isPlayer()){ //there's no reason to
        # update this when a player isn't controlling it` /
        # `unit.ammo(getAmmoFraction());`), soundLoop update
        # (`soundLoop.update(x, y, shouldActiveSound(),
        # activeSoundVolume());`), reload gate
        # (`if(reloadWhileCharging || !charging()){` /
        # `updateReload();`), fog range
        # (`if(state.rules.fog){` / `float newRange =
        # hasAmmo() ? peekAmmo().rangeChange : 0f;` /
        # `if(newRange != lastRangeChange){` /
        # `lastRangeChange = newRange;` /
        # `fogControl.forceUpdate(team, this);`) and the
        # hasAmmo targeting block (`if(hasAmmo()){` /
        # `if(Float.isNaN(reloadCounter)) reloadCounter =
        # 0;` / `if(timer(timerTarget, target != null ?
        # newTargetInterval : targetInterval)){` /
        # `findTarget();` / `boolean canShoot;` /
        # `if(controlled()){ //player behavior` /
        # `targetPos.set(unit.aimX(), unit.aimY());` /
        # `canShoot = unit.isShooting();` /
        # `}else if(logicControlled()){ //logic behavior`
        # / `canShoot = logicShooting;` /
        # `}else{ //default AI behavior` /
        # `if(!controlled()){` / `unit.aimX(targetPos.x);`
        # / `unit.aimY(targetPos.y);` /
        # `if(alwaysShooting){`) on `public class
        # TurretBuild extends ReloadTurretBuild implements
        # ControlBlock{` (Turret.java:277), inside
        # `public void updateTile(){`
        # (Turret.java:490). The guard lines are
        # registered with their Java trailing comments,
        # so they are distinct from the same bare text
        # owned elsewhere (`if(unit.isPlayer()){` alone
        # is N1899 BuildingComp.handleUnitPayload;
        # `}else{` alone is owned by sixteen slices).
        # NOT registered: `updateCooling();` (N2241),
        # `wasShooting = true;` (N2362),
        # `updateShooting();` (remote N2269),
        # `if(soundLoop != null){` (N2350). Call-sites
        # already owned arrive as Callables/params, never
        # re-registered: updateReload/updateCooling
        # (N2241), findTarget (N2316),
        # validateTarget/charging/controlled/logicControlled
        # (N2324/N2297), getAmmoFraction (N2348/N2355),
        # shouldActiveSound/activeSoundVolume (N2346).
        # Fourteen new result symbols.
        self.assertEqual(
            ledger['N2397']['source_symbols'],
            [
                'source_turret_update_tile_driver_state_result.unit_ammo_fraction',
                'source_turret_update_tile_driver_state_result.sound_loop_update',
                'source_turret_update_tile_driver_state_result.reload_gate_open',
                'source_turret_update_tile_driver_state_result.update_reload_called',
                'source_turret_update_tile_driver_state_result.last_range_change',
                'source_turret_update_tile_driver_state_result.fog_range_changed',
                'source_turret_update_tile_driver_state_result.fog_force_update_called',
                'source_turret_update_tile_driver_state_result.reload_counter',
                'source_turret_update_tile_driver_state_result.find_target_called',
                'source_turret_update_tile_driver_state_result.target_pos',
                'source_turret_update_tile_driver_state_result.can_shoot',
                'source_turret_update_tile_driver_state_result.unit_aim_x',
                'source_turret_update_tile_driver_state_result.unit_aim_y',
                'source_turret_update_tile_driver_state_result.always_shooting_gate',
            ],
        )
        for name in ledger['N2397']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2397']['runtime_proof'], '/root/C07TurretUpdateTileDriverProof')
        self.assertEqual(
            ledger['N2397']['tests'],
            [
                'test_c07_turret_update_tile_driver_registration',
                'test_all_c07_turret_update_tile_driver_input_evidence_is_exact',
                'test_turret_update_tile_driver_state',
                'test_reference_graph_and_actual_c07_turret_update_tile_driver',
            ],
        )
        self.assertTrue(ledger['N2397']['deferred_exprs'])
        self.assertIn(
            'Turret updateTile driver N2397 Windows Godot proof',
            ' '.join(ledger['N2397']['deferred_exprs']),
        )

    def test_all_c07_turret_update_tile_driver_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2397']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2397']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_update_tile_driver_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() driver-tick legs
        # (Turret.java:494-499, :548-557, :565-608). The
        # player branch sets targetPos from the unit aim
        # and reads canShoot from unit.isShooting(); the
        # logic branch reads canShoot from logicShooting;
        # the default-AI branch (targetPosition/within)
        # is remote N2250, so can_shoot stays null there.
        # The aim write runs exactly when !controlled(),
        # after the branch, on the (possibly updated)
        # targetPos. The fog leg only fires under
        # state.rules.fog and only force-updates when the
        # range actually changed. updateReload() is a
        # call-site (body N2241): the frame records that
        # it was called when the gate is open.
        # updateShooting() (remote N2269) and wasShooting
        # (N2362) are NOT registered: only the
        # alwaysShooting gate is recorded.
        self.assertIn('static func source_turret_update_tile_driver_state(frame: Dictionary, is_player: bool, ammo_fraction: float, has_sound_loop: bool, x: float, y: float, should_active_sound: bool, active_sound_volume: float, reload_while_charging: bool, charging: bool, fog: bool, has_ammo: bool, ammo_range_change: float, last_range_change: float, reload_counter: float, timer_target_ready: bool, validate_target: bool, controlled: bool, logic_controlled: bool, target_pos: Vector2, unit_aim_x: float, unit_aim_y: float, unit_is_shooting: bool, logic_shooting: bool, always_shooting: bool) -> Dictionary:', turret)
        self.assertIn('return {"unit_ammo_fraction": unit_ammo_fraction, "sound_loop_update": sound_loop_update, "reload_gate_open": reload_gate_open, "update_reload_called": update_reload_called, "last_range_change": new_last_range_change, "fog_range_changed": fog_range_changed, "fog_force_update_called": fog_force_update_called, "reload_counter": new_reload_counter, "find_target_called": find_target_called, "target_pos": new_target_pos, "can_shoot": can_shoot, "unit_aim_x": new_unit_aim_x, "unit_aim_y": new_unit_aim_y, "always_shooting_gate": always_shooting_gate}', turret)
        for expr in [
            "if(unit.isPlayer()){ //there's no reason to update this when a player isn't controlling it",
            'unit.ammo(getAmmoFraction());',
            'soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());',
            'if(reloadWhileCharging || !charging()){',
            'updateReload();',
            'if(state.rules.fog){',
            'float newRange = hasAmmo() ? peekAmmo().rangeChange : 0f;',
            'if(newRange != lastRangeChange){',
            'lastRangeChange = newRange;',
            'fogControl.forceUpdate(team, this);',
            'if(hasAmmo()){',
            'if(Float.isNaN(reloadCounter)) reloadCounter = 0;',
            'if(timer(timerTarget, target != null ? newTargetInterval : targetInterval)){',
            'findTarget();',
            'boolean canShoot;',
            'if(controlled()){ //player behavior',
            'targetPos.set(unit.aimX(), unit.aimY());',
            'canShoot = unit.isShooting();',
            '}else if(logicControlled()){ //logic behavior',
            'canShoot = logicShooting;',
            '}else{ //default AI behavior',
            'if(!controlled()){',
            'unit.aimX(targetPos.x);',
            'unit.aimY(targetPos.y);',
            'if(alwaysShooting){',
            'public float getAmmoFraction(){',
            'public boolean shouldActiveSound(){',
            'public float activeSoundVolume(){',
            'public boolean reloadWhileCharging = true;',
            'public boolean charging(){',
            'public boolean alwaysShooting = false;',
            'public boolean logicShooting = false;',
            'public Vec2 targetPos = new Vec2();',
            'public boolean controlled(){',
            'public boolean logicControlled(){',
            'public void updateTile(){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: player ammo sync applies
        # the fraction, non-player applies nothing; the
        # soundLoop update carries x/y/active/volume, an
        # absent loop carries null; the reload gate opens
        # while charging only when reloadWhileCharging,
        # and opens whenever not charging; fog changes the
        # range and force-updates only on a real change,
        # uses 0 range with no ammo, and does nothing
        # with fog off; a NaN reloadCounter resets to 0;
        # the target timer fires findTarget only when
        # ready; the player branch aims from the unit and
        # reads isShooting, the logic branch reads
        # logicShooting, the default-AI branch leaves
        # can_shoot null; the aim write follows
        # !controlled(); the alwaysShooting gate fires
        # only with ammo; with no ammo the targeting
        # block is skipped entirely.
        proof = TURRET_UPDATE_TILE_DRIVER_PROOF.read_text(encoding='utf-8')
        for key in [
            'ammo_sync_player',
            'ammo_sync_not_player',
            'sound_loop_update',
            'sound_loop_absent',
            'reload_gate_open_charging_allowed',
            'reload_gate_open_not_charging',
            'reload_gate_closed',
            'fog_range_changed',
            'fog_range_unchanged',
            'fog_no_ammo_zero_range',
            'fog_disabled',
            'reload_counter_nan_reset',
            'find_target_timer_ready',
            'find_target_timer_not_ready',
            'can_shoot_player_branch',
            'can_shoot_logic_branch',
            'can_shoot_default_ai_null',
            'always_shooting_gate',
            'no_ammo_skips_targeting',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_update_tile_driver(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretUpdateTileDriverProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_UPDATE_TILE_DRIVER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ammo_sync_player',
            'ammo_sync_not_player',
            'sound_loop_update',
            'sound_loop_absent',
            'reload_gate_open_charging_allowed',
            'reload_gate_open_not_charging',
            'reload_gate_closed',
            'fog_range_changed',
            'fog_range_unchanged',
            'fog_no_ammo_zero_range',
            'fog_disabled',
            'reload_counter_nan_reset',
            'find_target_timer_ready',
            'find_target_timer_not_ready',
            'can_shoot_player_branch',
            'can_shoot_logic_branch',
            'can_shoot_default_ai_null',
            'always_shooting_gate',
            'no_ammo_skips_targeting',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
