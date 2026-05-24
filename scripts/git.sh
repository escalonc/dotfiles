#!/usr/bin/env bash

section "»  Git Configuration"

GIT_NAME="Christopher Escalon"
GIT_EMAIL="escalonc@users.noreply.github.com"

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

git config --global core.editor          "code --wait"
git config --global core.autocrlf        "input"
git config --global core.excludesfile    "$HOME/.gitignore_global"
git config --global init.defaultBranch   "main"
git config --global push.default         "current"
git config --global pull.rebase          "true"
git config --global rebase.autoStash     "true"
git config --global fetch.prune          "true"
git config --global diff.colorMoved      "default"
git config --global rerere.enabled       "true"
git config --global help.autocorrect     "1"
git config --global color.ui             "auto"

# Delta as pager
git config --global core.pager           "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate       "true"
git config --global delta.light          "false"
git config --global delta.side-by-side   "true"
git config --global delta.line-numbers   "true"

# Aliases
git config --global alias.st   "status -sb"
git config --global alias.co   "checkout"
git config --global alias.br   "branch"
git config --global alias.lg   "log --oneline --graph --decorate --all"
git config --global alias.undo "reset HEAD~1 --mixed"
git config --global alias.wip  "commit -am 'WIP'"
git config --global alias.oops "commit --amend --no-edit"

success "Git configured for $GIT_NAME <$GIT_EMAIL>"
