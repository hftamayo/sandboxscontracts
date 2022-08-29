pragma solidity ^0.5.8;

contract UserBalance {
    uint8 private clientCount;
    mapping (address => uint) currentBalance;
    address public owner;

    struct User {
        string name;
        uint256 age;
    }

    User public new_current_user = current_user;

    constructor(){
        current_user.setUserDetails("Herbert Tamayo", 43);
    }

    modifier checkingBalance(){
        require(currentBalance[msg.sender]>0, "Not enough available funds for the requested operation");
    }

    //set user's info into the struct
    function setUserDetails(string memory _name, uint256 _age) public {
        current_user.name = _name;
        current_user.name = _age;
    }

    //send user's info from the struct
    function getUserDetails() public views return (User memory){
        return current_user;
    }

    /// @notice Deposit ether into bank, requires method is "payable"
    /// @return The balance of the user after the deposit is made
    function deposit(uint256 amount) public payable returns (uint256) {
        currentBalance[msg.sender] += amount;
        return currentBalance[msg.sender];
    }

    function withdraw(){
        address payable to = payable(msg.sender);
        to.transfer(checkBalance[msg.sender]);
        checkBalance(msg.sender) = 0;
    }

    function addFund(uint256 _amount){
        depositsBalance[msg.sender] += _amount;
    }


    /// @notice Just reads balance of the account requesting, so "constant"
    /// @return The balance of the user
    function checkBalance() public view returns (uint) {
        return currentBalance[msg.sender];
    }

    /// @return The balance of the Simple Bank contract
    function depositsBalance() public view returns (uint) {
        return address(this).balance;
    }
}
