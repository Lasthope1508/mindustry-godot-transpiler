"""Register Logic.updateGameOver() + Logic.gameOver() won leg (N2443).

Logic.updateGameOver() (Logic.java:426-431, `public static void
updateGameOver(Team winner){`) and Logic.gameOver()
(Logic.java:434-439, `public static void gameOver(Team
winner){`) share the one body expr `state.won =
player.team() == winner;` (:429 and :436) -- a twin slice
(batch 39 slot 3): both methods assign won the same way, so
both are registered here under the game-over owner. The
updateGameOver guard lines (:427 `state.gameOver = true;`,
owned by the shared key playable_game_over_runtime, and :428
`if(!headless){`, owned N1249/N1250/N608/...) are NOT
re-registered; the gameOver remainder (:435 wavesLasted,
:437 Time.run restart show, :438 netClient.setQuiet) is
deferred. The 1 expr is 0-hit in both ledgers (re-probed at
HEAD d638bfc2, origin 1f7aed4a).

Twin-register into the shared owner (precedent N2435): the
GD func keeps its name and gains two OPTIONAL team params
(player_team, winner_team, default "") plus two result keys
(won_expr, won). The contract keeps source_slice
playable_game_over_runtime and gains the two params and the
two return keys. The two existing callers
(SourceCoreDamageRuntimeState.gd, SourceGameRuntimeSummaryState.gd)
pass 2 args and keep working through the defaults. The
signature change updates the two pinned assertions that quote
it verbatim (test_playable.py game-over test, 3 lines;
test_source_symbols.py contract-params test, 1 line) -- an
intentional change, not drift. One slice source: Logic.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LOGIC = 'core/src/mindustry/core/Logic.java'
METHOD = 'Logic.updateGameOver()/Logic.gameOver()'
OWNER = 'PortGame.source_game_over_core_destroyed_state'
PROOF = '/root/C07LogicUpdateGameOverProof'
TESTS = ['test_c07_logic_update_game_over_registration', 'test_all_c07_logic_update_game_over_input_evidence_is_exact', 'test_logic_update_game_over_state', 'test_reference_graph_and_actual_c07_logic_update_game_over']
# The 1 slice source the N2443 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/core/Logic.java',
]
EXACT_EXPRS = [
    'state.won = player.team() == winner;',
]
SOURCE_SYMBOLS = [
    'source_game_over_core_destroyed_result.won_expr',
    'source_game_over_core_destroyed_result.won',
]

DEFERRED = [
    'Logic.gameOver() :435 `state.stats.wavesLasted = state.wave;` -- 0-hit both ledgers; waits for a stats slice (state.stats not ported).',
    'Logic.gameOver() :437 `Time.run(60f * 3f, () -> ui.restart.show(winner));` + :438 `netClient.setQuiet();` -- restart UI + net client not ported; waits for later slices.',
    'Logic.updateGameOver()/gameOver() won write-back -- the GD func returns won as data; no live state mutation in the pure func, the caller applies it; no game-state write-back slice yet.',
    'Logic.updateGameOver()/gameOver() Windows Godot proof -- debt in GOAL.md section 5: the N2443 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def extended_definitions():
    """The live input/result keys, copied verbatim from the
    catalog -- never retyped -- plus the two new keys."""
    schema = source_symbols.load_source_state_schema(GODOT)['schemas']
    inputs = {k: dict(v) for k, v in schema['source_game_over_core_destroyed_input']['keys'].items()}
    outputs = {k: dict(v) for k, v in schema['source_game_over_core_destroyed_result']['keys'].items()}
    inputs['player_team'] = backed('String', LOGIC, 'player.team()', 'The player team (Logic.java:429/436, `player.team()`): updateGameOver and gameOver compare it against the winner team; the GD func takes the team name as a String input.')
    inputs['winner_team'] = backed('String', LOGIC, 'player.team() == winner', 'The winning team (Logic.java:429/436, `player.team() == winner`): updateGameOver and gameOver receive it as the winner param; the GD func takes the team name as a String input.')
    outputs['won_expr'] = backed('String', LOGIC, 'state.won = player.team() == winner;', 'The won assignment recorded as data (Logic.java:429 in updateGameOver, :436 in gameOver, `state.won = player.team() == winner;`): the exact expr as a string, following the existing *_expr keys.')
    outputs['won'] = backed('bool', LOGIC, 'state.won = player.team() == winner;', 'Whether the player won (Logic.java:429 in updateGameOver, :436 in gameOver, `state.won = player.team() == winner;`): true exactly when the player team equals the winner team.')
    for meta in list(inputs.values()) + list(outputs.values()):
        meta['used_by'] = [OWNER]
    return inputs, outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = [extended_definitions()]
    # Only the 4 NEW keys are checked here: the old keys are
    # copied verbatim from the live catalog, and one of them
    # (result.source_owner, java_expr
    # `Logic.checkGameState()`) is a qualified reference that
    # never appears verbatim in Logic.java -- its evidence
    # was established by the original playable_game_over_runtime
    # registration, not by this slice.
    new_keys = {'player_team', 'winner_team', 'won_expr', 'won'}
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
            for field, meta in keys.items():
                if field not in new_keys:
                    continue
                total += 1
                source = meta['java_source']
                text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
                if meta['java_expr'] not in text:
                    missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    inputs, outputs = extended_definitions()

    # The shared input/result schemas gain the new keys;
    # every old key stays exactly as the catalog has it
    # (copied verbatim above -- never retyped). The stored
    # game-over schemas are keys-only, so the upsert keeps
    # that shape.
    source_symbols.upsert_source_state_schema(GODOT, 'source_game_over_core_destroyed_input', dict(keys=inputs))
    source_symbols.upsert_source_state_schema(GODOT, 'source_game_over_core_destroyed_result', dict(keys=outputs))

    # The shared contract gains the two new params and the
    # two new return keys; source_slice stays
    # playable_game_over_runtime and every other field stays
    # exactly as registered (copied from the live catalog
    # -- never retyped).
    contracts = source_symbols.load_source_api_contracts(GODOT)
    old_contract = dict(contracts['contracts'][OWNER])
    old_contract['params'] = list(old_contract['params']) + [
        dict(name='player_team', type='String', schema='source_game_over_core_destroyed_input.player_team'),
        dict(name='winner_team', type='String', schema='source_game_over_core_destroyed_input.winner_team'),
    ]
    old_contract['return_keys'] = list(old_contract['return_keys']) + ['won_expr', 'won']
    source_symbols.upsert_source_api_contract(GODOT, OWNER, old_contract)

    symbols = {}
    for name in SOURCE_SYMBOLS:
        field = name.split('.')[-1]
        meta = outputs[field]
        symbols[name] = dict(status='source-backed', godot_owner=OWNER, godot_symbol=name, java_source=meta['java_source'], java_method=METHOD, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)

    source_symbols.upsert_source_slice(GODOT, 'N2443', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method=METHOD, godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {OWNER}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
