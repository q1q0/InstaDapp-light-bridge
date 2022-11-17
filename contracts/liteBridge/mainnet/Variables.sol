// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IFxStateSender.sol";
import "./interface/IWETH.sol";
import "./interface/IRootChainManager.sol";

import "../common/Common.sol";


contract VariablesV1 is Common, Initializable, OwnableUpgradeable {
    // Root Chain manager contract
    IRootChainManager public immutable rootChainManager;

    // state sender contract
    IFxStateSender public immutable fxRoot;

    IWETH public immutable wETH;
    IERC20 public immutable stETH;
    address public immutable oneInchAddress;

    /* State variables from OZ lib

      - ### Initializable ### 

        uint8 private _initialized;

        bool private _initializing;

      - ### Initializable ### 
         
      - ### OwnableUpgradeable ### 

        address private _owner;
        uint256[49] private __gap;

      - ### OwnableUpgradeable ### 

    */

    uint256 public bridgeNonce;

    mapping (address => address) public rootToChainVault;

    mapping (address => bool) public rebalancer;

    constructor(
        address _rootChainManager,
        address _fxRoot,
        address _wETH,
        address _stETH,
        address _oneInchAddress
    ) {
        rootChainManager = IRootChainManager(_rootChainManager);
        fxRoot = IFxStateSender(_fxRoot);
        wETH = IWETH(_wETH);
        stETH = IERC20(_stETH);
        oneInchAddress = _oneInchAddress;

        _disableInitializers();
    }
}