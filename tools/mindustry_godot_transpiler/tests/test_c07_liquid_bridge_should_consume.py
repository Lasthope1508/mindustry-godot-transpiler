import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
LIQUID_BRIDGE_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeShouldConsumeProof.gd'
LIQUID_BRIDGE_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeShouldConsumeProof.tscn'


class C07LiquidBridgeShouldConsumeTests(unittest.TestCase):
    def test_c07_liquid_bridge_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2198']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_should_consume_state')
        # N2179 gave the liquid bridge its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO live link on any
        # placed-building frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- when unlinked power.status
        # reads 1.0 while Java efficiency is 0. LiquidBridgeBuild
        # does NOT override shouldConsume: it inherits
        # ItemBridgeBuild.shouldConsume (`return hadValidLink &&
        # enabled;`, ItemBridge.java:495-496) verbatim, because
        # LiquidBridge extends ItemBridge (LiquidBridge.java:7,
        # `public class LiquidBridge extends ItemBridge{`) and
        # LiquidBridgeBuild extends ItemBridgeBuild
        # (LiquidBridge.java:19, `public class LiquidBridgeBuild
        # extends ItemBridgeBuild{`), overriding only
        # updateTransport and doDump (LiquidBridge.java:22-31).
        # N2197 supplied the missing link frame state on the
        # ItemBridge family frame (frame keys link/had_valid_link
        # + pure configure + pure linkValid + driver recompute),
        # and N2198 wires the inherited gate into the liquid
        # bridge's OWN driver (SourceLiquidBridgeBuildState.gd,
        # frame key "source_liquid_bridge_building"): the
        # LiquidBridge frame gets its own link/had_valid_link
        # keys (Java field defaults link -1, ItemBridge.java:198;
        # hadValidLink false, ItemBridge.java:202), the driver
        # recomputes had_valid_link every tick AFTER the
        # consumption fold (updateConsumption runs before
        # updateTile, BuildingComp.java:2274-2277) and only when
        # enabled (ItemBridge `noUpdateDisabled = true;`,
        # ItemBridge.java:54, inherited through the super
        # constructor -- a disabled bridge freezes its
        # had_valid_link instead of clearing it), and the pure
        # gate feeds `should_consume = had_valid_link && enabled`
        # to the machinery, so an unlinked phase-conduit folds
        # efficiency 0 like Java. The gate reads the previous
        # tick's had_valid_link -- correct per Java, NOT a bug.
        # Reuse, not a second copy: the driver calls N2197's pure
        # linkValid (SourceItemBridgeBuildState.
        # source_item_bridge_link_valid_state) through a preload
        # (the SourceFactoryRuntimeState precedent, which
        # preloads family BuildState files and calls their static
        # funcs), and the proof sets links through N2197's pure
        # configure -- exactly as Java inherits linkValid and the
        # config handlers instead of re-implementing them. Only
        # the arc Point2 pack/unpack primitives are duplicated as
        # private helpers in the family file (the N2191 slerpDelta
        # local precedent -- N2197 kept them private per-family,
        # and this slice must not touch the ItemBridge file,
        # which N2188 is editing in parallel). Two new result
        # symbols: the gate and the link validity it reads.
        self.assertEqual(
            ledger['N2198']['source_symbols'],
            [
                'source_liquid_bridge_should_consume_state_result.should_consume',
                'source_liquid_bridge_should_consume_state_result.had_valid_link',
            ],
        )
        for name in ledger['N2198']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_liquid_bridge_should_consume_state_result.should_consume': 'SourceLiquidBridgeBuildState.source_liquid_bridge_should_consume_state',
                    'source_liquid_bridge_should_consume_state_result.had_valid_link': 'SourceLiquidBridgeBuildState.source_liquid_bridge_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2198']['runtime_proof'], '/root/C07LiquidBridgeShouldConsumeProof')
        self.assertEqual(
            ledger['N2198']['tests'],
            [
                'test_c07_liquid_bridge_should_consume_registration',
                'test_all_c07_liquid_bridge_should_consume_input_evidence_is_exact',
                'test_liquid_bridge_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_should_consume',
            ],
        )
        self.assertTrue(ledger['N2198']['deferred_exprs'])
        # This slice resolves the N2179 LiquidBridge gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTransport advance, doDump, findLink
        # auto-link (N2199), draw/config, and per-def stat rows
        # stay deferred.
        self.assertFalse(any(entry.startswith('LiquidBridge shouldConsume gate (') for entry in ledger['N2198']['deferred_exprs']))

    def test_all_c07_liquid_bridge_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2198']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_liquid_bridge_should_consume_state_result.should_consume': 'SourceLiquidBridgeBuildState.source_liquid_bridge_should_consume_state',
                    'source_liquid_bridge_should_consume_state_result.had_valid_link': 'SourceLiquidBridgeBuildState.source_liquid_bridge_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'arc-core/src/arc/math/geom/Point2.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2198']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_should_consume_gate_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the liquid-bridge build state:
        # LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume
        # (ItemBridge.java:495, `public boolean shouldConsume(){`
        # with `return hadValidLink && enabled;`,
        # ItemBridge.java:496) -- LiquidBridge extends ItemBridge
        # (LiquidBridge.java:7, `public class LiquidBridge extends
        # ItemBridge{`) and LiquidBridgeBuild extends
        # ItemBridgeBuild (LiquidBridge.java:19, `public class
        # LiquidBridgeBuild extends ItemBridgeBuild{`), overriding
        # only updateTransport and doDump, so the gate is
        # inherited verbatim. The link validity lives on the
        # LiquidBridge frame (`public int link = -1;`,
        # ItemBridge.java:198 -- the old family comment cited
        # :202, fixed by this slice -- with `public boolean
        # wasMoved, moved, hadValidLink;`, ItemBridge.java:202 --
        # the old comment cited :206, fixed by this slice). When
        # the gate is false updateConsumption forces efficiency
        # to zero (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The driver recomputes had_valid_link
        # every tick (ItemBridge.java:332-333, `Tile other =
        # world.tile(link);` / `hadValidLink = linkValid(tile,
        # other);`), AFTER the consumption fold -- updateConsumption
        # runs before updateTile (BuildingComp.java:2274-2277,
        # `updateConsumption();` then `if(enabled ||
        # !block.noUpdateDisabled){` / `updateTile();`) -- and
        # only when enabled (ItemBridge `noUpdateDisabled =
        # true;`, ItemBridge.java:54, inherited through the super
        # constructor). The recompute reuses N2197's pure
        # linkValid (SourceItemBridgeBuildState.
        # source_item_bridge_link_valid_state) through a preload
        # -- the linkValid logic is NOT copied a second time; the
        # partner must be a LiquidBridge (the block clause,
        # ItemBridge.java:152, with `this` the LiquidBridge block)
        # and its link is read from its own liquid-bridge frame.
        # The pack is arc Point2.pack (arc Point2.java:40-42,
        # `return (((short)x) << 16) | (((short)y) & 0xFFFF);`),
        # the unpack arc Point2.unpack (arc Point2.java:35-37,
        # `return new Point2((short)(pos >>> 16), (short)(pos &
        # 0xFFFF));`); both are private helpers in the family
        # file (the N2191 slerpDelta local precedent -- no
        # separate symbol), with GDScript's 64-bit ints masked
        # and sign-extended back to short. The range comes from
        # the catalog (block.properties["range"], 12 for
        # phase-conduit, `range = 12;`, Blocks.java:2388; the Java
        # field default is 0 when the def does not set it,
        # `public int range;`, ItemBridge.java:27). The N2179 RED
        # decision is resolved: the machinery no longer runs with
        # should_consume=true when enabled. The updateTransport
        # advance (LiquidBridge.java:22-26, warmup gate 0.25f),
        # doDump, placement auto-link (playerPlaced / findLink /
        # lastBuild, N2199), sense, and draw/config UI wait for
        # their own slices.
        self.assertIn('static func source_liquid_bridge_should_consume_state', liquid_bridge)
        self.assertIn('had_valid_link and enabled', liquid_bridge)
        self.assertIn('public boolean shouldConsume(){', liquid_bridge)
        self.assertIn('return hadValidLink && enabled;', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class LiquidBridgeBuild extends ItemBridgeBuild{', liquid_bridge)
        self.assertIn('public int link = -1;', liquid_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', liquid_bridge)
        self.assertIn('`public int link = -1;` (ItemBridge.java:198)', liquid_bridge)
        self.assertIn('`public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202)', liquid_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', liquid_bridge)
        self.assertIn('Tile other = world.tile(link);', liquid_bridge)
        self.assertIn('noUpdateDisabled = true;', liquid_bridge)
        self.assertIn('boolean update = shouldConsume() && productionValid();', liquid_bridge)
        self.assertIn('if(!update){', liquid_bridge)
        self.assertIn('updateConsumption();', liquid_bridge)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', liquid_bridge)
        self.assertIn('return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));', liquid_bridge)
        self.assertIn('return (((short)x) << 16) | (((short)y) & 0xFFFF);', liquid_bridge)
        self.assertIn('"link": -1', liquid_bridge)
        self.assertIn('"had_valid_link": false', liquid_bridge)
        self.assertIn('frame["link"]', liquid_bridge)
        self.assertIn('frame["had_valid_link"]', liquid_bridge)
        self.assertIn('static func _point2_pack', liquid_bridge)
        self.assertIn('static func _point2_unpack', liquid_bridge)
        # The driver feeds the live gate to the machinery and
        # recomputes had_valid_link after the fold through
        # N2197's pure linkValid: the gate call, the
        # enabled-and-gate fold, the ItemBridge preload, the
        # reused linkValid call, the placed_blocks partner
        # lookup, and the catalog range.
        self.assertIn('static func source_liquid_bridge_tick_buildings_state', liquid_bridge)
        self.assertIn('source_liquid_bridge_should_consume_state(frame)', liquid_bridge)
        self.assertIn('bool(gate.get("should_consume", true))', liquid_bridge)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', liquid_bridge)
        self.assertIn('source_item_bridge_build_state.source_item_bridge_link_valid_state(', liquid_bridge)
        self.assertIn('game.get("placed_blocks")', liquid_bridge)
        self.assertIn('block.properties.get("range", 0)', liquid_bridge)
        # The documented limits record the gate as live; the old
        # N2179 deferral text is gone. The N2179 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2198)', liquid_bridge)
        self.assertNotIn('runs with should_consume=true when enabled', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_power_status_row_state', liquid_bridge)
        # The proof's keys drive the pure gate (true with a valid
        # link, false when unlinked, false when disabled) plus
        # the live tick (efficiency 0 when the gate is false, the
        # N2179 power fold preserved when the gate is true, and
        # the driver recomputing had_valid_link both ways). The
        # proof sets links through N2197's pure configure
        # (reused, not copied) -- no auto-link N2199 needed.
        # There are no transport / warmup / move-liquid keys: the
        # updateTransport advance (LiquidBridge.java:22-26,
        # warmup gate 0.25f) waits for its own slice, so the
        # warmup gate (LiquidBridge.java:23) is what the
        # efficiency keys prove. Static checks: the proof
        # preloads both family state files that exist, and the
        # scene file references the proof script that exists.
        proof = LIQUID_BRIDGE_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_with_valid_link',
            'gate_false_when_unlinked',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'live_tick_recomputes_had_valid_link',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertIn('item_bridge_build_state.source_item_bridge_configure_state(', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.is_file())
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        scene = LIQUID_BRIDGE_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LiquidBridgeShouldConsumeProof.gd', scene)
        self.assertTrue(LIQUID_BRIDGE_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_liquid_bridge_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_with_valid_link',
            'gate_false_when_unlinked',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'live_tick_recomputes_had_valid_link',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
