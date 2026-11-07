# Mindustry -> Godot SSOT / Canonical Migration Handoff

**Date:** 2026-09-23
**Workspace:** `C:\Users\Admin\Documents\Game\mindustry-godot-transpiler-copy-20260714-073528`
**Branch:** `codex/mindustry-godot-transpiler`
**Upstream commit:** `2bdedfed25932ebf11330d3584092c50e2e26d96`
**Target engine:** Godot 4.6.2
**Target language:** GDScript
**Purpose:** operational handoff for the next coding agent.

Read this file before modifying code. This document defines ownership, module boundaries, checkpoints, and quality gates. The upstream Java files and root SSOT JSON remain the authority for individual symbols and formulas.

## 1. Mission

The mission is not to maximize generated file count. The mission is a repeatable Mindustry-to-Godot migration with explicit source lineage, canonical naming, modular runtime behavior, and reproducible verification.

Required outcomes:

1. Every source-backed behavior traces to an upstream file, class, method, and expression.
2. Every concept has one canonical name, one canonical owner, and one canonical data location.
3. Registry data, abstract state, generated code, and runtime implementation stay separate.
4. Generated output can be regenerated without losing handwritten runtime logic.
5. A slice is done only after source tests, registry validation, Godot validation, and runtime proof pass.
6. Unsupported behavior is visible in an unsupported/deferred/stub ledger.
7. Modules represent coherent domain/lifecycle capabilities; do not split code into one-line helper fragments.

Do not claim full Mindustry parity because the scanner parses all Java files or the emitter writes all class files. Parse coverage is structural coverage only.

## 2. Current baseline

These numbers describe the current architecture, not completed gameplay parity.

| Area | Current evidence |
|---|---:|
| Java files scanned | 801 |
| Java files parsed | 801 |
| AST failures | 0 |
| Generated class files | 801 |
| Bridged assets | 2,970 |
| Root SSOT symbols | 9,569 |
| Root SSOT slices | 1,405 |
| API contracts | 1,286 |
| State schemas | 2,337 |
| Manifest extension modules | 100 |
| Distinct canonical root keys | 37 |
| Source function records | 1,286 |
| Registered source owners | 1,265 |
| Explicit SSOT/meta exemptions | 8 |
| Legacy unregistered owners | 0 |
| Audit records not explained by registered + exempt + legacy counters | 13 |
| Unsupported feature records | 6,986 |
| PortGame function count | about 2,221 |
| PortGame delegate chain depth | 87 |
| Generated bridge function count | 733 |
| Generated Java-like method functions | 6,226 |
| Generated methods still returning null | about 5,340 |

The high stub count is the main semantic risk. `801/801` emitted classes proves structural coverage, not body semantics.

Authoritative baseline files:

- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_symbol_audit_report.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_ssot_modules.json`
- `godot-mindustry/src/generated/source_manifest.json`
- `godot-mindustry/src/generated/ast_manifest.json`
- `godot-mindustry/src/generated/port_report.json`
- `godot-mindustry/src/generated/port_report.md`

Older logs show different failure totals (`1930 passed / 20 failed` and `1484 passed / 8 failed`). Do not use those logs as a current checkpoint. Create a fresh CP0 baseline first.

The audit counters do not currently add up to `totalSourceFunctions`: `1286 - 1265 - 8 - 0 = 13`. Investigate whether those 13 are legitimate aliases, duplicate function records, or a reporting bug during P0/P1. Do not round this discrepancy away or claim complete owner coverage from the zero legacy count alone.

## 3. Source-of-truth rules

### 3.1 Authority order

When two artifacts disagree, use this order:

1. Exact upstream Java at the pinned commit.
2. Root SSOT JSON.
3. Manifest-registered SSOT mirrors under `src/generated/source_modules/`.
4. Generated metadata emitted from the pipeline.
5. Handwritten Godot runtime code.
6. Runtime proof and test output.

Runtime proof validates an implementation. It must not invent semantics.

### 3.2 Root SSOT and mirrors

The four canonical payload roots are:

- `source_symbol_registry.json`: symbol, owner, Java expression, canonical Godot symbol, status, tests, and runtime proof.
- `source_slice_ledger.json`: migration unit tied to a source method or behavior cluster.
- `source_api_contracts.json`: public input/output contract for bridge and state APIs.
- `source_state_schema.json`: state/result keys and types.

Two adjacent control artifacts are also mandatory: `source_symbol_audit_report.json` is the derived owner-coverage audit, and `source_ssot_modules.json` is the canonical extension manifest (module, root key, canonical reference, and mirror policy). The repository's `AGENTS.md` calls the four payload roots plus the audit report the "five SSOT files" and lists the extension manifest separately.

Files under `src/generated/source_modules/` are extensions or mirrors. Every shard must:

- have one canonical `root_key`;
- be registered in `source_ssot_modules.json`;
- expose canonical reference metadata when it mirrors a root;
- avoid becoming a second source of truth;
- avoid hidden aliases.

If a field already exists in a root, a shard references it by canonical key instead of copying and independently editing the payload.

### 3.3 Required metadata for new symbols

Every new runtime input, state, result, or public API shape must have:

- `java_source`
- `java_class`
- `java_method`
- `java_expr` or `exact_exprs`
- `godot_owner`
- `godot_symbol`
- `status`: `source-backed`, `explicit-input`, `deferred`, or `generated`
- `rule`
- `tests`
- `runtime_proof`

If an old compatibility name remains, record `alias_of` or an audit note. Do not create a second synonym because the old name is inconvenient.

### 3.4 Abstract/state rules

Abstract/state modules may contain source-backed state shape, defaults, formulas, branches, source text constants, and generated-vs-canonical comparison results. They must not contain scene wiring, input handling, texture loading, debug UI, or unsourced gameplay fallback.

A value not found in Java must be marked `explicit-input` or `deferred`. Never label it `source-backed` by assumption.

## 4. Runtime layers and ownership

### Layer A: upstream and scanner

Scope: `mindustry-upstream/core/src` and parser/scanner/emitter tooling under `tools/mindustry_godot_transpiler/`.

Responsibility: read Java, produce manifests, AST metadata, generated source, and unsupported reports. No Godot gameplay logic.

### Layer B: root SSOT

Scope: the root JSON files under `godot-mindustry/src/generated/`.

Responsibility: canonical facts, contracts, schemas, slices, ownership, and module rules. No scene code.

### Layer C: generated output

Scope: `src/generated/classes/`, generated registries, generated content, and generated asset metadata.

Generated files are read-only outputs. Do not patch generated `.gd` by hand to fix runtime behavior. Change the emitter, source metadata, or slice, then regenerate.

### Layer D: source text/default/state

Examples: `Source*SourceTextState.gd`, `Source*Defaults.gd`, and `Source*State.gd`.

Responsibility: source-backed constants, canonical state transitions, and formulas by domain. No direct scene wiring.

### Layer E: PortBridge

Examples: `Source*PortBridge.gd`.

Responsibility: adapt old facade/generated API to canonical state modules. A bridge normalizes inputs, delegates, and packages results; it does not own new semantics.

### Layer F: facade/game shell

`src/game/PortGame.gd` is the compatibility facade and playable shell. New domain logic must go into a canonical domain module first. PortGame should keep a thin compatibility wrapper.

### Layer G: scene/runtime proof

Scope: `tools/runtime_proofs/`, scenes, MCP calls, and debug summaries. Proof calls the public facade/bridge and returns machine-readable evidence. Do not bypass the public boundary to create a false positive.

## 5. Module boundaries and anti-fragmentation rules

### 5.1 What one module represents

A module should represent one capability or lifecycle cluster, for example:

- `SourceBuildingItemState`: item accept/handle/dump lifecycle.
- `SourceBuildingLifecycleState`: init/create/add/remove/team/pickup lifecycle.
- `SourceTurretCombatState`: target, ammo, recoil, shot origin, and fire transition.
- `SourcePowerGraphState`: graph membership, battery/distribution, and update behavior.

Do not create a separate module for one arithmetic operation, one dictionary lookup, or one return literal unless it has an independent source boundary and independent test boundary.

### 5.2 Slice size

Prefer one vertical slice containing 3-10 related behaviors: source text/defaults, canonical state, bridge, SSOT, tests, and runtime proof. A single method may be isolated only when it is a public API, a separate lifecycle boundary, a separate regression, or an emitter rule.

Do not create a commit that changes one constant in one file when the whole source-backed behavior cluster can be completed together.

### 5.3 File budget

A domain unit may use:

1. one `Source<Name>SourceTextState.gd` when exact source literals/method text are needed;
2. one `Source<Name>State.gd` for canonical state logic;
3. one `Source<Name>PortBridge.gd` for adapters;
4. one or two tests;
5. one runtime proof scene/script;
6. root SSOT entries and one registered mirror shard when needed.

If a feature requires more than three consecutive bridge layers, stop and consolidate the boundary. The existing 87-level PortGame chain is technical debt; do not reproduce it.

## 6. Mandatory workflow for every work unit

### Step 0: choose a capability, not a file

Write one sentence describing the capability, such as: "BuildingComp item dump transfers inventory to the core using source order and capacity." Do not start with "edit PortGame.gd line X".

### Step 1: read context

Read `AGENTS.md`, the design spec, the five SSOT files named there, the separate SSOT module manifest and related shards, the exact upstream Java methods, existing state/bridge modules, and existing tests/proofs.

### Step 2: find existing canonical ownership

Search symbols, owners, schemas, contracts, and slices. Reuse existing entries. If two names mean the same thing, add an alias or migrate the canonical entry; do not add another owner.

### Step 3: RED

Add source parity and registry tests first. The failure must be caused by missing behavior or metadata, not by an invalid fixture.

### Step 4: update SSOT

Add root entries before implementation. Register any new shard in the same work unit. Use canonical pointers; do not duplicate payloads.

### Step 5: GREEN

Implement the canonical state module. Keep bridge code thin. Modify generated output only by changing emitter/source metadata and regenerating.

### Step 6: validate contracts and schemas

Check names, types, status, owner, source path, method, test list, runtime proof, and mirror consistency.

### Step 7: runtime proof

Run a Godot MCP proof scene. Call the public facade/bridge. Expect `matches=true` when a generated/canonical comparison exists, or an explicit documented `deferred`/`explicit-input` result. Debug errors must be empty.

### Step 8: full gate

Run targeted tests, full JSON/Python tests, Godot parse/LSP, and `git diff --check`.

### Step 9: checkpoint

Record scope, SSOT delta, code delta, commands/results, and known gaps. Commit one coherent capability cluster only.

## 7. Planned phases

### P0: fresh baseline and deterministic environment

Create a fresh baseline report. Validate all root/module JSON. Run the full Python suite. Run Godot editor parse/LSP. Check process ownership of MCP port `7777`. Classify every failure as expectation, missing file, parse, runtime, or stale artifact.

P0 gate: every current failure has a classification and an owner. No feature migration starts before this exists.

### P1: SSOT integrity gate

Add or strengthen a single validator for duplicate canonical symbols/owners, orphan modules, invalid root keys, missing source methods, missing implementations/proofs, missing contract schemas, alias cycles, invalid statuses, and generated owners incorrectly used as handwritten owners.

P1 gate: validator returns `errors=[]`; audit has no legacy unregistered owner; module manifest has no orphan or mismatch.

### P2: facade and bridge debt reduction

Reduce logic in `PortGame.gd` by domain cluster. Build an owner-to-module inventory, group same-domain delegates, move local state to its canonical owner, retain old facade methods as thin wrappers, and measure function count/chain depth/duplicate delegates after each cluster.

P2 gate: the cluster does not increase chain depth, does not add unnecessary aliases, and all prior runtime proofs remain green.

### P3: vertical gameplay parity

Work in dependency order:

1. content initialization and registry load order;
2. block/building lifecycle and placement;
3. item/liquid transport, drill/conveyor/core inventory;
4. power graph, generator, battery, distribution;
5. turret ammo/target/fire/bullet effects;
6. unit lifecycle/controller/command/weapon/death;
7. world/wave/campaign shell;
8. UI/presentation/audio/network serialization.

Do not move to the next cluster while the previous cluster has canonical drift or red runtime proofs.

### P4: semantic reduction of generated stubs

Classify stubs by tier instead of translating them blindly:

- Tier 0: metadata, constructor, true empty source body.
- Tier 1: getter/setter/default return/field assignment.
- Tier 2: source-backed branch/formula without deep Arc/LibGDX dependency.
- Tier 3: lifecycle behavior calling Godot runtime.
- Tier 4: networking/UI/serialization/anonymous/lambda-heavy behavior.

Each tier needs emitter fixtures, source parity tests, and representative runtime proofs. Remaining stubs must be marked `deferred` or `unsupported` in the ledger.

### P5: runtime stability and performance

Make process/port cleanup deterministic. Keep registry inspection out of the critical simulation boot path. Measure startup time, memory, frame time, class-load failures, and simulation behavior. Keep runtime summaries schema-backed and small.

### P6: release candidate

Only after P0-P5 are green: verify clean checkout regeneration, build/smoke test, unsupported/deferred report, GPL/source lineage, and reproducible runtime evidence.

## 8. Checkpoint contract

Every checkpoint must contain:

1. **Scope:** exact capability and source methods.
2. **SSOT delta:** root keys, owners, contracts, schemas, and module entries.
3. **Code delta:** state, bridge, emitter, generated output, and proof.
4. **Evidence:** commands, test counts, diagnostics, MCP result, and debug errors.
5. **Known gap:** behavior still deferred, unsupported, or blocked.

### CP0: baseline accepted

Fresh report saved; root JSON readable; module/root counts recorded; fresh Python result saved; Godot parse result saved; MCP port/process state recorded.

### CP1: registry integrity accepted

All new owners registered; no orphan root/module; no duplicate canonical; alias graph acyclic; validator returns `errors=[]`.

### CP2: one vertical slice accepted

Exact Java evidence, RED then GREEN tests, clear state/bridge boundary, generated-vs-canonical comparison, and MCP proof with `matches=true` or a documented deferred result.

### CP3: domain cluster accepted

Every method in the cluster classified as implemented/deferred/unsupported; no new domain hardcode outside SSOT; no new PortGame logic; domain gates green.

### CP4: runtime accepted

Godot parse/LSP clean; scene startup stable; MCP connected; proof scenes have empty debug errors; runtime summary matches its schema.

### CP5: release candidate accepted

Clean checkout can regenerate/build/smoke test; unsupported/deferred artifacts are current; license/source lineage is preserved.

## 9. Hardcode policy

### Prohibited

- Java-derived formulas or numbers written directly in `PortGame.gd` or a bridge.
- Repeated Java class/method strings without a source-text/registry constant.
- New dictionary keys without a schema.
- Unsourced fallback defaults without `explicit-input` or `deferred` status.
- Hand edits to generated `.gd` files.
- Duplicate canonical payloads in multiple shards.
- Tests that only check a string while ignoring source path, owner, and behavior match.

### Allowed

- Godot-only scene/presentation wiring with no Java equivalent, kept out of source-backed state.
- Test fixture values.
- Explicit runtime input required by Godot, with metadata.
- Compatibility aliases that point to a canonical owner.

### Required review searches

For every cluster, review new numeric literals, Java class/method strings, duplicate dictionary keys, new generated `return null`, unregistered preloads, and direct state mutation from the facade.

## 10. Generated stub policy

`return null` is neither automatically a bug nor automatically an implementation. Every stub must be classified as:

- `implemented`: semantic body ported and proven;
- `metadata-only`: method shape/metadata is sufficient;
- `empty-source-body`: upstream body is genuinely empty;
- `deferred`: dependency not yet ported;
- `unsupported`: no safe mapping exists;
- `blocked`: source/runtime evidence is missing.

Never reduce the stub count by returning guessed defaults. Keep the stub and update the ledger when dependencies are not ready.

## 11. Verification commands

Run from `mindustry-godot-transpiler-copy-20260714-073528`.

### SSOT and source tests

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p '*json*' -v
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p '*source*' -v
```

