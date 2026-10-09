# Introduction

## What StellarStream is

StellarStream is a protocol for streaming payments on Stellar. Instead of
sending a lump sum, a sender locks a deposit in a Soroban contract next to a
start time and a stop time. The deposit unlocks to the recipient continuously,
second by second, until the stop time. The recipient can withdraw whatever has
accrued whenever they want, as many times as they want.

One sentence: **lock funds once, and they unlock to the recipient every second
until the stream ends.**

## The problem

Recurring payouts — salaries, contractor retainers, vesting schedules,
subscriptions, grant disbursements — are usually handled in one of two ways:

1. **Lump-sum transfers** on a fixed date. The recipient's money arrives in
   one chunk, and until that date the balance they have *earned* is invisible
   and inaccessible.
2. **Off-chain bookkeeping.** A spreadsheet or payroll system tracks what is
   owed. The number is not auditable by the recipient and depends entirely on
   trusting the payer's records.

Both leave the receiving party unable to see or claim what they have already
earned. A stream fixes that: at any second, the recipient can read an exact
number and withdraw it.

The scale of the flow this touches is large. The World Bank estimates global
remittance flows reached about **$905 billion in 2024**, up 4.6% from $865
billion in 2023, and the average cost of sending remittances was **6.36%** in
Q3 2025 against the United Nations target of 3% by 2030.[^1] Recurring,
cross-border payouts are exactly the case where a per-second, auditable balance
beats a monthly batch.

## Why Stellar, specifically

The Stellar-specific reasons matter, not generic "blockchain is fast and cheap"
claims:

- **Settlement speed.** Stellar ledgers close every few seconds, so a
  withdrawal is confirmed while the user is still looking at the screen. A
  streaming UI that updates at 60 frames per second is pointless if the
  withdrawal takes a minute.
- **Predictable, sub-cent fees.** A stream can be withdrawn frequently. If each
  withdrawal cost dollars, recipients would batch them and the "stream" would
  collapse back into lump sums.
- **Soroban.** The accrual rule itself lives on-chain. The contract computes
  the earned amount from the ledger timestamp, so the number is authoritative
  and does not depend on a server the recipient has to trust.
- **Stellar Asset Contract (SAC).** Native XLM and any Stellar-issued asset can
  be streamed through the same code path, because the contract treats the token
  as any other token contract.
- **Network reliability.** Stellar reported **3.6 billion transactions in 2025**
  and 99.99% uptime, with 21.5 billion lifetime operations.[^2]

## How it works, step by step

1. **Fund and open.** A sender calls `create_stream` with the recipient, the
   token, the deposit, the start and stop times, and whether the stream is
   cancellable. The contract transfers the deposit from the sender into itself
   and stores a `Stream` record. It returns a stream id.
2. **Accrue.** From `start_time`, the contract computes earned amount as
   `deposit_amount × elapsed ÷ duration` using the current ledger timestamp.
   Nothing is stored per second — the balance is derived, so it never drifts.
3. **Withdraw.** The recipient calls `withdraw` for any amount up to what has
   accrued and not yet been taken. The contract pays it out and keeps the stream
   running.
4. **Optionally cancel.** If the stream is cancellable, the sender can call
   `cancel` before it ends. The recipient immediately receives everything
   already earned; the sender is refunded the rest.
5. **Complete.** At `stop_time` the recipient has earned the full deposit and
   can withdraw the remainder at any point.

## What is in this repository

- **`packages/sdk`** — a typed TypeScript client over the contract: it builds
  and simulates transactions, encodes arguments to XDR, parses return values,
  and mirrors the on-chain integer math for live UI counters.
- **`indexer`** — a long-running service that subscribes to the contract's
  events over Soroban RPC and exposes them over a small REST API, so the
  frontend can list streams without scanning every id on-chain.
- **`apps/web`** — the Next.js frontend: a dashboard, a stream-creation form, a
  detailed stream page with a live balance visualizer, and Freighter wallet
  integration for signing.

The Soroban contract itself is specified and documented in
[stellar-stream-contract](https://github.com/Deyanju23/stellar-stream-contract).
This site restates its interface in
[Contract reference](contract-reference.md) so you do not have to cross-reference
repositories.

[^1]: World Bank — [Remittance Prices Worldwide](https://remittanceprices.worldbank.org/) (average cost 6.36% in Q3 2025) and [Migration Data Portal](https://www.migrationdataportal.org/themes/remittances-overview) (global flows $865B → $905B, 2023 → 2024), citing World Bank *Migration and Development Brief*.
[^2]: Stellar — [End of Year 2025 Report: Execution at Scale](https://stellar.org/blog/foundation-news/2025-year-in-review).
