// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract LiteBridgeChild is TransparentUpgradeableProxy {
    constructor(address _logic, bytes memory _data)
        TransparentUpgradeableProxy(_logic, msg.sender, _data)
    {}
}