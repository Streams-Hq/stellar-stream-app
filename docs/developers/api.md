# Indexer API

The indexer subscribes to the `stream` contract's events over Soroban RPC,
persists them to SQLite, and serves a small read-only REST API on port
`3001` by default.

Base URL: `NEXT_PUBLIC_INDEXER_URL` (local: `http://localhost:3001`).

The indexer is a cache. If it is unreachable, the app falls back to querying the
chain directly for a single stream by id — it never treats the cache as final.

## `GET /health`

Liveness and sync position.

```json
{
  "status": "ok",
  "service": "stellar-stream-indexer",
  "lastLedger": 1234567,
  "timestamp": "2026-01-01T00:00:00.000Z"
}
```

## `GET /api/streams`

List streams, newest first.

| Query param | Type | Default | Notes |
| --- | --- | --- | --- |
| `limit` | integer | 50 | clamped to 1–100 |
| `offset` | integer | 0 | |

```json
{
  "streams": [ /* StreamRecord[] */ ],
  "limit": 50,
  "offset": 0
}
```

## `GET /api/streams/{id}`

One stream by id.

```json
{
  "stream": {
    "id": 0,
    "sender": "G...",
    "recipient": "G...",
    "token": "CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC",
    "deposit_amount": "10000000000",
    "start_time": 1735689600,
    "stop_time": 1738281600,
    "rate_per_second": "3858",
    "remaining_balance": "10000000000",
    "recipient_withdrawn": "0",
    "is_canceled": 0,
    "cancelable": 1,
    "created_at": 1735689600,
    "updated_at": 1735689600
  }
}
```

Errors: `400` for a non-numeric id, `404` if the stream is unknown.

## `GET /api/streams/sender/{address}`

All streams created by an address, newest first.

```json
{ "streams": [ /* StreamRecord[] */ ] }
```

## `GET /api/streams/recipient/{address}`

All streams paid to an address, newest first.

```json
{ "streams": [ /* StreamRecord[] */ ] }
```

## `GET /api/events/{streamId}`

The full event history for a stream, oldest first — the audit trail.

```json
{
  "events": [
    {
      "id": 1,
      "stream_id": 0,
      "event_type": "StreamCreated",
      "ledger": 1234500,
      "ledger_closed_at": "2026-01-01T00:00:05Z",
      "data": { "sender": "G...", "recipient": "G...", "stream_id": 0 },
      "tx_hash": "ab12…",
      "created_at": 1735689605
    }
  ]
}
```

`event_type` is one of `StreamCreated`, `TokensWithdrawn`, or `StreamCanceled`.

## `StreamRecord`

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | number | Stream id |
| `sender` / `recipient` | string | Stellar addresses |
| `token` | string | Token contract id |
| `deposit_amount` | string | Base units, as a decimal string |
| `start_time` / `stop_time` | number | Unix seconds |
| `rate_per_second` | string | `deposit_amount ÷ duration` |
| `remaining_balance` | string | Tokens still held for this stream |
| `recipient_withdrawn` | string | Cumulative withdrawn |
| `is_canceled` | number | `0` or `1` |
| `cancelable` | number | `0` or `1` |
| `created_at` / `updated_at` | number | Unix seconds the row was written |

!!! note "Amounts are strings, not numbers"
    `deposit_amount`, `rate_per_second`, `remaining_balance`, and
    `recipient_withdrawn` are `i128` values stored as decimal strings so no
    precision is lost in JSON. Parse them with `BigInt(...)`.

## Running it

```bash
pnpm --filter indexer dev     # tsx watch, port 3001
pnpm --filter indexer build && pnpm --filter indexer start   # production
```

Required env: `STREAM_CONTRACT_ID`, `SOROBAN_RPC_URL`. See
[Environment variables](environment.md).
