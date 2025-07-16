#!/usr/bin/env bash
set -euo pipefail

echo "🏗️  Configurando bases multi-tenant…"

# 🔧 Helper: deja solo al owner con CONNECT
grant_connect_exclusive() {
    local db="$1"   # nombre de la base
    local owner="$2"
    PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "postgres" <<SQL
    REVOKE CONNECT ON DATABASE "$db" FROM PUBLIC;
    GRANT  CONNECT ON DATABASE "$db" TO "$owner";
SQL
}

# 🔧 Helper: instala extensiones necesarias
create_extensions() {
    local db="$1"
    PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$db" <<'SQL'
    CREATE EXTENSION IF NOT EXISTS vector;
    CREATE EXTENSION IF NOT EXISTS vchord;
    CREATE EXTENSION IF NOT EXISTS cube;
    CREATE EXTENSION IF NOT EXISTS earthdistance;
SQL
}

# 1️⃣ Blindamos las bases “públicas”
for sysdb in postgres template0 template1; do
    grant_connect_exclusive "$sysdb" "postgres"
done

# 2️⃣ Recorremos la lista de usuaries
IFS=',' read -ra USER_ARRAY <<< "${DATABASE_USERS:-}"
for raw_name in "${USER_ARRAY[@]}"; do
    name="$(echo "$raw_name" | xargs)"
    [[ -z "$name" ]] && continue

    up_name="$(echo "$name" | tr '[:lower:]' '[:upper:]')"
    pw_var="USER_PASSWORD_${up_name}"
    pw="${!pw_var:-}"

    [[ -z "$pw" ]] && { echo "⚠️  Falta la contraseña para '$name' ( \$${pw_var} ). Se omite."; continue; }

    echo "🔐 Creando role y BBDD para '$name'…"

    # Role con LOGIN
    PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "postgres" <<SQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$name') THEN
        CREATE ROLE "$name" LOGIN PASSWORD '$pw';
        END IF;
    END
    \$\$;
SQL

    # Base dedicada
    PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "postgres" \
        -c "CREATE DATABASE \"$name\" OWNER \"$name\" TEMPLATE template0;" \
        || true

    # Solo su dueñe puede entrar
    grant_connect_exclusive "$name" "$name"

    # Extensiones listas para usarse
    create_extensions "$name"
done

echo "✅  Bases blindadas y extensiones preparadas."
