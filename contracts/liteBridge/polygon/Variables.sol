// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IFxMessageProcessor.sol";

import "../common/Common.sol";


contract VariablesV1 is Common {
    // state sender contract child
    IFxMessageProcessor public immutable fxChild;

    // Lite Bridge Contract Child
    address public immutable liteBridgeRoot;

    mapping (address => address) public childToRootVault;

    mapping (address => bool) public rebalancer;

    constructor(address _fxChild, address _liteBridgeRoot) {
        fxChild = IFxMessageProcessor(_fxChild);
        liteBridgeRoot = _liteBridgeRoot;
    }
}