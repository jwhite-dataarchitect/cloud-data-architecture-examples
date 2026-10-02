#!/usr/bin/env bash
#
# sync-data.sh — Sync data from source to GCS landing bucket using RClone
#
# Usage:
#   ./sync-data.sh --source /local/path --dest gcs:bucket-name/path [--dry-run]
#
# Environment variables:
#   RCLONE_CONFIG: Path to rclone.conf (optional, uses default if not set)

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: $0 --source SOURCE --dest DEST [--dry-run] [--quiet] [--log-file FILE]"
  exit 0
fi

set -euo pipefail

# Default values
DRY_RUN=""
VERBOSE="-v"
SOURCE=""
DEST=""
LOG_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --source)
      SOURCE="$2"
      shift 2
      ;;
    --dest)
      DEST="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="--dry-run"
      shift
      ;;
    --quiet)
      VERBOSE=""
      shift
      ;;
    --log-file)
      LOG_FILE="--log-file=$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --source SOURCE --dest DEST [--dry-run] [--quiet] [--log-file FILE]"
      exit 1
      ;;
  esac
done

# Validate required args
if [[ -z "$SOURCE" || -z "$DEST" ]]; then
  echo "Error: --source and --dest are required"
  echo "Usage: $0 --source SOURCE --dest DEST [--dry-run] [--quiet] [--log-file FILE]"
  exit 1
fi

# Build rclone command
RCLONE_CMD="rclone copy $VERBOSE $DRY_RUN $LOG_FILE"

# Add config file if specified
if [[ -n "${RCLONE_CONFIG:-}" ]]; then
  RCLONE_CMD="$RCLONE_CMD --config=$RCLONE_CONFIG"
fi

# Execute sync
echo ">> Starting sync..."
echo "   Source: $SOURCE"
echo "   Dest:   $DEST"
[[ -n "$DRY_RUN" ]] && echo "   Mode:   DRY RUN (no changes will be made)"

$RCLONE_CMD "$SOURCE" "$DEST"

echo ">> Sync complete!"