// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IiTokenVault {
    function supply(
        address token_,
        uint256 amount_,
        address to_
    ) external returns(uint256);
    function supplyEth(address to) external payable returns(uint256);
    function withdraw(uint256 amount_, address to_) external returns(uint256);
    function getCurrentExchangePrice() external view returns(uint256, uint256);

    // MOCK MOCK MOCK MOCK
    function updateExchangePrice() external returns(uint256);
    // MOCK MOCK MOCK MOCK
}