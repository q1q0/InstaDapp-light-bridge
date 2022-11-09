/* eslint-disable prettier/prettier */
import * as dotenv from 'dotenv'
dotenv.config()

import { HardhatUserConfig } from 'hardhat/types'
import { task } from 'hardhat/config'

// Plugins

import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import '@nomiclabs/hardhat-waffle'
// import 'hardhat-abi-exporter'
// import 'hardhat-gas-reporter'
import 'hardhat-contract-sizer'
import '@tenderly/hardhat-tenderly'
import '@openzeppelin/hardhat-upgrades'
import '@typechain/hardhat'
import "hardhat-contract-sizer";
import { createAlchemyWeb3 } from "@alch/alchemy-web3";

// Tasks

// task('accounts', 'Prints the list of accounts', async (taskArgs, bre) => {
//   const accounts = await bre.ethers.getSigners()
//   for (const account of accounts) {
//     console.log(await account.getAddress())
//   }
// })

task("account", "returns nonce and balance for specified address on multiple networks")
  .addParam("address")
  .setAction(async address => {
    const web3Goerli = createAlchemyWeb3(`https://goerli.infura.io/v3/${process.env.INFURA_KEY}`);
    const web3Mumbai = createAlchemyWeb3(`https://polygon-testnet.public.blastapi.io`);

    const networkIDArr = ["Ethereum Goerli:", "Polygon  Mumbai:"]
    const providerArr = [web3Goerli, web3Mumbai];
    const resultArr = [];
    
    for (let i = 0; i < providerArr.length; i++) {
      const nonce = await providerArr[i].eth.getTransactionCount(address.address, "latest");
      const balance = await providerArr[i].eth.getBalance(address.address)
      resultArr.push([networkIDArr[i], nonce, parseFloat(providerArr[i].utils.fromWei(balance, "ether")).toFixed(2) + "ETH"]);
    }
    resultArr.unshift(["  |NETWORK|   |NONCE|   |BALANCE|  "])
    console.log(resultArr);
  });

// Config

const config: HardhatUserConfig = {
  paths: {
    sources: './contracts',
    tests: './test',
    artifacts: './build/contracts',
  },
  mocha: {
    timeout: 100000000
  },
  solidity: {
    compilers: [
      {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 1,
          },
          outputSelection: {
            '*': {
              '*': ['storageLayout'],
            },
          },
        },
      },
    ],
  },
  defaultNetwork: 'hardhat',
  
  networks: {
    hardhat: {
      chainId: 31337,
      // loggingEnabled: true,
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        enabled: true,
      }
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      chainId: 1,
      // accounts: [process.env.PRIVATE_KEY as string],
    },
    goerli: {
        // url: `https://goerli.infura.io/v3/${process.env.INFURA_KEY}`,
        url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        chainId: 5,
        // accounts: [process.env.PRIVATE_KEY as string],
    },
    mumbai: {
      url: `https://polygon-testnet.public.blastapi.io`,
      chainId: 80001,
      // accounts: [process.env.PRIVATE_KEY as string],
    },
    ganache: {
      chainId: 1337,
      url: 'http://localhost:8545',
    },
  },
  etherscan: {
    // apiKey: {
    //   polygonMumbai: process.env.POLYGON_API_KEY,
    // }
     apiKey: process.env.ETHERSCAN_API_KEY // for ether net work
    //  apiKey: process.env.POLYGON_API_KEY // for ether net work
    //  apiKey: "N2E5BV7EU18ZEFEMGM8YS5NBPPQH9QJK3Q"
    // apiKey: "BCT83TFQ1QJ7XPRIVG2V82YVF6SVTRVNDE"
  },
  typechain: {
    outDir: 'build/types',
    target: 'ethers-v5',
  },
  // abiExporter: {
  //   path: './build/abis',
  //   clear: false,
  //   flat: true,
  // },
  // contractSizer: {
  //   alphaSort: true,
  //   runOnCompile: false,
  //   disambiguatePaths: true,
  // },
}

export default config
