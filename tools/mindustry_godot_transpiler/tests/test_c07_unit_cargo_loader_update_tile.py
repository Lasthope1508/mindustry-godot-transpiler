import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderUpdateTileProof.gd'
UNIT_CARGO_LOADER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderUpdateTileProof.tscn'


class C07UnitCargoLoaderUpdateTileTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2234']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_update_tile_advance_state')
        # N2165 proved the unit-cargo-loader family's live power
        # read and N2211 the shouldConsume gate (return unit ==
        # null, INVERTED, no enabled term) -- but the port
        # tracked no readUnitId / buildProgress / totalProgress
        # / warmup / readyness at all, so a unit-cargo-loader
        # never advanced its build, never warmed up, and the
        # unit key only ever changed when a test seeded it.
        # N2234 is the updateTile advance
        # (UnitTransportSourceBuild.updateTile(),
        # UnitCargoLoader.java:92-125): the unit lost/destroyed
        # clear (UnitCargoLoader.java:94-96), the readUnitId
        # unbox (UnitCargoLoader.java:98-103, the live
        # Groups.unit.getByID query arriving as the explicit
        # found_unit param), the warmup / readyness
        # approachDelta folds (UnitCargoLoader.java:105-106),
        # the canCreate-gated build advance
        # (UnitCargoLoader.java:108-110, can_create an explicit
        # param, default true) and the spawn at build complete
        # (UnitCargoLoader.java:112-122, reported as the pure
        # result spawned_unit with buildProgress reset to 0f
        # via spawned(), UnitCargoLoader.java:127-133). The
        # port is single-player (net_client defaults false
        # everywhere -- SourceBuildingPayloadState.gd:115,
        # SourcePuddlesDepositState.gd:11 -- and no net layer
        # exists in godot-mindustry/src), so the advance always
        # takes the !net.client() branch: a null found_unit
        # still clears readUnitId, and the spawn takes the
        # server branch (unit created at once, buildProgress
        # 0f; the client branch readUnitId = id never applies).
        # Seven new result symbols.
        self.assertEqual(
            ledger['N2234']['source_symbols'],
            [
                'source_unit_cargo_loader_update_tile_advance_state_result.unit',
                'source_unit_cargo_loader_update_tile_advance_state_result.read_unit_id',
                'source_unit_cargo_loader_update_tile_advance_state_result.warmup',
                'source_unit_cargo_loader_update_tile_advance_state_result.readyness',
                'source_unit_cargo_loader_update_tile_advance_state_result.build_progress',
                'source_unit_cargo_loader_update_tile_advance_state_result.total_progress',
                'source_unit_cargo_loader_update_tile_advance_state_result.spawned_unit',
            ],
        )
        for name in ledger['N2234']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java')
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_update_tile_advance_state')
        self.assertEqual(ledger['N2234']['runtime_proof'], '/root/C07UnitCargoLoaderUpdateTileProof')
        self.assertEqual(
            ledger['N2234']['tests'],
            [
                'test_c07_unit_cargo_loader_update_tile_registration',
                'test_all_c07_unit_cargo_loader_update_tile_input_evidence_is_exact',
                'test_unit_cargo_loader_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_update_tile',
            ],
        )
        self.assertTrue(ledger['N2234']['deferred_exprs'])
        # This slice resolves the N2165 updateTile advance
        # deferral, so the advance entry is gone from DEFERRED
        # -- and the unit spawn rows entry goes too (the pure
        # spawn lands here: spawned_unit + the buildProgress
        # reset + the frame unit), as does the old live unit
        # fill entry (it claimed the spawn / unbox "wait for
        # the updateTile advance slice" -- that slice is this
        # one -- and that "no live fill sets frame[unit] yet",
        # which the advance now does from found_unit and from
        # the spawn). The new live-fill entry (getByID live
        # query + live spawn application + disabled early
        # return) and the new live canCreate entry take their
        # place. The liquid nitrogen row stays: the second
        # consumer is still not modeled.
        self.assertFalse(any(entry.startswith('UnitCargoLoader updateTile advance (') for entry in ledger['N2234']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('UnitCargoLoader unit spawn rows (') for entry in ledger['N2234']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('UnitCargoLoader live unit fill (') for entry in ledger['N2234']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader updateTile live unit fill (') for entry in ledger['N2234']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader updateTile live canCreate check (') for entry in ledger['N2234']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader liquid consumer row (') for entry in ledger['N2234']['deferred_exprs']))

    def test_all_c07_unit_cargo_loader_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2234']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2234']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_update_tile_advance_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the unit-cargo-loader build
        # state: the unit lost/destroyed clear
        # (UnitCargoLoader.java:94-96), the readUnitId unbox
        # (UnitCargoLoader.java:98-103), the warmup / readyness
        # approachDelta folds (UnitCargoLoader.java:105-106),
        # the canCreate-gated build advance
        # (UnitCargoLoader.java:108-110), the spawn at build
        # complete (UnitCargoLoader.java:112-122) and the
        # buildProgress reset via spawned()
        # (UnitCargoLoader.java:127-133). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). Cite corrections (all
        # verified by grep at this pin -- the scope brief drifts
        # on the field lines): the build class is
        # `public class UnitTransportSourceBuild extends Building
        # implements UnitTetherBlock{` at :84 (not :85),
        # readUnitId is :86, buildProgress/totalProgress :87,
        # warmup/readyness :88, unit :89; updateTile is 92-125,
        # spawned is 127-133, shouldConsume is 141-142. The Arc
        # formula is approachDelta(from, to, speed) =
        # approach(from, to, Time.delta * speed) with approach =
        # from + clamp(to - from, -speed, speed)
        # (Mathf.java:208, 415-427), via the shared
        # source_math_state.source_approach_delta helper.
        # Time.delta in the port is seconds * 60 through
        # game_source_delta (arc Time.java:26), never raw
        # seconds (the N2186/N2187/N2191 lesson: raw seconds
        # run 60x slow). edelta() = efficiency * delta() with
        # delta() = Time.delta * timeScale
        # (BuildingComp.java:1922-1929). The unit dict contract:
        # {type, x, y, rotation, dead (default false), added
        # (default true)}; a non-dict unit has no readable flags
        # and is kept (defensive -- the gate only reads
        # null-ness, so the N2211 {"type": "dart"} fixture keeps
        # working). net.client() is always false in the port
        # (single-player: net_client defaults false everywhere
        # and no net layer exists in godot-mindustry/src), so
        # the advance always takes the !net.client() branch.
        self.assertIn('static func source_unit_cargo_loader_update_tile_advance_state', unit_cargo_loader)
        self.assertIn('if(unit != null && (unit.dead || !unit.isAdded())){', unit_cargo_loader)
        self.assertIn('unit = null;', unit_cargo_loader)
        self.assertIn('if(readUnitId != -1){', unit_cargo_loader)
        self.assertIn('unit = Groups.unit.getByID(readUnitId);', unit_cargo_loader)
        self.assertIn('if(unit != null || !net.client()){', unit_cargo_loader)
        self.assertIn('readUnitId = -1;', unit_cargo_loader)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);', unit_cargo_loader)
        self.assertIn('readyness = Mathf.approachDelta(readyness, unit != null ? 1f : 0f, 1f / 60f);', unit_cargo_loader)
        self.assertIn('if(unit == null && Units.canCreate(team, unitType)){', unit_cargo_loader)
        self.assertIn('buildProgress += edelta() / unitBuildTime;', unit_cargo_loader)
        self.assertIn('totalProgress += edelta();', unit_cargo_loader)
        self.assertIn('if(buildProgress >= 1f){', unit_cargo_loader)
        self.assertIn('if(!net.client()){', unit_cargo_loader)
        self.assertIn('unit = unitType.create(team);', unit_cargo_loader)
        self.assertIn('if(unit instanceof BuildingTetherc bt){', unit_cargo_loader)
        self.assertIn('bt.building(this);', unit_cargo_loader)
        self.assertIn('unit.set(x, y);', unit_cargo_loader)
        self.assertIn('unit.rotation = 90f;', unit_cargo_loader)
        self.assertIn('unit.add();', unit_cargo_loader)
        self.assertIn('Call.unitTetherBlockSpawned(tile, unit.id);', unit_cargo_loader)
        self.assertIn('public void spawned(int id){', unit_cargo_loader)
        self.assertIn('Fx.spawn.at(x, y);', unit_cargo_loader)
        self.assertIn('buildProgress = 0f;', unit_cargo_loader)
        self.assertIn('if(net.client()){', unit_cargo_loader)
        self.assertIn('readUnitId = id;', unit_cargo_loader)
        self.assertIn('public int readUnitId = -1;', unit_cargo_loader)
        self.assertIn('public float buildProgress, totalProgress;', unit_cargo_loader)
        self.assertIn('public float warmup, readyness;', unit_cargo_loader)
        self.assertIn('public @Nullable Unit unit;', unit_cargo_loader)
        self.assertIn('public UnitType unitType = UnitTypes.manifold;', unit_cargo_loader)
        self.assertIn('public float unitBuildTime = 60f * 8f;', unit_cargo_loader)
        self.assertIn('public class UnitTransportSourceBuild extends Building implements UnitTetherBlock{', unit_cargo_loader)
        self.assertIn('public class UnitCargoLoader extends Block{', unit_cargo_loader)
        self.assertIn('public static boolean canCreate(Team team, UnitType type){', unit_cargo_loader)
        self.assertIn('return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());', unit_cargo_loader)
        self.assertIn('useUnitCap = true,', unit_cargo_loader)
        self.assertIn('unitBuildTime = 60f * 8f;', unit_cargo_loader)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 10f / 60f);', unit_cargo_loader)
        # The def values are driver constants (single def --
        # unit-cargo-loader): the warmup/readyness approach
        # speed 1f/60f (UnitCargoLoader.java:105-106), the unit
        # build time 60f * 8f = 480f (UnitCargoLoader.java:25,
        # restated by the def, Blocks.java:2273), the unit type
        # manifold (UnitCargoLoader.java:24, the def does NOT
        # override it) and the spawn rotation 90f
        # (UnitCargoLoader.java:119).
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_WARMUP_SPEED := 1.0 / 60.0', unit_cargo_loader)
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_UNIT_BUILD_TIME := 480.0', unit_cargo_loader)
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_UNIT_TYPE := "manifold"', unit_cargo_loader)
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_SPAWN_ROTATION := 90.0', unit_cargo_loader)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption, like Java's Building.update()
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing. The driver passes found_unit null (no live
        # Groups.unit fill yet) and evaluates can_create live
        # since N2322 (source_unit_cargo_loader_can_create_state,
        # from the frame can_create_inputs dict, permissive true
        # when unstamped -- the live unit-count source still
        # defers).
        self.assertIn('game_source_delta(game, seconds)', unit_cargo_loader)
        self.assertIn('time_scale(sprite', unit_cargo_loader)
        self.assertIn('source_unit_cargo_loader_update_tile_advance_state(frame, source_delta, time_scale, null, bool(can_create_state.get("can_create", true)))', unit_cargo_loader)
        self.assertIn('frame["unit"]', unit_cargo_loader)
        self.assertIn('frame["read_unit_id"]', unit_cargo_loader)
        self.assertIn('frame["warmup"]', unit_cargo_loader)
        self.assertIn('frame["readyness"]', unit_cargo_loader)
        self.assertIn('frame["build_progress"]', unit_cargo_loader)
        self.assertIn('frame["total_progress"]', unit_cargo_loader)
        self.assertIn('frame["spawned_unit"]', unit_cargo_loader)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', unit_cargo_loader)
        # The deferred live fills arrive as explicit params
        # with Java-faithful defaults: no found unit means the
        # getByID query found nothing, and can_create defaults
        # true (the live cap check waits for the N2140 helper
        # wiring). The frame inputs read through .get defaults
        # matching the Java field defaults.
        self.assertIn('found_unit: Variant = null', unit_cargo_loader)
        self.assertIn('can_create: bool = true', unit_cargo_loader)
        self.assertIn('frame.get("unit", null)', unit_cargo_loader)
        self.assertIn('frame.get("read_unit_id", -1)', unit_cargo_loader)
        self.assertIn('frame.get("build_progress", 0.0)', unit_cargo_loader)
        self.assertIn('frame.get("total_progress", 0.0)', unit_cargo_loader)
        self.assertIn('frame.get("warmup", 0.0)', unit_cargo_loader)
        self.assertIn('frame.get("readyness", 0.0)', unit_cargo_loader)
        self.assertIn('frame.get("efficiency", 0.0)', unit_cargo_loader)
        self.assertIn('frame.get("x", 0.0)', unit_cargo_loader)
        self.assertIn('frame.get("y", 0.0)', unit_cargo_loader)
        # The fresh frame binds the new state keys with the Java
        # field defaults.
        self.assertIn('"unit": null', unit_cargo_loader)
        self.assertIn('"read_unit_id": -1', unit_cargo_loader)
        self.assertIn('"build_progress": 0.0', unit_cargo_loader)
        self.assertIn('"total_progress": 0.0', unit_cargo_loader)
        self.assertIn('"warmup": 0.0', unit_cargo_loader)
        self.assertIn('"readyness": 0.0', unit_cargo_loader)
        # The documented limits now record the advance as done
        # and the remaining deferrals (getByID live query,
        # canCreate live check, live spawn application, the
        # nitrogen second consumer, the disabled early return);
        # the shouldConsume gate stays live (N2211) and the
        # N2165 power row is preserved.
        self.assertIn('updateTile advance live (N2234)', unit_cargo_loader)
        self.assertNotIn('No updateTile advance', unit_cargo_loader)
        self.assertNotIn('No unit spawn rows', unit_cargo_loader)
        self.assertIn('shouldConsume gate live (N2211)', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_power_status_row_state', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_should_consume_state', unit_cargo_loader)
        # The proof's keys drive the pure advance (the lost-unit
        # clear, the warmup approach toward efficiency, the
        # build advance when empty -- including no build when a
        # unit is present, when can_create is false, and the
        # readUnitId unbox -- the spawn at build complete with
        # the buildProgress reset, the readyness fold over unit
        # presence) plus the live tick (fresh-frame defaults +
        # a placed unit-cargo-loader advancing warmup /
        # build_progress / total_progress on a 1/60s tick,
        # efficiency still folding power.status).
        proof = UNIT_CARGO_LOADER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'lost_unit_clears',
            'warmup_approaches_efficiency',
            'build_progress_advances_when_empty',
            'spawn_at_build_complete',
            'readyness_folds_unit_presence',
            'live_tick_advances_cargo_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_CARGO_LOADER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitCargoLoaderUpdateTileProof.gd', scene)
        self.assertIn('C07UnitCargoLoaderUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_unit_cargo_loader_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'lost_unit_clears',
            'warmup_approaches_efficiency',
            'build_progress_advances_when_empty',
            'spawn_at_build_complete',
            'readyness_folds_unit_presence',
            'live_tick_advances_cargo_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
