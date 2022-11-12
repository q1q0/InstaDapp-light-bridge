import hre from "hardhat";
import {ethers} from "hardhat";


import CONFIG from "../common/config"
import {
    getChainId,
    deployContract,
    waitTx,
    CONSTANTS,
    getMode,
    Mode,
    getChildChainId
} from "../common/utlis"

async function main() {

    const chainId = await getChainId();
    const childChainId = await getChildChainId()
    const signer = (await ethers.getSigners())[0]

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

    const liteMainnetBridge = await ethers.getContractAt("LiteMainnetBridge", CONFIG.LITE_BRIDGE[chainId])    

    // const lengthOfVaults = 5
    // let tx = await waitTx(liteMainnetBridge.updateExchangeRate(
    //     Array(lengthOfVaults).fill(CONFIG.MOCK_VAULT_ETH[chainId]),
    //     Array(lengthOfVaults).fill(CONFIG.MOCK_VAULT_ETH["80001"])
    // ))

    let tx = await waitTx(liteMainnetBridge.updateExchangeRate(
        [CONFIG.MOCK_VAULT_ETH[chainId], CONFIG.MOCK_VAULT_TOKEN[chainId]],
        [CONFIG.MOCK_VAULT_ETH[childChainId], CONFIG.MOCK_VAULT_TOKEN[childChainId]],
    ))
    console.log("Updated ExchangePrice Transaction", tx)
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
