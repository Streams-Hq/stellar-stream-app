# Contributing to StellarStream App

Thanks for your interest. This repository is part of the StellarStream project
and takes part in the Stellar Drips Wave program. Issues are labelled so new
contributors can find work at a comfortable level.

This repository is the application layer: the Next.js frontend (`apps/web`), the
TypeScript SDK (`packages/sdk`), and the event indexer (`indexer`). The Soroban
contracts live in
[Deyanju23/stellar-stream-contract](https://github.com/Deyanju23/stellar-stream-contract).

## Before you start

Read [`docs/contract-reference.md`](./docs/contract-reference.md) — it mirrors the
contract's public interface. If a change depends on new or altered contract
behavior, that change must land in the contracts repository first, and the
interface in this repo must be updated in the same pull request as the code that
uses it.

## Workflow

1. Open or claim an issue before writing code. Comment on the issue to avoid
   duplicate work.
2. Branch from `main`: `git checkout -b feat/stream-search` (or `fix/…`,
   `docs/…`, `test/…`).
3. Make small, focused commits using Conventional Commits:
   `type(scope): description`
   - types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `style`
   - scope: `web`, `sdk`, `indexer`, or `docs`
   - example: `feat(web): add status filter to the dashboard`
4. Push early and often. Do not batch a week of work into one push.
5. Open a pull request against `main`. At least one maintainer review and green
   CI are required before merge. Do not merge your own PR.

## Standards

### General

- Node.js 20+ and pnpm 10. Do not commit `package-lock.json` or `yarn.lock`;
  the lockfile is `pnpm-lock.yaml`.
- One logical change per pull request. Keep diffs reviewable.
- Never use floating-point arithmetic for token amounts. Amounts are stroops
  (`bigint`, 7 decimals for XLM). Use `parseUnits` / `formatUnits` from the SDK.

### TypeScript

- TypeScript strict mode is on. No `any` without a comment explaining why.
- Prefer `bigint` over `number` for anything that touches balances or time.
- No non-null assertions (`!`) on values that can legitimately be missing;
  handle the absent case.
- Keep React components presentational where possible; put chain access in
  `packages/sdk` and data fetching in hooks.

### Contract interaction

- All Soroban RPC reads and writes go through `packages/sdk`. The frontend and
  indexer must not hand-roll XDR.
- A write path is build → sign → submit → poll. Signing always happens through
  the user's wallet; never ask for or store a secret key.

### Documentation

- Public functions and exported types carry doc comments.
- Behavior changes update the matching page under `docs/` in the same PR.

Run the full check locally before opening a PR:

```bash
pnpm install
pnpm --filter @stellar-stream/sdk test
pnpm build
```

## Tests

New behavior needs tests. The SDK's arithmetic is covered by
`packages/sdk/src/__tests__/math.test.ts`; when you touch accrual math, add a
case there. Prefer testing the invariant, not just the happy path — for example
`recipientEarned + senderRefundable == deposit` at every second. If you fix a
bug, add the test that would have caught it.

## Reporting bugs and security issues

Ordinary bugs: open an issue using the bug template.

Security issues: follow [`SECURITY.md`](./SECURITY.md). Do not open a public
issue.

## License

By contributing you agree that your contributions are licensed under the MIT
License in [`LICENSE`](./LICENSE).
