pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Contactable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract MyIcoToken is ERC20, Contactable {
    using SafeMath for uint;

    // token name (string)
    string constant public name = "MyIco Token";
    // token symbol (string)
    string constant public symbol = "ICO";
    // decimals amount (uint8)
    uint8 constant public decimals = 18;

    // total tokens amount (uint)
    uint public totalSupply_;
    // ICO activation status (bool)
    bool public isActivated = false; 
    // address, who is allowed to issue new tokens (presale and sale contracts)
    address public minter;
    // mitning status (bool)
    bool public mintingFinished = false;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) internal allowed;
    mapping (address => bool) public freezedList;
    
    event Mint(address indexed to, uint amount);
    event MintingFinished();

    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier whenActivated() {
        require(isActivated);
        _;
    }

    constructor() public {
        minter = msg.sender;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) whenActivated public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(!freezedList[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value) whenActivated public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(!freezedList[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint _value) public returns (bool) {
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

      /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint _amount, bool freeze) canMint onlyMinter external returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        if (freeze) {
            freezedList[_to] = true;
        }
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    
    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() canMint onlyMinter external returns (bool) {
        mintingFinished = true;
        emit MintingFinished();
        return true;
    }
    
    /**
     * Minter can pass it's role to another address
     */
    function setMinter(address _minter) external onlyMinter {
        require(_minter != 0x0);
        minter = _minter;
    }

    /**
     * Owner can unfreeze any address
     */
    function removeFromFreezedList(address user) external onlyOwner {
        freezedList[user] = false;
    }

    /**
     * Activation of the token allows all tokenholders to operate with the token
     */
    function activate() external onlyOwner returns (bool) {
        isActivated = true;
        return true;
    }
}
