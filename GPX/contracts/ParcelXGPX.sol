pragma solidity 0.4.19;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./MultiOwnable.sol";
import "./Pausable.sol";
import "./Convertible.sol";


/**
 * The main body of final smart contract 
 */
contract ParcelXGPX is ERC20, MultiOwnable, Pausable, Convertible {

    using SafeMath for uint256;
  
    string public constant name = "ParcelX";
    string public constant symbol = "GPX";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = uint256(1000000000) * (uint256(10) ** decimals);  // 10,0000,0000

    address internal tokenPool = address(0);      // Use a token pool holding all GPX. Avoid using sender address.
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function ParcelXGPX(address[] _multiOwners, uint _multiRequires) 
        MultiOwnable(_multiOwners, _multiRequires) public {
        require(tokenPool == address(0));
        tokenPool = this;
        require(tokenPool != address(0));
        balances[tokenPool] = TOTAL_SUPPLY;
    }

    /**
     * FEATURE 1): ERC20 implementation
     */
    function totalSupply() public view returns (uint256) {
        return TOTAL_SUPPLY;       
    }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
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

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
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
    event Withdraw(address indexed who, uint256 value, address indexed lastApprover, string extra);
        

    function getBuyRate() external view returns (uint256) {
        return buyRate;
    }

    function setBuyRate(uint256 newBuyRate) mostOwner(keccak256(msg.data)) external {
        buyRate = newBuyRate;
    }

    /**
     * FEATURE 4): Buyable
     * minimum of 0.001 ether for purchase in the public, pre-ico, and private sale
     */
    function buy() payable whenNotPaused public returns (uint256) {
        Deposit(msg.sender, msg.value);
        require(msg.value >= 0.001 ether);

        // Token compute & transfer
        uint256 tokens = msg.value.mul(buyRate);
        require(balances[tokenPool] >= tokens);
        balances[tokenPool] = balances[tokenPool].sub(tokens);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        Transfer(tokenPool, msg.sender, tokens);
        
        return tokens;
    }

    // gets called when no other function matches
    function () payable public {
        if (msg.value > 0) {
            buy();
        }
    }

    /**
     * FEATURE 6): Budget control
     * Malloc GPX for airdrops, marketing-events, bonus, etc 
     */
    function mallocBudget(address _admin, uint256 _value) mostOwner(keccak256(msg.data)) external returns (bool) {
        require(_admin != address(0));
        require(_value <= balances[tokenPool]);

        balances[tokenPool] = balances[tokenPool].sub(_value);
        balances[_admin] = balances[_admin].add(_value);
        Transfer(tokenPool, _admin, _value);
        return true;
    }
    
    function execute(address _to, uint256 _value, string _extra) mostOwner(keccak256(msg.data)) external returns (bool){
        require(_to != address(0));
        _to.transfer(_value);   // Prevent using call() or send()
        Withdraw(_to, _value, msg.sender, _extra);
        return true;
    }

    /**
     * FEATURE 5): 'Convertible' implements
     * Below actions would be performed after token being converted into mainchain:
     * - Unsold tokens are discarded.
     * - Tokens sold with bonus will be locked for a period (see Whitepaper).
     * - Token distribution for team will be locked for a period (see Whitepaper).
     */
    function convertMainchainGPX(string destinationAccount, string extra) external returns (bool) {
        require(bytes(destinationAccount).length > 10 && bytes(destinationAccount).length < 1024);
        require(balances[msg.sender] > 0);
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        balances[tokenPool] = balances[tokenPool].add(amount);   // return GPX to tokenPool - the init account
        Converted(msg.sender, destinationAccount, amount, extra);
        return true;
    }

}

