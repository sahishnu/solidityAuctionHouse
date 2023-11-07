// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "hardhat/console.sol";
import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

    // TODO: place your code here
    uint public startBlock;
    uint public endBlock;
    uint public reservePrice;
    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement)
             Auction (_sellerAddress, _judgeAddress, address(0), 0) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;
        // TODO: place your code here
        startBlock = time();
        endBlock = startBlock + biddingPeriod;
        reservePrice = initialPrice - (biddingPeriod * offerPriceDecrement);
    }


    function bid() public payable{
        // TODO: place your code here
        require(msg.value >= reservePrice, "Offer is below the minimum reserve price.");
        require(msg.sender != sellerAddress, "Seller cannot bid.");
        require(time() < endBlock, "Bidding period has ended.");
        require(getWinner() == address(0), "There is already a winning bid.");

        uint elapsedBlocks = time() - startBlock;
        uint currentPrice = initialPrice - elapsedBlocks * offerPriceDecrement;
        require(msg.value >= currentPrice, "Offer is too low.");

        winnerAddress = payable(msg.sender);
        uint refund = msg.value - currentPrice;

        if (refund > 0) {
            pendingWithdrawals[msg.sender] = refund;
        }

        pendingWithdrawals[sellerAddress] = currentPrice;
    }

}
