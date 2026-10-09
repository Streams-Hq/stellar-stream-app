# SDK reference

`@stellar-stream/sdk` is the typed TypeScript client for the `stream` contract.
It builds and simulates transactions, encodes arguments to XDR, parses return
values, and mirrors the on-chain integer math for live UI counters.

```bash
pnpm --filter @stellar-stream/sdk build
```

## Setup

```ts
import { StellarStreamClient } from '@stellar-stream/sdk';

const client = new StellarStreamClient({
  rpcUrl: 'https://soroban-testnet.stellar.org',
  networkPassphrase: 'Test SDF Network ; September 2015',
  contractId: process.env.STREAM_CONTRACT_ID!,
});
```

`ClientConfig`

| Field | Type |
| --- | --- |
| `rpcUrl` | `string` |
| `networkPassphrase` | `string` |
| `contractId` | `string` |

## Reads

### `getStream(streamId: bigint): Promise<Stream>`

Simulates `get_stream(stream_id)` and parses the result into a `Stream`.

```ts
const stream = await client.getStream(0n);
console.log(stream.sender, stream.depositAmount, stream.stopTime);
```

Throws if the simulation fails or the contract returns an empty result.

### `balanceOf(streamId: bigint, target: string): Promise<bigint>`

Simulates `balance_of(stream_id, target)` and returns the raw `i128` amount —
claimable for the recipient, refundable for the sender.

```ts
const claimable = await client.balanceOf(0n, recipientAddress);
```

Reads use a fixed dummy source account with fee `100`, so they need no wallet.

## Writes

Write methods return an **unsigned, prepared transaction** for the caller's
wallet to sign. They do not sign or submit.

### `createStreamTx(params: CreateStreamParams): Promise<Transaction>`

Builds and prepares `create_stream`.

```ts
const tx = await client.createStreamTx({
  sender: 'G...',
  recipient: 'G...',
  token: 'CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC',
  depositAmount: 1_000_000_000n,          // 100 XLM in stroops
  startTime: BigInt(Math.floor(Date.now() / 1000)),
  stopTime: BigInt(Math.floor(Date.now() / 1000) + 86_400 * 30),
  cancelable: true,
});

const signed = await wallet.signTransaction(tx.toXDR(), {
  networkPassphrase: 'Test SDF Network ; September 2015',
});
```

### `withdrawTx(params: WithdrawParams): Promise<Transaction>`

Builds and prepares `withdraw`.

```ts
const tx = await client.withdrawTx({
  streamId: 0n,
  amount: 250_000_000n,                   // 25 XLM
  recipient: 'G...',
});
```

### `cancelTx(streamId: bigint, sender: string): Promise<Transaction>`

Builds and prepares `cancel`.

```ts
const tx = await client.cancelTx(0n, senderAddress);
```

## Submitting

The SDK stops at the prepared transaction. The app submits it and polls for the
result:

```ts
const send = await client.server.sendTransaction(signedTx);
const hash = send.hash;

for (let i = 0; i < 15; i++) {
  await new Promise((r) => setTimeout(r, 2000));
  const status = await client.server.getTransaction(hash);
  if (status.status === 'SUCCESS') break;
  if (status.status === 'FAILED') throw new Error('Transaction failed on-chain');
}
```

## Types

```ts
interface Stream {
  id: bigint;
  sender: string;
  recipient: string;
  token: string;
  depositAmount: bigint;
  startTime: bigint;
  stopTime: bigint;
  ratePerSecond: bigint;
  remainingBalance: bigint;
  recipientWithdrawn: bigint;
  isCanceled: boolean;
  cancelable: boolean;
}

interface LiveBalance {
  recipientEarned: bigint;
  recipientClaimable: bigint;
  senderRefundable: bigint;
  progressFraction: number;   // 0..1
}
```

Also exported: `CreateStreamParams`, `WithdrawParams`, `CancelParams`,
`ClientConfig`, and the event shapes `StreamCreatedEvent`, `TokensWithdrawnEvent`,
`StreamCanceledEvent`, and the `StreamEvent` union.

## Live-balance math

These mirror the on-chain integer arithmetic exactly, so a UI counter never
disagrees with `withdraw`.

### `computeEarned(stream, currentTimestamp): bigint`

```ts
computeEarned(stream, now)   // deposit_amount * elapsed / duration, truncated
```

### `calculateLiveBalance(stream, currentTimestamp): LiveBalance`

Returns earned, claimable (earned − withdrawn), and refundable
(deposit − earned) in one call. A cancelled stream returns its settled values.

### Formatting helpers

```ts
formatUnits(1234567890n, 7);        // "123.4567890"
parseUnits('123.4567890', 7);       // 1234567890n
formatRatePerSecond(10_000_000_000n, 1000n, 7);  // "1.0000000"
```

`formatUnits` / `parseUnits` use 7 decimals by default — the precision of XLM
and the default for the app.

## XDR helpers

For advanced callers who build operations themselves:

| Function | Purpose |
| --- | --- |
| `addressToScVal(address)` | `G...`/`C...` → Address ScVal |
| `u64ToScVal(value)` | integer → `u64` ScVal |
| `i128ToScVal(value)` | integer → `i128` ScVal |
| `boolToScVal(value)` | boolean → `bool` ScVal |
| `parseStreamScVal(val)` | raw ScVal or native map → typed `Stream` |

`parseStreamScVal` accepts both snake_case (`deposit_amount`) and camelCase
(`depositAmount`) keys, so it tolerates either representation from `scValToNative`.
