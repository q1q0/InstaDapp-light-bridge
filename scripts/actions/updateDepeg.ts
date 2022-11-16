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

    const mockLiteVaultRoot = await ethers.getContractAt("MockLiteVaultRoot", CONFIG.MOCK_VAULT_ETH[chainId])    

    const depeg = 0.98 
    const depegInWei = depeg * 1e4
    let tx = await waitTx(mockLiteVaultRoot.updateDepeg(depegInWei))

    console.log(`Depeg(${depeg}%) Updated: `, tx)
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
