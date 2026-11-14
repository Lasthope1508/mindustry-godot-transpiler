import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07RadarPowerStatusTests(unittest.TestCase):
    def test_c07_radar_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2173']['godot_owner'], 'SourceRadarBuildState.source_radar_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172 proved the pure power-row
        # pattern on the factory, adjacent-factory, drill, turret,
        # burst-drill, solid-pump, point-defense, tractor-beam,
        # fracker, mechanical-pump, beam-drill, mend-projector,
        # overdrive-projector, force-projector, base-shield,
        # regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver and launch-pad drivers -- but
        # the Radar (radar, consumePower 0.6f, Blocks.java:1994)
        # has NO driver at all: it extends Block
        # (Radar.java:17), not a factory or crafter, so no
        # existing driver matches it, and its updateTile progress
        # advance (Radar.java:68, `progress += edelta() /
        # discoveryTime;`) advances progress by edelta()
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`), so a radar with no power would never
        # discover -- its progress would sit frozen as if
        # power.status were 1.0. N2173 is the radar's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the launch-pad driver (N2172).
        # RadarBuild has NO shouldConsume override, so the
        # BuildingComp default (BuildingComp.java:755-757,
        # `return enabled;`) applies; the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). Two new result symbols: the row
        # and its presence flag.
        self.assertEqual(
            ledger['N2173']['source_symbols'],
            [
                'source_radar_power_status_row_state_result.row',
                'source_radar_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2173']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_radar_power_status_row_state_result.row': 'SourceRadarBuildState.source_radar_power_status_row_state',
                    'source_radar_power_status_row_state_result.has_power_row': 'SourceRadarBuildState.source_radar_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2173']['runtime_proof'], '/root/C07RadarPowerStatusProof')
        self.assertEqual(
            ledger['N2173']['tests'],
            [
                'test_c07_radar_power_status_registration',
                'test_all_c07_radar_power_status_input_evidence_is_exact',
                'test_radar_power_status_row_state',
                'test_reference_graph_and_actual_c07_radar_power_status',
            ],
        )
        self.assertTrue(ledger['N2173']['deferred_exprs'])

    def test_all_c07_radar_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2173']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_radar_power_status_row_state_result.row': 'SourceRadarBuildState.source_radar_power_status_row_state',
                    'source_radar_power_status_row_state_result.has_power_row': 'SourceRadarBuildState.source_radar_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2173']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_power_status_row_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new radar build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled ?
        # 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_radar_power_status_row_state', radar)
        self.assertIn('return build.power.status;', radar)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', radar)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the radar
        # (0.6f) power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length > 0;`).
        # The radar's updateTile progress advance
        # (Radar.java:68, `progress += edelta() / discoveryTime;`,
        # keep on ONE comment line, the N2148 shootWarmup lesson:
        # a split line fails this test) advances progress by
        # edelta(), and edelta() is efficiency * delta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`); the smooth-efficiency lerp (Radar.java:61,
        # `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency,
        # efficiency, 0.05f);`) and the total-progress advance
        # (Radar.java:71, `totalProgress += efficiency *
        # edelta();`) follow the folded efficiency too.
        # RadarBuild has NO shouldConsume override, so the
        # BuildingComp default (BuildingComp.java:755, `public
        # boolean shouldConsume(){` with `return enabled;`,
        # BuildingComp.java:756) applies; the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). The radar is its own family
        # (Radar.java:17, `public class Radar extends Block{`;
        # RadarBuild, Radar.java:48, `public class RadarBuild
        # extends Building{`). One def (radar, `consumePower(0.6f);`,
        # Blocks.java:1994; fogRadius 34, Blocks.java:1991).
        self.assertIn('"is_power": true', radar)
        self.assertIn('block.properties.has("consumePower")', radar)
        self.assertIn('hasConsumers = consumers.length > 0;', radar)
        self.assertIn('progress += edelta() / discoveryTime;', radar)
        self.assertIn('smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);', radar)
        self.assertIn('totalProgress += efficiency * edelta();', radar)
        self.assertIn('public boolean shouldConsume(){', radar)
        self.assertIn('return enabled;', radar)
        self.assertIn('public class Radar extends Block{', radar)
        self.assertIn('public class RadarBuild extends Building{', radar)
        self.assertIn('consumePower(0.6f);', radar)
        self.assertIn('static func source_radar_tick_buildings_state', radar)
        # The radar needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the launch-pad precedent, N2172).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_radar_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_radar_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress /
        # smooth-efficiency / fog-radius keys: the updateTile
        # advance (Radar.java:60-72) waits for its own slice, so
        # the progress advance (Radar.java:68) is what the
        # efficiency keys prove.
        proof = RADAR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'radar_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'radar_has_power_consumer',
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
