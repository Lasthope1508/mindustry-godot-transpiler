import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAMS_UPDATE_TEAM_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsUpdateTeamStatsProof.gd'

EXACT_EXPRS = [
    'present.clear();',
    'bosses.clear();',
    'data.presentFlag = data.buildings.size > 0;',
    'data.units.clear();',
    'data.players.clear();',
    'if(data.cores.size > 0){',
    'data.lastCore = data.cores.first();',
    'if(data.unitTree != null){',
    'data.unitTree.clear();',
    'if(data.unitsByType != null){',
    'for(int i = 0; i < data.unitsByType.length; i++){',
    'if(data.unitsByType[i] != null){',
    'data.unitsByType[i].clear();',
    'if(unit.type == null) continue;',
    'TeamData data = unit.team.data();',
    'data.presentFlag = true;',
    'if(unit.team == state.rules.waveTeam && unit.isBoss()){',
    'bosses.add(unit);',
    'if(data.unitsByType == null || data.unitsByType.length <= unit.type.id){',
    'data.unitsByType = new Seq[content.units().size];',
    'if(data.unitsByType[unit.type.id] == null){',
    'data.unitsByType[unit.type.id] = new Seq<>();',
    'data.unitsByType[unit.type.id].add(unit);',
    'count(unit);',
    'for(var player : Groups.player){',
    'player.team().data().players.add(player);',
    'if(data.presentFlag || data.active()){',
    'present.add(data);',
]

PROOF_KEYS = [
    'reset_clears_stale_units_and_players',
    'reset_present_flag_from_buildings',
    'reset_last_core_first_core',
    'reset_clears_unit_tree_then_inserts',
    'reset_zeroes_type_counts',
    'reset_clears_units_by_type_entries',
    'units_by_type_grows_to_content_size',
    'null_type_unit_skipped',
    'count_recurses_payload_units',
    'wave_team_boss_in_bosses',
    'non_wave_boss_not_in_bosses',
    'players_grouped_by_team',
    'present_includes_present_teams',
    'present_excludes_absent_team',
    'present_flag_set_by_units',
    'returns_only_four_keys',
]


class C07TeamsUpdateTeamStatsTests(unittest.TestCase):
    def test_c07_teams_update_team_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2383']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_update_team_stats_state')
        # Teams.updateTeamStats() (Teams.java:181-251), the
        # full multi-team rebuild: reset every tracked
        # team's data (presentFlag from buildings, units /
        # players cleared, lastCore, unitTree cleared,
        # unitsByType entries cleared), recount every live
        # unit (tree insert, units add, presentFlag, wave
        # bosses, unitsByType grow/alloc/add, count(unit)),
        # group players by team, rebuild present from
        # presentFlag || active(). 28 new exact_exprs
        # (re-probed at base 0ac2993f, 0-hit in both
        # ledgers). NOT re-registered (evidence/bridge
        # only): the header `public void updateTeamStats(){`
        # + `data.unitCount = 0;` +
        # `if(data.typeCounts != null){` +
        # `Arrays.fill(data.typeCounts, 0);` +
        # `for(Unit unit : Groups.unit){` +
        # `data.units.add(unit);` + helper `count(Unit)` --
        # all already the exact_exprs of N2141; the loop
        # header `for(Team team : Team.all){` -- already the
        # exact_expr of N1356 (Block.load); `data.tree()`
        # is the unitTree explicit param (the QuadTree is
        # modeled as its inserted-unit list, created lazily
        # exactly as tree() does, Teams.java:437-439);
        # `TeamData.active()` is already the exact_expr of
        # N2074/N2075 -- the file's `_teams_active` helper
        # is that callee. Four new result symbols.
        self.assertEqual(
            ledger['N2383']['java_method'],
            'Teams.updateTeamStats()',
        )
        self.assertEqual(
            ledger['N2383']['source_symbols'],
            [
                'source_teams_update_team_stats_state_result.teams_state',
                'source_teams_update_team_stats_state_result.present',
                'source_teams_update_team_stats_state_result.bosses',
                'source_teams_update_team_stats_state_result.unit_counts_by_team',
            ],
        )
        for name in ledger['N2383']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_update_team_stats_state'))
        self.assertEqual(ledger['N2383']['runtime_proof'], '/root/C07TeamsUpdateTeamStatsProof')
        self.assertEqual(
            ledger['N2383']['tests'],
            [
                'test_c07_teams_update_team_stats_registration',
                'test_all_c07_teams_update_team_stats_input_evidence_is_exact',
                'test_teams_update_team_stats_state',
                'test_reference_graph_and_actual_c07_teams_update_team_stats',
            ],
        )
        self.assertTrue(ledger['N2383']['deferred_exprs'])

    def test_all_c07_teams_update_team_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2383']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_update_team_stats_state'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2383']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_update_team_stats_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.updateTeamStats() (Teams.java:181-251): the
        # full multi-team rebuild -- reset, recount, group
        # players, rebuild present. present/bosses arrive as
        # the frame's in/out Seqs (cleared first, rebuilt in
        # place); units/players arrive as explicit record
        # Arrays; state.rules.waveTeam and
        # content.units().size arrive as explicit params;
        # Team.all is the teams_state["teams"] keys.
        self.assertIn('static func source_teams_update_team_stats_state(teams_state: Dictionary, units: Array, players: Array, wave_team_id: int, content_unit_size: int, present: Array, bosses: Array) -> Dictionary:', teams)
        for expr in EXACT_EXPRS:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof drives the pure function with synthetic
        # teams_state dicts (no live tick): stale units /
        # players / type counts / unit-tree inserts /
        # unitsByType entries are cleared by the reset; the
        # wave-team boss lands in bosses and a non-wave boss
        # does not; the null-type unit is skipped; count()
        # recurses into payload units; players group by
        # team; present is rebuilt from presentFlag ||
        # active() in teams_state key order.
        proof = TEAMS_UPDATE_TEAM_STATS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_update_team_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsUpdateTeamStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_UPDATE_TEAM_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
