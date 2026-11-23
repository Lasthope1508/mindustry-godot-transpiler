"""Register the Drill.setStats() booster amount arg (N2434).

Drill.setStats() (Drill.java:175-191): the `:187` line
`consBase.amount,` -- the second argument of the
`StatValues.speedBoosters("{0}" +
StatUnit.timesSpeed.localized(), consBase.amount,
liquidBoostIntensity * liquidBoostIntensity, false,
consBase::consumes)` call (:186-188), the per-frame liquid
amount (`public float amount;`,
ConsumeLiquidBase.java:8) -- was never registered as an
expr. N2332 registered the surrounding call opener
(`StatValues.speedBoosters("{0}" +
StatUnit.timesSpeed.localized(),`, :186) and the
squared-intensity tail (`liquidBoostIntensity *
liquidBoostIntensity, false, consBase::consumes)`, :188),
and used the amount only as the `booster_amount` param
value of the already-live func
source_drill_set_stats_state, which returns it as
`booster_row["amount"]`. The line is 0-hit in BOTH
ledgers (re-probed at base 477d5174).

This slice extends the existing GD function
source_drill_set_stats_state (N2332): it adds no new
owner, no new contract and no new schema (the N2427 /
N2430 registration-only precedent). The 4 result symbols
are shared with N2332 (the shared-symbol precedent).

Main-thread decision (2026-11-22 ~21:5x +07): this
mid-call argument line IS registrable as its own expr,
because it was never registered under any form -- it was
only consumed as a param value. This is NOT the
TractorBeam :165 case (batch 35 section 4c, rejected):
there N1239 had already registered all 4 fragments of
the Drawf.laser call including the 2 args separately, so
the middle line was a comma artifact. It is also NOT
the BurstDrill override line (BurstDrill.java:65,
`consBase.amount, liquidBoostIntensity, false,
consBase::consumes)` -- PLAIN intensity, owned at
N2309): this line is Drill.java:187, SQUARED intensity
on the next line (:188).

NOT re-registered here: `super.setStats();` (:176,
N1696), `stats.add(Stat.drillTier, ...)` (:178-179,
N2332), `stats.add(Stat.drillSpeed, 60f / drillTime *
size * size, StatUnit.itemsSecond);` (:181, N2332),
the guard `:183` (N2332), `stats.remove(Stat.booster);`
(:184, N2332), `StatValues.speedBoosters("{0}" +
StatUnit.timesSpeed.localized(),` (:186, N2332),
`liquidBoostIntensity * liquidBoostIntensity, false,
consBase::consumes)` (:188, N2332).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_drill_set_stats import DEFERRED as N2332_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PROOF = '/root/C07DrillSetStatsBoosterAmountProof'
SET_STATS_OWNER = 'SourceBurstDrillBuildState.source_drill_set_stats_state'
TESTS = ['test_c07_drill_set_stats_booster_amount_registration', 'test_all_c07_drill_set_stats_booster_amount_input_evidence_is_exact', 'test_drill_set_stats_booster_amount_state', 'test_reference_graph_and_actual_c07_drill_set_stats_booster_amount']
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/production/Drill.java',
]
EXACT_EXPRS = [
    'consBase.amount,',
]
SOURCE_SYMBOLS = [
    'source_drill_set_stats_state_result.drill_tier_row',
    'source_drill_set_stats_state_result.drill_speed_row',
    'source_drill_set_stats_state_result.booster_row_removed',
    'source_drill_set_stats_state_result.booster_row',
]

# DEFERRED is carried from the N2332 register script via import --
# never retyped. One entry is added: the N2434 Windows Godot
# proof debt (GOAL.md section 5).
DEFERRED = N2332_DEFERRED + [
    'Drill setStats() booster amount arg Windows Godot proof -- debt in GOAL.md section 5, same as N2332: the N2434 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def verify():
    """Check every EXACT_EXPRS line appears verbatim in its
    upstream source, without touching any SSOT JSON. Exit 0
    when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    total = len(EXACT_EXPRS)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    source_symbols.upsert_source_slice(GODOT, 'N2434', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='Drill.setStats()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {SET_STATS_OWNER}
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
