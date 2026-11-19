"""Register the TurretBuild.canConsume() heat gate (N2272).

The deferred item named in the N2270/N2271 handoffs:
"TurretBuild.canConsume() heat gate (Turret.java:623-628) --
waits for its own slice; the driver still has no
shouldConsume gate, so an unheated afflict/malign folds
efficiency to 0 through the fold but is not yet gated out
of consuming."

The gate (Turret.java:623-629, inside TurretBuild):
`public boolean canConsume(){`
`if(heatRequirement > 0 && heatReq <= 0f){`
`return false;`
`}`
`return super.canConsume();`
`}`
`heatRequirement` defaults to -1 (Turret.java:52-53, `/**
Minimum input heat required to fire. */ public float
heatRequirement = -1f;`) and `heatReq` is the live
per-build field (Turret.java:295, `public float heatReq;`),
recomputed by calculateHeat -- which stays BLOCKED (live
proximity scan, BuildingComp.java:410-461), so this slice
models the gate purely and takes heat_req as a live input
parameter. Only afflict (`heatRequirement = 20f;`,
Blocks.java:5122) and malign (`heatRequirement = 144f;`,
Blocks.java:6240) set a positive requirement among turrets
-- the other Blocks.java setters (surge crucible, cyanogen
/ phase synthesizer) are HeatCrafter blocks, not turrets.
Every other turret reads the -1 default, so the gate
passes through super.canConsume() unchanged.

This slice follows the N2268/N2269/N2271 event-driven
pattern: one pure function,
source_turret_can_consume_heat_gate_state(heat_requirement,
heat_req, super_can_consume), returning {can_consume} --
false exactly when heat_requirement > 0 and heat_req <= 0
(the :625 guard), super_can_consume otherwise (the :628
pass-through). NO driver tick: canConsume() is evaluated
per consumption check, not per tick, and the driver has no
shouldConsume gate yet. The catalog values come from N2270
-- no extractor change in this slice. SSOT expected after
GREEN: symbols +1, Done +1, contracts +1, schema +2,
11643/1721/1655/3101 -> 11644/1722/1656/3103; defense shard
slices 198 -> 199, contracts 197 -> 198.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_charge_state import DEFERRED as N2271_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretCanConsumeHeatGateProof'
HEAT_GATE_OWNER = 'SourceTurretBuildState.source_turret_can_consume_heat_gate_state'
TESTS = ['test_c07_turret_can_consume_heat_gate_registration', 'test_all_c07_turret_can_consume_heat_gate_input_evidence_is_exact', 'test_turret_can_consume_heat_gate', 'test_reference_graph_and_actual_c07_turret_can_consume_heat_gate']
# The slice sources the N2272 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public float heatRequirement = -1f;', 'Minimum input heat required to fire.', 'public float heatReq;', 'public boolean canConsume(){', 'if(heatRequirement > 0 && heatReq <= 0f){', 'return false;', 'return super.canConsume();', 'heatRequirement = 20f;', 'heatRequirement = 144f;', 'afflict = new PowerTurret("afflict"){{', 'malign = new PowerTurret("malign"){{']

# DEFERRED is carried from the N2271 register script via import --
# never retyped. The canConsume() heat gate is done by this slice
# (it was the next item named in the N2270/N2271 handoffs); the
# charge effect, calculateHeat live scan, findTarget,
# maxHealth/health re-sync, set(tile) world position and the other
# ItemTurret defs still wait.
DEFERRED = list(N2271_DEFERRED) + [
    'TurretBuild.canConsume() heat gate -- DONE by this slice (N2272); it was the next item named in the N2270/N2271 handoffs. The pure gate returns false exactly when heat_requirement > 0 and heat_req <= 0 (Turret.java:625), and passes through super.canConsume() otherwise (Turret.java:628). No driver tick: canConsume() is evaluated per consumption check, not per tick, and the driver has no shouldConsume gate yet. The catalog values come from N2270 (afflict 20f, malign 144f); heat_req stays a live input because calculateHeat is still BLOCKED (live proximity scan).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    heat_gate_inputs = {
        'heat_requirement': a('float', 'public float heatRequirement = -1f;', 'The turret heat requirement in heat units (Turret.java:52-53, the class default -1; the catalog value when the block carries one -- 20.0 for afflict, Blocks.java:5122; 144.0 for malign, Blocks.java:6240).'),
        'heat_req': a('float', 'public float heatReq;', 'The live per-build heat input (Turret.java:295), recomputed by calculateHeat from nearby heaters; taken as a live input because calculateHeat is still BLOCKED (live proximity scan).'),
        'super_can_consume': a('bool', 'return super.canConsume();', 'The superclass canConsume() result passed in (Turret.java:628): the gate returns it unchanged unless the heat guard closes.'),
    }
    heat_gate_outputs = {
        'can_consume': a('bool', 'if(heatRequirement > 0 && heatReq <= 0f){', 'Whether the turret may consume (Turret.java:623-629 -- false exactly when heat_requirement > 0 and heat_req <= 0; super_can_consume otherwise).'),
    }
    return heat_gate_inputs, heat_gate_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    heat_gate_inputs, heat_gate_outputs = definitions()

    entries = [
        ('N2272', HEAT_GATE_OWNER, 'source_turret_can_consume_heat_gate_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.canConsume()', heat_gate_inputs, heat_gate_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.canConsume() heat gate from Turret.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.canConsume() heat gate from Turret.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_consume.
    by_slice['N2272'] = [
        'source_turret_can_consume_heat_gate_state_result.can_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2272', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.canConsume()', godot_owner=HEAT_GATE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2272'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
