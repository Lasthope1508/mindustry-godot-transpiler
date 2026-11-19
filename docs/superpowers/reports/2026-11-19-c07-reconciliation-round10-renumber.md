# Reconciliation round 10 — renumber N2259 → N2300 (divergence #30)

## Divergence

- origin/main e9dfee4 → **dbb7bbc** (5 commits: slice e90d146 + 4 docs). Remote **N2259 =
  TurretBuild.updateTile() charge advance** (owner `source_turret_charge_state`, 4 exact_exprs,
  2 symbols `charge`/`charging`, proof "8 keys" commit-message only — no JSON in the remote tree)
  collides number-only with local **N2259 = ambient A, Game headless** (Vars.headless, owner
  `SourceGameHeadlessState.source_game_headless_state`, commit f84c402 round 3, proof
  C07GameHeadlessProof **6 keys counted from disk**). Overlap 0/4 exact_exprs, 0/2 symbols.
  Different class, GD file, owner.
- Probe: `hidden_files/divergence-30-n2259-renumber-impact.md` (24.395 byte, 178 lines; 61 lines
  mention N2259 on disk, 24 to sed). N2300 free in both ledgers (verified twice: probe + main
  thread). Nuance (merge-time, not a renumber blocker): remote N2259 shares 2 exact_exprs with
  local N2265 (warmup) + 1 with local N2297 (micro-accessors) — evidence only, not ownership.
- **Divergence #31 (no action):** origin dbb7bbc → 458bf37. Remote N2260 = Turret unit sync;
  local ledger has no N2260. Probe: `hidden_files/divergence-31-n2260-renumber-impact.md`.
  Ambient B (N2260, Windows line) lost its number to the remote Turret slice — new number needed
  when Windows does it (Windows line's call, not this VM's).
- **Divergence #32 (next):** origin 458bf37 → 965c45c. Remote N2261 = Turret logicControlTime
  decay collides number-only with local N2261 = Turret estimateDps (overlap 0/6 exprs, 0/1
  symbols). Probe: `hidden_files/divergence-32-n2261-renumber-impact.md`. Plan: local
  N2261 → N2301 after this round's docs; batch after that relabels N2301–N2303 → N2302–N2304.

## Renumber

- **N2259 → N2300 (ambient A, Game headless), commit `1faeb9b`** (8 files, 1802+/1802-).
  Reserve N2300 by script first (status 'renumbering', next_free_n → 2301). Sed 25 lines: register
  headless (8) + test headless (8) + register sound-control-loop (7) + spec :331 (whole line) +
  GOAL :381. KEPT per round-4 precedent: spec :355 prose ("precedent N2259" in the N2287 row),
  register/test prose of other slices, historical docs, ledger N2259 range prose in other entries.
  Script delete: ledger key + 1 contract (`SourceGameHeadlessState.source_game_headless_state`)
  + 2 schemas (input/result); defense/production shards verified absent (Game slice).
- **Probe corrections (caught by main-thread verification, not by the probe):** the probe was
  written BEFORE batch N2297–N2299 merged, so it missed the chain link
  `register_c07_sound_control_should_play.py:44` (imports DEFERRED from sound-control-loop) —
  chain re-register is **3 registers** in import order (game_headless → sound_control_loop →
  should_play), not 2. The probe also missed the alias use at sound_control_loop :130
  (`DEFERRED = [e for e in N2259_DEFERRED ...]`) — sedded too, or the register would NameError.
  Lesson for future probes: re-check the import chain against the CURRENT HEAD, not the base the
  probe was written on.
- Chain re-register --verify **7/7 + 88/88 + 12/12**; targeted 12/12 (180 subtests); family
  Game 12/12 (180); wiring 32/32 (250); proof C07GameHeadlessProof re-run in main, **6 keys**
  all true (counted from JSON — the file has 8 keys including `matches` + `module`; 6 is the
  check-key count for this proof, same convention as the original commit f84c402).
- Key-by-key diff vs HEAD: only N2259 out / N2300 in; N2287 + N2299 changed ONLY in
  `deferred_exprs` (2 strings each); 1 contract + 2 headless schemas changed `source_slice`; 3
  loop schemas changed `keys` (number swap only). New N2300 entry byte-identical to old N2259
  after the number swap. SSOT unchanged **11696/1731/1679/3149**. Done 1731.
- **Re-gate GREEN (PID 8681, ~14:39–14:57): Ran 6217 in 1084.276s, failures=231, skipped=5,
  0 errors** — counted from the log: 231 FAIL headers, all 231 `AssertionError: unexpectedly
  None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors. Log:
  `hidden_files/full-suite-renumber-30-gate.log` (154473 byte). No VM restart during the gate
  (uptime 1:27 at 15:03 check).

## Docs (this commit)

- This report + handoff (round 10). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 1faeb9b (precedent rounds 7/8/9); GOAL scene hash stays `f84c402` (the commit
  that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Renumber #32 is NEXT:** local N2261 (Turret estimateDps) → **N2301**. Probe:
  `hidden_files/divergence-32-n2261-renumber-impact.md`. N2301 free in both ledgers (verified).
  Ambient-family renumber, same rename-at-place technique. After renumber #32 → re-gate → docs
  #32 → spawn batch **N2302–N2304** (NOT N2301–N2303 — N2301 goes to the renumber): Turret
  hasAmmo() + `controlled()` (deferred from N2297), BurstDrill draw(), Game SoundControl.isDark().
  Scope file: `hidden_files/next-batch-scope-after-n2300-renumber30.md` (185 lines, read-only
  scope agent, 0-hit both ledgers at N2301–N2303 labels — relabel to N2302–N2304 before use;
  its §4 only probed remote collisions up to N2260, re-probe with N2261 at spawn).
- allocations.json: N2300 done (1faeb9b), next_free_n **2301**. N2264 still held (ambient C).
- Push from Windows: local ahead/behind origin/main 965c45c — recount at push time. Merge by hand
  in the spec at push time. No force-push. Merge-time flags: remote N2259 (charge) + N2260 (unit
  sync) + N2261 (logicControlTime) are a complementary updateTile trio driver-tick family
  (charge → unit sync → logicControlTime → recoilOffset), no dedup; remote N2259 shares evidence
  with local N2265 (2 exprs) + N2297 (1 expr); remote N2261 shares evidence with local N742 /
  N2270 / N2297 (3/6 exprs, field/accessor already live); warmup ownership/dedup (remote N2253
  vs local N2265) still open; remote recoil family N2254+N2255+N2256+N2257+N2258 complementary,
  no dedup; remote N2258 vs local N741/N742 (PortGame-era recoilOffset evidence) still open;
  `SourceItemTurretBuildState.gd` both-modified; remote adds 9 functions to
  SourceTurretBuildState.gd (charge, unit sync, logicControlTime + 6 recoil) that local lacks
  (plus local N2285 status + N2297 accessors when merging).
