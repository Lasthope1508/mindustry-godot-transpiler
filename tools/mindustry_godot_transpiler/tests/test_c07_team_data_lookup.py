import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAM_DATA_LOOKUP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamDataLookupProof.gd'


class C07TeamDataLookupTests(unittest.TestCase):
    def test_c07_team_data_lookup_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2390']['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_get_buildings_state')
        # TeamData.getBuildings()+getCount()+getUnits()+unitCache()
        # (Teams.java:318-320 + :322-325 + :418-420 + :422-426), one
        # grouped slice (main-thread decision 2026-11-21, the
        # N2380 seven-method / N2374 five-accessor group
        # precedent): four one-to-two-line read-only lookup
        # methods on TeamData (`buildingTypes` + `unitsByType`).
        # Four GD functions, one ledger entry, one owner per
        # function (the N2380 multi-function precedent; the
        # N2378 lesson: a contract owner must be an actual GD
        # function, so the group label
        # `source_team_data_lookup_state` is NOT an owner --
        # the ledger godot_owner is the first function owner,
        # `source_team_data_get_buildings_state`).
        # `unitCache` called by getUnits() is INSIDE the group
        # (an internal self-reference, not an outside expr).
        # `buildingTypes`/`unitsByType` arrive as explicit
        # params; the `() -> new Seq<>(false)` default supplier
        # arrives as a Callable. All four functions are
        # read-only: getBuildings does NOT store the default
        # (ObjectMap.get with a default never puts).
        # Four new result symbols.
        self.assertEqual(
            ledger['N2390']['java_method'],
            'TeamData.getBuildings(Block)/TeamData.getCount(Block)/TeamData.getUnits(UnitType)/TeamData.unitCache(UnitType)',
        )
        self.assertEqual(
            ledger['N2390']['source_symbols'],
            [
                'source_team_data_get_buildings_state_result.buildings',
                'source_team_data_get_count_state_result.count',
                'source_team_data_get_units_state_result.units',
                'source_team_data_unit_cache_state_result.units',
            ],
        )
        for name in ledger['N2390']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_data_'))
        self.assertEqual(ledger['N2390']['runtime_proof'], '/root/C07TeamDataLookupProof')
        self.assertEqual(
            ledger['N2390']['tests'],
            [
                'test_c07_team_data_lookup_registration',
                'test_all_c07_team_data_lookup_input_evidence_is_exact',
                'test_team_data_lookup_state',
                'test_reference_graph_and_actual_c07_team_data_lookup',
            ],
        )
        self.assertTrue(ledger['N2390']['deferred_exprs'])

    def test_all_c07_team_data_lookup_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2390']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_data_'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2390']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_data_lookup_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # TeamData.getBuildings()+getCount()+getUnits()+unitCache()
        # (Teams.java:318-320 + :322-325 + :418-420 + :422-426):
        # getBuildings returns the stored Array for a known
        # block, or the fresh empty Array from the default
        # supplier when missing (never storing it); getCount
        # returns the stored Array size, or 0 when missing;
        # getUnits is the unitCache alias; unitCache returns
        # null on a null table, an out-of-range type id, or a
        # null slot, else the cached Array.
        self.assertIn('static func source_team_data_get_buildings_state(building_types: Dictionary, block_key: Variant, default_buildings: Callable) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_get_count_state(building_types: Dictionary, block_key: Variant) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_get_units_state(units_by_type: Variant, type_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_unit_cache_state(units_by_type: Variant, type_id: int) -> Dictionary:', teams)
        for expr in [
            'public static class TeamData{',
            'public Seq<Building> getBuildings(Block block){',
            'return buildingTypes.get(block, () -> new Seq<>(false));',
            'public int getCount(Block block){',
            'var res = buildingTypes.get(block);',
            'return res == null ? 0 : res.size;',
            'public Seq<Unit> getUnits(UnitType type){',
            'return unitCache(type);',
            'public Seq<Unit> unitCache(UnitType type){',
            'if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;',
            'return unitsByType[type.id];',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the four pure functions with
        # synthetic inputs (no live tick): getBuildings returns
        # the stored buildings / calls the default supplier
        # when missing / never stores the default / returns
        # only its one key; getCount returns the stored size /
        # 0 when missing / returns only its one key; getUnits
        # returns the cached units / null when missing;
        # unitCache is null on a null table / out-of-range
        # type id / null slot / returns only its one key.
        proof = TEAM_DATA_LOOKUP_PROOF.read_text(encoding='utf-8')
        for key in [
            'get_buildings_returns_stored_buildings',
            'get_buildings_calls_default_when_missing',
            'get_buildings_does_not_store_default',
            'get_buildings_returns_only_one_key',
            'get_count_returns_stored_size',
            'get_count_zero_when_missing',
            'get_count_returns_only_one_key',
            'get_units_returns_cached_units',
            'get_units_null_when_missing',
            'unit_cache_null_when_units_by_type_null',
            'unit_cache_null_when_type_out_of_range',
            'unit_cache_null_when_slot_null',
            'unit_cache_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_data_lookup(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamDataLookupProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_DATA_LOOKUP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'get_buildings_returns_stored_buildings',
            'get_buildings_calls_default_when_missing',
            'get_buildings_does_not_store_default',
            'get_buildings_returns_only_one_key',
            'get_count_returns_stored_size',
            'get_count_zero_when_missing',
            'get_count_returns_only_one_key',
            'get_units_returns_cached_units',
            'get_units_null_when_missing',
            'unit_cache_null_when_units_by_type_null',
            'unit_cache_null_when_type_out_of_range',
            'unit_cache_null_when_slot_null',
            'unit_cache_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
