#!/usr/bin/env bash
#
# Apply branch protection to main for stellar-stream-app.
#
# Requires an authenticated gh CLI with admin rights on the repository:
#   bash scripts/setup-branch-protection.sh
#
# Required status check names MUST match the job names in the workflows, or the
# checks will never be satisfied. Current job names:
#   - "Lint, Test & Build Monorepo"  (.github/workflows/ci.yml)
#   - "Build documentation"          (.github/workflows/ci.yml)
#
# Note: status checks only become selectable after they have run at least once.
# Run CI on main (push) before applying this if the API rejects the contexts.
set -euo pipefail

REPO="${REPO:-Deyanju23/stellar-stream-app}"
BRANCH="${BRANCH:-main}"

echo "Applying branch protection to $REPO@$BRANCH ..."

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "repos/$REPO/branches/$BRANCH/protection" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Lint, Test & Build Monorepo",
      "Build documentation"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_last_push_approval": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON

echo
echo "Done. Verify in: https://github.com/$REPO/settings/branches"
