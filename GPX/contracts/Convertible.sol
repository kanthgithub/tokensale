pragma solidity ^0.4.20;

/**
 * Exchange all my ParcelX token to mainchain GPX
 */
contract Convertible {

    function convertMainchainGPX(string destinationAccount, string extra) external returns (bool);
  
    // ParcelX deamon program is monitoring this event. 
    // Once it triggered, ParcelX will transfer corresponding GPX to destination account
    event Converted(address indexed who, string destinationAccount, uint256 amount, string extra);
}

