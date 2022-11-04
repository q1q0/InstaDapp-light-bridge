import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'
import * as dotenv from "dotenv";
import * as config  from "../config/config.json";

dotenv.config();

async function main() {
  let tokenList;

  const network = await ethers.provider.getNetwork();

  if (network.chainId === 1) {
    // Polygon Mainnet
    tokenList = config.mainnet.iTokenMain;
  } else if (network.chainId === 5) {
    // Mumbai Testnet
    tokenList = config.testnet.iTokenMain;
  } else {
    return;
  }

  for(let i = 0; i < tokenList.length; i++) {
    const ERC20 = await ethers.getContractFactory("LiteVaultRoot");
    const erc20 = await ERC20.deploy(tokenList[i].name, tokenList[i].symbol, tokenList[i].underlyingToken);  
    await erc20.deployed();
    console.log("ERC20ChildTunnel deployed to:", erc20.address);
    console.log(
      "npx hardhat verify --network goerli",
      erc20.address,
      `"${tokenList[i].name}"`,
      `"${tokenList[i].symbol}"`,
      `${tokenList[i].underlyingToken}`,
      " --contract contracts/tunnel/LiteVaultRoot.sol:LiteVaultRoot"
    );
  }
 

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
