# Sending a stream

This guide is for the person funding a stream — the sender. You need a Stellar
account and the [Freighter](https://www.freighter.app) browser extension set to
**testnet**.

## Before you start

- Install Freighter and create or import an account.
- Switch Freighter to **Testnet**.
- Fund the account. On testnet you can use
  [Friendbot](https://laboratory.stellar.org/#account-creator?network=testnet).

## Open the app

Go to the StellarStream web app and click **Connect Freighter** in the top-right
corner. Approve the connection in the extension. Your shortened address appears
in the header when you are connected.

## Create a stream

1. Click **Create Stream**.
2. **Recipient address** — paste the `G...` address that will receive the funds.
   The field turns green when it is a valid Stellar address.
3. **Token and amount** — leave **Native XLM** selected to stream XLM, or choose
   **Custom SAC** and paste a token contract address (`C...`). Enter the total
   deposit you want to lock.
4. **Schedule** — pick a duration from the presets (1 day to 1 year) and a start
   time (**Now**, +1 hour, or +1 day). The form shows the exact start and end
   timestamps.
5. **Cancelable** — leave the toggle **on** if you want the option to stop the
   stream early and reclaim the unearned part. Turn it **off** for an
   irrevocable stream the recipient can rely on completely.
6. Check the **Computed Flow Rate** preview — that is the amount unlocking every
   second.
7. Click the **Stream … XLM** button. Freighter asks you to sign; approve it.

The transaction is submitted to Soroban testnet. When it confirms, you get a
success banner with a link to the transaction on Stellar.Expert and a button to
open the new stream.

!!! note "What just happened"
    Your deposit was transferred from your account into the stream contract in
    a single transaction. From the start time, the balance accrues continuously
    to the recipient.

## Track your streams

The dashboard has three views:

- **Outgoing (Created)** — streams you funded.
- **Incoming (Received)** — streams paid to you.
- **Explore All** — every stream the indexer has seen.

Filter by status (**All / Active / Completed / Canceled**) or search by stream
id or address. Each card shows the live accrued amount, the rate, and the time
remaining.

Click any card to open the stream detail page.

## Cancel a stream

1. Open the stream from the dashboard.
2. In the **Stream Management** panel, click **Cancel Stream & Settle Payouts**.
3. Review the confirmation dialog. It shows exactly what the recipient will
   receive (everything earned so far) and what you get back (the rest).
4. Confirm and sign in Freighter.

Cancellation is immediate and final. The recipient is paid what they earned;
you are refunded the unearned remainder. You cannot cancel a stream that is
already completed or was created as irrevocable.

## What it costs

- One Stellar network fee per transaction (create, withdraw, or cancel) — a
  fraction of a cent on testnet.
- The deposit itself, which is locked in the contract until it accrues to the
  recipient or you cancel.

There is no protocol fee.

## Tips

- **Double-check the recipient address.** Funds accrue to whoever you name; the
  contract cannot redirect them.
- **Use a future start time** for vesting that begins on a cliff date.
- **Keep streams cancelable** unless the recipient's certainty is the point —
  for example, a settlement where they need an unconditional guarantee.
- **Long streams are fine.** The balance is derived from the clock, so a
  one-year stream costs the same to create as a one-day stream.
