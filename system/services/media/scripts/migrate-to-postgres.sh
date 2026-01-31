#!/usr/bin/env bash
# Migration script for *arr SQLite to PostgreSQL
# Run this AFTER PostgreSQL is set up but BEFORE enabling usePostgresql on services

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
CONFIG_BASE="${CONFIG_BASE:-/tank/config}"
EXPORT_DIR="${EXPORT_DIR:-/tank/config/postgres-migration}"
POSTGRES_USER="${POSTGRES_USER:-media}"
POSTGRES_HOST="${POSTGRES_HOST:-127.0.0.1}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

# Apps to migrate (only those that support PostgreSQL via env vars)
APPS=("sonarr" "radarr")

usage() {
    echo "Usage: $0 [command] [app]"
    echo ""
    echo "Commands:"
    echo "  check       - Check if SQLite databases exist and are readable"
    echo "  export      - Export SQLite databases to SQL files (for review/pgloader)"
    echo "  export-all  - Export all supported apps"
    echo "  backup      - Create backups of SQLite databases"
    echo "  migrate     - Migrate SQLite to PostgreSQL (stops service first)"
    echo "  migrate-all - Migrate all supported apps"
    echo "  verify      - Verify PostgreSQL has data after migration"
    echo ""
    echo "Apps: ${APPS[*]}"
    echo ""
    echo "Environment variables:"
    echo "  CONFIG_BASE  - Base config path (default: /tank/config)"
    echo "  EXPORT_DIR   - Export directory (default: /tank/config/postgres-migration)"
    echo ""
    echo "Workflow:"
    echo "  1. Deploy with homelab.media.postgresql.enable = true (services still on SQLite)"
    echo "  2. Run: sudo $0 export-all"
    echo "  3. Review exported SQL files in $EXPORT_DIR"
    echo "  4. Run: sudo $0 migrate-all"
    echo "  5. Run: sudo $0 verify"
    echo "  6. Set usePostgresql = true in NixOS config and rebuild"
}

check_prerequisites() {
    if ! command -v pgloader &> /dev/null; then
        log_error "pgloader is not installed. Add it to environment.systemPackages"
        exit 1
    fi

    if ! command -v psql &> /dev/null; then
        log_error "psql is not installed"
        exit 1
    fi

    if ! command -v sqlite3 &> /dev/null; then
        log_error "sqlite3 is not installed"
        exit 1
    fi
}

check_postgres() {
    if ! psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -c "SELECT 1" &> /dev/null; then
        log_error "Cannot connect to PostgreSQL at $POSTGRES_HOST:$POSTGRES_PORT as $POSTGRES_USER"
        exit 1
    fi
    log_info "PostgreSQL connection OK"
}

get_sqlite_paths() {
    local app=$1
    local config_dir="$CONFIG_BASE/$app"

    case $app in
        sonarr)
            echo "$config_dir/sonarr.db"
            ;;
        radarr)
            echo "$config_dir/radarr.db"
            ;;
        lidarr)
            echo "$config_dir/lidarr.db"
            ;;
        readarr)
            echo "$config_dir/readarr.db"
            ;;
        *)
            log_error "Unknown app: $app"
            exit 1
            ;;
    esac
}

get_log_db_path() {
    local app=$1
    echo "$CONFIG_BASE/$app/logs.db"
}

check_app() {
    local app=$1
    local main_db
    local log_db
    local size
    local tables
    local series
    local episodes
    local movies

    main_db=$(get_sqlite_paths "$app")
    log_db=$(get_log_db_path "$app")

    log_info "Checking $app..."

    if [[ -f "$main_db" ]]; then
        size=$(du -h "$main_db" | cut -f1)
        tables=$(sqlite3 "$main_db" ".tables" 2>/dev/null | wc -w)
        log_info "  Main DB: $main_db ($size, $tables tables)"

        # Show key stats
        case $app in
            sonarr)
                series=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM Series;" 2>/dev/null || echo "?")
                episodes=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM Episodes;" 2>/dev/null || echo "?")
                log_info "    Series: $series, Episodes: $episodes"
                ;;
            radarr)
                movies=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM Movies;" 2>/dev/null || echo "?")
                log_info "    Movies: $movies"
                ;;
        esac
    else
        log_warn "  Main DB not found: $main_db"
    fi

    if [[ -f "$log_db" ]]; then
        size=$(du -h "$log_db" | cut -f1)
        log_info "  Log DB: $log_db ($size)"
    else
        log_warn "  Log DB not found: $log_db"
    fi
}

