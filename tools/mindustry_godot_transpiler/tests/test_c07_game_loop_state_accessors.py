import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
STATE_ACCESSORS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07GameLoopStateAccessorsProof.gd'

PROOF_KEYS = [
    'boss_first_when_bosses_nonempty',
    'boss_null_when_bosses_empty',
    'sector_returns_rules_sector',
    'sector_null_when_no_sector',
    'planet_from_sector_when_sector_present',
    'planet_falls_back_to_rules_planet_when_no_sector',
    'is_editor_true_when_rules_editor',
    'is_editor_false_when_not_editor',
    'is_playing_true_when_playing',
    'is_playing_false_when_paused',
    'is_game_true_when_playing',
    'is_game_false_when_menu',
    'is_menu_true_when_menu',
    'is_menu_false_when_playing',
    'is_state_true_when_equal',
    'is_state_false_when_different',
    'state_returns_state_name',
    'returns_owner_plus_nine_keys',
    'idempotent_second_call',
]


class C07GameLoopStateAccessorsTests(unittest.TestCase):
    def test_c07_game_loop_state_accessors_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2454']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_loop_state_accessors_state')
        # GameState 9 accessors (GameState.java:56-117), one grouped
        # slice (batch 43 slot 3): exactly the 9 body exprs
        # `:57` `return teams.bosses.firstOpt();`,
        # `:82` `return rules.sector;`,
        # `:86` `return rules.sector != null ? rules.sector.planet : rules.planet;`,
        # `:90` `return rules.editor;`,
        # `:99` `return state == State.playing;`,
        # `:104` `return state != State.menu;`,
        # `:108` `return state == State.menu;`,
        # `:112` `return state == astate;`,
        # `:116` `return state;`.
        # `state` is a private Java field, so it arrives as the
        # state_name String input ("paused"/"playing"/"menu");
        # `rules` arrives as its fields (rules_sector /
        # rules_planet / rules_editor); `teams.bosses` arrives
        # as the bosses Array. isPaused() :94 is NOT here --
        # N2123 owns it; isCampaign() :74 / hasSector() :78
        # share the literal `return rules.sector != null;`
        # already owned by N2124 -- NOT registered here;
        # set(State) :62/:64/:65 waits for the event-bus
        # decision; hasSpawns() :69 is N2448.
        self.assertEqual(
            ledger['N2454']['java_method'],
            'GameState.boss()/getSector()/getPlanet()/isEditor()/isPlaying()/isGame()/isMenu()/is(State)/getState()',
        )
        self.assertEqual(
            ledger['N2454']['source_symbols'],
            [
                'source_game_loop_state_accessors_state_result.boss',
                'source_game_loop_state_accessors_state_result.sector',
                'source_game_loop_state_accessors_state_result.planet',
                'source_game_loop_state_accessors_state_result.is_editor',
                'source_game_loop_state_accessors_state_result.is_playing',
                'source_game_loop_state_accessors_state_result.is_game',
                'source_game_loop_state_accessors_state_result.is_menu',
                'source_game_loop_state_accessors_state_result.is_state',
                'source_game_loop_state_accessors_state_result.state',
            ],
        )
        for name in ledger['N2454']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/GameState.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_state_accessors_state'))
        self.assertEqual(ledger['N2454']['runtime_proof'], '/root/C07GameLoopStateAccessorsProof')
        self.assertEqual(
            ledger['N2454']['tests'],
            [
                'test_c07_game_loop_state_accessors_registration',
                'test_all_c07_game_loop_state_accessors_input_evidence_is_exact',
                'test_game_loop_state_accessors_state',
                'test_reference_graph_and_actual_c07_game_loop_state_accessors',
            ],
        )
        self.assertTrue(ledger['N2454']['deferred_exprs'])

    def test_all_c07_game_loop_state_accessors_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2454']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_state_accessors_state'))
        slice_sources = {
            'core/src/mindustry/core/GameState.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2454']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_game_loop_state_accessors_state(self):
        game_loop = GAME_LOOP.read_text(encoding='utf-8')
        # GameState 9 accessors (GameState.java:56-117): the 9 body
        # exprs only -- boss() :57, getSector() :82, getPlanet()
        # :86, isEditor() :90, isPlaying() :99, isGame() :104,
        # isMenu() :108, is(State) :112, getState() :116.
        # isPaused() :94 is NOT in this slice -- N2123 owns it.
        # isCampaign() :74 / hasSector() :78 are NOT here -- the
        # shared literal is owned by N2124. set(State) :62/:64/:65
        # is NOT here -- it waits for the event-bus decision.
        self.assertIn('static func source_game_loop_state_accessors_state(state_name: String, astate_name: String, rules_sector: Variant, rules_planet: Variant, rules_editor: bool, bosses: Array) -> Dictionary:', game_loop)
        for expr in [
            'return teams.bosses.firstOpt();',
            'return rules.sector;',
            'return rules.sector != null ? rules.sector.planet : rules.planet;',
            'return rules.editor;',
            'return state == State.playing;',
            'return state != State.menu;',
            'return state == State.menu;',
            'return state == astate;',
            'return state;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, game_loop)
        self.assertIn('bosses[0]', game_loop)
        self.assertIn('state_name == "playing"', game_loop)
        self.assertIn('state_name != "menu"', game_loop)
        self.assertIn('state_name == "menu"', game_loop)
        self.assertIn('state_name == astate_name', game_loop)
        # The proof's keys drive the pure function with synthetic
        # frame inputs (no live tick, no game): boss is the first
        # boss or null when empty; sector passes through; planet
        # comes from the sector when present, else rules.planet;
        # is_editor passes through; the four state predicates
        # read state_name ("paused"/"playing"/"menu"); is_state
        # compares state_name with astate_name; state returns
        # state_name; exactly the 9 payload keys plus the
        # source_owner envelope key, and a second call on the
        # same inputs yields the same value.
        proof = STATE_ACCESSORS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_game_loop_state_accessors(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07GameLoopStateAccessorsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_GAME_LOOP_STATE_ACCESSORS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
