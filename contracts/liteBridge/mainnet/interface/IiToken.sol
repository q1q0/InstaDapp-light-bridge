// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IiTokenVault {
   // TODO: add mainnet functions
    function supply(
        address token_,
        uint256 amount_,
        address to_
    ) external returns(uint256);
    function supplyEth(address to) external payable returns(uint256);
    function withdraw(uint256 amount_, address to_) external returns(uint256);
    function getCurrentExchangePrice() external view returns(uint256, uint256);
}