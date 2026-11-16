# Handoff N2448 — StackConveyor blends/plan/rotated rows

## What this slice did

Three pure-only pures (no tick wiring):
`source_stack_conveyor_blends_state` (all predicates
caller-supplied; state Variant null = not a StackConveyorBuild) +
`source_stack_conveyor_draw_plan_state` (bits caller-supplied,
getTiling CALL record) +
`source_stack_conveyor_rotated_output_state`. 5 files, commit
`9636bd0ce` on `slice/N2448-stack-conveyor-blends-plan-rows`.

## Key facts for the next agent

- **BRIEF ERROR — Java wins:** stateMove=0, stateLoad=1,
  stateUnload=2 (the brief said stateLoad 0).
- **Plan rect key is "rotation"** (N2438/N2442/N2434 convention).
- **setStats entry ADDED** (verified uncovered) — the merge
  allows the genuine addition through (N2430 precedent).
- SSOT +4/+1/+3/+6 (exact est). DEFERRED #58 resolved, list 258.

## Godot debt (this slice)

- NEW proof `C07StackConveyorBlendsPlanRowsProof` (6 keys) —
  never run.
