// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICrowdFundingContract {
    // Structs
    struct Program {
        uint256 id;
        string title;
        string image;
        string desc;
        address pic;
        uint256 targetFund;
        uint256 startDate;
        uint256 endDate;
        uint256 totalAmount;
        uint256 withdrawAmount;
        uint8 status; // enum ProgramStatus: 0=Active, 1=Completed, 2=Canceled
    }

    struct ContributeHistory {
        address contribute;
        uint256 amount;
    }

    struct Withdrawal {
        uint256 programId;
        uint256 amount;
        string desc;
        uint256 time;
    }

    // Events
    event ProgramCreated(
        uint256 indexed id,
        string title,
        address indexed pic,
        uint256 targetFund,
        uint256 startDate,
        uint256 endDate
    );

    event ContributionReceived(
        uint256 indexed programId,
        address indexed contributor,
        uint256 amountContributed,
        uint256 totalCollected
    );

    event FundsWithdrawn(
        uint256 indexed programId,
        address indexed recipient,
        uint256 amount,
        string desc,
        uint256 timestamp
    );

    event ProgramCanceled(
        uint256 indexed programId,
        address indexed canceller
    );

    event RefundIssued(
        uint256 indexed programId,
        address indexed contributor,
        uint256 amount
    );

    // Core Functions
    function createProgram(
        string memory _title,
        string memory _desc,
        string memory _image,
        address _pic,
        uint256 _targetFund,
        uint256 _startDate,
        uint256 _endDate
    ) external;

    function contribute(uint256 _programId) external payable;

    function withdraw(
        uint256 _programId,
        uint256 _amount,
        string memory _desc
    ) external;

    function cancelAndRefund(uint256 _programId) external;

    // View Functions
    function getProgramById(uint256 _programId) external view returns (Program memory);

    function getListProgramId() external view returns (uint256[] memory);

    function getHistoryWithdrawByProgram(uint256 _programId) external view returns (Withdrawal[] memory);

    function getFeeProgram(uint256 _programId) external view returns (uint256);

    function getAmountProgramAfterFee(uint256 _programId) external view returns (uint256);

    function getTotalPlatformFee() external view returns (uint256);

    // Admin
    function withdrawFeeAdmin(uint256 _amount) external;
}
