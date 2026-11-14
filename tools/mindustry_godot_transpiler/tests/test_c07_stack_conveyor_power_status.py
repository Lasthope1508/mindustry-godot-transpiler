import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceStackConveyorBuildState.gd'
STACK_CONVEYOR_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07StackConveyorPowerStatusTests(unittest.TestCase):
    def test_c07_stack_conveyor_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2180']['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
        # N2178/N2179 proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator,
        # wall-crafter, mass-driver, launch-pad, radar,
        # repair-turret, shield-wall, repair-tower,
        # shockwave-tower, item-bridge and liquid-bridge drivers -- but the
        # StackConveyor (surge-conveyor, consumePower 1f/60f,
        # Blocks.java:2251) has NO driver at all: it extends
        # Block (StackConveyor.java:24, `public class
        # StackConveyor extends Block implements Autotiler{`), not a factory
        # or crafter or bridge, so no existing driver matches it -- the
        # N2178/N2179 drivers' implementation lists hold "ItemBridge" /
        # "LiquidBridge" only, exact-string matches, so "StackConveyor"
        # never matches them. Its StackConveyorBuild.updateTile reels
        # items in at a rate that follows the folded efficiency
        # (StackConveyor.java:270, `float eff = enabled ?
        # (efficiency + baseEfficiency) : 1f;`, with
        # StackConveyor.java:273, `if(cooldown > 0f) cooldown =
        # Mathf.clamp(cooldown - speed * eff * delta(), 0f,
        # recharge);`) -- so a surge-conveyor with no power would reel
        # slower and draw no glow, as if power.status were 1.0. N2180
        # is the stack conveyor's live read: a pure power row over the
        # stamped frame value, folded by the shared machinery into the
        # min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its own
        # driver, wired into simulate_factory like the item-bridge /
        # liquid-bridge drivers (N2178/N2179).
        # The family splits in two: surge-conveyor is a
        # StackConveyor with `consumePower(1f / 60f);`
        # (Blocks.java:2251) and `hasPower = true;`
        # (Blocks.java:2245), while plastanium-conveyor is a
        # StackConveyor with NO consumePower def and NO hasPower
        # line (Blocks.java:2084-2089) -- its transport does NOT
        # depend on power.status (with no power consumer its
        # efficiency stays 1.0 when enabled, so the cooldown still
        # reels at baseEfficiency 0f). This slice covers
        # surge-conveyor ONLY; the driver's implementation list
        # holds "StackConveyor" only, so the plastanium-conveyor
        # def never gets a power row -- and the plain radar gate
        # (block.properties.has("consumePower")) enforces the same
        # split on the def side. Catalog quirk to respect:
        # plastanium-conveyor lists `consumesPower: true` and
        # `hasPower: true` in the catalog despite NO consumePower
        # def and NO hasPower line in Blocks.java, the same pattern
        # as bridge-conveyor in N2178 and bridge-conduit in N2179
        # -- so the plain radar gate
        # (block.properties.has("consumePower")) is what matters;
        # it correctly includes surge-conveyor and excludes
        # plastanium-conveyor. Do NOT adapt the gate to `or
        # consumesPower` (the RepairTurret adaptation is for
        # ConsumePowerCondition defs; here the power def is a
        # plain static `consumePower(1f / 60f)`).
        # The surge def carries `baseEfficiency = 1f;`
        # (Blocks.java:2250) -- so the coupling is NOT a hard gate:
        # updateTile computes `eff = efficiency + baseEfficiency`
        # when enabled, so at efficiency 0 (no power) the belt
        # still reels at eff 1f, and power raises eff toward 2f
        # and lights the glow (StackConveyor.java:156-158, `if
        # (glowRegion.found() && power != null && power.status >
        # 0f){` with `Draw.color(glowColor, glowAlpha *
        # power.status);`). The proof's efficiency_zero_at_no_power
        # key proves the folded efficiency is 0 -- it must NOT
        # claim the belt stops; the reel continues at the base
        # rate. The glow is the only hard power gate on this
        # family.
        # StackConveyorBuild has NO shouldConsume override, so the
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
        # The stack conveyor's power draw is STATIC, not
        # conditional: `consumePower(1f / 60f);`
        # (Blocks.java:2251) registers a plain ConsumePower, so
        # the catalog consumePower 0.0167 is present and the plain
        # radar gate works -- no RepairTurret-style `or
        # consumesPower` adaptation is needed. Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2180']['source_symbols'],
            [
                'source_stack_conveyor_power_status_row_state_result.row',
                'source_stack_conveyor_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2180']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_stack_conveyor_power_status_row_state_result.row': 'SourceStackConveyorBuildState.source_stack_conveyor_power_status_row_state',
                    'source_stack_conveyor_power_status_row_state_result.has_power_row': 'SourceStackConveyorBuildState.source_stack_conveyor_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2180']['runtime_proof'], '/root/C07StackConveyorPowerStatusProof')
        self.assertEqual(
            ledger['N2180']['tests'],
            [
                'test_c07_stack_conveyor_power_status_registration',
                'test_all_c07_stack_conveyor_power_status_input_evidence_is_exact',
                'test_stack_conveyor_power_status_row_state',
                'test_reference_graph_and_actual_c07_stack_conveyor_power_status',
            ],
        )
        self.assertTrue(ledger['N2180']['deferred_exprs'])

    def test_all_c07_stack_conveyor_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2180']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_stack_conveyor_power_status_row_state_result.row': 'SourceStackConveyorBuildState.source_stack_conveyor_power_status_row_state',
                    'source_stack_conveyor_power_status_row_state_result.has_power_row': 'SourceStackConveyorBuildState.source_stack_conveyor_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2180']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_conveyor_power_status_row_state(self):
        stack_conveyor = STACK_CONVEYOR_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new stack-conveyor build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_stack_conveyor_power_status_row_state', stack_conveyor)
        self.assertIn('return build.power.status;', stack_conveyor)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', stack_conveyor)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the stack
        # conveyor's static power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The single def carries
        # `consumePower(1f / 60f);` (Blocks.java:2251) with
        # `baseEfficiency = 1f;` (Blocks.java:2250) and
        # `speed = 5f / 60f;` (Blocks.java:2241). The stack
        # conveyor's updateTile (StackConveyor.java:270, `float
        # eff = enabled ? (efficiency + baseEfficiency) : 1f;`
        # with StackConveyor.java:273, `if(cooldown > 0f)
        # cooldown = Mathf.clamp(cooldown - speed * eff *
        # delta(), 0f, recharge);`, keep on ONE comment line, the
        # N2148 shootWarmup lesson: a split line fails this
        # test) reels items at a rate that follows the folded
        # efficiency -- and because the surge def sets
        # baseEfficiency 1f, the belt still reels at eff 1f with
        # no power; power raises eff toward 2f and lights the
        # glow (StackConveyor.java:156, `if(glowRegion.found()
        # && power != null && power.status > 0f){` with
        # StackConveyor.java:158, `Draw.color(glowColor,
        # glowAlpha * power.status);`). The glow is the only hard
        # power gate on this family.
        # StackConveyorBuild has NO shouldConsume override, so the
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
        # The stack conveyor is its own family
        # (StackConveyor.java:24, `public class StackConveyor
        # extends Block implements Autotiler{`;
        # StackConveyorBuild, StackConveyor.java:114, `public
        # class StackConveyorBuild extends Building{`), a
        # distribution block, NOT related to any factory / turret
        # / defense / bridge family. Class fields:
        # `protected static final int stateMove = 0, stateLoad =
        # 1, stateUnload = 2;` (StackConveyor.java:25),
        # `public float glowAlpha = 1f;`
        # (StackConveyor.java:34), `public Color glowColor =
        # Pal.redLight;` (StackConveyor.java:35), `public float
        # baseEfficiency = 0f;` (StackConveyor.java:37),
        # `public float speed = 0f;` (StackConveyor.java:38),
        # `public boolean outputRouter = true;`
        # (StackConveyor.java:39), `public float recharge = 2f;`
        # (StackConveyor.java:41), `public Effect loadEffect =
        # Fx.conveyorPoof;` (StackConveyor.java:42), `public
        # Effect unloadEffect = Fx.conveyorPoof;`
        # (StackConveyor.java:43); constructor `rotate = true;`
        # (StackConveyor.java:48), `update = true;`
        # (StackConveyor.java:49), `group =
        # BlockGroup.transportation;` (StackConveyor.java:50),
        # `hasItems = true;` (StackConveyor.java:51),
        # `itemCapacity = 10;` (StackConveyor.java:52),
        # `conveyorPlacement = true;` (StackConveyor.java:53),
        # `underBullets = true;` (StackConveyor.java:54),
        # `priority = TargetPriority.transport;`
        # (StackConveyor.java:55), `drawCached = true;`
        # (StackConveyor.java:56), `buildingCacheLayer =
        # BuildingCacheLayer.under;` (StackConveyor.java:57),
        # `ambientSound = Sounds.loopConveyor;`
        # (StackConveyor.java:59), `ambientSoundVolume =
        # 0.004f;` (StackConveyor.java:60). Build fields:
        # `public int state, blendprox;`
        # (StackConveyor.java:115), `public int link = -1;`
        # (StackConveyor.java:117), `public float cooldown;`
        # (StackConveyor.java:118), `public Item lastItem;`
        # (StackConveyor.java:119), `boolean proxUpdating =
        # false;` (StackConveyor.java:121). The transfer branch
        # (StackConveyor.java:276, `if(link == -1) return;` with
        # StackConveyor.java:287, `if(!enabled) return;`)
        # returns early without a link or when disabled, and the
        # handoff sets `cooldown = recharge;`
        # (StackConveyor.java:311) with `e.cooldown = 1;`
        # (StackConveyor.java:312).
        # Single def -- surge-conveyor only (size 1, speed 5f/60f,
        # itemCapacity 10, health 130, surge-alloy 1 / tungsten 1,
        # Blocks.java:2237-2253). plastanium-conveyor
        # (StackConveyor, no power def, NO hasPower line,
        # Blocks.java:2084) is explicitly OUT of scope.
        self.assertIn('"is_power": true', stack_conveyor)
        self.assertIn('block.properties.has("consumePower")', stack_conveyor)
        self.assertIn('hasConsumers = consumers.length > 0;', stack_conveyor)
        self.assertIn('consumePower(1f / 60f);', stack_conveyor)
        self.assertIn('baseEfficiency = 1f;', stack_conveyor)
        self.assertIn('outputRouter = false;', stack_conveyor)
        self.assertIn('speed = 5f / 60f;', stack_conveyor)
        self.assertIn('health = 130;', stack_conveyor)
        self.assertIn('hasPower = true;', stack_conveyor)
        self.assertIn('consumesPower = true;', stack_conveyor)
        self.assertIn('conductivePower = true;', stack_conveyor)
        self.assertIn('public class StackConveyor extends Block implements Autotiler{', stack_conveyor)
        self.assertIn('protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;', stack_conveyor)
        self.assertIn('public float glowAlpha = 1f;', stack_conveyor)
        self.assertIn('public Color glowColor = Pal.redLight;', stack_conveyor)
        self.assertIn('public float baseEfficiency = 0f;', stack_conveyor)
        self.assertIn('public float speed = 0f;', stack_conveyor)
        self.assertIn('public boolean outputRouter = true;', stack_conveyor)
        self.assertIn('public float recharge = 2f;', stack_conveyor)
        self.assertIn('public Effect loadEffect = Fx.conveyorPoof;', stack_conveyor)
        self.assertIn('public Effect unloadEffect = Fx.conveyorPoof;', stack_conveyor)
        self.assertIn('rotate = true;', stack_conveyor)
        self.assertIn('update = true;', stack_conveyor)
        self.assertIn('group = BlockGroup.transportation;', stack_conveyor)
        self.assertIn('hasItems = true;', stack_conveyor)
        self.assertIn('itemCapacity = 10;', stack_conveyor)
        self.assertIn('conveyorPlacement = true;', stack_conveyor)
        self.assertIn('underBullets = true;', stack_conveyor)
        self.assertIn('priority = TargetPriority.transport;', stack_conveyor)
        self.assertIn('drawCached = true;', stack_conveyor)
        self.assertIn('buildingCacheLayer = BuildingCacheLayer.under;', stack_conveyor)
        self.assertIn('ambientSound = Sounds.loopConveyor;', stack_conveyor)
        self.assertIn('ambientSoundVolume = 0.004f;', stack_conveyor)
        self.assertIn('public class StackConveyorBuild extends Building{', stack_conveyor)
        self.assertIn('public int state, blendprox;', stack_conveyor)
        self.assertIn('public int link = -1;', stack_conveyor)
        self.assertIn('public float cooldown;', stack_conveyor)
        self.assertIn('public Item lastItem;', stack_conveyor)
        self.assertIn('boolean proxUpdating = false;', stack_conveyor)
        self.assertIn('if(glowRegion.found() && power != null && power.status > 0f){', stack_conveyor)
        self.assertIn('Draw.color(glowColor, glowAlpha * power.status);', stack_conveyor)
        self.assertIn('float eff = enabled ? (efficiency + baseEfficiency) : 1f;', stack_conveyor)
        self.assertIn('if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);', stack_conveyor)
        self.assertIn('if(link == -1) return;', stack_conveyor)
        self.assertIn('if(!enabled) return;', stack_conveyor)
        self.assertIn('cooldown = recharge;', stack_conveyor)
        self.assertIn('e.cooldown = 1;', stack_conveyor)
        self.assertIn('public boolean shouldConsume(){', stack_conveyor)
        self.assertIn('return enabled;', stack_conveyor)
        self.assertIn('public boolean canConsume(){', stack_conveyor)
        self.assertIn('return potentialEfficiency > 0;', stack_conveyor)
        self.assertIn('boolean update = shouldConsume() && productionValid();', stack_conveyor)
        self.assertIn('if(!update){', stack_conveyor)
        self.assertIn('return efficiency * delta();', stack_conveyor)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', stack_conveyor)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', stack_conveyor)
        self.assertIn('static func source_stack_conveyor_tick_buildings_state', stack_conveyor)
        # The stack conveyor needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the item-bridge / liquid-bridge
        # precedent, N2178/N2179).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_stack_conveyor_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_stack_conveyor_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no reel / cooldown /
        # transfer / link / state-machine keys: the updateTile
        # advance (StackConveyor.java:268-315, eff fold 270,
        # cooldown reel 273, link gate 276, transfer branch
        # 290-312) waits for its own slice, so the eff fold
        # (StackConveyor.java:270) is what the efficiency keys
        # prove. The efficiency_zero_at_no_power key proves the
        # folded efficiency is 0 -- it does NOT claim the belt
        # stops, because baseEfficiency 1f keeps the reel at eff
        # 1f; the glow is the only hard power gate.
        proof = STACK_CONVEYOR_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stack_conveyor_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_stack_conveyor_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackConveyorPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_CONVEYOR_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stack_conveyor_has_power_consumer',
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
