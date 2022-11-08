// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IRootChainManager.sol";
import "../../interface/IFxStateSender.sol";

contract Constants {
    address public ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    bytes32 public constant UPDATE_PRICE = keccak256("UPDATE_PRICE");
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");
    bytes32 public constant WITHDRAW_TOKEN = keccak256("WITHDRAW_TOKEN");
    // bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;
}

contract VariablesV1 is Constants {
    // Root Chain manager contract
    IRootChainManager public immutable rootChainManager;

    // state sender contract
    IFxStateSender public immutable fxRoot;

    mapping (address => address) public rootToChainVault;

    mapping (address => bool) public rebalancer;

    // encode and decode data format in updateChangeRate() between main and polygon
    struct ExchangePriceData {
       address rootVault;
       address childVault;
       uint256 exchangePrice;
    }

    constructor(address _rootChainManager, address _fxRoot) {
        rootChainManager = IRootChainManager(_rootChainManager);
        fxRoot = IFxStateSender(_fxRoot);
    }
}