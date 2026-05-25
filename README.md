<div align="center">

```

         ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
         ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
         ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
         ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
         ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
         ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

```
        ╔══════════════════════════════════════════════════════════════╗
        ║  > SYSTEM: macOS · ARCH: arm64 · STATUS: [ READY ]           ║
        ║  > OPERATOR: escalonc · UPLINK: 1Password · MODE: solo dev   ║
        ╚══════════════════════════════════════════════════════════════╝
```

[![Typing](https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=20&duration=2800&pause=900&color=7AA2F7&center=true&vCenter=true&width=620&lines=%3E+initializing+escalonc%40dev...;%3E+one+command.+fully+loaded+mac.;%3E+44+CLI+tools+%C2%B7+25+apps+%C2%B7+5+fonts;%3E+zsh+%2B+p10k+%2B+fzf+%2B+atuin+%2B+zoxide;%3E+rust+rewrites+over+legacy+%E2%9C%93;%3E+ready_)](https://git.io/typing-svg)

![macOS](https://img.shields.io/badge/macOS-1a1b26?style=for-the-badge&logo=apple&logoColor=C0CAF5&labelColor=1a1b26)
![Shell](https://img.shields.io/badge/SHELL-zsh-7AA2F7?style=for-the-badge&logo=gnubash&logoColor=7AA2F7&labelColor=1a1b26)
![Homebrew](https://img.shields.io/badge/BREW-44%20formulae-E0AF68?style=for-the-badge&logo=homebrew&logoColor=E0AF68&labelColor=1a1b26)
![Rust](https://img.shields.io/badge/RUST-tools-7DCFFF?style=for-the-badge&logo=rust&logoColor=7DCFFF&labelColor=1a1b26)
![Idempotent](https://img.shields.io/badge/IDEMPOTENT-yes-9ECE6A?style=for-the-badge&labelColor=1a1b26)
![License](https://img.shields.io/badge/LICENSE-do%20what%20you%20want-BB9AF7?style=for-the-badge&labelColor=1a1b26)

</div>

---

```bash
$ curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/bootstrap.sh | bash
```

```
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  100%

[ OK ] kernel handshake          [ OK ] toolchain forge
[ OK ] homebrew core             [ OK ] vscode extensions
[ OK ] oh-my-zsh + p10k          [ OK ] symlink dotfiles → $HOME
[ OK ] fnm · uv · rustup         [ OK ] macOS defaults rewritten
```

---

## `>_ ./payload --list`

<table>
<tr><td valign="top" width="50%">

**`SHELL & TERMINAL`** `[01]`

```
► zsh ............ default shell
► oh-my-zsh ...... framework
► powerlevel10k .. prompt
► 23 plugins ..... loaded
► ghostty ........ GPU terminal
► warp ........... AI terminal
► zellij ......... multiplexer
```

`████████████ ONLINE`

</td><td valign="top" width="50%">

**`CLI ARSENAL`** `[02]`

```
► bat ........... cat++
► eza ........... ls with icons
► fd ............ find, faster
► rg ............ ripgrep
► fzf ........... fuzzy finder
► zoxide ........ smarter cd
► atuin ......... history search
► delta ......... pretty diffs
► lazygit ....... git TUI
► yazi .......... file manager
```

`████████████ ARMED`

</td></tr>
<tr><td valign="top">

**`LANGUAGES & RUNTIMES`** `[03]`

```
► node ......... via fnm
► python ....... via uv (100×)
► rust ......... via rustup
► pnpm ......... supply-safe
```

> *rust > legacy. always.*

`████████████ LIVE`

</td><td valign="top">

**`macOS TUNING`** `[04]`

```
► dark mode + liquid glass
► dock: autohide, no delay
► keyboard: fast repeat
► trackpad: tap-to-click
► finder: list view, folders 1st
► screenshots → ~/Pictures
► true tone ............ OFF
```

`████████████ TUNED`

</td></tr>
</table>

---

## `>_ tree ~/.dotfiles`

```
~/.dotfiles/
│
├── ⚡ bootstrap.sh ··············· curl|bash entry · installs brew · clones repo
├── ⚙  setup.sh ··················· orchestrator · 9 phases · idempotent
├── 🍺 Brewfile ··················· 44 formulae · 25 casks · 5 fonts
│
├── 📁 dotfiles/  ·················· symlinked into $HOME
│   ├── .zshrc ···················· shell config
│   ├── .gitignore_global ········· global ignore rules
│   └── .ssh/config ··············· 1Password SSH agent
│
└── 📁 scripts/  ··················· orchestrator modules
    ├── helpers.sh ················ colors · logging
    ├── shell.sh ·················· oh-my-zsh + 23 plugins
    ├── languages.sh ·············· fnm · uv · rustup
    ├── packages.sh ··············· pnpm globals · uv tools
    ├── vscode.sh ················· 26 extensions
    ├── git.sh ···················· config · aliases · delta
    ├── macos.sh ·················· system defaults
    └── claude.sh ················· claude code install
