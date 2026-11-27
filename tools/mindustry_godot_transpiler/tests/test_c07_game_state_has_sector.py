import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
HAS_SECTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07GameStateHasSectorProof.gd'

PROOF_KEYS = [
    'sector_null_planet_present_is_false',
    'sector_present_planet_null_is_true',
    'both_null_is_false',
    'both_present_is_true',
    'sector_dict_without_planet_is_true',
    'cross_pin_is_campaign_all_four',
    'returns_owner_plus_one_key',
    'idempotent_second_call',
]


class C07GameStateHasSectorTests(unittest.TestCase):
    def test_c07_game_state_has_sector_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2483']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_state_has_sector_state')
        # GameState.hasSector() (GameState.java:77-79):
        #     public boolean hasSector(){
        #         return rules.sector != null;
        #     }
        # Body IDENTICAL to isCampaign() (:73-75) -- that is
        # the real Java, not a copy error; the two methods
        # sit next to each other. TRAP: NO fallback to
        # rules.planet (unlike getPlanet(), N2454:
        # `return rules.sector != null ? rules.sector.planet
        # : rules.planet;`) -- sector null is false even
        # when rules.planet is non-null.
        # TWIN-REGISTER (main thread approved explicitly
        # 2026-11-27): the literal `return rules.sector !=
        # null;` is already an exact_expr of N2124 (cited
        # there only as dependency evidence for
        # unlockedNowHost(), `return !state.isCampaign() ||
        # unlockedHost();`, register_unit_factory_should_consume.py:117-120)
        # AND of N2474 (isCampaign -- the twin sibling,
        # twin-registered with its own approval 2026-11-26).
        # N2124 is the original owner of the literal; it
        # ports NO hasSector function (its owner is
        # SourceUnitFactoryBuildState) and N2474 ports
        # isCampaign, not hasSector. N2474's deferred_exprs
        # anticipated exactly this ("GameState.hasSector()
        # (GameState.java:77-79) is NOT in this slice: it
        # shares the literal ... and needs its own
        # twin-register approval"). Precedent: N2474,
        # N2421 (`return isShooting;`), N2389, N2418.
        # The only `has_sector` hit in the registry before
        # this slice is the unrelated TeamData symbol
        # source_team_data_time_destroy_state_result.has_sector.
        self.assertEqual(
            ledger['N2483']['java_method'],
            'GameState.hasSector()',
        )
        self.assertEqual(
            ledger['N2483']['source_symbols'],
            [
                'source_game_state_has_sector_state_input.rules_sector',
                'source_game_state_has_sector_state_input.rules_planet',
                'source_game_state_has_sector_state_result.has_sector',
            ],
        )
        for name in ledger['N2483']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/GameState.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_state_has_sector_state'))
        self.assertEqual(ledger['N2483']['runtime_proof'], '/root/C07GameStateHasSectorProof')
        self.assertEqual(
            ledger['N2483']['tests'],
            [
                'test_c07_game_state_has_sector_registration',
                'test_all_c07_game_state_has_sector_input_evidence_is_exact',
                'test_game_state_has_sector_state',
                'test_reference_graph_and_actual_c07_game_state_has_sector',
            ],
        )
        self.assertTrue(ledger['N2483']['deferred_exprs'])

    def test_all_c07_game_state_has_sector_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2483']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_state_has_sector_state'))
        slice_sources = {
            'core/src/mindustry/core/GameState.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2483']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_game_state_has_sector_state(self):
        game_loop = GAME_LOOP.read_text(encoding='utf-8')
        # GameState.hasSector() (GameState.java:77-79):
        #     return rules.sector != null;
        # TRAP: no fallback to rules.planet -- sector null is
        # false even when the planet is non-null (getPlanet(),
        # N2454, DOES fall back). rules_planet is received for
        # signature parity with getPlanet() / isCampaign()
        # (N2474) and to pin the trap; the body deliberately
        # does NOT consult it.
        self.assertIn('static func source_game_state_has_sector_state(rules_sector: Variant, rules_planet: Variant) -> Dictionary:', game_loop)
        self.assertIn('return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_STATE_HAS_SECTOR_STATE, "has_sector": rules_sector != null}', game_loop)
        # Function order follows Java order: isCampaign()
        # (:73-75) comes before hasSector() (:77-79) in
        # GameState.java, so source_game_state_is_campaign_state
        # comes before source_game_state_has_sector_state in
        # this file; hasSector() (:77-79) comes before the
        # N2454 accessors group (getSector :81-83 ...), so
        # the new function comes before
        # source_game_loop_state_accessors_state.
        self.assertLess(
            game_loop.index('static func source_game_state_is_campaign_state('),
            game_loop.index('static func source_game_state_has_sector_state('),
        )
        self.assertLess(
            game_loop.index('static func source_game_state_has_sector_state('),
            game_loop.index('static func source_game_loop_state_accessors_state('),
        )
        # The proof drives the pure function with synthetic
        # sector/planet pairs (no live tick, no game state)
        # and cross-pins it against isCampaign (N2474): the
        # same inputs give the same result on all 4
        # combinations, because the two Java bodies are
        # identical. A sector Dictionary without a "planet"
        # key is still a sector -- presence, not contents,
        # decides.
        proof = HAS_SECTOR_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_game_state_has_sector(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07GameStateHasSectorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_GAME_STATE_HAS_SECTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
