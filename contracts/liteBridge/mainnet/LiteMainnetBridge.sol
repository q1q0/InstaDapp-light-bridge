// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Variables.sol";
import "./interface/IiToken.sol";

/*
 - Add Ownable logics
*/


contract AdminModule is VariablesV1 {
    event LogToggleRootToChildVaultMap(
        address indexed rootVault,
        address indexed childVault,
        bool indexed add
    );

    event LogToggleRebalancer(
        address indexed rebalancer,
        bool indexed add
    );

    modifier onlyRebalancer() {
        require(rebalancer[msg.sender], "LBM: not a rebalancer");
        _;
    }

    function toggleRootToChildVaultMap(
        address rootVault,
        address childVault,
        bool add
    ) public /* onlyOwner */ {
        if (add) {
            require(rootToChainVault[rootVault] == address(0), "LBM:[toggleRootToChainMap]:: Root to Child Mapping already added");
            rootToChainVault[rootVault] = childVault;
        } else {
            require(rootToChainVault[rootVault] != address(0), "LBM:[toggleRootToChainMap]:: Root to Child Mapping not added");
            delete rootToChainVault[rootVault];
        }

        emit LogToggleRootToChildVaultMap(
            rootVault,
            childVault,
            add
        );
    }

    function toggleRebalancer(
        address rebalancerAddress,
        bool add
    ) public /* onlyOwner */ {
        if (add) {
            require(!rebalancer[rebalancerAddress], "LBM:[toggleRebalancer]:: rebalancerAddress already enabled");
            rebalancer[rebalancerAddress] = add;
        } else {
            require(rebalancer[rebalancerAddress], "LBM:[toggleRebalancer]::rebalancerAddress not enabled");
            rebalancer[rebalancerAddress] = add;
        }

        emit LogToggleRebalancer(
            rebalancerAddress,
            add
        );
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

    event LogDeposit(
        address indexed vault,
        address indexed token,
        uint256 amount
    );


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

        emit LogDeposit(
            vault,
            token,
            amount
        );
    }

    event LogUpdateExchangePrice(
        uint256 indexed bridgeNonce,
        address indexed rootVault,
        address indexed childVault,
        uint256 exchangePrice
    );

    function updateExchangeRate(
        address[] memory rootVaults,
        address[] memory childVaults
    ) external /* onlyRebalancer */ {
        uint256 length_ = rootVaults.length;
        for(uint256 i = 0; i < length_; i++) {
            address rootVault_ = rootVaults[i];
            address childVault_ = childVaults[i];
            ExchangePriceData memory exchangePriceData;

            require(rootToChainVault[rootVault_] == childVault_, "LBM:[updateExchangeRate]:: root to child are not same");

                                                        // mock 
                                                        IiTokenVault(rootVault_).updateExchangePrice();
                                                        // mock

            (exchangePriceData.exchangePrice, ) = IiTokenVault(rootVault_).getCurrentExchangePrice();
            exchangePriceData.rootVault = rootVault_;
            exchangePriceData.childVault = childVault_;
            _sendMessageToChild(
                abi.encode(
                    UPDATE_EXCHANGE_PRICE_SINGLE,
                    ++bridgeNonce,
                    abi.encode(exchangePriceData)
                )
            );
            emit LogUpdateExchangePrice(
                bridgeNonce,
                rootVault_,
                childVault_,
                exchangePriceData.exchangePrice
            );
        }
    }

    event LogWithdrawToPolygon(
        uint256 indexed bridgeNonce,
        address indexed rootVault,
        address indexed childVault,
        address token,
        uint256 amount
    );

    function withdraw(
        address[] memory rootVaults,
        address[] memory childVaults,
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
                    Address.functionCall(oneInchAddress, abi.encodeWithSignature("swap(uint256,address)", stETHBalance_, rootVault_), "steth-1inch-swap-failed"); // MOCK
                    // Address.functionCall(oneInchAddress, oneInchSwapCalldata, "steth-1inch-swap-failed");
                    

                    uint256 ethBalanceAfterSwap_ = address(this).balance;
                    uint256 ethAmountFromSwap_ = ethBalanceAfterSwap_ - ethBalance_;
                    ethBalance_ = ethBalanceAfterSwap_;

                    uint256 depegPercentage_ = ethAmountFromSwap_ * 1e4 / stETHBalance_;

                    require(depegPercentage_ >= 0.995 * 1e4, "steth-high-depeg"); // 0.5% depeg  // TODO: move it
                }
                amount_ = ethBalance_;

                rootChainManager.depositEtherFor{value: ethBalance_}(address(this));
            } else {
                IERC20(token_).safeApprove(address(rootChainManager), amount_);
                rootChainManager.depositFor(address(this), token_, abi.encode(amount_));
            }

            _sendMessageToChild(
                abi.encode(
                    WITHDRAW_SINGLE,
                    ++bridgeNonce,
                    abi.encode(0x00)
                )
            );

            emit LogWithdrawToPolygon(
                bridgeNonce,
                rootVault_,
                childVaults[i],
                token_,
                amount_
            );
        }
        
        // optional - send exchangeRate to polygon of the vault
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
