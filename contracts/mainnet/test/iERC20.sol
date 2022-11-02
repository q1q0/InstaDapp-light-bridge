
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Variables is ERC20 {
    using SafeERC20 for IERC20;

    uint256 internal exchangePrice = 1e18;
    IERC20 immutable UNDERLYING_TOKEN;
    address liteBridgeContract;

    constructor(string memory name_, string memory symbol_, address underlyingToken_, address liteBridgeContract_) ERC20(name_, symbol_){
        UNDERLYING_TOKEN = IERC20(underlyingToken_);
        liteBridgeContract = liteBridgeContract_;
    }
}

contract BridgeModule is Variables{
    constructor(string memory name_, string memory symbol_, address underlyingToken_,  address liteBridgeContract_) Variables(name_, symbol_, underlyingToken_) {

    }

    function updateExchangePrice(uint256 exchangePrice_) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
        require(exchangePrice_ >= exchangePrice);

        exchangePrice = exchangePrice_;

        // Event is emitted
    }

    function depositToMainnet() public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
       
        UNDERLYING_TOKEN.transfer(liteBridgeContract, UNDERLYING_TOKEN.balanceOf(address(this)) * 9 / 10); // Sends only 90% of the funds
        // Event is emitted
    }

    function withdrawFromMainnet(uint256 amount) public {
        require(msg.sender == liteBridgeContract, "not-bridge-contract");
       
        UNDERLYING_TOKEN.transferFrom(liteBridgeContract, address(this), amount);
        // Event is emitted
    }

}

contract UserModule is BridgeModule {

    constructor(string memory name_, string memory symbol_, address underlyingToken_,  address liteBridgeContract_) BridgeModule(name_, symbol_, underlyingToken_, liteBridgeContract_) {
        
    }

    function supply(
        uint256 amount_,
        address to_
    ) external returns (uint256 itokenAmount_) {
        itokenAmount_ = (amount_ * 1e18) / exchangePrice;
        UNDERLYING_TOKEN.safeTransferFrom(msg.sender, address(this), amount_);
        _mint(to_, itokenAmount_);
        // emit event
    }

    function withdraw(
        uint256 amount_,
        address to_
    ) external returns (uint256 itokenAmount_) {
        itokenAmount_ = (amount_ * 1e18) / exchangePrice;
        _burn(to_, itokenAmount_);
        UNDERLYING_TOKEN.safeTransfer(to_, amount_);
        // emit event
    }

}

contract LiteVault is UserModule {
    constructor(string memory name_, string memory symbol_, address underlyingToken_,  address liteBridgeContract_) UserModule(name_, symbol_, underlyingToken_, liteBridgeContract_) {
        
    }

} 