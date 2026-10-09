# Receiving a stream

This guide is for the person a stream pays — the recipient. You need the address
the sender named and the [Freighter](https://www.freighter.app) extension set to
**testnet**.

## Find your streams

1. Open the StellarStream web app and click **Connect Freighter**.
2. Switch to the **Incoming (Received)** tab. Every stream directed at your
   address that the indexer has seen is listed there.
3. Click a stream to open its detail page.

If you know the stream id, you can also open it directly from the dashboard —
the detail page falls back to an on-chain query if the indexer has not seen it.

## Read your balance

The stream detail page is dominated by the live balance panel. It updates about
60 times a second and shows:

- **Earned** — everything that has accrued to you since the start time.
- **Claimable** — what you can withdraw right now (earned minus anything you
  have already withdrawn).
- **Progress** — how far through the stream you are, as a percentage and a
  countdown to the end.

These numbers come from the same integer arithmetic the contract uses, so they
match what `withdraw` will actually pay. The panel is a display convenience;
the contract is always the source of truth.

## Withdraw

You can withdraw any amount up to the claimable balance, at any time, as often
as you like. There is no penalty for withdrawing early or in pieces.

1. In the **Withdraw Claimable Tokens** panel, enter an amount or click **MAX**
   to take everything available.
2. Click **Withdraw … XLM**. Freighter asks you to sign; approve it.
3. On confirmation, the tokens land in your wallet and the panel updates to
   reflect the withdrawal.

The stream keeps running after a withdrawal — the remaining deposit continues to
accrue until the stop time.

!!! tip "Withdraw or leave it?"
    Withdrawing only moves funds that have already accrued to you; it does not
    slow the stream. Withdraw whenever you want the tokens, or leave them until
    the end. Nothing is lost either way.

## If the sender cancels

If the stream was created as cancelable, the sender can stop it early. When that
happens:

- You are paid everything you had earned but not yet withdrawn, immediately.
- You receive nothing further, because the stream has ended.

You do not need to do anything to receive that final payout — it is sent to you
as part of the cancellation. The stream page shows a **Canceled** status and the
settlement appears in the stream's event history.

## If the stream was irrevocable

Some streams are created with cancellation disabled. For these, the full deposit
is guaranteed to accrue to you over the duration; no one can stop or refund it.

## Verifying a transaction

Every action you take produces a transaction. The app links to
[Stellar.Expert](https://stellar.expert/explorer/testnet) so you can inspect the
transaction and the contract's events independently. The stream's on-chain
history is reconstructed from the contract's `StreamCreated`,
`TokensWithdrawn`, and `StreamCanceled` events.

## Troubleshooting

- **Nothing appears in Incoming.** Confirm Freighter is on testnet, then use the
  refresh button. If the indexer is down, open the stream by id — the page
  queries the chain directly.
- **"Connected Wallet is Not Recipient".** The stream pays a different address
  than the one Freighter currently has selected. Switch accounts in Freighter.
- **Withdraw is disabled.** Your claimable balance is 0 (the stream has not
  started, has completed, or was fully withdrawn).
