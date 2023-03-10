// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.17;

// interface IRootChainManager {
//     function checkpointManagerAddress() external view returns (address);
//     function depositEtherFor(address user) external payable;
//     function exit(bytes calldata inputData) external;
//     function childToRootToken(address) external view returns(address);
//     function tokenToType(address) external view returns(bytes32);
//     function typeToPredicate(bytes32) external view returns(address);
//     function depositFor(
//         address user,
//         address rootToken,
//         bytes calldata depositData
//     ) external;
// }

// interface IChildChainManager {
//     function withdraw(uint256 amount) external;
//     function transferFrom(address sender, address recipient, uint256 amount) external;
//     function balanceOf(address account) external view returns(uint256);
// }

