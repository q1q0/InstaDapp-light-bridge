// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IiETH {
    function depeg() external returns(uint256);
}

contract Mock1InchContract {
    using SafeERC20 for IERC20;

    IERC20 immutable public STETH_TOKEN;

    constructor(address stETH_) {
        STETH_TOKEN = IERC20(stETH_);
    }

    function swap(uint256 amount, address iETHVault) public {
        STETH_TOKEN.transferFrom(msg.sender, address(this), amount);
        uint256 depeg = IiETH(iETHVault).depeg();
        sendETH(
            amount * depeg / 1e4,
            msg.sender
        );
    }

    function send(uint256 amount, address to) public {
        STETH_TOKEN.transfer(to, amount);
    }

     function sendETH(uint256 amount, address to) public {
        Address.sendValue(payable(to), amount);
    }

    receive() external payable {}
} 