import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerDrawRowsProof.gd'
REPAIR_TOWER_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerDrawRowsProof.tscn'


class C07RepairTowerDrawRowsTests(unittest.TestCase):
    def test_c07_repair_tower_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2428']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_draw_state')
        # The RepairTower tick is live (N2227 advance +
        # N2306 live scan + N2250 liquid row) but NOTHING
        # modeled draw(): the draw circle/glow rows
        # (RepairTower.java:94-110), drawSelect
        # (:122-124), drawPlace (:44-48), setStats
        # (:36-40), range() (:112-114), warmup()
        # (:117-119). Verify-first (N2428): the def
        # (unit-repair-tower, Blocks.java:6575-6583)
        # overrides only range (100f) and healAmount
        # (1.5f); the draw constants are the class
        # defaults (circleStroke 3f, squareRad 3f,
        # squareSpinScl 0.8f, glowMag 0.5f, glowScl 8f,
        # RepairTower.java:23; circleColor / glowColor
        # Pal.heal, :22). N2428 ports them as TWO
        # pure-only pures (the N2419 Separator
        # precedent): the draw pure (super + circle +
        # square + glow + select + place calls) and the
        # stats/accessor pure (the setStats range +
        # repairSpeed rows + the range() / warmup()
        # accessors). Ten new result symbols: the six
        # draw calls + the two stat rows + the two
        # accessor values.
        self.assertEqual(
            ledger['N2428']['source_symbols'],
            [
                'source_repair_tower_draw_state_result.super_call',
                'source_repair_tower_draw_state_result.circle_call',
                'source_repair_tower_draw_state_result.square_call',
                'source_repair_tower_draw_state_result.glow_call',
                'source_repair_tower_draw_state_result.select_call',
                'source_repair_tower_draw_state_result.place_call',
                'source_repair_tower_stats_state_result.range_blocks',
                'source_repair_tower_stats_state_result.repair_per_second',
                'source_repair_tower_stats_state_result.range_value',
                'source_repair_tower_stats_state_result.warmup_value',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/graphics/Layer.java',
        }
        for name in ledger['N2428']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTowerBuildState.source_repair_tower_'))
        self.assertEqual(ledger['N2428']['runtime_proof'], '/root/C07RepairTowerDrawRowsProof')
        self.assertEqual(
            ledger['N2428']['tests'],
            [
                'test_c07_repair_tower_draw_rows_registration',
                'test_all_c07_repair_tower_draw_rows_input_evidence_is_exact',
                'test_repair_tower_draw_rows_state',
                'test_reference_graph_and_actual_c07_repair_tower_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2428']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #52 (1-based in
        # DEFERRED-after-advances-25.py): the RepairTower
        # draw / drawSelect / drawPlace / setStats /
        # range / warmup rows entry is REMOVED -- draw()
        # / drawSelect() / drawPlace() / setStats() /
        # range() / warmup() are live now, so nothing of
        # the entry remains. Net 280 - 1 = 279.
        self.assertFalse(any(entry.startswith('RepairTower draw / drawSelect / drawPlace / setStats / range / warmup rows') for entry in ledger['N2428']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower liquid consumer display rows') for entry in ledger['N2428']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower per-def stat rows') for entry in ledger['N2428']['deferred_exprs']))
        self.assertEqual(len(ledger['N2428']['deferred_exprs']), 279)

    def test_all_c07_repair_tower_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2428']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTowerBuildState.source_repair_tower_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/graphics/Layer.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The absin formula lives in Arc, not
        # Mindustry: Mathf.java under arc-upstream (the
        # N2191 / N2373 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2428']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_draw_rows_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The draw rows (RepairTowerBuild.draw(),
        # RepairTower.java:94-110) run super.draw() and
        # then, unless warmup <= 0.001f, the Layer.effect
        # circle (mod = totalProgress % 1f, stroke
        # circleStroke * (1 - mod) * warmup, radius
        # range * mod), the Pal.heal square (radius
        # squareRad * warmup, rotation Time.time /
        # squareSpinScl) and the additive glow (alpha
        # warmup * (1 - glowMag + absin(Time.time,
        # glowScl, glowMag)) at Layer.blockAdditive).
        # drawSelect (:122-124) dash-circles the range
        # in Pal.placing at the building x/y; drawPlace
        # (:44-48) dash-circles the same range at the
        # tile position (x * tilesize + offset).
        # setStats (:36-40) adds the range row (range /
        # tilesize blocks) and the repairSpeed row
        # (healAmount * 60 per second); range()
        # (:112-114) returns range and warmup()
        # (:117-119) returns warmup.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_repair_tower_draw_state', repair_tower)
        self.assertIn('static func source_repair_tower_stats_state', repair_tower)
        self.assertIn('public class RepairTower extends Block{', repair_tower)
        self.assertIn('public class RepairTowerBuild extends Building implements Ranged{', repair_tower)
        self.assertIn('public float range = 80f;', repair_tower)
        self.assertIn('public Color circleColor = Pal.heal, glowColor = Pal.heal.cpy().a(0.5f);', repair_tower)
        self.assertIn('public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', repair_tower)
        self.assertIn('public float healAmount = 1f;', repair_tower)
        self.assertIn('public @Load("@-glow") TextureRegion glow;', repair_tower)
        self.assertIn('public float warmup = 0f;', repair_tower)
        self.assertIn('public float totalProgress = 0f;', repair_tower)
        self.assertIn('stats.add(Stat.range, range / tilesize, StatUnit.blocks);', repair_tower)
        self.assertIn('stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);', repair_tower)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', repair_tower)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);', repair_tower)
        self.assertIn('super.draw();', repair_tower)
        self.assertIn('if(warmup <= 0.001f) return;', repair_tower)
        self.assertIn('Draw.z(Layer.effect);', repair_tower)
        self.assertIn('float mod = totalProgress % 1f;', repair_tower)
        self.assertIn('Draw.color(circleColor);', repair_tower)
        self.assertIn('Lines.stroke(circleStroke * (1f - mod) * warmup);', repair_tower)
        self.assertIn('Lines.circle(x, y, range * mod);', repair_tower)
        self.assertIn('Draw.color(Pal.heal);', repair_tower)
        self.assertIn('Fill.square(x, y, squareRad * warmup, Time.time / squareSpinScl);', repair_tower)
        self.assertIn('Draw.reset();', repair_tower)
        self.assertIn('Drawf.additive(glow, glowColor, warmup * (1f - glowMag + Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f, Layer.blockAdditive);', repair_tower)
        self.assertIn('return range;', repair_tower)
        self.assertIn('return warmup;', repair_tower)
        self.assertIn('Drawf.dashCircle(x, y, range, Pal.placing);', repair_tower)
        self.assertIn('range = 100f;', repair_tower)
        self.assertIn('healAmount = 1.5f;', repair_tower)
        self.assertIn('public static void dashCircle(float x, float y, float rad, Color color){', repair_tower)
        self.assertIn('public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){', repair_tower)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', repair_tower)
        self.assertIn('public static final int tilesize = 8;', repair_tower)
        self.assertIn('return (sin(in, scl * 2f, mag) + mag) / 2f;', repair_tower)
        self.assertIn('heal = Color.valueOf("98ffa9"),', repair_tower)
        self.assertIn('placing = accent,', repair_tower)
        self.assertIn('effect = 110,', repair_tower)
        self.assertIn('blockAdditive = 31,', repair_tower)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2428)', repair_tower)
        # The proof's keys drive the draw pures (the
        # warmup gate, the circle mod/stroke/radius, the
        # square + the glow absin, the select/place dash
        # circles, the setStats rows, the range/warmup
        # accessors).
        proof = REPAIR_TOWER_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_warmup_gate',
            'draw_circle',
            'draw_square_glow',
            'draw_select_place',
            'draw_stats',
            'draw_accessors',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceRepairTowerBuildState.gd")', proof)
        self.assertTrue(REPAIR_TOWER_STATE.exists())
        self.assertTrue(REPAIR_TOWER_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07RepairTowerDrawRowsProof.gd', REPAIR_TOWER_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_repair_tower_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_warmup_gate',
            'draw_circle',
            'draw_square_glow',
            'draw_select_place',
            'draw_stats',
            'draw_accessors',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
