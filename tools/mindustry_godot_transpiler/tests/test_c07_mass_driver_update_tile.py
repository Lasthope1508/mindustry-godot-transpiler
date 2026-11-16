import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverUpdateTileProof.gd'
MASS_DRIVER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverUpdateTileProof.tscn'
MASS_DRIVER_ACCEPT_ITEM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverAcceptItemProof.gd'
MASS_DRIVER_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDumpProof.gd'
MASS_DRIVER_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDumpWriteBackProof.gd'
MASS_DRIVER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverPowerStatusProof.gd'


class C07MassDriverUpdateTileTests(unittest.TestCase):
    def test_c07_mass_driver_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2237']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_update_tile_advance_state')
        # N2171 proved the MassDriver live power read -- but the
        # port tracked no link / state / reload / waiting /
        # rotation / fire state at all, so a mass driver never
        # left idle: the no-power skip gated on an efficiency
        # no advance ever followed. N2237 is the updateTile
        # advance (MassDriverBuild.updateTile(), MassDriver.java:
        # 133-221, + fire(), MassDriver.java:290-317): the link
        # refresh (hasLink = linkValid, :134-139), the reload
        # decay regardless of state (:142-144), the
        # currentShooter cleanup (:146-151), the idle ->
        # accepting / shooting switch (:154-161), the no-power
        # skip (:169-171), the accepting align (:173-182), the
        # shooting register + align + fire gate (:182-220), and
        # fire() (:290-317, items leave the self frame the
        # moment they fire, bullet damage = totalUsed/2f).
        # The link is a CONFIG link (player set, :58-59) -- the
        # port has no config UI, so link is a frame key
        # (default -1) and the pure advance takes the linked
        # building as an explicit dict; dumpAccumulate
        # (:164-166), the Time.run arrival cleanup (:209-214),
        # handlePayload (:319-340) and the bullet entity
        # creation defer. Angles.near is STRICT < (Arc
        # Angles.java:29-31), not the <= of Angles.within.
        # Thirteen new result symbols: the advanced frame
        # values plus the partner write-back plus the fire
        # report.
        self.assertEqual(
            ledger['N2237']['source_symbols'],
            [
                'source_mass_driver_update_tile_advance_state_result.link',
                'source_mass_driver_update_tile_advance_state_result.rotation',
                'source_mass_driver_update_tile_advance_state_result.reload_counter',
                'source_mass_driver_update_tile_advance_state_result.state',
                'source_mass_driver_update_tile_advance_state_result.waiting_shooters',
                'source_mass_driver_update_tile_advance_state_result.items',
                'source_mass_driver_update_tile_advance_state_result.partner_waiting_shooters',
                'source_mass_driver_update_tile_advance_state_result.fired',
                'source_mass_driver_update_tile_advance_state_result.fired_items',
                'source_mass_driver_update_tile_advance_state_result.fired_total',
                'source_mass_driver_update_tile_advance_state_result.bullet_damage',
                'source_mass_driver_update_tile_advance_state_result.bullet_speed',
                'source_mass_driver_update_tile_advance_state_result.bullet_lifetime',
            ],
        )
        for name in ledger['N2237']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/MassDriver.java')
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_update_tile_advance_state')
        self.assertEqual(ledger['N2237']['runtime_proof'], '/root/C07MassDriverUpdateTileProof')
        self.assertEqual(
            ledger['N2237']['tests'],
            [
                'test_c07_mass_driver_update_tile_registration',
                'test_all_c07_mass_driver_update_tile_input_evidence_is_exact',
                'test_mass_driver_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_mass_driver_update_tile',
            ],
        )
        self.assertTrue(ledger['N2237']['deferred_exprs'])
        # This slice resolves TWO deferrals: the updateTile
        # advance entry and the fire / bullet entry (fire() is
        # ported: items leave the frame, bullet params are
        # pure results). Three new deferrals record what this
        # slice leaves behind (dumpAccumulate, the Time.run
        # arrival cleanup, the bullet entity creation).
        self.assertFalse(any(entry.startswith('MassDriver updateTile advance (') for entry in ledger['N2237']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('MassDriver fire / bullet rows (') for entry in ledger['N2237']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver dumpAccumulate / dump rows (') for entry in ledger['N2237']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver fire arrival / Time.run cleanup (') for entry in ledger['N2237']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver bullet entity / DriverBulletData rows (') for entry in ledger['N2237']['deferred_exprs']))

    def test_all_c07_mass_driver_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2237']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2237']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_update_tile_advance_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the mass-driver build state:
        # the link refresh (MassDriver.java:134-139), the reload
        # decay (MassDriver.java:142-144), the currentShooter
        # cleanup (MassDriver.java:146-151), the state switch
        # (MassDriver.java:154-161), dumpAccumulate
        # (MassDriver.java:164-166, deferred), the no-power skip
        # (MassDriver.java:169-171), the accepting align
        # (MassDriver.java:173-182), the shooting register +
        # align + fire gate (MassDriver.java:182-220), fire()
        # (MassDriver.java:290-317), shooterValid
        # (MassDriver.java:342-344) and linkValid
        # (MassDriver.java:346-349). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). delta() is `return Time.delta
        # * timeScale;` (BuildingComp.java:1922-1924) and
        # edelta() is `return efficiency * delta();`
        # (BuildingComp.java:1927-1929); source_delta is
        # Time.delta in ticks (seconds * 60 through
        # game_source_delta, arc Time.java:26), never raw
        # seconds. Angles.near is STRICT < (Arc Angles.java:
        # 29-31, `return angleDist(a, b) < range;`), unlike
        # Angles.within (<=); Mathf.clamp one-arg clamps to
        # [0, 1] (Arc Mathf.java:402-404).
        self.assertIn('static func source_mass_driver_update_tile_advance_state', mass_driver)
        self.assertIn('public class MassDriver extends Block{', mass_driver)
        self.assertIn('public class MassDriverBuild extends Building implements RotBlock{', mass_driver)
        self.assertIn('public int link = -1;', mass_driver)
        self.assertIn('public float rotation = 90;', mass_driver)
        self.assertIn('public float reloadCounter = 0f;', mass_driver)
        self.assertIn('public DriverState state = DriverState.idle;', mass_driver)
        self.assertIn('public OrderedSet<Building> waitingShooters = new OrderedSet<>();', mass_driver)
        self.assertIn('public float rotateSpeed = 5f;', mass_driver)
        self.assertIn('public int minDistribute = 10;', mass_driver)
        self.assertIn('public float reload = 100f;', mass_driver)
        self.assertIn('public float bulletSpeed = 5.5f;', mass_driver)
        self.assertIn('public float bulletLifetime = 200f;', mass_driver)
        self.assertIn('public void updateTile(){', mass_driver)
        self.assertIn('Building link = world.build(this.link);', mass_driver)
        self.assertIn('boolean hasLink = linkValid();', mass_driver)
        self.assertIn('this.link = link.pos();', mass_driver)
        self.assertIn('reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);', mass_driver)
        self.assertIn('var current = currentShooter();', mass_driver)
        self.assertIn('if(current != null && !shooterValid(current)){', mass_driver)
        self.assertIn('waitingShooters.remove(current);', mass_driver)
        self.assertIn('if(state == DriverState.idle){', mass_driver)
        self.assertIn('if(!waitingShooters.isEmpty() && (itemCapacity - items.total() >= minDistribute)){', mass_driver)
        self.assertIn('state = DriverState.accepting;', mass_driver)
        self.assertIn('state = DriverState.shooting;', mass_driver)
        self.assertIn('dumpAccumulate();', mass_driver)
        self.assertIn('if(efficiency <= 0f){', mass_driver)
        self.assertIn('if(currentShooter() == null || (itemCapacity - items.total() < minDistribute)){', mass_driver)
        self.assertIn('state = DriverState.idle;', mass_driver)
        self.assertIn('rotation = Angles.moveToward(rotation, angleTo(currentShooter()), rotateSpeed * efficiency);', mass_driver)
        self.assertIn('}else if(state == DriverState.shooting){', mass_driver)
        self.assertIn('if(!hasLink || (!waitingShooters.isEmpty() && (itemCapacity - items.total() >= minDistribute))){', mass_driver)
        self.assertIn('float targetRotation = angleTo(link);', mass_driver)
        self.assertIn('items.total() >= minDistribute', mass_driver)
        self.assertIn('link.block.itemCapacity - link.items.total() >= minDistribute', mass_driver)
        self.assertIn('MassDriverBuild other = (MassDriverBuild)link;', mass_driver)
        self.assertIn('other.waitingShooters.add(this);', mass_driver)
        self.assertIn('if(reloadCounter <= 0.0001f){', mass_driver)
        self.assertIn('rotation = Angles.moveToward(rotation, targetRotation, rotateSpeed * efficiency);', mass_driver)
        self.assertIn('if(other.currentShooter() == this &&', mass_driver)
        self.assertIn('other.state == DriverState.accepting &&', mass_driver)
        self.assertIn('Angles.near(rotation, targetRotation, 2f) && Angles.near(other.rotation, targetRotation + 180f, 2f)){', mass_driver)
        self.assertIn('fire(other);', mass_driver)
        self.assertIn('float timeToArrive = Math.min(bulletLifetime / timeScale, dst(other) / (bulletSpeed * timeScale));', mass_driver)
        self.assertIn('Time.run(timeToArrive, () -> {', mass_driver)
        self.assertIn('other.waitingShooters.remove(this);', mass_driver)
        self.assertIn('other.state = DriverState.idle;', mass_driver)
        self.assertIn('protected void fire(MassDriverBuild target){', mass_driver)
        self.assertIn('reloadCounter = 1f;', mass_driver)
        self.assertIn('for(int i = 0; i < content.items().size; i++){', mass_driver)
        self.assertIn('int maxTransfer = Math.min(items.get(content.item(i)), tile.block().itemCapacity - totalUsed);', mass_driver)
        self.assertIn('totalUsed += maxTransfer;', mass_driver)
        self.assertIn('items.remove(content.item(i), maxTransfer);', mass_driver)
        self.assertIn('totalUsed/2f, bulletSpeed * timeScale, bulletLifetime / timeScale', mass_driver)
        self.assertIn('protected boolean shooterValid(Building other){', mass_driver)
        self.assertIn('return other instanceof MassDriverBuild entity && other.isValid() && other.efficiency > 0 && entity.block == block && entity.link == pos() && within(other, range);', mass_driver)
        self.assertIn('protected boolean linkValid(){', mass_driver)
        self.assertIn('if(link == -1) return false;', mass_driver)
        self.assertIn('return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);', mass_driver)
        self.assertIn('public void handlePayload(Bullet bullet, DriverBulletData data){', mass_driver)
        self.assertIn('config(Point2.class, (MassDriverBuild tile, Point2 point) -> tile.link = Point2.pack(point.x + tile.tileX(), point.y + tile.tileY()));', mass_driver)
        self.assertIn('config(Integer.class, (MassDriverBuild tile, Integer point) -> tile.link = point);', mass_driver)
        self.assertIn('return Time.delta * timeScale;', mass_driver)
        self.assertIn('return efficiency * delta();', mass_driver)
        self.assertIn('updateConsumption();', mass_driver)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', mass_driver)
        self.assertIn('public boolean noUpdateDisabled = false;', mass_driver)
        self.assertIn('return angleDist(a, b) < range;', mass_driver)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', mass_driver)
        self.assertIn('amount = Math.min(amount, items[item.id]);', mass_driver)
        self.assertIn('itemCapacity = 120;', mass_driver)
        self.assertIn('reload = 200f;', mass_driver)
        self.assertIn('range = 440f;', mass_driver)
        self.assertIn('consumePower(1.75f);', mass_driver)
        # The def constants (mass-driver only, Blocks.java:
        # 2167-2174): the DEF reload 200f beats the class
        # `public float reload = 100f;` (MassDriver.java:33).
        # The class constants are rotateSpeed 5f, minDistribute
        # 10, bulletSpeed 5.5f, bulletLifetime 200f. The
        # initial frame carries the Java build-field defaults
        # (link -1, rotation 90, reloadCounter 0, state idle,
        # empty waitingShooters, empty items).
        self.assertIn('SOURCE_MASS_DRIVER_ITEM_CAPACITY := 120', mass_driver)
        self.assertIn('SOURCE_MASS_DRIVER_RELOAD := 200.0', mass_driver)
        self.assertIn('SOURCE_MASS_DRIVER_RANGE := 440.0', mass_driver)
        self.assertIn('SOURCE_MASS_DRIVER_ROTATE_SPEED := 5.0', mass_driver)
        self.assertIn('SOURCE_MASS_DRIVER_MIN_DISTRIBUTE := 10', mass_driver)
        self.assertIn('SOURCE_MASS_DRIVER_BULLET_SPEED := 5.5', mass_driver)
        self.assertIn('SOURCE_MASS_DRIVER_BULLET_LIFETIME := 200.0', mass_driver)
        self.assertIn('"link": -1', mass_driver)
        self.assertIn('"rotation": 90.0', mass_driver)
        self.assertIn('"reload_counter": 0.0', mass_driver)
        self.assertIn('"state": "idle"', mass_driver)
        self.assertIn('"waiting_shooters": []', mass_driver)
        self.assertIn('"items": {}', mass_driver)
        # The driver wires the advance into the live tick after
        # the consumption fold (the Java order:
        # updateConsumption before updateTile, BuildingComp.java:2274-2277),
        # WITHOUT an enabled guard (MassDriver has
        # noUpdateDisabled = false, the Block default,
        # Block.java:170 -- the N2231 precedent: Java runs
        # updateTile() even when disabled). The source delta is
        # game_source_delta(game, seconds) and timeScale reads
        # live from the sprite meta. The fire loop runs over
        # the catalog item order (item_names_by_id, the
        # content-id order fire() iterates), the rotation
        # reuses the shared angle helpers
        # (source_angles_move_toward / source_angles_angle),
        # and the item take / total reuse the shared drill
        # inventory helpers (SourceDrillInventoryRuntimeState).
        # The driver writes back BOTH frames (the N2225
        # precedent): the self keys and the partner's
        # waiting_shooters.
        self.assertIn('game_source_delta(game, seconds)', mass_driver)
        self.assertIn('time_scale(sprite', mass_driver)
        self.assertIn('source_mass_driver_update_tile_advance_state(frame, source_delta, time_scale, SOURCE_MASS_DRIVER_ITEM_CAPACITY, SOURCE_MASS_DRIVER_RELOAD, SOURCE_MASS_DRIVER_ROTATE_SPEED, SOURCE_MASS_DRIVER_MIN_DISTRIBUTE, SOURCE_MASS_DRIVER_BULLET_SPEED, SOURCE_MASS_DRIVER_BULLET_LIFETIME, this_pos, self_x, self_y, linked, shooters, item_order)', mass_driver)
        self.assertIn('item_names_by_id', mass_driver)
        self.assertIn('source_angles_move_toward(', mass_driver)
        self.assertIn('source_angles_angle(', mass_driver)
        self.assertIn('inventory.remove_item_state(', mass_driver)
        self.assertIn('inventory.items_total(', mass_driver)
        self.assertIn('inventory.item_count(', mass_driver)
        self.assertIn('frame["link"]', mass_driver)
        self.assertIn('frame["rotation"]', mass_driver)
        self.assertIn('frame["reload_counter"]', mass_driver)
        self.assertIn('frame["state"]', mass_driver)
        self.assertIn('frame["waiting_shooters"]', mass_driver)
        self.assertIn('frame["items"]', mass_driver)
        self.assertIn('partner_frame["waiting_shooters"]', mass_driver)
        # The documented limits now record the updateTile
        # advance as live and the remaining deferrals (dump,
        # Time.run arrival, bullet entity, handlePayload); the
        # old N2171 "No updateTile advance" text is gone. The
        # N2171 power row is preserved.
        self.assertIn('updateTile advance live (N2237)', mass_driver)
        self.assertNotIn('No updateTile advance', mass_driver)
        self.assertIn('static func source_mass_driver_power_status_row_state', mass_driver)
        self.assertIn('static func source_mass_driver_tick_buildings_state', mass_driver)
        self.assertIn('static func source_mass_driver_bind_frame_state', mass_driver)
        # The proof's keys drive the pure advance (the reload
        # counter decays by edelta / reload regardless of
        # state, idle accepts a waiting shooter and aligns,
        # shooting registers on the linked frame, fire moves
        # the items out and resets reload, no fire without
        # alignment) plus the live tick (the driver writes the
        # advance keys onto the frame). Static checks: the
        # proof preloads the family state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = MASS_DRIVER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'reload_counter_decays',
            'idle_accepts_waiting_shooter',
            'shooting_registers_on_link',
            'fire_transfers_items_and_resets_reload',
            'no_fire_without_alignment',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = MASS_DRIVER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MassDriverUpdateTileProof.gd', scene)
        self.assertIn('C07MassDriverUpdateTileProof', scene)

    def test_mass_driver_live_link_uses_java_tilesize_8(self):
        # N2375: the live link world-coord math uses the JAVA
        # tilesize constant 8.0 -- NEVER the game tile_size
        # 32 (the N2364 PMD precedent). Java ground truth
        # (read verbatim below): `public static final int
        # tilesize = 8;` (Vars.java:135); linkValid /
        # shooterValid gate on `within(other, range)`
        # (MassDriver.java:343/:348); within is STRICT dst <
        # range (Position.java:44-46, arc). Range is 440f in
        # Java world units (Blocks.java:2172). The game
        # tile_size is 32 (rendering px per tile -- it feeds
        # viewport/input), so the old driver line `tile_size
        # = game.get("tile_size")` (default 8.0 if unset)
        # made live link distances 4x Java's while the range
        # stayed in Java units: the live link range in tiles
        # was 4x SHORTER than Java's.
        # Boundary numbers (the deviation, verified FIRST):
        # 30 cells apart: Java 30*8 = 240 < 440 in range, old
        # port 30*32 = 960 > 440 out of range. 54 cells is
        # the last in-range separation under Java math (432 <
        # 440); 55 cells (440, NOT < 440) stays out of range
        # after the fix -- strict dst. Old boundary: 13
        # cells in (416 < 440), 14 cells out (448 > 440).
        java_tilesize = 8.0
        game_tile_size = 32.0
        mass_driver_range = 440.0
        self.assertLess(30 * java_tilesize, mass_driver_range)
        self.assertGreater(30 * game_tile_size, mass_driver_range)
        self.assertLess(54 * java_tilesize, mass_driver_range)
        self.assertFalse(55 * java_tilesize < mass_driver_range)
        self.assertLess(13 * game_tile_size, mass_driver_range)
        self.assertGreater(14 * game_tile_size, mass_driver_range)
        vars_lines = (ROOT / 'mindustry-upstream/core/src/mindustry/Vars.java').read_text(encoding='utf-8').splitlines()
        self.assertEqual(vars_lines[134].strip(), 'public static final int tilesize = 8;')
        mass_driver_lines = (ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/distribution/MassDriver.java').read_text(encoding='utf-8').splitlines()
        self.assertIn('within(other, range)', mass_driver_lines[342])
        self.assertIn('within(other, range)', mass_driver_lines[347])
        blocks_lines = (ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java').read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2171].strip(), 'range = 440f;')
        position_lines = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8').splitlines()
        self.assertEqual(position_lines[44].strip(), 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;')
        # The fix: the driver hard-codes the Java constant
        # and NEVER reads game tile_size for world-coord
        # math. Every consumer of the local was audited: the
        # self / other / shooter coords (the within_range
        # checks + the linked x/y) -- ALL Java world units;
        # none needs the game value. The old "the game
        # tile_size when set" comment is gone.
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        self.assertIn('\t\tvar tile_size: float = 8.0\n', mass_driver)
        self.assertNotIn('game.get("tile_size")', mass_driver)
        self.assertNotIn('tile_size_value', mass_driver)
        self.assertNotIn('the game tile_size when set', mass_driver)
        self.assertIn('the game tile_size 32 is rendering px per tile', mass_driver)
        self.assertIn('float(cell.x) * tile_size', mass_driver)
        self.assertIn('float(other_cell.x) * tile_size', mass_driver)
        self.assertIn('float(shooter_cell.x) * tile_size', mass_driver)
        # NO RE-SEED NEEDED (unlike N2364 -> N2365): every
        # MassDriver proof was checked against the fix --
        # the AcceptItem pair sits 2 cells apart (in range
        # under BOTH maths: 2*8 = 16 < 440 and 2*32 = 64 <
        # 440, so no verdict flips), and every other
        # live-tick proof ticks with link -1 / no link / no
        # waiting shooter (the updateTile live tick, the
        # Dump proof, the DumpWriteBack proof, the
        # PowerStatus proof -- single unlinked driver). The
        # pure/advance fixtures pass precomputed coords
        # already in Java units (partner x 80.0 = 10 cells *
        # 8). No MassDriver proof needs a re-run for N2375.
        self.assertLess(2 * java_tilesize, mass_driver_range)
        self.assertLess(2 * game_tile_size, mass_driver_range)
        accept_proof = MASS_DRIVER_ACCEPT_ITEM_PROOF.read_text(encoding='utf-8')
        self.assertIn('Vector2i(28, 21)', accept_proof)
        self.assertIn('Vector2i(30, 21)', accept_proof)
        update_proof = MASS_DRIVER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        self.assertIn('int(mass_driver_frame.get("link", 0)) == -1', update_proof)
        dump_proof = MASS_DRIVER_DUMP_PROOF.read_text(encoding='utf-8')
        self.assertIn('no link) with the reload counter', dump_proof)
        write_back_proof = MASS_DRIVER_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        self.assertIn('link -1, no waiting', write_back_proof)
        power_proof = MASS_DRIVER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        self.assertNotIn('frame["link"]', power_proof)

    def test_reference_graph_and_actual_c07_mass_driver_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'reload_counter_decays',
            'idle_accepts_waiting_shooter',
            'shooting_registers_on_link',
            'fire_transfers_items_and_resets_reload',
            'no_fire_without_alignment',
            'live_tick_writes_advance_frame_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
