import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_DROP_LOOP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDropLoopProof.gd'
BEAM_DRILL_DROP_LOOP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDropLoopProof.tscn'


class C07BeamDrillDropLoopTests(unittest.TestCase):
    def test_c07_beam_drill_drop_loop_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2477']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_drop_loop_state')
        # N2477 is the BeamDrill drop loop + time reset +
        # lastDrillSpeed (DEFERRED #119): a NEW pure,
        # tick-wired after the N2195 advance -- NOT an
        # amendment of the advance. The advance cannot
        # grow: the N2473 test pins its return dict to
        # exactly the four N2195 keys, and the N2195 test
        # pins its 3-arg call string, so the drop loop
        # lives in its own pure (the N2289 timer-dump
        # precedent) and the tick calls it between the
        # advance (:251) and the timerDump dump (:264),
        # the Java order inside updateTile
        # (BeamDrill.java:237-267). The pure re-walks the
        # facing rays (updateFacing, BeamDrill.java:
        # 375-411 -- the SAME walk as the N2339 scan, which
        # returns ONLY the count and has no last_item /
        # facing key to read) to derive facing[] + lastItem
        # (multiple distinct drops -> null, :393-394 /
        # :408-409), wires getDrillTime (:247, via the
        # N2473 lookup -- INLINED, not called: the N2473
        # test pins the multiplier pure's call count at 1,
        # the definition alone), computes lastDrillSpeed
        # (:249), runs the capacity-gated drop loop
        # (:253-261, items.total() re-checked PER tile)
        # and resets time with `%=` (:261). Seven new
        # result symbols, one per return key.
        self.assertEqual(
            ledger['N2477']['source_symbols'],
            [
                'source_beam_drill_drop_loop_state_result.last_item',
                'source_beam_drill_drop_loop_state_result.facing',
                'source_beam_drill_drop_loop_state_result.drill_time',
                'source_beam_drill_drop_loop_state_result.last_drill_speed',
                'source_beam_drill_drop_loop_state_result.time',
                'source_beam_drill_drop_loop_state_result.items',
                'source_beam_drill_drop_loop_state_result.produced',
            ],
        )
        for name in ledger['N2477']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_drop_loop_state')
        self.assertEqual(ledger['N2477']['runtime_proof'], '/root/C07BeamDrillDropLoopProof')
        self.assertEqual(
            ledger['N2477']['tests'],
            [
                'test_c07_beam_drill_drop_loop_registration',
                'test_all_c07_beam_drill_drop_loop_input_evidence_is_exact',
                'test_beam_drill_drop_loop_state',
                'test_reference_graph_and_actual_c07_beam_drill_drop_loop',
            ],
        )
        self.assertTrue(ledger['N2477']['deferred_exprs'])
        # This slice RESOLVES the drop-loop entry (#119)
        # by text: the old entry is gone. One NEW entry
        # records the produced() sector stats + unlock
        # (BuildingComp.java:1039-1046 -- the pure reports
        # produced counts per item, no sector stats write
        # exists in the port). Count stays 234 (234 - 1
        # resolved + 1 new). The canPlaceOn / drawPlace
        # entry (N2478's slice) and the disabled-early-
        # return entry stay.
        self.assertEqual(len(ledger['N2477']['deferred_exprs']), 234)
        self.assertFalse(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2477']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill produced() sector stats (') for entry in ledger['N2477']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill canPlaceOn / drawPlace rows (') for entry in ledger['N2477']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill disabled-early-return rows (') for entry in ledger['N2477']['deferred_exprs']))

    def test_all_c07_beam_drill_drop_loop_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2477']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_drop_loop_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Tile.java'),
            ('arc-upstream', 'arc-core/src/arc/struct/ObjectFloatMap.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2477']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_drop_loop_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The drop loop (BeamDrillBuild.updateTile(),
        # BeamDrill.java:237-267, in Java order):
        # `float drillTime = getDrillTime(lastItem);`
        # (:247, getDrillTime :216-218,
        # `public float getDrillTime(Item item){` /
        # `return drillTime / drillMultipliers.get(item, 1f);`,
        # :217, the map
        # `public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`,
        # :47, with the 1f default honoured by arc
        # `public float get(K key, float defaultValue){`,
        # ObjectFloatMap.java:286, including a null item,
        # `if(key == null) return defaultValue;`, :287),
        # `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`
        # (:249),
        # `if(time >= drillTime){`
        # (:253),
        # `for(Tile tile : facing){`
        # (:254),
        # `Item drop = tile == null ? null : tile.wallDrop();`
        # (:255, wallDrop
        # `public @Nullable Item wallDrop(){`,
        # Tile.java:575),
        # `if(items.total() < itemCapacity && drop != null){`
        # (:256, the capacity gate re-checked PER tile),
        # `items.add(drop, 1);`
        # (:257),
        # `produced(drop);`
        # (:258, `public void produced(Item item){`,
        # BuildingComp.java:1035, the sector stats +
        # unlock -- reported as counts, not written),
        # `time %= drillTime;`
        # (:261). The facing[] dests + lastItem come
        # from updateFacing (:375-411):
        # `public Tile[] facing = new Tile[size];`
        # (:221),
        # `public @Nullable Item lastItem;`
        # (:223), the multiple detection
        # `if(lastItem != drop && lastItem != null){`
        # / `multiple = true;` (:393-394),
        # `facing[p] = dest;` (:404), the null-out
        # `if(multiple){` / `lastItem = null;`
        # (:408-409), over the mineable gate
        # `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
        # (:391). The base drillTime is
        # `public float drillTime = 200f;`
        # (:39), `drillTime = 160f;` plasma-bore /
        # `drillTime = 100f;` large-plasma-bore
        # (Blocks.java:3042/3055); itemCapacity is
        # `public int itemCapacity = 10;`
        # (Block.java:75), `itemCapacity = 20;`
        # large-plasma-bore (Blocks.java:3062). The
        # class range / tier are :40/:41 (NOT :35-36
        # as the old scan docstring cited -- :35-36 are
        # the top/glow region lines; the N2473
        # :36-40 lesson, same class of drift). Keep
        # each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this
        # test).
        self.assertIn('static func source_beam_drill_drop_loop_state(frame: Dictionary, time_scale: float, drill_time_base: float, drill_multipliers: Dictionary, item_capacity: int, size: int, beam_range: int, tier: int, blocked_items: Variant) -> Dictionary:', beam_drill)
        self.assertIn('public Tile[] facing = new Tile[size];', beam_drill)
        self.assertIn('public @Nullable Item lastItem;', beam_drill)
        self.assertIn('public float drillTime = 200f;', beam_drill)
        self.assertIn('public float getDrillTime(Item item){', beam_drill)
        self.assertIn('return drillTime / drillMultipliers.get(item, 1f);', beam_drill)
        self.assertIn('float drillTime = getDrillTime(lastItem);', beam_drill)
        self.assertIn('lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;', beam_drill)
        self.assertIn('if(time >= drillTime){', beam_drill)
        self.assertIn('for(Tile tile : facing){', beam_drill)
        self.assertIn('Item drop = tile == null ? null : tile.wallDrop();', beam_drill)
        self.assertIn('if(items.total() < itemCapacity && drop != null){', beam_drill)
        self.assertIn('items.add(drop, 1);', beam_drill)
        self.assertIn('produced(drop);', beam_drill)
        self.assertIn('time %= drillTime;', beam_drill)
        self.assertIn('if(lastItem != drop && lastItem != null){', beam_drill)
        self.assertIn('multiple = true;', beam_drill)
        self.assertIn('facing[p] = dest;', beam_drill)
        self.assertIn('if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){', beam_drill)
        self.assertIn('drillTime = 160f;', beam_drill)
        self.assertIn('drillTime = 100f;', beam_drill)
        self.assertIn('public int itemCapacity = 10;', beam_drill)
        self.assertIn('itemCapacity = 20;', beam_drill)
        self.assertIn('public float get(K key, float defaultValue){', beam_drill)
        self.assertIn('if(key == null) return defaultValue;', beam_drill)
        self.assertIn('public void produced(Item item){', beam_drill)
        self.assertIn('public @Nullable Item wallDrop(){', beam_drill)
        # The pure returns exactly its seven N2477 keys;
        # the multiplier lookup is INLINED (a null
        # lastItem reads 1.0, the arc null-key rule --
        # the pure never calls the N2473 multiplier pure
        # by name, whose call count the N2473 test pins
        # at 1); the reset is fmod (the BurstDrill
        # precedent); the capacity gate re-checks
        # items.total() PER tile through the shared
        # inventory helper, and each add goes through
        # the same helper.
        self.assertIn('return {"last_item": last_item, "facing": facing, "drill_time": drill_time, "last_drill_speed": last_drill_speed, "time": time, "items": next_items, "produced": produced}', beam_drill)
        self.assertIn('float(drill_multipliers.get(last_item, 1.0))', beam_drill)
        self.assertIn('fmod(time, drill_time)', beam_drill)
        self.assertIn('source_drill_inventory_runtime_state.items_total(next_items)', beam_drill)
        self.assertIn('source_drill_inventory_runtime_state.add_item_state(next_items, face_drop_id, 1)', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_DRILL_TIME_DEFAULT := 200.0', beam_drill)
        # The tick wires the drop loop AFTER the advance
        # and BEFORE the timerDump dump (Java order
        # :251 -> :253-262 -> :264-266), inside the same
        # enabled gate; drillTime reads the catalog per
        # def with the 200f class default, the
        # multiplier map is {} (neither def sets an
        # entry, Blocks.java:3038-3068, the N2473
        # verification), itemCapacity reads the catalog
        # (10 default, Block.java:75), and the scan
        # locals (size / range / tier / blockedItems)
        # are reused. The write-back stamps last_item /
        # facing / drill_time / last_drill_speed / time
        # / items / produced onto the frame.
        self.assertIn('block.properties.get("drillTime", SOURCE_BEAM_DRILL_DRILL_TIME_DEFAULT)', beam_drill)
        self.assertIn('source_beam_drill_drop_loop_state(frame, time_scale, beam_drill_time, {}, int(block.properties.get("itemCapacity", 10)), beam_size, beam_range, beam_tier, beam_blocked_items)', beam_drill)
        self.assertIn('frame["last_item"] = dropped.get("last_item", null)', beam_drill)
        self.assertIn('frame["facing"] = dropped.get("facing", [])', beam_drill)
        self.assertIn('frame["drill_time"] = dropped.get("drill_time", beam_drill_time)', beam_drill)
        self.assertIn('frame["last_drill_speed"] = dropped.get("last_drill_speed", 0.0)', beam_drill)
        self.assertIn('frame["time"] = dropped.get("time", frame.get("time", 0.0))', beam_drill)
        self.assertIn('frame["items"] = dropped.get("items", frame.get("items", {}))', beam_drill)
        self.assertIn('frame["produced"] = dropped.get("produced", {})', beam_drill)
        self.assertEqual(beam_drill.count('source_beam_drill_drop_loop_state('), 2)
        self.assertLess(
            beam_drill.index('source_beam_drill_update_tile_advance_state(frame, source_delta, time_scale)'),
            beam_drill.index('source_beam_drill_drop_loop_state(frame, time_scale, beam_drill_time, {}, int(block.properties.get("itemCapacity", 10)), beam_size, beam_range, beam_tier, beam_blocked_items)'),
        )
        self.assertLess(
            beam_drill.index('source_beam_drill_drop_loop_state(frame, time_scale, beam_drill_time, {}, int(block.properties.get("itemCapacity", 10)), beam_size, beam_range, beam_tier, beam_blocked_items)'),
            beam_drill.index('source_beam_drill_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the drop loop
        # as live since N2477 (N2477 IS the reset slice
        # the old note waited for); the N2195 advance,
        # the N2202 gate, the N2339 scan and the N2289
        # timer dump are preserved, and the pure N2195
        # advance is untouched: its return dict keeps
        # exactly the four N2195 keys.
        self.assertIn('drop loop + `time %= drillTime;` reset +', beam_drill)
        self.assertIn('are live since N2477', beam_drill)
        self.assertIn('N2477 IS that reset slice', beam_drill)
        self.assertIn('(3) Partial updateTile', beam_drill)
        self.assertIn('advance (N2195)', beam_drill)
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        self.assertIn('timerDump dump is live since N2289', beam_drill)
        self.assertIn('time grows unbounded', beam_drill)
        self.assertIn('facing scan live (N2339)', beam_drill)
        self.assertIn('return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}', beam_drill)
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('static func source_beam_drill_facing_scan_state', beam_drill)
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        self.assertIn('static func source_beam_drill_timer_dump_state', beam_drill)
        # The proof's keys drive the pure drop loop (the
        # threshold gate, the reset + adds, the per-tile
        # capacity re-check, the lastDrillSpeed formula,
        # the multiplier dividing the base drillTime)
        # plus the live tick (a placed plasma-bore drops
        # on a seeded near-threshold clock).
        proof = BEAM_DRILL_DROP_LOOP_PROOF.read_text(encoding='utf-8')
        for key in [
            'drop_threshold',
            'drop_time_reset',
            'drop_capacity_gate',
            'drop_last_drill_speed',
            'drop_multiplier',
            'drop_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('beam_drill_build_state.source_beam_drill_drop_loop_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_tick_buildings_state(', proof)
        scene = BEAM_DRILL_DROP_LOOP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillDropLoopProof.gd', scene)
        self.assertIn('C07BeamDrillDropLoopProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_drop_loop(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDropLoopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DROP_LOOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'drop_threshold',
            'drop_time_reset',
            'drop_capacity_gate',
            'drop_last_drill_speed',
            'drop_multiplier',
            'drop_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
