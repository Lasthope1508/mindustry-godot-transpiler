# Handoff N2321 — ItemBridge timerCheckMoved snapshot

## What this slice did

Wired the ItemBridge timerCheckMoved snapshot: a frame-local
Interval-equivalent accumulates `timer_check_moved_elapsed` and, on fire at
literal 30f, snapshots `was_moved = moved` and clears `moved = false` BEFORE
the N2225 advance runs. 5 files, +1048/−4, commit `c551588e` on
`slice/N2321-item-bridge-timer-check-moved`.

## Key facts for the next agent

- Pure `source_item_bridge_timer_check_moved_state(...)` → `{fired,
  timer_elapsed_after, was_moved}`: UNSCALED source_delta, literal 30f (NO
  `/ time_scale`), reset 0 on fire, `time_scale <= 0` → threshold INF
  (elapsed still accumulates).
- **Design addition vs the brief:** the pure takes an extra input `was_moved`
  — it returns `was_moved` even when not firing, so the driver stamps the
  frame unconditionally.
- **`moved` is SHARED with N2225** (owner transport unchanged, verified) —
  the N2321 ledger lists 4 symbols but only 3 are new. Wave SSOT counts +3
  for this slice.
- Live tick pins the literal-30 threshold at overdrive (time_scale 2.0: 29+1
  fires, 9+1 doesn't — absolute elapsed, not scaled).
- SSOT +3 new/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED 323 (−1 #163 +
  1 first-fire deviation).
- Cites: ItemBridge.java:320-323/:25, TimerComp.java:10-13, arc
  Interval.java:20-26 — all verified correct.

## Godot debt (this slice)

- NEW proof `C07ItemBridgeTimerCheckMovedProof` (6 keys) — never run.
