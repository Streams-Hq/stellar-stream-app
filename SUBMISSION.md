# Drips Wave submission pack

Ready-to-paste material for the StellarStream submission. Anything marked
**TODO** is not filled in yet — do not submit with a TODO still present.

## Supporting links

| Item | Link | Status |
| --- | --- | --- |
| Docs site | https://deyanju23.github.io/stellar-stream-app/ | after Pages is enabled |
| App repo | https://github.com/Deyanju23/stellar-stream-app | live |
| Contracts repo | https://github.com/Deyanju23/stellar-stream-contract | live |
| Live app | *(TODO: deployment URL)* | pending deploy |
| Contract verification | *(TODO: `https://stellar.expert/explorer/testnet/contract/<ID>`)* | pending testnet deploy |
| Demo video | *(TODO: 2–4 min walkthrough of create → live balance → withdraw → cancel)* | pending |

## Repo relationship

StellarStream is split into two repositories along the contract/application
boundary.

- **[stellar-stream-contract](https://github.com/Deyanju23/stellar-stream-contract)**
  holds the single Soroban contract that custodies the deposit and enforces the
  accrual rule. It is pure Rust with no knowledge of the frontend.
- **stellar-stream-app** (this repository) holds everything that talks to it:
  the `@stellar-stream/sdk` TypeScript client that builds and simulates the
  contract calls, the Express + SQLite indexer that subscribes to the contract's
  events, and the Next.js web app that presents them.

The two connect through one value: the deployed contract id. The contracts repo
prints `STREAM_CONTRACT_ID` at the end of a deploy; that id is set as
`NEXT_PUBLIC_STREAM_CONTRACT_ID` in the frontend and `STREAM_CONTRACT_ID` in the
indexer. The frontend also talks to Soroban RPC directly to build and submit
writes; the indexer is a read-side cache that the frontend falls back away from
when it is unavailable.

## Planned issues

Issues are already open in both repositories, labelled `Stellar Wave` with
`complexity: low / mid / high` so contributors can pick scoped work. The
backlog is reproducible: `scripts/create-issues.sh` in each repo creates the
full set.

**Contracts (`stellar-stream-contract`)**

- Auth-rejection tests for `withdraw` / `cancel` / `create_stream`
- Event-payload assertions for the three events
- Attach the release wasm to tagged releases
- `withdraw_all(stream_id)` convenience function
- Per-address stream index in the contract

**Application (this repository)**

- **SDK** — tests for XDR encoding and the client read paths; `withdrawAllTx`
  once `withdraw_all` is deployed (cross-repo dependency).
- **Indexer** — tests for event decoding and the REST API; an optional Postgres
  backend for stateless production hosting.
- **Web** — dashboard pagination beyond the 100-stream cap; a clear
  configuration error when the contract id is missing.
- **CI** — Dependabot and concurrency cancellation.
- **Docs** — architecture and data-flow diagrams.

## Project description

StellarStream is a continuous payment-streaming protocol on Stellar Soroban.
A sender locks a token deposit into a contract with a start and stop time, and
the balance accrues to the recipient every second until the stream ends; the
recipient can withdraw whatever has accrued at any moment, and if the stream is
cancellable the sender can stop early while the recipient keeps everything
already earned. It replaces the two usual ways recurring payouts are handled —
lump-sum transfers on a fixed date, or off-chain bookkeeping neither party can
audit — with an on-chain, per-second, claimable balance. Stellar is the right
foundation because transfers settle in seconds and cost a fraction of a cent
(so frequent small withdrawals are viable), and because Soroban runs the accrual
rule itself, using exact integer arithmetic derived from the ledger timestamp
with no floating point and no drift. The technical foundation is a single Rust
Soroban contract, a TypeScript SDK that mirrors its math, an event indexer over
REST, and a Next.js frontend with Freighter wallet integration; the application
is documented at https://deyanju23.github.io/stellar-stream-app/.

## Submission checklist (Phase 12)

- [ ] Repo settings applied: `bash scripts/setup-repo-settings.sh` (Pages,
      topics, branch protection) — needs a repo-admin token
- [ ] Project is not already in the approved list (search
      https://www.drips.network/wave/stellar/repos)
- [ ] Docs site URL resolves and loads
- [ ] Both repo URLs added
- [ ] Deployed contract id recorded and verified on a block explorer
- [ ] Live app URL added
- [ ] Demo video recorded and linked
- [ ] Repo relationship description pasted (above)
- [ ] Planned-issues description pasted (above)
- [ ] Project description pasted (above)
