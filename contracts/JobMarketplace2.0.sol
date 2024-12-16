// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**Created by Matt Lindborg
 * UAT MS582 Week 7
 * @title JobMarketplace
 * @dev Job Marketplace for Freelance Solidity Developers
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

contract JobMarketplace {

    // Struct to store job details
    struct Job {
        uint256 id;            // Unique job ID
        address client;        // Address of the client
        address freelancer;    // Address of the freelancer
        uint256 budget;        // Job budget in wei
        string title;          // Job title
        string description;    // Job description
        bool isCompleted;      // Whether the job is completed
    }

    // State variables
    uint256 public jobCounter; // Counter to generate job IDs
    mapping(uint256 => Job) public jobs; // Mapping of job ID to Job details

    // Events
    event JobPosted(uint256 jobId, address client, uint256 budget, string title, string description);
    event JobAccepted(uint256 jobId, address freelancer);
    event FundsReleased(uint256 jobId, address to);

    // Post a job
    function postJob(uint256 budget, string calldata title, string calldata description) external {
        require(budget > 0, "Budget must be greater than zero");
        require(bytes(title).length > 0, "Title is required");

        jobCounter++;

        jobs[jobCounter] = Job(
            jobCounter,
            msg.sender,
            address(0),
            budget,
            title,
            description,
            false
        );

        emit JobPosted(jobCounter, msg.sender, budget, title, description);
    }

    // Accept a job as a freelancer
    function acceptJob(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(job.client != address(0), "Job does not exist");
        require(job.freelancer == address(0), "Job already accepted");
        require(msg.sender != job.client, "Client cannot accept their own job");

        job.freelancer = msg.sender;

        emit JobAccepted(jobId, msg.sender);
    }

    // Client deposits funds into escrow
    function depositFunds(uint256 jobId) external payable {
        Job storage job = jobs[jobId];
        require(job.client == msg.sender, "Only the client can deposit funds");
        require(msg.value == job.budget, "Incorrect deposit amount");
        require(job.freelancer != address(0), "Job has no freelancer assigned");
    }

    // Release funds to the freelancer
    function releaseFunds(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Only the client can release funds");
        require(!job.isCompleted, "Funds already released");

        job.isCompleted = true;
        payable(job.freelancer).transfer(job.budget);

        emit FundsReleased(jobId, job.freelancer);
    }
}
