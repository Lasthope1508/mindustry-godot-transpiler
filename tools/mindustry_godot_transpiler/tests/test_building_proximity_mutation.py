import json
import shutil
import subprocess
import unittest
import copy
import tempfile
import sys
from contextlib import ExitStack
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_symbols

ROOT = Path(__file__).resolve().parents[3]


class BuildingProximityMutationTests(unittest.TestCase):
    def _void_catalog(self, source, *, params=None, return_keys=None):
        owner = 'Example.source_mutate'
        contract = dict(status='active', source_slice='fixture', java_source='Fixture.java', source_method='public void mutate(){', params=[dict(name='value', type='int', schema='fixture_input.value')] if params is None else params, return_keys=[] if return_keys is None else return_keys, return_type='void', tests=['fixture'], runtime_proof='/root/Fixture', rule='Actual void mutation')
        with tempfile.TemporaryDirectory() as folder, ExitStack() as stack:
            root = Path(folder)
            (root / 'Example.gd').write_text(source, encoding='utf-8')
            for name, data in [
                ('load_source_symbol_registry', {'symbols': {'fixture.value': dict(godot_owner=owner, godot_symbol='fixture_input.value', tests=['fixture'], runtime_proof='/root/Fixture')}}),
                ('load_source_slice_ledger', {'slices': {'fixture': dict(source_symbols=['fixture.value'], tests=['fixture'], runtime_proof='/root/Fixture')}}),
                ('load_source_api_contracts', {'contracts': {owner: contract}}),
                ('load_source_state_schema', {'schemas': {'fixture_input': {'keys': {'value': {'type': 'int'}}}}}),
            ]:
                stack.enter_context(patch.object(source_symbols, name, return_value=data))
            stack.enter_context(patch.object(source_symbols.source_ssot, 'validate_json_modules', return_value=dict(errors=[], module_count=0)))
            return source_symbols.validate_source_catalog(root)

    def test_void_contract_shape_requires_explicit_type(self):
        entry = dict(status='active', source_slice='fixture', java_source='Fixture.java', source_method='public void mutate(){', params=[], return_keys=[], return_type='void', tests=['fixture'], runtime_proof='/root/Fixture', rule='Void mutation')
        def errors(value):
            return source_symbols.validate_source_api_contracts(dict(version=1, policy={'newSourceOwnerRequiresApiContract': True}, contracts={'Example.source_mutate': value}))
        self.assertEqual(errors(entry), [])
        for change in [{'return_type': 'Dictionary'}, {'return_type': 'unknown'}, {'return_type': None}, {'return_keys': ['invented']}]:
            with self.subTest(change=change):
                invalid = copy.deepcopy(entry)
                invalid.update(change)
                self.assertTrue(errors(invalid))
        no_type = dict(entry)
        del no_type['return_type']
        self.assertTrue(errors(no_type))

    def test_void_contract_requires_typed_implementation(self):
        for annotation in ['Dictionary', '']:
            source = 'class_name Example\nextends RefCounted\nstatic func source_mutate(value: int)' + (' -> ' + annotation if annotation else '') + ':\n\tpass\n'
            with self.subTest(annotation=annotation):
                report = self._void_catalog(source)
                self.assertTrue(report['categories']['implementation_linkage'], report)
        valid = self._void_catalog('class_name Example\nextends RefCounted\nstatic func source_mutate(value: int) -> void:\n\tpass\n')
        self.assertEqual(valid['errors'], [])

    def test_void_contract_keeps_parameter_and_return_validation(self):
        source = 'class_name Example\nextends RefCounted\nstatic func source_mutate(value: int) -> void:\n\tpass\n'
        report = self._void_catalog(source, params=[dict(name='value', type='int', schema='missing.value')])
        self.assertTrue(report['categories']['contract_schema_linkage'])
        invalid = self._void_catalog(source, return_keys=['invented'])
        self.assertTrue(invalid['categories']['return_schema_linkage'])

    def test_void_signature_handles_multiline_nested_defaults(self):
        source = 'class_name Example\nextends RefCounted\nstatic func source_mutate(\n\tvalue: int, # ignored closing )\n\tpoint: Vector2i = Vector2i(1, 2),\n\ttext: String = ") -> Dictionary:",\n) -> void:\n\tpass\n'
        self.assertEqual(self._void_catalog(source)['errors'], [])

    def test_optional_mirror_preserves_absence_and_detects_void_type_drift(self):
        ssot = source_symbols.source_ssot
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            ssot.write_json(root, 'api_contracts', {'version': 1, 'contracts': {'void_owner': {'return_keys': [], 'return_type': 'void'}, 'dict_owner': {'return_keys': ['value']}}})
            manifest = {'version': 1, 'modules': {'fixture_contracts': {'path': 'src/generated/source_modules/fixture_contracts.json', 'root_key': 'contracts', 'canonical_module': 'api_contracts', 'canonical_reference_key': 'canonical_contract', 'canonical_reference_prefix': 'source_api_contracts.', 'mirror_fields': ['return_keys'], 'optional_mirror_fields': ['return_type']}}}
            (root / ssot.extension_manifest_relative_path()).write_text(json.dumps(manifest), encoding='utf-8')
            mirror = ssot.build_extension_shard(root, 'fixture_contracts')
            self.assertEqual(mirror['contracts']['void_owner']['return_type'], 'void')
            self.assertNotIn('return_type', mirror['contracts']['dict_owner'])
            entry = ssot.registered_module(root, 'fixture_contracts')
            errors = []
            ssot._validate_extension_canonical_mirror(root, entry, mirror, errors)
            self.assertEqual(errors, [])
            for kind in ['missing', 'changed', 'invented']:
                with self.subTest(kind=kind):
                    mutated = copy.deepcopy(mirror)
                    if kind == 'missing':
                        del mutated['contracts']['void_owner']['return_type']
                    elif kind == 'changed':
                        mutated['contracts']['void_owner']['return_type'] = 'Dictionary'
                    else:
                        mutated['contracts']['dict_owner']['return_type'] = 'void'
                    errors = []
                    ssot._validate_extension_canonical_mirror(root, entry, mutated, errors)
                    self.assertTrue(errors)
            for invalid in ['return_type', [''], [7], ['return_type', 'return_type'], ['return_keys']]:
                with self.subTest(invalid=invalid):
                    manifest['modules']['fixture_contracts']['optional_mirror_fields'] = invalid
                    (root / ssot.extension_manifest_relative_path()).write_text(json.dumps(manifest), encoding='utf-8')
                    errors = []
                    ssot._manifest_extension_modules(root, errors)
                    self.assertTrue(errors)

    def test_executable_lifecycle_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema in [
            ('N2026', 'SourceBuildingLifecycleProximityState.source_apply_remove_from_proximity', 'source_apply_remove_from_proximity_input'),
            ('N2027', 'SourceBuildingLifecycleProximityState.source_apply_update_proximity', 'source_apply_update_proximity_input'),
            ('N2028', 'SourceBlockGeometry.source_apply_tile_pre_changed', 'source_apply_tile_pre_changed_input'),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner]['return_type'], 'void')
                self.assertEqual(contracts[owner]['return_keys'], [])
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                if sid in ['N2026', 'N2027']:
                    mirror = source_symbols.source_ssot.load_registered_json(ROOT / 'godot-mindustry', 'comp_api_contracts')['contracts']
                    self.assertEqual(mirror[owner]['return_type'], 'void')
                self.assertTrue(ledger[sid]['deferred_exprs'])

    def test_all_lifecycle_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2026', 'N2027', 'N2028']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_reference_graph_and_actual_tile_pre_change(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/BuildingProximityMutationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('BUILDING_PROXIMITY_MUTATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
