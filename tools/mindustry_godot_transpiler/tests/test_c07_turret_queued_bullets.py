import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_QUEUED_BULLETS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretQueuedBulletsProof.gd'


class C07TurretQueuedBulletsTests(unittest.TestCase):
    def test_c07_turret_queued_bullets_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2269']['godot_owner'], 'SourceTurretBuildState.source_turret_queued_bullets_state')
        # TurretBuild keeps a cross-tick counter of bullets that
        # have been queued to fire but have not fired yet:
        # `public int queuedBullets = 0;` (Turret.java:293).
        # shoot() (Turret.java:741-777) increments it once per
        # bullet the shoot pattern queues: `queuedBullets++;`
        # (:754); when the pattern delay is positive the bullet
        # is deferred: `if(delay > 0f){` `Time.run(delay, () ->
        # {` `bullet(type, xOffset, yOffset, angle, mover);`
        # `});` (:756-764), otherwise it fires at once
        # (`bullet(type, xOffset, yOffset, angle, mover);`,
        # :765). bullet() (Turret.java:772-777) decrements it
        # first thing: `queuedBullets --;` (:773). While any
        # bullet is still queued and the def has a first-shot
        # delay, the turret is charging:
        # `public boolean charging(){`
        # `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
        # `}` (:715-717) -- and updateShooting()
        # (Turret.java:731-740) refuses to shoot while charging:
        # `if(reloadCounter >= reload && !charging() &&
        # shootWarmup >= minWarmup){` `shoot(type);`
        # `reloadCounter %= reload;` `}` (:733-738).
        # updateShooting() runs from updateTile()
        # (`updateShooting();`, :601/:609). The delay branch
        # also plays the charge sound when a shot begins:
        # `if(shoot.firstShotDelay > 0){`
        # `chargeSound.at(bulletX, bulletY,
        # Mathf.random(soundPitchMin, soundPitchMax));` (:747-748)
        # -- `/** Sound emitted when shoot.firstShotDelay is >0
        # and shooting begins. */` (:125). The field default is
        # `public float firstShotDelay = 0;`
        # (ShootPattern.java:11), and the only def that sets it
        # is lancer: `lancer = new PowerTurret("lancer"){{`
        # `range = 165f;` `shoot.firstShotDelay = 40f;`
        # `reload = 80f;` (Blocks.java:3560-3567). Duo never sets
        # it (Blocks.java:3257-3331) so its delay is 0,
        # charging() is always false for duo, and its delay-0
        # bullets fire at once, leaving the counter at 0.
        # `public float minWarmup = 0f;` (Turret.java:76) is the
        # warmup floor in the gate. There is NO driver tick:
        # the delayed bullets are Time.run callbacks with no
        # driver equivalent, and the gate is evaluated per shoot
        # event, not per tick (the N2248 precedent,
        # N2264/N2266/N2267/N2268) -- the logic executor does not
        # exist in the driver yet, so the pure function is called
        # directly by the proof. Four new result symbols:
        # queued_bullets, charging, can_shoot,
        # reload_counter_after.
        self.assertEqual(
            ledger['N2269']['source_symbols'],
            [
                'source_turret_queued_bullets_state_result.queued_bullets',
                'source_turret_queued_bullets_state_result.charging',
                'source_turret_queued_bullets_state_result.can_shoot',
                'source_turret_queued_bullets_state_result.reload_counter_after',
            ],
        )
        for name in ledger['N2269']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_queued_bullets_state_result.queued_bullets': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                    'source_turret_queued_bullets_state_result.charging': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                    'source_turret_queued_bullets_state_result.can_shoot': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                    'source_turret_queued_bullets_state_result.reload_counter_after': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                }[name])
        self.assertEqual(ledger['N2269']['runtime_proof'], '/root/C07TurretQueuedBulletsProof')
        self.assertEqual(
            ledger['N2269']['tests'],
            [
                'test_c07_turret_queued_bullets_registration',
                'test_all_c07_turret_queued_bullets_input_evidence_is_exact',
                'test_turret_queued_bullets_state',
                'test_reference_graph_and_actual_c07_turret_queued_bullets',
            ],
        )
        self.assertTrue(ledger['N2269']['deferred_exprs'])

    def test_all_c07_turret_queued_bullets_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2269']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_queued_bullets_state_result.queued_bullets': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                    'source_turret_queued_bullets_state_result.charging': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                    'source_turret_queued_bullets_state_result.can_shoot': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                    'source_turret_queued_bullets_state_result.reload_counter_after': 'SourceTurretBuildState.source_turret_queued_bullets_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2269']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_queued_bullets_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild keeps a cross-tick counter of bullets that
        # have been queued to fire but have not fired yet:
        # `public int queuedBullets = 0;` (Turret.java:293).
        # shoot() (Turret.java:741-777) increments it once per
        # bullet the shoot pattern queues: `queuedBullets++;`
        # (:754); when the pattern delay is positive the bullet
        # is deferred: `if(delay > 0f){` `Time.run(delay, () ->
        # {` `bullet(type, xOffset, yOffset, angle, mover);`
        # `});` (:756-764), otherwise it fires at once
        # (`bullet(type, xOffset, yOffset, angle, mover);`,
        # :765). bullet() (Turret.java:772-777) decrements it
        # first thing: `queuedBullets --;` (:773). While any
        # bullet is still queued and the def has a first-shot
        # delay, the turret is charging:
        # `public boolean charging(){`
        # `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
        # `}` (:715-717) -- and updateShooting()
        # (Turret.java:731-740) refuses to shoot while charging:
        # `if(reloadCounter >= reload && !charging() &&
        # shootWarmup >= minWarmup){` `shoot(type);`
        # `reloadCounter %= reload;` `}` (:733-738).
        # updateShooting() runs from updateTile()
        # (`updateShooting();`, :601/:609). The delay branch
        # also plays the charge sound when a shot begins:
        # `if(shoot.firstShotDelay > 0){`
        # `chargeSound.at(bulletX, bulletY,
        # Mathf.random(soundPitchMin, soundPitchMax));` (:747-748)
        # -- `/** Sound emitted when shoot.firstShotDelay is >0
        # and shooting begins. */` (:125). The field default is
        # `public float firstShotDelay = 0;`
        # (ShootPattern.java:11), and the only def that sets it
        # is lancer: `lancer = new PowerTurret("lancer"){{`
        # `range = 165f;` `shoot.firstShotDelay = 40f;`
        # `reload = 80f;` (Blocks.java:3560-3567). Duo never sets
        # it (Blocks.java:3257-3331) so its delay is 0,
        # charging() is always false for duo, and its delay-0
        # bullets fire at once, leaving the counter at 0.
        # `public float minWarmup = 0f;` (Turret.java:76) is the
        # warmup floor in the gate. The pure function takes the
        # current counter, the first-shot delay, the bullets
        # queued and fired this tick, the reload counter, the
        # reload, the shoot warmup and the warmup floor, and
        # returns the four keys `{"queued_bullets": ..,
        # "charging": .., "can_shoot": ..,
        # "reload_counter_after": ..}`. There is NO driver tick:
        # the delayed bullets are Time.run callbacks with no
        # driver equivalent, and the gate is evaluated per shoot
        # event, not per tick (the N2248 precedent,
        # N2264/N2266/N2267/N2268).
        self.assertIn('static func source_turret_queued_bullets_state(queued_bullets: int, first_shot_delay: float, queued_now: int, fired_now: int, reload_counter: float, reload: float, shoot_warmup: float, min_warmup: float) -> Dictionary:', turret)
        self.assertIn('return {"queued_bullets": queued_bullets_after, "charging": charging, "can_shoot": can_shoot, "reload_counter_after": reload_counter_after}', turret)
        self.assertIn('public int queuedBullets = 0;', turret)
        self.assertIn('public boolean charging(){', turret)
        self.assertIn('return queuedBullets > 0 && shoot.firstShotDelay > 0;', turret)
        self.assertIn('protected void updateShooting(){', turret)
        self.assertIn('if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', turret)
        self.assertIn('shoot(type);', turret)
        self.assertIn('reloadCounter %= reload;', turret)
        self.assertIn('protected void shoot(BulletType type){', turret)
        self.assertIn('if(shoot.firstShotDelay > 0){', turret)
        self.assertIn('chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));', turret)
        self.assertIn('/** Sound emitted when shoot.firstShotDelay is >0 and shooting begins. */', turret)
        self.assertIn('queuedBullets++;', turret)
        self.assertIn('if(delay > 0f){', turret)
        self.assertIn('Time.run(delay, () -> {', turret)
        self.assertIn('bullet(type, xOffset, yOffset, angle, mover);', turret)
        self.assertIn('protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', turret)
        self.assertIn('queuedBullets --;', turret)
        self.assertIn('public float minWarmup = 0f;', turret)
        self.assertIn('updateShooting();', turret)
        self.assertIn('public float firstShotDelay = 0;', turret)
        self.assertIn('lancer = new PowerTurret("lancer"){{', turret)
        self.assertIn('range = 165f;', turret)
        self.assertIn('shoot.firstShotDelay = 40f;', turret)
        self.assertIn('reload = 80f;', turret)
        # The proof's keys drive the counter through the pure
        # function: queueing increments the counter / firing
        # decrements it / a queued bullet with a first-shot
        # delay is charging / no queued bullet is not charging
        # / a zero first-shot delay never charges / the gate
        # blocks while charging / the gate allows a ready shot
        # and wraps the reload counter / the gate blocks when
        # the reload is not ready / the gate blocks when the
        # warmup is below the floor / a lancer bullet queued on
        # one tick blocks the next tick until it fires / the
        # lancer live case (firstShotDelay 40, reload 80, range
        # 165) / the duo live case (firstShotDelay 0, delay-0
        # bullets fire at once, counter stays 0).
        proof = TURRET_QUEUED_BULLETS_PROOF.read_text(encoding='utf-8')
        for key in [
            'qb_queue_increments',
            'qb_fire_decrements',
            'qb_charging_true_lancer',
            'qb_charging_false_no_queue',
            'qb_charging_false_zero_delay',
            'qb_gate_blocks_while_charging',
            'qb_gate_allows_when_ready',
            'qb_gate_blocks_reload_not_ready',
            'qb_gate_blocks_warmup_low',
            'qb_cross_tick_blocks_next_shot',
            'qb_lancer_live',
            'qb_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_queued_bullets(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretQueuedBulletsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_QUEUED_BULLETS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'qb_queue_increments',
            'qb_fire_decrements',
            'qb_charging_true_lancer',
            'qb_charging_false_no_queue',
            'qb_charging_false_zero_delay',
            'qb_gate_blocks_while_charging',
            'qb_gate_allows_when_ready',
            'qb_gate_blocks_reload_not_ready',
            'qb_gate_blocks_warmup_low',
            'qb_cross_tick_blocks_next_shot',
            'qb_lancer_live',
            'qb_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
