# Handoff N2334 — OverdriveProjector boost scan

## What this slice did

Wired the OverdriveProjector boost scan: a new pure reports the in-range
overdrivable targets (eachBlock rect filter + canOverdrive), and the tick
runs it after the N2194 advance when charge_ready. 5 files, +1116/−10,
commit `0af9b062` on `slice/N2334-overdrive-boost-scan`.

## Key facts for the next agent

- Pure `source_overdrive_projector_supplied_boost_targets_state(candidates,
  real_range, building_x, building_y)` → `{boost_targets, real_range}`:
  rect filter (half-side realRange, INCLUSIVE, center-in-rect — N2277
  precedent) + canOverdrive predicate. Missing x/y → excluded;
  non-Dictionary → excluded; entries never rewritten.
- Tick wiring after the N2194 advance (post-advance phase_heat), gated on
  `charge_ready`; realRange via the existing `projector_range` accessor
  (same formula as drawSelect); position from origin cell + block offset
  (N2306 precedent); result in new frame key `frame["last_boost_scan"]`.
  Charge not ready → Java runs no scan → empty targets at the live
  realRange.
- **Application DEFERRED:** the pure only reports targets;
  `applyBoost(realBoost(), reload + 1f)` waits for its own slice (N2325
  precedent).
- Scope corrections: the real DEFERRED entries are **#190 + #198** (SCOPE
  said #189/#197 — those are BeamDrill draw + Radar fogRadius);
  canOverdrive defaults **true** (Block.java:309, only 6 defs opt out) →
  missing → true (the brief's "missing → false" was wrong); the Java cite
  is :106-111 (brief :107-113 off by one; the N2194 driver comments had the
  same shift — the coordinator aligned them at integration, 3b2e2055).
- No follow-through needed (N2194/N2262 pins untouched).
- SSOT +2/+1/+1/+2 (2 symbols: boost_targets + real_range). DEFERRED
  329→330 (−1 #190 + 2 new; #198 rewritten in place).

## Godot debt (this slice)

- NEW proof `C07OverdriveProjectorBoostScanProof` (6 keys) — never run.
