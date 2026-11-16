import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawRowsProof.gd'
REPAIR_TURRET_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawRowsProof.tscn'


class C07RepairTurretDrawRowsTests(unittest.TestCase):
    def test_c07_repair_turret_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2421']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_draw_state')
        # The RepairTurret tick is live (N2226 advance +
        # N2280 timer cadence + N2259 coolant multiplier)
        # but NOTHING modeled draw(): the base/shadow/
        # region rects (RepairTurret.java:164-174), the
        # static drawBeam (:106-150) with its rand-seeded
        # jitter + pulse circle + two Drawf.laser calls,
        # drawSelect (:177-179) and drawPlace (:95-99)
        # dash circles, icons (:102-104). N2421 ports all
        # five areas as ONE pure-only draw pure, the N2396
        # precedent: draw is never called by the tick, so
        # the pure takes caller-supplied inputs (frame
        # rotation / strength / target / lastEnd / offset,
        # Time.time as time_value, and the four rand rolls
        # as already-rolled values -- NO RNG in the pure)
        # and returns the draw calls as data. The icons
        # rows ride the draw pure (icons() takes no args
        # and the SSOT schema validator requires non-empty
        # input keys) -- one pure, seven new result
        # symbols: the base / shadow / region calls, the
        # beam call, the select + place calls, and the
        # icons region list.
        self.assertEqual(
            ledger['N2421']['source_symbols'],
            [
                'source_repair_turret_draw_state_result.base_call',
                'source_repair_turret_draw_state_result.shadow_call',
                'source_repair_turret_draw_state_result.region_call',
                'source_repair_turret_draw_state_result.beam_call',
                'source_repair_turret_draw_state_result.select_call',
                'source_repair_turret_draw_state_result.place_call',
                'source_repair_turret_draw_state_result.icon_regions',
            ],
        )
        for name in ledger['N2421']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTurretBuildState.source_repair_turret_'))
        self.assertEqual(ledger['N2421']['runtime_proof'], '/root/C07RepairTurretDrawRowsProof')
        self.assertEqual(
            ledger['N2421']['tests'],
            [
                'test_c07_repair_turret_draw_rows_registration',
                'test_all_c07_repair_turret_draw_rows_input_evidence_is_exact',
                'test_repair_turret_draw_rows_state',
                'test_reference_graph_and_actual_c07_repair_turret_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2421']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #52 (1-based in
        # the merged advances-24 DEFERRED base): the
        # RepairTurret draw / drawSelect / drawPlace /
        # icons entry is REMOVED -- draw, drawBeam,
        # drawSelect, drawPlace and icons are all live
        # now, so nothing of the entry remains. Net
        # 286 - 1 = 285.
        self.assertFalse(any(entry.startswith('RepairTurret draw / drawSelect / drawPlace / icons rows (') for entry in ledger['N2421']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret read/write rows (') for entry in ledger['N2421']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret per-def stat rows (') for entry in ledger['N2421']['deferred_exprs']))
        self.assertEqual(len(ledger['N2421']['deferred_exprs']), 285)

    def test_all_c07_repair_turret_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2421']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTurretBuildState.source_repair_turret_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2421']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_draw_rows_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The draw rows (RepairPointBuild.draw(),
        # RepairTurret.java:164-174): `Draw.rect(baseRegion,
        # x, y);` + `Draw.z(Layer.turret);` + the
        # Drawf.shadow / Draw.rect region pair at
        # rotation - 90 -- the shadow shifts by the FLOAT
        # (size / 2f), so a size-2 repair-turret shifts
        # by 1.0 and a size-1 repair-point by 0.5 (NOT
        # the MassDriver int division). The drawBeam rows
        # (static, RepairTurret.java:106-150):
        # `rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));`
        # + the target branch (origin = pos + trns(
        # rotation, length), lastEnd setLength(max(2,
        # len)), the offset.trns jitter rotated by the
        # target rotation) + the strength > 0.01 gate
        # (pulse circle + two Drawf.laser calls, f =
        # (Time.time / 85f + rand.random(1f)) % 1f, alpha
        # 1 - Interp.pow5In(f)). NO RNG IN THE PURE: the
        # four rand rolls (angle 360f, phase 200f,
        # magnitude range, f 1f) are caller-supplied
        # inputs -- the pure computes geometry
        # deterministically from the already-rolled
        # values, and the caller (game runtime) owns the
        # seed/roll. The drawSelect rows (:177-179) and
        # drawPlace rows (:95-99) are dash circles at
        # repairRadius (the place circle WITH the Block
        # offset, unlike MassDriver). The icons rows
        # (:102-104): `return new TextureRegion[]{baseRegion, region};`
        # (`public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;`,
        # :47). Pure-only: the tick never calls draw
        # (draw is called by the renderer, drawSelect/
        # drawPlace by the UI, icons by the atlas).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_repair_turret_draw_state', repair_turret)
        self.assertIn('public float repairRadius = 50f;', repair_turret)
        self.assertIn('public float length = 5f;', repair_turret)
        self.assertIn('public float beamWidth = 1f;', repair_turret)
        self.assertIn('public float pulseRadius = 6f;', repair_turret)
        self.assertIn('public float pulseStroke = 2f;', repair_turret)
        self.assertIn('public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;', repair_turret)
        self.assertIn('public Color laserColor = Color.valueOf("98ffa9"), laserTopColor = Color.white.cpy();', repair_turret)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', repair_turret)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', repair_turret)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);', repair_turret)
        self.assertIn('public TextureRegion[] icons(){', repair_turret)
        self.assertIn('return new TextureRegion[]{baseRegion, region};', repair_turret)
        self.assertIn('public static void drawBeam(float x, float y, float rotation, float length, int id, @Nullable Sized target, Team team,', repair_turret)
        self.assertIn('rand.setSeed(id + (target instanceof Entityc e ? e.id() : 0));', repair_turret)
        self.assertIn('if(target != null){', repair_turret)
        self.assertIn('originX = x + Angles.trnsx(rotation, length),', repair_turret)
        self.assertIn('originY = y + Angles.trnsy(rotation, length);', repair_turret)
        self.assertIn('lastEnd.set(target).sub(originX, originY);', repair_turret)
        self.assertIn('lastEnd.setLength(Math.max(2f, lastEnd.len()));', repair_turret)
        self.assertIn('lastEnd.add(offset.trns(', repair_turret)
        self.assertIn('rand.random(360f) + Time.time/2f,', repair_turret)
        self.assertIn('Mathf.sin(Time.time + rand.random(200f), 55f, rand.random(target.hitSize() * 0.2f, target.hitSize() * 0.45f))', repair_turret)
        self.assertIn(').rotate(target instanceof Rotc rot ? rot.rotation() : 0f));', repair_turret)
        self.assertIn('lastEnd.add(originX, originY);', repair_turret)
        self.assertIn('if(strength > 0.01f){', repair_turret)
        self.assertIn('Draw.z(Layer.flyingUnit + 1); //above all units', repair_turret)
        self.assertIn('Draw.color(laserColor);', repair_turret)
        self.assertIn('float f = (Time.time / 85f + rand.random(1f)) % 1f;', repair_turret)
        self.assertIn('Draw.alpha(1f - Interp.pow5In.apply(f));', repair_turret)
        self.assertIn('Lines.stroke(strength * pulseStroke);', repair_turret)
        self.assertIn('Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);', repair_turret)
        self.assertIn('Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);', repair_turret)
        self.assertIn('Draw.z(Layer.flyingUnit + 1.1f);', repair_turret)
        self.assertIn('Draw.color(laserTopColor);', repair_turret)
        self.assertIn('Drawf.laser(laserTop, laserTopEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);', repair_turret)
        self.assertIn('Draw.color();', repair_turret)
        self.assertIn('Draw.rect(baseRegion, x, y);', repair_turret)
        self.assertIn('Draw.z(Layer.turret);', repair_turret)
        self.assertIn('Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);', repair_turret)
        self.assertIn('Draw.rect(region, x, y, rotation - 90);', repair_turret)
        self.assertIn('drawBeam(x, y, rotation, length, id, target, team, strength,', repair_turret)
        self.assertIn('pulseStroke, pulseRadius, beamWidth, lastEnd, offset, laserColor, laserTopColor,', repair_turret)
        self.assertIn('laser, laserEnd, laserTop, laserTopEnd);', repair_turret)
        self.assertIn('Drawf.dashCircle(x, y, repairRadius, Pal.accent);', repair_turret)
        self.assertIn('public float strength, rotation = 90;', repair_turret)
        self.assertIn('public Vec2 offset = new Vec2(), lastEnd = new Vec2();', repair_turret)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', repair_turret)
        self.assertIn('public static final int tilesize = 8;', repair_turret)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2421)', repair_turret)
        # The proof's keys drive the draw pure (the base
        # / shadow / region geometry incl. the FLOAT
        # size / 2f shadow shift, the beam with a target
        # at fixed rolls incl. the min-length-2 branch,
        # the weak-strength no-beam branch, the null-
        # target lastEnd hold, the select/place dash
        # circles, the icons region list).
        proof = REPAIR_TURRET_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_shadow_region',
            'draw_beam_with_target',
            'draw_beam_weak_strength',
            'draw_beam_target_null',
            'draw_select_place',
            'draw_icons',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceRepairTurretBuildState.gd")', proof)
        self.assertTrue(REPAIR_TURRET_STATE.exists())
        self.assertTrue(REPAIR_TURRET_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07RepairTurretDrawRowsProof.gd', REPAIR_TURRET_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_repair_turret_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_shadow_region',
            'draw_beam_with_target',
            'draw_beam_weak_strength',
            'draw_beam_target_null',
            'draw_select_place',
            'draw_icons',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
