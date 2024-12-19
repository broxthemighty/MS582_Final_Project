require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");

module.exports = {
    solidity: "0.8.18", // Ensure your Solidity version matches
    networks: {
        localhost: {
            url: "http://127.0.0.1:8545"
        }
    }
};
