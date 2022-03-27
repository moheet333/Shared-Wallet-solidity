// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Allowance is Ownable {

    event AllowanceChanged (address indexed _forWho , address indexed _fromWhom , uint _oldAllowance , uint _newAllowance);

    mapping(address => uint) public allowance;

    function isOwner () internal view returns (bool) {
        return owner() == msg.sender;
    }

    function addAllowance (address payable _who , uint _amount) public onlyOwner{
        emit AllowanceChanged (_who , msg.sender , allowance[_who] , _amount);
        allowance[_who] += _amount;
    }

    modifier onwerOrAllowed (uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount , "You are not allowed.");
        _;
    }

    function reduceAllowance (address _who , uint _amount) internal {
        emit AllowanceChanged (_who , msg.sender , allowance[_who] , allowance[_who] - _amount);
        allowance[_who] -= _amount;
        }


}

contract SharedWallet is Allowance {

    event MoneySent (address indexed _beneficiary , uint _amount);
    event MoneyReceived (address indexed _from , uint _amount);
    
    function WithdrawMoney (address payable _to , uint _amount) public onwerOrAllowed(_amount){
        require(address(this).balance >= _amount , "Contract doesn't have enough balance.");
        if(!isOwner()){
            reduceAllowance(msg.sender , _amount);
        }
        emit MoneySent (_to , _amount);
        _to.transfer(_amount);
    }

    receive () external payable {
        emit MoneyReceived (msg.sender , msg.value);
    }  

}