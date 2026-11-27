# C07 — VM line complete: handoff to the Windows line

Date: 2026-11-27. From: the VM (Linux) line. To: the Windows line.

## What this means

This VM line's part of C07 is finished and pushed. "Finished" here means
**this line's five families only** — it is NOT a claim about the whole C07
chapter, which also includes your families. Your families are yours to
judge; this file only states what this line did, what state it leaves
behind, and what it asks of you.

## This line's C07: done

- Families: Turret, BurstDrill, Radar, Game, BuildTurret. N numbers
  N2449–N2999 (this line's range only).
- Last work: batch 53 (N2482 BuildTurretBuild.warmup, N2483
  GameState.hasSector, N2484 BuildTurretBuild.sense) + batch 54
  (N2485 BuildTurretBuild.senseObject, N2486 BaseTurretBuild.estimateDps,
  N2487 PayloadTurretBuild.getAmmoFraction).
- HEAD at handoff: `e99a5a0b` (N2487), main == origin/main.
- SSOT state: ledger **1962 slices**, registry **12514 symbols**.
- Full gate census at handoff: **7141 tests**. Pass bar: exactly the
  2 pre-existing baseline failures (`test_reference_graph_and_actual_c05_gate`
  and `test_reference_graph_and_actual_unit_factory_consumer_binding`),
  errors = 0.
- The pure-accessor pool in this line's five families is exhausted
  (batch 49 emptied the Rules accessors; batches 50–54 emptied the
  Turret / BuildTurret / Game remainder, the last three slots all needed
  twin-register or generic-literal approval). What remains in these
  families is behaviour / live-path work, not countable accessors.
- Next for this line (user decision 2026-11-27 08:10): move to **C8** —
  run the inventory of the 5,390 null-body functions and classify them
  (source-empty / deferred / real work). This line will not start new
  C07 slices in its families unless the C8 inventory turns up one.

## What the Windows line still owns

- Families: **Weapon, RepairTower, RepairTurret, PointDefenseTurret**.
  N numbers **N3000+** only. Never take a number in N2449–N2999.
- Each family lives in ONE GD file; do not edit this line's family
  files (`SourceTurretBuildState.gd`, `SourceBuildTurretBuildState.gd`,
  `SourceBeamDrillBuildState.gd`, `SourceGameLoopRuntimeState.gd`,
  `SourcePayloadAmmoTurretBuildPortBridge.gd`, and the other files this
  line owns). Shared SSOT JSON (`godot-mindustry/src/generated/`) is
  touched by both lines — one slice at a time, never in parallel.
- If a method you need is already ported under a different class with
  the same body, check the ledger's `exact_exprs` for the body literal
  before assuming it is free: a body can be owned as dependency evidence
  of another slice even when `java_method` is a 0-hit (precedents:
  N2474 isCampaign / N2124, N2483 hasSector / N2474). Twin-register
  needs an explicit approval recorded in the register docstring and the
  ledger `deferred_exprs`; generic-literal reuse (same body, different
  class, e.g. N2479 / N2487 vs N1181) does not.

## Windows proof debt (the main ask)

- `docs/superpowers/GOAL.md` §5 holds **248 unchecked proof entries**
  at handoff. Each is a slice whose proof scene passed on Linux Godot
  ("Linux GREEN", 8 keys) and has **not yet run on Windows Godot**.
  Each entry records its slice's first commit hash.
- Please run those proof scenes on Windows Godot and check each box
  off in GOAL.md §5 as you verify it. A passing actual Godot proof on
  either platform satisfies the hourly-validation duty; do not repeat
  tests solely because Windows evidence is absent for a slice you are
  not otherwise touching.
- Proof scenes live in `godot-mindustry/tools/runtime_proofs/`
  (`C07*.gd` / `.tscn`); the matching pytest module is
  `tools/mindustry_godot_transpiler/tests/test_c07_*.py`.

## Shared state you should know

- Upstream pins: `mindustry-upstream`
  `2bdedfed25932ebf11330d3584092c50e2e26d96`, `arc-upstream`
  `f30acd23ece4b626b755660d56c1b0d4aaf46aed`. GameState.java lives at
  `core/src/mindustry/core/GameState.java`, not `game/`.
- Gate baseline: exactly 2 failures (named above), 0 errors. A third
  failure is acceptable ONLY if it is the known reference-graph
  port-7777 flake: the proof payload still has `matches:true` with all
  keys true, and the test fails only on `assertNotIn('ERROR:', output)`
  because Godot printed `ERROR: [MCP Runtime] Failed to start server
  on port 7777`. Confirm it by re-running that module alone — it passes
  standalone. Never call a new failure a flake without that evidence;
  stash the slice and re-run on clean HEAD first.
- Gate runs sharded (see `docs/gate-sharding.md`): coarse shard A1
  (698 tests) then fine chunks of ≤100 tests; regenerate `shards.json`
  before every gate or new test modules are silently under-covered.
- Never stage `*.gd.uid`, `godot-mindustry/project.godot`,
  `arc-upstream/`, `mindustry-upstream/`, proof `.json`, or gate logs.
  Never `git add .`. Push via HTTPS credential store
  (`git -c credential.helper=store push`); do not write the helper
  into `.git/config` and do not debug SSH to github.com (the VM egress
  proxy resets it — not a key error).

## Contact / coordination

- This line's working notes: `~/workspace/mindustry-godot-transpiler-work/WORKFLOW.md`
  (not in the repo) and the repo's `AGENTS.md` (family split, N ranges,
  gate sharding, wiring-standard test set).
- If the C8 inventory turns up C07 work in this line's families, this
  line will pick it up and say so in the same place (a new handoff
  file here). Until then, consider this line's C07 closed.
