// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interface/IChildChainManager.sol";
import "./interface/IChildVault.sol";
import "./interface/IiTokenPolygon.sol";

import "./Variables.sol";

abstract contract FxBaseChildTunnel is VariablesV1 {
    // MessageTunnel on L1 will get data from this event
    event MessageSent(bytes message);

    modifier validateSender(address sender) {
        require(sender == address(this), "invalid-sender");
        _;
    }

    function processMessageFromRoot(
        uint256 stateId,
        address rootMessageSender,
        bytes calldata data
    ) external {
        require(msg.sender == address(fxChild), "FxBaseChildTunnel: INVALID_SENDER");
        _processMessageFromRoot(stateId, rootMessageSender, data);
    }

    /**
     * @notice Emit message that can be received on Root Tunnel
     * @dev Call the internal function when need to emit message
     * @param message bytes message that will be sent to Root Tunnel
     * some message examples -
     *   abi.encode(tokenId);
     *   abi.encode(tokenId, tokenMetadata);
     *   abi.encode(messageType, messageData);
     */
    function _sendMessageToRoot(bytes memory message) internal {
        emit MessageSent(message);
    }

    /**
     * @notice Process message received from Root Tunnel
     * @dev function needs to be implemented to handle message as per requirement
     * This is called by onStateReceive function.
     * Since it is called via a system call, any event will not be emitted during its execution.
     * @param stateId unique state id
     * @param sender root message sender
     * @param message bytes message that was sent from Root Tunnel
     */
    function _processMessageFromRoot(
        uint256 stateId,
        address sender,
        bytes memory message
    ) internal virtual;

    constructor(address _fxChild) VariablesV1(_fxChild) {}
}

abstract contract AdminModule is FxBaseChildTunnel {
    // Add function to add RootToChain Mapping
    // Add function to add rebalancer Mapping

    function setRebalancer(address _account, bool flag) external /* onlyOwner */ {
        rebalancer[_account] = flag;
    }

    constructor(address _fxChild) FxBaseChildTunnel(_fxChild) {}
}

contract LitePolygonBridge is AdminModule {
    using SafeERC20 for IERC20;

    // function setRebalancer(address _account, bool flag) external onlyOwner {
    //     rebalancer[_account] = flag;
    // }

    receive() external payable {}

    function _processMessageFromRoot(
        uint256,
        address sender,
        bytes memory data
    ) internal override /* validateSender(sender) */ {
        (bytes32 key_, uint256 id_, bytes memory encodedRootData_) = abi.decode(data, (bytes32, uint256, bytes));
        if(key_ == UPDATE_EXCHANGE_PRICE) {
            ExchangePriceData[] memory exchangePriceDatas_ = abi.decode(encodedRootData_, (ExchangePriceData[]));
            uint256 length_ = exchangePriceDatas_.length;
            for (uint256 i = 0; i < length_; i++) {
                // require
                IiTokenVaultPolygon(exchangePriceDatas_[i].childVault).updateExchangePrice(exchangePriceDatas_[i].exchangePrice);
            }
        }
    }

    function processFromMainnet(
        address vault,
        address token,
        uint256 amount,
        bool processWithdral
    ) public /* OnlyRebalancer */ {

        IERC20(token).safeApprove(vault, amount);
        IiTokenVaultPolygon(vault).fromMainnet(amount);

        // Emit event
    }

    function processToMainnet(
        address vault,
        address token,
        uint256 amount
    ) public /* OnlyRebalancer */ {
        // Add balance condition

        IChildVault(vault).toMainnet(amount);
        IChildChainManager(token).withdraw(amount);

        // Emit event
    }

    constructor(address _fxChild) AdminModule(_fxChild) {}

}
