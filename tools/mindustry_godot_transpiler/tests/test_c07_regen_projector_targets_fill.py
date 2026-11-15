import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_TARGETS_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorTargetsFillProof.gd'
REGEN_PROJECTOR_TARGETS_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorTargetsFillProof.tscn'


class C07RegenProjectorTargetsFillTests(unittest.TestCase):
    def test_c07_regen_projector_targets_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2277']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_targets_state')
        # N2228 ported the updateTile advance (warmup / totalTime
        # / optionalTimer / didRegen / anyTargets / mendMap) but
        # took targets as the frame input: the live updateTargets
        # query (RegenProjector.java:115-119, an indexer.eachBlock
        # over the team's buildings in the square range*tilesize
        # rect) had no fill, so a live regen-projector read
        # any_targets false and never consumed. N2277 is the live
        # fill: when the frame tile_changes differs from
        # last_change (RegenProjector.java:122-125), the pure scan
        # rebuilds targets from the candidate buildings (same
        # team, center inside the square rect, range 28,
        # Blocks.java:2012), each entry in the exact format the
        # N2228 advance reads (pos, block_health, health,
        # damaged, heal_suppressed); otherwise targets stay
        # untouched and refreshed is false. Three new result
        # symbols.
        self.assertEqual(
            ledger['N2277']['source_symbols'],
            [
                'source_regen_projector_update_targets_state_result.targets',
                'source_regen_projector_update_targets_state_result.last_change',
                'source_regen_projector_update_targets_state_result.refreshed',
            ],
        )
        for name in ledger['N2277']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/RegenProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_targets_state')
        self.assertEqual(ledger['N2277']['runtime_proof'], '/root/C07RegenProjectorTargetsFillProof')
        self.assertEqual(
            ledger['N2277']['tests'],
            [
                'test_c07_regen_projector_targets_fill_registration',
                'test_all_c07_regen_projector_targets_fill_input_evidence_is_exact',
                'test_regen_projector_update_targets_state',
                'test_reference_graph_and_actual_c07_regen_projector_targets_fill',
            ],
        )
        self.assertTrue(ledger['N2277']['deferred_exprs'])
        # This slice resolves the N2214 targets-computation
        # live-fill entry whole: the contains-damaged fold landed
        # in N2228 and the indexer query lands here, so the entry
        # is gone. The bundled updateTile live-fill entry stays
        # (mendMap flush, effect chance, suppression fill and the
        # disabled early return still wait for their own slices;
        # its updateTargets clause is stale now and the
        # coordinator narrows it at merge, the N2260 consume()
        # precedent). Two new deferrals take its place: the live
        # world.tileChanges counter (the port has no live counter,
        # so the driver reads the frame input tile_changes as-is)
        # and the indexer hitbox-overlap + privileged nuance (the
        # port tests building centers against the rect).
        self.assertFalse(any(entry.startswith('RegenProjector targets computation live fill (') for entry in ledger['N2277']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector updateTile live fill (') for entry in ledger['N2277']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector live tileChanges counter (') for entry in ledger['N2277']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector updateTargets hitbox overlap + privileged filter (') for entry in ledger['N2277']['deferred_exprs']))

    def test_all_c07_regen_projector_targets_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2277']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_targets_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/RegenProjector.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/core/World.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/ai/BlockIndexer.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2277']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_update_targets_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure scan lives on the regen-projector build
        # state: updateTargets() (RegenProjector.java:115-119),
        # the tileChanges trigger (RegenProjector.java:122-125),
        # the contains-damaged fold it feeds
        # (RegenProjector.java:139), the damaged() predicate
        # (HealthComp.java:47-49), the tileChanges initial value
        # (World.java:35), the range def (Blocks.java:2012) over
        # the class default (RegenProjector.java:26), the pos
        # pack (Tile.java:73-75), the drawx/drawy centers
        # (Tile.java:176/180) with the block offset
        # (Block.java:761) and tilesize (Vars.java:135), and the
        # indexer query itself (BlockIndexer.java:364-380: the
        # quadtree intersect at :371, the privileged filter at
        # :372). Keep each Java expr on ONE comment line (the
        # N2148 shootWarmup lesson: a split line fails this
        # test). Cite corrections (all verified by grep at this
        # pin): range = 28 is Blocks.java:2012 (not :2011 as the
        # brief and the scope doc say -- the N2228 test already
        # corrected this); updateTargets is :115-119 and the
        # trigger is :122-125, exactly as the brief says; the
        # indexer lives in BlockIndexer.java (not Indexer.java,
        # which does not exist at this pin); taken is declared at
        # :21 and only ever cleared at :117, never read, so not
        # porting it loses no behavior. setCentered(x, y, size)
        # is a SQUARE (arc Rect.java:49-51, set(x - size/2,
        # y - size/2, size, size)) -- the scan tests the building
        # center against the square, never dst2.
        self.assertIn('static func source_regen_projector_update_targets_state', regen_projector)
        self.assertIn('public void updateTargets(){', regen_projector)
        self.assertIn('targets.clear();', regen_projector)
        self.assertIn('taken.clear();', regen_projector)
        self.assertIn('indexer.eachBlock(team, Tmp.r1.setCentered(x, y, range * tilesize), b -> true, targets::add);', regen_projector)
        self.assertIn('if(lastChange != world.tileChanges){', regen_projector)
        self.assertIn('lastChange = world.tileChanges;', regen_projector)
        self.assertIn('updateTargets();', regen_projector)
        self.assertIn('public Seq<Building> targets = new Seq<>();', regen_projector)
        self.assertIn('public int lastChange = -2;', regen_projector)
        self.assertIn('public int range = 14;', regen_projector)
        self.assertIn('range = 28;', regen_projector)
        self.assertIn('return health < maxHealth - 0.001f;', regen_projector)
        self.assertIn('public int tileChanges = 1, floorChanges = 1;', regen_projector)
        self.assertIn('return Point2.pack(x, y);', regen_projector)
        self.assertIn('return block().offset + worldx();', regen_projector)
        self.assertIn('return block().offset + worldy();', regen_projector)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', regen_projector)
        self.assertIn('public static final int tilesize = 8;', regen_projector)
        self.assertIn('public boolean eachBlock(Team team, Rect rect, Boolf<Building> pred, Cons<Building> cons){', regen_projector)
        self.assertIn('buildings.intersect(rect, b -> {', regen_projector)
        self.assertIn('if(pred.get(b) && !b.block.privileged){', regen_projector)
        self.assertIn('public class RegenProjector extends Block{', regen_projector)
        self.assertIn('public class RegenProjectorBuild extends Building{', regen_projector)
        self.assertIn('public void updateTile(){', regen_projector)
        self.assertIn('anyTargets = targets.contains(b -> b.damaged());', regen_projector)
        # The def range is a driver constant (single def --
        # regen-projector): 28 (Blocks.java:2012, the def
        # override of the class 14, RegenProjector.java:26).
        self.assertIn('SOURCE_REGEN_PROJECTOR_RANGE := 28', regen_projector)
        # The frame inputs keep their Java-faithful defaults:
        # lastChange -2 (RegenProjector.java:110) against
        # tileChanges 1 (World.java:35), so the first tick
        # refreshes; no supplied targets means an empty list;
        # team_id comes from the tick stamp.
        self.assertIn('frame.get("tile_changes", 1)', regen_projector)
        self.assertIn('frame.get("last_change", -2)', regen_projector)
        self.assertIn('frame.get("targets", [])', regen_projector)
        self.assertIn('frame.get("team_id"', regen_projector)
        # The driver wires the scan into the live tick BEFORE
        # the advance (the Java order: the tileChanges check
        # opens updateTile, RegenProjector.java:122-125, and the
        # advance then folds anyTargets over the fresh targets).
        # Candidates come from the placed buildings
        # (source_unique_buildings_state, the N2197 link-lookup
        # precedent): each candidate's world center is the
        # drawx/drawy of its origin cell (the RepairTurret
        # precedent), its pos is the packed cell
        # (tile_pos_state), its health/max health come from the
        # sprite metas, and its team from the build-team meta.
        tick = regen_projector[regen_projector.find('static func source_regen_projector_tick_buildings_state'):]
        scan_call = tick.find('source_regen_projector_update_targets_state(')
        advance_call = tick.find('source_regen_projector_update_tile_advance_state(frame, source_delta, time_scale)')
        self.assertNotEqual(scan_call, -1)
        self.assertNotEqual(advance_call, -1)
        self.assertLess(scan_call, advance_call)
        self.assertIn('source_unique_buildings_state(game)', regen_projector)
        self.assertIn('tile_drawx_state(', regen_projector)
        self.assertIn('tile_drawy_state(', regen_projector)
        self.assertIn('tile_pos_state(', regen_projector)
        self.assertIn('SOURCE_BLOCK_MAX_HEALTH_META_KEY', regen_projector)
        self.assertIn('source_placed_block_state.health(', regen_projector)
        self.assertIn('frame["targets"]', regen_projector)
        self.assertIn('frame["last_change"]', regen_projector)
        # The documented limits now record the live fill as done
        # (N2277) and the remaining deferrals (the live
        # tileChanges counter, the mendMap flush, the effect
        # chance, the suppression fill, the disabled early
        # return); the shouldConsume gate stays live (N2214) and
        # the updateTile advance stays live (N2228).
        self.assertIn('updateTargets live (N2277)', regen_projector)
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        self.assertIn('updateTile advance live (N2228)', regen_projector)
        self.assertIn('static func source_regen_projector_power_status_row_state', regen_projector)
        self.assertIn('static func source_regen_projector_should_consume_state', regen_projector)
        self.assertIn('static func source_regen_projector_update_tile_advance_state', regen_projector)
        # The proof's keys drive the pure scan (refresh on a
        # tile change, no refresh without one, same-team +
        # in-rect only, the damaged flag with its 0.001f
        # epsilon, the square-not-circle rect) plus the live
        # tick (a placed damaged neighbor lands in the frame
        # targets on the first tick and stays put on the second).
        proof = REGEN_PROJECTOR_TARGETS_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'targets_refresh_on_tile_change',
            'targets_unchanged_without_tile_change',
            'targets_only_same_team_in_rect',
            'targets_include_damaged_flag',
            'rect_is_square_not_circle',
            'live_tick_refreshes_targets',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRegenProjectorBuildState.gd")', proof)
        self.assertTrue(REGEN_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REGEN_PROJECTOR_TARGETS_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorTargetsFillProof.gd', scene)
        self.assertIn('C07RegenProjectorTargetsFillProof', scene)

    def test_reference_graph_and_actual_c07_regen_projector_targets_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorTargetsFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_TARGETS_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'targets_refresh_on_tile_change',
            'targets_unchanged_without_tile_change',
            'targets_only_same_team_in_rect',
            'targets_include_damaged_flag',
            'rect_is_square_not_circle',
            'live_tick_refreshes_targets',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