export_app() {
    local app=$1
    local main_db
    local log_db
    local app_export_dir

    main_db=$(get_sqlite_paths "$app")
    log_db=$(get_log_db_path "$app")
    app_export_dir="$EXPORT_DIR/$app"

    log_info "=== Exporting $app ==="

    mkdir -p "$app_export_dir"

    # Export main database
    if [[ -f "$main_db" ]]; then
        log_info "Exporting main database..."

        # Schema only
        sqlite3 "$main_db" ".schema" > "$app_export_dir/${app}-main-schema.sql"
        log_info "  Schema: $app_export_dir/${app}-main-schema.sql"

        # Full dump (schema + data)
        sqlite3 "$main_db" ".dump" > "$app_export_dir/${app}-main-full.sql"
        log_info "  Full dump: $app_export_dir/${app}-main-full.sql"

        # Table list and row counts
        {
            echo "=== $app Main Database Tables ==="
            echo "Exported: $(date)"
            echo ""
            sqlite3 "$main_db" "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;" | while read -r table; do
                count=$(sqlite3 "$main_db" "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null || echo "error")
                printf "%-40s %s rows\n" "$table" "$count"
            done
        } > "$app_export_dir/${app}-main-tables.txt"
        log_info "  Table summary: $app_export_dir/${app}-main-tables.txt"

        # Create pgloader command file for this app
        cat > "$app_export_dir/${app}-main.load" << EOF
-- pgloader command file for $app main database
-- Run with: pgloader $app_export_dir/${app}-main.load

LOAD DATABASE
    FROM sqlite://$main_db
    INTO postgresql://$POSTGRES_USER@$POSTGRES_HOST:$POSTGRES_PORT/${app}-main

WITH include drop, create tables, create indexes, reset sequences

SET work_mem to '128MB', maintenance_work_mem to '512 MB'

CAST type datetime to timestamptz using zero-dates-to-null,
     type text to text drop typemod;
EOF
        log_info "  pgloader config: $app_export_dir/${app}-main.load"
    else
        log_warn "Main DB not found: $main_db"
    fi

    # Export log database
    if [[ -f "$log_db" ]]; then
        log_info "Exporting log database..."

        sqlite3 "$log_db" ".schema" > "$app_export_dir/${app}-log-schema.sql"
        sqlite3 "$log_db" ".dump" > "$app_export_dir/${app}-log-full.sql"

        cat > "$app_export_dir/${app}-log.load" << EOF
-- pgloader command file for $app log database
LOAD DATABASE
    FROM sqlite://$log_db
    INTO postgresql://$POSTGRES_USER@$POSTGRES_HOST:$POSTGRES_PORT/${app}-log

WITH include drop, create tables, create indexes, reset sequences

SET work_mem to '128MB', maintenance_work_mem to '512 MB'

CAST type datetime to timestamptz using zero-dates-to-null,
     type text to text drop typemod;
EOF
        log_info "  Log DB exported"
    else
        log_warn "Log DB not found: $log_db"
    fi

    log_info "=== Export complete for $app ==="
    log_info "Files in: $app_export_dir"
    ls -la "$app_export_dir/"
    echo ""
}

backup_app() {
    local app=$1
    local main_db
    local log_db
    local backup_dir

    main_db=$(get_sqlite_paths "$app")
    log_db=$(get_log_db_path "$app")
    backup_dir="$CONFIG_BASE/$app/backup-$(date +%Y%m%d-%H%M%S)"

    log_info "Creating backup for $app in $backup_dir"
    mkdir -p "$backup_dir"

    if [[ -f "$main_db" ]]; then
        cp "$main_db" "$backup_dir/"
        cp "${main_db}-shm" "$backup_dir/" 2>/dev/null || true
        cp "${main_db}-wal" "$backup_dir/" 2>/dev/null || true
        log_info "  Backed up main database"
    fi

    if [[ -f "$log_db" ]]; then
        cp "$log_db" "$backup_dir/"
        cp "${log_db}-shm" "$backup_dir/" 2>/dev/null || true
        cp "${log_db}-wal" "$backup_dir/" 2>/dev/null || true
        log_info "  Backed up log database"
    fi

    log_info "Backup complete: $backup_dir"
}

migrate_database() {
    local sqlite_path=$1
    local postgres_db=$2
    local pgloader_cmd

    if [[ ! -f "$sqlite_path" ]]; then
        log_warn "SQLite database not found: $sqlite_path (skipping)"
        return 0
    fi

    log_info "Migrating $sqlite_path -> $postgres_db"

    # Create pgloader command file
    pgloader_cmd=$(mktemp)
    cat > "$pgloader_cmd" << EOF
LOAD DATABASE
    FROM sqlite://$sqlite_path
    INTO postgresql://$POSTGRES_USER@$POSTGRES_HOST:$POSTGRES_PORT/$postgres_db

WITH include drop, create tables, create indexes, reset sequences

SET work_mem to '128MB', maintenance_work_mem to '512 MB'

CAST type datetime to timestamptz using zero-dates-to-null,
     type text to text drop typemod;
EOF

    # Run pgloader
    if pgloader "$pgloader_cmd" 2>&1; then
        log_info "  Migration successful"
    else
        log_error "  Migration failed"
        rm -f "$pgloader_cmd"
        return 1
    fi

    rm -f "$pgloader_cmd"
}

migrate_app() {
    local app=$1
    local main_db
    local log_db
    local service_name

    main_db=$(get_sqlite_paths "$app")
    log_db=$(get_log_db_path "$app")
    service_name="podman-$app"

    log_info "=== Migrating $app ==="

    # Check if service is running
    if systemctl is-active --quiet "$service_name" 2>/dev/null; then
        log_info "Stopping $service_name..."
        systemctl stop "$service_name"
        sleep 2
    fi

    # Backup first
    backup_app "$app"

    # Migrate main database
    migrate_database "$main_db" "${app}-main"

    # Migrate log database
    migrate_database "$log_db" "${app}-log"

    log_info "=== Migration complete for $app ==="
    echo ""
    log_info "Next steps:"
    log_info "1. Enable PostgreSQL in your NixOS config:"
    log_info "   homelab.media.$app.usePostgresql = true;"
    log_info "2. Rebuild: nixos-rebuild switch"
    log_info "3. The service will start automatically with PostgreSQL"
}

verify_app() {
    local app=$1
    local db
    local db_suffix
    local table_count
    local series
    local episodes
    local movies

    log_info "Verifying PostgreSQL data for $app..."

    for db_suffix in "main" "log"; do
        db="${app}-${db_suffix}"
        table_count=$(psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$db" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')

        if [[ -n "$table_count" && "$table_count" -gt 0 ]]; then
            log_info "  $db: $table_count tables"

            # Show some key tables and row counts for main db
            if [[ "$db_suffix" == "main" ]]; then
                case $app in
                    sonarr)
                        series=$(psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$db" -t -c "SELECT COUNT(*) FROM \"Series\";" 2>/dev/null | tr -d ' ')
                        episodes=$(psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$db" -t -c "SELECT COUNT(*) FROM \"Episodes\";" 2>/dev/null | tr -d ' ')
                        log_info "    Series: $series, Episodes: $episodes"
                        ;;
                    radarr)
                        movies=$(psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$db" -t -c "SELECT COUNT(*) FROM \"Movies\";" 2>/dev/null | tr -d ' ')
                        log_info "    Movies: $movies"
                        ;;
                esac
            fi
        else
            log_warn "  $db: No tables found or error querying"
        fi
    done
}

