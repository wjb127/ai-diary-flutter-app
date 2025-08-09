#!/usr/bin/env bash
set -euo pipefail

# Required envs:
#   PROJECT_REF=jihhsiijrxhazbxhoirl
#   ANTHROPIC_API_KEY=<claude_key>

: "${PROJECT_REF:?PROJECT_REF is required}"
: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY is required}"

supabase link --project-ref "$PROJECT_REF"
supabase secrets set ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"

echo "Secrets set for project $PROJECT_REF"


