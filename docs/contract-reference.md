# Contract reference

The `stream` contract has a single responsibility: custody and linear accrual of
a timed token deposit. It is one contract, written in Rust with
`soroban-sdk` 28.x for target `wasm32v1-none`, and it is **immutable once
deployed**.

This page restates the public interface so the app team does not need to
cross-reference the contracts repository. The authoritative version is
[`docs/CONTRACT_SPEC.md`](https://github.com/Deyanju23/stellar-stream-contract/blob/main/docs/CONTRACT_SPEC.md).

## Storage

| Key | Storage class | Meaning |
| --- | --- | --- |
| `Admin` | instance | The address set at initialization |
| `NextStreamId` | instance | Monotonic counter for stream ids |
| `Stream(u64)` | persistent | One `Stream` struct per id |

Instance entries share the contract instance's TTL. Persistent entries carry
their own TTL and are extended on every access.

## Errors

All state-changing functions return `Result<T, StreamError>`.

| Code | Variant | Raised when |
| --- | --- | --- |
| 1 | `NotInitialized` | Admin read before `init` |
| 2 | `AlreadyInitialized` | `init` called twice |
| 3 | `Unauthorized` | Caller is neither recipient nor sender where required |
| 4 | `StreamNotFound` | No `Stream` under the given id |
| 5 | `StreamEnded` | Reserved |
| 6 | `StreamCanceled` | Operation on an already-cancelled stream |
| 7 | `InvalidTimeRange` | `start_time >= stop_time` |
| 8 | `ZeroDeposit` | `deposit_amount <= 0` |
| 9 | `AmountMismatch` | Reserved |
| 10 | `WithdrawAmountTooHigh` | `amount > available` |
| 11 | `NotCancelable` | `cancel` on a stream with `cancelable = false` |
| 12 | `MathOverflow` | Any checked arithmetic overflows |

Codes are stable and part of the ABI.

## Events

Every state-changing function emits exactly one event.

| Event | Fields | Emitted by |
| --- | --- | --- |
| `StreamCreated` | `sender, recipient, stream_id, token, deposit_amount, start_time, stop_time` | `create_stream` |
| `TokensWithdrawn` | `recipient, stream_id, amount, remaining_balance` | `withdraw` |
| `StreamCanceled` | `stream_id, sender_refund, recipient_payout` | `cancel` |

## Functions

### `init(admin: Address) -> Result<(), StreamError>`

- **Auth:** `admin.require_auth()`.
- **Effect:** stores `Admin`, sets `NextStreamId = 0`. Fails with
  `AlreadyInitialized` if admin is already set.
- **Events:** none. **Called once** after deployment.

### `create_stream(...) -> Result<u64, StreamError>`

```rust
create_stream(
    sender: Address,
    recipient: Address,
    token_addr: Address,
    deposit_amount: i128,
    start_time: u64,
    stop_time: u64,
    cancelable: bool,
) -> u64
```

- **Auth:** `sender.require_auth()`.
- **Validation:** `deposit_amount > 0` (else `ZeroDeposit`);
  `start_time < stop_time` (else `InvalidTimeRange`).
- **Effect:** transfers the deposit from `sender` to the contract, assigns the
  next id, stores the `Stream`, increments `NextStreamId`. Returns the new id.
- **Events:** `StreamCreated`.
- **Notes:** `start_time` may be in the past, so retroactive vesting is allowed.

### `balance_of(stream_id: u64, target: Address) -> Result<i128, StreamError>`

- **Auth:** none — read-only.
- **Returns:** for `recipient`, `earned - recipient_withdrawn`; for `sender`,
  `deposit_amount - earned`. Any other address returns `Unauthorized`.
- **Failure:** `StreamNotFound`; `StreamCanceled` if the stream was cancelled.
- **Side effect:** extends the persistent TTL of the stream entry.

### `get_stream(stream_id: u64) -> Result<Stream, StreamError>`

- **Auth:** none.
- **Returns:** the full `Stream` struct. Extends the persistent TTL.

### `withdraw(stream_id: u64, amount: i128) -> Result<(), StreamError>`

- **Auth:** `recipient.require_auth()`.
- **Validation:** `amount <= earned - recipient_withdrawn` (else
  `WithdrawAmountTooHigh`); `StreamCanceled` if already cancelled;
  `StreamNotFound` if missing.
- **Effect:** increments `recipient_withdrawn`, decrements `remaining_balance`,
  transfers `amount` from the contract to the recipient. State is written before
  the transfer (checks-effects-interactions).
- **Events:** `TokensWithdrawn`.

### `cancel(stream_id: u64) -> Result<(), StreamError>`

- **Auth:** `sender.require_auth()`.
- **Validation:** `cancelable` must be `true` (else `NotCancelable`); not
  already cancelled (else `StreamCanceled`).
- **Effect:** computes `earned`, pays the recipient
  `earned - recipient_withdrawn`, refunds the sender `deposit_amount - earned`,
  sets `is_canceled = true` and `remaining_balance = 0`.
- **Events:** `StreamCanceled`.

## Calling the contract from the app

The SDK builds and simulates these calls. You rarely hand-roll XDR:

```ts
import { StellarStreamClient } from '@stellar-stream/sdk';

const client = new StellarStreamClient({
  rpcUrl: 'https://soroban-testnet.stellar.org',
  networkPassphrase: 'Test SDF Network ; September 2015',
  contractId: process.env.STREAM_CONTRACT_ID!,
});

// Read
const stream = await client.getStream(0n);
const claimable = await client.balanceOf(0n, recipient);

// Write (returns an unsigned, prepared transaction to sign and submit)
const tx = await client.createStreamTx({ /* ... */ });
```

See the [SDK reference](developers/sdk.md) for every method.

## Invariants

1. `contract token balance >= Σ remaining_balance` over all live streams.
2. For any live stream and timestamp,
   `balance_of(recipient) + balance_of(sender) == deposit_amount`.
3. `earned` is non-decreasing and equals `deposit_amount` at `stop_time` and
   after.
4. `recipient_withdrawn` never exceeds `earned`.
5. After `cancel` or a full withdrawal, the contract holds 0 tokens for that
   stream.
