import hre from "hardhat";
import {ethers} from "hardhat";

import CONFIG from "../common/config"

import {
    getChainId,
    deployContract,
    waitTx,
    Mode,
    getMode,
    getChildChainId,
    getRootChainId
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
    const childChainId = await getChildChainId();

    const map: [string, string] = isETH ? [CONFIG.MOCK_VAULT_ETH[chainId], CONFIG.MOCK_VAULT_ETH[childChainId]] : [CONFIG.MOCK_VAULT_TOKEN[chainId], CONFIG.MOCK_VAULT_TOKEN[childChainId]]
    const liteMainnetBridgeProxy = await ethers.getContractAt("LiteMainnetBridge", CONFIG.LITE_BRIDGE[chainId])
    let txHash = await waitTx(liteMainnetBridgeProxy.toggleRootToChildVaultMap(...map, true))
    console.log("Updated Mapping of liteMainnetBridge: ", txHash)

  } else {
    const rootChainId = await getRootChainId();

    const map: [string, string] = isETH ? [CONFIG.MOCK_VAULT_ETH[rootChainId], CONFIG.MOCK_VAULT_ETH[chainId]] : [CONFIG.MOCK_VAULT_TOKEN[rootChainId], CONFIG.MOCK_VAULT_TOKEN[chainId]]
    const litePolygonBridgeProxy = await ethers.getContractAt("LitePolygonBridge", CONFIG.LITE_BRIDGE[chainId])
    let txHash = await waitTx(litePolygonBridgeProxy.toggleChildToRootVaultMap(...map, true))
    console.log("Updated Mapping of litePolygonBridge: ", txHash)
  }
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
