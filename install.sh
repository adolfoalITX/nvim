#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME_DIR="$(dirname "$SCRIPT_DIR")"

log() {
  printf '[install] %s\n' "$*"
}

print_banner() {
  local cyan="" magenta="" green="" dim="" bold="" reset=""

  if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
    cyan="$(printf '\033[1;36m')"
    magenta="$(printf '\033[1;35m')"
    green="$(printf '\033[1;32m')"
    dim="$(printf '\033[2m')"
    bold="$(printf '\033[1m')"
    reset="$(printf '\033[0m')"
  fi

  cat <<EOF
${magenta}::================================================================::${reset}
${cyan}███╗   ██╗██╗   ██╗██╗███╗   ███╗${magenta}    ███╗   ██╗███████╗ ██████╗ ███╗   ██╗${reset}
${cyan}████╗  ██║██║   ██║██║████╗ ████║${magenta}    ████╗  ██║██╔════╝██╔═══██╗████╗  ██║${reset}
${cyan}██╔██╗ ██║██║   ██║██║██╔████╔██║${magenta}    ██╔██╗ ██║█████╗  ██║   ██║██╔██╗ ██║${reset}
${cyan}██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║${magenta}    ██║╚██╗██║██╔══╝  ██║   ██║██║╚██╗██║${reset}
${cyan}██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║${magenta}    ██║ ╚████║███████╗╚██████╔╝██║ ╚████║${reset}
${cyan}╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝${magenta}    ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝${reset}
${magenta}::================================================================::${reset}
${bold}${green}                 [ bootstrapping your editor rig ]${reset}
${dim}                    plugins, lsp, treesitter, toolchain${reset}

EOF
}

fail() {
  printf '[install] ERROR: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

nvim_version() {
  if ! need_cmd nvim; then
    return 1
  fi

  nvim --version | while IFS= read -r line; do
    case "$line" in
      "NVIM v"*)
        printf '%s\n' "${line#NVIM v}"
        break
        ;;
    esac
  done
}

version_ge() {
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

detect_package_manager() {
  if need_cmd apt-get; then
    echo apt
    return
  fi
  if need_cmd dnf; then
    echo dnf
    return
  fi
  if need_cmd pacman; then
    echo pacman
    return
  fi
  if need_cmd zypper; then
    echo zypper
    return
  fi
  if need_cmd brew; then
    echo brew
    return
  fi

  fail "No supported package manager found. Install dependencies manually."
}

sudo_if_needed() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_packages() {
  local pm="$1"
  shift
  local packages=("$@")

  case "$pm" in
    apt)
      sudo_if_needed apt-get update
      sudo_if_needed apt-get install -y "${packages[@]}"
      ;;
    dnf)
      sudo_if_needed dnf install -y "${packages[@]}"
      ;;
    pacman)
      sudo_if_needed pacman -Sy --noconfirm "${packages[@]}"
      ;;
    zypper)
      sudo_if_needed zypper --non-interactive install "${packages[@]}"
      ;;
    brew)
      brew install "${packages[@]}"
      ;;
    *)
      fail "Unsupported package manager: $pm"
      ;;
  esac
}

install_base_dependencies() {
  local pm="$1"

  case "$pm" in
    apt)
      install_packages "$pm" \
        git curl unzip tar gzip build-essential make ripgrep fd-find npm cargo luarocks xclip
      if ! need_cmd fd && need_cmd fdfind; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
      fi
      ;;
    dnf)
      install_packages "$pm" \
        git curl unzip tar gzip gcc gcc-c++ make ripgrep fd-find npm cargo luarocks xclip
      ;;
    pacman)
      install_packages "$pm" \
        git curl unzip tar gzip base-devel ripgrep fd npm cargo luarocks xclip
      ;;
    zypper)
      install_packages "$pm" \
        git curl unzip tar gzip gcc gcc-c++ make ripgrep fd npm cargo luarocks xclip
      ;;
    brew)
      install_packages "$pm" \
        git curl unzip gnu-tar gzip make ripgrep fd node rust luarocks neovim
      ;;
  esac
}

ensure_tree_sitter_cli() {
  if need_cmd tree-sitter; then
    return
  fi

  need_cmd npm || fail "npm is required to install tree-sitter-cli"
  log "Installing tree-sitter CLI via npm"
  sudo_if_needed npm install -g tree-sitter-cli
}

