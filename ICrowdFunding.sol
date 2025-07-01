// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICrowdFundingContract {

    enum ProgramStatus { Active, Completed, Canceled }

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
        ProgramStatus status;
    }

    struct Withdrawal {
        uint256 programId;
        uint256 amount;
        string desc;
        uint256 time;
    }

    error ProgramEnd();
    error CallerNotPIC();
    error FundraiseIsNotClosed();
    error WithdrawAmountError();
    error WithdrawFailed();
    error CancelAndRefundFailed();


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

    // Fungsi View (read-only)

    function getHistoryWithdrawByProgram(uint256 _programId) 
        external 
        view 
        returns (Withdrawal[] memory);

    function getListProgramId() external view returns (uint256[] memory);

    function getProgramById(uint256 _programId) 
        external 
        view 
        returns (Program memory);
    
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function renounceOwnership() external;
}