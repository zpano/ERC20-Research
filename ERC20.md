# ERC20

## 来源

**ERC-20** 是一个 [以太坊](https://zh.wikipedia.org/wiki/以太坊) [区块链](https://zh.wikipedia.org/wiki/块链) 上的 [智能合约](https://zh.wikipedia.org/wiki/智能合约) 的一种协议标准。它的提出来自于EIP20

![image-20211126123331870](../image/image-20211126123331870.png)

## 规范详解

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

