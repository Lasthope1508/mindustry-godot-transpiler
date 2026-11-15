import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleUpdateTileProof.gd'
UNIT_ASSEMBLER_MODULE_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleUpdateTileProof.tscn'


class C07UnitAssemblerModuleUpdateTileTests(unittest.TestCase):
    def test_c07_unit_assembler_module_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2248']['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_update_tile_advance_state')
        # N2168 proved the UnitAssemblerModule family's live power
        # read -- but the port tracked no link / lastChange /
        # payload at all, so a basic-assembler-module never
        # re-found its assembler when tiles changed and never
        # forwarded its payload. N2248 is the updateTile advance
        # (UnitAssemblerModuleBuild.updateTile(),
        # UnitAssemblerModule.java:132-141): the lastChange
        # refresh on world.tileChanges (UnitAssemblerModule.java:
        # 133-136, lastChange init -2 at :73) with the findLink
        # re-discovery (UnitAssemblerModule.java:75-83) over the
        # explicit link-candidate frame input, the moveInPayload
        # approach + arrival check (PayloadBlock.java:181-197,
        # rotate=true, payloadSpeed 0.7f / payloadRotateSpeed 5f,
        # the PayloadBlock class defaults -- the module does not
        # override them), and the handoff gate
        # (UnitAssemblerModule.java:138) with the explicit
        # moduleFits / wasOccupied / acceptPayload predicates,
        # clearing the module payload when the gate holds
        # (UnitAssemblerModule.java:140). The getLink indexer
        # discovery, the removeModule / updateModules side
        # effects on the assembler, and the live predicate
        # evaluation defer (the link candidate and the
        # predicates arrive as frame inputs); the assembler-side
        # yeetPayload receive is N2131's intake state, and the
        # handoff-to-intake wiring waits for its own slice.
        # Eight new result symbols.
        self.assertEqual(
            ledger['N2248']['source_symbols'],
            [
                'source_unit_assembler_module_update_tile_advance_state_result.last_change',
                'source_unit_assembler_module_update_tile_advance_state_result.link',
                'source_unit_assembler_module_update_tile_advance_state_result.link_refreshed',
                'source_unit_assembler_module_update_tile_advance_state_result.pay_vector',
                'source_unit_assembler_module_update_tile_advance_state_result.pay_rotation',
                'source_unit_assembler_module_update_tile_advance_state_result.moved_in',
                'source_unit_assembler_module_update_tile_advance_state_result.payload',
                'source_unit_assembler_module_update_tile_advance_state_result.handed_off',
            ],
        )
        for name in ledger['N2248']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_unit_assembler_module_update_tile_advance_state_result.last_change': 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.link': 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.link_refreshed': 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.pay_vector': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.pay_rotation': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.moved_in': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.payload': 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
                    'source_unit_assembler_module_update_tile_advance_state_result.handed_off': 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_update_tile_advance_state')
        self.assertEqual(ledger['N2248']['runtime_proof'], '/root/C07UnitAssemblerModuleUpdateTileProof')
        self.assertEqual(
            ledger['N2248']['tests'],
            [
                'test_c07_unit_assembler_module_update_tile_registration',
                'test_all_c07_unit_assembler_module_update_tile_input_evidence_is_exact',
                'test_unit_assembler_module_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_update_tile',
            ],
        )
        self.assertTrue(ledger['N2248']['deferred_exprs'])
        # This slice resolves the N2168 UnitAssemblerModule
        # updateTile advance deferral, so the advance entry is
        # gone from DEFERRED -- while the handoff-to-intake
        # wiring entry and the updateTile live-fill entry take
        # its place, and the link / findLink entry is reworded
        # (the refresh is done; the discovery, the
        # removeModule / updateModules side effects, and the
        # live moduleFits evaluation still wait). DEFERRED goes
        # 283 - 1 removed + 2 added = 284 entries.
        self.assertEqual(len(ledger['N2248']['deferred_exprs']), 284)
        self.assertFalse(any(entry.startswith('UnitAssemblerModule updateTile advance (') for entry in ledger['N2248']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule link / findLink rows (') and 'N2248 advance models the link refresh' in entry for entry in ledger['N2248']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-to-intake wiring (') for entry in ledger['N2248']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule updateTile live fill (') for entry in ledger['N2248']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2248']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_update_tile_advance_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssembler.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/core/World.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Angles.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Vec2.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2248']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_update_tile_advance_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the unit-assembler-module
        # build state: the lastChange refresh
        # (UnitAssemblerModule.java:133-136), findLink
        # (UnitAssemblerModule.java:75-83) with getLink
        # (UnitAssemblerModule.java:65-69), the handoff gate
        # (UnitAssemblerModule.java:138) with yeetPayload +
        # payload clear (:139-140), moveInPayload(true)
        # (PayloadBlock.java:181-197) with the payRotation
        # moveToward toward rotdeg() (the module rotates,
        # UnitAssemblerModule.java:26) and the payVector
        # approach + hasArrived arrival check
        # (PayloadBlock.java:242-244). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). Cite corrections (all
        # verified by grep at this pin -- the scope brief and
        # the N2168 driver drift on them): updateTile is
        # 132-141 (not 129-141), getLink is 65-69 (not 64-69),
        # the class is at :18 and the build at :71, and
        # moduleFits is UnitAssembler.java:338 (not :323 --
        # :323 is the modules list). Time.delta in the port is
        # seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the N2186/N2187/
        # N2191 lesson); delta() = Time.delta * timeScale
        # (BuildingComp.java:1922-1924) is what moveInPayload
        # scales by, not edelta().
        self.assertIn('static func source_unit_assembler_module_update_tile_advance_state', unit_assembler_module)
        self.assertIn('if(lastChange != world.tileChanges){', unit_assembler_module)
        self.assertIn('lastChange = world.tileChanges;', unit_assembler_module)
        self.assertIn('link = getLink(team, tile.x, tile.y, rotation);', unit_assembler_module)
        self.assertIn('link.removeModule(this);', unit_assembler_module)
        self.assertIn('link.updateModules(this);', unit_assembler_module)
        self.assertIn('return results.find(b -> b.moduleFits(this, x * tilesize + offset, y * tilesize + offset, rotation));', unit_assembler_module)
        self.assertIn('if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){', unit_assembler_module)
        self.assertIn('link.yeetPayload(payload);', unit_assembler_module)
        self.assertIn('payload = null;', unit_assembler_module)
        self.assertIn('public UnitAssemblerBuild link;', unit_assembler_module)
        self.assertIn('public int lastChange = -2;', unit_assembler_module)
        self.assertIn('return moveInPayload(true);', unit_assembler_module)
        self.assertIn('payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());', unit_assembler_module)
        self.assertIn('payVector.approach(Vec2.ZERO, payloadSpeed * delta());', unit_assembler_module)
        self.assertIn('return hasArrived();', unit_assembler_module)
        self.assertIn('return payVector.isZero(0.01f);', unit_assembler_module)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', unit_assembler_module)
        self.assertIn('public Vec2 payVector = new Vec2();', unit_assembler_module)
        self.assertIn('public float payRotation;', unit_assembler_module)
        self.assertIn('public boolean moduleFits(Block other, float ox, float oy, int rotation){', unit_assembler_module)
        self.assertIn('public boolean wasOccupied = false;', unit_assembler_module)
        self.assertIn('blocks.add(payload.content(), 1);', unit_assembler_module)
        self.assertIn('return rotation * 90;', unit_assembler_module)
        self.assertIn('return Time.delta * timeScale;', unit_assembler_module)
        self.assertIn('public int tileChanges = 1, floorChanges = 1;', unit_assembler_module)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', unit_assembler_module)
        self.assertIn('consumePower(3.5f);', unit_assembler_module)
        # The def values are driver constants (single def --
        # basic-assembler-module; the catalog carries no
        # payload speeds): payloadSpeed 0.7f and
        # payloadRotateSpeed 5f are the PayloadBlock class
        # defaults (PayloadBlock.java:18) -- the module does
        # not override them -- and the arrival margin is the
        # hasArrived isZero(0.01f) squared-length margin
        # (PayloadBlock.java:243, Vec2.java:679-681).
        self.assertIn('SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_SPEED := 0.7', unit_assembler_module)
        self.assertIn('SOURCE_UNIT_ASSEMBLER_MODULE_PAYLOAD_ROTATE_SPEED := 5.0', unit_assembler_module)
        self.assertIn('SOURCE_UNIT_ASSEMBLER_MODULE_ARRIVAL_MARGIN := 0.01', unit_assembler_module)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the rotation reads live
        # from the sprite rotation meta
        # (SourceBlockGeometry.SOURCE_BUILD_ROTATION_META_KEY,
        # default 0); the advance runs after consumption, like
        # Java's Building.update() (BuildingComp.java:2274
        # updateConsumption(), then the updateTile gate
        # `if(enabled || !block.noUpdateDisabled){` at
        # BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing.
        self.assertIn('game_source_delta(game, seconds)', unit_assembler_module)
        self.assertIn('time_scale(sprite', unit_assembler_module)
        self.assertIn('SOURCE_BUILD_ROTATION_META_KEY', unit_assembler_module)
        self.assertIn('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)', unit_assembler_module)
        self.assertIn('frame["last_change"]', unit_assembler_module)
        self.assertIn('frame["link"]', unit_assembler_module)
        self.assertIn('frame["link_refreshed"]', unit_assembler_module)
        self.assertIn('frame["pay_vector"]', unit_assembler_module)
        self.assertIn('frame["pay_rotation"]', unit_assembler_module)
        self.assertIn('frame["moved_in"]', unit_assembler_module)
        self.assertIn('frame["payload"]', unit_assembler_module)
        self.assertIn('frame["handed_off"]', unit_assembler_module)
        # The deferred live fills arrive as frame inputs with
        # Java-faithful defaults: no supplied link candidate
        # means getLink found nothing, no predicate state means
        # no fit / not occupied / no acceptance, no payload
        # means moveInPayload returns false, and tileChanges
        # starts at 1 (World.java:35) against lastChange -2
        # (UnitAssemblerModule.java:73), so the first tick
        # refreshes.
        self.assertIn('frame.get("tile_changes", 1)', unit_assembler_module)
        self.assertIn('frame.get("last_change", -2)', unit_assembler_module)
        self.assertIn('frame.get("link", null)', unit_assembler_module)
        self.assertIn('frame.get("link_candidate", null)', unit_assembler_module)
        self.assertIn('frame.get("module_fits", false)', unit_assembler_module)
        self.assertIn('frame.get("was_occupied", false)', unit_assembler_module)
        self.assertIn('frame.get("accept_payload", false)', unit_assembler_module)
        self.assertIn('frame.get("payload", null)', unit_assembler_module)
        self.assertIn('frame.get("pay_vector", Vector2.ZERO)', unit_assembler_module)
        self.assertIn('frame.get("pay_rotation", 0.0)', unit_assembler_module)
        self.assertIn('frame.get("rotation", 0)', unit_assembler_module)
        # The fresh frame binds the new state keys with the Java
        # field defaults.
        self.assertIn('"link": null', unit_assembler_module)
        self.assertIn('"last_change": -2', unit_assembler_module)
        self.assertIn('"payload": null', unit_assembler_module)
        self.assertIn('"pay_vector": Vector2.ZERO', unit_assembler_module)
        self.assertIn('"pay_rotation": 0.0', unit_assembler_module)
        # The documented limits now record the advance as done
        # and the remaining deferrals (getLink discovery,
        # removeModule / updateModules side effects, live
        # predicate evaluation, handoff-to-intake wiring, live
        # payload fill); the N2168 power row is preserved.
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertNotIn('No updateTile advance', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_power_status_row_state', unit_assembler_module)
        # The proof's keys drive the pure advance (the link
        # refresh on a tile change, no refresh without one, the
        # handoff needing a link + fit + arrival, the occupied
        # block, the power block) plus the live tick (a placed
        # basic-assembler-module with a seeded payload +
        # link-candidate + predicates hands its payload off and
        # clears the frame payload, efficiency still folding
        # power.status).
        proof = UNIT_ASSEMBLER_MODULE_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'link_refreshes_on_tile_change',
            'no_refresh_without_change',
            'handoff_needs_link_and_fit',
            'handoff_blocked_when_occupied',
            'handoff_clears_payload',
            'handoff_blocked_without_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_ASSEMBLER_MODULE_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleUpdateTileProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'link_refreshes_on_tile_change',
            'no_refresh_without_change',
            'handoff_needs_link_and_fit',
            'handoff_blocked_when_occupied',
            'handoff_clears_payload',
            'handoff_blocked_without_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
