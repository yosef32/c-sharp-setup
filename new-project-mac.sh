#!/usr/bin/env bash
# Creates a new C# console app and opens it in Visual Studio Code.
#
# Asks for a project name, creates that console app in the current folder,
# runs it once, and opens the folder in Visual Studio Code.
#
# Run setup-mac.command first so .NET and Visual Studio Code are installed.
#
# Double-click new-project-mac.command in Finder, or from Terminal:
#   chmod +x new-project-mac.sh
#   ./new-project-mac.sh
#   ./new-project-mac.sh MyApp

set -euo pipefail

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

valid_name() {
  local upper
  [[ "$1" =~ ^[A-Za-z][A-Za-z0-9_]{0,49}$ ]] || return 1
  upper="$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')"
  case "$upper" in
    CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9]) return 1 ;;
  esac
  return 0
}

ask_name_dialog() {
  local suggested="$1"
  local folder="$2"
  command -v osascript >/dev/null 2>&1 || return 2
  osascript - "$suggested" "$folder" 2>/dev/null <<'EOF' || return 2
on run argv
  set suggested to item 1 of argv
  set folderPath to item 2 of argv
  set prompt to "Type a name for the new console app.

Use a letter first, then letters, numbers, or underscores.

The folder is created in:
" & folderPath
  try
    set dialogResult to display dialog prompt default answer suggested buttons {"Cancel", "Create"} default button "Create" with title "New C# project"
    return text returned of dialogResult
  on error number -128
    return ""
  end try
end run
EOF
}

show_notice() {
  osascript - "$1" >/dev/null 2>&1 <<'EOF' || true
on run argv
  display dialog (item 1 of argv) buttons {"OK"} default button "OK" with title "New C# project"
end run
EOF
}

