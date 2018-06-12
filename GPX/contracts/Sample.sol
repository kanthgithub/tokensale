pragma solidity ^0.4.19;

/**
 * A sample evaluates whether write-ops could be commited in truffle test-cases.    
 */
contract Sample {

    uint public i = 10;
    
    function add() public returns (uint) {
        i ++;
        return i;
    }
}
