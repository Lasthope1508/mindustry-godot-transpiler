import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIGHT_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourceLightBlockBuildState.gd'
LIGHT_BLOCK_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07LightBlockPowerStatusTests(unittest.TestCase):
    def test_c07_light_block_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2185']['godot_owner'], 'SourceLightBlockBuildState.source_light_block_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178/N2179/N2180/N2181/N2182/N2183/N2184 proved the pure
        # power-row pattern on the factory, adjacent-factory, drill,
        # turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump, beam-drill,
        # mend-projector, overdrive-projector, force-projector,
        # base-shield, regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower,
        # shockwave-tower, item-bridge, liquid-bridge,
        # stack-conveyor, stack-router, impact-reactor,
        # accelerator and build-turret drivers -- but the
        # LightBlock (illuminator, consumePower 0.05f,
        # Blocks.java:6767) has NO driver at all: it extends
        # Block directly (LightBlock.java:21, `public class
        # LightBlock extends Block{`), and grep for "LightBlock"
        # in godot-mindustry/src/game/ returns nothing.
        # The coupling is the light itself: drawLight scales the
        # emitted light by efficiency (LightBlock.java:128,
        # `Drawf.light(x, y, lightRadius * Math.min(smoothTime,
        # 2f), Tmp.c1.set(color), brightness * efficiency);`) --
        # an illuminator that cannot draw its 0.05f emits at
        # brightness 0, while the port without this slice would
        # behave as if power.status were 1.0. N2185 is the
        # illuminator's live read: a pure power row over the
        # stamped frame value, folded by the shared machinery
        # into the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its
        # own driver, wired into simulate_factory like the
        # build-turret driver (N2184). The family has a SINGLE
        # def: illuminator is the only LightBlock
        # (Blocks.java:6763) -- there is no second LightBlock
        # def to split from. The power draw is STATIC:
        # `consumePower(0.05f);` (Blocks.java:6767) registers a
        # plain ConsumePower, so the catalog consumePower 0.05
        # is present and the plain radar gate
        # (block.properties.has("consumePower")) works -- no
        # RepairTurret-style `or consumesPower` adaptation is
        # needed. LightBuild has NO shouldConsume override, so
        # the BuildingComp default (BuildingComp.java:755-756,
        # `return enabled;`) applies -- the power-only fold is
        # EXACT, no deferral needed (the StackConveyor N2180 /
        # Accelerator N2183 precedent). Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2185']['source_symbols'],
            [
                'source_light_block_power_status_row_state_result.row',
                'source_light_block_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2185']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_light_block_power_status_row_state_result.row': 'SourceLightBlockBuildState.source_light_block_power_status_row_state',
                    'source_light_block_power_status_row_state_result.has_power_row': 'SourceLightBlockBuildState.source_light_block_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2185']['runtime_proof'], '/root/C07LightBlockPowerStatusProof')
        self.assertEqual(
            ledger['N2185']['tests'],
            [
                'test_c07_light_block_power_status_registration',
                'test_all_c07_light_block_power_status_input_evidence_is_exact',
                'test_light_block_power_status_row_state',
                'test_reference_graph_and_actual_c07_light_block_power_status',
            ],
        )
        self.assertTrue(ledger['N2185']['deferred_exprs'])

    def test_all_c07_light_block_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2185']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_light_block_power_status_row_state_result.row': 'SourceLightBlockBuildState.source_light_block_power_status_row_state',
                    'source_light_block_power_status_row_state_result.has_power_row': 'SourceLightBlockBuildState.source_light_block_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/power/LightBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2185']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_light_block_power_status_row_state(self):
        light_block = LIGHT_BLOCK_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new light-block build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # illuminator's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(0.05f);` (Blocks.java:6767) -- the only
        # consumer on the block, so the folded efficiency is the
        # min over the modeled consumers (power only).
        # The block's updateTile (LightBlock.java:104) only
        # lerps smoothTime toward timeScale
        # (LightBlock.java:105, `smoothTime =
        # Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`) -- the
        # smoothTime advance waits for its own slice; the
        # coupling is drawLight (LightBlock.java:127), which
        # scales the emitted light by brightness * efficiency
        # (LightBlock.java:128, `Drawf.light(x, y, lightRadius
        # * Math.min(smoothTime, 2f), Tmp.c1.set(color),
        # brightness * efficiency);`) -- so an illuminator that
        # cannot draw its 0.05f emits at brightness 0; the
        # folded efficiency is what the efficiency keys prove,
        # and drawLight itself (presentation) waits for its own
        # slice. canConsume (BuildingComp.java:1917, `public
        # boolean canConsume(){` with `return
        # potentialEfficiency > 0;`, BuildingComp.java:1918)
        # and edelta (BuildingComp.java:1927-1929, `return
        # efficiency * delta();`) are the surrounding gates.
        # The illuminator is its own family
        # (LightBlock.java:21, `public class LightBlock extends
        # Block{`; LightBuild, LightBlock.java:67, `public class
        # LightBuild extends Building{`), a power / effect
        # block with no parent driver: no existing family state
        # covers it. Class fields: `public float brightness =
        # 0.9f;` (LightBlock.java:22), `public float radius =
        # 200f;` (LightBlock.java:23), `public @Load("@-top")
        # TextureRegion topRegion;` (LightBlock.java:24);
        # constructor `public LightBlock(String name){`
        # (LightBlock.java:26), `hasPower = true;`
        # (LightBlock.java:28), `update = true;`
        # (LightBlock.java:29), `configurable = true;`
        # (LightBlock.java:30), `saveConfig = true;`
        # (LightBlock.java:31), `envEnabled |= Env.space;`
        # (LightBlock.java:32), `swapDiagonalPlacement = true;`
        # (LightBlock.java:33). init sets the light radius and
        # clip (LightBlock.java:40, `lightRadius =
        # radius*2.5f;` with LightBlock.java:41, `lightClipSize
        # = Math.max(lightClipSize, lightRadius * 3f);` and
        # LightBlock.java:42, `emitLight = true;`). Build
        # fields: `public int color = Pal.accent.rgba();`
        # (LightBlock.java:68), `public float smoothTime = 1f;`
        # (LightBlock.java:69). The color config
        # (LightBlock.java:35, `config(Integer.class,
        # (LightBuild tile, Integer value) -> tile.color =
        # value);`), configured / control / sense
        # (LightBlock.java:72-94), buildConfiguration picker
        # (LightBlock.java:109-115) and onConfigureBuildTapped
        # (LightBlock.java:117-127) wait for their own slices,
        # as do draw (LightBlock.java:96-102), drawPlace
        # (LightBlock.java:48-53), changePlacementPath
        # (LightBlock.java:55-59), minimapColor
        # (LightBlock.java:61-66) and read/write
        # (LightBlock.java:137-148). Single def -- illuminator
        # only (brightness 0.75f, radius 140f, graphite 12 /
        # silicon 8 / lead 8, Blocks.java:6763-6767). No second
        # LightBlock def exists; there is no family split to
        # manage.
        self.assertIn('return build.power.status;', light_block)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', light_block)
        self.assertIn('hasConsumers = consumers.length > 0;', light_block)
        self.assertIn('public class LightBlock extends Block{', light_block)
        self.assertIn('public float brightness = 0.9f;', light_block)
        self.assertIn('public float radius = 200f;', light_block)
        self.assertIn('public @Load("@-top") TextureRegion topRegion;', light_block)
        self.assertIn('public LightBlock(String name){', light_block)
        self.assertIn('super(name);', light_block)
        self.assertIn('hasPower = true;', light_block)
        self.assertIn('update = true;', light_block)
        self.assertIn('configurable = true;', light_block)
        self.assertIn('saveConfig = true;', light_block)
        self.assertIn('envEnabled |= Env.space;', light_block)
        self.assertIn('swapDiagonalPlacement = true;', light_block)
        self.assertIn('config(Integer.class, (LightBuild tile, Integer value) -> tile.color = value);', light_block)
        self.assertIn('public void init(){', light_block)
        self.assertIn('lightRadius = radius*2.5f;', light_block)
        self.assertIn('lightClipSize = Math.max(lightClipSize, lightRadius * 3f);', light_block)
        self.assertIn('emitLight = true;', light_block)
        self.assertIn('super.init();', light_block)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', light_block)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', light_block)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);', light_block)
        self.assertIn('public void changePlacementPath(Seq<Point2> points, int rotation){', light_block)
        self.assertIn('var placeRadius2 = Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;', light_block)
        self.assertIn('Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);', light_block)
        self.assertIn('public int minimapColor(Tile tile){', light_block)
        self.assertIn('var build = (LightBuild)tile.build;', light_block)
        self.assertIn('return build == null ? 0 : build.color | 0xff;', light_block)
        self.assertIn('public class LightBuild extends Building{', light_block)
        self.assertIn('public int color = Pal.accent.rgba();', light_block)
        self.assertIn('public float smoothTime = 1f;', light_block)
        self.assertIn('public void configured(Unit player, Object value){', light_block)
        self.assertIn('super.configured(player, value);', light_block)
        self.assertIn('if(!headless) renderer.minimap.update(tile);', light_block)
        self.assertIn('public void control(LAccess type, double p1, double p2, double p3, double p4){', light_block)
        self.assertIn('if(type == LAccess.color){', light_block)
        self.assertIn('color = Tmp.c1.fromDouble(p1).rgba8888();', light_block)
        self.assertIn('super.control(type, p1, p2, p3, p4);', light_block)
        self.assertIn('public double sense(LAccess sensor){', light_block)
        self.assertIn('if(sensor == LAccess.color) return Tmp.c1.set(color).toDoubleBits();', light_block)
        self.assertIn('return super.sense(sensor);', light_block)
        self.assertIn('public void draw(){', light_block)
        self.assertIn('super.draw();', light_block)
        self.assertIn('Draw.color(Tmp.c1.set(color).a(0.6f));', light_block)
        self.assertIn('Draw.rect(topRegion, x, y);', light_block)
        self.assertIn('Draw.color();', light_block)
        self.assertIn('public void updateTile(){', light_block)
        self.assertIn('smoothTime = Mathf.lerpDelta(smoothTime, timeScale, 0.1f);', light_block)
        self.assertIn('public void buildConfiguration(Table table){', light_block)
        self.assertIn('table.button(Icon.pencil, Styles.cleari, () -> {', light_block)
        self.assertIn('ui.picker.show(Tmp.c1.set(color).a(0.5f), false, res -> configure(res.rgba()));', light_block)
        self.assertIn('deselect();', light_block)
        self.assertIn('}).size(40f);', light_block)
        self.assertIn('public boolean onConfigureBuildTapped(Building other){', light_block)
        self.assertIn('if(this == other){', light_block)
        self.assertIn('return false;', light_block)
        self.assertIn('return true;', light_block)
        self.assertIn('public void drawLight(){', light_block)
        self.assertIn('Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);', light_block)
        self.assertIn('public Integer config(){', light_block)
        self.assertIn('return color;', light_block)
        self.assertIn('public void write(Writes write){', light_block)
        self.assertIn('super.write(write);', light_block)
        self.assertIn('write.i(color);', light_block)
        self.assertIn('public void read(Reads read, byte revision){', light_block)
        self.assertIn('super.read(read, revision);', light_block)
        self.assertIn('color = read.i();', light_block)
        self.assertIn('illuminator = new LightBlock("illuminator"){{', light_block)
        self.assertIn('requirements(Category.effect, BuildVisibility.lightingOnly, with(Items.graphite, 12, Items.silicon, 8, Items.lead, 8));', light_block)
        self.assertIn('brightness = 0.75f;', light_block)
        self.assertIn('radius = 140f;', light_block)
        self.assertIn('consumePower(0.05f);', light_block)
        self.assertIn('return enabled;', light_block)
        self.assertIn('public boolean canConsume(){', light_block)
        self.assertIn('return potentialEfficiency > 0;', light_block)
        self.assertIn('boolean update = shouldConsume() && productionValid();', light_block)
        self.assertIn('if(!update){', light_block)
        self.assertIn('return efficiency * delta();', light_block)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', light_block)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', light_block)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_light_block_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_light_block_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no smoothTime / color
        # / config keys: the smoothTime advance
        # (LightBlock.java:104-107) and the color config
        # (LightBlock.java:35, 72-94, 109-127) wait for their own
        # slices, so the drawLight brightness fold is what the
        # efficiency keys prove. The
        # efficiency_zero_at_no_power key proves the folded
        # efficiency is 0 -- it does NOT claim the light stops
        # drawing, because drawLight is presentation
        # (LightBlock.java:127-128) and waits for its own slice;
        # the power row is the only hard gate here.
        proof = LIGHT_BLOCK_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'light_block_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_light_block_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LightBlockPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIGHT_BLOCK_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'light_block_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
