import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
LIQUID_BRIDGE_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgePowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07LiquidBridgePowerStatusTests(unittest.TestCase):
    def test_c07_liquid_bridge_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2179']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178 proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower,
        # shockwave-tower and item-bridge drivers -- but the
        # LiquidBridge (phase-conduit, consumePower 0.30f,
        # Blocks.java:2396) has NO driver at all: it extends
        # ItemBridge (LiquidBridge.java:7, `public class
        # LiquidBridge extends ItemBridge{`), not a factory or
        # crafter, so no existing driver matches it -- the N2178
        # driver's implementation list holds "ItemBridge" only,
        # an exact-string match, so "LiquidBridge" never matches
        # it. Its LiquidBridgeBuild.updateTransport moves liquid
        # only once warmup reaches 0.25f (LiquidBridge.java:23,
        # `if(warmup >= 0.25f){` with `moved |= moveLiquid(other,
        # liquids.current()) > 0.05f;`, LiquidBridge.java:24), and
        # warmup itself follows the folded efficiency through the
        # inherited ItemBridge updateTile (ItemBridge.java:345,
        # `warmup = Mathf.approachDelta(warmup, efficiency, 1f /
        # 30f);`) -- so a phase-conduit with no power would never
        # warm up and never move liquid across the bridge, as if
        # power.status were 1.0. N2179 is the liquid bridge's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the item-bridge driver (N2178).
        # The family splits in two: phase-conduit is a
        # LiquidBridge with `consumePower(0.30f);`
        # (Blocks.java:2396) and `hasPower = true;`
        # (Blocks.java:2391), while bridge-conduit is a
        # LiquidBridge with `hasPower = false;`
        # (Blocks.java:2380) and NO consumePower def -- its
        # transport does NOT depend on power.status (with no
        # power consumer its efficiency stays 1.0 when enabled,
        # so warmup still reaches 0.25f and liquid still moves).
        # This slice covers phase-conduit ONLY; the driver's
        # implementation list holds "LiquidBridge" only, so the
        # bridge-conduit def never gets a power row -- and the
        # plain radar gate (block.properties.has("consumePower"))
        # enforces the same split on the def side. Catalog quirk
        # to respect: bridge-conduit lists `consumesPower: true`
        # and `hasPower: true` in the catalog despite `hasPower =
        # false;` (Blocks.java:2380), the same pattern as
        # bridge-conveyor in N2178 -- so the plain radar gate
        # (block.properties.has("consumePower")) is what matters;
        # it correctly includes phase-conduit and excludes
        # bridge-conduit. Do NOT adapt the gate to `or
        # consumesPower` (the RepairTurret adaptation is for
        # ConsumePowerCondition defs; here the power def is a
        # plain static `consumePower(0.30f)`).
        # reinforced-bridge-conduit is a DirectionLiquidBridge
        # (Blocks.java:2432), a DIFFERENT class (extends
        # DirectionBridge, not ItemBridge) with `hasPower =
        # false;` and no consumePower def -- it is explicitly OUT
        # of scope, a different driver family if ever needed.
        # The liquid bridge's power draw is STATIC, not
        # conditional: `consumePower(0.30f);`
        # (Blocks.java:2396) registers a plain ConsumePower, so
        # the catalog consumePower 0.3 is present and the plain
        # radar gate works -- no RepairTurret-style `or
        # consumesPower` adaptation is needed. LiquidBridgeBuild
        # inherits ItemBridgeBuild.shouldConsume: `return
        # hadValidLink && enabled;` (ItemBridge.java:495-496), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1994,
        # `if(!update){` / efficiency = optionalEfficiency =
        # 0f). RED decision (the PointDefenseTurret N2151
        # precedent, and the RepairTurret N2174 / RepairTower
        # N2176 / ShockwaveTower N2177 / ItemBridge N2178
        # precedents): the port tracks NO live link on any
        # placed-building frame, so this slice folds power-only
        # and defers the gate with a documented limit -- when
        # unlinked power.status reads 1.0 while Java efficiency
        # is 0; the observable gap is efficiency 1.0 vs 0.0 when
        # unlinked. Two new result symbols: the row and its
        # presence flag.
        self.assertEqual(
            ledger['N2179']['source_symbols'],
            [
                'source_liquid_bridge_power_status_row_state_result.row',
                'source_liquid_bridge_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2179']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_liquid_bridge_power_status_row_state_result.row': 'SourceLiquidBridgeBuildState.source_liquid_bridge_power_status_row_state',
                    'source_liquid_bridge_power_status_row_state_result.has_power_row': 'SourceLiquidBridgeBuildState.source_liquid_bridge_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2179']['runtime_proof'], '/root/C07LiquidBridgePowerStatusProof')
        self.assertEqual(
            ledger['N2179']['tests'],
            [
                'test_c07_liquid_bridge_power_status_registration',
                'test_all_c07_liquid_bridge_power_status_input_evidence_is_exact',
                'test_liquid_bridge_power_status_row_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_power_status',
            ],
        )
        self.assertTrue(ledger['N2179']['deferred_exprs'])

    def test_all_c07_liquid_bridge_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2179']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_liquid_bridge_power_status_row_state_result.row': 'SourceLiquidBridgeBuildState.source_liquid_bridge_power_status_row_state',
                    'source_liquid_bridge_power_status_row_state_result.has_power_row': 'SourceLiquidBridgeBuildState.source_liquid_bridge_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/world/blocks/distribution/BufferedItemBridge.java',
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2179']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_power_status_row_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new liquid-bridge build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_liquid_bridge_power_status_row_state', liquid_bridge)
        self.assertIn('return build.power.status;', liquid_bridge)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', liquid_bridge)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the liquid
        # bridge's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(0.30f);` (Blocks.java:2396) with `range =
        # 12;` (Blocks.java:2388) and `liquidCapacity = 100f;`
        # (Blocks.java:2395). The liquid bridge's updateTransport
        # (LiquidBridge.java:23-24, `if(warmup >= 0.25f){` with
        # `moved |= moveLiquid(other, liquids.current()) >
        # 0.05f;`, keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test) moves liquid only
        # once warmup reaches 0.25f, and warmup follows the
        # folded efficiency through the inherited ItemBridge
        # updateTile (ItemBridge.java:345, `warmup =
        # Mathf.approachDelta(warmup, efficiency, 1f / 30f);`;
        # ItemBridge.java:356, `transportCounter += edelta();`,
        # and edelta() is efficiency * delta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`)). doDump dumps the current liquid
        # (LiquidBridge.java:30, `dumpLiquid(liquids.current(),
        # 1f);`). draw() uses `float warmup = hasPower ?
        # this.warmup : 1f;` (ItemBridge.java:387) -- the
        # bridge-conduit (hasPower false) always draws warmup 1f,
        # another reason the two defs must not share one driver
        # row.
        # LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume
        # (ItemBridge.java:495, `public boolean shouldConsume(){`
        # with `return hadValidLink && enabled;`,
        # ItemBridge.java:496); updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). RED decision (the PointDefenseTurret
        # N2151 precedent and the RepairTurret N2174 / RepairTower
        # N2176 / ShockwaveTower N2177 / ItemBridge N2178
        # precedents): the port tracks no live link on any
        # placed-building frame, so this slice folds power-only
        # and defers the gate with a documented limit; the
        # machinery runs with should_consume=true when enabled
        # (the MendProjector suppression precedent). The link gate
        # itself is `hadValidLink = linkValid(tile, other);`
        # (ItemBridge.java:333).
        # The liquid bridge is its own family
        # (LiquidBridge.java:7, `public class LiquidBridge extends
        # ItemBridge{`; LiquidBridgeBuild, LiquidBridge.java:19,
        # `public class LiquidBridgeBuild extends ItemBridgeBuild{`),
        # a liquid block, NOT related to any factory / turret /
        # defense family. Constructor: `hasItems = false;`
        # (LiquidBridge.java:11), `hasLiquids = true;`
        # (LiquidBridge.java:12), `outputsLiquid = true;`
        # (LiquidBridge.java:13), `canOverdrive = false;`
        # (LiquidBridge.java:14), `group =
        # BlockGroup.liquids;` (LiquidBridge.java:15),
        # `envEnabled = Env.any;` (LiquidBridge.java:16). It
        # inherits the ItemBridge class (ItemBridge.java:24,
        # `public class ItemBridge extends Block{`;
        # ItemBridgeBuild, ItemBridge.java:197, `public class
        # ItemBridgeBuild extends Building{`), a distribution
        # block. Class fields: `public final int timerCheckMoved =
        # timers ++;` (ItemBridge.java:25), `public int range;`
        # (ItemBridge.java:27), `public float transportTime;`
        # (ItemBridge.java:28), `public boolean fadeIn = true;`
        # (ItemBridge.java:34), `public boolean moveArrows =
        # true;` (ItemBridge.java:35), `public boolean pulse =
        # false;` (ItemBridge.java:36), `public float arrowSpacing
        # = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;`
        # (ItemBridge.java:37), `public float arrowTimeScl =
        # 6.2f;` (ItemBridge.java:38), `public float bridgeWidth =
        # 6.5f;` (ItemBridge.java:39); constructor `update =
        # true;` (ItemBridge.java:45), `solid = true;`
        # (ItemBridge.java:46), `underBullets = true;`
        # (ItemBridge.java:47), `hasPower = true;`
        # (ItemBridge.java:48), `itemCapacity = 10;`
        # (ItemBridge.java:49), `configurable = true;`
        # (ItemBridge.java:50), `hasItems = true;`
        # (ItemBridge.java:51). Build fields: `public int link =
        # -1;` (ItemBridge.java:202), `public IntSeq incoming =
        # new IntSeq(false, 4);` (ItemBridge.java:203), `public
        # float warmup;` (ItemBridge.java:204), `public float
        # time = -8f, timeSpeed;` (ItemBridge.java:205), `public
        # boolean wasMoved, moved, hadValidLink;`
        # (ItemBridge.java:206), `public float transportCounter;`
        # (ItemBridge.java:207). canConsume (BuildingComp.java:1917,
        # `public boolean canConsume(){` with `return
        # potentialEfficiency > 0;`, BuildingComp.java:1918) and
        # the shouldConsume default (BuildingComp.java:755,
        # `public boolean shouldConsume(){` with `return
        # enabled;`, BuildingComp.java:756) are the surrounding
        # gates. No sense / read / write overrides exist on
        # LiquidBridgeBuild -- those wait for their own slices
        # only if a later Java line needs them.
        # Single def -- phase-conduit only (size 1, range 12,
        # liquidCapacity 100f, phase-fabric 5 / silicon 7 /
        # metaglass 20 / titanium 10, Blocks.java:2385-2397).
        # bridge-conduit (LiquidBridge, no power def, `hasPower =
        # false;`, Blocks.java:2380) is explicitly OUT of scope;
        # reinforced-bridge-conduit (DirectionLiquidBridge,
        # Blocks.java:2432, different class, hasPower false) is
        # explicitly OUT of scope.
        self.assertIn('"is_power": true', liquid_bridge)
        self.assertIn('block.properties.has("consumePower")', liquid_bridge)
        self.assertIn('hasConsumers = consumers.length > 0;', liquid_bridge)
        self.assertIn('consumePower(0.30f);', liquid_bridge)
        self.assertIn('range = 12;', liquid_bridge)
        self.assertIn('liquidCapacity = 100f;', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class LiquidBridgeBuild extends ItemBridgeBuild{', liquid_bridge)
        self.assertIn('hasItems = false;', liquid_bridge)
        self.assertIn('hasLiquids = true;', liquid_bridge)
        self.assertIn('outputsLiquid = true;', liquid_bridge)
        self.assertIn('canOverdrive = false;', liquid_bridge)
        self.assertIn('group = BlockGroup.liquids;', liquid_bridge)
        self.assertIn('envEnabled = Env.any;', liquid_bridge)
        self.assertIn('if(warmup >= 0.25f){', liquid_bridge)
        self.assertIn('moved |= moveLiquid(other, liquids.current()) > 0.05f;', liquid_bridge)
        self.assertIn('dumpLiquid(liquids.current(), 1f);', liquid_bridge)
        self.assertIn('public class ItemBridge extends Block{', liquid_bridge)
        self.assertIn('public class ItemBridgeBuild extends Building{', liquid_bridge)
        self.assertIn('public final int timerCheckMoved = timers ++;', liquid_bridge)
        self.assertIn('public int range;', liquid_bridge)
        self.assertIn('public float transportTime;', liquid_bridge)
        self.assertIn('public boolean fadeIn = true;', liquid_bridge)
        self.assertIn('public boolean moveArrows = true;', liquid_bridge)
        self.assertIn('public boolean pulse = false;', liquid_bridge)
        self.assertIn('public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;', liquid_bridge)
        self.assertIn('public float arrowTimeScl = 6.2f;', liquid_bridge)
        self.assertIn('public float bridgeWidth = 6.5f;', liquid_bridge)
        self.assertIn('update = true;', liquid_bridge)
        self.assertIn('solid = true;', liquid_bridge)
        self.assertIn('underBullets = true;', liquid_bridge)
        self.assertIn('hasPower = true;', liquid_bridge)
        self.assertIn('itemCapacity = 10;', liquid_bridge)
        self.assertIn('configurable = true;', liquid_bridge)
        self.assertIn('hasItems = true;', liquid_bridge)
        self.assertIn('public int link = -1;', liquid_bridge)
        self.assertIn('public IntSeq incoming = new IntSeq(false, 4);', liquid_bridge)
        self.assertIn('public float warmup;', liquid_bridge)
        self.assertIn('public float time = -8f, timeSpeed;', liquid_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', liquid_bridge)
        self.assertIn('public float transportCounter;', liquid_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', liquid_bridge)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);', liquid_bridge)
        self.assertIn('transportCounter += edelta();', liquid_bridge)
        self.assertIn('float warmup = hasPower ? this.warmup : 1f;', liquid_bridge)
        self.assertIn('hasPower = false;', liquid_bridge)
        self.assertIn('public boolean shouldConsume(){', liquid_bridge)
        self.assertIn('return hadValidLink && enabled;', liquid_bridge)
        self.assertIn('public boolean canConsume(){', liquid_bridge)
        self.assertIn('return potentialEfficiency > 0;', liquid_bridge)
        self.assertIn('return enabled;', liquid_bridge)
        self.assertIn('boolean update = shouldConsume() && productionValid();', liquid_bridge)
        self.assertIn('if(!update){', liquid_bridge)
        self.assertIn('return efficiency * delta();', liquid_bridge)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', liquid_bridge)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_tick_buildings_state', liquid_bridge)
        # The liquid bridge needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the item-bridge precedent, N2178).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_liquid_bridge_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_liquid_bridge_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no transport / warmup
        # / move-liquid / link keys: the updateTransport advance
        # (LiquidBridge.java:22-26, warmup gate 0.25f) waits for
        # its own slice, so the warmup gate
        # (LiquidBridge.java:23) is what the efficiency keys
        # prove.
        proof = LIQUID_BRIDGE_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'liquid_bridge_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_liquid_bridge_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgePowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'liquid_bridge_has_power_consumer',
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
