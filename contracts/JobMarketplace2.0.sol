// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**Created by Matt Lindborg
 * UAT MS582 Week 7
 * @title JobMarketplace
 * @dev Job Marketplace for Freelance Solidity Developers
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

/*Future Implmementations or improvements:
    Job Cancellation - cancel a job and return the amount in escrow to the client
    Escrow Refunds - ties into the Job Cancellation function
    Freelancer Completion Confirmation - allow the freelancer to mark a job as completed
    Dispute Resolution System - ability for an arbitrator to decide outcome from a job disagreement
    Escrow State Tracking - allow visibility into the status of the escrow currency
    Ratings and Reviews of Freelancers - allow a review of the job done for the client
    Deadline Management - allow a client to set a deadline for the job to be completed
    Token Based Payments - allow for the use of tokens for payment, instead of currency
*/

contract JobMarketplace2 { 

    // Struct to store job details
    struct Job {
        uint256 id;            // Unique job ID
        address client;        // Address of the client
        address freelancer;    // Address of the freelancer
        uint256 budget;        // Job budget in wei
        uint256 amountDeposited; // Tracks funds deposited into escrow
        string title;          // Job title
        string description;    // Job description
        bool isCompleted;      // Whether the job is completed
    }

    // State variables
    uint256 public jobCounter = 0; // Counter to generate job IDs, starting at 0
    mapping(uint256 => Job) public jobs; // Mapping of job ID to Job details

    // Events
    event JobPosted(uint256 jobId, address client, uint256 budget, string title, string description);
    event JobAccepted(uint256 jobId, address freelancer);
    event FundsDeposited(uint256 jobId, address client, uint256 amount);
    event FundsReleased(uint256 jobId, address to);
    event TransferFailed(uint256 jobId, address to, string reason);

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
            0, // Initialize amountDeposited to 0
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
        require(job.amountDeposited == 0, "Funds already deposited");

        // Update amountDeposited
        job.amountDeposited = msg.value;

        emit FundsDeposited(jobId, msg.sender, msg.value);
    }

    // Release funds to the freelancer when job is complete
    function releaseFunds(uint256 jobId) external { 
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Only the client can release funds");
        require(!job.isCompleted, "Funds already released");
        require(job.amountDeposited == job.budget, "Funds not yet deposited");

        job.isCompleted = true;

        // Use call to send Ether and can wrap it in try-catch
        (bool success, ) = payable(job.freelancer).call{value: job.amountDeposited}("");

        if (success) {
            emit FundsReleased(jobId, job.freelancer);
            job.amountDeposited = 0; // Reset escrow amount
        } else {
            job.isCompleted = false; // Revert job state
            emit TransferFailed(jobId, job.freelancer, "Transfer failed");
        }
    }
}
