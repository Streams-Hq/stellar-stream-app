#!/usr/bin/env bash
#
# Apply the repository settings the Drips Wave program expects for
# stellar-stream-app:
#   1. Enable GitHub Pages (source: GitHub Actions) for the docs site
#   2. Add discoverability topics
#   3. Protect `main` (PRs required, required status checks)
#
# These are repository-admin operations. Run with an authenticated gh CLI that
# has admin rights on the repository:
#   bash scripts/setup-repo-settings.sh
#
# Required status check names MUST match the job names in the workflows:
#   - "Lint, Test & Build Monorepo"  (.github/workflows/ci.yml)
#   - "Build documentation"          (.github/workflows/ci.yml)
# Status checks only become selectable after they have run at least once, so
# push a commit (or re-run CI) before applying protection.
set -euo pipefail

REPO="${REPO:-Deyanju23/stellar-stream-app}"
BRANCH="${BRANCH:-main}"

TOPICS='["stellar","soroban","stellar-network","payment-streaming","money-streaming","defi","nextjs","typescript","smart-contracts","stellar-wave"]'

echo "==> Enabling GitHub Pages (source: GitHub Actions) on $REPO ..."
if gh api "repos/$REPO/pages" >/dev/null 2>&1; then
  echo "    Pages already enabled."
else
  gh api --method POST "repos/$REPO/pages" -f build_type=workflow >/dev/null
  echo "    Pages enabled."
fi

echo "==> Setting topics ..."
gh api --method PUT "repos/$REPO/topics" --input - <<JSON
{ "names": $TOPICS }
JSON
echo "    Topics set."

echo "==> Protecting $BRANCH ..."
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
echo "    Branch protection applied."

echo
echo "Done."
echo "  Pages:  https://github.com/$REPO/settings/pages"
echo "  Topics: https://github.com/$REPO/settings"
echo "  Branch: https://github.com/$REPO/settings/branches"
