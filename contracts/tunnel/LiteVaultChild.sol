// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// @title Polygon Lite vault

import "../lib/IToken.sol";

abstract contract BridgeModule is Variables{

    function updateExchangePrice(uint256 exchangePrice_) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        require(exchangePrice_ >= exchangePrice);
        exchangePrice = exchangePrice_;

        // Event is emitted
    }

    function depositToMainnet() public returns(uint256 amount) {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        amount = UNDERLYING_TOKEN.balanceOf(address(this)) * 9 / 10;
        UNDERLYING_TOKEN.transfer(liteBridgeContract, amount); // Sends only 90% of the funds
        // Event is emitted
    }

    function withdrawFromMainnet(uint256 amount) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
       
        UNDERLYING_TOKEN.transferFrom(liteBridgeContract, address(this), amount);
        // Event is emitted
    }

}

contract UserModule is BridgeModule {

    function supply(
        uint256 amount_,
        address to_
    ) external returns (uint256 itokenAmount_) {
        itokenAmount_ = (amount_ * 1e18) / exchangePrice;
        UNDERLYING_TOKEN.transferFrom(msg.sender, address(this), amount_);
        _mint(to_, itokenAmount_);
        // emit event
    }

    function withdraw(
        uint256 amount_,
        address to_
    ) external returns (uint256 itokenAmount_) {
        itokenAmount_ = (amount_ * 1e18) / exchangePrice;
        _burn(to_, itokenAmount_);
        UNDERLYING_TOKEN.transfer(to_, amount_);
        // emit event
    }

}

contract LiteVaultChild is UserModule {

} 