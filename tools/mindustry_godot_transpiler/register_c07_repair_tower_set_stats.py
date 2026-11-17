"""Register the RepairTower setStats() rows (N2230).

RepairTower.setStats() (RepairTower.java:35-41, `public void
setStats(){`) adds two stat rows unconditionally
(`stats.add(Stat.range, range / tilesize,
StatUnit.blocks);` -- RepairTower.java:38 -- and
`stats.add(Stat.repairSpeed, healAmount * 60f,
StatUnit.perSecond);` -- RepairTower.java:39).
`super.setStats();` (:37) is Block-level stat work (N1696),
NOT this slice: the base stats come from Block.setStats and
are not re-emitted here.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2190 / N2191 / N2211 / N2228 / N2229
built: source_repair_tower_set_stats_state(range,
heal_amount, tilesize) returning a single `stats` list with
the two rows in Java order (the scope-pinned shape,
mirroring the stats.add order). All three params are
explicit floats (the N2212 acquire / N2220 draw-place /
N2224 setStats per-def-param precedent -- range and
healAmount are per-def static state, not live frame keys:
class defaults range 80f / healAmount 1f,
RepairTower.java:21, :24; unit-repair-tower 100f / 1.5f,
Blocks.java:6579-6580); tilesize is 8 (Vars.java:135,
`public static final int tilesize = 8;`). The `range`
param name parses cleanly under Godot 4.6.2 (verified at
RED with --check-only on the exact pinned signature).
(2) There is NO driver tick line: setStats is a
stat-display read, not a tick write (the N2224 RepairTurret
setStats / N2220 draw-select/draw-place precedent); the
proof calls the pure function directly with per-def params,
and its no_driver_tick_line key reads the state script
source and greps the driver body -- a runtime check, not a
hardcoded true. (3) One new result symbol, `stats` (the
two-row list): the scope's +5 estimate was copied from
N2224's flat 5-key return and is corrected at RED -- this
slice returns a single list, so symbols +1, Done +1,
contracts +1, schema +2, SSOT 11497/1679/1606/3003 ->
11498/1680/1607/3005. Slice sources: RepairTower.java +
Vars.java + Blocks.java. Shard note: unlike N2229 (whose
java_source is ConsumeLiquid.java), N2230's java_source IS
RepairTower.java, so no shard changes (the N2219-N2228
precedent); no `generated_owner` key is needed.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_tower_ozone_consume import DEFERRED as N2229_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTowerSetStatsProof'
SET_STATS_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_set_stats_state'
TESTS = ['test_c07_repair_tower_set_stats_registration', 'test_all_c07_repair_tower_set_stats_input_evidence_is_exact', 'test_repair_tower_set_stats_state', 'test_reference_graph_and_actual_c07_repair_tower_set_stats']
# The 3 slice sources the N2230 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public void setStats(){', 'super.setStats();', 'stats.add(Stat.range, range / tilesize, StatUnit.blocks);', 'stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);', 'public float range = 80f;', 'public float healAmount = 1f;', 'range = 100f;', 'healAmount = 1.5f;', 'public static final int tilesize = 8;', 'public class RepairTower extends Block{']

# DEFERRED is carried from the N2229 register script via import --
# never retyped. The two lumped draw-family entries that mention
# setStats() (the old entry 151 and the N2229 entry 280) are
# DROPPED here -- this slice closes setStats() -- and replaced
# by the new entry below, which keeps the draw/drawSelect/
# drawPlace/range/warmup deferral record with its line refs;
# every other entry is carried verbatim (the N2211/N2228 lesson
# -- never retype the pool). The filter drops only entries
# mentioning BOTH RepairTower and setStats, so the other
# families' setStats entries (UnitAssemblerModule, StackRouter,
# ImpactReactor, BuildTurret) and the RepairTurret setStats
# Windows-proof debt entry survive untouched.
DEFERRED = [e for e in N2229_DEFERRED if not ('RepairTower' in e and 'setStats' in e)] + [
    'RepairTower draw / drawSelect / drawPlace / range / warmup rows (draw circle/glow, RepairTower.java:94-110; drawSelect dash circle, RepairTower.java:122-124; drawPlace dash circle, RepairTower.java:44-48; range() returns range, RepairTower.java:112-114; warmup() returns warmup, RepairTower.java:117-119) -- setStats() is DONE at N2230; the draw/drawSelect/drawPlace/range/warmup rows still wait for their own slices.',
    'RepairTower setStats() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2229: the N2230 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_inputs = {
        'range': a('float', 'public float range = 80f;', 'The per-def repair range in world pixels (RepairTower.java:21, `public float range = 80f;`, the class default; unit-repair-tower 100f, Blocks.java:6579); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
        'heal_amount': a('float', 'public float healAmount = 1f;', 'The per-def heal amount in health per tick (RepairTower.java:24, `public float healAmount = 1f;`, the class default; unit-repair-tower 1.5f, Blocks.java:6580); passed explicitly because it is per-def static state, not a live frame key.'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2220 draw-place precedent) so the range leg divides by the caller-supplied world constant.', source=VARS),
    }
    set_stats_outputs = {
        'stats': a('Array', 'stats.add(Stat.range, range / tilesize, StatUnit.blocks);', 'The two stat rows setStats() adds, in Java order: the Stat.range row (range / tilesize, StatUnit.blocks, RepairTower.java:38) and the Stat.repairSpeed row (healAmount * 60f, StatUnit.perSecond, RepairTower.java:39).'),
    }
    return set_stats_inputs, set_stats_outputs


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
    set_stats_inputs, set_stats_outputs = definitions()

    entries = [
        ('N2230', SET_STATS_OWNER, 'source_repair_tower_set_stats_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower', 'RepairTower.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower setStats() state from RepairTower.java + Vars.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower setStats() state from RepairTower.java + Vars.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: stats (the single two-row list).
    by_slice['N2230'] = [
        'source_repair_tower_set_stats_state_result.stats',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2230', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower', java_method='RepairTower.setStats()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2230'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
