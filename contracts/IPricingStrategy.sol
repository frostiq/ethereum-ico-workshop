pragma solidity ^0.4.17;

interface IPricingStrategy {

    function isPricingStrategy() external view returns (bool);

    /** Calculate the current price for buy in amount. */
    function calculateTokenAmount(uint weiAmount, uint tokensSold) external view returns (uint tokenAmount);

}