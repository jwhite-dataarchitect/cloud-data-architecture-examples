.PHONY: help test-sync sync-sample clean-test

help:
	@echo "Available targets:"
	@echo "  test-sync     - Run RClone dry-run test"
	@echo "  sync-sample   - Sync sample data to GCS"
	@echo "  clean-test    - Remove test data from GCS"
	@echo "  check-bucket  - List contents of landing bucket"

test-sync:
	./ingestion/rclone/scripts/test-local.sh

sync-sample:
	./ingestion/rclone/scripts/sync-data.sh \
		--source "ingestion/rclone/data/sample_$$(date +%Y%m%d).csv" \
		--dest "gcs:data-arch-demo-landing-dev/manual-test/$$(date +%Y/%m/%d)/"

clean-test:
	rclone delete gcs:data-arch-demo-landing-dev/test/ --rmdirs
	rclone delete gcs:data-arch-demo-landing-dev/manual-test/ --rmdirs

check-bucket:
	rclone ls gcs:data-arch-demo-landing-dev/
