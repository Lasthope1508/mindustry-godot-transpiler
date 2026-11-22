import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponDrawProof.gd'


class C07WeaponDrawTests(unittest.TestCase):
    def test_c07_weapon_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2538']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_draw_state')
        # draw() is the Weapon draw read (Weapon.java:214-286):
        # `public void draw(Unit unit, WeaponMount mount){` /
        # `float z = Draw.z();` /
        # `Draw.z(z + layerOffset);` /
        # `rotation = unit.rotation - 90,` /
        # `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
        # `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
        # `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
        # `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
        # `if(shadow > 0){` / `Drawf.shadow(wx, wy, shadow);` /
        # `if(top){` / `drawOutline(unit, mount);` /
        # `if(parts.size > 0){` (per-part DrawPart drawing is a
        # later DrawPart subsystem slice) /
        # `Draw.xscl *= -Mathf.sign(flipSprite);` /
        # `if(region.found()) Draw.rect(region, wx, wy, weaponRotation);` /
        # `if(cellRegion.found()){` /
        # `if(heatRegion.found() && mount.heat > 0){` /
        # `Draw.z(z);` (render-state restore, not a return value).
        # draw() has NO early return (unlike drawOutline):
        # every branch returns all thirteen keys. The slice
        # mirrors into the type shard (java_source Weapon.java
        # contains "/type/"); comp stays 572/475.
        self.assertEqual(
            ledger['N2538']['source_symbols'],
            [
                'source_weapon_draw_state_result.rotation',
                'source_weapon_draw_state_result.real_recoil',
                'source_weapon_draw_state_result.weapon_rotation',
                'source_weapon_draw_state_result.wx',
                'source_weapon_draw_state_result.wy',
                'source_weapon_draw_state_result.xscl',
                'source_weapon_draw_state_result.z_draw',
                'source_weapon_draw_state_result.shadow_drawn',
                'source_weapon_draw_state_result.outline_called',
                'source_weapon_draw_state_result.has_parts',
                'source_weapon_draw_state_result.region_drawn',
                'source_weapon_draw_state_result.cell_drawn',
                'source_weapon_draw_state_result.heat_drawn',
            ],
        )
        for name in ledger['N2538']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_draw_state')
        self.assertEqual(ledger['N2538']['runtime_proof'], '/root/C07WeaponDrawProof')
        self.assertEqual(
            ledger['N2538']['tests'],
            [
                'test_c07_weapon_draw_registration',
                'test_all_c07_weapon_draw_input_evidence_is_exact',
                'test_weapon_draw_state',
                'test_reference_graph_and_actual_c07_weapon_draw',
            ],
        )
        self.assertTrue(ledger['N2538']['deferred_exprs'])

    def test_all_c07_weapon_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2538']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_draw_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/units/WeaponMount.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2538']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_draw_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # draw() (Weapon.java:214-286) for the Weapon family as
        # one pure function, in exact Java order: z / layerOffset
        # first, then rotation / realRecoil / weaponRotation /
        # wx / wy, then the shadow / top / parts / region / cell /
        # heat branches, then the z restore (render-state
        # restore, not a return value). The function returns all
        # thirteen keys on every call -- draw() has no early
        # return. NO driver tick call site (the N2528/N2529/
        # N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537
        # precedent): draw() is draw code, rendering is outside
        # the game, and no caller reads it today.
        signature = 'static func source_weapon_draw_state(z: float, unit_rotation: float, unit_x: float, unit_y: float, mount_recoil: float, mount_rotation: float, rotate: bool, base_rotation: float, recoil: float, recoil_pow: float, weapon_x: float, weapon_y: float, flip_sprite: bool, shadow: float, top: bool, region_found: bool, cell_region_found: bool, heat_region_found: bool, mount_heat: float, layer_offset: float, parts_count: int) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('return {"rotation": rotation, "real_recoil": real_recoil, "weapon_rotation": weapon_rotation, "wx": wx, "wy": wy, "xscl": xscl, "z_draw": z_draw, "shadow_drawn": shadow_drawn, "outline_called": outline_called, "has_parts": has_parts, "region_drawn": region_drawn, "cell_drawn": cell_drawn, "heat_drawn": heat_drawn}', core)
        self.assertIn('public void draw(Unit unit, WeaponMount mount){', core)
        self.assertIn('float z = Draw.z();', core)
        self.assertIn('Draw.z(z + layerOffset);', core)
        self.assertIn('rotation = unit.rotation - 90,', core)
        self.assertIn('realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,', core)
        self.assertIn('weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),', core)
        self.assertIn('wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),', core)
        self.assertIn('wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);', core)
        self.assertIn('if(shadow > 0){', core)
        self.assertIn('Drawf.shadow(wx, wy, shadow);', core)
        self.assertIn('if(top){', core)
        self.assertIn('drawOutline(unit, mount);', core)
        self.assertIn('if(parts.size > 0){', core)
        self.assertIn('Draw.xscl *= -Mathf.sign(flipSprite);', core)
        self.assertIn('if(region.found()) Draw.rect(region, wx, wy, weaponRotation);', core)
        self.assertIn('if(cellRegion.found()){', core)
        self.assertIn('if(heatRegion.found() && mount.heat > 0){', core)
        self.assertIn('Draw.z(z);', core)
        self.assertIn('DORMANT', core)
        # The trns legs reuse the existing port (no scalar
        # trnsx/trnsy port exists): source_angles_trns_vec
        # (SourceMathState.gd:140) computes exactly
        # Angles.trnsx/trnsy(angle, x, y) (arc Angles.java:74-82).
        self.assertIn('source_angles_trns_vec(rotation, weapon_x, weapon_y)', core)
        self.assertIn('source_angles_trns_vec(weapon_rotation, 0.0, -real_recoil)', core)
        # xscl is -Mathf.sign(flipSprite); arc Mathf.sign(boolean)
        # (Mathf.java:203-205) is 1 if true else -1, so xscl is
        # -1.0 when flip_sprite is true, +1.0 otherwise.
        self.assertIn('var xscl: float = -1.0 if flip_sprite else 1.0', core)
        # z_draw is z + layerOffset (Weapon.java:214-215).
        self.assertIn('var z_draw: float = z + layer_offset', core)
        # shadow_drawn is shadow > 0 (Weapon.java:224);
        # outline_called is top (Weapon.java:228-229);
        # has_parts is parts_count > 0 (Weapon.java:232);
        # region_drawn is region_found (Weapon.java:253);
        # cell_drawn is cell_region_found (Weapon.java:255);
        # heat_drawn is heat_region_found AND mount_heat > 0
        # (Weapon.java:261).
        self.assertIn('var shadow_drawn: bool = shadow > 0.0', core)
        self.assertIn('var outline_called: bool = top', core)
        self.assertIn('var has_parts: bool = parts_count > 0', core)
        self.assertIn('var region_drawn: bool = region_found', core)
        self.assertIn('var cell_drawn: bool = cell_region_found', core)
        self.assertIn('var heat_drawn: bool = heat_region_found and mount_heat > 0.0', core)
        # The canonical function sits immediately AFTER
        # source_weapon_draw_outline_state (the N2537 function)
        # and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_draw_outline_state('), core.index('static func source_weapon_draw_state('))
        self.assertLess(core.index('static func source_weapon_draw_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_draw_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_draw_state(z, unit_rotation, unit_x, unit_y, mount_recoil, mount_rotation, rotate, base_rotation, recoil, recoil_pow, weapon_x, weapon_y, flip_sprite, shadow, top, region_found, cell_region_found, heat_region_found, mount_heat, layer_offset, parts_count)', facade)
        self.assertEqual(facade.count('source_weapon_draw_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (all with Java defaults unless
        # noted: z 0, unit_rotation 90, unit 0,0, mount_recoil 0,
        # mount_rotation 0, rotate false, base_rotation 0,
        # recoil 1.5, recoil_pow 1.8, weapon x 5, y 0,
        # flip_sprite false, shadow -1, top true, region_found
        # true, cell_region_found false, heat_region_found
        # false, mount_heat 0, layer_offset 0, parts_count 0):
        # 1 Java defaults -> rotation 0.0, real_recoil 0.0,
        # weapon_rotation 0.0, wx 5.0, wy 0.0, xscl 1.0,
        # z_draw 0.0, shadow_drawn false, outline_called true,
        # has_parts false, region_drawn true, cell_drawn false,
        # heat_drawn false; 2 shadow 10 -> shadow_drawn true;
        # 3 top false -> outline_called false; 4 region not
        # found -> region_drawn false; 5 cell_region_found true
        # -> cell_drawn true; 6 heat_region_found true,
        # mount_heat 0 -> heat_drawn false; 7
        # heat_region_found true, mount_heat 0.5 ->
        # heat_drawn true; 8 unit_rotation 180 -> rotation
        # 90.0, wx 0.0, wy 5.0, weapon_rotation 90.0.
        proof = WEAPON_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_java_defaults',
            'draw_shadow',
            'draw_top_false',
            'draw_region_not_found',
            'draw_cell',
            'draw_heat_zero',
            'draw_heat_positive',
            'draw_unit_rot_180',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_java_defaults',
            'draw_shadow',
            'draw_top_false',
            'draw_region_not_found',
            'draw_cell',
            'draw_heat_zero',
            'draw_heat_positive',
            'draw_unit_rot_180',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
