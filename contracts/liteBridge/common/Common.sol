// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Structs {
    // encode and decode data format in updateChangeRate() between main and polygon
    struct ExchangePriceData {
       address rootVault;
       address childVault;
       uint256 exchangePrice;
    }

    struct WithdrawData {
       address rootVault;
       address childVault;
       uint256 amount;
    }

    struct StateData {
        uint8 isExecuted;
        bytes32 key;
        bytes data;
    }

    struct BatchWithdrawParams {
        address rootVault;
        address childVault;
        address token;
        uint256 amount;
        bytes oneInchSwapCalldata;
    }
}

contract Common is Structs {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    bytes32 public constant UPDATE_EXCHANGE_PRICE_SINGLE = keccak256("UPDATE_EXCHANGE_PRICE_SINGLE");
    bytes32 public constant UPDATE_EXCHANGE_PRICE_MULTI = keccak256("UPDATE_EXCHANGE_PRICE_MULTI");
    bytes32 public constant DEPOSIT_SINGLE = keccak256("DEPOSIT_SINGLE");
    bytes32 public constant DEPOSIT_MULTI = keccak256("DEPOSIT_MULTI");
    bytes32 public constant WITHDRAW_SINGLE = keccak256("WITHDRAW_SINGLE");
    bytes32 public constant WITHDRAW_MULTI = keccak256("WITHDRAW_MULTI");
}