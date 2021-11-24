// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Bet{

  address[] public players;
  mapping(address => bool) isPlayer;
  uint public numPositions;

  mapping(uint => address payable[]) addrPosition;
  mapping(address => uint) posPlayer;
  mapping(address => uint) valuePlayer;

  constructor(address[] memory _players, uint _numPositions) public payable {
    require(_players.length > 0, "Invalid player address");
    require(_numPositions > 0 && _numPositions <= _players.length, "Invalid number of positions");

    for (uint i = 0; i < _players.length; i++){
      address player = _players[i];
      require(player != address(0), "Invalid player");
      require(!isPlayer[player], "Player not unique");
      isPlayer[player] = true;
      players.push(player);
    }
  }
  
  modifier playerExists() {
    require(isPlayer[msg.sender], "player does not exist");
    _;
  }

  modifier playerPayable(uint _value){
    require(_value <= address(this).balance, "Not enough eth" );
    _;
  }

  function Deposit() 
  playerExists()
  playerPayable(msg.value)
  public payable{
    valuePlayer[msg.sender] = msg.value;
  }

  modifier positionExists(uint _position){
    require(_position <= numPositions && _position > 0, "Invalid position");
    _;
  }

  function makeBet(uint _position)
  playerExists()
  positionExists(_position)
  public
  {
    addrPosition[_position].push(payable(msg.sender));
    posPlayer[msg.sender] = _position;
  }

  modifier isBetsMaked(){
    for (uint i = 0; i < players.length; i++){
      require(posPlayer[players[i]] > 0 && valuePlayer[players[i]] > 0, "All player must make bets");
    }
    _;
  }

  function ethDistribution(uint _rightPosition)
  isBetsMaked()
  payable external 
  {
    uint numWinners = addrPosition[_rightPosition].length;
    uint sum_value = 0;
    address payable tempaddr;

   for (uint i = 0; i < numPositions; i++){
      if (posPlayer[players[i]] == _rightPosition)
        continue;
      for (uint q = 0; q < numWinners; q++){
        tempaddr = addrPosition[_rightPosition][q];
        tempaddr.transfer(valuePlayer[players[i]] * valuePlayer[tempaddr] / sum_value);
      }     
    }
  }
}
