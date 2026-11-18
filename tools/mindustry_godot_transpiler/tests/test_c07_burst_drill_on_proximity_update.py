import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_ON_PROXIMITY_UPDATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillOnProximityUpdateProof.gd'


class C07BurstDrillOnProximityUpdateTests(unittest.TestCase):
    def test_c07_burst_drill_on_proximity_update_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2262']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_on_proximity_update_state')
        # DrillBuild.onProximityUpdate (Drill.java:266-277,
        # `public void onProximityUpdate(){` with
        # `super.onProximityUpdate();` / `countOre(tile);` /
        # `dominantItem = returnItem;` / `dominantItems =
        # returnCount;`) is inherited whole by BurstDrillBuild
        # (BurstDrill.java:17, `public class BurstDrill
        # extends Drill{`, with BurstDrillBuild,
        # BurstDrill.java:70, `public class BurstDrillBuild
        # extends DrillBuild{`, and DrillBuild,
        # Drill.java:237, `public class DrillBuild extends
        # Building{`) -- BurstDrill does not override it.
        # countOre (Drill.java:198-229, `protected void
        # countOre(Tile tile){`) resets returnItem /
        # returnCount, counts the drop of every linked tile
        # canMine accepts (`for(Tile other :
        # tile.getLinkedTilesAs(this, tempTiles)){` /
        # `if(canMine(other)){` /
        # `oreCount.increment(getDrop(other), 0, 1);`),
        # sorts the counted items low-priority-last, then by
        # count, then by id (`int type =
        # Boolean.compare(!item1.lowPriority,
        # !item2.lowPriority);` / `if(type != 0) return
        # type;` / `int amounts = Integer.compare(
        # oreCount.get(item1, 0), oreCount.get(item2, 0));`
        # / `if(amounts != 0) return amounts;` /
        # `return Integer.compare(item1.id, item2.id);`)
        # and peeks the last one (`if(itemArray.size ==
        # 0){` / `returnItem = itemArray.peek();` /
        # `returnCount = oreCount.get(itemArray.peek(),
        # 0);`). canMine (Drill.java:230-235, `public
        # boolean canMine(Tile tile){`) rejects a null or
        # static tile and requires a drop whose hardness is
        # at most the tier and which is not blocked
        # (`if(tile == null || tile.block().isStatic())
        # return false;` / `Item drops = tile.drop();` /
        # `return drops != null && drops.hardness <= tier
        # && (blockedItems == null ||
        # !blockedItems.contains(drops));`). Drill.init
        # (Drill.java:93-94) turns a lone blockedItem into
        # the list (`if(blockedItems == null &&
        # blockedItem != null){` / `blockedItems =
        # Seq.with(blockedItem);`). The per-def values are
        # explicit params (the N2212 / N2248 per-def-param
        # precedent): impact-drill tier 6
        # (Blocks.java:3076, `tier = 6;`) with blockedItem
        # thorium (Blocks.java:3080, `blockedItem =
        # Items.thorium;`); eruption-drill tier 7
        # (Blocks.java:3097, `tier = 7;`) with NO blocked
        # item. N2262 closes the BurstDrill-owned binding
        # gate with one pure function delegating to the
        # N2010/N2020 core -- it does NOT port countOre
        # again (one pure function, one owner): the
        # function takes (linked_tiles, tier,
        # blocked_items) and returns the dominant_item /
        # dominant_items pair the frame carries. The live
        # driver already stamps those keys: the placement
        # callback (SourceWorldTerrainRuntimeState.gd:116)
        # calls
        # SourceDrillConsumptionRuntimeState.
        # source_on_proximity_update_state for every placed
        # build, and that driver stamps frame["dominant_item"]
        # / frame["dominant_items"] under the shared meta
        # key "source_drill_building" -- the same key as
        # SOURCE_BURST_DRILL_BUILDING_META_KEY
        # (SourceBurstDrillBuildState.gd:27) -- so the
        # burst-drill frame IS the drill frame. The driver
        # gate is the catalog key, not the value: it returns
        # {"applied": false} only when
        # block.properties lacks "blockedItems", and the
        # catalog carries that key (null-valued) for BOTH
        # defs -- impact-drill blockedItem thorium /
        # blockedItems null, eruption-drill blockedItem null
        # / blockedItems null -- so applied is true for
        # both, and the bind helper
        # (SourceDrillRuntimeState.
        # source_bind_ore_items_state) resolves impact to
        # blocked_items [thorium] and eruption to
        # blocked_items null. Proximity update runs at
        # placement, not per tick, so there is NO driver
        # tick line in
        # source_burst_drill_tick_buildings_state. Two new
        # result symbols: dominant_item, dominant_items.
        self.assertEqual(
            ledger['N2262']['source_symbols'],
            [
                'source_burst_drill_on_proximity_update_state_result.dominant_item',
                'source_burst_drill_on_proximity_update_state_result.dominant_items',
            ],
        )
        for name in ledger['N2262']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2262']['runtime_proof'], '/root/C07BurstDrillOnProximityUpdateProof')
        self.assertEqual(
            ledger['N2262']['tests'],
            [
                'test_c07_burst_drill_on_proximity_update_registration',
                'test_all_c07_burst_drill_on_proximity_update_input_evidence_is_exact',
                'test_burst_drill_on_proximity_update_state',
                'test_reference_graph_and_actual_c07_burst_drill_on_proximity_update',
            ],
        )
        self.assertTrue(ledger['N2262']['deferred_exprs'])

    def test_all_c07_burst_drill_on_proximity_update_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2262']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2262']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_on_proximity_update_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure BurstDrill-owned binding gate lives on the
        # burst-drill build state next to the N2256 updateTile
        # advance: DrillBuild.onProximityUpdate
        # (Drill.java:266-277) runs countOre over the linked
        # tiles and assigns dominantItem / dominantItems from
        # the peeked return; BurstDrillBuild inherits it
        # whole (BurstDrill.java:17/70). The gate delegates
        # to the N2010/N2020 core
        # (SourceDrillRuntimeState.
        # source_on_proximity_update_state) instead of
        # porting countOre again -- one pure function, one
        # owner. The linked tiles are the drill's linked
        # tiles (Drill.java:206, `for(Tile other :
        # tile.getLinkedTilesAs(this, tempTiles)){`); the
        # tier gates canMine (Drill.java:230-235, `return
        # drops != null && drops.hardness <= tier &&
        # (blockedItems == null ||
        # !blockedItems.contains(drops));`); the blocked
        # list is null for a def with no blocked item
        # (eruption-drill) and holds the blocked item
        # otherwise (impact-drill thorium, Drill.init
        # Drill.java:93-94, `if(blockedItems == null &&
        # blockedItem != null){` / `blockedItems =
        # Seq.with(blockedItem);`). The per-def tier /
        # blockedItem are explicit params (the N2212 /
        # N2248 per-def-param precedent): impact-drill tier
        # 6 with blockedItem thorium, eruption-drill tier 7
        # with no blocked item (Blocks.java:3076/3080/3097).
        # The pickedUp reset (`public void pickedUp(){` /
        # `dominantItem = null;`, Drill.java:264-266) is
        # inherited too but waits for its own slice.
        # Proximity update runs at placement, not per tick,
        # so the tick driver never calls this function.
        self.assertIn('const source_drill_runtime_state := preload("res://src/game/SourceDrillRuntimeState.gd")', burst_drill)
        self.assertIn('static func source_burst_drill_on_proximity_update_state(linked_tiles: Array, tier: int, blocked_items: Variant) -> Dictionary:', burst_drill)
        # The gate delegates to the N2010/N2020 core and
        # returns the dominant pair the frame carries.
        self.assertIn('var selected: Dictionary = source_drill_runtime_state.source_on_proximity_update_state(linked_tiles, tier, blocked_items)', burst_drill)
        self.assertIn('return {"dominant_item": selected["dominant_item"], "dominant_items": selected["dominant_items"]}', burst_drill)
        for expr in [
            'protected void countOre(Tile tile){',
            'returnItem = null;',
            'returnCount = 0;',
            'oreCount.clear();',
            'itemArray.clear();',
            'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){',
            'if(canMine(other)){',
            'oreCount.increment(getDrop(other), 0, 1);',
            'for(Item item : oreCount.keys()){',
            'itemArray.add(item);',
            'int type = Boolean.compare(!item1.lowPriority, !item2.lowPriority);',
            'if(type != 0) return type;',
            'int amounts = Integer.compare(oreCount.get(item1, 0), oreCount.get(item2, 0));',
            'if(amounts != 0) return amounts;',
            'return Integer.compare(item1.id, item2.id);',
            'if(itemArray.size == 0){',
            'returnItem = itemArray.peek();',
            'returnCount = oreCount.get(itemArray.peek(), 0);',
            'public boolean canMine(Tile tile){',
            'if(tile == null || tile.block().isStatic()) return false;',
            'Item drops = tile.drop();',
            'return drops != null && drops.hardness <= tier && (blockedItems == null || !blockedItems.contains(drops));',
            'public void onProximityUpdate(){',
            'super.onProximityUpdate();',
            'countOre(tile);',
            'dominantItem = returnItem;',
            'dominantItems = returnCount;',
            'public int tier;',
            'public @Nullable Item blockedItem;',
            'public @Nullable Seq<Item> blockedItems;',
            'protected @Nullable Item returnItem;',
            'protected int returnCount;',
            'public int dominantItems;',
            'public Item dominantItem;',
            'if(blockedItems == null && blockedItem != null){',
            'blockedItems = Seq.with(blockedItem);',
            'public void pickedUp(){',
            'dominantItem = null;',
            'public class DrillBuild extends Building{',
            'public class BurstDrill extends Drill{',
            'public class BurstDrillBuild extends DrillBuild{',
            'tier = 6;',
            'blockedItem = Items.thorium;',
            'tier = 7;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # No per-tick driver line: proximity update runs at
        # placement (the SourceWorldTerrainRuntimeState
        # callback), so the burst-drill tick driver must not
        # call the binding gate.
        driver_start = burst_drill.index('static func source_burst_drill_tick_buildings_state')
        driver_text = burst_drill[driver_start:]
        self.assertNotIn('source_burst_drill_on_proximity_update_state', driver_text)
        # The proof's keys drive the pure binding gate (the
        # catalog blockedItems key for both defs, the bind
        # resolution for both defs, the impact exclusion,
        # the eruption inclusion, the empty / tie-break /
        # low-priority cases, and the round-trip into the
        # N2256 updateTile advance). There is no pickedUp
        # key and no placed-sprite live-run key: the
        # pickedUp reset and the placed-sprite run wait for
        # their own slices.
        proof = BURST_DRILL_ON_PROXIMITY_UPDATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'catalog_impact_blocked_items_key',
            'catalog_eruption_blocked_items_key',
            'bind_impact_thorium_blocked',
            'bind_eruption_null_blocked',
            'delegate_impact_excludes_thorium',
            'delegate_eruption_counts_thorium',
            'delegate_empty_tiebreak_low_priority',
            'roundtrip_update_tile_advances',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_on_proximity_update(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillOnProximityUpdateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_ON_PROXIMITY_UPDATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'catalog_impact_blocked_items_key',
            'catalog_eruption_blocked_items_key',
            'bind_impact_thorium_blocked',
            'bind_eruption_null_blocked',
            'delegate_impact_excludes_thorium',
            'delegate_eruption_counts_thorium',
            'delegate_empty_tiebreak_low_priority',
            'roundtrip_update_tile_advances',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
