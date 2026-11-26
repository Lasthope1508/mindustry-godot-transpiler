"""Register BuildTurretBuild.canControl() (N2480).

BuildTurretBuild.canControl() (BuildTurret.java:103-105) is one
slice (batch 52 slot 2):
    @Override
    public boolean canControl(){
        return true;
    }
on `public class BuildTurretBuild extends BaseTurretBuild
implements ControlBlock, RotBlock{` (BuildTurret.java:92).
The build tower is ALWAYS controllable -- ControlBlock with
no gate -- so the method returns the constant true and reads
NO state: no unit, no player, no logic, no block field. It
takes no params, so no input schema is upserted (the N2422
zero-param contract precedent: `source_laser_turret_build_placed_state_result`
exists with no `_input` schema; 82 contracts in the ledger
have 0 params). One new result symbol: can_control.

TRAP: this is NOT TurretBuild.canControl() (N2297,
Turret.java:376-378, `return playerControllable;` -- the
block-level field `public boolean playerControllable =
true;`, Turret.java:97, "If true, this turret can be
controlled by players.", which a def can set false): a block
with playerControllable = false still returns true here and
false in N2297. TRAP: this is NOT TurretBuild.controlled()
(N2324/N2523, `return unit.isPlayer();`) -- canControl is
about the block being controllable, controlled is about who
holds it now. Java order: canControl (:103-105) stands
BEFORE buildRotation (:107-110, N2477) in the same class, so
the GD function sits before source_build_turret_build_rotation_state
in SourceBuildTurretBuildState.gd.

TWIN-REGISTER -- approved explicitly by the main thread
for N2480 (2026-11-27). The body literal `public boolean
canControl(){` is ALREADY an exact_expr of N2184
(BuildTurretBuild.updateTile, owner GD
SourceBuildTurretBuildState.source_build_turret_power_status_row_state),
which cites the BuildTurret.java:103-110 rows (canControl +
buildRotation) only as dependency evidence -- N2184 ports
NO canControl function (its godot_owner is the power-status
row state), and its own deferred_exprs say "BuildTurret
unit rows (... canControl / buildRotation,
BuildTurret.java:103-110; ...) -- unit creation + control
waits for its own slice", i.e. N2184 itself declares
canControl waits for its own slice. This is the SAME
deferred sentence that approved the twin-register for N2477
(buildRotation, same :103-110 cluster). The second literal
hit, N2297 (TurretBuild.canControl, TurretBuild -- the
parent-class method with the `return playerControllable;`
body), is a different method in a different class, not this
one. The body line `return true;` is a generic constant
line (45 exact_expr hits across slices) and is NOT twin
evidence -- it is registered here only as the verbatim body
of this method. java_method `BuildTurretBuild.canControl()`
is 0-hit and no GD function computes it yet, so this slice
adds a real new GD function -- NOT a duplicate like
TeamData.active(), which was permanently excluded because
its behaviour was already ported by N2074/N2075. Precedent
for twin registration with explicit main-thread approval:
N2474 (isCampaign, literal owned by N2124), N2477
(buildRotation, literal owned by N2184), N2421
(`return isShooting;`), N2389, N2418. One slice source:
BuildTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
PROOF = '/root/C07BuildTurretCanControlProof'
CAN_CONTROL_OWNER = 'SourceBuildTurretBuildState.source_build_turret_can_control_state'
TESTS = ['test_c07_build_turret_can_control_registration', 'test_all_c07_build_turret_can_control_input_evidence_is_exact', 'test_build_turret_can_control_state', 'test_reference_graph_and_actual_c07_build_turret_can_control']
# The 1 slice source the N2480 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
]
FORMULA = '            return true;'
EXACT_EXPRS = [
    '        public boolean canControl(){',
    FORMULA,
    '    public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{',
]
JAVA_METHOD = 'BuildTurretBuild.canControl()'

DEFERRED = [
    'BuildTurretBuild.canControl() Windows Godot proof -- debt in GOAL.md section 5: the N2480 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildTurretBuild.canControl() is a TWIN-REGISTER with explicit main-thread approval (2026-11-27): the literal `public boolean canControl(){` is also an exact_expr of N2184 (BuildTurretBuild.updateTile), which cites the BuildTurret.java:103-110 rows only as dependency evidence and ports no canControl function; N2184 is the original owner of the literal, and its own deferred_exprs say canControl "waits for its own slice". The same deferred sentence approved the twin-register for N2477 (buildRotation, same :103-110 cluster). The second literal hit, N2297 (TurretBuild.canControl, `return playerControllable;`), is a different method in a different class. The body line `return true;` is a generic constant line (45 exact_expr hits) and is NOT twin evidence. Precedent: N2474, N2477, N2421, N2389, N2418.',
    'TurretBuild.canControl() (Turret.java:376-378, N2297, `return playerControllable;`) is NOT in this slice: it is the parent-class method whose result follows the block-level `playerControllable` field (Turret.java:97, default true) -- a block with playerControllable = false returns false there and true here; the proof pins the cross-trap.',
    'TurretBuild.controlled() (Turret.java:441-443, N2324/N2523, `return unit.isPlayer();`) is NOT in this slice: canControl is about the block being controllable, controlled is about who holds it now.',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    # Zero params: canControl() takes no state -- no input schema
    # is registered (the N2422 zero-param contract precedent).
    can_control_inputs = {}
    can_control_outputs = {
        'can_control': a('bool', FORMULA, 'Whether the build tower can be controlled (BuildTurret.java:103-105, `return true;`): BuildTurretBuild implements ControlBlock (BuildTurret.java:92) with no gate, so the method always returns true -- it reads no unit, no player, no logic, and NOT the block-level `playerControllable` field (Turret.java:97) that TurretBuild.canControl() (N2297) follows.'),
    }
    return can_control_inputs, can_control_outputs


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
    can_control_inputs, can_control_outputs = definitions()

    entries = [
        ('N2480', CAN_CONTROL_OWNER, 'source_build_turret_can_control_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', JAVA_METHOD, can_control_inputs, can_control_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            # Zero params: skip the input schema entirely (the
            # N2422 precedent) -- an empty keys object fails
            # state-schema validation.
            if not keys:
                continue
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.canControl() state from BuildTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.canControl() state from BuildTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2480'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2480', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method=JAVA_METHOD, godot_owner=CAN_CONTROL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2480'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
