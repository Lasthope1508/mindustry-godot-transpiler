import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_LAUNCH_EFFECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadLaunchEffectProof.gd'
LAUNCH_PAD_LAUNCH_EFFECT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadLaunchEffectProof.tscn'


class C07LaunchPadLaunchEffectTests(unittest.TestCase):
    def test_c07_launch_pad_launch_effect_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2444']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_launch_effect_state')
        # The launch fire is ALREADY LIVE since N2238 (the
        # full-and-timed gate, the stacks copy,
        # items.clear(), the launchCounter = 0f reset,
        # exposing launched + launched_stacks) and the pod
        # descriptor since N2397 -- so N2444 does NOT
        # re-implement the fire. What N2444 adds is the
        # launch sound + effect + shake as pure call
        # records (the N2396 record-the-call precedent):
        # source_launch_pad_launch_effect_state(launched,
        # x, y, pitch_roll) returns sound_call {sound
        # padLaunch, x, y, pitch 1f + pitch_roll} +
        # fx_call {effect launchPod, x, y} + shake_call
        # {intensity 3f, duration 3f, x, y}, all null
        # unless launched. NO sound is played, NO effect
        # spawned, NO camera shaken -- the audio/effect
        # call sites wait for their own slices. The pitch
        # roll is an ALREADY-ROLLED caller-supplied input
        # in [-0.1, 0.1] (Mathf.range(launchSoundPitchRand),
        # arc Mathf.range(r) = random(-r, r)) -- NO RNG in
        # the pure (the N2421 precedent). Three new result
        # symbols, in Java updateTile order: the sound
        # call (:149), the FX call (:156), the shake call
        # (:158).
        self.assertEqual(
            ledger['N2444']['source_symbols'],
            [
                'source_launch_pad_launch_effect_state_result.sound_call',
                'source_launch_pad_launch_effect_state_result.fx_call',
                'source_launch_pad_launch_effect_state_result.shake_call',
            ],
        )
        for name in ledger['N2444']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/LaunchPad.java')
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_launch_effect_state')
        self.assertEqual(ledger['N2444']['runtime_proof'], '/root/C07LaunchPadLaunchEffectProof')
        self.assertEqual(
            ledger['N2444']['tests'],
            [
                'test_c07_launch_pad_launch_effect_registration',
                'test_all_c07_launch_pad_launch_effect_input_evidence_is_exact',
                'test_launch_pad_launch_effect_state',
                'test_reference_graph_and_actual_c07_launch_pad_launch_effect',
            ],
        )
        self.assertTrue(ledger['N2444']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #131 (1-based in
        # DEFERRED-after-advances-27.py): the LaunchPad
        # updateTile launch sound / effects entry is
        # REMOVED -- launchSound.at + Fx.launchPod.at +
        # Effect.shake are live now as pure call records,
        # so nothing of the entry remains. Net 266 - 1 =
        # 265. (The #260 launch-fire entry still stands:
        # its text says only the sound/FX remain, which
        # N2444 now covers -- the coordinator decides
        # whether to retire it at merge.)
        self.assertFalse(any(entry.startswith('LaunchPad updateTile launch sound / effects (launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand))') for entry in ledger['N2444']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad updateTile launch fire (') for entry in ledger['N2444']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad config / display / shouldShowConfigure rows (') for entry in ledger['N2444']['deferred_exprs']))
        self.assertEqual(len(ledger['N2444']['deferred_exprs']), 265)

    def test_all_c07_launch_pad_launch_effect_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2444']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_launch_effect_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/content/Fx.java',
            'core/src/mindustry/entities/Effect.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2444']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_launch_effect_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The launch sound / FX rows (LaunchPadBuild.
        # updateTile(), LaunchPad.java:147-159): the fire
        # itself is live since N2238 (the gate, the
        # stacks copy, items.clear(), the launchCounter
        # = 0f reset) and the pod descriptor since
        # N2397, so this pure consumes the N2238
        # launched gate and reports the launch sound +
        # effect + shake as pure call records (the N2396
        # record-the-call precedent -- no sound played,
        # no effect spawned, no camera shaken):
        # `launchSound.at(x, y, 1f + Mathf.range(
        # launchSoundPitchRand));` + `Fx.launchPod.at(
        # this);` + `Effect.shake(3f, 3f, this);`. The
        # sound is the block field (`public Sound
        # launchSound = Sounds.padLaunch;`, LaunchPad.
        # java:34 -- the Sounds class is build-generated
        # mindustry.gen.Sounds, but the token is exact:
        # the asset is core/assets/sounds/block/
        # padLaunch.ogg). The pitch is 1f + Mathf.range(
        # launchSoundPitchRand) with the class default
        # (`public float launchSoundPitchRand = 0.1f;`,
        # LaunchPad.java:33, no def override), and
        # Mathf.range(r) is the arc uniform roll in
        # [-r, r] (`public static float range(float
        # range){` with `return random(-range, range);`,
        # arc Mathf.java:220-222) -- so the pitch roll is
        # an ALREADY-ROLLED caller-supplied input in
        # [-0.1, 0.1] and the pure never rolls (NO RNG in
        # pures, the N2421 precedent). The effect is
        # Fx.launchPod (`launchPod = new Effect(50,
        # e -> {`, Fx.java:2747), fired at the pad
        # (`.at(this)` positions it at the pad's x/y).
        # The shake is Effect.shake(3f, 3f, this) -- the
        # Position overload (`public static void shake(
        # float intensity, float duration, Position
        # loc){`, Effect.java:210-212) delegates to
        # (`public static void shake(float intensity,
        # float duration, float x, float y){`, Effect.
        # java:201), so the first arg is the intensity
        # and the second the duration, both 3f; the
        # camera-distance falloff inside the x/y overload
        # (Effect.java:204-207) is the callee's own
        # behavior -- the pure records the CALL params at
        # the pad position, not the falloff result. When
        # launched is false all three calls are null (the
        # N2397 null-when-absent precedent). Keep each
        # Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_launch_pad_launch_effect_state', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));', launch_pad)
        self.assertIn('Fx.launchPod.at(this);', launch_pad)
        self.assertIn('Effect.shake(3f, 3f, this);', launch_pad)
        self.assertIn('public float launchSoundPitchRand = 0.1f;', launch_pad)
        self.assertIn('public Sound launchSound = Sounds.padLaunch;', launch_pad)
        self.assertIn('launchPod = new Effect(50, e -> {', launch_pad)
        self.assertIn('public static void shake(float intensity, float duration, Position loc){', launch_pad)
        self.assertIn('public static void shake(float intensity, float duration, float x, float y){', launch_pad)
        self.assertIn('public static float range(float range){', launch_pad)
        self.assertIn('return random(-range, range);', launch_pad)
        # The documented limits record the launch FX rows
        # as live.
        self.assertIn('Launch FX rows live (N2444)', launch_pad)
        # The proof's keys drive the effect pure (the
        # null calls when not launched, the sound pitch
        # math at the +/-0.1 bounds, the FX call, the
        # shake params, the x/y passthrough, plus the
        # live frame values -- a full pad launches
        # through the N2238 advance and the effect pure
        # reads launched from the live frame).
        proof = LAUNCH_PAD_LAUNCH_EFFECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'effect_null_when_not_launched',
            'effect_sound_pitch',
            'effect_fx_call',
            'effect_shake_params',
            'effect_xy_passthrough',
            'effect_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.exists())
        self.assertTrue(LAUNCH_PAD_LAUNCH_EFFECT_PROOF_SCENE.exists())
        self.assertIn('C07LaunchPadLaunchEffectProof.gd', LAUNCH_PAD_LAUNCH_EFFECT_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_launch_pad_launch_effect(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadLaunchEffectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_LAUNCH_EFFECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'effect_null_when_not_launched',
            'effect_sound_pitch',
            'effect_fx_call',
            'effect_shake_params',
            'effect_xy_passthrough',
            'effect_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
