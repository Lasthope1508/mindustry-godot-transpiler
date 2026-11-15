import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_CAN_CREATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderCanCreateProof.gd'
UNIT_CARGO_LOADER_CAN_CREATE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderCanCreateProof.tscn'


class C07UnitCargoLoaderCanCreateTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_can_create_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2322']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_can_create_state')
        # Advance N2234 ported the updateTile advance in full,
        # but the spawn gate (UnitCargoLoader.java:108,
        # `if(unit == null && Units.canCreate(team, unitType)){`)
        # read can_create from an explicit param defaulting to
        # true, and the driver passed that default -- so a
        # unit-cargo-loader built its manifold even past the
        # unit cap. N2322 is the live canCreate evaluation
        # (Units.canCreate, Units.java:115-117, over getCap,
        # Units.java:119-126): a new pure,
        # source_unit_cargo_loader_can_create_state, reading
        # the frame can_create_inputs dict (count_type /
        # use_unit_cap / is_banned / is_wave_team / is_campaign
        # / is_pvp / disable_unit_cap / ignore_unit_cap /
        # unit_cap / unit_cap_variable / team_unit_cap) and
        # returning {can_create, cap}, wired into the tick so
        # the N2234 advance reads the live verdict instead of
        # the default true. No input stamped means permissive
        # (can_create true, cap Integer.MAX_VALUE), preserving
        # the current behavior. The cap itself comes from the
        # shared N2140 bridge (SourceUnitUpdateState.cap_state
        # + SourceUnitRuntimeState.source_units_can_create_state),
        # not a re-implementation. Two new result symbols.
        self.assertEqual(
            ledger['N2322']['source_symbols'],
            [
                'source_unit_cargo_loader_can_create_state_result.can_create',
                'source_unit_cargo_loader_can_create_state_result.cap',
            ],
        )
        for name in ledger['N2322']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/Units.java')
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_can_create_state')
        self.assertEqual(ledger['N2322']['runtime_proof'], '/root/C07UnitCargoLoaderCanCreateProof')
        self.assertEqual(
            ledger['N2322']['tests'],
            [
                'test_c07_unit_cargo_loader_can_create_registration',
                'test_all_c07_unit_cargo_loader_can_create_input_evidence_is_exact',
                'test_unit_cargo_loader_can_create_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_can_create',
            ],
        )
        self.assertTrue(ledger['N2322']['deferred_exprs'])
        # This slice resolves the N2234 live canCreate check
        # entry, so it is gone from DEFERRED -- and the new
        # live unit-count source entry takes its place (the
        # count_type frame input has no live
        # team.data().countType query behind it yet). The
        # canPlaceOn placement gate stays deferred (out of
        # scope: this slice wires only the updateTile spawn
        # gate), as does the live unit fill (getByID + live
        # spawn application).
        self.assertFalse(any(entry.startswith('UnitCargoLoader updateTile live canCreate check (') for entry in ledger['N2322']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canCreate live unit-count source (') for entry in ledger['N2322']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canPlaceOn / Units.canCreate rows (') for entry in ledger['N2322']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader updateTile live unit fill (') for entry in ledger['N2322']['deferred_exprs']))

    def test_all_c07_unit_cargo_loader_can_create_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2322']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_can_create_state')
        slice_sources = {
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/game/Teams.java',
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2322']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_can_create_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The canCreate pure (N2322) evaluates
        # Units.canCreate(team, unitType) (Units.java:115-117)
        # over getCap (Units.java:119-126) from the frame
        # can_create_inputs dict and returns {can_create,
        # cap}. Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test). Cite
        # corrections (all verified by grep at this pin -- the
        # scope brief drifts on the getCap lines): getCap is
        # Units.java:119-126 (signature :119, the uncapped
        # branch :122-124, the clamped return :125), not
        # :120-125; canCreate is :115-117 as briefed. The
        # manifold def (UnitTypes.java:4568-4593) sets NO
        # useUnitCap override, so manifold keeps the UnitType
        # default `useUnitCap = true,` (UnitType.java:205);
        # the only useUnitCap = false in UnitTypes.java is
        # :4612, assemblyDrone. isBanned() is
        # state.rules.isBanned(this) (UnitType.java:759-760),
        # i.e. unitWhitelist != bannedUnits.contains(unit)
        # (Rules.java:311-312). countType returns 0 for a
        # missing type (Teams.java:442-444). The cap math
        # (four uncapped branches + the max(0, ...) clamp +
        # the unitCapVariable branch) lives in the shared
        # N2140 bridge (SourceUnitUpdateState.cap_state,
        # delegating to SourceUnitLifecycleState.cap_state)
        # and the predicate in
        # SourceUnitRuntimeState.source_units_can_create_state;
        # this pure composes them, it does not duplicate them.
        self.assertIn('static func source_unit_cargo_loader_can_create_state', unit_cargo_loader)
        self.assertIn('public static boolean canCreate(Team team, UnitType type){', unit_cargo_loader)
        self.assertIn('return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());', unit_cargo_loader)
        self.assertIn('public static int getCap(Team team){', unit_cargo_loader)
        self.assertIn('if((team == state.rules.waveTeam && !state.rules.pvp) || (state.isCampaign() && team == state.rules.waveTeam) || state.rules.disableUnitCap || team.ignoreUnitCap){', unit_cargo_loader)
        self.assertIn('return Integer.MAX_VALUE;', unit_cargo_loader)
        self.assertIn('return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);', unit_cargo_loader)
        self.assertIn('if(unit == null && Units.canCreate(team, unitType)){', unit_cargo_loader)
        self.assertIn('public UnitType unitType = UnitTypes.manifold;', unit_cargo_loader)
        self.assertIn('return state.rules.isBanned(this);', unit_cargo_loader)
        self.assertIn('return unitWhitelist != bannedUnits.contains(unit);', unit_cargo_loader)
        self.assertIn('return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];', unit_cargo_loader)
        self.assertIn('public boolean unitCapVariable = true;', unit_cargo_loader)
        self.assertIn('public int unitCap = 0;', unit_cargo_loader)
        self.assertIn('public boolean disableUnitCap;', unit_cargo_loader)
        self.assertIn('public boolean ignoreUnitCap = false;', unit_cargo_loader)
        self.assertIn('public int unitCap;', unit_cargo_loader)
        # The uncapped cap is Integer.MAX_VALUE as a driver
        # constant (2147483647, fits a GDScript 64-bit int),
        # and the pure delegates the cap math and the
        # predicate to the shared N2140 helpers.
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_UNIT_CAP_MAX := 2147483647', unit_cargo_loader)
        self.assertIn('const source_unit_update_state := preload("res://src/game/SourceUnitUpdateState.gd")', unit_cargo_loader)
        self.assertIn('const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")', unit_cargo_loader)
        self.assertIn('source_unit_update_state.cap_state(', unit_cargo_loader)
        self.assertIn('source_unit_runtime_state.source_units_can_create_state(', unit_cargo_loader)
        # The frame-input contract: the pure reads the
        # can_create_inputs dict from the frame (count_type /
        # use_unit_cap / is_banned / is_wave_team / is_campaign
        # / is_pvp / disable_unit_cap / ignore_unit_cap /
        # unit_cap / unit_cap_variable / team_unit_cap), each
        # with its Java default; no input stamped (absent,
        # non-dict or empty) means permissive -- can_create
        # true, cap MAX -- preserving the pre-N2322 behavior
        # (the driver passed the default true).
        self.assertIn('frame.get("can_create_inputs", null)', unit_cargo_loader)
        self.assertIn('inputs.get("count_type", 0)', unit_cargo_loader)
        self.assertIn('inputs.get("use_unit_cap", true)', unit_cargo_loader)
        self.assertIn('inputs.get("is_banned", false)', unit_cargo_loader)
        self.assertIn('inputs.get("is_wave_team", false)', unit_cargo_loader)
        self.assertIn('inputs.get("is_campaign", false)', unit_cargo_loader)
        self.assertIn('inputs.get("is_pvp", false)', unit_cargo_loader)
        self.assertIn('inputs.get("disable_unit_cap", false)', unit_cargo_loader)
        self.assertIn('inputs.get("ignore_unit_cap", false)', unit_cargo_loader)
        self.assertIn('inputs.get("unit_cap", 0)', unit_cargo_loader)
        self.assertIn('inputs.get("unit_cap_variable", true)', unit_cargo_loader)
        self.assertIn('inputs.get("team_unit_cap", 0)', unit_cargo_loader)
        self.assertIn('{"can_create": true, "cap": SOURCE_UNIT_CARGO_LOADER_UNIT_CAP_MAX}', unit_cargo_loader)
        self.assertIn('{"can_create": bool(verdict.get("can_create", true)), "cap": unit_cap}', unit_cargo_loader)
        # The tick wires the live verdict into the N2234
        # advance instead of the default true: the pure runs
        # before the advance call, and the advance call passes
        # the live can_create (found_unit still null -- the
        # getByID live fill waits for its own slice). The
        # N2234 gate (`if unit == null and can_create:`,
        # SourceUnitCargoLoaderBuildState.gd) then blocks the
        # build when the cap is hit, without any change to the
        # spawn logic itself.
        self.assertIn('var can_create_state: Dictionary = source_unit_cargo_loader_can_create_state(frame)', unit_cargo_loader)
        self.assertIn('source_unit_cargo_loader_update_tile_advance_state(frame, source_delta, time_scale, null, bool(can_create_state.get("can_create", true)))', unit_cargo_loader)
        self.assertIn('if unit == null and can_create:', unit_cargo_loader)
        # The documented limits now record the canCreate
        # evaluation as live (N2322) and the remaining
        # deferrals (getByID live query, live spawn
        # application, the live unit-count source); the
        # updateTile advance stays live (N2234) and the
        # shouldConsume gate stays live (N2211).
        self.assertIn('canCreate live evaluation (N2322)', unit_cargo_loader)
        self.assertIn('updateTile advance live (N2234)', unit_cargo_loader)
        self.assertIn('shouldConsume gate live (N2211)', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_update_tile_advance_state', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_should_consume_state', unit_cargo_loader)
        # The proof's keys drive the pure (no cap when the
        # type ignores the cap, below/at cap, banned, the
        # four uncapped branches, the variable-cap team bonus
        # with the max(0, ...) clamp, the permissive default
        # without inputs) plus the live tick (a capped loader
        # frozen, an unstamped loader building).
        proof = UNIT_CARGO_LOADER_CAN_CREATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'no_cap_when_unit_cap_unused',
            'can_create_below_cap',
            'cannot_create_at_cap',
            'banned_type_cannot_create',
            'uncapped_when_unit_cap_disabled',
            'variable_cap_adds_team_bonus',
            'permissive_default_without_inputs',
            'live_tick_blocks_build_when_capped',
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
        scene = UNIT_CARGO_LOADER_CAN_CREATE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitCargoLoaderCanCreateProof.gd', scene)
        self.assertIn('C07UnitCargoLoaderCanCreateProof', scene)

    def test_reference_graph_and_actual_c07_unit_cargo_loader_can_create(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderCanCreateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_CAN_CREATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'no_cap_when_unit_cap_unused',
            'can_create_below_cap',
            'cannot_create_at_cap',
            'banned_type_cannot_create',
            'uncapped_when_unit_cap_disabled',
            'variable_cap_adds_team_bonus',
            'permissive_default_without_inputs',
            'live_tick_blocks_build_when_capped',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
