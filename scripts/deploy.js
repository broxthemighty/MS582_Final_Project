async function main() {
    // Get the contract to deploy
    const JobMarketplace = await ethers.getContractFactory("JobMarketplace");
    console.log("Deploying JobMarketplace...");

    // Deploy the contract
    const jobMarketplace = await JobMarketplace.deploy();

    // Wait for the deployment to complete
    // await jobMarketplace.deployed();

    console.log(`JobMarketplace deployed to: ${jobMarketplace.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
