# Codex recommendations

Consolidated review and proposed direction for this dotfiles repository, the
macOS workstation, and the remote development/agent host.

## Recommended decisions

| Area | Recommendation |
| --- | --- |
| VPS provider | Keep Hetzner |
| Hetzner location | Use `ash` (Ashburn) instead of `fsn1` |
| Server OS | Ubuntu 24.04 LTS; reconsider 26.04 after its first point release |
| Infrastructure | Keep plain OpenTofu |
| First boot | Keep cloud-init minimal |
| Dotfiles | Keep chezmoi |
| Private access | Tailscale with regular OpenSSH |
| macOS packages | Homebrew and a Brewfile |
| Ubuntu system packages | APT only |
| Development tools and runtimes | mise on macOS and Ubuntu |
| Node manager | Replace fnm with mise |
| Agent execution | Dedicated non-sudo user, systemd, and isolated worktrees or containers |
| Recovery | Git plus encrypted external backups |
| Initial capacity | 4-8 vCPUs, 16 GB RAM, at most two concurrent agents |

## Immediate repository fixes

1. Replace the unsupported `fedora-42` provisioning image as part of the
   Ubuntu migration.
2. Fix the zsh-completions path. `$ZSH_CUSTOM` is not initialized at that
   point in `.zshrc`, so the current expression resolves to `/plugins/...`:

   ```zsh
   fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
   ```

3. Implement the documented local shell override before syntax highlighting:

   ```zsh
   [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
   ```

4. Install JetBrains Mono Nerd Font; Powerlevel10k and eza icons depend on a
   Nerd Font, but the current Brewfile has no font entry.
5. Remove the unused chezmoi `headless` prompt and associated README claims,
   or introduce real behavior that uses it.
6. Install `lsof` on Linux because `ports`, `killport`, and `whatsport` require
   it.
7. Quote the Brewfile path passed to `brew bundle`.
8. Pin releases or commits for Oh My Zsh, Powerlevel10k, and zsh plugins rather
   than refreshing moving `master` archives weekly.

## Operating system

Use Ubuntu 24.04 LTS for the remote host.

Fedora is a good development distribution, particularly for recent packages
and Podman, but its short support lifecycle creates unnecessary upgrade work
for an always-on development and agent host. Ubuntu 24.04 is mature and has a
longer maintenance window. Fedora remains reasonable when Fedora itself is
part of the development target or frequent rebuilding is intentional.

Do not reproduce the entire macOS tool installation through APT. Keep Ubuntu's
system package set deliberately small and use mise for portable developer
tools.

## Package and tool ownership

Homebrew and mise are complementary rather than alternatives.

### Homebrew on macOS

Use Homebrew for machine-level packages and applications:

- GUI casks and fonts
- zsh and tmux
- system libraries
- OrbStack and UTM
- 1Password
- Sublime Text and JetBrains Toolbox
- macOS-specific utilities

Keep macOS-only Brewfile entries guarded with `OS.mac?` when appropriate.

### APT on Ubuntu

Use Ubuntu's repositories for operating-system dependencies and services:

```text
build-essential
ca-certificates
curl
file
git
gnupg
jq
lsof
procps
sudo
tmux
unzip
zsh
```

Use `apt-get`, not `apt`, in non-interactive scripts. Avoid adding a vendor APT
repository for each CLI tool. A third-party repository is justified only for a
system-level service that benefits from managed security updates, such as
Tailscale or Docker Engine.

When a third-party repository is necessary:

- use a dedicated signing key;
- use `Signed-By`;
- use a deb822 `.sources` file;
- do not use deprecated `apt-key`;
- consider repository pinning.

### mise on macOS and Ubuntu

Use mise for portable developer tools and language runtimes:

- Node and pnpm
- Neovim
- ripgrep, fd, fzf, bat, eza, and zoxide
- git-delta and GitHub CLI
- OpenTofu
- just, ShellCheck, and shfmt
- future Python, Go, Java, or other runtimes

Store global tool choices in `dot_config/mise/config.toml`. Use exact versions
in each project's committed `mise.toml`; global interactive defaults may track
a major release or `latest` where reproducibility is not important.

Remove fnm after mise manages Node. Keep TypeScript, `tsx`, linters, formatters,
and similar JavaScript tooling in project `devDependencies`, not as global
packages. Commit package-manager lockfiles and declare the package manager in
each project.

Unattended agents must only trust mise configuration from approved
repositories. Do not automatically execute tasks or hooks from arbitrary pull
requests.

## Hetzner and location

Keep Hetzner. It is a good price/performance fit for API-backed coding agents,
Git operations, builds, and tests. DigitalOcean offers a simpler managed
platform and AWS offers a much larger service ecosystem, but neither currently
adds enough value for this single host to justify the additional cost and
complexity.

Use Ashburn because the workstation is in Central America and interactive SSH
latency matters. Measure it before committing, but `ash` is a better default
than Germany for this workflow.

If agents eventually run models locally rather than calling hosted APIs, use a
specialized GPU provider instead of scaling a general-purpose Hetzner VPS.

## OpenTofu and provisioning boundaries

Keep OpenTofu responsible only for cloud infrastructure:

- server;
- firewall;
- SSH public key;
- IP address;
- backups;
- optional volume;
- outputs.

Use the following ownership model:

| Layer | Responsibility |
| --- | --- |
| OpenTofu | Hetzner resources and networking |
| cloud-init | User creation and minimal first-boot bootstrap |
| chezmoi | Shell, Git, and user configuration |
| mise | Developer tools and runtime versions |
| Project repositories | Dependencies, containers, and exact project versions |
| Backup system | Persistent data not safely stored in Git |

