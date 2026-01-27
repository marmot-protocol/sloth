#!/bin/bash
set -eo pipefail
export LC_ALL=C

TEMPLATE="${1:-lib/l10n/app_en.arb}"
ERRORS=0
MISSING_COUNT=0
EXTRA_COUNT=0

JQ_STDERR=$(mktemp)
trap 'rm -f "$JQ_STDERR"' EXIT

echo "=== L10n Validation ==="
echo "Template: $TEMPLATE"

if [ ! -f "$TEMPLATE" ]; then
  echo "❌ Template file not found: $TEMPLATE"
  exit 1
fi

if ! TEMPLATE_KEYS=$(jq -r 'keys[] | select(startswith("@") | not)' "$TEMPLATE" 2>"$JQ_STDERR" | sort); then
  echo "❌ Failed to parse template $TEMPLATE:"
  sed 's/^/   /' "$JQ_STDERR"
  exit 1
fi

echo "Template keys: $(echo "$TEMPLATE_KEYS" | wc -l | tr -d ' ')"
echo ""

L10N_DIR=$(dirname "$TEMPLATE")

for ARB in "$L10N_DIR"/app_*.arb; do
  if [ "$ARB" = "$TEMPLATE" ]; then
    continue
  fi

  LANG=$(basename "$ARB" .arb | sed 's/app_//')

  if ! ARB_KEYS=$(jq -r 'keys[] | select(startswith("@") | not)' "$ARB" 2>"$JQ_STDERR" | sort); then
    echo "❌ $LANG: Failed to parse ARB file:"
    sed 's/^/   /' "$JQ_STDERR"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  MISSING=$(comm -23 <(echo "$TEMPLATE_KEYS") <(echo "$ARB_KEYS"))
  EXTRA=$(comm -13 <(echo "$TEMPLATE_KEYS") <(echo "$ARB_KEYS"))

  HAS_ERROR=0

  if [ -n "$MISSING" ]; then
    echo "❌ $LANG: Missing keys:"
    echo "$MISSING" | sed 's/^/   - /'
    MISSING_COUNT=$((MISSING_COUNT + 1))
    HAS_ERROR=1
  fi

  if [ -n "$EXTRA" ]; then
    echo "❌ $LANG: Extra/orphaned keys (not in template):"
    echo "$EXTRA" | sed 's/^/   - /'
    EXTRA_COUNT=$((EXTRA_COUNT + 1))
    HAS_ERROR=1
  fi

  if [ $HAS_ERROR -eq 1 ]; then
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ $LANG: All keys valid"
  fi
done

echo ""
if [ $ERRORS -gt 0 ]; then
  ERROR_DETAILS=""
  [ $MISSING_COUNT -gt 0 ] && ERROR_DETAILS="$MISSING_COUNT with missing keys"
  if [ $EXTRA_COUNT -gt 0 ]; then
    [ -n "$ERROR_DETAILS" ] && ERROR_DETAILS="$ERROR_DETAILS, "
    ERROR_DETAILS="${ERROR_DETAILS}$EXTRA_COUNT with extra keys"
  fi
  echo "❌ $ERRORS locale(s) have validation errors: $ERROR_DETAILS"
  exit 1
else
  echo "✅ All locales validated successfully!"
fi
