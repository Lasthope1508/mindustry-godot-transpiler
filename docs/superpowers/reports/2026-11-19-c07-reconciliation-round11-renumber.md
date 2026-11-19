# Reconciliation round 11 — renumber N2261 → N2301 (divergence #32)

## Divergence

- origin/main 458bf37 → **965c45c** (5 commits: slice 4cebe13 + 4 docs). Remote **N2261 =
  TurretBuild.updateTile() logicControlTime decay** (owner
  `source_turret_logic_control_time_state`, 6 exact_exprs, 1 symbol `logic_control_time`, 4
  tests, proof "8 keys" commit-message only — no JSON in the remote tree) collides number-only
  with local **N2261 = TurretBuild.estimateDps()** (12 exact_exprs, proof C07TurretEstimateDpsProof
  **7 keys counted from disk** when batch N2261–N2263 merged). Overlap 0/6 exact_exprs, 0/1
  symbols, 0/4 tests. Different method, same GD file, different owner.
- Probe: `hidden_files/divergence-32-n2261-renumber-impact.md` (15.888 byte). N2301 free in both
  ledgers (verified twice: probe + main thread). Nuance (merge-time, not a renumber blocker):
  remote N2261 shares 3/6 exact_exprs with other local slices (N742/N2270/N2297 — field/accessor
  already live, evidence only); remote N2261 vs N2259/N2260 overlap 0 — the updateTile trio
  (charge → unit sync → logicControlTime) is complementary.

## Renumber

- **N2261 → N2301 (Turret estimateDps), commit `71a8fd1`** (11 files, 288+/288-). Reserve N2301
  by script first (status 'renumbering', next_free_n → 2302). Sed 25 lines: register estimateDps
  (10) + test (9) + warmup register alias/use/comment (3) + proof .gd (1) + spec :334 (whole
  line) + GOAL :387. KEPT per round-4 precedent: `(the N2268/N2261 precedent)` strings in
  other slices' registers/tests/GD comments/proofs (design-precedent references, not data
  pointers), spec :332 round-4 history line, spec :335/:336 batch labels "N2261–N2263",
  historical docs. Script delete: ledger key + 1 contract + 2 schemas + defense shard key +
  defense contract (Turret is a defense family — the shards DO contain it, unlike the Game
  slice in #30).
- Chain re-register **9 registers** in import order (estimate_dps → warmup → find_target →
  tracking_range → write_read → is_active → min_range → status → micro_accessors), --verify
  **20/20 + 44/44 + 87/87 + 18/18 + 36/36 + 17/17 + 16/16 + 25/25 + 28/28**; targeted 4/4
  (40 subtests); family Turret 56/56 (791); wiring 32/32 (250); proof C07TurretEstimateDpsProof
  re-run in main, **7 keys** all true (counted from JSON — the file has 10 keys including
  `one_headquarter_per_ssot` + `registry_valid` + `matches`; 7 is the slice check-key count).
- Key-by-key diff vs HEAD: only N2261 out / N2301 in; 8 downstream entries changed ONLY in
  `deferred_exprs`; 1 contract + 2 schemas + defense contract changed `source_slice`; defense
  shard key swapped. New N2301 entry byte-identical to old N2261 after the number swap.
  SSOT unchanged **11696/1731/1679/3149**. Done 1731.
- **VM restart #30 ~15:38 killed the first gate** (PID 12911, ~98.6% through: log frozen at
  6129 byte, 5903 dots + 221 F + 5 s, no summary; log kept at
  `hidden_files/full-suite-renumber-32-gate-killed-by-restart30.log`). Main thread verified the
  restart from disk (uptime 3 min), recreated the wiped `/usr/local/bin/godot` symlink (the
  researcher's "symlink survived" claim was wrong — it checked `~/workspace/godot-bin/godot`,
  which is not on PATH), verified Godot 4.6.2 + javalang + pytest, and **re-ran the gate
  immediately** (PID 2148, ~15:41–15:59).
- **Re-gate GREEN (PID 2148, ~15:41–15:59): Ran 6217 in 1069.317s, failures=231, skipped=5,
  0 errors** — counted from the log: 231 FAIL headers, all 231 `AssertionError: unexpectedly
  None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors. Log:
  `hidden_files/full-suite-renumber-32-gate.log` (154473 byte). No VM restart during the gate
  (uptime 30 min at 16:08 check).

## Docs (this commit)

- This report + handoff (round 11). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 71a8fd1 (precedent rounds 7/8/9/10); GOAL scene hash stays `b24ced5` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #33 (already probed):** origin 965c45c → 3da46ae. Remote N2262 = Turret rotate
  sync collides number-only with local N2262 = BurstDrill onProximityUpdate (overlap 0/6).
  Probe: `hidden_files/divergence-33-n2262-renumber-impact.md`. Plan: local **N2262 → N2302**
  (free in both ledgers, verified; next_free_n 2302) after this docs commit — renumber #33,
  same rename-at-place technique, then re-gate + docs #33.
- **Batch N2303–N2305 after that** (NOT N2302–N2304 — N2302 goes to renumber #33): Turret
  hasAmmo() + `controlled()` (deferred from N2297), BurstDrill draw(), Game SoundControl.isDark().
  Scope file: `hidden_files/next-batch-scope-after-n2300-renumber30.md` (relabel N2301–N2303 →
  N2303–N2305 before use; its §4 only probed remote collisions up to N2260, re-probe with
  N2261/N2262 at spawn).
- allocations.json: N2301 done (71a8fd1), next_free_n **2302**. N2264 still held (ambient C).
- Push from Windows: local ahead/behind origin/main 3da46ae — recount at push time. Merge by hand
  in the spec at push time. No force-push. Merge-time flags: remote updateTile quartet
  (charge N2259 → unit sync N2260 → logicControlTime N2261 → rotate sync N2262) is
  complementary, no dedup; remote N2261 shares evidence with local N742/N2270/N2297; warmup
  ownership/dedup (remote N2253 vs local N2265) still open; remote recoil family
  N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local N741/N742
  (PortGame-era recoilOffset evidence) still open; `SourceItemTurretBuildState.gd`
  both-modified; remote adds 10 functions to SourceTurretBuildState.gd (charge, unit sync,
  logicControlTime, rotate sync + 6 recoil) that local lacks (plus local N2285 status + N2297
  accessors when merging).