choose_name() {
  local candidate invalid suggested dialog_status exists
  invalid="Use a name that starts with a letter and uses only letters, numbers, and underscores. For example: MyApp"
  if [[ $# -ge 1 && -n "${1:-}" ]]; then
    candidate="$1"
    valid_name "$candidate" || die "$invalid"
    [[ -e "$candidate" ]] && die "A folder named $candidate is already here. Pick another name."
    PROJECT_NAME="$candidate"
    return
  fi

  suggested="MyApp"
  while true; do
    dialog_status=0
    candidate="$(ask_name_dialog "$suggested" "$(pwd)")" || dialog_status=$?
    if [[ "$dialog_status" -eq 2 ]]; then
      [[ -t 0 ]] || die "Pass a project name: ./new-project-mac.sh MyApp"
      printf "The new project folder is created in:\n    %s\n\n" "$(pwd)"
      read -r -p "Project name [$suggested]: " candidate
      if [[ -z "${candidate//[[:space:]]/}" ]]; then
        candidate="$suggested"
      fi
    elif [[ "$dialog_status" -ne 0 ]]; then
      die "Could not ask for a project name."
    elif [[ -z "${candidate//[[:space:]]/}" ]]; then
      printf "Project creation cancelled.\n"
      exit 0
    fi

    candidate="${candidate#"${candidate%%[![:space:]]*}"}"
    candidate="${candidate%"${candidate##*[![:space:]]}"}"
    if ! valid_name "$candidate"; then
      if [[ "$dialog_status" -eq 2 ]]; then
        printf "    %s\n" "$invalid"
      else
        show_notice "$invalid"
        [[ -n "$candidate" ]] && suggested="$candidate"
      fi
      continue
    fi
    if [[ -e "$candidate" ]]; then
      exists="A folder named $candidate is already here. Pick another name."
      if [[ "$dialog_status" -eq 2 ]]; then
        printf "    %s\n" "$exists"
      else
        show_notice "$exists"
      fi
      continue
    fi
    PROJECT_NAME="$candidate"
    return
  done
}

dotnet_root_of() {
  local path="$1"
  (
    while [[ -L "$path" ]]; do
      local dir
      dir="$(cd "$(dirname "$path")" && pwd)"
      path="$(readlink "$path")"
      [[ "$path" != /* ]] && path="$dir/$path"
    done
    cd "$(dirname "$path")" && pwd
  )
}

find_dotnet() {
  local candidates=()
  local candidate root version
  if command -v dotnet >/dev/null 2>&1; then
    candidates+=("$(command -v dotnet)")
  fi
  candidates+=(
    "/usr/local/share/dotnet/dotnet"
    "/opt/homebrew/share/dotnet/dotnet"
    "$HOME/.dotnet/dotnet"
  )

  for candidate in "${candidates[@]}"; do
    [[ -x "$candidate" ]] || continue
    root="$(dotnet_root_of "$candidate")"
    version="$(DOTNET_ROOT="$root" PATH="$root:$PATH" "$candidate" --version 2>/dev/null | tr -d '\r' | sed -n '/^[0-9][0-9]*\.[0-9][0-9]*\.[0-9]/p' | head -n 1 || true)"
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
      DOTNET_EXE="$candidate"
      DOTNET_ROOT="$root"
      DOTNET_VERSION="$version"
      export DOTNET_ROOT
      export PATH="$DOTNET_ROOT:$PATH"
      return 0
    fi
  done
  return 1
}

find_code() {
  if command -v code >/dev/null 2>&1; then
    CODE_BIN="$(command -v code)"
    return 0
  fi
  if [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    return 0
  fi
  return 1
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

write_editor_files() {
  local project_dir="$1"
  local project_name="$2"
  local tfm="$3"
  local exe_json root_json
  mkdir -p "$project_dir/.vscode"
  exe_json="$(json_escape "$DOTNET_EXE")"
  root_json="$(json_escape "$DOTNET_ROOT")"

  cat > "$project_dir/.vscode/settings.json" <<EOF
{
  "dotnet.dotnetPath": "$exe_json",
  "dotnetAcquisitionExtension.sharedExistingDotnetPath": "$exe_json",
  "terminal.integrated.env.osx": {
    "DOTNET_ROOT": "$root_json",
    "PATH": "$root_json:\${env:PATH}"
  }
}
EOF

  cat > "$project_dir/.vscode/launch.json" <<EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch $project_name",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "\${workspaceFolder}/bin/Debug/$tfm/$project_name.dll",
      "args": [],
      "cwd": "\${workspaceFolder}",
      "stopAtEntry": false,
      "console": "integratedTerminal"
    }
  ]
}
EOF

  cat > "$project_dir/.vscode/tasks.json" <<EOF
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build",
      "command": "dotnet",
      "type": "process",
      "args": [
        "build",
        "\${workspaceFolder}/$project_name.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary;ForceNoAlign"
      ],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": "\$msCompile"
    }
  ]
}
EOF
}

if [[ $# -gt 1 ]]; then
  die "Usage: ./new-project-mac.sh [ProjectName]"
fi

printf "New C# project\n"

step "Checking macOS"
[[ "$(uname -s)" == "Darwin" ]] || die "This script is for macOS. On Windows, double-click new-project-windows.cmd."

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

step "Choosing a project name"
choose_name "${1:-}"
ok "The project name is $PROJECT_NAME."

step "Checking the .NET SDK"
find_dotnet || die "The dotnet command was not found. Double-click setup-mac.command first, then run this script again."
framework="net${DOTNET_VERSION%%.*}.$(printf '%s' "${DOTNET_VERSION#*.}" | cut -d. -f1)"
ok ".NET SDK $DOTNET_VERSION ($framework)"

step "Checking Visual Studio Code"
find_code || die "Visual Studio Code was not found. Double-click setup-mac.command first, then run this script again."
ok "Visual Studio Code is available."

step "Creating $PROJECT_NAME"
mkdir "$PROJECT_NAME"
if ! (
  cd "$PROJECT_NAME"
  "$DOTNET_EXE" new console --language "C#" --name "$PROJECT_NAME" --output . --framework "$framework" --no-update-check
); then
  rm -rf "$PROJECT_NAME"
  printf "    Trying again with the SDK's default framework.\n"
  mkdir "$PROJECT_NAME"
  if ! (
    cd "$PROJECT_NAME"
    "$DOTNET_EXE" new console --language "C#" --name "$PROJECT_NAME" --output . --no-update-check
  ); then
    rm -rf "$PROJECT_NAME"
    die "dotnet new console failed. Double-click setup-mac.command first, then run this script again."
  fi
fi

(
  cd "$PROJECT_NAME"
  "$DOTNET_EXE" run
) || die "The new project did not run."

csproj="$PROJECT_NAME/$PROJECT_NAME.csproj"
tfm="$(sed -n 's:.*<TargetFramework>\([^<]*\)</TargetFramework>.*:\1:p' "$csproj" | head -n 1 | tr -d '[:space:]')"
[[ "$tfm" =~ ^net[0-9]+\.[0-9]+$ ]] || die "Could not read the target framework from $csproj."

write_editor_files "$(pwd)/$PROJECT_NAME" "$PROJECT_NAME" "$tfm"
ok "Created $(pwd)/$PROJECT_NAME"
ok "Run and Debug is set to Launch $PROJECT_NAME"

step "Opening the project in Visual Studio Code"
"$CODE_BIN" "$(pwd)/$PROJECT_NAME" || die "Visual Studio Code did not open $(pwd)/$PROJECT_NAME."
ok "VS Code is opening $(pwd)/$PROJECT_NAME"

cat <<EOF

Press F5, or open Run and Debug and start Launch $PROJECT_NAME.
You can also run it from the terminal:

    dotnet run
EOF
