pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Contactable.sol";
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";


contract FundBase is Contactable {
    using SafeERC20 for ERC20Basic;
    
    ERC20Basic public token;

    constructor(ERC20Basic _token) public {
        token = _token;
    }
}