// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IRootChainManager {
    function checkpointManagerAddress() external view returns (address);
    function depositEtherFor(address user) external payable;
    function exit(bytes calldata inputData) external;
    function childToRootToken(address) external view returns(address);
    function tokenToType(address) external view returns(bytes32);
    function typeToPredicate(bytes32) external view returns(address);
    function depositFor(
        address user,
        address rootToken,
        bytes calldata depositData
    ) external;
}
