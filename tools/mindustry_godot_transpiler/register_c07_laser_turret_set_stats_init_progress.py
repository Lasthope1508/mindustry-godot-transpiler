"""Register LaserTurret.setStats()+init() + LaserTurretBuild.progress() (N2386).

LaserTurret.setStats() (LaserTurret.java:26-33)
drops the booster stat row and, when a coolant
consumer exists, adds an input row with the
boosters spec (reload, coolant.amount,
coolantMultiplier, baseReload false,
this::consumesLiquid). LaserTurret.init()
(LaserTurret.java:36-43) resolves the coolant
consumer with findConsumer when it is still null.
LaserTurretBuild.progress()
(LaserTurret.java:110-112) is 1 -
clamp(reloadCounter / reload). The three methods
share one concern (LaserTurret coolant+reload
setup and progress) and each carries only one
distinguishing expr, so they are one slice
(grouping approved by the main thread;
N2330/N2367/N2381/N2384 precedent). The
functions live in the existing PortBridge file
(opened by N2360), following the PortBridge
precedent (N2355/N2360/N2364/N2369/N2372/N2373)
-- each function gets its own owner
(PortGame.<function>_state), the N2384
three-method precedent, so every contract name
equals its GD function name (the batch-17
contract-name lesson).

RED decisions (resolved at RED): (1) The three
distinguishing exprs are `stats.add(Stat.input,
StatValues.boosters(reload, coolant.amount,
coolantMultiplier, false, this::consumesLiquid));`,
`coolant = findConsumer(c -> c instanceof
ConsumeLiquidBase);` and `return 1f -
Mathf.clamp(reloadCounter / reload);` (0 hits in
both ledgers at probe time). (2) `super.setStats
();`, `stats.remove(Stat.booster);`, `if(coolant
!= null){`, `super.init();`, `if(coolant == null)
{` and the method headers are evidence only,
never the sole distinguishing expr. (3) `stats`
arrives as an explicit Array of row dicts (the
N2384 setStats precedent) and is never mutated
-- the returned rows are fresh. (4) `coolant` is
`ConsumeLiquidBase` (BaseTurret.java:34): it
arrives as an explicit Dictionary {amount} or
null. `coolantMultiplier` is a LaserTurret field
with default 1f (LaserTurret.java:22): it arrives
as an explicit float. (5) `this::consumesLiquid`
is Block.consumesLiquid (Block.java:778): the
Boolf<Liquid> filter StatValues.boosters takes
(StatValues.java:439) -- it arrives as an
explicit Callable. (6) The findConsumer
predicate `c -> c instanceof ConsumeLiquidBase`
is NOT ported -- the driver runs findConsumer
(Block.java:1104) and the found consumer arrives
as the explicit found_consumer param (nullable).
(7) `return bullets.any();` (shouldActiveSound)
is NOT registered here -- it belongs to a later
ContinuousTurret slot. (8) NO driver line: three
pure functions the setup/tick reads, not
per-tick writes.
Four new result symbols: stats, coolant,
coolant_found, progress.
Slice source: LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_update_tile_leg2 import DEFERRED as N2373_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretSetStatsInitProgressProof'
SET_STATS_OWNER = 'PortGame.source_laser_turret_build_set_stats_state'
INIT_OWNER = 'PortGame.source_laser_turret_build_init_state'
PROGRESS_OWNER = 'PortGame.source_laser_turret_build_progress_state'
TESTS = ['test_c07_laser_turret_set_stats_init_progress_registration', 'test_all_c07_laser_turret_set_stats_init_progress_input_evidence_is_exact', 'test_laser_turret_set_stats_init_progress_state', 'test_reference_graph_and_actual_c07_laser_turret_set_stats_init_progress']
# The 1 slice source the N2386 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public void setStats(){',
    'super.setStats();',
    'stats.remove(Stat.booster);',
    'if(coolant != null){',
    'stats.add(Stat.input, StatValues.boosters(reload, coolant.amount, coolantMultiplier, false, this::consumesLiquid));',
    '@Override',
    'public void init(){',
    'super.init();',
    'if(coolant == null){',
    'coolant = findConsumer(c -> c instanceof ConsumeLiquidBase);',
    'public float progress(){',
    'return 1f - Mathf.clamp(reloadCounter / reload);',
]

# DEFERRED is carried from the N2373 register script via import --
# never retyped. All N2373 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2360/N2364/N2369/N2372/N2373's
# own Windows proof debt -- none of them is resolved by this
# slice). One entry is added: N2386's Windows proof debt.
DEFERRED = list(N2373_DEFERRED) + [
    'LaserTurret setStats+init+progress Windows Godot proof -- debt in GOAL.md section 5, same as N2360/N2364/N2369/N2372/N2373: the N2386 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_header = 'public void setStats(){'
    super_set_stats = 'super.setStats();'
    remove_booster = 'stats.remove(Stat.booster);'
    coolant_guard = 'if(coolant != null){'
    boosters_line = 'stats.add(Stat.input, StatValues.boosters(reload, coolant.amount, coolantMultiplier, false, this::consumesLiquid));'
    init_header = 'public void init(){'
    super_init = 'super.init();'
    coolant_null_guard = 'if(coolant == null){'
    find_consumer_line = 'coolant = findConsumer(c -> c instanceof ConsumeLiquidBase);'
    progress_header = 'public float progress(){'
    progress_line = 'return 1f - Mathf.clamp(reloadCounter / reload);'
    set_stats_inputs = {
        'stats': a('Array', remove_booster, 'The stats rows, stats (LaserTurret.java:29, `stats.remove(Stat.booster);`): an Array of row dicts {stat, ...} (the N2384 setStats precedent) -- the input is never mutated, the returned rows are fresh.'),
        'coolant': a('Variant', coolant_guard, 'The coolant consumer, coolant (LaserTurret.java:30, `if(coolant != null){`): a Dictionary {amount} (ConsumeLiquidBase, BaseTurret.java:34) or null -- null skips the input row.'),
        'reload': a('float', boosters_line, 'The reload time, reload (LaserTurret.java:31, `stats.add(Stat.input, StatValues.boosters(reload, coolant.amount, coolantMultiplier, false, this::consumesLiquid));`): Turret.reload -- passed to the boosters spec.'),
        'coolant_multiplier': a('float', boosters_line, 'The coolant multiplier, coolantMultiplier (LaserTurret.java:31): a LaserTurret field with default 1f (LaserTurret.java:22, `coolantMultiplier = 1f;`) -- passed to the boosters spec.'),
        'consumes_liquid': a('Callable', boosters_line, 'The consumes-liquid filter, this::consumesLiquid (LaserTurret.java:31): Block.consumesLiquid (Block.java:778, `public boolean consumesLiquid(Liquid liq)`) as the Boolf<Liquid> filter StatValues.boosters takes (StatValues.java:439) -- the driver evaluates it per liquid when rendering the row.'),
    }
    set_stats_outputs = {
        'stats': a('Array', remove_booster, 'The stats rows after setStats (LaserTurret.java:29, `stats.remove(Stat.booster);`): the booster rows dropped, and the input row with the boosters spec appended when coolant exists (LaserTurret.java:31) -- unchanged apart from those two ops.'),
    }
    init_inputs = {
        'coolant': a('Variant', coolant_null_guard, 'The coolant consumer, coolant (LaserTurret.java:39, `if(coolant == null){`): a Dictionary {amount} (ConsumeLiquidBase, BaseTurret.java:34) or null -- when already set the finder never runs.'),
        'found_consumer': a('Variant', find_consumer_line, 'The consumer findConsumer found, findConsumer(c -> c instanceof ConsumeLiquidBase) (LaserTurret.java:40, `coolant = findConsumer(c -> c instanceof ConsumeLiquidBase);`): Block.findConsumer (Block.java:1104) run by the driver -- the first matching consumer, or null when none matches.'),
    }
    init_outputs = {
        'coolant': a('Variant', find_consumer_line, 'The resolved coolant consumer (LaserTurret.java:40, `coolant = findConsumer(c -> c instanceof ConsumeLiquidBase);`): the found consumer when the input was null, the input unchanged otherwise -- null when nothing was found.'),
        'coolant_found': a('bool', coolant_null_guard, 'Whether the finder supplied the coolant (LaserTurret.java:39, `if(coolant == null){`): true exactly when the input coolant was null and a consumer was found.'),
    }
    progress_inputs = {
        'reload_counter': a('float', progress_line, 'The reload counter, reloadCounter (LaserTurret.java:111, `return 1f - Mathf.clamp(reloadCounter / reload);`): the TurretBuild reload counter -- 0 means ready to fire.'),
        'reload': a('float', progress_line, 'The reload time, reload (LaserTurret.java:111): Turret.reload -- the counter is measured against it.'),
    }
    progress_outputs = {
        'progress': a('float', progress_line, 'The reload progress (LaserTurret.java:111, `return 1f - Mathf.clamp(reloadCounter / reload);`): 1 - clamp(reloadCounter / reload, 0, 1) -- 1 when ready, 0 when at or past reload.'),
    }
    return (set_stats_inputs, set_stats_outputs), (init_inputs, init_outputs), (progress_inputs, progress_outputs)


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
    (set_stats_inputs, set_stats_outputs), (init_inputs, init_outputs), (progress_inputs, progress_outputs) = definitions()

    entries = [
        ('N2386', SET_STATS_OWNER, 'source_laser_turret_build_set_stats_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret', 'LaserTurret.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
        ('N2386', INIT_OWNER, 'source_laser_turret_build_init_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret', 'LaserTurret.init()', init_inputs, init_outputs, True, 'Dictionary'),
        ('N2386', PROGRESS_OWNER, 'source_laser_turret_build_progress_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.progress()', progress_inputs, progress_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurret.setStats()+init() + LaserTurretBuild.progress() state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurret.setStats()+init() + LaserTurretBuild.progress() state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: set_stats stats,
    # init coolant + coolant_found, progress progress.
    by_slice['N2386'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2386', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret', java_method='LaserTurret.setStats(); LaserTurret.init(); LaserTurretBuild.progress()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2386'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
