import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorUpdateTileProof.gd'
SEPARATOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorUpdateTileProof.tscn'


class C07SeparatorUpdateTileTests(unittest.TestCase):
    def test_c07_separator_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2222']['godot_owner'], 'SourceSeparatorBuildState.source_separator_update_tile_advance_state')
        # N2200 gave the separator its live shouldConsume gate --
        # total minus the consItems buffer < itemCapacity &&
        # enabled, fed to the machinery so a full separator folds
        # efficiency 0 -- but RED-deferred the updateTile advance
        # itself: the port tracked no progress / warmup /
        # totalProgress at all, so a separator never crafted
        # anything even at full power. N2222 is the updateTile
        # advance (SeparatorBuild.updateTile(),
        # Separator.java:130-167): totalProgress += warmup *
        # delta() (:131); while efficiency > 0, progress +=
        # getProgressIncrease(craftTime) (:134, BuildingComp
        # :1203-1205 `return 1f / baseTime * edelta();` with
        # edelta() = efficiency * delta(), BuildingComp
        # :1927-1929) and warmup lerpDelta toward 1f at 0.02f
        # (:135), else warmup lerpDelta toward 0f (:137); at
        # progress >= 1f (:140) progress wraps (:141), the
        # weighted random pick runs through Arc
        # Mathf.randomSeed(seed++, 0, sum - 1) (:145) over the
        # def results, consume() triggers the consumers (:158,
        # only ConsumeItems removes anything, ConsumeItems
        # :44-48, at the default multiplier 1f, Consume.java:18),
        # and the picked item offloads when the held count fits
        # itemCapacity (:160-161). The random pick is a faithful
        # Arc Rand port (xorshift128+, Rand.java) -- NOT the
        # port's SourceMathState.random_seed_int, which seeds a
        # single-state murmur chain with seed * 99999 (the
        # float-overload seeding) and masks on the power-of-two
        # path, so it draws different values than Arc's
        # two-state Rand. The created() seed init is live too:
        # tile.pos() is Point2.pack(x, y) (arc Point2.java:40-42),
        # computable from the sprite's origin cell, so the
        # driver seeds a fresh frame like created()
        # (Separator.java:83) instead of defaulting to 0. The
        # timerDump dump (:165-167) still waits -- the port has
        # no timer helper -- and the offload's neighbor routing
        # waits for a proximity acceptItem query, so the picked
        # result falls back to the separator's own items (the
        # Java no-neighbor-accepts outcome, BuildingComp
        # :1001-1016). Eight new result symbols: the advanced
        # frame values plus the craft outcome.
        self.assertEqual(
            ledger['N2222']['source_symbols'],
            [
                'source_separator_update_tile_advance_state_result.progress',
                'source_separator_update_tile_advance_state_result.warmup',
                'source_separator_update_tile_advance_state_result.total_progress',
                'source_separator_update_tile_advance_state_result.seed',
                'source_separator_update_tile_advance_state_result.items',
                'source_separator_update_tile_advance_state_result.cdump',
                'source_separator_update_tile_advance_state_result.picked_item',
                'source_separator_update_tile_advance_state_result.crafted',
            ],
        )
        for name in ledger['N2222']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Separator.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_update_tile_advance_state')
        self.assertEqual(ledger['N2222']['runtime_proof'], '/root/C07SeparatorUpdateTileProof')
        self.assertEqual(
            ledger['N2222']['tests'],
            [
                'test_c07_separator_update_tile_registration',
                'test_all_c07_separator_update_tile_input_evidence_is_exact',
                'test_separator_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_separator_update_tile',
            ],
        )
        self.assertTrue(ledger['N2222']['deferred_exprs'])
        # This slice resolves the N2169 Separator updateTile
        # advance deferral and the created() half of the
        # created/shouldAmbientSound deferral (the seed init is
        # live now; shouldAmbientSound stays deferred on its own
        # entry), and adds the timerDump dump + offload neighbor
        # routing deferrals.
        self.assertFalse(any(entry.startswith('Separator updateTile advance (') for entry in ledger['N2222']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('Separator created / shouldAmbientSound rows (') for entry in ledger['N2222']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator shouldAmbientSound row (') for entry in ledger['N2222']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump (') for entry in ledger['N2222']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator offload neighbor routing (') for entry in ledger['N2222']['deferred_exprs']))

    def test_all_c07_separator_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2222']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_update_tile_advance_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Separator.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/ConsumeItems.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/Consume.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/modules/ItemModule.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Rand.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Point2.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2222']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_update_tile_advance_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the separator build state:
        # totalProgress += warmup * delta() (Separator.java:131),
        # progress += getProgressIncrease(craftTime)
        # (Separator.java:134) while efficiency > 0, warmup
        # lerpDelta toward 1f / 0f at 0.02f (Separator.java:135 /
        # 137), the progress >= 1f craft branch (Separator.java:140)
        # with progress %= 1f (Separator.java:141), the weighted
        # random pick (Separator.java:145), consume()
        # (Separator.java:158), and the conditional offload
        # (Separator.java:160-161). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). getProgressIncrease is the
        # BuildingComp base (BuildingComp.java:1203-1205, `return
        # 1f / baseTime * edelta();`) -- Separator extends Block,
        # not GenericCrafter, so no override applies. delta() =
        # Time.delta * timeScale (BuildingComp.java:1922-1924),
        # edelta() = efficiency * delta()
        # (BuildingComp.java:1927-1929); Time.delta in the port
        # is seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the N2186/N2187/N2191
        # lesson: raw seconds run 60x slow). lerpDelta scales by
        # Time.delta, not delta() (Mathf.java:430-432), so the
        # warmup lerp uses the unscaled source delta.
        self.assertIn('static func source_separator_update_tile_advance_state', separator)
        self.assertIn('totalProgress += warmup * delta();', separator)
        self.assertIn('progress += getProgressIncrease(craftTime);', separator)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);', separator)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);', separator)
        self.assertIn('if(progress >= 1f){', separator)
        self.assertIn('progress %= 1f;', separator)
        self.assertIn('int i = Mathf.randomSeed(seed++, 0, sum - 1);', separator)
        self.assertIn('for(ItemStack stack : results){', separator)
        self.assertIn('if(i >= count && i < count + stack.amount){', separator)
        self.assertIn('item = stack.item;', separator)
        self.assertIn('consume();', separator)
        self.assertIn('if(item != null && items.get(item) < itemCapacity){', separator)
        self.assertIn('offload(item);', separator)
        self.assertIn('if(timer(timerDump, dumpTime / timeScale)){', separator)
        self.assertIn('seed = Mathf.randomSeed(tile.pos(), 0, Integer.MAX_VALUE - 1);', separator)
        self.assertIn('return 1f / baseTime * edelta();', separator)
        self.assertIn('return Time.delta * timeScale;', separator)
        self.assertIn('return efficiency * delta();', separator)
        self.assertIn('public float progress;', separator)
        self.assertIn('public float totalProgress;', separator)
        self.assertIn('public float warmup;', separator)
        self.assertIn('public int seed;', separator)
        # The random pick ports Arc Rand faithfully (Rand.java
        # xorshift128+ + Mathf.java:297-302): setSeed hashes the
        # seed twice through murmurHash3 (Rand.java:181-184),
        # nextLong is the xorshift128+ step (Rand.java:65-77),
        # nextLong(n) rejection-samples (Rand.java:115-122), and
        # the int randomSeed discards one nextInt() when max is
        # a power of two (Mathf.java:299-301). GDScript has no
        # >>> operator, so the port emulates it with an
        # arithmetic >> plus a mask to the surviving bits; int64
        # arithmetic wraps (the SourceMathState murmur
        # precedent). The created() seed packs the tile position
        # (Point2.pack, arc Point2.java:40-42).
        self.assertIn('static func _separator_random_seed_int', separator)
        self.assertIn('static func _separator_rand_next_long', separator)
        self.assertIn('static func _separator_rand_murmur_hash3', separator)
        self.assertIn('static func _separator_rand_set_seed', separator)
        self.assertIn('static func _separator_point2_pack', separator)
        self.assertIn('public static int randomSeed(long seed, int min, int max){', separator)
        self.assertIn('seedr.setSeed(seed);', separator)
        self.assertIn('if(isPowerOfTwo(max)){', separator)
        self.assertIn('return seedr.nextInt(max - min + 1) + min;', separator)
        self.assertIn('long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE : seed);', separator)
        self.assertIn('setState(seed0, murmurHash3(seed0));', separator)
        self.assertIn('s1 ^= s1 << 23;', separator)
        self.assertIn('return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;', separator)
        self.assertIn('final long bits = nextLong() >>> 1;', separator)
        self.assertIn('if(bits - value + (n - 1) >= 0) return value;', separator)
        self.assertIn('x *= 0xff51afd7ed558ccdL;', separator)
        self.assertIn('x *= 0xc4ceb9fe1a85ec53L;', separator)
        self.assertIn('x ^= x >>> 33;', separator)
        self.assertIn('return (((short)x) << 16) | (((short)y) & 0xFFFF);', separator)
        # consume() triggers every consumer (BuildingComp
        # :1911-1915); only ConsumeItems removes anything
        # (ConsumeItems.java:44-48, at the default multiplier 1f,
        # Consume.java:18), clamped at what the module holds
        # (ItemModule.java:258-262). The port removes through the
        # drill inventory helper (remove_item_state, clamped the
        # same way), reused through the inventory preload, and
        # offloads through offload_item_state (the Java
        # no-neighbor-accepts fallback adds to the building's own
        # items, BuildingComp.java:1001-1016).
        self.assertIn('for(Consume cons : block.consumers){', separator)
        self.assertIn('cons.trigger(self());', separator)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', separator)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', separator)
        self.assertIn('amount = Math.min(amount, items[item.id]);', separator)
        self.assertIn('public void offload(Item item){', separator)
        self.assertIn('int dump = this.cdump;', separator)
        self.assertIn('produced(item, 1);', separator)
        self.assertIn('handleItem(self(), item);', separator)
        self.assertIn('inventory.remove_item_state(items', separator)
        self.assertIn('inventory.offload_item_state(items', separator)
        self.assertIn('inventory.item_count(items, picked_item)', separator)
        # craftTime / results are per-def constants (the catalog
        # parses craftTime only for the GenericCrafter family, so
        # the driver reads these): separator craftTime 35f
        # (Blocks.java:1240) with copper 5 / lead 3 / graphite 2 /
        # titanium 2 (Blocks.java:1233-1239), disassembler
        # craftTime 15f (Blocks.java:1258) with sand 2 / graphite
        # 1 / titanium 1 / thorium 1 (Blocks.java:1251-1257).
        self.assertIn('SOURCE_SEPARATOR_CRAFT_TIME := 35.0', separator)
        self.assertIn('SOURCE_DISASSEMBLER_CRAFT_TIME := 15.0', separator)
        self.assertIn('craftTime = 35f;', separator)
        self.assertIn('craftTime = 15f;', separator)
        self.assertIn('results = with(', separator)
        self.assertIn('Items.copper, 5,', separator)
        self.assertIn('Items.sand, 2,', separator)
        self.assertIn('public int itemCapacity = 10;', separator)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption and only when enabled
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170). A fresh frame is
        # seeded from its tile position like created()
        # (Separator.java:83); the cons items come from the
        # catalog consumeItem rows with their amounts, the
        # capacity from the catalog itemCapacity.
        self.assertIn('game_source_delta(game, seconds)', separator)
        self.assertIn('time_scale(sprite', separator)
        self.assertIn('source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity)', separator)
        self.assertIn('frame["progress"]', separator)
        self.assertIn('frame["warmup"]', separator)
        self.assertIn('frame["total_progress"]', separator)
        self.assertIn('frame["seed"]', separator)
        self.assertIn('frame["items"]', separator)
        self.assertIn('frame["cdump"]', separator)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', separator)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', separator)
        self.assertIn('public boolean noUpdateDisabled = false;', separator)
        self.assertIn('block.properties.get("consumeItem", [])', separator)
        self.assertIn('block.properties.get("itemCapacity", 10)', separator)
        # The documented limits now record the advance as done
        # (progress / warmup / totalProgress / seed / consume /
        # offload pick) and the remaining deferrals (the
        # timerDump dump, the offload neighbor routing, the live
        # items intake); the N2200 gate and the N2169 power row
        # are preserved.
        self.assertIn('Partial updateTile advance (N2222)', separator)
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertIn('static func source_separator_power_status_row_state', separator)
        self.assertIn('static func source_separator_should_consume_state', separator)
        # The proof's keys drive the pure advance (progress /
        # warmup / totalProgress advance, the craft completion
        # with its consume + wrap, the weighted pick + offload)
        # plus the live tick (progress + warmup advance on a
        # placed separator, efficiency still folding
        # power.status, the frame seeded from its tile position
        # like created()).
        proof = SEPARATOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_advances_when_efficient',
            'warmup_approaches_one_when_efficient',
            'total_progress_advances_with_warmup',
            'craft_completes_at_progress_one',
            'offload_picks_weighted_result',
            'live_tick_advances_progress_and_warmup',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('separator_build_state.source_separator_update_tile_advance_state(', proof)
        self.assertIn('separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SEPARATOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorUpdateTileProof.gd', scene)
        self.assertIn('C07SeparatorUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_separator_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_advances_when_efficient',
            'warmup_approaches_one_when_efficient',
            'total_progress_advances_with_warmup',
            'craft_completes_at_progress_one',
            'offload_picks_weighted_result',
            'live_tick_advances_progress_and_warmup',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
