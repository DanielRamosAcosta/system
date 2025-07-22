#!/bin/bash
set -euo pipefail

IFS=',' read -ra USERS <<< "${DATABASE_USERS:-}"

for USER in "${USERS[@]}"; do
  DB_NAME="$USER"
  DB_USER="$USER"
  PASSWORD_VAR="USER_PASSWORD_${USER^^}"
  DB_PASS="${!PASSWORD_VAR:-}"

  if [ -z "$DB_PASS" ]; then
    echo "❌ Falta $PASSWORD_VAR"
    exit 1
  fi

  echo "🛠️ Configurando user '$DB_USER' y base '$DB_NAME'..."

  mariadb -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
REVOKE ALL PRIVILEGES ON *.* FROM '${DB_USER}'@'%';
GRANT USAGE ON *.* TO '${DB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

  echo "✅ Usuario '$DB_USER' configurado."
done
