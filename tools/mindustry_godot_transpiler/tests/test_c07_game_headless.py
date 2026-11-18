import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_HEADLESS_STATE = ROOT / 'godot-mindustry/src/game/SourceGameHeadlessState.gd'
GAME_LOOP_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
GAME_BUILD_PROJECTOR_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePortGameBuildProjectorStatePortBridge.gd'
GAME_HEADLESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07GameHeadlessProof.gd'
GAME_LOOP_MODULE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/GameLoopRuntimeStateModuleProof.gd'


class C07GameHeadlessTests(unittest.TestCase):
    def test_c07_game_headless_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2259']['godot_owner'], 'SourceGameHeadlessState.source_game_headless_state')
        # The game-level headless source (ambient A): Vars.headless
        # (Vars.java:208-209, `/** whether the game is running on
        # a headless server */` / `public static boolean headless;`
        # -- a static boolean, default false). The only assignment
        # in the whole repo is ServerLauncher.init()
        # (ServerLauncher.java:45, `headless = true;`). The port
        # derives it from the display server instead (decision
        # 2026-11-17 ~12:56, Option 1, the first DisplayServer use
        # in the port): `DisplayServer.get_name() == "headless"`,
        # stamped onto the game node by
        # SourceGameLoopRuntimeState.ready(). The ambient gate
        # (N657) already takes this value as its headless_mode
        # input (BuildingComp.update, BuildingComp.java:2270-2271,
        # `if(!headless && block.ambientSound != Sounds.none &&
        # shouldAmbientSound()){` /
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`); this
        # slice only supplies the input, it builds no second gate.
        # One new result symbol: headless.
        self.assertEqual(
            ledger['N2259']['source_symbols'],
            [
                'source_game_headless_state_result.headless',
            ],
        )
        for name in ledger['N2259']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/Vars.java',
                    'server/src/mindustry/server/ServerLauncher.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceGameHeadlessState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2259']['runtime_proof'], '/root/C07GameHeadlessProof')
        self.assertEqual(
            ledger['N2259']['tests'],
            [
                'test_c07_game_headless_registration',
                'test_all_c07_game_headless_input_evidence_is_exact',
                'test_game_headless_state',
                'test_reference_graph_and_actual_c07_game_headless',
            ],
        )
        self.assertTrue(ledger['N2259']['deferred_exprs'])

    def test_all_c07_game_headless_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2259']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceGameHeadlessState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/Vars.java',
            'server/src/mindustry/server/ServerLauncher.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2259']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_game_headless_state(self):
        headless = GAME_HEADLESS_STATE.read_text(encoding='utf-8')
        # The pure headless accessor lives on its own game state
        # file: it reads the game node's headless flag, returns
        # false for a null game (no pause state, so it reads not
        # headless like the Java default -- the paused accessor
        # precedent in SourceGameLoopRuntimeState), and a game
        # without the flag reads null, which is not headless.
        # The stamp lives in SourceGameLoopRuntimeState.ready():
        # DisplayServer.get_name() == "headless" (Option 1),
        # first thing ready() does so every load step below sees
        # the same value the ambient gate (N657) reads. The flag
        # is declared on the game node next to the other
        # game.set-stamped vars (last_place_blocked precedent),
        # default false, the Java default.
        self.assertIn('static func source_game_headless_state(game: Object) -> Dictionary:', headless)
        with self.subTest(case='null game reads not headless'):
            self.assertIn('if game == null:', headless)
        with self.subTest(case='missing flag reads null, which is not headless'):
            # bool() has no null overload in GDScript (parse error
            # bool(null), runtime "No constructor" on a null
            # Variant), so the accessor compares with true instead
            # of calling bool() on the get() result.
            self.assertIn('result["headless"] = game.get("headless") == true', headless)
        with self.subTest(case='source owner is the registered headless state'):
            self.assertIn('source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_HEADLESS_STATE', headless)
        for expr in [
            '/** whether the game is running on a headless server */',
            'public static boolean headless;',
            'headless = true;',
            'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){',
            'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, headless)
        loop_runtime = GAME_LOOP_RUNTIME_STATE.read_text(encoding='utf-8')
        with self.subTest(case='ready stamps headless from DisplayServer first'):
            self.assertIn('game.set("headless", DisplayServer.get_name() == "headless")', loop_runtime)
        bridge = GAME_BUILD_PROJECTOR_BRIDGE.read_text(encoding='utf-8')
        with self.subTest(case='game node declares the headless flag, default false'):
            self.assertIn('var headless := false', bridge)
        module_proof = GAME_LOOP_MODULE_PROOF.read_text(encoding='utf-8')
        with self.subTest(case='module proof fake declares the headless flag'):
            self.assertIn('var headless := false', module_proof)
        # The proof's keys drive the accessor and the stamp (the
        # default false / null game / missing property / stamp
        # matches DisplayServer / accessor matches the game
        # property / the gate's headless input suppresses the
        # loop). There is no driver tick line key: the RepairTurret
        # driver (B, N2260) waits for A to land and its accessor
        # interface to be fixed. There is no SoundControl mixer
        # key: the updateLoops aggregate (C, N2243) waits for B.
        proof = GAME_HEADLESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'headless_default_false',
            'null_game_headless_false',
            'missing_property_headless_false',
            'headless_after_ready_matches_display_server',
            'accessor_matches_game_property',
            'gate_loop_suppressed_when_headless',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_game_headless(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07GameHeadlessProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_GAME_HEADLESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'headless_default_false',
            'null_game_headless_false',
            'missing_property_headless_false',
            'headless_after_ready_matches_display_server',
            'accessor_matches_game_property',
            'gate_loop_suppressed_when_headless',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
