//SPDX-License-Identifier: MIT
pragma solidity>= 0.5.0 < 0.9.0;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol'; 

contract Farmer_to_Collector is ChainlinkClient{
    using Chainlink for Chainlink.Request;
    

    bytes32 private jobId;
    uint256 private fee;

    uint public litres ;
    uint public pH;
    uint public Ec;
    uint public  price_per_litre= 2 wei;
    uint public amt;
    address payable public collector ;
    address payable public Farmer ;

    event RequestMultipleFulfilled(bytes32 indexed requestId, uint256 pH, uint256 Ec);

    constructor (){
        collector= payable(msg.sender);
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        setChainlinkOracle(0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10;
    }

    // Chainlink
    function requestUnitsData() public  {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillMultipleParameters.selector);
        
        req.add("urlpH","https://fiyt-a6244-default-rtdb.firebaseio.com/.json");
        req.add("pathPh", "Ph");

        req.add("urlEc","https://fiyt-a6244-default-rtdb.firebaseio.com/.json" );
        req.add("pathEc", "Ec");
        
        int256 timesAmount = 10 ** 2;
        req.addInt('times', timesAmount);
        sendChainlinkRequest(req, fee);
    }

    function fulfillMultipleParameters(bytes32 requestId, uint256 _pHresponse,uint256 _Ecresponse) public recordChainlinkFulfillment(requestId) {
        emit RequestMultipleFulfilled(
            requestId,
            _pHresponse,
            _Ecresponse
        );
        pH=_pHresponse;
        Ec=_Ecresponse;

        
    }



    function sentmilk() external 
    {   
        
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
        amt = price_per_litre;
        Farmer.transfer(amt);

    }


}