import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
GROUP_COUNTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitGroupCountsProof.gd'


class C07UnitGroupCountsTests(unittest.TestCase):
    def test_c07_unit_group_counts_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2141']['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_update_count_state')
        # N2140 left the frame without live per-type unit counts:
        # the canCreate helper reads frame["team_unit_counts"]
        # (default 0 for a missing unit, exactly
        # TeamData.countType, Teams.java:442-444) but no frame
        # records it yet. N2141 is the unit-group slice: a pure
        # TeamData.updateCount (Teams.java:429-436) with the
        # countType read-back, plus a pure updateTeamStats rebuild
        # for one team (Teams.java:182-245) that resets the counts
        # and recounts every live unit of that team, recursing
        # into payload units exactly as Teams.count(unit)
        # (Teams.java:168-179). The tick driver stamps the
        # rebuilt frame["team_unit_counts"] before the assembler
        # can_create call, so the N2140 predicate finally reads
        # live counts instead of the 0 default. Five new result
        # symbols: three for updateCount, two for the stats
        # rebuild.
        self.assertEqual(
            ledger['N2141']['source_symbols'],
            [
                'source_team_data_update_count_state_result.type_counts',
                'source_team_data_update_count_state_result.unit_count',
                'source_team_data_update_count_state_result.count_type',
                'source_team_data_update_team_stats_state_result.team_unit_counts',
                'source_team_data_update_team_stats_state_result.unit_count',
            ],
        )
        for name in ledger['N2141']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Teams.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_team_data_update_count_state_result.type_counts': 'SourceTeamsRuntimeState.source_team_data_update_count_state',
                    'source_team_data_update_count_state_result.unit_count': 'SourceTeamsRuntimeState.source_team_data_update_count_state',
                    'source_team_data_update_count_state_result.count_type': 'SourceTeamsRuntimeState.source_team_data_update_count_state',
                    'source_team_data_update_team_stats_state_result.team_unit_counts': 'SourceTeamsRuntimeState.source_team_data_update_team_stats_state',
                    'source_team_data_update_team_stats_state_result.unit_count': 'SourceTeamsRuntimeState.source_team_data_update_team_stats_state',
                }[name])
        self.assertEqual(ledger['N2141']['runtime_proof'], '/root/C07UnitGroupCountsProof')
        self.assertEqual(
            ledger['N2141']['tests'],
            [
                'test_c07_unit_group_counts_registration',
                'test_all_c07_unit_group_counts_input_evidence_is_exact',
                'test_team_data_update_count_state',
                'test_reference_graph_and_actual_c07_unit_group_counts',
            ],
        )
        self.assertTrue(ledger['N2141']['deferred_exprs'])

    def test_all_c07_unit_group_counts_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2141']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_team_data_update_count_state_result.type_counts': 'SourceTeamsRuntimeState.source_team_data_update_count_state',
                    'source_team_data_update_count_state_result.unit_count': 'SourceTeamsRuntimeState.source_team_data_update_count_state',
                    'source_team_data_update_count_state_result.count_type': 'SourceTeamsRuntimeState.source_team_data_update_count_state',
                    'source_team_data_update_team_stats_state_result.team_unit_counts': 'SourceTeamsRuntimeState.source_team_data_update_team_stats_state',
                    'source_team_data_update_team_stats_state_result.unit_count': 'SourceTeamsRuntimeState.source_team_data_update_team_stats_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/entities/comp/PayloadComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2141']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_data_update_count_state(self):
        state = TEAMS_STATE.read_text(encoding='utf-8')
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        # The pure updateCount grows typeCounts to the content
        # unit count, clamps both counts at 0, and reads the
        # updated per-type count back through countType; the
        # pure updateTeamStats rebuild resets unitCount and
        # typeCounts, then recounts every live unit of the team
        # (payload units included) into frame team_unit_counts.
        self.assertIn('static func source_team_data_update_count_state', state)
        self.assertIn('static func source_team_data_update_team_stats_state', state)
        self.assertIn('unitCount = Math.max(amount + unitCount, 0);', state)
        self.assertIn('typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);', state)
        self.assertIn('return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];', state)
        self.assertIn('data.unitCount = 0;', state)
        self.assertIn('count(unit);', state)
        # The tick driver stamps the rebuilt team_unit_counts
        # into the frame before the assembler can_create call,
        # so the N2140 predicate reads live counts; the stale
        # "no per-type counts" comment is gone.
        self.assertIn('source_team_data_update_team_stats_state(', factory)
        self.assertNotIn('the frame still records no', factory)
        # The proof's keys drive both pure functions directly:
        # add / add-existing / remove-clamp / grow-array /
        # null-counts for updateCount, per-team counting and
        # payload recursion for the stats rebuild.
        proof = GROUP_COUNTS_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_count_add_grows',
            'update_count_add_existing',
            'update_count_remove_clamps_zero',
            'update_count_grows_array',
            'count_type_null_counts',
            'update_team_stats_counts_units',
            'update_team_stats_payload_recursion',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_unit_group_counts(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitGroupCountsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_GROUP_COUNTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'update_count_add_grows',
            'update_count_add_existing',
            'update_count_remove_clamps_zero',
            'update_count_grows_array',
            'count_type_null_counts',
            'update_team_stats_counts_units',
            'update_team_stats_payload_recursion',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
