import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
DESTROY_PAYLOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsDestroyPayloadProof.gd'


class C07TeamsDestroyPayloadTests(unittest.TestCase):
    def test_c07_teams_destroy_payload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2402']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_destroy_payload_state')
        # Teams.destroyPayload (Teams.java:483-488), one slice
        # (main-thread decision 2026-11-22, batch 25 slot 3:
        # @Remote static IS in C07 scope here -- the body is
        # pure deterministic logic, the @Remote annotation is
        # transport metadata only, recorded in the register
        # note, never as a distinguishing expr). The body
        # checks build != null + getPayload/takePayload are a
        # UnitPayload, then dumps the payload and kills its
        # unit. getPayload/takePayload arrive as Callables,
        # dump/kill arrive as frame-writing Callables; no
        # packet is ever sent.
        self.assertEqual(
            ledger['N2402']['java_method'],
            'Teams.destroyPayload()',
        )
        self.assertEqual(
            ledger['N2402']['source_symbols'],
            [
                'source_teams_destroy_payload_state_result.destroyed_payload',
                'source_teams_destroy_payload_state_result.dumped_payloads',
                'source_teams_destroy_payload_state_result.killed_units',
            ],
        )
        for name in ledger['N2402']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        self.assertEqual(ledger['N2402']['runtime_proof'], '/root/C07TeamsDestroyPayloadProof')
        self.assertEqual(
            ledger['N2402']['tests'],
            [
                'test_c07_teams_destroy_payload_registration',
                'test_all_c07_teams_destroy_payload_input_evidence_is_exact',
                'test_teams_destroy_payload_state',
                'test_reference_graph_and_actual_c07_teams_destroy_payload',
            ],
        )
        self.assertTrue(ledger['N2402']['deferred_exprs'])

    def test_all_c07_teams_destroy_payload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2402']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2402']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_destroy_payload_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.destroyPayload (Teams.java:483-488): when the
        # build is present and its payload is a UnitPayload,
        # take the payload, dump it and kill its unit; the
        # frame records the destroyed payload, the dumped
        # payloads and the killed units.
        self.assertIn('static func source_teams_destroy_payload_state(build: Variant, has_unit_payload: bool, take_payload: Callable, dump_payload: Callable, kill_unit: Callable) -> Dictionary:', teams)
        for expr in [
            'if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){',
            'unit.dump();',
            'unit.unit.killed();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no packets): the
        # happy path dumps the payload and kills its unit,
        # a null build does nothing, a non-unit payload is
        # never taken, and a taken payload that is not a
        # record is never dumped or killed; the frame records
        # the destroyed payload, dumped payloads and killed
        # units.
        proof = DESTROY_PAYLOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'destroy_payload_dumps_and_kills_unit_payload',
            'destroy_payload_skips_null_build',
            'destroy_payload_skips_non_unit_payload',
            'destroy_payload_skips_non_dict_payload',
            'destroy_payload_returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_destroy_payload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsDestroyPayloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_DESTROY_PAYLOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'destroy_payload_dumps_and_kills_unit_payload',
            'destroy_payload_skips_null_build',
            'destroy_payload_skips_non_unit_payload',
            'destroy_payload_skips_non_dict_payload',
            'destroy_payload_returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
