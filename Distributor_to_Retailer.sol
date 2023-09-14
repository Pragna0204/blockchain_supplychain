//SPDX-License-Identifier: MIT
pragma solidity>= 0.5.0 < 0.9.0;

contract Distributor_to_Retailer{
    uint public litres;
    uint public  price_per_litre= 2 wei;
    uint public amt;
    address payable public retailer ;
    address payable public distributor ;
    constructor (){
        retailer= payable(msg.sender);
    }

    function sentmilk(uint _litres) external 
    { 
        litres=_litres;
        distributor=payable(address(msg.sender));
    }

    function getBalance () public view returns (uint)
    { 
       return address(msg.sender). balance;
    }


    function payment() external  payable {
        //require(msg.sender == collector && msg.sender!=address(0),"invalid or unauthorised address");
        amt = litres;
        distributor.transfer(amt);

    }


}