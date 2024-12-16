// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JobMarketplace {
    // Struct to store job details
    struct Job {
        uint256 id;
        address client;
        address freelancer;
        uint256 budget;
        string description;
        bool isCompleted;
        bool isDisputed;
    }

    uint256 public jobCounter; // Job ID counter
    mapping(uint256 => Job) public jobs; // Store jobs by ID

    event JobPosted(uint256 jobId, address client, uint256 budget, string description);
    event JobAccepted(uint256 jobId, address freelancer);
    event FundsReleased(uint256 jobId, address to);
    event DisputeRaised(uint256 jobId, address by);

    // Post a job
    function postJob(uint256 budget, string calldata description) external {
        require(budget > 0, "Budget must be greater than zero");

        jobCounter++;
        jobs[jobCounter] = Job(
            jobCounter,
            msg.sender,
            address(0),
            budget,
            description,
            false,
            false
        );

        emit JobPosted(jobCounter, msg.sender, budget, description);
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
        require(!job.isDisputed, "Job is disputed");

        job.isCompleted = true;
        payable(job.freelancer).transfer(job.budget);

        emit FundsReleased(jobId, job.freelancer);
    }

    // Raise a dispute
    function raiseDispute(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client || msg.sender == job.freelancer, "Only involved parties can raise disputes");
        require(!job.isCompleted, "Job already completed");

        job.isDisputed = true;

        emit DisputeRaised(jobId, msg.sender);
    }
}
