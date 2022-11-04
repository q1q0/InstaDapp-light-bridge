
pragma solidity ^0.8.11;

// @title Polygon Lite vault

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Variables is ERC20, Ownable {
    using SafeERC20 for IERC20;

    uint256 internal exchangePrice = 1e18;
    IERC20 immutable public UNDERLYING_TOKEN;
    address public liteBridgeContract;

    constructor(string memory name_, string memory symbol_, address underlyingToken_) ERC20(name_, symbol_){
        UNDERLYING_TOKEN = IERC20(underlyingToken_);
    }

    function setLiteBridgeContract(address liteBridgeContract_) external onlyOwner {
        liteBridgeContract = liteBridgeContract_;
    }
}