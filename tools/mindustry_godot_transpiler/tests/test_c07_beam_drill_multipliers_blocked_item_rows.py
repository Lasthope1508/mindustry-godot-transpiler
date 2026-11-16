import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_MULTIPLIERS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillMultipliersBlockedItemRowsProof.gd'
BEAM_DRILL_MULTIPLIERS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillMultipliersBlockedItemRowsProof.tscn'


class C07BeamDrillMultipliersBlockedItemRowsTests(unittest.TestCase):
    def test_c07_beam_drill_multipliers_blocked_item_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2473']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_blocked_items_state')
        # N2473 is the BeamDrill drillMultipliers /
        # blockedItem rows (DEFERRED #13): two pure-only
        # pures, NO tick wiring. The init promotion
        # (BeamDrill.init, BeamDrill.java:81-87,
        # `if(blockedItems == null && blockedItem != null){`
        # / `blockedItems = Seq.with(blockedItem);`, :84-85)
        # wraps a lone blockedItem into the one-element
        # list, and the drill-time multiplier lookup
        # (BeamDrill.getDrillTime, BeamDrill.java:216-218,
        # `return drillTime / drillMultipliers.get(item, 1f);`,
        # :217) reads the ObjectFloatMap with the 1f
        # default. The fields are drillMultipliers :47,
        # blockedItem :49, blockedItems :51 -- NOT :36-40
        # as the entry cited (:36-40 are the top/glow
        # regions + drillTime + range). The lookup IS
        # drill-time, not setStats-only: updateTile calls
        # it every tick (`float drillTime =
        # getDrillTime(lastItem);`, :247) and the result
        # drives lastDrillSpeed (:249), the drop
        # threshold (:253) and the reset (:261); setStats
        # (:122) is only the OTHER use. Two new result
        # symbols, one per pure.
        self.assertEqual(
            ledger['N2473']['source_symbols'],
            [
                'source_beam_drill_blocked_items_state_result.blocked_items_after',
                'source_beam_drill_drill_multiplier_state_result.multiplier',
            ],
        )
        for name in ledger['N2473']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertIn(symbol['godot_owner'], ('SourceBeamDrillBuildState.source_beam_drill_blocked_items_state', 'SourceBeamDrillBuildState.source_beam_drill_drill_multiplier_state'))
        self.assertEqual(ledger['N2473']['runtime_proof'], '/root/C07BeamDrillMultipliersBlockedItemRowsProof')
        self.assertEqual(
            ledger['N2473']['tests'],
            [
                'test_c07_beam_drill_multipliers_blocked_item_rows_registration',
                'test_all_c07_beam_drill_multipliers_blocked_item_rows_input_evidence_is_exact',
                'test_beam_drill_multipliers_blocked_item_rows_state',
                'test_reference_graph_and_actual_c07_beam_drill_multipliers_blocked_item_rows',
            ],
        )
        self.assertTrue(ledger['N2473']['deferred_exprs'])
        # This slice RESOLVES the drillMultipliers /
        # blockedItem entry (#13) by text: the old entry
        # (with its wrong :36-40 cite) is gone. The
        # drop-loop entry is REWRITTEN in place (the
        # multiplier lookup is live since N2473, the
        # getDrillTime wiring into the advance waits for
        # the drop-loop slice), and a NEW canPlaceOn /
        # drawPlace entry records the :205 / :154 gates
        # (same gate shape as the :391 facing gate, but
        # the placement methods themselves are not
        # ported). The facing / laser binding entry
        # stays.
        self.assertFalse(any(entry.startswith('BeamDrill drillMultipliers / blockedItem rows (') for entry in ledger['N2473']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') and 'live since N2473' in entry for entry in ledger['N2473']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill canPlaceOn / drawPlace rows (') for entry in ledger['N2473']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill facing / laser binding (') for entry in ledger['N2473']['deferred_exprs']))

    def test_all_c07_beam_drill_multipliers_blocked_item_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2473']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceBeamDrillBuildState.source_beam_drill_blocked_items_state', 'SourceBeamDrillBuildState.source_beam_drill_drill_multiplier_state'))
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/struct/ObjectFloatMap.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2473']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_multipliers_blocked_item_rows_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The init promotion (BeamDrill.init,
        # BeamDrill.java:81-87 -- NOT :78-83, the old
        # facing-scan docstring cite):
        # `if(blockedItems == null && blockedItem != null){`
        # `blockedItems = Seq.with(blockedItem);`
        # (:84-85). The fields are
        # `public @Nullable Item blockedItem;`
        # (:49 -- NOT :38) and
        # `public @Nullable Seq<Item> blockedItems;`
        # (:51 -- NOT :40), and the map is
        # `public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();`
        # (:47). The lookup is getDrillTime
        # (`public float getDrillTime(Item item){` /
        # `return drillTime / drillMultipliers.get(item, 1f);`,
        # :216-218), called every tick by updateTile
        # (`float drillTime = getDrillTime(lastItem);`,
        # :247) to drive
        # `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`
        # (:249),
        # `if(time >= drillTime){`
        # (:253) and
        # `time %= drillTime;`
        # (:261) -- so drillMultipliers IS drill-time,
        # not setStats-only (setStats is only the other
        # use:
        # `stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->`,
        # :122). drawPlace reads it too for the speed
        # text
        # (`float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);`,
        # :183, in
        # `public void drawPlace(int x, int y, int rotation, boolean valid){`).
        # The base is
        # `public float drillTime = 200f;`
        # (:39), `drillTime = 160f;` plasma-bore /
        # `drillTime = 100f;` large-plasma-bore
        # (Blocks.java:3042/3055). The 1f default is
        # honoured by arc
        # (`public float get(K key, float defaultValue){`,
        # ObjectFloatMap.java:286, returns defaultValue
        # when the key is absent -- including a null key,
        # `if(key == null) return defaultValue;`, :287,
        # the lastItem-null case). The promoted list is
        # what the three drill gates read -- the
        # updateFacing gate
        # `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){`
        # (:391, live since N2339), the drawPlace gate
        # (:154) and the canPlaceOn gate (:205, in
        # `public boolean canPlaceOn(Tile tile, Team team, int rotation){`).
        # The thorium / beryllium-2f proof values are
        # BurstDrill def values
        # (`blockedItem = Items.thorium;`, Blocks.java:3080,
        # `drillMultipliers.put(Items.beryllium, 2f);`,
        # Blocks.java:3083/3114) -- neither BeamDrill def
        # sets an entry (Blocks.java:3038-3068). Keep each
        # Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this
        # test).
        self.assertIn('static func source_beam_drill_blocked_items_state', beam_drill)
        self.assertIn('static func source_beam_drill_drill_multiplier_state', beam_drill)
        self.assertIn('public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();', beam_drill)
        self.assertIn('public @Nullable Item blockedItem;', beam_drill)
        self.assertIn('public @Nullable Seq<Item> blockedItems;', beam_drill)
        self.assertIn('if(blockedItems == null && blockedItem != null){', beam_drill)
        self.assertIn('blockedItems = Seq.with(blockedItem);', beam_drill)
        self.assertIn('public float getDrillTime(Item item){', beam_drill)
        self.assertIn('return drillTime / drillMultipliers.get(item, 1f);', beam_drill)
        self.assertIn('float drillTime = getDrillTime(lastItem);', beam_drill)
        self.assertIn('lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;', beam_drill)
        self.assertIn('if(time >= drillTime){', beam_drill)
        self.assertIn('time %= drillTime;', beam_drill)
        self.assertIn('public float drillTime = 200f;', beam_drill)
        self.assertIn('stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->', beam_drill)
        self.assertIn('float width = drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / getDrillTime(item) * count, 2), x, y, valid);', beam_drill)
        self.assertIn('public boolean canPlaceOn(Tile tile, Team team, int rotation){', beam_drill)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', beam_drill)
        self.assertIn('if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){', beam_drill)
        self.assertIn('drillTime = 160f;', beam_drill)
        self.assertIn('drillTime = 100f;', beam_drill)
        self.assertIn('drillMultipliers.put(Items.beryllium, 2f);', beam_drill)
        self.assertIn('blockedItem = Items.thorium;', beam_drill)
        self.assertIn('public float get(K key, float defaultValue){', beam_drill)
        self.assertIn('if(key == null) return defaultValue;', beam_drill)
        # The two pures return exactly their one N2473 key
        # each: the init pure promotes a lone blockedItem
        # to [blocked_item] and passes anything else
        # through unchanged; the multiplier pure returns
        # 1.0 for a null item (the ObjectFloatMap null-key
        # early return) and the mapped value or 1.0
        # otherwise. The map is caller-supplied (the
        # N2435 precedent): a Dict item-name -> float.
        self.assertIn('static func source_beam_drill_blocked_items_state(blocked_item: Variant, blocked_items: Variant) -> Dictionary:', beam_drill)
        self.assertIn('static func source_beam_drill_drill_multiplier_state(item: Variant, drill_multipliers: Dictionary) -> Dictionary:', beam_drill)
        self.assertIn('return {"blocked_items_after": [blocked_item]}', beam_drill)
        self.assertIn('return {"blocked_items_after": blocked_items}', beam_drill)
        self.assertIn('return {"multiplier": 1.0}', beam_drill)
        self.assertIn('return {"multiplier": float(drill_multipliers.get(item, 1.0))}', beam_drill)
        # Pure-only: NO tick wiring -- the tick never
        # calls either pure (the init transition is a
        # def-time row, the getDrillTime division waits
        # for the drop-loop slice, and the facing scan
        # keeps the shared Drill bind). The documented
        # limits now record the rows as live since N2473
        # (with the corrected :47/:49/:51 cites and the
        # drill-time verdict) and the facing-scan
        # docstring cites are corrected (:51/:49/:81-87).
        self.assertEqual(beam_drill.count('source_beam_drill_blocked_items_state('), 1)
        self.assertEqual(beam_drill.count('source_beam_drill_drill_multiplier_state('), 1)
        self.assertIn('drillMultipliers / blockedItem rows are live since', beam_drill)
        self.assertIn('N2473', beam_drill)
        self.assertIn('(3) Partial updateTile', beam_drill)
        self.assertIn('advance (N2195)', beam_drill)
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        self.assertIn('timerDump dump is live since N2289', beam_drill)
        self.assertIn('time grows unbounded', beam_drill)
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('static func source_beam_drill_facing_scan_state', beam_drill)
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        self.assertIn('static func source_beam_drill_timer_dump_state', beam_drill)
        # The pure N2195 advance is untouched: its return
        # dict keeps exactly the four N2195 keys.
        self.assertIn('return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}', beam_drill)
        # The proof's keys drive both pures (the init
        # promotion: sets / keeps / null; the lookup: hit
        # / default / the BeamDrill def map, which is
        # empty so every item reads 1.0).
        proof = BEAM_DRILL_MULTIPLIERS_PROOF.read_text(encoding='utf-8')
        for key in [
            'blocked_init_sets',
            'blocked_init_keeps',
            'blocked_init_null',
            'multiplier_hit',
            'multiplier_default',
            'multiplier_def',
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
        self.assertIn('beam_drill_build_state.source_beam_drill_blocked_items_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_drill_multiplier_state(', proof)
        scene = BEAM_DRILL_MULTIPLIERS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillMultipliersBlockedItemRowsProof.gd', scene)
        self.assertIn('C07BeamDrillMultipliersBlockedItemRowsProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_multipliers_blocked_item_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillMultipliersBlockedItemRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_MULTIPLIERS_BLOCKED_ITEM_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'blocked_init_sets',
            'blocked_init_keeps',
            'blocked_init_null',
            'multiplier_hit',
            'multiplier_default',
            'multiplier_def',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
