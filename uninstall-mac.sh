#!/usr/bin/env bash
# Removes the C# and Visual Studio Code tools installed by setup-mac.sh.
#
# Removes, when present:
#   - C# Dev Kit, the C# extension, and the .NET Install Tool
#   - Visual Studio Code
#   - The .NET SDK (Homebrew cask and the ~/.dotnet copy from the install script)
#   - Git's Homebrew copy
#
# Homebrew and the Xcode Command Line Tools stay installed. Other projects
# on the Mac may still need them.
#
# The script asks you to type YES before it removes anything.
# Pass --yes to skip that question.
#
# Usage:
#   chmod +x uninstall-mac.sh
#   ./uninstall-mac.sh
#   ./uninstall-mac.sh --yes --remove-sample

set -euo pipefail

ASSUME_YES=0
REMOVE_SAMPLE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)
      ASSUME_YES=1
      ;;
    --remove-sample)
      REMOVE_SAMPLE=1
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: ./uninstall-mac.sh [--yes] [--remove-sample]" >&2
      exit 1
      ;;
  esac
  shift
done

step() {
  printf "\n==> %s\n" "$1"
}

ok() {
  printf "    %s\n" "$1"
}

die() {
  printf "\nError: %s\n" "$1" >&2
  exit 1
}

remove_exact_line() {
  local file="$1"
  local line="$2"
  local tmp
  [[ -f "$file" ]] || return 0
  tmp="$(mktemp)"
  grep -Fvx "$line" "$file" >"$tmp" || true
  mv "$tmp" "$file"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script is for macOS. On Windows, run uninstall-windows.ps1."
fi

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo "This removes the Homebrew copy of Git, the .NET SDK, Visual Studio Code, and the C# extensions."
  echo "Homebrew and the Xcode Command Line Tools stay installed."
  read -r -p "Type YES to continue: " answer
  [[ "$answer" == "YES" ]] || die "Uninstall cancelled."
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

command -v brew >/dev/null 2>&1 || die "Homebrew is not available, so the installed apps cannot be removed from here."

step "Removing VS Code C# extensions"
CODE_BIN=""
if command -v code >/dev/null 2>&1; then
  CODE_BIN="$(command -v code)"
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [[ -n "$CODE_BIN" ]]; then
  for extension in \
    "ms-dotnettools.csdevkit" \
    "ms-dotnettools.csharp" \
    "ms-dotnettools.vscode-dotnet-runtime"
  do
    if "$CODE_BIN" --uninstall-extension "$extension"; then
      ok "Removed $extension"
    else
      ok "$extension was not installed."
    fi
  done
else
  ok "Visual Studio Code is not installed, so there are no extensions to remove."
fi

step "Removing Visual Studio Code"
if brew list --cask visual-studio-code >/dev/null 2>&1; then
  brew uninstall --cask visual-studio-code
  ok "Visual Studio Code is removed."
else
  ok "Visual Studio Code was not installed with Homebrew."
fi

step "Removing the .NET SDK"
if brew list --cask dotnet-sdk >/dev/null 2>&1; then
  brew uninstall --cask --zap dotnet-sdk
  ok "The .NET SDK cask is removed."
else
  ok "The .NET SDK cask was not installed."
fi

if [[ -d /usr/local/share/dotnet ]]; then
  ok "Removing the .NET files left in /usr/local/share/dotnet. This may ask for your Mac password."
  sudo rm -rf /usr/local/share/dotnet
  sudo rm -f /etc/paths.d/dotnet /etc/paths.d/dotnet-cli-tools /usr/local/bin/dotnet
fi

if [[ -d "$HOME/.dotnet" ]]; then
  rm -rf "$HOME/.dotnet"
  ok "Removed ~/.dotnet"
fi

for profile in "$HOME/.zprofile" "$HOME/.bash_profile"; do
  remove_exact_line "$profile" 'export DOTNET_ROOT="$HOME/.dotnet"'
  remove_exact_line "$profile" 'export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"'
done
ok "Removed the .NET PATH lines added by setup."

step "Removing Git's Homebrew copy"
if brew list git >/dev/null 2>&1; then
  brew uninstall git
  ok "Homebrew Git is removed. Git from Xcode Command Line Tools is unchanged."
else
  ok "Git was not installed with Homebrew."
fi

if [[ "$REMOVE_SAMPLE" -eq 1 ]]; then
  step "Removing the HelloCSharp sample in the current folder"
  if [[ -f HelloCSharp/HelloCSharp.csproj ]]; then
    rm -rf HelloCSharp
    ok "Removed $(pwd)/HelloCSharp"
  else
    ok "No HelloCSharp sample was found here."
  fi
fi

step "C# setup was removed"
cat <<'EOF'

Open a new terminal so PATH updates.
Homebrew and the Xcode Command Line Tools are still installed.
EOF
