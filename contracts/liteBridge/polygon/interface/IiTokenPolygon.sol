// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IiTokenVaultPolygon {
   // TODO: add polygon functions
   function toMainnet() external returns(uint256);
    function fromMainnet(uint256 amount) external;
    function updateExchangePrice(uint256 exchangePrice_) external;
    function UNDERLYING_TOKEN() external returns(address);
}