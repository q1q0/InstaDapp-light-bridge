// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface/IRootChainManager.sol";



import "../../interface/IFxStateSender.sol";
import "../tunnel/FxBaseRootTunnel.sol"; // Remove Later

contract Constants {
    address public ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    bytes32 public constant UPDATE_PRICE = keccak256("UPDATE_PRICE");
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");
    bytes32 public constant WITHDRAW_TOKEN = keccak256("WITHDRAW_TOKEN");
    // bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;
}

contract FxBaseRootTunnelVariables {
    // keccak256(MessageSent(bytes))
    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;

    // state sender contract
    IFxStateSender public immutable fxRoot;

    // root chain manager
    ICheckpointManager public immutable checkpointManager;

    // child tunnel contract which receives and sends messages
    address public immutable fxChildTunnel;

    // storage to avoid duplicate exits
    mapping(bytes32 => bool) public processedExits;

    constructor(address _checkpointManager, address _fxRoot, address _fxChildTunnel) {
        checkpointManager = ICheckpointManager(_checkpointManager);
        fxRoot = IFxStateSender(_fxRoot);
        fxChildTunnel = _fxChildTunnel;
    }
} 

contract VariablesV1 is Constants {
    // Root Chain manager contract
    IRootChainManager public immutable rootChainManager;

    // state sender contract
    IFxStateSender public immutable fxRoot;

    mapping (address => address) public rootToChainVault;


    // fx child
    // address public fxChild;

    // fx root tunnel
    // address public fxRootTunnel;

    // state sender contract
    // IFxStateSender public fxRoot;

    // root chain manager for bridging funds from main to polygon
    // IRootChainManager manager;
    
    // child tunnel contract which receives and sends messages
    address public fxChildTunnel;
    address public predicateETH;

    mapping(address => address) iTokenList; // pair of (underlyingToken => iToken) in main bridge, getting iToken address by underlyingToken
    
    // iToken list in main bridge. Will be used for updateChangeRate()
    address[] iTokenArr;

    // encode and decode data format in updateChangeRate() between main and polygon
    struct ExchangePriceData {
       address rootVault;
       address childVault;
       uint256 exchangePrice;
    }

    // encode and decode data format in multi Withdraw from main to polygon
    struct Withdraw {
        address iChildToken;
        uint256 amount;
    }
}