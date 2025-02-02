// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "hardhat/console.sol";

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;

    // TODO: place your code here
    mapping(address => uint) public pendingWithdrawals;

    // constructor
    constructor(address _sellerAddress,
                address _judgeAddress,
                address _winnerAddress,
                uint _winningPrice) payable {

        judgeAddress = _judgeAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == address(0))
          sellerAddress = msg.sender;
        winnerAddress = _winnerAddress;
        winningPrice = _winningPrice;
    }

    // Ensure the auction has ended
    modifier auctionHasEnded() {
        require(getWinner() != address(0x0), "No winner specified, auction is not over.");
        _;
    }

    // This is used in testing.
    // You should use this instead of block.number directly.
    // You should not modify this function.
    function time() public view returns (uint) {
        return block.number;
    }

    function getWinner() public view virtual returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public virtual auctionHasEnded {

        // TODO: place your code here

        // If judge is specified, only judge or winner can finalize
        if (judgeAddress != address(0x0)) {
            require(
                msg.sender == judgeAddress || msg.sender == getWinner(),
                "Judge is specified. Only winner or judge can finalize the auction and pay the seller"
            );
        }

        // If no judge is specified, anyone can finalize
        pendingWithdrawals[sellerAddress] += winningPrice;

    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public auctionHasEnded {

        // TODO: place your code here
        require(
            msg.sender == judgeAddress || msg.sender == sellerAddress,
            "Only the seller or judge can refund the money to the winner"
        );

        pendingWithdrawals[winnerAddress] += winningPrice;
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {

        //TODO: place your code here
        uint withdrawAmount = pendingWithdrawals[msg.sender];
        require(withdrawAmount >= 0, "Attempting to withdraw invalid amount of funds.");

        pendingWithdrawals[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: withdrawAmount}("");
        require(sent, "Failed to send funds");
    }

}
