import hre from "hardhat";
import {ethers} from "hardhat";

import CONFIG from "../common/config"
import {
    getChainId,
    deployContract,
    waitTx,
    CONSTANTS
} from "../common/utlis"

import { POSClient,use , setProofApi} from "@maticnetwork/maticjs"
import { Web3ClientPlugin } from '@maticnetwork/maticjs-ethers'

use(Web3ClientPlugin)
setProofApi("https://apis.matic.network/")

async function main() {

    const chainId = await getChainId();

    if (hre.network.name === 'mainnet') {
        console.log(
        '\n\n Deploying Contracts to mainnet. Hit ctrl + c to abort'
        )
    } else if (hre.network.name === 'matic') {
        console.log(
        '\n\n Deploying Contracts to polygon. Hit ctrl + c to abort'
        )
    } else if (hre.network.name === 'avax') {
        console.log(
        '\n\n Deploying Contracts to avax. Hit ctrl + c to abort'
        )
    } else if (hre.network.name === 'hardhat') {
        console.log(
        '\n\n Deploying Contracts to hardhat.'
        )
    }

    const burnTransactionHash = "0xc5fe2b9413adea120dbea8b88ef3445337103489d374f28ee7a060d9919170c4"
    const signer = (await ethers.getSigners())[0]
    const liteMainnetBridge = await ethers.getContractAt("LiteMainnetBridge", CONFIG.LITE_BRIDGE[chainId])
    const mainnetProvider = ethers.provider
    
    const polygonProvider = new ethers.providers.JsonRpcProvider(
        // @ts-ignore
        chainId === "1" ?  hre.userConfig.networks.polygon.url : hre.userConfig.networks.mumbai.url
    );    
    
    const posClient = new POSClient();
    await posClient.init({
        network: chainId === "1" ? "mainnet" : 'testnet',
        version: chainId === "1" ? "v1" : 'mumbai',
        parent: {
            provider: ethers.provider,
            defaultConfig: {
                from: signer.address
            }
        },
        child: {
            provider: polygonProvider,
            defaultConfig: {
                from: signer.address
            }
        }
    });
    
    
    const proof = await posClient.exitUtil.buildPayloadForExit(
        burnTransactionHash,
        "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
        false
    )

    const amount = "100000000000000"
    
    const txHash = await waitTx(liteMainnetBridge.deposit(
        proof,
        CONFIG.MOCK_VAULT_ETH[chainId],
        CONSTANTS.nativeToken,
        amount
    ))
    console.log("Deposit Transaction: ", txHash)

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
