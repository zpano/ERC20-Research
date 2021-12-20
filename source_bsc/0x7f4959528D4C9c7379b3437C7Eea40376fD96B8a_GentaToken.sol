pragma solidity ^0.4.24;

/**Copyright (C) 2017-2020
*All righst reserved.
*Author : Tulsa Pro Company
*/

interface GentaInterface { function receiveApproval (address _from, uint256 _value, address _token, bytes _extradata) external;}

contract GentaSecurity {
    address public owner;  ///Tulsa Pro///
    
    constructor(){ ///by Tulsa Pro//
        owner = msg.sender;
    }
    
    modifier onlyOwner { ///Genta - Network///
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership (address newOwner) onlyOwner { 
        owner = newOwner;
    }
}

contract GentaToken is GentaSecurity {

    string public name = "Genta"; 
    string public symbol = "GENA";
    uint8 public decimals = 18;
    uint256 public totalSupply; ///10*1280pixels x 0.92(percentage locked) = 11760 x 10000distribute = max supplly 117,760,000 Million GENA///
    
    mapping (address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;
    
    event Transfer ( address indexed from, address indexed to, uint256 value );
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    constructor(
        uint256 initialSupply,
        string tokenName, 
        string tokenSymbol
        ) public{
            totalSupply = initialSupply*10**uint256(decimals);
            balanceOf[msg.sender] = totalSupply;
            name = tokenName; 
            symbol = tokenSymbol; 
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to !=0x0);
        require(balanceOf[_from] >=_value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(!frozenAccount[msg.sender]);
        
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer (_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success){
        
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success){
        
        require(_value <=allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -=_value;
        _transfer(_from,_to, _value);
        return true;
    }
    
    function approve (address _spender, uint256 _value) public
    returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extradata) public returns (bool success){
        GentaInterface spender = GentaInterface(_spender);
        
        if(approve(_spender,_value)){
            spender.receiveApproval(msg.sender, _value, this, _extradata);
            return true;
        }
    }

    
    function burn (uint256 _value) onlyOwner public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success){
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
        
    }
    

    function PreMining (address target, uint256 miningAmount) onlyOwner {
        balanceOf[target] += miningAmount;
        totalSupply += miningAmount;
    }
    /// Frozen Account will be only Accepted by the Genta Network if there are Hacking activity ///
    /// We only do it if there is a Stolen from Market Exchange or Reported as a Scam ///
    function freezeAccount (address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenFunds (target, freeze);
    }
    
/** TRANSFER SECTION by Tulsa Pro - Genta Network
* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
* @param _spender The address which will spend the funds.
* @param _value The amount of tokens to be spent.
*/
        /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     * Requirements:
     * - The divisor cannot be zero.
     */
     
/**
*0x653089db8a2ac50548C401e04f48154F3B6c9b71 (Smart-Contract Deployer Address) 
*©2017-2020 by Tulsa Pro - BSC - Genta - GENA /// (codexpert) (vitalik) (satoshi) - Binance Smart-Chain
*/
}