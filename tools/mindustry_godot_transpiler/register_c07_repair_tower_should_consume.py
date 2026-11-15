"""Register the RepairTower shouldConsume gate (N2191).

The RepairTower's shouldConsume gate, following the N2176 pure-row
pattern. N2176 folded power-only: a pure power row over the stamped
frame value, folded by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) -- but RepairTowerBuild DOES override
shouldConsume: `return targets.size > 0;`
(RepairTower.java:90), and updateConsumption forces efficiency to
zero when the gate is false (BuildingComp.java:1960, `boolean update
= shouldConsume() && productionValid();` + 1992-1993,
`if(!update){` / `efficiency = optionalEfficiency = 0f;`).
N2176 deferred the gate with a documented limit (the
PointDefenseTurret N2151 precedent): the port tracked no live
target on any placed-building frame, so with no targets
requestedPower is 0 so power.status reads 1.0 while Java
efficiency is 0. N2190 stamped the prerequisite count: the refresh
block is the ONLY writer of `targets` (RepairTower.java:59-66,
`if(potentialEfficiency > 0 && (refresh += Time.delta) >=
refreshInterval){` / `targets.clear();` / `refresh = 0f;` /
`Units.nearby(team, x, y, range, u -> {` / `if(u.damaged()){` /
`targets.add(u);`) and stamps `targets_count` on refresh expiry
when a `nearby_damaged_units` observation exists. N2191 closes
that gap with one pure function
(source_repair_tower_should_consume_state) over that one frame key
(`targets_count`, int): the gate is the same expression over the
observed count, `targets.size > 0`, read as `targets_count > 0 &&
enabled`. RED decision (pinned by this slice -- the N2188
`has_target` precedent): when the frame carries NO `targets_count`
key, preserve the N2176 behavior (`should_consume = enabled`) --
null means "no observation yet", not "no targets", because no
placed-building frame carries a live targets count until the
live-units query slice stamps `nearby_damaged_units`, and
defaulting absent to false would zero efficiency for every live
repair tower, a live regression against N2176 GREEN. The gate
therefore activates when a refresh expiry stamps `targets_count`
from the observed count. The driver change is one line in the
existing source_repair_tower_tick_buildings_state: the
pure-function call replaces `var should_consume: bool =
bool(frame.get("enabled", true))` BEFORE the consumption setup --
the Java order (updateConsumption :2274 reads shouldConsume() at
:1960), reading the `targets_count` the previous tick's refresh
stamped; the setup / power row / `update_consumption_state` /
`apply_update_consumption_state` calls are unchanged. No new frame
meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change, no shard change (no shard selects
/world/blocks/units/).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false. N2191 does not touch it.
N2191 supplies the missing pure gate + the one-line driver change;
no new consumer rows. The repair tower's power draw stays STATIC
(consumePower 1f, Blocks.java:6582 -- a plain ConsumePower, not
the RepairTurret-style conditional draw), so the folded
efficiency is the min over the *modeled* consumers (power only);
the ozone liquid consumer (consumeLiquid ozone 3f/60f,
Blocks.java:6583) is the second pass and waits for its own slice.
No updateTile advance: the heal / warmup / totalProgress advance
(RepairTower.java:67-86) and the Units.nearby live query
(RepairTower.java:61-65) wait for their own slices; the proof
carries no heal/warmup/totalProgress/query keys. Single def
(unit-repair-tower, size 2, range 100f, healAmount 1.5f,
Blocks.java:6575-6583).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_tower_target_refresh import DEFERRED as _N2190_DEFERRED

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTowerShouldConsumeProof'
OWNER = 'SourceRepairTowerBuildState.source_repair_tower_should_consume_state'
TESTS = ['test_c07_repair_tower_should_consume_registration', 'test_all_c07_repair_tower_should_consume_input_evidence_is_exact', 'test_repair_tower_should_consume_state', 'test_reference_graph_and_actual_c07_repair_tower_should_consume']
EXACT_EXPRS = ['public boolean shouldConsume(){', 'return targets.size > 0;', 'public Seq<Unit> targets = new Seq<>();', 'targets.clear();', 'refresh = 0f;', 'targets.add(u);', 'consumePower(1f);', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return efficiency * delta();', 'potentialEfficiency = efficiency;', 'public void updateConsumption(){', 'public void updateTile(){', 'public class RepairTowerBuild extends Building implements Ranged{']

# DEFERRED is carried from the N2190 register script via import --
# never retyped. The N2190 script's DEFERRED is a computed
# expression (list(_N2176_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. The new N2191 entry below
# is the handoff's deferred item that is not already in that list
# (the Windows Godot proof debt). NOTE for the next slice: N2191's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(_N2190_DEFERRED) + [
    'RepairTower shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2190: the N2191 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2191_inputs = {
        'frame': f('Dictionary', 'return targets.size > 0;', 'The building frame carrying the targets_count observation (RepairTower.java:49, `public Seq<Unit> targets = new Seq<>();`, stamped by the N2190 refresh on expiry when a nearby_damaged_units observation exists) and enabled; a missing targets_count key means no observation yet (N2176 behavior preserved), not no targets.'),
    }
    n2191_outputs = {
        'should_consume': f('bool', 'return targets.size > 0;', 'The shouldConsume gate (RepairTower.java:89-90): targets_count > 0 && enabled when a targets observation is present, enabled when the frame carries no targets_count key (the N2176 behavior); false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).'),
    }

    entries = [
        ('N2191', OWNER, 'source_repair_tower_should_consume_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.shouldConsume()', n2191_inputs, n2191_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower shouldConsume gate from RepairTower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower shouldConsume gate from RepairTower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2191'] = [
        'source_repair_tower_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2191', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTowerBuild.shouldConsume()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2191'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
