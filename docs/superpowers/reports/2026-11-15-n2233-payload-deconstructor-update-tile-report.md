# N2233 PayloadDeconstructor updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-3, integration branch `integration/wave-advances-3-n2229-n2234`, base `ff82ab1d`).

## Source

- PayloadDeconstructorBuild.updateTile (PayloadDeconstructor.java:109-204): dumpRate 4 × dumpAccumulate (:111-116 — deferred); deconstructing == null → progress = 0 (:118-120); payRotation moveToward 90f with **edelta()** (:122); canProgress = total <= capacity && all accum < 1f (:126-129); shift = edelta() * deconstructSpeed 2.5f / buildTime (:132); realShift = min(shift, 1 − progress) (:133); **progress += shift (NOT realShift — can exceed 1)** (:134); time += edelta; accum += reqs * multiplier * realShift; speedScl lerpDelta 0.1f (:141); transfer taken = min((int)accum, capacity − total) (:144-150); progress >= 1f → rounding check equal(accum, 1f, 0.0001f) → finish (deconstructing = null, accum = null) (:154-162); else moveInPayload(false) intake (:164-202).
- payRotation uses **edelta**, moveIn uses **delta** — both honored.
- UnitPayload buildTime = `unit.type.getBuildTime()` (UnitPayload.java:66-68) — the scope's `unit.buildTime` was WRONG; corrected in this slice.
- Constants: maxPayloadSize 4, deconstructSpeed 2.5f, dumpRate 4 (:18-20).

## Implementation

- `SourcePayloadDeconstructorBuildState.gd`:
  - Pure `source_payload_deconstructor_update_tile_advance_state(frame, ...)` → 10 result symbols: progress, time, speed_scl, accum, items, deconstructing, payload, pay_vector, pay_rotation, finished.
  - Guard `shift = 0` when build_time <= 0 protects the minimal N2166/N2210 fixtures (N2222 precedent).
  - Reuses `source_angles_move_toward` / `source_math_state` lerp delta + inventory helpers + SourceRulesRuntimeState unit cost (build cost reads the rules dict, default 1.0).
  - arc-upstream was MISSING from the worker worktree — worker rsynced it (716 files, 0 zero-byte).

## Commits

- Slice `1b5264f8` (worker-N2233 re-spawn after VM restart 4, branch `slice/N2233-payload-deconstructor-update-tile`, 5 files +1352/−7; đã push 17:41, remote tip 1b5264f8).
- Integration cherry-pick `8040e691`; SSOT gộp `b5129382` (wave advances-3): 11568/1675/1598/2987 (slice riêng +10/+1/+1/+2 → 11517/1670/1593/2977).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 68/68, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent. Proof pins `progress += shift` (1.05) — NOT realShift.
- Sibling N2166 power + N2210 gate: 6/8 PASS, 2 fail đều là proof Godot-absent — không regression.
- Targeted wave (6 module): Ran 24, 18 PASS + 6 proof Godot-absent. Neighbours 12 module power+gate: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-3: Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors — 175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).

## SSOT / DEFERRED

- SSOT slice riêng +10/+1/+1/+2 → 11517/1670/1593/2977; audit 1336, legacy 0. Payload shards đổi (`payload_api_contracts` + `payload_slices`, N2210/N2166 precedent).
- DEFERRED 262 (260 − 1 resolved + 3 new: puddles dump, moveIn live payload positioning, Fx.breakBlock finish effect).
- DEFERRED gộp sau wave advances-3: 265 entries (260 − 14 resolved + 19 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PayloadDeconstructorUpdateTileProof` — 7 keys (6 scope + live_tick_advances_progress, deliberate): progress_advances_with_edelta, accum_folds_requirements, transfer_moves_whole_items, finish_clears_deconstructing, intake_moves_payload_to_deconstructing, progress_zero_without_deconstructing, live_tick_advances_progress.
