# Wave36 batch6: N2415 GREEN; N2417 GREEN; N2418 GREEN

Tested `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch6-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `2361f4cb455e116ae36ab2a7ae2c25132b5b264d`. Main and integration wave refs explicitly fetched; both snapshots unchanged since batch5. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, selected slice reports and handoffs describe these proofs as never run. No matching prior passing engine validation found. N2323 UCL UpdateTile fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches its pushed fix branch; no fixture transplant needed.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2415 `C07UnitCargoLoaderDrawRowsProof` | 4/4, 22.132s | 9/9 true, matches true |
| N2417 `C07UnitCargoLoaderBarRowsProof` | 4/4, 21.723s | 9/9 true, matches true |
| N2418 `C07PayloadDeconstructorDrawRowsProof` | 4/4, 21.995s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_unit_cargo_loader_draw_rows -v
python -m unittest tests.test_c07_unit_cargo_loader_bar_rows -v
python -m unittest tests.test_c07_payload_deconstructor_draw_rows -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors. Warning counts: N2415 120, N2417 120, N2418 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch6/) contains all three targeted logs and native captures. No full gate claimed.

These proofs cover the current pure presentation rows: UnitCargoLoader construct/poly draw branches and unit-cap bar arithmetic, and PayloadDeconstructor draw/icons rows. They verify returned values and call descriptors; they do not certify a UI/rendering call site or full visual output. Caller-supplied font icon and payload metadata remain explicit inputs.

All three selected proofs pass. Previous unrelated REDs remain pending.

Seven report/evidence additions only. No gameplay, SSOT, ledger, PortGame, fixture or assertion changes. Dirty imports/UID/project settings preserved. Existing actual Linux/Windows passes accepted; unchanged REDs, including N2407, not rerun. This batch does not clear the integration backlog.
