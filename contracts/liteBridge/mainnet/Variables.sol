// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IFxStateSender.sol";
import "./interface/IRootChainManager.sol";

import "../common/Common.sol";


contract VariablesV1 is Common {
    // Root Chain manager contract
    IRootChainManager public immutable rootChainManager;

    // state sender contract
    IFxStateSender public immutable fxRoot;

    // Lite Bridge Contract Child
    address public immutable liteBridgeChild;

    mapping (address => address) public rootToChainVault;

    mapping (address => bool) public rebalancer;

    constructor(address _rootChainManager, address _fxRoot, address _liteBridgeChild) {
        rootChainManager = IRootChainManager(_rootChainManager);
        fxRoot = IFxStateSender(_fxRoot);
        liteBridgeChild = _liteBridgeChild;
    }
}