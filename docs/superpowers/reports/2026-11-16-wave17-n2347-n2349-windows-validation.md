# Windows Godot validation: N2347–N2349 on wave17

All three selected proofs passed on Windows Godot 4.6.2 stable: 12/12 targeted tests and three native MCP scenes. No fixture or implementation changes were needed.

## Snapshot

- Integration branch: `integration/wave-advances-17-n2351-n2357`.
- Tested SHA: `1843003e2eb9b625501af03363c94784f036dcf5`, containing wave16 and the N2323 UCL fixture fix.
- Main report baseline: `ef6f8086b1ccff94abd75f91bf6a3e08f4d9aef8`.
- Isolated validation branch: `codex/godot-wave17-batch-validation`.
- Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Integration slice / scene | Targeted result | Native result |
| --- | --- | --- |
| N2347 `C07ShockwaveTowerBulletScanBroadHitboxProof` | 4/4, 22.180s | 9/9 keys true, matches true |
| N2348 `C07UnitAssemblerModuleTierStampProof` | 4/4, 21.836s | 8/8 keys true, matches true |
| N2349 `C07SeparatorDisassemblerScrapRowProof` | 4/4, 22.002s | 9/9 keys true, matches true |

Commands were run sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_shockwave_tower_bullet_scan_broad_hitbox -v
python -m unittest tests.test_c07_unit_assembler_module_tier_stamp -v
python -m unittest tests.test_c07_separator_disassembler_scrap_row -v
```

Each actual engine test requires exit 0, no `ERROR:`, matches true and all semantic keys true. The native scenes additionally ran through Godot MCP with the runtime server listening on TCP 7777. Debug output was inspected and only our instances stopped. Port 7777 was checked before every launch. All final native captures have zero runtime/parser errors and 109 existing warning messages; warnings are retained in the evidence.

The initial native N2347 launch had no proof output at the 15-second capture and was stopped. It was relaunched with a longer startup wait and passed; no assertions or files were changed to obtain that result. This was an incomplete capture, not a semantic RED or GREEN claim.

## Evidence and limits

Raw targeted logs and final native debug captures are in [evidence](evidence/2026-11-16-wave17-batch/). No gameplay, SSOT, ledger, PortGame or proof fixture was edited. No full gate was run or claimed. This report-only PR does not merge integration implementation into main.

Main N2207 LaunchPad updateTile already has detailed actual Linux Godot 4.6.2 evidence at the main baseline: targeted 4/4, main-thread rerun 4/4, post-rebase 4/4, matches true and zero false, with exit0/no-ERROR requirements in its test. No Windows repetition was needed. Main and integration reuse slice IDs; coverage must be matched by scene and implementation.

Wave17 reports 157 proofs plus 20 reruns and 30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not independently reconciled remaining debt after our validation batches. N2350, new wave17 proofs, N2327's changed bullet-scan fixture rerun and older missing proofs remain queued. Prior BaseShield and RegenProjector fixture fixes are pushed separately and still require adoption in their migration branches; this batch does not claim those original fixtures pass unmodified.
