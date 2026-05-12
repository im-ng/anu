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

GNOME_EXTENSIONS=(
    "openbar|https://extensions.gnome.org/extension-data/openbarneuromorph.v35.shell-extension.zip|openbar@neuromorph"
    "tilingshell|https://extensions.gnome.org/extension-data/tilingshellferrarodomenico.com.v12.shell-extension.zip|tilingshell@ferrarodomenico.com"
    "vitals|https://extensions.gnome.org/extension-data/VitalsCoreCoding.com.v68.shell-extension.zip|Vitals@CoreCoding.com"
    "appindicator|https://extensions.gnome.org/extension-data/appindicatorsupportrgcjonas.gmail.com.v58.shell-extension.zip|appindicatorsupport@rgcjonas.gmail.com"
    "hidetopbar|https://extensions.gnome.org/extension-data/hidetopbarmathieu.bidon.ca.v123.shell-extension.zip|hidetopbar@mathieu.bidon.ca"
)

ZIG_VERSION="0.15.1"
GO_VERSION="1.25.3"
ULAUNCHER_VERSION="5.15.7"

cleanup_file() {
    local f="$1"
    if [[ -f "$f" ]]; then rm -f "$f"; fi
    if [[ -d "$f" ]]; then rm -rf "$f"; fi
}

