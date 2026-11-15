# N2271 Accelerator CanLaunch + Launch — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## What this slice did

Accelerator canLaunch gate + launch transition: 2 pure functions (`source_accelerator_can_launch_state`, `source_accelerator_launch_state`). One-shot frame trigger `launch_requested`: evaluated after the advance; on pass applies the transition (items `{}`, resources snapshot, battery drained by requirement, progress 0.0); cleared on both pass and fail. `launching` is NOT touched by this slice.

## Key facts for the next agent

- **buildConfiguration cites in the brief run 3–4 lines high** — guard :261 (not :265), re-check :264 (not :267), consume() :265 (not :268), resources :266-268, useBatteries :270, progress=0 :271, renderer.showLaunch :273, Time.runTask :275-286, Events.fire :289, method closes :290. The old driver docstring's :270/:271/:289 are CORRECT.
- **drawSelect battery warning is :252** (not :267; the SCOPE's :255-257 is also wrong — fixed in the slice). **PowerGraph.java lives in `core/src/mindustry/world/blocks/power/`** (not `world/modules/`).
- `beginLaunch` (:334-337) sets `launching = true` — called by LaunchAnimator via renderer.showLaunch, NOT by buildConfiguration. `endLaunch` (:392-394) sets `launching = false`. No port equivalent exists yet.
- `consume()` at launch removes exactly the ConsumeItems requirements (copper 8000 / lead 8000 / silicon 5000 / thorium 4000, N2267) → resources = items minus requirements (clamped 0 per stack); then items = `{}`. `resources.add(items)` carries only nonzero remainders (ItemModule.each visits only count ≠ 0, ItemModule.java:100-106; ItemSeq.java:104-106).
- `useBatteries` port: `new_stored = max(0.0, stored - min(stored, requirement))`. Per-battery proportional scaling deferred (the port graph summary has only the total, no battery list). `battery_stored` is a frame INPUT (no live fill — the graph summary computes it but does not stamp it on building frames; only power_status is stamped, N2142).
- Precision: Java float32 rounds `1_000_000f − 0.00001f` back to exactly `1_000_000f`; the port's float64 keeps the epsilon (1e-5 difference on a 1e6 scale) — noted in the docstring.
- SSOT +9/+1/+2/+4 → 11782/1720/1650/3092 (audit 1336). +9 symbols, not the SCOPE-estimated +4 — the 2 result dicts carry 5+4 keys (2 contracts + 4 schemas as estimated). Exact-evidence 42/42. DEFERRED 289 (−2 resolved + 1 new battery_stored live fill + per-battery useBatteries scaling; the launch-rows entry stays).

## Godot debt (this slice)

`C07AcceleratorLaunchProof` — 6 keys: can_launch_false_when_launching, can_launch_requires_full_battery, can_launch_requires_positive_efficiency, can_launch_requires_progress_one, launch_clears_items_and_resets_progress, launch_drains_battery_by_requirement (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_accelerator_launch`. Do NOT mark done until it passes there.
