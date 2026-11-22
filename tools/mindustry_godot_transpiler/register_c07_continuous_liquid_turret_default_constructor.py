"""Register the ContinuousLiquidTurret(String name) ctor field default (N2413).

ContinuousLiquidTurret(String name) (ContinuousLiquidTurret.java:17-24,
`public ContinuousLiquidTurret(String name){`) assigns 1 distinguishing
field default on the ContinuousLiquidTurret def: `loopSound =
Sounds.loopMineBeam;` (:20). The other ctor lines are NOT in this slice
and are never re-registered: `super(name);` is already the exact_expr of
N2185, `hasLiquids = true;` of N927/N2000/N2179/N2182/N2209, and
`shootSound = Sounds.none;` / `smokeEffect = Fx.none;` / `shootEffect =
Fx.none;` of N2406 (LiquidTurret ctor) -- all 0-hit re-probed at HEAD
2a31a3fb, local + remote ledgers. One GD function on
SourceContinuousLiquidTurretBuildState.gd (the ContinuousLiquidTurret
def-defaults file, NOT a new file -- main-thread decision batch 29,
N2406 precedent). The value is a Sound reference, NOT a literal: it
arrives as an explicit Variant param and passes through (the N2405
BaseTurret ctor precedent for `EnumSet.of(BlockFlag.turret)`). The Turret
base default the ctor overrides is `public Sound loopSound =
Sounds.none;` (Turret.java:128). The default is frame data only; no Draw
is ported, and the ambient-sound driver (N2304, HELD) is untouched. Two
new result symbols: the default plus the updated def frame. One slice
source: ContinuousLiquidTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_liquid_turret_default_constructor import DEFERRED as N2406_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_LIQUID_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java'
PROOF = '/root/C07ContinuousLiquidTurretDefaultConstructorProof'
CTOR_OWNER = 'SourceContinuousLiquidTurretBuildState.source_continuous_liquid_turret_default_constructor_state'
TESTS = ['test_c07_continuous_liquid_turret_default_constructor_registration', 'test_all_c07_continuous_liquid_turret_default_constructor_input_evidence_is_exact', 'test_continuous_liquid_turret_default_constructor_state', 'test_reference_graph_and_actual_c07_continuous_liquid_turret_default_constructor']
# The 1 slice source the N2413 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java',
]
EXACT_EXPRS = [
    'loopSound = Sounds.loopMineBeam;',
]

# DEFERRED is carried from the N2406 register script via import --
# never retyped. Nothing in it closes here: N2413 ports the
# ContinuousLiquidTurret() ctor field default, which no N2406 entry
# lists. One entry is added: the N2413 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = list(N2406_DEFERRED) + [
    'ContinuousLiquidTurret() ctor field default N2413 Windows Godot proof -- debt in GOAL.md section 5, same as N2406: the N2413 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_LIQUID_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_inputs = {
        'continuous_liquid_turret_defaults': a('Dictionary', 'public ContinuousLiquidTurret(String name){', 'The ContinuousLiquidTurret def frame (ContinuousLiquidTurret.java:17, `public ContinuousLiquidTurret(String name){`): the family-convention first arg; the ctor writes its 1 field default into it, so continuous_liquid_turret_defaults is an in/out param -- keys already present keep their unrelated values, the ctor key is overwritten with the ctor value.'),
        'loop_sound': a('Variant', 'loopSound = Sounds.loopMineBeam;', 'The loop sound (ContinuousLiquidTurret.java:20, `loopSound = Sounds.loopMineBeam;`): Turret.loopSound; the Sound reference arrives as an explicit Variant param and passes through to the result loop_sound key; the Turret base default it overrides is `public Sound loopSound = Sounds.none;` (Turret.java:128).'),
    }
    ctor_outputs = {
        'loop_sound': a('Variant', 'loopSound = Sounds.loopMineBeam;', 'The loop sound, read through (ContinuousLiquidTurret.java:20, `loopSound = Sounds.loopMineBeam;`): the Sound reference passed in as loop_sound; the continuous liquid turret loops the mining beam sound while firing.'),
        'continuous_liquid_turret_defaults': a('Dictionary', 'public ContinuousLiquidTurret(String name){', 'The updated ContinuousLiquidTurret def frame (ContinuousLiquidTurret.java:17, `public ContinuousLiquidTurret(String name){`): the same in/out Dictionary -- unrelated keys preserved, the ctor key written with the ctor value.'),
    }
    return ctor_inputs, ctor_outputs


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
    ctor_inputs, ctor_outputs = definitions()

    entries = [
        ('N2413', CTOR_OWNER, 'source_continuous_liquid_turret_default_constructor_state', CONTINUOUS_LIQUID_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret', 'ContinuousLiquidTurret(String name)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret() ctor field default state from ContinuousLiquidTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret() ctor field default state from ContinuousLiquidTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the default first, then the
    # updated def frame.
    by_slice['N2413'] = [
        'source_continuous_liquid_turret_default_constructor_state_result.loop_sound',
        'source_continuous_liquid_turret_default_constructor_state_result.continuous_liquid_turret_defaults',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2413', dict(status='done', java_source=CONTINUOUS_LIQUID_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret', java_method='ContinuousLiquidTurret(String name)', godot_owner=CTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2413'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
