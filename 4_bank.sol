//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Project {
        address lead;
        string description;
        uint goal;
        uint minContribution;
        uint totalFunds;
        uint approvalCount;
        bool isActive;
        uint totalContributor;
        mapping(address => uint) contributors;
    }

    address public manager;
    uint public projectCount;
    mapping(uint => Project) public projects;

    constructor() {
        manager = msg.sender;
    }

    function createProject(address lead, string memory description, uint goal, uint minContribution) public {
        require(msg.sender == manager, "Only manager can create projects");
        require(minContribution > 0, "Minimum contribution must be greater than 0");

        Project storage newProject = projects[projectCount];
        newProject.lead = lead;
        newProject.description = description;
        newProject.goal = goal;
        newProject.minContribution = minContribution;
        newProject.isActive = true;
        projectCount++;
    }

    function fundProject(uint projectId) public payable {
        require(projectId < projectCount, "Invalid project index");
        Project storage project = projects[projectId];
        require(project.isActive, "Project is not active");
        require(msg.value >= project.minContribution, "Minimum contribution not met");

        project.totalFunds += msg.value;
        if(project.contributors[msg.sender] == 0){
            project.contributors[msg.sender] = 1;
            project.totalContributor++;
        }
    }

    function voteProject(uint projectId) public {
        require(projectId < projectCount, "Invalid project index");
        Project storage project = projects[projectId];
        require(project.isActive, "Project is not active");
        require(project.contributors[msg.sender] == 1, "You must be a contributor to vote or you have already voted");

        project.approvalCount += 1;
        project.contributors[msg.sender] = 2;
    }

    function approveProject(uint projectId) public payable {
        require(msg.sender == manager, "Only manager can approve projects");
        require(projectId < projectCount, "Invalid project index");
        Project storage project = projects[projectId];
        require(project.isActive, "Project is not active");
        require((project.approvalCount * 100) / project.totalContributor > 50, "Approval count is less than 50%");

        project.isActive = false;
        payable(project.lead).transfer(project.totalFunds);
    }

    function getProjectSummary(uint projectId) public view returns (address, string memory,  uint,  uint, uint, uint, bool, uint) {
        require(projectId < projectCount, "Invalid project index");
        Project storage project = projects[projectId];
        
        return (
            project.lead,
            project.description,
            project.goal,
            project.minContribution,
            project.totalFunds,
            project.approvalCount,
            project.isActive,
            project.totalContributor
        );
    }

}