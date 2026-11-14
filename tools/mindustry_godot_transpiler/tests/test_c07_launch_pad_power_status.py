import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07LaunchPadPowerStatusTests(unittest.TestCase):
    def test_c07_launch_pad_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2172']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171 proved the pure power-row pattern
        # on the factory, adjacent-factory, drill, turret,
        # burst-drill, solid-pump, point-defense, tractor-beam,
        # fracker, mechanical-pump, beam-drill, mend-projector,
        # overdrive-projector, force-projector, base-shield,
        # regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter and mass-driver drivers -- but the LaunchPad
        # (launch-pad, consumePower 4f, Blocks.java:6797;
        # advanced-launch-pad, consumePower 8f, Blocks.java:6809)
        # has NO driver at all: it extends Block
        # (LaunchPad.java:30), not a factory or crafter, so no
        # existing driver matches it, and its updateTile launch
        # gate (LaunchPad.java:146, `if((launchCounter +=
        # edelta()) >= launchTime && items.total() >=
        # itemCapacity){`) advances launchCounter by edelta()
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), so a launch pad with no power would never
        # launch -- its launchCounter would sit frozen as if
        # power.status were 1.0. N2172 is the launch pad's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the mass-driver driver (N2171).
        # LaunchPadBuild HAS a shouldConsume override
        # (LaunchPad.java:92-95, `return launchCounter <
        # launchTime;`) -- the gate waits for its own slice; the
        # machinery runs with should_consume=true when enabled
        # (the MendProjector suppression precedent). Two new
        # result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2172']['source_symbols'],
            [
                'source_launch_pad_power_status_row_state_result.row',
                'source_launch_pad_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2172']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_power_status_row_state_result.row': 'SourceLaunchPadBuildState.source_launch_pad_power_status_row_state',
                    'source_launch_pad_power_status_row_state_result.has_power_row': 'SourceLaunchPadBuildState.source_launch_pad_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2172']['runtime_proof'], '/root/C07LaunchPadPowerStatusProof')
        self.assertEqual(
            ledger['N2172']['tests'],
            [
                'test_c07_launch_pad_power_status_registration',
                'test_all_c07_launch_pad_power_status_input_evidence_is_exact',
                'test_launch_pad_power_status_row_state',
                'test_reference_graph_and_actual_c07_launch_pad_power_status',
            ],
        )
        self.assertTrue(ledger['N2172']['deferred_exprs'])

    def test_all_c07_launch_pad_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2172']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_power_status_row_state_result.row': 'SourceLaunchPadBuildState.source_launch_pad_power_status_row_state',
                    'source_launch_pad_power_status_row_state_result.has_power_row': 'SourceLaunchPadBuildState.source_launch_pad_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2172']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_power_status_row_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new launch pad build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled ?
        # 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_launch_pad_power_status_row_state', launch_pad)
        self.assertIn('return build.power.status;', launch_pad)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', launch_pad)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the launch pad
        # (4f / 8f) power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length > 0;`).
        # The launch pad's updateTile launch gate advances
        # launchCounter by edelta() (LaunchPad.java:146, keep on
        # ONE comment line, the N2148 shootWarmup lesson: a split
        # line fails this test), and edelta() is efficiency *
        # delta (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), so the launch follows the folded efficiency.
        # LaunchPadBuild HAS a shouldConsume override
        # (LaunchPad.java:92, `public boolean shouldConsume(){`
        # with `return launchCounter < launchTime;`,
        # LaunchPad.java:94) -- the gate waits for its own slice;
        # the machinery runs with should_consume=true when enabled
        # (the BuildingComp default, BuildingComp.java:755-757,
        # `return enabled;`, is what the driver uses). The launch
        # pad is its own family (LaunchPad.java:30, `public class
        # LaunchPad extends Block{`; LaunchPadBuild,
        # LaunchPad.java:83, `public class LaunchPadBuild extends
        # Building{`). Two defs share the implementation
        # (launch-pad, `consumePower(4f);`, Blocks.java:6797;
        # advanced-launch-pad, `consumePower(8f);`,
        # Blocks.java:6809), so the same driver covers the whole
        # family; the advanced def also consumes liquid oil, which
        # waits for its own slice.
        self.assertIn('"is_power": true', launch_pad)
        self.assertIn('block.properties.has("consumePower")', launch_pad)
        self.assertIn('hasConsumers = consumers.length > 0;', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('return launchCounter < launchTime;', launch_pad)
        self.assertIn('public boolean shouldConsume(){', launch_pad)
        self.assertIn('return enabled;', launch_pad)
        self.assertIn('public class LaunchPad extends Block{', launch_pad)
        self.assertIn('public class LaunchPadBuild extends Building{', launch_pad)
        self.assertIn('consumePower(4f);', launch_pad)
        self.assertIn('consumePower(8f);', launch_pad)
        self.assertIn('static func source_launch_pad_tick_buildings_state', launch_pad)
        # The launch pad needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the mass-driver precedent, N2171).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_launch_pad_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_launch_pad_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no launch/counter/
        # payload keys: the updateTile advance (LaunchPad.java:
        # 143-161) waits for its own slice, so the launch gate
        # (LaunchPad.java:146) is what the efficiency keys prove.
        proof = LAUNCH_PAD_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'launch_pad_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_launch_pad_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'launch_pad_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
