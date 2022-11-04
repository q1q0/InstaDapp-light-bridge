// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseChildTunnel} from "./tunnel/FxBaseChildTunnel.sol";
import "./lib/Const.sol";

interface IChildChainManager {
    function withdraw(uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns(uint256);
}

interface IIToken {
    function depositToMainnet() external returns(uint256);
    function withdrawFromMainnet(uint256 amount) external;
    function updateExchangePrice(uint256 exchangePrice_) external;
    function UNDERLYING_TOKEN() external returns(address);
}

/**
 * @title LitePolygonBridge
 */
contract LitePolygonBridge is FxBaseChildTunnel, Const {
    // uint256 public latestStateId;
    // address public latestRootMessageSender;
    // bytes public latestData;

    // IChildChainManager manager;
    mapping(address => bool) rebalancer;
    mapping(address => address) iTokenList;

    event Key(bytes32 key);

    // constructor(address _fxChild, address _bridge) FxBaseChildTunnel(_fxChild) {
    //     manager = IChildChainManager(_bridge);
    // }

    function _processMessageFromRoot(
        uint256,
        address sender,
        bytes memory data
    ) internal override validateSender(sender) {
        // latestStateId = stateId;
        // latestRootMessageSender = sender;
        // latestData = data;
        (bytes32 key, bytes memory _dataFromRoot) = abi.decode(data, (bytes32, bytes));
        if(key == UPDATE_PRICE) {
            (address underlyingToken_, uint256 amount_) = abi.decode(_dataFromRoot, (address, uint256));
            // withdrawBalance[token] += amount;
            IIToken(getItoken(underlyingToken_)).updateExchangePrice(amount_);
        }

        emit Key(key);
    }

    function sendMessageToRoot(bytes memory message) public {
        _sendMessageToRoot(message);
    }

    function deposit(address iToken) external {
        require(rebalancer[msg.sender], "no permission");
        iTokenList[IIToken(iToken).UNDERLYING_TOKEN()] = iToken;
        uint256 _amount = IIToken(iToken).depositToMainnet();
        IChildChainManager(IIToken(iToken).UNDERLYING_TOKEN()).withdraw(_amount);
    }

    function getItoken(address underlyingToken_) public view returns(address iToken) {
        iToken = iTokenList[underlyingToken_];
    }

    function setRebalancer(address _account, bool flag) external {
        require(msg.sender == owner, "no permission");
        rebalancer[_account] = flag;
    }

    receive() external payable {}
}
