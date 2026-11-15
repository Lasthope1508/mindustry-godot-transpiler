"""Register the RepairTower target refresh (N2190).

The RepairTower's target refresh, following the N2176 pure-row
pattern. N2176 folded the repair tower's live power.status into
the min efficiency -- but the tower's shouldConsume gate
(`return targets.size > 0;`, RepairTower.java:89-91) reads the
target list, and the refresh block is the ONLY writer of
`targets` (RepairTower.java:59-66,
`if(potentialEfficiency > 0 && (refresh += Time.delta) >=
refreshInterval){` / `targets.clear();` / `refresh = 0f;` /
`Units.nearby(team, x, y, range, u -> {` / `if(u.damaged()){` /
`targets.add(u);`): until a slice stamps a live targets count, no
gate slice can read one. N2190 is that prerequisite slice and
nothing else: one pure function
(source_repair_tower_refresh_targets_state) over the frame keys
`refresh` (seconds accumulated), `targets_count` (stamped on
refresh expiry when an observation exists),
`nearby_damaged_units` (the observation channel, stamped by the
future live-units query slice, NOT this one) and
`potential_efficiency` (already stamped every tick by the N2176
driver via apply_update_consumption_state), gated on the single
boolean from the Java line (potentialEfficiency > 0) plus the
accumulated delta reaching the interval (`static final float
refreshInterval = 6f;`, RepairTower.java:19). The timer advance
needs no per-def values (range/healAmount are irrelevant to the
timer), no second subsystem input, and its driver file is
dedicated. The gate reads the potentialEfficiency stamped by THIS
tick's updateConsumption (BuildingComp.java:2263-2277,
updateConsumption() runs BEFORE updateTile()), and the port mirror
sets `potential_efficiency := efficiency` (the min) before the
`if not update` zeroing, so potentialEfficiency is the pre-gate
min efficiency (power.status fold) and stays 1.0 with full power
even when shouldConsume is false (no targets) -- the tower
therefore keeps refreshing with no targets; it only stops when
power is gone or it is disabled.

RED decisions (pinned by this slice): absent `refresh` -> 0.0
(timer starts at 0; first refresh after exactly 6s of powered
operation). Java inits `refresh = Mathf.random(refreshInterval)`
(RepairTower.java:47) -- the port takes the deterministic 0.0
start, a documented deviation pinned in the proof; no `randf` in
the pure function (determinism; the C06DefenseProof lesson: seeded
RNG only in proof scenes, never in game code). Absent
`potential_efficiency` -> 0.0 (Java field default,
BuildingComp.java:89, `transient float
potentialEfficiency;`) -- no advance before the first consumption
stamp, which also makes the first live tick a no-advance tick,
pinned in the proof. Absent `nearby_damaged_units` at expiry ->
the timer refreshes but `targets_count` is NOT stamped (no
observation yet -- the N2188 `has_target` precedent), so the
follow-up shouldConsume gate must treat an absent `targets_count`
as "no observation" and preserve the N2176 power-only behavior.
The driver change is one call + comment in the existing
source_repair_tower_tick_buildings_state, INSIDE the existing
`if has_power_consumer and enabled and not cheating:` block,
AFTER `apply_update_consumption_state` -- the Java order
(updateConsumption :2274 before updateTile :2277). The driver
writes `frame["refresh"]` from the result every call, and
`frame["targets_count"]` only when `has_targets_count` is true.
`delta` is the tick's `seconds` (Time.delta). No new frame meta
key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change, no shard change (no shard selects
/world/blocks/units/).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already stamps
potential_efficiency every tick. N2190 does not touch it. N2190
supplies the missing pure refresh + the one-call driver change;
no new consumer rows. The effective query radius (range +
hitSize/2 per unit, Units.java:449-451) belongs to the future
live-units query slice. Single def (unit-repair-tower, size 2,
range 100f, healAmount 1.5f, Blocks.java:6575-6583).
"""
import ast
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
UNITS = 'core/src/mindustry/entities/Units.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTowerTargetRefreshProof'
OWNER = 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state'
TESTS = ['test_c07_repair_tower_target_refresh_registration', 'test_all_c07_repair_tower_target_refresh_input_evidence_is_exact', 'test_repair_tower_refresh_targets_state', 'test_reference_graph_and_actual_c07_repair_tower_target_refresh']
EXACT_EXPRS = ['static final float refreshInterval = 6f;', 'public float refresh = Mathf.random(refreshInterval);', 'public float range = 80f;', 'public float healAmount = 1f;', 'public class RepairTowerBuild extends Building implements Ranged{', 'public void updateTile(){', 'if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', 'targets.clear();', 'refresh = 0f;', 'Units.nearby(team, x, y, range, u -> {', 'if(u.damaged()){', 'targets.add(u);', 'public boolean shouldConsume(){', 'return targets.size > 0;', 'potentialEfficiency = efficiency;', 'public void updateConsumption(){', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'return efficiency * delta();', 'consumePower(1f);', 'public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', 'if(unit.within(x, y, radius + unit.hitSize/2f)){']

