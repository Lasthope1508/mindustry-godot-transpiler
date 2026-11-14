import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07WallCrafterPowerStatusTests(unittest.TestCase):
    def test_c07_wall_crafter_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2170']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169 proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module and separator
        # drivers -- but the WallCrafter (cliff-crusher, consumePower
        # 11 / 60f, Blocks.java:3004; large-cliff-crusher,
        # consumePower 1f, Blocks.java:3018) has NO driver at all: it
        # extends Block (WallCrafter.java:25), not a factory or
        # crafter, so no existing driver matches it, and its
        # updateTile warmup fold (WallCrafter.java:193) gates on
        # efficiency > 0, so a wall crafter with no power would
        # warm up as if power.status were 1.0. N2170 is the wall
        # crafter's live read: a pure power row over the stamped
        # frame value, folded by the shared machinery into the min
        # efficiency (BuildingComp.java:1969-1976, ConsumePower.
        # efficiency is build.power.status) in its own driver, wired
        # into simulate_factory like the separator driver (N2169).
        # WallCrafterBuild overrides shouldConsume
        # (WallCrafter.java:226-228, `return items.get(output) <
        # itemCapacity;`), so the default (BuildingComp.java:755)
        # does NOT apply here; the gate is deferred (items state is
        # not tracked yet) and the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). Two new result symbols: the row
        # and its presence flag.
        self.assertEqual(
            ledger['N2170']['source_symbols'],
            [
                'source_wall_crafter_power_status_row_state_result.row',
                'source_wall_crafter_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2170']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_power_status_row_state_result.row': 'SourceWallCrafterBuildState.source_wall_crafter_power_status_row_state',
                    'source_wall_crafter_power_status_row_state_result.has_power_row': 'SourceWallCrafterBuildState.source_wall_crafter_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2170']['runtime_proof'], '/root/C07WallCrafterPowerStatusProof')
        self.assertEqual(
            ledger['N2170']['tests'],
            [
                'test_c07_wall_crafter_power_status_registration',
                'test_all_c07_wall_crafter_power_status_input_evidence_is_exact',
                'test_wall_crafter_power_status_row_state',
                'test_reference_graph_and_actual_c07_wall_crafter_power_status',
            ],
        )
        self.assertTrue(ledger['N2170']['deferred_exprs'])

    def test_all_c07_wall_crafter_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2170']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_power_status_row_state_result.row': 'SourceWallCrafterBuildState.source_wall_crafter_power_status_row_state',
                    'source_wall_crafter_power_status_row_state_result.has_power_row': 'SourceWallCrafterBuildState.source_wall_crafter_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2170']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_power_status_row_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new wall crafter build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled ?
        # 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_wall_crafter_power_status_row_state', wall_crafter)
        self.assertIn('return build.power.status;', wall_crafter)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', wall_crafter)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the cliff-crusher
        # (11 / 60f) and large-cliff-crusher (1f) power consumers
        # count toward hasConsumers (Block.java:1449,
        # `hasConsumers = consumers.length > 0;`). The wall
        # crafter's updateTile warmup fold gates on efficiency > 0
        # (WallCrafter.java:193, keep on ONE comment line, the
        # N2148 shootWarmup lesson: a split line fails this test),
        # and its lastEfficiency fold multiplies by efficiency
        # (WallCrafter.java:211, `lastEfficiency = eff * timeScale
        # * efficiency;`). WallCrafterBuild overrides shouldConsume
        # (WallCrafter.java:226, `public boolean shouldConsume(){`;
        # WallCrafter.java:227, `return items.get(output) <
        # itemCapacity;`) -- the gate is deferred (items state is
        # not tracked yet) and the machinery runs with
        # should_consume=true when enabled. The wall crafter is its
        # own family (WallCrafter.java:25, `public class WallCrafter
        # extends Block{`; WallCrafterBuild, WallCrafter.java:183,
        # `public class WallCrafterBuild extends Building{`).
        self.assertIn('"is_power": true', wall_crafter)
        self.assertIn('block.properties.has("consumePower")', wall_crafter)
        self.assertIn('hasConsumers = consumers.length > 0;', wall_crafter)
        self.assertIn('warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);', wall_crafter)
        self.assertIn('lastEfficiency = eff * timeScale * efficiency;', wall_crafter)
        self.assertIn('public boolean shouldConsume(){', wall_crafter)
        self.assertIn('return items.get(output) < itemCapacity;', wall_crafter)
        self.assertIn('public class WallCrafter extends Block{', wall_crafter)
        self.assertIn('public class WallCrafterBuild extends Building{', wall_crafter)
        self.assertIn('consumePower(11 / 60f);', wall_crafter)
        self.assertIn('consumePower(1f);', wall_crafter)
        self.assertIn('consumeLiquid(Liquids.hydrogen, 1f / 60f);', wall_crafter)
        self.assertIn('static func source_wall_crafter_tick_buildings_state', wall_crafter)
        # The wall crafter needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the separator precedent, N2169).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_wall_crafter_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_wall_crafter_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no warmup / time /
        # offload keys: the updateTile advance (WallCrafter.java:
        # 186-223) waits for its own slice, so the warmup fold
        # (WallCrafter.java:193) is what the efficiency keys prove.
        proof = WALL_CRAFTER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'wall_crafter_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wall_crafter_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'wall_crafter_has_power_consumer',
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
