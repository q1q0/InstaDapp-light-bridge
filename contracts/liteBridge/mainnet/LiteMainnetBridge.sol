// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Variables.sol";
import "./interface/IiToken.sol";


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

    function transferOwnership(address newOwner) public override virtual onlyOwner {
        toggleRebalancer(owner(), false);
        super.transferOwnership(newOwner);
        toggleRebalancer(newOwner, true);
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

    event LogDepositToVault(
        address indexed vault,
        address indexed token,
        uint256 amount
    );

    event LogFromPolygon(
        address indexed token,
        uint256 amount
    );


    function depositToVaultFromPolygon(
        bytes memory polygonExitData,
        address vault,
        address token,
        uint256 amount
    ) external /* onlyRebalancer */ {
        rootChainManager.exit(polygonExitData);
        emit LogFromPolygon(token, amount); // TODO later: use RLP decoding to find out the token and amount from input data
        depositToVault(vault, token, amount);
    }

    function depositToVault(
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

        emit LogDepositToVault(
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

    function updateExchangePrice(
        address rootVault,
        address childVault
    ) public onlyRebalancer {
        ExchangePriceData memory exchangePriceData;

        require(rootToChainVault[rootVault] == childVault, "LBM:[updateExchangeRate]:: root to child are not same");

                                                    // mock 
                                                    IiTokenVault(rootVault).updateExchangePrice();
                                                    // mock

        (exchangePriceData.exchangePrice, ) = IiTokenVault(rootVault).getCurrentExchangePrice();
        exchangePriceData.rootVault = rootVault;
        exchangePriceData.childVault = childVault;
        _sendMessageToChild(
            abi.encode(
                UPDATE_EXCHANGE_PRICE_SINGLE,
                ++bridgeNonce,
                abi.encode(exchangePriceData)
            )
        );
        emit LogUpdateExchangePrice(
            bridgeNonce,
            rootVault,
            childVault,
            exchangePriceData.exchangePrice
        );
    }

    // @notice onlyRebalancer - is ran inside withdrawToPolygon function
    function updateExchangePrice(
        UpdateExchangePriceParams[] memory updateExchangePriceParams
    ) external {
        uint256 length_ = updateExchangePriceParams.length;
        for(uint256 i = 0; i < length_; i++) {
            UpdateExchangePriceParams memory updateExchangePriceParams_ = updateExchangePriceParams[i];
            updateExchangePrice(updateExchangePriceParams_.rootVault, updateExchangePriceParams_.childVault);
        }
    }

    event LogWithdrawToPolygon(
        uint256 indexed bridgeNonce,
        address indexed rootVault,
        address indexed childVault,
        address token,
        uint256 amount
    );

    function withdrawToPolygon(
        address rootVault,
        address childVault,
        address token, 
        uint256 amount,
        bytes memory oneInchSwapCalldata
    ) public onlyRebalancer returns(uint256 iTokenAmount) {
        require(rootToChainVault[rootVault] == childVault, "LBM:[withdraw]:: root to child are not same");

        iTokenAmount = IiTokenVault(rootVault).withdraw(amount, address(this));
        uint256 amount_ = amount;
        if(token == NATIVE_TOKEN) {
            uint256 stETHBalance_ = stETH.balanceOf(address(this));
            uint256 ethBalance_ = address(this).balance;
            if (stETHBalance_ > 0) {
                stETH.safeApprove(oneInchAddress, stETHBalance_);

                // Address.functionCall(oneInchAddress, abi.encodeWithSignature("swap(uint256,address)", stETHBalance_, rootVault), "LBM:[withdraw]:: steth-1inch-swap-failed"); // MOCK
                
                Address.functionCall(oneInchAddress, oneInchSwapCalldata, "LBM:[withdraw]:: steth-1inch-swap-failed");

                uint256 ethBalanceAfterSwap_ = address(this).balance;
                uint256 ethAmountFromSwap_ = ethBalanceAfterSwap_ - ethBalance_;
                ethBalance_ = ethBalanceAfterSwap_;

                uint256 depegPercentage_ = ethAmountFromSwap_ * 1e4 / stETHBalance_;

                require(depegPercentage_ >= 0.90 * 1e4, "steth-high-depeg"); // 10% depeg  // TODO: add better logics later
            }
            amount_ = ethBalance_;

            rootChainManager.depositEtherFor{value: ethBalance_}(address(this));
        } else {
            IERC20(token).safeApprove(address(rootChainManager), amount);
            rootChainManager.depositFor(address(this), token, abi.encode(amount));
        }

        WithdrawData memory withdrawData_ = WithdrawData(
            rootVault,
            childVault,
            token,
            rootChainManager.rootToChildToken(token),
            amount_
        );

        _sendMessageToChild(
            abi.encode(
                WITHDRAW_SINGLE,
                ++bridgeNonce,
                abi.encode(withdrawData_)
            )
        );

        emit LogWithdrawToPolygon(
            bridgeNonce,
            rootVault,
            childVault,
            token,
            amount_
        );
    }  

    // @notice onlyRebalancer - is ran inside withdrawToPolygon function
    function batchWithdrawToPolygon(BatchWithdrawParams[] memory batchWithdrawParams) external returns(uint256[] memory iTokenAmounts) {
        uint256 length_ = batchWithdrawParams.length;
        iTokenAmounts = new uint256[](length_);
        for (uint256 i = 0; i < length_; i++) {
            BatchWithdrawParams memory batchWithdrawParams_ = batchWithdrawParams[i];
            iTokenAmounts[i] = withdrawToPolygon(
                batchWithdrawParams_.rootVault,
                batchWithdrawParams_.childVault,
                batchWithdrawParams_.token,
                batchWithdrawParams_.amount,
                batchWithdrawParams_.oneInchSwapCalldata
            );
        }
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

    function initialize(address owner_) public initializer {
        __Ownable_init();
        toggleRebalancer(owner_, true);
        _transferOwnership(owner_);
    }
}
