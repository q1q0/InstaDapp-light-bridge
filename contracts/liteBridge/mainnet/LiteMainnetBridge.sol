// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Variables.sol";
import "./interface/IiToken.sol";

/*
 - Fix all the compiler errors
 - Add Ownable logics
 - Add admin functions
 - Add onlyRebalancer modifier
 - Add events
 - Fill IiToken interface file
*/


contract AdminModule is VariablesV1 {
    // Add function to add RootToChain Mapping
    // Add function to add rebalancer Mapping

     function setRebalancer(address _account, bool flag) external /* onlyOwner */ {
        rebalancer[_account] = flag;
    }

    constructor(
        address _rootChainManager,
        address _fxRoot
    ) VariablesV1 (
        _rootChainManager,
        _fxRoot
    ) {}
}

contract LiteMainnetBridge is AdminModule {
    using SafeERC20 for IERC20 ;

    function _sendMessageToChild(bytes memory message) internal {
        fxRoot.sendMessageToChild(address(this), message);
    }

    function deposit( // rename function
        bytes memory inputData,
        address vault,
        address token,
        uint256 amount
    ) external /* onlyRebalancer */ {
        rootChainManager.exit(inputData);

        if (token == NATIVE_TOKEN) {
            // deposit into weth
            // give allowance
        } else {
            // give allowance
        }


        uint256 iTokenAmount_ = IiTokenVault(vault).supply(token, amount, address(this));
        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    function depositToVault( // rename function
        address vault,
        address token,
        uint256 amount
    ) external /* onlyRebalancer */ {
        if (token == NATIVE_TOKEN) {
            // deposit into weth
            // give allowance
        } else {
            // give allowance
        }

        uint256 iTokenAmount_ = IiTokenVault(vault).supply(token, amount, address(this));

        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    function updateExchangeRate(
        address[] memory rootVaults
    ) external /* onlyRebalancer */ {
        uint256 length_ = rootVaults.length;
        ExchangePriceData[] memory exchangePrices_ = new ExchangePriceData[](length_);
        for(uint256 i = 0; i < length_; i++) {
            address rootVault_ = rootVaults[i];
            (exchangePrices_[i].exchangePrice, ) = IiTokenVault(rootVault_).getCurrentExchangePrice();
            exchangePrices_[i].rootVault = rootVault_;
            exchangePrices_[i].childVault = rootToChainVault[rootVault_];
        }
        _sendMessageToChild(
            abi.encode(
                UPDATE_EXCHANGE_PRICE,
                1,
                abi.encode(exchangePrices_)
            )
        );

        // emit event
    }

    function withdraw(
        address[] memory rootVaults,
        address[] memory tokens,
        uint256[] memory amounts
    ) external {
        uint256 length_ = rootVaults.length;
        for(uint256 i = 0; i < length_; i++) {
            address rootVault_ = rootVaults[i];
            uint256 amount_ = amounts[i];
            address token_ = tokens[i];
            IiTokenVault(rootVault_).withdraw(amount_, address(this));
            if(token_ == NATIVE_TOKEN) {
                // Check balance of wETH and stETH
                // Convert wETH and stETH into ETH
                uint256 ethAmount = 0; // balance of wETH and stETH
                rootChainManager.depositEtherFor{value: amount_}(address(this));
            } else {
                // Approve
                rootChainManager.depositFor(address(this), token_, abi.encode(amount_));
            }
        }
        
        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    receive() external payable {}

    constructor(
        address _rootChainManager,
        address _fxRoot
    ) AdminModule (
        _rootChainManager,
        _fxRoot
    ) {}
}
