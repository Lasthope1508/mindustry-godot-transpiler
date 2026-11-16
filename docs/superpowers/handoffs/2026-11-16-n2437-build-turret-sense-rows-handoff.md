# Handoff N2437 — BuildTurret sense rows

## What this slice did

Two pure-only pures (N2387/N2390/N2391 precedent, no tick wiring):
`source_build_turret_sense_state` (buildX/buildY → unit plan
coordinate, else super_value) + `source_build_turret_sense_object_state`
(building/breaking → unit descriptor, else super_value). 5 files,
+994/−1, commit `62d0d7092` on `slice/N2437-build-turret-sense-rows`.

## Key facts for the next agent

- **LAccess is mindustry.logic.LAccess**, not arc (the brief was
  wrong). Tokens: buildX/buildY (:54-55), building/breaking
  (:59-60).
- **senseObject default is the `noSensed` sentinel**, not null —
  modeled as value null + no_sensed true; the numeric fallback is
  in the logic executor (LExecutor.java:697-700).
- **Stale driver line** (pre-existing): "The draw / write / read /
  sense rows wait for their own slices" still claims draw + sense
  wait though both are live — cleanup candidate.
- SSOT +4/+1/+2/+4 (exact est). DEFERRED #90 resolved (273→272).

## Godot debt (this slice)

- NEW proof `C07BuildTurretSenseRowsProof` (6 keys) — never run.
