#!/bin/bash

ANUDIR="$HOME/.config/anu"
ANULOG="$ANUDIR/anu.log"
ANUSTATUS="$ANUDIR/status"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DRYRUN=false
FORCE=false
FAILURES=0
SUCCESSES=0
SKIPS=0

anu_init() {
    local mode="${1:-INSTALL}"

    if [[ "$DRYRUN" == "true" ]]; then
        echo -e "${CYAN}=== ANU ${mode} (DRY RUN) ===${NC}"
        echo ""
        return
    fi

    mkdir -p "$ANUDIR"
    echo "# anu $(echo "$mode" | tr '[:upper:]' '[:lower:]') run $(date -Iseconds)" > "$ANULOG"

    if [[ "$mode" == "INSTALL" ]]; then
        > "$ANUSTATUS"
    fi

    echo -e "${CYAN}=== ANU ${mode} ===${NC}"
    echo ""
}

log_info() {
    local level="$1" id="$2" msg="$3"
    local ts color prefix

    ts=$(date '+%H:%M:%S')
    case "$level" in
        OK)   color="$GREEN";  prefix="OK" ;;
        FAIL) color="$RED";    prefix="FAIL" ;;
        SKIP) color="$YELLOW"; prefix="SKIP" ;;
        DRY)  color="$CYAN";   prefix="DRY" ;;
        *)    color="$NC";     prefix="INFO" ;;
    esac

    echo -e "${color}[${prefix}]${NC} ${msg}"

    if [[ "$DRYRUN" != "true" && -d "$ANUDIR" ]]; then
        echo "[${prefix}] ${ts} | ${id} | ${msg}" >> "$ANULOG"
    fi
}

track() {
    local step_id="$1" status="$2"

    if [[ "$DRYRUN" != "true" && -d "$ANUDIR" ]]; then
        echo "${step_id}=${status}" >> "$ANUSTATUS"
    fi

    case "$status" in
        ok)   ((SUCCESSES++)) ;;
        fail) ((FAILURES++)) ;;
        skip) ((SKIPS++)) ;;
    esac
}

was_installed() {
    local step_id="$1"
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    if [[ ! -f "$ANUSTATUS" ]]; then
        return 1
    fi
    grep -q "^${step_id}=ok$" "$ANUSTATUS"
}

run_step() {
    local step_id="$1" description="$2"
    shift 2
    local cmd="$*"

    if [[ "$DRYRUN" == "true" ]]; then
        log_info "DRY" "$step_id" "would: ${description}"
        track "$step_id" "skip"
        return 0
    fi

    log_info "INFO" "$step_id" "${description}"

    if eval "$cmd"; then
        track "$step_id" "ok"
        log_info "OK" "$step_id" "${description}"
        return 0
    else
        local ec=$?
        track "$step_id" "fail"
        log_info "FAIL" "$step_id" "${description} (exit ${ec})"
        return "$ec"
    fi
}

print_summary() {
    local total=$((SUCCESSES + FAILURES + SKIPS))
    echo ""
    echo "=============================="
    echo "  ANU SUMMARY"
    echo "=============================="

    if [[ "$DRYRUN" == "true" ]]; then
        echo -e "  ${CYAN}This was a dry run. No changes made.${NC}"
        echo ""
    fi

    echo -e "  ${GREEN}Success:${NC} ${SUCCESSES}"
    echo -e "  ${RED}Failed:${NC}  ${FAILURES}"
    echo -e "  ${YELLOW}Skipped:${NC} ${SKIPS}"
    echo "  Total:   ${total}"
    echo ""

    if [[ "$FAILURES" -gt 0 ]]; then
        echo -e "${RED}Some steps failed.${NC}"
        if [[ "$DRYRUN" != "true" ]]; then
            echo "Check ${ANULOG} for details."
        fi
    else
        echo -e "${GREEN}All steps completed successfully.${NC}"
    fi

    if [[ "$DRYRUN" != "true" ]]; then
        echo ""
        echo "Log:     ${ANULOG}"
        echo "Status:  ${ANUSTATUS}"
    fi
    echo ""
}

confirm_restart() {
    echo ""
    echo -e "${YELLOW}A GNOME session restart is recommended.${NC}"
    echo "Restart now? (y/N)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        gnome-session-quit --force
    fi
}
