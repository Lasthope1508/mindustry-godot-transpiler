# Wave26: three sense proofs GREEN on Windows Godot

N2387 PayloadDeconstructor, N2388 Separator and N2389 LaunchPad sense rows pass targeted tests and native Godot MCP on Windows Godot 4.6.2. No runtime, fixture or assertion edits were made.

## Snapshot and results

Tested `integration/wave-advances-26-n2425-n2431` at `91ee0f1dc97fc7e10ae9157289ea00ea09c1f02d` on isolated branch `codex/godot-wave26-batch6-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection was `a87b14b2fa5fda23af355d4f7edddb2cea3a19b3`; the report branch was advanced to `03816a8dbacbf640f8b6b4286743434afcdfdfaa` before publication after inspecting the unrelated N2219 RepairTurret change. These results certify the exact integration snapshot, not a runtime transplant from main.

GOAL, selected reports and handoffs at the tested SHA identify these proofs as never run; no matching actual prior pass was found. N2323 UCL proof content still matches the pushed fix branch exactly (blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5`, content inclusion rather than original commit ancestry).

| Slice / scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2387 `C07PayloadDeconstructorSenseRowsProof` | 4/4, 21.458s | 10/10 total keys true, matches true |
| N2388 `C07SeparatorSenseRowsProof` | 4/4, 21.578s | 9/9 total keys true, matches true |
| N2389 `C07LaunchPadSenseRowsProof` | 4/4, 21.119s | 9/9 total keys true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_payload_deconstructor_sense_rows -v
python -m unittest tests.test_c07_separator_sense_rows -v
python -m unittest tests.test_c07_launch_pad_sense_rows -v
```

Each scene also ran through native Godot MCP without headless mode. Engine output: `4.6.2.stable.official.71f334935`. Each native capture has zero runtime/parser errors and 113 existing warnings. TCP7777 checked before every engine launch; debug output inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave26-batch6/) contains targeted logs and native captures. No full gate is claimed.

The proofs cover unclamped Deconstructor/Separator progress, Deconstructor content matching, clamped LaunchPad progress, super-sensor delegation/defaults and current frame values. They do not certify the deferred port-wide logic caller, missing payload descriptor identity integration, Separator canDump or other runtime behavior. All prior RED proofs and conditional fixture adoption requirements remain pending; sense GREEN does not clear earlier dump/write-back REDs.

Only report/evidence additions are published; no migration ancestry, gameplay, SSOT, ledger, PortGame, project settings or import/UID noise. Matching actual Linux/Windows passes and unchanged REDs were not repeated. Wave26's reported216 missing proofs plus26 reruns are baseline counts, not independently reconciled remaining debt;30 Windows-track proofs already Linux GREEN remain excluded.
