#!/bin/sh
set -eu

export PGPASSWORD="${POSTGRES_PASSWORD}"

echo "[reindex_weekly] Starting at $(date +%F_%H%M%S)"
echo "[reindex_weekly] Host=${POSTGRES_HOST} Port=${POSTGRES_PORT} User=${POSTGRES_USER}"

DB_LIST=${DB_LIST:-}
if [ -z "${DB_LIST}" ]; then
  DB_LIST=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d postgres -t -A -q -c "select datname from pg_database where datistemplate = false order by datname;")
fi

RC=0
for DB in ${DB_LIST}; do
  echo "[reindex_weekly] REINDEX DATABASE ${DB}"
  if ! psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${DB}" -v ON_ERROR_STOP=1 -c "REINDEX DATABASE \"${DB}\";" >/dev/null; then
    echo "[reindex_weekly] ERROR: REINDEX failed on ${DB}"
    RC=1
  fi
done

if [ ${RC} -eq 0 ]; then
  echo "[reindex_weekly] Completed successfully"
fi
exit ${RC}