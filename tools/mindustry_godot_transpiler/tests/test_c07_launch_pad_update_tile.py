import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadUpdateTileProof.gd'
LAUNCH_PAD_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadUpdateTileProof.tscn'


class C07LaunchPadUpdateTileTests(unittest.TestCase):
    def test_c07_launch_pad_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2238']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_update_tile_advance_state')
        # N2172 proved the launch pad family's live power read --
        # but the port tracked no launchCounter / items at all, so
        # a launch pad never advanced its counter, never fired a
        # launch, and its items sat forever. N2238 is the
        # updateTile advance (LaunchPadBuild.updateTile(),
        # LaunchPad.java:143-161): the launchCounter += edelta()
        # advance (LaunchPad.java:146), the full-and-timed launch
        # gate (LaunchPad.java:146, items.total() >=
        # itemCapacity), the consume() call (LaunchPad.java:148,
        # a no-op for items on this def -- ConsumePower has no
        # trigger override and the Consume default trigger is
        # empty, Consume.java:50), the LaunchPayload stacks copy
        # (LaunchPad.java:151, items.each -- zero amounts skipped,
        # ItemModule.java:100-106), the items.clear()
        # (LaunchPad.java:157) and the launchCounter = 0f reset
        # (LaunchPad.java:159). The entity creation/application
        # (LaunchPad.java:150-155), the launch sound and the
        # launch effects (LaunchPad.java:149/156/158) defer: the
        # launch is reported as the pure result launched_stacks
        # (the N2234 spawned_unit precedent) plus launched. Four
        # new result symbols.
        self.assertEqual(
            ledger['N2238']['source_symbols'],
            [
                'source_launch_pad_update_tile_advance_state_result.launched',
                'source_launch_pad_update_tile_advance_state_result.launched_stacks',
                'source_launch_pad_update_tile_advance_state_result.launch_counter',
                'source_launch_pad_update_tile_advance_state_result.items',
            ],
        )
        for name in ledger['N2238']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/LaunchPad.java')
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_update_tile_advance_state')
        self.assertEqual(ledger['N2238']['runtime_proof'], '/root/C07LaunchPadUpdateTileProof')
        self.assertEqual(
            ledger['N2238']['tests'],
            [
                'test_c07_launch_pad_update_tile_registration',
                'test_all_c07_launch_pad_update_tile_input_evidence_is_exact',
                'test_launch_pad_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_launch_pad_update_tile',
            ],
        )
        self.assertTrue(ledger['N2238']['deferred_exprs'])
        # This slice resolves the N2172 updateTile advance
        # deferral, so the advance entry is gone from DEFERRED --
        # and the LaunchPayload entity creation/application, the
        # launch sound / effects and the disabled / cheating /
        # no-power advance entries take its place. The liquid
        # consumer row stays: the advanced def's oil consumer is
        # still not modeled. The advanced variant entry stays:
        # the same driver covers both defs, but the advanced def
        # waits for its own verification slice. The shouldConsume
        # gate entry stays too: N2186 lives on its own unmerged
        # branch in this line, so the gate still waits here.
        self.assertFalse(any(entry.startswith('LaunchPad updateTile advance (') for entry in ledger['N2238']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad updateTile LaunchPayload entity creation/application (') for entry in ledger['N2238']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad updateTile launch sound / effects (') for entry in ledger['N2238']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad updateTile disabled / cheating / no-power advance (') for entry in ledger['N2238']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad liquid consumer row (') for entry in ledger['N2238']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad advanced variant (') for entry in ledger['N2238']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad shouldConsume gate (') for entry in ledger['N2238']['deferred_exprs']))

    def test_all_c07_launch_pad_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2238']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2238']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_update_tile_advance_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the launch-pad build state:
        # the launchCounter += edelta() advance and the
        # full-and-timed launch gate (LaunchPad.java:146), the
        # consume() call (LaunchPad.java:148), the LaunchPayload
        # stacks copy (LaunchPad.java:151), the items.clear()
        # (LaunchPad.java:157) and the launchCounter = 0f reset
        # (LaunchPad.java:159). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the N2186/N2187/
        # N2191 lesson: raw seconds run 60x slow). edelta() =
        # efficiency * delta() with delta() = Time.delta *
        # timeScale (BuildingComp.java:1922-1929). The items
        # dict is keyed by item name (the factory precedent,
        # SourceFactoryBuildState.gd:89-101) and its total is
        # the drill inventory total (SourceDrillInventoryRuntimeState.
        # items_total, reused through the inventory preload, not
        # recomputed -- the Separator precedent). The stacks copy
        # skips zero amounts, like ItemModule.each
        # (ItemModule.java:100-106, `if(items[i] != 0){`).
        self.assertIn('static func source_launch_pad_update_tile_advance_state', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('consume();', launch_pad)
        self.assertIn('launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));', launch_pad)
        self.assertIn('LaunchPayload entity = LaunchPayload.create();', launch_pad)
        self.assertIn('items.each((item, amount) -> entity.stacks.add(new ItemStack(item, amount)));', launch_pad)
        self.assertIn('entity.set(this);', launch_pad)
        self.assertIn('entity.lifetime(120f);', launch_pad)
        self.assertIn('entity.team(team);', launch_pad)
        self.assertIn('entity.add();', launch_pad)
        self.assertIn('Fx.launchPod.at(this);', launch_pad)
        self.assertIn('items.clear();', launch_pad)
        self.assertIn('Effect.shake(3f, 3f, this);', launch_pad)
        self.assertIn('launchCounter = 0f;', launch_pad)
        self.assertIn('public float launchCounter;', launch_pad)
        self.assertIn('public float launchTime = 1f;', launch_pad)
        self.assertIn('public class LaunchPadBuild extends Building{', launch_pad)
        self.assertIn('public class LaunchPad extends Block{', launch_pad)
        self.assertIn('return launchCounter < launchTime;', launch_pad)
        self.assertIn('return efficiency * delta();', launch_pad)
        self.assertIn('return Time.delta * timeScale;', launch_pad)
        self.assertIn('launchTime = 60f * 20;', launch_pad)
        self.assertIn('launchTime = 60f * 30;', launch_pad)
        self.assertIn('consumePower(4f);', launch_pad)
        self.assertIn('consumePower(8f);', launch_pad)
        self.assertIn('itemCapacity = 100;', launch_pad)
        self.assertIn('public int itemCapacity = 10;', launch_pad)
        self.assertIn('acceptMultipleItems = true;', launch_pad)
        self.assertIn('consumeLiquid(Liquids.oil, 9f/60f);', launch_pad)
        self.assertIn('public void trigger(Building build){}', launch_pad)
        self.assertIn('for(Consume cons : block.consumers){', launch_pad)
        self.assertIn('cons.trigger(self());', launch_pad)
        self.assertIn('public void each(ItemConsumer cons){', launch_pad)
        self.assertIn('if(items[i] != 0){', launch_pad)
        self.assertIn('public int total(){', launch_pad)
        self.assertIn('public void clear(){', launch_pad)
        self.assertIn('Seq<ItemStack> stacks = new Seq<>();', launch_pad)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', launch_pad)
        self.assertIn('updateConsumption();', launch_pad)
        self.assertIn('updateTile();', launch_pad)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', launch_pad)
        self.assertIn('transient float efficiency;', launch_pad)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default the game
        # default 1.0, BuildingComp.java:98 `private transient
        # float timeScale = 1f, timeScaleDuration;`); the advance
        # runs after consumption, like Java's Building.update()
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing. launchTime is a per-def block field the
        # catalog does not carry, so the driver stamps it from
        # the block id every tick (the N2186 stamp, mirrored
        # here because N2186 is not in this base); itemCapacity
        # IS in the catalog, so the driver passes it as the
        # explicit item_capacity param (the Separator
        # precedent), defaulting to the Block class default 10
        # (Block.java:75) when the catalog is silent.
        self.assertIn('source_launch_pad_update_tile_advance_state(frame, source_delta, time_scale, item_capacity)', launch_pad)
        self.assertIn('game_source_delta(game, seconds)', launch_pad)
        self.assertIn('time_scale(sprite', launch_pad)
        self.assertIn('block.properties.get("itemCapacity", 10)', launch_pad)
        self.assertIn('frame["launch_counter"]', launch_pad)
        self.assertIn('frame["items"]', launch_pad)
        self.assertIn('frame["launched"]', launch_pad)
        self.assertIn('frame["launched_stacks"]', launch_pad)
        self.assertIn('block_id == "launch-pad"', launch_pad)
        self.assertIn('block_id == "advanced-launch-pad"', launch_pad)
        self.assertIn('launch_time = 60.0 * 20.0', launch_pad)
        self.assertIn('launch_time = 60.0 * 30.0', launch_pad)
        self.assertIn('frame["launch_time"] = launch_time', launch_pad)
        # The frame inputs read through .get defaults matching
        # the Java field defaults: launchCounter 0f
        # (LaunchPad.java:84), launchTime 1f (LaunchPad.java:32,
        # the class default when the driver has not stamped the
        # def value), efficiency 0f (BuildingComp.java:85
        # `transient float efficiency;`), items {} (the empty
        # ItemModule of a fresh build).
        self.assertIn('frame.get("launch_counter", 0.0)', launch_pad)
        self.assertIn('frame.get("items", {})', launch_pad)
        self.assertIn('frame.get("launch_time", 1.0)', launch_pad)
        self.assertIn('frame.get("efficiency", 0.0)', launch_pad)
        self.assertIn('inventory.items_total(items)', launch_pad)
        # The fresh frame binds the new state keys with the Java
        # field defaults.
        self.assertIn('"launch_counter": 0.0', launch_pad)
        self.assertIn('"items": {}', launch_pad)
        # The documented limits now record the advance as done
        # and the remaining deferrals (LaunchPayload entity
        # creation/application, launch sound / effects, the oil
        # second consumer, the disabled / cheating / no-power
        # advance); the N2172 power row is preserved.
        self.assertIn('updateTile advance live (N2238)', launch_pad)
        self.assertNotIn('No updateTile advance', launch_pad)
        self.assertIn('static func source_launch_pad_power_status_row_state', launch_pad)
        self.assertIn('static func source_launch_pad_tick_buildings_state', launch_pad)
        # The proof's keys drive the pure advance (the counter
        # advancing by edelta, the launch firing when full and
        # timed, the clear + reset on launch -- including the
        # zero-amount skip in the stacks copy -- no launch when
        # not full, no launch before launchTime) plus the live
        # tick (fresh-frame defaults + a placed launch-pad
        # advancing its counter on 1/60s ticks at half power,
        # then launching live when full and timed, efficiency
        # still folding power.status).
        proof = LAUNCH_PAD_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'launch_counter_advances_with_edelta',
            'launch_fires_when_full_and_timed',
            'launch_clears_items_and_resets',
            'no_launch_when_not_full',
            'no_launch_before_launch_time',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = LAUNCH_PAD_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LaunchPadUpdateTileProof.gd', scene)
        self.assertIn('[node name="C07LaunchPadUpdateTileProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_launch_pad_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'launch_counter_advances_with_edelta',
            'launch_fires_when_full_and_timed',
            'launch_clears_items_and_resets',
            'no_launch_when_not_full',
            'no_launch_before_launch_time',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
