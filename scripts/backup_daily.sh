#!/bin/sh
set -eu

BACKUP_DIR=${BACKUP_DIR:-/backups}
TIMESTAMP=$(date +%F_%H%M%S)

export PGPASSWORD="${POSTGRES_PASSWORD}"
echo "[backup_daily] Starting at ${TIMESTAMP}"
echo "[backup_daily] Host=${POSTGRES_HOST} Port=${POSTGRES_PORT} User=${POSTGRES_USER} BackupDir=${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

DB_LIST=${DB_LIST:-}

if [ -z "${DB_LIST}" ]; then
  DB_LIST=$(psql \
    -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d postgres \
    -t -A -q -c "select datname from pg_database where datistemplate = false order by datname;")
fi

if [ -z "${DB_LIST}" ]; then
  echo "[backup_daily] No databases found to back up. Exiting."
  exit 0
fi

EXIT_CODE=0

for DBNAME in ${DB_LIST}; do
  OUT_FILE="${BACKUP_DIR}/${DBNAME}_${TIMESTAMP}.dump"
  echo "[backup_daily] Dumping database '${DBNAME}' -> ${OUT_FILE}"
  if ! pg_dump -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${DBNAME}" -Fc -f "${OUT_FILE}"; then
    echo "[backup_daily] ERROR: pg_dump failed for database '${DBNAME}'"
    EXIT_CODE=1
  fi
done

if [ ${EXIT_CODE} -eq 0 ]; then
  echo "[backup_daily] Completed successfully at $(date +%F_%H%M%S)"
else
  echo "[backup_daily] Completed with errors at $(date +%F_%H%M%S)"
fi

exit ${EXIT_CODE}