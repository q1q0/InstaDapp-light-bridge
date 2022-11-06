// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// @title Polygon Lite vault

import "../lib/IToken.sol";

contract BridgeModule is Variables{
    address public iChildToken;

    function getExchangePrice() public view returns(uint256) {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        // add some updateExchange logic
        return exchangePrice;
    }

    function deposit(uint256 amount_) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
       
        UNDERLYING_TOKEN.transferFrom(liteBridgeContract, address(this), amount_);
        _mint(msg.sender, amount_);
        // Event is emitted
    }

    function withdraw() public returns(address, uint256) {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        if(isIETHContract) {
            uint256 balance = address(this).balance;
            payable(msg.sender).transfer(balance);
            _burn(msg.sender, balance);
            return (address(0), balance);
        } else {
            UNDERLYING_TOKEN.transfer(liteBridgeContract, UNDERLYING_TOKEN.balanceOf(address(this)));
            uint256 balance = UNDERLYING_TOKEN.balanceOf(address(this));
            _burn(msg.sender, balance);
            return (address(UNDERLYING_TOKEN), balance);
        }
        // Event is emitted
    }

    function depositForETH() public payable {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        _mint(msg.sender, msg.value);
    }

    function setIChildToken(address childToken_) external {
        require(owner == msg.sender, "no permission");
        iChildToken = childToken_;
    }

}

contract LiteVaultRoot is BridgeModule {

} 