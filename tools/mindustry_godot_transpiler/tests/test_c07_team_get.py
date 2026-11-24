import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAM_GET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamGetProof.gd'

PROOF_KEYS = [
    'base_id_direct',
    'wrap_256_to_zero',
    'negative_id_wraps',
    'wrap_plus_one',
    'team_get_returns_two_keys',
    'team_get_idempotent_second_call',
]


class C07TeamGetTests(unittest.TestCase):
    def test_c07_team_get_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2456']['godot_owner'], 'SourceTeamsRuntimeState.source_team_get_state')
        # Team.get(int) (Team.java:58-60): the 2 distinct body
        # exprs only -- `public static Team get(int id){` (:58)
        # and `return all[((byte)id) & 0xff];` (:59). The (byte)
        # cast keeps only the low 8 bits, then & 0xff makes the
        # index unsigned, so the id wraps modulo 256: 256 -> 0,
        # -1 -> 255, -256 -> 0, 257 -> 1. GD takes the 256-entry
        # Team.all array (Team.java:27-28) as an Array input
        # (option (A) data-driven, precedent N2453/N2455) and does
        # not build the 256 teams itself: the static init at
        # Team.java:43-56 (with its Mathf.rand seed) belongs to a
        # later slice. Call-sites (BuildingComp.setProp,
        # SpawnGroup.read) are NOT registered here.
        self.assertEqual(
            ledger['N2456']['java_method'],
            'Team.get(int)',
        )
        self.assertEqual(
            ledger['N2456']['source_symbols'],
            [
                'source_team_get_state_result.team',
                'source_team_get_state_result.wrapped_id',
            ],
        )
        for name in ledger['N2456']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Team.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_get_state'))
        self.assertEqual(ledger['N2456']['runtime_proof'], '/root/C07TeamGetProof')
        self.assertEqual(
            ledger['N2456']['tests'],
            [
                'test_c07_team_get_registration',
                'test_all_c07_team_get_input_evidence_is_exact',
                'test_team_get_state',
                'test_reference_graph_and_actual_c07_team_get',
            ],
        )
        self.assertTrue(ledger['N2456']['deferred_exprs'])

    def test_all_c07_team_get_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2456']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_get_state'))
        slice_sources = {
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2456']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_get_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Team.get(int) (Team.java:58-60): the 2 distinct body
        # exprs only. GD takes the already-built 256-entry Team.all
        # array as an Array input (option (A) data-driven,
        # precedent N2453/N2455) and does not build the teams
        # itself: the static init is NOT ported and belongs to a
        # later slice. GDScript's % keeps the dividend's sign, so
        # the double modulo ((id % 256) + 256) % 256 reproduces
        # the Java ((byte)id) & 0xff wrap for every int, including
        # negatives -- a single % or a direct & 0xff would be wrong
        # for id < 0.
        self.assertIn('static func source_team_get_state(all_teams: Array, id: int) -> Dictionary:', teams)
        self.assertIn('return {"team": all_teams[wrapped_id], "wrapped_id": wrapped_id}', teams)
        # The proof's keys drive the pure function with a synthetic
        # 256-team array (no live tick, no Teams state, no static
        # init): base ids hit directly, 256 wraps to 0, -1 wraps
        # to 255, -256 wraps to 0, 257/514 wrap to 1/2, exactly 2
        # result keys, and a second call on the same inputs yields
        # the same value.
        proof = TEAM_GET_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_get(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamGetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_GET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
