#!/usr/bin/env bash

set -euo pipefail

DIST_DIR="dist"
GOLDEN_DIR="dist-golden"
ENVIRONMENT="${ENVIRONMENT:-auth}"
STATUS=0

tk export $DIST_DIR/$ENVIRONMENT environments/$ENVIRONMENT --merge-strategy replace-envs

echo "🔍 Comparando archivos *.yaml entre $GOLDEN_DIR/$ENVIRONMENT y $DIST_DIR/$ENVIRONMENT..."

# Recorre todos los archivos .yaml del golden
find "$GOLDEN_DIR/$ENVIRONMENT" -type f -name '*.yaml' | while read -r golden_file; do
  # Ruta relativa respecto al subdirectorio
  relative_path="${golden_file#$GOLDEN_DIR/$ENVIRONMENT/}"
  dist_file="$DIST_DIR/$ENVIRONMENT/$relative_path"

  if [[ ! -f "$dist_file" ]]; then
    echo "❌ Falta archivo en $DIST_DIR/$ENVIRONMENT: $relative_path"
    STATUS=1
    continue
  fi

  if ! diff -q "$golden_file" "$dist_file" > /dev/null; then
    echo "❌ Diferencias encontradas en: $relative_path"
    diff "$golden_file" "$dist_file" || true
    STATUS=1
  fi
done

# Verifica archivos extra en dist
find "$DIST_DIR/$ENVIRONMENT" -type f -name '*.yaml' | while read -r dist_file; do
  relative_path="${dist_file#$DIST_DIR/$ENVIRONMENT/}"
  golden_file="$GOLDEN_DIR/$ENVIRONMENT/$relative_path"

  if [[ ! -f "$golden_file" ]]; then
    echo "❌ Archivo extra en $DIST_DIR/$ENVIRONMENT: $relative_path"
    STATUS=1
  fi
done

if [[ $STATUS -eq 0 ]]; then
  echo "✅ Todos los archivos coinciden. ¡Test pasado!"
else
  echo "❌ ¡Test fallido!"
  exit 1
fi
