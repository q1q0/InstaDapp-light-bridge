import hre from "hardhat";
import {ethers} from "hardhat";

import CONFIG from "../common/config"

import {
    getChainId,
    deployContract,
    waitTx,
    Mode,
    getMode
} from "../common/utlis"


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


  if ((await getMode()) == Mode.ROOT) {
    const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])

    const mockLiteVaultRootArgs = [
        CONFIG.WETH_ADDRESS[chainId],
        CONFIG.LITE_BRIDGE[chainId],
        true
    ]
    const mockLiteVaultRoot = await deployContract('MockLiteVaultRoot', mockLiteVaultRootArgs)

    let tx = await waitTx(liteProxyAdmin.upgrade(CONFIG.MOCK_VAULT_ETH[chainId], mockLiteVaultRoot.address))
    tx = await waitTx(liteProxyAdmin.upgrade(CONFIG.MOCK_VAULT_TOKEN[chainId], mockLiteVaultRoot.address), 4)

    if (hre.network.name !== 'hardhat') {
        try {
          await hre.run('verify:verify', {
              address: mockLiteVaultRoot.address,
              contract: "contracts/mock/vault/LiteVaultRoot.sol:MockLiteVaultRoot",
              constructorArguments: mockLiteVaultRootArgs
          })
        } catch (error) {
          console.log(error)
        }
    } else {
        console.log("contract deployed")
    }  

   
  } else {
    const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])    

    const mockLiteVaultChildArgs = [
        CONFIG.WETH_ADDRESS[chainId],
        CONFIG.LITE_BRIDGE[chainId],
        true
      ]
    const mockLiteVaultChild = await deployContract('MockLiteVaultChild', mockLiteVaultChildArgs)

    let tx = await waitTx(liteProxyAdmin.upgrade(CONFIG.MOCK_VAULT_ETH[chainId], mockLiteVaultChild.address))
    tx = await waitTx(liteProxyAdmin.upgrade(CONFIG.MOCK_VAULT_TOKEN[chainId], mockLiteVaultChild.address), 12)

    if (hre.network.name !== 'hardhat') {
        try {
          await hre.run('verify:verify', {
              address: mockLiteVaultChild.address,
              contract: "contracts/mock/vault/LiteVaultChild.sol:MockLiteVaultChild",
              constructorArguments: mockLiteVaultChildArgs
          })
        } catch (error) {
          console.log(error)
        }
    } else {
        console.log("contract deployed")
    }  
  }

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
