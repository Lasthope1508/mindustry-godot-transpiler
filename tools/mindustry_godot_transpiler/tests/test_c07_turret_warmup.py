import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_WARMUP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretWarmupProof.gd'


class C07TurretWarmupTests(unittest.TestCase):
    def test_c07_turret_warmup_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2253']['godot_owner'], 'SourceTurretBuildState.source_turret_warmup_state')
        # TurretBuild.updateTile (Turret.java:490-515) advances
        # the warmup before it aims or shoots: `float
        # warmupTarget = (isShooting && canConsume()) ||
        # charging() ? 1f : 0f;` (Turret.java:502), the hold
        # (`if(warmupTarget > 0 && !controlled()){ warmupHold
        # = 1f; }` / `if(warmupHold > 0f){ warmupHold -=
        # Time.delta / warmupMaintainTime; warmupTarget = 1f;
        # }`, :503-509), then the lerp (`if(linearWarmup){`
        # / `shootWarmup = Mathf.approachDelta(shootWarmup,
        # warmupTarget, shootWarmupSpeed * (warmupTarget > 0
        # ? efficiency : 1f));` / `}else{` /
        # `shootWarmup = Mathf.lerpDelta(shootWarmup,
        # warmupTarget, shootWarmupSpeed * (warmupTarget > 0
        # ? efficiency : 1f));`, :511-515). The driver read
        # frame["shoot_warmup"] (SourceTurretBuildState.gd:317,
        # default 0.0) as the aim/shoot gate input but NEVER
        # stamped it back -- warmup never advanced live. This
        # slice adds the one pure function on the shared
        # TurretBuild driver file (it is TurretBuild.updateTile,
        # common to every turret, not ItemTurret-only) plus one
        # driver tick in the duo branch BEFORE the aim/shoot
        # call (Java order :502-514 before the shoot gate
        # :733, and aim/shoot read shoot_warmup as a gate
        # input). Three new result symbols: shoot_warmup +
        # warmup_hold + warmup_target.
        self.assertEqual(
            ledger['N2253']['source_symbols'],
            [
                'source_turret_warmup_state_result.shoot_warmup',
                'source_turret_warmup_state_result.warmup_hold',
                'source_turret_warmup_state_result.warmup_target',
            ],
        )
        for name in ledger['N2253']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_warmup_state_result.shoot_warmup': 'SourceTurretBuildState.source_turret_warmup_state',
                    'source_turret_warmup_state_result.warmup_hold': 'SourceTurretBuildState.source_turret_warmup_state',
                    'source_turret_warmup_state_result.warmup_target': 'SourceTurretBuildState.source_turret_warmup_state',
                }[name])
        self.assertEqual(ledger['N2253']['runtime_proof'], '/root/C07TurretWarmupProof')
        self.assertEqual(
            ledger['N2253']['tests'],
            [
                'test_c07_turret_warmup_registration',
                'test_all_c07_turret_warmup_input_evidence_is_exact',
                'test_turret_warmup_state',
                'test_reference_graph_and_actual_c07_turret_warmup',
            ],
        )
        self.assertTrue(ledger['N2253']['deferred_exprs'])

    def test_all_c07_turret_warmup_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2253']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_warmup_state_result.shoot_warmup': 'SourceTurretBuildState.source_turret_warmup_state',
                    'source_turret_warmup_state_result.warmup_hold': 'SourceTurretBuildState.source_turret_warmup_state',
                    'source_turret_warmup_state_result.warmup_target': 'SourceTurretBuildState.source_turret_warmup_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2253']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_warmup_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile (Turret.java:490-515) advances
        # the warmup before it aims or shoots. isShooting is
        # `isShooting = alwaysShooting || (unit.controller()
        # instanceof Player ? unit.isShooting() :
        # logicControlled() ? logicShooting : target !=
        # null);` (Turret.java:492 -- duo has no player and
        # no logic, so isShooting is target != null after the
        # validateTarget verdict at :491, N2251). The target
        # is `float warmupTarget = (isShooting &&
        # canConsume()) || charging() ? 1f : 0f;`
        # (Turret.java:502); ItemTurret canConsume is `return
        # ammo.size > 0 && (ammo.peek().amount >= ammoPerShot
        # || cheating());` (Turret.java:711 -- ammo is the
        # Seq<ItemStack>, peek() is the last stack; the
        # driver's stacks are the {"item", "amount"} dicts of
        # SourceTurretAmmoState, peeked from the last stack --
        # SourceItemTurretBuildState.gd:420 and the useAmmo
        # inline at :541-543, `var entry: Dictionary =
        # ammo_entries_after[ammo_entries_after.size() - 1]`,
        # and SourceTurretAmmoState._peek_turret_ammo_state_impl
        # reads `stacks[stacks.size() - 1]`; the driver takes
        # the last entry's amount, >= ammoPerShot 1 for duo,
        # or cheating). charging is `return queuedBullets > 0
        # && shoot.firstShotDelay > 0;` (Turret.java:715-717
        # -- duo firstShotDelay is 0, so charging is false
        # live, but the gate is still checked).
        # controlled is `public boolean controlled(){` /
        # `return unit.isPlayer();` (Turret.java:441-443 --
        # the driver passes frame["controlled"] with a false
        # default, no live player control, same pattern as
        # N2251). The hold is `if(warmupTarget > 0 &&
        # !controlled()){` / `warmupHold = 1f;` /
        # `if(warmupHold > 0f){` / `warmupHold -= Time.delta /
        # warmupMaintainTime;` / `warmupTarget = 1f;`
        # (Turret.java:503-509 -- with the duo default
        # warmupMaintainTime 0f the division is +inf, so the
        # hold ends on the very tick it is set; the test pins
        # warmup_hold <= 0.0 after that tick, never exactly
        # -inf). The advance is `if(linearWarmup){` /
        # `shootWarmup = Mathf.approachDelta(shootWarmup,
        # warmupTarget, shootWarmupSpeed * (warmupTarget > 0
        # ? efficiency : 1f));` / `}else{` /
        # `shootWarmup = Mathf.lerpDelta(shootWarmup,
        # warmupTarget, shootWarmupSpeed * (warmupTarget > 0
        # ? efficiency : 1f));` (Turret.java:511-515 -- arc
        # Mathf.java:402-404 `public static float
        # clamp(float value){` / `return Math.max(Math.min
        # (value, 1f), 0f);` clamps to [0, 1]; :415-417
        # `public static float approach(float from, float to,
        # float speed){` / `return from + Mathf.clamp(to -
        # from, -speed, speed);`; :420-422 `public static
        # float approachDelta(float from, float to, float
        # speed){` / `return approach(from, to, Time.delta *
        # speed);`; :426-428 `public static float lerp(float
        # fromValue, float toValue, float progress){` /
        # `return fromValue + (toValue - fromValue) *
        # progress;`; :430-432 `public static float
        # lerpDelta(float fromValue, float toValue, float
        # progress){` / `return lerp(fromValue, toValue,
        # clamp(progress * Time.delta));`). Class defaults
        # are minWarmup 0f (`public float minWarmup = 0f;`,
        # Turret.java:76), warmupMaintainTime 0f (`public
        # float warmupMaintainTime = 0f;`, :84),
        # shootWarmupSpeed 0.1f (`public float
        # shootWarmupSpeed = 0.1f;`, :136), linearWarmup
        # false (`public boolean linearWarmup = false;`,
        # :138) -- the duo def (Blocks.java:3257-3295)
        # overrides NONE of them, so the driver passes 0.1 /
        # false / 0.0. The shoot gate still reads the warmup
        # (`if(reloadCounter >= reload && !charging() &&
        # shootWarmup >= minWarmup){`, Turret.java:733 --
        # duo minWarmup is 0, so the gate always passes, but
        # the warmup still has to advance for the frame to be
        # right). The result is a 3-key dict: `shoot_warmup`
        # (after the lerp/approach step), `warmup_hold`
        # (after the hold decay), `warmup_target` (0.0/1.0
        # after the hold fold). The recoil/heat decay
        # (`curRecoil = Mathf.approachDelta(curRecoil, 0, 1 /
        # recoilTime);` / `heat = Mathf.approachDelta(heat, 0,
        # 1 / cooldownTime);`, Turret.java:519/:526), the
        # charge advance (`charge = charging() ?
        # Mathf.approachDelta(charge, 1, 1 /
        # shoot.firstShotDelay) : 0;`, :527), queuedBullets
        # when shotDelay > 0, effects/sound, and findTarget
        # are NOT this slice -- they wait for their own
        # slices. The hasAmmo() swap (`if(ammo.size >= 2 &&
        # ammo.peek().amount < ammoPerShot){` /
        # `ammo.swap(ammo.size - 1, i);`, Turret.java:700-706
        # -- it swaps a sufficient stack to the top before
        # the canConsume return) is hasAmmo() detail and
        # waits with the hasAmmo() wrapper slice; can_consume
        # here reads the peek amount as-is.
        self.assertIn('static func source_turret_warmup_state(shoot_warmup: float, warmup_hold: float, is_shooting: bool, can_consume: bool, charging: bool, controlled: bool, efficiency: float, delta: float, shoot_warmup_speed: float, linear_warmup: bool, warmup_maintain_time: float) -> Dictionary:', turret)
        self.assertIn('var warmup_target: float = 1.0 if ((is_shooting and can_consume) or charging) else 0.0', turret)
        self.assertIn('if warmup_target > 0.0 and not controlled:', turret)
        self.assertIn('warmup_hold = 1.0', turret)
        self.assertIn('if warmup_hold > 0.0:', turret)
        self.assertIn('warmup_hold -= delta / warmup_maintain_time', turret)
        self.assertIn('warmup_target = 1.0', turret)
        self.assertIn('var rate: float = shoot_warmup_speed * (efficiency if warmup_target > 0.0 else 1.0)', turret)
        self.assertIn('if linear_warmup:', turret)
        self.assertIn('shoot_warmup = shoot_warmup + clampf(warmup_target - shoot_warmup, -rate * delta, rate * delta)', turret)
        self.assertIn('shoot_warmup = lerpf(shoot_warmup, warmup_target, clampf(rate * delta, 0.0, 1.0))', turret)
        self.assertIn('return {"shoot_warmup": shoot_warmup, "warmup_hold": warmup_hold, "warmup_target": warmup_target}', turret)
        self.assertIn('float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;', turret)
        self.assertIn('if(warmupTarget > 0 && !controlled()){', turret)
        self.assertIn('warmupHold = 1f;', turret)
        self.assertIn('if(warmupHold > 0f){', turret)
        self.assertIn('warmupHold -= Time.delta / warmupMaintainTime;', turret)
        self.assertIn('shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', turret)
        self.assertIn('shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', turret)
        self.assertIn('isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);', turret)
        self.assertIn('return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());', turret)
        self.assertIn('return queuedBullets > 0 && shoot.firstShotDelay > 0;', turret)
        self.assertIn('public boolean controlled(){', turret)
        self.assertIn('return unit.isPlayer();', turret)
        self.assertIn('public float minWarmup = 0f;', turret)
        self.assertIn('public float warmupMaintainTime = 0f;', turret)
        self.assertIn('public float shootWarmupSpeed = 0.1f;', turret)
        self.assertIn('public boolean linearWarmup = false;', turret)
        self.assertIn('if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', turret)
        self.assertIn('public static float clamp(float value){', turret)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', turret)
        self.assertIn('public static float approach(float from, float to, float speed){', turret)
        self.assertIn('return from + Mathf.clamp(to - from, -speed, speed);', turret)
        self.assertIn('public static float approachDelta(float from, float to, float speed){', turret)
        self.assertIn('return approach(from, to, Time.delta * speed);', turret)
        self.assertIn('public static float lerp(float fromValue, float toValue, float progress){', turret)
        self.assertIn('return fromValue + (toValue - fromValue) * progress;', turret)
        self.assertIn('public static float lerpDelta(float fromValue, float toValue, float progress){', turret)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', turret)
        self.assertIn('curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', turret)
        self.assertIn('heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch BEFORE
        # the aim/shoot call (Java order :502-514 before the
        # shoot gate :733, and aim/shoot read shoot_warmup as a
        # gate input): it reads the peek amount from the last
        # duo stack entry (the {"item", "amount"} dicts --
        # ammo.peek() is the last stack, Turret.java:711),
        # computes can_consume as stacks non-empty AND (peek
        # amount >= ammoPerShot 1 OR cheating), calls the new
        # pure function with is_shooting = has_target AND the
        # N2251 validate verdict, charging / controlled /
        # efficiency from the frame, delta = seconds, and the
        # per-def duo values (shootWarmupSpeed 0.1,
        # linearWarmup false, warmupMaintainTime 0.0), then
        # stamps shoot_warmup + warmup_hold back on the frame
        # so the aim/shoot call below reads the advanced
        # warmup.
        self.assertIn('var duo_peek_amount: int = 0', turret)
        self.assertIn('if not duo_entries.is_empty():', turret)
        self.assertIn('var duo_peek_entry: Dictionary = duo_entries[duo_entries.size() - 1]', turret)
        self.assertIn('duo_peek_amount = int(duo_peek_entry.get("amount", 0))', turret)
        self.assertIn('var duo_can_consume: bool = not duo_entries.is_empty() and (duo_peek_amount >= 1 or bool(frame.get("cheating", false)))', turret)
        self.assertIn('var warmup: Dictionary = source_turret_warmup_state(float(frame.get("shoot_warmup", 0.0)), float(frame.get("warmup_hold", 0.0)), bool(frame.get("has_target", false)) and bool(validate.get("valid", false)), duo_can_consume, bool(frame.get("charging", false)), bool(frame.get("controlled", false)), float(frame.get("efficiency", 1.0)), seconds, 0.1, false, 0.0)', turret)
        self.assertIn('frame["shoot_warmup"] = warmup.get("shoot_warmup", 0.0)', turret)
        self.assertIn('frame["warmup_hold"] = warmup.get("warmup_hold", 0.0)', turret)
        # The proof's keys drive the warmup through the real
        # driver (the warmup rises toward 1 while shooting /
        # falls toward 0 with no target / the hold keeps the
        # target at 1 while maintainTime > 0 / a zero
        # maintainTime ends the hold on the next tick / the
        # linear branch approaches in fixed steps / efficiency
        # scales the rise rate when the target is 1 / the
        # frame carries the advanced warmup before aim reads
        # it / the duo minWarmup 0 gate still passes). There
        # are no recoil/heat / charge / queuedBullets /
        # findTarget keys: those wait for their own slices.
        proof = TURRET_WARMUP_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_rises_toward_1_while_shooting',
            'warmup_falls_toward_0_when_no_target',
            'warmup_hold_keeps_target_1',
            'warmup_hold_zero_maintain_no_extend',
            'warmup_linear_approach_branch',
            'warmup_efficiency_scales_rise',
            'warmup_stamped_to_frame_before_aim',
            'warmup_min_warmup_gate_still_passes_duo',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_warmup(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretWarmupProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_WARMUP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_rises_toward_1_while_shooting',
            'warmup_falls_toward_0_when_no_target',
            'warmup_hold_keeps_target_1',
            'warmup_hold_zero_maintain_no_extend',
            'warmup_linear_approach_branch',
            'warmup_efficiency_scales_rise',
            'warmup_stamped_to_frame_before_aim',
            'warmup_min_warmup_gate_still_passes_duo',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
