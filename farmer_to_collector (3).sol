//SPDX-License-Identifier: MIT
pragma solidity>= 0.5.0 < 0.9.0;

contract Farmer_to_Collector{
    uint public litres;
    uint public pH;
    uint public Ec;
    uint public  price_per_litre= 2 wei;
    uint public amt;
    address payable public collector ;
    address payable public Farmer ;
    constructor (){
        collector= payable(msg.sender);
    }

    function sentmilk(uint _pH,uint _Ec,uint _litres) external 
    { 
        litres=_litres;
        pH=_pH;
        Ec=_Ec;
        Farmer=payable(address(msg.sender));
    }


    modifier quality_check(){
        require(pH >= 645 && pH <= 667,"adulterated milk,no payment");
        require(Ec >= 465 && Ec <= 526,"adulterated milk,no payment");
        _;
    }

    function getBalance () public view returns (uint)
    { 
       return address(msg.sender). balance;
    }


    function payment() external quality_check() payable {
        //require(msg.sender == collector && msg.sender!=address(0),"invalid or unauthorised address");
        amt = litres;
        Farmer.transfer(amt);

    }


}