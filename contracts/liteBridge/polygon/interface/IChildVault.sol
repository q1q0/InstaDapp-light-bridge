// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IChildVault {
    function toMainnet(uint256 amount) external ;
    function fromMainnet(uint256 amount) external;
}