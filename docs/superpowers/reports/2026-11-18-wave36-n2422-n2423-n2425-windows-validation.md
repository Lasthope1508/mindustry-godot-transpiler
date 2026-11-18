# Wave36 batch8: N2422 GREEN; N2423 GREEN; N2425 GREEN

Tested `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch8-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `7dfdec38ff55fc75f65feb2bb1abdbc0fde60ca9`. Main and integration wave refs explicitly fetched; integration unchanged; main advanced with N2232-N2242. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, selected slice reports and handoffs describe these proofs as never run. No matching prior passing engine validation found. N2323 UCL UpdateTile fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches its pushed fix branch; no fixture transplant needed.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2422 `C07AcceleratorPowerBufferBarRowsProof` | 4/4, 41.539s | 9/9 true, matches true |
| N2423 `C07ForceProjectorAbsorbExplosionProof` | 4/4, 22.036s | 9/9 true, matches true |
| N2425 `C07UnitAssemblerModuleDrawRowsProof` | 4/4, 21.555s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_accelerator_power_buffer_bar_rows -v
python -m unittest tests.test_c07_force_projector_absorb_explosion -v
python -m unittest tests.test_c07_unit_assembler_module_draw_rows -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors. Warning counts: N2422 120, N2423 120, N2425 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-18-wave36-batch8/) contains all three targeted logs and native captures. No full gate claimed.

These proofs cover Accelerator power-buffer bar raw values, ForceProjector explosion absorption geometry/hit/buildup result, and UnitAssemblerModule draw/place/plan/icons descriptors. They validate current pure function assertions; UI formatting/rendering, live graph supplier and explosion event dispatch are not certified.

All three selected proofs pass. Previous unrelated REDs remain pending.

Main N2232-N2242 has eleven detailed reports of actual passing Linux proofs (scene identity, matches:true, zero engine errors and targeted4/4); those passes are accepted without Windows repetition. N2242's report records repaired neighbour fixtures and family20/20 after its live-bullets wiring change. Main-only numbering is independent of the older integration snapshot. The automatic schedule remains paused; this batch was requested manually.

Seven report/evidence additions only. No gameplay, SSOT, ledger, PortGame, fixture or assertion changes. Dirty imports/UID/project settings preserved. Existing actual Linux/Windows passes accepted; unchanged REDs, including N2407, not rerun. This batch does not clear the integration backlog.
