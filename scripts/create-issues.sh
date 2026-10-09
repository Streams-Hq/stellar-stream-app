#!/usr/bin/env bash
#
# Seed the Drips Wave issue backlog for stellar-stream-app.
#
# Run once, from the repository root, with an authenticated gh CLI:
#   bash scripts/create-issues.sh
#
# The script is safe to re-run: an issue whose title already exists in an open
# issue is skipped. It creates labels first, then issues.
#
# Nothing here touches main or pushes code. It only opens issues.
set -euo pipefail

REPO="${REPO:-Deyanju23/stellar-stream-app}"

# ---------------------------------------------------------------------------
# Labels
# ---------------------------------------------------------------------------
echo "Creating/updating labels on $REPO ..."
label() {
  gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force >/dev/null
}
label "Stellar Wave" "7B3FE4" "Part of the Stellar Drips Wave program"
label "good first issue" "7057FF" "Scoped, low-risk, good starting point"
label "complexity: low" "C2E0C6" "Roughly a day of work"
label "complexity: mid" "FEF2C0" "A few days of work"
label "complexity: high" "F9D0C4" "Touches core behavior; needs care"
label "type: bug" "D73A4A" "Incorrect or risky behavior"
label "type: test" "1D76DB" "Adds or improves tests"
label "type: docs" "0075CA" "Documentation only"
label "type: ci" "5319E7" "CI / build / tooling"
label "type: feature" "0E8A16" "New capability"

# ---------------------------------------------------------------------------
# Issues
# ---------------------------------------------------------------------------
created=0
skipped=0

create_issue() {
  local title="$1" labels="$2" body="$3"
  if gh issue list --repo "$REPO" --state open --search "$title in:title" \
      --json title --jq '.[].title' | grep -Fxq "$title"; then
    echo "skip  : $title"
    skipped=$((skipped + 1))
    return
  fi
  local label_args=()
  local part
  IFS=',' read -ra parts <<< "$labels"
  for part in "${parts[@]}"; do
    label_args+=(-l "$part")
  done
  gh issue create --repo "$REPO" --title "$title" "${label_args[@]}" --body "$body" >/dev/null
  echo "create: $title"
  created=$((created + 1))
}

create_issue \
  "test(sdk): cover XDR encoding and client read paths" \
  "Stellar Wave,type: test,complexity: low,good first issue" \
  "$(cat <<'EOF'
## Summary
Only `packages/sdk/src/math.ts` has tests. `xdr.ts` and `client.ts` — the parts
that encode arguments and parse contract return values — have none. A wrong
`i128` or `u64` encoding fails at runtime, not at compile time, so it should be
covered.

## Acceptance Criteria
- [ ] `addressToScVal`, `u64ToScVal`, `i128ToScVal`, `boolToScVal` round-trip to the expected ScVal
- [ ] `parseStreamScVal` parses both snake_case and camelCase keys
- [ ] `parseStreamScVal` throws on a missing required field
- [ ] Tests run under `pnpm --filter @stellar-stream/sdk test`

## Tech Stack
TypeScript, `node:test`, `@stellar/stellar-sdk`.
EOF
)"

create_issue \
  "test(indexer): add tests for event decoding and the REST API" \
  "Stellar Wave,type: test,complexity: mid" \
  "$(cat <<'EOF'
## Summary
The indexer decodes raw Soroban events and serves them over REST, but nothing
tests the decoding or the endpoints. A regression in topic parsing would only
show up against a live network.

## Acceptance Criteria
- [ ] Fixture events for `StreamCreated`, `TokensWithdrawn`, `StreamCanceled` decode to the expected rows
- [ ] Unknown/short events are ignored without crashing
- [ ] `/api/streams/:id` returns 404 for a missing stream and 400 for a bad id
- [ ] Uses an in-memory SQLite database (`:memory:`) so no files are written
- [ ] Wired into `pnpm --filter indexer test`

## Tech Stack
TypeScript, `node:test` or Vitest, better-sqlite3, Express.
EOF
)"

create_issue \
  "feat(web): paginate the stream dashboard" \
  "Stellar Wave,type: feature,complexity: mid" \
  "$(cat <<'EOF'
## Summary
The dashboard fetches `/api/streams?limit=100` once and renders everything. The
indexer caps `limit` at 100, so stream 101 and beyond are invisible, and there
is no way to page through them.

## Acceptance Criteria
- [ ] The list pages with a "Load more" control or infinite scroll
- [ ] Requests use the API's `limit` and `offset` parameters
- [ ] The filtered/search view stays consistent with the loaded page
- [ ] Loading and empty states remain correct at the end of the list

