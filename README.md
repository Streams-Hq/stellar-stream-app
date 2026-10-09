<div align="center">

# StellarStream App

**The application layer for continuous, linear payment streams on Stellar — built with Soroban.**

A sender locks a deposit that unlocks to the recipient every second. This repo holds the web app, the TypeScript SDK, and the event indexer.

[![CI](https://github.com/Deyanju23/stellar-stream-app/actions/workflows/ci.yml/badge.svg)](https://github.com/Deyanju23/stellar-stream-app/actions/workflows/ci.yml)
[![Docs](https://github.com/Deyanju23/stellar-stream-app/actions/workflows/docs.yml/badge.svg)](https://deyanju23.github.io/stellar-stream-app/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Next.js](https://img.shields.io/badge/Next.js-14-black.svg)](https://nextjs.org/)
[![pnpm](https://img.shields.io/badge/pnpm-10.30.1-orange.svg)](https://pnpm.io/)
[![Stellar](https://img.shields.io/badge/Stellar-7B3FE4.svg)](https://www.drips.network/wave/stellar)

**[Documentation](https://deyanju23.github.io/stellar-stream-app/)** · **[Contracts repo](https://github.com/Deyanju23/stellar-stream-contract)**

</div>

StellarStream is a protocol for streaming payments on Stellar. A sender locks a token deposit into a Soroban contract together with a start and stop time. From that point the balance accrues to the recipient continuously, and the recipient can withdraw whatever has accrued at any moment. If the stream is cancellable, the sender can stop it early — the recipient keeps everything already earned and the sender is refunded the rest.

This repository holds the application layer. The Soroban contracts live in a separate repository: [Deyanju23/stellar-stream-contract](https://github.com/Deyanju23/stellar-stream-contract).

## Why

Recurring payouts on a blockchain are usually either lump-sum transfers or off-chain bookkeeping. Neither is transparent to the party receiving the money. Streaming makes the balance visible and claimable at every second, which fits salary, vesting, subscriptions, and grant disbursement. Stellar is a good fit because transfers settle in seconds and cost a fraction of a cent, and Soroban lets the accrual rule live on-chain instead of in a spreadsheet.

## Architecture

This pnpm workspaces monorepo contains three packages plus the documentation site.

```
stellar-stream-app/
├── apps/
│   └── web/                  # Next.js 14 App Router frontend (Tailwind)
│       └── src/
│           ├── app/          # Dashboard, create-stream, and stream/[id] pages
│           ├── components/   # Navbar, WalletButton, StreamCard, StreamVisualizer
│           ├── hooks/        # useFreighter (wallet), useStreamBalance (60fps)
│           └── lib/          # config + Soroban/RPC helper functions
├── packages/
│   └── sdk/                  # @stellar-stream/sdk — typed client over the contract
│       └── src/
│           ├── client.ts     # Build/simulate create, withdraw, cancel, get, balance
│           ├── xdr.ts        # ScVal ↔ native XDR conversion
│           ├── math.ts       # Integer-exact live-balance calculator
│           └── types.ts      # Domain types and event shapes
├── indexer/                  # Soroban event indexer + REST API
│   └── src/
│       ├── indexer.ts        # Polls Soroban RPC for contract events
│       ├── db.ts             # SQLite schema (streams + events)
│       └── server.ts         # Express REST API
├── docs/                     # Documentation site source (MkDocs Material)
├── scripts/                  # Issue backlog + branch-protection helpers
└── mkdocs.yml                # GitHub Pages docs config
```

- **`packages/sdk`** — TypeScript SDK for the `stream` contract: typed clients, XDR argument encoders, a Soroban return-value parser, and a 60fps high-frequency balance calculator that mirrors the on-chain integer math exactly.
- **`indexer`** — Long-running service that polls Soroban RPC for `StreamCreated`, `TokensWithdrawn`, and `StreamCanceled` events, persists them to SQLite, and serves them over REST.
- **`apps/web`** — Next.js frontend with a live stream visualizer (7 decimal places at 60fps), Freighter wallet integration, stream creation, withdrawal, and cancellation.

## Documentation

Full documentation — protocol mechanics, contract reference, end-user guides, and the developer guide — is published at:

**https://deyanju23.github.io/stellar-stream-app/**

The source lives in [`docs/`](./docs) and is built with MkDocs Material and deployed to GitHub Pages by [`.github/workflows/docs.yml`](./.github/workflows/docs.yml).

## Maintainers

| Name | Role | Contact |
| --- | --- | --- |
| Deyanju23 | Maintainer | GitHub [@Deyanju23](https://github.com/Deyanju23) |

## Community

Questions, ideas, and Wave discussion happen in the project's GitHub [Discussions](https://github.com/Deyanju23/stellar-stream-app/discussions) and [Issues](https://github.com/Deyanju23/stellar-stream-app/issues). For anything security-related, read [`SECURITY.md`](./SECURITY.md) first.

## Network & configuration

| Variable | Purpose | Testnet default |
| --- | --- | --- |
| `NEXT_PUBLIC_STELLAR_NETWORK_PASSPHRASE` | Network passphrase | `Test SDF Network ; September 2015` |
| `NEXT_PUBLIC_SOROBAN_RPC_URL` | Soroban RPC endpoint | `https://soroban-testnet.stellar.org` |
| `NEXT_PUBLIC_STREAM_CONTRACT_ID` | Deployed `stream` contract (`C...`) | *(populated after deploy)* |
| `NEXT_PUBLIC_INDEXER_URL` | Indexer REST base URL | `http://localhost:3001` |
| `NEXT_PUBLIC_DEFAULT_TOKEN_ADDRESS` | Default token (native XLM SAC) | `CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC` |

The native XLM Stellar Asset Contract (SAC) address is the token used by default; it is **not** the stream contract address. `NEXT_PUBLIC_STREAM_CONTRACT_ID` is filled in from the contracts repo's deploy output. See the [deployment guide](https://deyanju23.github.io/stellar-stream-app/developers/local-setup/) for details.

## Quick start

Prerequisites: Node.js 20+ and pnpm 10.

```bash
git clone https://github.com/Deyanju23/stellar-stream-app.git
cd stellar-stream-app
pnpm install

pnpm build   # build every package
pnpm test    # run the SDK unit tests
pnpm dev     # start the web app (3000), indexer (3001) and SDK watcher
```

To run the pieces separately:

```bash
pnpm --filter @stellar-stream/sdk build
pnpm --filter indexer dev          # indexer + REST API on :3001
pnpm --filter web dev              # frontend on :3000
```

Copy the example environment files before starting the app and indexer:

```bash
cp apps/web/.env.example apps/web/.env.local
cp indexer/.env.example indexer/.env
```

## Contributing

Read [`CONTRIBUTING.md`](./CONTRIBUTING.md). Issues labelled `good first issue` are the best entry points. One logical change per pull request, Conventional Commits, green CI, one maintainer review.

## License

MIT — see [`LICENSE`](./LICENSE).

## Contributors

Thanks to everyone who has contributed.

<a href="https://github.com/Deyanju23/stellar-stream-app/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Deyanju23/stellar-stream-app" alt="Contributors" />
</a>
