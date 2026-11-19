import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
OWNER_REGISTRY = ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd'
SOUND_CONTROL_LOOP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlLoopProof.gd'


class C07SoundControlLoopTests(unittest.TestCase):
    def test_c07_sound_control_loop_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2287']['godot_owner'], 'SourceSoundControlState.source_sound_control_loop_state')
        # SoundControl.loop() (SoundControl.java:93-117) owns all
        # three overloads in one slice: loop(Sound, float)
        # (:93-97, headless guard + Core.camera.position),
        # loop(Sound, Position, float) (:99-101, pitch defaults
        # 1f) and loop(Sound, Position, float, float) (:103-117,
        # the accumulator). Each overload returns the updated
        # SoundData (SoundControl.java:378-385) as 8 result
        # symbols: the 6 accumulated fields plus sound_id and
        # cur_volume carried through unchanged (updateLoops,
        # N2264, owns them). 24 new result symbols in all.
        self.assertEqual(
            ledger['N2287']['source_symbols'],
            [
                'source_sound_control_loop_state_result.volume',
                'source_sound_control_loop_state_result.pitch',
                'source_sound_control_loop_state_result.total',
                'source_sound_control_loop_state_result.total_volume',
                'source_sound_control_loop_state_result.sum_x',
                'source_sound_control_loop_state_result.sum_y',
                'source_sound_control_loop_state_result.sound_id',
                'source_sound_control_loop_state_result.cur_volume',
                'source_sound_control_loop_position_state_result.volume',
                'source_sound_control_loop_position_state_result.pitch',
                'source_sound_control_loop_position_state_result.total',
                'source_sound_control_loop_position_state_result.total_volume',
                'source_sound_control_loop_position_state_result.sum_x',
                'source_sound_control_loop_position_state_result.sum_y',
                'source_sound_control_loop_position_state_result.sound_id',
                'source_sound_control_loop_position_state_result.cur_volume',
                'source_sound_control_loop_volume_state_result.volume',
                'source_sound_control_loop_volume_state_result.pitch',
                'source_sound_control_loop_volume_state_result.total',
                'source_sound_control_loop_volume_state_result.total_volume',
                'source_sound_control_loop_volume_state_result.sum_x',
                'source_sound_control_loop_volume_state_result.sum_y',
                'source_sound_control_loop_volume_state_result.sound_id',
                'source_sound_control_loop_volume_state_result.cur_volume',
            ],
        )
        for name in ledger['N2287']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                    'arc-core/src/arc/audio/Sound.java',
                    'arc-core/src/arc/audio/Audio.java',
                    'core/src/mindustry/Vars.java',
                    'arc-core/src/arc/math/Mathf.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2287']['runtime_proof'], '/root/C07SoundControlLoopProof')
        self.assertEqual(
            ledger['N2287']['tests'],
            [
                'test_c07_sound_control_loop_registration',
                'test_all_c07_sound_control_loop_input_evidence_is_exact',
                'test_sound_control_loop_state',
                'test_reference_graph_and_actual_c07_sound_control_loop',
            ],
        )
        self.assertTrue(ledger['N2287']['deferred_exprs'])

    def test_all_c07_sound_control_loop_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2287']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/audio/SoundControl.java',
            'arc-core/src/arc/audio/Sound.java',
            'arc-core/src/arc/audio/Audio.java',
            'core/src/mindustry/Vars.java',
            'arc-core/src/arc/math/Mathf.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2287']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_loop_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # The three overloads live on the new game state file
        # (the N2259 precedent: a game-level slice gets its own
        # state file; PortGame.gd is main-thread-only). The
        # accumulator takes every live value as an explicit
        # param -- headless (the N2259 accessor supplies it),
        # camera position (Core.camera.position), Core.audio
        # falloff (Audio.java:13, 16000f) and the Sound falloff
        # offset (Sound.java:32, 0f) -- plus the previous
        # SoundData for the sound (the `sounds.get(sound,
        # SoundData::new)` map lookup, SoundControl.java:109:
        # an empty prev is a fresh SoundData, all fields zero).
        self.assertIn('static func source_sound_control_loop_state(sound: String, pos_x: float, pos_y: float, volume: float, pitch: float, headless: bool, camera_x: float, camera_y: float, audio_falloff: float, falloff_offset: float, prev: Dictionary) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_loop_position_state(sound: String, pos_x: float, pos_y: float, volume: float, headless: bool, camera_x: float, camera_y: float, audio_falloff: float, falloff_offset: float, prev: Dictionary) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_loop_volume_state(sound: String, volume: float, headless: bool, camera_x: float, camera_y: float, audio_falloff: float, falloff_offset: float, prev: Dictionary) -> Dictionary:', state)
        # The guard is the Java guard verbatim (SoundControl.java:104):
        # headless, sound == Sounds.none (the string "none", the
        # N2222 precedent) or volume <= 0.00001f returns the
        # previous SoundData unchanged.
        self.assertIn('if headless or sound == SOUND_NONE or volume <= LOOP_VOLUME_EPSILON:', state)
        self.assertIn('const SOUND_NONE := "none"', state)
        self.assertIn('const LOOP_VOLUME_EPSILON := 0.00001', state)
        # calcFalloff (Sound.java:151-157) kept exactly: dst2 is
        # the squared camera distance minus falloffOffset squared,
        # floored at 0 (Math.max), and the one-arg clamp is the
        # [0, 1] clamp (Mathf.java:402-404, `return
        # Math.max(Math.min(value, 1f), 0f);`) -- never "fixed"
        # into a two-bound clamp, it already is one.
        self.assertIn('var dst2: float = maxf(dx * dx + dy * dy - falloff_offset * falloff_offset, 0.0)', state)
        self.assertIn('var base_vol: float = clampf(1.0 / (dst2 / audio_falloff), 0.0, 1.0)', state)
        # The accumulator lines (SoundControl.java:110-115): the
        # volume clamp is the three-arg Mathf.clamp(data.volume,
        # 0f, 1f), and sum is the position weighted by baseVol.
        self.assertIn('result["volume"] = clampf(float(result["volume"]) + vol, 0.0, 1.0)', state)
        self.assertIn('result["pitch"] = float(result["pitch"]) + pitch * vol', state)
        self.assertIn('result["total"] = float(result["total"]) + base_vol', state)
        self.assertIn('result["total_volume"] = float(result["total_volume"]) + vol', state)
        self.assertIn('result["sum_x"] = float(result["sum_x"]) + pos_x * base_vol', state)
        self.assertIn('result["sum_y"] = float(result["sum_y"]) + pos_y * base_vol', state)
        # The wrappers delegate: the 3-arg overload fixes pitch
        # to 1f (SoundControl.java:101, `loop(sound, pos,
        # volume, 1f);`), the 2-arg overload passes the camera
        # position as the sound position (SoundControl.java:96,
        # `loop(sound, Core.camera.position, volume);`) and each
        # re-stamps its own owner on the delegated result.
        self.assertIn('source_sound_control_loop_state(sound, pos_x, pos_y, volume, LOOP_DEFAULT_PITCH, headless, camera_x, camera_y, audio_falloff, falloff_offset, prev)', state)
        self.assertIn('source_sound_control_loop_position_state(sound, camera_x, camera_y, volume, headless, camera_x, camera_y, audio_falloff, falloff_offset, prev)', state)
        self.assertIn('const LOOP_DEFAULT_PITCH := 1.0', state)
        for owner in [
            'source_runtime_owner_registry.PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_STATE',
            'source_runtime_owner_registry.PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_POSITION_STATE',
            'source_runtime_owner_registry.PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_VOLUME_STATE',
        ]:
            with self.subTest(owner=owner):
                self.assertIn(owner, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): loop() only accumulates numbers into
        # SoundData; playback belongs to updateLoops (N2264).
        self.assertNotIn('AudioStreamPlayer', state)
        registry = OWNER_REGISTRY.read_text(encoding='utf-8')
        for const in [
            'const PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_STATE := "port_game.source_sound_control_loop_state"',
            'const PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_POSITION_STATE := "port_game.source_sound_control_loop_position_state"',
            'const PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_VOLUME_STATE := "port_game.source_sound_control_loop_volume_state"',
        ]:
            with self.subTest(const=const):
                self.assertIn(const, registry)
        for expr in [
            'public void loop(Sound sound, float volume){',
            'loop(sound, Core.camera.position, volume);',
            'public void loop(Sound sound, Position pos, float volume){',
            'loop(sound, pos, volume, 1f);',
            'public void loop(Sound sound, Position pos, float volume, float pitch){',
            'if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;',
            'float baseVol = sound.calcFalloff(pos.getX(), pos.getY());',
            'SoundData data = sounds.get(sound, SoundData::new);',
            'data.volume = Mathf.clamp(data.volume, 0f, 1f);',
            'data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);',
            'protected static class SoundData{',
            'public float calcFalloff(float x, float y){',
            'return Mathf.clamp(1f / (dst2 / Core.audio.falloff));',
            'public float falloff = 16000f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys cover the accumulator math
        # (hand-computed falloff + accumulation + clamp), the
        # three guards (headless / none / tiny volume), both
        # delegating overloads, and the falloff offset. There is
        # no updateLoops key: the mixer (C, N2264) waits for B.
        proof = SOUND_CONTROL_LOOP_PROOF.read_text(encoding='utf-8')
        for key in [
            'loop_at_camera_full',
            'loop_far_falloff',
            'loop_accumulates_prev',
            'loop_headless_noop',
            'loop_none_sound_noop',
            'loop_tiny_volume_noop',
            'loop_position_pitch_defaults_one',
            'loop_volume_uses_camera_position',
            'loop_falloff_offset',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_loop(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlLoopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_LOOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'loop_at_camera_full',
            'loop_far_falloff',
            'loop_accumulates_prev',
            'loop_headless_noop',
            'loop_none_sound_noop',
            'loop_tiny_volume_noop',
            'loop_position_pitch_defaults_one',
            'loop_volume_uses_camera_position',
            'loop_falloff_offset',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
