import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadUpdateTileProof.gd'


class C07LaunchPadUpdateTileTests(unittest.TestCase):
    def test_c07_launch_pad_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2207']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_update_tile_state')
        # LaunchPadBuild.updateTile advances the launch counter
        # then launches when full (LaunchPad.java:143, `public void
        # updateTile(){` with `if((launchCounter += edelta()) >=
        # launchTime && items.total() >= itemCapacity){`,
        # LaunchPad.java:146). The counter advances by edelta()
        # every tick (BuildingComp.java:1927-1929, `public float
        # edelta(){` with `return efficiency * delta();`, and
        # delta() is `Time.delta * timeScale`,
        # BuildingComp.java:1922-1923), so a pad with no power
        # never advances -- its efficiency is 0. The launch
        # itself fires only when the counter reaches launchTime
        # AND the pad holds a full itemCapacity of items; on
        # launch Java consumes, sounds, spawns the LaunchPayload
        # entity, clears the items and resets the counter
        # (LaunchPad.java:148-160). N2207 closes the advance
        # half of that gap with one pure function over the frame
        # (`launch_counter`, `efficiency`, `items_total`) plus
        # the per-def launchTime and itemCapacity parameters,
        # following the N2204 ShieldWall updateTile precedent
        # exactly: the pure function takes (frame, delta,
        # launch_time, item_capacity) and returns the new
        # `launch_counter` plus a `launched` flag, and the driver
        # stamps both on the frame every tick. The launch side
        # effects -- consume() (LaunchPad.java:148), the launch
        # sound (LaunchPad.java:149), the LaunchPayload entity
        # spawn (LaunchPad.java:150-155), Fx.launchPod
        # (LaunchPad.java:156), items.clear()
        # (LaunchPad.java:157) and Effect.shake
        # (LaunchPad.java:158) -- are a new subsystem with no
        # frame state to run on, so they wait for their own
        # slice; the `launched` flag is the observable signal
        # that slice will consume. RED decisions (pinned by
        # this slice): (1) the advance reads `efficiency` from
        # the frame, absent -> 0.0 -- the transient field
        # default (BuildingComp.java:85, `transient float
        # efficiency;`), the N2192/N2204 precedent -- so the
        # shouldConsume gate needs no separate parameter: a
        # false gate zeroes efficiency via updateConsumption
        # (BuildingComp.java:1960 + 1992-1993) and edelta()
        # goes to 0. (2) An absent `launch_counter` key starts
        # at 0.0 -- the Java init default (`public float
        # launchCounter;` defaults to 0.0f), the N2206 decision
        # -- and an absent `items_total` key reads 0.0, because
        # a fresh ItemModule totals 0 (`protected int total;`,
        # ItemModule.java:25, with `public int total(){` /
        # `return total;`, ItemModule.java:174-175), so a pad
        # with no tracked items never launches until an
        # inventory slice stamps `items_total`. (3) NO clamp at
        # launchTime: the counter keeps growing past launchTime
        # while the pad waits for items (the N2192 no-clamp
        # precedent -- Java only resets the counter on launch,
        # LaunchPad.java:160, `launchCounter = 0f;`), so a
        # full counter with too few items stays full. (4) The
        # per-def launchTime differs (launch-pad 1200f = 60f *
        # 20, Blocks.java:6794; advanced-launch-pad 1800f = 60f
        # * 30, Blocks.java:6804; class default 1f,
        # LaunchPad.java:32) and itemCapacity is 100 for both
        # defs (Blocks.java:6793, 6803; class default 10,
        # Block.java:75, `public int itemCapacity = 10;`), and
        # the catalog carries itemCapacity (content_registry
        # blocks launch-pad / advanced-launch-pad properties),
        # so the driver reads it from block.properties and
        # passes it in, like launchTime. Two new result symbols:
        # the advanced counter and the launch flag.
        self.assertEqual(
            ledger['N2207']['source_symbols'],
            [
                'source_launch_pad_update_tile_state_result.launch_counter',
                'source_launch_pad_update_tile_state_result.launched',
            ],
        )
        for name in ledger['N2207']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_update_tile_state_result.launch_counter': 'SourceLaunchPadBuildState.source_launch_pad_update_tile_state',
                    'source_launch_pad_update_tile_state_result.launched': 'SourceLaunchPadBuildState.source_launch_pad_update_tile_state',
                }[name])
        self.assertEqual(ledger['N2207']['runtime_proof'], '/root/C07LaunchPadUpdateTileProof')
        self.assertEqual(
            ledger['N2207']['tests'],
            [
                'test_c07_launch_pad_update_tile_registration',
                'test_all_c07_launch_pad_update_tile_input_evidence_is_exact',
                'test_launch_pad_update_tile_state',
                'test_reference_graph_and_actual_c07_launch_pad_update_tile',
            ],
        )
        self.assertTrue(ledger['N2207']['deferred_exprs'])

    def test_all_c07_launch_pad_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2207']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_update_tile_state_result.launch_counter': 'SourceLaunchPadBuildState.source_launch_pad_update_tile_state',
                    'source_launch_pad_update_tile_state_result.launched': 'SourceLaunchPadBuildState.source_launch_pad_update_tile_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2207']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_update_tile_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the launch-pad
        # build state next to the N2205 shouldConsume gate and
        # the N2206 sense override: LaunchPadBuild.updateTile
        # (LaunchPad.java:143, `public void updateTile(){`)
        # advances the counter by edelta() every tick
        # (LaunchPad.java:146, `if((launchCounter += edelta())
        # >= launchTime && items.total() >= itemCapacity){`)
        # and launches only when the counter reaches launchTime
        # AND the pad holds a full itemCapacity of items. edelta()
        # is efficiency * delta (BuildingComp.java:1927-1928,
        # `public float edelta(){` with `return efficiency *
        # delta();`, and `public float delta(){` with `return
        # Time.delta * timeScale;`, BuildingComp.java:1922-1923
        # -- timeScale is 1 by default and the port passes the
        # raw tick seconds, the N2190 driver convention). The
        # folded efficiency is the transient field
        # (BuildingComp.java:85, `transient float efficiency;`),
        # default 0.0 before the first machinery run; a disabled
        # pad never advances because updateConsumption zeroes
        # the efficiencies first (`if(!enabled){` with
        # `potentialEfficiency = efficiency = optionalEfficiency
        # = 0f;`, BuildingComp.java:1954-1955), so the driver
        # zeroes efficiency before the call (the N2204
        # precedent). The shouldConsume gate needs no separate
        # parameter: it zeroes efficiency the same way
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`), and the gate itself is
        # `return launchCounter < launchTime;`
        # (LaunchPad.java:92-94, `public boolean
        # shouldConsume(){`). The frame carries the launch
        # counter as `launch_counter` (float, absent defaults to
        # 0.0 -- the Java field init, LaunchPad.java:84,
        # `public float launchCounter;`), the folded efficiency
        # as `efficiency` (float, absent defaults to 0.0 -- the
        # transient field default, the N2192/N2204 precedent)
        # and the held items as `items_total` (float, absent
        # defaults to 0.0 -- a fresh ItemModule totals 0,
        # `protected int total;`, ItemModule.java:25, with
        # `public int total(){` / `return total;`,
        # ItemModule.java:174-175). There is NO clamp at
        # launchTime: the counter keeps growing past it while
        # the pad waits for items (the N2192 no-clamp
        # precedent); Java only resets the counter on launch
        # (`launchCounter = 0f;`, LaunchPad.java:160). The
        # launch side effects -- `consume();`
        # (LaunchPad.java:148), `launchSound.at(x, y, 1f +
        # Mathf.range(launchSoundPitchRand));`
        # (LaunchPad.java:149), `LaunchPayload entity =
        # LaunchPayload.create();` (LaunchPad.java:150),
        # `Fx.launchPod.at(this);` (LaunchPad.java:156),
        # `items.clear();` (LaunchPad.java:157) and
        # `Effect.shake(3f, 3f, this);` (LaunchPad.java:158) --
        # wait for their own slice: the LaunchPayload entity
        # spawn is a new subsystem and the port tracks no items
        # module for a launch pad yet. The per-def launchTime is
        # 1200f for launch-pad (Blocks.java:6794, `launchTime =
        # 60f * 20;`, with `size = 3;` and `itemCapacity = 100;`)
        # and 1800f for advanced-launch-pad (Blocks.java:6804,
        # `launchTime = 60f * 30;`, with `size = 4;` and
        # `itemCapacity = 100;`), overriding the class default
        # `public float launchTime = 1f;` (LaunchPad.java:32);
        # the class default itemCapacity is 10 (Block.java:75,
        # `public int itemCapacity = 10;`). Two defs share the
        # implementation (LaunchPad.java:30, `public class
        # LaunchPad extends Block{`; LaunchPadBuild,
        # LaunchPad.java:83, `public class LaunchPadBuild
        # extends Building{`).
        self.assertIn('static func source_launch_pad_update_tile_state(frame: Dictionary, delta: float, launch_time: float, item_capacity: float)', launch_pad)
        # The advance cases, pinned as the pure function's
        # decision structure: the counter advances by
        # efficiency * delta every tick; the launch fires only
        # when the advanced counter reaches launchTime AND the
        # held items reach itemCapacity, resetting the counter
        # to 0.0; otherwise the counter keeps its advanced
        # value, unclamped, past launchTime if needed.
        self.assertIn('float(frame.get("launch_counter", 0.0))', launch_pad)
        self.assertIn('float(frame.get("efficiency", 0.0))', launch_pad)
        self.assertIn('float(frame.get("items_total", 0.0))', launch_pad)
        with self.subTest(case='counter advances by efficiency * delta'):
            self.assertIn('launch_counter += efficiency * delta', launch_pad)
        with self.subTest(case='launch fires at launchTime with full items and resets the counter'):
            self.assertIn('if launch_counter >= launch_time and items_total >= item_capacity:', launch_pad)
            self.assertIn('launch_counter = 0.0', launch_pad)
        with self.subTest(case='launch flag is true only on the launch tick'):
            self.assertIn('return {"launch_counter": launch_counter, "launched": launched}', launch_pad)
        with self.subTest(case='counter below launchTime advances without launching'):
            self.assertIn('launch_counter += efficiency * delta', launch_pad)
        with self.subTest(case='full counter without enough items stays full, unclamped'):
            self.assertIn('if launch_counter >= launch_time and items_total >= item_capacity:', launch_pad)
        with self.subTest(case='no efficiency means no advance'):
            self.assertIn('float(frame.get("efficiency", 0.0))', launch_pad)
        self.assertIn('public void updateTile(){', launch_pad)
        self.assertIn('if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', launch_pad)
        self.assertIn('launchCounter = 0f;', launch_pad)
        self.assertIn('public float launchCounter;', launch_pad)
        self.assertIn('public float launchTime = 1f;', launch_pad)
        self.assertIn('public float edelta(){', launch_pad)
        self.assertIn('return efficiency * delta();', launch_pad)
        self.assertIn('public float delta(){', launch_pad)
        self.assertIn('return Time.delta * timeScale;', launch_pad)
        self.assertIn('transient float efficiency;', launch_pad)
        self.assertIn('potentialEfficiency = efficiency = optionalEfficiency = 0f;', launch_pad)
        self.assertIn('public int itemCapacity = 10;', launch_pad)
        self.assertIn('itemCapacity = 100;', launch_pad)
        self.assertIn('launchTime = 60f * 20;', launch_pad)
        self.assertIn('launchTime = 60f * 30;', launch_pad)
        self.assertIn('protected int total;', launch_pad)
        self.assertIn('public int total(){', launch_pad)
        self.assertIn('return total;', launch_pad)
        self.assertIn('public boolean shouldConsume(){', launch_pad)
        self.assertIn('return launchCounter < launchTime;', launch_pad)
        self.assertIn('public class LaunchPad extends Block{', launch_pad)
        self.assertIn('public class LaunchPadBuild extends Building{', launch_pad)
        self.assertIn('consume();', launch_pad)
        self.assertIn('items.clear();', launch_pad)
        self.assertIn('LaunchPayload entity = LaunchPayload.create();', launch_pad)
        self.assertIn('Fx.launchPod.at(this);', launch_pad)
        self.assertIn('Effect.shake(3f, 3f, this);', launch_pad)
        self.assertIn('launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));', launch_pad)
        self.assertIn('size = 3;', launch_pad)
        self.assertIn('size = 4;', launch_pad)
        self.assertIn('source_launch_pad_update_tile_state(frame, seconds, launch_time, item_capacity)', launch_pad)
        self.assertIn('static func source_launch_pad_tick_buildings_state', launch_pad)
        # The proof's keys drive the pure updateTile advance
        # (advance by edelta / no advance without efficiency /
        # launch when full / no launch without items / absent
        # counter starts at zero / per-def advanced-pad launch).
        # There are no launch-effect keys: consume / sound /
        # LaunchPayload spawn / Fx / items.clear / shake wait
        # for their own slice, and the sense(progress) override
        # (N2206) and shouldConsume gate (N2205) are separate
        # rows with their own proofs.
        proof = LAUNCH_PAD_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_tile_advances_counter_by_edelta',
            'update_tile_no_advance_without_efficiency',
            'update_tile_launches_when_full',
            'update_tile_no_launch_without_items',
            'update_tile_absent_counter_starts_zero',
            'update_tile_advanced_pad_launches',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

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
            'update_tile_advances_counter_by_edelta',
            'update_tile_no_advance_without_efficiency',
            'update_tile_launches_when_full',
            'update_tile_no_launch_without_items',
            'update_tile_absent_counter_starts_zero',
            'update_tile_advanced_pad_launches',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
