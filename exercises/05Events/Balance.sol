pragma solidity ^0.8.7;

contract UserBalance {
    uint256 private constant FEE = 3;
    mapping (address => uint) private balances;
    address public owner;

    struct UserStruct {
        bytes32 userName;
        uint256 userAge;
    }

    struct DonorStruct {
        bytes32 donorName;
        uint256 donorAmount;
    }
    mapping(address => UserStruct) private userStructs;
    address[] private userIndex;

    mapping(address => DonorStruct) private donorStructs;
    address[] private donorIndex;

    //@notice customError
    error AmountToSmall (uint256 sent, uint256 minRequired);    

    //event's assignment
    event FundsDeposited(address user, uint256 amount);
    event ProfileUpdated(address user);

    constructor() {
        owner = msg.sender;
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

    //Structs assignment:
    //set user's info into the struct
    function setUserDetails(address userAddress, bytes32 _name, uint256 _age) public {
        userStructs[userAddress].userName = _name;
        userStructs[userAddress].userAge = _age;
    }

    //send user's info from the struct
    function getUserDetails(address _addr) public view returns (UserStruct memory){
        return(
            userStructs[_addr]
        );
    }

    //Modifiers assignment:

    /// @notice set donor's info into a struct
    function depositFromDonor(address donorAddress, bytes32 _donor, uint256 _amount) public {
        donorStructs[donorAddress].donorName = _donor;
        donorStructs[donorAddress].donorAmount += _amount;
        balances[msg.sender] += _amount;
    }    

   // Checking if the caller is the owner of the contract.
    modifier checkOwner() {
        require(msg.sender == owner, "Operation restricted to the Owner");
        _;
    }    

    function withdraw(uint256 _amount) public {
        balances[msg.sender] -= _amount;
    }

    modifier checkAddFundConstraints(address _addr){
        require(donorStructs[_addr].donorName.length == 0, "Donor needs to have a donation previously");
        require(donorStructs[_addr].donorAmount == 0, "The balance is zero. Make a deposit first");
        _;
    }

    function addFund(address _addr, uint256 _amount) public {
        if (_amount < FEE){
            revert AmountToSmall({
                sent: _amount,
                minRequired: FEE
            });
        } else {
            donorStructs[_addr].donorAmount = donorStructs[_addr].donorAmount + _amount;
            emit FundsDeposited(_addr, _amount);
        }
    }

    //@notice: events assignment

    function updateDonorInfo(address donorAddress, bytes32 _name) public {
        donorStructs[donorAddress].donorName = _name;
        emit ProfileUpdated(donorAddress);
    }    

}
