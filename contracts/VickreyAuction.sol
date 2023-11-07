// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;

    // TODO: place your code here
    mapping(address => bytes32) public bidCommitments;
    mapping(address => bool) public revealedBids;
    uint public highestBid;
    uint public secondHighestBid;
    address public highestBidAddress;
    address public secondHighestBidAddress;

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount)
             Auction (_sellerAddress, _judgeAddress, address(0), 0) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;

        // TODO: place your code here
        highestBid = _minimumPrice;
        secondHighestBid = _minimumPrice;
        highestBidAddress = address(0x0);
        secondHighestBidAddress = address(0x0);
    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {

        // TODO: place your code here
        require(time() < biddingDeadline, "Bid commit period has ended.");
        require(msg.sender != sellerAddress, "Seller cannot bid.");

        if (bidCommitments[msg.sender] == 0) {
            require(msg.value == bidDepositAmount, "Incorrect bid deposit sent.");
        } else {
            require(msg.value == 0, "Commit updates should not include deposit.");
        }
        bidCommitments[msg.sender] = bidCommitment;
    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(uint nonce) public payable{

        // TODO: place your code here
        require(time() >= biddingDeadline, "Bid revealing period has not begun.");
        require(time() < revealDeadline, "Bid revealing period has ended.");
        require(bidCommitments[msg.sender] != 0, "Sender did not make any bid.");
        
        bytes32 checkCommit = keccak256(abi.encodePacked(msg.value, nonce));

        require(checkCommit == bidCommitments[msg.sender], "Bidder failed commit validation during reveal.");

        require(revealedBids[msg.sender] != true, "Cannot reveal bid multiple times.");

        if (msg.value >= highestBid) {
            secondHighestBid = highestBid;
            secondHighestBidAddress = highestBidAddress;
            highestBid = msg.value;
            highestBidAddress = msg.sender;
            pendingWithdrawals[secondHighestBidAddress] += secondHighestBid;
        } else if (msg.value >= secondHighestBid) {
            pendingWithdrawals[secondHighestBidAddress] += secondHighestBid;
            secondHighestBid = msg.value;
            secondHighestBidAddress = msg.sender;
        }
        revealedBids[msg.sender] = true;
        pendingWithdrawals[msg.sender] += bidDepositAmount;
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){

        // TODO: place your code here
        if (time() >= revealDeadline) {
            winner = highestBidAddress;
            return winner;
        }

        return address(0x0);
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {
 
        // TODO: place your code here
        require(time() >= revealDeadline, "Auction is not completed yet. Cannot finalize.");
        if (highestBid > secondHighestBid) {
            winningPrice = secondHighestBid;
            pendingWithdrawals[getWinner()] += highestBid - winningPrice;
        } else {
            winningPrice = highestBid;
        }

        if (pendingWithdrawals[secondHighestBidAddress] < secondHighestBid + bidDepositAmount) {
            pendingWithdrawals[secondHighestBidAddress] += secondHighestBid;
        }

        pendingWithdrawals[sellerAddress] += winningPrice;
        // call the general finalize() logic
        super.finalize();
    }
}
