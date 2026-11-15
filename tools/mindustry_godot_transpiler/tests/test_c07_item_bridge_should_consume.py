import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeShouldConsumeProof.gd'
ITEM_BRIDGE_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeShouldConsumeProof.tscn'


class C07ItemBridgeShouldConsumeTests(unittest.TestCase):
    def test_c07_item_bridge_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2188']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_should_consume_state')
        # N2178 wired the item bridge's live power.status read but
        # left its shouldConsume gate deferred: ItemBridgeBuild
        # HAS a shouldConsume override (ItemBridge.java:495-496,
        # `return hadValidLink && enabled;`) -- the gate needs a
        # live link the tick did not track yet, so the machinery
        # ran with should_consume=true when enabled (the
        # MendProjector suppression precedent), and the first
        # N2188 attempt stopped at scoping for exactly that
        # reason. N2197 supplied the missing link frame state
        # (frame keys `link` / `had_valid_link`, a pure configure
        # mirroring the two constructor handlers, a pure linkValid
        # mirroring linkValid + positionsValid, and a driver
        # recompute every tick after the consumption fold -- the
        # Java order, updateConsumption before updateTile,
        # BuildingComp.java:2274-2277 -- and only when enabled,
        # ItemBridge `noUpdateDisabled = true;`,
        # ItemBridge.java:54). N2188 wires the gate: the driver
        # reads should_consume through the pure
        # source_item_bridge_should_consume_state function (the
        # N2186/N2187 gate precedent), which is the override
        # exactly -- `hadValidLink && enabled`, INCLUDING the
        # enabled check, unlike the LaunchPad/ShockwaveTower
        # overrides, whose enabled handling lives in
        # updateConsumption (BuildingComp.java:1954-1957, the
        # disabled early return). The gate reads the previous
        # tick's had_valid_link (the N2197 recompute runs after
        # the fold) -- that is Java, not a bug: updateTile
        # assigns hadValidLink after updateConsumption has
        # already folded efficiency (ItemBridge.java:332-333,
        # BuildingComp.java:2274-2277). When the gate is false,
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`), so an
        # unlinked bridge no longer reads power.status 1.0 while
        # Java efficiency is 0. Two new result symbols: the gate
        # verdict and the link state it read. LiquidBridge
        # inherits this gate (LiquidBridgeBuild extends
        # ItemBridgeBuild) but is its own slice, N2198 -- this
        # slice touches no LiquidBridge file.
        self.assertEqual(
            ledger['N2188']['source_symbols'],
            [
                'source_item_bridge_should_consume_state_result.should_consume',
                'source_item_bridge_should_consume_state_result.had_valid_link',
            ],
        )
        for name in ledger['N2188']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_should_consume_state_result.should_consume': 'SourceItemBridgeBuildState.source_item_bridge_should_consume_state',
                    'source_item_bridge_should_consume_state_result.had_valid_link': 'SourceItemBridgeBuildState.source_item_bridge_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2188']['runtime_proof'], '/root/C07ItemBridgeShouldConsumeProof')
        self.assertEqual(
            ledger['N2188']['tests'],
            [
                'test_c07_item_bridge_should_consume_registration',
                'test_all_c07_item_bridge_should_consume_input_evidence_is_exact',
                'test_item_bridge_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_item_bridge_should_consume',
            ],
        )
        self.assertTrue(ledger['N2188']['deferred_exprs'])

    def test_all_c07_item_bridge_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2188']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_should_consume_state_result.should_consume': 'SourceItemBridgeBuildState.source_item_bridge_should_consume_state',
                    'source_item_bridge_should_consume_state_result.had_valid_link': 'SourceItemBridgeBuildState.source_item_bridge_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2188']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_should_consume_gate_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure gate is ItemBridgeBuild.shouldConsume()
        # exactly (ItemBridge.java:495, `public boolean
        # shouldConsume(){` with `return hadValidLink &&
        # enabled;`, ItemBridge.java:496): the bridge consumes
        # only while its link is valid AND it is enabled. The
        # override INCLUDES the enabled check -- unlike the
        # LaunchPad (N2186) and ShockwaveTower (N2187) overrides
        # -- so the pure function reads both frame keys:
        # had_valid_link (ItemBridge.java:202, `public boolean
        # wasMoved, moved, hadValidLink;`, recomputed every tick
        # by the N2197 driver, ItemBridge.java:332-333, `Tile
        # other = world.tile(link);` / `hadValidLink =
        # linkValid(tile, other);`) and enabled
        # (BuildingComp.java:77, `transient boolean enabled =
        # true;`, the BuildingComp default shouldConsume,
        # BuildingComp.java:755-756, `return enabled;`). The
        # gate reads the previous tick's had_valid_link: the
        # N2197 recompute runs AFTER the consumption fold --
        # updateConsumption runs before updateTile
        # (BuildingComp.java:2274-2277, `updateConsumption();`
        # then `if(enabled || !block.noUpdateDisabled){` /
        # `updateTile();`) -- and only when enabled (ItemBridge
        # `noUpdateDisabled = true;`, ItemBridge.java:54, so a
        # disabled bridge freezes its had_valid_link instead of
        # clearing it). When the gate is false, updateConsumption
        # folds efficiency to 0 (BuildingComp.java:1960,
        # `boolean update = shouldConsume() &&
        # productionValid();`, with BuildingComp.java:1992-1994,
        # `if(!update){` / `efficiency =
        # optionalEfficiency = 0f;`). The power row itself is
        # unchanged (N2178): the pure ConsumePower read (`return
        # build.power.status;`, ConsumePower.java:39) over the
        # stamped frame value, for the phase-conveyor's static
        # power consumer (`consumePower(0.30f);`,
        # Blocks.java:2125; range 12, Blocks.java:2118;
        # transportTime 2f, Blocks.java:2119). The transport
        # advance, warmup, sense, draw/config UI, and placement
        # auto-link (N2199) still wait for their own slices.
        self.assertIn('static func source_item_bridge_should_consume_state', item_bridge)
        self.assertIn('public boolean shouldConsume(){', item_bridge)
        self.assertIn('return hadValidLink && enabled;', item_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', item_bridge)
        self.assertIn('public int link = -1;', item_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', item_bridge)
        self.assertIn('Tile other = world.tile(link);', item_bridge)
        self.assertIn('boolean update = shouldConsume() && productionValid();', item_bridge)
        self.assertIn('if(!update){', item_bridge)
        self.assertIn('efficiency = optionalEfficiency = 0f;', item_bridge)
        self.assertIn('return enabled;', item_bridge)
        self.assertIn('noUpdateDisabled = true;', item_bridge)
        self.assertIn('updateConsumption();', item_bridge)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', item_bridge)
        self.assertIn('updateTile();', item_bridge)
        self.assertIn('return build.power.status;', item_bridge)
        self.assertIn('consumePower(0.30f);', item_bridge)
        self.assertIn('range = 12;', item_bridge)
        self.assertIn('transportTime = 2f;', item_bridge)
        # The driver reads the gate through the pure function
        # (the N2186/N2187 gate precedent) instead of the old
        # `should_consume = enabled` line, and the N2178 power
        # row + the N2197 link frame state are preserved.
        self.assertIn('var gate: Dictionary = source_item_bridge_should_consume_state(frame)', item_bridge)
        self.assertIn('var should_consume: bool = bool(gate.get("should_consume", false))', item_bridge)
        self.assertIn('static func source_item_bridge_power_status_row_state', item_bridge)
        self.assertIn('static func source_item_bridge_configure_state', item_bridge)
        self.assertIn('static func source_item_bridge_link_valid_state', item_bridge)
        self.assertIn('frame["had_valid_link"]', item_bridge)
        # The old driver line (should_consume = enabled alone,
        # the whole line including its line end) is gone.
        self.assertNotIn('\n\t\t\tvar should_consume: bool = bool(frame.get("enabled", true))\n', item_bridge)
        # The proof's keys drive the pure gate (open with a
        # valid link, closed when unlinked, closed when
        # disabled -- the override includes enabled) plus the
        # live tick (the gate reads the previous tick's
        # had_valid_link, efficiency 0 when the gate is closed,
        # old N2178 behavior kept when the gate is open). There
        # are no transport/warmup keys: the transport advance
        # (ItemBridge.java:319-363) waits for its own slice, and
        # placement auto-link (playerPlaced / findLink /
        # lastBuild) waits for N2199 -- the proof sets the link
        # directly through the N2197 pure configure function.
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = ITEM_BRIDGE_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_open_with_valid_link',
            'gate_closed_when_unlinked',
            'gate_closed_when_disabled',
            'gate_reads_previous_tick_link',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertIn('write_proof("C07ItemBridgeShouldConsumeProof"', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        scene = ITEM_BRIDGE_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeShouldConsumeProof.gd', scene)
        self.assertIn('[node name="C07ItemBridgeShouldConsumeProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_item_bridge_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_open_with_valid_link',
            'gate_closed_when_unlinked',
            'gate_closed_when_disabled',
            'gate_reads_previous_tick_link',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
