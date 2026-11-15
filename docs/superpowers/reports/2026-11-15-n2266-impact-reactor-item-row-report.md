# N2266 ImpactReactor Item Row + Timer-Gated Consume (blast-compound) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 8 — wave dynamic/special, integration branch `integration/wave-dynamic-special-n2265-n2269`, base `e07aac89`).

## Source

Def: impact-reactor (Blocks.java:2632-2645) — `consumePower(25f)` (:2642), `consumeItem(Items.blastCompound)` (:2643), `consumeLiquid(Liquids.cryofluid, 0.25f)` (:2644), `itemDuration = 140f` (:2637; class default 60f, ImpactReactor.java:20). `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0. updateTile (ImpactReactor.java:78-101): if `efficiency >= 0.9999f && power.status >= 0.99f` (:79) → warmup lerp + `if(timer(timerUse, itemDuration / timeScale)){ consume(); }` (:91-92). `TimerComp.timer` (TimerComp.java:10-13): false if time infinite, else `Interval.get`; `Interval.get` resets `times[id] = Time.time` on fire (arc Interval.java:20-26); check :28-30; `Time.time` is in TICKS (`timeRaw += delta;`, Time.java:75, update :74-85; delta :26). `ItemModule.has(ItemStack[], float)` (ItemModule.java:153-158). **Scope corrections (grep-verified): `ItemModule.has` :153-158 (not :153-156); `Time.time` accumulation is Time.java:75 (the brief's ":69-80" covers the tail of the preceding method); TimerComp.timer is :10-13 (not :11-14 — the slice files cited :11-14, fixed at integration by d303492e).**

## Implementation

`SourceImpactReactorBuildState.gd`: pure `source_impact_reactor_item_consumer_row_state` (BINARY 1.0/0.0 via `inventory.item_count`; stacks `[{"item": "blast-compound", "amount": 1}]`, catalog matches) → `required_results` (after the liquid row); pure `source_impact_reactor_timer_use_state(elapsed, duration, time_scale)` → `{fired, elapsed_after, threshold}` — the frame-local Interval-equivalent (threshold = duration/time_scale; time_scale ≤ 0 → fired=false; reset to 0.0 on fire, NOT subtract). `_initial_frame` gains `"items": {}`. `timer_use_elapsed` accumulates `source_delta` EVERY tick, unconditionally (mirror of Time.time), before the fold. After the N2192 advance (untouched — the driver diff has only 5 deletions outside it), the warmup gate is recomputed from frame (efficiency ≥ 0.9999 && power_status ≥ 0.99, default 1.0); if the gate holds and the timer fires (140f def) → DIRECT removal of 1 blast-compound (clamped) + elapsed reset to 0.0. The timer check sits inside the `enabled` gate like the advance — Java's disabled early return zeroes efficiency (BuildingComp.java:1954-1957) so a disabled reactor never fires; the port doesn't model that zeroing yet (same rationale as the advance gate). **Documented deviation: first fire** — Java fires (nearly) immediately after placement when the gate first holds (global Time.time already large vs fresh Interval times[]=0); the frame-local clock delays the first fire by one full interval.

## Commits

Slice `a0ddd235` (worker-N2266, branch `slice/N2266-impact-reactor-item-row`, 5 files, +1050/−5, đã push, remote tip verified by ls-remote). Integration cherry-pick `6a05631b` on `integration/wave-dynamic-special-n2265-n2269` (base e07aac89). Coordinator fix d303492e (TimerComp.timer cite :11-14 → :10-13 in the 4 N2266 files, comment-only, after the gate; targeted re-verified 3/4). The cross-proof seeding fix e5412ae9 seeds blast-compound 1 in the N2182/N2192/N2254 proofs.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 28/28, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status N2182, liquid_row N2254, update_tile N2192: Ran 12, 9 PASS), the fails all their Godot proof tests; N2192 non-proof tests pass intact — 0 other failures. Full wave gate (PID 8064, launch 23:07 by coordinator lượt 8, done 23:27 +07): Ran 6166 in 1159.193s, failures=218, skipped=5, 0 errors — 218/218 Godot-absent (213 inherited + 5 new proof tests N2265–N2269).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+2/+4 → 11754/1715/1640/3071; audit stays 1336. Shards touched: `consumer_api_contracts.json`, `consumer_slices.json` (+ 4 canonical files); no KeyError (slice uses `generated_owner=''` with `ConsumeItems.java` as java_source, the N2254 pattern). DEFERRED 289 (289 − 2 resolved + 2 new: first-fire deviation + ImpactReactor frame items intake). **This slice resolves TWO entries** — the item-row entry AND the "ImpactReactor consume-timer rows" entry (its "liquid consumption infrastructure" clause is a red herring — `consume()` only triggers item consumers; ConsumePower/ConsumeLiquid don't override `trigger`, verified by grep) — so the wave resolve count is 6, not 5. Merged wave DEFERRED: 290 entries (DEFERRED-after-dynamic-special.py) — 289 − 6 resolved + 7 new, resolved by entry TEXT not number.

## Godot debt

`C07ImpactReactorItemRowProof` — 6 keys: item_row_binary_blast_compound, item_row_folds_required_min, timer_fires_at_item_duration, timer_no_fire_below_threshold, timer_consume_removes_one, timer_no_fire_when_gate_closed (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
