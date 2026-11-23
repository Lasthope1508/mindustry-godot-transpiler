# Reconciliation round 15 — renumber N2266 → N2309 (divergence #37)

## Divergence

- origin/main c8a5ba8 → **2adf884** (5 commits: slice a421f48 + 4 docs). Remote **N2266 =
  TurretBuild.targetPosition(pos)** (owner `SourceTurretBuildState.source_turret_target_position_control_state`,
  21 exact_exprs, 1 symbol, 4 tests, proof "9 keys" commit-message only — no JSON in the
  remote tree; the probe counted 9 domain keys in the remote proof script) collides
  number-only with local **N2266 = BurstDrill.setStats()** (owner
  `SourceBurstDrillBuildState.source_burst_drill_set_stats_state`, commit 10d3db6 batch
  N2265–N2267, 19 exact_exprs, 2 symbols, 4 tests, proof C07BurstDrillSetStatsProof **5
  domain keys / 8 total, counted from JSON** when that batch merged). Overlap **0/21
  exact_exprs, 0 symbols, 0 tests**. Different method, different GD file, different owner.
- Probe: `hidden_files/divergence-37-n2266-renumber-impact.md`. N2309 free in both ledgers
  (verified: probe + main thread). Nuance (merge-time, not a renumber blocker): remote N2266
  shares 16/21 exact_exprs with local N2122 (Predict evidence — the whole `targetPosition`
  body already lives as evidence in the C06 Predict slice); only 5 exprs are truly new
  (the `intercept(Position...)` overload, the zero-intercept fallback recursion, and the two
  duo default values). Remote targetPosition calls `hasAmmo()` + `peekAmmo()` — hasAmmo (now
  N2311 after the #38 shift, see below) + peekAmmo (T6 queue, no number yet) must be owned
  before merging remote N2266. Local GD has no function
  `source_turret_target_position_control_state` — merging remote adds a new function, no
  name clash. Remote N2266 is the 3rd link of their control() chain (N2264 control() → N2265
  efficiency fold → N2266 targetPosition, called from `control()` :398).

## Renumber

- **N2266 → N2309 (BurstDrill setStats), commit `26fbb10`** (21 files, 1711+/1711-).
  Reserve N2309 by script first (status 'renumbering'). Sed: register setStats (whole file,
  11 places) + test (8 places) + proof .gd (1 place) + spec :338 (first occurrence only —
  the row label; :333 is the N2269 row naming "N2262+N2266 registers re-run" and :348 is
  the N2280 row naming the super leg — both prose precedent in other slices' entries, KEPT)
  + GOAL :395 + write_read register comments (:46/:48) + drill_draw_select :44 +
  drill_ambient_volume :29 + drill_should_ambient_sound :36 + test drill_set_stats :33/:36
  + proof DrillSetStatsProof.gd :38/:41 + GD SourceBurstDrillBuildState.gd :377 (TRAP comment
  in N2280's function, re-pointed per the #36 precedent).
- **Lesson (new, probe missed 6 lines):** after the first sed pass, a full grep of `N2266`
  found 6 more occurrences the probe had not listed — the TRAP + DEFERRED-carry comments in
  the N2271 register (:36, :79, :80) and the N2280 register (:21, :50, :79, :129, :130,
  :138 — six lines after the alias lines were already sed'd). Fixed by whole-file sed on
  both registers. **Rule (extends the #36 lesson): after the probe-listed sed, grep the old
  number across the whole tree (excluding .git/.godot/__pycache__/old reports) and sed every
  live reference — probes list what they found, not what exists.**
- Script delete: ledger key + 1 contract + 2 schemas + production_api_contracts entry +
  production shard key. (The 3rd schema "occurrence" was a rule-text mention, rewritten by
  the register run, not a `source_slice` field.) Asserted each delete count before proceeding.
- **Chain re-register 6 registers** in import order (setStats → ambientVolume → 
  Drill.ambientVolume → Drill.setStats → write/read → shouldAmbientSound), --verify **26/26
  + 11/11 + 11/11 + 54/54 + 28/28 + 20/20**; targeted 4/4 (52 subtests); family
  BurstDrill+Drill 56/56 (922); wiring 32/32 (250); proof C07BurstDrillSetStatsProof re-run
  in main, **5 domain keys (8 total)** all true (counted from JSON — the commit 10d3db6 said
  "5 keys", correct under the domain-key convention).
- Literal N2266 in the ledger = **0** after the chain (N2309 = 24: 1 key + 23 deferred
  mentions — own 4 + downstream 19, matching the probe exactly). Key-by-key diff vs HEAD:
  only N2266 out / N2309 in; 5 downstream entries changed ONLY in `deferred_exprs`; 1
  contract + 2 schemas + production contract changed `source_slice`; production shard key
  swapped; symbol registry + production_symbols rule text rewritten by the register. SSOT
  unchanged **11699/1734/1682/3155**. Done 1734.
- **Gate #37 GREEN (PID 8618, ~20:44–21:02): Ran 6229 in 1084.563s, failures=234, skipped=5,
  0 errors** — counted from the log: 234 FAIL headers, all 234 `AssertionError: unexpectedly
  None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors. Log:
  `hidden_files/full-suite-renumber-37-gate.log`. No VM restart during the gate (uptime 1:37
  at the 21:15 check).

## Docs (this commit)

- This report + handoff (round 15). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 26fbb10 (precedent rounds 7–14); GOAL scene hash stays `10d3db6` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #38 (already probed + verified by main thread from disk):** origin 2adf884 →
  410ac5d (5 commits: slice 5295a7e + 4 docs). Remote N2267 = BuildingComp.control() / Turret
  super.control() collides with local **N2267 = RadarBuild.write()/read()**. Overlap 0/19
  exact_exprs, 0 symbols, 0 tests. Plan: local N2267 → **N2310**, chain re-register 5
  registers in the linear Radar chain (write/read → canPickup → draw → drawSelect →
  drawPlace). Probe: `hidden_files/divergence-38-n2267-renumber-impact.md`. **Do #38 next,
  right after this docs commit.** Merge-time: remote N2267 shares 13/15 exprs with local
  N552/N553/N1088/N1089 (BuildingComp.control() already owned at PortGame level) — dedup
  decision at merge; only 2 exprs truly new.
- **Divergence #39 (NEW, found by main-thread fetch ~21:15, probe agent running):** origin
  410ac5d → **6cfc8b8** (5 commits: slice 1d030ba + 4 docs). Remote **N2268 = Turret
  configured() dispatch effect** (owner `SourceTurretBuildState.source_turret_configured_dispatch_state`,
  26 exact_exprs, 4 symbols, 4 tests, proof "12 keys" commit-message only) collides with
  local **N2268 = TurretBuild.fogRadius()** (renumbered from N2244 in round 4, commit
  83bf0bc). Remote ledger 1717 → 1718 slices, added key only N2268. Probe:
  `hidden_files/divergence-39-n2268-renumber-impact.md` (agent running at docs time). Likely
  plan: local N2268 → **N2311** (N2310 is #38's) — confirm from the probe, do **#38 first,
  #39 second**.
- **Batch labels shift +1 again if #39 takes N2311:** hasAmmo / BurstDrill draw / isDark →
  **N2312–N2314**; `controlled()` (+ charging alternate) → **N2315–N2317**; next_free_n after
  #37 + #38 + #39 + both batches = **2318**. Scope file
  `hidden_files/next-batch-scope-after-n2310.md` (refreshed 20:34, base 26fbb10) still
  carries the pre-#39 labels N2311–N2313 / N2314–N2316 — relabel before spawning. hasAmmo
  side-effect note stands: the `ammo.swap(...)` modelling needs main-thread confirmation in
  scope before spawn.
- allocations.json: N2309 done (26fbb10), next_free_n **2310**. N2304 held (ambient C, waits
  for Windows B).
- Push from Windows: local ahead/behind origin/main 6cfc8b8 — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: remote updateTile driver-tick
  family charge N2259 → unit sync N2260 → logicControlTime N2261 → rotate sync N2262 →
  heatReq N2263 → efficiency fold N2265 (fold runs BEFORE warmup when merged); control() chain
  N2264 → N2266 targetPosition → N2267 super.control → **N2268 configured() dispatch**
  (remote N2264 already owns Turret control(), local `controlled()` still unported); remote
  recoil family N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local
  N741/N742 still open; warmup ownership/dedup (remote N2253 vs local N2308) still open;
  remote N2266 vs local N2122 still open; remote N2267 vs local N552/N553/N1088/N1089 still
  open; `SourceItemTurretBuildState.gd` both-modified; remote adds 16 functions to
  SourceTurretBuildState.gd that local lacks (plus local N2285 status + N2297 accessors +
  N2307 unit() when merging).
