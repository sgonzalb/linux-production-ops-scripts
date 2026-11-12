#!/usr/bin/env bash
# ==============================================================================
# Script: run_batch_pipeline.sh
# Description: Production batch wrapper for pre-validation, exit-code control,
#              log rotation, and file archival (Control-M / Cron ready).
# Author: Sandra González (sgonzalb)
# ==============================================================================

set -euo pipefail

# --- Configuration ---
BATCH_DATE=$(date +"%Y%m%d_%H%M%S")
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCOMING_DIR="${BASE_DIR}/incoming"
PROCESSED_DIR="${BASE_DIR}/archive/processed"
REJECTED_DIR="${BASE_DIR}/archive/rejected"
LOG_DIR="${BASE_DIR}/logs"
LOG_FILE="${LOG_DIR}/batch_execution_${BATCH_DATE}.log"
INPUT_FILE="${1:-sample_batch.csv}"

mkdir -p "$INCOMING_DIR" "$PROCESSED_DIR" "$REJECTED_DIR" "$LOG_DIR"

log() {
    local LEVEL="$1"
    local MESSAGE="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${LEVEL}] ${MESSAGE}" | tee -a "$LOG_FILE"
}

# --- Step 1: Pre-flight Checks ---
log "INFO" "Initializing batch pipeline for file: ${INPUT_FILE}"

if [[ ! -f "${BASE_DIR}/${INPUT_FILE}" ]]; then
    log "ERROR" "Input file '${INPUT_FILE}' not found. Aborting job (RC=2)."
    exit 2
fi

if [[ ! -s "${BASE_DIR}/${INPUT_FILE}" ]]; then
    log "ERROR" "Input file '${INPUT_FILE}' is empty (0 bytes). Aborting job (RC=3)."
    exit 3
fi

# --- Step 2: Execute Core Validation ---
log "INFO" "Running batch integrity validation..."
set +e
python3 "${BASE_DIR}/validator.py" >> "$LOG_FILE" 2>&1
EXIT_CODE=$?
set -e

# --- Step 3: Exit Code Evaluation & File Archival ---
if [[ $EXIT_CODE -eq 0 ]]; then
    cp "${BASE_DIR}/${INPUT_FILE}" "${PROCESSED_DIR}/${BATCH_DATE}_${INPUT_FILE}"
    log "INFO" "Batch completed successfully (RC=0). Archived to processed/."
else
    cp "${BASE_DIR}/${INPUT_FILE}" "${REJECTED_DIR}/${BATCH_DATE}_${INPUT_FILE}"
    log "ERROR" "Batch validation failed with RC=${EXIT_CODE}. Moved to rejected/."
    exit "$EXIT_CODE"
fi

# --- Step 4: Log Retention Policy (Keep last 7 days) ---
find "$LOG_DIR" -name "*.log" -type f -mtime +7 -delete
log "INFO" "Log retention check completed. Pipeline finished."
exit 0
