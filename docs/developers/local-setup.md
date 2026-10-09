# Local setup

This page gets the whole application layer — SDK, indexer, and web app — running
against Stellar testnet.

## Prerequisites

| Tool | Version | Notes |
| --- | --- | --- |
| Node.js | 20 or newer | testnet + build tooling |
| pnpm | 10.30.1 | the repo pins this via `packageManager` |
| Git | any recent | |
| Freighter | latest | browser extension, for wallet actions |

You also need the deployed `stream` contract id. If it has not been deployed
yet, see the
[contracts deployment guide](https://github.com/Deyanju23/stellar-stream-contract/blob/main/docs/DEPLOYMENT.md).

## Clone and install

```bash
git clone https://github.com/Deyanju23/stellar-stream-app.git
cd stellar-stream-app
pnpm install
```

## Configure environment variables

Copy the examples and fill in the contract id:

```bash
cp apps/web/.env.example apps/web/.env.local
cp indexer/.env.example indexer/.env
```

Set `NEXT_PUBLIC_STREAM_CONTRACT_ID` in `apps/web/.env.local` and
`STREAM_CONTRACT_ID` in `indexer/.env` to the **same** deployed contract id.
See [Environment variables](environment.md) for the full table.

## Run

Everything at once with Turborepo:

```bash
pnpm dev
```

This starts:

- the SDK in watch mode,
- the indexer and its REST API on `http://localhost:3001`,
- the web app on `http://localhost:3000`.

Or run pieces individually:

```bash
pnpm --filter @stellar-stream/sdk build
pnpm --filter indexer dev
pnpm --filter web dev
```

Open `http://localhost:3000`, connect Freighter on testnet, and create a stream.

## Build and test

```bash
pnpm build   # build all packages
pnpm test    # run the SDK unit tests
```

The SDK tests cover the accrual math and precision guarantees:

```bash
pnpm --filter @stellar-stream/sdk test
```

## Documentation site

The docs site is built with MkDocs Material:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements-docs.txt
mkdocs serve           # preview at http://127.0.0.1:8000
mkdocs build --strict  # what CI runs
```

## Deploying the app

The frontend is a standard Next.js app: set the `NEXT_PUBLIC_*` variables from
[Environment variables](environment.md) in your hosting platform and deploy.
The indexer is a long-running Node service with a SQLite database and needs a
host that keeps a process alive (for example Render or Fly.io); point
`NEXT_PUBLIC_INDEXER_URL` at its public URL.

!!! warning "Set variables at build time for the frontend"
    Next.js inlines `NEXT_PUBLIC_*` values during `next build`. Changing them
    after a build has no effect — set them before building, and rebuild after
    changing them.

## Troubleshooting

- **`command not found: pnpm`** — install it with `corepack enable` or
  `npm i -g pnpm@10.30.1`.
- **Web app shows "Stream Not Found"** — `NEXT_PUBLIC_STREAM_CONTRACT_ID` is
  empty or points at a different network than Freighter.
- **Indexer lists nothing** — the indexer starts from a recent ledger. Create a
  stream (or set `START_LEDGER` to an earlier ledger) and wait one poll cycle.
- **Indexer fails with "Could not locate the bindings file"** — pnpm 10 skips
  native build scripts by default, so `better-sqlite3` is not compiled. Run
  `pnpm approve-builds` and select `better-sqlite3`, or
  `pnpm rebuild better-sqlite3`.
- **Freighter rejects the network** — set the extension to testnet; the app
  signs with the `Test SDF Network ; September 2015` passphrase.
