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
    address public nativeToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    bytes32 public constant UPDATE_EXCHANGE_PRICE = keccak256("UPDATE_EXCHANGE_PRICE");
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");
    bytes32 public constant WITHDRAW_TOKEN = keccak256("WITHDRAW_TOKEN");
}