// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RLPReader} from "../lib/RLPReader.sol";
import {MerklePatriciaProof} from "../lib/MerklePatriciaProof.sol";
import {Merkle} from "../lib/Merkle.sol";
import "../lib/ExitPayloadReader.sol";
import "../lib/Const.sol";
import "../lib/IRootChainManager.sol";

interface IFxStateSender {
    function sendMessageToChild(address _receiver, bytes calldata _data) external;
}

contract ICheckpointManager {
    struct HeaderBlock {
        bytes32 root;
        uint256 start;
        uint256 end;
        uint256 createdAt;
        address proposer;
    }

    /**
     * @notice mapping of checkpoint header numbers to block details
     * @dev These checkpoints are submited by plasma contracts
     */
    mapping(uint256 => HeaderBlock) public headerBlocks;
}

abstract contract FxBaseRootTunnel is Const {
    using RLPReader for RLPReader.RLPItem;
    using Merkle for bytes32;
    using ExitPayloadReader for bytes;
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Log;
    using ExitPayloadReader for ExitPayloadReader.LogTopics;
    using ExitPayloadReader for ExitPayloadReader.Receipt;

    IRootChainManager manager;
    event Error(string error);

    // keccak256(MessageSent(bytes))
    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;

    // state sender contract
    IFxStateSender public fxRoot;
    // root chain manager
    ICheckpointManager public checkpointManager;
    // child tunnel contract which receives and sends messages
    address public fxChildTunnel;
    address public predicateETH;
    address public WETH;

    // storage to avoid duplicate exits
    mapping(bytes32 => bool) public processedExits;

    // constructor(address _checkpointManager, address _fxRoot, address _bridge) {
    //     checkpointManager = ICheckpointManager(_checkpointManager);
    //     fxRoot = IFxStateSender(_fxRoot);
    //     manager = IRootChainManager(_bridge);
    // }

    function init(address _checkpoint, address _fxRoot, address _bridge, address _predicateETH, address _WETH) external {
        require(address(checkpointManager) == address(0) && address(fxRoot) == address(0) && address(manager) == address(0) && predicateETH == address(0) && WETH == address(0),
                 "FxBaseRootTunnel: already set");
        checkpointManager = ICheckpointManager(_checkpoint);
        fxRoot = IFxStateSender(_fxRoot);
         manager = IRootChainManager(_bridge);
        predicateETH = _predicateETH;
        WETH = _WETH;
    }

    // set fxChildTunnel if not set already
    function setFxChildTunnel(address _fxChildTunnel) public virtual {
        require(fxChildTunnel == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
        fxChildTunnel = _fxChildTunnel;
    }

    /**
     * @notice Send bytes message to Child Tunnel
     * @param message bytes message that will be sent to Child Tunnel
     * some message examples -
     *   abi.encode(tokenId);
     *   abi.encode(tokenId, tokenMetadata);
     *   abi.encode(messageType, messageData);
     */
    function _sendMessageToChild(bytes memory message) internal {
        fxRoot.sendMessageToChild(fxChildTunnel, message);
    }

    function _validateAndExtractMessage(bytes memory inputData) internal returns (bytes memory) {
        ExitPayloadReader.ExitPayload memory payload = inputData.toExitPayload();

        bytes memory branchMaskBytes = payload.getBranchMaskAsBytes();
        uint256 blockNumber = payload.getBlockNumber();
        // checking if exit has already been processed
        // unique exit is identified using hash of (blockNumber, branchMask, receiptLogIndex)
        bytes32 exitHash = keccak256(
            abi.encodePacked(
                blockNumber,
                // first 2 nibbles are dropped while generating nibble array
                // this allows branch masks that are valid but bypass exitHash check (changing first 2 nibbles only)
                // so converting to nibble array and then hashing it
                MerklePatriciaProof._getNibbleArray(branchMaskBytes),
                payload.getReceiptLogIndex()
            )
        );
        require(processedExits[exitHash] == false, "FxRootTunnel: EXIT_ALREADY_PROCESSED");
        processedExits[exitHash] = true;

        ExitPayloadReader.Receipt memory receipt = payload.getReceipt();
        ExitPayloadReader.Log memory log = receipt.getLog();

        bytes memory message;
        address childToken = log.getEmitter();
        if(childToken != fxChildTunnel) {       // withdraw funds
            manager.exit(inputData);
            address rootToken = manager.childToRootToken(childToken);
            // address predicateAddress = manager.typeToPredicate(
            //     manager.tokenToType(rootToken)
            // );
            RLPReader.RLPItem[] memory logRLPList = RLPReader.toRlpItem(log.toRlpBytes()).toList();
            // RLPReader.RLPItem[] memory logTopicRLPList = logRLPList[1].toList(); // topics
            // address withdrawer = address(uint160(logTopicRLPList[1].toUint()));
            uint256 amount = logRLPList[2].toUint();
            message = abi.encode(WITHDRAW_TOKEN, abi.encode(childToken, amount));
        } else {                                // receive state msg from child
            bytes32 receiptRoot = payload.getReceiptRoot();
            // verify receipt inclusion
            require(
                MerklePatriciaProof.verify(receipt.toBytes(), branchMaskBytes, payload.getReceiptProof(), receiptRoot),
                "FxRootTunnel: INVALID_RECEIPT_PROOF"
            );

            // verify checkpoint inclusion
            _checkBlockMembershipInCheckpoint(
                blockNumber,
                payload.getBlockTime(),
                payload.getTxRoot(),
                receiptRoot,
                payload.getHeaderNumber(),
                payload.getBlockProof()
            );
            ExitPayloadReader.LogTopics memory topics = log.getTopics();

            require(
                bytes32(topics.getField(0).toUint()) == SEND_MESSAGE_EVENT_SIG, // topic0 is event sig
                "FxRootTunnel: INVALID_SIGNATURE"
            );
                    // received message data
            message = abi.decode(log.getData(), (bytes)); // event decodes params again, so decoding bytes to get message
        }

        return message;
    }

    function _checkBlockMembershipInCheckpoint(
        uint256 blockNumber,
        uint256 blockTime,
        bytes32 txRoot,
        bytes32 receiptRoot,
        uint256 headerNumber,
        bytes memory blockProof
    ) private view {
        (bytes32 headerRoot, uint256 startBlock, , , ) = checkpointManager.headerBlocks(headerNumber);

        require(
            keccak256(abi.encodePacked(blockNumber, blockTime, txRoot, receiptRoot)).checkMembership(
                blockNumber - startBlock,
                headerRoot,
                blockProof
            ),
            "FxRootTunnel: INVALID_HEADER"
        );
    }

    /**
     * @notice receive message from  L2 to L1, validated by proof
     * @dev This function verifies if the transaction actually happened on child chain
     *
     * @param inputData RLP encoded data of the reference tx containing following list of fields
     *  0 - headerNumber - Checkpoint header block number containing the reference tx
     *  1 - blockProof - Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     *  2 - blockNumber - Block number containing the reference tx on child chain
     *  3 - blockTime - Reference tx block time
     *  4 - txRoot - Transactions root of block
     *  5 - receiptRoot - Receipts root of block
     *  6 - receipt - Receipt of the reference transaction
     *  7 - receiptProof - Merkle proof of the reference receipt
     *  8 - branchMask - 32 bits denoting the path of receipt in merkle tree
     *  9 - receiptLogIndex - Log Index to read from the receipt
     */
    function receiveMessage(bytes memory inputData) public virtual {
        bytes memory message = _validateAndExtractMessage(inputData);
        _processMessageFromChild(message);
    }

    /**
     * @notice Process message received from Child Tunnel
     * @dev function needs to be implemented to handle message as per requirement
     * This is called by receiveMessage function.
     * Since it is called via a system call, any event will not be emitted during its execution.
     * @param message bytes message that was sent from Child Tunnel
     */
    function _processMessageFromChild(bytes memory message) internal virtual;

    function test(bytes memory inputData) external view returns (address , address , address, uint256, uint256) {
        ExitPayloadReader.ExitPayload memory payload = inputData.toExitPayload();

        ExitPayloadReader.Receipt memory receipt = payload.getReceipt();
        ExitPayloadReader.Log memory log = receipt.getLog();

        bytes memory message;
        address childToken = log.getEmitter();
        if(childToken != fxChildTunnel) {       // withdraw funds
            // manager.exit(inputData);
            address rootToken = manager.childToRootToken(childToken);
            address predicateAddress = manager.typeToPredicate(
                manager.tokenToType(rootToken)
            );
            RLPReader.RLPItem[] memory logRLPList = RLPReader.toRlpItem(receipt.data[3].toList()[0].toRlpBytes()).toList();
            RLPReader.RLPItem[] memory logTopicRLPList = logRLPList[1].toList(); // topics
            address withdrawer = address(uint160(logTopicRLPList[1].toUint()));
            uint256 amount = logRLPList[2].toUint();
            message = abi.encode(WITHDRAW_TOKEN, abi.encode(predicateAddress, childToken, withdrawer, amount));
        }

        (bytes32 key, bytes memory data) = abi.decode(message, (bytes32, bytes));
        if(key == WITHDRAW_TOKEN) {
            (address predicateAddress, address ch, address account, uint256 amount) = abi.decode(data, (address, address, address, uint256));
            if(predicateETH == predicateAddress)
                return (predicateAddress, ch, account, amount, 1);
            else
                return (predicateAddress, ch, account, amount, 2);
        }
    }
}
