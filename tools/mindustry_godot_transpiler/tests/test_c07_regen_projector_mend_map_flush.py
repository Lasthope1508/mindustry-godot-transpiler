import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_MEND_MAP_FLUSH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorMendMapFlushProof.gd'
REGEN_PROJECTOR_MEND_MAP_FLUSH_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorMendMapFlushProof.tscn'


class C07RegenProjectorMendMapFlushTests(unittest.TestCase):
    def test_c07_regen_projector_mend_map_flush_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2325']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_tile_advance_state')
        # N2228 ported the updateTile advance (RegenProjectorBuild.
        # updateTile(), RegenProjector.java:122-179) -- warmup /
        # totalTime / optionalTimer / didRegen / anyTargets /
        # mendMap accumulation -- but the mendMap FLUSH deferred
        # whole (application + cadence): mendMap is static-shared
        # across projectors (RegenProjector.java:23) and the flush
        # heals live buildings via world.build(pos)
        # (RegenProjector.java:168-177), which the port has no
        # frames for. N2325 is the flush as a pure result: when
        # the frame last_update_frame (default -1, `private
        # static long lastUpdateFrame = -1;`,
        # RegenProjector.java:24) differs from the frame update_id
        # (default 0, `public long updateId;`, GameState.java:23,
        # incremented once per logic update, `state.updateId ++;`,
        # Logic.java:512), the advance reports the whole mend_map
        # as heal_applications {pos: amount}, clears mend_map,
        # and stamps last_update_frame = update_id. The flush
        # sits AFTER the heal branch and OUTSIDE the efficiency
        # gate, so it fires on a zero-efficiency tick too -- but
        # never on a suppressed tick (the early return keeps the
        # map). The LIVE application of the amounts to the target
        # buildings (world.build(pos) + build.heal +
        # recentlyHealed(), the timestamp write `lastHealTime =
        # Time.time;`, BuildingComp.java:491-493) still waits for
        # its own slice, and with no live updateId source the
        # frame update_id stays 0, so the flush fires once (on
        # the first tick) and then waits for a game-state slice
        # that stamps the live counter. The port tracks a
        # per-building mend_map instead of the Java static-shared
        # map (documented deviation -- in Java the first
        # projector ticked in a frame flushes every projector's
        # amounts). Two new result symbols: last_update_frame
        # and heal_applications; the N2228 result schema and
        # contract are extended in place (same names, 11 keys),
        # so this slice adds +2/+1/+0/+0.
        self.assertEqual(
            ledger['N2325']['source_symbols'],
            [
                'source_regen_projector_update_tile_advance_state_result.last_update_frame',
                'source_regen_projector_update_tile_advance_state_result.heal_applications',
            ],
        )
        for name in ledger['N2325']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/RegenProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_tile_advance_state')
        self.assertEqual(ledger['N2325']['runtime_proof'], '/root/C07RegenProjectorMendMapFlushProof')
        self.assertEqual(
            ledger['N2325']['tests'],
            [
                'test_c07_regen_projector_mend_map_flush_registration',
                'test_all_c07_regen_projector_mend_map_flush_input_evidence_is_exact',
                'test_regen_projector_mend_map_flush_state',
                'test_reference_graph_and_actual_c07_regen_projector_mend_map_flush',
            ],
        )
        self.assertTrue(ledger['N2325']['deferred_exprs'])
        # The flush is live now, so the updateTile live-fill
        # entry is REWRITTEN in place (it cannot be deleted:
        # the effect chance, the suppression live fill and the
        # disabled early return still wait) and two new
        # deferrals join: the live heal application to the
        # target buildings and the live updateId counter.
        live_fill = [entry for entry in ledger['N2325']['deferred_exprs'] if entry.startswith('RegenProjector updateTile live fill (')]
        self.assertEqual(len(live_fill), 1)
        self.assertIn('mendMap flush is live since N2325', live_fill[0])
        self.assertFalse(any('the mendMap flush (mendMap is static-shared across projectors' in entry for entry in ledger['N2325']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector mendMap flush live heal application (') for entry in ledger['N2325']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector live updateId counter (') for entry in ledger['N2325']['deferred_exprs']))

    def test_all_c07_regen_projector_mend_map_flush_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2325']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/RegenProjector.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/core/GameState.java',
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2325']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_mend_map_flush_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The flush (RegenProjectorBuild.updateTile(),
        # RegenProjector.java:168-177) runs after the heal branch
        # and outside the efficiency gate: `if(lastUpdateFrame !=
        # state.updateId){` / `lastUpdateFrame = state.updateId;`
        # / `for(var entry : mendMap.entries()){` / `var build =
        # world.build(entry.key);` / `if(build != null){` /
        # `build.heal(entry.value);` / `build.recentlyHealed();`
        # / `mendMap.clear();`. The port reports the flushed map
        # as the pure heal_applications result {pos: amount} and
        # clears mend_map; the live application to the target
        # buildings (world.build(pos) + build.heal +
        # recentlyHealed(), the timestamp write `lastHealTime =
        # Time.time;`, BuildingComp.java:491-493) waits for its
        # own slice. lastUpdateFrame is the Java static
        # `private static long lastUpdateFrame = -1;`
        # (RegenProjector.java:24) and updateId is `public long
        # updateId;` (GameState.java:23), incremented once per
        # logic update (`state.updateId ++;`, Logic.java:512);
        # both arrive as frame inputs with the Java-faithful
        # defaults -1 / 0, so a fresh frame flushes once (on the
        # first tick) and then waits for a live updateId source.
        # A suppressed tick returns before the flush (the early
        # return keeps the map and reports no applications).
        # mendMap is static-shared in Java (`private static final
        # IntFloatMap mendMap = new IntFloatMap();`,
        # RegenProjector.java:23); the port tracks a per-building
        # mend_map instead (documented deviation). Keep each Java
        # expr on ONE comment line (the N2148 lesson).
        self.assertIn('static func source_regen_projector_update_tile_advance_state', regen_projector)
        self.assertIn('if(lastUpdateFrame != state.updateId){', regen_projector)
        self.assertIn('lastUpdateFrame = state.updateId;', regen_projector)
        self.assertIn('for(var entry : mendMap.entries()){', regen_projector)
        self.assertIn('var build = world.build(entry.key);', regen_projector)
        self.assertIn('if(build != null){', regen_projector)
        self.assertIn('build.heal(entry.value);', regen_projector)
        self.assertIn('build.recentlyHealed();', regen_projector)
        self.assertIn('mendMap.clear();', regen_projector)
        self.assertIn('private static long lastUpdateFrame = -1;', regen_projector)
        self.assertIn('private static final IntFloatMap mendMap = new IntFloatMap();', regen_projector)
        self.assertIn('public long updateId;', regen_projector)
        self.assertIn('state.updateId ++;', regen_projector)
        self.assertIn('lastHealTime = Time.time;', regen_projector)
        self.assertIn('public void recentlyHealed(){', regen_projector)
        # The flush frame inputs with their Java-faithful
        # defaults, the flush branch itself (report the whole
        # map as heal_applications, then clear), and the two new
        # result keys on both return paths (the suppressed early
        # return reports the unchanged last_update_frame and an
        # empty heal_applications).
        self.assertIn('frame.get("last_update_frame", -1)', regen_projector)
        self.assertIn('frame.get("update_id", 0)', regen_projector)
        self.assertIn('if last_update_frame != update_id:', regen_projector)
        self.assertIn('heal_applications = Dictionary(mend_map)', regen_projector)
        self.assertIn('mend_map = {}', regen_projector)
        self.assertIn('"last_update_frame"', regen_projector)
        self.assertIn('"heal_applications"', regen_projector)
        # The driver wires the flush result into the live tick:
        # last_update_frame and heal_applications are written
        # back on the frame after the advance call (the tick
        # applies nothing to the target buildings yet).
        self.assertIn('source_regen_projector_update_tile_advance_state(frame, source_delta, time_scale)', regen_projector)
        self.assertIn('frame["last_update_frame"]', regen_projector)
        self.assertIn('frame["heal_applications"]', regen_projector)
        # The documented limits now record the flush as live
        # (N2325); the N2228 advance, N2277 updateTargets and
        # N2214 shouldConsume text stays.
        self.assertIn('mendMap flush is live (N2325)', regen_projector)
        self.assertNotIn('mendMap flush DEFERS whole', regen_projector)
        self.assertIn('updateTile advance live (N2228)', regen_projector)
        self.assertIn('updateTargets live (N2277)', regen_projector)
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        # The proof's keys drive the pure flush (flush on a new
        # frame -- seeded + freshly accumulated amounts -- no
        # flush when the frame is unchanged, flush without
        # efficiency, no flush when suppressed) plus the live
        # tick (tick 1 flushes the first-tick mend, tick 2
        # accumulates again with no flush).
        proof = REGEN_PROJECTOR_MEND_MAP_FLUSH_PROOF.read_text(encoding='utf-8')
        for key in [
            'mend_map_flushes_on_new_frame',
            'no_flush_when_frame_unchanged',
            'flush_fires_without_efficiency',
            'suppression_blocks_flush',
            'live_tick_flushes_mend_map',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRegenProjectorBuildState.gd")', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_update_tile_advance_state(', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REGEN_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REGEN_PROJECTOR_MEND_MAP_FLUSH_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorMendMapFlushProof.gd', scene)
        self.assertIn('C07RegenProjectorMendMapFlushProof', scene)

    def test_reference_graph_and_actual_c07_regen_projector_mend_map_flush(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorMendMapFlushProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_MEND_MAP_FLUSH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'mend_map_flushes_on_new_frame',
            'no_flush_when_frame_unchanged',
            'flush_fires_without_efficiency',
            'suppression_blocks_flush',
            'live_tick_flushes_mend_map',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
