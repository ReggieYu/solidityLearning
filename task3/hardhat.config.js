const { version, artifacts } = require('hardhat');

require('@chainlink/env-enc').config();
require("@nomicfoundation/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-deploy");
require("solidity-coverage");

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";


/**
 * hardhat 配置
 * - solidity编译器0.8.28 开启优化
 * - 集成hardhat-deploy，定义namedAccounts
 * - 配置sepolia 测试网络（从.evn读取）
 */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: { enabled: true, runs: 200 }
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: PRIVATE_KEY ? PRIVATE_KEY : [],
    },
  },
  paths: {
    source: "contracts",
    artifacts: "artifacts",
    cache: "cache",
  },
  mocha: {
    timeout: 60000,
    reporter: "mocha-multi-reporters",
    reporterOptions: {
      reporterEnabled: "spec, mocha-juint-reporter, mochawesome",
      mochaJunitReporterReporterOptions: {
        mochaFile: "reports/junit.xml",
        toConsole: false,
      },
      mochawesomeReporterOptions: {
        reportDir: "reports/mochawesome",
        reportFilename: "report",
        quiet: true,
        override: true,
        html: true,
        json: true,
      },
    },
  },
  // hardhat-deploy
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