# Main
case "${1:-}" in
    check)
        if [[ -n "${2:-}" ]]; then
            check_app "$2"
        else
            for app in "${APPS[@]}"; do
                check_app "$app"
            done
        fi
        ;;
    export)
        if [[ -z "${2:-}" ]]; then
            log_error "Please specify an app to export"
            usage
            exit 1
        fi
        check_prerequisites
        export_app "$2"
        ;;
    export-all)
        check_prerequisites
        mkdir -p "$EXPORT_DIR"
        for app in "${APPS[@]}"; do
            export_app "$app"
        done
        log_info ""
        log_info "All exports complete. Files in: $EXPORT_DIR"
        log_info ""
        log_info "Review the exports, then run:"
        log_info "  sudo $0 migrate-all"
        ;;
    backup)
        if [[ -z "${2:-}" ]]; then
            log_error "Please specify an app to backup"
            usage
            exit 1
        fi
        backup_app "$2"
        ;;
    migrate)
        if [[ -z "${2:-}" ]]; then
            log_error "Please specify an app to migrate"
            usage
            exit 1
        fi
        check_prerequisites
        check_postgres
        migrate_app "$2"
        ;;
    migrate-all)
        check_prerequisites
        check_postgres
        for app in "${APPS[@]}"; do
            migrate_app "$app"
        done
        log_info ""
        log_info "All migrations complete!"
        log_info ""
        log_info "Verify with: sudo $0 verify"
        log_info ""
        log_info "Then update NixOS config:"
        for app in "${APPS[@]}"; do
            log_info "  homelab.media.$app.usePostgresql = true;"
        done
        log_info ""
        log_info "And rebuild: nixos-rebuild switch"
        ;;
    verify)
        check_prerequisites
        check_postgres
        if [[ -n "${2:-}" ]]; then
            verify_app "$2"
        else
            for app in "${APPS[@]}"; do
                verify_app "$app"
            done
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac
