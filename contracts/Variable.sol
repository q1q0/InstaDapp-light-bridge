// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IChainManager.sol";
import "./interface/IFxStateSender.sol";

contract Const {
    bytes32 public constant UPDATE_PRICE = keccak256("UPDATE_PRICE");
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");
    bytes32 public constant WITHDRAW_TOKEN = keccak256("WITHDRAW_TOKEN");
    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;
}

contract VariableForVault {
    uint256 internal exchangePrice;
    IERC20 public UNDERLYING_TOKEN;
    address public liteBridgeContract;
    bool internal isIETHContract;
    address public iChildToken;
}

contract VariableForBridge is Const {
    // fx child
    address public fxChild;

    // fx root tunnel
    address public fxRootTunnel;

    // state sender contract
    IFxStateSender public fxRoot;

    // root chain manager for bridging funds from main to polygon
    IRootChainManager manager;
    
    // child tunnel contract which receives and sends messages
    address public fxChildTunnel;
    address public predicateETH;

    mapping(address => address) iTokenList; // pair of (underlyingToken => iToken) in main bridge, getting iToken address by underlyingToken
    
    // iToken list in main bridge. Will be used for updateChangeRate()
    address[] iTokenArr;

    // encode and decode data format in updateChangeRate() between main and polygon
    struct ExchangePrice {
       address mainnetVault;
       address polygonVault;
       uint256 exchangePrice;
    }

    // encode and decode data format in multi Withdraw from main to polygon
    struct Withdraw {
        address iChildToken;
        uint256 amount;
    }
}