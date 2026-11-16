# Handoff N2324 — StackRouter target() live proximity selection

## What this slice did

Wired the StackRouter live target() selection: a new pure simulates
consecutive DuctRouter.target() calls over the frame proximity neighbours
and the tick passes the ordered targets list + stamps cdump into the N2240
advance (replacing the `[]` literal, so live handoffs can finally happen).
6 files, +1002/−10, commit `8d2ef755` on
`slice/N2324-stack-router-target`.

## Key facts for the next agent

- Pure `source_stack_router_target_list_state(...)` → `{targets,
  cdump_after}`. Each simulated call scans from the current cdump, first
  match wins, cdump advances by neighbours scanned INCLUDING the match
  (incrementDump runs on every scanned iteration, DuctRouter.java:148-153).
- A call that scans the whole list without a match returns null and stops
  the sequence (cdump advance = full size = no-op modulo size).
- The pure needs an extra `team` param (brief missed it).
- Tick wiring stamps cdump only when `handed_off > 0`.
- **The N2240 test pin was updated in this slice** (:244, `[]` targets
  literal → live call).
- Scope corrections: target() is DuctRouter.java:139–157 (brief said
  :139–156); the DEFERRED live-fill entry is #189 by the worker, #190 by
  SCOPE — verified by entry TEXT at merge.
- **Trailing-call deviation:** Java calls target() once more after the
  final handoff; the port stops after the last handoff — documented in the
  driver + DEFERRED.
- SSOT +2/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED net 0 (−1+1).

## Godot debt (this slice)

- NEW proof `C07StackRouterTargetProof` (6 keys) — never run.
