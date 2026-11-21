"""Register the turret power-graph last-values stamp: the live tick stamps the graph snapshot into the frame (N2522).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). N2519 wired its eight already-ported
legs into the dispatch `source_building_comp_sense_state`, reading
12 frame keys; N2520 stamped 5 of them from the live turret tick
(`source_turret_tick_buildings_state`, TurretBuild.updateTile(),
Turret.java:490) and N2521 stamped the items pair. This slice
stamps the last 4 graph keys (`last_scaled_power_in` /
`last_scaled_power_out` / `last_power_stored` / `last_capacity`)
and closes the sense() frame:

- `last_scaled_power_in`: `update["balance_state"]
  ["last_scaled_power_in"]` (`lastScaledPowerIn = (powerProduced +
  energyDelta) / Time.delta;`, PowerGraph.java:233);
- `last_scaled_power_out`: `update["balance_state"]
  ["last_scaled_power_out"]` (`lastScaledPowerOut = powerNeeded /
  Time.delta;`, PowerGraph.java:234);
- `last_capacity`: `update["balance_state"]["last_capacity"]`
  (`lastCapacity = getTotalBatteryCapacity();`,
  PowerGraph.java:235);
- `last_power_stored`: `update["last_power_stored"]` (top-level on
  BOTH branches, `lastPowerStored = getBatteryStored();`,
  PowerGraph.java:236).

The stamp copies the owner's snapshot (the
`source_factory_update_power_graph_state` return, whose `update`
is the `update_state` output — PowerGraph.update() is `public void
update(){`, PowerGraph.java:216-260) and stamps a key ONLY when
present in the update: on the cheat branch `balance_state` is `{}`
(Java returns before :233-236, PowerGraph.java:217-224, so the
fields keep their previous values) and the stamp leaves the
scaled/capacity keys untouched, so the frame keeps the previous
tick's values; an empty `{}` update stamps NOTHING, so the
dispatch keeps handled:false for powerNet* (the N2519 absent-key
fallback). `last_power_stored` IS present on the cheat branch in
the port owner (`SourcePowerGraphState.update_state` reports the
fresh stored total there, while Java keeps the old field value — a
PRE-EXISTING owner deviation from N2142-era, NOT changed by this
slice; the stamp copies the owner's snapshot verbatim). The stamp
does NOT recompute any formula (the formula lives once in
`update_balance_state`, SourcePowerGraphBalanceState.gd:116-119)
and does NOT call the graph update. The live loop already runs
the update before the turret tick (`simulate_factory`,
SourceFactoryRuntimeState.gd:199) and stores its return on the
game (`power_graph_update`, declared in
SourcePortGameFactoryStatePortBridge.gd); the tick reads it from
the game — it must NOT re-run the update (it is NOT idempotent:
it writes battery `power_status` back to sprite metas, so a
second run would charge/discharge AGAIN) and must NOT recompute
from `game_runtime_state` (that would duplicate the formula, and
its batteries read status 0.0). The tick signature stays
`(game: Object, seconds: float)` and the factory call text stays
`source_turret_build_state.source_turret_tick_buildings_state(game,
delta)` — both pinned by test_turret_live_loop.py:84-85 (N2108).
`power == null` handling stays in the dispatch legs (they return
0.0 when `not has_power`), so stamping graph values for a
power-less turret is safe. Per-graph vs global: Java reads each
building's OWN graph (`power.graph.getLastScaledPowerIn()`); the
port groups ALL placed buildings into ONE graph (`_group_state`,
SourcePlacedPowerGraphState.gd:254-284, has no connectivity split
— `PowerGraph.addGraph` merge is not ported), so the
building→graph lookup IS the single global placed graph. A
per-graph split waits for connectivity grouping.

GREEN decisions (pinned by this slice): (1) ONE pure function on
SourceTurretBuildState.gd,
source_turret_power_graph_last_values_stamp_state(frame,
power_graph_update), placed right after
source_turret_ammo_items_stamp_state (mirroring Java order -- the
tick refreshes frame keys, the stamp is part of that refresh). It
writes exactly the 4 keys above and returns the frame (the N2108
tick-frame precedent: one result symbol, `result.frame`). (2) ONE
tick call site in source_turret_tick_buildings_state, right after
the N2521 ammo-items stamp call: the tick reads the stored update
from the game (`game.get("power_graph_update")`, guarded to `{}`).
(3) The live loop stores the update on the game
(`simulate_factory` captures the `source_factory_update_power_graph_state`
return and `game.set("power_graph_update", ...)`) and the var is
declared in SourcePortGameFactoryStatePortBridge.gd (the
`item_progress` precedent). (4) The 8 leg functions, the dispatch,
the N2519/N2520/N2521 proofs and tests are UNTOUCHED. The SenseI
pure functions (N2507/N2510) are UNTOUCHED -- the composition at
the caller is a later slice (no LExecutor instruction loop exists
in the port yet). (5) Shard routing: the ported method is
BuildingComp.sense, so the java_source is BuildingComp.java and
the slice mirrors into the comp shard: comp 571/474 -> 572/475;
defense stays 210/209. SSOT expected after GREEN: symbols +1,
Done +1, contracts +1, schema +2, 11709/1750/1683/3157 ->
11710/1751/1684/3159.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_ammo_items_stamp import DEFERRED as N2521_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/C07TurretPowerGraphLastValuesStampProof'
STAMP_OWNER = 'SourceTurretBuildState.source_turret_power_graph_last_values_stamp_state'
TESTS = ['test_c07_turret_power_graph_last_values_stamp_registration', 'test_all_c07_turret_power_graph_last_values_stamp_input_evidence_is_exact', 'test_turret_power_graph_last_values_stamp_state', 'test_reference_graph_and_actual_c07_turret_power_graph_last_values_stamp']
# The slice sources the N2522 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/power/PowerGraph.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
    'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
    'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();',
    'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();',
    'public void update(){',
    'lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;',
    'lastScaledPowerOut = powerNeeded / Time.delta;',
    'lastCapacity = getTotalBatteryCapacity();',
    'lastPowerStored = getBatteryStored();',
    'public float getLastScaledPowerIn(){',
    'public float getTotalBatteryCapacity(){',
    'public float getBatteryStored(){',
    'public void updateTile(){',
]

# DEFERRED is carried from the N2521 register script via import --
# never retyped. No entry is dropped: the stamp completes no
# deferred entry except the 4 graph keys (recorded STAMPED below).
# New entries below record the 4 graph keys as DONE by this slice
# and the still-open work with its reasons (the scope's verbatim
# reasons).
DEFERRED = N2521_DEFERRED + [
    'Turret power-graph last-values stamp (`last_scaled_power_in` / `last_scaled_power_out` / `last_power_stored` / `last_capacity` frame keys) -- STAMPED by this slice (N2522): `source_turret_power_graph_last_values_stamp_state` copies the owner\'s snapshot (the `source_factory_update_power_graph_state` return, whose `update` is the `update_state` output) into the 4 keys (`last_scaled_power_in` / `last_scaled_power_out` / `last_capacity` from `update["balance_state"]`, `last_power_stored` from `update["last_power_stored"]`) and the tick calls it right after `source_turret_ammo_items_stamp_state`, reading the stored update from the game; the N2519-wired dispatch stops reporting handled:false for the powerNet* legs when a live turret ticks. A key is stamped ONLY when present in the update: on the cheat branch `balance_state` is `{}` (Java returns before PowerGraph.java:233-236, so the fields keep their previous values) and the stamp leaves the scaled/capacity keys untouched; `last_power_stored` IS present on the cheat branch in the port owner (a pre-existing owner deviation — `SourcePowerGraphState.update_state` reports the fresh stored total there while Java keeps the old field value — NOT changed by this slice). The sense() frame is now complete: all 12 dispatch keys have a live source.',
    'Turret sense frame stamp per-graph split -- DEFERRED (still, after N2522): Java reads each building\'s OWN graph (`power.graph.getLastScaledPowerIn()`, BuildingComp.java:2113-2116); the port groups ALL placed buildings into ONE graph (`_group_state`, SourcePlacedPowerGraphState.gd:254-284, has no connectivity split — `PowerGraph.addGraph` merge is not ported), so the building→graph lookup IS the single global placed graph; a per-graph split waits for connectivity grouping.',
    'Turret power-graph last-values stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521: the N2522 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    stamp_inputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The turret frame (the port Building state) the tick stamps every tick (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126 -- the dispatch reads the stamped keys from this frame); the stamp writes the 4 graph keys in place and returns the frame (the N2108 tick-frame precedent).'),
        'power_graph_update': a('Dictionary', 'public void update(){', 'The graph update the live loop already ran this tick (`public void update(){`, PowerGraph.java:216-260 -- the `source_factory_update_power_graph_state` return, whose `update` is the `update_state` output; the tick reads it from the game, `power_graph_update`, declared in SourcePortGameFactoryStatePortBridge.gd): the stamp copies `last_scaled_power_in` / `last_scaled_power_out` / `last_capacity` from `update["balance_state"]` and `last_power_stored` from `update["last_power_stored"]`, stamping a key ONLY when present in the update.', source=POWER_GRAPH),
    }
    stamp_outputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The stamped frame, with the 4 live graph keys set (`last_scaled_power_in` / `last_scaled_power_out` / `last_power_stored` / `last_capacity`, copied from the owner\'s snapshot — a key absent from the update stays untouched, so the frame keeps the previous tick\'s value on the cheat branch and the dispatch keeps handled:false when no update ran) plus every key the frame already carried (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126).'),
    }
    return stamp_inputs, stamp_outputs


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
    stamp_inputs, stamp_outputs = definitions()

    entries = [
        ('N2522', STAMP_OWNER, 'source_turret_power_graph_last_values_stamp_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', stamp_inputs, stamp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed turret power-graph last-values stamp from BuildingComp.java:2093-2126 + PowerGraph.java:216-236 + Turret.java:490.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed turret power-graph last-values stamp from BuildingComp.java:2093-2126 + PowerGraph.java:216-236 + Turret.java:490.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: frame.
    by_slice['N2522'] = [
        'source_turret_power_graph_last_values_stamp_state_result.frame',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2522', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=STAMP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2522'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
