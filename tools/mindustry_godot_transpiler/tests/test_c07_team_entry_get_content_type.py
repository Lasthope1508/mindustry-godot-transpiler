import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTENT_REGISTRY_STATE = ROOT / 'godot-mindustry/src/game/SourceContentRegistryRuntimeState.gd'
GET_CONTENT_TYPE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamEntryGetContentTypeProof.gd'

PROOF_KEYS = [
    'content_type_is_team',
    'content_type_returns_only_one_key',
    'content_type_is_string',
    'content_type_not_block',
    'content_type_not_item',
    'content_type_qualified_name',
    'content_type_deterministic',
    'content_type_is_enum_constant',
]


class C07TeamEntryGetContentTypeTests(unittest.TestCase):
    def test_c07_team_entry_get_content_type_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2493']['godot_owner'], 'SourceContentRegistryRuntimeState.source_team_entry_get_content_type_state')
        # TeamEntry.getContentType() (TeamEntry.java:27-29):
        #     @Override
        #     public ContentType getContentType(){
        #         return ContentType.team;
        #     }
        # on `public class TeamEntry extends
        # UnlockableContent` (TeamEntry.java:9) -- "only
        # for displaying team lore in the content
        # database". One line, returns the constant enum
        # ContentType.team. GD models the enum by its
        # qualified Java name string (the N1319
        # precedent: Block.getContentType returns
        # "ContentType.block"). ContentType.team is the
        # enum constant with folderName "teams" and
        # contentClass TeamEntry.class
        # (ContentType.java:27).
        self.assertEqual(
            ledger['N2493']['java_method'],
            'TeamEntry.getContentType()',
        )
        self.assertEqual(
            ledger['N2493']['source_symbols'],
            [
                'source_team_entry_get_content_type_state_result.content_type',
            ],
        )
        for name in ledger['N2493']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/type/TeamEntry.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceContentRegistryRuntimeState.source_team_entry_get_content_type_state'))
        self.assertEqual(ledger['N2493']['runtime_proof'], '/root/C07TeamEntryGetContentTypeProof')
        self.assertEqual(
            ledger['N2493']['tests'],
            [
                'test_c07_team_entry_get_content_type_registration',
                'test_all_c07_team_entry_get_content_type_input_evidence_is_exact',
                'test_team_entry_get_content_type_state',
                'test_reference_graph_and_actual_c07_team_entry_get_content_type',
            ],
        )
        self.assertTrue(ledger['N2493']['deferred_exprs'])

    def test_all_c07_team_entry_get_content_type_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2493']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceContentRegistryRuntimeState.source_team_entry_get_content_type_state'))
        slice_sources = {
            'core/src/mindustry/type/TeamEntry.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2493']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_entry_get_content_type_state(self):
        registry_state = CONTENT_REGISTRY_STATE.read_text(encoding='utf-8')
        # TeamEntry.getContentType() (TeamEntry.java:27-29)
        # returns the constant ContentType.team; the GD
        # function takes no params (the N2486 zero-param
        # precedent: no input schema) and returns the
        # one-key {"content_type": "ContentType.team"}
        # envelope, the enum modeled by its qualified
        # Java name string (the N1319 precedent for
        # Block.getContentType -> "ContentType.block").
        self.assertIn('static func source_team_entry_get_content_type_state() -> Dictionary:', registry_state)
        self.assertIn('return {"content_type": "ContentType.team"}', registry_state)
        self.assertNotIn('"ContentType.block"', registry_state)
        # Placement: no UnlockableContent/TeamEntry GD
        # file exists, so the function lives in the
        # content registry runtime state (home of the
        # content catalog state functions), right after
        # source_liquid_catalog_state and before the
        # consts block.
        self.assertLess(
            registry_state.index('static func source_liquid_catalog_state('),
            registry_state.index('static func source_team_entry_get_content_type_state('),
        )
        self.assertLess(
            registry_state.index('static func source_team_entry_get_content_type_state('),
            registry_state.index('const source_content_registry_source_text_state'),
        )
        # The proof drives the pure function with no
        # inputs (no live tick, no game state): the
        # value is exactly "ContentType.team", the
        # result carries exactly one key, the value is
        # a non-empty String, it is not a sibling enum
        # value (block/item), it is a qualified enum
        # name, repeated calls agree, and the value is
        # a bare enum constant name.
        proof = GET_CONTENT_TYPE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_entry_get_content_type(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamEntryGetContentTypeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_ENTRY_GET_CONTENT_TYPE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
