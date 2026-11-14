import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgePowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ItemBridgePowerStatusTests(unittest.TestCase):
    def test_c07_item_bridge_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2178']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177
        # proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower and
        # shockwave-tower drivers -- but the ItemBridge
        # (phase-conveyor, consumePower 0.30f, Blocks.java:2125)
        # has NO driver at all: it extends Block
        # (ItemBridge.java:24), not a factory or crafter, so no
        # existing driver matches it, and its updateTransport
        # charges its transport counter by edelta()
        # (ItemBridge.java:356, `transportCounter += edelta();`)
        # and moves one item per transportTime (2f for
        # phase-conveyor, Blocks.java:2119) -- so a phase-conveyor
        # with no power would never advance its transport counter
        # and never move items across the bridge, as if
        # power.status were 1.0. N2178 is the item bridge's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the radar driver (N2173).
        # The family splits in two: phase-conveyor is an ItemBridge
        # with `consumePower(0.30f);` (Blocks.java:2125) and
        # `hasPower = true;` (ItemBridge.java:48), while
        # bridge-conveyor is a BufferedItemBridge
        # (BufferedItemBridge.java:9) with `hasPower = false;`
        # (BufferedItemBridge.java:18) and NO consumePower def --
        # its updateTransport polls an ItemBuffer instead of the
        # edelta loop, so its transport does NOT depend on
        # power.status. This slice covers phase-conveyor ONLY;
        # the driver's implementation list holds "ItemBridge"
        # only, so BufferedItemBridge never matches. Catalog quirk
        # to respect: bridge-conveyor lists `consumesPower: true`
        # despite `hasPower: false` and no `consumePower`
        # property, so the plain radar gate
        # (block.properties.has("consumePower")) is what matters
        # -- it correctly includes phase-conveyor and excludes
        # bridge-conveyor. Do NOT adapt the gate to `or
        # consumesPower` (the RepairTurret adaptation is for
        # ConsumePowerCondition defs; here the power def is a
        # plain static `consumePower(0.30f)`).
        # The item bridge's power draw is STATIC, not
        # conditional: `consumePower(0.30f);`
        # (Blocks.java:2125) registers a plain ConsumePower, so
        # the catalog consumePower 0.3 is present and the plain
        # radar gate works -- no RepairTurret-style `or
        # consumesPower` adaptation is needed. ItemBridgeBuild
        # DOES override shouldConsume: `return hadValidLink &&
        # enabled;` (ItemBridge.java:495-496), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1994,
        # `if(!update){` / efficiency = optionalEfficiency =
        # 0f). RED decision (the PointDefenseTurret N2151
        # precedent, whose `return super.shouldConsume() && target
        # != null;` gate was deferred the same way, and the
        # RepairTurret N2174 / RepairTower N2176 / ShockwaveTower
        # N2177 precedents): the port tracks NO live link on any
        # placed-building frame, so this slice folds power-only
        # and defers the gate with a documented limit -- when
        # unlinked power.status reads 1.0 while Java efficiency
        # is 0; the observable gap is efficiency 1.0 vs 0.0 when
        # unlinked. Two new result symbols: the row and its
        # presence flag.
        self.assertEqual(
            ledger['N2178']['source_symbols'],
            [
                'source_item_bridge_power_status_row_state_result.row',
                'source_item_bridge_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2178']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_power_status_row_state_result.row': 'SourceItemBridgeBuildState.source_item_bridge_power_status_row_state',
                    'source_item_bridge_power_status_row_state_result.has_power_row': 'SourceItemBridgeBuildState.source_item_bridge_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2178']['runtime_proof'], '/root/C07ItemBridgePowerStatusProof')
        self.assertEqual(
            ledger['N2178']['tests'],
            [
                'test_c07_item_bridge_power_status_registration',
                'test_all_c07_item_bridge_power_status_input_evidence_is_exact',
                'test_item_bridge_power_status_row_state',
                'test_reference_graph_and_actual_c07_item_bridge_power_status',
            ],
        )
        self.assertTrue(ledger['N2178']['deferred_exprs'])

    def test_all_c07_item_bridge_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2178']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_power_status_row_state_result.row': 'SourceItemBridgeBuildState.source_item_bridge_power_status_row_state',
                    'source_item_bridge_power_status_row_state_result.has_power_row': 'SourceItemBridgeBuildState.source_item_bridge_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/world/blocks/distribution/BufferedItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2178']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_power_status_row_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new item-bridge build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_item_bridge_power_status_row_state', item_bridge)
        self.assertIn('return build.power.status;', item_bridge)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', item_bridge)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the item bridge's
        # static power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`). The single def carries `consumePower(0.30f);`
        # (Blocks.java:2125) with `range = 12;`
        # (Blocks.java:2118) and `transportTime = 2f;`
        # (Blocks.java:2119). The item bridge's updateTransport
        # (ItemBridge.java:356, `transportCounter += edelta();`,
        # keep on ONE comment line, the N2148 shootWarmup lesson:
        # a split line fails this test) charges its transport
        # counter by edelta(), and edelta() is efficiency * delta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`). The warmup approach (ItemBridge.java:345,
        # `warmup = Mathf.approachDelta(warmup, efficiency, 1f /
        # 30f);`) also follows the folded efficiency when a valid
        # link exists; without a link `warmup = 0f`
        # (ItemBridge.java:337). draw() uses `float warmup =
        # hasPower ? this.warmup : 1f;` (ItemBridge.java:387) --
        # the bridge-conveyor (hasPower false) always draws
        # warmup 1f, another reason the two defs must not share
        # one driver row.
        # ItemBridgeBuild overrides shouldConsume
        # (ItemBridge.java:495, `public boolean shouldConsume(){`
        # with `return hadValidLink && enabled;`,
        # ItemBridge.java:496); updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). RED decision (the PointDefenseTurret
        # N2151 precedent and the RepairTurret N2174 / RepairTower
        # N2176 / ShockwaveTower N2177 precedents): the port
        # tracks no live link on any placed-building frame, so
        # this slice folds power-only and defers the gate with a
        # documented limit; the machinery runs with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). The link gate itself is
        # `hadValidLink = linkValid(tile, other);`
        # (ItemBridge.java:333).
        # The item bridge is its own family
        # (ItemBridge.java:24, `public class ItemBridge extends
        # Block{`; ItemBridgeBuild, ItemBridge.java:197, `public
        # class ItemBridgeBuild extends Building{`), a
        # distribution block, NOT related to any factory / turret
        # / defense family. Class fields: `public final int
        # timerCheckMoved = timers ++;` (ItemBridge.java:25),
        # `public int range;` (ItemBridge.java:27), `public float
        # transportTime;` (ItemBridge.java:28), `public boolean
        # fadeIn = true;` (ItemBridge.java:34), `public boolean
        # moveArrows = true;` (ItemBridge.java:35), `public
        # boolean pulse = false;` (ItemBridge.java:36), `public
        # float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod =
        # 0.4f;` (ItemBridge.java:37), `public float arrowTimeScl
        # = 6.2f;` (ItemBridge.java:38), `public float bridgeWidth
        # = 6.5f;` (ItemBridge.java:39); constructor `update =
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
        # (ItemBridge.java:207). BufferedItemBridge extends
        # ItemBridge (BufferedItemBridge.java:9, `public class
        # BufferedItemBridge extends ItemBridge{`) with
        # `hasPower = false;` (BufferedItemBridge.java:18) and
        # `bufferCapacity = 50` class default (def overrides to
        # 14, Blocks.java:2113) and `speed = 74f` (def,
        # Blocks.java:2112). canConsume (BuildingComp.java:1917,
        # `public boolean canConsume(){` with `return
        # potentialEfficiency > 0;`, BuildingComp.java:1918) and
        # the shouldConsume default (BuildingComp.java:755,
        # `public boolean shouldConsume(){` with `return
        # enabled;`, BuildingComp.java:756) are the surrounding
        # gates. No sense / read / write overrides exist on
        # ItemBridgeBuild -- those wait for their own slices only
        # if a later Java line needs them.
        # Single def -- phase-conveyor only (size 1, range 12,
        # transportTime 2f, phase-fabric 5 / silicon 7 / lead 10
        # / graphite 10, Blocks.java:2116-2125).
        # bridge-conveyor (BufferedItemBridge, no power def) is
        # explicitly OUT of scope.
        self.assertIn('"is_power": true', item_bridge)
        self.assertIn('block.properties.has("consumePower")', item_bridge)
        self.assertIn('hasConsumers = consumers.length > 0;', item_bridge)
        self.assertIn('consumePower(0.30f);', item_bridge)
        self.assertIn('range = 12;', item_bridge)
        self.assertIn('transportTime = 2f;', item_bridge)
        self.assertIn('public class ItemBridge extends Block{', item_bridge)
        self.assertIn('public class ItemBridgeBuild extends Building{', item_bridge)
        self.assertIn('public final int timerCheckMoved = timers ++;', item_bridge)
        self.assertIn('public int range;', item_bridge)
        self.assertIn('public float transportTime;', item_bridge)
        self.assertIn('public boolean fadeIn = true;', item_bridge)
        self.assertIn('public boolean moveArrows = true;', item_bridge)
        self.assertIn('public boolean pulse = false;', item_bridge)
        self.assertIn('public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;', item_bridge)
        self.assertIn('public float arrowTimeScl = 6.2f;', item_bridge)
        self.assertIn('public float bridgeWidth = 6.5f;', item_bridge)
        self.assertIn('update = true;', item_bridge)
        self.assertIn('solid = true;', item_bridge)
        self.assertIn('underBullets = true;', item_bridge)
        self.assertIn('hasPower = true;', item_bridge)
        self.assertIn('itemCapacity = 10;', item_bridge)
        self.assertIn('configurable = true;', item_bridge)
        self.assertIn('hasItems = true;', item_bridge)
        self.assertIn('public int link = -1;', item_bridge)
        self.assertIn('public IntSeq incoming = new IntSeq(false, 4);', item_bridge)
        self.assertIn('public float warmup;', item_bridge)
        self.assertIn('public float time = -8f, timeSpeed;', item_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', item_bridge)
        self.assertIn('public float transportCounter;', item_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', item_bridge)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);', item_bridge)
        self.assertIn('transportCounter += edelta();', item_bridge)
        self.assertIn('float warmup = hasPower ? this.warmup : 1f;', item_bridge)
        self.assertIn('public class BufferedItemBridge extends ItemBridge{', item_bridge)
        self.assertIn('hasPower = false;', item_bridge)
        self.assertIn('public boolean shouldConsume(){', item_bridge)
        self.assertIn('return hadValidLink && enabled;', item_bridge)
        self.assertIn('public boolean canConsume(){', item_bridge)
        self.assertIn('return potentialEfficiency > 0;', item_bridge)
        self.assertIn('return enabled;', item_bridge)
        self.assertIn('boolean update = shouldConsume() && productionValid();', item_bridge)
        self.assertIn('if(!update){', item_bridge)
        self.assertIn('return efficiency * delta();', item_bridge)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', item_bridge)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', item_bridge)
        self.assertIn('static func source_item_bridge_tick_buildings_state', item_bridge)
        # The item bridge needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the radar precedent, N2173).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_item_bridge_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_item_bridge_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no transport / warmup
        # / link keys: the updateTile advance (ItemBridge.java:
        # 319-347) waits for its own slice, so the transport
        # charge (ItemBridge.java:356) is what the efficiency
        # keys prove.
        proof = ITEM_BRIDGE_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'item_bridge_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_item_bridge_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgePowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'item_bridge_has_power_consumer',
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
