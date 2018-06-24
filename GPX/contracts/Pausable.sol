pragma solidity 0.4.19;

import "./MultiOwnable.sol";

/**
 * FEATURE 3): Pausable implementation
 */
contract Pausable is MultiOwnable {
    event Pause();
    event Unpause();

    bool paused = false;

    // Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    // Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(paused);
        _;
    }

    // called by the owner to pause, triggers stopped state
    function pause() mostOwner(keccak256(msg.data)) whenNotPaused public {
        paused = true;
        Pause();
    }

    // called by the owner to unpause, returns to normal state
    function unpause() mostOwner(keccak256(msg.data)) whenPaused public {
        paused = false;
        Unpause();
    }

    function isPause() view public returns(bool) {
        return paused;
    }
}
