import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAM_STATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamStateProof.gd'


class C07TeamStateTests(unittest.TestCase):
    def test_c07_team_state_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2450']['godot_owner'], 'SourceTeamsRuntimeState.source_team_state')
        # Team.items()+data()+core()+active()+isAlive()+isOnlyAI()
        # +needsFlowField()+cores() (Team.java:83-133), one grouped
        # slice (main-thread decision 2026-11-23, the N2390/N2395
        # group precedent): eight one-line forwards, one record,
        # eight java_method entries, one shared owner.
        # `public ItemModule items(){`
        # `return core() == null ? ItemModule.empty : core().items;`
        # `public TeamData data(){`
        # `return state.teams.get(this);`
        # `@Nullable`
        # `public CoreBuild core(){`
        # `return data().core();`
        # `public boolean active(){`
        # `return state.teams.isActive(this);`
        # `public boolean isAlive(){`
        # `return data().isAlive();`
        # `public boolean isOnlyAI(){`
        # `return isAI() && data().players.size == 0;`
        # `public boolean needsFlowField(){`
        # `return isAI() && !rules().rtsAi;`
        # `public Seq<CoreBuild> cores(){`
        # `return state.teams.cores(this);`
        # isAI() (:112-114) + activateUnitFactories() (:127-129)
        # are NOT ported here: both are already the exact_exprs
        # of N2124. rules() (:89) is NOT ported here: its only
        # line is the twin exact_expr of N2099+N2107, and
        # needsFlowField takes rts_ai as an explicit input.
        # localized() + coloredName() are NOT ported here: they
        # wait for the i18n decision (batch 43+). items()
        # computes core() once and reuses it (Java calls core()
        # twice in one expr). Eight domain result symbols plus
        # the teams_state housekeeping symbol (the N2380
        # precedent: get/cores/is_active all return it).
        self.assertEqual(
            ledger['N2450']['java_method'],
            'Team.items()/data()/core()/active()/isAlive()/isOnlyAI()/needsFlowField()/cores()',
        )
        self.assertEqual(
            ledger['N2450']['source_symbols'],
            [
                'source_team_state_result.items',
                'source_team_state_result.data',
                'source_team_state_result.core',
                'source_team_state_result.active',
                'source_team_state_result.is_alive',
                'source_team_state_result.is_only_ai',
                'source_team_state_result.needs_flow_field',
                'source_team_state_result.cores',
                'source_team_state_result.teams_state',
            ],
        )
        for name in ledger['N2450']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Team.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_team_state')
        self.assertEqual(ledger['N2450']['runtime_proof'], '/root/C07TeamStateProof')
        self.assertEqual(
            ledger['N2450']['tests'],
            [
                'test_c07_team_state_registration',
                'test_all_c07_team_state_input_evidence_is_exact',
                'test_team_state',
                'test_reference_graph_and_actual_c07_team_state',
            ],
        )
        self.assertTrue(ledger['N2450']['deferred_exprs'])

    def test_all_c07_team_state_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2450']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_team_state')
        slice_sources = {
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2450']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Team.items()+data()+core()+active()+isAlive()+isOnlyAI()
        # +needsFlowField()+cores() (Team.java:83-133): the grouped
        # forward calls the three Teams funcs already live
        # (source_teams_get_state, source_teams_cores_state,
        # source_teams_is_active_state) plus the liveness func
        # (source_team_data_liveness_state) for core/is_alive,
        # and reads players from the TeamData dict for isOnlyAI.
        # isAI() is N2124 (another file), so it arrives as the
        # explicit is_ai input; rules().rtsAi arrives as the
        # explicit rts_ai input (rules() itself is a twin, not
        # re-ported). items() computes core() once: the first
        # core's items dict, or {} when there is no core
        # (ItemModule.empty).
        self.assertIn('static func source_team_state(teams_state: Dictionary, team_id: int, is_ai: bool, rts_ai: bool) -> Dictionary:', teams)
        self.assertIn('return {"items": items, "data": data, "core": core, "active": is_active, "is_alive": is_alive, "is_only_ai": is_only_ai, "needs_flow_field": needs_flow_field, "cores": cores, "teams_state": teams_state}', teams)
        for expr in [
            'public class Team implements Comparable<Team>, Senseable{',
            'public ItemModule items(){',
            'return core() == null ? ItemModule.empty : core().items;',
            'public TeamData data(){',
            'return state.teams.get(this);',
            '@Nullable',
            'public CoreBuild core(){',
            'return data().core();',
            'public boolean active(){',
            'return state.teams.isActive(this);',
            'public boolean isAlive(){',
            'return data().isAlive();',
            'public boolean isOnlyAI(){',
            'return isAI() && data().players.size == 0;',
            'public boolean needsFlowField(){',
            'return isAI() && !rules().rtsAi;',
            'public Seq<CoreBuild> cores(){',
            'return state.teams.cores(this);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with synthetic
        # teams_state dicts (no live tick): items empty with no
        # core / items from the first core / data is the TeamData
        # dict / core is the first core or null / active true
        # with cores / false when empty / isAlive delegates to
        # hasCore / isOnlyAI true only for AI with no players /
        # false with players / false when not AI / needsFlowField
        # true for AI without rtsAi / false with rtsAi / false
        # when not AI / cores returns the cores Array / the
        # result carries only its nine keys in pinned order.
        proof = TEAM_STATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'items_empty_when_no_core',
            'items_from_first_core',
            'data_returns_team_data',
            'core_first_when_present',
            'core_null_when_empty',
            'active_true_with_cores',
            'active_false_when_empty',
            'is_alive_delegates_has_core',
            'is_only_ai_true_ai_no_players',
            'is_only_ai_false_with_players',
            'is_only_ai_false_when_not_ai',
            'needs_flow_field_true_ai_no_rts',
            'needs_flow_field_false_when_rts_ai',
            'needs_flow_field_false_when_not_ai',
            'cores_returns_cores',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_state(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamStateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_STATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'items_empty_when_no_core',
            'items_from_first_core',
            'data_returns_team_data',
            'core_first_when_present',
            'core_null_when_empty',
            'active_true_with_cores',
            'active_false_when_empty',
            'is_alive_delegates_has_core',
            'is_only_ai_true_ai_no_players',
            'is_only_ai_false_with_players',
            'is_only_ai_false_when_not_ai',
            'needs_flow_field_true_ai_no_rts',
            'needs_flow_field_false_when_rts_ai',
            'needs_flow_field_false_when_not_ai',
            'cores_returns_cores',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
