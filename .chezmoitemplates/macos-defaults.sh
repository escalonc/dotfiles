{{- /*
  The macOS `defaults write` payload, included by run_onchange_after_60-ui-defaults.sh.tmpl:

      {{ template "macos-defaults.sh" . }}

  Split out so the run script stays a thin OS gate. Editing THIS file still
  re-triggers that script: chezmoi hashes the RENDERED script content, and the
  include makes this file part of it.
*/ -}}
echo "→ Applying macOS system preferences..."

# Dock
defaults write com.apple.dock autohide               -bool true
defaults write com.apple.dock autohide-delay         -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock magnification          -bool false
defaults write com.apple.dock show-recents           -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mineffect              -string "scale"
defaults write com.apple.dock mru-spaces             -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock enterMissionControlByTopWindowDrag -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Window tiling — disable macOS native tiling; Rectangle handles window management.
defaults write com.apple.WindowManager EnableTilingByEdgeDrag       -bool false  # drag to left/right edge to tile
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag    -bool false  # drag to menu bar to fill screen
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false # hold ⌥ while dragging to tile
defaults write com.apple.WindowManager EnableTiledWindowMargins     -bool false  # margins between tiled windows

# Finder
defaults write com.apple.finder FXPreferredViewStyle        -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope        -string "SCcf"
defaults write com.apple.finder _FXSortFoldersFirst         -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop     -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write NSGlobalDomain AppleShowAllExtensions        -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat                -int 2
defaults write NSGlobalDomain InitialKeyRepeat         -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled  -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled   -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled     -bool false
# 3 = Full Keyboard Access (Tab reaches ALL controls). 2 would be only the lesser
# "Keyboard navigation" toggle — looks similar, isn't.
defaults write NSGlobalDomain AppleKeyboardUIMode                  -int 2

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true

# Screenshots
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type     "png"
defaults write com.apple.screencapture disable-shadow -bool true

# UI
defaults write NSGlobalDomain AppleInterfaceStyle       -string "Dark"
defaults write NSGlobalDomain AppleIconAppearanceTheme  -string "RegularDark"
defaults write NSGlobalDomain AppleReduceDesktopTinting -int 1
defaults write NSGlobalDomain NSGlassDiffusionSetting   -int 1
defaults write NSGlobalDomain NSWindowResizeTime        -float 0.001
defaults write NSGlobalDomain AppleActionOnDoubleClick  -string "None"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint    -bool true

# Reduce Motion — replaces the slow desktop-switch slide with an instant
# crossfade (removes the "debounce" when switching Spaces back and forth).
# NOTE: com.apple.universalaccess is a TCC-protected domain; `defaults write`
# is blocked (even with sudo). Enable manually once per machine:
#   System Settings → Accessibility → Display → Reduce Motion
# (or deploy a configuration profile via MDM).

# Menu bar
defaults write NSGlobalDomain AppleMenuBarFontSize           -string "large"
defaults write NSGlobalDomain SLSMenuBarUseBlurredAppearance -bool true

# Security
defaults write com.apple.screensaver askForPassword      -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Apply.
killall Dock           2>/dev/null || true
killall Finder         2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall WindowManager  2>/dev/null || true

echo "✓ macOS defaults applied"
