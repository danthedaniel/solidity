Outgoing
===

This smart contract allows multiple addresses to withdraw ETH from the
contract periodically.

This could be used for any type of periodic payment system, like

* Netflix Subscriptions
* Twitch Subscriptions (with one per each streamer)
* Patreon Donations

# Setup

The contract owner can create and over-write a subscription, with one
subscription per receiving address. Each subscription specifies a
recipient, amount per payment cycle, and a payment cycle duration. The
duration of a subscription period and amount given must both be greater
than 0.

# Locking/Freezing

Using the `lock()` and `activate()` functions, the owner of the contract
can choose to completely disable subscription payouts and subsequently
re-enable the contract.

The `freezeSubscription()` and `thawSubscription()` functions disable or
enable specific subscriptions from being able to pay out.

# Subscription Payout

A recipient of a subscription fee may either call `payout()` to receive
whatever amount the subscription has stored as its payout amount, or
they may alternatively utilize the `payoutFixed(uint expectedAmount)`
function to only have ETH sent if the subscription is set to pay out
exactly the amount specified by `expectedAmount`.
