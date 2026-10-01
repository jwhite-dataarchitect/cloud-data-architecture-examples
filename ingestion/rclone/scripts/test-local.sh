#!/usr/bin/env bash
#
# test-local.sh — Test RClone configuration without cloud charges
#
# Creates a local test file and syncs it to GCS in dry-run mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DATA_DIR="${PROJECT_ROOT}/data"
BUCKET_NAME="${1:-data-arch-demo-landing-dev}"

echo ">> Creating test data..."
mkdir -p "$TEST_DATA_DIR"

# Create a small CSV file with sample data
cat > "${TEST_DATA_DIR}/sample_$(date +%Y%m%d).csv" <<EOF
id,name,value,timestamp
1,test_record_1,100,$(date -u +%Y-%m-%dT%H:%M:%SZ)
2,test_record_2,200,$(date -u +%Y-%m-%dT%H:%M:%SZ)
3,test_record_3,300,$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

TEST_FILE=$(ls -t "${TEST_DATA_DIR}"/sample_*.csv | head -1)
echo "   Created: $TEST_FILE"

echo ">> Testing RClone connection (dry-run)..."
echo "   This simulates the sync without transferring data"

# Run dry-run sync
"${SCRIPT_DIR}/sync-data.sh" \
  --source "$TEST_FILE" \
  --dest "gcs:${BUCKET_NAME}/test/$(date +%Y/%m/%d)/" \
  --dry-run

echo ""
echo ">> Local test passed!"
echo "   To perform actual sync, run:"
echo "   ${SCRIPT_DIR}/sync-data.sh --source \"$TEST_FILE\" --dest \"gcs:${BUCKET_NAME}/test/$(date +%Y/%m/%d)/\""