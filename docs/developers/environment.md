# Environment variables

Every value the application layer reads, where it is used, and what it defaults
to. Values marked **populated post-deploy** come from the contracts repository's
deploy output.

## Frontend — `apps/web/.env.local`

All frontend variables are prefixed `NEXT_PUBLIC_` and are **inlined at build
time**. Set them in your hosting platform and rebuild after any change.

| Variable | Required | Default (testnet) | Purpose |
| --- | --- | --- | --- |
| `NEXT_PUBLIC_STELLAR_NETWORK_PASSPHRASE` | yes | `Test SDF Network ; September 2015` | Network the app signs for |
| `NEXT_PUBLIC_SOROBAN_RPC_URL` | yes | `https://soroban-testnet.stellar.org` | Soroban RPC endpoint |
| `NEXT_PUBLIC_STREAM_CONTRACT_ID` | yes | *(none)* | Deployed `stream` contract id (`C...`) |
| `NEXT_PUBLIC_INDEXER_URL` | yes | `http://localhost:3001` | Indexer REST base URL |
| `NEXT_PUBLIC_DEFAULT_TOKEN_ADDRESS` | no | native XLM SAC `CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC` | Token pre-filled in the create form |

!!! warning "`NEXT_PUBLIC_DEFAULT_TOKEN_ADDRESS` is not the stream contract"
    `CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC` is the native XLM
    Stellar Asset Contract. It is the *token* being streamed by default, not the
    StellarStream contract. The stream contract id goes in
    `NEXT_PUBLIC_STREAM_CONTRACT_ID`.

## Indexer — `indexer/.env`

| Variable | Required | Default | Purpose |
| --- | --- | --- | --- |
| `PORT` | no | `3001` | REST API port |
| `SOROBAN_RPC_URL` | yes | `https://soroban-testnet.stellar.org` | Soroban RPC endpoint |
| `STELLAR_NETWORK_PASSPHRASE` | yes | `Test SDF Network ; September 2015` | Network passphrase |
| `STREAM_CONTRACT_ID` | yes | *(none)* | Contract to index (`C...`) |
| `START_LEDGER` | no | `0` | First ledger to scan when no cursor is stored |
| `DB_PATH` | no | `stellar_stream.sqlite` | SQLite file path |

`STREAM_CONTRACT_ID` must match `NEXT_PUBLIC_STREAM_CONTRACT_ID` for the same
network. If it is empty the indexer waits and re-reads the environment each poll
cycle rather than scanning the wrong contract.

## Contract deployment output

The contracts repo prints these at the end of a deploy:

```text
STREAM_CONTRACT_ID=C...
VITE_STREAM_CONTRACT_ID=C...
```

Use `STREAM_CONTRACT_ID` for both `NEXT_PUBLIC_STREAM_CONTRACT_ID`
(frontend) and `STREAM_CONTRACT_ID` (indexer). The `VITE_` alias is for other
frontends and is not read by this repo.

## Example files

- `apps/web/.env.example`
- `indexer/.env.example`

Never commit a real `.env` or `.env.local`; both are git-ignored.
