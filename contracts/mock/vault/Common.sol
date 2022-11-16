// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// @title Polygon Lite vault

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseIToken is ERC20Upgradeable {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IERC20 public immutable UNDERLYING_TOKEN;
    address public immutable LITE_BRIDGE_CONTRACT;
    bool public immutable ETH_VAULT;
    
    uint256 public exchangePrice;

    uint256 public investedAssets;

    uint256 public depeg;
    uint256 public ratio;

    constructor(address underlyingToken_, address liteBridgeContract_, bool isEthVault_) {
        UNDERLYING_TOKEN = IERC20(underlyingToken_);
        _disableInitializers();
        LITE_BRIDGE_CONTRACT = liteBridgeContract_;
        ETH_VAULT = isEthVault_;
    }

    function initialize(string memory name_, string memory symbol_) external initializer {
        __ERC20_init(name_,symbol_);
        exchangePrice = 1e18;
    }

    function updateDepeg(uint256 depeg_, uint256 ratio_) public {
        depeg = depeg_;
        ratio = ratio_;
    }
}