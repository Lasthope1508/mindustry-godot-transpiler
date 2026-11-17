"""Register the RepairTurret init() updateClipRadius call-arg (N2226).

RepairTurret.init() (RepairTurret.java:83-92, `public void
init(){`) pins the clip radius with one call
(`updateClipRadius(repairRadius + tilesize);` --
RepairTurret.java:90). The other init() legs are NOT this
slice: the coolant leg (`if(acceptCoolant){ hasLiquids =
true; consume(new ConsumeCoolant(coolantUse)).optional(true,
true); }` -- :84-86) registers a coolant consumer and waits
for its own slice; the power leg (`consumePowerCond(powerUse,
(RepairPointBuild entity) -> entity.target != null);` --
:89) registers a power-condition consumer and waits for its
own slice; `super.init();` (:91) is Block.init internals,
deferred (the N1234 TractorBeamTurret.init() precedent:
"Inherited BaseTurret.init internals and
Block.updateClipRadius side effects remain deferred; this
slice records the exact TractorBeamTurret updateClipRadius
argument"). The Block.updateClipRadius side effect itself
(`clipSize = Math.max(clipSize, this.size * tilesize +
radiusInWorldUnits * 2f);`, Block.java:1007) is likewise
deferred -- this slice pins only the call argument.

RED decisions (resolved at RED): (1) One pure function on
the same family file N2174 / N2188 / N2209 / N2212-N2215 /
N2217 / N2219-N2225 built:
source_repair_turret_init_state(repair_radius, tilesize)
returning clip_radius (repair_radius + tilesize). Both
params are explicit floats (the N2212 acquire / N2220
draw-place / N2223 sense per-def-param precedent:
repairRadius is per-def static state, not a live frame key;
tilesize is the Vars constant, Vars.java:135, `public
static final int tilesize = 8;`). (2) There is NO driver
tick line: init() runs once at block init, not per tick
(the N2217 read/write + N2224 setStats lifecycle
precedent). One new result symbol: clip_radius. Slice
sources: RepairTurret.java + Blocks.java + Vars.java +
Block.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_draw import DEFERRED as N2225_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretInitProof'
INIT_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_init_state'
TESTS = ['test_c07_repair_turret_init_registration', 'test_all_c07_repair_turret_init_input_evidence_is_exact', 'test_repair_turret_init_state', 'test_reference_graph_and_actual_c07_repair_turret_init']
# The 4 slice sources the N2226 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = ['public void init(){', 'updateClipRadius(repairRadius + tilesize);', 'public float repairRadius = 50f;', 'repairRadius = 60f;', 'repairRadius = 145f;', 'public static final int tilesize = 8;', 'public void updateClipRadius(float radiusInWorldUnits){', 'clipSize = Math.max(clipSize, this.size * tilesize + radiusInWorldUnits * 2f);', 'public class RepairTurret extends Block{', 'super.init();']

# DEFERRED is carried from the N2225 register script via import --
# never retyped. The N2225 script's DEFERRED is a computed
# expression (list comprehension over the N2224 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. NOTE for the next
# slice: N2226's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval.
# One carried entry is DROPPED here, not carried: the N2225
# entry deferring the RepairTurret init() updateClipRadius call
# to "its own slice (N2226)" -- N2226 IS that slice, so carrying
# it would leave a stale "waits for its own slice" row for done
# work. Every other carried entry still waits for its own slice.
DEFERRED = [e for e in N2225_DEFERRED if 'init() updateClipRadius' not in e] + [
    'RepairTurret init() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2225: the N2226 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    init_inputs = {
        'repair_radius': a('float', 'public float repairRadius = 50f;', 'The per-def repairRadius in world units (RepairTurret.java:32, `public float repairRadius = 50f;`, the class default; repair-point 60f, Blocks.java:6389, `repairRadius = 60f;`, repair-turret 145f, Blocks.java:6401, `repairRadius = 145f;`); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly because the pure function takes the init() call argument as args, not a frame.', source=VARS),
    }
    init_outputs = {
        'clip_radius': a('float', 'updateClipRadius(repairRadius + tilesize);', 'The updateClipRadius call argument: repairRadius + tilesize (RepairTurret.java:90, `updateClipRadius(repairRadius + tilesize);`); class default 50f + 8 = 58.0, repair-point 60f + 8 = 68.0, repair-turret 145f + 8 = 153.0. The Block.updateClipRadius side effect (`clipSize = Math.max(clipSize, this.size * tilesize + radiusInWorldUnits * 2f);`, Block.java:1007) is deferred (the N1234 precedent) -- only the call argument is pinned.'),
    }
    return init_inputs, init_outputs


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
    init_inputs, init_outputs = definitions()

    entries = [
        ('N2226', INIT_OWNER, 'source_repair_turret_init_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret', 'RepairTurret.init()', init_inputs, init_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret init() state from RepairTurret.java + Blocks.java + Vars.java + Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret init() state from RepairTurret.java + Blocks.java + Vars.java + Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: clip_radius.
    by_slice['N2226'] = [
        'source_repair_turret_init_state_result.clip_radius',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2226', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret', java_method='RepairTurret.init()', godot_owner=INIT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2226'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
