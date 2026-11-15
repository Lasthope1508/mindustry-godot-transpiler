# Hourly Godot validation duty

Authorized directly by the user on 2026-11-15 (Asia/Bangkok): check once per hour, validate slices lacking Godot evidence, push and merge only the validation agent's own passing work, and preserve this duty across context loss. The user explicitly excludes slices already verified on Godot Linux from repeat validation.

## Scope

Repository: https://github.com/Lasthope1508/mindustry-godot-transpiler.git

Local validation workspace: `C:/Users/Admin/.codex/worktrees/windows-godot-validation/mindustry-godot-c06-proof`.

Persistent local checkpoint: `C:/Users/Admin/.codex/task-state/mindustry-godot-validation/checkpoint.json`. Keep credentials out of this file. Git Credential Manager selects `Lasthope1508` for this repository; verify the actual account and push/merge permissions before publishing. Do not assume browser login changes Git credentials.

This duty audits evidence and runs existing proofs. It does not authorize implementing the migration backlog. Read applicable AGENTS.md instructions. Preserve user/other-agent changes, including project.godot, imports, UID files and dependency checkouts. Do not reset or clean a dirty checkout.

## Every run and after context recovery

1. Read this file, AGENTS.md and the local checkpoint. Acquire an exclusive local run lock (store PID and start time under the task-state directory); if another live validation run owns it, do not launch another. Recover a stale lock only after verifying its owner is no longer running. Release your lock in a finally/cleanup step.
2. Fetch origin main without switching another agent's checkout. Record the exact remote SHA. Compare slice ledger, implementation/test changes, reports and handoffs since the last audited SHA. On first use, inspect the currently completed slices and existing validation reports; never use a slice number alone as evidence.
3. Accept specific evidence of an actual passing Godot run on Linux OR Windows for the relevant implementation: scene/test identity, engine version, passing matches/assertions and output/error result or a detailed source-controlled report of these. Static tests, a written scene, RED results, skipped tests and an absent-engine gate are not actual runtime validation. Treat a later behavior change as needing fresh matching evidence. Existing detailed Linux proof reports count; do not demand Windows reruns or raw logs solely to repeat them.
4. Build the missing-evidence queue. If empty, record the audited SHA and that all reviewed slices already have evidence; do not create empty commits or PRs. Audit-only progress may remain in the local checkpoint.
5. For missing entries, work on a fresh isolated `codex/` branch based on the audited main snapshot. Run existing targeted unittest modules and their Godot scenes sequentially. Check local TCP 7777 before every engine launch; do not kill or collide with another agent's process. If busy, leave the item pending. Use the actual validation project path explicitly, not a stale checkout path copied from an old report. Capture commands, engine version, tested SHA, exit codes, stdout/stderr and fresh proof results. Check matches/assertions and unexpected errors, not exit code alone. Record expected negative-path diagnostics separately. Use Godot MCP/native proof as applicable, inspect debug output and stop only the project you started. Distinguish warnings from runtime errors honestly.
6. If a proof fails, retain RED evidence. Only a minimal proof-fixture setup repair within this selected validation scope is allowed, with unchanged behavior assertions and affected/neighbor reruns. Do not change gameplay, shared SSOT, ledger counts, PortGame.gd or unrelated fixtures. If repair needs implementation changes or conflicts with another agent, record the failure and defer it to the responsible migration work; do not merge a GREEN claim.
7. For passing work, write a concise report under docs/superpowers/reports with exact scope, base SHA, evidence, initial failures/repairs, final results and limits. Never claim a full gate when only targeted coverage ran. Stage only an explicit allowlist of this run's files; exclude generated import/UID noise and source-adjacent ignored proof JSON. Copied evidence belongs under the report evidence directory.
8. Run git diff --check, review the entire staged diff and commit/push only your validation branch. Create a PR to Lasthope1508/main and attach it to this chat. Immediately before merge, refresh main and inspect intervening changes, required checks, mergeability and PR head SHA. Rerun affected proofs if relevant behavior changed. Merge only this agent's own passing PR after required checks pass. Do not merge another agent's PR, bypass protections, force-push main, or overwrite conflicts. Merge preserves the other main commits; uncertain conflicts stay pending for human attention.
9. Verify merged state and that the commit is reachable from remote main. Update checkpoint with audited/tested SHAs, covered slices and evidence links, pending/failing entries, branch/PR/merge SHA, timestamp and next action. Send a brief Vietnamese report for meaningful changes, completed validation/merge, failures or required user input. No-change runs need no repetitive notification.

## Checkpoint recovery

The checkpoint is a resume aid, not proof by itself. Read referenced reports and check remote state before continuing. A context reset must not duplicate an existing PR, rerun already-covered Linux proofs, resume stale credentials, or claim uncommitted results. Search existing PRs/branches before creating replacements. If credentials or runtime are unavailable, preserve the queue and report the concrete blocker; do not broaden permissions automatically.

The recurring schedule is managed by the Codex app heartbeat attached to this chat. Repository files describe scope and recovery; they do not install a Windows Task Scheduler job or guarantee execution while the app/host is unavailable.
