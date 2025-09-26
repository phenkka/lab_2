#!/bin/sh
set -eu

export PGPASSWORD="${POSTGRES_PASSWORD}"

echo "[integrity_check] Starting at $(date +%F_%H%M%S)"
echo "[integrity_check] Host=${POSTGRES_HOST} Port=${POSTGRES_PORT} User=${POSTGRES_USER}"

INTEGRITY_MODE=${INTEGRITY_MODE:-amcheck}

if command -v pg_amcheck >/dev/null 2>&1 && [ "${INTEGRITY_MODE}" = "amcheck" ]; then
  if pg_amcheck -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -c -P progress; then
    echo "[integrity_check] pg_amcheck passed"
    exit 0
  else
    echo "[integrity_check] pg_amcheck reported issues"
    exit 2
  fi
else
  echo "[integrity_check] pg_amcheck not available or disabled; falling back to extension checks"
  DBS=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d postgres -t -A -q -c "select datname from pg_database where datistemplate = false order by datname;")
  RC=0
  for DB in ${DBS}; do
    echo "[integrity_check] Checking DB=${DB} via extension"
    SQL="DO \$\$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname='amcheck') THEN CREATE EXTENSION amcheck; END IF; END \$\$; SELECT COUNT(*) FROM pg_catalog.pg_class WHERE relkind = 'i';"
    if ! psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${DB}" -v ON_ERROR_STOP=1 -c "${SQL}" >/dev/null; then
      echo "[integrity_check] ERROR: amcheck prepare failed in ${DB}"
      RC=2
      continue
    fi
    if ! psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${DB}" -v ON_ERROR_STOP=1 -c "SELECT bt_index_check(c.oid) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.relkind='i' AND n.nspname NOT IN ('pg_catalog','pg_toast');" >/dev/null; then
      echo "[integrity_check] ERROR: index check failed in ${DB}"
      RC=2
    fi
  done
  if [ ${RC} -eq 0 ]; then
    echo "[integrity_check] Extension checks passed"
  fi
  exit ${RC}
fi


