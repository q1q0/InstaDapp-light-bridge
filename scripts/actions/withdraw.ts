import hre from "hardhat";
import {ethers} from "hardhat";


import CONFIG from "../common//config"
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
    const mockLiteVaultRoot = await ethers.getContractAt("MockLiteVaultRoot", CONFIG.MOCK_VAULT_ETH[chainId])    
    const liteMainnetBridge = await ethers.getContractAt("LiteMainnetBridge", CONFIG.LITE_BRIDGE[chainId])    


    const amount = ethers.BigNumber.from(await mockLiteVaultRoot.balanceOf(liteMainnetBridge.address)).mul(99).div(100)


    let txHash = await waitTx(
        liteMainnetBridge.withdraw(
            [CONFIG.MOCK_VAULT_ETH[chainId]],
            [CONSTANTS.nativeToken],
            [amount],
            "0x"
        )
    )

    console.log("Moving funds to Polygon Transaction", txHash)
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
