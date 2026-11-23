# Reconciliation round 23 — renumber N2273 → N2319 (divergence #44)

## Divergence

- origin/main c9ab307 → **34c947c** (9 commits: slice 6268070 + 5 docs + 3 evidence
  validation N2272). Remote **N2273 = TurretBuild.shoot() — charge-effect part**
  (owner `SourceTurretBuildState.source_turret_charge_effect_state`, 10 exact_exprs, 3
  symbols, 4 tests, proof "8 keys" commit-message only — remote tree has the .gd +
  .tscn but NO proof JSON) collides number-only with local **N2273 =
  TurretBuild.trackingRange()** (owner
  `SourceTurretBuildState.source_turret_tracking_range_state`, commit 99a4c9f, 13
  exact_exprs, 1 symbol, 4 tests, proof C07TurretTrackingRangeProof **10 keys** all
  true, counted from JSON). Overlap **0/13 exact_exprs**, 0 symbols, 0 tests. Different
  method (`trackingRange()` vs `shoot()` charge-effect), different proof.
- Probe: `hidden_files/divergence-44-n2273-renumber-impact.md` (68 occurrences / 56
  lines / 18 files; main thread re-verified the collision from disk: remote ledger
  added key only N2273; local N2273 still present, N2319 free in both ledgers).
  Merge-time (not a renumber blocker): remote N2273 is the FIRST slice touching
  `TurretBuild.shoot()` in the local ledger — local GD has no
  `source_turret_charge_effect_state`, merging remote adds a new function, no dedup;
  remote N2273 vs remote N2271 (charge sound, #42) are two sub-slices of the same
  `shoot()` — compare at merge. Local N2273 exact_exprs quote `peekAmmo()` as evidence
  — peekAmmo itself is still unowned (batch N2326–N2328 after the renumber queue).

## Renumber

- **N2273 → N2319 (Turret trackingRange), commit `e959ee1`** (11 files, 234+/234-).
  Reserve N2319 by script first (status 'reserved', then 'done' after commit). Sed:
  register tracking_range + register write_read + test tracking_range + proof .gd
  (whole files) + spec :343 (first occurrence only — the row label; the same line's
  "Batch N2271–N2273" history KEPT) + GOAL :405. AGENTS.md: **0 hit** N2273, no edit
  needed. No GD code file mentions N2273 (only the proof comment).
- Script delete: ledger key + 1 contract + 2 schemas (input+result) +
  defense_api_contracts entry + defense_slices key. Asserted each delete count before
  proceeding (ledger 1737 → 1736, contracts 1685 → 1684, schemas 3161 → 3159).
- **Chain re-register 8 registers** in import order (tracking_range → write_read →
  is_active → min_range → status → micro_accessors → unit → has_ammo), --verify
  **18/18 + 36/36 + 17/17 + 16/16 + 25/25 + 28/28 + 15/15 + 21/21**. Post-chain
  full-tree grep: N2273 = 0 in all generated JSON (N2319 = 31 occurrences) and 0 in
  code except the historical "Batch N2271–N2273" labels (spec 3 occurrences + history
  reports/handoffs, kept by precedent). No sibling rule-text stragglers (lesson #42
  check: full generated-JSON grep, not just the ledger). Targeted 4/4 (42 subtests);
  family Turret 64/64 (876); wiring 32/32 (250); proof C07TurretTrackingRangeProof
  re-run in main, **10 keys** all true (7 domain + 3 standard, counted from JSON).
  SSOT unchanged **11716/1737/1685/3161**. Done 1737.

## Gate #43 — six deaths, then the chunked runner (new tool)

- Gate #43 (renumber #43, HEAD 573ebb6) died **six times** as one 18-minute
  `unittest discover` process: attempt 1 (PID 7378) + rerun1 (2141) + rerun2 (3098)
  + rerun3 (2118) + rerun4 (2180) + rerun5 (2935). Only rerun3 died from a verified
  restart (restart #38, 05:45:02, `who -b`). The other five died silently — no
  restart in between (uptime continuous), no traceback, log frozen mid-dots. Earlier
  attributions were wrong and are corrected here: restart #37 (boot 04:20) happened
  BEFORE attempt 1 launched (~04:27), so it did not kill it; the "~05:16" timing once
  reported for restart #38 was arithmetic error (real time 05:45:02). No OOM evidence
  could be established: `dmesg` empty, `journalctl -k` empty, no kern.log/syslog, no
  cgroup memory.events readable — OOM is NOT claimed. RAM stays tight (~7.1/7.9 GB
  used, ~180 MB free) and uptime readings once contradicted each other (05:14 boot
  04:20 vs 05:33 boot 04:37), suggesting sessions may land on different cells — both
  recorded as unproven hypotheses, not causes.
- **Fix: chunked resumable gate** (`hidden_files/gate-runner-chunked.py`, 364 test
  modules run one by one, progress state saved after EVERY module, resume from the
  next un-done module on relaunch; same tests, same counts, just split). Gate #43
  went green on the chunked runner ~07:05: **Ran 6241, failures=237 (all 237
  `unexpectedly None` Godot-absent), errors=0, skipped=5, 364/364 modules** (log
  `hidden_files/full-suite-renumber-43-gate.log` + `.state.json`). The runner takes an
  optional log-path argument; later gates pass their own log.
- **Gate #44 GREEN** on the chunked runner (PID 6749, log
  `hidden_files/full-suite-renumber-44-gate.log`): **Ran 6241, failures=237, errors=0,
  skipped=5, 364/364 modules** — 237 FAIL headers, all 237 `unexpectedly None`, 0
  ERROR (counted from the log by main thread). Renumber #44 is fully closed.

## Docs (this commit)

- This report + handoff (round 23). Spec row + GOAL §5 number were already renumbered
  in the renumber commit e959ee1 (precedent rounds 7–22); GOAL scene hash stays
  `99a4c9f` (the commit that first carried the scene to Windows — the renumber changed
  no scene content).

## Handoff / next

- **Renumber #45 NEXT:** local N2274 (Radar updateTile, 26 exact_exprs, proof 10 keys)
  → **N2320**. Remote N2274 = TurretBuild.updateTile() unit world position (10
  exact_exprs, origin 46d4b30). Number-only, overlap **0/10 exact_exprs**, 0 symbols,
  0 tests. Probe: `hidden_files/divergence-45-n2274-renumber-impact.md` (60
  occurrences / 20 files, chain re-register 5: update_tile → fog_radius → draw →
  draw_select → draw_place). Reserve N2320 by script first (next_free_n is 2320 now).
- **Renumber #46:** local N2275 (Radar fogRadius, 10 exact_exprs, proof 9 keys) →
  **N2321**. Remote N2275 = TurretBuild.updateTile() unit maxHealth (4 exact_exprs,
  origin 192a5bc). Number-only, overlap **0/4**. Probe:
  `hidden_files/divergence-46-n2275-renumber-impact.md` (chain re-register 5).
- **Renumber #47:** local N2276 (Turret write/read/version, 25 exact_exprs, proof
  C07TurretWriteReadProof 11 keys all true) → **N2322**. Remote N2276 =
  TurretBuild.updateTile() unit health (4 exact_exprs, origin 5f0f72c, 5 commits: slice
  a5ccb08 + 4 docs). Number-only, overlap **0/4 exact_exprs**, 0 symbols, 0 tests
  (main thread re-verified from disk; N2320/N2321/N2322 free in both ledgers). Probe:
  `hidden_files/divergence-47-n2276-renumber-impact.md`. Chain re-register per probe.
