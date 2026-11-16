import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDrawRowsProof.gd'
BEAM_DRILL_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDrawRowsProof.tscn'


class C07BeamDrillDrawRowsTests(unittest.TestCase):
    def test_c07_beam_drill_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2436']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_draw_state')
        # The BeamDrill tick is live (N2202 shouldConsume
        # gate + N2195 updateTile advance + N2289
        # timerDump dump + N2339 facing scan + N2346
        # laser origins + N2352 facing-tile fill +
        # N2405 dump neighbour live fill + N2363 dump
        # neighbour write-back) but NOTHING modeled
        # draw() / drawSelect(): the base + top rects
        # (BeamDrill.java:276-277), the per-laser
        # width / mixcol absins (:293/:296), the
        # centered laserCenter branch (:297-310) vs
        # the Drawf.laser branch (:311-323), the Lod.l2
        # sparks (:327-345), the glow additive (:348-
        # 355) and the drawItemSelection select call
        # (:231-234), plus icons() (:108-115). N2436
        # ports draw() + drawSelect() as ONE pure-only
        # draw pure, the N2430/N2431 precedent: draw
        # is never called by the tick, so the pure
        # takes caller-supplied inputs (frame x / y /
        # rotation / size / id / warmup / boostWarmup,
        # Time.time, the Lod flags, the payload flag,
        # the facing tiles + laser origins, lastItem,
        # the glow found flag, the heat colors, the
        # heat pulse params, the spark rolls and the
        # def laserWidth) and returns the draw calls
        # as data. NO RNG in the pure: the spark
        # draws ride caller-supplied rolls (the N2421
        # precedent). Eight new result symbols: the
        # base / top calls, the laser calls, the glow
        # call (null when the glow region is not
        # found), the select call (null when lastItem
        # is null), the icon regions, the draw
        # rotation and the payload-return flag.
        self.assertEqual(
            ledger['N2436']['source_symbols'],
            [
                'source_beam_drill_draw_state_result.base_call',
                'source_beam_drill_draw_state_result.top_call',
                'source_beam_drill_draw_state_result.laser_calls',
                'source_beam_drill_draw_state_result.glow_call',
                'source_beam_drill_draw_state_result.select_call',
                'source_beam_drill_draw_state_result.icon_regions',
                'source_beam_drill_draw_state_result.draw_rotation',
                'source_beam_drill_draw_state_result.payload_return',
            ],
        )
        for name in ledger['N2436']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceBeamDrillBuildState.source_beam_drill_'))
        self.assertEqual(ledger['N2436']['runtime_proof'], '/root/C07BeamDrillDrawRowsProof')
        self.assertEqual(
            ledger['N2436']['tests'],
            [
                'test_c07_beam_drill_draw_rows_registration',
                'test_all_c07_beam_drill_draw_rows_input_evidence_is_exact',
                'test_beam_drill_draw_rows_state',
                'test_reference_graph_and_actual_c07_beam_drill_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2436']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #143 (1-based in
        # the merged advances-26 DEFERRED base): the
        # BeamDrill draw / drawSelect rows entry is
        # REMOVED -- the base + top rects, the laser
        # centered / laser branches with the boost
        # gates, the sparks, the glow and the select
        # call are all live now, so nothing of the
        # entry remains. Net 273 - 1 = 272.
        self.assertFalse(any(entry.startswith('BeamDrill draw / drawSelect rows (') for entry in ledger['N2436']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drillMultipliers / blockedItem rows (') for entry in ledger['N2436']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2436']['deferred_exprs']))
        self.assertEqual(len(ledger['N2436']['deferred_exprs']), 272)

    def test_all_c07_beam_drill_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2436']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBeamDrillBuildState.source_beam_drill_'))
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/graphics/Drawf.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Tile.java'),
            ('mindustry-upstream', 'core/src/mindustry/Vars.java'),
            ('mindustry-upstream', 'core/src/mindustry/graphics/Lod.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Geometry.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Angles.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Rand.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2436']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_draw_rows_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The draw rows (BeamDrillBuild.drawSelect(),
        # BeamDrill.java:231-234 + BeamDrillBuild.draw(),
        # BeamDrill.java:275-357): `drawItemSelection(
        # lastItem);` + the base rect + the top rect at
        # rotdeg() + the payload early return + the
        # per-laser width / mixcol absins + the
        # centered laserCenter branch vs the Drawf.
        # laser branch + the Lod.l2 sparks + the glow
        # additive, plus icons() (:108-115, {region,
        # topRegion}). The width absin reads (id % 9)
        # * 9 while the mixcol absin reads id * 9 --
        # NOT the same offset. The boost gates are
        # asymmetric: the center boost gate is > 0.01
        # while the laser boost gate is > 0.001. The
        # absin calls land Java-exact through the
        # shared helper at the DOUBLED scale (the
        # N2372/N2382 precedent). Mathf.slope is the
        # triangle 1 - |fin - 0.5| * 2 (arc Mathf.
        # java:594-596). NO RNG in the pure: the three
        # spark draws per spark ride caller-supplied
        # rolls in Java order (random, range(2),
        # range(spread)). laserWidth is a caller-
        # supplied input because large-plasma-bore
        # overrides it to 0.7f (Blocks.java:3061) over
        # the 0.65f class default -- every other draw
        # field takes the class default, no def
        # overrides it. Pure-only: the tick never
        # calls draw/drawSelect (draw is called by
        # the renderer). Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_beam_drill_draw_state', beam_drill)
        self.assertIn('public void drawSelect(){', beam_drill)
        self.assertIn('drawItemSelection(lastItem);', beam_drill)
        self.assertIn('public void draw(){', beam_drill)
        self.assertIn('Draw.rect(block.region, x, y);', beam_drill)
        self.assertIn('Draw.rect(topRegion, x, y, rotdeg());', beam_drill)
        self.assertIn('if(isPayload()) return;', beam_drill)
        self.assertIn('var dir = Geometry.d4(rotation);', beam_drill)
        self.assertIn('int ddx = Geometry.d4x(rotation + 1), ddy = Geometry.d4y(rotation + 1);', beam_drill)
        self.assertIn('Tile face = facing[i];', beam_drill)
        self.assertIn('if(face != null){', beam_drill)
        self.assertIn('Item drop = face.wallDrop();', beam_drill)
        self.assertIn('if(drop == null) continue;', beam_drill)
        self.assertIn('Point2 p = lasers[i];', beam_drill)
        self.assertIn('float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;', beam_drill)
        self.assertIn('float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;', beam_drill)
        self.assertIn('Draw.z(Layer.power - 1);', beam_drill)
        self.assertIn('Draw.mixcol(glowColor, Mathf.absin(Time.time + i*5 + id*9, glowScl, glowIntensity));', beam_drill)
        self.assertIn('if(Math.abs(p.x - face.x) + Math.abs(p.y - face.y) == 0){', beam_drill)
        self.assertIn('Draw.scl(width);', beam_drill)
        self.assertIn('if(boostWarmup < 0.99f){', beam_drill)
        self.assertIn('Draw.alpha(1f - boostWarmup);', beam_drill)
        self.assertIn('Draw.rect(laserCenter, lx, ly);', beam_drill)
        self.assertIn('if(boostWarmup > 0.01f){', beam_drill)
        self.assertIn('Draw.alpha(boostWarmup);', beam_drill)
        self.assertIn('Draw.rect(laserCenterBoost, lx, ly);', beam_drill)
        self.assertIn('Draw.scl();', beam_drill)
        self.assertIn('float lsx = (p.x - dir.x/2f) * tilesize, lsy = (p.y - dir.y/2f) * tilesize;', beam_drill)
        self.assertIn('Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);', beam_drill)
        self.assertIn('if(boostWarmup > 0.001f){', beam_drill)
        self.assertIn('Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);', beam_drill)
        self.assertIn('Draw.color();', beam_drill)
        self.assertIn('Draw.mixcol();', beam_drill)
        self.assertIn('if(Lod.l2){', beam_drill)
        self.assertIn('Draw.z(Layer.effect);', beam_drill)
        self.assertIn('Lines.stroke(warmup);', beam_drill)
        self.assertIn('rand.setState(i, id);', beam_drill)
        self.assertIn('Color col = drop.color;', beam_drill)
        self.assertIn('Color spark = Tmp.c3.set(sparkColor).lerp(boostHeatColor, boostWarmup);', beam_drill)
        self.assertIn('for(int j = 0; j < sparks; j++){', beam_drill)
        self.assertIn('float fin = (Time.time / sparkLife + rand.random(sparkRecurrence + 1f)) % sparkRecurrence;', beam_drill)
        self.assertIn('float or = rand.range(2f);', beam_drill)
        self.assertIn('Tmp.v1.set(sparkRange * fin, 0).rotate(rotdeg() + rand.range(sparkSpread));', beam_drill)
        self.assertIn('Color result = Tmp.c1.set(spark).lerp(col, fin);', beam_drill)
        self.assertIn('Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);', beam_drill)
        self.assertIn('float px = Tmp.v1.x, py = Tmp.v1.y;', beam_drill)
        self.assertIn('if(fin <= 1f) Lines.lineAngle(lx + px + or * ddx, ly + py + or * ddy, Angles.angle(px, py), Mathf.slope(fin) * sparkSize);', beam_drill)
        self.assertIn('Draw.reset();', beam_drill)
        self.assertIn('if(glowRegion.found()){', beam_drill)
        self.assertIn('Draw.z(Layer.blockAdditive);', beam_drill)
        self.assertIn('Draw.blend(Blending.additive);', beam_drill)
        self.assertIn('Draw.color(Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup), warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))));', beam_drill)
        self.assertIn('Draw.rect(glowRegion, x, y, rotdeg());', beam_drill)
        self.assertIn('Draw.blend();', beam_drill)
        self.assertIn('public Tile[] facing = new Tile[size];', beam_drill)
        self.assertIn('public Point2[] lasers = new Point2[size];', beam_drill)
        self.assertIn('public @Nullable Item lastItem;', beam_drill)
        self.assertIn('public float warmup, boostWarmup;', beam_drill)
        self.assertIn('public float laserWidth = 0.65f;', beam_drill)
        self.assertIn('public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;', beam_drill)
        self.assertIn('public float glowIntensity = 0.2f, pulseIntensity = 0.07f;', beam_drill)
        self.assertIn('public float glowScl = 3f;', beam_drill)
        self.assertIn('public int sparks = 7;', beam_drill)
        self.assertIn('public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;', beam_drill)
        self.assertIn('public Color boostHeatColor = Color.sky.cpy().mul(0.87f);', beam_drill)
        self.assertIn('public Color heatColor = new Color(1f, 0.35f, 0.35f, 0.9f);', beam_drill)
        self.assertIn('public float heatPulse = 0.3f, heatPulseScl = 7f;', beam_drill)
        self.assertIn('public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;', beam_drill)
        self.assertIn('public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;', beam_drill)
        self.assertIn('public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;', beam_drill)
        self.assertIn('public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;', beam_drill)
        self.assertIn('public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;', beam_drill)
        self.assertIn('public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;', beam_drill)
        self.assertIn('public @Load("@-top") TextureRegion topRegion;', beam_drill)
        self.assertIn('public @Load("@-glow") TextureRegion glowRegion;', beam_drill)
        self.assertIn('public TextureRegion[] icons(){', beam_drill)
        self.assertIn('return new TextureRegion[]{region, topRegion};', beam_drill)
        self.assertIn('for(int i = 0; i < size; i++){', beam_drill)
        self.assertIn('public static void laser(TextureRegion line, TextureRegion edge, float x, float y, float x2, float y2, float scale){', beam_drill)
        self.assertIn('plasmaBore = new BeamDrill("plasma-bore"){{', beam_drill)
        self.assertIn('largePlasmaBore = new BeamDrill("large-plasma-bore"){{', beam_drill)
        self.assertIn('laserWidth = 0.7f;', beam_drill)
        self.assertIn('size = 2;', beam_drill)
        self.assertIn('size = 3;', beam_drill)
        self.assertIn('public void drawItemSelection(@Nullable UnlockableContent selection){', beam_drill)
        self.assertIn('float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;', beam_drill)
        self.assertIn('public float rotdeg(){', beam_drill)
        self.assertIn('return rotation * 90;', beam_drill)
        self.assertIn('public float worldx(){', beam_drill)
        self.assertIn('return x * tilesize;', beam_drill)
        self.assertIn('public float worldy(){', beam_drill)
        self.assertIn('return y * tilesize;', beam_drill)
        self.assertIn('public static final int tilesize = 8;', beam_drill)
        self.assertIn('public static boolean l2 = true;', beam_drill)
        self.assertIn('public static float alpha2 = 1f;', beam_drill)
        self.assertIn('public static float absin(float in, float scl, float mag){', beam_drill)
        self.assertIn('return (sin(in, scl * 2f, mag) + mag) / 2f;', beam_drill)
        self.assertIn('public static float slope(float fin){', beam_drill)
        self.assertIn('return 1f - Math.abs(fin - 0.5f) * 2f;', beam_drill)
        self.assertIn('public static Point2 d4(int i){', beam_drill)
        self.assertIn('public static int d4x(int i){', beam_drill)
        self.assertIn('public static int d4y(int i){', beam_drill)
        self.assertIn('public final static int[] d4x = {1, 0, -1, 0};', beam_drill)
        self.assertIn('public final static int[] d4y = {0, 1, 0, -1};', beam_drill)
        self.assertIn('public static float angle(float x, float y){', beam_drill)
        self.assertIn('public void setState(final long seed0, final long seed1){', beam_drill)
        self.assertIn('public float random(float max){', beam_drill)
        self.assertIn('return nextFloat() * max;', beam_drill)
        self.assertIn('public float range(float amount){', beam_drill)
        self.assertIn('return nextFloat() * amount * 2 - amount;', beam_drill)
        # The def constants (verified first): the
        # class-default draw fields have NO def
        # override (Blocks.java:3038-3071 sets only
        # laserWidth 0.7f on large-plasma-bore), so
        # they ride driver constants; laserWidth is a
        # caller-supplied input instead.
        self.assertIn('SOURCE_BEAM_DRILL_GLOW_SCL := 3.0', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_PULSE_INTENSITY := 0.07', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_GLOW_INTENSITY := 0.2', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_SPARKS := 7', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_SPARK_RANGE := 10.0', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_SPARK_LIFE := 27.0', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_SPARK_RECURRENCE := 4.0', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_SPARK_SPREAD := 45.0', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_SPARK_SIZE := 3.5', beam_drill)
        self.assertIn('SOURCE_BEAM_DRILL_HEAT_COLOR_ALPHA := 0.9', beam_drill)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2436)', beam_drill)
        # The proof's keys drive the draw pure (the
        # base + top rects with the payload early
        # return, the centered laser branch, the
        # Drawf.laser branch with the asymmetric boost
        # gates, the spark rolls with the fin gate,
        # the glow additive and the select call).
        proof = BEAM_DRILL_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_top',
            'draw_laser_centered',
            'draw_laser_branch_boost',
            'draw_sparks_rolls',
            'draw_glow',
            'draw_select',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.exists())
        self.assertTrue(BEAM_DRILL_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BeamDrillDrawRowsProof.gd', BEAM_DRILL_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_beam_drill_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_top',
            'draw_laser_centered',
            'draw_laser_branch_boost',
            'draw_sparks_rolls',
            'draw_glow',
            'draw_select',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
