#!/usr/bin/env bash
set -euo pipefail

# Required envs:
#   PROJECT_REF=jihhsiijrxhazbxhoirl
#   SUPABASE_URL=https://jihhsiijrxhazbxhoirl.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY=<service_role_key>
#   ANTHROPIC_API_KEY=<claude_key>

: "${PROJECT_REF:?PROJECT_REF is required}"
: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${SUPABASE_SERVICE_ROLE_KEY:?SUPABASE_SERVICE_ROLE_KEY is required}"
: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY is required}"

supabase link --project-ref "$PROJECT_REF"
supabase secrets set \
  SUPABASE_URL="$SUPABASE_URL" \
  SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY" \
  ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"

echo "Secrets set for project $PROJECT_REF"


