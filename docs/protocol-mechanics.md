# How streaming works

This page describes the state machine and the arithmetic of a stream. It is the
user-facing restatement of the contract; the authoritative specification is
[`docs/CONTRACT_SPEC.md`](https://github.com/Deyanju23/stellar-stream-contract/blob/main/docs/CONTRACT_SPEC.md).

## The stream object

A stream is one record in the contract:

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | `u64` | Stream identifier, assigned sequentially from 0 |
| `sender` | `Address` | Funded the stream; may cancel if allowed |
| `recipient` | `Address` | Accrues and withdraws |
| `token` | `Address` | Token contract (SAC or Soroban token) |
| `deposit_amount` | `i128` | Total locked at creation, in base units |
| `start_time` | `u64` | Unix seconds when accrual begins |
| `stop_time` | `u64` | Unix seconds when accrual completes |
| `rate_per_second` | `i128` | `deposit_amount ÷ duration` (informational) |
| `remaining_balance` | `i128` | Tokens still held by the contract for this stream |
| `recipient_withdrawn` | `i128` | Cumulative amount withdrawn by the recipient |
| `is_canceled` | `bool` | Set once cancellation completes |
| `cancelable` | `bool` | Whether the sender may cancel before `stop_time` |

Amounts are integers in the token's base unit. For XLM, 1 XLM is
`10,000,000` stroops (7 decimals). There is no floating point anywhere in the
protocol.

## The accrual rule

For the current ledger timestamp `t`:

```
elapsed = clamp(t - start_time, 0, duration)     where duration = stop_time - start_time
earned  = deposit_amount * elapsed / duration    // i128, integer division
```

Two properties follow directly:

- `earned` is **monotonic** — it never decreases as time passes.
- `earned` reaches exactly `deposit_amount` at `stop_time` and stays there.

Because `earned` is derived from the clock rather than stored per second, it
cannot drift. The only approximation is integer division, which truncates down
by at most **1 stroop (0.0000001 XLM)** over the life of a stream — and because
the sender's refund is computed as `deposit - earned`, the two always sum
exactly to the deposit.

## Lifecycle and state machine

```
                 create_stream
                       │
                       ▼
                ┌─────────────┐   t < start        ┌──────────────┐
                │ NOT_STARTED │ ─────────────────▶ │  (accruing)  │
                └─────────────┘                    └──────────────┘
                       │  t >= start                      │
                       ▼                                  │
                ┌─────────────┐   withdraw (any amount)    │
                │  STREAMING  │ ◀──────────────────────────┘
                └─────────────┘
                   │        │
        t >= stop  │        │  cancel (sender, cancelable only)
                   ▼        ▼
            ┌────────────┐ ┌────────────┐
            │ COMPLETED  │ │  CANCELED  │  (terminal)
            └────────────┘ └────────────┘
```

- **Not started** — before `start_time`, nothing has accrued. `balance_of`
  returns 0 for the recipient.
- **Streaming** — between `start_time` and `stop_time`. The recipient may
  withdraw any amount up to `earned - recipient_withdrawn` at any time.
- **Completed** — at or after `stop_time`. The recipient has earned the full
  deposit and may withdraw the remainder.
- **Canceled** — terminal. All outstanding amounts were settled at cancellation:
  the recipient was paid what they had earned but not yet withdrawn, and the
  sender was refunded the rest.

Cancellation is only possible when `cancelable = true` and the stream has not
already ended. An irrevocable stream (`cancelable = false`) cannot be stopped by
anyone.

## Worked example

Stream **1,000 XLM** over **30 days**, cancelable, starting now.

Let `deposit = 1,000 XLM = 10,000,000,000` stroops and
`duration = 30 days = 2,592,000` seconds.

- Rate: `10,000,000,000 ÷ 2,592,000 = 3,858` stroops/sec ≈
  **0.0003858 XLM/sec**.
- At **day 10** (`elapsed = 864,000` s):

  ```
  earned = 10,000,000,000 * 864,000 / 2,592,000
         = 3,333,333,333 stroops   (integer division)
         = 333.3333333 XLM
  ```

  This is one third of the deposit, exactly.

- At **day 15** (`elapsed = 1,296,000` s): `earned = 5,000,000,000` stroops =
  **500.0000000 XLM** — exactly half.

### Withdrawing part-way through

At day 10 the recipient withdraws **100 XLM**:

| Quantity | Value |
| --- | --- |
| Earned | 333.3333333 XLM |
| Already withdrawn | 100.0000000 XLM |
| Still claimable | 233.3333333 XLM |

The stream keeps running. At day 15 the recipient has earned 500 XLM and has
300 XLM claimable (500 − 200 withdrawn).

### Cancelling part-way through

Suppose at day 10 the recipient has withdrawn 100 XLM and the sender cancels.

| Recipient | | Sender | |
| --- | --- | --- | --- |
| Earned (payout) | 333.3333333 XLM | Refund (`deposit − earned`) | 666.6666667 XLM |
| Already withdrawn | 100.0000000 XLM | | |
| **Total received** | **433.3333333 XLM** | **Total received** | **666.6666667 XLM** |

`666.6666667 + 433.3333333 = 1,000.0000000 XLM`, the full deposit, with no
stroop lost. In raw integers: `6,666,666,667 + 3,333,333,333 = 10,000,000,000`.

## Invariants

These hold for every stream at every timestamp and are what the tests assert:

1. For a live stream: `balance_of(recipient) + balance_of(sender) == deposit_amount`.
2. `earned` is non-decreasing in time and equals `deposit_amount` at and after
   `stop_time`.
3. `recipient_withdrawn` never exceeds `earned`.
4. The contract's token balance is at least the sum of all live streams'
   `remaining_balance`.
5. After a cancellation or a full withdrawal, the contract holds 0 tokens for
   that stream.
