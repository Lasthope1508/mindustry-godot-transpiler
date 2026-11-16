import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILDING_POWER_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingPowerState.gd'
PLACED_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
FACTORY_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FactoryBatteryEnabledStampProof.gd'
FACTORY_STAMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FactoryBatteryEnabledStampProof.tscn'

STAMP_SYMBOLS = [
    'source_building_power_battery_enabled_stamp_state_input.frame',
    'source_building_power_battery_enabled_stamp_state_result.batteries',
    'source_building_power_battery_enabled_stamp_state_result.disabled_count',
    'source_building_power_battery_enabled_stamp_state_result.enabled_count',
]

PROOF_KEYS = [
    'factory_stamp_disabled_excluded_from_stored',
    'factory_stamp_disabled_untouched_by_drain',
    'factory_stamp_enabled_drained',
    'factory_stamp_disabled_flag_false_in_update',
    'factory_stamp_all_enabled_drain_scales_both',
    'factory_stamp_all_enabled_stored_total',
    'factory_stamp_all_enabled_flags_true',
    'factory_stamp_cheat_branch_disabled_untouched',
    'factory_stamp_cheat_branch_stored_total',
]


class C07FactoryBatteryEnabledStampTests(unittest.TestCase):
    def test_c07_factory_battery_enabled_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        self.assertEqual(ledger['N2359']['godot_owner'], 'SourceFactoryRuntimeState.source_factory_update_power_graph_state')
        # Wiring-only (the N2127 precedent): the N2134 stamp pure
        # already exists and is already wired into
        # SourcePlacedPowerGraphState.runtime_state, but the
        # factory live loop -- source_factory_update_power_graph_state
        # -- never called it, so the grouped batteries reached the
        # distribution, the N2354 launch drain and the N2342
        # stored-total stamp with their statically derived enabled
        # and a disabled battery still counted as enabled. N2359
        # is the one call that stamps the grouped batteries before
        # the graph update reads them. No new symbols, contracts,
        # or schemas: the slice reuses the N2134 stamp symbols
        # (shared symbol listings across slices are the
        # established pattern) and the N2134 / N2077 contracts
        # keep their source slices.
        self.assertEqual(ledger['N2359']['source_symbols'], STAMP_SYMBOLS)
        for name in ledger['N2359']['source_symbols']:
            with self.subTest(symbol=name):
                self.assertEqual(symbols[name]['godot_owner'], 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state')
        self.assertEqual(contracts['SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state']['source_slice'], 'N2134')
        self.assertEqual(contracts['SourceFactoryRuntimeState.source_factory_update_power_graph_state']['source_slice'], 'N2077')
        self.assertEqual(schemas['source_building_power_battery_enabled_stamp_state_input']['owner'], 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state')
        self.assertEqual(schemas['source_factory_update_power_graph_state_input']['owner'], 'SourceFactoryRuntimeState.source_factory_update_power_graph_state')
        self.assertEqual(ledger['N2359']['runtime_proof'], '/root/C07FactoryBatteryEnabledStampProof')
        self.assertEqual(
            ledger['N2359']['tests'],
            [
                'test_c07_factory_battery_enabled_stamp_registration',
                'test_all_c07_factory_battery_enabled_stamp_input_evidence_is_exact',
                'test_factory_battery_enabled_stamp_state',
                'test_reference_graph_and_actual_c07_factory_battery_enabled_stamp',
            ],
        )
        self.assertTrue(ledger['N2359']['deferred_exprs'])
        # DEFERRED net 0: the N2354 follow-through this slice
        # closes was never a DEFERRED entry (it was recorded in
        # the wave-17 GOAL entry), and the slice adds no new
        # deferral. Base is the merged post-advances-17 list
        # (320 entries).
        self.assertEqual(len(ledger['N2359']['deferred_exprs']), 320)

    def test_all_c07_factory_battery_enabled_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2359']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildingPowerState.source_building_power_battery_enabled_stamp_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2359']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_factory_battery_enabled_stamp_state(self):
        runtime = FACTORY_RUNTIME.read_text(encoding='utf-8')
        power = BUILDING_POWER_STATE.read_text(encoding='utf-8')
        placed = PLACED_STATE.read_text(encoding='utf-8')
        # The stamp pure already exists (N2134) and is already
        # wired into the placed graph's live tick path
        # (runtime_state) -- this slice wires the same pure into
        # the factory live loop, it does not create a second one.
        self.assertIn('static func source_building_power_battery_enabled_stamp_state(frame: Dictionary) -> Dictionary:', power)
        self.assertIn('source_building_power_battery_enabled_stamp_state', placed.split('static func runtime_state')[1])
        step = runtime.split('static func source_factory_update_power_graph_state')[1]
        # The factory runtime preloads the building power state
        # (the placed graph's own preload, same spelling) and
        # stamps the grouped batteries before the graph update
        # reads them. The stamp is pure -- it duplicates each
        # dict -- so the stamped list replaces the grouped list:
        # the distribute step inside update_state, the N2354
        # launch drain and the N2342 stored total below all read
        # stamped batteries, and on the cheat branch
        # update["batteries"] is this same stamped list (the
        # fallback the drain and the stored total read there).
        # Stamping updated_batteries instead would leave the
        # cheat branch unstamped and the distribution itself
        # reading the static flag.
        self.assertIn('const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")', runtime)
        self.assertIn('source_building_power_battery_enabled_stamp_state({"batteries": batteries})', step)
        self.assertIn('batteries = stamped_batteries.get("batteries", batteries)', step)
        stamp_at = step.index('source_building_power_battery_enabled_stamp_state({"batteries": batteries})')
        self.assertLess(stamp_at, step.index('source_power_graph_state.update_state(consumers, producers, batteries, 0.0, delta, [])'))
        self.assertLess(stamp_at, step.index('use_batteries_state(drain_batteries'))
        self.assertLess(stamp_at, step.index('battery_state(stored_batteries)'))
        # No other logic in the step changed: the drain and the
        # stored total still read the same lists they read
        # before (now stamped upstream), and the write-back loop
        # still covers updated_batteries.
        self.assertIn('var drain_batteries: Array = updated_batteries', step)
        self.assertIn('var stored_batteries: Array = updated_batteries', step)
        self.assertIn('for battery in updated_batteries:', step)
        # The proof drives a live tick through the factory step
        # on a fake game (the N2354 FakePowerGame precedent):
        # mixed enabled/disabled batteries + an accelerator with
        # a pending launch drain, an all-enabled control, and a
        # cheat-branch game. The scene file exists and the proof
        # preloads scripts that exist.
        proof = FACTORY_STAMP_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(FACTORY_STAMP_PROOF_SCENE.exists())
        self.assertIn('SourceFactoryRuntimeState.gd', proof)
        self.assertIn('SourceBuildingPowerState.gd', proof)
        self.assertIn('SourcePlacedPowerGraphState.gd', proof)
        self.assertIn('SourceAcceleratorBuildState.gd', proof)
        for preload in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload[len('res://'):]).is_file(), preload)
        scene = FACTORY_STAMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FactoryBatteryEnabledStampProof.gd', scene)

    def test_reference_graph_and_actual_c07_factory_battery_enabled_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FactoryBatteryEnabledStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FACTORY_BATTERY_ENABLED_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
