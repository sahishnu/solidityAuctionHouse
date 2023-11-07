// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;
    uint public startBlock;
    uint public endBlock;
    uint public currentMinBidRequired;
    uint public currentHighestBid;
    address public currentHighestBidder;

    // TODO: place your code here

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement)
             Auction (_sellerAddress, _judgeAddress, address(0), 0) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        // TODO: place your code here
        startBlock = time();
        endBlock = startBlock + biddingPeriod;
        currentHighestBid = initialPrice; // Initial bid needs to be at least initial price
        currentMinBidRequired = initialPrice;

    }

    function bid() public payable{

        // TODO: place your code here
        require(time() < endBlock, "Bidding period has ended.");
        require(msg.sender != sellerAddress, "Seller cannot bid.");
        require(getWinner() == address(0), "There is already a winning bid.");
        require(msg.value >= currentMinBidRequired, "Offer too low. It should be higher than the current bid.");

        // Incremenet next minimum required bid amount.
        currentMinBidRequired = msg.value + minimumPriceIncrement;

        // Refund the current highest bidder if one exists.
        if (currentHighestBidder != address(0x0)) {
            pendingWithdrawals[currentHighestBidder] += currentHighestBid;
        }

        currentHighestBid = msg.value;
        currentHighestBidder = msg.sender;
        endBlock = time() + biddingPeriod;

    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){

        // TODO: place your code here
        if (time() >= endBlock) {
            return currentHighestBidder;
        }

        return address(0x0);

    }
}
