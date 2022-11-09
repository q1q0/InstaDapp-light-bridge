// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IFxStateSender {
    function sendMessageToChild(address _receiver, bytes calldata _data) external;
}
