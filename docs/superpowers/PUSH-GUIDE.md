# Pushing to GitHub from this VM (for Muse agents)

Repo: `Lasthope1508/mindustry-godot-transpiler`. This VM has no Godot and no
interactive git credentials. Pushes go over SSH on port 443 through the
egress proxy. This setup was verified working on 2026-11-15.

## Push route (do not use HTTPS push, port 22, or `gh auth`)

- HTTPS git has no stored credential on this VM (`fatal: could not read
  Username`). Do not embed credentials in git commands and do not start
  PAT/device-auth flows.
- Direct SSH (port 22 and port 443) is reset by the egress proxy. The
  working route is SSH to `ssh.github.com:443` through an HTTP CONNECT
  tunnel via the egress proxy.
- SSH config lives at `/home/hatch/.ssh/config` (persistent home):

```text
Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile /home/hatch/.ssh/id_ed25519
  UserKnownHostsFile /home/hatch/.ssh/known_hosts
  ProxyCommand nc -X connect -x hatch-egress-proxy:3128 ssh.github.com 443
```

- GOTCHA: `ssh` resolves `~` and the default config path from the passwd
  home (`/root`), not from `$HOME` (`/home/hatch`), so it ignores
  `~/.ssh/config` unless told otherwise. Always invoke ssh with
  `-F /home/hatch/.ssh/config`. The repo's `core.sshCommand` is already
  set to `ssh -F /home/hatch/.ssh/config`, so plain `git push` over an
  SSH remote URL works from any worktree.
- The matching public key is registered on the GitHub account
  `Lasthope1508` (Settings → SSH and GPG keys, title "Muse VM", added
  2026-11-15). If the key pair is ever replaced, the new public key must
  be added there before pushes work again. Never expose the private key.

## Test and push

```bash
# Expect: "Hi Lasthope1508! You've successfully authenticated..."
ssh -F /home/hatch/.ssh/config -T git@github.com

# Push one or more finished branches (keep origin as HTTPS; fetch works over HTTPS)
git push git@github.com:Lasthope1508/mindustry-godot-transpiler.git <branch> [<branch> ...]
```

## Push policy (user decision, 2026-11-15)

- Push each completed slice/integration branch as it finishes. Do not wait
  to batch pushes.
- Never push to `main` from this VM without explicit user approval.
  Remote `main` is ahead of local `main` and is also pushed to by another
  agent working in parallel under the same account.

## No Godot on this VM

Slices stop before the Godot proof step and move to the next slice. Each
pending Godot proof is recorded as debt in the repo (slice report +
handoff + `GOAL.md` §5) for another agent the user assigns to test.

## N2186/N2187 numbering decision (2026-11-15)

Remote `main` carries different N2186/N2187 slices than this VM's local
branches: remote = ImpactReactor powerProduction/consume live reads;
local = LaunchPad / ShockwaveTower `shouldConsume` gates. Both sides are
complete slices of different features, so neither replaces the other.
Decision: keep both; the remote slices keep numbers N2186/N2187 (already
on `main`); this VM's N2186/N2187 slices must be renumbered before any
merge to `main`. Branch pushes are unaffected (branch names do not
collide with `main`).
