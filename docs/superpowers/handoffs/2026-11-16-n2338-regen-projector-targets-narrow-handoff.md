# Handoff N2338 — RegenProjector updateTargets hitbox + privileged narrow

## What this slice did

Chained a hitbox + privileged narrow refinement after the N2277 rect scan:
same-team straddlers with STRICT hitbox overlap are admitted, privileged
blocks are dropped. 9 files, +2810/−6, commit `12436d1a` on
`slice/N2338-regen-projector-update-targets-hitbox`.

## Key facts for the next agent

- Pure `source_regen_projector_update_targets_narrow_state(targets,
  candidates, team_id, building_x, building_y)` → `{targets}`. Pass 1
  keeps rect members minus privileged; pass 2 admits hitbox straddlers.
- **FOUR privileged defs**: world-processor :6955, world-cell :6965,
  world-message :6974, **world-switch :6981** (Blocks.java). The brief,
  SCOPE, and the N2277 docstring all missed :6981; the worker cited all 4
  + fixed the N2277 docstring.
- Defaults: hit_size missing → 0.0; privileged missing → false; missing
  x/y → excluded; non-Dict → skipped.
- The N2277 proof does NOT seed hydrogen (the brief was wrong); this
  proof seeds hydrogen 1.0 + power_status 1.0 + any_targets true (N2325
  pattern).
- DEFERRED net 0 (resolve #249 + 1 new: live privileged flag fill).
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). No shard changed.
- N2277 does NOT need a re-run.

## Godot debt (this slice)

- NEW proof `C07RegenProjectorTargetsNarrowProof` (5 keys) — never run.
