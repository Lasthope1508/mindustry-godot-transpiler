import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_ACCEPT_ITEM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverAcceptItemProof.gd'
MASS_DRIVER_ACCEPT_ITEM_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverAcceptItemProof.tscn'


class C07MassDriverAcceptItemTests(unittest.TestCase):
    def test_c07_mass_driver_accept_item_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2336']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_accept_item_state')
        # N2237 gave the mass driver its updateTile advance
        # (link refresh / reloadCounter decay / waitingShooters
        # cleanup / the idle-accepting-shooting switch /
        # rotation align / register + fire, MassDriver.java:
        # 133-221 + fire() :290-317) and N2294 gave it the
        # dumpAccumulate dump -- but the intake gate itself
        # was RED-deferred all along: acceptItem (MassDriver.
        # java:285-288, `public boolean acceptItem(Building
        # source, Item item){` with `//mass drivers that
        # output only cannot accept items` and `return items.
        # total() < itemCapacity && linkValid();`) was never
        # ported, so nothing in the port could answer whether
        # a mass driver takes an item. N2336 is the gate: the
        # pure accept function returns {accepts} from the two
        # Java terms -- the store total under the def
        # itemCapacity (120, Blocks.java:2170) AND linkValid()
        # (MassDriver.java:346-349, `protected boolean
        # linkValid(){` with `if(link == -1) return false;`
        # and `return world.build(this.link) instanceof
        # MassDriverBuild other && other.block == block &&
        # other.team == team && within(other, range);`). The
        # source/item args are ignored by Java -- the gate is
        # capacity + link only. linkValid reads the
        # driver-gathered linked dict (the N2225 partner
        # precedent): exists / is_mass_driver / same_block /
        # same_team / within_range, the SAME dict the N2237
        # advance reads for its has_link conjunction -- no
        # second gather, no new frame keys. within is STRICT
        # dst2 < range*range (Position.java:44-46, the N2229
        # verification); range is the single def 440f
        # (Blocks.java:2172 -- no large-mass-driver def in
        # this upstream version). The tick stamps the verdict
        # on the frame as accepts_item every tick (the N2295
        # Loader acceptPayload precedent) so neighbour intake
        # queries can consult it. One new result symbol: the
        # accepts verdict.
        self.assertEqual(
            ledger['N2336']['source_symbols'],
            [
                'source_mass_driver_accept_item_state_result.accepts',
            ],
        )
        for name in ledger['N2336']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/MassDriver.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_accept_item_state')
        self.assertEqual(ledger['N2336']['runtime_proof'], '/root/C07MassDriverAcceptItemProof')
        self.assertEqual(
            ledger['N2336']['tests'],
            [
                'test_c07_mass_driver_accept_item_registration',
                'test_all_c07_mass_driver_accept_item_input_evidence_is_exact',
                'test_mass_driver_accept_item_state',
                'test_reference_graph_and_actual_c07_mass_driver_accept_item',
            ],
        )
        self.assertTrue(ledger['N2336']['deferred_exprs'])
        # This slice resolves the MassDriver acceptItem
        # deferral and adds one new one: the frame items
        # intake (no live intake fills frame["items"] yet --
        # conveyor delivery / neighbour dump into the building
        # waits for its own slice; the stamped accepts_item
        # verdict has no live consumer yet). The link/config,
        # handlePayload, and dump neighbour entries stay: the
        # config handlers, the payload receipt, and the
        # neighbour live fill still defer.
        self.assertFalse(any(entry.startswith('MassDriver acceptItem rows (') for entry in ledger['N2336']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver frame items intake (') for entry in ledger['N2336']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver link/config rows (') for entry in ledger['N2336']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver handlePayload / receive rows (') for entry in ledger['N2336']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver dump neighbour live fill (') for entry in ledger['N2336']['deferred_exprs']))

    def test_all_c07_mass_driver_accept_item_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2336']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_accept_item_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/MassDriver.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Position.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2336']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_accept_item_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The intake gate (MassDriver.java:285-288, `public
        # boolean acceptItem(Building source, Item item){`
        # with `//mass drivers that output only cannot accept
        # items` and `return items.total() < itemCapacity &&
        # linkValid();`) is two terms: the store total under
        # the def itemCapacity (120, Blocks.java:2170) AND
        # linkValid() (MassDriver.java:346-349, `protected
        # boolean linkValid(){` with `if(link == -1) return
        # false;` and `return world.build(this.link)
        # instanceof MassDriverBuild other && other.block ==
        # block && other.team == team && within(other,
        # range);`). The source/item args are ignored by Java
        # -- the gate is capacity + link only -- so the pure
        # takes no source/item inputs. The link is the config
        # link (`public int link = -1;`, MassDriver.java:116,
        # default -1). within is STRICT dst2 < range*range
        # (Position.java:44-46, the N2229 verification):
        # `default boolean within(Position other, float dst){`
        # delegates to `default boolean within(float x, float
        # y, float dst){` with `return Mathf.dst2(getX(),
        # getY(), x, y) < dst*dst;`; range is the single def
        # 440f (Blocks.java:2172 -- no large-mass-driver def
        # in this upstream version). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test).
        self.assertIn('static func source_mass_driver_accept_item_state', mass_driver)
        self.assertIn('public boolean acceptItem(Building source, Item item){', mass_driver)
        self.assertIn('//mass drivers that output only cannot accept items', mass_driver)
        self.assertIn('return items.total() < itemCapacity && linkValid();', mass_driver)
        self.assertIn('protected boolean linkValid(){', mass_driver)
        self.assertIn('if(link == -1) return false;', mass_driver)
        self.assertIn('return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);', mass_driver)
        self.assertIn('public int link = -1;', mass_driver)
        self.assertIn('itemCapacity = 120;', mass_driver)
        self.assertIn('range = 440f;', mass_driver)
        self.assertIn('default boolean within(Position other, float dst){', mass_driver)
        self.assertIn('default boolean within(float x, float y, float dst){', mass_driver)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', mass_driver)
        # The pure reads the store total through the shared
        # drill inventory helper (never a hand-rolled total)
        # and the linkValid conjunction through a private
        # helper mirroring the N2237 advance's has_link --
        # the linked dict carries the precomputed components
        # (exists / is_mass_driver / same_block / same_team /
        # within_range), the N2225 partner precedent, and the
        # tick gathers it live from placed_blocks for the
        # advance already, so the accept pure reuses the SAME
        # dict with no second gather. The frame starts
        # unlinked (link -1) with the verdict false, and the
        # tick stamps the verdict on the frame every tick
        # after the dump write-back (the N2295 Loader
        # acceptPayload precedent), reading the post-tick
        # store and the same linked dict. The N2237 advance
        # call and the N2294 dump call are untouched (both
        # pinned by their own tests).
        self.assertIn('inventory.items_total(', mass_driver)
        self.assertIn('static func _mass_driver_link_valid', mass_driver)
        self.assertIn('linked.get("exists", false)', mass_driver)
        self.assertIn('linked.get("is_mass_driver", false)', mass_driver)
        self.assertIn('linked.get("same_block", false)', mass_driver)
        self.assertIn('linked.get("same_team", false)', mass_driver)
        self.assertIn('linked.get("within_range", false)', mass_driver)
        self.assertIn('"accepts_item": false', mass_driver)
        self.assertIn('source_mass_driver_accept_item_state(frame, SOURCE_MASS_DRIVER_ITEM_CAPACITY, linked)', mass_driver)
        self.assertIn('frame["accepts_item"]', mass_driver)
        self.assertLess(
            mass_driver.index('source_mass_driver_dump_state(frame, post_switch_state, source_delta, time_scale, item_order, dump_neighbour_accepts, dump_neighbour_can_dump)'),
            mass_driver.index('source_mass_driver_accept_item_state(frame, SOURCE_MASS_DRIVER_ITEM_CAPACITY, linked)'),
        )
        # The documented limits now record acceptItem as live
        # (the capacity + linkValid gate, stamped on the frame
        # as accepts_item) and no longer list it among the
        # missing rows; the N2237 advance, the N2294 dump, and
        # the power row are preserved.
        self.assertIn('acceptItem live (N2336)', mass_driver)
        self.assertIn('updateTile advance live (N2237)', mass_driver)
        self.assertIn('dumpAccumulate (:164-166) is live since N2294', mass_driver)
        self.assertIn('static func source_mass_driver_power_status_row_state', mass_driver)
        self.assertIn('static func source_mass_driver_update_tile_advance_state', mass_driver)
        self.assertIn('static func source_mass_driver_dump_state', mass_driver)
        self.assertIn('static func source_mass_driver_tick_buildings_state', mass_driver)
        self.assertIn('static func source_mass_driver_bind_frame_state', mass_driver)
        # The proof's keys drive the pure gate (accepts when
        # linked with room, rejects when full, rejects when
        # unlinked, rejects when the partner is the wrong
        # block / wrong team / out of range) plus the live
        # tick (a placed linked pair stamps accepts_item true,
        # a full store stamps it false, an unlinked driver
        # stamps it false).
        proof = MASS_DRIVER_ACCEPT_ITEM_PROOF.read_text(encoding='utf-8')
        for key in [
            'accepts_when_linked_and_room',
            'rejects_when_full',
            'rejects_when_unlinked',
            'rejects_when_partner_wrong_block',
            'rejects_when_partner_wrong_team',
            'rejects_when_partner_out_of_range',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('mass_driver_build_state.source_mass_driver_accept_item_state(', proof)
        self.assertIn('mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = MASS_DRIVER_ACCEPT_ITEM_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MassDriverAcceptItemProof.gd', scene)
        self.assertIn('C07MassDriverAcceptItemProof', scene)

    def test_reference_graph_and_actual_c07_mass_driver_accept_item(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverAcceptItemProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_ACCEPT_ITEM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepts_when_linked_and_room',
            'rejects_when_full',
            'rejects_when_unlinked',
            'rejects_when_partner_wrong_block',
            'rejects_when_partner_wrong_team',
            'rejects_when_partner_out_of_range',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
