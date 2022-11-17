// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Events {
    event LogFromMainnet(
        address indexed rootVault,
        address indexed childVault,
        address indexed token,
        uint256 amont
    );

    event LogUpdatedExchangePrice(
        uint256 indexed id,
        address indexed vault,
        uint256 exchangePrice
    );

    event LogMessageReceived (
        uint256 indexed stateId,
        uint256 indexed bridgeNonce,
        bytes32 indexed key
    );

    event LogToMainnet(
        address indexed rootVault,
        address indexed childVault,
        address indexed token,
        uint256 amont
    );
}