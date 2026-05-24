#!/usr/bin/env bash

section "»  macOS System Preferences"

# ── Dock ─────────────────────────────────────────────────────────────────────
info "Configuring Dock..."
defaults write com.apple.dock autohide               -bool true
defaults write com.apple.dock autohide-delay         -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock magnification          -bool false
defaults write com.apple.dock show-recents           -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mineffect              -string "scale"
defaults write com.apple.dock mru-spaces             -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
success "Dock"

# ── Finder ───────────────────────────────────────────────────────────────────
info "Configuring Finder..."
defaults write com.apple.finder FXPreferredViewStyle        -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope        -string "SCcf"
defaults write com.apple.finder _FXSortFoldersFirst         -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop     -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write NSGlobalDomain AppleShowAllExtensions        -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
success "Finder"

# ── Keyboard & Input ─────────────────────────────────────────────────────────
info "Configuring keyboard..."
defaults write NSGlobalDomain KeyRepeat                -int 2
defaults write NSGlobalDomain InitialKeyRepeat         -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled  -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled   -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled     -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode                  -int 2
success "Keyboard"

# ── Trackpad ─────────────────────────────────────────────────────────────────
info "Configuring trackpad..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
success "Trackpad"

# ── Screenshots ──────────────────────────────────────────────────────────────
info "Configuring screenshots..."
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type     "png"
defaults write com.apple.screencapture disable-shadow -bool true
success "Screenshots → ~/Pictures/Screenshots"

# ── Menu Bar & UI ────────────────────────────────────────────────────────────
info "Configuring UI..."
defaults write NSGlobalDomain AppleInterfaceStyle    -string "Dark"
defaults write NSGlobalDomain AppleIconAppearanceTheme -string "RegularDark"
defaults write NSGlobalDomain AppleReduceDesktopTinting -int 1
defaults write NSGlobalDomain NSGlassDiffusionSetting   -int 1
defaults write NSGlobalDomain NSWindowResizeTime     -float 0.001
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint    -bool true
success "UI"

# ── Security ─────────────────────────────────────────────────────────────────
info "Configuring security..."
sudo defaults write /Library/Preferences/com.apple.loginwindow DisableConsoleAccess -bool true
defaults write com.apple.screensaver askForPassword        -int 1
defaults write com.apple.screensaver askForPasswordDelay   -int 0
success "Security"

# Apply changes
killall Dock    2>/dev/null || true
killall Finder  2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

success "macOS defaults applied"
