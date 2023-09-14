// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * THIS EXAMPLE USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract farm_coll is ChainlinkClient{
    using Chainlink for Chainlink.Request;

    uint256 public pH;
    uint256 public Ec;
    uint public  price_per_litre= 2 wei;
    uint public amt;
    address payable public collector ;
    address payable public Farmer ;


    bytes32 private jobId;
    uint256 private fee;

    event RequestEc(bytes32 indexed requestId, uint256 Ec);
    event RequestpH(bytes32 indexed requestId, uint256 pH);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Sepolia Testnet details:
     * Link Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789
     * Oracle: 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor(){
        collector= payable(msg.sender);
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 100 (to remove decimal places from data).
     */

     //function to request Ec
    function requestEcData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill1.selector
        );

        // Set the URL to perform the GET request on
        req.add(
            "get",
            "https://fiyt-a6244-default-rtdb.firebaseio.com/.json"
        );

        
        req.add("path", "Ec"); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 2;
        req.addInt("times", timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

 //function to request ph

    function requestpHData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        req.add(
            "get",
            "https://fiyt-a6244-default-rtdb.firebaseio.com/.json"
        );

        
        req.add("path", "Ph"); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 2;
        req.addInt("times", timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */

     function fulfill1(
        bytes32 _requestId,
        uint256 _Ec
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestEc(_requestId, _Ec);
        Ec = _Ec;
    }

    function fulfill(
        bytes32 _requestId,
        uint256 _pH
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestpH(_requestId, _pH);
        pH = _pH;
    }



    function sentmilk() external 
    {   //chainlink
        requestpHData();
        requestEcData();
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

/**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public {
        require(msg.sender == collector && msg.sender!=address(0),"invalid or unauthorised address");
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}

    
