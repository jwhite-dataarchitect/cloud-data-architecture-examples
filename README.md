## Project Status

This repository is actively being developed as a living showcase of cloud data architecture patterns, starting with GCP and expanding later to Azure and AWS.

For the current implementation plan, daily progress, design decisions, and open questions, see [`docs/implementation-notes.md`](docs/implementation-notes.md).

### Current milestone
- Day 1 scaffold is complete
- Local tooling is installed and verified
- Terraform repo structure and module stubs are in place
- Ready to begin Day 2: GCP foundation, IAM, and landing storage

### Focus for the next work sessions
- Select or confirm the GCP demo project strategy
- Establish the Terraform state approach
- Create the landing GCS bucket
- Add minimal IAM/service account permissions
- Begin the RClone ingestion layer

## Day 3: Data Ingestion with RClone

### Overview
RClone is configured to sync data to the GCS landing bucket (`data-arch-demo-landing-dev`) using service account impersonation via Application Default Credentials.

### Configuration
- **Remote name**: `gcs`
- **Config location**: `~/.config/rclone/rclone.conf`
- **Authentication**: `env_auth = true` (uses `gcloud auth application-default login`)
- **Storage class**: STANDARD (matches Terraform bucket configuration)

### Usage

**Dry-run test (no charges):**
```bash
./ingestion/rclone/scripts/test-local.sh
```

**Sync a file:**
```bash
./ingestion/rclone/scripts/sync-data.sh \
  --source /path/to/local/file.csv \
  --dest "gcs:data-arch-demo-landing-dev/landing/$(date +%Y/%m/%d)/"
```

**List files in bucket:**
```bash
rclone ls gcs:data-arch-demo-landing-dev/
```

**Sync with bandwidth limit (cost control):**
```bash
rclone copy /local/path gcs:data-arch-demo-landing-dev/path \
  --bwlimit 10M \
  --progress
```

### Directory Structure
```
ingestion/rclone/
├── scripts/
│   ├── sync-data.sh      # Main sync script
│   └── test-local.sh     # Dry-run test
├── config/
│   └── rclone.conf.template  # Configuration template
├── data/                 # Local test data (gitignored)
└── Dockerfile            # Container definition (pending Docker install)
```

### Cost Controls
- Always use `--dry-run` first to validate paths
- Use `--bwlimit` to prevent accidental large transfers
- Small test files (< 1KB) are effectively free
- Monitor usage: `gcloud storage du -s gs://data-arch-demo-landing-dev`

### Troubleshooting
- **"storageClass REGIONAL invalid"**: Ensure `storage_class = STANDARD` in rclone.conf
- **Authentication errors**: Run `gcloud auth application-default login`
- **Permission denied**: Verify service account impersonation is set up (Day 2)

### Next Steps (Day 4)
- Dockerize the ingestion process
- Set up Cloud Build triggers
- Add data validation hooks

# cloud-data-architecture-examples
Showcase of cloud data architecture examples using Terraform IaC — GCP first, with planned Azure/AWS examples. Designed for quick spin-up/tear-down to minimize cloud costs.

