"""Register WaveSpawner.playerNear() (N2451).

WaveSpawner.playerNear() (WaveSpawner.java:58-60, `public boolean
playerNear(){`) is a pure predicate: its only body expr is the full
return line (:59). The 1 expr is 0-hit in both ledgers (re-probed at
HEAD 63e1399c + origin 63e1399c -- local and remote ledgers agree at
1923 entries, no divergence). `spawns` is the WaveSpawner field
`private Seq<Tile> spawns = new Seq<>(false);` (WaveSpawner.java:26),
populated by reset() (:217-227, a later slice) from the world-tiles
scan; GD takes it as an Array of tile dicts and never recomputes it
from the world (precedent N2442 countSpawns / N2446 getSpawns, same
field; N2123/N2297 micro-accessors). `tilesize` is Vars.tilesize = 8
(Vars.java:135; SourceWorldDefaults.TILESIZE), NOT 32 -- the batch 42
draft said 32, which is wrong; verified from upstream Vars.java:135 +
SourceWorldSourceTextState.gd:6. `has_spawns` is taken as a bool input
(precedent spawn_knockback_state; the live hasSpawns() value comes
from source_game_loop_has_spawns_state, never called cross-file here).
`player.team() != state.rules.waveTeam` does not depend on the spawn
tile, so it is hoisted out of the loop -- identical result, same
short-circuit shape as the Java `&&` chain. The HudFragment call-site
`spawner.playerNear()` (HudFragment.java:664) is NOT registered here;
it belongs to HudFragment, a later slice. One GD function on the
existing file SourceWaveSpawnerState.gd (opened by N2442, extended by
N2444/N2446). One slice source: WaveSpawner.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WAVE_SPAWNER = 'core/src/mindustry/ai/WaveSpawner.java'
PROOF = '/root/C07WaveSpawnerPlayerNearProof'
PLAYER_NEAR_OWNER = 'SourceWaveSpawnerState.source_wave_spawner_player_near_state'
TESTS = ['test_c07_wave_spawner_player_near_registration', 'test_all_c07_wave_spawner_player_near_input_evidence_is_exact', 'test_wave_spawner_player_near_state', 'test_reference_graph_and_actual_c07_wave_spawner_player_near']
# The 1 slice source the N2451 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/ai/WaveSpawner.java',
]
EXACT_EXPRS = [
    'return state.hasSpawns() && !player.dead() && spawns.contains(g -> Mathf.dst(g.x * tilesize, g.y * tilesize, player.x, player.y) < state.rules.dropZoneRadius && player.team() != state.rules.waveTeam);',
]

DEFERRED = [
    'The HudFragment call-site `spawner.playerNear()` (HudFragment.java:664, the nearpoint label update `Mathf.lerpDelta(u.color.a, Mathf.num(spawner.playerNear()), 0.1f)`) -- not in this slice; it belongs to HudFragment, a later slice.',
    'The live reads feeding the frame inputs -- state.hasSpawns() (source_game_loop_has_spawns_state), player.dead(), player.team(), state.rules.dropZoneRadius / state.rules.waveTeam -- are later slices; playerNear only reads the frame inputs.',
    'WaveSpawner.playerNear() Windows Godot proof -- debt in GOAL.md section 5: the N2451 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WAVE_SPAWNER, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return state.hasSpawns() && !player.dead() && spawns.contains(g -> Mathf.dst(g.x * tilesize, g.y * tilesize, player.x, player.y) < state.rules.dropZoneRadius && player.team() != state.rules.waveTeam);'
    player_near_inputs = {
        'has_spawns': a('bool', 'state.hasSpawns()', 'Whether the wave spawner has spawn points (WaveSpawner.java:59, `state.hasSpawns()`): the first conjunct of playerNear(); GD takes it as a bool input, never calling source_game_loop_has_spawns_state cross-file.'),
        'player_dead': a('bool', 'player.dead()', 'Whether the player is dead (WaveSpawner.java:59, `player.dead()`): negated in the second conjunct of playerNear().'),
        'spawns': a('Array', 'private Seq<Tile> spawns = new Seq<>(false);', 'The spawn tiles of this WaveSpawner (WaveSpawner.java:26, `private Seq<Tile> spawns = new Seq<>(false);`): GD takes it as an Array of tile dicts with "x"/"y" tile coords and does not recompute it from the world.'),
        'player_pos': a('Vector2', 'player.x, player.y', 'The player position in pixels (WaveSpawner.java:59, `player.x, player.y`): the second point of the Mathf.dst call in playerNear().'),
        'drop_zone_radius': a('float', 'state.rules.dropZoneRadius', 'The drop-zone radius in pixels (WaveSpawner.java:59, `state.rules.dropZoneRadius`): the distance threshold of playerNear().'),
        'player_team_id': a('int', 'player.team()', 'The player team id (WaveSpawner.java:59, `player.team()`): compared against the wave team in playerNear().'),
        'wave_team_id': a('int', 'state.rules.waveTeam', 'The wave team id (WaveSpawner.java:59, `state.rules.waveTeam`): the team spawns belong to in playerNear().'),
    }
    player_near_outputs = {
        'player_near': a('bool', expr, 'Whether the player is near a ground spawn point (WaveSpawner.java:59, the full return line): hasSpawns() && !player.dead() && some spawn within dropZoneRadius on a team other than the wave team.'),
    }
    return player_near_inputs, player_near_outputs


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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
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
    player_near_inputs, player_near_outputs = definitions()

    entries = [
        ('N2451', PLAYER_NEAR_OWNER, 'source_wave_spawner_player_near_state', WAVE_SPAWNER, 'mindustry.ai.WaveSpawner', 'WaveSpawner.playerNear()', player_near_inputs, player_near_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed WaveSpawner.playerNear() state from WaveSpawner.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed WaveSpawner.playerNear() state from WaveSpawner.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: player_near -- the single
    # result key of the GD func.
    by_slice['N2451'] = [
        'source_wave_spawner_player_near_state_result.player_near',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2451', dict(status='done', java_source=WAVE_SPAWNER, java_class='mindustry.ai.WaveSpawner', java_method='WaveSpawner.playerNear()', godot_owner=PLAYER_NEAR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2451'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
