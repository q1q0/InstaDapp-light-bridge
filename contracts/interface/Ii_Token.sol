// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Ii_RootToken {
    function deposit(uint256 amount_) external;
    function withdraw() external returns(address, uint256);
    function depositForETH() external payable;
    function approve(address spender, uint256 amount) external;
    function getExchangePrice() external view returns(uint256);
    function iChildToken() external view returns(address);
}

interface Ii_ChildToken {
    function toMainnet() external returns(uint256);
    function fromMainnet(uint256 amount) external;
    function updateExchangePrice(uint256 exchangePrice_) external;
    function UNDERLYING_TOKEN() external returns(address);
}