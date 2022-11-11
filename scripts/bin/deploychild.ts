import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'
import { upgrades } from "hardhat"
import * as dotenv from "dotenv";
import * as config  from "../config/config.json";

dotenv.config();

async function main() {
  let fxChild, erc20Token;

  const network = await ethers.provider.getNetwork();

  if (network.chainId === 137) {
    // Polygon Mainnet
    fxChild = config.mainnet.fxChild.address;
    erc20Token = config.mainnet.fxERC20.address;
  } else if (network.chainId === 80001) {
    // Mumbai Testnet
    fxChild = config.testnet.fxChild.address;
    erc20Token = config.testnet.fxERC20.address;
  } else {
    return;
  }

  const ERC20 = await ethers.getContractFactory("LitePolygonBridge");
  const erc20 = await upgrades.deployProxy(ERC20,[fxChild], { initializer: 'init' });
  // await erc20.deployTransaction.wait();

  // console.log(await upgrades.erc1967.getImplementationAddress(erc20.address)," getImplementationAddress")
  // console.log(await upgrades.erc1967.getAdminAddress(erc20.address)," getAdminAddress")  

  await erc20.deployed();
  console.log("ERC20ChildTunnel deployed to:", erc20.address);
  console.log(
    "npx hardhat verify --network mumbai",
    // erc20.address,
    // fxChild,
    // bridge
  );

  // const ERC20 = await ethers.getContractFactory("FxERC20ChildTunnel");
  // const erc20 = await ERC20.deploy(fxChild, erc20Token);
  // await erc20.deployTransaction.wait();
  // console.log("ERC20ChildTunnel deployed to:", erc20.address);
  // console.log(
  //   "npx hardhat verify --network mumbai",
  //   erc20.address,
  //   fxChild,
  //   erc20Token
  // );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
