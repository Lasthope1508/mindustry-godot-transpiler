"""Register the Drill.countOre() sort opener (N2433).

Drill.countOre() (Drill.java:196-230): the 1 line N2010 +
N2302 did not register --
`itemArray.sort((item1, item2) -> {` (:215, the opener of
the 3-tier sort comparator: lowPriority -> oreCount ->
numeric id, ascending; peek selects the last).
Everything else in the method is already owned at N2010
(canMine + countOre, incl. the comparator body `int type
= Boolean.compare(!item1.lowPriority, !item2.lowPriority);`
/ `int amounts = Integer.compare(oreCount.get(item1, 0),
oreCount.get(item2, 0));` / `return Integer.compare(item1.id,
item2.id);` and `returnItem = itemArray.peek();`) or
N2302 (the DrillBuild.onProximityUpdate() wrapper, incl.
`protected void countOre(Tile tile){`, `if(itemArray.size
== 0){`, `returnItem = itemArray.peek();`) and is NOT
re-registered here.

This slice extends the existing GD function
source_count_ore_state (N2010): it adds no new owner, no
new contract and no new schema (the N2425 findEnemy-leg
precedent; same shape as N2427 / N2430). The sort already
lives as `item_array.sort_custom(...)` with exactly the
3-tier comparator; the opener call reorders itemArray and
peek (back()) selects the last. The 4 result symbols are
shared with N2010 (the shared-symbol precedent); note the
itemArray symbol's java_expr is already this opener line.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PROOF = '/root/C07DrillCountOreSortOpenerProof'
COUNT_OWNER = 'SourceDrillRuntimeState.source_count_ore_state'
TESTS = ['test_c07_drill_count_ore_sort_opener_registration', 'test_all_c07_drill_count_ore_sort_opener_input_evidence_is_exact', 'test_drill_count_ore_sort_opener_state', 'test_reference_graph_and_actual_c07_drill_count_ore_sort_opener']
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
]
EXACT_EXPRS = [
    'itemArray.sort((item1, item2) -> {',
]
SOURCE_SYMBOLS = [
    'source_drill_count_ore_result.returnItem',
    'source_drill_count_ore_result.returnCount',
    'source_drill_count_ore_result.oreCount',
    'source_drill_count_ore_result.itemArray',
]

# DEFERRED is carried from the N2010 ledger entry (verbatim)
# -- never retyped. One entry is added: the N2433 Windows
# Godot proof debt (GOAL.md section 5).
DEFERRED = [
    'Live Tile.drop/isStatic/getLinkedTilesAs providers, canonical Item ordinal binding and initialized blockedItems adapter.',
    'DrillBuild.onProximityUpdate assignment/invalidation and replacement of the bounded single-ore gameplay projection.',
    'Drill.countOre() sort opener Windows Godot proof -- debt in GOAL.md section 5, same as N2010: the N2433 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def verify():
    """Check every EXACT_EXPRS line appears verbatim in its
    upstream source, without touching any SSOT JSON. Exit 0
    when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    total = len(EXACT_EXPRS)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    source_symbols.upsert_source_slice(GODOT, 'N2433', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.countOre(Tile tile)', godot_owner=COUNT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {COUNT_OWNER}
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
