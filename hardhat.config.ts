import '@nomicfoundation/hardhat-toolbox'
import dotenv from 'dotenv'
import { HardhatUserConfig, task } from 'hardhat/config'
import 'hardhat-abi-exporter'
import '@oasisprotocol/sapphire-hardhat'

dotenv.config()

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 888,
          },
        },
      },
    ],
  },
  paths: {
    artifacts: './src/contracts/artifacts',
    cache: './cache',
    sources: './src/contracts',
    tests: './src/test',
  },
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: false,
      from: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    },
    sapphire_local: {
      chainId: 23293,
      url: "http://127.0.0.1:8545",
      accounts: ["0x160f52faa5c0aecfa26c793424a04d53cbf23dcad5901ce15b50c2e85b9d6ca7","0x0ba685723b47d8e744b1b70a9bea9d4d968f60205385ae9de99865174c1af110","0xfa990cf0c22af455d2734c879a2a844ff99bd779b400bb0e2919758d1be284b5","0x3bf225ef73b1b56b03ceec8bb4dfb4830b662b073b312beb7e7fec3159b1bb4f","0xad0dd7ceb896fd5f5ddc76d56e54ee6d5c2a3ffeac7714d3ef544d3d6262512c"]
    },
    sapphire_testnet: {
      chainId: 0x5aff,
      url: process.env.SAPPHIRE_TESTNET_URL || '',
      accounts: process.env.SAPPHIRE_TESTNET_URL !== undefined ? [process.env.TESTNET_PRIVATE_KEY!] : [],
    },
    sapphire: {
      url: process.env.SAPPHIRE_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    coinmarketcap: process.env.CMC_API_KEY,
    gasPrice: 1,
    currency: 'USD',
    src: './contracts',
  },
  mocha: {
    timeout: 500000,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
}

export default config
