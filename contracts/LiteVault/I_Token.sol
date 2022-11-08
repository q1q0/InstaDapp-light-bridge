// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// @title Polygon Lite vault

// import "./ERC20.sol";
// import "./IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VariableForVault} from "../Variable.sol";

contract I_Token is ERC20Upgradeable, OwnableUpgradeable, VariableForVault {

    function initialize(string memory name_, string memory symbol_, address underlyingToken_, bool isIETH) external initializer {
        __ERC20_init(name_,symbol_);
        UNDERLYING_TOKEN = IERC20(underlyingToken_);
        isIETHContract = isIETH;
        exchangePrice = 1e18;
        __Ownable_init();
    }

    function setLiteBridgeContract(address liteBridgeContract_) external onlyOwner {
        liteBridgeContract = liteBridgeContract_;
    }
}