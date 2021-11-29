# ERC20

## 来源

**ERC-20** 是一个 [以太坊](https://zh.wikipedia.org/wiki/以太坊) [区块链](https://zh.wikipedia.org/wiki/块链) 上的 [智能合约](https://zh.wikipedia.org/wiki/智能合约) 的一种协议标准。它的提出来自于EIP20

![image-20211126123331870](https://github.com/zpano/ERC20-Research/blob/main/image/image-20211126123331870.png)

## 规范

函数定义

```solidity
function name() public view returns (string)
function symbol() public view returns (string)
function decimals() public view returns (uint8)
function totalSupply() public view returns (uint256)
function balanceOf(address _owner) public view returns (uint256 balance)
function transfer(address _to, uint256 _value) public returns (bool success)
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
function approve(address _spender, uint256 _value) public returns (bool success)
function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```

事件定义

```solidity
event Transfer(address indexed _from, address indexed _to, uint256 _value)
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

## 详解

函数功能

- name    显示代币的完整名称

- symbol    显示代币的简称

- decimals    显示代币的精度

- totalSupply    显示代币的总供应量

- balanceOf    返回参数地址的余额

- transfer    给接收方地址转入指定数量的代币

- transferFrom     从授权地址转出指定数量的代币到接收方地址

- approve    授权代理地址指定数量的代币

- allowance    显示对应授权的代币数量

事件记录

- Transfer    记录转账事件的发送方，接收方，代币数量
- Approval    记录授权的授权地址，代理地址，授权代币数量

# [初始版本](https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol)

```solidity
pragma solidity ^0.4.21;

import "./EIP20Interface.sol";


contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX



    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
```

# 代码周期

## 初始化

```solidity
function EIP20(
    uint256 _initialAmount,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol
) public {
    balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
    totalSupply = _initialAmount;                        // Update total supply
    name = _tokenName;                                   // Set the name for display purposes
    decimals = _decimalUnits;                            // Amount of decimals for display purposes
    symbol = _tokenSymbol;                               // Set the symbol for display purposes
}
```

- 将合约创建者的余额设置为 _initialAmount
- 代币总供应量设置为_initialAmount
- 设置代币的name(代币完整名称)
- 设置合约的decimals(代币精度)
- 设置合约的symbol(代币简称)

## 代币转账

```solidity
mapping (address => uint256) public balances;
		function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
```

- 余额映射(地址=>余额)
- 判断发送方的余额是否大于等于转账的金额
- 减少发送方的余额
- 增加接收方的余额
- 记录转账事件
- 返回转账成功

## 授权转账

```solidity
mapping (address => mapping (address => uint256)) public allowed;
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
```

- 授权的映射(授权地址=>(代理地址=>金额))

授权函数

- 更改授权映射
- 记录授权事件

授权转账

- 获取授权映射记录的金额
- 判断授权地址的余额是否大于转账金额，且授权金额大于等于转账金额
- 减少授权转账发送方余额
- 增加授权转账接收方余额
- 判断授权金额是否小于MAX_UINT256
- 扣除对应的授权余额
- 记录转账事件
- 返回授权转账成功

## 查询功能

```solidity
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
```

- balanceOf   返回参数地址的余额

- allowance    显示对应授权的代币数量

# [OpenZeppelin版本](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20.sol)

```solidity
using SafeMath for uint256; //对于所有uint256类型变量的加减乘除操作均使用安全的数学库，防止整数溢出发生
```

新增加的函数

- increaseAllowance    增加授权
- decreaseAllowance    减少授权
- _mint    代币发行
- _burn    代币销毁
- _burnFrom    代币授权销毁

```solidity
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

```

- 判断授权地址不为零地址
- 对原授权映射进行增加，减少
- 记录新的授权事件

```solidity
  function _mint(address account, uint256 amount) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
```

- 代币发行接收地址不为零地址
- 增加代币的总供应量
- 增加接收地址的余额
- 记录转账事件

```solidity
  function _burn(address account, uint256 amount) internal {
    require(account != 0);
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }


  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
```

- 判断被销毁地址不为零地址
- 判断销毁金额小于等于被销毁账户的余额
- 减少代币总供应量
- 减少被销毁账户的余额
- 记录销毁事件
- 判断销毁金额小于等于授权的数量
- 减去相应的授权余额
- 调用销毁函数

## [ERC20Burnable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20Burnable.sol)

```solidity
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }
```

可以主动销毁

## [ERC20Capped.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20Capped.sol)

```solidity
  uint256 private _cap;

  constructor(uint256 cap)
    public
  {
    require(cap > 0);
    _cap = cap;
  }

  function cap() public view returns(uint256) {
    return _cap;
  }
  function mint(
    address to,
    uint256 amount
  )
    public
    returns (bool)
  {
    require(totalSupply().add(amount) <= _cap);

    return super.mint(to, amount);
  }

}
```

增加cap参数，保证代币不会过量发行

## [ERC20Mintable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20Mintable.sol)

```solidity
	event MintingFinished();
	bool private _mintingFinished = false;

  modifier onlyBeforeMintingFinished() {
    require(!_mintingFinished);
    _;
  }
  function mint(
    address to,
    uint256 amount
  )
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mint(to, amount);
    return true;
  }

  function finishMinting()
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mintingFinished = true;
    emit MintingFinished();
    return true;
  }
}
```

通过将_mintingFinished设置为ture，使得无法在发行代币

## [ERC20Pausable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20Pausable.sol)

```solidity
function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}
```

通过增加whenNotPaused，可以实现代币暂停交易，无法转账，授权，授权转账，增加/减少授权

## [SafeERC20.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/SafeERC20.sol)

```solidity
library SafeERC20 {
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    require(token.approve(spender, value));
  }
}
```

通过`using SafeERC20 for ERC20`引入三个安全函数，通过token.safeTransfer进行安全转账

## [TokenTimelock](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/TokenTimelock.sol)

```solidity
  IERC20 private _token;

  // beneficiary of tokens after they are released
  address private _beneficiary;

  // timestamp when token release is enabled
  uint256 private _releaseTime;

  constructor(
    IERC20 token,
    address beneficiary,
    uint256 releaseTime
  )
    public
  {
    // solium-disable-next-line security/no-block-members
    require(releaseTime > block.timestamp);
    _token = token;
    _beneficiary = beneficiary;
    _releaseTime = releaseTime;
  }

  function token() public view returns(IERC20) {
    return _token;
  }
  function beneficiary() public view returns(address) {
    return _beneficiary;
  }
  function releaseTime() public view returns(uint256) {
    return _releaseTime;
  }

  function release() public {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= _releaseTime);

    uint256 amount = _token.balanceOf(address(this));
    require(amount > 0);

    _token.safeTransfer(_beneficiary, amount);
  }
}
```

将 token 锁定至指定时间，之后才可以进行转账交易。例如允许顾问在一年之后才可以提取释放的 token

