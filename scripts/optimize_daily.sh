#!/bin/sh
set -eu

export PGPASSWORD="${POSTGRES_PASSWORD}"

echo "[optimize_daily] Starting at $(date +%F_%H%M%S)"
echo "[optimize_daily] Host=${POSTGRES_HOST} Port=${POSTGRES_PORT} User=${POSTGRES_USER}"

DB_LIST=${DB_LIST:-}
if [ -z "${DB_LIST}" ]; then
  DB_LIST=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d postgres -t -A -q -c "select datname from pg_database where datistemplate = false order by datname;")
fi

RC=0
for DB in ${DB_LIST}; do
  echo "[optimize_daily] VACUUM (ANALYZE) on ${DB}"
  if ! psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${DB}" -v ON_ERROR_STOP=1 -c "VACUUM (ANALYZE);" >/dev/null; then
    echo "[optimize_daily] ERROR: VACUUM failed on ${DB}"
    RC=1
  fi
done

if [ ${RC} -eq 0 ]; then
  echo "[optimize_daily] Completed successfully"
fi
exit ${RC}