// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Const {
    bytes32 public constant UPDATE_PRICE = keccak256("UPDATE_PRICE");
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");
    bytes32 public constant WITHDRAW_TOKEN = keccak256("WITHDRAW_TOKEN");
    
    struct ExchangePrice {
       address mainnetVault;
       address polygonVault;
       uint256 exchangePrice;
    }

    struct Withdraw {
        address iChildToken;
        uint256 amount;
    }
}