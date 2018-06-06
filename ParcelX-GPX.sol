pragma solidity ^0.4.20;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./MultiOwnable.sol";
import "./Pausable.sol";
import "./Buyable.sol";
import "./Convertible.sol";


/**
 * The main body of final smart contract 
 */
contract ParcelXToken is ERC20, MultiOwnable, Pausable, Buyable, Convertible {

    using SafeMath for uint256;
  
    string public constant name = "ParcelX Token";
    string public constant symbol = "GPX";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = uint256(1000000000) * (uint256(10) ** decimals);  // 10,0000,0000

    address internal creator;
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function ParcelXToken(address[] _otherOwners, uint _multiRequires) 
        MultiOwnable(_otherOwners, _multiRequires) public {
        creator = msg.sender;
        balances[creator] = TOTAL_SUPPLY;
    }

    /**
     * FEATURE 1): ERC20 implementation
     */
    function totalSupply() public view returns (uint256) {
        return TOTAL_SUPPLY;       
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
  }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * FEATURE 4): Buyable implements
     * 0.000268 eth per GPX, so the rate is 1.0 / 0.000268 = 3731.3432835820895
     */
    uint256 internal buyRate = uint256(3731); 
    
    event Deposit(address indexed who, uint256 value);
    event Withdraw(address indexed who, uint256 value, address indexed lastApprover);
        

    function getBuyRate() public view returns (uint256) {
        return buyRate;
    }

    function setBuyRate(uint256 newBuyRate) mostOwner(keccak256(msg.data)) public {
        buyRate = newBuyRate;
    }

    // minimum of 1 ether for purchase in the public, pre-ico, and private sale
    function buy() payable whenNotPaused public returns (uint256) {
        require(msg.value >= 1 ether);
        uint256 tokens = msg.value.mul(buyRate);  // calculates the amount
        require(balances[creator] >= tokens);               // checks if it has enough to sell
        balances[creator] = balances[creator].sub(tokens);                        // subtracts amount from seller's balance
        balances[msg.sender] = balances[msg.sender].add(tokens);                  // adds the amount to buyer's balance
        Transfer(creator, msg.sender, tokens);               // execute an event reflecting the change
        return tokens;                                    // ends function and returns
    }

    // gets called when no other function matches
    function () public payable {
        if (msg.value > 0) {
            buy();
            Deposit(msg.sender, msg.value);
        }
    }

    function execute(address _to, uint256 _value, bytes _data) mostOwner(keccak256(msg.data)) external returns (bool){
        require(_to != address(0));
        Withdraw(_to, _value, msg.sender);
        return _to.call.value(_value)(_data);
    }

    /**
     * FEATURE 5): Convertible implements
     */
    function convertMainchainGPX(string destinationAccount, string extra) public returns (bool) {
        require(bytes(destinationAccount).length > 10 && bytes(destinationAccount).length < 128);
        require(balances[msg.sender] > 0);
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        balances[creator] = balances[creator].add(amount);   // recycle ParcelX to creator's init account
        Converted(msg.sender, destinationAccount, amount, extra);
        return true;
    }

}
