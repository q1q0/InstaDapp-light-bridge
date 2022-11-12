// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Variables.sol";
import "./interface/IiToken.sol";

/*
 - Add Ownable logics
 - Add admin functions
 - Add onlyRebalancer modifier
 - Add events
*/


contract AdminModule is VariablesV1 {
    // Add function to add RootToChain Mapping
    // Add function to add rebalancer Mapping

     function setRebalancer(address _account, bool flag) external /* onlyOwner */ {
        rebalancer[_account] = flag;
    }

    constructor(
        address _rootChainManager,
        address _fxRoot,
        address _wETH,
        address _stETH,
        address _oneInchAddress
    ) VariablesV1 (
        _rootChainManager,
        _fxRoot,
        _wETH,
        _stETH,
        _oneInchAddress
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
        depositToVault(vault, token, amount);
    }

    function depositToVault( // rename function
        address vault,
        address token,
        uint256 amount
    ) public /* onlyRebalancer */ {
        uint256 iTokenAmount_;
        if (token == NATIVE_TOKEN) {
            iTokenAmount_ = IiTokenVault(vault).supplyEth{value: amount}(address(this));
        } else {
            IERC20(token).safeApprove(vault, amount);
            iTokenAmount_ = IiTokenVault(vault).supply(token, amount, address(this));
        }


        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    event LogUpdateExchangePrice(
        uint256 indexed bridgeNonce,
        address indexed rootVault,
        address indexed childVault,
        uint256 exchangePrice
    );

    function updateExchangeRate(
        address[] memory rootVaults,
        address[] memory rootToChainVaults
    ) external /* onlyRebalancer */ {
        uint256 length_ = rootVaults.length;
        ExchangePriceData[] memory exchangePrices_ = new ExchangePriceData[](length_);
        for(uint256 i = 0; i < length_; i++) {
            address rootVault_ = rootVaults[i];
            ExchangePriceData memory exchangePriceData;
            // mock 
            IiTokenVault(rootVault_).updateExchangePrice();
            // mock
            (exchangePriceData.exchangePrice, ) = IiTokenVault(rootVault_).getCurrentExchangePrice();
            exchangePriceData.rootVault = rootVault_;
            // exchangePriceData.childVault = rootToChainVault[rootVault_]; // TODO:
            exchangePriceData.childVault = rootToChainVaults[i];
            _sendMessageToChild(
                abi.encode(
                    UPDATE_EXCHANGE_PRICE,
                    ++bridgeNonce,
                    abi.encode(exchangePriceData)
                )
            );
            emit LogUpdateExchangePrice(
                bridgeNonce,
                rootVault_,
                rootToChainVaults[i],
                exchangePriceData.exchangePrice
            );
        }

        // emit event
    }

    function withdraw(
        address[] memory rootVaults,
        address[] memory tokens,
        uint256[] memory amounts,
        bytes memory oneInchSwapCalldata
    ) external {
        uint256 length_ = rootVaults.length;
        for(uint256 i = 0; i < length_; i++) {
            address rootVault_ = rootVaults[i];
            address token_ = tokens[i];
            uint256 amount_ = amounts[i];
            IiTokenVault(rootVault_).withdraw(amount_, address(this));
            if(token_ == NATIVE_TOKEN) {
                uint256 stETHBalance_ = stETH.balanceOf(address(this));
                uint256 ethBalance_ = address(this).balance;
                if (stETHBalance_ > 0) {
                    // TODO: swap and depeg logics
                    stETH.safeApprove(oneInchAddress, stETHBalance_);
                    Address.functionCall(oneInchAddress, oneInchSwapCalldata, "steth-1inch-swap-failed");

                    uint256 ethBalanceAfterSwap_ = address(this).balance;
                    uint256 ethAmountFromSwap_ = ethBalanceAfterSwap_ - ethBalance_;
                    ethBalance_ = ethBalanceAfterSwap_;

                    uint256 depegPercentage_ = ethAmountFromSwap_ * 1e4 / stETHBalance_;

                    require(depegPercentage_ >= 0.995 * 1e4, "steth-high-depeg"); // 0.5% depeg  // TODO: move it
                }

                rootChainManager.depositEtherFor{value: ethBalance_}(address(this));
            } else {
                IERC20(token_).safeApprove(address(rootChainManager), amount_);
                rootChainManager.depositFor(address(this), token_, abi.encode(amount_));
            }
        }
        
        // optional - send exchangeRate to polygon of the vault

        // emit event
    }

    receive() external payable {}

    constructor(
        address _rootChainManager,
        address _fxRoot,
        address _wETH,
        address _stETH,
        address _oneInchAddress
    ) AdminModule (
        _rootChainManager,
        _fxRoot,
        _wETH,
        _stETH,
        _oneInchAddress
    ) {}
}
