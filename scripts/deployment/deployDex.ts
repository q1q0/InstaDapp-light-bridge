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

    const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])

    // mock contracts
    const dexArgs = [
      CONFIG.STETH_ADDRESS[chainId],
    ]
    const mock1InchContract = await deployContract('Mock1InchContract', dexArgs)
    const mockProxy = await deployContract('MockProxy', [mock1InchContract.address, liteProxyAdmin.address, "0x"], [], 4)

    if (hre.network.name !== 'hardhat') {
      try {
        await hre.run('verify:verify', {
            address: mock1InchContract.address,
            contract: "contracts/mock/oneInchDex.sol:Mock1InchContract",
            constructorArguments: dexArgs
        })
      } catch (error) {
        console.log(error)
      }

      try {
        await hre.run('verify:verify', {
            address: mockProxy.address,
            contract: "contracts/mock/proxy.sol:MockProxy",
            constructorArguments: [mock1InchContract.address, liteProxyAdmin.address, "0x"]
        })
      } catch (error) {
        console.log(error)
      }
    } else {
        console.log("Contracts deployed.")
    }
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
