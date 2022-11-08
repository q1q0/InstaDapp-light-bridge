// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token//ERC20/utils/SafeERC20.sol";

import "./Variables.sol";
import "./interface/IiToken.sol";


contract LiteMainnetBridge is VariablesV1 {
    using IERC20 for SafeERC20;

    function _sendMessageToChild(bytes memory message) internal {
        fxRoot.sendMessageToChild(address(this), message);
    }

    function deposit( // rename function
        bytes memory inputData,
        address vault,
        address token,
        uint256 amount
    ) external onlyRebalancer {
        rootChainManager.exit(inputData);

        if (token == ethAddress) {
            // deposit into weth
            // give allowance
        } else {
            // give allowance
        }

        uint256 iTokenAmount_ = IiTokenVault(vault).supply(token, amount);

        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    function depositToVault( // rename function
        address vault,
        address token,
        uint256 amount
    ) external onlyRebalancer {
        if (token == ethAddress) {
            // deposit into weth
            // give allowance
        } else {
            // give allowance
        }

        uint256 iTokenAmount_ = IiTokenVault(vault).supply(token, amount);

        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    function updateExchangeRate(
        address[] memory rootVaults
    ) external onlyRebalancer {
        uint256 length_ = rootVaults.length;
        ExchangePriceData[] memory exchangePrices_ = new ExchangePriceData[](length_);
        for(uint256 i = 0; i < length_; i++) {
            address rootVault_ = rootVaults[i];
            (exchangePrices_.exchangePrice, ) = IiTokenVault(rootVault_).getCurrentExchangePrice();
            exchangePrices_.rootVault = rootVault_;
            exchangePrices_.childVault = rootToChainVault[rootVault_];
        }
        _sendMessageToChild(
            abi.encode(
                UPDATE_EXCHANGE_PRICE,
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
            address amount_ = amounts[i];
            address token_ = tokens[i];
            (address rootToken, uint256 amount) = IiTokenVault(rootVault_).withdraw();
            if(token_ == ethAddress) {
                // Check balance of wETH and stETH
                // Convert wETH and stETH into ETH
                uint256 ethAmount = 0; // balance of wETH and stETH
                rootChainManager.depositEtherFor{value: amount_}(address(this));
            } else {
                // Approve
                manager.depositFor(address(this), token_, abi.encode(amount_));
            }
        }
        
        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    receive() external payable {}
}