# DEFERRED is carried from the N2176 register script via AST --
# never retyped. The N2176 script's DEFERRED is a plain list
# literal, so ast.literal_eval recovers it verbatim; the new
# N2190 entries below are the handoff's deferred items that are
# not already in that list (the Units.nearby live query, the
# heal/warmup/totalProgress remainder of the updateTile advance,
# and the Windows Godot proof debt).
_N2176_REGISTER = Path(__file__).resolve().parent / 'register_c07_repair_tower_power_status.py'
_N2176_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2176_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
DEFERRED = list(_N2176_DEFERRED) + [
    'RepairTower Units.nearby live query (Units.nearby(team, x, y, range, u -> { if(u.damaged()){ targets.add(u); } }), RepairTower.java:62-65; effective radius range + hitSize/2 per unit, Units.java:449-451, `if(unit.within(x, y, radius + unit.hitSize/2f)){`) -- stamps nearby_damaged_units on the frame; the pure refresh consumes the count, it does not produce it; the port has no live friendly-unit enumeration wired into any driver, so the query waits for its own slice.',
    'RepairTower heal / warmup / totalProgress advance (heal `target.heal(healAmount * edelta());` / warmup lerp `warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);` / totalProgress advance, RepairTower.java:67-86) -- the target refresh (RepairTower.java:59-66) is N2190; the heal loop, warmup lerp and totalProgress advance wait for their own slice; the N2190 proof carries no heal/warmup/totalProgress keys.',
    'RepairTower target-refresh Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2188: the N2190 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2190_inputs = {
        'frame': f('Dictionary', 'if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', 'The building frame carrying the refresh timer, the potential_efficiency stamped by this tick\'s updateConsumption (BuildingComp.java:1989, `potentialEfficiency = efficiency;`), and the nearby_damaged_units observation channel; absent refresh starts at 0.0, absent potential_efficiency folds to 0.0 (Java field default, BuildingComp.java:89).'),
        'delta': f('float', '(refresh += Time.delta)', 'The tick delta (Time.delta, RepairTower.java:59, `(refresh += Time.delta)`): the seconds accumulated onto the refresh timer each powered tick.'),
    }
    n2190_outputs = {
        'refreshed': f('bool', 'if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', 'Whether the refresh fired this tick (RepairTower.java:59): potentialEfficiency > 0 and the accumulated refresh reached refreshInterval (6f, RepairTower.java:19).'),
        'refresh': f('float', 'refresh = 0f;', 'The accumulated refresh timer after this tick (RepairTower.java:61, `refresh = 0f;` on expiry): the carried-over accumulation below the interval, 0.0 on expiry.'),
        'targets_count': f('int', 'targets.add(u);', 'The stamped targets count on refresh expiry (RepairTower.java:64, `targets.add(u);` for each damaged unit in range): the observed nearby_damaged_units count when an observation exists, null when none exists yet.'),
        'has_targets_count': f('bool', 'if(u.damaged()){', 'Whether a targets count was stamped (RepairTower.java:63, `if(u.damaged()){` gates the add): true on expiry when a nearby_damaged_units observation exists; false when the timer refreshes with no observation yet (the N2188 has_target precedent).'),
    }

    entries = [
        ('N2190', OWNER, 'source_repair_tower_refresh_targets_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.updateTile()', n2190_inputs, n2190_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower target refresh from RepairTower.java / BuildingComp.java / Units.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower target refresh from RepairTower.java / BuildingComp.java / Units.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: refreshed, refresh, targets_count, has_targets_count.
    by_slice['N2190'] = [
        'source_repair_tower_refresh_targets_state_result.refreshed',
        'source_repair_tower_refresh_targets_state_result.refresh',
        'source_repair_tower_refresh_targets_state_result.targets_count',
        'source_repair_tower_refresh_targets_state_result.has_targets_count',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2190', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2190'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
