import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_HEAL_APPLICATION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorHealApplicationProof.gd'
REGEN_PROJECTOR_HEAL_APPLICATION_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorHealApplicationProof.tscn'


class C07RegenProjectorHealApplicationTests(unittest.TestCase):
    def test_c07_regen_projector_heal_application_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2399']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_heal_application_state')
        # N2325 reported the mendMap flush as the pure
        # heal_applications result {pos: amount} and cleared
        # mend_map, but the tick applied nothing to the target
        # buildings. N2399 is the live application: the tick
        # applies each flushed {pos: amount} AFTER the flush
        # (RegenProjector.java:168-177 -- `var build =
        # world.build(entry.key);` / `if(build != null){` /
        # `build.heal(entry.value);` /
        # `build.recentlyHealed();`). Verified before coding:
        # (a) pos is the packed ORIGIN cell -- the N2277 fill
        # packs it with tile_pos_state (Tile.pos() is
        # `return Point2.pack(x, y);`, Tile.java:73-75, and
        # build.pos() is `return tile.pos();`,
        # BuildingComp.java:578-580) -- decoded with
        # Point2.unpack (`return new Point2((short)(pos >>>
        # 16), (short)(pos & 0xFFFF));`, arc
        # Point2.java:35-37); (b) the cell resolves to its
        # sprite through block_sprite_at_cell (the N2353/N2371
        # helper precedent); (c) NO family frame carries
        # health -- the target's health lives on the sprite
        # metas source_block_health / source_block_max_health,
        # so the helper repairs the sprite meta directly
        # (walls and cores heal through the same path, like
        # Java healing ANY building); a target with no sprite
        # reports no_sprite, the Java `build == null` skip
        # (World.build(int pos) returns null for a missing
        # tile/build, World.java:142-146); (d) heal() caps at
        # maxHealth -- HealthComp.heal is `health += amount;`
        # + clampHealth `health = Math.min(health,
        # maxHealth);` (HealthComp.java:103-112), and the
        # shared repair_sprite is that exact cap; (e) NO time
        # input reaches the tick (the tick gets game +
        # seconds, a delta, and the port exposes no live
        # Time.time), so recentlyHealed() DEFERS -- the
        # result carries recently_healed false and no
        # last_heal_time is stamped anywhere. Four new result
        # symbols: applications, applied_count, skipped_count,
        # recently_healed; a new input + result schema and a
        # new contract for the helper, so this slice adds
        # +4/+1/+1/+2.
        self.assertEqual(
            ledger['N2399']['source_symbols'],
            [
                'source_regen_projector_heal_application_state_result.applications',
                'source_regen_projector_heal_application_state_result.applied_count',
                'source_regen_projector_heal_application_state_result.skipped_count',
                'source_regen_projector_heal_application_state_result.recently_healed',
            ],
        )
        for name in ledger['N2399']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/RegenProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_heal_application_state')
        self.assertEqual(ledger['N2399']['runtime_proof'], '/root/C07RegenProjectorHealApplicationProof')
        self.assertEqual(
            ledger['N2399']['tests'],
            [
                'test_c07_regen_projector_heal_application_registration',
                'test_all_c07_regen_projector_heal_application_input_evidence_is_exact',
                'test_regen_projector_heal_application_state',
                'test_reference_graph_and_actual_c07_regen_projector_heal_application',
            ],
        )
        self.assertTrue(ledger['N2399']['deferred_exprs'])
        # DEFERRED #274 (1-based, DEFERRED-after-advances-21.py)
        # resolves: the live heal application entry is gone.
        # The updateTile live-fill entry is REWRITTEN in place
        # (it cannot be deleted: the effect chance, the
        # suppression live fill and the disabled early return
        # still wait) to record the application as live, and
        # two new deferrals join: the recentlyHealed()
        # timestamp (no Time.time input reaches the tick) and
        # the frame targets health snapshot refresh (the
        # healed target's snapshot stays stale until the next
        # tile_changes scan).
        self.assertFalse(any(entry.startswith('RegenProjector mendMap flush live heal application (') for entry in ledger['N2399']['deferred_exprs']))
        live_fill = [entry for entry in ledger['N2399']['deferred_exprs'] if entry.startswith('RegenProjector updateTile live fill (')]
        self.assertEqual(len(live_fill), 1)
        self.assertIn('the live heal application to the target buildings is live since N2399', live_fill[0])
        self.assertTrue(any(entry.startswith('RegenProjector mendMap flush recentlyHealed() timestamp (') for entry in ledger['N2399']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector frame targets health snapshot refresh (') for entry in ledger['N2399']['deferred_exprs']))

    def test_all_c07_regen_projector_heal_application_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2399']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_heal_application_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/RegenProjector.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/HealthComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/core/World.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Tile.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Point2.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2399']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_heal_application_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The live heal application (RegenProjectorBuild.
        # updateTile(), RegenProjector.java:168-177): the
        # flush loop `for(var entry : mendMap.entries()){` /
        # `var build = world.build(entry.key);` / `if(build !=
        # null){` / `build.heal(entry.value);` /
        # `build.recentlyHealed();` / `mendMap.clear();`.
        # world.build(pos) is `public @Nullable Building
        # build(int pos){` with `if(tile == null) return
        # null;` (World.java:142-146) -- a missing target is
        # skipped, never healed. heal() is HealthComp.heal
        # (`health += amount;` + clampHealth `health =
        # Math.min(health, maxHealth);`,
        # HealthComp.java:103-112), capped at maxHealth.
        # recentlyHealed() is the timestamp write
        # `lastHealTime = Time.time;`
        # (BuildingComp.java:491-493) -- it DEFERS (no
        # Time.time input reaches the tick), so the helper
        # reports recently_healed false and stamps nothing.
        # pos decodes with Point2.unpack (`return new
        # Point2((short)(pos >>> 16), (short)(pos &
        # 0xFFFF));`, arc Point2.java:35-37); the pack side is
        # `return (((short)x) << 16) | (((short)y) &
        # 0xFFFF);` (arc Point2.java:40-42), reached through
        # Tile.pos() (`return Point2.pack(x, y);`,
        # Tile.java:73-75) and build.pos() (`return
        # tile.pos();`, BuildingComp.java:578-580). Keep each
        # Java expr on ONE comment line (the N2148 lesson).
        self.assertIn('static func source_regen_projector_heal_application_state', regen_projector)
        self.assertIn('static func _point2_unpack', regen_projector)
        self.assertIn('static func _to_short', regen_projector)
        self.assertIn('for(var entry : mendMap.entries()){', regen_projector)
        self.assertIn('var build = world.build(entry.key);', regen_projector)
        self.assertIn('if(build != null){', regen_projector)
        self.assertIn('build.heal(entry.value);', regen_projector)
        self.assertIn('build.recentlyHealed();', regen_projector)
        self.assertIn('mendMap.clear();', regen_projector)
        self.assertIn('public @Nullable Building build(int pos){', regen_projector)
        self.assertIn('if(tile == null) return null;', regen_projector)
        self.assertIn('health += amount;', regen_projector)
        self.assertIn('health = Math.min(health, maxHealth);', regen_projector)
        self.assertIn('public void recentlyHealed(){', regen_projector)
        self.assertIn('lastHealTime = Time.time;', regen_projector)
        self.assertIn('return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));', regen_projector)
        self.assertIn('return (((short)x) << 16) | (((short)y) & 0xFFFF);', regen_projector)
        self.assertIn('return Point2.pack(x, y);', regen_projector)
        self.assertIn('return tile.pos();', regen_projector)
        # The helper resolves the target sprite through
        # block_sprite_at_cell (the N2353/N2371 precedent)
        # and heals the sprite health meta through the shared
        # repair_sprite (the exact HealthComp.heal cap -- no
        # family frame carries health, so there is no frame
        # lookup and no frame write-back). Every input pos
        # gets exactly one application entry {pos, cell,
        # amount, healed, reason}; the reasons cover every
        # exit: a resolved sprite heals, a missing sprite
        # reports no_sprite (the Java build == null skip),
        # and a non-positive amount reports invalid_amount.
        # The result also carries the applied / skipped
        # counts and the recently_healed flag (always false:
        # no Time.time input reaches the tick).
        self.assertIn('game.call("block_sprite_at_cell", target_cell)', regen_projector)
        self.assertIn('source_placed_block_state.repair_sprite(target_sprite, amount)', regen_projector)
        self.assertIn('_point2_unpack(', regen_projector)
        self.assertIn('"applications"', regen_projector)
        self.assertIn('"applied_count"', regen_projector)
        self.assertIn('"skipped_count"', regen_projector)
        self.assertIn('"recently_healed"', regen_projector)
        self.assertIn('"healed"', regen_projector)
        self.assertIn('"no_sprite"', regen_projector)
        self.assertIn('"invalid_amount"', regen_projector)
        self.assertIn('"cell"', regen_projector)
        # The driver wires the application into the live tick
        # AFTER the N2325 flush write-back (Java order: the
        # heal loop is the flush block itself,
        # RegenProjector.java:168-177, and the port applies
        # the flushed map the advance just reported): the
        # frame heal_applications write-back precedes the
        # helper call, and the helper result rides the frame
        # as heal_applied.
        self.assertIn('frame["heal_applications"] = advanced["heal_applications"]', regen_projector)
        self.assertIn('frame["heal_applied"] = source_regen_projector_heal_application_state(game, advanced["heal_applications"])', regen_projector)
        self.assertLess(
            regen_projector.index('frame["heal_applications"] = advanced["heal_applications"]'),
            regen_projector.index('frame["heal_applied"] = source_regen_projector_heal_application_state(game, advanced["heal_applications"])'),
        )
        # The documented limits now record the live heal
        # application as live (N2399) and the "applies
        # nothing" text is gone; the N2325 flush, N2228
        # advance, N2277 updateTargets and N2214
        # shouldConsume text stays.
        self.assertIn('live heal application is live (N2399)', regen_projector)
        self.assertNotIn('applies nothing', regen_projector)
        self.assertIn('mendMap flush is live (N2325)', regen_projector)
        self.assertIn('updateTile advance live (N2228)', regen_projector)
        self.assertIn('updateTargets live (N2277)', regen_projector)
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        # The proof's keys drive the helper directly (pos
        # decode to the right cell, the exact amount lands,
        # the cap at max health, a missing target reports
        # no_sprite, recentlyHealed defers without a time
        # input) plus the live tick (tick 1 flushes the
        # first-tick mend AND heals the wall in the same
        # tick; tick 2 accumulates again with no flush and
        # no application).
        proof = REGEN_PROJECTOR_HEAL_APPLICATION_PROOF.read_text(encoding='utf-8')
        for key in [
            'heal_application_decodes_pos_to_cell',
            'heal_application_applies_amount_to_target',
            'heal_application_caps_at_max_health',
            'heal_application_no_sprite_reports_no_sprite',
            'live_tick_applies_flush_after_advance',
            'recently_healed_deferred_without_time_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRegenProjectorBuildState.gd")', proof)
        self.assertIn('preload("res://src/game/SourcePlacedBlockState.gd")', proof)
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_heal_application_state(', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REGEN_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REGEN_PROJECTOR_HEAL_APPLICATION_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorHealApplicationProof.gd', scene)
        self.assertIn('C07RegenProjectorHealApplicationProof', scene)

    def test_reference_graph_and_actual_c07_regen_projector_heal_application(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorHealApplicationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_HEAL_APPLICATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'heal_application_decodes_pos_to_cell',
            'heal_application_applies_amount_to_target',
            'heal_application_caps_at_max_health',
            'heal_application_no_sprite_reports_no_sprite',
            'live_tick_applies_flush_after_advance',
            'recently_healed_deferred_without_time_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
