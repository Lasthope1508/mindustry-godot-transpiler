import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
IS_CAMPAIGN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07GameStateIsCampaignProof.gd'

PROOF_KEYS = [
    'sector_null_planet_present_is_false',
    'sector_present_planet_null_is_true',
    'both_null_is_false',
    'both_present_is_true',
    'sector_dict_without_planet_is_true',
    'get_planet_fallback_contrast',
    'returns_owner_plus_one_key',
    'idempotent_second_call',
]


class C07GameStateIsCampaignTests(unittest.TestCase):
    def test_c07_game_state_is_campaign_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2474']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_state_is_campaign_state')
        # GameState.isCampaign() (GameState.java:72-75):
        #     /** Note that being in a campaign does not
        #     necessarily mean having a sector. */
        #     public boolean isCampaign(){
        #         return rules.sector != null;
        #     }
        # TRAP: NO fallback to rules.planet (unlike
        # getPlanet(), N2454: `return rules.sector != null ?
        # rules.sector.planet : rules.planet;`) -- sector null
        # is false even when rules.planet is non-null.
        # TWIN-REGISTER (main thread approved explicitly):
        # the literal `return rules.sector != null;` is also
        # an exact_expr of N2124, which cites it only as
        # dependency evidence for unlockedNowHost()
        # (`return !state.isCampaign() || unlockedHost();`,
        # register_unit_factory_should_consume.py:117-120) --
        # N2124 ports NO isCampaign function (its owner is
        # SourceUnitFactoryBuildState). This slice adds the
        # first GD function that computes GameState.isCampaign().
        # Precedent: N2421 (`return isShooting;`), N2389,
        # N2418; N2454's deferred_exprs anticipated this
        # ("twin-register only when main thread approves it
        # explicitly"). hasSector() (:77-79) shares the same
        # literal and stays UNregistered -- it needs its own
        # twin approval. Near names already ported: the N2454
        # 9 accessors (boss/getSector/getPlanet/isEditor/
        # isPlaying/isGame/isMenu/is(State)/getState -- no
        # isCampaign in that compound), hasSpawns N2448,
        # isPaused N2123.
        self.assertEqual(
            ledger['N2474']['java_method'],
            'GameState.isCampaign()',
        )
        self.assertEqual(
            ledger['N2474']['source_symbols'],
            [
                'source_game_state_is_campaign_state_input.rules_sector',
                'source_game_state_is_campaign_state_input.rules_planet',
                'source_game_state_is_campaign_state_result.is_campaign',
            ],
        )
        for name in ledger['N2474']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/GameState.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_state_is_campaign_state'))
        self.assertEqual(ledger['N2474']['runtime_proof'], '/root/C07GameStateIsCampaignProof')
        self.assertEqual(
            ledger['N2474']['tests'],
            [
                'test_c07_game_state_is_campaign_registration',
                'test_all_c07_game_state_is_campaign_input_evidence_is_exact',
                'test_game_state_is_campaign_state',
                'test_reference_graph_and_actual_c07_game_state_is_campaign',
            ],
        )
        self.assertTrue(ledger['N2474']['deferred_exprs'])

    def test_all_c07_game_state_is_campaign_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2474']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_state_is_campaign_state'))
        slice_sources = {
            'core/src/mindustry/core/GameState.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2474']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_game_state_is_campaign_state(self):
        game_loop = GAME_LOOP.read_text(encoding='utf-8')
        # GameState.isCampaign() (GameState.java:72-75):
        #     return rules.sector != null;
        # TRAP: no fallback to rules.planet -- sector null is
        # false even when the planet is non-null (getPlanet(),
        # N2454, DOES fall back). rules_planet is received for
        # signature parity with getPlanet() and to pin the trap;
        # the body deliberately does NOT consult it.
        self.assertIn('static func source_game_state_is_campaign_state(rules_sector: Variant, rules_planet: Variant) -> Dictionary:', game_loop)
        self.assertIn('return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_STATE_IS_CAMPAIGN_STATE, "is_campaign": rules_sector != null}', game_loop)
        # Function order follows Java order: hasSpawns()
        # (:68-70) comes before isCampaign() (:72-75) in
        # GameState.java, so source_game_loop_has_spawns_state
        # comes before source_game_state_is_campaign_state
        # in this file; isCampaign() (:72-75) comes before
        # the N2454 accessors group (boss :56-58 ...
        # getState :115-117, whose function sits after it in
        # this file), so the new function comes before
        # source_game_loop_state_accessors_state.
        self.assertLess(
            game_loop.index('static func source_game_loop_has_spawns_state('),
            game_loop.index('static func source_game_state_is_campaign_state('),
        )
        self.assertLess(
            game_loop.index('static func source_game_state_is_campaign_state('),
            game_loop.index('static func source_game_loop_state_accessors_state('),
        )
        # The proof drives the pure function with synthetic
        # sector/planet pairs (no live tick, no game state):
        # sector null + planet present is false (the trap),
        # sector present + planet null is true, both null is
        # false, both present is true, a sector Dictionary
        # without a planet key is true, and the same
        # (null, "erekir") inputs give planet "erekir"
        # through getPlanet() while isCampaign is false.
        proof = IS_CAMPAIGN_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_game_state_is_campaign(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07GameStateIsCampaignProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_GAME_STATE_IS_CAMPAIGN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
