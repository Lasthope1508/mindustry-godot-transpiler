"""Register GameState 9 accessors (N2454).

GameState.boss()/getSector()/getPlanet()/isEditor()/isPlaying()/
isGame()/isMenu()/is(State)/getState() (GameState.java:56-117,
`public Unit boss(){` /
`return teams.bosses.firstOpt();` /
`public @Nullable Sector getSector(){` /
`return rules.sector;` /
`public @Nullable Planet getPlanet(){` /
`return rules.sector != null ? rules.sector.planet : rules.planet;` /
`public boolean isEditor(){` /
`return rules.editor;` /
`public boolean isPlaying(){` /
`return state == State.playing;` /
`public boolean isGame(){` /
`return state != State.menu;` /
`public boolean isMenu(){` /
`return state == State.menu;` /
`public boolean is(State astate){` /
`return state == astate;` /
`public State getState(){` /
`return state;`) is one grouped slice: nine one-line accessors,
one record, nine java_method entries, one shared owner -- the
N2390/N2395 group precedent, same as N2450 (Team.java 8
forwards). All 9 body exprs are 0-hit in exact_exprs in both
ledgers (re-probed at HEAD 2fb5e9c7 + origin 63e1399c; the only
other appearance of `return rules.sector;` is N811's
bridge_exprs -- a bridge dependency listing, not ownership,
same as N2124's `return rules.sector != null;` twin).
`state` is a private Java field, so it arrives as the
state_name String input ("paused"/"playing"/"menu",
GameState.java:119-121); `rules` arrives as its fields
(rules_sector / rules_planet / rules_editor); `teams.bosses`
arrives as the bosses Array -- firstOpt() is null when the
bosses seq is empty.

NOT registered: isPaused() (:93-95) -- its only body expr is
the exact_expr of N2123; isCampaign() (:73-75) +
hasSector() (:77-79) -- both share the literal `return
rules.sector != null;` already owned by N2124; set(State)
(:60-66) -- `:64` Events.fire needs the event-bus decision
(batch 37 scope section 4a); hasSpawns() (:68-70) -- N2448.
One slice source: GameState.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
GAME_STATE = 'core/src/mindustry/core/GameState.java'
PROOF = '/root/C07GameLoopStateAccessorsProof'
OWNER = 'SourceGameLoopRuntimeState.source_game_loop_state_accessors_state'
TESTS = ['test_c07_game_loop_state_accessors_registration', 'test_all_c07_game_loop_state_accessors_input_evidence_is_exact', 'test_game_loop_state_accessors_state', 'test_reference_graph_and_actual_c07_game_loop_state_accessors']
# The 1 slice source the N2454 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/core/GameState.java',
]
EXACT_EXPRS = [
    'return teams.bosses.firstOpt();',
    'return rules.sector;',
    'return rules.sector != null ? rules.sector.planet : rules.planet;',
    'return rules.editor;',
    'return state == State.playing;',
    'return state != State.menu;',
    'return state == State.menu;',
    'return state == astate;',
    'return state;',
]

DEFERRED = [
    'GameState.isPaused() (GameState.java:93-95) is NOT in this slice: its only body expr `return state == State.paused;` is the exact_expr of N2123.',
    'GameState.isCampaign() (GameState.java:73-75) + hasSector() (GameState.java:77-79) are NOT in this slice: both share the literal `return rules.sector != null;` already owned by N2124 (twin-register only when main thread approves it explicitly).',
    'GameState.set(State) (GameState.java:60-66) is NOT in this slice: `:64` Events.fire(new StateChangeEvent(state, astate)); needs the event-bus decision (batch 37 scope section 4a); `:62` guard + `:65` assign are setter-mutate legs for batch 44+.',
    'GameState.hasSpawns() (GameState.java:68-70) is NOT in this slice: N2448 owns it.',
    'GameState 9 accessors Windows Godot proof -- debt in GOAL.md section 5: the N2454 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=GAME_STATE, **extra):
        return backed(typ, source, expr, rule, **extra)

    state_inputs = {
        'state_name': a('String', 'state == State.playing', 'The current game state as a name (GameState.java:99, `state == State.playing;`): `state` is a private Java field (GameState.java:53), so it arrives as a String ("paused"/"playing"/"menu", the State enum GameState.java:119-121) instead of being read live.'),
        'astate_name': a('String', 'return state == astate;', 'The state to compare against, as a name (GameState.java:112, `return state == astate;`): the `astate` param of is(State), in the same String form as state_name.'),
        'rules_sector': a('Variant', 'return rules.sector;', 'The rules sector, or null (GameState.java:82, `return rules.sector;`): `rules` is the GameState input param, not an owned schema; the sector arrives as an opaque ref (a Dictionary carrying "planet" in the proof).'),
        'rules_planet': a('Variant', 'return rules.sector != null ? rules.sector.planet : rules.planet;', 'The fallback planet when there is no sector (GameState.java:86, `return rules.sector != null ? rules.sector.planet : rules.planet;`): rules.planet, used by getPlanet() only when rules_sector is null.'),
        'rules_editor': a('bool', 'return rules.editor;', 'Whether the rules are in editor mode (GameState.java:90, `return rules.editor;`): the rules.editor flag arrives as a frame input.'),
        'bosses': a('Array', 'return teams.bosses.firstOpt();', 'The boss units (GameState.java:57, `return teams.bosses.firstOpt();`): teams.bosses arrives as an Array; firstOpt() is the first element, or null when empty -- no cross-call to Teams.'),
    }
    state_outputs = {
        'boss': a('Variant', 'return teams.bosses.firstOpt();', 'The first boss unit, or null (GameState.java:57, `return teams.bosses.firstOpt();`): bosses[0] when the Array is non-empty, else null.'),
        'sector': a('Variant', 'return rules.sector;', 'The rules sector, or null (GameState.java:82, `return rules.sector;`): rules_sector passed through as-is.'),
        'planet': a('Variant', 'return rules.sector != null ? rules.sector.planet : rules.planet;', 'The planet of the current sector, or rules.planet (GameState.java:86, `return rules.sector != null ? rules.sector.planet : rules.planet;`): sector.planet when rules_sector is non-null, else rules_planet.'),
        'is_editor': a('bool', 'return rules.editor;', 'Whether the rules are in editor mode (GameState.java:90, `return rules.editor;`): rules_editor passed through.'),
        'is_playing': a('bool', 'return state == State.playing;', 'Whether there is an unpaused game in progress (GameState.java:99, `return state == State.playing;`): state_name == "playing".'),
        'is_game': a('bool', 'return state != State.menu;', 'Whether the current state is not the menu (GameState.java:104, `return state != State.menu;`): state_name != "menu".'),
        'is_menu': a('bool', 'return state == State.menu;', 'Whether the current state is the menu (GameState.java:108, `return state == State.menu;`): state_name == "menu".'),
        'is_state': a('bool', 'return state == astate;', 'Whether the current state equals the given state (GameState.java:112, `return state == astate;`): state_name == astate_name.'),
        'state': a('String', 'return state;', 'The current game state as a name (GameState.java:116, `return state;`): state_name passed through as-is.'),
    }
    return (state_inputs, state_outputs)


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
            total += len(keys)
            for field, meta in keys.items():
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
    symbols = {}
    (state_inputs, state_outputs) = definitions()

    entries = [
        ('N2454', OWNER, 'source_game_loop_state_accessors_state', GAME_STATE, 'mindustry.core.GameState', 'GameState.boss()/getSector()/getPlanet()/isEditor()/isPlaying()/isGame()/isMenu()/is(State)/getState()', state_inputs, state_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GameState 9 accessors state from GameState.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GameState 9 accessors state from GameState.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: boss, sector, planet,
    # is_editor, is_playing, is_game, is_menu, is_state, state
    # -- the Java order of the 9 accessors (GameState.java:56-117).
    by_slice['N2454'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2454', dict(status='done', java_source=GAME_STATE, java_class='mindustry.core.GameState', java_method='GameState.boss()/getSector()/getPlanet()/isEditor()/isPlaying()/isGame()/isMenu()/is(State)/getState()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2454'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
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
