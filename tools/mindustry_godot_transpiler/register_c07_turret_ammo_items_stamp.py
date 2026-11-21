"""Register the turret ammo-items stamp: the live tick stamps the item inventory into the frame (N2521).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). N2519 wired its eight already-ported
legs into the dispatch `source_building_comp_sense_state`, reading
12 frame keys; N2520 stamped 5 of them from the live turret tick
(`source_turret_tick_buildings_state`, TurretBuild.updateTile(),
Turret.java:490). This slice stamps the items pair
(`items_is_null` / `items_total`) and explicitly leaves the 4
graph keys absent (N2519's absent-key fallback keeps handled:false
for powerNet* -- no behavior change there):

- `items_is_null`: `not has_items` -- only ItemTurret has an item
  module (`if(block.hasItems) items = new ItemModule();`,
  BuildingComp.java:145; `hasItems = true;`,
  ItemTurret.java:28, the ONLY hasItems set among the 5 ticked
  implementations);
- `items_total`: the constant 0 -- the `items` module is NEVER
  written for an ItemTurretBuild: `ItemTurretBuild.handleItem`
  (ItemTurret.java:155-185) overrides `BuildingComp.handleItem`
  (:860-862, `items.add(item, 1);`) WITHOUT calling super, so it
  only updates `totalAmmo` (`totalAmmo += type.ammoMultiplier;`,
  :168) and the ammo-weighted `ammo` entries; `handleStack`
  (:141-147) loops `handleItem` and `read()` restores `ammo` +
  `totalAmmo`, never `items`. The module exists but stays empty,
  so `items.total()` is 0 always (`case totalItems -> items ==
  null ? 0 : items.total();`, :2107; `public int total(){`,
  ItemModule.java:174-176). The port's `turret_ammo_stacks` are
  the Java `ammo` Seq (ammo-weighted entries), NOT the `items`
  module -- summing them would invent behavior (a duo with copper
  5 + graphite 3 stacks would read 8.0 while Java reads 0.0), so
  the tick reads NO stacks dict for this stamp.

NOT stamped (deferred, carried below): `last_scaled_power_in` /
`last_scaled_power_out` / `last_power_stored` / `last_capacity`
(the port power graph has NO per-graph last-* snapshot and NO
building->graph lookup in the tick; PowerGraph.update :233-234
`lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;`
`lastScaledPowerOut = powerNeeded / Time.delta;`, :236
`lastPowerStored = getBatteryStored();`).

GREEN decisions (pinned by this slice): (1) ONE pure function on
SourceTurretBuildState.gd,
source_turret_ammo_items_stamp_state(frame, has_items), placed
right after source_turret_sense_frame_stamp_state (mirroring Java
order -- the tick refreshes frame keys, the stamp is part of that
refresh). It writes exactly the 2 keys above and returns the frame
(the N2108 tick-frame precedent: one result symbol,
`result.frame`). (2) ONE tick call site in
source_turret_tick_buildings_state, right after the N2520
sense-stamp call: `has_items` is `str(block.implementation) ==
"ItemTurret"` (the file's established implementation-string
pattern). (3) The 8 leg functions, the dispatch, the N2519/N2520
proofs and N2519/N2520 tests are UNTOUCHED. The SenseI pure
functions (N2507/N2510) are UNTOUCHED -- the composition at the
caller is a later slice (no LExecutor instruction loop exists in
the port yet). (4) Shard routing: the ported method is
BuildingComp.sense, so the java_source is BuildingComp.java and
the slice mirrors into the comp shard: comp 570/473 -> 571/474;
defense stays 210/209. SSOT expected after GREEN: symbols +1,
Done +1, contracts +1, schema +2, 11708/1749/1682/3155 ->
11709/1750/1683/3157.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_sense_frame_stamp import DEFERRED as N2520_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
ITEM_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/C07TurretAmmoItemsStampProof'
STAMP_OWNER = 'SourceTurretBuildState.source_turret_ammo_items_stamp_state'
TESTS = ['test_c07_turret_ammo_items_stamp_registration', 'test_all_c07_turret_ammo_items_stamp_input_evidence_is_exact', 'test_turret_ammo_items_stamp_state', 'test_reference_graph_and_actual_c07_turret_ammo_items_stamp']
# The slice sources the N2521 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
    'core/src/mindustry/world/modules/ItemModule.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/power/PowerGraph.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'case totalItems -> items == null ? 0 : items.total();',
    'if(block.hasItems) items = new ItemModule();',
    'hasItems = true;',
    'public int total(){',
    'items.add(item, 1);',
    'totalAmmo += type.ammoMultiplier;',
    'public void updateTile(){',
    'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
    'lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;',
    'lastPowerStored = getBatteryStored();',
]

# DEFERRED is carried from the N2520 register script via import --
# never retyped. No entry is dropped: the stamp completes no
# deferred entry (the 6 N2520 entries describe the stamped keys
# DONE / the unstamped keys DEFERRED / SenseI / controlled() /
# Windows debt, which stay as recorded). New entries below record
# the 2 items keys as DONE by this slice and the still-open work
# with its reasons (the scope's verbatim reasons).
DEFERRED = N2520_DEFERRED + [
    'Turret ammo-items stamp (`items_is_null` / `items_total` frame keys) -- STAMPED by this slice (N2521): `source_turret_ammo_items_stamp_state` writes the 2 keys the tick can supply today into the frame (`items_is_null` as `not has_items` -- only ItemTurret has an item module, `if(block.hasItems) items = new ItemModule();`, BuildingComp.java:145, `hasItems = true;`, ItemTurret.java:28 -- `items_total` as the constant 0, because the `items` module is NEVER written for an ItemTurretBuild: `ItemTurretBuild.handleItem` (ItemTurret.java:155-185) overrides `BuildingComp.handleItem` (:860-862, `items.add(item, 1);`) without calling super, so it only updates `totalAmmo` and the ammo-weighted `ammo` entries; the port\'s `turret_ammo_stacks` are the Java `ammo` Seq, NOT the `items` module, so summing them would invent behavior) and the tick calls it right after `source_turret_sense_frame_stamp_state`; the N2519-wired dispatch stops reporting handled:false for the totalItems leg when a live turret ticks.',
    'Turret sense frame stamp `last_scaled_power_in` / `last_scaled_power_out` / `last_power_stored` / `last_capacity` -- DEFERRED (still, after N2521): the port power graph has NO per-graph last-* snapshot and NO building->graph lookup in the tick (port has per-tick needed/produced/battery totals via `SourcePlacedPowerGraphState.runtime_state`, but not `lastScaledPowerIn/Out`, `lastCapacity`, `lastPowerStored` per graph); waits for the PowerGraph last-values prerequisite slice (PowerGraph.update :233-234 `lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;` `lastScaledPowerOut = powerNeeded / Time.delta;`, :236 `lastPowerStored = getBatteryStored();`); the dispatch keeps handled:false for powerNet* until then.',
    'Non-duo ItemTurret drivers (scatter / salvo / ...) -- DEFERRED: their frames are not stamped by N2521 because no tick driver visits them yet; until their own drivers land, only turrets the tick actually visits read totalItems live.',
    'Composing the SenseI LAccess leg (N2510) with the dispatch at the caller -- DEFERRED (still, after N2521): waits for a logic-executor driver (no LExecutor instruction loop exists in the port yet); the stamped frame is the input that caller will read.',
    'BuildingComp sense() frame stamp `controlled()` live wiring -- DEFERRED (still, after N2521): needs a player unit; when it lands, the tick passes the live player camera value as `unit_sense_value` instead of 0.0.',
    'Turret ammo-items stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520: the N2521 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    stamp_inputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The turret frame (the port Building state) the tick stamps every tick (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126 -- the dispatch reads the stamped keys from this frame); the stamp writes the 2 items keys in place and returns the frame (the N2108 tick-frame precedent).'),
        'has_items': a('bool', 'hasItems = true;', 'Whether the block has an item module (`hasItems = true;`, ItemTurret.java:28 -- the ONLY hasItems set among the 5 ticked implementations; `if(block.hasItems) items = new ItemModule();`, BuildingComp.java:145): the tick passes `str(block.implementation) == "ItemTurret"`; the stamp writes `items_is_null` as `not has_items`.', source=ITEM_TURRET),
    }
    stamp_outputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The stamped frame, with the 2 live items keys set (`items_is_null` as `not has_items`, `items_total` as the constant 0 -- the `items` module is never written for an ItemTurretBuild, so `items.total()` is 0 always) plus every key the frame already carried; the 4 graph keys stay absent, so the dispatch keeps handled:false for powerNet* exactly as N2519/N2520 left them (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126).'),
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
        ('N2521', STAMP_OWNER, 'source_turret_ammo_items_stamp_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', stamp_inputs, stamp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed turret ammo-items stamp from BuildingComp.java:145/2107 + ItemTurret.java:28/155-185 + ItemModule.java:174-176.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed turret ammo-items stamp from BuildingComp.java:145/2107 + ItemTurret.java:28/155-185 + ItemModule.java:174-176.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: frame.
    by_slice['N2521'] = [
        'source_turret_ammo_items_stamp_state_result.frame',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2521', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=STAMP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2521'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
