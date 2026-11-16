# Wave23 parse backport: ItemBridge GREEN, BurstDrill and Separator pending

N2362 ItemBridge doDump write-back passes Windows Godot 4.6.2 native MCP and all four targeted tests. N2360 BurstDrill and N2361 Separator timerDump proofs remain RED after the owner fixed the common parse blocker. No runtime or fixture changes are published by this validation batch.

## Snapshots and results

- Tested integration: `integration/wave-advances-23-n2402-n2408`, SHA `bbcd71e88ba68b46cbc798134cf14c767cb5b13c`. Its owner backport renames duplicate `filled` locals in Fracker and BeamDrill; the previous blocked snapshot was `a0e246e1f1473cf0009557a19e25ec98c8e5dc43`.
- Also audited `integration/wave-advances-24-n2409-n2415`, SHA `e4e57bca37bfbbfc052cd750491b797a6e06e86c`. It contains the earlier wave23 base but does not contain the backport: its Fracker/BeamDrill still have the duplicate local declarations. Do not extend this GREEN result to wave24. No runtime fix was cherry-picked by the validation agent.
- Main baseline: `f3267e5042d489cfc8a0bb7612b49590be203d07`. N2213 RepairTurret heal advance has credible actual Linux 4.6.2 evidence in `2026-11-16-c07-repair-turret-heal-advance.md`: targeted4/4 (15.404s; reruns14.157s/15.348s), family20/20, wiring32/32, eleven proof keys true. Accepted without repeating Windows.
- Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Selected proof | Targeted unittest | Native MCP |
| --- | --- | --- |
| N2362 `C07ItemBridgeDoDumpWriteBackProof` | 4/4, 21.500s | 6/6 keys true, zero runtime/parser errors |
| N2361 `C07SeparatorTimerDumpWriteBackProof` | 4 tests / 1 failure, 21.345s | Live neighbor write-back false; matches false; zero runtime/parser errors |
| N2360 `C07BurstDrillTimerDumpWriteBackProof` | Initial4 tests / 1 failure,21.720s; world-fixture trial4 tests / 1 failure,21.584s | Original stops at overlay assertion; trial still fails live neighbor write-back |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_burst_drill_timer_dump_write_back -v
python -m unittest tests.test_c07_separator_timer_dump_write_back -v
python -m unittest tests.test_c07_item_bridge_do_dump_write_back -v
```

Port7777 was checked before each proof launch. Native debug output was inspected and only owned instances stopped. Native scenes still emit existing GDScript warnings; no clean-warning claim is made. No full gate was run or claimed. The final worktree has no proof/runtime source edits from this batch.

## Retained RED and discarded fixture trial

N2361 passes the pure advance and no-frame routing keys, but `live_tick_writes_dumped_item_to_neighbour_frame` is false. It is not certified GREEN.

N2360's original fixture calls `source_set_world_overlay_state` for a size-5 footprint around (50,40) outside the supplied world, triggering `Tile overlay mutation requires resolved world/content`. Native debug output stops at that assertion. A temporary setup-only trial expanded the world to contain both existing footprints while copying every original tile. All proof positions, values and assertion assignments remained unchanged. The overlay assertion disappeared and the no-frame routing key passed, but live neighbor write-back still failed. Native diagnostics show copper4, cdump15, timer0, dominant_items25 on the drill and an empty items dictionary on the neighbor. The evidence does not determine which runtime/fixture change the owner should make.

The world trial and diagnostic print were removed completely. They are retained only in evidence for owner diagnosis; no failing fixture is committed and no assertion was weakened. N2353's earlier semantic RED and previous conditional fixture-adoption requirements remain pending separately.

## Scope and remaining queue

Raw targeted and native results, including RED and the discarded trial patch, are in [evidence](evidence/2026-11-16-wave23-fixed/). This PR contains report/evidence only and is based on main; it does not merge any migration ancestry or another agent's work.

Wave24 reports202 missing proofs plus26 reruns and30 Windows-track entries already Linux GREEN. These are migration baseline counts, not independently reconciled remaining debt after our validation batches. The latest branch still needs its owner parse correction before Main-based proofs can be certified there. Match historical coverage to the tested implementation and dependencies; do not infer current GREEN merely from slice numbers or an unchanged main.
