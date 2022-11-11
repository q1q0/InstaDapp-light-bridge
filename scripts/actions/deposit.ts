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

    const wethContract = await ethers.getContractAt("IERC20", CONFIG.WETH_ADDRESS[chainId])
    const mockLiteVaultChild = await ethers.getContractAt("MockLiteVaultChild", CONFIG.MOCK_VAULT[chainId])    
    const litePolygonBridge = await ethers.getContractAt("LitePolygonBridge", CONFIG.LITE_BRIDGE[chainId])    
    const amount = "100000000000000"

    let tx = await waitTx(wethContract.approve(mockLiteVaultChild.address, amount))
    tx = await waitTx(mockLiteVaultChild.supply(amount, signer.address))

    console.log("Deposited Transaction", tx)

    tx = await waitTx(litePolygonBridge.processToMainnet(CONFIG.MOCK_VAULT[chainId], CONSTANTS.nativeToken, amount))

    console.log("Burn Transaction", tx)
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
