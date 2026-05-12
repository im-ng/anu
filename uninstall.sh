#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/anu.sh"

APT_PACKAGES=(
    "curl"
    "wget"
    "git"
    "chrome-gnome-shell"
    "gnome-browser-connector"
    "gnome-shell-extension-manager"
    "codium"
)

CODIUM_EXTS=(
    "akamud.vscode-theme-onelight"
    "catppuccin.catppuccin-vsc"
    "catppuccin.catppuccin-vsc-icons"
    "vadimcn.vscode-lldb"
    "ms-azuretools.vscode-containers"
    "ms-azuretools.vscode-docker"
    "golang.go"
    "ziglang.vscode-zig"
    "dreamcatcher45.podmanager"
    "cweijan.vscode-redis-client"
    "mtxr.sqltools"
    "vscode-icons-team.vscode-icons"
    "antfu.icons-carbon"
    "alexdauenhauer.catppuccin-noctis-icons"
    "donjayamanne.githistory"
    "shd101wyy.markdown-preview-enhanced"
    "esbenp.prettier-vscode"
)

GNOME_EXT_IDS=(
    "openbar@neuromorph"
    "tilingshell@ferrarodomenico.com"
    "Vitals@CoreCoding.com"
    "appindicatorsupport@rgcjonas.gmail.com"
    "hidetopbar@mathieu.bidon.ca"
)

check_status_file() {
    if [[ ! -f "$ANUSTATUS" ]]; then
        if [[ "$FORCE" == "true" ]]; then
            log_info "INFO" "uninstall.force" "No status file — forcing uninstall of all known items"
            return 0
        fi
        echo -e "${YELLOW}No status file found at ${ANUSTATUS}${NC}"
        echo ""
        echo "Packages may have been installed by an older version of anu."
        echo "Force uninstall everything anyway?"
        echo ""
        echo "  ./uninstall.sh --force    # skip this prompt next time"
        echo ""
        read -rp "Proceed with force uninstall? (y/N) " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            FORCE=true
            log_info "INFO" "uninstall.force" "Force uninstall of all known items"
            return 0
        fi
        echo "Aborted."
        exit 0
    fi
}

uninstall_codium_extensions() {
    echo ""
    echo -e "${CYAN}--- VSCodium Extensions ---${NC}"
    for ext in "${CODIUM_EXTS[@]}"; do
        local track_id
        track_id=$(echo "$ext" | tr '.' '-')
        if was_installed "codium.${track_id}"; then
            run_step "codium.${track_id}.remove" "Uninstall extension ${ext}" \
                "codium --uninstall-extension ${ext}"
        else
            log_info "SKIP" "codium.${track_id}.remove" "${ext} was not installed by anu"
            track "codium.${track_id}.remove" "skip"
        fi
    done
}

uninstall_apt_packages() {
    echo ""
    echo -e "${CYAN}--- APT Packages ---${NC}"
    for pkg in "${APT_PACKAGES[@]}"; do
        if was_installed "apt.${pkg}"; then
            run_step "apt.${pkg}.remove" "Remove ${pkg}" \
                "sudo apt remove -y ${pkg}"
        else
            log_info "SKIP" "apt.${pkg}.remove" "${pkg} was not installed by anu"
            track "apt.${pkg}.remove" "skip"
        fi
    done
}

uninstall_gnome_extensions() {
    echo ""
    echo -e "${CYAN}--- GNOME Extensions ---${NC}"
    for uuid in "${GNOME_EXT_IDS[@]}"; do
        local name
        name=$(echo "$uuid" | cut -d'@' -f1 | tr '[:upper:]' '[:lower:]')
        if was_installed "gnome.${name}.install"; then
            run_step "gnome.${name}.remove" "Uninstall ${uuid}" \
                "gnome-extensions uninstall ${uuid} --quiet"
        else
            log_info "SKIP" "gnome.${name}.remove" "${uuid} was not installed by anu"
            track "gnome.${name}.remove" "skip"
        fi
    done
}

uninstall_tools() {
    echo ""
    echo -e "${CYAN}--- Additional Tools ---${NC}"

    if was_installed "tool.starship"; then
        run_step "tool.starship.remove" "Remove Starship" \
            "rm -f /usr/local/bin/starship"
    else
        log_info "SKIP" "tool.starship.remove" "Starship was not installed by anu"
        track "tool.starship.remove" "skip"
    fi

    if was_installed "tool.brave"; then
        run_step "tool.brave.remove" "Remove Brave browser" \
            "sudo apt remove -y brave-browser"
    else
        log_info "SKIP" "tool.brave.remove" "Brave was not installed by anu"
        track "tool.brave.remove" "skip"
    fi
}

