# Validation evidence

**Date:** October 5, 2026

**Scope:** isolated cloud demonstration with deliberately induced failures.

| Check | Verified outcome |
|---|---|
| Container build | Build, binary smoke test, and image publication succeeded; only intended build files were uploaded |
| Keyless authentication | Attached execution identity used; no execution key mount and no user-managed execution keys listed |
| Transfer integrity | Seeded 49-byte CSV matched by content, MD5, and CRC32C |
| Repeat execution | Successful rerun without destination object-generation change |
| Local transfer path | Separate dry-run and real copy checks passed |
| Scheduling | Authenticated Jobs API invocation returned HTTP 200; automatically launched executions succeeded |
| Configuration fault | Deliberately invalid source configuration caused a failed execution |
| Bucket-path drift | Out-of-band job source path changed to a nonexistent bucket; execution failed with source-directory errors |
| Failure notification | Matching error logs, positive failure-metric points, incident generation, and user-confirmed email delivery |
| Infrastructure repair | Reviewed plan restored the correct job path through one in-place update; no resource replacement or deletion |
| Recovery | Successful execution after repair; automatic incident closure and user-confirmed resolution email |
| Data preservation | Destination checksum and object generation remained unchanged through fault and repair |
| Infrastructure consistency | Post-repair plan reported no changes |
| Teardown | Saved destroy plan applied successfully; subsequent state listing independently confirmed empty |

## What the results do not establish

- The tiny dataset is a correctness check, not a throughput or scale benchmark.
- Unchanged-input reconciliation is not proof of exactly-once processing.
- Notifications arrived after several minutes; no delivery-time SLA is claimed.
- Existing build permissions were broad; this was not a least-privilege build audit.
- Empty Terraform state does not imply an empty cloud project. Unmanaged resources
  and artifacts can remain.
- Incident closure is asynchronous and distinct from restoring configuration or
  completing a successful execution.

The alert policy did not need modification to demonstrate recovery.
Terraform repaired configuration when explicitly applied; it did not execute
the transfer or autonomously repair drift.

Raw logs, state, plans, account identifiers, and implementation remain private.
See [architecture](architecture.md) or return to the [project overview](README.md).
