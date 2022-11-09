// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IChildChainManager {
    function withdraw(uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns(uint256);
}