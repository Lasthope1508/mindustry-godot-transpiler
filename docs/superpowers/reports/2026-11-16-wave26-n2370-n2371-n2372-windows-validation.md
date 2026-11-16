# Wave26 validation: UAM and MendProjector GREEN; Fracker live liquid RED

N2370 UnitAssemblerModule handoff fits wiring and N2372 MendProjector draw rows pass targeted tests and native Godot MCP on Windows Godot 4.6.2 stable. N2371 shared liquid helper checks pass, but both live Fracker assertions fail. No runtime, fixture or assertion edits were made.

## Snapshot and evidence

Tested integration `integration/wave-advances-26-n2425-n2431` at `91ee0f1dc97fc7e10ae9157289ea00ea09c1f02d`, using isolated branch `codex/godot-wave26-batch2-validation` and project `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main remained `6e90868e53fa4586389f9e365a0676497fbc5edf` during selection. Latest integration includes preceding waves and the owner duplicate-local parse correction. The N2323 UCL proof content matches its pushed fix branch (content inclusion, not original commit ancestry).

GOAL and slice reports/handoffs identify all three as lacking actual Godot runs. N2371 also carries the later N2385 cursor pin correction; this run tests the current wave26 version. Existing matching Linux/Windows passes and unchanged earlier RED proofs were not repeated.

| Slice / scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2370 `C07UnitAssemblerModuleHandoffFitsWiringProof` | 4/4, 21.281s | 8/8 total keys true, matches true |
| N2371 `C07LiquidNeighbourWriteBackProof` | 4 tests, 1 failure, 21.401s | 2 semantic keys false, matches false |
| N2372 `C07MendProjectorDrawRowsProof` | 4/4, 21.517s | 10/10 total keys true, matches true |

Commands, run sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_unit_assembler_module_handoff_fits_wiring -v
python -m unittest tests.test_c07_liquid_neighbour_write_back -v
python -m unittest tests.test_c07_mend_projector_draw_rows -v
```

Each scene was also launched through Godot MCP without headless mode. Native output reports engine `4.6.2.stable.official.71f334935`; each capture contains zero runtime/parser errors and 113 existing warnings. TCP7777 was checked before every launch; debug output inspected and owned native projects stopped. Raw logs/captures are in [evidence](evidence/2026-11-16-wave26-batch2/). No full gate is claimed.

## N2371 remains RED

`live_tick_writes_dumped_liquid_to_neighbour_frame` and `live_tick_dumped_liquid_leaves_fracker_without_frame` are false in both targeted and native results. Direct frame/conduit helper writes, missing-frame/missing-sprite guards and advance index exposure are true. These conjunctions do not alone identify the underlying wrong runtime value. Owner diagnosis is required; no GREEN certification or weakened assertion is published for N2371.

This PR adds only validation reports/evidence on a main-based branch; it brings no migration ancestry or gameplay/SSOT/ledger/PortGame changes. Earlier REDs and conditional fixture adoption requirements remain tracked in the checkpoint. Wave26's 216 missing proofs plus 26 reruns are migration-reported baseline counts, not an independently reconciled remaining queue; 30 Windows-track proofs already Linux GREEN remain excluded from repeat work.
