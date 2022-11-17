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

  const isETH = false

  if ((await getMode()) == Mode.ROOT) {

    const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])

    // mock contracts
    const mockLiteVaultRootArgsEth = [
      CONFIG.STETH_ADDRESS[chainId],
      CONFIG.LITE_BRIDGE[chainId],
      true
    ]

    // mock contracts
    const mockLiteVaultRootArgsToken = [
      CONFIG.TOKEN_ADDRESS[chainId],
      CONFIG.LITE_BRIDGE[chainId],
      false
    ]

    const mockLiteVaultRootArgs = isETH ? mockLiteVaultRootArgsEth : mockLiteVaultRootArgsToken;
    const tokenDetails = isETH ? ["ZzZzZ ETH", "zETH"] : ["ZzZzZ Token", "zTKN"]

    const mockLiteVaultRoot = await deployContract('MockLiteVaultRoot', mockLiteVaultRootArgs)
    const mockLiteVaultRootInitialiseCalldata = (await mockLiteVaultRoot.populateTransaction.initialize(...tokenDetails)).data
    const mockProxy = await deployContract('MockProxy', [mockLiteVaultRoot.address, liteProxyAdmin.address, mockLiteVaultRootInitialiseCalldata], [], 4)

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

      try {
        await hre.run('verify:verify', {
            address: mockProxy.address,
            contract: "contracts/mock/proxy.sol:MockProxy",
            constructorArguments: [mockLiteVaultRoot.address, liteProxyAdmin.address, mockLiteVaultRootInitialiseCalldata]
        })
      } catch (error) {
        console.log(error)
      }
    } else {
        console.log("Contracts deployed.")
    }
  } else {
    const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])
    
    
    // mock contracts
    const mockLiteVaultChildArgsEth = [
      CONFIG.TOKEN_ADDRESS[chainId],
      CONFIG.LITE_BRIDGE[chainId],
      true
    ]

    // mock contracts
    const mockLiteVaultChildArgsToken = [
      CONFIG.TOKEN_ADDRESS[chainId],
      CONFIG.LITE_BRIDGE[chainId],
      true
    ]

    const mockLiteVaultChildArgs = isETH ? mockLiteVaultChildArgsEth : mockLiteVaultChildArgsToken;
    const tokenDetails = isETH ? ["ZzZzZ PolETH", "zPolETH"] : ["ZzZzZ PolToken", "zPolTKN"]

    const mockLiteVaultChild = await deployContract('MockLiteVaultChild', mockLiteVaultChildArgs)
    const mockLiteVaultChildInitialiseCalldata = (await mockLiteVaultChild.populateTransaction.initialize(...tokenDetails)).data
    const mockProxy = await deployContract('MockProxy', [mockLiteVaultChild.address, liteProxyAdmin.address, mockLiteVaultChildInitialiseCalldata], [], 12)

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

      try {
        await hre.run('verify:verify', {
            address: mockProxy.address,
            contract: "contracts/mock/proxy.sol:MockProxy",
            constructorArguments: [mockLiteVaultChild.address, liteProxyAdmin.address, mockLiteVaultChildInitialiseCalldata]
        })
      } catch (error) {
        console.log(error)
      }
    } else {
        console.log("Contracts deployed.")
    }
  }
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
