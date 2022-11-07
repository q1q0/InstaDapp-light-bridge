// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {FxBaseChildTunnel} from "./tunnel/FxBaseChildTunnel.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ii_ChildToken} from "./interface/Ii_Token.sol";
import {IChildChainManager} from "./interface/IChainManager.sol";

/**
 * @title LitePolygonBridge
 */
contract LitePolygonBridge is FxBaseChildTunnel {

    mapping(address => bool) rebalancer;

    event Key(bytes32 key);

    function sendMessageToRoot(bytes memory message) external {
        _sendMessageToRoot(message);
    }

    function deposit(address iToken) external {
        require(rebalancer[msg.sender] || owner() == msg.sender, "no permission");
        uint256 _amount = Ii_ChildToken(iToken).toMainnet();
        IChildChainManager(Ii_ChildToken(iToken).UNDERLYING_TOKEN()).withdraw(_amount);
    }

    function setRebalancer(address _account, bool flag) external onlyOwner {
        rebalancer[_account] = flag;
    }

    receive() external payable {}

    function _processMessageFromRoot(
        uint256,
        address sender,
        bytes memory data
    ) internal override validateSender(sender) {
        (bytes32 key, bytes memory _dataFromRoot) = abi.decode(data, (bytes32, bytes));
        if(key == UPDATE_PRICE) {
            ExchangePrice[] memory list = abi.decode(_dataFromRoot, (ExchangePrice[]));
            uint256 len = list.length;
            for (uint256 i = 0; i < len; i++) {
                Ii_ChildToken(list[i].polygonVault).updateExchangePrice(list[i].exchangePrice);
            }
        } else if(key == WITHDRAW_TOKEN) {
            Withdraw[] memory list = abi.decode(_dataFromRoot, (Withdraw[]));
            uint256 len = list.length;
            for (uint256 i = 0; i < len; i++) {
                address underlyingToken = Ii_ChildToken(list[i].iChildToken).UNDERLYING_TOKEN();
                IERC20(underlyingToken).approve(list[i].iChildToken, list[i].amount);
                Ii_ChildToken(list[i].iChildToken).fromMainnet(list[i].amount);
            }
        }

        emit Key(key);
    }
}
