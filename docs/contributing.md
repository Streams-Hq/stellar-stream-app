# Contributing

Thanks for your interest. StellarStream takes part in the Stellar Drips Wave
program, and issues are labelled so new contributors can find work at a
comfortable level.

The full guide lives in the repository:

**→ [CONTRIBUTING.md](https://github.com/Deyanju23/stellar-stream-app/blob/main/CONTRIBUTING.md)**

## The short version

1. **Claim an issue first.** Comment on it to avoid duplicate work.
2. **Branch from `main`:** `feat/…`, `fix/…`, `docs/…`, `test/…`.
3. **Commit in Conventional Commits** — `type(scope): description`, with scope
   `web`, `sdk`, `indexer`, or `docs`.
4. **Push early and often.** Do not batch.
5. **Open a PR.** Green CI and one maintainer review are required; do not merge
   your own.

## Good entry points

Issues labelled `good first issue` and `Stellar Wave` are scoped for new
contributors. The `complexity: low / mid / high` labels indicate roughly how
much work each one is.

## House rules

- Node 20+, pnpm 10, lockfile is `pnpm-lock.yaml`.
- Never use floating point for token amounts — use `bigint` and the SDK's
  `parseUnits` / `formatUnits`.
- All contract reads and writes go through `packages/sdk`.
- New behavior needs tests; test invariants, not only the happy path.
- Behavior changes update the matching page under `docs/` in the same PR.

## Security

Do not open a public issue for a security problem. Follow the
[security policy](https://github.com/Deyanju23/stellar-stream-app/blob/main/SECURITY.md)
and report privately.
