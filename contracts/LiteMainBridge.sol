// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseRootTunnel} from "./tunnel/FxBaseRootTunnel.sol";
import "./lib/IERC20.sol";
import "./lib/IRootChainManager.sol";

interface IToken {
    function deposit(uint256 amount_) external;
    function withdraw() external returns(address, uint256);
    function depositForETH() external payable;
    function approve(address spender, uint256 amount) external;
    function getExchangePrice() external view returns(uint256);
    function iChildToken() external view returns(address);
}

/**
 * @title LiteMainBridge
 */
contract LiteMainBridge is FxBaseRootTunnel {
    mapping(address => address) iTokenList;
    address[] iTokenArr;

    event Key(bytes32 key, bytes data);

    // constructor(address _checkpointManager, address _fxRoot, address _bridge) FxBaseRootTunnel(_checkpointManager, _fxRoot, _bridge) {
    // }

    function _processMessageFromChild(bytes memory message) internal override {
        (bytes32 key, bytes memory data) = abi.decode(message, (bytes32, bytes));
        if(key == WITHDRAW_TOKEN) {
            (address rootToken, address iChildToken, address predicateAddress, uint256 amount) = abi.decode(data, (address, address, address, uint256));
            address iRootToken = getItoken(rootToken);
            if(predicateETH == predicateAddress) {
                IToken(iRootToken).depositForETH{value: amount}();
            } else {
                IERC20(rootToken).approve(iRootToken, amount);
                IToken(iRootToken).deposit(amount);
            }
            // _sendMessageToChild(abi.encode(UPDATE_PRICE, abi.encode(childToken, amount)));
        }
        emit Key(key, data);
    }

    function updateExchangeRate() external {
        uint256 len = iTokenArr.length;
        ExchangePrice[] memory price = new ExchangePrice[](len);
        for(uint256 i = 0; i < len; i++) {
            price[i].exchangePrice = IToken(iTokenArr[i]).getExchangePrice();
            price[i].mainnetVault = iTokenArr[i];
            price[i].polygonVault = IToken(iTokenArr[i]).iChildToken();
        }
        _sendMessageToChild(abi.encode(UPDATE_PRICE, abi.encode(price)));
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

    function getItoken(address underlyingToken_) public view returns(address iToken) {
        iToken = iTokenList[underlyingToken_];
    }

    function setItoken(address[] memory underlyingToken_, address[] memory iToken_) external {
        require(underlyingToken_.length == iToken_.length, "not match");
        for(uint256 i = 0; i < underlyingToken_.length; i++) {
            if(iTokenList[underlyingToken_[i]] == address(0)) {
                iTokenArr.push(iToken_[i]);
                iTokenList[underlyingToken_[i]] = iToken_[i];
            }
        }
    }

    function withdraw(address[] memory iToken_) external {
        uint256 len = iToken_.length;
        Withdraw[] memory sendData_ = new Withdraw[](iToken_.length);
        for(uint256 i = 0; i < len; i++) {
            (address rootToken, uint256 amount) = IToken(iToken_[i]).withdraw();
            if(rootToken == address(0)) {
                manager.depositEtherFor{value: amount}(address(this));
            } else {
                _depositFor(address(this), rootToken, amount);
            }
            sendData_[i].iChildToken = IToken(iToken_[i]).iChildToken();
            sendData_[i].amount = amount;
        }
        _sendMessageToChild(abi.encode(WITHDRAW_TOKEN, abi.encode(sendData_)));
    }

    receive() external payable {}

}
