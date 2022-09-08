// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  //handler for user's balances
  mapping(address => uint256) public balances;
  uint256 public constant THRESHOLD = 1 ether;
  //establishing the deadline
  uint256 public deadline = block.timestamp + 12 hours;

  event Stake(address indexed sender, uint256 amount);

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
 function stake() public payable deadlineReached(false) stakeNotCompleted {
    // update the user's balance
    balances[msg.sender] += msg.value;
    
    // emit the event to notify the blockchain that we have correctly Staked some fund for the user
    emit Stake(msg.sender, msg.value);
  }

  modifier deadlineReached( bool requireReached ) {
    uint256 timeRemaining = timeLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Deadline is already reached");
    }
    _;
  }

   /**
  * @notice Modifier that require the external contract to not be completed
  */
  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public stakeNotCompleted deadlineReached(false) {
    uint256 contractBalance = address(this).balance;

    // check the contract has enough ETH to reach the treshold
    require(contractBalance >= THRESHOLD, "Threshold not reached");
    exampleExternalContract.complete{value: address(this).balance}();    

  }  
  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public deadlineReached(true) stakeNotCompleted {
    uint256 userBalance = balances[msg.sender];

    // check if the user has balance to withdraw
    require(userBalance > 0, "You don't have balance to withdraw");

    // reset the balance of the user
    balances[msg.sender] = 0;

    // Transfer balance back to the user
    (bool sent,) = msg.sender.call{value: userBalance}("");
    require(sent, "Failed to send user balance back to the user");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    this.stake();
  }

}
