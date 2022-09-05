// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

contract UserBalance {
    uint8 private clientCount;
    mapping (address => uint256) private balances;
    address public owner;

  // Log the event about a deposit being made by an address and its amount
    event LogDepositMade(address indexed accountAddress, uint amount);

    // Constructor is "payable" so it can receive the initial funding of 30, 
    // required to reward the first 3 clients
    constructor() payable {
        owner = payable(msg.sender);
    }

    /// @notice Deposit ether into bank, requires method is "payable"
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint256) {
        balances[msg.sender] += msg.value;
        emit LogDepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    receive() external payable{
        deposit();
    }

    fallback() external payable{
        deposit();
    }    

    /// @return The balance of the Simple Bank contract
    function depositsBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
