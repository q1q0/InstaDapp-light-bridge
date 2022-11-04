import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'
import * as dotenv from "dotenv";
import * as config  from "../config/config.json";

dotenv.config();

async function main() {
  let tokenList;

  const network = await ethers.provider.getNetwork();

  if (network.chainId === 137) {
    // Polygon Mainnet
    tokenList = config.mainnet.iTokenPolygon;
  } else if (network.chainId === 80001) {
    // Mumbai Testnet
    tokenList = config.testnet.iTokenPolygon;
  } else {
    return;
  }

  await Promise.all(tokenList.map(async(each)=>{
    const ERC20 = await ethers.getContractFactory("LiteVaultChild");
    const erc20 = await ERC20.deploy(each.name, each.symbol, each.underlyingToken);  
    await erc20.deployed();
    console.log("ERC20ChildTunnel deployed to:", erc20.address);
    console.log(
      "npx hardhat verify --network mumbai",
      erc20.address,
      `"${each.name}"`,
      `"${each.symbol}"`,
      `${each.underlyingToken}`,
      " --contract contracts/tunnel/LiteVaultChild.sol:LiteVaultChild"
    );
  }))
  

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
