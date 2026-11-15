# N2227 RepairTower updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-2, integration branch `integration/wave-advances-2-n2224-n2228`, base `542b383e`).

## Source

- RepairTowerBuild.updateTile (RepairTower.java:57-86): potentialEfficiency > 0 && refresh += Time.delta >= refreshInterval 6f → clear + Units.nearby damaged scan; checkSuppression → warmup=0 return; heal loop healAmount*edelta(); warmup lerpDelta 0.08f; totalProgress += Time.delta/circleSpeed; fields refresh=random(refreshInterval), warmup, totalProgress, targets.
- Def unit-repair-tower: range 100f, healAmount 1.5f.
- potentialEfficiency = efficiency (BuildingComp.java:1989); the driver ALREADY tracks it (`apply_update_consumption_state` writes `frame["potential_efficiency"]`).

## Implementation

- `SourceRepairTowerBuildState.gd`:
  - Pure `source_repair_tower_update_tile_advance_state(frame, ...)` → 5 result symbols: refresh, warmup, total_progress, targets, heal_amounts.
  - Frame key suppression = **`heal_suppressed` (KHÔNG phải `suppressed`)** — AGENTS.md normalize (prefer the SSOT name, no synonym) + N2215 BuildTurret precedent. N2228 initially used `suppressed`; the coordinator renamed it to `heal_suppressed` at integration (fix `f240da22`).
  - The advance reads `potential_efficiency` from the frame with default = efficiency (source-backed by BuildingComp.java:1989). Refresh short-circuit exactly Java: only advances when potentialEfficiency > 0.
  - The N2222 created-seed precedent does NOT apply: the Separator seed derives from tile.pos(), but `refresh = Mathf.random(refreshInterval)` is pure global random → frame default 0.0 (documented deviation, like N2193 charge).
  - `_initial_frame` kept as `{"targets": []}` (N2193 precedent); new keys read via `.get()` defaults. The tick supplies `frame["targets"]` as the refill list (no live scan).
  - A target entry missing the `damaged` key counts as damaged (the scan only admits damaged units, RepairTower.java:63-64) — so the N2213 fixture `{"type": "dart"}` still heals.

## Commits

- Slice `0a768d68` (worker-N2227, branch `slice/N2227-repair-tower-update-tile`, 5 files +1018/−4; đã push 16:57, remote tip 0a768d68).
- Integration cherry-pick `b97dd2d5`; SSOT gộp `e76dd9c8` (wave advances-2): 11507/1669/1592/2975 (slice riêng +5/+1/+1/+2 → 11475/1665/1588/2967).

## Tests

- RED đúng mẫu trước GREEN (2 errors KeyError N2227 + 2 failures).
- Targeted post-register: 3/4 PASS (registration, exact-evidence 35/35, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling RepairTower modules (N2176 power + N2213 gate): 6/8 pass, 2 fail chỉ là proof Godot-absent — driver edits không vỡ assert cũ.
- Targeted wave (5 module): Ran 20, 15 PASS + 5 proof Godot-absent. Neighbours 12 module power+gate+link: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-2: Ran 5969 in 1029.991s, failures=169, skipped=5, 0 errors — 169/169 Godot-absent (164 inherited + 5 new proof tests N2224–N2228).

## SSOT / DEFERRED

- SSOT slice riêng +5/+1/+1/+2 → 11475/1665/1588/2967; audit 1336, legacy 0. **KHÔNG shard nào đổi** — chỉ 4 file SSOT canonical (tiền lệ N2176/N2213).
- DEFERRED 259 (258 − 1 resolved RepairTower advance + 2 new: live targets refresh scan + heal application; suppression live fill). Entry "RepairTower suppression rows" GIỮ NGUYÊN (vẫn đúng — live suppression state chưa được track).
- Note: the old DEFERRED entry "RepairTower live targets refresh" (added by N2213) is kept verbatim — its wording "waits for the updateTile advance slice" is now partly stale, but its core claim (no live fill) is still true.
- DEFERRED gộp sau wave advances-2: 260 entries (258 − 8 resolved + 10 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07RepairTowerUpdateTileProof` — 6 keys: refresh_clears_targets_at_interval, warmup_approaches_efficiency_when_healing (pure + live tick: efficiency 0.5, warmup 0.04, total_progress 1/120, heal_amounts [0.75]), warmup_zero_when_suppressed (incl. proof that refresh still runs before the early return, totalProgress does not advance when suppressed), total_progress_advances, heal_amounts_fold_heal_amount_edelta, frame_defaults_zero.
