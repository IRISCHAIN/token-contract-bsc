import { defineConfig } from "hardhat/config";
import hardhatEthers from "@nomicfoundation/hardhat-ethers";
import hardhatToolboxMochaEthers from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import hardhatVerify from "@nomicfoundation/hardhat-verify";
import * as dotenv from "dotenv";

dotenv.config();

const PRIVATE_KEY_TESTNET = process.env.PRIVATE_KEY_TESTNET || "";
const PRIVATE_KEY_MAINNET = process.env.PRIVATE_KEY_MAINNET || "";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";

export default defineConfig({
  plugins: [
    hardhatEthers,
    hardhatToolboxMochaEthers,
    hardhatVerify
  ],

  solidity: {
    version: "0.8.30",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    bscTestnet: {
      type: "http",
      chainType: "generic",
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      accounts: PRIVATE_KEY_TESTNET ? [PRIVATE_KEY_TESTNET] : []
    },

    bscMainnet: {
      type: "http",
      chainType: "generic",
      url: "https://bsc-dataseed.binance.org",
      chainId: 56,
      accounts: PRIVATE_KEY_MAINNET ? [PRIVATE_KEY_MAINNET] : []
    }
  },

  verify: {
    etherscan: {
      apiKey: ETHERSCAN_API_KEY
    },
    blockscout: {
      enabled: false
    },
    sourcify: {
      enabled: false
    }
  }
});
