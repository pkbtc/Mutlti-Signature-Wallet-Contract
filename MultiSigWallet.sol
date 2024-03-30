// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSig{
    address[] public owner;
    uint public noOfConfirmationRequired;

    struct Transaction{
        address to;
        uint value;
        bool excecuted;

    }

    mapping(uint=>mapping(address=>bool)) isConfirmed;
    Transaction[] public transactions; 

    event TransactionSubmitted(uint transactionId,address sender,address reciever,uint amount);
    event TransactionConfired(uint transactionId);
    event TransactionExcecuted(uint transactionId);


    constructor(address[] memory _owner,uint _noOfconfirmationRequired){
        require(_owner.length>1,"owner should be more than 1");
        require(_noOfconfirmationRequired>0 && _noOfconfirmationRequired<=_owner.length,"the number of confirmation does not match with the owner number");

        for(uint i=0;i<_owner.length;i++){
            require(_owner[i]!=address(0),"address cannot be empty");
            owner.push(_owner[i]);
        }
        noOfConfirmationRequired=_noOfconfirmationRequired;
    }

    function submitTransaction(address _to) public payable{
        require(_to!=address(0),"invalid reciever address");
        require(msg.value>0,"value should be greater than zero");
        uint transactionId=transactions.length;
        transactions.push(Transaction({to:_to,value:msg.value,excecuted:false})); 
        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    function ConfirmTransaction(uint _transactionId) public {
       require(_transactionId<transactions.length,"ninvalid trsanction id");
       require(!isConfirmed[_transactionId][msg.sender],"transaction is already confirmed by the owner");
       isConfirmed[_transactionId][msg.sender]=true;
       emit TransactionConfired(_transactionId);
       if(isTransactionConfirmed(_transactionId)){
        excetuTransaction(_transactionId);
       }
    }
    function excetuTransaction(uint _transactionId) public   payable{
        require(_transactionId<transactions.length,"invalid transaction id");
        require(!transactions[_transactionId].excecuted,"transaction is already excecuted");
       (bool sucess,)= transactions[_transactionId].to.call{value:transactions[_transactionId].value}("");
       require(sucess,"transaction excuted failed");
       emit TransactionExcecuted(_transactionId);
        




    }

    function isTransactionConfirmed(uint _transactionId) public view returns(bool){
        require(_transactionId<transactions.length,"invalid transaction id");
        uint countConfirmedTransaction;

        for(uint i=0;i<owner.length;i++){
            if(isConfirmed[_transactionId][owner[i]]){
                countConfirmedTransaction++;
            }

        }
        return countConfirmedTransaction>=noOfConfirmationRequired;
    }


}