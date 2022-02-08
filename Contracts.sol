// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract A is Ownable {

  address public myAddr = address(this);

  B b;

  /* Starts the B contract with a null address to mitigate hard-coding, just add through the updateContract function. */

  constructor() {
    b = B(address(0));
  }

  /* isContract function determines if an address is a contract, which allows prevention of accidentally switching contract A or B to a wallet */

  function isContract(address m) public view returns (bool){
      uint32 size;
      assembly {
        size := extcodesize(m)
      }
      return (size > 0);
  }

  /* Deposit function allows users to deposit ERC20 tokens and notifies contract B to store the data. The user has to approve tokens from the ERC20 contract due to the nature of ERC20 tokens, vs an alternative like ERC777 which provides open approval, eliminating this middle step. */

  function Deposit(address _token, uint _amount) public onlyOwner {
    require(isContract(_token), "The token address must be a contract.");
    ERC20(_token).transferFrom(msg.sender, myAddr, _amount);
    b.depositComplete(msg.sender, _token, _amount);
  }

  /* Updates contract B. */
  
  function updateContract(address _newContract) public onlyOwner {
    require(isContract(_newContract), "You can only swap to a contract.");
    b = B(_newContract);
  }
}

contract B {

  address public myAddr = address(this);

  /* OnlyAdmin modifier, allows both contract A and the specified admin (deployer on construction) to write in the onlyAdmin functions */

  modifier onlyAdmin {
    require(msg.sender == address(a) || msg.sender == admin, "Only callable by admins.");
    _;
  }

  /* Where deposit info is stored, each user has an array of deposits. */

  mapping(address => Deposit[]) public deposits;

  A a;
  address admin;
  
  /* Starts the A contract with a null address to mitigate hard-coding, just add through the updateOwnership function. */

  constructor() {
    a = A(address(0));
    admin = msg.sender;
  }

  /* Deposit struct. */

  struct Deposit {
    address user;
    address token;
    uint amount;
  }

  /* isContract function determines if an address is a contract, which allows prevention of accidentally switching contract A or B to a wallet */

  function isContract(address m) public view returns (bool){
      uint32 size;
      assembly {
        size := extcodesize(m)
      }
      return (size > 0);
  }

  /* I opted for a single function with an onlyAdmin role for efficiency because it allows for both the contract A and owner to channel through one function. */

  function depositComplete(address _user, address _token, uint _amount) public onlyAdmin {
    require(isContract(_token), "The token address must be a contract.");
    Deposit memory _deposit = Deposit(_user, _token, _amount);
    deposits[_user].push(_deposit);
  }

  /* Opted for another single function with this that allows for the admin to enter the parameter they want to change, this could also be done with two functions. Keccak allows me to compare the strings which I take in a parameter. */

  function updateOwnership(string memory _update, address _newAddress) public onlyAdmin {
    if (keccak256(abi.encodePacked(_update)) == keccak256(abi.encodePacked("a"))) {
      require(isContract(_newAddress), "You can only swap to a contract.");
      a = A(_newAddress);
    } else if (keccak256(abi.encodePacked(_update)) == keccak256(abi.encodePacked("admin"))) {
      admin = _newAddress;
    }
  }

  /* Deposit lookup function to access deposit data. */

  function locateDeposit(address _user, uint _index) public view returns (address, address, uint) {
    Deposit memory entry = deposits[_user][_index];
    return (entry.user, entry.token, entry.amount);
  }
}
