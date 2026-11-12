# linux-production-ops-scripts
Production-ready Bash scripts for Linux batch orchestration, exit-code control, log rotation, and automated file archival (Control-M / Cron ready).
# 🐧 Linux Production Operations & Batch Orchestration (Bash)

Production-oriented Shell scripts designed for **IT Operations, Production Control, and Batch Schedulers (BMC Control-M / Cron)**. Implements pre-flight file checks, exit-code propagation, automated log rotation, and structured file archival.

## 🚀 Key Capabilities
- **Pre-Flight Integrity Checks:** Verifies file existence (`-f`) and non-empty payload (`-s`) prior to execution, returning distinct exit codes (`RC=2`, `RC=3`) for scheduler alerting.
- **Exit-Code Control & Archival:** Captures downstream execution return codes (`$?`) to route processed files into `archive/processed/` or `archive/rejected/`.
- **Automated Log Rotation:** Generates timestamped execution logs and enforces a 7-day retention policy via `find -mtime +7`.
- **Fail-Fast Safety:** Configured with `set -euo pipefail` for predictable behavior in unattended production environments.

## 🛠️ Tech Stack
- **Shell:** GNU Bash (`#!/usr/bin/env bash`)
- **Target Environments:** Linux Servers (RHEL / Ubuntu), BMC Control-M, Cron

## ▶️ How to Run
```bash
chmod +x run_batch_pipeline.sh
./run_batch_pipeline.sh sample_batch.csv
