// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// @title Polygon Lite vault

import "../lib/IToken.sol";

contract BridgeModule is Variables{
    constructor(string memory name_, string memory symbol_, address underlyingToken_) 
    Variables(name_, symbol_, underlyingToken_) {

    }

    function updateExchangePrice(uint256 exchangePrice_) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        require(exchangePrice_ >= exchangePrice);

        exchangePrice = exchangePrice_;

        // Event is emitted
    }

    function deposit(uint256 amount_) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
       
        UNDERLYING_TOKEN.transferFrom(liteBridgeContract, address(this), amount_);
        _mint(msg.sender, amount_);
        // Event is emitted
    }

    function withdrawFromMainnet() public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
       
        UNDERLYING_TOKEN.transfer(liteBridgeContract, UNDERLYING_TOKEN.balanceOf(address(this)));
        _burn(msg.sender, UNDERLYING_TOKEN.balanceOf(address(this)));
        // Event is emitted
    }

    function depositForETH() public payable {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        _mint(msg.sender, msg.value);
    }

    function withdrawForETH() public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        _burn(msg.sender, balance);
    }

}

contract LiteVaultRoot is BridgeModule {
    constructor(string memory name_, string memory symbol_, address underlyingToken_) 
    BridgeModule(name_, symbol_, underlyingToken_) {
        
    }

} 