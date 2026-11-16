import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OVERDRIVE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd'
OVERDRIVE_PROJECTOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorDrawRowsProof.gd'
OVERDRIVE_PROJECTOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorDrawRowsProof.tscn'


class C07OverdriveProjectorDrawRowsTests(unittest.TestCase):
    def test_c07_overdrive_projector_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2435']['godot_owner'], 'SourceOverdriveProjectorBuildState.source_overdrive_projector_draw_rows_state')
        # The OverdriveProjector tick is live (N2157 power.status
        # row + N2194 updateTile advance + N2262 item rows +
        # N2334 boost scan) but NOTHING modeled the draw rows:
        # draw() (OverdriveProjector.java:137-158, the super
        # call + the Lod.l2 gate + the top region + the 4-point
        # ring), drawLight() (:92-94, the smoothEfficiency-scaled
        # light), drawSelect() (:128-133, the realRange dash
        # circle + the selected targets) and drawPlace() (:54-61,
        # the range dash circle + the selected targets at the
        # tile position). N2435 ports all four as ONE pure-only
        # draw pure, the N2421 precedent: draw is never called
        # by the tick, so the pure takes caller-supplied inputs
        # (frame x / y / tile / range / phaseHeat / lightRadius /
        # smoothEfficiency / heat, Time.time as time_value, the
        # Lod gate + alpha, size, the base/phase color tokens,
        # the caller-supplied selected blocks and the place
        # valid flag) and returns the draw calls as data. The
        # pure is named draw_rows_state (not draw_state): the
        # older display path already owns the
        # source_overdrive_projector_draw_state schemas
        # (PortGame.source_overdrive_projector_draw_state, N726)
        # and reusing the name would overwrite those schemas --
        # the N2372 MendProjector precedent. Six new result
        # symbols: the base (super) call, the top call, the ring
        # call (line points + stroke), the light call, the
        # select call (dash + selected) and the place call (dash
        # + selected). No icon_regions key: OverdriveProjector
        # has NO icons() override (verified first -- no "icon"
        # line in OverdriveProjector.java at all), so the base
        # Block.icons() default applies and there is nothing to
        # port (the N2429 ItemBridge precedent).
        self.assertEqual(
            ledger['N2435']['source_symbols'],
            [
                'source_overdrive_projector_draw_rows_state_result.base_call',
                'source_overdrive_projector_draw_rows_state_result.top_call',
                'source_overdrive_projector_draw_rows_state_result.ring_call',
                'source_overdrive_projector_draw_rows_state_result.light_call',
                'source_overdrive_projector_draw_rows_state_result.select_call',
                'source_overdrive_projector_draw_rows_state_result.place_call',
            ],
        )
        for name in ledger['N2435']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/OverdriveProjector.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceOverdriveProjectorBuildState.source_overdrive_projector_'))
        self.assertEqual(ledger['N2435']['runtime_proof'], '/root/C07OverdriveProjectorDrawRowsProof')
        self.assertEqual(
            ledger['N2435']['tests'],
            [
                'test_c07_overdrive_projector_draw_rows_registration',
                'test_all_c07_overdrive_projector_draw_rows_input_evidence_is_exact',
                'test_overdrive_projector_draw_rows_state',
                'test_reference_graph_and_actual_c07_overdrive_projector_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2435']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #141 (1-based in
        # the merged advances-26 DEFERRED base): the
        # OverdriveProjector draw / drawLight / drawSelect /
        # drawPlace rows entry is REMOVED -- the top region +
        # ring, the smoothEfficiency-scaled light, the
        # drawSelect range circle + target highlight and the
        # drawPlace range circle are all live now, so nothing
        # of the entry remains. Net 273 - 1 = 272, no new
        # entries (the renderer/UI call sites are renderer
        # slices, not OverdriveProjector deferrals -- the
        # N2431 precedent -- and the eachBlock live index is
        # already covered by the boost-scan live-index entry).
        self.assertFalse(any(entry.startswith('OverdriveProjector draw / drawLight / drawSelect / drawPlace rows (draw top region + ring, OverdriveProjector.java:137-158') for entry in ledger['N2435']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector boost application (') for entry in ledger['N2435']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector frame items intake (') for entry in ledger['N2435']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('OverdriveProjector disabled-early-return rows (') for entry in ledger['N2435']['deferred_exprs']))
        self.assertEqual(len(ledger['N2435']['deferred_exprs']), 272)

    def test_all_c07_overdrive_projector_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2435']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceOverdriveProjectorBuildState.source_overdrive_projector_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/OverdriveProjector.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/Lod.java',
            'core/src/mindustry/content/Blocks.java',
            'arc-core/src/arc/math/Mathf.java',
            'arc-core/src/arc/math/geom/Geometry.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2435']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_overdrive_projector_draw_rows_state(self):
        overdrive_projector = OVERDRIVE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The draw rows (OverdriveBuild.draw(),
        # OverdriveProjector.java:137-158; drawLight(),
        # :92-94; drawSelect(), :128-133; drawPlace(),
        # :54-61). draw() is `super.draw();` + the Lod.l2
        # gate + `float f = 1f - (Time.time / 100f) % 1f;`
        # + the baseColor -> phaseColor lerp by phaseHeat +
        # the top rect at alpha heat * absin(Time.time, 50f
        # / PI2, 1f) * 0.5f * Lod.alpha2 + the 4-point ring
        # (Lines.beginLine / the d4 loop with the extra
        # point when f < 0.5f / Lines.endLine(true)) at
        # stroke (2f * f + 0.1f) * heat + `Draw.reset();`.
        # The f factor is computed AFTER the Lod guard
        # (line order :140 before :142 -- the REVERSE of
        # MendProjector, where f comes first), so the pure
        # reports f 0.0 when hidden (the N726 display-state
        # precedent). The absin calls are Java-exact through
        # the shared helper at the DOUBLED scale: Java absin
        # is `return (sin(in, scl * 2f, mag) + mag) / 2f;`
        # (Mathf.java:78-80, arc), while the helper is
        # (sin(value / scl) * 0.5 + 0.5) * mag
        # (SourceMathState.source_absin), i.e. helper(v, s)
        # == Java absin(v, s / 2f) -- so the pure passes
        # 100f / PI2 for the draw absin and 8f for the
        # select/place absin(4f, 1f), the 2-arg form that
        # reads Time.time (`return absin(Time.time, scl,
        # mag);`, Mathf.java:74-75, arc). The ring geometry
        # uses Geometry.d4 (Geometry.java:9-14, (1,0) /
        # (0,1) / (-1,0) / (0,-1)) with r = max(0, clamp(2f
        # - f * 2f) * size * tilesize / 2f - f - 0.2f) and
        # w = clamp(0.5f - f) * size * tilesize, where
        # clamp is the 1-arg [0,1] clamp (Mathf.java:402,
        # arc). The drawPlace tile position uses the Block
        # offset (`offset = ((size + 1) % 2) * tilesize /
        # 2f;`, Block.java:761) -- 4 for the size-2
        # projector, 0 for the size-3 dome. The def
        # constants are verified first: range 80f / dome
        # 200f, phaseRangeBoost 20f (no def override),
        # lightRadius 50f (no def override), baseColor
        # feb380 / phaseColor ffd59e (no def override),
        # Lod.alpha2 defaults 1f (Lod.java:17). Pure-only:
        # the tick never calls draw / drawLight / drawSelect
        # / drawPlace. Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_overdrive_projector_draw_rows_state', overdrive_projector)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', overdrive_projector)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', overdrive_projector)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);', overdrive_projector)
        self.assertIn('indexer.eachBlock(player.team(), x * tilesize + offset, y * tilesize + offset, range, other -> other.block.canOverdrive, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));', overdrive_projector)
        self.assertIn('public void drawLight(){', overdrive_projector)
        self.assertIn('Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);', overdrive_projector)
        self.assertIn('public void drawSelect(){', overdrive_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', overdrive_projector)
        self.assertIn('indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));', overdrive_projector)
        self.assertIn('Drawf.dashCircle(x, y, realRange, baseColor);', overdrive_projector)
        self.assertIn('public void draw(){', overdrive_projector)
        self.assertIn('super.draw();', overdrive_projector)
        self.assertIn('if(!Lod.l2) return;', overdrive_projector)
        self.assertIn('float f = 1f - (Time.time / 100f) % 1f;', overdrive_projector)
        self.assertIn('Draw.color(baseColor, phaseColor, phaseHeat);', overdrive_projector)
        self.assertIn('Draw.alpha(heat * Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) * 0.5f * Lod.alpha2);', overdrive_projector)
        self.assertIn('Draw.rect(topRegion, x, y);', overdrive_projector)
        self.assertIn('Draw.alpha(Lod.alpha2);', overdrive_projector)
        self.assertIn('Lines.stroke((2f * f + 0.1f) * heat);', overdrive_projector)
        self.assertIn('float r = Math.max(0f, Mathf.clamp(2f - f * 2f) * size * tilesize / 2f - f - 0.2f), w = Mathf.clamp(0.5f - f) * size * tilesize;', overdrive_projector)
        self.assertIn('Lines.beginLine();', overdrive_projector)
        self.assertIn('for(int i = 0; i < 4; i++){', overdrive_projector)
        self.assertIn('Lines.linePoint(x + Geometry.d4(i).x * r + Geometry.d4(i).y * w, y + Geometry.d4(i).y * r - Geometry.d4(i).x * w);', overdrive_projector)
        self.assertIn('if(f < 0.5f) Lines.linePoint(x + Geometry.d4(i).x * r - Geometry.d4(i).y * w, y + Geometry.d4(i).y * r + Geometry.d4(i).x * w);', overdrive_projector)
        self.assertIn('Lines.endLine(true);', overdrive_projector)
        self.assertIn('Draw.reset();', overdrive_projector)
        self.assertIn('public @Load("@-top") TextureRegion topRegion;', overdrive_projector)
        self.assertIn('public float range = 80f;', overdrive_projector)
        self.assertIn('public float phaseRangeBoost = 20f;', overdrive_projector)
        self.assertIn('public Color baseColor = Color.valueOf("feb380");', overdrive_projector)
        self.assertIn('public Color phaseColor = Color.valueOf("ffd59e");', overdrive_projector)
        self.assertIn('lightRadius = 50f;', overdrive_projector)
        self.assertIn('emitLight = true;', overdrive_projector)
        self.assertIn('overdriveProjector = new OverdriveProjector("overdrive-projector"){{', overdrive_projector)
        self.assertIn('overdriveDome = new OverdriveProjector("overdrive-dome"){{', overdrive_projector)
        self.assertIn('range = 200f;', overdrive_projector)
        self.assertIn('hasBoost = false;', overdrive_projector)
        self.assertIn('public static void light(float x, float y, float radius, Color color, float opacity){', overdrive_projector)
        self.assertIn('public static void selected(Building tile, Color color){', overdrive_projector)
        self.assertIn('public static void dashCircle(float x, float y, float rad, Color color){', overdrive_projector)
        self.assertIn('Lines.stroke(3f, Pal.gray);', overdrive_projector)
        self.assertIn('Lines.stroke(1f, color);', overdrive_projector)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', overdrive_projector)
        self.assertIn('public static boolean l2 = true;', overdrive_projector)
        self.assertIn('public static float alpha2 = 1f;', overdrive_projector)
        self.assertIn('public static float absin(float scl, float mag){', overdrive_projector)
        self.assertIn('return absin(Time.time, scl, mag);', overdrive_projector)
        self.assertIn('public static float absin(float in, float scl, float mag){', overdrive_projector)
        self.assertIn('return (sin(in, scl * 2f, mag) + mag) / 2f;', overdrive_projector)
        self.assertIn('public static float clamp(float value){', overdrive_projector)
        self.assertIn('public static Point2 d4(int i){', overdrive_projector)
        self.assertIn('public final static Point2[] d4 = {', overdrive_projector)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2435)', overdrive_projector)
        # The proof's keys drive the draw pure (the f math
        # + the top call, the ring points at f 0.5 / 0.25,
        # the Lod.l2 gate, the light scaling, the select
        # realRange + selected targets, the place dash +
        # selected targets at the tile position).
        proof = OVERDRIVE_PROJECTOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_f_top',
            'draw_ring_points',
            'draw_lod_gate',
            'draw_light',
            'draw_select',
            'draw_place',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceOverdriveProjectorBuildState.gd")', proof)
        self.assertTrue(OVERDRIVE_PROJECTOR_STATE.exists())
        self.assertTrue(OVERDRIVE_PROJECTOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07OverdriveProjectorDrawRowsProof.gd', OVERDRIVE_PROJECTOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_overdrive_projector_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07OverdriveProjectorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_OVERDRIVE_PROJECTOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_f_top',
            'draw_ring_points',
            'draw_lod_gate',
            'draw_light',
            'draw_select',
            'draw_place',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