uninstall_ulauncher() {
    echo ""
    echo -e "${CYAN}--- Ulauncher ---${NC}"

    if was_installed "app.ulauncher.install"; then
        run_step "app.ulauncher.remove" "Remove Ulauncher" \
            "sudo apt remove -y ulauncher"
    else
        log_info "SKIP" "app.ulauncher.remove" "Ulauncher was not installed by anu"
        track "app.ulauncher.remove" "skip"
    fi

    if was_installed "app.ulauncher.autostart"; then
        run_step "app.ulauncher.autostart.remove" "Remove Ulauncher autostart" \
            "rm -f ~/.config/autostart/ulauncher.desktop"
    fi

    if [[ -d "$HOME/.config/ulauncher" ]]; then
        run_step "app.ulauncher.config.remove" "Remove Ulauncher config" \
            "rm -rf ~/.config/ulauncher"
    fi
}

uninstall_theme() {
    echo ""
    echo -e "${CYAN}--- Adwaitaru Theme ---${NC}"

    if was_installed "theme.install"; then
        run_step "theme.remove" "Remove Adwaitaru-blue icons" \
            "rm -rf ~/.icons/Adwaitaru-blue"
    else
        log_info "SKIP" "theme.remove" "Theme was not installed by anu"
        track "theme.remove" "skip"
    fi

    if [[ -z "$(ls -A ~/.icons 2>/dev/null)" ]]; then
        run_step "theme.iconsdir.remove" "Remove empty icons directory" \
            "rmdir ~/.icons"
    fi
}

reset_dconf() {
    echo ""
    echo -e "${CYAN}--- GNOME Settings ---${NC}"

    if was_installed "dconf.load"; then
        run_step "dconf.reset" "Reset GNOME settings to defaults" \
            "rm -f ~/.config/dconf/user"
    else
        log_info "SKIP" "dconf.reset" "dconf settings were not loaded by anu"
        track "dconf.reset" "skip"
    fi
}

uninstall_langs() {
    echo ""
    echo -e "${CYAN}--- Languages ---${NC}"

    if was_installed "lang.zig.extract"; then
        run_step "lang.zig.remove" "Remove Zig" \
            "sudo rm -rf /usr/local/zig"
        run_step "lang.zig.env.remove" "Remove ZIG from .bashrc" \
            "sed -i '/export ZIG=\/usr\/local\/zig/d' ~/.bashrc"
    else
        log_info "SKIP" "lang.zig.remove" "Zig was not installed by anu"
        track "lang.zig.remove" "skip"
    fi

    if was_installed "lang.go.extract"; then
        run_step "lang.go.remove" "Remove Go" \
            "sudo rm -rf /usr/local/go"
        run_step "lang.go.env.remove" "Remove GO from .bashrc" \
            "sed -i '/export GO=\/usr\/local\/go/d' ~/.bashrc"
    else
        log_info "SKIP" "lang.go.remove" "Go was not installed by anu"
        track "lang.go.remove" "skip"
    fi

    if was_installed "env.path"; then
        run_step "env.path.remove" "Remove anu PATH from .bashrc" \
            "sed -i '/export PATH=\$ZIG:\$GO\/bin:\$PATH/d' ~/.bashrc"
    else
        log_info "SKIP" "env.path.remove" "PATH was not set by anu"
        track "env.path.remove" "skip"
    fi
}

cleanup_anu_files() {
    echo ""
    echo -e "${CYAN}--- Cleanup ---${NC}"

    if [[ -d "$ANUDIR" ]]; then
        run_step "cleanup.anudir" "Remove anu tracking files" \
            "rm -rf ${ANUDIR}"
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Print what would be done without making changes"
    echo "  --force      Force uninstall all known items (no status file needed)"
    echo "  --help       Show this help message"
    exit 0
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRYRUN=true ;;
            --force)   FORCE=true ;;
            --help)    usage ;;
            *)
                echo "Unknown option: $arg"
                usage
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    anu_init "UNINSTALL"

    check_status_file

    uninstall_codium_extensions
    uninstall_gnome_extensions
    uninstall_tools
    uninstall_ulauncher
    uninstall_apt_packages
    uninstall_theme
    reset_dconf
    uninstall_langs
    cleanup_anu_files

    print_summary

    if [[ "$DRYRUN" != "true" ]]; then
        confirm_restart
    fi
}

main "$@"
