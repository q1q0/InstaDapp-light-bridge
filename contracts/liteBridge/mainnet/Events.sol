// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Events {
    event LogToggleRootToChildVaultMap(
        address indexed rootVault,
        address indexed childVault,
        bool indexed add
    );

    event LogToggleRebalancer(
        address indexed rebalancer,
        bool indexed add
    );

    event LogDepositToVault(
        address indexed vault,
        address indexed token,
        uint256 amount
    );

    event LogFromPolygon(
        address indexed token,
        uint256 amount
    );

    event LogUpdateExchangePrice(
        uint256 indexed bridgeNonce,
        address indexed rootVault,
        address indexed childVault,
        uint256 exchangePrice
    );


    event LogWithdrawToPolygon(
        uint256 indexed bridgeNonce,
        address indexed rootVault,
        address indexed childVault,
        address token,
        uint256 amount
    );
}