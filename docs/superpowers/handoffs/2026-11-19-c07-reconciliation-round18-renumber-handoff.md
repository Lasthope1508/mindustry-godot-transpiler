# Handoff — reconciliation round 18 (renumber N2269 → N2312, divergence #40)

## Done
- **Renumber #40: local N2269 (BurstDrill icons) → N2312, commit `9cd9f9a`** (17 files,
  1546+/1546-). Sed: register icons + on_proximity_update register (whole file) + test icons
  + proof .gd + spec :333 (first occurrence only) + GOAL :385 + 6 line-targeted register
  seds. Probe listed everything — full-tree grep after sed found no missed live reference.
  Delete ledger key + 1 contract + 2 schemas + production contract + production slice key.
  Chain re-register **8 registers** (icons → on_proximity_update → set_stats →
  ambient_volume → drill_ambient_volume → should_ambient_sound + write_read +
  drill_set_stats). --verify 13/13 + 49/49 + 26/26 + 11/11 + 11/11 + 20/20 + 28/28 +
  54/54; targeted 4/4 (28); family BurstDrill+Drill 60/60 (966); wiring 32/32 (250); proof
  C07BurstDrillIconsProof re-run in main, 3 domain keys (6 total) all true. Literal N2269
  in the ledger = 0 (N2312 = 9). SSOT unchanged 11699/1734/1682/3155. Done 1734.
- **Gate #40 GREEN (PID 21632, ~22:59–23:17): Ran 6229 in 1083.724s, failures=234,
  skipped=5, 0 errors** — all 234 `unexpectedly None`. Log
  `hidden_files/full-suite-renumber-40-gate.log`. No VM restart during the gate (uptime 3:54
  at the 23:31 check).
- **Origin moved, NOT a divergence:** a95971b → 38067ef (2 evidence commits N2433–N2435),
  remote ledger unchanged 1719 slices.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round18-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 9cd9f9a.

## Next — batch N2313–N2315 continuations, then batch N2316–N2318
- **Batch N2313–N2315 (hasAmmo / BurstDrill draw / isDark) — continuations:** cron spawned
  the batch at 23:15 and its 900s timeout cut all 3 workers short before GREEN+proof.
  Disk state verified by main thread: N2313 + N2314 wrote nothing (read-only prep only);
  N2315 wrote GD function + test + register (uncommitted, no verify/proof yet). Worktrees
  (base 9cd9f9a): `~/workspace/mindustry-wt-n2313-turret`,
  `~/workspace/mindustry-wt-n2314-burstdrill`, `~/workspace/mindustry-wt-n2315-game`.
  **Spawn 3 continuation workers from the main thread** (not cron — main-thread spawns
  are not subject to the 900s limit): N2313 full slice (read the scope file's hasAmmo
  section first — `ammo.swap(...)` modelling needs main-thread confirmation in scope);
  N2314 full slice; N2315 verify-first (register --verify, targeted, family, wiring,
  proof — do not rewrite what is already written). Scope:
  `hidden_files/next-batch-scope-after-n2312.md` (base 9cd9f9a, labels N2313–N2315 /
  N2316–N2318 — verify against allocations.json before spawning). Briefs include
  editor-import uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream
  symlinks. Merge in N order, then gate once, then docs batch.
- Then batch **N2316–N2318** (`controlled()` + charging alternate — note: remote N2269
  already owns a `charging()` gate; local `charging()` slice scope must check overlap with
  remote N2269 at spawn time); next_free_n ends at **2319**.
- allocations.json: N2312 done (9cd9f9a); N2313–N2315 reserved (owner cron, base 9cd9f9a),
  next_free_n 2316, spawn_lock active. N2304 held (ambient C, waits for Windows B).
- Push from Windows: local ahead/behind origin/main 38067ef — recount at push time. Merge by
  hand in the spec at push time. No force-push.
