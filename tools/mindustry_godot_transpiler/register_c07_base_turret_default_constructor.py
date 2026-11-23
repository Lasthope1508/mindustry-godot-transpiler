"""Register the BaseTurret(String name) ctor field defaults (N2405).

BaseTurret(String name) (BaseTurret.java:36-46, `public
BaseTurret(String name){`) assigns 4 literal field defaults
on the BaseTurret def: `outlineIcon = true;` (:41),
`attacks = true;` (:42), `priority =
TargetPriority.turret;` (:43) and `flags =
EnumSet.of(BlockFlag.turret);` (:45). The other ctor lines
are NOT in this slice and are never re-registered:
`super(name);` is already the exact_expr of N2185,
`update = true;` of 22 slices, `solid = true;` of 11
slices, `group = BlockGroup.turrets;` of N2184 (all
0-hit re-probed at HEAD 5ffcadd1, local + remote
ledgers). One GD function on the NEW
SourceBaseTurretDefaults.gd (the BaseTurret def-defaults
file, NOT SourceTurretBuildState.gd, which is the
TurretBuild file) -- the Turret ctor batch 25 precedent
(owner `source_turret_default_constructor_state` on
SourceTurretDefaults.gd). `TargetPriority.turret` is the
float constant 1f (TargetPriority.java,
core/src/mindustry/entities/TargetPriority.java) and
Block.priority is a float field defaulting to
TargetPriority.base = 0f (Block.java:253), so the priority
default is the float literal 1.0, NOT an enum param.
`EnumSet.of(BlockFlag.turret)` is the block-flag enum
value (`turret` -- "Any turret.", BlockFlag.java,
core/src/mindustry/world/meta/BlockFlag.java) -- it
arrives as an explicit Variant param, NOT re-ported (the
N2401 BeamDrill ctor precedent). The Block base defaults
the ctor overrides are `public boolean outlineIcon =
false;` (Block.java:313), `public boolean attacks =
false;` (Block.java:305) and `public EnumSet<BlockFlag>
flags = EnumSet.of();` (Block.java:251). The defaults
are frame data only (bool/float literals + one enum
param); no Draw is ported, and the proof asserts frame
defaults, never a real render. Five new result symbols:
one per default plus the updated def frame. Four slice
sources: BaseTurret.java + Block.java + BlockFlag.java +
TargetPriority.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_default_constructor import DEFERRED as N2400_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCK_FLAG = 'core/src/mindustry/world/meta/BlockFlag.java'
TARGET_PRIORITY = 'core/src/mindustry/entities/TargetPriority.java'
PROOF = '/root/C07BaseTurretDefaultConstructorProof'
CTOR_OWNER = 'SourceBaseTurretDefaults.source_base_turret_default_constructor_state'
TESTS = ['test_c07_base_turret_default_constructor_registration', 'test_all_c07_base_turret_default_constructor_input_evidence_is_exact', 'test_base_turret_default_constructor_state', 'test_reference_graph_and_actual_c07_base_turret_default_constructor']
# The 4 slice sources the N2405 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/meta/BlockFlag.java',
    'core/src/mindustry/entities/TargetPriority.java',
]
EXACT_EXPRS = [
    'outlineIcon = true;',
    'attacks = true;',
    'priority = TargetPriority.turret;',
    'flags = EnumSet.of(BlockFlag.turret);',
]

# DEFERRED is carried from the N2400 register script via import --
# never retyped. Nothing in it closes here: N2405 ports the
# BaseTurret() ctor field defaults, which no N2400 entry lists.
# One entry is added: the N2405 Windows Godot proof debt
# (GOAL.md section 5).
DEFERRED = list(N2400_DEFERRED) + [
    'BaseTurret() ctor field defaults N2405 Windows Godot proof -- debt in GOAL.md section 5, same as N2400: the N2405 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BASE_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_inputs = {
        'base_turret_defaults': a('Dictionary', 'public BaseTurret(String name){', 'The BaseTurret def frame (BaseTurret.java:36, `public BaseTurret(String name){`): the family-convention first arg; the ctor writes its 4 literal field defaults into it, so base_turret_defaults is an in/out param -- keys already present keep their unrelated values, the 4 ctor keys are overwritten with the ctor literals.'),
        'block_flags': a('Variant', 'flags = EnumSet.of(BlockFlag.turret);', 'The block flags (BaseTurret.java:45, `flags = EnumSet.of(BlockFlag.turret);`): the block-flag enum value (`turret` -- "Any turret.", BlockFlag.java, core/src/mindustry/world/meta/BlockFlag.java) -- EnumSet is NOT ported here: it arrives as an explicit Variant param and passes through to the result flags key; the Block base default it overrides is `public EnumSet<BlockFlag> flags = EnumSet.of();` (Block.java:251).'),
    }
    ctor_outputs = {
        'outline_icon': a('bool', 'outlineIcon = true;', 'Whether the block draws its outline icon (BaseTurret.java:41, `outlineIcon = true;`): Block.outlineIcon; the ctor enables it for base turrets, overriding the Block base default (`public boolean outlineIcon = false;`, Block.java:313).'),
        'attacks': a('bool', 'attacks = true;', 'Whether the block attacks (BaseTurret.java:42, `attacks = true;`): Block.attacks; the ctor enables it for base turrets, overriding the Block base default (`public boolean attacks = false;`, Block.java:305).'),
        'priority': a('float', 'priority = TargetPriority.turret;', 'The targeting priority of this block, as seen by enemies (BaseTurret.java:43, `priority = TargetPriority.turret;`): Block.priority is a float field defaulting to TargetPriority.base = 0f (Block.java:253); TargetPriority.turret is the float constant 1f (TargetPriority.java, core/src/mindustry/entities/TargetPriority.java), so the ctor literal is the float 1.0 -- turrets deal damage so they are more important.'),
        'flags': a('Variant', 'flags = EnumSet.of(BlockFlag.turret);', 'The block flags, read through (BaseTurret.java:45, `flags = EnumSet.of(BlockFlag.turret);`): the block-flag enum value passed in as block_flags; the Block base default it overrides is `public EnumSet<BlockFlag> flags = EnumSet.of();` (Block.java:251).'),
        'base_turret_defaults': a('Dictionary', 'public BaseTurret(String name){', 'The updated BaseTurret def frame (BaseTurret.java:36, `public BaseTurret(String name){`): the same in/out Dictionary -- unrelated keys preserved, the 4 ctor keys written with the ctor literals.'),
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
        ('N2405', CTOR_OWNER, 'source_base_turret_default_constructor_state', BASE_TURRET, 'mindustry.world.blocks.defense.turrets.BaseTurret', 'BaseTurret(String name)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BaseTurret() ctor field defaults state from BaseTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BaseTurret() ctor field defaults state from BaseTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the 4 defaults in ctor
    # order, then the updated def frame.
    by_slice['N2405'] = [
        'source_base_turret_default_constructor_state_result.outline_icon',
        'source_base_turret_default_constructor_state_result.attacks',
        'source_base_turret_default_constructor_state_result.priority',
        'source_base_turret_default_constructor_state_result.flags',
        'source_base_turret_default_constructor_state_result.base_turret_defaults',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2405', dict(status='done', java_source=BASE_TURRET, java_class='mindustry.world.blocks.defense.turrets.BaseTurret', java_method='BaseTurret(String name)', godot_owner=CTOR_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2405'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
