# Security Policy

## Audit status

The StellarStream application (web app, SDK, and indexer) and its contracts are
**unaudited**. This is testnet software and must not be used to handle funds of
significant value. Treat the code as a work in progress: peer-reviewed, but
never reviewed by an external security firm.

## Scope

In scope for this repository:

- `packages/sdk` — transaction building, XDR encoding, and balance math
- `indexer` — Soroban event decoding, SQLite persistence, and the REST API
- `apps/web` — wallet integration, transaction submission, and UI state

Out of scope (report elsewhere):

- The Soroban contracts — report in
  [Deyanju23/stellar-stream-contract](https://github.com/Deyanju23/stellar-stream-contract)
- The Stellar network, Soroban runtime, or `@stellar/stellar-sdk` itself —
  report those upstream to the Stellar Development Foundation
- Anything requiring a compromised user key, a malicious RPC endpoint, or a
  malicious token contract
- Frontend-only issues that depend on a compromised browser extension

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability.

- **Preferred:** open a private report via GitHub Security Advisories —
  https://github.com/Deyanju23/stellar-stream-app/security/advisories/new
- **Or** contact the maintainer directly: GitHub [@Deyanju23](https://github.com/Deyanju23)

Include, where possible:

- A description of the issue and its impact
- The affected file(s) or package and a minimal reproduction
- Whether it has been disclosed elsewhere

## What to expect

- Acknowledgement within 72 hours
- An assessment and remediation plan within 7 days
- Credit in the fix's release notes unless you ask to stay anonymous

## Known non-issues

The following are understood and documented, not vulnerabilities:

- The SDK's live-balance calculator mirrors on-chain math client-side; it is a
  display convenience, not a source of truth. The contract is authoritative.
- The indexer is a cache. A stale or missing indexer record falls back to a
  direct on-chain query in the UI, and must never be treated as final.
- The contract is immutable once deployed, so there is no upgrade path from the
  application side.
