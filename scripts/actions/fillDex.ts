import hre from "hardhat";
import {ethers} from "hardhat";


import CONFIG from "../common/config"
import {
    getChainId,
    deployContract,
    waitTx,
    CONSTANTS
} from "../common/utlis"

async function main() {

    const chainId = await getChainId();
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

    const amount = 0.01
    const amountInWei = ethers.utils.parseEther(amount.toString())

    const to = CONFIG.MOCK_DEX[chainId]
    // const to = CONFIG.MOCK_VAULT_ETH[chainId]

    let tx = await waitTx(signer.sendTransaction({
        value: amountInWei,
        to
    }))
    console.log("Funds Transferred", tx)
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
