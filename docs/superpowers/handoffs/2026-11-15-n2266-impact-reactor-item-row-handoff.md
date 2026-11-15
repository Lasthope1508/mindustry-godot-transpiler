# N2266 ImpactReactor Item Row + Timer-Gated Consume (blast-compound) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave dynamic/special, coordinator lượt 8).

## What this slice did

Blast-compound item row + timer-gated consume in `SourceImpactReactorBuildState.gd` (impact-reactor def Blocks.java:2632-2645; `consumeItem(Items.blastCompound)` :2643; `itemDuration = 140f` :2637; `ConsumeItems.efficiency` BINARY 1/0, ConsumeItems.java:51-53; timer consume inside the warmup gate, ImpactReactor.java:91-92). Pure row function → `required_results` (after the liquid row); pure timer function → `{fired, elapsed_after, threshold}` (frame-local Interval-equivalent: threshold = duration/time_scale; time_scale ≤ 0 → never fires; reset to 0.0 on fire). `timer_use_elapsed` accumulates every tick unconditionally; when the warmup gate holds and the timer fires → DIRECT removal of 1 blast-compound + elapsed reset. The N2192 advance is untouched. `_initial_frame` gains `"items": {}`.

## Key facts for the next agent

**Verified line numbers**: TimerComp.timer :10-13 (NOT :11-14 — fixed at integration by d303492e); Interval.get reset :20-26, check :28-30; `Time.time` ticks (`timeRaw += delta;`, Time.java:75); `ItemModule.has` :153-158. **First-fire deviation (documented)**: Java fires (nearly) immediately after placement; the frame-local clock delays the first fire by one full interval — waits for a global-clock timer-infra slice. **This slice resolves TWO DEFERRED entries** (item row + consume-timer rows). Register: 28 exact exprs, all grep-verified verbatim. DEFERRED: 289 (289 − 2 resolved + 2 new: first-fire deviation + ImpactReactor frame items intake). Slice commit `a0ddd235` (branch `slice/N2266-impact-reactor-item-row`, đã push). Integration cherry-pick `6a05631b`.

## Godot debt (this slice)

`C07ImpactReactorItemRowProof` — 6 keys: item_row_binary_blast_compound, item_row_folds_required_min, timer_fires_at_item_duration, timer_no_fire_below_threshold, timer_consume_removes_one, timer_no_fire_when_gate_closed. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
