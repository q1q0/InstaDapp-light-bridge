// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IFxMessageProcessor.sol";

import "../common/Common.sol";


contract VariablesV1 is Common {
    // state sender contract child
    IFxMessageProcessor public immutable fxChild;

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
    
    mapping (uint256 => StateData) public bridgeNonceToData;

    mapping (address => address) public childToRootVault;

    mapping (address => bool) public rebalancer;

    constructor(address _fxChild) {
        fxChild = IFxMessageProcessor(_fxChild);
    }
}