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
    Escrow Refunds - ties int the Job Cancellation function
    Freelancer Completion Confirmation - allow the freelancer to mark a job as completed
    Dispute Resolution System - ability for an arbitrator to decide outcome from a job disagreement
    Escrow State Tracking - allow visibilty into the status of the escrow currency
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
        string title;          // Job title
        string description;    // Job description
        bool isCompleted;      // Whether the job is completed
    }

    // State variables
    uint256 public jobCounter; // Counter to generate job IDs
    mapping(uint256 => Job) public jobs; // Mapping of job ID to Job details

    // Events
    event JobPosted(uint256 jobId, address client, uint256 budget, string title, string description); // info on posted job
    event JobAccepted(uint256 jobId, address freelancer); // notification of a job being accepted
    event FundsReleased(uint256 jobId, address to); // notification of funds being released after job completion
    event TransferFailed(uint256 jobId, address to, string reason); // notification of transfer of funds failed

    // Post a job
    function postJob(uint256 budget, string calldata title, string calldata description) external { // external type
        require(budget > 0, "Budget must be greater than zero");
        require(bytes(title).length > 0, "Title is required");

        jobCounter++; // starting at 1 in jobs map

        jobs[jobCounter] = Job( // struct used in map
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
    function acceptJob(uint256 jobId) external { // external type
        Job storage job = jobs[jobId];
        require(job.client != address(0), "Job does not exist");
        require(job.freelancer == address(0), "Job already accepted");
        require(msg.sender != job.client, "Client cannot accept their own job");

        job.freelancer = msg.sender;

        emit JobAccepted(jobId, msg.sender);
    }

    // Client deposits funds into escrow
    function depositFunds(uint256 jobId) external payable { // external type
        Job storage job = jobs[jobId];
        require(job.client == msg.sender, "Only the client can deposit funds");
        require(msg.value == job.budget, "Incorrect deposit amount");
        require(job.freelancer != address(0), "Job has no freelancer assigned");
    }

    // Release funds to the freelancer when job is complete
    function releaseFunds(uint256 jobId) external { // external type
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Only the client can release funds");
        require(!job.isCompleted, "Funds already released");

        job.isCompleted = true;

        // Use call to send Ether and can wrap it in try-catch
        (bool success, ) = payable(job.freelancer).call{value: job.budget}("");

        if (success) {
            emit FundsReleased(jobId, job.freelancer);
        } else {
            job.isCompleted = false; // Revert completion if transfer fails
            emit TransferFailed(jobId, job.freelancer, "Transfer failed");
        }
    }
}
