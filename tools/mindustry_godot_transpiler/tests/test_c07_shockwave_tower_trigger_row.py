import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_TRIGGER_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerTriggerRowProof.gd'
SHOCKWAVE_TOWER_TRIGGER_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerTriggerRowProof.tscn'


class C07ShockwaveTowerTriggerRowTests(unittest.TestCase):
    def test_c07_shockwave_tower_trigger_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2505']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_trigger_state')
        # The ShockwaveTower updateTile STATE is live
        # (N2247 advance): the fire gate + bullet scan
        # + wave damage + fire reset + heat decay run
        # every tick -- but the advance fires SILENTLY
        # (pure result only): the team event at the
        # end of the fire branch (:98-99) was never
        # modeled. N2505 ports it as ONE pure-only
        # CALL record (the N2488 precedent, NO tick
        # wiring): source_shockwave_tower_trigger_
        # state(fired, is_default_team) returns
        # {trigger_call} -- {event: "Trigger.
        # shockwaveTowerUse"} when fired AND
        # is_default_team, null otherwise (the N2397
        # null-when-absent precedent). The trigger
        # fires ONLY for the default team, and ONLY
        # inside the fire branch, AFTER the wave
        # damage loop (:89-96). Both inputs are
        # caller-supplied: fired is the fire-branch
        # verdict (the caller composes it from the
        # N2340/N2347 hitbox + the N2390 sense/warmup
        # inputs) and is_default_team is team ==
        # state.rules.defaultTeam (Rules.java:205,
        # `public Team defaultTeam = Team.sharded;`).
        # NO event is fired -- the event-dispatch call
        # site waits for an event slice. One new
        # result symbol.
        self.assertEqual(
            ledger['N2505']['source_symbols'],
            [
                'source_shockwave_tower_trigger_state_result.trigger_call',
            ],
        )
        for name in ledger['N2505']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_trigger_state')
        self.assertEqual(ledger['N2505']['runtime_proof'], '/root/C07ShockwaveTowerTriggerRowProof')
        self.assertEqual(
            ledger['N2505']['tests'],
            [
                'test_c07_shockwave_tower_trigger_row_registration',
                'test_all_c07_shockwave_tower_trigger_row_input_evidence_is_exact',
                'test_shockwave_tower_trigger_row_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_trigger_row',
            ],
        )
        self.assertTrue(ledger['N2505']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #35 (1-based
        # in DEFERRED-after-advances-35.py): the
        # ShockwaveTower trigger row entry is REMOVED
        # -- Events.fire(Trigger.shockwaveTowerUse)
        # is live now as a pure call record, so
        # nothing of the entry remains. Net 218 - 1 =
        # 217. (The wave-damage-application entry and
        # the random-reloadCounter-init entry still
        # stand: the damage application on live
        # bullets and the random initial offset are
        # NOT in this slice's scope.)
        self.assertFalse(any(entry.startswith('ShockwaveTower trigger row (') for entry in ledger['N2505']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave damage application on live bullets (') for entry in ledger['N2505']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower random reloadCounter init (') for entry in ledger['N2505']['deferred_exprs']))
        self.assertEqual(len(ledger['N2505']['deferred_exprs']), 217)

    def test_all_c07_shockwave_tower_trigger_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2505']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_trigger_state')
        slice_sources = [
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/game/EventType.java',
            'core/src/mindustry/game/Rules.java',
        ]
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2505']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_trigger_row_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The trigger row (ShockwaveTowerBuild.
        # updateTile(), ShockwaveTower.java:98-99):
        # the STATE is live since N2247 (the fire
        # gate + bullet scan + wave damage + fire
        # reset + heat decay), so this pure consumes
        # the caller-evaluated fired gate (the N2247
        # fire verdict) and the caller-evaluated team
        # gate (team == state.rules.defaultTeam) and
        # reports the Events.fire call as a pure call
        # record (the N2488 precedent -- no event is
        # fired; the event-dispatch call site waits
        # for an event slice): `if(targets.size >
        # 0){` + `for(var target : targets){` +
        # `hitEffect.at(target.x, target.y,
        # waveColor);` + `if(team == state.rules.
        # defaultTeam){` + `Events.fire(Trigger.
        # shockwaveTowerUse);`. The trigger is the
        # LAST statement of the fire branch, AFTER
        # the wave damage loop (:89-96). The enum
        # value is VERIFIED: `public enum Trigger{`
        # (EventType.java:20) carries
        # `shockwaveTowerUse,` (EventType.java:28),
        # so the event token is the exact "Trigger.
        # shockwaveTowerUse". The team gate reads
        # state.rules.defaultTeam (`public Team
        # defaultTeam = Team.sharded;`,
        # Rules.java:205). When either gate fails the
        # call is null (the N2397 null-when-absent
        # precedent). Pure-only: the tick never calls
        # it -- the N2247 advance owns the fire gate.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_shockwave_tower_trigger_state', shockwave_tower)
        self.assertIn('if(targets.size > 0){', shockwave_tower)
        self.assertIn('for(var target : targets){', shockwave_tower)
        self.assertIn('hitEffect.at(target.x, target.y, waveColor);', shockwave_tower)
        self.assertIn('if(team == state.rules.defaultTeam){', shockwave_tower)
        self.assertIn('Events.fire(Trigger.shockwaveTowerUse);', shockwave_tower)
        self.assertIn('public enum Trigger{', shockwave_tower)
        self.assertIn('shockwaveTowerUse,', shockwave_tower)
        self.assertIn('public Team defaultTeam = Team.sharded;', shockwave_tower)
        # The documented limits record the trigger
        # row as live.
        self.assertIn('Trigger row live (N2505)', shockwave_tower)
        # The proof's keys drive the trigger pure
        # (the fire + team gate, the two null cases,
        # the event token, the gate shape, and the
        # live N2390-sense-composed input).
        proof = SHOCKWAVE_TOWER_TRIGGER_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'trigger_on_fire',
            'trigger_null_when_not_fired',
            'trigger_null_when_not_default_team',
            'trigger_event_token',
            'trigger_gate_shape',
            'trigger_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue(SHOCKWAVE_TOWER_TRIGGER_ROW_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerTriggerRowProof.gd', SHOCKWAVE_TOWER_TRIGGER_ROW_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_trigger_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerTriggerRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_TRIGGER_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'trigger_on_fire',
            'trigger_null_when_not_fired',
            'trigger_null_when_not_default_team',
            'trigger_event_token',
            'trigger_gate_shape',
            'trigger_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
