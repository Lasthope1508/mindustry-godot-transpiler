import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
COLORED_NAME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamColoredNameProof.gd'

PROOF_KEYS = [
    'colored_name_sharded',
    'colored_name_with_emoji',
    'colored_name_empty_localized',
    'colored_name_markup_literals_verbatim',
    'colored_name_concat_order',
    'colored_name_localized_is_precomputed_input',
    'colored_name_idempotent',
    'colored_name_returns_only_one_key',
]


class C07TeamColoredNameTests(unittest.TestCase):
    def test_c07_team_colored_name_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2488']['godot_owner'], 'SourceTeamsRuntimeState.source_team_colored_name_state')
        # Team.coloredName() (Team.java:139-141):
        #     public String coloredName(){
        #         return emoji + "[#" + color + "]" + localized() + "[]";
        #     }
        # The field `emoji` is `public String` (Team.java:23,
        # default "") and `color` is `public final Color`
        # (Team.java:18). The "[#" + color + "]" segment
        # stringifies the arc Color via Color.toString()
        # (arc-core Color.java:769-779): RRGGBBAA, 8 hex
        # chars -- so the color arrives as a precomputed hex
        # string, not a Color object. localized() (:135-137)
        # is `Core.bundle.get("team." + name + ".name",
        # name)` -- NOT ported here; its value arrives as a
        # precomputed input (the precomputed-input precedent).
        # The 3 coloredName hits in exact_exprs (N548 /
        # N1864 / N2268) are all CALL-SITES
        # (player.coloredName(), getPlayer().coloredName())
        # -- no slice owns this method, so no twin-register.
        self.assertEqual(
            ledger['N2488']['java_method'],
            'Team.coloredName()',
        )
        self.assertEqual(
            ledger['N2488']['source_symbols'],
            [
                'source_team_colored_name_state_input.emoji',
                'source_team_colored_name_state_input.color_hex',
                'source_team_colored_name_state_input.localized_name',
                'source_team_colored_name_state_result.colored_name',
            ],
        )
        for name in ledger['N2488']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Team.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_colored_name_state'))
        self.assertEqual(ledger['N2488']['runtime_proof'], '/root/C07TeamColoredNameProof')
        self.assertEqual(
            ledger['N2488']['tests'],
            [
                'test_c07_team_colored_name_registration',
                'test_all_c07_team_colored_name_input_evidence_is_exact',
                'test_team_colored_name_state',
                'test_reference_graph_and_actual_c07_team_colored_name',
            ],
        )
        self.assertTrue(ledger['N2488']['deferred_exprs'])

    def test_all_c07_team_colored_name_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2488']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_colored_name_state'))
        slice_sources = {
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2488']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_colored_name_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Team.coloredName() (Team.java:139-141) is plain
        # string concatenation: emoji + "[#" + color + "]"
        # + localized() + "[]". No guard, no clamp, no
        # escaping: an empty emoji contributes nothing, an
        # empty localized leaves "[#...][]", and the "[#",
        # "]", "[]" markup literals pass through verbatim.
        # The color is the arc Color.toString() hex
        # (RRGGBBAA), so it arrives as a String input, and
        # localized() arrives precomputed (Core.bundle is
        # not ported in this slice).
        self.assertIn('static func source_team_colored_name_state(emoji: String, color_hex: String, localized_name: String) -> Dictionary:', teams)
        self.assertIn('return {"colored_name": colored_name}', teams)
        # Function order follows Java order: Team.get()
        # (:58-60) comes before coloredName() (:139-141),
        # which comes before compareTo() (:159-162), so
        # source_team_colored_name_state sits between
        # source_team_get_state and
        # source_team_compare_to_state in this file.
        self.assertLess(
            teams.index('static func source_team_get_state('),
            teams.index('static func source_team_colored_name_state('),
        )
        self.assertLess(
            teams.index('static func source_team_colored_name_state('),
            teams.index('static func source_team_compare_to_state('),
        )
        # The proof drives the pure function with synthetic
        # string inputs (no live tick, no game state):
        # sharded with the default empty emoji, a team with
        # an emoji glyph, an empty localized name, the "[#"
        # / "]" / "[]" markup literals verbatim, the concat
        # order emoji < color markup < localized, the
        # localized value used verbatim as a precomputed
        # input, idempotence, and exactly one result key.
        proof = COLORED_NAME_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_colored_name(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamColoredNameProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_COLORED_NAME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
