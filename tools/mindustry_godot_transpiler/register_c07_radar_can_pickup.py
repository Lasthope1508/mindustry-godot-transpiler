"""Register the Radar canPickup() accessor (N2318).

RadarBuild.canPickup() (Radar.java:75, `public boolean
canPickup(){` with `return false;`, Radar.java:76)
overrides the base BuildingComp.canPickup()
(BuildingComp.java:1838, `public boolean canPickup(){`
with `return block.canPickup;`, BuildingComp.java:1839)
for Radar: a radar can never be picked up, whatever the
frame holds. The override takes no state, so the pure
function takes the family-convention frame first arg
(every Radar pure function takes it, the write/read
precedent) and ignores it. Pickup is a placement-time
gate, not tick state, so no driver tick line lands here
(the accessor precedent N2311/N2249).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2263 built, following the N2263
progress accessor precedent: (frame) and the accessor
returns the constant false; no per-def param is needed
(the override is unconditional -- no block field is
read). (2) No driver tick line lands here: the accessor
is the read its callers (the pickup gate) share, and
there is no tick that writes a pickup key. (3) One new
result symbol: can_pickup (bool). Slice source:
Radar.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_radar_write_read import DEFERRED as N2310_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
PROOF = '/root/C07RadarCanPickupProof'
CAN_PICKUP_OWNER = 'SourceRadarBuildState.source_radar_can_pickup_state'
TESTS = ['test_c07_radar_can_pickup_registration', 'test_all_c07_radar_can_pickup_input_evidence_is_exact', 'test_radar_can_pickup_state', 'test_reference_graph_and_actual_c07_radar_can_pickup']
# The 1 slice source the N2318 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
]
EXACT_EXPRS = ['public boolean canPickup(){', 'return false;', 'public class Radar extends Block{', 'public class RadarBuild extends Building{']

# DEFERRED is carried from the N2310 register script via import --
# never retyped. One carried entry is DROPPED here, not carried:
# the Radar canPickup row entry -- N2318 IS the canPickup
# slice, so carrying it would leave a stale "waits for its own
# slice" row for done work.
DEFERRED = [e for e in N2310_DEFERRED if 'Radar canPickup row' not in e] + [
    'Radar canPickup Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2248/N2303/N2310: the N2318 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    can_pickup_inputs = {
        'frame': a('Dictionary', 'public boolean canPickup(){', 'The radar frame (RadarBuild.canPickup, Radar.java:75): the family-convention first arg (every Radar pure function takes it); the override takes no state, so the frame is unused.', source=RADAR),
    }
    can_pickup_outputs = {
        'can_pickup': a('bool', 'return false;', 'Whether the radar can be picked up: canPickup() (Radar.java:75-76), `return false;` -- always false, whatever the frame holds; the override flips the base BuildingComp.canPickup() (BuildingComp.java:1838-1839, `return block.canPickup;`).', source=RADAR),
    }
    return can_pickup_inputs, can_pickup_outputs


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
    can_pickup_inputs, can_pickup_outputs = definitions()

    entries = [
        ('N2318', CAN_PICKUP_OWNER, 'source_radar_can_pickup_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.canPickup()', can_pickup_inputs, can_pickup_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar canPickup() accessor from Radar.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar canPickup() accessor from Radar.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_pickup.
    by_slice['N2318'] = [
        'source_radar_can_pickup_state_result.can_pickup',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2318', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.canPickup()', godot_owner=CAN_PICKUP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2318'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
