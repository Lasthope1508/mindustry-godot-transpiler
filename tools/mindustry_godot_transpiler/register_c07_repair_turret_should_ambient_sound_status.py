"""Register the RepairTurret shouldAmbientSound/status rows (N2221).

N2212-N2215 made the repair turret live (target acquire, heal
advance, rotation slerp, strength lerp), N2217 persisted its
rotation, N2219 captured the beam state and N2220 the dash-circle
state -- but nothing in the port captured when the turret plays
its ambient sound or what status it reports:
RepairPointBuild.shouldAmbientSound() returns `target != null &&
efficiency > 0f` (RepairTurret.java:182, inside `public boolean
shouldAmbientSound(){`, RepairTurret.java:181) and
RepairPointBuild.status() returns `Mathf.equal
(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput :
super.status()` (RepairTurret.java:226, inside `public
BlockStatus status(){`, RepairTurret.java:225).

RED decisions (resolved at RED): (1) Two pure functions on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217 /
N2219 / N2220 built, returning the ambient gate (bool) and the
status (String). (2) The ambient gate reads the live target
observation as `has_target` (stamped every tick by the N2212
acquire) and the folded `efficiency` (stamped every tick by the
driver via apply_update_consumption_state); absent has_target
means "no observation yet", so it reads false, and absent
efficiency folds to 1.0 (the N2174 missing-stamp precedent).
(3) The status gate reads `potential_efficiency` (stamped every
tick by the driver via apply_update_consumption_state);
Mathf.equal(potentialEfficiency, 0f, 0.01f) is `Math.abs(a - b)
<= tolerance` (Mathf.java:554-556), so the gate is
`absf(potential_efficiency) <= 0.01`; absent
potential_efficiency reads 0.0 -- the Java transient field
default (BuildingComp.java:89, `transient float
potentialEfficiency;`) -- so an unticked frame reports noInput,
exactly like Java before the first updateConsumption. (4)
super.status() is BuildingComp.status()
(BuildingComp.java:632-646): disabled -> logicDisable,
shouldConsume false -> noOutput, efficiency <= 0 or
productionValid false -> noInput, else the tick flicker
`((state.tick / 30f) % 1f) < efficiency ? active : noInput`;
the shouldConsume leg reuses
source_repair_turret_should_consume_state (N2188) and
productionValid is the canonical true default
(SourceBuildingAccessState.production_valid_state()); the tick
arrives as an explicit float param, not from the frame (the
driver stamps no tick key). Status strings are the
SourceBuildingAccessState constants ("logicDisable" /
"noOutput" / "noInput" / "active"). (5) There is NO driver tick
line: status() / shouldAmbientSound() are read functions (UI +
the ambient-sound gate BuildingComp.update() calls), not
per-tick -- the live-loop ambient-sound gate call waits for its
own slice. Two new result symbols: ambient
should_ambient_sound, status status. Slice sources:
RepairTurret.java + BuildingComp.java (super.status()).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_draw_select_place import DEFERRED as N2220_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07RepairTurretShouldAmbientSoundStatusProof'
AMBIENT_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_should_ambient_sound_state'
STATUS_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_status_state'
TESTS = ['test_c07_repair_turret_should_ambient_sound_status_registration', 'test_all_c07_repair_turret_should_ambient_sound_status_input_evidence_is_exact', 'test_repair_turret_should_ambient_sound_status_state', 'test_reference_graph_and_actual_c07_repair_turret_should_ambient_sound_status']
# The 2 slice sources the N2221 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = ['public boolean shouldAmbientSound(){', 'return target != null && efficiency > 0f;', 'public BlockStatus status(){', 'return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();', 'if(!enabled){', 'return BlockStatus.logicDisable;', 'if(!shouldConsume()){', 'return BlockStatus.noOutput;', 'if(efficiency <= 0 || !productionValid()){', 'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;', 'transient float potentialEfficiency;']

# DEFERRED is carried from the N2220 register script via import --
# never retyped. The N2220 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2219 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2221's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
# NOTE: the N2220 pool entries claiming RepairTurret
# shouldAmbientSound (RepairTurret.java:181-184) and status()
# (RepairTurret.java:225-228) "wait for their own slice" are
# SUPERSEDED by this slice -- the ambient gate and the status
# gate now have pure functions and result symbols. The pool is
# cumulative history, so the old entries stay; the new entries
# below pin what is still deferred.
DEFERRED = list(N2220_DEFERRED) + [
    'RepairTurret ambient-sound live-loop gate (the BuildingComp.update() ambient-sound gate calling shouldAmbientSound() each tick, BuildingComp.java updateAmbientSound) -- the pure gate exists (N2221), the live-loop call waits for its own slice.',
    'RepairTurret shouldAmbientSound/status Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2220: the N2221 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ambient_inputs = {
        'frame': a('Dictionary', 'return target != null && efficiency > 0f;', 'The repair-turret frame carrying the live target observation as `has_target` (stamped every tick by the N2212 acquire; absent means "no observation yet", so it reads false) and the folded `efficiency` (stamped every tick by the driver via apply_update_consumption_state; absent folds to 1.0, the N2174 missing-stamp precedent).'),
    }
    ambient_outputs = {
        'should_ambient_sound': a('bool', 'return target != null && efficiency > 0f;', 'The ambient-sound gate (RepairTurret.java:182, `return target != null && efficiency > 0f;`): true only with a live target and efficiency above zero.'),
    }
    status_inputs = {
        'frame': a('Dictionary', 'return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();', 'The repair-turret frame carrying `potential_efficiency` (stamped every tick by the driver via apply_update_consumption_state; absent reads 0.0, the Java transient field default, BuildingComp.java:89, `transient float potentialEfficiency;`), `enabled`, `has_target` (the N2188 shouldConsume leg) and the folded `efficiency` (stamped every tick by the driver).'),
        'tick': a('float', 'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;', 'The game tick (state.tick, BuildingComp.java:645, `return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;`): the flicker term of the active leg; passed explicitly because the driver stamps no tick key on the frame.', source=BUILDING_COMP),
    }
    status_outputs = {
        'status': a('String', 'return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();', 'The block status (RepairTurret.java:226, `return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();`): "noInput" when potential efficiency is within 0.01 of zero, else BuildingComp.status() (BuildingComp.java:632-646) -- "logicDisable" / "noOutput" / "noInput" / "active" (the SourceBuildingAccessState constants).'),
    }
    return ambient_inputs, ambient_outputs, status_inputs, status_outputs


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
    ambient_inputs, ambient_outputs, status_inputs, status_outputs = definitions()

    entries = [
        ('N2221', AMBIENT_OWNER, 'source_repair_turret_should_ambient_sound_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.shouldAmbientSound()', ambient_inputs, ambient_outputs, True, 'Dictionary'),
        ('N2221', STATUS_OWNER, 'source_repair_turret_status_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.status()', status_inputs, status_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret shouldAmbientSound/status state from RepairTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret shouldAmbientSound/status state from RepairTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: ambient should_ambient_sound,
    # status status.
    by_slice['N2221'] = [
        'source_repair_turret_should_ambient_sound_state_result.should_ambient_sound',
        'source_repair_turret_status_state_result.status',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2221', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.shouldAmbientSound()/RepairPointBuild.status()', godot_owner=AMBIENT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2221'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
