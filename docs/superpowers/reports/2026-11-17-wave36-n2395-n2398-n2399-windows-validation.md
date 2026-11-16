# Wave36: N2395 GREEN; N2398 and N2399 RED

N2395 Separator canDump passes targeted tests and native Godot MCP. N2398 WallCrafter offload routing and N2399 RegenProjector heal application fail semantic assertions in both targeted and native runs. These failures remain pending; neither is certified GREEN. No runtime, fixture or assertion changes were made.

Tested `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, containing wave34 ancestry, on isolated branch `codex/godot-wave36-batch1-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `9b40f031993227f391a659eee888afbe030fa6e3`. Publication adds this report and evidence to a branch based on main, with no migration ancestry.

Explicit main and all `integration/wave-*` fetch refspecs were used. Exact-SHA GOAL, reports and handoffs identify all three scenes as never run; no matching prior actual pass was found. N2323 UCL fixture content matches the pushed fix blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5`.

| Slice / native scene | Targeted tests | Native result |
| --- | --- | --- |
| N2395 `C07SeparatorCanDumpItemFilterProof` | 4/4, 21.300s | 9/9 total keys true, matches true |
| N2398 `C07WallCrafterOffloadRoutingProof` | 3/4, 21.000s; proof test fails | 2/4 semantic keys false, matches false |
| N2399 `C07RegenProjectorHealApplicationProof` | 3/4, 21.500s; proof test fails | 4/6 semantic keys false, matches false |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_separator_candump_item_filter -v
python -m unittest tests.test_c07_wall_crafter_offload_routing -v
python -m unittest tests.test_c07_regen_projector_heal_application -v
```

Each scene also ran natively through Godot MCP without headless mode, Windows `4.6.2.stable.official.71f334935`. Each capture has zero runtime/parser errors and 120 existing warnings. TCP7777 checked before every engine launch; debug output inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch1/) contains all three targeted logs and native captures, including RED results. No full gate is claimed.

N2395 covers Separator all-false itemFilter, Disassembler scrap-only filter, canDump decisions, unknown-def edge and live frame reads. Its GREEN result does not clear any earlier dump/write-back RED.

N2398 false keys: `advance_exposes_offload_neighbour_index`, `live_tick_routes_offloaded_item_to_neighbour_frame`. Inventory fallback and routed-item departure without a destination frame pass. N2399 false keys: `heal_application_decodes_pos_to_cell`, `heal_application_applies_amount_to_target`, `heal_application_caps_at_max_health`, `live_tick_applies_flush_after_advance`. No-sprite handling and the explicit deferred recentlyHealed outcome pass. Composite assertions do not isolate which inner comparison is wrong; root cause is unconfirmed. No assertion was weakened, and no speculative gameplay/fixture repair was applied. Responsible migration work must resolve these failures before a GREEN claim; repeat only after a relevant change.

Main added N2222 RepairTurret ambient-sound loop. Its detailed Linux Godot4.6.2 report records targeted4/4, nine total keys alltrue/matches, family48/48 main-verified223.240s and wiring32/32. Accepted without Windows repetition. The main delta was inspected and is separate from this tested integration snapshot.

Only seven report/evidence additions are published. Gameplay, shared SSOT, ledger totals, PortGame, fixture assertions and workspace import/UID noise are preserved. Prior unrelated REDs and conditional fixture requirements remain pending. This batch does not clear the integration backlog or certify newer implementations of earlier proofs.
