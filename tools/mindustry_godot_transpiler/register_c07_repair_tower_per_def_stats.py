"""Register the RepairTower per-def stat rows (N2238).

The per-def stat rows (Blocks.java:6575-6583 + class defaults
RepairTower.java:21, :24 + Block.java:215): unit-repair-tower
range 100f (`range = 100f;`, Blocks.java:6579), healAmount
1.5f (`healAmount = 1.5f;`, Blocks.java:6580), size 2
(`size = 2;`, Blocks.java:6578); class defaults range 80f
(`public float range = 80f;`, RepairTower.java:21),
healAmount 1f (`public float healAmount = 1f;`,
RepairTower.java:24), size 1 (`public int size = 1;`,
Block.java:215). The single def is `unitRepairTower = new
RepairTower("unit-repair-tower"){{` (Blocks.java:6575), of
the block `public class RepairTower extends Block{`
(RepairTower.java:18).

RED decisions (resolved at RED): (1) One pure function on
the same family file, taking the block id explicitly (per-def
static state, not a live frame key -- the N2212 / N2220 /
N2235 / N2237 precedent) and returning all three rows, via
three new helpers (`_range_for_block_id`,
`_heal_amount_for_block_id`, `_size_for_block_id`) -- no
duplicated constants, no existing per-def helpers to reuse
(the RepairTower file has none). (2) There is NO driver
tick line: a static read (the N2233 range / N2235 ambient
volume / N2237 precedent). (3) The deferred pool entry
"RepairTower per-def stat rows" is dropped here and replaced
by the N2238 Windows-proof debt entry; the RepairTurret
per-def stat rows entry was already resolved by N2237.
(4) Requirements (graphite 90 / silicon 90 / tungsten 80,
Blocks.java:6576) are NOT in this slice: the content
registry already carries them for unit-repair-tower
(content_registry.json, `requirements` under
`properties`), as it does size 2, range 100.0 and
consumePower 1.0; powerUse 1f lives in the catalog
consumePower (the N2237 powerUse precedent). (5)
Suppression live + targets live list stay BLOCKED: no
`frame["units"] =` stamp exists anywhere in src/game, and
no frame stamps `heal_suppressed` /
`heal_suppression_time`. Three new result symbols: range,
heal_amount, size. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schema +2, 11537/1687/1618/3027 ->
11540/1688/1619/3029. Slice sources: RepairTower.java +
Blocks.java + Block.java (the size class default). No shard
change: RepairTower.java matches no shard (the
N2211-N2237 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_per_def_stats import DEFERRED as N2237_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTowerPerDefStatsProof'
STATS_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_per_def_stats_state'
TESTS = ['test_c07_repair_tower_per_def_stats_registration', 'test_all_c07_repair_tower_per_def_stats_input_evidence_is_exact', 'test_repair_tower_per_def_stats_state', 'test_reference_graph_and_actual_c07_repair_tower_per_def_stats']
# The 3 slice sources the N2238 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['public float range = 80f;', 'public float healAmount = 1f;', 'public int size = 1;', 'range = 100f;', 'healAmount = 1.5f;', 'size = 2;', 'public class RepairTower extends Block{', 'unitRepairTower = new RepairTower("unit-repair-tower"){{']

# DEFERRED is carried from the N2237 register script via import --
# never retyped. The lumped entry "RepairTower per-def stat
# rows" is DROPPED here -- the verification slice lands here --
# and replaced by the new entry below, which keeps the
# Windows-proof debt; every other entry is carried verbatim
# (the N2211/N2228 lesson -- never retype the pool). The
# filter drops only the entry carrying the exact RepairTower
# phrase, so the RepairTurret Windows-proof debt entry from
# N2237 survives untouched.
DEFERRED = [e for e in N2237_DEFERRED if 'RepairTower per-def stat rows' not in e] + [
    'RepairTower per-def stat rows Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2237: the N2238 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    stats_inputs = {
        'block_id': a('String', 'unitRepairTower = new RepairTower("unit-repair-tower"){{', 'The block id (Blocks.java:6575, `unitRepairTower = new RepairTower("unit-repair-tower"){{`): the per-def identity whose catalog stat overrides the resolver returns, passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2220 / N2235 / N2237 per-def-param precedent).', source=BLOCKS),
    }
    stats_outputs = {
        'range': a('float', 'range = 100f;', 'The per-def range (unit-repair-tower 100f, Blocks.java:6579, `range = 100f;`; class default 80f, RepairTower.java:21, `public float range = 80f;`): the range RepairTowerBuild.range() returns (RepairTower.java:112-113, `return range;`) and setStats() reports as range / tilesize (RepairTower.java:38, `stats.add(Stat.range, range / tilesize, StatUnit.blocks);`).', source=BLOCKS),
        'heal_amount': a('float', 'healAmount = 1.5f;', 'The per-def heal amount (unit-repair-tower 1.5f, Blocks.java:6580, `healAmount = 1.5f;`; class default 1f, RepairTower.java:24, `public float healAmount = 1f;`): the amount RepairTowerBuild.updateTile() heals with (RepairTower.java:78, `target.heal(healAmount * edelta());`) and setStats() reports as healAmount * 60f per second (RepairTower.java:39, `stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);`).', source=BLOCKS),
        'size': a('int', 'size = 2;', 'The per-def footprint size (unit-repair-tower 2, Blocks.java:6578, `size = 2;`; class default 1, Block.java:215, `public int size = 1;`): the tile footprint the block occupies.', source=BLOCKS),
    }
    return stats_inputs, stats_outputs


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
    stats_inputs, stats_outputs = definitions()

    entries = [
        ('N2238', STATS_OWNER, 'source_repair_tower_per_def_stats_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTower.setStats()/RepairTowerBuild.updateTile()/RepairTowerBuild.range()', stats_inputs, stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower per-def stat rows from RepairTower.java + Blocks.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower per-def stat rows from RepairTower.java + Blocks.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: range, heal_amount, size.
    by_slice['N2238'] = [
        'source_repair_tower_per_def_stats_state_result.range',
        'source_repair_tower_per_def_stats_state_result.heal_amount',
        'source_repair_tower_per_def_stats_state_result.size',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2238', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTower.setStats()/RepairTowerBuild.updateTile()/RepairTowerBuild.range()', godot_owner=STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2238'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