### Full Python gate

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Use pytest only when the repository configuration requires it:

```powershell
python -m pytest -q -p no:cacheprovider
```

### Regeneration

```powershell
python tools/mindustry_godot_transpiler/transpile.py --upstream mindustry-upstream --godot godot-mindustry scan
python tools/mindustry_godot_transpiler/transpile.py --upstream mindustry-upstream --godot godot-mindustry emit
python tools/mindustry_godot_transpiler/transpile.py --upstream mindustry-upstream --godot godot-mindustry report
```

### Godot parse/editor gate

```powershell
$godot = (Get-Command Godot_v4.6.2-stable_win64_console.exe).Source
& $godot --headless --path godot-mindustry --editor --quit
```

Record the executable path and output in the checkpoint. If MCP cannot bind `7777`, classify and resolve the process/port state before claiming runtime success.

### Diff hygiene

```powershell
git diff --check
git status --short
```

Do not stage workspace noise (`project.godot`, `.gd.uid`, `arc-upstream`, proof PNG/log files) unless it is part of the declared capability.

## 12. Dirty worktree policy

The worktree contains many modified and untracked slice artifacts. The next agent must:

1. never reset, checkout, or revert changes it did not create;
2. never use `git add .`;
3. capture `git status --short` before work;
4. stage only files in the current capability;
5. read existing diffs before editing a modified target;
6. stop and inspect ownership/history if an unexpected change appears in a file being edited.