check_environment() {
    echo ""
    if [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
        log_info "FAIL" "env.check" "This script works only in GNOME environment"
        exit 1
    fi
    log_info "OK" "env.check" "GNOME environment confirmed"
    echo ""
}

system_update() {
    run_step "system.update" "Update apt repositories" \
        "sudo apt update"

    run_step "system.upgrade" "Upgrade installed packages" \
        "sudo apt upgrade -y"
}

install_apt_packages() {
    echo ""
    echo -e "${CYAN}--- APT Packages ---${NC}"
    for pkg in "${APT_PACKAGES[@]}"; do
        run_step "apt.${pkg}" "Install ${pkg}" \
            "sudo apt install -y ${pkg}"
    done
}

install_vscodium() {
    echo ""
    echo -e "${CYAN}--- VSCodium ---${NC}"

    run_step "codium.repo" "Add VSCodium APT repository" \
        "sudo wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg && echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list && sudo apt update"

    run_step "apt.codium" "Install codium" \
        "sudo apt install -y codium"
}

install_tools() {
    echo ""
    echo -e "${CYAN}--- Additional Tools ---${NC}"

    local tmpdir
    tmpdir=$(mktemp -d)

    run_step "tool.starship" "Install Starship prompt" \
        "curl -sS https://starship.rs/install.sh -o ${tmpdir}/starship-install.sh && sh ${tmpdir}/starship-install.sh -y"

    run_step "tool.brave" "Install Brave browser" \
        "curl -fsS https://dl.brave.com/install.sh -o ${tmpdir}/brave-install.sh && sudo sh ${tmpdir}/brave-install.sh"

    cleanup_file "$tmpdir"
}

install_codium_extensions() {
    echo ""
    echo -e "${CYAN}--- VSCodium Extensions ---${NC}"
    for ext in "${CODIUM_EXTS[@]}"; do
        local track_id
        track_id=$(echo "$ext" | tr '.' '-')
        run_step "codium.${track_id}" "Install extension ${ext}" \
            "codium --install-extension ${ext}"
    done
}

install_gnome_extensions() {
    echo ""
    echo -e "${CYAN}--- GNOME Extensions ---${NC}"
    local tmpdir
    tmpdir=$(mktemp -d)

    for entry in "${GNOME_EXTENSIONS[@]}"; do
        IFS='|' read -r name url uuid <<< "$entry"
        local zipfile="${tmpdir}/${name}.zip"

        if ! run_step "gnome.${name}.download" "Download ${name}" \
            "wget -q ${url} -O ${zipfile}"; then
            cleanup_file "$zipfile"
            continue
        fi

        run_step "gnome.${name}.install" "Install ${name}" \
            "gnome-extensions install ${zipfile} --force"

        run_step "gnome.${name}.enable" "Enable ${name}" \
            "gnome-extensions enable ${uuid}"

        cleanup_file "$zipfile"
    done

    cleanup_file "$tmpdir"
}

install_ulauncher() {
    echo ""
    echo -e "${CYAN}--- Ulauncher ---${NC}"
    local tmpdir debfile
    tmpdir=$(mktemp -d)
    debfile="${tmpdir}/ulauncher_${ULAUNCHER_VERSION}_all.deb"
    local url="https://github.com/Ulauncher/Ulauncher/releases/download/${ULAUNCHER_VERSION}/ulauncher_${ULAUNCHER_VERSION}_all.deb"

    run_step "app.ulauncher.download" "Download Ulauncher ${ULAUNCHER_VERSION}" \
        "wget -q ${url} -O ${debfile}"

    run_step "app.ulauncher.install" "Install Ulauncher" \
        "sudo apt install -y ${debfile}"

    run_step "app.ulauncher.autostart" "Set up Ulauncher autostart" \
        "mkdir -p ~/.config/autostart && cp ${SCRIPT_DIR}/config/ulauncher.desktop ~/.config/autostart/"

    cleanup_file "$tmpdir"
}

install_theme() {
    echo ""
    echo -e "${CYAN}--- Adwaitaru Theme ---${NC}"
    local tmpdir
    tmpdir=$(mktemp -d)

    run_step "theme.clone" "Clone Adwaitaru icon theme" \
        "git clone https://github.com/ricardoherreramx/adwaitaru.git ${tmpdir}/adwaitaru"

    if was_installed "theme.clone"; then
        run_step "theme.install" "Install Adwaitaru-blue icons" \
            "mkdir -p ~/.icons && cp -r ${tmpdir}/adwaitaru/Adwaitaru-blue ~/.icons/"
    fi

    cleanup_file "$tmpdir"
}

load_dconf() {
    echo ""
    echo -e "${CYAN}--- GNOME Settings ---${NC}"

    run_step "dconf.load" "Load GNOME keyboard shortcuts and settings" \
        "dconf load / < ${SCRIPT_DIR}/config/dconf-settings.ini"
}

install_zig() {
    echo ""
    echo -e "${CYAN}--- Zig ${ZIG_VERSION} ---${NC}"
    local tmpdir tarball url
    tmpdir=$(mktemp -d)
    tarball="${tmpdir}/zig-${ZIG_VERSION}.tar.xz"
    url="https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz"

    run_step "lang.zig.download" "Download Zig ${ZIG_VERSION}" \
        "wget -q ${url} -O ${tarball}"

    if was_installed "lang.zig.download"; then
        run_step "lang.zig.extract" "Extract Zig" \
            "sudo tar -C /usr/local/ -xf ${tarball} && sudo mv -f /usr/local/zig-x86_64-linux-${ZIG_VERSION} /usr/local/zig"

        if was_installed "lang.zig.extract"; then
            local bashrc="$HOME/.bashrc"
            if ! grep -q 'export ZIG=/usr/local/zig' "$bashrc" 2>/dev/null; then
                run_step "lang.zig.env" "Set ZIG environment variable" \
                    "echo 'export ZIG=/usr/local/zig' >> ${bashrc}"
            else
                log_info "SKIP" "lang.zig.env" "ZIG already set in .bashrc"
                track "lang.zig.env" "skip"
            fi
        fi
    fi

    cleanup_file "$tarball"
    cleanup_file "$tmpdir"
}

install_go() {
    echo ""
    echo -e "${CYAN}--- Go ${GO_VERSION} ---${NC}"
    local tmpdir tarball url
    tmpdir=$(mktemp -d)
    tarball="${tmpdir}/go-${GO_VERSION}.tar.gz"
    url="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

    run_step "lang.go.download" "Download Go ${GO_VERSION}" \
        "wget -q ${url} -O ${tarball}"

    if was_installed "lang.go.download"; then
        run_step "lang.go.extract" "Extract Go" \
            "sudo tar -C /usr/local -xzf ${tarball}"

        if was_installed "lang.go.extract"; then
            local bashrc="$HOME/.bashrc"
            if ! grep -q 'export GO=/usr/local/go' "$bashrc" 2>/dev/null; then
                run_step "lang.go.env" "Set GO environment variable" \
                    "echo 'export GO=/usr/local/go' >> ${bashrc}"
            else
                log_info "SKIP" "lang.go.env" "GO already set in .bashrc"
                track "lang.go.env" "skip"
            fi
        fi
    fi

    cleanup_file "$tarball"
    cleanup_file "$tmpdir"
}

set_path() {
    echo ""
    echo -e "${CYAN}--- PATH ---${NC}"
    local bashrc="$HOME/.bashrc"
    if ! grep -q 'export PATH=$ZIG:$GO/bin:$PATH' "$bashrc" 2>/dev/null; then
        run_step "env.path" "Add Zig and Go to PATH" \
            "echo 'export PATH=\$ZIG:\$GO/bin:\$PATH' >> ${bashrc}"
    else
        log_info "SKIP" "env.path" "PATH already set in .bashrc"
        track "env.path" "skip"
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Print what would be done without making changes"
    echo "  --help       Show this help message"
    exit 0
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRYRUN=true ;;
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
    anu_init "INSTALL"

    check_environment
    system_update
    install_apt_packages
    install_vscodium
    install_tools
    install_codium_extensions
    install_gnome_extensions
    install_ulauncher
    install_theme
    load_dconf
    install_zig
    install_go
    set_path

    print_summary

    if [[ "$DRYRUN" != "true" && "$FAILURES" -eq 0 ]]; then
        confirm_restart
    fi
}

main "$@"
