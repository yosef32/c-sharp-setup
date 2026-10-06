#!/usr/bin/env bash
# Prepares a Mac for C# development in Visual Studio Code.
#
# Installs, if missing:
#   - Homebrew
#   - Xcode Command Line Tools (prompt only; finish the dialog if it appears)
#   - Git
#   - .NET SDK 10 (current long-term support release; includes the runtime)
#   - Visual Studio Code
#   - C# language support, the .NET Install Tool, and C# Dev Kit
#
# Safe to run again. Packages that are already installed are left in place.
# Homebrew may ask for your Mac password the first time.
#
# C# Dev Kit is free for individuals, students, and open-source work. The first
# time you open it, VS Code may ask you to sign in with a Microsoft account.
#
# When the install finishes, the script creates a HelloCSharp console app in
# the current folder, runs it once, and opens that folder in Visual Studio Code.
# If HelloCSharp is already there, it opens the existing project.
#
# Usage:
#   chmod +x setup-mac.sh
#   ./setup-mac.sh

set -euo pipefail

DOTNET_CHANNEL="10.0"
EXTENSIONS=(
  "ms-dotnettools.vscode-dotnet-runtime"
  "ms-dotnettools.csharp"
  "ms-dotnettools.csdevkit"
)

if [[ $# -gt 0 ]]; then
  echo "Unknown option: $1" >&2
  echo "Usage: ./setup-mac.sh" >&2
  exit 1
fi

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

append_once() {
  local file="$1"
  local line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf "\n%s\n" "$line" >>"$file"
  fi
}

step "Checking macOS"
[[ "$(uname -s)" == "Darwin" ]] || die "This script is for macOS. On Windows, run setup-windows.ps1."

step "Checking Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  die "A dialog to install Xcode Command Line Tools should be open. Finish it, then run this script again."
fi
ok "Command Line Tools are installed."

step "Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    step "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    else
      die "Homebrew installed, but the brew command was not found."
    fi
  fi
fi

BREW_PREFIX="$(brew --prefix)"
append_once "$HOME/.zprofile" "eval \"\$($BREW_PREFIX/bin/brew shellenv)\""
ok "Homebrew is at $BREW_PREFIX"

step "Installing Git"
brew install git
ok "$(git --version)"

install_dotnet_with_script() {
  step "Installing the .NET $DOTNET_CHANNEL SDK with Microsoft's install script"
  local script
  script="$(mktemp)"
  curl -fsSL "https://dot.net/v1/dotnet-install.sh" -o "$script"
  bash "$script" --channel "$DOTNET_CHANNEL"
  rm -f "$script"

  append_once "$HOME/.zprofile" 'export DOTNET_ROOT="$HOME/.dotnet"'
  append_once "$HOME/.zprofile" 'export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"'
  append_once "$HOME/.bash_profile" 'export DOTNET_ROOT="$HOME/.dotnet"'
  append_once "$HOME/.bash_profile" 'export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"'

  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
}

step "Installing the .NET SDK"
if ! brew list --cask dotnet-sdk >/dev/null 2>&1; then
  if ! brew install --cask dotnet-sdk; then
    ok "The Homebrew .NET cask did not install. Using Microsoft's install script instead."
    install_dotnet_with_script
  fi
else
  ok ".NET SDK cask is already installed."
fi

if [[ -x /usr/local/share/dotnet/dotnet ]]; then
  export PATH="/usr/local/share/dotnet:$PATH"
fi

if ! command -v dotnet >/dev/null 2>&1 || ! dotnet --list-sdks 2>/dev/null | grep -q "^${DOTNET_CHANNEL%.*}\."; then
  install_dotnet_with_script
fi

step "Checking the .NET SDK"
command -v dotnet >/dev/null 2>&1 || die "dotnet is not on PATH. Open a new terminal and run this script again."
SDK_LIST="$(dotnet --list-sdks)"
printf "%s\n" "$SDK_LIST" | grep -q "^${DOTNET_CHANNEL%.*}\." || die "No .NET ${DOTNET_CHANNEL%.*} SDK was found. Installed SDKs:
$SDK_LIST"
ok "Installed SDKs:"
printf "%s\n" "$SDK_LIST" | sed 's/^/      /'

step "Installing Visual Studio Code"
if ! brew list --cask visual-studio-code >/dev/null 2>&1; then
  brew install --cask visual-studio-code
else
  ok "Visual Studio Code is already installed."
fi

CODE_BIN=""
if command -v code >/dev/null 2>&1; then
  CODE_BIN="$(command -v code)"
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi
[[ -n "$CODE_BIN" ]] || die "Visual Studio Code installed, but the code command was not found."

step "Installing VS Code C# extensions"
for extension in "${EXTENSIONS[@]}"; do
  echo "    Installing $extension"
  "$CODE_BIN" --install-extension "$extension" --force
done

INSTALLED="$("$CODE_BIN" --list-extensions)"
for extension in "${EXTENSIONS[@]}"; do
  printf "%s\n" "$INSTALLED" | grep -qx "$extension" || die "Extension '$extension' did not install."
  ok "$extension"
done

step "Creating a HelloCSharp project in the current folder"
if [[ ! -e HelloCSharp ]]; then
  mkdir HelloCSharp
  (
    cd HelloCSharp
    dotnet new console --name HelloCSharp --output .
    dotnet run
  )
  ok "Created $(pwd)/HelloCSharp"
elif [[ -f HelloCSharp/HelloCSharp.csproj ]]; then
  ok "Using the existing project at $(pwd)/HelloCSharp"
else
  die "HelloCSharp already exists and is not a C# project. Move that folder aside and run this script again."
fi

step "Opening the project in Visual Studio Code"
"$CODE_BIN" "$(pwd)/HelloCSharp"
ok "VS Code is opening $(pwd)/HelloCSharp"

step "This Mac is ready for C#"
cat <<'EOF'

HelloCSharp is open in Visual Studio Code. In the terminal there, run:

    dotnet run

Sign in if C# Dev Kit asks. That unlocks solution view, debugging, and tests.
EOF
