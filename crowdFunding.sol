// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract crowdFunding is AccessControl{

    bytes32 public constant PIC_ROLE = keccak256("PIC_ROLE");

    constructor(){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    uint256 private _nextId = 1;

    enum ProgramStatus {Active, Completed, Canceled}

    struct Program {
        uint256 id;
        string title;
        string desc;
        string image;
        address pic;
        uint256 targetFund;
        uint256 startDate;
        uint256 endDate;
        uint256 amountNow;
        ProgramStatus status;
        address[] contributors;
        uint[] contributionAmounts;
    }

    mapping(uint256 => Program) public programs;

    modifier onlyAdmin(){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not admin");
        _;
    }

    Program[] public listProgram;
    uint256[] public listTokenId;

    function createProgram(
            string memory _title,
            string memory _desc,
            string memory _image,
            address _pic,
            uint256 _targetFund,
            uint256 _startDate,
            uint256 _endDate
            )
        public onlyAdmin {
            programs[_nextId] = Program({
                id: _nextId,
                title:_title,
                desc :_desc,
                image :_image, 
                pic   : _pic, 
                targetFund     : _targetFund, 
                startDate      : _startDate, 
                endDate        : _endDate, 
                amountNow          : 0,
                status         : ProgramStatus.Active,
                contributors: new address[] (0),
                contributionAmounts: new uint[] (0)
            });

            listProgram.push(programs[_nextId]);
            listTokenId.push(_nextId);
            _nextId++;
            _grantRole(PIC_ROLE, _pic);
        }

        function contribute(uint _id, uint256 amount) public payable {
        Program storage programStorage = programs[_id];

        uint256 remainingFundsNeeded = programStorage.targetFund - programStorage.amountNow;

        if(amount < remainingFundsNeeded){
            programStorage.amountNow += amount;
        }
        else if(amount == remainingFundsNeeded){
            programStorage.amountNow += amount;
            programStorage.status = ProgramStatus.Completed;
        }
        else{
            uint excessAmount = amount - remainingFundsNeeded;
            uint refundedAmount = amount - excessAmount;
            payable(msg.sender).transfer(excessAmount);
            programStorage.amountNow += refundedAmount;
            programStorage.status = ProgramStatus.Completed;
        }
        programStorage.contributors.push(msg.sender);
        programStorage.contributionAmounts.push(amount);
    } 
    
}

     




