import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_DEFAULT_CONSTRUCTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlDefaultConstructorProof.gd'

DEFAULT_CONSTRUCTOR_SIGNATURE = 'static func source_sound_control_default_constructor_state(reload_handler: Callable, wave_delay_ticks: float, wave_is_boss: bool, wave_chance_roll: bool, music_wave_chance: float, play_boss_once: Callable, play_random: Callable, filter: Variant, has_current: bool, current: String, fade: float, has_last_random_played: bool, last_random_played: String, should_play: bool, has_boss_music: bool, boss_music: String, now_millis: int) -> Dictionary:'

# The 8 registered lines of SoundControl() (SoundControl.java:45-68)
# -- only the lines that are 0-hit in BOTH ledgers at base 1571952f.
# The draft (batch 30 §1) listed 12 lines, probed BEFORE N2411
# merged: N2411 (SoundControl.update(), SoundControl.java:128-195)
# already owns `setupFilters();`, `lastPlayed = Time.millis();`,
# `Core.audio.soundBus.stop();` and `Core.audio.soundBus.play();`
# (they repeat in update() :149/:152/:156/:188), so they are NOT
# re-registered here -- the ctor only drives them through the
# N2349 delegate and the reset-leg commands. `playOnce(...)` (:53)
# is N2326/N2347-owned and `playRandom();` (:55) is N2306-owned;
# the ctor only drives them through the play_boss_once /
# play_random Callables.
EXACT_EXPRS = [
    'Events.on(ClientLoadEvent.class, e -> reload());',
    'Events.on(WaveEvent.class, e -> Time.run(Mathf.random(8f, 15f) * 60f, () -> {',
    'boolean boss = state.rules.spawns.contains(group -> group.getSpawned(state.wave - 2) > 0 && group.effect == StatusEffects.boss);',
    'if(boss){',
    '}else if(Mathf.chance(musicWaveChance)){',
    '}));',
    'Events.on(ResetEvent.class, e -> {',
    '});',
]

PROOF_KEYS = [
    'ctor_registers_client_load',
    'ctor_registers_wave',
    'ctor_wave_boss_plays_boss_music',
    'ctor_wave_chance_plays_random',
    'ctor_wave_skips_when_no_chance',
    'ctor_registers_reset',
    'ctor_setup_filters_called',
    'ctor_reset_stops_and_plays_bus',
    'ctor_returns_only_fourteen_keys',
]


class C07SoundControlDefaultConstructorTests(unittest.TestCase):
    def test_c07_sound_control_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl() (SoundControl.java:45-68) registers three
        # event subscriptions (ClientLoadEvent -> reload,
        # WaveEvent -> the delayed boss/chance leg, ResetEvent
        # -> lastPlayed + sound-bus stop/play) and calls
        # setupFilters() once. The subscriptions arrive as
        # explicit Callables (the N2377 drawer-Callable +
        # N2411 driver-tick precedent): the ctor never calls
        # the engine itself. The wave leg (boss -> playOnce
        # boss music, else chance -> playRandom, else nothing)
        # is evaluated once with explicit outcomes
        # (wave_is_boss / wave_chance_roll, the N2315
        # chance-roll precedent); the delay
        # (Mathf.random(8f, 15f) * 60f ticks) arrives as the
        # explicit wave_delay_ticks param. NO audio playback
        # in this slice (0 AudioStreamPlayer in the port):
        # bus and playback calls are returned as command
        # state, never executed; playback belongs to
        # updateLoops (N2304, held waiting for B).
        self.assertEqual(ledger['N2414']['godot_owner'], 'SourceSoundControlState.source_sound_control_default_constructor_state')
        self.assertEqual(
            ledger['N2414']['source_symbols'],
            [
                'source_sound_control_default_constructor_state_result.client_load_event',
                'source_sound_control_default_constructor_state_result.client_load_subscribed',
                'source_sound_control_default_constructor_state_result.reload_called',
                'source_sound_control_default_constructor_state_result.wave_event',
                'source_sound_control_default_constructor_state_result.wave_subscribed',
                'source_sound_control_default_constructor_state_result.wave_delay_ticks',
                'source_sound_control_default_constructor_state_result.music_wave_chance',
                'source_sound_control_default_constructor_state_result.wave_action',
                'source_sound_control_default_constructor_state_result.wave_music',
                'source_sound_control_default_constructor_state_result.reset_event',
                'source_sound_control_default_constructor_state_result.reset_subscribed',
                'source_sound_control_default_constructor_state_result.last_played',
                'source_sound_control_default_constructor_state_result.setup_filters_called',
                'source_sound_control_default_constructor_state_result.commands',
            ],
        )
        for name in ledger['N2414']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2414']['runtime_proof'], '/root/C07SoundControlDefaultConstructorProof')
        self.assertEqual(
            ledger['N2414']['tests'],
            [
                'test_c07_sound_control_default_constructor_registration',
                'test_all_c07_sound_control_default_constructor_input_evidence_is_exact',
                'test_sound_control_default_constructor_state',
                'test_reference_graph_and_actual_c07_sound_control_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2414']['deferred_exprs'])

    def test_all_c07_sound_control_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2414']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/audio/SoundControl.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2414']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_default_constructor_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl() (SoundControl.java:45-68): three
        # Events.on subscriptions plus one setupFilters()
        # call, kept in Java order. The already-owned
        # lines (setupFilters(); / lastPlayed =
        # Time.millis(); / soundBus.stop(); / soundBus.play();
        # all N2411, plus playOnce(...) N2326/N2347 and
        # playRandom(); N2306) are NOT re-registered -- the
        # ctor only drives them through the delegates and
        # explicit params. The 3 subscriptions arrive as
        # Callables (reload_handler / play_boss_once /
        # play_random); the RNG draws (Mathf.random delay,
        # Mathf.chance roll, the boss-spawn check) arrive
        # as explicit outcome params. NO audio playback in
        # this slice: bus and playback calls are returned
        # as command state, never executed; playback
        # belongs to updateLoops (N2304, held waiting
        # for B).
        self.assertIn(DEFAULT_CONSTRUCTOR_SIGNATURE, state)
        for expr in EXACT_EXPRS:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The delegates are called, not re-ported:
        # setupFilters (N2349) is a direct static call in
        # the same file; reload / playOnce (N2345) /
        # playRandom (N2347) arrive as Callables and are
        # .call()ed.
        self.assertIn('source_sound_control_setup_filters_state(filter)', state)
        self.assertIn('reload_handler.call()', state)
        self.assertIn('play_boss_once.call(', state)
        self.assertIn('play_random.call(', state)
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: the delay
        # draw and the chance roll arrive as explicit
        # params (the N2315 chance-roll precedent).
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function
        # directly with explicit params: the three
        # subscriptions, the wave leg (boss / chance /
        # skipped), the reset leg, the setupFilters call,
        # and the fourteen-key result shape.
        proof = SOUND_CONTROL_DEFAULT_CONSTRUCTOR_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
