# Wave34: three missing proofs pass Windows Godot

N2394 PayloadUnloader dump neighbour live fill, N2396 MassDriver draw rows and N2397 LaunchPad pod result pass targeted tests and native Godot MCP. The existing N2409 correction to N2394 is included unchanged. No runtime, fixture or assertion edits were made in this validation.

## Snapshot and results

Tested latest pushed integration `integration/wave-advances-34-n2484-n2490` at `67e525a681f60a62ae008f81c0aa9dbf9ac324ab`, containing wave33 ancestry, on isolated branch `codex/godot-wave34-batch1-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection was `5260285acaa15e83448c65cc5cab3f9447fbe62a`. The report branch is based on main; it adds no migration ancestry.

Explicit main and `integration/wave-*` fetch refspecs were used. GOAL and selected reports/handoffs at the tested SHA identify these proofs as unrun, including N2409's required rerun of the corrected N2394 fixture. No matching previous actual passing evidence was found. N2323 UCL fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches the pushed fix branch by content.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2394 `C07PayloadUnloaderDumpNeighbourLiveFillProof` | 4/4, 21.655s | 9/9 total keys true, matches true |
| N2396 `C07MassDriverDrawRowsProof` | 4/4, 21.723s | 9/9 total keys true, matches true |
| N2397 `C07LaunchPadPodResultProof` | 4/4, 20.789s | 9/9 total keys true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_payload_unloader_dump_neighbour_live_fill -v
python -m unittest tests.test_c07_mass_driver_draw_rows -v
python -m unittest tests.test_c07_launch_pad_pod_result -v
```

Each corresponding scene also ran natively through Godot MCP, without headless mode, using Windows `4.6.2.stable.official.71f334935`. Each completed capture has zero runtime/parser errors; existing warnings are recorded in the raw evidence (120 for N2394, 121 for N2396, 120 for N2397). TCP7777 was checked before every engine launch, debug output inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave34-batch1/) includes three targeted logs and three native captures. No full gate is claimed.

N2394 validates live ring arrays, capacity/consumes-item gates, absent neighbours and the corrected live dump: press at (31,20), cdump5, water43.75 dumped/6.25 remaining/43.75 received, four coal and dump_accum0.9. N2396 covers shadow, configure link, place range/link, icons and current frame draw values. N2397 covers null pod, mirrored/deep-copied stacks, lifetime120 and team/position. Their stated deferred behavior and unrelated slice failures remain outside this certification.

Main added N2221 RepairTurret shouldAmbientSound/status. Its detailed Linux Godot4.6.2 report records targeted4/4, 11 total keys alltrue/matches, family44/44 and wiring32/32; accepted without repeating Windows. That main change does not alter the selected integration snapshot.

Only this report and six evidence additions are published. Gameplay, shared SSOT, ledger totals, PortGame, fixture assertions, imports and UID noise are preserved. Prior unrelated REDs and conditional fixture adoption requirements remain pending. Three selected passes do not clear the full integration backlog or certify newer implementations of earlier proofs.