## 13. Slice/cluster plan template

```markdown
# <ID> <Capability>

## Scope
- Java class/method:
- Runtime capability:
- Out of scope:

## Canonical SSOT
- root keys:
- source owners:
- API contracts:
- state schemas:
- manifest shards:

## Source evidence
- exact upstream paths:
- exact expressions/branches:
- deferred/unsupported constructs:

## RED
- test names:
- expected failure:

## GREEN
- state module:
- source text/default module:
- PortBridge:
- emitter/generated output:
- facade compatibility wrapper:

## Runtime proof
- proof scene/script:
- public MCP call:
- expected result:
- debug errors expected: []

## Gates
- [ ] SSOT validator
- [ ] targeted tests
- [ ] full source/parity tests
- [ ] Godot parse/LSP
- [ ] MCP runtime proof
- [ ] git diff --check
- [ ] exact files staged

## Known gaps
-
```

## 14. First actions for the next agent

Do not begin with a new gameplay feature. Follow this order:

1. Read this handoff, `AGENTS.md`, and the design spec.
2. Produce the CP0 fresh baseline, especially full Python results and Godot/MCP port state.
3. Add or expose a one-command SSOT integrity validator if one does not already exist.
4. Reclassify the old 20/8 failures with a fresh run; do not assume old logs are current.
5. Choose one dependency-clear domain cluster that either reduces facade debt or unlocks real runtime behavior.
6. Start the next behavior slice only after CP1 is green.

The first technical priority is deterministic runtime proof: make `7777` process cleanup/configuration reliable, ensure one Godot process owns the port, and make proof scenes return machine-readable results. Without deterministic MCP, gameplay claims lack evidence.

## 15. Project Definition of Done

The project may claim completion only when all conditions hold:

- source and generated inventories are reproducible from the pinned upstream commit;
- root SSOT is the canonical headquarters and shards do not drift;
- every source owner is registered or explicitly explained as exempt;
- no unregenerable manual generated edit remains;
- important methods are classified by semantic tier;
- unsupported/deferred/stub gaps are visible;
- PortGame is a facade, not the owner of new domain logic;
- major domains have vertical runtime proofs;
- full Python/JSON gates are green;
- Godot parse/LSP is green;
- MCP runtime is green with empty debug errors;
- clean checkout can regenerate/build/smoke test;
- GPL/source notice and modified-source lineage are preserved.

If any condition is not met, the correct status is `in progress`, `deferred`, or `blocked`, never `done`.
