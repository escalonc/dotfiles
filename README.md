<div align="center">

```
  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&duration=3000&pause=1000&color=00FF41&center=true&vCenter=true&width=500&lines=%24+one+command.+fully+loaded+mac.;%24+curl+%7C+bash+%E2%86%92+dev+machine+ready;%24+44+CLI+tools+%C2%B7+25+apps+%C2%B7+5+fonts;%24+zsh+%2B+p10k+%2B+fzf+%2B+atuin+%2B+zoxide" alt="Typing SVG">

<br>

![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=zsh&logoColor=white)
![Rust](https://img.shields.io/badge/Rust_Tools-000000?style=for-the-badge&logo=rust&logoColor=white)
![pnpm](https://img.shields.io/badge/pnpm-F69220?style=for-the-badge&logo=pnpm&logoColor=white)
![Node](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

<br>

**[View the full interactive README with CRT effects and theme switcher](https://escalonc.github.io/dotfiles)**

<br>

```bash
curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/bootstrap.sh | bash
```

</div>

---

<br>

## `>_ what's inside`

<table>
<tr>
<td width="50%">

```
╔══════════════════════════════════╗
║  SHELL & TERMINAL               ║
╠══════════════════════════════════╣
║                                  ║
║  ➜ Zsh + Oh My Zsh              ║
║  ➜ Powerlevel10k prompt          ║
║  ➜ 23 plugins loaded             ║
║  ➜ Ghostty + Warp terminals      ║
║  ➜ Zellij multiplexer            ║
║                                  ║
╚══════════════════════════════════╝
```

</td>
<td width="50%">

```
╔══════════════════════════════════╗
║  CLI ARSENAL                     ║
╠══════════════════════════════════╣
║                                  ║
║  ➜ bat ─── syntax-highlighted cat║
║  ➜ eza ─── modern ls with icons  ║
║  ➜ fd ──── fast find             ║
║  ➜ rg ──── ripgrep (fast grep)   ║
║  ➜ fzf ─── fuzzy everything      ║
║  ➜ zoxide ─ smart cd             ║
║  ➜ atuin ── shell history search  ║
║  ➜ delta ── beautiful git diffs   ║
║  ➜ lazygit ─ terminal git UI     ║
║  ➜ yazi ─── terminal file mgr    ║
║                                  ║
╚══════════════════════════════════╝
```

</td>
</tr>
<tr>
<td width="50%">

```
╔══════════════════════════════════╗
║  LANGUAGES & RUNTIMES            ║
╠══════════════════════════════════╣
║                                  ║
║  ➜ Node.js ── via fnm (fast)     ║
║  ➜ Python ─── via uv (100x)      ║
║  ➜ Rust ───── via rustup          ║
║  ➜ pnpm ──── supply-chain safe   ║
║                                  ║
╚══════════════════════════════════╝
```

</td>
<td width="50%">

```
╔══════════════════════════════════╗
║  macOS TUNING                    ║
╠══════════════════════════════════╣
║                                  ║
║  ➜ Dark mode + Liquid Glass      ║
║  ➜ Dock: autohide, no delay      ║
║  ➜ Keyboard: fast repeat         ║
║  ➜ Trackpad: tap-to-click        ║
║  ➜ Finder: list view, folders 1st║
║  ➜ Screenshots → ~/Pictures/     ║
║                                  ║
╚══════════════════════════════════╝
```

</td>
</tr>
</table>

<br>

---

## `>_ tree ~/.dotfiles`

```
~/.dotfiles/
│
├── bootstrap.sh ·············· curl|bash entry point
├── setup.sh ·················· orchestrator
├── Brewfile ·················· 44 formulae · 25 casks · 5 fonts
│
├── dotfiles/
│   ├── .zshrc ················ shell config (symlinked → ~)
│   ├── .gitignore_global ····· global gitignore
│   └── .ssh/config ··········· 1Password SSH agent
│
└── scripts/
    ├── helpers.sh ············ colors & logging
    ├── shell.sh ·············· oh-my-zsh + plugins
    ├── languages.sh ·········· fnm · uv · rustup
    ├── packages.sh ··········· pnpm globals · uv tools
    ├── vscode.sh ············· 26 extensions
    ├── git.sh ················ config + aliases + delta
    ├── macos.sh ·············· system defaults
    └── claude.sh ············· claude code
```

<br>

---

## `>_ how it works`

<div align="center">

```
┌──────────────┐     ┌──────────────┐     ┌────────────────────────────────────┐
│              │     │              │     │                                    │
│  curl | bash │────▶│ bootstrap.sh │────▶│            setup.sh                │
│              │     │              │     │                                    │
└──────────────┘     └──────────────┘     │  ① brew bundle (Brewfile)          │
                                          │  ② oh-my-zsh + plugins             │
  installs Homebrew                       │  ③ fnm + uv + rustup               │
  + Xcode CLT                             │  ④ pnpm/uv globals                 │
  + clones repo                           │  ⑤ VS Code extensions              │
                                          │  ⑥ git config + SSH                │
                                          │  ⑦ symlink dotfiles → $HOME        │
                                          │  ⑧ macOS system defaults            │
                                          │  ⑨ Claude Code                     │
                                          │                                    │
                                          └────────────────────────────────────┘
```

</div>

**Already set up?** Pull and re-run:

```bash
cd ~/.dotfiles && git pull && ./setup.sh
```

> Idempotent — safe to run repeatedly. Skips what's already installed.

<br>

---

## `>_ customize`

```
╔═══════════════════════════════════════════════════════════════════╗
║  TASK                             FILE                           ║
╠═══════════════════════════════════════════════════════════════════╣
║  Add a CLI tool                   Brewfile (brew "name")         ║
║  Add an app                       Brewfile (cask "name")         ║
║  Change shell config              dotfiles/.zshrc                ║
║  Add VS Code extension            scripts/vscode.sh             ║
║  Tweak macOS defaults             scripts/macos.sh              ║
║  Machine-specific overrides       ~/.zshrc.local (not tracked)  ║
╚═══════════════════════════════════════════════════════════════════╝
```

<br>

---

## `>_ post-install`

```
 ┌────────────────────────────────────────────────────────────────┐
 │  MANUAL STEPS                                                  │
 ├────────────────────────────────────────────────────────────────┤
 │                                                                │
 │  [ ] Restart terminal (or source ~/.zshrc)                     │
 │  [ ] p10k configure                                            │
 │  [ ] 1Password → Settings → Developer → enable SSH agent       │
 │  [ ] gh auth login                                             │
 │  [ ] claude (authenticate)                                     │
 │  [ ] OrbStack + Raycast first-launch                           │
 │  [ ] Set JetBrains Mono Nerd Font in terminal                  │
 │  [ ] System Settings → Displays → uncheck True Tone           │
 │  [ ] Restart Mac                                               │
 │                                                                │
 └────────────────────────────────────────────────────────────────┘
```

<br>

---

## `>_ philosophy`

```
  ╔══════════════════════════════════════════════════════════════════╗
  ║                                                                  ║
  ║   ▸ Personal, not general — one developer, not a team            ║
  ║   ▸ Modern tools — Rust rewrites over legacy                     ║
  ║   ▸ Minimal globals — pnpm over npm (supply-chain hygiene)       ║
  ║   ▸ Idempotent — run once or ten times, same result              ║
  ║   ▸ No magic — shell scripts you can read in 5 minutes          ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝
```

<br>

<div align="center">

---

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=14&duration=4000&pause=2000&color=00FF41&center=true&vCenter=true&width=400&lines=%5Bprocess+complete%5D+built+with+caffeine+%2B+claude+code" alt="Footer">

</div>
