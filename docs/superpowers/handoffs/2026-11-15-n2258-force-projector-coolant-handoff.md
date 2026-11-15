# N2258 ForceProjector Coolant (ConsumeCoolant 0.1f, manual updateTile consume) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-2, coordinator lượt 6).

## What this slice did

ConsumeCoolant optional row in `SourceForceProjectorBuildState.gd` (ConsumeCoolant.java:12 filter; ConsumeLiquidFilter.java:50-55 efficiency with ed = edelta, NO efficiencyScale; :63-76 getConsumed; :42-47 update): coolant 0.1f (ForceProjector.java:43-44, consumer :85 with `.boost().update(false)`). Pure `source_force_projector_coolant_consumer_row_state` → 3 result symbols: row, has_coolant_row, consumed_liquid. The driver stamps coolant inputs onto frame keys; the N2235 advance prefers frame values, falls back to params; the advance reports `coolant_consumed_liquid` / `coolant_consumed_amount` and the driver removes directly only when consumption is reported (Java consumes by hand in updateTile :227-231 inside `if(buildup > 0)` :223).

## Key facts for the next agent

**Verified line numbers**: filter ConsumeCoolant.java:12 (maxTemp 0.5, maxFlammability 0.1 :5; allowLiquid true, allowGas false :6); Liquid.java defaults coolant=true :50, temp=0.5 :40, flammability=0 :38, gas=false :28, heatCapacity=0.5 :42; only **water** (heatCap 0.4) and **cryofluid** (heatCap 0.9, temp 0.25) pass the filter; efficiency :50-55, getConsumed :63-76, update :42-47; coolant 0.1f ForceProjector.java:43-44, consumer :85; manual update :223/:227-232, re-evaluated efficiency :228, `coolantConsumer.update(this)` :229, heatCapacity scale :230; cooldownLiquid 1.2f Blocks.java:1971. **The pre-existing cite `ForceProjector.java:69-71` is WRONG** (shieldConsumer lambda; correct :43-44 / :84-85). **N2235 contract decision:** the 2 new advance keys are registered symbols-only; the N2235 contract's `return_keys` (10 keys) does NOT list them — the validator only checks contract keys ⊆ schema keys, so no merge is required. **update(false) means the second pass never consumes** — the driver removes directly only when the advance reports consumption. Register: ledger/contract java_source is ForceProjector.java. Register: 36 exact exprs, all grep-verified verbatim. DEFERRED: 292 (293 − 1 resolved, 0 added). PhaseFabric booster item row still deferred — optionalEfficiency incomplete until it lands. Slice commit `4c0f4b77` (branch `slice/N2258-force-projector-coolant`, đã push). Integration cherry-pick `7dd58201`; coordinator fix `33893e22` (Fracker guard cite :141→:221; optional-pass for-loop cite :1979→:1980).

## Godot debt (this slice)

`C07ForceProjectorCoolantProof` — 6 keys: coolant_row_folds_optional_when_present, filter_rejects_non_coolant, get_consumed_prefers_current_liquid, buildup_scale_uses_current_heat_capacity, no_coolant_no_scale, live_tick_consumes_coolant_only_when_buildup. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
