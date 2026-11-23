import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
CAN_PLACE_ON_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillCanPlaceOnSetBarsDrawPlanConfigProof.gd'


class C07DrillCanPlaceOnSetBarsDrawPlanConfigTests(unittest.TestCase):
    def test_c07_drill_can_place_on_set_bars_draw_plan_config_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2330']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_can_place_on_state')
        # Drill.canPlaceOn() (Drill.java:126-137,
        # `public boolean canPlaceOn(Tile tile, Team
        # team, int rotation){`): multiblock drills
        # scan `tile.getLinkedTilesAs(this,
        # tempTiles)` and return true on the first
        # tile canMine() accepts, else false; a
        # single-tile drill returns canMine(tile)
        # directly. canMine() itself is N2010
        # (SourceDrillRuntimeState.source_can_mine_state)
        # -- NOT this slice: the caller passes the
        # already-computed canMine result per tile.
        # Drill.setBars() (Drill.java:114-121,
        # `public void setBars(){`): `super.setBars();`
        # (Block.setBars, Block.java:696-746, health /
        # power / items / liquid bars) is NOT this
        # slice -- the caller passes the already-built
        # super bars -- then `addBar("drillspeed",
        # (DrillBuild e) -> new Bar(() ->
        # Core.bundle.format("bar.drillspeed",
        # Strings.fixed(e.lastDrillSpeed * 60 *
        # e.timeScale(), 2)), () -> Pal.ammo, () ->
        # e.warmup));` adds the drillspeed bar. This
        # slice ports only the new bar spec (key,
        # text, color, fraction) as a pure function
        # and does NOT touch real Bar/UI playback.
        # Drill.drawPlanConfig() (Drill.java:100-111,
        # `public void drawPlanConfig(BuildPlan plan,
        # Eachable<BuildPlan> list){`): `if(!
        # plan.worldContext) return;`, `Tile tile =
        # plan.tile();`, `if(tile == null) return;`,
        # `countOre(tile);`, `if(returnItem == null
        # || !drawMineItem) return;`, then
        # `Draw.tint(returnItem.color);` and
        # `Draw.rect(itemRegion, plan.drawx(),
        # plan.drawy());`. countOre() is N2010
        # (SourceDrillRuntimeState.source_count_ore_state)
        # -- NOT this slice: the caller passes the
        # already-computed returnItem. This slice
        # ports only the tint + rect state as a pure
        # function and does NOT touch real Draw
        # playback. Eight new result symbols:
        # can_place_on, bar_key, bar_text, bar_color,
        # bar_fraction, visible, tint_color,
        # item_rect. There is NO driver tick line:
        # canPlaceOn is a placement predicate,
        # setBars is a load-time bar spec, and
        # drawPlanConfig is per-frame plan render
        # state (the N2341 drawSelect lifecycle
        # precedent).
        self.assertEqual(
            ledger['N2330']['source_symbols'],
            [
                'source_drill_can_place_on_state_result.can_place_on',
                'source_drill_set_bars_state_result.bar_key',
                'source_drill_set_bars_state_result.bar_text',
                'source_drill_set_bars_state_result.bar_color',
                'source_drill_set_bars_state_result.bar_fraction',
                'source_drill_draw_plan_config_state_result.visible',
                'source_drill_draw_plan_config_state_result.tint_color',
                'source_drill_draw_plan_config_state_result.item_rect',
            ],
        )
        for name in ledger['N2330']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/entities/units/BuildPlan.java',
                    'core/src/mindustry/type/Item.java',
                    'core/src/mindustry/graphics/Pal.java',
                    'core/src/mindustry/ui/Bar.java',
                    'arc-core/src/arc/util/Strings.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2330']['runtime_proof'], '/root/C07DrillCanPlaceOnSetBarsDrawPlanConfigProof')
        self.assertEqual(
            ledger['N2330']['tests'],
            [
                'test_c07_drill_can_place_on_set_bars_draw_plan_config_registration',
                'test_all_c07_drill_can_place_on_set_bars_draw_plan_config_input_evidence_is_exact',
                'test_drill_can_place_on_set_bars_draw_plan_config_state',
                'test_reference_graph_and_actual_c07_drill_can_place_on_set_bars_draw_plan_config',
            ],
        )
        self.assertTrue(ledger['N2330']['deferred_exprs'])

    def test_all_c07_drill_can_place_on_set_bars_draw_plan_config_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2330']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/units/BuildPlan.java',
            'core/src/mindustry/type/Item.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/ui/Bar.java',
            'arc-core/src/arc/util/Strings.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2330']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_can_place_on_set_bars_draw_plan_config_state(self):
        drill = DRILL_STATE.read_text(encoding='utf-8')
        # Drill.canPlaceOn() (Drill.java:126-137):
        # `public boolean canPlaceOn(Tile tile, Team
        # team, int rotation){`, `if(isMultiblock()){`
        # with `for(Tile other : tile.getLinkedTilesAs
        # (this, tempTiles)){` and `if(canMine(other)){`
        # then `return true;`, else `return false;`;
        # the single-tile leg is `return
        # canMine(tile);`. isMultiblock() is
        # `public boolean isMultiblock(){` with
        # `return size > 1;` (Block.java:1014-1016);
        # all four Drill defs are multiblock
        # (mechanical/pneumatic-drill `size = 2;`,
        # laser-drill `size = 3;`, blast-drill
        # `size = 4;`, Blocks.java), so the
        # multiblock leg is the live one and the
        # single-tile leg is kept for the Java shape.
        # Drill.setBars() (Drill.java:114-121):
        # `public void setBars(){` with `super.setBars
        # ();` then `addBar("drillspeed", (DrillBuild
        # e) ->` and `new Bar(() -> Core.bundle.format
        # ("bar.drillspeed", Strings.fixed(
        # e.lastDrillSpeed * 60 * e.timeScale(), 2)),
        # () -> Pal.ammo, () -> e.warmup));`. The
        # bundle value is `bar.drillspeed = Drill
        # Speed: {0}/s` (bundle.properties:1279); the
        # fixed text is Strings.fixedBuilder
        # truncation at 2 decimals (arc Strings.java:
        # 729-760, `dec.append((int)(float)(d *
        # Math.pow(10, decimalPlaces) + 0.0001f));`).
        # Pal.ammo is `ammo = Color.valueOf(
        # "ff8947"),` (Pal.java:64); the Bar
        # constructor is `public Bar(Prov<CharSequence>
        # name, Prov<Color> color, Floatp fraction){`
        # with `lastValue = value = Mathf.clamp(
        # fraction.get());` (Bar.java:31-33).
        # Drill.drawPlanConfig() (Drill.java:100-111):
        # `public void drawPlanConfig(BuildPlan plan,
        # Eachable<BuildPlan> list){` with `if(!
        # plan.worldContext) return;` (BuildPlan.java:
        # 30, `public boolean worldContext = true;`),
        # `Tile tile = plan.tile();` (`public @Nullable
        # Tile tile(){` with `return world.tile(x, y);`,
        # BuildPlan.java:161-163), `if(tile == null)
        # return;`, `countOre(tile);` (N2010, sets
        # `returnItem = itemArray.peek();`),
        # `if(returnItem == null || !drawMineItem)
        # return;`, `Draw.tint(returnItem.color);`
        # (Item.java:19, `public Color color;`),
        # `Draw.rect(itemRegion, plan.drawx(),
        # plan.drawy());` (`public float drawx(){`
        # with `return x*tilesize + (block == null ? 0
        # : block.offset);`, BuildPlan.java:142-144).
        # The classes are `public class Drill extends
        # Block{` (Drill.java:27) and `public class
        # DrillBuild extends Building{` (:237). There
        # is NO driver tick line: placement is a
        # predicate, setBars is a bar spec, and
        # drawPlanConfig is plan render state.
        self.assertIn('static func source_drill_can_place_on_state(frame: Dictionary, is_multiblock: bool, linked_tiles_can_mine: Array, tile_can_mine: bool) -> Dictionary:', drill)
        self.assertIn('static func source_drill_set_bars_state(frame: Dictionary, super_set_bars: Variant, last_drill_speed: float, time_scale: float, warmup: float) -> Dictionary:', drill)
        self.assertIn('static func source_drill_draw_plan_config_state(frame: Dictionary, world_context: bool, has_tile: bool, return_item: Variant, return_item_color: Variant, draw_mine_item: bool, item_region: Variant, draw_x: float, draw_y: float) -> Dictionary:', drill)
        for expr in [
            'public void drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list){',
            'if(!plan.worldContext) return;',
            'Tile tile = plan.tile();',
            'if(tile == null) return;',
            'countOre(tile);',
            'if(returnItem == null || !drawMineItem) return;',
            'Draw.tint(returnItem.color);',
            'Draw.rect(itemRegion, plan.drawx(), plan.drawy());',
            'Draw.color();',
            'public void setBars(){',
            'super.setBars();',
            'addBar("drillspeed", (DrillBuild e) ->',
            'new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastDrillSpeed * 60 * e.timeScale(), 2)), () -> Pal.ammo, () -> e.warmup));',
            'public boolean canPlaceOn(Tile tile, Team team, int rotation){',
            'if(isMultiblock()){',
            'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){',
            'if(canMine(other)){',
            'return true;',
            'return false;',
            'return canMine(tile);',
            'protected @Nullable Item returnItem;',
            'public boolean drawMineItem = true;',
            'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;',
            'public float lastDrillSpeed;',
            'public float warmup;',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
            'public boolean isMultiblock(){',
            'return size > 1;',
            'public int size = 1;',
            'addBar("health", entity -> new Bar("stat.health", Pal.health, entity::healthf).blink(Color.white));',
            'public <T extends Building> void addBar(String name, Func<T, Bar> sup){',
            'public boolean worldContext = true;',
            'public float drawx(){',
            'return x*tilesize + (block == null ? 0 : block.offset);',
            'public float drawy(){',
            'public @Nullable Tile tile(){',
            'return world.tile(x, y);',
            'public float timeScale(){',
            'return timeScale;',
            'private transient float timeScale = 1f, timeScaleDuration;',
            'public Color color;',
            'ammo = Color.valueOf("ff8947"),',
            'public Bar(Prov<CharSequence> name, Prov<Color> color, Floatp fraction){',
            'lastValue = value = Mathf.clamp(fraction.get());',
            'public static String fixed(float d, int decimalPlaces){',
            'return fixedBuilder(d, decimalPlaces).toString();',
            'dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));',
            'int decimalPosition = len - decimalPlaces;',
            'size = 2;',
            'size = 3;',
            'size = 4;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, drill)
        # The proof's keys drive the three pure
        # functions directly with per-def params:
        # canPlaceOn multiblock true on the first
        # minable linked tile, false when none mines,
        # single-tile leg from tile_can_mine; setBars
        # text "Drill Speed: 30.00/s" at
        # lastDrillSpeed 0.5 timeScale 1 and the
        # truncation case "Drill Speed: 7.41/s" at
        # 0.12365; drawPlanConfig visible with
        # worldContext + tile + returnItem +
        # drawMineItem, hidden by each guard leg.
        proof = CAN_PLACE_ON_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_place_on_multiblock',
            'can_place_on_single',
            'set_bars_text',
            'set_bars_spec',
            'draw_plan_config_visible',
            'draw_plan_config_hidden',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_can_place_on_set_bars_draw_plan_config(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillCanPlaceOnSetBarsDrawPlanConfigProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_CAN_PLACE_ON_SET_BARS_DRAW_PLAN_CONFIG_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_place_on_multiblock',
            'can_place_on_single',
            'set_bars_text',
            'set_bars_spec',
            'draw_plan_config_visible',
            'draw_plan_config_hidden',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])
