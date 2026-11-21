"""Register the Turret range() / minRange() / trackingRange() accessors (N2526).

range() / minRange() / trackingRange() are the three
TurretBuild accessors (Turret.java:334-350):
`public float minRange(){` /
`if(peekAmmo() != null){` /
`return minRange + peekAmmo().minRangeChange;` /
`return minRange;` (:334-338) /
`public float range(){` /
`if(peekAmmo() != null){` /
`return range + peekAmmo().rangeChange;` /
`return range;` (:340-346) /
`public float trackingRange(){` /
`return range() + trackingRange - range;` (:348-350),
with the init() normalization (`trackingRange =
Math.max(range, trackingRange);`, Turret.java:217-219)
folded into the function so a raw catalog trackingRange
of 0f (the class default, Turret.java:72, `public float
trackingRange = 0f;` -- no def records trackingRange in
the catalog) does not shrink the tracking range below
range(). `range` is the BaseTurret field (`public float
range = 80f;`, BaseTurret.java:21); `minRange` is the
Turret field (`public float minRange = 0f;`,
Turret.java:74 -- only ripple sets it, `minRange = 50f;`,
Blocks.java:4076); `rangeChange` / `minRangeChange` are
BulletType defaults (`public float rangeChange = 0f;`,
BulletType.java:157; `public float minRangeChange = 0f;`,
:163 -- duo graphite sets `rangeChange = 16f;`,
Blocks.java:3276, copper and silicon leave both at 0f,
:3259-3295; NO def sets minRangeChange today, so the
parameter stays for Java-faithfulness when content
changes). `has_peek_ammo` is `peekAmmo() != null` (the
ammo stack non-empty), NOT `hasAmmo()` (which also folds
canConsume(), Turret.java:705-708); the tick's
`peek_turret_ammo` returns an empty dict when there is no
ammo. The three accessors are ported as ONE pure function
because they share the peekAmmo() read and the same
consumers (`findTarget()`, Turret.java:652-656, `float
trackRange = trackingRange(), range = range();`, and the
updateTile() within-check, :590 -- both consumers are
later slices; findTarget stays BLOCKED). NO driver tick
call site: the frame stamps no `tracking_range` /
`min_range` live keys. The aim inline
(`SourceItemTurretBuildState.gd:506`, `shoot_range =
range + range_change + hit_size / 1.9`) is a
within-check, NOT range() -- left alone; rewiring aim
onto this function is a consumer slice.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_range_state(frame, range_value, min_range,
tracking_range, has_peek_ammo, range_change,
min_range_change), placed immediately AFTER
source_turret_cooling_state (N2525) and BEFORE
source_turret_can_heal_state. It reads no frame key
today (all inputs are parameters) and returns exactly
three keys, `range` / `min_range` / `tracking_range`.
(2) NO tick call site -- the function is DORMANT live
today: the driver tick never calls it, so live behavior
does not change. (3) The trackingRange normalization
(`maxf(range_value, tracking_range)`, Turret.java:217)
lives INSIDE the function, not at the caller: callers
pass raw catalog values (duo trackingRange absent ->
0f) and the raw formula would give `range_out + 0 -
160 = range_change`, which is wrong; Java normalizes
at def init, so the function normalizes too. SSOT
expected after GREEN: symbols +3, Done +1, contracts
+1, schema +2, 11715/1754/1687/3165 -> 11718/1755/1688/3167;
defense shard slices 213 -> 214, contracts 212 -> 213;
comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_cooling import DEFERRED as N2525_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretRangeProof'
RANGE_OWNER = 'SourceTurretBuildState.source_turret_range_state'
TESTS = ['test_c07_turret_range_registration', 'test_all_c07_turret_range_input_evidence_is_exact', 'test_turret_range_state', 'test_reference_graph_and_actual_c07_turret_range']
# The slice sources the N2526 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'if(peekAmmo() != null){',
    'return minRange + peekAmmo().minRangeChange;',
    'return minRange;',
    'return range + peekAmmo().rangeChange;',
    'return range;',
    'return range() + trackingRange - range;',
    'trackingRange = Math.max(range, trackingRange);',
]

# DEFERRED is carried from the N2525 register script via import --
# never retyped. No entry is dropped: the range accessors the
# N2525 pool entry deferred are recorded DONE below. New entries
# below record the accessors as DONE by this slice, the Windows
# proof debt, and the consumers (findTarget / aim within-check)
# that still need wiring onto this function.
DEFERRED = N2525_DEFERRED + [
    'Turret range() / minRange() / trackingRange() accessors (`range` / `min_range` / `tracking_range` frame keys) -- DONE by this slice (N2526): `source_turret_range_state` ports Turret.java:334-350 for the Turret family (minRange fold `minRange + peekAmmo().minRangeChange`, range fold `range + peekAmmo().rangeChange`, trackingRange `range() + trackingRange - range` with the init() normalization `trackingRange = Math.max(range, trackingRange);`, Turret.java:217-219, folded in), mirroring the N2525 pure-function-only pattern. NO driver tick call site: the frame stamps no `tracking_range` / `min_range` live keys and the consumers (findTarget, Turret.java:652-656, and the updateTile() within-check, :590) are later slices. Dormant live today: the driver tick never calls the function, so live behavior does not change.',
    'Turret range() / minRange() / trackingRange() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525: the N2526 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret range() consumers still DEFERRED (after N2526): `findTarget()` (`float trackRange = trackingRange(), range = range();`, Turret.java:652-656) stays BLOCKED on the live entity scan, and the updateTile() within-check (`within(target, range() + hitSize/1.9f)`, Turret.java:590) plus the aim inline (`SourceItemTurretBuildState.gd:506`, `shoot_range = range + range_change + hit_size / 1.9`, a within-check, NOT range()) wait for consumer slices that call `source_turret_range_state` and stamp its results onto the frame.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    range_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (the port Building state) the tick stamps every tick (`public void updateTile(){`, Turret.java:490 -- the driver tick for every Turret-family build); passed for the SourceTurretBuildState pure-function signature convention -- this function reads no frame key today (all inputs are parameters) and stamps nothing; the consumers (findTarget, the updateTile() within-check) stamp the results onto the frame in later slices.', source=TURRET),
        'range_value': a('float', 'public float range = 80f;', 'The def range in tiles * 8 (`public float range = 80f;`, BaseTurret.java:21 -- the class default; duo 160, scatter 220.0, salvo 190.0, foreshadow 500.0, hail 235.0, lancer 165.0, ripple 290.0, smite 300, malign 410, Blocks.java / content_registry.json).', source=BASE_TURRET),
        'min_range': a('float', 'public float minRange = 0f;', 'The def minimum bullet range (`public float minRange = 0f;`, Turret.java:74 -- the class default; only ripple sets it, `minRange = 50f;`, Blocks.java:4076).'),
        'tracking_range': a('float', 'public float trackingRange = 0f;', 'The def tracking range (`public float trackingRange = 0f;`, Turret.java:72 -- the class default; no def records it in the catalog, so it arrives as 0f and the function normalizes it with `maxf(range_value, tracking_range)` per the init() normalization, Turret.java:217-219; smite and malign set `trackingRange = range * 1.4f;`, Blocks.java:5913/:6256).'),
        'has_peek_ammo': a('bool', 'if(peekAmmo() != null){', 'Whether peekAmmo() returns an ammo type (`if(peekAmmo() != null){`, Turret.java:335/:343 -- the ammo stack non-empty), NOT hasAmmo() (which also folds canConsume(), Turret.java:705-708); the tick `peek_turret_ammo` returns an empty dict when there is no ammo.'),
        'range_change': a('float', 'public float rangeChange = 0f;', 'The peeked ammo range delta (`public float rangeChange = 0f;`, BulletType.java:157 -- the class default; duo graphite sets `rangeChange = 16f;`, Blocks.java:3276, copper and silicon leave it at 0f, :3259-3295).', source=BULLET_TYPE),
        'min_range_change': a('float', 'public float minRangeChange = 0f;', 'The peeked ammo minimum-range delta (`public float minRangeChange = 0f;`, BulletType.java:163 -- the class default; NO def sets it today, so the parameter stays for Java-faithfulness when content changes).', source=BULLET_TYPE),
    }
    range_outputs = {
        'range': a('float', 'return range + peekAmmo().rangeChange;', 'The effective range (`return range + peekAmmo().rangeChange;`, Turret.java:344, with `return range;`, :346, when there is no peeked ammo).'),
        'min_range': a('float', 'return minRange + peekAmmo().minRangeChange;', 'The effective minimum range (`return minRange + peekAmmo().minRangeChange;`, Turret.java:336, with `return minRange;`, :338, when there is no peeked ammo).'),
        'tracking_range': a('float', 'return range() + trackingRange - range;', 'The effective tracking range (`return range() + trackingRange - range;`, Turret.java:350 -- `range()` already folded with the ammo, minus the `range` field, plus the init-normalized `trackingRange`, Turret.java:217-219).'),
    }
    return range_inputs, range_outputs


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
    range_inputs, range_outputs = definitions()

    entries = [
        ('N2526', RANGE_OWNER, 'source_turret_range_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.range()', range_inputs, range_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret range() / minRange() / trackingRange() accessors from Turret.java:334-350 + :217-219 + BaseTurret.java:21 + BulletType.java:157/:163 + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret range() / minRange() / trackingRange() accessors from Turret.java:334-350 + :217-219 + BaseTurret.java:21 + BulletType.java:157/:163 + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: range, min_range,
    # tracking_range.
    by_slice['N2526'] = [
        'source_turret_range_state_result.range',
        'source_turret_range_state_result.min_range',
        'source_turret_range_state_result.tracking_range',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2526', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.range()', godot_owner=RANGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2526'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
