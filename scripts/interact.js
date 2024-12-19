const { ethers } = require("hardhat");

async function main() {
    // Get the signer (default account)
    const [owner] = await ethers.getSigners();

    // Replace with your deployed contract address
    const jobMarketplaceAddress = "0xYourDeployedContractAddress";

    // Attach to the deployed contract
    const jobMarketplace = await ethers.getContractAt("JobMarketplace", jobMarketplaceAddress);

    // Post a job
    const tx = await jobMarketplace.postJob(
        ethers.utils.parseEther("1.0"), // Budget in wei
        "Full Stack Developer",         // Job title
        "Build a DApp with React"       // Job description
    );
    await tx.wait();

    console.log("Job posted successfully!");

    // Check the job counter
    const jobCounter = await jobMarketplace.jobCounter();
    console.log(`Current job counter: ${jobCounter.toString()}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
