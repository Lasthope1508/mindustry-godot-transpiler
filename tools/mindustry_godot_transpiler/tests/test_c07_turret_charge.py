import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_CHARGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretChargeProof.gd'


class C07TurretChargeTests(unittest.TestCase):
    def test_c07_turret_charge_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2259']['godot_owner'], 'SourceTurretBuildState.source_turret_charge_state')
        # TurretBuild.updateTile() advances the charge every
        # tick, after the recoil/heat decay and before the
        # recoilOffset draw:
        # `charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;`
        # (Turret.java:527). charging is
        # `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
        # (Turret.java:715-717). The field is
        # `public float shootWarmup, charge, warmupHold = 0f;`
        # (:286) and the queue counter is
        # `public int queuedBullets = 0;` (:293). The delay
        # is `public float firstShotDelay = 0;`
        # (ShootPattern.java:11, `/** delay in ticks before
        # first shot */`); duo never overrides it
        # (`shoot = new ShootAlternate(3.5f);`,
        # Blocks.java:3299, inside the duo block 3257-3330 --
        # ShootAlternate only sets the spread, and every
        # bullet delay is firstShotDelay + shotDelay * i =
        # 0 + 0 = 0, so bullet() runs synchronously inside
        # shoot() and queuedBullets is 0 at every tick
        # boundary for duo: charge is always 0 live, but
        # the gate is still checked and the frame still
        # gets a live charge + charging stamp, which the
        # warmup tick (N2253) and the shoot gate (:733)
        # read. This slice is the LIVE frame tick on the
        # new duo driver: one pure function on the shared
        # TurretBuild driver file plus one driver tick in
        # the duo branch AFTER the N2254/N2256 decay ticks
        # and BEFORE the N2258 recoilOffset tick (Java
        # order :519/:520-525 decay, :526 heat, :527
        # charge, :532 offset). Two new result symbols:
        # charge and charging.
        self.assertEqual(
            ledger['N2259']['source_symbols'],
            [
                'source_turret_charge_state_result.charge',
                'source_turret_charge_state_result.charging',
            ],
        )
        for name in ledger['N2259']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_charge_state_result.charge': 'SourceTurretBuildState.source_turret_charge_state',
                    'source_turret_charge_state_result.charging': 'SourceTurretBuildState.source_turret_charge_state',
                }[name])
        self.assertEqual(ledger['N2259']['runtime_proof'], '/root/C07TurretChargeProof')
        self.assertEqual(
            ledger['N2259']['tests'],
            [
                'test_c07_turret_charge_registration',
                'test_all_c07_turret_charge_input_evidence_is_exact',
                'test_turret_charge_state',
                'test_reference_graph_and_actual_c07_turret_charge',
            ],
        )
        self.assertTrue(ledger['N2259']['deferred_exprs'])

    def test_all_c07_turret_charge_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2259']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_charge_state_result.charge': 'SourceTurretBuildState.source_turret_charge_state',
                    'source_turret_charge_state_result.charging': 'SourceTurretBuildState.source_turret_charge_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2259']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_charge_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-532)
        # advances the charge every tick:
        # `charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;`
        # (:527), where charging is
        # `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
        # (:715-717). approachDelta is
        # `public static float approachDelta(float from, float to, float speed){`
        # / `return approach(from, to, Time.delta * speed);`
        # (arc Mathf.java:420-422) with approach
        # `public static float approach(float from, float to, float speed){`
        # / `return from + Mathf.clamp(to - from, -speed, speed);`
        # (:415-417), so each tick moves the charge toward 1
        # by delta / firstShotDelay, never past 1, and a
        # non-charging tick resets it to 0 outright (not a
        # decay). The field is
        # `public float shootWarmup, charge, warmupHold = 0f;`
        # (:286), the queue counter is
        # `public int queuedBullets = 0;` (:293), the delay
        # is `public float firstShotDelay = 0;`
        # (ShootPattern.java:11), and duo never overrides
        # it (`shoot = new ShootAlternate(3.5f);`,
        # Blocks.java:3299). The pure function takes the
        # previous charge, the live queuedBullets count,
        # firstShotDelay and delta, derives charging
        # internally (queuedBullets > 0 and
        # firstShotDelay > 0, so firstShotDelay <= 0 never
        # divides by zero), and returns both keys:
        # `{"charge": .., "charging": ..}`. The driver tick
        # reads frame["charge"] (default 0.0) and
        # frame["queued_bullets"] (default 0 -- live-correct
        # for duo, whose every bullet delay is 0 so the
        # queue is empty at every tick boundary), calls the
        # pure function with duo firstShotDelay 0.0, then
        # stamps charge + charging back on the frame so the
        # warmup tick (N2253, which already reads
        # frame["charging"]) and the shoot gate (:733) read
        # a live flag.
        self.assertIn('static func source_turret_charge_state(charge: float, queued_bullets: int, first_shot_delay: float, delta: float) -> Dictionary:', turret)
        self.assertIn('return {"charge": charge, "charging": charging}', turret)
        self.assertIn('charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;', turret)
        self.assertIn('return queuedBullets > 0 && shoot.firstShotDelay > 0;', turret)
        self.assertIn('public float shootWarmup, charge, warmupHold = 0f;', turret)
        self.assertIn('public int queuedBullets = 0;', turret)
        self.assertIn('public float firstShotDelay = 0;', turret)
        self.assertIn('shoot = new ShootAlternate(3.5f);', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2256 multi-recoil decay tick and BEFORE the
        # N2258 recoilOffset tick (Java order :526 heat,
        # :527 charge, :532 offset): it reads the previous
        # tick's charge and queuedBullets, calls the new pure
        # function with duo firstShotDelay 0.0, then stamps
        # charge + charging back on the frame.
        self.assertIn('var charge_state: Dictionary = source_turret_charge_state(float(frame.get("charge", 0.0)), int(frame.get("queued_bullets", 0)), 0.0, seconds)', turret)
        self.assertIn('frame["charge"] = charge_state.get("charge", 0.0)', turret)
        self.assertIn('frame["charging"] = charge_state.get("charging", false)', turret)
        # The proof's keys drive the charge through the pure
        # function and the real driver (zero charge when not
        # charging / zero charge when firstShotDelay is 0
        # even with a queued bullet / the charge advances
        # toward 1 by delta / firstShotDelay per tick / the
        # charge clamps at 1, never past it / the charge
        # builds on the previous charge, not from 0 / the
        # charge + charging are stamped on the frame after
        # the tick / the charging flag matches the
        # queuedBullets > 0 and firstShotDelay > 0 gate /
        # the duo live tick stamps charge 0 + charging
        # false). There are no queuedBullets-counter /
        # delayed-bullet keys: the cross-tick queue counter
        # for firstShotDelay > 0 turrets waits for its own
        # slice (delayed Time.run bullets).
        proof = TURRET_CHARGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'charge_zero_when_not_charging',
            'charge_zero_when_first_shot_delay_zero',
            'charge_advances_toward_one',
            'charge_clamps_at_one',
            'charge_uses_previous_charge',
            'charge_stamped_to_frame',
            'charging_flag_matches_gate',
            'charge_duo_live_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_charge(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretChargeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CHARGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'charge_zero_when_not_charging',
            'charge_zero_when_first_shot_delay_zero',
            'charge_advances_toward_one',
            'charge_clamps_at_one',
            'charge_uses_previous_charge',
            'charge_stamped_to_frame',
            'charging_flag_matches_gate',
            'charge_duo_live_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
