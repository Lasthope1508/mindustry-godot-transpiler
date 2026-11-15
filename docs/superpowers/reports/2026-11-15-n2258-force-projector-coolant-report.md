# N2258 ForceProjector Coolant (ConsumeCoolant 0.1f, manual updateTile consume) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 6 — wave second-consumers-2, integration branch `integration/wave-second-consumers-2-n2256-n2259`, base `73185810`).

## Source

ConsumeCoolant filter (ConsumeCoolant.java:12): `liquid.coolant && temp ≤ 0.5 && flammability < 0.1 && non-gas` (maxTemp 0.5, maxFlammability 0.1 :5; allowLiquid true, allowGas false :6). Liquid.java defaults: coolant=true :50, temp=0.5 :40, flammability=0 :38, gas=false :28, heatCapacity=0.5 :42. The catalog lacks props for many liquids — use Java defaults. Only **water** (heatCap 0.4) and **cryofluid** (heatCap 0.9, temp 0.25) pass the filter. `ConsumeLiquidFilter.efficiency` :50-55 uses ed = edelta with NO efficiencyScale; `getConsumed` :63-76 (current liquid first if filter matches + amount > 0, else first in content order); `update` :42-47. ForceProjector coolant 0.1f (class default, ForceProjector.java:43-44; consumer created :85 with `.boost().update(false)`). Manual update inside `if(buildup > 0)` (:223, :227-232) — efficiency re-evaluated with folded efficiency (:228), scale uses `liquids.current().heatCapacity` (:230), cooldownLiquid 1.2f (Blocks.java:1971). **Scope corrections (verified by grep): the pre-existing cite `ForceProjector.java:69-71` is WRONG (shieldConsumer lambda; correct :43-44 / :84-85); `coolantConsumer.update(this)` is :229 (not :232); `if(buildup > 0){` is :223; the optional pass for-loop is BuildingComp.java:1980, min :1981 (the comment line is :1979, so ":1979-1981" ranges including it are fine).**

## Implementation

`SourceForceProjectorBuildState.gd`: pure `source_force_projector_coolant_consumer_row_state(frame, ...)` (filter + heat-capacity + catalog-props pures alongside) → 3 result symbols: row, has_coolant_row, consumed_liquid. The driver stamps coolant inputs onto frame keys; the N2235 advance prefers frame values and falls back to its params (call shape unchanged — the N2235 test pins the call string). The advance reports consumption via 2 new pure results `coolant_consumed_liquid` / `coolant_consumed_amount`; the driver applies DIRECT removal only when the advance reports consumption (Java consumes by hand in updateTile, :227-231 — `update(false)` means the second pass never consumes it). Register: ledger/contract java_source is ForceProjector.java. **N2235 contract decision:** the advance now returns 2 new keys registered as symbols-only; the N2235 contract's `return_keys` (10 keys) does NOT list them — the validator only checks contract keys ⊆ schema keys, so no merge is required (documented in STATUS.md). Note: the phaseFabric booster item row is still deferred, so optionalEfficiency is incomplete until it lands.

## Commits

Slice `4c0f4b77` (worker-N2258, branch `slice/N2258-force-projector-coolant`, 5 files, +1158/−24, đã push, remote tip verified by ls-remote). Integration cherry-pick `7dd58201` on `integration/wave-second-consumers-2-n2256-n2259` (base 73185810). Coordinator fix `33893e22` at integration: Fracker guard cite :141→:221 in the driver; optional-pass for-loop cite :1979→:1980 in the register.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 36/36, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (N2235 advance + power family: 6/8 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6126 in 1081.029s, failures=208, skipped=5, 0 errors — 208/208 Godot-absent (204 inherited + 4 new proof tests N2256–N2259).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11725/1706/1628/3047; audit stays 1336. DEFERRED 292 (293 − 1 resolved, 0 added). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-2.py) — the ForceProjector live-fill entry's coolant sub-part trimmed by the coordinator (entry stays, coolant wording removed).

## Godot debt

`C07ForceProjectorCoolantProof` — 6 keys: coolant_row_folds_optional_when_present, filter_rejects_non_coolant, get_consumed_prefers_current_liquid, buildup_scale_uses_current_heat_capacity, no_coolant_no_scale, live_tick_consumes_coolant_only_when_buildup (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
