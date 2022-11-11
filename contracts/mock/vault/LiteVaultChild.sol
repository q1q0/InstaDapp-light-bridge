// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// @title Polygon Lite vault

import "./Common.sol";

abstract contract BridgeModule is BaseIToken {
    constructor(address underlyingToken_, address liteBridgeContract_, bool isEthVault_) BaseIToken(underlyingToken_, liteBridgeContract_, isEthVault_){}


    function updateExchangePrice(uint256 exchangePrice_) public {
        require(msg.sender == LITE_BRIDGE_CONTRACT, "not-bridge-contract");
        require(exchangePrice_ >= exchangePrice);
        exchangePrice = exchangePrice_;

        // Event is emitted
    }

    function toMainnet(uint256 amount) public {
        // require(msg.sender == LITE_BRIDGE_CONTRACT, "not-bridge-contract"); // TODO: add this
        UNDERLYING_TOKEN.transfer(msg.sender, amount);
        // Event is emitted
    }

    function fromMainnet(uint256 amount) public {
        // require(msg.sender == LITE_BRIDGE_CONTRACT, "not-bridge-contract"); // TODO: add this
       
        UNDERLYING_TOKEN.transferFrom(msg.sender, address(this), amount);
        // Event is emitted
    }

}

contract UserModule is BridgeModule {
    constructor(address underlyingToken_, address liteBridgeContract_, bool isEthVault_) BridgeModule(underlyingToken_, liteBridgeContract_, isEthVault_){}

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

contract MockLiteVaultChild is UserModule {
    constructor(address underlyingToken_, address liteBridgeContract_, bool isEthVault_) UserModule(underlyingToken_, liteBridgeContract_, isEthVault_){}
 

} 