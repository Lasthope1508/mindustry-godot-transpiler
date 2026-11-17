"""Register the RepairTower heal advance (N2228).

The remainder of RepairTowerBuild.updateTile() (RepairTower.java:69-85):
the suppression gate (`if(checkSuppression()){` / `warmup = 0f;` /
`return;`, RepairTower.java:69-72), the heal loop (`boolean any =
false;` / `if(efficiency > 0){` / `for(var target : targets){` /
`if(target.damaged()){` / `target.heal(healAmount * edelta());` /
`any = true;`, RepairTower.java:74-82), the warmup lerp (`warmup =
Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`,
RepairTower.java:84) and the totalProgress advance (`totalProgress
+= Time.delta / circleSpeed;`, RepairTower.java:85). The target
refresh (RepairTower.java:59-66) is N2190, the shouldConsume gate
(RepairTower.java:89-90) is N2191, the driver stamp of the live
nearby-damaged count is N2211. The ozone liquid consumer
(`consumeLiquid(Liquids.ozone, 3f / 60f);`, Blocks.java:6583) is NOT
this slice: its fold needs a liquid-stock observation no frame
carries yet (the N2187 cryofluid precedent -- a consume row of its
own, after a liquid-stock observation lands).

RED decisions (resolved at RED): (1) One pure function on
SourceRepairTowerBuildState.gd, after
source_repair_tower_should_consume_state:
source_repair_tower_heal_advance_state(frame, targets, heal_amount,
delta, circle_speed, suppressed) returning `{"suppressed": ...,
"any": ..., "healed_count": ..., "warmup": ..., "total_progress":
..., "targets": ..., "heal_amount": ...}`. `targets` is an explicit
Array param (Java heals the `targets` Seq, RepairTower.java:76;
no frame key stamps a live targets list yet -- scope section 10(a)
-- so the driver passes `frame.get("targets", [])` and the advance
still runs warmup/totalProgress with zero targets, exactly Java
with an empty list). `suppressed` is an explicit bool param (the
driver reads `frame.get("heal_suppressed", false)`; no frame stamps
it yet and the default false is the Java default,
`healSuppressionTime = -1f`, BuildingComp.java:93 -- scope section
10(b), re-pinned: the bridges are the static funcs
`SourceBuildingLifecycleState.is_heal_suppressed_state`
(:408) and `SourceBuildingLifecycleState.check_suppression_state`
(:463), NOT `SourceBuildingLifecyclePortBridge.
source_building_check_suppression_state`, which does not exist).
(2) efficiency reads `frame.get("efficiency", 1.0)` (the N2176 /
N2182 fold precedent); efficiency <= 0 skips the heal loop but the
warmup lerp and totalProgress advance still run (RepairTower.java:84-85
sit outside the `if(efficiency > 0){` block). (3) damaged() is
`health < maxHealth - 0.001f` (HealthComp.java:47-49), NOT `health
< maxHealth`; the heal is `heal_amount * edelta()` with edelta =
efficiency * delta (BuildingComp.java:1927-1928, `return efficiency
* delta();`, delta() = Time.delta * timeScale, BuildingComp.java:1922-1923,
timeScale = 1 default) and clamps at maxHealth
(HealthComp.java:109-112, `health += amount;` / `clampHealth();`
with `health = Math.min(health, maxHealth);`, HealthComp.java:104).
The returned targets are DUPLICATES with the healed health (the
N2213 precedent) -- the input list is not mutated, so the driver
stamps the returned list. (4) warmup lerps through the shared
helper `SourceMathState.source_lerp_delta` (SourceMathState.gd:52-53,
`lerpf(from, to, clampf(delta * progress, 0, 1))` -- exactly
Mathf.lerpDelta with Time.delta = delta; the N2215 strength-lerp
math precedent) toward `efficiency` when any target healed, else
toward 0. warmup reads `frame.get("warmup", 0.0)` (field default,
RepairTower.java:52) and total_progress reads
`frame.get("total_progress", 0.0)` (field default, RepairTower.java:53).
(5) The driver calls the heal advance after the refresh in the
powered branch (Java runs refresh :59-66 before heal :74-82 in the
same updateTile(), and updateConsumption() runs before updateTile(),
BuildingComp.java:2274/2277) with the per-def healAmount
(`healAmount = 1.5f;`, Blocks.java:6580, falling back to the class
default `public float healAmount = 1f;`, RepairTower.java:24 -- the
driver reads `block.properties.get("healAmount", 1.0)`, the N2211
range precedent) and circleSpeed 120f (RepairTower.java:23, Blocks
does not override), stamping `frame["warmup"]`,
`frame["total_progress"]` and `frame["targets"]` live. Seven new
result symbols: suppressed + any + healed_count + warmup +
total_progress + targets + heal_amount. Slice sources:
RepairTower.java + HealthComp.java + BuildingComp.java + Blocks.java.
Shard note: the N2219-N2227 precedent applies -- no source_modules
shard matches RepairTower.java (`/world/blocks/units/`, not
`/world/blocks/power/`), so the GREEN register run must record that
no shard changes.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TOWER = 'core/src/mindustry/world/blocks/units/RepairTower.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTowerHealAdvanceProof'
HEAL_OWNER = 'SourceRepairTowerBuildState.source_repair_tower_heal_advance_state'
TESTS = ['test_c07_repair_tower_heal_advance_registration', 'test_all_c07_repair_tower_heal_advance_input_evidence_is_exact', 'test_repair_tower_heal_advance_state', 'test_reference_graph_and_actual_c07_repair_tower_heal_advance']
# The 4 slice sources the N2228 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTower.java',
    'core/src/mindustry/entities/comp/HealthComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public class RepairTower extends Block{', 'static final float refreshInterval = 6f;', 'public float range = 80f;', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'public float healAmount = 1f;', 'public float refresh = Mathf.random(refreshInterval);', 'public float warmup = 0f;', 'public float totalProgress = 0f;', 'public Seq<Unit> targets = new Seq<>();', 'public void updateTile(){', 'if(checkSuppression()){', 'warmup = 0f;', 'return;', 'boolean any = false;', 'if(efficiency > 0){', 'for(var target : targets){', 'if(target.damaged()){', 'target.heal(healAmount * edelta());', 'any = true;', 'warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);', 'totalProgress += Time.delta / circleSpeed;', 'boolean damaged(){', 'return health < maxHealth - 0.001f;', 'void heal(float amount){', 'health += amount;', 'clampHealth();', 'health = Math.min(health, maxHealth);', 'public boolean isHealSuppressed(){', 'return block.suppressable && Time.time <= healSuppressionTime;', 'public boolean checkSuppression(){', 'if(isHealSuppressed()){', 'return true;', 'return false;', 'public float delta(){', 'return Time.delta * timeScale;', 'public float edelta(){', 'return efficiency * delta();', 'range = 100f;', 'healAmount = 1.5f;']

# DEFERRED is carried from the N2227 register script via import --
# never retyped. The N2227 script's DEFERRED is a computed
# expression (list comprehension over the N2226 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it (ValueError: malformed node); the
# import recovers the runtime value verbatim. NOTE for the next
# slice: N2228's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval. NOTE on the chain: the N2190/N2191 ledger
# entries record a 'RepairTower heal / warmup / totalProgress
# advance ... waits for its own slice' deferred entry, but that
# entry is ABSENT from the carried chain by N2210 (N2210 DEFERRED
# has 155 entries, none of them the heal entry; N2211 branched its
# import from N2210, not from N2191) -- so N2228 closes work whose
# carried deferred row was already lost upstream, and there is no
# entry to drop here. The N2190/N2191 ledger snapshots keep their
# own (now stale) deferred lists, as the ledger records the
# registration-time snapshot.
DEFERRED = list(N2227_DEFERRED) + [
    'RepairTower heal advance Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2227: the N2228 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    heal_inputs = {
        'frame': a('Dictionary', 'public float warmup = 0f;', 'The tower frame (RepairTower.java:52-53, `public float warmup = 0f;` / `public float totalProgress = 0f;` -- the frame carries warmup, total_progress and the folded efficiency; absent keys read the Java field defaults: warmup 0, total_progress 0, efficiency 1.0, the N2176 fold).'),
        'targets': a('Array', 'public Seq<Unit> targets = new Seq<>();', 'The refresh target list (RepairTower.java:54, `public Seq<Unit> targets = new Seq<>();` -- Java heals this Seq, RepairTower.java:76; passed explicitly because no frame key stamps a live targets list yet, so the driver passes `frame.get("targets", [])` and the advance still runs warmup/totalProgress with zero targets, exactly Java with an empty list).'),
        'heal_amount': a('float', 'healAmount = 1.5f;', 'The per-def healAmount (Blocks.java:6580, `healAmount = 1.5f;` -- class default `public float healAmount = 1f;`, RepairTower.java:24; the driver reads `block.properties.get("healAmount", 1.0)`, the N2211 range precedent).', source=BLOCKS),
        'delta': a('float', 'return efficiency * delta();', 'The tick delta in seconds (BuildingComp.java:1928, `return efficiency * delta();` -- edelta is efficiency * delta, and delta() is Time.delta * timeScale, BuildingComp.java:1922-1923, timeScale = 1 default; the driver passes its per-tick seconds).', source=BUILDING_COMP),
        'circle_speed': a('float', 'public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', 'The circle speed (RepairTower.java:23 -- Blocks does not override it; the driver passes the 120f literal).'),
        'suppressed': a('bool', 'if(checkSuppression()){', 'Whether checkSuppression() fired this tick (RepairTower.java:69, `if(checkSuppression()){` -- the driver reads `frame.get("heal_suppressed", false)`; no frame stamps it yet and the default false is the Java default, `healSuppressionTime = -1f`, BuildingComp.java:93; the bridges are `SourceBuildingLifecycleState.is_heal_suppressed_state` :408 and `check_suppression_state` :463, and live suppression plumbing waits for its own slice).'),
    }
    heal_outputs = {
        'suppressed': a('bool', 'if(checkSuppression()){', 'Whether the suppression gate fired this tick: checkSuppression() zeroes warmup and returns early (RepairTower.java:69-72, `if(checkSuppression()){` / `warmup = 0f;` / `return;`) -- no heal, no totalProgress advance.'),
        'any': a('bool', 'boolean any = false;', 'Whether any target was healed this tick (RepairTower.java:74, `boolean any = false;`, set `any = true;` only when a damaged target is healed, RepairTower.java:79 -- drives the warmup lerp target, RepairTower.java:84).'),
        'healed_count': a('int', 'any = true;', 'How many targets were healed this tick (RepairTower.java:79, `any = true;` -- one count per damaged target healed; 0 when efficiency <= 0 or no target is damaged).'),
        'warmup': a('float', 'warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);', 'The warmup after this tick: lerpDelta toward efficiency when any target healed, else toward 0 (RepairTower.java:84 -- runs every non-suppressed tick, outside the `if(efficiency > 0){` block; 0.0 on the suppression early return).'),
        'total_progress': a('float', 'totalProgress += Time.delta / circleSpeed;', 'The totalProgress after this tick: advanced by delta / circleSpeed (RepairTower.java:85 -- runs every non-suppressed tick; unchanged on the suppression early return).'),
        'targets': a('Array', 'health = Math.min(health, maxHealth);', 'The targets after this tick: duplicates of the input list with the healed health, clamped at maxHealth (HealthComp.java:104, `health = Math.min(health, maxHealth);` -- the N2213 duplicate precedent; the input list is not mutated, so the driver stamps the returned list).', source=HEALTH_COMP),
        'heal_amount': a('float', 'target.heal(healAmount * edelta());', 'The health added per healed target this tick: healAmount * edelta (RepairTower.java:78 -- 0.0 when efficiency is 0 or the suppression gate fired).'),
    }
    return heal_inputs, heal_outputs


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
    heal_inputs, heal_outputs = definitions()

    entries = [
        ('N2228', HEAL_OWNER, 'source_repair_tower_heal_advance_state', REPAIR_TOWER, 'mindustry.world.blocks.units.RepairTower.RepairTowerBuild', 'RepairTowerBuild.updateTile()', heal_inputs, heal_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTower heal advance from RepairTower.java / HealthComp.java / BuildingComp.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTower heal advance from RepairTower.java / HealthComp.java / BuildingComp.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: suppressed + any + healed_count
    # + warmup + total_progress + targets + heal_amount.
    by_slice['N2228'] = [
        'source_repair_tower_heal_advance_state_result.suppressed',
        'source_repair_tower_heal_advance_state_result.any',
        'source_repair_tower_heal_advance_state_result.healed_count',
        'source_repair_tower_heal_advance_state_result.warmup',
        'source_repair_tower_heal_advance_state_result.total_progress',
        'source_repair_tower_heal_advance_state_result.targets',
        'source_repair_tower_heal_advance_state_result.heal_amount',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2228', dict(status='done', java_source=REPAIR_TOWER, java_class='mindustry.world.blocks.units.RepairTower.RepairTowerBuild', java_method='RepairTowerBuild.updateTile()', godot_owner=HEAL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2228'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
