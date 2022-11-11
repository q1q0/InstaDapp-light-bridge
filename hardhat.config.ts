import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { HardhatUserConfig } from "hardhat/config";
import { HttpNetworkUserConfig } from "hardhat/types";

import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";


const {
  ALCHEMY_TOKEN_MAINNET,
  ALCHEMY_TOKEN_POLYGON,
  ALCHEMY_TOKEN_ARBITRUM,
  ALCHEMY_TOKEN_OPTIMISM,
  ETHERSCAN_API_KEY_MAINNET,
  ETHERSCAN_API_KEY_POLYGON,
  DEPLOYER_PRIVATE_KEY,
  DEPLOYER_MNEMONIC,
} = process.env;

const DEFAULT_MNEMONIC =
  "myth like bonus scare over problem client lizard pioneer submit female collect";

const sharedNetworkConfig: HttpNetworkUserConfig = {};

if (DEPLOYER_PRIVATE_KEY) {
  sharedNetworkConfig.accounts = [DEPLOYER_PRIVATE_KEY];
} else {
  sharedNetworkConfig.accounts = {
    mnemonic: DEPLOYER_MNEMONIC || DEFAULT_MNEMONIC,
  };
}

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [{ version: "0.8.17", settings: {} }],
  },
  networks: {
    hardhat: {
      forking: {
        // url: "https://eth-mainnet.g.alchemy.com/v2/" + ALCHEMY_TOKEN_MAINNET,
        url: "https://rpc.ankr.com/eth_goerli",
        // blockNumber: 15752216,
      },
      // gasPrice: 20000000000,
      // gas: 6000000,
    },
    localhost: {},
    mainnet: {
      ...sharedNetworkConfig,
      url: "https://eth-mainnet.g.alchemy.com/v2/" + ALCHEMY_TOKEN_MAINNET,
      chainId: 1
    },
    polygon: {
      ...sharedNetworkConfig,
      url: "https://polygon-mainnet.g.alchemy.com/v2/" + ALCHEMY_TOKEN_POLYGON,
      chainId: 137
    },
    avalanche: {
      ...sharedNetworkConfig,
      url: "https://rpc.ankr.com/avalanche",
      chainId: 43114
    },
    goerli: {
      ...sharedNetworkConfig,
      url: "https://rpc.ankr.com/eth_goerli",
      chainId: 5
    },
    mumbai: {
      ...sharedNetworkConfig,
      url: "https://rpc.ankr.com/polygon_mumbai",
      chainId: 80001
    },
    coverage: {
      url: "http://127.0.0.1:8555", // Coverage launches its own ganache-cli client
    },
  },
  etherscan: {
    apiKey: {
      // @ts-ignore
      goerli: ETHERSCAN_API_KEY_MAINNET,
      // @ts-ignore
      polygonMumbai: ETHERSCAN_API_KEY_POLYGON
    },
  },
  namedAccounts: {
    deployer: {
      default: 0, // use the first account (index = 0).
    },
  },
};

export default config;