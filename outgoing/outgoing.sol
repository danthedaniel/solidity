pragma solidity ^0.4.0;

/// @title Outgoing Payments
/// @author teaearlgraycold
contract Outgoing {
    struct Subscription {
        uint amount;     // Amount of ETH to send per cycle
        uint renewTime;  // Next time the subscription can be called on
        uint interval;   // Minimum time for which a subscription can be paid out
        SubState state;
    }
    
    enum SubState { Active, Inactive }
    enum State { Active, Locked }
    
    mapping (address => Subscription ) public subscriptions;
    State private state;
    address public owner;
    
    modifier inState(State _state) {
        if (state != _state) revert();
        _;
    }

    modifier isOwner() {
        if (msg.sender != owner) revert();
        _;
    }
    
    function Outgoing() {
        owner = msg.sender;
        state = State.Active;
    }
    
    function() {
        revert();
    }
    
    // Add or modify an existing subscription
    function subscribe(address recipient, uint amount, uint interval) public isOwner {
        // Subscription time interval must be non-zero
        require(interval >= 0);
        require(amount >= 0);
        
        subscriptions[recipient] = Subscription({
            amount: amount,
            renewTime: block.timestamp,
            interval: interval,
            state: SubState.Active
        });
    }
    
    // Lock the contract, preventing any subscriptions from being sent out
    function lock() public isOwner {
        state = State.Locked;
    }
    
    // Activate the contract, allowing subscriptions to be sent out
    function activate() public isOwner {
        state = State.Active;
    }
    
    // Freeze a single subscription, preventing it from being sent out
    function freezeSubscription(address recipient) public isOwner inState(State.Active) {
        subscriptions[recipient].state = SubState.Inactive;
    }
    
    // Un-freezing a single subscription, preventing it from being sent out
    function thawSubscription(address recipient) public isOwner inState(State.Active) {
        subscriptions[recipient].state = SubState.Active;
    }
    
    // Send payment to the subscription recipient, and also check that a
    // specific amount will be transferred.
    function payoutFixed(uint expectedAmount) public inState(State.Active) {
        require(subscriptions[msg.sender].amount == expectedAmount);

        payout();
    }
    
    // Send payment to the subscription recipient, only if at least a specified
    // amount will be sent.
    function payoutMin(uint minAmount) public inState(State.Active) {
        require(subscriptions[msg.sender].amount >= minAmount);

        payout();
    }
    
    function payout() private inState(State.Active) {
        require(subscriptions[msg.sender].state == SubState.Active);
        require(subscriptions[msg.sender].renewTime <= block.timestamp);

        subscriptions[msg.sender].renewTime = block.timestamp + subscriptions[msg.sender].interval;
        msg.sender.transfer(subscriptions[msg.sender].amount);
    }
}
