//SPDX-License-Identifier: MIT
pragma solidity>= 0.5.0 < 0.9.0;

contract Processing_to_Distributor{
    uint public litres;
    uint public  price_per_litre= 2 wei;
    uint public amt;
    address payable public processing ;
    address payable public distributor ;
    constructor (){
        distributor= payable(msg.sender);
    }

    function sentmilk(uint _litres) external 
    { 
        litres=_litres;
        processing=payable(address(msg.sender));
    }

    function getBalance () public view returns (uint)
    { 
       return address(msg.sender). balance;
    }


    function payment() external  payable {
        //require(msg.sender == collector && msg.sender!=address(0),"invalid or unauthorised address");
        amt = litres;
        processing.transfer(amt);

    }


}