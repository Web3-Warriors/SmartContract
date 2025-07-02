// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Ownable} from './lib/openzeppelin-contracts/contracts/access/Ownable.sol';


contract CrowdFundingContract is Ownable{

    // --- Events ---
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
        uint256 amountContributed, // Actual amount that went into the program
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
    // --- End Events ---

    constructor() Ownable(msg.sender) {}

    uint256 private _nextProgramId;

    enum ProgramStatus {Active, Completed, Canceled}

    struct Program {
        uint256 id;
        string  title;
        string  image;
        string  desc;
        address pic;
        uint256 targetFund;
        uint256 startDate;
        uint256 endDate;
        uint256 totalAmount;
        uint256 withdrawAmount;
        ProgramStatus status;
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

    mapping(uint256 => Program) public programs;
    // contribute history by Program
    mapping(uint256 => ContributeHistory[]) public contributeHistory;
    // history withdraw by Program
    mapping(uint256 => Withdrawal[]) public withdrawalByProgram;

    uint256[] public listProgramId;


    modifier onlyPIC(uint256 _programId ,address _PIC){
        if(programs[_programId].pic != _PIC ){
            revert CallerNotPIC();
        }
        _;
    }

    error ProgramEnd();
    error CallerNotPIC();
    error FundraiseIsNotClosed();
    error WithdrawAmountError();
    error WithdrawFailed();
    error CancelAndRefundFailed();

    function createProgram
        (
        string memory _title,
        string memory _desc,
        string memory _image,
        address _pic,
        uint256 _targetFund,
        uint256 _startDate,
        uint256 _endDate        
        )
        public 
        onlyOwner 
        {
            uint256 programId = ++_nextProgramId;
            programs[programId] = Program({
                id                  : programId,
                title               :_title,
                desc                :_desc,
                image               :_image, 
                pic                 : _pic, 
                targetFund          : _targetFund, 
                startDate           : _startDate, 
                endDate             : _endDate, 
                totalAmount         : 0,
                withdrawAmount      : 0,
                status              : ProgramStatus.Active
            });

            listProgramId.push(programId);
            emit ProgramCreated(
            programId,
            _title,
            _pic,
            _targetFund,
            _startDate,
            _endDate
        );

    }

    function contribute
        (
            uint _programId
        )
        public
        payable
        {
            Program storage _program = programs[_programId];

            require(_program.status == ProgramStatus.Active, "Not Active");
            if(block.timestamp > _program.endDate ) {
                revert ProgramEnd();
            }
            // validasi untuk dana program sudah tercapai
            require(_program.totalAmount != _program.targetFund, "Fund has reached");
            
            // mengubah status menjadi completed jika fund terakhir sudah mencukupi target fund
            if((msg.value + _program.totalAmount) == _program.targetFund){
                _program.status = ProgramStatus.Completed;
            }
           
            _program.totalAmount += msg.value;

            ContributeHistory memory _contribute = ContributeHistory(
                msg.sender,
                msg.value
            );
            contributeHistory[_programId].push(_contribute);

            emit ContributionReceived(_programId, msg.sender, msg.value, _program.totalAmount);
    }

    function withdraw
        (
            uint256 _programId, 
            uint256 _amount,
            string memory _desc
        )
        public
        onlyPIC(_programId, msg.sender)
        {
            Program storage _program = programs[_programId];
            if (_program.targetFund > block.timestamp) {
                revert FundraiseIsNotClosed();
            
            }

            uint256 totaAmountFund = _program.totalAmount;
            uint256 totalWithdraw = _program.withdrawAmount;

            // withdraw tidak boleh lebih dari data total dana yang sudah terkumpul
            if (_amount + totalWithdraw >= totaAmountFund) {
                revert WithdrawAmountError();
            }

            _program.withdrawAmount += _amount;
            (bool success, ) = payable(_program.pic).call{value: _amount}("");
            if(!success) revert WithdrawFailed();

            Withdrawal memory withdrawal = Withdrawal(
                _programId,
                _amount,
                _desc,
                block.timestamp
            );

            withdrawalByProgram[_programId].push(withdrawal);
            emit FundsWithdrawn(
            _programId,
            _program.pic,
            _amount,
            _desc,
            block.timestamp
        );

    }

    function cancelAndRefund
        (
            uint256 _programId
        ) 
        public 
        onlyOwner 
        {
            Program storage _program = programs[_programId];
            require(
                _program.status == ProgramStatus.Active || _program.status == ProgramStatus.Completed,
                "Not Active or Completed"
            );
            for (uint i = 0; i < contributeHistory[_programId].length; i++) {
                address _addr = contributeHistory[_programId][i].contribute;
                uint256 _amount = contributeHistory[_programId][i].amount;
                (bool success, ) = payable(_addr).call{value: _amount}("");
                if(!success) revert CancelAndRefundFailed();
                emit RefundIssued(_programId, _addr, _amount);
            }
            _program.status = ProgramStatus.Canceled;
    }


    function getHistoryWithdrawByProgram
        (
            uint256 _programId
        )
        public 
        view
        returns(Withdrawal[] memory)
        {
            return withdrawalByProgram[_programId];
        }

    function getListProgramId() public view returns (uint256 [] memory ){
        return listProgramId;
    }

    function getProgramById(uint256 _programId) public view returns (Program memory){
        return programs[_programId];
    }
    
}