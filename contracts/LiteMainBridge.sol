// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseRootTunnel} from "./tunnel/FxBaseRootTunnel.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/IRootChainManager.sol";

interface IToken {
    function updateExchangePrice(uint256 exchangePrice_) external;
    function deposit(uint256 amount_) external;
    function withdrawFromMainnet() external;
    function depositForETH() external payable;
    function withdrawForETH() external;
}

/**
 * @title LiteMainBridge
 */
contract LiteMainBridge is FxBaseRootTunnel {
    mapping(address => address) iTokenList;

    event Key(bytes32 key, bytes data);
    event Withdraw(address token, uint256 amount);

    // constructor(address _checkpointManager, address _fxRoot, address _bridge) FxBaseRootTunnel(_checkpointManager, _fxRoot, _bridge) {
    // }

    function _processMessageFromChild(bytes memory message) internal override {
        (bytes32 key, bytes memory data) = abi.decode(message, (bytes32, bytes));
        if(key == WITHDRAW_TOKEN) {
            (address childToken, uint256 amount) = abi.decode(data, (address, uint256));
            // if(predicateETH == predicateAddress)
            //     payable(account).transfer(amount);
            // else
            //     IERC20(predicateAddress).transfer(account, amount);
            _sendMessageToChild(abi.encode(UPDATE_PRICE, abi.encode(childToken, amount)));
            emit Withdraw(childToken, amount);
        }
        emit Key(key, data);
    }

    function _depositFor(
        address user,
        address rootToken,
        uint256 amount
    ) private {
        IERC20(rootToken).transferFrom(msg.sender, address(this), amount);
        bytes memory depositData = abi.encode(amount);
        manager.depositFor(user, rootToken, depositData);
    }

    function depositMulti(address user, address[] memory rootTokens, uint256[] memory amounts) external payable {
        require(rootTokens.length == amounts.length, "No match");
        for(uint i = 0; i < rootTokens.length; i++) {
            _depositFor(user, rootTokens[i], amounts[i]);
        }
        if(msg.value > 0)
            manager.depositEtherFor{value: msg.value}(user);
    }

    function getItoken(address underlyingToken_) public view returns(address iToken) {
        iToken = iTokenList[underlyingToken_];
    }

    function setItoken(address[] memory underlyingToken_, address[] memory iToken_) external {
        require(underlyingToken_.length == iToken_.length, "not match");
        for(uint256 i = 0; i < underlyingToken_.length; i++) {
            iTokenList[underlyingToken_[i]] = iToken_[i];
        }
    }

    receive() external payable {}

}
