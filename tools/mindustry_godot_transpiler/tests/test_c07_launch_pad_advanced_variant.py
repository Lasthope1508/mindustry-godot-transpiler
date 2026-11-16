import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
LAUNCH_PAD_ADVANCED_VARIANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadAdvancedVariantProof.gd'
LAUNCH_PAD_ADVANCED_VARIANT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadAdvancedVariantProof.tscn'


class C07LaunchPadAdvancedVariantTests(unittest.TestCase):
    def test_all_c07_launch_pad_advanced_variant_input_evidence_is_exact(self):
        # No N2400 ledger entry (see the state test), so
        # the exact evidence is verified straight from
        # upstream instead of through ledger exact_exprs:
        # both defs' lines in Blocks.java plus the class
        # defaults in LaunchPad.java and Block.java,
        # verbatim AND on the right lines (the N2307
        # lesson: a right string on a wrong line is a
        # stale cite).
        blocks = (ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java').read_text(encoding='utf-8')
        blocks_lines = blocks.splitlines()
        launch_pad = (ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/campaign/LaunchPad.java').read_text(encoding='utf-8')
        launch_pad_lines = launch_pad.splitlines()
        block = (ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java').read_text(encoding='utf-8')
        block_lines = block.splitlines()
        for expr in [
            'launchPad = new LaunchPad("launch-pad"){{',
            'advancedLaunchPad = new LaunchPad("advanced-launch-pad"){{',
            'size = 3;',
            'size = 4;',
            'itemCapacity = 100;',
            'launchTime = 60f * 20;',
            'launchTime = 60f * 30;',
            'liquidCapacity = 40f;',
            'acceptMultipleItems = true;',
            'drawLiquid = Liquids.oil;',
            'consumeLiquid(Liquids.oil, 9f/60f);',
            'consumePower(4f);',
            'consumePower(8f);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, blocks)
        for expr in [
            'public float launchTime = 1f;',
            'public boolean acceptMultipleItems = false;',
            'public float launchCounter;',
            'return launchCounter < launchTime;',
            'if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);',
            'if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, launch_pad)
        for expr in [
            'public int itemCapacity = 10;',
            'public float liquidCapacity = -1f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, block)
        # Plain def (Blocks.java:6790-6797).
        self.assertIn('launch-pad', blocks_lines[6789])
        self.assertEqual(blocks_lines[6791].strip(), 'size = 3;')
        self.assertEqual(blocks_lines[6792].strip(), 'itemCapacity = 100;')
        self.assertEqual(blocks_lines[6793].strip(), 'launchTime = 60f * 20;')
        self.assertEqual(blocks_lines[6794].strip(), 'hasPower = true;')
        self.assertEqual(blocks_lines[6795].strip(), 'acceptMultipleItems = true;')
        self.assertEqual(blocks_lines[6796].strip(), 'consumePower(4f);')
        # Advanced def (Blocks.java:6800-6809).
        self.assertIn('advanced-launch-pad', blocks_lines[6799])
        self.assertEqual(blocks_lines[6801].strip(), 'size = 4;')
        self.assertEqual(blocks_lines[6802].strip(), 'itemCapacity = 100;')
        self.assertEqual(blocks_lines[6803].strip(), 'launchTime = 60f * 30;')
        self.assertEqual(blocks_lines[6804].strip(), 'liquidCapacity = 40f;')
        self.assertEqual(blocks_lines[6805].strip(), 'hasPower = true;')
        self.assertEqual(blocks_lines[6806].strip(), 'drawLiquid = Liquids.oil;')
        self.assertEqual(blocks_lines[6807].strip(), 'consumeLiquid(Liquids.oil, 9f/60f);')
        self.assertEqual(blocks_lines[6808].strip(), 'consumePower(8f);')
        # Class defaults (LaunchPad.java:32/40/84/92-94/
        # 98-101/146; Block.java:75/77): the DEFs win on
        # every field they set. launchTime 1f and
        # acceptMultipleItems false are the class
        # defaults the advanced def keeps for the
        # latter (it sets no acceptMultipleItems) and
        # overrides for the former (1800f). Block's
        # liquidCapacity is -1f, derived in Block.init
        # (Block.java:1407-1419) only when negative --
        # the advanced def's explicit 40f survives
        # init, the plain def derives 10f (no liquid
        # consumers, consumeAmount 1f, round(10 * 1)).
        self.assertEqual(launch_pad_lines[31].strip(), 'public float launchTime = 1f;')
        self.assertEqual(launch_pad_lines[39].strip(), 'public boolean acceptMultipleItems = false;')
        self.assertEqual(launch_pad_lines[83].strip(), 'public float launchCounter;')
        self.assertEqual(launch_pad_lines[91].strip(), 'public boolean shouldConsume(){')
        self.assertEqual(launch_pad_lines[93].strip(), 'return launchCounter < launchTime;')
        self.assertEqual(launch_pad_lines[98].strip(), 'if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);')
        self.assertEqual(launch_pad_lines[145].strip(), 'if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){')
        self.assertEqual(block_lines[74].strip(), 'public int itemCapacity = 10;')
        self.assertEqual(block_lines[76].strip(), 'public float liquidCapacity = -1f;')

    def test_launch_pad_advanced_variant_state(self):
        # N2400 is a VERIFICATION slice, not a port slice:
        # no new pure, no new symbol, no new ledger entry
        # (the +0 precedent -- N2357, N2307, N2337, N2300,
        # N2302, N2309 have no ledger entry either). The
        # advanced def is covered by five existing
        # entries: the N2186 shouldConsume gate, the
        # N2238 updateTile advance, the N2253 liquid row,
        # the N2333 acceptItem gate, and the N2389 sense
        # rows. This test pins those owners, and pins
        # that this slice adds no entry of its own.
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertNotIn('N2400', ledger)
        self.assertEqual(ledger['N2186']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state')
        self.assertEqual(ledger['N2238']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_update_tile_advance_state')
        self.assertEqual(ledger['N2253']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_liquid_consumer_row_state')
        self.assertEqual(ledger['N2333']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_accept_item_state')
        self.assertEqual(ledger['N2389']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_sense_state')
        self.assertEqual(
            ledger['N2186']['source_symbols'],
            [
                'source_launch_pad_should_consume_state_result.should_consume',
                'source_launch_pad_should_consume_state_result.launch_counter',
            ],
        )
        self.assertEqual(
            ledger['N2389']['source_symbols'],
            [
                'source_launch_pad_sense_state_result.value',
                'source_launch_pad_sense_state_result.is_progress',
            ],
        )
        for name in ledger['N2186']['source_symbols'] + ledger['N2389']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/LaunchPad.java')
        # The catalog carries the per-def rows the driver
        # reads live: size / consumePower / powerUsage /
        # itemCapacity for BOTH defs, plus the oil
        # consumeLiquid row for the advanced def only
        # (amount 0.15 = 9f/60f). launchTime is in NO
        # catalog row -- the driver stamps it per def by
        # block id (pinned below). liquidCapacity is
        # likewise absent from BOTH rows: that is the
        # REPORTED discrepancy (see the driver pins
        # below), NOT an expected absence -- 31 other
        # blocks DO carry liquidCapacity in this same
        # catalog, and Java sets 40f explicitly for the
        # advanced def (Blocks.java:6805).
        blocks = json.loads((generated / 'source_modules/content_registry_blocks.json').read_text(encoding='utf-8'))['blocks']
        plain = blocks['launch-pad']
        advanced = blocks['advanced-launch-pad']
        self.assertEqual(plain['implementation'], 'LaunchPad')
        self.assertEqual(advanced['implementation'], 'LaunchPad')
        self.assertEqual(plain['properties']['size'], 3)
        self.assertEqual(advanced['properties']['size'], 4)
        self.assertEqual(plain['properties']['consumePower'], 4.0)
        self.assertEqual(advanced['properties']['consumePower'], 8.0)
        self.assertEqual(plain['properties']['powerUsage'], 4.0)
        self.assertEqual(advanced['properties']['powerUsage'], 8.0)
        self.assertEqual(plain['properties']['itemCapacity'], 100)
        self.assertEqual(advanced['properties']['itemCapacity'], 100)
        self.assertEqual(advanced['properties']['consumeLiquid'], [{'amount': 0.15, 'liquid': 'oil'}])
        self.assertNotIn('consumeLiquid', plain['properties'])
        self.assertNotIn('launchTime', plain['properties'])
        self.assertNotIn('launchTime', advanced['properties'])
        self.assertNotIn('liquidCapacity', plain['properties'])
        self.assertNotIn('liquidCapacity', advanced['properties'])
        self.assertTrue(any('liquidCapacity' in entry['properties'] for entry in blocks.values()))
        # The driver documents BOTH defs in its header
        # (Blocks.java:6790-6809) and stamps launchTime
        # per def by block id every tick: 60 * 20 for
        # launch-pad, 60 * 30 for advanced-launch-pad,
        # the class default 1f for any other LaunchPad
        # id. The power row keys off has("consumePower")
        # (the 8f MAGNITUDE flows through the power
        # graph, N2142, not the LaunchPad driver -- the
        # driver folds power.status, never the wattage);
        # the liquid row reads the catalog consumeLiquid
        # rows; itemCapacity reads the catalog with the
        # Block default 10.
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        self.assertIn('advanced-launch-pad (consumePower 8f, Blocks.java:6809', launch_pad)
        self.assertIn('launch-pad (consumePower 4f, Blocks.java:6797', launch_pad)
        self.assertIn('if block_id == "launch-pad":', launch_pad)
        self.assertIn('launch_time = 60.0 * 20.0', launch_pad)
        self.assertIn('elif block_id == "advanced-launch-pad":', launch_pad)
        self.assertIn('launch_time = 60.0 * 30.0', launch_pad)
        self.assertIn('var has_power_consumer: bool = bool(block.properties.has("consumePower"))', launch_pad)
        self.assertIn('var consume_liquid_rows: Array = block.properties.get("consumeLiquid", [])', launch_pad)
        self.assertIn('var item_capacity: int = int(block.properties.get("itemCapacity", 10))', launch_pad)
        # DISCREPANCY (reported, not fixed -- verification
        # only): the driver NEVER reads liquidCapacity
        # from the catalog or the frame (no catalog get,
        # no frame get) and never reads size either --
        # size flows through the catalog into placement /
        # geometry, liquidCapacity flows nowhere at all
        # as a SUPPLIED value. N2420 narrowed the gap:
        # the draw pure takes liquid_capacity as an
        # explicit caller-supplied input (like the sense
        # capacity pure), so the driver now MENTIONS it
        # -- exactly twice (the param + the alpha ratio)
        # -- but nothing in the port still supplies the
        # Java 40f; the oil row only ever reads what is
        # held, never a cap.
        self.assertNotIn('get("liquidCapacity"', launch_pad)
        self.assertNotIn('frame["liquid_capacity"]', launch_pad)
        self.assertIn('liquid_capacity: float', launch_pad)
        self.assertEqual(launch_pad.count('liquid_capacity'), 2)
        self.assertNotIn('properties.get("size"', launch_pad)
        # The geometry helpers turn the catalog size into
        # world extents: block_world_size(size, tile_size)
        # is max(1, size) * tile_size (128.0 vs 96.0 at
        # the game tile_size 32), and the hitbox size is
        # block_size * tilesize (32.0 vs 24.0 at the Java
        # tilesize 8.0 -- the N2364 lesson).
        geometry = BLOCK_GEOMETRY.read_text(encoding='utf-8')
        self.assertIn('static func block_world_size(block_size: int, tile_size: int) -> float:', geometry)
        self.assertIn('return float(max(source_block_defaults.SIZE_DEFAULT, block_size)) * float(tile_size)', geometry)
        self.assertIn('static func tile_get_hitbox_state(x: int, y: int, block_size: int, tilesize: float, block_offset: float, rect_value: Variant = null) -> Dictionary:', geometry)
        self.assertIn('var size_in_world: float = float(block_size) * tilesize', geometry)
        # The pures the advanced def runs through are
        # intact: the N2186 gate, the N2238 advance, the
        # N2253 liquid row, the N2333 accept gate, the
        # N2389 sense dispatch, the power row, the tick,
        # and the frame bind.
        self.assertIn('static func source_launch_pad_should_consume_state(frame: Dictionary) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, item_capacity: int) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_accept_item_state(frame: Dictionary, item: String, item_capacity: int, accept_multiple_items: bool, item_order: Array) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_sense_state(sensor: String, launch_counter: float, launch_time: float, super_value: Variant = null) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', launch_pad)
        self.assertIn('static func source_launch_pad_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:', launch_pad)
        # The proof's keys drive the advanced def end to
        # end: the catalog rows (power 8f / size 4 / oil
        # row / the liquidCapacity gap), the 1800f sense
        # + gate, the 1800f advance discriminator, the
        # oil row at the 40f full store, the size-4
        # hitbox, and the live tick stamps. Static
        # checks: the proof preloads the family state
        # file, the geometry / placement / liquid /
        # registry helpers, and the main scene, all of
        # which exist; the scene file references the
        # proof script that exists.
        proof = LAUNCH_PAD_ADVANCED_VARIANT_PROOF.read_text(encoding='utf-8')
        for key in [
            'advanced_def_catalog_rows',
            'advanced_def_launch_time_1800_sense',
            'advanced_def_launch_time_1800_advance',
            'advanced_def_oil_row_live',
            'advanced_def_size_4_hitbox',
            'advanced_def_live_tick_stamps',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertIn('preload("res://src/game/SourcePlacedBlockState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceLiquidModuleState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceContentRegistryRuntimeState.gd")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.is_file())
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = LAUNCH_PAD_ADVANCED_VARIANT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LaunchPadAdvancedVariantProof.gd', scene)
        self.assertIn('C07LaunchPadAdvancedVariantProof', scene)

    def test_reference_graph_and_actual_c07_launch_pad_advanced_variant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadAdvancedVariantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_ADVANCED_VARIANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advanced_def_catalog_rows',
            'advanced_def_launch_time_1800_sense',
            'advanced_def_launch_time_1800_advance',
            'advanced_def_oil_row_live',
            'advanced_def_size_4_hitbox',
            'advanced_def_live_tick_stamps',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
