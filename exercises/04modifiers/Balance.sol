pragma solidity ^0.8.7;

contract UserBalance {
    uint8 private clientCount;
    mapping (address => uint) private balances;
    address public owner;

    struct ContractOwnerStruct {
        string ownerName;
        uint256 ownerAge;
    }

    mapping(address => ContractOwnerStruct) private contractOwnerStructs;
    address[] private userIndex;

    // Constructor is "payable" so it can receive the initial funding of 30, 
    // required to reward the first 3 clients
    constructor() public payable{
        require(msg.value == 30 ether, "30 ether initial funding required");        
        owner = msg.sender;
        clientCount = 0;
    }

    //Structs assignment:
    //set user's info into the struct
    function setUserDetails(address userAddress, string memory _name, uint256 _age) public {
        contractOwnerStructs[userAddress].ownerName = _name;
        contractOwnerStructs[userAddress].ownerAge = _age;
    }

    //send user's info from the struct
    function getUserDetails(address userAddress) public view returns (string memory, uint256){
        return(
            contractOwnerStructs[userAddress].ownerName,contractOwnerStructs[userAddress].ownerAge
        );
    }

    //modifiers assignment

    /// @notice Deposit ether into bank, requires method is "payable"
    /// @return The balance of the user after the deposit is made
    function deposit(uint256 amount) public payable {
        balanceReceived += msg.value;
        donor = msg.sender;
    }



}
