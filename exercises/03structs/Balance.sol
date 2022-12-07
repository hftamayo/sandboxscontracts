// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract UserBalance {
    uint8 private clientCount;
    mapping (address => uint) private balances;
    address public owner;

    struct UserStruct {
        string userName;
        uint256 userAge;
    }

    UserStruct public userStruct;
    address[] private userIndex;

    constructor() {
        owner = msg.sender;
        clientCount = 0;
    }

    /// @notice Deposit ether into bank, requires method is "payable"
    /// @return The balance of the user after the deposit is made
    function deposit(uint256 amount) public payable returns (uint256) {
        balances[msg.sender] += amount;
        return balances[msg.sender];
    }

    /// @notice Just reads balance of the account requesting, so "constant"
    /// @return The balance of the user
    function checkBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /// @return The balance of the Simple Bank contract
    function depositsBalance() public view returns (uint) {
        return address(this).balance;
    }

    //Structs assignment:
    //set user's info into the struct
    function setUserDetails(string calldata _name, uint256 _age) public {
        UserStruct storage new_userStruct = userStruct;
        new_userStruct.userName = _name;
        new_userStruct.userAge = _age;
    }

    //send user's info from the struct
    function getUserDetails() public view returns (UserStruct memory){
        return userStruct;
    }
}
