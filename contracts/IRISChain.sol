// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
abstract contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) external view virtual returns (uint256);
    function transfer(address to, uint256 value) external virtual returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Ownable {
    event AddressAllowed(address indexed addr, bool allowed);
    event AddressLocked(address indexed addr, bool locked);
    event ContractLocked(bool locked);

    mapping(address => uint256) balances;
    mapping(address => bool) public allowedAddresses;
    mapping(address => bool) public lockedAddresses;
    bool public locked = false;

    function allowAddress(address _addr, bool _allowed) public onlyOwner {
        require(_addr != address(0), "Cannot modify zero address");
        require(_addr != owner, "Cannot modify owner's address");
        allowedAddresses[_addr] = _allowed;
        emit AddressAllowed(_addr, _allowed);
    }

    function lockAddress(address _addr, bool _locked) public onlyOwner {
        require(_addr != address(0), "Cannot modify zero address");
        require(_addr != owner, "Cannot modify owner's address");
        lockedAddresses[_addr] = _locked;
        emit AddressLocked(_addr, _locked);
    }

    function setLocked(bool _locked) public onlyOwner {
        locked = _locked;
        emit ContractLocked(_locked);
    }

    function canTransfer(address _addr) public view returns (bool) {
        if (locked) {
            if (!allowedAddresses[_addr] && _addr != owner) return false;
        } else if (lockedAddresses[_addr]) return false;

        return true;
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(canTransfer(msg.sender), "Sender cannot transfer");
        require(balances[msg.sender] >= _value, "Insufficient balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) external view override returns (uint256 balance) {
        return balances[_owner];
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        require(newOwner != owner, "New owner cannot be the current owner");
        require(!lockedAddresses[msg.sender], "Current owner is locked");

        allowedAddresses[newOwner] = true;
        allowedAddresses[owner] = false;

        super._transferOwnership(newOwner);
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
abstract contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) external view virtual returns (uint256);
    function transferFrom(address from, address to, uint256 value) external virtual returns (bool);
    function approve(address spender, uint256 value) external virtual returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is ERC20, BasicToken {
    mapping(address => mapping(address => uint256)) allowed;

    function safeApprove(address _spender, uint256 _currentValue, uint256 _value) internal {
        require(allowed[msg.sender][_spender] == _currentValue, "Current allowance value does not match");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(canTransfer(msg.sender), "Sender cannot transfer");
        require(canTransfer(_from), "From address cannot transfer");
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "Insufficient allowance");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        require(_spender != address(0), "Cannot approve zero address");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        require(_spender != address(0), "Cannot approve zero address");
        uint256 currentAllowance = allowed[msg.sender][_spender];
        safeApprove(_spender, currentAllowance, currentAllowance + _addedValue);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        require(_spender != address(0), "Cannot approve zero address");
        uint256 currentAllowance = allowed[msg.sender][_spender];
        uint256 newValue = _subtractedValue > currentAllowance ? 0 : currentAllowance - _subtractedValue;
        safeApprove(_spender, currentAllowance, newValue);
        return true;
    }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {
        require(_value > 0, "Burn amount must be greater than 0");
        require(balances[msg.sender] >= _value, "Insufficient balance");

        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
    }
}

contract Token is BurnableToken {
    string public constant name = "IRIS";
    string public constant symbol = "IRC";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 2000000000 * (10 ** uint256(decimals));

    constructor() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        allowedAddresses[owner] = true;
    }
}