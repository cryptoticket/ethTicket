// developed by Phenom.Team
// contact us for any questions:
// info@phenom.Team

pragma solidity ^0.4.15;

contract Tickets {

    string public name = "Crypto ticket";
    string public symbol = "TIC";
    uint8 public decimals = 0;

    address[30000] public holders;
    mapping(uint256 => bool) public usedTickets;
    mapping(uint256 => string) public additionalInfo;
    mapping(address => uint[16]) public seatsList;
    mapping(address => uint256) public balanceOf;

    address ManagerForMint;
    address ManagerForTransfer;
    address ManagerForRedeem;
    address nullAddress = 0x0;

    uint public limitPerHolder = 16;
    uint public seatsCount = 30000;
    uint scaleMultiplier = 1000000000000000000;

    modifier _managerForMint_ { require(msg.sender == ManagerForMint); _; }
    modifier _managerForTransfer_ { require(msg.sender == ManagerForTransfer); _; }
    modifier _managerForRedeem_ { require(msg.sender == ManagerForRedeem); _; }

    event LogAllocateTicket(uint256 _seatID, address _buyer, string _infoString);
    event LogTransfer(address _holder, address _receiver, uint256 _numberOfSea, string _infoStringt);
    event LogRedeemTicket(uint _seatID, address _holder, string _infoString);

    function Tickets(address _ManagerForMint, address _ManagerForTransfer, address _ManagerForRedeem) {
        ManagerForMint = _ManagerForMint;
        ManagerForTransfer = _ManagerForTransfer;
        ManagerForRedeem = _ManagerForRedeem;
    }

    function allocateTicket(uint256 seatID, address buyer, string infoString) external _managerForMint_ {
        require(seatID > 0 && seatID < seatsCount);
        require(holders[seatID] == nullAddress);
        require(balanceOf[buyer] < limitPerHolder);
        uint i = 0;
        for(i = 0; i < limitPerHolder; i++)
        {
            if(seatsList[buyer][i] == 0)
            {
                break;
            }
        }
        holders[seatID] = buyer;
        balanceOf[buyer] += 1;
        additionalInfo[seatID] = infoString;
        seatsList[buyer][i] = seatID;
        LogAllocateTicket(seatID, buyer, infoString);
    }

    function redeemTicket(uint seatID, address holder) external _managerForRedeem_ {
        require(seatID > 0 && seatID < seatsCount);
        require(usedTickets[seatID] == false);
        require(holders[seatID] == holder);
        usedTickets[seatID] = true;
        string infoString = additionalInfo[seatID];
        LogRedeemTicket(seatID, holder, infoString);
    }

    function transfer(address holder, address receiver, uint256 seatID) external _managerForTransfer_{
        require(seatID > 0 && seatID < seatsCount);
        require(holders[seatID] == holder);
        require(balanceOf[receiver] < limitPerHolder);
        uint i = 0;
        holders[seatID] = receiver;
        balanceOf[holder] -= 1;
        if(receiver != nullAddress)
        {
            for(i = 0; i < limitPerHolder; i++)
              {
                  if(seatsList[receiver][i] == 0)
                  {
                     break;
                  }
            }
            balanceOf[receiver] += 1;
            seatsList[receiver][i] = seatID;
        }
        for(i = 0; i < limitPerHolder; i++)
        {
            if(seatsList[holder][i] == seatID)
            {
                seatsList[holder][i] = 0;
            }
        }
        string infoString = additionalInfo[seatID];
        LogTransfer(holder, receiver, seatID, infoString);
    }
}
