// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ConstructionEscrow {
    address public client;
    address public builder;
    address public oracle;
    address public owner;
    uint public constant COMMISSION = 15; // 1.5%
    uint public constant DENOMINATOR = 1000;

    struct Stage {
        uint amount;
        uint deadline;
        bool completed;
        string ipfsHash;
        bool extensionRequested;
        uint newDeadline;
    }

    Stage[] public stages;
    address public token;
    uint public totalDeposited;
    uint public commissionAmount;

    constructor(address _builder, address _oracle, address _token) {
        client = msg.sender;
        builder = _builder;
        oracle = _oracle;
        owner = msg.sender;
        token = _token;
        stages.push(Stage(0, block.timestamp + 7 days, false, "", false, 0)); // Фундамент
        stages.push(Stage(0, block.timestamp + 14 days, false, "", false, 0)); // Стіни
        stages.push(Stage(0, block.timestamp + 21 days, false, "", false, 0)); // Дах
    }

    function deposit(uint totalAmount) external payable {
        require(msg.sender == client, "Only client");
        require(totalDeposited == 0, "Already funded");

        commissionAmount = (totalAmount * COMMISSION) / DENOMINATOR;
        uint netAmount = totalAmount - commissionAmount;
        uint stageAmount = netAmount / 3;
        for (uint i = 0; i < 3; i++) {
            stages[i].amount = stageAmount;
        }

        if (token == address(0)) {
            require(msg.value == totalAmount, "Incorrect ETH amount");
        } else {
            require(IERC20(token).transferFrom(msg.sender, address(this), totalAmount), "Transfer failed");
        }
        totalDeposited = totalAmount;
    }

    function submitProof(uint stageId, string memory ipfsHash) external {
        require(msg.sender == builder, "Only builder");
        require(stageId < 3, "Invalid stage");
        require(!stages[stageId].completed, "Already completed");
        stages[stageId].ipfsHash = ipfsHash;
    }

    function confirmStage(uint stageId) external {
        require(msg.sender == oracle, "Only oracle");
        require(stageId < 3, "Invalid stage");
        require(block.timestamp <= stages[stageId].deadline, "Deadline passed");
        require(!stages[stageId].completed, "Already completed");

        stages[stageId].completed = true;
        if (token == address(0)) {
            payable(builder).transfer(stages[stageId].amount);
        } else {
            IERC20(token).transfer(builder, stages[stageId].amount);
        }
    }

    function requestExtension(uint stageId, uint extraDays) external {
        require(msg.sender == builder, "Only builder");
        require(stageId < 3, "Invalid stage");
        require(!stages[stageId].completed, "Already completed");
        require(!stages[stageId].extensionRequested, "Extension already requested");
        stages[stageId].extensionRequested = true;
        stages[stageId].newDeadline = stages[stageId].deadline + (extraDays * 1 days);
    }

    function approveExtension(uint stageId) external {
        require(msg.sender == client, "Only client");
        require(stageId < 3, "Invalid stage");
        require(stages[stageId].extensionRequested, "No extension requested");
        stages[stageId].deadline = stages[stageId].newDeadline;
        stages[stageId].extensionRequested = false;
        stages[stageId].newDeadline = 0;
    }

    function reclaimFunds() external {
        require(msg.sender == client, "Only client");
        uint refund = 0;
        for (uint i = 0; i < 3; i++) {
            if (!stages[i].completed && block.timestamp > stages[i].deadline && !stages[i].extensionRequested) {
                refund += stages[i].amount;
                stages[i].amount = 0;
            }
        }
        if (refund > 0) {
            if (token == address(0)) {
                payable(client).transfer(refund);
            } else {
                IERC20(token).transfer(client, refund);
            }
        }
    }

    function withdrawCommission() external {
        require(msg.sender == owner, "Only owner");
        uint amount = commissionAmount;
        commissionAmount = 0;
        if (token == address(0)) {
            payable(owner).transfer(amount);
        } else {
            IERC20(token).transfer(owner, amount);
        }
    }
}