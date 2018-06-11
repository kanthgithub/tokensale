pragma solidity ^0.4.19;

/**
 * FEATURE 2): MultiOwnable implementation
 * Creator address + _otherOwners addresses. Transactions approved by _multiRequires addresses will be executed. 

 * All functions needing unit-tests cannot be INTERNAL
 */
contract MultiOwnable {

    address[8] m_owners;
    uint m_numOwners;
    uint m_multiRequires;

    mapping (bytes32 => uint) internal m_pendings;

    // constructor is given number of sigs required to do protected "multiOwner" transactions
    function MultiOwnable (address[] _otherOwners, uint _multiRequires) {
        require(0 < _multiRequires && _multiRequires <= _otherOwners.length + 1);
        m_numOwners = _otherOwners.length + 1;
        require(m_numOwners <= 8);   // 不支持大于8人
        m_owners[0] = msg.sender;
        for (uint i = 0; i < _otherOwners.length; ++i) {
            m_owners[1 + i] = _otherOwners[i];
        }
        m_multiRequires = _multiRequires;
    }

    // Any one of the owners, will approve the action
    modifier anyOwner {
        if (isOwner(msg.sender)) {
            _;
        }
    }

    // Requiring num > m_multiRequires owners, to approve the action
    modifier mostOwner(bytes32 operation) {
        if (checkAndConfirm(msg.sender, operation)) {
            _;
        }
    }

    function isOwner(address currentUser) view returns (bool) {
        for (uint i = 0; i < m_numOwners; ++i) {
            if (m_owners[i] == currentUser) {
                return true;
            }
        }
        return false;
    }

    function checkAndConfirm(address currentUser, bytes32 operation) returns (bool) {
        uint ownerIndex = m_numOwners;
        uint i;
        for (i = 0; i < m_numOwners; ++i) {
            if (m_owners[i] == currentUser) {
                ownerIndex = i;
            }
        }
        if (ownerIndex == m_numOwners) {
            return false;  // Not Owner
        }
        
        uint newBitFinger = (m_pendings[operation] | (2 ** ownerIndex));

        uint confirmTotal = 0;
        for (i = 0; i < m_numOwners; ++i) {
            if ((newBitFinger & (2 ** i)) > 0) {
                confirmTotal ++;
            }
        }
        if (confirmTotal >= m_multiRequires) {
            delete m_pendings[operation];
            return true;
        }
        else {
            m_pendings[operation] = newBitFinger;
            return false;
        }
    }
}
