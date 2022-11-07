// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {FxBaseRootTunnel} from "./tunnel/FxBaseRootTunnel.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRootChainManager} from "./interface/IChainManager.sol";
import {Ii_RootToken} from "./interface/Ii_Token.sol";


/**
 * @title LiteMainBridge
 */
contract LiteMainBridge is FxBaseRootTunnel {

    event Key(bytes32 key, bytes data);

    function updateExchangeRate() external {
        uint256 len = iTokenArr.length;
        ExchangePrice[] memory price = new ExchangePrice[](len);
        for(uint256 i = 0; i < len; i++) {
            price[i].exchangePrice = Ii_RootToken(iTokenArr[i]).getExchangePrice();
            price[i].mainnetVault = iTokenArr[i];
            price[i].polygonVault = Ii_RootToken(iTokenArr[i]).iChildToken();
        }
        _sendMessageToChild(abi.encode(UPDATE_PRICE, abi.encode(price)));
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
            (address rootToken, uint256 amount) = Ii_RootToken(iToken_[i]).withdraw();
            if(rootToken == address(0)) {
                manager.depositEtherFor{value: amount}(address(this));
            } else {
                _depositFor(address(this), rootToken, amount);
            }
            sendData_[i].iChildToken = Ii_RootToken(iToken_[i]).iChildToken();
            sendData_[i].amount = amount;
        }
        _sendMessageToChild(abi.encode(WITHDRAW_TOKEN, abi.encode(sendData_)));
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

    function _processMessageFromChild(bytes memory message) internal override {
        (bytes32 key, bytes memory data) = abi.decode(message, (bytes32, bytes));
        if(key == WITHDRAW_TOKEN) {
            (address rootToken, , address predicateAddress, uint256 amount) = abi.decode(data, (address, address, address, uint256));
            address iRootToken = getItoken(rootToken);
            if(predicateETH == predicateAddress) {
                Ii_RootToken(iRootToken).depositForETH{value: amount}();
            } else {
                IERC20(rootToken).approve(iRootToken, amount);
                Ii_RootToken(iRootToken).deposit(amount);
            }
        }
        emit Key(key, data);
    }

    receive() external payable {}
}
