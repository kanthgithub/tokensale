pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MultiOwnable.sol";


// http://truffleframework.com/docs/getting_started/solidity-tests
// Why filename should be same as contract name? Otherwise, error(s) will be occur in running 'truffle test'
contract TestMultiOwnable {

  function testCheckMultiOwners() public {
  	address a0 = 0x1;
  	address a1 = 0x2;
  	address a2 = 0x3;
  	address a3 = 0x4;
  	address[] memory arr = new address[](3);
  	arr[0] = a0;
  	arr[1] = a1;
  	arr[2] = a2;
  	
    MultiOwnable instance = new MultiOwnable(arr, 2);
    Assert.isFalse(instance.checkAndConfirm(a0, keccak256('OP1')), "Step 1");
    Assert.isFalse(instance.checkAndConfirm(a0, keccak256('OP2')), "Step 2");

	Assert.isFalse(instance.checkAndConfirm(a1, keccak256('OP3')), "Step 3");
	Assert.isTrue(instance.checkAndConfirm(a1, keccak256('OP2')), "Step 4");

	Assert.isFalse(instance.checkAndConfirm(a1, keccak256('OP2')), "Step 5");
	Assert.isFalse(instance.checkAndConfirm(a3, keccak256('OP2')), "Step 6");
	Assert.isTrue(instance.checkAndConfirm(a2, keccak256('OP2')), "Step 7");

  }
}