```

---

## `>_ ./how-it-works`

```mermaid
graph LR
    A([🌐 curl ∣ bash]) ==>|"fetch + clone"| B{{⚡ bootstrap.sh}}
    B ==>|"hands off to"| C{{"⚙️ setup.sh"}}

    C --> D["🍺 INSTALL<br>brew bundle · fnm<br>uv · rustup · pnpm"]
    C --> E["🔧 CONFIGURE<br>oh-my-zsh · vscode ext<br>git config · ssh keys"]
    C --> F["🖥️ PERSONALIZE<br>symlink dotfiles<br>macOS defaults · claude"]

    D ~~~ E ~~~ F

    style A fill:#1a1b26,stroke:#7aa2f7,color:#c0caf5,stroke-width:2px
    style B fill:#1a1b26,stroke:#e0af68,color:#e0af68,stroke-width:2px
    style C fill:#1a1b26,stroke:#9ece6a,color:#9ece6a,stroke-width:2px
    style D fill:#1a1b26,stroke:#7dcfff,color:#c0caf5
    style E fill:#1a1b26,stroke:#bb9af7,color:#c0caf5
    style F fill:#1a1b26,stroke:#f7768e,color:#c0caf5
```

**Already provisioned?** Re-run anytime — it's idempotent.

```bash
cd ~/.dotfiles && git pull && ./setup.sh
```

---

## `>_ ./customize`

```
WHEN YOU WANT TO...               EDIT THIS FILE

► add a CLI tool                  Brewfile                 brew ""
► add a GUI app                   Brewfile                 cask ""
► change shell config             dotfiles/.zshrc
► add a VS Code extension         scripts/vscode.sh
► tweak macOS defaults            scripts/macos.sh
► add a global pnpm package       scripts/packages.sh
► machine-specific overrides      ~/.zshrc.local       (untracked)
```

---

## `>_ ./post-install --checklist`

```
HUMAN-IN-THE-LOOP STEPS

[ ] restart terminal           ── or: source ~/.zshrc
[ ] p10k configure             ── pick your prompt vibe
[ ] 1password → ssh agent      ── settings · developer · enable
[ ] gh auth login              ── github cli login
[ ] claude                     ── authenticate claude code
[ ] orbstack + raycast         ── first-launch dance
[ ] terminal font              ── JetBrains Mono Nerd Font
[ ] displays                   ── uncheck True Tone
[ ] restart mac                ── one final cleanse

finished? ──────────────────────────> you are operational.
```

---

## `>_ cat philosophy.txt`

```
▸ personal, not general ............. one developer, no committee
▸ modern over legacy ................ rust rewrites win
▸ minimal globals ................... pnpm > npm · supply hygiene
▸ idempotent by design .............. run once or ten times
▸ no magic .......................... shell scripts, 5 min read
▸ keyboard > mouse .................. fzf · zoxide · lazygit
```

> *"your machine should feel like an extension of your hand,
> not someone else's idea of a default."*

---

<div align="center">

```
   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
   █████████████████████████████████████████████████████████████████
```

[![Footer](https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=14&duration=3800&pause=1800&color=7AA2F7&center=true&vCenter=true&width=520&lines=%5B+process+complete+%5D+%C2%B7+stay+caffeinated;built+with+zsh%2C+rust%2C+and+claude+code;EOF)](https://git.io/typing-svg)

```
END OF TRANSMISSION
```

</div>
