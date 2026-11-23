import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP_STATE = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
CHECK_CAMPAIGN_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LogicCheckCampaignStatsProof.gd'

PROOF_KEYS = [
    'campaign_stats_campaign_not_client',
    'campaign_stats_not_campaign',
    'campaign_stats_client',
]


class C07LogicCheckCampaignStatsTests(unittest.TestCase):
    def test_c07_logic_check_campaign_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2438']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_loop_check_campaign_stats_state')
        # Logic.checkCampaignStats() (Logic.java:251-253): the `:252`
        # line `return state.isCampaign() && !net.client();` --
        # the pure predicate for whether campaign stats should
        # be recorded (campaign game, not a net client). 0-hit
        # in BOTH ledgers (re-probed at base 91576ded). The
        # call-sites `if(checkCampaignStats()){` in the Logic
        # ctor (Logic.java:163, :196, :206, :212, :223, :232,
        # :239, :245) are NOT registered here -- they belong to
        # the 16 handler ctor slices, waiting on the bus
        # decision. `state.isCampaign()` and `net.client()`
        # are read as frame inputs here; their live reads are
        # later slices.
        self.assertEqual(
            ledger['N2438']['java_method'],
            'Logic.checkCampaignStats()',
        )
        self.assertEqual(
            ledger['N2438']['exact_exprs'],
            [
                'return state.isCampaign() && !net.client();',
            ],
        )
        self.assertEqual(
            ledger['N2438']['source_symbols'],
            [
                'source_game_loop_check_campaign_stats_state_result.campaign_stats',
            ],
        )
        for name in ledger['N2438']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/core/Logic.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_check_campaign_stats_state'))
        self.assertEqual(ledger['N2438']['runtime_proof'], '/root/C07LogicCheckCampaignStatsProof')
        self.assertEqual(
            ledger['N2438']['tests'],
            [
                'test_c07_logic_check_campaign_stats_registration',
                'test_all_c07_logic_check_campaign_stats_input_evidence_is_exact',
                'test_logic_check_campaign_stats_state',
                'test_reference_graph_and_actual_c07_logic_check_campaign_stats',
            ],
        )
        self.assertTrue(ledger['N2438']['deferred_exprs'])

    def test_all_c07_logic_check_campaign_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2438']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_check_campaign_stats_state'))
        slice_sources = {
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2438']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_logic_check_campaign_stats_state(self):
        state = GAME_LOOP_STATE.read_text(encoding='utf-8')
        # The GD function is new (N2438): a pure predicate
        # over the frame inputs, returning the
        # `campaign_stats` envelope key. The exact Java expr
        # is quoted verbatim on its own comment line inside
        # source_game_loop_check_campaign_stats_state (the
        # N2378 precedent: never split an exact expr across
        # lines).
        self.assertIn('static func source_game_loop_check_campaign_stats_state(is_campaign: bool, is_client: bool) -> Dictionary:', state)
        for expr in [
            'return state.isCampaign() && !net.client();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        self.assertIn('"campaign_stats":', state)
        self.assertIn('PORT_GAME_SOURCE_GAME_LOOP_CHECK_CAMPAIGN_STATS_STATE', state)
        # The proof's keys pin the predicate: campaign and
        # not a client -> stats; not a campaign -> no stats;
        # a client -> no stats even in a campaign (the
        # `!net.client()` conjunct).
        proof = CHECK_CAMPAIGN_STATS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_logic_check_campaign_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LogicCheckCampaignStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LOGIC_CHECK_CAMPAIGN_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
