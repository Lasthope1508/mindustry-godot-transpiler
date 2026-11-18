import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_SETSTATS_ICONS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretSetStatsIconsProof.gd'


class C07PointDefenseTurretSetStatsIconsTests(unittest.TestCase):
    def test_c07_point_defense_turret_setstats_icons_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2246']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_set_stats_state')
        # N2240-N2245 made the point-defense turret live (aim +
        # shoot, shouldConsume, live bullets, team stamp, draw,
        # write/read) -- but the class-level display rows had
        # no slice: PointDefenseTurret overrides setStats()
        # (PointDefenseTurret.java:51-57, `public void
        # setStats(){`), adding two unconditional stat rows
        # (`stats.add(Stat.reload, 60f / reload,
        # StatUnit.perSecond);` -- PointDefenseTurret.java:55
        # -- and `stats.add(Stat.damage, bulletDamage,
        # StatUnit.none);` -- PointDefenseTurret.java:56),
        # and overrides icons()
        # (PointDefenseTurret.java:46-49, `@Override public
        # TextureRegion[] icons(){`), returning the two
        # loaded regions in order (`return new
        # TextureRegion[]{baseRegion, region};` --
        # PointDefenseTurret.java:48). baseRegion is the
        # block's own base field (`public @Load(value =
        # "@-base", fallback = "block-@size") TextureRegion
        # baseRegion;` -- PointDefenseTurret.java:24) and
        # region is the inherited block region (`public
        # TextureRegion region;` -- Block.java:427).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) Two pure functions on the
        # same family file N2240-N2245 built:
        # source_point_defense_turret_set_stats_state(reload,
        # bullet_damage) returning reload_per_second (60f /
        # reload) and damage (bulletDamage);
        # source_point_defense_turret_icons_state(base_region,
        # region) returning icons ([base_region, region]).
        # Both setStats params are explicit floats (the N2224
        # RepairTurret setStats per-def-param precedent --
        # reload and bulletDamage are per-def static state,
        # not live frame keys: class defaults reload 30f /
        # bulletDamage 10f, PointDefenseTurret.java:40, :33;
        # the one def, segment, reload 8f / bulletDamage 30f,
        # Blocks.java:3845, :3844); both icons params are
        # explicit Variants (the N2227 RepairTurret icons
        # precedent: TextureRegion values ride as Variants;
        # the proof passes string region ids, as the N2227
        # proof did with ["repair-point-base",
        # "repair-point"]). (2) There is NO driver tick line:
        # setStats/icons are load-time/display reads, not
        # per-tick writes (the N2224 setStats + N2227 icons
        # lifecycle precedent); the proof calls the pure
        # functions directly with per-def params. (3) The
        # `super.setStats();` leg
        # (PointDefenseTurret.java:53) is NOT this slice: the
        # base stats come from the ReloadTurret.setStats()
        # booster replace (ReloadTurret.java:17-23,
        # `if(coolant != null){` / `stats.replace(
        # Stat.booster, StatValues.boosters(reload,
        # coolant.amount, coolantMultiplier, true,
        # coolant::consumes));`) -- a no-op for segment,
        # which defines NO coolant consumer
        # (Blocks.java:3835-3845, the N2241 precedent) --
        # plus the BaseTurret shootRange row
        # (`stats.add(Stat.shootRange, range / tilesize,
        # StatUnit.blocks);`, BaseTurret.java:96) and the
        # Block base rows (N1696); only the two
        # PointDefenseTurret-own rows are pinned here. (4)
        # The Block.icons() base (`protected TextureRegion[]
        # icons(){`, Block.java:976-980, the
        # variants/teamRegion fold) is NOT this slice:
        # PointDefenseTurret overrides it, so only the
        # override's return array is pinned; the
        # getGeneratedIcons cache (`public TextureRegion[]
        # getGeneratedIcons(){`, Block.java:986, `return
        # generatedIcons == null ? (generatedIcons =
        # icons()) : generatedIcons;`, Block.java:987) is
        # likewise deferred -- only the override's
        # two-element array, base first (the N1232
        # TractorBeamTurret.icons() precedent). (5) The one
        # def, segment, is the only PointDefenseTurret def
        # (Blocks.java:3835-3845), so one set of functions
        # covers it. Three new result symbols:
        # reload_per_second, damage, icons.
        self.assertEqual(
            ledger['N2246']['source_symbols'],
            [
                'source_point_defense_turret_set_stats_state_result.reload_per_second',
                'source_point_defense_turret_set_stats_state_result.damage',
                'source_point_defense_turret_icons_state_result.icons',
            ],
        )
        for name in ledger['N2246']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2246']['runtime_proof'], '/root/C07PointDefenseTurretSetStatsIconsProof')
        self.assertEqual(
            ledger['N2246']['tests'],
            [
                'test_c07_point_defense_turret_setstats_icons_registration',
                'test_all_c07_point_defense_turret_setstats_icons_input_evidence_is_exact',
                'test_point_defense_turret_setstats_icons_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_setstats_icons',
            ],
        )
        self.assertTrue(ledger['N2246']['deferred_exprs'])

    def test_all_c07_point_defense_turret_setstats_icons_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2246']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2246']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_setstats_icons_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # PointDefenseTurret.setStats()
        # (PointDefenseTurret.java:51-57, `public void
        # setStats(){`): `super.setStats();` (:53) is the
        # ReloadTurret / BaseTurret / Block base-stat chain,
        # NOT this slice (the N2224 precedent); this slice
        # owns the two unconditional rows
        # (`stats.add(Stat.reload, 60f / reload,
        # StatUnit.perSecond);` -- :55 -- and
        # `stats.add(Stat.damage, bulletDamage,
        # StatUnit.none);` -- :56). Both params are explicit
        # per-def floats (the N2224 precedent): class
        # defaults reload 30f / bulletDamage 10f
        # (PointDefenseTurret.java:40, :33); segment reload
        # 8f / bulletDamage 30f (Blocks.java:3845, :3844).
        # The ReloadTurret booster replace
        # (`if(coolant != null){` -- ReloadTurret.java:20 --
        # `stats.replace(Stat.booster,
        # StatValues.boosters(reload, coolant.amount,
        # coolantMultiplier, true, coolant::consumes));` --
        # :21) is a no-op for segment, which defines NO
        # coolant consumer (Blocks.java:3835-3845, the N2241
        # precedent); the BaseTurret shootRange row
        # (`stats.add(Stat.shootRange, range / tilesize,
        # StatUnit.blocks);`, BaseTurret.java:96) is likewise
        # the super chain, not this slice.
        # PointDefenseTurret.icons()
        # (PointDefenseTurret.java:46-49, `@Override public
        # TextureRegion[] icons(){`): `return new
        # TextureRegion[]{baseRegion, region};` (:48) pins
        # the two-element array, base first. baseRegion is
        # the block's own base field (`public @Load(value =
        # "@-base", fallback = "block-@size") TextureRegion
        # baseRegion;`, PointDefenseTurret.java:24); region
        # is the inherited block region (`public
        # TextureRegion region;`, Block.java:427). The
        # Block.icons() base (`protected TextureRegion[]
        # icons(){`, Block.java:976-980) and the
        # getGeneratedIcons cache (Block.java:986-987) are
        # deferred -- only the override's return array is
        # pinned (the N1232 precedent). There is NO driver
        # tick line: setStats/icons are load-time/display
        # reads, not per-tick writes (the N2224 / N2227
        # lifecycle precedent).
        self.assertIn('static func source_point_defense_turret_set_stats_state(reload: float, bullet_damage: float) -> Dictionary:', point_defense)
        self.assertIn('return {"reload_per_second": reload_per_second, "damage": damage}', point_defense)
        self.assertIn('static func source_point_defense_turret_icons_state(base_region: Variant, region: Variant) -> Dictionary:', point_defense)
        self.assertIn('return {"icons": icons}', point_defense)
        for expr in [
            'public TextureRegion[] icons(){',
            'return new TextureRegion[]{baseRegion, region};',
            'public void setStats(){',
            'super.setStats();',
            'stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);',
            'stats.add(Stat.damage, bulletDamage, StatUnit.none);',
            'public float bulletDamage = 10f;',
            'reload = 30f;',
            'public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;',
            'public TextureRegion region;',
            'protected TextureRegion[] icons(){',
            'public TextureRegion[] getGeneratedIcons(){',
            'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;',
            'public class PointDefenseTurret extends ReloadTurret{',
            'segment = new PointDefenseTurret("segment"){{',
            'bulletDamage = 30f;',
            'reload = 8f;',
            'if(coolant != null){',
            'stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));',
            'stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, point_defense)
        # The proof's keys drive the pure functions directly
        # with per-def params (no live tick: setStats/icons
        # are display reads): reload-per-second + damage at
        # the class default (60/30 = 2.0, 10.0) and the
        # segment def (60/8 = 7.5, 30.0), the two-row result
        # shape, and the segment icons array
        # ("segment-base", "segment") -- baseRegion loads
        # "@-base" (name + "-base"), region is the block's
        # own region (the block name); Blocks.java:3835.
        proof = POINT_DEFENSE_SETSTATS_ICONS_PROOF.read_text(encoding='utf-8')
        for key in [
            'set_stats_reload_per_second_default',
            'set_stats_reload_per_second_segment',
            'set_stats_damage_default',
            'set_stats_damage_segment',
            'set_stats_returns_only_two_rows',
            'icons_segment',
            'icons_length_two',
            'icons_base_first',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_setstats_icons(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretSetStatsIconsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_SET_STATS_ICONS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'set_stats_reload_per_second_default',
            'set_stats_reload_per_second_segment',
            'set_stats_damage_default',
            'set_stats_damage_segment',
            'set_stats_returns_only_two_rows',
            'icons_segment',
            'icons_length_two',
            'icons_base_first',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
