import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07StackRouterPowerStatusTests(unittest.TestCase):
    def test_c07_stack_router_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2181']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178/N2179/N2180 proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower,
        # shockwave-tower, item-bridge, liquid-bridge and
        # stack-conveyor drivers -- but the
        # StackRouter (surge-router, consumePower 3f/60f,
        # Blocks.java:2266) has NO driver at all: it extends
        # DuctRouter (StackRouter.java:11, `public class
        # StackRouter extends DuctRouter{`), not a factory
        # or crafter or bridge or conveyor, so no existing driver matches it -- the
        # N2178/N2179/N2180 drivers' implementation lists hold "ItemBridge" /
        # "LiquidBridge" / "StackConveyor" only, exact-string matches, so "StackRouter"
        # never matches them. Its StackRouterBuild.updateTile unloads
        # items at a rate that follows the folded efficiency
        # (StackRouter.java:29, `float eff = enabled ?
        # (efficiency + baseEfficiency) : 0f;`, with
        # StackRouter.java:35, `progress += eff;`) -- so a surge-router with no power would unload
        # slower and draw no glow, as if power.status were 1.0. N2181
        # is the stack router's live read: a pure power row over the
        # stamped frame value, folded by the shared machinery into the
        # min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its own
        # driver, wired into simulate_factory like the item-bridge /
        # liquid-bridge / stack-conveyor drivers (N2178/N2179/N2180).
        # The family has a SINGLE def: surge-router is the only
        # StackRouter (Blocks.java:2255) -- there is no second
        # StackRouter def to split from, unlike the conveyor
        # (surge vs plastanium) or the bridges. The parent
        # DuctRouter (duct-router, Blocks.java:2193) and the
        # plain Router (router, Blocks.java:2139; distributor,
        # Blocks.java:2144) carry NO consumePower def and NO
        # hasPower line, so their transport does NOT depend on
        # power.status. This slice covers surge-router ONLY; the
        # driver's implementation list holds "StackRouter" only,
        # so no DuctRouter / Router def ever gets a power row --
        # and the plain radar gate
        # (block.properties.has("consumePower")) enforces the same
        # split on the def side. Catalog quirk to respect:
        # duct-router and router list `consumesPower: true` and
        # `hasPower: true` in the catalog despite NO consumePower
        # def and NO hasPower line in Blocks.java, the same pattern
        # as plastanium-conveyor in N2180 and bridge-conveyor in
        # N2178 and bridge-conduit in N2179 -- so the plain radar gate
        # (block.properties.has("consumePower")) is what matters;
        # it correctly includes surge-router and excludes
        # duct-router and router. Do NOT adapt the gate to `or
        # consumesPower` (the RepairTurret adaptation is for
        # ConsumePowerCondition defs; here the power def is a
        # plain static `consumePower(3f / 60f)`).
        # The surge def carries `baseEfficiency = 1f;`
        # (Blocks.java:2265) -- so the coupling is NOT a hard gate:
        # updateTile computes `eff = efficiency + baseEfficiency`
        # when enabled, so at efficiency 0 (no power) the router
        # still unloads at eff 1f, and power raises eff toward 2f
        # and lights the glow (StackRouter.java:79-81, `if
        # (glowRegion.found() && power != null && power.status >
        # 0){` with `Draw.color(glowColor, glowAlpha *
        # power.status);`). The proof's efficiency_zero_at_no_power
        # key proves the folded efficiency is 0 -- it must NOT
        # claim the router stops; the unload continues at the base
        # rate. The glow is the only hard power gate on this
        # family. Note the disabled branch differs from the
        # conveyor: StackRouter computes `... : 0f;`
        # (StackRouter.java:29) where StackConveyor computes
        # `... : 1f;` (StackConveyor.java:270) -- a disabled
        # surge-router unloads nothing, while a disabled
        # surge-conveyor still reels at eff 1f.
        # StackRouterBuild has NO shouldConsume override, so the
        # BuildingComp default applies (BuildingComp.java:755,
        # `public boolean shouldConsume(){` with
        # BuildingComp.java:756, `return enabled;`), and
        # updateConsumption forces efficiency to zero when the
        # gate is false (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1994,
        # `if(!update){` / efficiency = optionalEfficiency =
        # 0f). Unlike the ItemBridge / LiquidBridge link gates
        # (N2178/N2179), there is NO gate to defer here: the
        # power-only fold is EXACT for this family, because the
        # only gate is `enabled`, which the driver already checks.
        # The stack router's power draw is STATIC, not
        # conditional: `consumePower(3f / 60f);`
        # (Blocks.java:2266) registers a plain ConsumePower, so
        # the catalog consumePower 0.05 is present and the plain
        # radar gate works -- no RepairTurret-style `or
        # consumesPower` adaptation is needed. Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2181']['source_symbols'],
            [
                'source_stack_router_power_status_row_state_result.row',
                'source_stack_router_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2181']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_stack_router_power_status_row_state_result.row': 'SourceStackRouterBuildState.source_stack_router_power_status_row_state',
                    'source_stack_router_power_status_row_state_result.has_power_row': 'SourceStackRouterBuildState.source_stack_router_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2181']['runtime_proof'], '/root/C07StackRouterPowerStatusProof')
        self.assertEqual(
            ledger['N2181']['tests'],
            [
                'test_c07_stack_router_power_status_registration',
                'test_all_c07_stack_router_power_status_input_evidence_is_exact',
                'test_stack_router_power_status_row_state',
                'test_reference_graph_and_actual_c07_stack_router_power_status',
            ],
        )
        self.assertTrue(ledger['N2181']['deferred_exprs'])

    def test_all_c07_stack_router_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2181']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_stack_router_power_status_row_state_result.row': 'SourceStackRouterBuildState.source_stack_router_power_status_row_state',
                    'source_stack_router_power_status_row_state_result.has_power_row': 'SourceStackRouterBuildState.source_stack_router_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2181']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_power_status_row_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new stack-router build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_stack_router_power_status_row_state', stack_router)
        self.assertIn('return build.power.status;', stack_router)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', stack_router)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the stack
        # router's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(3f / 60f);` (Blocks.java:2266) with
        # `baseEfficiency = 1f;` (Blocks.java:2265) and
        # `speed = 6f;` (Blocks.java:2259). The stack
        # router's updateTile (StackRouter.java:29, `float
        # eff = enabled ? (efficiency + baseEfficiency) : 0f;`
        # with StackRouter.java:35, `progress += eff;`, keep on ONE comment line, the
        # N2148 shootWarmup lesson: a split line fails this
        # test) unloads items at a rate that follows the folded
        # efficiency -- and because the surge def sets
        # baseEfficiency 1f, the router still unloads at eff 1f with
        # no power; power raises eff toward 2f and lights the
        # glow (StackRouter.java:79, `if(glowRegion.found()
        # && power != null && power.status > 0){` with
        # StackRouter.java:81, `Draw.color(glowColor,
        # glowAlpha * power.status);`). The glow is the only hard
        # power gate on this family. Note the disabled branch
        # differs from the conveyor: `... : 0f;`
        # (StackRouter.java:29) where StackConveyor computes
        # `... : 1f;` (StackConveyor.java:270).
        # StackRouterBuild has NO shouldConsume override, so the
        # BuildingComp default applies (BuildingComp.java:755,
        # `public boolean shouldConsume(){` with `return
        # enabled;`, BuildingComp.java:756); updateConsumption
        # forces efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). There is NO gate to defer here (unlike
        # the ItemBridge / LiquidBridge link gates): the
        # power-only fold is EXACT, because the only gate is
        # `enabled`, which the driver already checks. canConsume
        # (BuildingComp.java:1917, `public boolean canConsume(){`
        # with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) and edelta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`) are the surrounding gates.
        # The stack router is its own family
        # (StackRouter.java:11, `public class StackRouter
        # extends DuctRouter{`; StackRouterBuild,
        # StackRouter.java:24, `public class StackRouterBuild
        # extends DuctRouterBuild{`), a distribution block, NOT
        # related to any factory / turret / defense / bridge /
        # conveyor family. Its parent DuctRouter
        # (DuctRouter.java:18, `public class DuctRouter extends
        # Block{`; DuctRouterBuild, DuctRouter.java:76,
        # `public class DuctRouterBuild extends Building{`)
        # supplies the sortItem / progress / current build
        # fields and the base updateTile (`progress +=
        # edelta() / speed * 2f;`, DuctRouter.java:102) --
        # but StackRouterBuild OVERRIDES updateTile
        # (StackRouter.java:28), so the parent's edelta-based
        # advance never runs for a surge-router. Class fields:
        # `public float baseEfficiency = 0f;`
        # (StackRouter.java:12), `public @Load(value =
        # "@-glow", fallback = "arrow-glow") TextureRegion
        # glowRegion;` (StackRouter.java:14), `public float
        # glowAlpha = 1f;` (StackRouter.java:15), `public
        # Color glowColor = Pal.redLight;`
        # (StackRouter.java:16); constructor `public
        # StackRouter(String name){`
        # (StackRouter.java:18), `itemCapacity = 10;`
        # (StackRouter.java:20), `drawDynamic = true;`
        # (StackRouter.java:21). Build fields: `public
        # boolean unloading = false;`
        # (StackRouter.java:25). The unload branch
        # (StackRouter.java:47, `var target = target();`
        # with StackRouter.java:49, `target.handleItem(this,
        # current);` and StackRouter.java:50,
        # `items.remove(current, 1);`) hands items to the
        # target while unloading, and the current-pick branch
        # (StackRouter.java:62, `if((current == null ||
        # items.get(current) == 0) && items.total() > 0){`
        # with StackRouter.java:63, `current =
        # items.first();`) picks the next item when the
        # current one runs out. Parent class fields:
        # `public float speed = 5f;`
        # (DuctRouter.java:19), `public @Load(value =
        # "@-top") TextureRegion topRegion;`
        # (DuctRouter.java:21); constructor `group =
        # BlockGroup.transportation;` (DuctRouter.java:26),
        # `update = true;` (DuctRouter.java:27), `solid =
        # false;` (DuctRouter.java:28), `hasItems = true;`
        # (DuctRouter.java:29), `unloadable = false;`
        # (DuctRouter.java:30), `itemCapacity = 1;`
        # (DuctRouter.java:31), `noUpdateDisabled = true;`
        # (DuctRouter.java:32), `configurable = true;`
        # (DuctRouter.java:33), `saveConfig = true;`
        # (DuctRouter.java:34), `rotate = true;`
        # (DuctRouter.java:35), `clearOnDoubleTap = true;`
        # (DuctRouter.java:36), `underBullets = true;`
        # (DuctRouter.java:37), `priority =
        # TargetPriority.transport;` (DuctRouter.java:38),
        # `envEnabled = Env.space | Env.terrestrial |
        # Env.underwater;` (DuctRouter.java:39), `drawCached
        # = true;` (DuctRouter.java:40), `drawDynamic =
        # false;` (DuctRouter.java:41). Parent build fields:
        # `public @Nullable Item sortItem;`
        # (DuctRouter.java:77), `public float progress;`
        # (DuctRouter.java:79), `public @Nullable Item
        # current;` (DuctRouter.java:80).
        # Single def -- surge-router only (size 1, speed 6f,
        # itemCapacity 10, health 130, surge-alloy 5 / tungsten 1,
        # Blocks.java:2255-2268). duct-router (DuctRouter, no power def, NO hasPower line,
        # Blocks.java:2193) and router (Router, no power def, NO hasPower line,
        # Blocks.java:2139) are explicitly OUT of scope.
        self.assertIn('"is_power": true', stack_router)
        self.assertIn('block.properties.has("consumePower")', stack_router)
        self.assertIn('hasConsumers = consumers.length > 0;', stack_router)
        self.assertIn('consumePower(3f / 60f);', stack_router)
        self.assertIn('baseEfficiency = 1f;', stack_router)
        self.assertIn('speed = 6f;', stack_router)
        self.assertIn('health = 130;', stack_router)
        self.assertIn('hasPower = true;', stack_router)
        self.assertIn('consumesPower = true;', stack_router)
        self.assertIn('conductivePower = true;', stack_router)
        self.assertIn('public class StackRouter extends DuctRouter{', stack_router)
        self.assertIn('public float baseEfficiency = 0f;', stack_router)
        self.assertIn('public @Load(value = "@-glow", fallback = "arrow-glow") TextureRegion glowRegion;', stack_router)
        self.assertIn('public float glowAlpha = 1f;', stack_router)
        self.assertIn('public Color glowColor = Pal.redLight;', stack_router)
        self.assertIn('public StackRouter(String name){', stack_router)
        self.assertIn('itemCapacity = 10;', stack_router)
        self.assertIn('drawDynamic = true;', stack_router)
        self.assertIn('public class StackRouterBuild extends DuctRouterBuild{', stack_router)
        self.assertIn('public boolean unloading = false;', stack_router)
        self.assertIn('float eff = enabled ? (efficiency + baseEfficiency) : 0f;', stack_router)
        self.assertIn('float cap = speed;', stack_router)
        self.assertIn('if(!unloading && current != null && items.total() >= itemCapacity){', stack_router)
        self.assertIn('if(progress < cap){', stack_router)
        self.assertIn('progress += eff;', stack_router)
        self.assertIn('if(progress >= cap){', stack_router)
        self.assertIn('unloading = true;', stack_router)
        self.assertIn('progress %= cap;', stack_router)
        self.assertIn('if(unloading && current != null){', stack_router)
        self.assertIn('var target = target();', stack_router)
        self.assertIn('while(target != null && items.get(current) > 0){', stack_router)
        self.assertIn('target.handleItem(this, current);', stack_router)
        self.assertIn('items.remove(current, 1);', stack_router)
        self.assertIn('if(items.get(current) == 0){', stack_router)
        self.assertIn('current = null;', stack_router)
        self.assertIn('unloading = false;', stack_router)
        self.assertIn('if((current == null || items.get(current) == 0) && items.total() > 0){', stack_router)
        self.assertIn('current = items.first();', stack_router)
        self.assertIn('if(items.empty()){', stack_router)
        self.assertIn('public void drawCached(){', stack_router)
        self.assertIn('super.draw();', stack_router)
        self.assertIn('if(glowRegion.found() && power != null && power.status > 0){', stack_router)
        self.assertIn('Draw.z(Layer.blockAdditive);', stack_router)
        self.assertIn('Draw.color(glowColor, glowAlpha * power.status);', stack_router)
        self.assertIn('Draw.blend(Blending.additive);', stack_router)
        self.assertIn('Draw.rect(glowRegion, x, y, rotation * 90);', stack_router)
        self.assertIn('Draw.blend();', stack_router)
        self.assertIn('Draw.color();', stack_router)
        self.assertIn('public boolean acceptItem(Building source, Item item){', stack_router)
        self.assertIn('(Edges.getFacingEdge(source.tile, tile).relativeTo(tile) == rotation);', stack_router)
        self.assertIn('public class DuctRouter extends Block{', stack_router)
        self.assertIn('public float speed = 5f;', stack_router)
        self.assertIn('public @Load(value = "@-top") TextureRegion topRegion;', stack_router)
        self.assertIn('public DuctRouter(String name){', stack_router)
        self.assertIn('group = BlockGroup.transportation;', stack_router)
        self.assertIn('update = true;', stack_router)
        self.assertIn('solid = false;', stack_router)
        self.assertIn('hasItems = true;', stack_router)
        self.assertIn('unloadable = false;', stack_router)
        self.assertIn('itemCapacity = 1;', stack_router)
        self.assertIn('noUpdateDisabled = true;', stack_router)
        self.assertIn('configurable = true;', stack_router)
        self.assertIn('saveConfig = true;', stack_router)
        self.assertIn('rotate = true;', stack_router)
        self.assertIn('clearOnDoubleTap = true;', stack_router)
        self.assertIn('underBullets = true;', stack_router)
        self.assertIn('priority = TargetPriority.transport;', stack_router)
        self.assertIn('envEnabled = Env.space | Env.terrestrial | Env.underwater;', stack_router)
        self.assertIn('drawCached = true;', stack_router)
        self.assertIn('drawDynamic = false;', stack_router)
        self.assertIn('public class DuctRouterBuild extends Building{', stack_router)
        self.assertIn('public @Nullable Item sortItem;', stack_router)
        self.assertIn('public float progress;', stack_router)
        self.assertIn('public @Nullable Item current;', stack_router)
        self.assertIn('progress += edelta() / speed * 2f;', stack_router)
        self.assertIn('if(progress >= (1f - 1f/speed)){', stack_router)
        self.assertIn('progress %= (1f - 1f/speed);', stack_router)
        self.assertIn('public boolean shouldConsume(){', stack_router)
        self.assertIn('return enabled;', stack_router)
        self.assertIn('public boolean canConsume(){', stack_router)
        self.assertIn('return potentialEfficiency > 0;', stack_router)
        self.assertIn('boolean update = shouldConsume() && productionValid();', stack_router)
        self.assertIn('if(!update){', stack_router)
        self.assertIn('return efficiency * delta();', stack_router)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', stack_router)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', stack_router)
        self.assertIn('static func source_stack_router_tick_buildings_state', stack_router)
        # The stack router needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the item-bridge / liquid-bridge /
        # stack-conveyor precedent, N2178/N2179/N2180).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_stack_router_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_stack_router_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress /
        # unloading / target / acceptItem keys: the updateTile
        # advance (StackRouter.java:28-70, eff fold 29,
        # progress advance 35, unload branch 47-60) waits for
        # its own slice, so the eff fold
        # (StackRouter.java:29) is what the efficiency keys
        # prove. The efficiency_zero_at_no_power key proves the
        # folded efficiency is 0 -- it does NOT claim the router
        # stops, because baseEfficiency 1f keeps the unload at eff
        # 1f; the glow is the only hard power gate.
        proof = STACK_ROUTER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stack_router_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_stack_router_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stack_router_has_power_consumer',
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
