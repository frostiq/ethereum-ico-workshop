pragma solidity ^0.4.17;

import "./Fund.sol";
import "./VestedFund.sol";


contract ReserveFund is VestedFund {
    
    constructor(ERC20Basic _token) VestedFund(_token) public {
        
    }
}