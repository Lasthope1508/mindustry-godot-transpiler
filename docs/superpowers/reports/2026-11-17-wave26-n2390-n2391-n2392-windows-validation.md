# Wave26: ShockwaveTower, ImpactReactor and MassDriver sense proofs

N2390, N2391 and N2392 pass targeted tests and native Godot MCP on Windows Godot `4.6.2.stable.official.71f334935`. No runtime, fixture or assertion changes were needed.

Tested `integration/wave-advances-26-n2425-n2431` at `91ee0f1dc97fc7e10ae9157289ea00ea09c1f02d`, isolated branch `codex/godot-wave26-batch7-validation`, project `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection/publication preparation: `a46a820ee4469bfc1c3c048f48f8a4188f00e806`. This certifies the integration snapshot; no migration ancestry is merged into main.

GOAL and selected reports/handoffs at that SHA list these proofs as never run; no matching previous actual passing evidence was found. N2323 UCL fixture content matches the pushed fix blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` (content match, not commit ancestry).

| Slice / native scene | Targeted | Native MCP |
| --- | --- | --- |
| N2390 `C07ShockwaveTowerSenseRowsProof` | 4/4, 21.564s | 9/9 keys true, matches true |
| N2391 `C07ImpactReactorSenseRowsProof` | 4/4, 21.417s | 9/9 keys true, matches true |
| N2392 `C07MassDriverSenseRowsProof` | 4/4, 21.464s | 9/9 keys true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_shockwave_tower_sense_rows -v
python -m unittest tests.test_c07_impact_reactor_sense_rows -v
python -m unittest tests.test_c07_mass_driver_sense_rows -v
```

Each corresponding scene ran natively through Godot MCP, without headless mode. Each completed native capture has zero runtime/parser errors and 113 existing warnings. TCP7777 was checked before each engine launch; diagnostics were inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave26-batch7/) contains the three targeted logs and three completed native captures. No full gate is claimed.

An initial N2391 native capture was stopped during startup before proof output; it was not counted as a pass and was rerun to completion. An initial N2392 unittest invocation from the repository root failed to import `tests`, executed no slice tests, and was corrected to the test-tool directory. Neither required a code or assertion change; the completed runs above are the validation results.

Coverage is limited to pure sense rows: ShockwaveTower uses unclamped reloadCounter/reload and heat for warmup; ImpactReactor returns frame warmup directly for heat and its warmup accessor; MassDriver clamps 1-reloadCounter. Super-sensor delegation/defaults and frame values pass. Deferred logic/drawer callers and unrelated update behavior are not certified.

Only this report and six evidence files are published. Previous REDs and conditional fixture adoption requirements remain pending; these sense results do not clear dump/write-back failures. Already passing Linux/Windows proofs and unchanged REDs were not repeated. Wave26's reported 216 missing proofs plus 26 reruns are migration baseline counts, not an independently reconciled remaining backlog; the 30 Windows-track proofs already passing on Linux remain excluded.
