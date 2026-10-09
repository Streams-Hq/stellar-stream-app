# StellarStream

**Continuous, linear payment streams on Stellar.**

A sender locks a token deposit into a Soroban contract together with a start and
stop time. From that point the balance accrues to the recipient every second,
and the recipient can withdraw whatever has accrued at any moment.

StellarStream is two repositories:

- **[stellar-stream-contract](https://github.com/Deyanju23/stellar-stream-contract)** —
  the Soroban contract that custodies the deposit and enforces the accrual rule.
- **stellar-stream-app** (this documentation) — the Next.js web app, the
  TypeScript SDK, and the event indexer.

## Where to start

<div class="grid cards" markdown>

- **New to the idea?** Read [Introduction](introduction.md) for the problem and
  how the protocol solves it.
- **Want the mechanics?** Read [How streaming works](protocol-mechanics.md) for
  the lifecycle and the arithmetic, with worked numbers.
- **Using the app?** Jump to the guides for
  [senders](guides/sender.md) and [recipients](guides/recipient.md).
- **Building on it?** Start with [Local setup](developers/local-setup.md), then
  the [SDK reference](developers/sdk.md) and the
  [Indexer API](developers/api.md).

</div>

## At a glance

| | |
| --- | --- |
| Network | Stellar testnet |
| Contract | [`stellar-stream-contract`](https://github.com/Deyanju23/stellar-stream-contract) (`stream`, Rust/Soroban) |
| Frontend | Next.js 14 (App Router), Tailwind CSS |
| SDK | [`@stellar-stream/sdk`](developers/sdk.md) (TypeScript) |
| Indexer | Node.js + Express + SQLite |
| Wallet | [Freighter](https://www.freighter.app) |
| Audit status | **Unaudited, testnet only** — see the [security policy](https://github.com/Deyanju23/stellar-stream-app/blob/main/SECURITY.md) |

!!! warning "Testnet software"
    Both the contracts and this application are unaudited and run on Stellar
    testnet. Do not use them to custody funds of significant value.
