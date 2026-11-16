"""Register the LaunchPad shouldConsume gate (N2205).

The LaunchPad's shouldConsume gate, following the N2172 pure-row
pattern and the N2193 shouldConsume precedent. N2172 folded
power-only: a pure power row over the stamped frame value, folded
by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) -- but LaunchPadBuild DOES override
shouldConsume: `return launchCounter < launchTime;`
(LaunchPad.java:94), and updateConsumption forces efficiency to
zero when the gate is false (BuildingComp.java:1960, `boolean
update = shouldConsume() && productionValid();` + 1992-1993,
`if(!update){` / `efficiency = optionalEfficiency = 0f;`).
N2172 deferred the gate with a documented limit (the
PointDefenseTurret N2151 precedent): the port tracked no live
launch counter on any placed-building frame, so with a full
counter power.status reads 1.0 while Java efficiency is 0.
N2205 closes that gap with one pure function
(source_launch_pad_should_consume_state) over one frame key
(`launch_counter`, float) plus the per-def launchTime parameter:
the gate is the same expression over the observed counter,
`launchCounter < launchTime`, read as `float(launch_counter) <
launch_time and enabled`. RED decision (pinned by this slice --
the N2191 `targets_count` precedent): when the frame carries NO
`launch_counter` key, preserve the N2172 behavior
(`should_consume = enabled`) -- null means "no observation yet",
not "fully launched", because the future updateTile advance
stamps `launch_counter` only after the first launch gate consult
each tick, and defaulting absent to false would zero efficiency
for every live launch pad before its first advance tick, a live
regression against N2172 GREEN. It also matches the Java init:
`public float launchCounter;` (LaunchPad.java:84) defaults to
0.0f, always < launchTime, so at Java init the gate is true when
enabled. The per-def launchTime differs (launch-pad 1200f = 60f
* 20, Blocks.java:6794; advanced-launch-pad 1800f = 60f * 30,
Blocks.java:6804; class default 1f, LaunchPad.java:32), and the
catalog carries no launchTime property (content_registry.json
blocks[404]/[405] properties have no launchTime key), so the
driver selects it by block id
(SOURCE_LAUNCH_PAD_LAUNCH_TIMES, defaulting to the class default
1.0) and passes it as the pure function's second parameter --
the pure function takes (frame, launch_time), it does not read a
frame key for the threshold. The driver change is one line in the
existing source_launch_pad_tick_buildings_state: the pure-function
call replaces `var should_consume: bool =
bool(frame.get("enabled", true))` BEFORE the consumption setup --
the Java order (updateConsumption :2274 reads shouldConsume() at
:1960), reading the `launch_counter` the previous tick's advance
stamped; the setup / power row / `update_consumption_state` /
`apply_update_consumption_state` calls are unchanged. No new frame
meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: LaunchPad.java lives
under /world/blocks/campaign/ and no campaign_slices shard file
exists yet; the register rebuilds extension shards from
source_ssot_modules.json (the N2172 precedent), so the GREEN
register run must record which shard files actually change.

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false. N2205 does not touch
it. N2205 supplies the missing pure gate + the one-line driver
change; no new consumer rows. The launch pad's power draw stays
STATIC (consumePower 4f launch-pad / 8f advanced-launch-pad,
Blocks.java:6797/6809 -- plain ConsumePower rows, not the
RepairTurret-style conditional draw), so the folded efficiency is
the min over the *modeled* consumers (power only); the advanced
oil consumer (consumeLiquid oil 9f/60f, Blocks.java:6808) is the
second pass and waits for its own slice. No updateTile advance:
the launchCounter advance / LaunchPayload spawn / items.clear
(LaunchPad.java:143-161) waits for its own slice; the proof
carries no launch/counter/payload keys, and the future updateTile
slice owns live stamping of `launch_counter`. No sense modeling:
sense(LAccess.progress) (LaunchPad.java:98-101) waits for its own
slice. Two defs share the implementation (launch-pad, size 3,
itemCapacity 100, launchTime 60f * 20; advanced-launch-pad, size
4, itemCapacity 100, launchTime 60f * 30, liquidCapacity 40f,
Blocks.java:6790-6809).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shield_wall_update_tile import DEFERRED as _N2204_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LAUNCH_PAD = 'core/src/mindustry/world/blocks/campaign/LaunchPad.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07LaunchPadShouldConsumeProof'
OWNER = 'SourceLaunchPadBuildState.source_launch_pad_should_consume_state'
TESTS = ['test_c07_launch_pad_should_consume_registration', 'test_all_c07_launch_pad_should_consume_input_evidence_is_exact', 'test_launch_pad_should_consume_state', 'test_reference_graph_and_actual_c07_launch_pad_should_consume']
# The 6 slice sources the N2205 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/consumers/ConsumePower.java',
    'core/src/mindustry/world/blocks/units/UnitAssembler.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public boolean shouldConsume(){', 'return launchCounter < launchTime;', 'public float launchCounter;', 'public float launchTime = 1f;', 'public class LaunchPad extends Block{', 'public class LaunchPadBuild extends Building{', 'if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){', 'if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);', 'public void updateTile(){', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return efficiency * delta();', 'return enabled;', 'public boolean canConsume(){', 'return potentialEfficiency > 0;', 'potentialEfficiency = efficiency;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'launchTime = 60f * 20;', 'launchTime = 60f * 30;', 'consumePower(4f);', 'consumePower(8f);', 'size = 3;', 'size = 4;', 'itemCapacity = 100;']

# DEFERRED is carried from the N2204 register script via import --
# never retyped. The N2204 script's DEFERRED is a computed
# expression (list comprehensions over the N2175 list plus the
# N2202/N2203 tails plus a literal tail), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2205's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# shouldConsume gate itself is NOT carried as deferred: it is THIS
# slice (N2205) -- the inherited N2172 entry still names it as
# waiting, which is stale history, superseded by this slice.
DEFERRED = list(_N2204_DEFERRED) + [
    'LaunchPad shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2204: the N2205 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=LAUNCH_PAD, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2205_inputs = {
        'frame': f('Dictionary', 'return launchCounter < launchTime;', 'The building frame carrying the launch_counter observation (LaunchPad.java:84, `public float launchCounter;`, stamped by the future updateTile advance every tick after the launch gate consult) plus enabled; a missing launch_counter key means no observation yet (N2172 behavior preserved), not fully launched. The per-def launchTime arrives as the separate launch_time parameter, not a frame key, because the catalog carries no launchTime property.'),
        'launch_time': f('float', 'public float launchTime = 1f;', 'The per-def launchTime the gate runs the counter against (LaunchPad.java:32, the class default 1f): launch-pad 1200f (Blocks.java:6794, `launchTime = 60f * 20;`) and advanced-launch-pad 1800f (Blocks.java:6804, `launchTime = 60f * 30;`); the driver selects it by block id from SOURCE_LAUNCH_PAD_LAUNCH_TIMES and passes it in.'),
    }
    n2205_outputs = {
        'should_consume': f('bool', 'return launchCounter < launchTime;', 'The shouldConsume gate (LaunchPad.java:92-95): float(launch_counter) < launch_time and enabled when a counter observation is present, enabled when the frame carries no launch_counter key (the N2172 behavior); false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).'),
    }
    return n2205_inputs, n2205_outputs


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
    inputs, outputs = definitions()
    for keys in (inputs, outputs):
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + len(inputs) + len(outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    n2205_inputs, n2205_outputs = definitions()

    entries = [
        ('N2205', OWNER, 'source_launch_pad_should_consume_state', LAUNCH_PAD, 'mindustry.world.blocks.campaign.LaunchPad.LaunchPadBuild', 'LaunchPadBuild.shouldConsume()', n2205_inputs, n2205_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaunchPad shouldConsume gate from LaunchPad.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaunchPad shouldConsume gate from LaunchPad.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2205'] = [
        'source_launch_pad_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2205', dict(status='done', java_source=LAUNCH_PAD, java_class='mindustry.world.blocks.campaign.LaunchPad.LaunchPadBuild', java_method='LaunchPadBuild.shouldConsume()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2205'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
