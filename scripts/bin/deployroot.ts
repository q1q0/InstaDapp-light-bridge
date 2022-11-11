import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'
import { upgrades } from "hardhat"
import * as dotenv from "dotenv";
import config  from "../../config/config.json";

dotenv.config();

async function main() {
  let fxRoot, checkpointManager, fxERC20, rootchainManager, predicateETH;

  const network = await ethers.provider.getNetwork();

  if (network.chainId === 1) {
    // Ethereum Mainnet
    fxRoot = config.mainnet.fxRoot.address;
    checkpointManager = config.mainnet.checkpointManager.address;
    fxERC20 = config.mainnet.fxERC20.address;
    rootchainManager = config.mainnet.fxRootChainManager.address;
    predicateETH = config.mainnet.ETHPredicate.address

  } else if (network.chainId === 5) {
    // Goerli Testnet
    fxRoot = config.testnet.fxRoot.address;
    checkpointManager = config.testnet.checkpointManager.address;
    fxERC20 = config.testnet.fxERC20.address;
    rootchainManager = config.testnet.fxRootChainManager.address;
    predicateETH = config.testnet.ETHPredicate.address

  } else {
    return

  }

  const ERC20 = await ethers.getContractFactory("LiteMainBridge");
  const erc20 = await upgrades.deployProxy(ERC20,[checkpointManager, fxRoot, rootchainManager, predicateETH], { initializer: 'init' });
  // const erc20 = await ERC20.deploy(checkpointManager, fxRoot, bridge);
  await erc20.deployTransaction.wait();
  console.log("ERC20ChildTunnel deployed to:", erc20.address);
  console.log(
    "npx hardhat verify --network goerli",
    erc20.address,
  );

  // const ERC20 = await ethers.getContractFactory("FxERC20RootTunnel");
  // const erc20 = await ERC20.deploy(checkpointManager, fxRoot, fxERC20);
  // // console.log(erc20.deployTransaction);
  // await erc20.deployTransaction.wait();
  // console.log("ERC20RootTunnel deployed to:", erc20.address);
  // console.log(
  //   "npx hardhat verify --network goerli",
  //   erc20.address,
  //   checkpointManager,
  //   fxRoot,
  //   fxERC20
  // );

  // const setERC20Child = await erc20.setFxChildTunnel(fxERC20ChildTunnel);
  // // console.log(setERC20Child);
  // await setERC20Child.wait();
  // console.log("ERC20ChildTunnel set");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
