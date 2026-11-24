"""Register GameStats.getPlaced(Block) + getDestroyed(Block) (N2460).

GameStats.getPlaced(Block) + getDestroyed(Block) (GameStats.java:30-36)
is one slice (batch 45 slot 3): exactly the 4 distinct body exprs --
the two signatures `public int getPlaced(Block block){` (:30) /
`public int getDestroyed(Block block){` (:34) and the two return
lines `return placedBlockCount.get(block, 0);` (:31) /
`return destroyedBlockCount.get(block, 0);` (:35) -- all 0-hit in
ledger, registry and contracts at base c48a0af0 (1932 slices). Each
reads its own ObjectIntMap only: placed reads placedBlockCount
(:21), destroyed reads destroyedBlockCount (:24). The two maps are
independent -- a block present in one map only still returns 0
from the other, and a missing block returns 0 (the default of
`get(block, 0)`), never KeyError or null. GD models the block as a
String name (the data-driven equivalent of Java Block identity for
named content, precedent N2453/N2455/N2456/N2457) and looks up with
`.get(block, 0)` on the right map; getDestroyed is never derived
from placed counts. coreItemCount (:28) and the int counters
(enemyUnitsDestroyed, wavesLasted, buildingsBuilt,
buildingsDeconstructed, buildingsDestroyed, unitsCreated) are NOT
part of this slice. Two GD functions on the new file
SourceGameStatsRuntimeState.gd (first GameStats slice; no GD file
existed for GameStats). One slice source: GameStats.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
GAME_STATS = 'core/src/mindustry/game/GameStats.java'
PROOF = '/root/C07GameStatsProof'
PLACED_OWNER = 'SourceGameStatsRuntimeState.source_game_stats_get_placed_state'
DESTROYED_OWNER = 'SourceGameStatsRuntimeState.source_game_stats_get_destroyed_state'
TESTS = ['test_c07_game_stats_registration', 'test_all_c07_game_stats_input_evidence_is_exact', 'test_game_stats_state', 'test_reference_graph_and_actual_c07_game_stats']
# The 1 slice source the N2460 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/GameStats.java',
]
EXACT_EXPRS = [
    'public int getPlaced(Block block){',
    'return placedBlockCount.get(block, 0);',
    'public int getDestroyed(Block block){',
    'return destroyedBlockCount.get(block, 0);',
]
JAVA_METHOD = 'GameStats.getPlaced(Block)/getDestroyed(Block)'

DEFERRED = [
    'GameStats.coreItemCount (GameStats.java:28, `public ObjectIntMap<Item> coreItemCount = new ObjectIntMap<>();`) -- NOT ported here; no getter exists in Java, so a later slice needs a new accessor decision.',
    'The int counters (GameStats.java:8-18: enemyUnitsDestroyed, wavesLasted, buildingsBuilt, buildingsDeconstructed, buildingsDestroyed, unitsCreated) -- NOT ported here; they are public fields with no getters, so a later slice needs a new accessor decision.',
    'Block identity (GameStats.java:30/34, `Block block`) -- GD compares the block name as a String (data-driven model); the actual Block object identity is not ported.',
    'GameStats.getPlaced(Block) + getDestroyed(Block) Windows Godot proof -- debt in GOAL.md section 5: the N2460 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=GAME_STATS, **extra):
        return backed(typ, source, expr, rule, **extra)

    placed_inputs = {
        'stats_state': a('Dictionary', 'public ObjectIntMap<Block> placedBlockCount = new ObjectIntMap<>();', 'The GameStats state (GameStats.java:21, `public ObjectIntMap<Block> placedBlockCount = new ObjectIntMap<>();`): a Dictionary with placedBlockCount and destroyedBlockCount, each a Dictionary keyed by block name to int counts.'),
        'block': a('String', 'public int getPlaced(Block block){', 'The block to look up (GameStats.java:30, `public int getPlaced(Block block){`): a String block name; a missing block returns 0.'),
    }
    placed_outputs = {
        'placed': a('int', 'return placedBlockCount.get(block, 0);', 'How many of the block have been placed (GameStats.java:31): `placedBlockCount.get(block, 0)` -- 0 when the block is absent from the placed map.'),
    }
    destroyed_inputs = {
        'stats_state': a('Dictionary', 'public ObjectIntMap<Block> destroyedBlockCount = new ObjectIntMap<>();', 'The GameStats state (GameStats.java:24, `public ObjectIntMap<Block> destroyedBlockCount = new ObjectIntMap<>();`): a Dictionary with placedBlockCount and destroyedBlockCount, each a Dictionary keyed by block name to int counts.'),
        'block': a('String', 'public int getDestroyed(Block block){', 'The block to look up (GameStats.java:34, `public int getDestroyed(Block block){`): a String block name; a missing block returns 0.'),
    }
    destroyed_outputs = {
        'destroyed': a('int', 'return destroyedBlockCount.get(block, 0);', 'How many of the block have been destroyed (GameStats.java:35): `destroyedBlockCount.get(block, 0)` -- 0 when the block is absent from the destroyed map, even if it is present in the placed map.'),
    }
    return (placed_inputs, placed_outputs), (destroyed_inputs, destroyed_outputs)


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
    (placed_inputs, placed_outputs), (destroyed_inputs, destroyed_outputs) = definitions()

    entries = [
        ('N2460', PLACED_OWNER, 'source_game_stats_get_placed_state', GAME_STATS, 'mindustry.game.GameStats', JAVA_METHOD, placed_inputs, placed_outputs, True, 'Dictionary'),
        ('N2460', DESTROYED_OWNER, 'source_game_stats_get_destroyed_state', GAME_STATS, 'mindustry.game.GameStats', JAVA_METHOD, destroyed_inputs, destroyed_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GameStats.getPlaced(Block)/getDestroyed(Block) state from GameStats.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GameStats.getPlaced(Block)/getDestroyed(Block) state from GameStats.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2460'] = [
        'source_game_stats_get_placed_state_result.placed',
        'source_game_stats_get_destroyed_state_result.destroyed',
    ]
    # Two GD functions, one slice: godot_owner joins both owners
    # with '; ' (precedent N1996/N1997).
    source_symbols.upsert_source_slice(GODOT, 'N2460', dict(status='done', java_source=GAME_STATS, java_class='mindustry.game.GameStats', java_method=JAVA_METHOD, godot_owner=PLACED_OWNER + '; ' + DESTROYED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2460'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