- Order is strict: #45 → #46 → #47, one at a time, chunked gate + docs after each.
  Then spawn batch **N2323–N2325** (controlled() / DrillBuild.draw() base / 3 music
  getters), then **N2326–N2328** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig /
  findMusic), then **N2329–N2331** (drawSelect / Drill.icons / play), then
  **N2332–N2334** (Turret shouldTurn / BurstDrill shouldConsume / Game reload — scope
  file `hidden_files/next-batch-scope-after-n2327.md` exists). Scope files need
  relabel after the renumber queue (labels on disk are TEMP, pre-#42):
  `next-batch-scope-after-n2315.md` +6 → N2323–N2325,
  `next-batch-scope-after-n2319.md` +6 → N2326–N2328,
  `next-batch-scope-after-n2323.md` +5 → N2329–N2331,
  `next-batch-scope-after-n2327.md` +3 → N2332–N2334. next_free_n after 4 renumbers
  + 4 batches = **2335**. Reserve by script + write spawn lock BEFORE spawning;
  worktrees from latest HEAD (after docs #47); brief includes editor-import uid_cache +
  port-7777-free check + Godot symlink check.
- allocations.json: N2319 done (e959ee1), next_free_n **2320**. N2304 held (ambient C,
  waits for Windows B).
- Push from Windows: local ahead/behind origin/main 5f0f72c = **104 / 196** (counted
  2026-11-20 ~07:5x +07; recount at push time). Merge by hand in the spec at push
  time. No force-push. Merge-time flags: remote N2273 charge effect is new (no dedup,
  first slice touching `TurretBuild.shoot()`); remote N2273 vs remote N2271 (charge
  sound) are two sub-slices of the same `shoot()` — compare at merge; remote N2274
  unit world position is new (local GD has no `source_turret_unit_world_position_state`;
  1/10 expr overlap with local N2307 `unit.tile(this);` is a call-site line, no dedup);
  remote N2275 unit maxHealth vs local N2308 warmup — check overlap at merge (probe
  #46); remote N2276 unit health — check overlap at merge (probe #47); warmup
  ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote recoil family
  N2254–N2258 complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266
  targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) +
  peekAmmo (in batch N2326–N2328) owned before it merges; remote N2267 super.control()
  overlaps local N552/N553/N1088/N1089 (13/15 exprs); remote N2268 configured()
  overlaps local N544–N549/N1751/N1752 (23/26 exprs); remote N2269 queuedBullets/
  charging overlaps local N2308 (2/24 exprs); `SourceItemTurretBuildState.gd`
  both-modified; remote adds functions to SourceTurretBuildState.gd (plus local N2285
  status + N2297 accessors + N2307 unit() + N2313 hasAmmo()).
