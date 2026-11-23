"""Register the PayloadTurret getAmmoContent() (N2368).

PayloadTurretBuild.getAmmoContent()
(PayloadAmmoTurret.java:148-157, `public
UnlockableContent getAmmoContent(){` /
`if(!payloads.isEmpty()){` / `for(var content :
ammoKeys){` / `if(payloads.contains(content)){` /
`return content;` / `return null;`) is one pure
function on the existing
SourcePayloadAmmoTurretBuildPortBridge.gd (created by N2358
for currentAmmo), following the ContinuousTurret PortBridge
precedent (SourceContinuousTurretBuildPortBridge.gd, N2355)
and the ItemTurret PortBridge precedent
(SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state). It
returns the first ammo key (in ammoKeys order) whose
content is currently held in the payloads seq -- but ONLY
when the payloads seq is non-empty -- or null when
payloads is empty or none matches.

RED decisions (resolved at RED): (1) The function lives
in the existing PortBridge file: there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2358 PortGame.source_payload_ammo_turret_build_current_ammo_state,
N2363 PortGame.source_payload_ammo_turret_build_use_ammo_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) The `if(!payloads.isEmpty()){` guard is ported
literally as `if not payload_contents.is_empty():`
wrapping the scan: the payloads seq arrives reduced to
its contents as the explicit payload_contents param (the
N2330 param precedent), so the guard reads the param's
emptiness. The guard is behaviorally redundant (an empty
seq scans to null anyway) but it is the slice's
distinguishing line and is kept verbatim in structure.
(3) Content refs are plain strings (content names); the
result is the matching name or null. NO ammoTypes param:
unlike useAmmo, getAmmoContent never touches ammoTypes.
(4) NO driver line: a pure accessor the HUD / ammo
display caller reads, not a per-tick write; the caller
wiring waits for its own slice.
(5) Evidence, not ownership: the `for(var content :
ammoKeys){` line also appears at
PayloadAmmoTurret.java:98/:123/:134 in other methods and
`return null;` is shared with the N2358 currentAmmo, the
N2363 useAmmo and the N2348 base getAmmoContent -- shared
text, not ownership of those methods. The distinguishing
line against currentAmmo in the same class is
`if(!payloads.isEmpty()){` -- currentAmmo scans
unconditionally, getAmmoContent scans only inside the
non-empty guard; same returned value, different body, NO
dedup. Against useAmmo (N2363): getAmmoContent has NO
`payloads.remove(content);` and NO
`return ammoTypes.get(content);` -- it does not remove
and does not return a BulletType. The other
getAmmoContent-adjacent methods own their own bodies --
peekAmmo waits for its own slice, getAmmoFraction is a
separate method -- and are NOT touched here. One new
result symbol: ammo_content. Slice source:
PayloadAmmoTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_ammo_turret_use_ammo import DEFERRED as N2363_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadAmmoTurretGetAmmoContentProof'
GET_AMMO_CONTENT_OWNER = 'PortGame.source_payload_ammo_turret_build_get_ammo_content_state'
TESTS = ['test_c07_payload_ammo_turret_get_ammo_content_registration', 'test_all_c07_payload_ammo_turret_get_ammo_content_input_evidence_is_exact', 'test_payload_ammo_turret_get_ammo_content_state', 'test_reference_graph_and_actual_c07_payload_ammo_turret_get_ammo_content']
# The 1 slice source the N2368 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    'public PayloadSeq payloads = new PayloadSeq();',
    'ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);',
    'public UnlockableContent getAmmoContent(){',
    'if(!payloads.isEmpty()){',
    'for(var content : ammoKeys){',
    'if(payloads.contains(content)){',
    'return content;',
    'return null;',
]

# DEFERRED is carried from the N2363 register script via import --
# never retyped. This slice closes none of the carried entries;
# it only adds its own Windows-proof debt entry.
DEFERRED = list(N2363_DEFERRED) + [
    'PayloadTurret getAmmoContent Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2368 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_ammo_content_inputs = {
        'ammo_keys': a('Array', 'ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);', 'The ordered ammo keys (PayloadAmmoTurret.java:89, `ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);`): the iteration order getAmmoContent scans -- the first key whose content is held wins; arrives as an explicit param (the N2330 param precedent).'),
        'payload_contents': a('Array', 'if(!payloads.isEmpty()){', 'The contents currently held in the payloads seq (PayloadAmmoTurret.java:149, `if(!payloads.isEmpty()){`): the `public PayloadSeq payloads = new PayloadSeq();` field (PayloadAmmoTurret.java:95) reduced to its contents -- the payloads.contains lookup itself is NOT ported, its contents arrive as an explicit param (the N2330 param precedent); the non-empty guard reads this param.'),
    }
    get_ammo_content_outputs = {
        'ammo_content': a('Variant', 'return content;', 'The current ammo content (PayloadAmmoTurret.java:152, `return content;`): the first ammo key (in ammoKeys order) whose content is held in payloads, scanned only when payloads is non-empty (`if(!payloads.isEmpty()){`, PayloadAmmoTurret.java:149) -- null when payloads is empty or none matches (`return null;`, PayloadAmmoTurret.java:155); GD has no UnlockableContent mapping, so content refs are plain strings (content names) and the caller must null-check before using it.'),
    }
    return (get_ammo_content_inputs, get_ammo_content_outputs)


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
    inputs_outputs = [definitions()]
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
    (get_ammo_content_inputs, get_ammo_content_outputs) = definitions()

    entries = [
        ('N2368', GET_AMMO_CONTENT_OWNER, 'source_payload_ammo_turret_build_get_ammo_content_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', 'PayloadTurretBuild.getAmmoContent()', get_ammo_content_inputs, get_ammo_content_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.getAmmoContent() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.getAmmoContent() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ammo_content.
    by_slice['N2368'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2368', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', java_method='PayloadTurretBuild.getAmmoContent()', godot_owner=GET_AMMO_CONTENT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2368'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
