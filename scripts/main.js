// Import ethers.js
import { ethers } from "ethers";

// Ethers.js setup
let provider;
let signer;

// Contract ABI and Address
const contractAddress = "0xBd5255841E45B97E8Ec638F768ED9753845D70F2"; // Replace with your contract address
const abi = [
    {
        "inputs": [{ "internalType": "uint256", "name": "jobId", "type": "uint256" }],
        "name": "acceptJob",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{ "internalType": "uint256", "name": "jobId", "type": "uint256" }],
        "name": "depositFunds",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "inputs": [
            { "internalType": "uint256", "name": "budget", "type": "uint256" },
            { "internalType": "string", "name": "title", "type": "string" },
            { "internalType": "string", "name": "description", "type": "string" }
        ],
        "name": "postJob",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "jobCounter",
        "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "name": "jobs",
        "outputs": [
            { "internalType": "uint256", "name": "id", "type": "uint256" },
            { "internalType": "address", "name": "client", "type": "address" },
            { "internalType": "address", "name": "freelancer", "type": "address" },
            { "internalType": "uint256", "name": "budget", "type": "uint256" },
            { "internalType": "uint256", "name": "amountDeposited", "type": "uint256" },
            { "internalType": "string", "name": "title", "type": "string" },
            { "internalType": "string", "name": "description", "type": "string" },
            { "internalType": "bool", "name": "isCompleted", "type": "bool" }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

// Connect Wallet
document.getElementById("connectWallet").addEventListener("click", async () => {
    if (window.ethereum) {
        try {
            provider = new ethers.providers.Web3Provider(window.ethereum);
            await provider.send("eth_requestAccounts", []);
            signer = provider.getSigner();
            const address = await signer.getAddress();
            document.getElementById("walletAddress").innerText = `Connected: ${address}`;
            console.log("Wallet connected:", address);
        } catch (error) {
            console.error("Error connecting wallet:", error);
            alert("Error connecting to wallet.");
        }
    } else {
        alert("MetaMask not found. Please install it.");
    }
});

// Post a Job
document.getElementById("postJobForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const title = document.getElementById("title").value;
    const description = document.getElementById("description").value;
    const budget = ethers.utils.parseEther(document.getElementById("budget").value);

    try {
        const contract = new ethers.Contract(contractAddress, abi, signer);
        const tx = await contract.postJob(budget, title, description);
        await tx.wait(); // Wait for the transaction to be mined
        alert("Job posted successfully!");
        fetchJobs(); // Refresh job list
    } catch (error) {
        console.error("Error posting job:", error);
        alert("Error posting job.");
    }
});

// Fetch Jobs
async function fetchJobs() {
    const jobList = document.getElementById("jobList");
    jobList.innerHTML = ""; // Clear the current job list

    try {
        const contract = new ethers.Contract(contractAddress, abi, provider);
        const totalJobs = await contract.jobCounter();

        for (let jobId = 1; jobId <= totalJobs; jobId++) {
            const job = await contract.jobs(jobId);
            const budgetInEth = ethers.utils.formatEther(job.budget);

            jobList.innerHTML += `
                <div>
                    <h3>${job.title}</h3>
                    <p>${job.description}</p>
                    <p>Budget: ${budgetInEth} ETH</p>
                    <p>Client: ${job.client}</p>
                    <p>Freelancer: ${job.freelancer === "0x0000000000000000000000000000000000000000" ? "Unassigned" : job.freelancer}</p>
                </div>
                <hr />
            `;
        }
    } catch (error) {
        console.error("Error fetching jobs:", error);
    }
}

// Load jobs on page load
window.addEventListener("load", fetchJobs);
