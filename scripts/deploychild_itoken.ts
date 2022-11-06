import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'
import * as dotenv from "dotenv";
import * as config  from "../config/config.json";
import { upgrades } from "hardhat"

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

  for(let i = 0; i < tokenList.length; i++) {
    const ERC20 = await ethers.getContractFactory("LiteVaultChild");
    const owner = "0x027814f84608EDdbaAE145778A55651079E2b52d";
    let erc20 = await upgrades.deployProxy(ERC20, [owner, tokenList[i].name, tokenList[i].symbol, tokenList[i].decimal, tokenList[i].underlyingToken, tokenList[i].isIETH], {initializer: 'setInit'})
    await erc20.deployTransaction.wait();
    console.log("ERC20ChildTunnel deployed to:", erc20.address);
    console.log(
      "npx hardhat verify --network mumbai",
      erc20.address,
      // `"${each.name}"`,
      // `"${each.symbol}"`,
      // `${each.underlyingToken}`,
      // " --contract contracts/tunnel/LiteVaultChild.sol:LiteVaultChild"
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
