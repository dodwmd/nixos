#!/usr/bin/env bash
# Standalone export script for *arr SQLite databases
# Run this on nexus BEFORE deploying PostgreSQL changes
# No dependencies other than sqlite3 (already installed)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
CONFIG_BASE="${CONFIG_BASE:-/tank/config}"
EXPORT_DIR="${EXPORT_DIR:-/tank/config/postgres-migration}"

# Apps to export (sonarr and radarr are most important per user)
APPS=("sonarr" "radarr")

get_main_db() {
    local app=$1
    case $app in
        sonarr) echo "$CONFIG_BASE/$app/sonarr.db" ;;
        radarr) echo "$CONFIG_BASE/$app/radarr.db" ;;
        *) echo "$CONFIG_BASE/$app/$app.db" ;;
    esac
}

get_log_db() {
    echo "$CONFIG_BASE/$1/logs.db"
}

check_sqlite() {
    if ! command -v sqlite3 &> /dev/null; then
        log_error "sqlite3 not found. Install with: nix-shell -p sqlite"
        exit 1
    fi
}

export_app() {
    local app=$1
    local main_db=$(get_main_db "$app")
    local log_db=$(get_log_db "$app")
    local app_dir="$EXPORT_DIR/$app"

    log_info "=== Exporting $app ==="
    mkdir -p "$app_dir"

    if [[ ! -f "$main_db" ]]; then
        log_error "Main DB not found: $main_db"
        return 1
    fi

    # Stats
    local size=$(du -h "$main_db" | cut -f1)
    log_info "Main DB: $main_db ($size)"

    # Export schema
    sqlite3 "$main_db" ".schema" > "$app_dir/${app}-main-schema.sql"
    log_info "  Schema -> ${app}-main-schema.sql"

    # Export full dump
    sqlite3 "$main_db" ".dump" > "$app_dir/${app}-main-full.sql"
    local dump_size=$(du -h "$app_dir/${app}-main-full.sql" | cut -f1)
    log_info "  Full dump -> ${app}-main-full.sql ($dump_size)"

    # Table summary with row counts
    {
        echo "=== $app Main Database ==="
        echo "Source: $main_db"
        echo "Size: $size"
        echo "Exported: $(date)"
        echo ""
        echo "Tables:"
        sqlite3 "$main_db" "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;" | while read -r table; do
            if [[ -n "$table" ]]; then
                count=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null || echo "error")
                printf "  %-40s %s rows\n" "$table" "$count"
            fi
        done
        echo ""

        # App-specific key data
        case $app in
            sonarr)
                echo "Key Data:"
                local series=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM Series;" 2>/dev/null || echo "?")
                local episodes=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM Episodes;" 2>/dev/null || echo "?")
                local history=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM History;" 2>/dev/null || echo "?")
                echo "  Series: $series"
                echo "  Episodes: $episodes"
                echo "  History entries: $history"
                echo ""
                echo "Sample Series (first 10):"
                sqlite3 -header -column "$main_db" "SELECT Id, Title, Path, Status FROM Series LIMIT 10;" 2>/dev/null || echo "  (query failed)"
                ;;
            radarr)
                echo "Key Data:"
                local movies=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM Movies;" 2>/dev/null || echo "?")
                local history=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM History;" 2>/dev/null || echo "?")
                echo "  Movies: $movies"
                echo "  History entries: $history"
                echo ""
                echo "Sample Movies (first 10):"
                sqlite3 -header -column "$main_db" "SELECT Id, Title, Path, Status FROM Movies LIMIT 10;" 2>/dev/null || echo "  (query failed)"
                ;;
        esac
    } > "$app_dir/${app}-summary.txt"
    log_info "  Summary -> ${app}-summary.txt"

    # Export log database if exists
    if [[ -f "$log_db" ]]; then
        local log_size=$(du -h "$log_db" | cut -f1)
        sqlite3 "$log_db" ".dump" > "$app_dir/${app}-log-full.sql"
        log_info "  Log DB ($log_size) -> ${app}-log-full.sql"
    else
        log_warn "  Log DB not found: $log_db (skipping)"
    fi

    echo ""
}

show_summary() {
    log_info "=== Export Summary ==="
    echo ""
    for app in "${APPS[@]}"; do
        local summary="$EXPORT_DIR/$app/${app}-summary.txt"
        if [[ -f "$summary" ]]; then
            echo "--- $app ---"
            cat "$summary"
            echo ""
        fi
    done
}

# Main
check_sqlite

log_info "Exporting SQLite databases to: $EXPORT_DIR"
echo ""

mkdir -p "$EXPORT_DIR"

for app in "${APPS[@]}"; do
    export_app "$app" || log_warn "Failed to export $app"
done

log_info "=== All exports complete ==="
echo ""
log_info "Files exported to: $EXPORT_DIR"
ls -la "$EXPORT_DIR"/

echo ""
show_summary

log_info "Review the summaries above and the full dumps in $EXPORT_DIR"
log_info "If the data looks good, proceed with PostgreSQL deployment"
