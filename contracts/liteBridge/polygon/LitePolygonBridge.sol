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

    event LogUpdatedExchangePrice(
        uint256 indexed id,
        address indexed vault,
        uint256 exchangePrice
    );

    event LogMessageReceived (
        uint256 indexed stateId,
        uint256 indexed bridgeNonce,
        bytes32 indexed key
    );

    function _processMessageFromRoot(
        uint256 stateId,
        address sender,
        bytes memory data
    ) internal override /* validateSender(sender) */ {
        (bytes32 key_, uint256 bridgeNonce_, bytes memory encodedRootData_) = abi.decode(data, (bytes32, uint256, bytes));
        emit LogMessageReceived(stateId, bridgeNonce_, key_);

        bridgeNonceToData[bridgeNonce_] = StateData(
            0,
            key_,
            encodedRootData_
        );
    }

    function processUpdateExchangePrice(uint256[] memory bridgeNonces) public {
        for (uint256 i = 0; i < bridgeNonces.length; i++) {
            StateData memory stateData_ = bridgeNonceToData[bridgeNonces[i]];
            require(stateData_.isExecuted == 0, "already-updated");
            // require
            if(stateData_.key == UPDATE_EXCHANGE_PRICE_SINGLE) {
                ExchangePriceData memory exchangePriceData_ = abi.decode(stateData_.data, (ExchangePriceData));
                IiTokenVaultPolygon(exchangePriceData_.childVault).updateExchangePrice(exchangePriceData_.exchangePrice);
                emit LogUpdatedExchangePrice(bridgeNonces[i], exchangePriceData_.childVault, exchangePriceData_.exchangePrice);
            } else if (false) { //
                ExchangePriceData[] memory exchangePriceDatas_ = abi.decode(stateData_.data, (ExchangePriceData[]));
                uint256 length_ = exchangePriceDatas_.length;
                for (uint256 j = 0; j < length_; j++) {
                    // require
                    IiTokenVaultPolygon(exchangePriceDatas_[j].childVault).updateExchangePrice(exchangePriceDatas_[j].exchangePrice);
                    emit LogUpdatedExchangePrice(bridgeNonces[i], exchangePriceDatas_[j].childVault, exchangePriceDatas_[j].exchangePrice);
                }
            }
            bridgeNonceToData[bridgeNonces[i]].isExecuted = 1;
        }
    }


    event LogFromMainnet(
        address indexed rootVault,
        address indexed childVault,
        address indexed token,
        uint256 amont
    );

    function processFromMainnetSingle(
        address vault,
        address token,
        uint256 amount
    ) public /* OnlyRebalancer */ {

        IERC20(token).safeApprove(vault, amount);
        IiTokenVaultPolygon(vault).fromMainnet(amount);

        // Emit event
        emit LogFromMainnet(
            vault,
            vault,
            token,
            amount
        );
    }

    function processFromMainnet(
        address[] memory vaults,
        address[] memory tokens,
        uint256[] memory amounts
    ) external /* OnlyRebalancer */ {
        for (uint256 i = 0; i < vaults.length; i++) {
            processFromMainnetSingle(
                vaults[i],
                tokens[i],
                amounts[i]
            );
        }
    }

    event LogToMainnet(
        address indexed rootVault,
        address indexed childVault,
        address indexed token,
        uint256 amont
    );

    function processToMainnet(
        address vault,
        address token,
        uint256 amount
    ) public /* OnlyRebalancer */ {
        // Add balance condition

        IChildVault(vault).toMainnet(amount);
        IChildChainManager(token).withdraw(amount);

        // Emit event
        emit LogToMainnet(
            vault,
            vault,
            token,
            amount
        );
    }

    constructor(address _fxChild) AdminModule(_fxChild) {}

}
