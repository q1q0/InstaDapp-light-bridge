// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// @title Polygon Lite vault

import "./ERC20.sol";
// import "./IERC20.sol";

contract Variables is ERC20 {
    uint256 internal exchangePrice;
    IERC20 public UNDERLYING_TOKEN;
    address public liteBridgeContract;
    address public owner;
    bool internal isIETHContract;

    function setInit(address newOwner_, string memory name_, string memory symbol_, uint8 decimal_, address underlyingToken_, bool isIETH) external {
        require(owner == address(0), "already set");
        owner = newOwner_;
        _setupMetaData(name_,symbol_, decimal_);
        UNDERLYING_TOKEN = IERC20(underlyingToken_);
        isIETHContract = isIETH;
        exchangePrice = 1e18;
    }

    function transferOwnership(address newOnwer_) external {
        require(owner == msg.sender);
        owner = newOnwer_;
    }

    function setLiteBridgeContract(address liteBridgeContract_) external {
        liteBridgeContract = liteBridgeContract_;
    }
}