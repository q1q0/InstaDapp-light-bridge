import '@nomiclabs/hardhat-ethers'
import { ethers } from 'hardhat'
import * as dotenv from "dotenv";
import * as config  from "../../config/config.json";
import { upgrades } from "hardhat"

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
    let erc20 = await upgrades.deployProxy(ERC20, [tokenList[i].name, tokenList[i].symbol, tokenList[i].underlyingToken, tokenList[i].isIETH], {initializer: 'initialize'})
    await erc20.deployTransaction.wait();
    console.log("ERC20ChildTunnel deployed to:", erc20.address);
    console.log(
      "npx hardhat verify --network goerli",
      erc20.address,
      // `"${tokenList[i].name}"`,
      // `"${tokenList[i].symbol}"`,
      // `${tokenList[i].underlyingToken}`,
      // " --contract contracts/tunnel/LiteVaultRoot.sol:LiteVaultRoot"
    );
  }
 
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
