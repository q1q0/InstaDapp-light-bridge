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
        // Bridge Contracts
        const liteMainnetBridge = await deployContract('LiteMainnetBridge', Object.values(CONFIG.LITE_BRIDGE_CONSTUCTOR_ARGS[chainId]))
        const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])
    
        let tx = await waitTx(liteProxyAdmin.upgrade(CONFIG.LITE_BRIDGE[chainId], liteMainnetBridge.address), 4)
    
        if (hre.network.name !== 'hardhat') {
          try {
            await hre.run('verify:verify', {
                address: liteMainnetBridge.address,
                contract: "contracts/liteBridge/mainnet/LiteMainnetBridge.sol:LiteMainnetBridge",
                constructorArguments: Object.values(CONFIG.LITE_BRIDGE_CONSTUCTOR_ARGS[chainId])
            })
          } catch (error) {
            console.log(error)
          }
        } else {
            console.log("Contracts deployed.")
        }
  } else {
    // Bridge Contracts
    const litePolygonBridge = await deployContract('LitePolygonBridge', Object.values(CONFIG.LITE_BRIDGE_CONSTUCTOR_ARGS[chainId]))
    const liteProxyAdmin = await ethers.getContractAt("LiteProxyAdmin", CONFIG.PROXY_ADMIN[chainId])

    let tx = await waitTx(liteProxyAdmin.upgrade(CONFIG.LITE_BRIDGE[chainId], litePolygonBridge.address), 12)

    if (hre.network.name !== 'hardhat') {
      try {
        await hre.run('verify:verify', {
            address: litePolygonBridge.address,
            contract: "contracts/liteBridge/polygon/LitePolygonBridge.sol:LitePolygonBridge",
            constructorArguments: Object.values(CONFIG.LITE_BRIDGE_CONSTUCTOR_ARGS[chainId])
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
