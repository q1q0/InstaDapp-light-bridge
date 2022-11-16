// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Common.sol";

contract UserModule is BaseIToken {
    event supplyLog(address token_, uint256 amount_, address to_);
    event withdrawLog(uint256 amount_, address to_);

    using SafeERC20 for IERC20;

    constructor(address underlyingToken_, address liteBridgeContract_, bool isEthVault_) BaseIToken(underlyingToken_, liteBridgeContract_, isEthVault_){}

    function getCurrentExchangePrice() public view returns(uint256, uint256) {
        // add some updateExchange logic
        return (exchangePrice, 0);
    }

    function updateExchangePrice(uint256 exchangePrice_) public returns(uint256) {
        // add some updateExchange logic
        exchangePrice = exchangePrice_;
        return exchangePrice;
    }

    function updateExchangePrice() public returns(uint256) {
        // add some updateExchange logic
        exchangePrice = exchangePrice + 1e16;
        return exchangePrice;
    }

    function withdraw(uint256 amount, address to)
        external
        returns (uint256 vtokenAmount_)
    {
        if (amount == type(uint256).max) {
            vtokenAmount_ = balanceOf(msg.sender);
            amount = (vtokenAmount_ * exchangePrice) / 1e18;
        } else {
            vtokenAmount_ = (amount * 1e18) / exchangePrice;
        }

        _burn(msg.sender, vtokenAmount_);

        if(ETH_VAULT) {
            if (ratio == 0) {
                Address.sendValue(payable(msg.sender), amount);
            } else {
                uint256 stETHAmount = amount * ratio / 1e4;
                Address.sendValue(payable(msg.sender), amount - stETHAmount);
                Address.sendValue(payable(address(UNDERLYING_TOKEN)), stETHAmount);
                UNDERLYING_TOKEN.transfer(msg.sender, stETHAmount);
            }
        } else {
            UNDERLYING_TOKEN.transfer(msg.sender, amount);
        }
        emit withdrawLog(amount, to);
    }

    function supplyEth(address to_)
        external
        payable
        returns (uint256 vtokenAmount_)
    {   
        vtokenAmount_ = (msg.value * 1e18) / exchangePrice;
        _mint(to_, vtokenAmount_);
        emit supplyLog(address(UNDERLYING_TOKEN), msg.value, to_);
    }

    function supply(
        address token,
        uint256 amount,
        address to
    ) external returns (uint256 vtokenAmount_) {
        vtokenAmount_ = (amount * 1e18) / exchangePrice;
        _mint(to, vtokenAmount_);

        if (token != NATIVE_TOKEN) {
            UNDERLYING_TOKEN.safeTransferFrom(msg.sender, address(this), amount);
        }
        emit supplyLog(token, amount, to);
    }
}

contract MockLiteVaultRoot is UserModule {

    receive() external payable {}

    constructor(address underlyingToken_, address liteBridgeContract_, bool isEthVault_) UserModule(underlyingToken_, liteBridgeContract_, isEthVault_){}

} 