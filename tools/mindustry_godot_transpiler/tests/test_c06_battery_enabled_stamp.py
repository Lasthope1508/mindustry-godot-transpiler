import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILDING_POWER_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingPowerState.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
ENABLED_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C06BatteryEnabledStampProof.gd'


class C06BatteryEnabledStampTests(unittest.TestCase):
    def test_c06_battery_enabled_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2134']['godot_owner'], 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state')
        # The battery live enabled stamp: PowerGraph reads the live
        # Building.enabled on every battery pass (PowerGraph.java:123,
        # 135, 147, 163, 180) -- the flag itself is BuildingComp's
        # `transient boolean enabled = true;` (BuildingComp.java:77).
        # The port's battery dicts still carry the statically derived
        # enabled value from block_battery_state, so a disabled battery
        # building still counts as enabled in the graph until a live
        # tick stamps the building's own enabled onto each dict.
        self.assertEqual(
            ledger['N2134']['source_symbols'],
            [
                'source_building_power_battery_enabled_stamp_state_input.frame',
                'source_building_power_battery_enabled_stamp_state_result.batteries',
                'source_building_power_battery_enabled_stamp_state_result.disabled_count',
                'source_building_power_battery_enabled_stamp_state_result.enabled_count',
            ],
        )
        for name in ledger['N2134']['source_symbols']:
            with self.subTest(symbol=name):
                self.assertEqual(symbols[name]['godot_owner'], 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state')
                self.assertEqual(symbols[name]['java_source'], 'core/src/mindustry/world/blocks/power/PowerGraph.java' if 'frame' not in name else 'core/src/mindustry/entities/comp/BuildingComp.java')
        self.assertEqual(ledger['N2134']['runtime_proof'], '/root/C06BatteryEnabledStampProof')
        self.assertEqual(
            ledger['N2134']['tests'],
            [
                'test_c06_battery_enabled_stamp_registration',
                'test_all_c06_battery_enabled_stamp_input_evidence_is_exact',
                'test_battery_enabled_stamp_reads_live_building_enabled',
                'test_reference_graph_and_actual_c06_battery_enabled_stamp',
            ],
        )
        self.assertTrue(ledger['N2134']['deferred_exprs'])

    def test_all_c06_battery_enabled_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2134']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2134']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_battery_enabled_stamp_reads_live_building_enabled(self):
        power = BUILDING_POWER_STATE.read_text(encoding='utf-8')
        # The stamp function exists: it takes the tick frame (its
        # `batteries` list is the battery dicts built by
        # block_battery_state, each carrying its live building under
        # the `block` key) and overwrites each dict's `enabled` with
        # the live Building.enabled read through block_properties;
        # a battery whose block carries no live enabled keeps its
        # statically derived value, so existing proof frames are
        # unaffected (Java defaults enabled to true).
        self.assertIn('static func source_building_power_battery_enabled_stamp_state(frame: Dictionary) -> Dictionary:', power)
        placed = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        runtime = placed.split('static func runtime_state')[1]
        # The live tick path stamps the grouped batteries before the
        # graph reads them, so a disabled battery drops out of
        # stored/capacity/use/charge on the very next tick.
        self.assertIn('source_building_power_battery_enabled_stamp_state', runtime)
        # The new proof scene covers the stamp: enabled stays enabled,
        # disabled stamps false, a missing live flag keeps the static
        # value, mixed counts, and the disabled battery drops out of
        # the stored power the graph reports.
        proof = ENABLED_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'enabled_stamp_enabled_true',
            'enabled_stamp_disabled_false',
            'enabled_stamp_missing_keeps_static',
            'enabled_stamp_mixed_enabled_count',
            'enabled_stamp_mixed_disabled_count',
            'enabled_stamp_disabled_excluded_from_stored',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c06_battery_enabled_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06BatteryEnabledStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_BATTERY_ENABLED_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'enabled_stamp_enabled_true',
            'enabled_stamp_disabled_false',
            'enabled_stamp_missing_keeps_static',
            'enabled_stamp_mixed_enabled_count',
            'enabled_stamp_mixed_disabled_count',
            'enabled_stamp_disabled_excluded_from_stored',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
