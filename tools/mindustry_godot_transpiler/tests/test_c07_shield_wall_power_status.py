import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHIELD_WALL_STATE = ROOT / 'godot-mindustry/src/game/SourceShieldWallBuildState.gd'
SHIELD_WALL_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShieldWallPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ShieldWallPowerStatusTests(unittest.TestCase):
    def test_c07_shield_wall_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2175']['godot_owner'], 'SourceShieldWallBuildState.source_shield_wall_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174 proved the pure
        # power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump, beam-drill,
        # mend-projector, overdrive-projector, force-projector,
        # base-shield, regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar and
        # repair-turret drivers -- but the ShieldWall
        # (shielded-wall, consumePower 3f / 60f = 0.05,
        # Blocks.java:1905) has NO driver at all: it extends Wall
        # (ShieldWall.java:14), not a factory or crafter, so no
        # existing driver matches it, and its updateTile regen
        # advance (ShieldWall.java:80, `shield = Mathf.clamp(shield
        # + regenSpeed * edelta(), 0f, shieldHealth);`) regens by
        # edelta() (BuildingComp.java:1927-1929, `return efficiency
        # * delta();`), so a shield wall with no power would never
        # regen -- its shield would sit frozen as if power.status
        # were 1.0. And broken() (ShieldWall.java:92, `return
        # breakTimer > 0 || !canConsume();`) with canConsume()
        # (BuildingComp.java:1917-1919, `return potentialEfficiency
        # > 0;`) means a powerless shield wall is broken and
        # absorbs nothing. N2175 is the shield wall's live read: a
        # pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the radar driver (N2173).
        # ShieldWallBuild has NO shouldConsume override, so the
        # BuildingComp default (BuildingComp.java:755-757,
        # `return enabled;`) applies; the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). Two new result symbols: the row
        # and its presence flag.
        self.assertEqual(
            ledger['N2175']['source_symbols'],
            [
                'source_shield_wall_power_status_row_state_result.row',
                'source_shield_wall_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2175']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_power_status_row_state_result.row': 'SourceShieldWallBuildState.source_shield_wall_power_status_row_state',
                    'source_shield_wall_power_status_row_state_result.has_power_row': 'SourceShieldWallBuildState.source_shield_wall_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2175']['runtime_proof'], '/root/C07ShieldWallPowerStatusProof')
        self.assertEqual(
            ledger['N2175']['tests'],
            [
                'test_c07_shield_wall_power_status_registration',
                'test_all_c07_shield_wall_power_status_input_evidence_is_exact',
                'test_shield_wall_power_status_row_state',
                'test_reference_graph_and_actual_c07_shield_wall_power_status',
            ],
        )
        self.assertTrue(ledger['N2175']['deferred_exprs'])

    def test_all_c07_shield_wall_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2175']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_power_status_row_state_result.row': 'SourceShieldWallBuildState.source_shield_wall_power_status_row_state',
                    'source_shield_wall_power_status_row_state_result.has_power_row': 'SourceShieldWallBuildState.source_shield_wall_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/ShieldWall.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2175']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shield_wall_power_status_row_state(self):
        shield_wall = SHIELD_WALL_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new shield-wall build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled ?
        # 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_shield_wall_power_status_row_state', shield_wall)
        self.assertIn('return build.power.status;', shield_wall)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shield_wall)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the shield wall's
        # static power consumer (consumePower 3f / 60f = 0.05,
        # Blocks.java:1905) counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length > 0;`).
        # The shield wall's updateTile regen advance
        # (ShieldWall.java:80, `shield = Mathf.clamp(shield +
        # regenSpeed * edelta(), 0f, shieldHealth);`, keep on ONE
        # comment line, the N2148 shootWarmup lesson: a split line
        # fails this test) regens by edelta(), and edelta() is
        # efficiency * delta (BuildingComp.java:1927-1929,
        # `return efficiency * delta();`); the broken coupling
        # (ShieldWall.java:92, `return breakTimer > 0 ||
        # !canConsume();`) with canConsume()
        # (BuildingComp.java:1917, `public boolean canConsume(){`
        # with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) means a powerless shield wall
        # is broken and absorbs nothing. The updateConsumption
        # gate (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`) forces efficiency to zero when the gate
        # is false. ShieldWallBuild has NO shouldConsume override,
        # so the BuildingComp default (BuildingComp.java:755,
        # `public boolean shouldConsume(){` with `return enabled;`,
        # BuildingComp.java:756) applies; the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). The shield wall is its own family
        # (ShieldWall.java:14, `public class ShieldWall extends
        # Wall{`; ShieldWallBuild, ShieldWall.java:43, `public class
        # ShieldWallBuild extends WallBuild{`). One def
        # (shielded-wall, `consumePower(3f / 60f);`,
        # Blocks.java:1905; shieldHealth 900f, breakCooldown 60f *
        # 10f, regenSpeed 2f, ShieldWall.java:15-17; chanceDeflect
        # 8f, health 260 * wallHealthMultiplier * 4, armor 15f,
        # size 2, Blocks.java:1903-1916).
        self.assertIn('"is_power": true', shield_wall)
        self.assertIn('block.properties.has("consumePower")', shield_wall)
        self.assertIn('hasConsumers = consumers.length > 0;', shield_wall)
        self.assertIn('shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', shield_wall)
        self.assertIn('return breakTimer > 0 || !canConsume();', shield_wall)
        self.assertIn('public boolean canConsume(){', shield_wall)
        self.assertIn('return potentialEfficiency > 0;', shield_wall)
        self.assertIn('public boolean shouldConsume(){', shield_wall)
        self.assertIn('return enabled;', shield_wall)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shield_wall)
        self.assertIn('if(!update){', shield_wall)
        self.assertIn('return efficiency * delta();', shield_wall)
        self.assertIn('public class ShieldWall extends Wall{', shield_wall)
        self.assertIn('public class ShieldWallBuild extends WallBuild{', shield_wall)
        self.assertIn('consumePower(3f / 60f);', shield_wall)
        self.assertIn('public float shieldHealth = 900f;', shield_wall)
        self.assertIn('public float breakCooldown = 60f * 10f;', shield_wall)
        self.assertIn('public float regenSpeed = 2f;', shield_wall)
        self.assertIn('update = true;', shield_wall)
        self.assertIn('public float shield = shieldHealth, shieldRadius = 0f;', shield_wall)
        self.assertIn('static func source_shield_wall_tick_buildings_state', shield_wall)
        # The shield wall needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the radar precedent, N2173).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_shield_wall_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_shield_wall_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no shield /
        # shieldRadius / breakTimer keys: the updateTile advance
        # (ShieldWall.java:74-89) waits for its own slice, so the
        # regen advance (ShieldWall.java:80) is what the
        # efficiency keys prove; the broken() / damage coupling
        # (ShieldWall.java:91-93, 101-117) waits for its own slice.
        proof = SHIELD_WALL_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'shield_wall_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shield_wall_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShieldWallPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHIELD_WALL_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shield_wall_has_power_consumer',
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
