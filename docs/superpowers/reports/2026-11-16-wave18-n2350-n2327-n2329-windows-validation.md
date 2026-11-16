# Windows Godot validation: N2350, N2327 and N2329 on wave18

All three selected proofs passed on Windows Godot 4.6.2 stable: 12/12 targeted tests and three native MCP scenes, each with 9/9 total keys true. No fixture or implementation changes were needed.

## Snapshot and results

- Integration: `integration/wave-advances-18-n2358-n2364`, SHA `46b1b951bb5c8052248cc62d6da8ddc36321709c`, containing wave17 and the N2323 UCL fixture fix.
- Main report baseline: `a4562e05ba5e5bcc9737d0de0581bd3692daad52`.
- Isolated validation branch: `codex/godot-wave18-batch-validation`.
- Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Integration slice / scene | Targeted result | Native result |
| --- | --- | --- |
| N2350 `C07MendProjectorHealScanHitboxProof` | 4/4, 21.713s | 9/9 keys true, matches true |
| N2327 `C07ShockwaveTowerBulletScanProof` | 4/4, 21.190s | 9/9 keys true, matches true |
| N2329 `C07MendProjectorHealScanRangeProof` | 4/4, 21.281s | 9/9 keys true, matches true |

Commands, sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_mend_projector_heal_scan_hitbox -v
python -m unittest tests.test_c07_shockwave_tower_bullet_scan -v
python -m unittest tests.test_c07_mend_projector_heal_scan_range -v
```

Actual engine tests require exit 0, no `ERROR:`, matches true and all semantic keys true. The three native MCP launches additionally exposed the runtime server on TCP 7777. Debug output was inspected and only our instances stopped. Port 7777 was checked before every launch. Each final native capture has zero runtime/parser errors and 109 existing warning messages; warnings are retained.

## Why these reruns were required

N2347 changed ShockwaveTower's broad scan to strict hitbox overlap. Its migration fixture moved N2327's near-edge out-of-rect examples from 171 to 173, accounting for default bullet hit_size 4. The current N2327 scene now passes both its pure scan cases and live tick.

N2350 changed MendProjector's broad scan to strict hitbox overlap. N2329's current fixture supplies hit_size 8 on six in-range candidates to preserve boundary cases; its live expectation already reflects N2335's later circular/privileged narrow pass (one heal). Both N2350's new hitbox scene and the updated N2329 scene pass. These were required reruns for changed implementation/fixtures, not repetitions solely for Windows coverage. This agent made no repairs or assertion changes in this batch.

## Evidence and remaining queue

Raw targeted logs and native debug captures are in [evidence](evidence/2026-11-16-wave18-batch/). This report-only PR adds no gameplay, SSOT, ledger, PortGame or migration implementation. No full gate was run or claimed.

Main N2208 MassDriver sense(progress)/acceptItem already has detailed actual Linux Godot 4.6.2 evidence at the main baseline: targeted 4/4, main-thread rerun 4/4, family 12/12, matches true and zero false, with exit0/no-ERROR assertions in its test. No Windows repetition was needed. Slice IDs differ across main and integration; match coverage by scene and implementation.

Wave18 reports 163 proofs plus 23 reruns and 30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not reconciled remaining debt after our batches. New wave17/wave18 proofs and older unvalidated scenes remain queued. In particular, N2357, N2339 and N2352 have new implementation/fixture rerun requirements in wave18. Prior BaseShield and RegenProjector fixture commits remain separately tracked; this report does not claim those original scenes pass unmodified.
