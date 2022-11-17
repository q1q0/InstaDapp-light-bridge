// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interface/IChildChainManager.sol";
import "./interface/IChildVault.sol";
import "./interface/IiTokenPolygon.sol";

import "./Variables.sol";
import "./Events.sol";

abstract contract FxBaseChildTunnel is VariablesV1, Events {
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
    function transferOwnership(address newOwner) public override virtual onlyOwner {
        toggleRebalancer(owner(), false);
        super.transferOwnership(newOwner);
        toggleRebalancer(newOwner, true);
    }

    modifier OnlyRebalancer() {
        require(rebalancer[msg.sender], "LBP: not a rebalancer");
        _;
    }

    function toggleChildToRootVaultMap(
        address rootVault,
        address childVault,
        bool add
    ) public /* onlyOwner */ {
        if (add) {
            require(childToRootVault[rootVault] == address(0), "LBP:[toggleChildToRootVaultMap]:: child to root Mapping already added");
            childToRootVault[rootVault] = childVault;
        } else {
            require(childToRootVault[rootVault] != address(0), "LBP:[toggleChildToRootVaultMap]:: child to root Mapping not added");
            delete childToRootVault[rootVault];
        }

        emit LogToggleChildToRootVaultMap(
            rootVault,
            childVault,
            add
        );
    }

    function toggleRebalancer(
        address rebalancerAddress,
        bool add
    ) public /* onlyOwner */ {
        if (add) {
            require(!rebalancer[rebalancerAddress], "LBP:[toggleRebalancer]:: rebalancerAddress already enabled");
            rebalancer[rebalancerAddress] = add;
        } else {
            require(rebalancer[rebalancerAddress], "LBP:[toggleRebalancer]::rebalancerAddress not enabled");
            rebalancer[rebalancerAddress] = add;
        }

        emit LogToggleRebalancer(
            rebalancerAddress,
            add
        );
    }

    constructor(address _fxChild) FxBaseChildTunnel(_fxChild) {}
}

contract LitePolygonBridge is AdminModule {
    using SafeERC20 for IERC20;

    receive() external payable {}

    function _processMessageFromRoot(
        uint256 stateId,
        address sender,
        bytes memory data
    ) internal override validateSender(sender) {
        (bytes32 key_, uint256 bridgeNonce_, bytes memory encodedRootData_) = abi.decode(data, (bytes32, uint256, bytes));
        emit LogMessageReceived(stateId, bridgeNonce_, key_);

        bridgeNonceToData[bridgeNonce_] = StateData(
            0,
            key_,
            encodedRootData_
        );
    }

    function updateExchangePrice(
        uint256 bridgeNonce
    ) public OnlyRebalancer {
        StateData memory stateData_ = bridgeNonceToData[bridgeNonce];

        require(stateData_.isExecuted == 0, "LBP:[processUpdateExchangePrice]:: already executed");

        if(stateData_.key == UPDATE_EXCHANGE_PRICE_SINGLE) {
            ExchangePriceData memory exchangePriceData_ = abi.decode(stateData_.data, (ExchangePriceData));
            IiTokenVaultPolygon(exchangePriceData_.childVault).updateExchangePrice(exchangePriceData_.exchangePrice);
            emit LogUpdatedExchangePrice(bridgeNonce, exchangePriceData_.childVault, exchangePriceData_.exchangePrice);
        } else if (stateData_.key == UPDATE_EXCHANGE_PRICE_MULTI) { //
            ExchangePriceData[] memory exchangePriceDatas_ = abi.decode(stateData_.data, (ExchangePriceData[]));
            uint256 length_ = exchangePriceDatas_.length;
            for (uint256 j = 0; j < length_; j++) {
                IiTokenVaultPolygon(exchangePriceDatas_[j].childVault).updateExchangePrice(exchangePriceDatas_[j].exchangePrice);
                emit LogUpdatedExchangePrice(bridgeNonce, exchangePriceDatas_[j].childVault, exchangePriceDatas_[j].exchangePrice);
            }
        } else {
            revert("LBP:[processUpdateExchangePrice]:: not update exchange price key");
        }
        bridgeNonceToData[bridgeNonce].isExecuted = 1;
    }

    function batchUpdateExchangePrice(uint256[] memory bridgeNonces) public {
        for (uint256 i = 0; i < bridgeNonces.length; i++) {
            updateExchangePrice(bridgeNonces[i]);
        }
    }

    function processWithdrawFromMainnet(
        uint256 bridgeNonce
    ) public OnlyRebalancer{
        StateData memory stateData_ = bridgeNonceToData[bridgeNonce];

        require(stateData_.isExecuted == 0, "LBP:[processWithdrawFromMainnet]:: already executed");

        if(stateData_.key == WITHDRAW_SINGLE) {
            WithdrawData memory withdrawData_ = abi.decode(stateData_.data, (WithdrawData));
            IERC20(withdrawData_.childToken).safeApprove(withdrawData_.childVault, withdrawData_.amount);
            IiTokenVaultPolygon(withdrawData_.childVault).fromMainnet(withdrawData_.amount);
            emit LogFromMainnet(
                withdrawData_.rootVault,
                withdrawData_.childVault,
                withdrawData_.childToken,
                withdrawData_.amount
            );
        } else if (stateData_.key == WITHDRAW_MULTI) { // TODO implement later
            revert("LBP:[processWithdrawFromMainnet]:: not implemented yet");
        } else {
            revert("LBP:[processWithdrawFromMainnet]:: not update exchange price key");
        }
        bridgeNonceToData[bridgeNonce].isExecuted = 1;
    }

    function processBatchWithdrawFromMainnet(
        uint256[] memory bridgeNonce
    ) external {
        for (uint256 i = 0; i < bridgeNonce.length; i++) {
            processWithdrawFromMainnet(
                bridgeNonce[i]
            );
        }
    }

    function processToMainnet(
        address vault,
        address token,
        uint256 amount
    ) public OnlyRebalancer {

        IChildVault(vault).toMainnet(amount);
        IChildChainManager(token).withdraw(amount);

        emit LogToMainnet(
            vault,
            vault,
            token,
            amount
        );
    }

    constructor(address _fxChild) AdminModule(_fxChild) {}

    function initialize(address owner_) public initializer {
        __Ownable_init();
        toggleRebalancer(owner_, true);
        _transferOwnership(owner_);
    }

}
