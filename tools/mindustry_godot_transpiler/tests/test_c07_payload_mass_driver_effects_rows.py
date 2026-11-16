import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_EFFECTS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverEffectsRowsProof.gd'
PAYLOAD_MASS_DRIVER_EFFECTS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverEffectsRowsProof.tscn'


class C07PayloadMassDriverEffectsRowsTests(unittest.TestCase):
    def test_c07_payload_mass_driver_effects_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2468']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_receive_effects_state')
        # The PayloadMassDriver updateTile STATE is live
        # (N2245 advance + N2246 state branches): the
        # effectDelayTimer countdown + reloadCounter =
        # 1f reset (:173-179) and the charge + transfer
        # (:289-332, partner effectDelayTimer =
        # transferEffect.lifetime 11f) already run every
        # tick -- but the effects / sound / shake rows
        # were never modeled. N2468 ports them as TWO
        # pure-only pures (the N2444 precedent, NO tick
        # wiring): source_payload_mass_driver_receive_
        # effects_state(effect_delay_crossed, last_other,
        # x, y, turret_rotation, length, pitch_roll)
        # returns receive_effect_call {effect
        # "Fx.payloadReceive", x - cx/2f, y - cy/2f,
        # rotation} + receive_sound_call {sound
        # "massdriverReceive", x, y, pitch 1f +
        # pitch_roll, volume 0.7f} + shake_call
        # {intensity 3.0, duration 3.0} +
        # reload_counter_after 1f, all null unless the
        # crossed timer + lastOther gate fires; and
        # source_payload_mass_driver_shoot_effects_state(
        # charge_fired, x, y, turret_rotation, length,
        # pitch_roll, other_x, other_y, payload) returns
        # shoot_effect_call {effect "Fx.shootBig2", x +
        # cx, y + cy, rotation} + smoke_effect_call
        # {effect "Fx.shootPayloadDriver", x, y,
        # rotation} + transfer_effect_call {effect
        # "transferEffect", x + cx, y + cy, rotation,
        # data {from, to, payload}} + shoot_sound_call
        # {sound "massdriver", x, y, pitch pitch_roll,
        # volume 0.7f} + shake_call {intensity 3.0,
        # duration 3.0} + effect_delay_timer_after 11f,
        # all null unless charge_fired. NO sound is
        # played, NO effect spawned, NO camera shaken --
        # the audio/effect call sites wait for their own
        # slices. The pitch rolls are ALREADY-ROLLED
        # caller-supplied inputs (receive: Mathf.range(
        # 0.2f) in [-0.2, 0.2]; shoot: Mathf.random(0.9f,
        # 1.1f) in [0.9, 1.1]) -- NO RNG in the pures
        # (the N2421 precedent). Ten new result symbols,
        # in Java updateTile order: the receive call
        # records (:178-181), then the shoot call
        # records (:296-301) + the lifetime stamp (:304).
        self.assertEqual(
            ledger['N2468']['source_symbols'],
            [
                'source_payload_mass_driver_receive_effects_state_result.receive_effect_call',
                'source_payload_mass_driver_receive_effects_state_result.receive_sound_call',
                'source_payload_mass_driver_receive_effects_state_result.shake_call',
                'source_payload_mass_driver_receive_effects_state_result.reload_counter_after',
                'source_payload_mass_driver_shoot_effects_state_result.shoot_effect_call',
                'source_payload_mass_driver_shoot_effects_state_result.smoke_effect_call',
                'source_payload_mass_driver_shoot_effects_state_result.transfer_effect_call',
                'source_payload_mass_driver_shoot_effects_state_result.shoot_sound_call',
                'source_payload_mass_driver_shoot_effects_state_result.shake_call',
                'source_payload_mass_driver_shoot_effects_state_result.effect_delay_timer_after',
            ],
        )
        expected_owners = {
            'source_payload_mass_driver_receive_effects_state_result.receive_effect_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_receive_effects_state',
            'source_payload_mass_driver_receive_effects_state_result.receive_sound_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_receive_effects_state',
            'source_payload_mass_driver_receive_effects_state_result.shake_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_receive_effects_state',
            'source_payload_mass_driver_receive_effects_state_result.reload_counter_after': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_receive_effects_state',
            'source_payload_mass_driver_shoot_effects_state_result.shoot_effect_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_shoot_effects_state',
            'source_payload_mass_driver_shoot_effects_state_result.smoke_effect_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_shoot_effects_state',
            'source_payload_mass_driver_shoot_effects_state_result.transfer_effect_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_shoot_effects_state',
            'source_payload_mass_driver_shoot_effects_state_result.shoot_sound_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_shoot_effects_state',
            'source_payload_mass_driver_shoot_effects_state_result.shake_call': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_shoot_effects_state',
            'source_payload_mass_driver_shoot_effects_state_result.effect_delay_timer_after': 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_shoot_effects_state',
        }
        for name in ledger['N2468']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2468']['runtime_proof'], '/root/C07PayloadMassDriverEffectsRowsProof')
        self.assertEqual(
            ledger['N2468']['tests'],
            [
                'test_c07_payload_mass_driver_effects_rows_registration',
                'test_all_c07_payload_mass_driver_effects_rows_input_evidence_is_exact',
                'test_payload_mass_driver_effects_rows_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_effects_rows',
            ],
        )
        self.assertTrue(ledger['N2468']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #144 (1-based in
        # DEFERRED-after-advances-30.py): the
        # PayloadMassDriver updateTile effects / sound /
        # shake entry is REMOVED -- receiveEffect.at +
        # receiveSound.at + Effect.shake + shootEffect.at
        # + smokeEffect.at + transferEffect.at +
        # shootSound.at are live now as pure call
        # records, so nothing of the entry remains. Net
        # 246 - 1 = 245. (The #147 transfer-effects entry
        # still stands: it covers the same shoot lines
        # (:295-301) a second time -- the coordinator
        # decides whether to retire it at merge, the
        # N2444 #260 precedent.)
        self.assertFalse(any(entry.startswith('PayloadMassDriver updateTile effects / sound / shake rows (') for entry in ledger['N2468']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver transfer effects / sound / shake rows (') for entry in ledger['N2468']['deferred_exprs']))
        self.assertEqual(len(ledger['N2468']['deferred_exprs']), 245)

    def test_all_c07_payload_mass_driver_effects_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2468']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadMassDriverBuildState.source_payload_mass_driver_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/entities/Effect.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2468']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_effects_rows_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The updateTile effects / sound / shake rows
        # (PayloadDriverBuild.updateTile(), PayloadMass-
        # Driver.java:173-181 + :292-304): the STATE is
        # live since N2245/N2246 (the effectDelayTimer
        # countdown + reloadCounter = 1f reset, the
        # charge + transfer with partner effectDelayTimer
        # = transferEffect.lifetime 11f), so these pures
        # consume the caller-evaluated gates and report
        # the effects + sound + shake as pure call
        # records (the N2444 precedent -- no sound
        # played, no effect spawned, no camera shaken):
        # receive: `receiveEffect.at(x - cx/2f, y -
        # cy/2f, turretRotation);` + `reloadCounter =
        # 1f;` + `Effect.shake(shake, shake, this);` +
        # `receiveSound.at(x, y, 1f + Mathf.range(0.2f),
        # shootSoundVolume);` with cx/cy from the OTHER
        # driver's turretRotation (`float cx = Angles.
        # trnsx(other.turretRotation, length), cy =
        # Angles.trnsy(other.turretRotation, length);`);
        # shoot: `shootEffect.at(x + cx, y + cy,
        # turretRotation);` + `smokeEffect.at(x, y,
        # turretRotation);` + `Effect.shake(shake, shake,
        # this);` + `shootSound.at(x, y, Mathf.random(
        # 0.9f, 1.1f), shootSoundVolume);` +
        # `transferEffect.at(x + cx, y + cy,
        # turretRotation, new PayloadMassDriverData(x +
        # cx, y + cy, other.x - cx, other.y - cy,
        # payload));` with cx/cy from the SELF rotation.
        # The fields are the block fields (`public
        # Effect shootEffect = Fx.shootBig2;` /
        # `public Effect smokeEffect =
        # Fx.shootPayloadDriver;` / `public Effect
        # receiveEffect = Fx.payloadReceive;` / `public
        # Sound shootSound = Sounds.massdriver;` /
        # `public Sound receiveSound =
        # Sounds.massdriverReceive;` / `public float
        # shootSoundVolume = 0.7f;` / `public float
        # shake = 3f;`, PayloadMassDriver.java:32-38;
        # `public float length = 89 / 8f;`, :25;
        # `public Effect transferEffect = new Effect(
        # 11f, 600f, e -> {`, :40, lifetime 11f). The Fx
        # tokens are exact (`shootBig2 = new Effect(10,
        # e -> {`, Fx.java:1866; `shootPayloadDriver =
        # new Effect(30f, e -> {`, Fx.java:2189;
        # `payloadReceive = new Effect(30, e -> {`,
        # Fx.java:2677) and the Sounds tokens are exact
        # via the .ogg assets (massdriver.ogg +
        # massdriverReceive.ogg -- Sounds is build-
        # generated, no Sounds.java in upstream, the
        # N2444 padLaunch precedent). The shake is
        # Effect.shake(shake, shake, this) -- the
        # Position overload (`public static void shake(
        # float intensity, float duration, Position
        # loc){`, Effect.java:210-212) delegates to
        # (`public static void shake(float intensity,
        # float duration, float x, float y){`, Effect.
        # java:201), so the first arg is the intensity
        # and the second the duration, both 3f; the
        # camera-distance falloff inside (Effect.
        # java:204-207) is the callee's own behavior --
        # the pure records the CALL params, not the
        # falloff result. The pitch rolls are ALREADY-
        # ROLLED caller-supplied inputs (Mathf.range(r)
        # is the arc uniform roll in [-r, r], `public
        # static float range(float range){` with `return
        # random(-range, range);`, arc Mathf.java:220-
        # 222; Mathf.random(a, b) is uniform in [a, b],
        # `public static float random(float start, float
        # end){` with `return start + rand.nextFloat() *
        # (end - start);`, arc Mathf.java:285-287) -- NO
        # RNG in the pures (the N2421 precedent). The
        # transfer data is the PayloadMassDriverData
        # constructor (`public PayloadMassDriverData(
        # float x, float y, float ox, float oy, Payload
        # payload){`, PayloadMassDriver.java:514) -- the
        # callee's lerp geometry (transferEffect body,
        # :40-47) is NOT ported (the N2396 record-the-
        # call precedent). Angles.trnsx/trnsy are
        # len*cosDeg/sinDeg (`public static float
        # trnsx(float angle, float len){` with `return
        # len * Mathf.cosDeg(angle);`, arc Angles.
        # java:66-68; `public static float trnsy(float
        # angle, float len){` with `return len *
        # Mathf.sinDeg(angle);`, arc Angles.java:70-72),
        # through the shared source_angles_trns_vec (the
        # N2246 precedent). Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split line
        # fails this test).
        self.assertIn('static func source_payload_mass_driver_receive_effects_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_shoot_effects_state', payload_mass_driver)
        self.assertIn('boolean pos = effectDelayTimer > 0;', payload_mass_driver)
        self.assertIn('effectDelayTimer -= Time.delta;', payload_mass_driver)
        self.assertIn('if(effectDelayTimer <= 0 && pos && lastOther != null){', payload_mass_driver)
        self.assertIn('float cx = Angles.trnsx(other.turretRotation, length), cy = Angles.trnsy(other.turretRotation, length);', payload_mass_driver)
        self.assertIn('receiveEffect.at(x - cx/2f, y - cy/2f, turretRotation);', payload_mass_driver)
        self.assertIn('reloadCounter = 1f;', payload_mass_driver)
        self.assertIn('Effect.shake(shake, shake, this);', payload_mass_driver)
        self.assertIn('receiveSound.at(x, y, 1f + Mathf.range(0.2f), shootSoundVolume);', payload_mass_driver)
        self.assertIn('if(charge >= chargeTime){', payload_mass_driver)
        self.assertIn('float cx = Angles.trnsx(turretRotation, length), cy = Angles.trnsy(turretRotation, length);', payload_mass_driver)
        self.assertIn('shootEffect.at(x + cx, y + cy, turretRotation);', payload_mass_driver)
        self.assertIn('smokeEffect.at(x, y, turretRotation);', payload_mass_driver)
        self.assertIn('shootSound.at(x, y, Mathf.random(0.9f, 1.1f), shootSoundVolume);', payload_mass_driver)
        self.assertIn('transferEffect.at(x + cx, y + cy, turretRotation, new PayloadMassDriverData(x + cx, y + cy, other.x - cx, other.y - cy, payload));', payload_mass_driver)
        self.assertIn('other.effectDelayTimer = transferEffect.lifetime;', payload_mass_driver)
        self.assertIn('public float length = 89 / 8f;', payload_mass_driver)
        self.assertIn('public Effect shootEffect = Fx.shootBig2;', payload_mass_driver)
        self.assertIn('public Effect smokeEffect = Fx.shootPayloadDriver;', payload_mass_driver)
        self.assertIn('public Effect receiveEffect = Fx.payloadReceive;', payload_mass_driver)
        self.assertIn('public Sound shootSound = Sounds.massdriver;', payload_mass_driver)
        self.assertIn('public Sound receiveSound = Sounds.massdriverReceive;', payload_mass_driver)
        self.assertIn('public float shootSoundVolume = 0.7f;', payload_mass_driver)
        self.assertIn('public float shake = 3f;', payload_mass_driver)
        self.assertIn('public Effect transferEffect = new Effect(11f, 600f, e -> {', payload_mass_driver)
        self.assertIn('public PayloadMassDriverData(float x, float y, float ox, float oy, Payload payload){', payload_mass_driver)
        self.assertIn('shootBig2 = new Effect(10, e -> {', payload_mass_driver)
        self.assertIn('shootPayloadDriver = new Effect(30f, e -> {', payload_mass_driver)
        self.assertIn('payloadReceive = new Effect(30, e -> {', payload_mass_driver)
        self.assertIn('public static void shake(float intensity, float duration, Position loc){', payload_mass_driver)
        self.assertIn('public static void shake(float intensity, float duration, float x, float y){', payload_mass_driver)
        self.assertIn('public static float range(float range){', payload_mass_driver)
        self.assertIn('return random(-range, range);', payload_mass_driver)
        self.assertIn('public static float random(float start, float end){', payload_mass_driver)
        self.assertIn('return start + rand.nextFloat() * (end - start);', payload_mass_driver)
        self.assertIn('public static float trnsx(float angle, float len){', payload_mass_driver)
        self.assertIn('return len * Mathf.cosDeg(angle);', payload_mass_driver)
        self.assertIn('public static float trnsy(float angle, float len){', payload_mass_driver)
        self.assertIn('return len * Mathf.sinDeg(angle);', payload_mass_driver)
        # The documented limits record the effects rows
        # as live.
        self.assertIn('updateTile effects / sound / shake rows live (N2468)', payload_mass_driver)
        # The proof's keys drive both effect pures (the
        # receive fire + gate + pitch math, the shoot
        # fire + transfer data + gate).
        proof = PAYLOAD_MASS_DRIVER_EFFECTS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'receive_fires',
            'receive_gate',
            'receive_pitch',
            'shoot_fires',
            'shoot_transfer',
            'shoot_gate',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.exists())
        self.assertTrue(PAYLOAD_MASS_DRIVER_EFFECTS_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07PayloadMassDriverEffectsRowsProof.gd', PAYLOAD_MASS_DRIVER_EFFECTS_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_payload_mass_driver_effects_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverEffectsRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_EFFECTS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'receive_fires',
            'receive_gate',
            'receive_pitch',
            'shoot_fires',
            'shoot_transfer',
            'shoot_gate',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