Do not add Terragrunt, Pulumi, Kubernetes, Packer, or a module hierarchy for one
server. Add Ansible only if multiple durable servers or substantial system
configuration make the current bootstrap scripts difficult to maintain.

Keep cloud-init small because changes to `user_data` replace the server. Normal
day-two tool and configuration changes should not require rebuilding it.

## OpenTofu state

Local state is acceptable temporarily only if it is backed up securely.

- Short term: maintain an encrypted backup of local state.
- Better: use an encrypted, versioned S3-compatible backend with confirmed
  locking support.

Do not place permanent Tailscale credentials, model API keys, GitHub tokens, or
other secrets directly in cloud-init. Rendered `user_data` is stored in state.

Keep `prevent_destroy` while the workflow is new, but make the host rebuildable
so the protection is a guardrail rather than the only defense against data
loss.

## Remote access

Use Tailscale with regular OpenSSH:

1. Create the server with public SSH restricted to the current client IP.
2. Install and enroll Tailscale.
3. Verify SSH through its private hostname.
4. Close public port 22.
5. Retain Hetzner Console or Rescue as break-glass access.

Avoid SSH agent forwarding. Authenticate Git on the server through HTTPS with
GitHub CLI, a fine-grained token, or a GitHub App.

Resolve the current mismatch where provisioning expects
`~/.ssh/id_ed25519.pub` while private keys live in 1Password. Keeping or
exporting the public half on disk is safe; private keys should remain in
1Password.

## Agent-host architecture

Do not run unattended agents as the interactive `chris` user inside long-lived
tmux sessions.

Create two roles:

- `chris`: interactive administration and development;
- `agent`: automated execution with no sudo access.

Run workers as systemd user services and enable lingering:

```bash
sudo loginctl enable-linger agent
systemctl --user enable --now agent-runner.service
```

Use tmux for observation and debugging, not process supervision.

Each task should receive:

- its own Git worktree or rootless container;
- a maximum duration;
- CPU, memory, and process limits;
- persistent job state and logs;
- a cleanup policy;
- a narrowly scoped credential set.

Start with no more than two concurrent agents. Let agents create branches,
commits, and pull requests. Do not let them automatically merge, deploy,
modify infrastructure, or access unrelated repositories.

## Agent security

Treat agent execution as arbitrary-code execution:

- dedicated non-sudo account;
- rootless Podman or Docker where isolation is useful;
- fine-grained GitHub token or GitHub App;
- model API key with a spending limit;
- no 1Password vault access;
- no SSH agent forwarding;
- no unrestricted production credentials;
- maximum job duration and concurrency;
- emergency kill switch;
- completion and failure notifications.

Runtime secrets may be provided through a root-owned systemd credentials or
environment file. Any secret available to the worker must be considered
exposed if that worker is compromised.

## Persistence and recovery

A single VPS is a single failure domain regardless of provider.

- Git is the source of truth for committed code.
- Long-running or unfinished work should be pushed to temporary branches.
- Back up the agent queue or database.
- Enable Hetzner daily backups for convenient short-term recovery.
- Use restic with independent object storage for durable, encrypted recovery.
- Keep runtime secrets out of backups.

Hetzner backups alone are insufficient because they have limited retention and
are tied to the server. Avoid a persistent block volume unless it is genuinely
needed; it introduces a separate lifecycle and backup problem.

## Development workflow

The existing CLI choices are generally strong. Complete the workflow around
them:

- add a practical tmux configuration before relying on remote sessions;
- configure Neovim minimally or choose a different server editor;
- use JetBrains Remote Development if a full IDE is preferred;
- use OrbStack for local containers and lightweight Linux;
- use UTM specifically for clean full-VM provisioning tests;
- use Docker Engine on Ubuntu only when projects require Docker compatibility;
  otherwise consider rootless Podman.

Keeping OrbStack and UTM is reasonable when they have those distinct roles.

## Git configuration

Complete or remove the deferred Git decisions:

- configure work-email selection with `includeIf`;
- enable 1Password SSH commit signing or remove the stated intent;
- give automated agent commits a distinct name and email;
- use HTTPS or a GitHub App for server-side repository access;
- keep personal identity separate from agent identity.

## OS maintenance

Add an explicit maintenance policy:

- automatic security updates;
- planned reboot handling;
- disk-usage monitoring;
- log rotation;
- service restart policies;
- health and failure notification;
- root SSH disabled after normal access is validated;
- no sudo access for the automated agent account.

## Repository validation

Add a small test harness, preferably behind `just test`, that performs:

```text
render chezmoi for macOS
render chezmoi for Ubuntu
check zsh syntax
run ShellCheck
run shfmt checks
validate cloud-init YAML
tofu fmt -check
tofu validate
validate Brewfile syntax
```

Add `just`, ShellCheck, and shfmt to the managed tool set. Test a clean Ubuntu
VM with a first apply, a second idempotent apply, and `zsh -i -c exit`.

## Suggested implementation order

1. Fix the current dotfile correctness issues.
2. Introduce mise and migrate Node away from fnm.
3. Split package ownership between macOS Homebrew, Ubuntu APT, and mise.
4. Change provisioning to Ubuntu 24.04 in Ashburn.
5. Add a secure OpenTofu state backup.
6. Provision and validate the base VPS.
7. Add Tailscale and close public SSH.
8. Configure tmux and the remote editor.
9. Add encrypted external backups.
10. Create the isolated `agent` account.
11. Add systemd workers, task isolation, limits, and notifications.
12. Add automated repository validation.
13. Run unattended agents only after recovery and kill procedures are tested.