## Tech Stack
React 18, Next.js 14 App Router, the indexer REST API.
EOF
)"

create_issue \
  "fix(web): surface a clear error when the contract id is missing" \
  "Stellar Wave,type: bug,complexity: low,good first issue" \
  "$(cat <<'EOF'
## Summary
If `NEXT_PUBLIC_STREAM_CONTRACT_ID` is empty, `new Contract('')` fails and the
user sees a generic "Stream Not Found" or a raw simulation error. The real
cause — a missing configuration value — is never stated.

## Acceptance Criteria
- [ ] On load, if the contract id is empty or malformed, show a configuration banner
- [ ] The banner names the missing variable and links to the environment docs
- [ ] Chain actions are disabled while the config is invalid
- [ ] Nothing crashes when the indexer is also unreachable

## Tech Stack
Next.js, React, `apps/web/src/lib/config.ts`.
EOF
)"

create_issue \
  "feat(sdk): add withdrawAllTx after withdraw_all ships in the contract" \
  "Stellar Wave,type: feature,complexity: low" \
  "$(cat <<'EOF'
## Summary
Today a recipient who wants everything must call `balanceOf` and then
`withdrawTx` with that exact figure — two round trips, and the number can go
stale between them. The contracts repo tracks a `withdraw_all` convenience
function; once it is deployed, the SDK should expose it.

## Acceptance Criteria
- [ ] `withdrawAllTx(streamId: bigint, recipient: string)` builds and prepares the call
- [ ] Auth and return shape match `withdrawTx`
- [ ] Documented in the SDK reference
- [ ] A deployed contract with `withdraw_all` exists and its id is in the env

## Tech Stack
TypeScript, `@stellar/stellar-sdk`, `soroban-sdk`.

## Depends on
`feat(stream): add withdraw_all convenience function` in
Deyanju23/stellar-stream-contract — do not start until that contract is deployed.
EOF
)"

create_issue \
  "feat(indexer): support a Postgres backend for production" \
  "Stellar Wave,type: feature,complexity: high" \
  "$(cat <<'EOF'
## Summary
The indexer persists to a local SQLite file. On stateless hosts the file is
ephemeral, so restarting the service loses the index and forces a rescan from
the start ledger. Production needs a durable store.

## Acceptance Criteria
- [ ] A storage interface is defined with SQLite and Postgres implementations
- [ ] The backend is selected by env (`DATABASE_URL` present -> Postgres)
- [ ] The SQLite path keeps working for local development
- [ ] Since it re-decodes from scratch, a re-index path exists (set `START_LEDGER`)
- [ ] Documented in the indexer API page

## Design note
Decide and document whether the events table is also migrated, or whether
events stay SQLite-only. The former is more work but gives a real audit trail.

## Tech Stack
Node.js, TypeScript, better-sqlite3, `pg` or an equivalent.
EOF
)"

create_issue \
  "ci(repo): add dependency updates and cancel superseded runs" \
  "Stellar Wave,type: ci,complexity: low,good first issue" \
  "$(cat <<'EOF'
## Summary
CI runs on every push and PR but has no Dependabot configuration and does not
cancel an in-progress run when a new commit lands on the same branch, so stale
runs waste minutes and can report confusing statuses.

## Acceptance Criteria
- [ ] `.github/dependabot.yml` covers npm (root + workspaces) and GitHub Actions
- [ ] CI sets `concurrency` with `cancel-in-progress: true`
- [ ] Dependabot PRs run the same required checks as any other PR
- [ ] A short PR title convention is used for automated PRs

## Tech Stack
GitHub Actions, Dependabot.
EOF
)"

create_issue \
  "docs(app): add architecture and data-flow diagrams to the docs site" \
  "Stellar Wave,type: docs,complexity: low,good first issue" \
  "$(cat <<'EOF'
## Summary
The docs explain each piece in prose but never show how the pieces connect.
A reader has to assemble the user -> frontend -> indexer -> database path and
the direct frontend -> Soroban RPC write path themselves.

## Acceptance Criteria
- [ ] An end-to-end topology diagram on the local-setup page
- [ ] A sequence diagram for create -> sign -> submit -> index
- [ ] Diagrams are text-based (Mermaid) so they live in the repo, not as images
- [ ] `mkdocs build --strict` stays green

## Tech Stack
MkDocs Material, Mermaid.
EOF
)"

echo
echo "Done. created=$created skipped=$skipped"