install_neovim_from_tarball() {
  local arch archive_name install_dir target_dir url tmp_dir

  case "$(uname -m)" in
    x86_64)
      archive_name="nvim-linux-x86_64.tar.gz"
      target_dir="$HOME/.local/opt/nvim-linux-x86_64"
      ;;
    aarch64|arm64)
      archive_name="nvim-linux-arm64.tar.gz"
      target_dir="$HOME/.local/opt/nvim-linux-arm64"
      ;;
    *)
      fail "Unsupported Linux architecture for Neovim tarball: $(uname -m)"
      ;;
  esac

  url="https://github.com/neovim/neovim/releases/download/stable/$archive_name"
  tmp_dir="$(mktemp -d)"
  install_dir="$tmp_dir/nvim"

  log "Installing Neovim from official tarball"
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  curl -fsSL "$url" -o "$tmp_dir/$archive_name"
  mkdir -p "$install_dir"
  tar -xzf "$tmp_dir/$archive_name" -C "$install_dir"

  rm -rf "$target_dir"
  mv "$install_dir"/* "$target_dir"
  ln -sf "$target_dir/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp_dir"
}

ensure_nvim() {
  if need_cmd nvim; then
    local current_version
    current_version="$(nvim_version || true)"
    if [ -n "$current_version" ] && version_ge "$current_version" "0.12.0"; then
      return
    fi
  fi

  local pm="$1"

  if [ "$(uname -s)" = "Linux" ]; then
    install_neovim_from_tarball
  else
    log "Installing Neovim"
    case "$pm" in
      apt|dnf|pacman|zypper|brew)
        install_packages "$pm" neovim
        ;;
    esac
  fi

  local installed_version
  installed_version="$(nvim_version || true)"
  if [ -z "$installed_version" ] || ! version_ge "$installed_version" "0.12.0"; then
    fail "Neovim 0.12.0 or newer is required. Found: ${installed_version:-missing}"
  fi
}

ensure_path_contains_local_bin() {
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *)
      export PATH="$HOME/.local/bin:$PATH"
      ;;
  esac
}

ensure_asdf() {
  if need_cmd asdf; then
    return
  fi

  local asdf_dir="$HOME/.asdf"
  if [ ! -d "$asdf_dir" ]; then
    log "Installing asdf"
    git clone https://github.com/asdf-vm/asdf.git "$asdf_dir" --branch v0.18.0
  fi

  # shellcheck source=/dev/null
  . "$asdf_dir/asdf.sh"
}

ensure_asdf_plugin() {
  local plugin="$1"
  if asdf plugin list | grep -qx "$plugin"; then
    return
  fi

  log "Installing asdf plugin: $plugin"
  asdf plugin add "$plugin"
}

tool_version_from_file() {
  local tool="$1"
  local tool_versions="$SCRIPT_DIR/.tool-versions"

  if [ ! -f "$tool_versions" ]; then
    return
  fi

  awk -v tool="$tool" '$1 == tool { print $2 }' "$tool_versions"
}

install_asdf_tool() {
  local tool="$1"
  local version="$2"

  [ -n "$version" ] || return

  ensure_asdf
  ensure_asdf_plugin "$tool"

  log "Installing $tool $version via asdf"
  asdf install "$tool" "$version"
  asdf set -u "$tool" "$version"
}

install_node_from_tool_versions() {
  local version
  version="$(tool_version_from_file ivm-node || true)"
  [ -n "$version" ] || return

  install_asdf_tool ivm-node "$version"
}

install_java_from_tool_versions() {
  local version
  version="$(tool_version_from_file ivm-java || true)"
  [ -n "$version" ] || return

  install_asdf_tool ivm-java "$version"
}

install_maven_from_tool_versions() {
  local version
  version="$(tool_version_from_file ivm-maven || true)"
  [ -n "$version" ] || return

  install_asdf_tool ivm-maven "$version"
}

bootstrap_neovim() {
  log "Restoring plugins from lazy-lock.json"
  nvim --headless '+Lazy! restore' +qa

  log "Updating Tree-sitter parsers"
  nvim --headless '+TSUpdateSync' +qa

  log "Installing Mason packages"
  nvim --headless '+MasonUpdate' '+MasonInstall lua-language-server jdtls' +qa
}

main() {
  print_banner
  ensure_path_contains_local_bin
  export XDG_CONFIG_HOME="$CONFIG_HOME_DIR"

  local pm
  pm="$(detect_package_manager)"
  log "Using package manager: $pm"

  install_base_dependencies "$pm"
  ensure_nvim "$pm"
  install_node_from_tool_versions
  install_java_from_tool_versions
  install_maven_from_tool_versions
  ensure_tree_sitter_cli

  need_cmd nvim || fail "nvim is still not available after installation"
  need_cmd git || fail "git is required"
  need_cmd curl || fail "curl is required"
  need_cmd rg || fail "ripgrep is required"
  need_cmd tree-sitter || fail "tree-sitter CLI is required"
  need_cmd java || fail "Java is required for jdtls"
  need_cmd mvn || fail "Maven is required for Java projects"

  bootstrap_neovim

  log "Installation finished"
  log "Run 'nvim' and ':checkhealth' to verify the environment"
}

main "$@"
