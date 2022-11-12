// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Structs {
    // encode and decode data format in updateChangeRate() between main and polygon
    struct ExchangePriceData {
       address rootVault;
       address childVault;
       uint256 exchangePrice;
    }
}

contract Common is Structs {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    bytes32 public constant UPDATE_EXCHANGE_PRICE_SINGLE = keccak256("UPDATE_EXCHANGE_PRICE_SINGLE");
    bytes32 public constant UPDATE_EXCHANGE_PRICE_MULTI = keccak256("UPDATE_EXCHANGE_PRICE_MULTI");
    bytes32 public constant DEPOSIT_SINGLE = keccak256("DEPOSIT_SINGLE");
    bytes32 public constant DEPOSIT_MULTI = keccak256("DEPOSIT_MULTI");
    bytes32 public constant WITHDRAW = keccak256("WITHDRAW");
}